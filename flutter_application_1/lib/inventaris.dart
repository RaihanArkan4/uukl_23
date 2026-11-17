import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'data_dummy.dart';
import 'helper.dart';
import 'detail.dart';
import 'persetujuan.dart';


class InventarisPage extends StatefulWidget {
  const InventarisPage({super.key});

  @override
  State<InventarisPage> createState() => _InventarisPageState();
}

class _InventarisPageState extends State<InventarisPage> {
  final itemsRef = FirebaseFirestore.instance.collection('items');

  Future<void> isiDataDummy() async {
    try {
      for (var d in dataDummy) {
        var ref = itemsRef.doc();
        await ref.set({
          'item_id': ref.id,
          'item_name': d['item_name'],
          'category': d['category'],
          'code': d['code'],
          'status': d['status'],
          'image': d['image'],
          'spesification': d['spesification'],
          'created_at': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal mengisi data: $e')));
    }
  }

  void formItem({DocumentSnapshot? doc}) {
    Map<String, dynamic> lama = {};
    if (doc != null) lama = doc.data() as Map<String, dynamic>;

    final daftarNama = dataDummy.map((d) => d['item_name']!).toList();
    String? pilihan = lama['item_name'];
    if (pilihan != null && !daftarNama.contains(pilihan)) pilihan = null;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(builder: (dialogContext, setDialog) {
          return AlertDialog(
            title: Text(doc == null ? 'Tambah Alat' : 'Edit Alat'),
            content: DropdownButton<String>(
              isExpanded: true,
              hint: const Text('Pilih barang'),
              value: pilihan,
              items: daftarNama
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) {
                setDialog(() {
                  pilihan = value;
                });
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (pilihan == null) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(content: Text('Pilih barang dulu')),
                    );
                    return;
                  }

                  var d = dataDummy
                      .firstWhere((x) => x['item_name'] == pilihan);

                  Map<String, dynamic> data = {
                    'item_name': d['item_name'],
                    'category': d['category'],
                    'code': d['code'],
                    'image': d['image'],
                    'spesification': d['spesification'],
                  };

                  try {
                    if (doc == null) {
                      var ref = itemsRef.doc();
                      data['item_id'] = ref.id;
                      data['status'] = 'Available';
                      data['created_at'] = FieldValue.serverTimestamp();
                      await ref.set(data);
                    } else {
                      await doc.reference.update(data);
                    }
                    if (dialogContext.mounted) Navigator.pop(dialogContext);
                  } catch (e) {
                    if (dialogContext.mounted) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                          SnackBar(content: Text('Gagal menyimpan: $e')));
                    }
                  }
                },
                child: const Text('Simpan'),
              ),
            ],
          );
        });
      },
    );
  }

  void konfirmasiHapus(DocumentSnapshot doc) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus alat?'),
          content: const Text('Data yang dihapus tidak bisa dikembalikan.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                await doc.reference.delete();
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Inventaris'),
      backgroundColor: Colors.teal.shade600,
      foregroundColor: Colors.white,
    ),
    body: const Center(
      child: Text('Login dulu baru pakai'),
    ),
  );
}
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventaris'),
        backgroundColor: Colors.teal.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.fact_check_outlined),
            tooltip: 'Persetujuan',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PersetujuanPage()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal.shade600,
        foregroundColor: Colors.white,
        onPressed: () => formItem(),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: itemsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Gagal memuat data'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Belum ada inventaris'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: isiDataDummy,
                    child: const Text('Belum isi '),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var item = docs[index].data() as Map<String, dynamic>;
              String status = item['status'] ?? '';
              return ListTile(
                onTap: () => bukaDetail(context, docs[index]),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: gambarItem(item['image'] ?? '', lebar: 50, tinggi: 50),
                ),
                title: Text(item['item_name'] ?? '-'),
                subtitle: Text(
                    '${item['category'] ?? '-'} • ${item['code'] ?? '-'}\n$status'),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => formItem(doc: docs[index]),
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.delete, size: 20, color: Colors.red),
                      onPressed: () => konfirmasiHapus(docs[index]),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}