from django.urls import path
from article.views import article_list, create_article, show_xml, show_json, show_json_by_id, show_xml_by_id, article_detail, create_article_ajax
from article.views import edit_article, delete_article, create_article_flutter

app_name = 'article'

urlpatterns = [
    path('',article_list, name='article_list'),
    path('load_more/', article_list, name='load_more_articles'),
    path('create/', create_article, name='create_article'),
    path('<uuid:id>/', article_detail, name='article_detail'),
    path('xml/', show_xml, name='show_xml'),
    path('json/', show_json, name='show_json'),
    path('json/<str:id>/', show_json_by_id, name='show_json_by_id'),
    path('xml/<str:id>/', show_xml_by_id, name='show_xml_by_id'),
    path('create-ajax/', create_article_ajax, name='create_article_ajax'),
    path('edit/<uuid:id>/', edit_article, name='edit_article'),
    path('delete/<uuid:id>/', delete_article, name='delete_article'),
    path('create-flutter/', create_article_flutter, name='create_article_flutter'),
]