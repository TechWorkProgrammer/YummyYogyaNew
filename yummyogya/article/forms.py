from typing import Any
from django.forms import ModelForm
from article.models import ArticleEntry
from django.utils.html import strip_tags

class ArticleForm(ModelForm):
    class Meta:
        model = ArticleEntry
        fields = ['title', 'content', 'image_url']

    def clean_title(self):
        title = self.cleaned_data['title']
        return strip_tags(title)

    def clean_content(self):
        content = self.cleaned_data['content']
        return strip_tags(content)
    
    def clean_image_url(self):
        image_url = self.cleaned_data['image_url']
        return strip_tags(image_url)