# details/views.py
import json

from django.db import models
from django.db.models.aggregates import Avg
from django.http import JsonResponse
from django.shortcuts import render
from django.views.decorators.csrf import csrf_exempt

from dashboard.models import Food
from django.contrib.auth.models import User
from main.models import Makanan
from .models import Review  # Pastikan Anda memiliki model Review


@csrf_exempt
def add_review(request):
    if request.method == 'POST':
        data = json.loads(request.body)
        rating = data.get('rating')
        review_text = data.get('review')
        food_id = data.get('food_id')

        food = Makanan.objects.get(id=food_id) if food_id else None
        if food and request.user.is_authenticated:
            review = Review.objects.create(
                user=request.user,
                food=food,
                review=review_text,
                rating=rating
            )

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


@csrf_exempt
def add_review_flutter(request):
    try:
        if request.method == 'POST':
            data = json.loads(request.body)
            rating = data.get('rating')
            review_text = data.get('review')
            food_id = data.get('food_id')
            username = data.get('username')

            if not all([rating, review_text, food_id, username]):
                return JsonResponse({'status': 'error', 'message': 'Semua field wajib diisi'}, status=400)

            try:
                user = User.objects.get(username=username)
            except User.DoesNotExist:
                return JsonResponse({'status': 'error', 'message': 'Pengguna tidak ditemukan'}, status=404)

            try:
                food = Makanan.objects.get(id=food_id)
            except Makanan.DoesNotExist:
                return JsonResponse({'status': 'error', 'message': 'Makanan tidak ditemukan'}, status=404)

            review = Review.objects.create(
                user=user,
                food=food,
                review=review_text,
                rating=rating
            )

            all_reviews = Review.objects.filter(food=food)
            average_rating = all_reviews.aggregate(models.Avg('rating'))['rating__avg']
            food.rating = average_rating
            food.save()

            return JsonResponse({
                'status': 'success',
                'message': 'Review berhasil ditambahkan',
                'data': {
                    'review': {
                        'id': review.id,
                        'user': review.user.username,
                        'review': review.review,
                        'rating': review.rating,
                        'food_id': review.food.id
                    },
                    'average_rating': round(average_rating, 1)
                }
            }, status=201)
        else:
            return JsonResponse({'status': 'error', 'message': 'Metode request tidak valid'}, status=405)
    except Exception as e:
        return JsonResponse({'status': 'error', 'message': f'Terjadi kesalahan: {str(e)}'}, status=500)

@csrf_exempt
def food_detail_flutter_query(request):
    if request.method == "GET":
        food_id = request.GET.get('food_id')
        if not food_id:
            return JsonResponse({"status": "error", "message": "food_id is required"}, status=400)

        try:
            food = Makanan.objects.filter(pk=food_id).first() or Food.objects.filter(pk=food_id).first()
            if not food:
                return JsonResponse({"status": "error", "message": "Makanan tidak ditemukan"}, status=404)

            reviews = food.review_set.all()
            review_list = [
                {
                    "id": review.id,
                    "user": review.user.username,
                    "review": review.review,
                    "rating": review.rating,
                }
                for review in reviews
            ]

            total_reviews = reviews.aggregate(average=Avg('rating'))['average'] or 0
            average_rating = (float(food.rating) + total_reviews) / 2 if reviews.exists() else float(food.rating)

            data = {
                "id": food.id,
                "name": food.nama if hasattr(food, 'nama') else food.name,
                "description": food.deskripsi if hasattr(food, 'deskripsi') else food.description,
                "price": food.harga if hasattr(food, 'harga') else food.price,
                "rating": food.rating,
                "average_rating": round(average_rating, 1),
                "restaurant": food.restoran if hasattr(food, 'restoran') else food.restaurant,
                "image_url": food.gambar if hasattr(food, 'gambar') else food.image_url,
                "reviews": review_list,
            }
            return JsonResponse({"status": "success", "data": data}, status=200)
        except Exception as e:
            return JsonResponse({"status": "error", "message": str(e)}, status=500)

    return JsonResponse({"status": "error", "message": "Metode request tidak valid"}, status=405)
