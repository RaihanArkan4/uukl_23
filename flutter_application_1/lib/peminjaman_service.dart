import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> ajukanPinjam(BuildContext context, DocumentSnapshot doc) async {
  final messenger = ScaffoldMessenger.of(context);
  User? user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    messenger.showSnackBar(
      const SnackBar(content: Text('Login dulu untuk mengajukan pinjaman')),
    );
    return;
  }

  var item = doc.data() as Map<String, dynamic>;
  if (item['status'] != 'Available') {
    messenger.showSnackBar(
      const SnackBar(content: Text('Alat sedang dipinjam')),
    );
    return;
  }

  try {
    var borrowings = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('borrowings');

    var sudah = await borrowings
        .where('item_id', isEqualTo: doc.id)
        .where('status', isEqualTo: 'Menunggu')
        .get();
    if (sudah.docs.isNotEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Pengajuan alat ini sudah dikirim')),
      );
      return;
    }

    var u = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    String nama = (u.data()?['name'] ?? user.email ?? '').toString();

    var ref = borrowings.doc();
    await ref.set({
      'borrow_id': ref.id,
      'item_id': doc.id,
      'item_name': item['item_name'] ?? '',
      'borrow_date': FieldValue.serverTimestamp(),
      'status': 'Menunggu',
      'user_id': user.uid,
      'user_name': nama,
    });

    messenger.showSnackBar(
      SnackBar(
          content: Text('Pengajuan ${item['item_name']} terkirim, menunggu persetujuan')),
    );
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text('Gagal mengajukan: $e')));
  }
}

Future<void> setujuiPinjam(BuildContext context, DocumentSnapshot b) async {
  final messenger = ScaffoldMessenger.of(context);
  var data = b.data() as Map<String, dynamic>;

  try {
    var itemRef =
        FirebaseFirestore.instance.collection('items').doc(data['item_id']);
    var item = await itemRef.get();

    if (!item.exists || item['status'] != 'Available') {
      messenger.showSnackBar(
        const SnackBar(content: Text('Alat sudah tidak tersedia')),
      );
      return;
    }

    var batch = FirebaseFirestore.instance.batch();
    batch.update(b.reference, {'status': 'Disetujui'});
    batch.update(itemRef, {'status': 'Borrowed'});
    await batch.commit();

    messenger.showSnackBar(
      SnackBar(content: Text('${data['item_name']} disetujui')),
    );
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text('Gagal menyetujui: $e')));
  }
}

Future<void> tolakPinjam(BuildContext context, DocumentSnapshot b) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    await b.reference.update({'status': 'Ditolak'});
    messenger.showSnackBar(
      const SnackBar(content: Text('Pengajuan ditolak')),
    );
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text('Gagal menolak: $e')));
  }
}