import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'helper.dart';
import 'login_page.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  @override
  void initState() {
    super.initState();
    _pastikanDataUser();
  }

  // kalau akun belum punya dokumen users/{uid}, buat otomatis
  Future<void> _pastikanDataUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      var ref = FirebaseFirestore.instance.collection('users').doc(user.uid);
      var snap = await ref.get();
      if (!snap.exists) {
        String email = user.email ?? '';
        await ref.set({
          'user_id': user.uid,
          'name': email.contains('@') ? email.split('@')[0] : email,
          'email': email,
          'kelas': '-',
          'created_at': FieldValue.serverTimestamp(),
          'foto': 'https://picsum.photos/seed/${user.uid}/200',
        });
      }
    } catch (e) {
      debugPrint('Gagal membuat data user: $e');
    }
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  // warna label status pengajuan
  Color _warnaPengajuan(String status) {
    if (status == 'Disetujui') return Colors.green;
    if (status == 'Ditolak') return Colors.red;
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    // belum login (tamu)
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profil'),
          backgroundColor: Colors.teal.shade600,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Kamu belum login'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => _logout(context),
                child: const Text('Ke halaman login'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Colors.teal.shade600,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // data user dari users/{uid}: foto, nama, email, kelas
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                Map<String, dynamic> data = {};
                if (snapshot.hasData && snapshot.data!.exists) {
                  data = snapshot.data!.data() as Map<String, dynamic>;
                }
                String foto = (data['foto'] ?? '').toString();

                return Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.teal.shade100,
                        backgroundImage:
                            foto.isNotEmpty ? NetworkImage(foto) : null,
                        child: foto.isEmpty
                            ? Icon(Icons.person,
                                size: 40, color: Colors.teal.shade700)
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        data['name'] ?? '-',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(data['email'] ?? user.email ?? '-'),
                      const SizedBox(height: 4),
                      Text('Kelas: ${data['kelas'] ?? '-'}'),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Riwayat Peminjaman',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // riwayat dari users/{uid}/borrowings
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .collection('borrowings')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Gagal memuat riwayat');
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  var docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return const Text('Belum ada peminjaman');
                  }
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      var b = docs[index].data() as Map<String, dynamic>;
                      String st = (b['status'] ?? 'Menunggu').toString();
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading:
                            Icon(Icons.history, color: Colors.teal.shade600),
                        title: Text(b['item_name'] ?? '-'),
                        subtitle: Text(formatTanggal(b['borrow_date'])),
                        trailing: Text(
                          st,
                          style: TextStyle(
                            color: _warnaPengajuan(st),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout),
                label: const Text('Keluar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}