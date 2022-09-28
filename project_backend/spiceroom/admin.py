from django.contrib import admin
from spiceroom.models import Ingredient, Category, Measurement, Recipe

# Register your models here.
class IngredientAdmin(admin.ModelAdmin):
    list_display = ('name', 'isVegan')
admin.site.register(Ingredient, IngredientAdmin)

class CategoryAdmin(admin.ModelAdmin):
    list_display = ['name']
admin.site.register(Category, CategoryAdmin)

class MeasurementAdmin(admin.ModelAdmin):
    list_display = ['name']
admin.site.register(Measurement, MeasurementAdmin)

class RecipeAdmin(admin.ModelAdmin):
    list_display = ('name', 'duration', 'category')
admin.site.register(Recipe, RecipeAdmin)