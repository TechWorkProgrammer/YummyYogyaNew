# article/tests.py
from django.test import TestCase, Client
from django.urls import reverse
from .views import ARTICLESLIST, ARTICLESDETAIL

class ArticleViewTests(TestCase):
    def setUp(self):
        self.client = Client()

    def test_article_list_view(self):
        response = self.client.get(reverse('article:article_list'))
        self.assertEqual(response.status_code, 200)
        self.assertTemplateUsed(response, 'article_list.html')
        self.assertContains(response, 'Artikel Kuliner Yogyakarta')
        self.assertTrue('page_obj' in response.context)
        self.assertEqual(len(response.context['page_obj']), 3)

    def test_article_detail_view(self):
        for article in ARTICLESDETAIL:
            response = self.client.get(reverse('article:article_detail', args=[article['id']]))
            self.assertEqual(response.status_code, 200)
            self.assertTemplateUsed(response, 'article_detail.html')
            self.assertContains(response, article['title'])
            self.assertContains(response, article['content'])

    def test_load_more_articles(self):
        response = self.client.get(reverse('article:load_more_articles'), {'page': 2}, HTTP_X_REQUESTED_WITH='XMLHttpRequest')
        self.assertEqual(response.status_code, 200)
        self.assertTrue(response.json()['has_next'])
        self.assertEqual(len(response.json()['articles']), 3)