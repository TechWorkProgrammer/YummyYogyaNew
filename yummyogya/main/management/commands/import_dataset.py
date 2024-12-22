import csv
from django.core.management.base import BaseCommand
from main.models import Makanan

class Command(BaseCommand):
    help = 'Import data makanan dari CSV'

    def add_arguments(self, parser):
        parser.add_argument('csv_file', type=str, help="Path to the CSV file")

    def handle(self, *args, **kwargs):
        csv_file_path = kwargs['csv_file']

        # Menentukan encoding UTF-8 saat membuka file
        with open(csv_file_path, mode='r', encoding='utf-8') as file:
            reader = csv.DictReader(file)

            for row in reader:
                try:                   
                    Makanan.objects.create(
                        nama=row['Nama'],
                        deskripsi=row['Deskripsi'],
                        kategori=row['Kategori'],
                        restoran=row['Restoran'],
                        harga=int(row['Harga']),
                        rating=row['Rating'],
                        gambar=row.get('Foto', '')  # Kosongkan jika tidak ada gambar
                    )
                except ValueError:
                    self.stdout.write(self.style.ERROR(f"Invalid value for 'Harga' in row: {row}"))
                    continue

        self.stdout.write(self.style.SUCCESS('Data makanan berhasil diimport!'))
