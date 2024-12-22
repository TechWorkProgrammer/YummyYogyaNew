from django.shortcuts import render, redirect
from django.contrib.auth.decorators import login_required
from django.contrib.auth.forms import PasswordChangeForm
from .forms import ProfileUpdateForm 
from django.contrib.auth import update_session_auth_hash
from wishlist.models import Wishlist, WishlistItem
from details.models import Review
from django.http import JsonResponse
from .models import Profile
from django.views.decorators.csrf import csrf_exempt
import json

# Create your views here.

@login_required
def show_profile(request):
    user = request.user
    # Fetch or create the wishlist for the user
    wishlist, created = Wishlist.objects.get_or_create(user=user)
    wishlist_items = WishlistItem.objects.filter(wishlist=wishlist)[:3]
    food_items = [item.food for item in wishlist_items]
    profile, created = Profile.objects.get_or_create(user=user)  
    last_login = request.COOKIES.get('last_login', 'Not available')

    order = request.GET.get('order', 'latest')
    if order == 'latest':
        reviews = Review.objects.filter(user=user).order_by('-created_at').select_related('food', 'food_alt')
    else:
        reviews = Review.objects.filter(user=user).order_by('created_at').select_related('food', 'food_alt')

    context = {
        'user': user,
        'profile_form': ProfileUpdateForm(instance=profile),
        'food_items': food_items,
        'reviews': reviews,
        'last_login': last_login,
    }
    return render(request, 'profile.html', context)

@login_required
def update_profile(request):
    if request.method == 'POST':
        profile, created = Profile.objects.get_or_create(user=request.user)
        profile_form = ProfileUpdateForm(request.POST, request.FILES, instance=profile)
        delete_photo = request.POST.get('delete_photo', False)

        if profile_form.is_valid():
            new_bio = request.POST.get('bio')
            if new_bio is not None:
                profile.bio = new_bio
            if delete_photo:
                profile.profile_photo.delete()
            profile_form.save()
            return JsonResponse({'success': True})
        else:
            return JsonResponse({'success': False, 'errors': profile_form.errors})
    return JsonResponse({'success': False, 'error': 'Invalid request'})

@login_required
def change_password(request):
    if request.method == 'POST':
        password_form = PasswordChangeForm(user=request.user, data=request.POST)
        if password_form.is_valid():
            password_form.save()
            update_session_auth_hash(request, password_form.user)  # Agar pengguna tidak logout setelah mengganti password
            return JsonResponse({'success': True})
        else:
            return JsonResponse({'success': False, 'errors': password_form.errors})
    return JsonResponse({'success': False, 'error': 'Invalid request'})

@login_required
def get_profile_flutter(request):
    user = request.user
    profile = Profile.objects.get(user=user)
    wishlist_items = Wishlist.objects.filter(user=user).first().food.all()[:3]
    
    # Menyusun data wishlist
    wishlist = [
        {
            "id": item.id,
            "name": item.nama,
            "price": item.harga,
            "image": item.gambar.url if item.gambar else None,
        }
        for item in wishlist_items
    ]

    # Menyusun data review
    reviews = Review.objects.filter(user=user).order_by('-created_at')
    review_data = [
        {
            "id": review.id,
            "food_name": review.food.nama if review.food else "Tidak ada",
            "rating": review.rating,
            "review": review.review,
            "date": review.created_at.strftime("%Y-%m-%d"),
        }
        for review in reviews
    ]

    data = {
        "username": user.username,
        "email": user.email,
        "date_joined": user.date_joined.strftime("%Y-%m-%d"),
        "last_login": request.COOKIES.get('last_login', 'Not available'),
        "bio": profile.bio,
        "profile_photo": profile.profile_photo.url if profile.profile_photo else None,
        "wishlist": wishlist,
        "reviews": review_data,
    }
    return JsonResponse(data, safe=False)

@csrf_exempt
@login_required
def update_profile_flutter(request):
    if request.method == 'POST':
        profile = Profile.objects.get(user=request.user)
        data = json.loads(request.body)

        bio = data.get('bio', None)
        delete_photo = data.get('delete_photo', False)

        if bio is not None:
            profile.bio = bio

        if delete_photo:
            profile.profile_photo.delete()

        profile.save()

        return JsonResponse({"success": True, "message": "Profile updated successfully."})

    return JsonResponse({"success": False, "message": "Invalid request method."})

@csrf_exempt
@login_required
def change_password_flutter(request):
    if request.method == 'POST':
        data = json.loads(request.body)
        old_password = data.get('old_password')
        new_password1 = data.get('new_password1')
        new_password2 = data.get('new_password2')

        if new_password1 != new_password2:
            return JsonResponse({"success": False, "message": "Passwords do not match."})

        user = request.user
        if not user.check_password(old_password):
            return JsonResponse({"success": False, "message": "Old password is incorrect."})

        user.set_password(new_password1)
        user.save()
        return JsonResponse({"success": True, "message": "Password changed successfully."})

    return JsonResponse({"success": False, "message": "Invalid request method."})
