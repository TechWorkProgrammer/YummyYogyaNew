from django.test import TestCase, Client
from django.urls import reverse
from django.contrib.auth.models import User
from main.models import Makanan
from .models import Wishlist

class WishlistTestCase(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(username='testuser', password='testpass')
        self.client.login(username='testuser', password='testpass')

        self.food_item = Makanan.objects.create(
            nama='Test Food', 
            deskripsi='Test description', 
            kategori='Camilan', 
            restoran='Test Restoran', 
            harga=10000, 
            rating=4.5
        )

    def test_add_to_wishlist(self):
        response = self.client.post(reverse('wishlist:add_to_wishlist', args=[self.food_item.id]))
        self.assertEqual(response.status_code, 200)
        self.assertTrue(Wishlist.objects.filter(user=self.user, food=self.food_item).exists())

    def test_view_wishlist(self):
        wishlist = Wishlist.objects.create(user=self.user)
        wishlist.food.add(self.food_item)
        response = self.client.get(reverse('wishlist:view_wishlist'))
        self.assertEqual(response.status_code, 200)
        self.assertTemplateUsed(response, 'wishlist.html')

    def test_remove_from_wishlist(self):
        wishlist = Wishlist.objects.create(user=self.user)
        wishlist.food.add(self.food_item)
        response = self.client.post(reverse('wishlist:remove_from_wishlist', args=[self.food_item.id]))
        self.assertEqual(response.status_code, 302)  # Expect redirect
        self.assertFalse(Wishlist.objects.filter(user=self.user, food=self.food_item).exists())
