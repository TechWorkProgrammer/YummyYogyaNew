from django import forms
from .models import WishlistItem

class WishlistItemNotesForm(forms.ModelForm):
    notes = forms.CharField(
        widget=forms.Textarea(attrs={
            'class': 'form-control',
            'rows': 3,
            'placeholder': 'Add your notes here...'
        }),
        required=False,
        max_length=500
    )

    class Meta:
        model = WishlistItem
        fields = ['notes']