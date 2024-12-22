import json

from django.contrib.auth import update_session_auth_hash
from django.contrib.auth.decorators import login_required
from django.contrib.auth.forms import PasswordChangeForm
from django.contrib.auth.models import User
from django.http import JsonResponse
from django.shortcuts import get_object_or_404
from django.shortcuts import render
from django.views.decorators.csrf import csrf_exempt

from details.models import Review
from wishlist.models import Wishlist, WishlistItem
from .forms import ProfileUpdateForm
from .models import Profile


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
            update_session_auth_hash(request,
                                     password_form.user)  # Agar pengguna tidak logout setelah mengganti password
            return JsonResponse({'success': True})
        else:
            return JsonResponse({'success': False, 'errors': password_form.errors})
    return JsonResponse({'success': False, 'error': 'Invalid request'})


@csrf_exempt
def get_profile_flutter(request):
    try:
        username = request.GET.get('username')
        if not username:
            return JsonResponse({"status": "error", "message": "Username is required"}, status=400)

        user = get_object_or_404(User, username=username)
        profile, _ = Profile.objects.get_or_create(user=user)

        wishlist, _ = Wishlist.objects.get_or_create(user=user)
        wishlist_items = WishlistItem.objects.filter(wishlist=wishlist)[:3]
        food_items = [
            {
                "id": item.food.id,
                "name": item.food.nama,
                "price": item.food.harga,
                "image": item.food.gambar,
            }
            for item in wishlist_items
        ]

        reviews = Review.objects.filter(user=user).order_by('-created_at')[:3]
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
            "last_login": user.last_login.strftime("%Y-%m-%d %H:%M:%S") if user.last_login else "Not available",
            "bio": profile.bio,
            "profile_photo": profile.profile_photo.url if profile.profile_photo else None,
            "wishlist": food_items,
            "reviews": review_data,
        }

        return JsonResponse({"status": "success", "data": data}, safe=False)
    except Exception as e:
        return JsonResponse({"status": "error", "message": str(e)}, status=500)


@csrf_exempt
def update_profile_flutter(request):
    try:
        if request.method != 'POST':
            return JsonResponse({"success": False, "message": "Invalid request method."}, status=400)

        data = request.POST
        user_username = data.get('username')
        if not user_username:
            return JsonResponse({"success": False, "message": "Username is required."}, status=400)

        user = get_object_or_404(User, username=user_username)
        profile, _ = Profile.objects.get_or_create(user=user)

        profile_form = ProfileUpdateForm(request.POST, request.FILES, instance=profile)

        if profile_form.is_valid():
            new_bio = data.get('bio', None)
            if new_bio is not None:
                profile.bio = new_bio

            delete_photo = data.get('delete_photo', 'false').lower() == 'true'
            if delete_photo and profile.profile_photo:
                profile.profile_photo.delete()

            profile_form.save()

            return JsonResponse({"success": True, "message": "Profile updated successfully."})
        else:
            return JsonResponse({"success": False, "errors": profile_form.errors}, status=400)

    except Exception as e:
        return JsonResponse({"success": False, "message": f"An error occurred: {str(e)}"}, status=500)


@csrf_exempt
def change_password_flutter(request):
    try:
        if request.method != 'POST':
            return JsonResponse({"success": False, "message": "Invalid request method."}, status=400)

        data = json.loads(request.body)
        username = data.get('username')
        old_password = data.get('old_password')
        new_password1 = data.get('new_password1')
        new_password2 = data.get('new_password2')

        if not username:
            return JsonResponse({"success": False, "message": "Username is required."}, status=400)

        if not old_password or not new_password1 or not new_password2:
            return JsonResponse({"success": False, "message": "All password fields are required."}, status=400)

        if new_password1 != new_password2:
            return JsonResponse({"success": False, "message": "Passwords do not match."}, status=400)

        try:
            user = User.objects.get(username=username)
        except User.DoesNotExist:
            return JsonResponse({"success": False, "message": "User not found."}, status=404)

        if not user.check_password(old_password):
            return JsonResponse({"success": False, "message": "Old password is incorrect."}, status=400)

        user.set_password(new_password1)
        user.save()

        return JsonResponse({"success": True, "message": "Password changed successfully."})

    except Exception as e:
        return JsonResponse({"success": False, "message": f"An error occurred: {str(e)}"}, status=500)
