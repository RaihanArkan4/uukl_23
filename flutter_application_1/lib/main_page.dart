import 'package:flutter/material.dart';
import 'beranda_page.dart';
import 'inventaris.dart';
import 'profil.dart';

// halaman utama dengan bottom navigation
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int halamanAktif = 0;

  final List<Widget> halaman = const [
    BerandaPage(),
    InventarisPage(),
    ProfilPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: halaman[halamanAktif],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: halamanAktif,
        selectedItemColor: Colors.teal.shade700,
        onTap: (index) {
          setState(() {
            halamanAktif = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(
              icon: Icon(Icons.list_alt), label: 'Inventaris'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}