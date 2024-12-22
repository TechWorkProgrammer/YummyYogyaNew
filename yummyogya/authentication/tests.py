from django.test import TestCase
from django.contrib.auth.models import User
from django.urls import reverse
import datetime

# Create your tests here.

class AuthenticationTests(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(username='testuser', password='password123')
    
    def test_register_user(self):
        response = self.client.post(reverse('authentication:register'), {
            'username': 'newuser',
            'password1': 'newpassword123',
            'password2': 'newpassword123'
        })
        # Redirect jika berhasil registrasi, cek apakah new user ada di database.
        # Redirect ke login page, cek message success
        self.assertEqual(response.status_code, 302)
        self.assertTrue(User.objects.filter(username='newuser').exists())
        response = self.client.get(reverse('authentication:login'))
        self.assertContains(response, 'Your account has been successfully created!')
        
    def test_register_user_password_mismatch(self):
        response = self.client.post(reverse('authentication:register'), {
            'username': 'newuser',
            'password1': 'newpassword123',
            'password2': 'differentpassword'
        })
        # Ketika password mismatch, akan stay di form registrasi lalu menampilkan message error.
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, "Password confirmation: The two password fields didn’t match.")

    def test_login_user(self):
        response = self.client.post(reverse('authentication:login'), {
            'username': 'testuser',
            'password': 'password123'
        })
        # Ketika berhasil login akan redirect ke main page, dan menyimpan cookie.
        self.assertEqual(response.status_code, 302)
        self.assertRedirects(response, reverse('main:show_main'))
        self.assertEqual(response.cookies['last_login'].value[:10], str(datetime.datetime.now())[:10]) 

    def test_login_user_incorrect_credentials(self):
        response = self.client.post(reverse('authentication:login'), {
            'username': 'testuser',
            'password': 'wrongpassword'
        })
        # Ketika login gagal, akan stay di form login dan menampilkan message error. Tidak ada login session yang dibuat.
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, "Username atau password salah.")
        self.assertNotIn('_auth_user_id', self.client.session)

    def test_logout_user(self):
        self.client.login(username='testuser', password='password123')
        response = self.client.get(reverse('authentication:logout'))
        # Setelah logout akan redirect ke main page, user session cleared dan cookie last login expired.
        self.assertEqual(response.status_code, 302)
        self.assertRedirects(response, reverse('main:show_main'))
        self.assertNotIn('_auth_user_id', self.client.session)
        self.assertEqual(response.cookies['last_login'].value, "")
