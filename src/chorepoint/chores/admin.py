#!/usr/bin/env python
from chores.models import Chore, Task, SubTask
from django.contrib import admin

class SubTaskAdmin(admin.StackedInline):
    model = SubTask
    extra = 3

class TaskAdmin(admin.ModelAdmin):
    fieldsets = [(None, {'fields':  ['name', 'description', 'value', 'individual',]}),
                 ('Frequency', {'fields': ['minFrequency', 'maxFrequency', 'frequencyUnits',]}),]
    inlines = [SubTaskAdmin,]

admin.site.register(Task, TaskAdmin)

admin.site.register(Chore)
