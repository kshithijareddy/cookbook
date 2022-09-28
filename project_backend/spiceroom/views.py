import json
from urllib import response
from django.shortcuts import render
from django.conf.urls import url
from django.http import JsonResponse, HttpResponse
from django.forms.models import model_to_dict
from rest_framework.decorators import api_view
from .models import Ingredient, Category, Measurement, Recipe

images_path = "spiceroom/images/"

@api_view(["GET"])
def index(request):
    return JsonResponse({'message': 'Hello, Mani and Shitty!'})

# getAllRecipes returns all recipes in the database 
@api_view(["GET"])
def getAllRecipes(request):
    recipes = [model_to_dict(recipe) for recipe in Recipe.objects.all()]
    response = {"results": []}
    for recipe in recipes:
        response['results'].append({
            'id': recipe['id'],
            'name': recipe['name'],
            'description': recipe['description'],
            'duration': recipe['duration'],
            'category': recipe['category'],
            'items': json.loads(recipe['items']),
            'steps': json.loads(recipe['steps']),
            'imageName': recipe['image']
        })
    return JsonResponse(response, safe=False)

# getRecipesCount returns the number of recipes in the database
@api_view(["GET"])
def getRecipesCount(request):
    return JsonResponse(Recipe.objects.count(), safe=False)

# getRecipe returns a recipe with the given id
@api_view(["GET"])
def getRecipe(request, id):
    id = str(id)
    recipe = Recipe.objects.get(id=id)
    recipe = model_to_dict(recipe)
    recipe['items'] = json.loads(recipe['items'])
    recipe['steps'] = json.loads(recipe['steps'])
    recipe['img'] = ""
    return JsonResponse(recipe, safe=False)

# getImage returns the image with the given name
@api_view(["GET"])
def getImage(request, name):
    name = str(name)
    image_data = open(images_path + name, "rb").read()
    return HttpResponse(image_data, content_type="image/jpeg")

# getIngredient returns the ingredient with the given name
@api_view(["GET"])
def getIngredient(request, name):
    name = str(name)
    ingredient = Ingredient.objects.get(name=name)
    ingredient = model_to_dict(ingredient)
    ingredient['img'] = ""
    return JsonResponse(ingredient, safe=False)