import json
from django.shortcuts import render, redirect, get_object_or_404
from .models import Food
from django.contrib.auth.decorators import login_required
from .forms import FoodForm
from django.http import JsonResponse
from django.contrib.auth.models import User
from rest_framework.views import APIView
from rest_framework import status


from rest_framework.decorators import api_view, authentication_classes, permission_classes
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework.authtoken.models import Token
from rest_framework.authentication import TokenAuthentication
from rest_framework.permissions import IsAuthenticated
from .serializers import FoodSerializer
from django.views.decorators.csrf import csrf_exempt

def get_user_id(request):
    username = request.GET.get('username')
    if not username:
        return JsonResponse({'error': 'Username is required'}, status=400)

    user = User.objects.filter(username=username).first()
    if user:
        return JsonResponse({'user_id': user.id}, status=200)
    return JsonResponse({'error': 'User not found'}, status=404)

@csrf_exempt
def add_food_flutter(request):
    if request.method == "POST":
        try:
            data = json.loads(request.body)

            user_id = data.get('user_id')  # Ambil user_id dari Flutter
            if not user_id:
                return JsonResponse({'error': 'User ID is required'}, status=400)

            user = User.objects.get(id=user_id) 
            food = Food.objects.create(
                name=data['name'],
                price=data['price'],
                description=data.get('description', ''),
                category=data.get('category', ''),
                restaurant=data.get('restaurant', ''),
                rating=data.get('rating', 0),
                image_url=data.get('image_url', ''),
                created_by=user 
                
            )
            return JsonResponse({'message': 'Makanan berhasil ditambahkan', 'id': food.id}, status=201)
        except Exception as e:
            return JsonResponse({'error': f'Gagal menambahkan makanan: {str(e)}'}, status=400)
    return JsonResponse({'error': 'Metode tidak diizinkan'}, status=405)

@csrf_exempt
def update_food_flutter(request, food_id):
    if request.method == "PUT":
        try:
            data = json.loads(request.body)
            food = Food.objects.get(id=food_id)

            # Update fields
            food.name = data.get('name', food.name)
            food.price = data.get('price', food.price)
            food.description = data.get('description', food.description)
            food.category = data.get('category', food.category)
            food.restaurant = data.get('restaurant', food.restaurant)
            food.rating = data.get('rating', food.rating)
            food.image_url = data.get('image_url', food.image_url)
            food.save()

            return JsonResponse({'message': 'Food updated successfully!'}, status=200)
        except Food.DoesNotExist:
            return JsonResponse({'error': 'Food not found'}, status=404)
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=400)
    return JsonResponse({'error': 'Invalid request method'}, status=405)

@csrf_exempt
def dashboard_data(request):
    if request.method == "GET":
        foods = Food.objects.all().values()  # Mengambil semua data makanan
        return JsonResponse(list(foods), safe=False)
    return JsonResponse({'error': 'Metode tidak diizinkan'}, status=405)


@api_view(['GET'])
def user_dashboard(request):
    username = request.GET.get('username')  # Ambil username dari query parameter

    if not username:
        return JsonResponse({'error': 'Username is required'}, status=400)

    # Cari user berdasarkan username
    user = User.objects.filter(username=username).first()
    if not user:
        return JsonResponse({'error': 'User not found'}, status=404)

    # Ambil data makanan yang dibuat oleh user ini
    foods = Food.objects.filter(created_by=user)

    # Serialisasi data makanan menjadi JSON
    data = [
        {
            'id': food.id,
            'name': food.name,
            'description': food.description,
            'price': food.price,
            'image_url': food.image_url,
            'category': food.category,
            'restaurant': food.restaurant,
            'rating': food.rating,
        }
        for food in foods
    ]
    return JsonResponse(data, safe=False)

@login_required
def dashboard(request):
    sort_by = request.GET.get('sort_by', 'price')  
    sort_order = request.GET.get('sort_order', 'asc')  


    if sort_by == 'name':
        foods = Food.objects.filter(created_by=request.user).order_by('name' if sort_order == 'asc' else '-name')
    else: 
        foods = Food.objects.filter(created_by=request.user).order_by('price' if sort_order == 'asc' else '-price')

    return render(request, 'dashboard.html', {'foods': foods, 'sort_by': sort_by, 'sort_order': sort_order})


# Add Food AJAX
@login_required
def add_food(request):
    if request.method == 'POST':
        form = FoodForm(request.POST)
        if form.is_valid():
            food = form.save(commit=False)
            food.created_by = request.user
            food.save()
            
            
            # Cek apakah request berasal dari AJAX
            if request.headers.get('x-requested-with') == 'XMLHttpRequest':
                return JsonResponse({
                    'status': 'success',
                    'food_name': food.name,
                    'message': 'Food added successfully!',
                })
            return redirect('dashboard:dashboard')
    
    else:
        form = FoodForm()
    
    return render(request, 'add_food.html', {'form': form})

# Edit Food AJAX 
@login_required
def edit_food(request, id):
    food = get_object_or_404(Food, id=id, created_by=request.user)
    if request.method == 'POST':
        form = FoodForm(request.POST, instance=food)
        if form.is_valid():
            form.save()
            
            # Cek apakah request berasal dari AJAX
            if request.headers.get('x-requested-with') == 'XMLHttpRequest':
                return JsonResponse({
                    'status': 'success',
                    'food_name': food.name,
                    'message': 'Food updated successfully!',
                })
            return redirect('dashboard:dashboard')
    else:
        form = FoodForm(instance=food)

    return render(request, 'edit_food.html', {'form': form, 'food': food})


@login_required
def delete_food(request, id):
    food = get_object_or_404(Food, id=id)  
    food.delete()
    return redirect('dashboard:dashboard')  

@csrf_exempt
def delete_food_flutter(request, food_id):
    if request.method == "DELETE":
        try:
            food = Food.objects.get(id=food_id)
            food.delete()
            return JsonResponse({'message': 'Makanan berhasil dihapus'}, status=200)
        except Food.DoesNotExist:
            return JsonResponse({'error': 'Makanan tidak ditemukan'}, status=404)
    return JsonResponse({'error': 'Metode tidak diizinkan'}, status=405)

def get_foods(request):
    if request.method == 'GET':
        print("GET foods endpoint accessed")  # Debug log
        foods = Food.objects.all()  # Ambil semua data makanan
        data = [
            {
                "id": food.id,
                "name": food.name,
                "description": food.description,
                "price": food.price,
                "image_url": food.image_url,  # Menambahkan URL gambar
                "restoran": food.restaurant,
            }
            for food in foods
        ]
        return JsonResponse(data, safe=False)  # Mengembalikan JSON
    else:
        return JsonResponse({"error": "Invalid request method"}, status=405)
    
@api_view(['GET'])
def get_food_list(request):
    foods = Food.objects.filter(created_by=request.user) # Mengambil semua makanan dari database
    serializer = FoodSerializer(foods, many=True)
    return Response(serializer.data)
