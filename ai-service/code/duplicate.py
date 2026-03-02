import os
import hashlib
import shutil

def get_hash(file_path):
    hasher = hashlib.md5()
    with open(file_path, 'rb') as f:
        # Baca file per blok agar hemat RAM laptop Dell kamu
        for chunk in iter(lambda: f.read(4096), b""):
            hasher.update(chunk)
    return hasher.hexdigest()

def pindah_duplikat(target_dir, duplicate_dir):
    hashes = {}
    duplikat_count = 0
    
    # Buat folder tujuan kalau belum ada
    if not os.path.exists(duplicate_dir):
        os.makedirs(duplicate_dir)
        print(f"Folder {duplicate_dir} dibuat.")

    print(f"Mulai scanning di: {target_dir}")
    
    for root, dirs, files in os.walk(target_dir):
        for filename in files:
            path = os.path.join(root, filename)
            
            # Skip file kalau itu ternyata folder duplicate_dir itu sendiri
            if duplicate_dir in path:
                continue
                
            file_hash = get_hash(path)
            
            if file_hash in hashes:
                # Jika hash sudah ada, berarti ini duplikat
                dest_path = os.path.join(duplicate_dir, "dup_" + filename)
                
                # Pastikan nama file tidak bentrok di folder tujuan
                counter = 1
                while os.path.exists(dest_path):
                    name, ext = os.path.splitext(filename)
                    dest_path = os.path.join(duplicate_dir, f"dup_{name}_{counter}{ext}")
                    counter += 1
                
                shutil.move(path, dest_path)
                duplikat_count += 1
            else:
                hashes[file_hash] = path
    
    print(f"--- SELESAI ---")
    print(f"Total file duplikat dipindahkan: {duplikat_count}")

# Eksekusi untuk folder train kamu
pindah_duplikat("eyepac-light-v2-512-jpg/train/NRG", "temp_duplicates")