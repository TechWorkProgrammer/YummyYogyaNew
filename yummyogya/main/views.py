from django.http import HttpResponse
from django.http import JsonResponse
from django.core import serializers
from django.shortcuts import render
from django.core.paginator import Paginator
from django.contrib.auth.decorators import login_required
from .models import Makanan
from dashboard.models import Food

@login_required
def show_main(request):
    query = request.GET.get('q')

    # Ambil makanan umum dari model Makanan
    semua_makanan = Makanan.objects.filter(nama__icontains=query) if query else Makanan.objects.all()

    # Ambil makanan yang hanya dibuat oleh user yang sedang login
    if request.user.is_authenticated:
        user_makanan = Food.objects.filter(created_by=request.user)
        if query:
            user_makanan = user_makanan.filter(name__icontains=query)
    else:
        user_makanan = Food.objects.none()  # Tidak ada makanan jika user tidak login

    # Gabungkan hasil dari dua model (makanan umum dan makanan user yang login)
    combined_makanan = list(semua_makanan) + list(user_makanan)

    # Pagination
    paginator = Paginator(combined_makanan,8) 
    page_number = request.GET.get('page')
    page_obj = paginator.get_page(page_number)

    context = {
        'nama_web': "yummyogya",
        'page_obj': page_obj,
        'query': query,
    }
    return render(request, "main.html", context)


# Fungsi untuk handling request AJAX
# @login_required
def search_ajax(request):
    query = request.GET.get('q', '')
    page_number = request.GET.get('page', 1)  # Get the requested page number, default to 1

    # Retrieve general `Makanan` instances based on query
    makanan_list = Makanan.objects.filter(nama__icontains=query) if query else Makanan.objects.all()
    
    # Retrieve `Food` instances created by the logged-in user
    if request.user.is_authenticated:
        user_makanan_list = Food.objects.filter(created_by=request.user)
        if query:
            user_makanan_list = user_makanan_list.filter(name__icontains=query)
    else:
        user_makanan_list = Food.objects.none()

    # Combine both querysets and paginate
    combined_makanan = list(makanan_list) + list(user_makanan_list)
    paginator = Paginator(combined_makanan, 8)  # Paginate with 8 items per page

    # Get the requested page
    page_obj = paginator.get_page(page_number)

    # Prepare JSON-friendly data for each item
    makanan_data = []
    for makanan in page_obj.object_list:
        if isinstance(makanan, Makanan):  # If it's a Makanan instance
            makanan_data.append({
                'id': makanan.id,
                'nama': makanan.nama,
                'deskripsi': makanan.deskripsi,
                'harga': makanan.harga,
                'rating': makanan.rating,
                'gambar': makanan.gambar,
                'restoran': makanan.restoran
            })
        elif isinstance(makanan, Food):  # If it's a Food instance
            makanan_data.append({
                'id': makanan.id,
                'nama': makanan.name,
                'deskripsi': makanan.description,
                'harga': makanan.price,
                'rating': makanan.rating,
                'gambar': makanan.image_url,
                'restoran': makanan.restaurant
            })

    # Return paginated data including previous and next page information
    data = {
        'makanan_list': makanan_data,
        'previous_page': page_obj.previous_page_number() if page_obj.has_previous() else None,
        'next_page': page_obj.next_page_number() if page_obj.has_next() else None,
    }

    return JsonResponse(data)


def show_xml(request):
    data = Makanan.objects.all()
    return HttpResponse(serializers.serialize("xml", data), content_type="application/xml")

def show_json(request):
    data = Makanan.objects.all()
    return HttpResponse(serializers.serialize("json", data), content_type="application/json")

def show_xml_by_id(request, id):
    data = Makanan.objects.filter(pk=id)
    return HttpResponse(serializers.serialize("xml", data), content_type="application/xml")

def show_json_by_id(request, id):
    data = Makanan.objects.filter(pk=id)
    return HttpResponse(serializers.serialize("json", data), content_type="application/json")
