from django.contrib import admin
from django.shortcuts import render, redirect
from .models import Wishlist
from main.models import Makanan
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from django.http import JsonResponse

# Register your models here.
admin.site.register(Makanan)
admin.site.register(Wishlist)



