import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Color warnaStatus(String status) {
  if (status == 'Available') return Colors.green;
  if (status == 'Borrowed') return Colors.orange;
  return Colors.grey;
}

String formatTanggal(dynamic nilai) {
  if (nilai is Timestamp) {
    DateTime t = nilai.toDate();
    return '${t.day}/${t.month}/${t.year}';
  }
  return '-';
}


Widget gambarItem(String url, {double? lebar, double? tinggi}) {
  Widget pengganti = Container(
    width: lebar,
    height: tinggi,
    color: Colors.teal.shade50,
    child: Icon(
      Icons.science_outlined,
      color: Colors.teal.shade300,
    ),
  );

  if (url.isEmpty) return pengganti;

  if (url.startsWith('assets/')) {
    return Image.asset(
      url,
      width: lebar,
      height: tinggi,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => pengganti,
    );
  }

  return Image.network(
    url,
    width: lebar,
    height: tinggi,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) => pengganti,
  );
}
