from django.shortcuts import render
from django.core.paginator import Paginator
from django.http import JsonResponse
from django.shortcuts import render, redirect, get_object_or_404
from article.forms import ArticleForm
from article.models import ArticleEntry
from django.http import HttpResponse
from django.core import serializers
from django.contrib.auth.decorators import login_required
from django.utils.html import strip_tags
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_POST
from django.http import HttpResponseForbidden
import json
from django.http import JsonResponse

# show article
def article_list(request):
    article_entries = ArticleEntry.objects.all()
    context = {
        'article_entries': article_entries,
    }
    return render(request, 'article_list.html', context)

def article_detail(request, id):
    article_entry = get_object_or_404(ArticleEntry, id=id)
    return render(request, 'article_detail.html', {'article_entry': article_entry})

@login_required(login_url='login/')
def create_article(request):
    form = ArticleForm(request.POST or None)

    if form.is_valid() and request.method == 'POST':
        article_entry = form.save(commit=False)
        article_entry.user = request.user
        form.save()
        return redirect('article:article_list')
    
    context = {'form':form}
    return render(request, 'create_article.html', context)

def show_xml(request):
    data = ArticleEntry.objects.all()
    return HttpResponse(serializers.serialize("xml", data), content_type="application/xml")

def show_json(request):
    data = ArticleEntry.objects.all()
    return HttpResponse(serializers.serialize("json", data), content_type="application/json")

def show_xml_by_id(request, id):
    data = ArticleEntry.objects.filter(pk=id)
    return HttpResponse(serializers.serialize("xml", data), content_type="application/xml")

def show_json_by_id(request, id):
    data = ArticleEntry.objects.filter(pk=id)
    return HttpResponse(serializers.serialize("json", data), content_type="application/json")

@csrf_exempt
@require_POST
def create_article_ajax(request):
    if request.method == 'POST':
        title = strip_tags(request.POST.get('title'))
        content = strip_tags(request.POST.get('content'))
        image_url = strip_tags(request.POST.get('image_url'))
        article_entry = ArticleEntry.objects.create(
            title=title,
            content=content,
            image_url=image_url,
            user=request.user,
        )
        data = serializers.serialize('json', [article_entry])
        return JsonResponse({'article': data})
    else:
        return JsonResponse({'error': 'Invalid request'}, status=400)

login_required
def edit_article(request, id):
    article_entry = get_object_or_404(ArticleEntry, id=id)
    if article_entry.user != request.user:
        return HttpResponseForbidden("Anda tidak diizinkan untuk mengedit artikel ini.")

    if request.method == 'POST':
        form = ArticleForm(request.POST, instance=article_entry)
        if form.is_valid():
            form.save()
            return redirect('article:article_list')
    else:
        form = ArticleForm(instance=article_entry)

    return render(request, 'edit_article.html', {'form': form})

# View untuk menghapus artikel
@login_required
def delete_article(request, id):
    article_entry = get_object_or_404(ArticleEntry, id=id)
    if article_entry.user != request.user:
        return HttpResponseForbidden("Anda tidak diizinkan untuk menghapus artikel ini.")

    if request.method == 'POST':
        article_entry.delete()
        return redirect('article:article_list')

    return render(request, 'confirm_delete.html', {'article_entry': article_entry})

@csrf_exempt
def create_article_flutter(request):
    if request.method == 'POST':
        data = json.loads(request.body)
        new_article = ArticleEntry.objects.create(
            user=request.user,
            title=data['title'],
            content=data['content'],
            image_url=data['image_url'],
        )

        new_article.save()
        return JsonResponse({'status': 'success'}, status=200)
    else:
        return JsonResponse({'status': 'error'}, status=401)