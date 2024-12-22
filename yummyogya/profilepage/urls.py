from django.urls import path
from . import views

app_name = 'profilepage'

urlpatterns = [
    path('profile/', views.show_profile, name='show_profile'),
    path('profile/update/', views.update_profile, name='update_profile'),
    path('change_password/', views.change_password, name='change_password'),
    path('profile/api/', views.get_profile_flutter, name='get_profile_flutter'),
    path('profile/update/api/', views.update_profile_flutter, name='update_profile_flutter'),
    path('profile/change-password/api/', views.change_password_flutter, name='change_password_flutter'),

]
