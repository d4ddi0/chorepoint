from django.db import models
from django.contrib.auth.models import User

# Create your models here.

class Task(models.Model):
    '''A Task is a unit of work that will be tracked'''
    name = models.CharField(max_length=16)
    description = models.CharField(max_length=200)
    individual = models.BooleanField(help_text='If true, task frequency is per individual (e.g. making your bed), otherwise there is one task available (e.g. wash the dishes).')
    minFrequency= models.IntegerField()
    maxFrequency = models.IntegerField()
    frequencyUnits = models.IntegerField(choices=((1, 'Day'), (7, 'Week'),
    (14, 'BiWeek'), (30, 'Month'), (365, 'Year')))
    value = models.IntegerField()

    def __unicode__(self):
        return self.name

class SubTask(models.Model):
    '''Specific work needing to be done to complete the Task'''
    chore = models.ForeignKey(Task)
    description = models.CharField(max_length=40)

    def __unicode__(self):
        return self.description



class Chore(models.Model):
    '''A is a specific instance of a Task being done'''
    user = models.ForeignKey(User)
    chore = models.ForeignKey(Task)
    date = models.DateTimeField('date done')
    adjustment = models.IntegerField()
    comment = models.CharField(max_length=200)
    adminComment = models.CharField(max_length=200)

    def __unicode__(self):
        return self.chore.name + ' on ' + self.date

