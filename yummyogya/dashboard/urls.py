from django.urls import path
from .views import dashboard, add_food, edit_food, delete_food, get_foods,user_dashboard, add_food_flutter,get_food_list,delete_food_flutter,dashboard_data,  get_user_id, update_food_flutter
app_name = 'dashboard'

urlpatterns = [
    path('dashboard/', dashboard, name='dashboard'),
    path('add_food/', add_food, name='add_food'),
    path('edit_food/<int:id>/', edit_food, name='edit_food'),
    path('delete_food/<int:id>/', delete_food, name='delete_food'),
    path('foods/', get_foods, name='get_foods'), 
    path('api/dashboard/', user_dashboard, name='user_dashboard'),
    path('add_food_flutter/', add_food_flutter, name='add_food_flutter'),
    path('get_food_list/', get_food_list, name='get_food_list'),
    path('delete_food_flutter/<int:food_id>/', delete_food_flutter, name='delete_food_flutter'),
    path('api/dashboard/', dashboard_data, name='dashboard_data'),
    path('api/get_user_id', get_user_id, name='get_user_id'),
    path('update_food_flutter/<int:food_id>/', update_food_flutter, name='update_food_flutter'),


]

