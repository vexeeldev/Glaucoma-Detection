import os

# Path utama project kamu
base_path = "eyepac-light-v2-512-jpg"

# Daftar folder yang ingin dicek
folders = [
    "train/RG",
    "train/NRG",
    "validation/RG",
    "validation/NRG",
    "test/NRG",
    "test/RG"
]

print("--- Statistik Dataset Glaukoma ---")
total_semua = 0

for folder in folders:
    full_path = os.path.join(base_path, folder)
    if os.path.exists(full_path):
        # Menghitung file yang ada di dalam folder
        jumlah = len([f for f in os.listdir(full_path) if os.path.isfile(os.path.join(full_path, f))])
        print(f"Folder {folder:15}: {jumlah} file")
        total_semua += jumlah
    else:
        print(f"Folder {folder:15}: TIDAK DITEMUKAN!")

print("-" * 34)
print(f"Total Keseluruhan File: {total_semua}")