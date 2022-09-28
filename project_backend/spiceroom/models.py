from django.db import models

class Ingredient(models.Model):
    id = models.AutoField(primary_key=True)
    name = models.CharField(max_length=100)
    isVegan = models.BooleanField(default=True)
    image = models.CharField(max_length=100, default="")
    img = models.ImageField(upload_to='spiceroom/images/', blank=True)
    def __str__(self):
        return self.name

class Category(models.Model):
    id = models.AutoField(primary_key=True)
    name = models.CharField(max_length=100)
    def __str__(self):
        return self.name

class Measurement(models.Model):
    id = models.AutoField(primary_key=True)
    name = models.CharField(max_length=100)
    def __str__(self):
        return self.name

class Recipe(models.Model):
    id = models.AutoField(primary_key=True)
    name = models.CharField(max_length=100)
    description = models.TextField()
    duration = models.CharField(max_length=100)
    category = models.ForeignKey(Category, on_delete=models.CASCADE)
    items = models.TextField()
    steps = models.TextField()
    image = models.CharField(max_length=100, default="")
    img = models.ImageField(upload_to='spiceroom/images/', blank=True)
    def __str__(self):
        return self.name
    
    