from django.test import TestCase, Client
from django.urls import reverse
from django.contrib.auth.models import User
from .models import Makanan
from dashboard.models import Food
import json

class MainViewTests(TestCase):
    def setUp(self):
        # Create a test user
        self.user = User.objects.create_user(username='testuser', password='testpass')
        
        # Create sample Makanan instances
        Makanan.objects.create(nama="Nasi Goreng", deskripsi="Delicious fried rice", kategori="Main Course", restoran="Food Place", harga=20000, rating=4.5, gambar="http://example.com/nasigoreng.jpg")
        Makanan.objects.create(nama="Sate Ayam", deskripsi="Grilled chicken skewers", kategori="Appetizer", restoran="Sate House", harga=15000, rating=4.7, gambar="http://example.com/sateayam.jpg")
        
        # Create Food items specific to the user
        Food.objects.create(name="User's Special Dish", description="Only visible to the user", category="Special", restaurant="User's Place", price=30000, rating=4.9, image_url="http://example.com/userdish.jpg", created_by=self.user)
        
        # Initialize client
        self.client = Client()

    def test_show_main_view_status_code(self):
        # Test that the main page loads successfully
        response = self.client.get(reverse('main:show_main'))
        self.assertEqual(response.status_code, 200)
        self.assertTemplateUsed(response, 'main.html')

    def test_show_main_context_data(self):
        # Test that the main view includes Makanan in the context
        response = self.client.get(reverse('main:show_main'))
        self.assertContains(response, "Nasi Goreng")
        self.assertContains(response, "Sate Ayam")
        
    def test_show_main_context_data_authenticated_user(self):
        # Test that a logged-in user sees their own Food items
        self.client.login(username='testuser', password='testpass')
        response = self.client.get(reverse('main:show_main'))
        
        # Check that user's Food item is visible in the response
        self.assertContains(response, "User's Special Dish")
        self.assertContains(response, "Only visible to the user")
        
    def test_search_functionality(self):
        # Test the search functionality for unauthenticated users
        response = self.client.get(reverse('main:show_main') + '?q=Nasi')
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, "Nasi Goreng")
        self.assertNotContains(response, "Sate Ayam")
        
        # Test the search functionality for authenticated users
        self.client.login(username='testuser', password='testpass')
        response = self.client.get(reverse('main:show_main') + '?q=User')
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, "User's Special Dish")
        
    def test_ajax_search_unauthenticated(self):
        # Test the AJAX search functionality without user authentication
        response = self.client.get(reverse('main:search_ajax') + '?q=Sate', HTTP_X_REQUESTED_WITH='XMLHttpRequest')
        
        self.assertEqual(response.status_code, 200)
        
        # Check that the response is JSON
        response_data = json.loads(response.content)
        self.assertEqual(len(response_data['makanan_list']), 1)
        self.assertEqual(response_data['makanan_list'][0]['nama'], "Sate Ayam")

    def test_ajax_search_authenticated_user(self):
        # Test the AJAX search functionality for an authenticated user
        self.client.login(username='testuser', password='testpass')
        response = self.client.get(reverse('main:search_ajax') + '?q=User', HTTP_X_REQUESTED_WITH='XMLHttpRequest')
        
        self.assertEqual(response.status_code, 200)
        
        # Check that the response includes user's Food item
        response_data = json.loads(response.content)
        self.assertEqual(len(response_data['makanan_list']), 1)
        self.assertEqual(response_data['makanan_list'][0]['nama'], "User's Special Dish")

    def test_pagination_main_view(self):
        # Ensure pagination works in the main view with more than 8 items
        for i in range(10):
            Makanan.objects.create(
                nama=f"Dish {i}", deskripsi="Sample dish", kategori="Appetizer",
                restoran="Sample Place", harga=10000 + i, rating=4.0 + (i * 0.1),
                gambar="http://example.com/sample.jpg"
            )
        
        response = self.client.get(reverse('main:show_main'))
        self.assertEqual(response.status_code, 200)
        
        # Check if pagination displays only 8 items on the first page
        page_obj = response.context['page_obj']
        self.assertEqual(len(page_obj), 8)
        
    def test_pagination_ajax_search(self):
        # Create additional Makanan items for pagination testing
        for i in range(10):
            Makanan.objects.create(
                nama=f"SearchDish {i}", deskripsi="Paginated search item", kategori="Appetizer",
                restoran="Sample Place", harga=10000 + i, rating=4.0 + (i * 0.1),
                gambar="http://example.com/sample.jpg"
            )

        # Perform paginated AJAX search
        response = self.client.get(reverse('main:search_ajax') + '?q=SearchDish&page=2', HTTP_X_REQUESTED_WITH='XMLHttpRequest')
        self.assertEqual(response.status_code, 200)
        
        response_data = json.loads(response.content)
        
        # Check that items returned are the second page results (should be 2 in this setup)
        self.assertEqual(len(response_data['makanan_list']), 2)
        self.assertIsNotNone(response_data['previous_page'])
        self.assertIsNone(response_data['next_page'])  # Only 2 pages in total

    def test_show_json(self):
        # Test the JSON view
        response = self.client.get(reverse('main:show_json'))
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response['Content-Type'], 'application/json')

    def test_show_xml(self):
        # Test the XML view
        response = self.client.get(reverse('main:show_xml'))
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response['Content-Type'], 'application/xml')
