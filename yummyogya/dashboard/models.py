# Create your models here.
from django.db import models
from django.contrib.auth.models import User

class Food(models.Model):
    name = models.CharField(max_length=100)
    price = models.IntegerField()  
    description = models.TextField()
    category = models.CharField(max_length=100)
    restaurant = models.CharField(max_length=100)
    rating = models.DecimalField(max_digits=2, decimal_places=1, default=0)
    image_url = models.URLField() 
    created_by = models.ForeignKey(User, on_delete=models.CASCADE) 
    def _str_(self):
        return self.name