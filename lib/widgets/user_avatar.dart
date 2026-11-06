import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../theme.dart';

/// Avatar pengguna: foto (base64 dari Firestore) atau inisial nama.
class UserAvatar extends StatelessWidget {
  final String name;
  final String? photoBase64;
  final double size;
  final bool ring;
  const UserAvatar({
    super.key,
    required this.name,
    this.photoBase64,
    this.size = 48,
    this.ring = false,
  });

  /// Membaca foto profil dari format Base64.
  Uint8List? _bytes() {
    if (photoBase64 == null || photoBase64!.isEmpty) return null;
    try {
      return base64Decode(photoBase64!);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _bytes();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.secondary,
        shape: BoxShape.circle,
        border: ring ? Border.all(color: Colors.white, width: 4) : null,
        boxShadow: ring
            ? const [
                BoxShadow(
                    color: Color(0x261D72B8),
                    blurRadius: 24,
                    offset: Offset(0, 8))
              ]
            : null,
        image: bytes == null
            ? null
            : DecorationImage(
                image: MemoryImage(bytes),
                fit: BoxFit.cover,
              ),
      ),
      child: bytes == null
          ? Text(name.isEmpty ? '?' : name[0].toUpperCase(),
              style: TextStyle(
                  color: AppColors.primary,
                  fontSize: size * 0.4,
                  fontWeight: FontWeight.w700))
          : null,
    );
  }
}
