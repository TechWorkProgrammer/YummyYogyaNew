from django.test import TestCase, Client
from django.urls import reverse
from django.contrib.auth.models import User
from .models import Profile

# Create your tests here.

class ProfileTest(TestCase):
    def setUp(self):
        self.client = Client()
        self.user = User.objects.create_user(username='testuser', password='testpassword')
        Profile.objects.create(user=self.user)
    
    def test_show_profile_accessibility(self):
        # Cek page profile bisa diakses dan template benar.
        self.client.login(username='testuser', password='testpassword')
        response = self.client.get(reverse('profilepage:show_profile'))
        self.assertEqual(response.status_code, 200)
        self.assertTemplateUsed(response, 'profile.html')

    def test_show_profile_content(self):
        # Cek apakah informasi pengguna, wishlist, dan ulasan muncul di profile page.
        self.client.login(username='testuser', password='testpassword')
        response = self.client.get(reverse('profilepage:show_profile'))
        self.assertContains(response, self.user.username)
        self.assertIn('wishlist_items', response.context)
        self.assertIn('reviews', response.context)
        self.assertIn('last_login', response.context)

    def test_update_profile_success(self):
        # Cek jika update profile berhasil, apakah berhasil terupdate.
        self.client.login(username='testuser', password='testpassword')
        response = self.client.post(reverse('profilepage:update_profile'), {
            'bio': 'Updated bio',
            'delete_photo': False
        }, HTTP_X_REQUESTED_WITH='XMLHttpRequest')
        self.assertEqual(response.status_code, 200)
        self.assertJSONEqual(response.content, {'success': True})
        self.user.profile.refresh_from_db()
        self.assertEqual(self.user.profile.bio, 'Updated bio')

    def test_change_password_success(self):
        # Cek setelah berhasil ganti password, apakah password berhasil terganti.
        self.client.login(username='testuser', password='testpassword')
        response = self.client.post(reverse('profilepage:change_password'), {
            'old_password': 'testpassword',
            'new_password1': 'newpassword123',
            'new_password2': 'newpassword123',
        }, HTTP_X_REQUESTED_WITH='XMLHttpRequest')
        self.assertEqual(response.status_code, 200)
        self.assertJSONEqual(response.content, {'success': True})
        self.user.refresh_from_db()
        self.assertTrue(self.user.check_password('newpassword123'))

    def test_change_password_mismatch(self):
        # Cek jika password mismatch, apakah akan gagal ganti password dengan menampilkan message.
        self.client.login(username='testuser', password='testpassword')
        response = self.client.post(reverse('profilepage:change_password'), {
            'old_password': 'testpassword',
            'new_password1': 'newpassword123',
            'new_password2': 'differentpassword',
        }, HTTP_X_REQUESTED_WITH='XMLHttpRequest')
        self.assertEqual(response.status_code, 200)
        # Pastikan pesan error dikirim karena password tidak cocok
        self.assertIn('errors', response.json())
        self.assertFalse(self.user.check_password('newpassword123'))

    def test_change_password_incorrect_old_password(self):
        # Cek jika salah input password lama, apakah gagal ganti password dengan menampilkan message.
        self.client.login(username='testuser', password='testpassword')
        response = self.client.post(reverse('profilepage:change_password'), {
            'old_password': 'wrongpassword',
            'new_password1': 'newpassword123',
            'new_password2': 'newpassword123',
        }, HTTP_X_REQUESTED_WITH='XMLHttpRequest')
        self.assertEqual(response.status_code, 200)
        self.assertIn('errors', response.json())
        self.user.refresh_from_db()
        self.assertTrue(self.user.check_password('testpassword'))