from django.contrib.auth.models import User
from django.db import models
from main.models import Makanan

class Wishlist(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)

    def __str__(self):
        return f"{self.user.username}'s Wishlist"

class WishlistItem(models.Model):
    wishlist = models.ForeignKey(Wishlist, on_delete=models.CASCADE, related_name='items')
    food = models.ForeignKey(Makanan, on_delete=models.CASCADE)
    notes = models.TextField(blank=True, null=True, max_length=500)

    class Meta:
        unique_together = ('wishlist', 'food')

    def __str__(self):
        return f"{self.food.nama} in {self.wishlist.user.username}'s Wishlist"