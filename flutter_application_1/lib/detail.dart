
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'helper.dart';
import 'peminjaman_service.dart';

void bukaDetail(BuildContext context, DocumentSnapshot doc) {
  var item = doc.data() as Map<String, dynamic>;
  String status = item['status'] ?? '';

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: gambarItem(
                item['image'] ?? '',
                lebar: double.infinity,
                tinggi: 180,
              ),
            ),
            const SizedBox(height: 16),

            Text(
              item['item_name'] ?? '-',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),
            Text('${item['category'] ?? '-'}  •  ${item['code'] ?? '-'}'),

            const SizedBox(height: 4),
            Text(
              status,
              style: TextStyle(
                color: warnaStatus(status),
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),
            Text(item['spesification'] ?? '-'),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: status == 'Available'
                    ? () {
                        Navigator.pop(sheetContext);
                        ajukanPinjam(context, doc);
                      }
                    : null,
                child: Text(
                  status == 'Available'
                      ? 'Ajukan Pinjam'
                      : 'Sedang dipinjam',
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
