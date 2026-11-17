import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'helper.dart';
import 'peminjaman_service.dart';

class PersetujuanPage extends StatelessWidget {
  const PersetujuanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Persetujuan'),
        backgroundColor: Colors.teal.shade600,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collectionGroup('borrowings')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var menunggu = snapshot.data!.docs.where((d) {
            var b = d.data() as Map<String, dynamic>;
            return b['status'] == 'Menunggu';
          }).toList();

          if (menunggu.isEmpty) {
            return const Center(child: Text('Tidak ada pengajuan'));
          }

          return ListView.builder(
            itemCount: menunggu.length,
            itemBuilder: (context, index) {
              var b = menunggu[index].data() as Map<String, dynamic>;
              return ListTile(
                leading: Icon(Icons.pending_actions, color: Colors.orange),
                title: Text(b['item_name'] ?? '-'),
                subtitle: Text(
                    'Diajukan oleh ${b['user_name'] ?? '-'}\n${formatTanggal(b['borrow_date'])}'),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      tooltip: 'Setujui',
                      onPressed: () => setujuiPinjam(context, menunggu[index]),
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      tooltip: 'Tolak',
                      onPressed: () => tolakPinjam(context, menunggu[index]),
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