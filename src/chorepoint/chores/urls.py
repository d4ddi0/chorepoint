from django.conf.urls import patterns, include, url

from chores import views

urlpatterns = patterns('',
    # Examples:
    # url(r'^$', 'chorepoint.views.home', name='home'),
    # url(r'^chorepoint/', include('chorepoint.foo.urls')),

    # Uncomment the next line to enable the admin:
    url(r'^$', views.index, name='index'),
)
