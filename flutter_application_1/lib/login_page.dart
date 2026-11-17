import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _namaController = TextEditingController();
  final _kelasController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _modeLogin = true; // true = login, false = register
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _namaController.dispose();
    _kelasController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _pesan(String teks) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(teks)));
  }

  void _keHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainPage()),
    );
  }

  String _pesanError(FirebaseAuthException e) {
    if (e.code == 'user-not-found' ||
        e.code == 'wrong-password' ||
        e.code == 'invalid-credential') {
      return 'Email atau password salah';
    }
    if (e.code == 'email-already-in-use') return 'Email sudah terdaftar';
    if (e.code == 'weak-password') return 'Password minimal 6 karakter';
    if (e.code == 'invalid-email') return 'Format email tidak valid';
    return e.message ?? 'Terjadi kesalahan';
  }

  Future<void> _submit() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String nama = _namaController.text.trim();
    String kelas = _kelasController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _pesan('Email dan password wajib diisi');
      return;
    }
    if (!_modeLogin && (nama.isEmpty || kelas.isEmpty)) {
      _pesan('Nama dan kelas wajib diisi');
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (_modeLogin) {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
      } else {
        UserCredential hasil = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        String uid = hasil.user!.uid;

        // simpan identitas ke users/{uid}
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'user_id': uid,
          'name': nama,
          'email': email,
          'kelas': kelas,
          'created_at': FieldValue.serverTimestamp(),
          'foto': '',
        }).timeout(const Duration(seconds: 10));
      }

      if (!mounted) return;
      _keHome();
    } on FirebaseAuthException catch (e) {
      _pesan(_pesanError(e));
    } catch (e) {
      _pesan('Terjadi kesalahan: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _dekorasi(String hint, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      suffixIcon: suffix,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.teal.shade600, width: 1.8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tinggi = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.teal.shade700,
      body: Stack(
        children: [
          // header gradasi + pola gelombang
          Container(
            height: tinggi * 0.35,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.teal.shade200,
                  Colors.teal.shade600,
                  Colors.teal.shade800,
                ],
              ),
            ),
            child: CustomPaint(
              size: Size.infinite,
              painter: _WavePatternPainter(),
            ),
          ),

          // kartu putih berisi form
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: tinggi * 0.8,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(36),
                  topRight: Radius.circular(36),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 36, 28, 24),
                child: Column(
                  children: [
                    Text(
                      _modeLogin ? 'Welcome Back' : 'Buat Akun',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _modeLogin
                          ? 'Siap mengelola data inventaris lab?\nSilakan masuk ke akun Anda.'
                          : 'Isi data diri untuk mendaftar.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // nama & kelas hanya muncul saat register
                    if (!_modeLogin) ...[
                      TextField(
                        controller: _namaController,
                        decoration: _dekorasi('Nama'),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _kelasController,
                        decoration: _dekorasi('Kelas'),
                      ),
                      const SizedBox(height: 16),
                    ],

                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _dekorasi('Enter email'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: _dekorasi(
                        'Password',
                        suffix: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Colors.grey.shade500,
                          ),
                          onPressed: () {
                            setState(
                                () => _obscurePassword = !_obscurePassword);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // tombol login / sign up
                    Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.teal.shade400, Colors.teal.shade700],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.teal.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5),
                              )
                            : Text(
                                _modeLogin ? 'Log In' : 'Sign Up',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // masuk sebagai tamu (hapus kalau tidak dibutuhkan)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : _keHome,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.teal.shade600),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Masuk tanpa login',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.teal.shade700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // pindah mode login <-> register
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _modeLogin
                              ? "Don't have an account? "
                              : 'Sudah punya akun? ',
                          style: TextStyle(
                              color: Colors.grey.shade700, fontSize: 13.5),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (_isLoading) return;
                            setState(() {
                              _modeLogin = !_modeLogin;
                              _emailController.clear();
                              _passwordController.clear();
                              _namaController.clear();
                              _kelasController.clear();
                              _obscurePassword = true;
                            });
                          },
                          child: Text(
                            _modeLogin ? 'Sign Up' : 'Log In',
                            style: TextStyle(
                              color: Colors.teal.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// pola garis gelombang di header
class _WavePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (int i = 0; i < 28; i++) {
      final path = Path();
      double offset = i * 10.0;
      path.moveTo(0, offset);
      path.quadraticBezierTo(
        size.width * 0.45,
        size.height * 0.65 + offset * 0.4,
        size.width,
        offset * 0.6,
      );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}