# details/views.py
from django.shortcuts import render, get_object_or_404, redirect
from django.contrib import messages
from .models import Review  # Pastikan Anda memiliki model Review
from main.models import Makanan
from dashboard.models import Food
from django.views.decorators.csrf import csrf_exempt
from django.http import JsonResponse
import json
from django.db import models


@csrf_exempt
def add_review(request):
    if request.method == 'POST':
        data = json.loads(request.body)
        rating = data.get('rating')
        review_text = data.get('review')
        food_id = data.get('food_id')
        
        # Ambil objek food dan simpan ulasan
        food = Makanan.objects.get(id=food_id) if food_id else None
        if food and request.user.is_authenticated:
            review = Review.objects.create(
                user=request.user,
                food=food,
                review=review_text,
                rating=rating
            )

            # Hitung rata-rata rating
            all_reviews = Review.objects.filter(food=food)
            average_rating = all_reviews.aggregate(models.Avg('rating'))['rating__avg']
            food.rating = average_rating  # Update rating di objek food
            food.save()  # Simpan perubahan ke database
            
            return JsonResponse({'message': 'Review added successfully!', 'status': 'success'})
        return JsonResponse({'message': 'Failed to add review', 'status': 'error'})
    return JsonResponse({'message': 'Invalid request method', 'status': 'error'})

def food_detail(request, id):
    item = Makanan.objects.filter(pk=id).first() or Food.objects.filter(pk=id).first()
    if not item:
        return render(request, '404.html')

    reviews = item.review_set.all()  # Ambil semua ulasan untuk item ini
    context = {
        'item': {
            'id': item.id,
            'nama': item.nama if hasattr(item, 'nama') else item.name,
            'deskripsi': item.deskripsi if hasattr(item, 'deskripsi') else item.description,
            'harga': item.harga if hasattr(item, 'harga') else item.price,
            'rating': item.rating,
            'gambar': item.gambar if hasattr(item, 'gambar') else item.image_url,
            'restoran': item.restoran if hasattr(item, 'restoran') else item.restaurant,
        },
        'reviews': reviews  # Tambahkan daftar ulasan ke konteks
    }
    return render(request, 'food_detail.html', context)