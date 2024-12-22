from django.test import TestCase
from django.urls import reverse
from django.contrib.auth import get_user_model
from .models import Food
from django.contrib.auth.models import User


class FoodViewTests(TestCase):

    def setUp(self):
        self.user = User.objects.create_user(username='testuser', password='testpass')
        self.client.login(username='testuser', password='testpass')  # Log the user in

    def test_add_food(self):
        food_data = {
            'name': 'Pizza',
            'price': 20,
            'description': 'Delicious cheese pizza',
            'category': 'Fast Food',
            'restaurant': 'Pizza Place'
        }

        response = self.client.post(reverse('dashboard:add_food'), food_data)
