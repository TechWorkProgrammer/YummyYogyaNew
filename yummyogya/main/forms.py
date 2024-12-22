from django.forms import ModelForm
from main.models import Artikel, Makanan

class MakananEntryForm(ModelForm):
    class Meta:
        model = Makanan
        fields = ['nama',
                  'harga', 
                  'deskripsi',
                  'kategori',
                  'restoran',
                  'rating',
                  'gambar']
        
