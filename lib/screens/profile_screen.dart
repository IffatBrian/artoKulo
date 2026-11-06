import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/user_avatar.dart';

// Menampilkan dan mengubah profil pengguna.
class ProfileScreen extends StatefulWidget {
  final FirestoreService fs;
  const ProfileScreen({super.key, required this.fs});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

// Mengelola data profil, foto, dan sesi akun.
class _ProfileScreenState extends State<ProfileScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  bool _nameReady = false, _busy = false;

  /// Melepas pengendali nama.
  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  /// Memilih foto dan menyimpannya ke profil.
  Future<void> _pick(ImageSource source) async {
    try {
      final x = await ImagePicker().pickImage(
          source: source, maxWidth: 512, maxHeight: 512, imageQuality: 75);
      if (x == null) return;
      setState(() => _busy = true);
      final bytes = await x.readAsBytes();
      await widget.fs.updateProfile(photoBase64: base64Encode(bytes));
      if (mounted) showToast(context, 'Foto profil diperbarui');
    } catch (e) {
      if (mounted) showToast(context, 'Gagal mengganti foto: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Menghapus foto profil tersimpan.
  Future<void> _removePhoto() async {
    setState(() => _busy = true);
    try {
      await widget.fs.removePhoto();
      if (mounted) showToast(context, 'Foto profil dihapus');
    } catch (e) {
      if (mounted) showToast(context, 'Gagal menghapus foto: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Menampilkan pilihan pengelolaan foto.
  void _showPhotoSheet(bool hasPhoto) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(9999))),
              ),
              const SizedBox(height: 16),
              const Text('Foto profil',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              _SheetOption(
                  icon: Icons.photo_library_outlined,
                  label: 'Pilih dari galeri',
                  onTap: () {
                    Navigator.pop(context);
                    _pick(ImageSource.gallery);
                  }),
              _SheetOption(
                  icon: Icons.photo_camera_outlined,
                  label: 'Ambil foto',
                  onTap: () {
                    Navigator.pop(context);
                    _pick(ImageSource.camera);
                  }),
              if (hasPhoto)
                _SheetOption(
                    icon: Icons.delete_outline_rounded,
                    label: 'Hapus foto',
                    danger: true,
                    onTap: () {
                      Navigator.pop(context);
                      _removePhoto();
                    }),
            ],
          ),
        ),
      ),
    );
  }

  /// Menyimpan nama baru ke Firebase.
  Future<void> _saveName() async {
    if (!_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _busy = true);
    try {
      final name = _name.text.trim();
      await widget.fs.updateProfile(name: name);
      await FirebaseAuth.instance.currentUser?.updateDisplayName(name);
      if (mounted) showToast(context, 'Nama berhasil diperbarui');
    } catch (e) {
      if (mounted) showToast(context, 'Gagal menyimpan: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Mengonfirmasi dan mengakhiri sesi pengguna.
  Future<void> _logout() async {
    final nav = Navigator.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Keluar dari akun?',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
        content: const Text(
            'Sesi kamu akan diakhiri. Kamu perlu masuk lagi untuk mengakses catatan.',
            style: TextStyle(color: AppColors.hint)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child:
                  const Text('Batal', style: TextStyle(color: AppColors.hint))),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Keluar',
                  style: TextStyle(color: AppColors.expense))),
        ],
      ),
    );
    if (ok != true) return;
    nav.popUntil((r) => r.isFirst);
    await AuthService().logout();
  }

  @override
  Widget build(BuildContext context) {
    final authUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: SafeArea(
        child: StreamBuilder(
          stream: widget.fs.userStream(),
          builder: (context, snap) {
            final data = snap.data?.data();
            final name = (data?['name'] as String?) ??
                authUser?.displayName ??
                'Pengguna';
            final email = (data?['email'] as String?) ?? authUser?.email ?? '-';
            final photo = data?['photoBase64'] as String?;
            final created = (data?['createdAt'] as dynamic)?.toDate();

            if (!_nameReady && snap.hasData) {
              _name.text = name;
              _nameReady = true;
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                // Avatar + tombol ganti foto
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      GestureDetector(
                        onTap: _busy
                            ? null
                            : () => _showPhotoSheet(
                                photo != null && photo.isNotEmpty),
                        child: UserAvatar(
                            name: name,
                            photoBase64: photo,
                            size: 120,
                            ring: true),
                      ),
                      if (_busy)
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                              color: Colors.white.soft(0.7),
                              shape: BoxShape.circle),
                          child: const Center(
                              child: SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 3))),
                        ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: _busy
                              ? null
                              : () => _showPhotoSheet(
                                  photo != null && photo.isNotEmpty),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: const Icon(Icons.photo_camera_rounded,
                                color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(email,
                    textAlign: TextAlign.center,
                    style:
                        const TextStyle(color: AppColors.hint, fontSize: 14)),
                const SizedBox(height: 24),

                // Statistik
                StreamBuilder<List<TransactionModel>>(
                  stream: widget.fs.transactions(),
                  builder: (context, txSnap) {
                    final items = txSnap.data ?? [];
                    return Row(
                      children: [
                        Expanded(
                            child: _StatTile(
                                icon: Icons.receipt_long_rounded,
                                label: 'Transaksi',
                                value: '${items.length}')),
                        const SizedBox(width: 16),
                        Expanded(
                            child: _StatTile(
                                icon: Icons.event_available_rounded,
                                label: 'Bergabung',
                                value: created == null
                                    ? '-'
                                    : DateFormat('MMM yyyy', 'id_ID')
                                        .format(created))),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 32),

                // Form ubah nama
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: cardDecoration(),
                  child: Form(
                    key: _form,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Informasi Akun',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _name,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                              labelText: 'Nama lengkap',
                              prefixIcon: Icon(Icons.person_outline_rounded)),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Nama wajib diisi'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: email,
                          enabled: false,
                          decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.mail_outline_rounded),
                              filled: true,
                              fillColor: AppColors.background),
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: _busy ? null : _saveName,
                          child: const Text('Simpan Perubahan'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: _logout,
                  style: TextButton.styleFrom(
                      foregroundColor: AppColors.expense,
                      minimumSize: const Size.fromHeight(52)),
                  icon: const Icon(Icons.logout_rounded, size: 20),
                  label: const Text('Keluar'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// Menampilkan satu statistik akun.
class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _StatTile(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: cardDecoration(radius: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                  color: AppColors.secondary, shape: BoxShape.circle),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style:
                          const TextStyle(color: AppColors.hint, fontSize: 12)),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(value,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            fontFeatures: tnum)),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

// Menampilkan opsi pada lembar foto profil.
class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;
  const _SheetOption(
      {required this.icon,
      required this.label,
      required this.onTap,
      this.danger = false});

  @override
  Widget build(BuildContext context) {
    final c = danger ? AppColors.expense : AppColors.primary;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: danger ? const Color(0xFFFFDAD6) : AppColors.secondary,
                  shape: BoxShape.circle),
              child: Icon(icon, color: c, size: 20),
            ),
            const SizedBox(width: 12),
            Text(label,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: danger ? AppColors.expense : AppColors.text)),
          ],
        ),
      ),
    );
  }
}
