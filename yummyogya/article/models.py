from django.db import models
from django.contrib.auth.models import User
import uuid

class ArticleEntry(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    title = models.CharField(max_length=200, verbose_name="Title")
    content = models.TextField()
    published_date = models.DateTimeField(auto_now_add=True)
    image_url = models.CharField(max_length=1000, verbose_name="Image URL")

    def __str__(self):
        return self.title

    def get_absolute_url(self):
        from django.urls import reverse
        return reverse('article_detail', args=[str(self.id)])