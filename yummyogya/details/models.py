# details/models.py
from django.db import models
from django.contrib.auth.models import User
from main.models import Makanan
from dashboard.models import Food

class Review(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)  # Menghubungkan ke pengguna yang membuat ulasan
    food = models.ForeignKey(Makanan, null=True, blank=True, on_delete=models.CASCADE)  # Menghubungkan ke makanan di main.models
    food_alt = models.ForeignKey(Food, null=True, blank=True, on_delete=models.CASCADE)  # Menghubungkan ke makanan di dashboard.models
    review = models.TextField()  # Teks ulasan
    rating = models.IntegerField(choices=[(i, i) for i in range(1, 6)])  # Rating 1-5
    created_at = models.DateTimeField(auto_now_add=True)  # Tanggal ulasan dibuat

    def __str__(self):
        return f"Review by {self.user.username} for {self.food or self.food_alt}"
