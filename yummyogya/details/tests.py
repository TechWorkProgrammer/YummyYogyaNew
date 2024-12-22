# details/tests.py
from django.test import TestCase, Client
from django.urls import reverse
from .models import Review
from main.models import Makanan
from django.contrib.auth.models import User
import json

class DetailsTests(TestCase):
    def setUp(self):
        # Setup user
        self.user = User.objects.create_user(username='testuser', password='testpass')
        self.client = Client()
        self.client.login(username='testuser', password='testpass')

        # Setup food item with a default rating to avoid NULL constraint errors
        self.food = Makanan.objects.create(
            nama='Nasi Goreng',
            deskripsi='Nasi goreng enak',
            harga=15000,
            gambar='link_to_image.jpg',
            rating=0  # Ensure this field has a default value
        )

    def test_add_review(self):
        # Test adding a review for the food item
        response = self.client.post(reverse('details:add_review'), data=json.dumps({
            'rating': 5,
            'review': 'Delicious!',
            'food_id': self.food.id
        }), content_type='application/json')

        # Assertions to verify the correct response and data handling
        self.assertEqual(response.status_code, 200)
        self.assertJSONEqual(response.content, {'message': 'Review added successfully!', 'status': 'success'})
        self.assertEqual(Review.objects.count(), 1)
        self.assertEqual(Review.objects.first().review, 'Delicious!')
        self.food.refresh_from_db()
        self.assertEqual(self.food.rating, 5.0)

    def test_food_detail_view(self):
        # Test retrieving the food detail page for the specific food item
        response = self.client.get(reverse('details:food_detail', args=[self.food.id]))
        self.assertEqual(response.status_code, 200)
        self.assertTemplateUsed(response, 'food_detail.html')
        self.assertContains(response, self.food.nama)
        self.assertContains(response, self.food.deskripsi)