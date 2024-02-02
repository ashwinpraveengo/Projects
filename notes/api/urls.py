from django.urls import path
from . import views


urlpatterns = [
    path('', views.getRoutes),
    path("notes/", views.getNotes),
    path("notes/create/",views.createNote),
    path("notes/<int:pk>/", views.getNote),
    path("notes/<int:pk>/update/",views.updateNote),
    path("notes/<int:pk>/delete/",views.deleteNote),
    
]
