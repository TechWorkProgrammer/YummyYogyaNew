from django.urls import path, include
from main.views import show_main,search_ajax, show_xml, show_json, show_json_by_id, show_xml_by_id
from details.views import food_detail, add_review
from article.views import article_list

app_name = 'main'

urlpatterns = [
    path('', show_main, name='show_main'),
    path('search-ajax/', search_ajax, name='search_ajax'),
    path('xml/', show_xml, name='show_xml'),
    path('json/', show_json, name='show_json'),
    path('xml/<str:id>/', show_xml_by_id, name='show_xml_by_id'),
    path('json/<str:id>/', show_json_by_id, name='show_json_by_id'),
    path('details/<int:id>/', food_detail, name='food_detail'),
    path('details/add_review/', add_review, name='add_review'),
    path('article/', article_list, name='article_list'),
    path('authentication/', include('authentication.urls')),  # Include URLs dari modul authentication
]