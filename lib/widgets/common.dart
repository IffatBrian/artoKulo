import 'package:flutter/material.dart';
import '../theme.dart';

/// Menampilkan logo aplikasi.
class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, this.size = 88});

  @override
  Widget build(BuildContext context) => Image.asset(
        'assets/logo.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
      );
}

/// Chip pill (aktif: warna tipe, nonaktif: abu muda).
class TypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final Color? activeColor;
  final VoidCallback onTap;
  const TypeChip({
    super.key,
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final c = activeColor ?? AppColors.primary;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: active ? c.soft(0.12) : AppColors.chipInactive,
            borderRadius: BorderRadius.circular(9999),
            border: Border.all(color: active ? c : Colors.transparent),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: active ? c : AppColors.hint),
              const SizedBox(width: 8),
              Text(label,
                  style: TextStyle(
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      color: active ? c : AppColors.hint)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Menampilkan pesan singkat di bagian bawah layar.
void showToast(BuildContext context, String msg) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(msg)));
}
