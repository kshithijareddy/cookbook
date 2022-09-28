from django.urls import path
from django.contrib import admin
from django.conf.urls import url
from spiceroom import views

urlpatterns = [
    url(r'^admin/', admin.site.urls),
    url(r'^$', views.index, name='home'),
    url(r'^recipes/$', views.getAllRecipes, name='getAllRecipes'),
    url(r'^recipecount/$', views.getRecipesCount, name='getRecipesCount'),
    path("getrecipe/<id>", views.getRecipe, name="getRecipe"),
    path("getimage/<name>", views.getImage, name="getImage"),
    path("getingredient/<name>", views.getIngredient, name="getIngredient"),
]
