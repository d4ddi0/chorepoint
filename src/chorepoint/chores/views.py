from django.http import HttpResponse
from django.template import Context, loader
from django.contrib.auth.models import User
from chores.models import Chore, Task
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
    template  = loader.get_template('chores/index.html')
    context = Context({ 'tasklist' :tasklist, 'userlist': userlist })
    return HttpResponse(template.render(context))


def detail(request, task_id):
    return HttpResponse("You're looking at poll %s." % task_id)

def results(request, task_id):
    return HttpResponse("You're looking at the results of poll %s." % task_id)

def vote(request, task_id):
    return HttpResponse("You're voting on poll %s." % task_id)
