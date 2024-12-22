from django import forms
from .models import Profile

class ProfileUpdateForm(forms.ModelForm):
    bio = forms.CharField(widget=forms.Textarea(attrs={'rows': 3}), required=False)
    profile_photo = forms.ImageField(required=False)

    class Meta:
        model = Profile
        fields = ['bio', 'profile_photo']
