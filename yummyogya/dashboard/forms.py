from django import forms
from .models import Food

class FoodForm(forms.ModelForm):
    class Meta:
        model = Food
        fields = ['name', 'price', 'description', 'category', 'restaurant', 'rating', 'image_url']