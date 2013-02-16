from django.conf.urls import patterns, include, url
from chores import views

# Uncomment the next two lines to enable the admin:
from django.contrib import admin
admin.autodiscover()

urlpatterns = patterns('',
    # Examples:
    # url(r'^$', 'chorepoint.views.home', name='home'),
    # url(r'^chorepoint/', include('chorepoint.foo.urls')),

    # Uncomment the admin/doc line below to enable admin documentation:
    url(r'^admin/doc/', include('django.contrib.admindocs.urls')),

    # Uncomment the next line to enable the admin:
    url(r'^admin/', include(admin.site.urls)),
    url(r'^chores/', include('chores.urls')),
    url(r'^$', views.index, name='index'),
)
