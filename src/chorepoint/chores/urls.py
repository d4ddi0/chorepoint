from django.conf.urls import patterns, include, url

from chores import views

urlpatterns = patterns('',
    # Examples:
    # url(r'^$', 'chorepoint.views.home', name='home'),
    # url(r'^chorepoint/', include('chorepoint.foo.urls')),

    url(r'^$', views.index, name='index'),
    url(r'^(?P<task_id>\d+)/$', views.detail, name='detail'),
    url(r'^user/(?P<user_id>\d+)/$', views.userdetail, name='userdetail'),
    url(r'^(?P<task_id>\d+)/results/$', views.results, name='results'),
    url(r'^(?P<task_id>\d+)/vote/$', views.vote, name='vote'),
)
