from django.shortcuts import render, redirect, get_object_or_404
from main.models import Makanan
from .models import Wishlist, WishlistItem
from .forms import WishlistItemNotesForm
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from django.http import JsonResponse
from django.contrib.auth.models import User
from django.views.decorators.csrf import csrf_exempt
import json

from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from .models import Wishlist

@csrf_exempt
def remove_from_wishlist(request, food_id):
    if request.method == 'DELETE':
        try:
            wishlist_item = Makanan.objects.get(id=food_id)
            wishlist_item.delete()
            return JsonResponse({"message": "Item successfully removed"}, status=200)
        except Wishlist.DoesNotExist:
            return JsonResponse({"error": "Wishlist item not found"}, status=404)
    return JsonResponse({"error": "Invalid request method"}, status=400)

@login_required
def remove_wishlist(request, food_id):
    food = Makanan.objects.filter(id=food_id).first()
    
    if food is None:
        messages.error(request, "Food item not found.")
        return redirect('wishlist:view_wishlist')
    wishlist, created = Wishlist.objects.get_or_create(user=request.user)
    WishlistItem.objects.filter(wishlist=wishlist, food=food).delete()
    
    messages.success(request, f'{food.nama} has been removed from your wishlist.')
    return redirect('wishlist:view_wishlist')

@login_required
def add_to_wishlist(request, food_id):
    if request.method == 'POST':
        food_item = Makanan.objects.get(id=food_id)
        wishlist, created = Wishlist.objects.get_or_create(user=request.user)
        wishlist_item, item_created = WishlistItem.objects.get_or_create(
            wishlist=wishlist, 
            food=food_item
        )
    
        wishlist_count = wishlist.items.count()
        return JsonResponse({'wishlist_count': wishlist_count})
    return JsonResponse({'error': 'Invalid request'}, status=400)

@csrf_exempt
def add_to_wishlist_flutter(request):
    if request.method == "POST":
        try:
            data = json.loads(request.body)  
            username = data.get('username')
            food_id = data.get('food_id')

            if not username or not food_id:
                return JsonResponse({'error': 'Username and Food ID are required'}, status=400)

            user = User.objects.filter(username=username).first()
            if not user:
                return JsonResponse({'error': 'User not found'}, status=404)

            food_item = Makanan.objects.filter(id=food_id).first()
            if not food_item:
                return JsonResponse({'error': 'Food item not found'}, status=404)

            wishlist, created = Wishlist.objects.get_or_create(user=user)
            wishlist_item, item_created = WishlistItem.objects.get_or_create(
                wishlist=wishlist,
                food=food_item
            )

            wishlist_count = WishlistItem.objects.filter(wishlist=wishlist).count()
            return JsonResponse({'message': 'Item added to wishlist', 'wishlist_count': wishlist_count})

        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)

    return JsonResponse({'error': 'Invalid request'}, status=400)

@login_required
def view_wishlist(request): 
    wishlist, created = Wishlist.objects.get_or_create(user=request.user)
    wishlist_items = WishlistItem.objects.filter(wishlist=wishlist)

    context = {
        'wishlist': wishlist,
        'wishlist_items': wishlist_items,
        'wishlist_item_form': WishlistItemNotesForm()  
    }
    return render(request, 'wishlist.html', context)

@login_required
def update_wishlist_item_notes(request, food_id):
    if request.method == 'POST':
        food = get_object_or_404(Makanan, id=food_id)
        wishlist, created = Wishlist.objects.get_or_create(user=request.user)
        
        wishlist_item, created = WishlistItem.objects.get_or_create(
            wishlist=wishlist, 
            food=food
        )
        
        form = WishlistItemNotesForm(request.POST, instance=wishlist_item)
        if form.is_valid():
            form.save()
            messages.success(request, 'Notes updated successfully.')
            return redirect('wishlist:view_wishlist')
        else:
            messages.error(request, 'Error updating notes.')
            return redirect('wishlist:view_wishlist')
    
    return JsonResponse({'error': 'Invalid request'}, status=400)

def get_wishlist_json(request):
    username = request.GET.get('username') 
    print(f"Received username: {username}")

    if not username:
        return JsonResponse({'error': 'Username is required'}, status=400)

    user = User.objects.filter(username=username).first()
    if not user:
        return JsonResponse({'error': 'User not found'}, status=404)

    try:
        wishlist = Wishlist.objects.get(user=user)
        wishlist_items = WishlistItem.objects.filter(wishlist=wishlist)

        data = [
            {
                'id': item.food.id,
                'nama': item.food.nama,
                'harga': item.food.harga,
                'deskripsi': item.food.deskripsi,
                'rating': item.food.rating,
                'gambar': item.food.gambar,
                'notes': item.notes,
            }
            for item in wishlist_items
        ]
        return JsonResponse(data, safe=False)
    except Wishlist.DoesNotExist:
        return JsonResponse({'error': 'Wishlist not found'}, status=404)