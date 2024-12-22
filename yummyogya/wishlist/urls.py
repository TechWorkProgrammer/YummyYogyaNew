from django.urls import path
from . import views

app_name = 'wishlist'

urlpatterns = [
    path('add/<int:food_id>/', views.add_to_wishlist, name='add_to_wishlist'),
    path('wishlist/add_wishlist_flutter/', views.add_to_wishlist_flutter, name='add_wishlist_flutter'),
    path('wishlist/', views.view_wishlist, name='view_wishlist'),
    path('wishlist/get_wishlist/', views.get_wishlist_json, name='get_wishlist'),
    path('wishlist/remove-from-wishlist/<int:food_id>/', views.remove_from_wishlist, name='remove_from_wishlist'),
    path('wishlist/update-notes/<int:food_id>/', views.update_wishlist_item_notes, name='update_wishlist_item_notes'),
    path('wishlist/remove-wishlist/<int:food_id>/', views.remove_wishlist, name='remove_wishlist'),
]
