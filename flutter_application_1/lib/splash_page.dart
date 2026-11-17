import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'main_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), _arahkan);
  }

  void _arahkan() {
    if (!mounted) return;
    User? user = FirebaseAuth.instance.currentUser;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            user != null ? const MainPage() : const LoginPage(),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lebar = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.teal.shade600,
      body: Stack(
        children: [
          Positioned(
            bottom: -lebar * 0.75,
            left: -lebar * 0.35,
            child: Container(
              width: lebar * 1.7,
              height: lebar * 1.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            bottom: -lebar * 0.6,
            right: -lebar * 0.45,
            child: Container(
              width: lebar * 1.2,
              height: lebar * 1.2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 64,
                  height: 72,
                  child: CustomPaint(painter: _BeakerPainter()),
                ),
                SizedBox(height: 12),
                Text(
                  'Inventaris Lab',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BeakerPainter extends CustomPainter {
  const _BeakerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final garis = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final isi = Paint()
      ..color = Colors.white.withOpacity(0.35)
      ..style = PaintingStyle.fill;

    final cairan = Path()
      ..moveTo(w * 0.16, h * 0.52)
      ..quadraticBezierTo(w * 0.33, h * 0.46, w * 0.5, h * 0.52)
      ..quadraticBezierTo(w * 0.67, h * 0.58, w * 0.84, h * 0.52)
      ..lineTo(w * 0.84, h * 0.84)
      ..quadraticBezierTo(w * 0.84, h * 0.95, w * 0.72, h * 0.95)
      ..lineTo(w * 0.28, h * 0.95)
      ..quadraticBezierTo(w * 0.16, h * 0.95, w * 0.16, h * 0.84)
      ..close();
    canvas.drawPath(cairan, isi);

    final badan = Path()
      ..moveTo(w * 0.16, h * 0.06)
      ..lineTo(w * 0.16, h * 0.84)
      ..quadraticBezierTo(w * 0.16, h * 0.95, w * 0.28, h * 0.95)
      ..lineTo(w * 0.72, h * 0.95)
      ..quadraticBezierTo(w * 0.84, h * 0.95, w * 0.84, h * 0.84)
      ..lineTo(w * 0.84, h * 0.06);
    canvas.drawPath(badan, garis);
   
    canvas.drawLine(
        Offset(w * 0.07, h * 0.06), Offset(w * 0.93, h * 0.06), garis);
  
    final ukur = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
        Offset(w * 0.16, h * 0.24), Offset(w * 0.34, h * 0.24), ukur);
    canvas.drawLine(
        Offset(w * 0.16, h * 0.36), Offset(w * 0.28, h * 0.36), ukur);

    final gelembung = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset(w * 0.42, h * 0.76), w * 0.06, gelembung);
    canvas.drawCircle(Offset(w * 0.6, h * 0.68), w * 0.045, gelembung);
    canvas.drawCircle(Offset(w * 0.66, h * 0.82), w * 0.035, gelembung);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}