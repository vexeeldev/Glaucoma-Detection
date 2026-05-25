import matplotlib.pyplot as plt
import networkx as nx

# 1. Inisialisasi Graf
G = nx.Graph()

# 2. Tambahkan Edge (Rute) beserta Weight (Jarak dalam Km)
edges_data = [
    ('A', 'B', 11), ('A', 'C', 23), ('A', 'D', 51), ('A', 'L', 8), ('A', 'K', 14),
    ('B', 'C', 12), ('B', 'F', 11), ('B', 'K', 14), ('B', 'G', 19),
    ('C', 'D', 23), ('C', 'E', 11), ('C', 'F', 17),
    ('D', 'E', 17),
    ('E', 'F', 10),
    ('F', 'G', 15),
    ('G', 'K', 30), ('G', 'H', 23),
    ('H', 'I', 9),
    ('I', 'K', 20), ('I', 'J', 12),
    ('J', 'K', 12), ('J', 'L', 11),
    ('K', 'L', 6)
]

for u, v, w in edges_data:
    G.add_edge(u, v, weight=w)

# 3. Mengatur Koordinat Posisi Titik secara Otomatis (Spring Layout)
# K = tingkat kerenggangan antar node, seed agar posisi konisten setiap di-run
pos = nx.spring_layout(G, k=1.2, seed=42) 

# 4. Gambar Elemen Graf
plt.figure(figsize=(12, 9))

# Gambar Garis Rute (Edges)
nx.draw_networkx_edges(G, pos, width=2, edge_color='gray', alpha=0.6)

# Gambar Titik Kantor Pos (Nodes)
# Node 'A' diberi warna berbeda karena merupakan Kantor Cabang (Start/End)
node_colors = ['#FF5733' if node == 'A' else '#3498DB' for node in G.nodes()]
nx.draw_networkx_nodes(G, pos, node_size=800, node_color=node_colors, edgecolors='black')

# Label Nama Huruf (A-L)
nx.draw_networkx_labels(G, pos, font_size=12, font_weight='bold', font_color='white')

# Label Jarak (Km) di setiap garis
edge_labels = nx.get_edge_attributes(G, 'weight')
formatted_edge_labels = {k: f"{v} Km" for k, v in edge_labels.items()}
nx.draw_networkx_edge_labels(G, pos, edge_labels=formatted_edge_labels, font_size=9, font_color='red')

# 5. Keterangan Tambahan dan Tampilkan Gambar
plt.title("Peta Jaringan Koordinat Rute Kantor Pos Lamongan (A - L)", fontsize=14, fontweight='bold', pad=20)
plt.axis('off')
plt.tight_layout()
plt.show()