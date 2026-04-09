import streamlit as st

# Data Penyakit dan Gejala berdasarkan Gambar 1 & 2
# Format: {ID_Penyakit: [Daftar ID Gejala]}
RULES = {
    "Staphylococcus aureus": [20, 21, 22, 23, 29, 1, 4, 14, 2, 5, 7, 8, 15, 6, 9],
    "Jamur Beracun": [20, 21, 22, 24, 30, 1, 4, 8, 14, 2, 5, 7, 10, 16],
    "Salmonellae": [20, 21, 22, 25, 26, 29, 1, 4, 14, 2, 5, 7, 8, 15, 9, 11, 12],
    "Clostridium botulinum": [21, 27, 31, 4, 14, 5, 13, 17, 6],
    "Campylobacter": [28, 22, 25, 32, 1, 4, 18, 2, 7, 5, 19, 3, 9, 11]
}

# Deskripsi Gejala
GEJALA_DESC = {
    1: "Buang air besar (lebih dari 2 kali)",
    2: "Berak encer",
    3: "Berak berdarah",
    4: "Lesu dan tidak bergairah",
    5: "Tidak selera makan",
    6: "Merasa mual dan sering muntah",
    7: "Merasa sakit di bagian perut",
    8: "Tekanan darah rendah",
    9: "Pusing",
    10: "Pingsan",
    11: "Suhu badan tinggi",
    12: "Luka di bagian tertentu",
    13: "Tidak dapat menggerakkan anggota badan tertentu",
    14: "Pernah memakan sesuatu",
    15: "Memakan daging",
    16: "Memakan jamur",
    17: "Memakan makanan kaleng",
    18: "Membeli susu",
    19: "Meminum susu",
    20: "Mencret",
    21: "Muntah",
    22: "Sakit perut",
    23: "Darah rendah",
    24: "Koma",
    25: "Demam",
    26: "Septicaemia",
    27: "Lumpuh",
    28: "Mencret berdarah",
    29: "Makan daging",
    30: "Makan jamur",
    31: "Makan makanan kaleng",
    32: "Minum susu"
}

def main():
    st.title("Sistem Pakar Infeksi Gastro-Usus")
    st.write("Pilih gejala yang Anda alami di bawah ini:")

    # Layout checkbox untuk gejala
    selected_gejala = []
    
    # Membuat grid agar tidak terlalu panjang ke bawah
    cols = st.columns(2)
    for i, (id_gejala, desc) in enumerate(GEJALA_DESC.items()):
        with cols[i % 2]:
            if st.checkbox(f"{id_gejala}. {desc}", key=f"g_{id_gejala}"):
                selected_gejala.append(id_gejala)

    st.divider()
    
    # Input Th (%) seperti pada gambar (Threshold minimal)
    threshold = st.number_input("Th (%):", min_value=0, max_value=100, value=20)

    # Tombol Proses
    if st.button("Proses"):
        if not selected_gejala:
            st.warning("Silakan pilih minimal satu gejala.")
            return

        results = {}
        max_score = -1
        diagnosa = "Tidak Terdeteksi"

        st.subheader("Hasil Perhitungan:")
        
        for penyakit, gejala_rules in RULES.items():
            # Menghitung berapa banyak gejala terpilih yang ada di dalam rule penyakit tersebut
            match_count = len(set(selected_gejala) & set(gejala_rules))
            # Persentase (Gejala yang cocok / Total gejala di rule tersebut * 100)
            score = (match_count / len(gejala_rules)) * 100
            results[penyakit] = score
            
            st.write(f"{penyakit} : {score:.2f}%")
            
            # Mencari nilai tertinggi yang di atas threshold
            if score > max_score and score >= threshold:
                max_score = score
                diagnosa = penyakit

        st.divider()
        st.success(f"Terkena Penyakit: **{diagnosa}**")

if __name__ == "__main__":
    main()