import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common.dart';

// Menampilkan layar pembuka sebelum berpindah halaman.
class SplashScreen extends StatefulWidget {
  final Widget next;
  const SplashScreen({super.key, required this.next});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// Mengatur animasi dan navigasi awal.
class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1200))
    ..forward();

  /// Menjadwalkan perpindahan ke halaman berikutnya.
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2400), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => widget.next,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ));
    });
  }

  /// Melepas pengendali animasi.
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fade = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEAF4FD), AppColors.background],
          ),
        ),
        child: FadeTransition(
          opacity: fade,
          child: ScaleTransition(
            scale: Tween(begin: 0.9, end: 1.0).animate(fade),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppLogo(size: 104),
                SizedBox(height: 24),
                Text('artoKulo',
                    style:
                        TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
                SizedBox(height: 8),
                Text('By: Baihaqi',
                    style: TextStyle(color: AppColors.hint, fontSize: 14)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
