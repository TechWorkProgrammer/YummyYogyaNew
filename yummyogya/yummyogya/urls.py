from django.contrib import admin
from django.urls import path, include
from django.conf.urls.static import static
from django.conf import settings


urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include('main.urls')),
    path('article/', include('article.urls')),
    path('details/', include('details.urls')),
    path('wishlist/', include('wishlist.urls')),    # wishlist URL hanya di sini
    path('dashboard/', include('dashboard.urls')),  # dashboard URL seharusnya hanya di sini
    path('profilepage/', include('profilepage.urls')),
    path('authentication/', include('authentication.urls')),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)