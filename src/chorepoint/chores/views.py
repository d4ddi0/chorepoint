from django.shortcuts import render
from django.http import HttpResponseRedirect
from django.contrib.auth.models import User
from chores.models import Chore, Task, SubTask, ChoreForm
import datetime

#trackingduration needs a better home... but where?
tracking_duration = datetime.timedelta(30)

# Create your views here.
def index(request):
    userlist = User.objects.all()
    cutoff_date = datetime.date.today() - tracking_duration
    chorelist = Chore.objects.filter(date__gte=cutoff_date)
    tasklist = Task.objects.all()
    for task in tasklist:
        task.userpoints = {
                user: sum (
                    [ chore.task.value + chore.adjustment for
                        chore in chorelist if
                        chore.user == user and
                        chore.task == task ]
                ) for user in userlist
            }
        task.nextuser = min(task.userpoints, key=task.userpoints.get)
    for user in userlist:
        user.points = sum ([ task.userpoints[user] for task in tasklist ])
        usertasklist = [x for x in tasklist if x.nextuser == user]
        if usertasklist:
            user.nexttask = max(usertasklist, key=lambda x: x.userpoints[user])
        else:
            user.nexttask = Task(name="All caught up")
#    userlist.sort(key=lambda x: x.points)        
#    tasklist.sort(key=lambda x: x.priority)
    return render(request, 'chores/index.html',
            {'tasklist' :tasklist, 'userlist': userlist })


def detail(request, task_id):
    task = Task.objects.get(id=task_id)
    task.subtasklist = SubTask.objects.filter(task=task_id)
    if request.method == 'POST':
        form = ChoreForm(request.POST)
        if form.is_valid():
            chore = form.save(commit=False)
            chore.task_id = task_id
            chore.save()
            return HttpResponseRedirect('/')

    else:
        form = ChoreForm()
    #return render(request, 'chores/accepttask.html', {'task' :task })
    return render(request, 'chores/accepttask.html', {'task' :task, 'form': form })

def results(request, task_id):
    return HttpResponse("You're looking at the results of poll %s." % task_id)

def vote(request, task_id):
    return HttpResponse("You're voting on poll %s." % task_id)
