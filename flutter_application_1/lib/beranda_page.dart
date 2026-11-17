
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'data_dummy.dart';
import 'helper.dart';
import 'detail.dart';

class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  // Daftar kategori barang
  final List<String> listKategori = dataDummy
      .map((item) => item['category']!)
      .toSet()
      .toList();

  final List<String> listStatus = dataDummy
      .map((item) => item['status']!)
      .toSet()
      .toList();

  final cariController = TextEditingController();
  String kataCari = '';
  String kategoriDipilih = '';
  String statusDipilih = '';

  final List<String> bannerList = [
    'assets/alat.jpg',
    'assets/black_scientist.jpg',
    'assets/neraca.jpg',
  ];

  @override
  void dispose() {
    cariController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String? uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Container(
              padding: const EdgeInsets.only(
                  top: 60, left: 20, right: 20, bottom: 20),
              decoration: BoxDecoration(
                color: Colors.teal.shade600,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (uid == null)
                        const Text(
                          'Halo, Tamu',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      else
                        StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(uid)
                              .snapshots(),
                          builder: (context, snapshot) {
                            String nama = '';
                            if (snapshot.hasData && snapshot.data!.exists) {
                              var data = snapshot.data!.data()
                                  as Map<String, dynamic>;
                              nama = data['name'] ?? '';
                            }
                            return Text(
                              'Halo, $nama',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      const Icon(
                        Icons.notifications,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: TextField(
                      controller: cariController,
                      onChanged: (value) {
                        setState(() {
                          kataCari = value.toLowerCase();
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: 'Cari alat...',
                        prefixIcon: Icon(Icons.search),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            CarouselSlider(
              options: CarouselOptions(
                height: 150,
                autoPlay: true,
                enlargeCenterPage: true,
                autoPlayInterval: const Duration(seconds: 3),
                viewportFraction: 0.85,
              ),
              items: bannerList.map((path) {
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      path,
                      width: double.infinity,
                      height: 150,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 40,
                          ),
                        );
                      },
                    ),
                  ),
                );
              }).toList(),
            ),

            judul('Semua Data'),
            SizedBox(
              height: 170,
                child: uid == null
      ? const Center(child: Text('Login dulu jika mau pake'))
      : StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('items')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Gagal memuat data'),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  List<DocumentSnapshot> hasil = [];

                  for (var doc in snapshot.data!.docs) {
                    var item = doc.data() as Map<String, dynamic>;

                    String nama =
                        (item['item_name'] ?? '').toString().toLowerCase();

                    if (kataCari != '' && !nama.contains(kataCari)) {
                      continue;
                    }

                    if (kategoriDipilih != '' &&
                        item['category'] != kategoriDipilih) {
                      continue;
                    }

                    if (statusDipilih != '' &&
                        item['status'] != statusDipilih) {
                      continue;
                    }

                    hasil.add(doc);
                  }

                  if (hasil.isEmpty) {
                    return const Center(
                      child: Text('Data tidak ditemukan'),
                    );
                  }

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: hasil.length,
                    itemBuilder: (context, index) {
                      var item =
                          hasil[index].data() as Map<String, dynamic>;

                      String status = item['status'] ?? '';

                      return GestureDetector(
                        onTap: () => bukaDetail(context, hasil[index]),
                        child: Container(
                          width: 130,
                          margin: const EdgeInsets.only(left: 15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(14),
                                ),
                                child: gambarItem(
                                  item['image'] ?? '',
                                  lebar: 130,
                                  tinggi: 90,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['item_name'] ?? '-',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      status,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: warnaStatus(status),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            judul('Kategori Peralatan'),
            barisChip(listKategori, kategoriDipilih, (pilihan) {
              setState(() {
                kategoriDipilih =
                    (kategoriDipilih == pilihan) ? '' : pilihan;
              });
            }),

            // baris 3: status
            judul('Status'),
            barisChip(listStatus, statusDipilih, (pilihan) {
              setState(() {
                statusDipilih =
                    (statusDipilih == pilihan) ? '' : pilihan;
              });
            }),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget judul(String teks) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Text(
        teks,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ===== Widget filter chip =====
  Widget barisChip(
    List<String> daftar,
    String dipilih,
    Function(String) saatDiklik,
  ) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: daftar.length,
        itemBuilder: (context, index) {
          bool aktif = daftar[index] == dipilih;

          return GestureDetector(
            onTap: () => saatDiklik(daftar[index]),
            child: Container(
              margin: const EdgeInsets.only(left: 15),
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: aktif
                    ? Colors.teal.shade600
                    : Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                daftar[index],
                style: TextStyle(
                  color: aktif ? Colors.white : Colors.teal.shade700,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
