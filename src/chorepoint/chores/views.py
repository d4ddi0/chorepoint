from django.http import HttpResponse

# Create your views here.
def index(request):
    return HttpResponse("<h1> Hello, world. You're at the chores index. </h1>")

