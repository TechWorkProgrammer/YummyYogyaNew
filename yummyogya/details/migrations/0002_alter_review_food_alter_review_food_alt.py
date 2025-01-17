# Generated by Django 5.1.2 on 2024-10-27 12:57

import django.db.models.deletion
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('dashboard', '0002_alter_food_rating'),
        ('details', '0001_initial'),
        ('main', '0005_alter_makanan_id'),
    ]

    operations = [
        migrations.AlterField(
            model_name='review',
            name='food',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='reviews', to='main.makanan'),
        ),
        migrations.AlterField(
            model_name='review',
            name='food_alt',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='reviews', to='dashboard.food'),
        ),
    ]
