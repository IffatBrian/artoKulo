import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/flow_chart.dart';
import '../widgets/user_avatar.dart';
import 'goals_screen.dart';
import 'profile_screen.dart';
import 'transaction_detail_screen.dart';
import 'transaction_form_screen.dart';

// Menampilkan ringkasan dan riwayat transaksi.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Meminta konfirmasi sebelum keluar.
  Future<void> _confirmLogout(BuildContext context) async {
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
    if (ok == true) await AuthService().logout();
  }

  // Menampilkan dialog konfirmasi umum.
  Future<bool> _confirm(
      BuildContext context, String title, String message, String action) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
        content: Text(message, style: const TextStyle(color: AppColors.hint)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child:
                  const Text('Batal', style: TextStyle(color: AppColors.hint))),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(action,
                  style: const TextStyle(color: AppColors.expense))),
        ],
      ),
    );
    return ok == true;
  }

  // Menghapus seluruh riwayat transaksi.
  Future<void> _deleteAll(
      BuildContext context, FirestoreService fs, int count) async {
    final ok = await _confirm(
        context,
        'Hapus semua riwayat?',
        '$count transaksi akan dihapus permanen dan tidak bisa dikembalikan.',
        'Hapus semua');
    if (!ok) return;
    try {
      await fs.deleteAll();
      if (context.mounted) showToast(context, 'Seluruh riwayat dihapus');
    } catch (e) {
      if (context.mounted) showToast(context, 'Gagal menghapus: $e');
    }
  }

  @override
  // Menyusun dasbor dan memuat transaksi.
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final fs = FirestoreService(user.uid);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Transaksi',
            style: TextStyle(fontWeight: FontWeight.w600)),
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => TransactionFormScreen(fs: fs))),
      ),
      body: SafeArea(
        child: StreamBuilder<List<TransactionModel>>(
          stream: fs.transactions(),
          builder: (context, snap) {
            if (snap.hasError) {
              return Center(
                  child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Gagal memuat data:\n${snap.error}',
                    textAlign: TextAlign.center),
              ));
            }
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final items = snap.data!;
            double income = 0, expense = 0;
            for (final t in items) {
              t.isIncome ? income += t.amount : expense += t.amount;
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 112),
              children: [
                _Header(
                    fs: fs,
                    fallbackName: user.displayName,
                    onLogout: () => _confirmLogout(context)),
                const SizedBox(height: 24),
                _HeroCard(
                    balance: income - expense,
                    income: income,
                    expense: expense),
                const SizedBox(height: 16),
                _StatCard(total: items.length),
                const SizedBox(height: 32),
                GoalsSection(fs: fs),
                const SizedBox(height: 32),
                FlowChart(items: items),
                const SizedBox(height: 32),
                Row(
                  children: [
                    const Expanded(
                      child: Text('Riwayat Transaksi',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600)),
                    ),
                    if (items.isNotEmpty)
                      TextButton.icon(
                        onPressed: () => _deleteAll(context, fs, items.length),
                        style: TextButton.styleFrom(
                            foregroundColor: AppColors.expense),
                        icon: const Icon(Icons.delete_sweep_outlined, size: 18),
                        label: const Text('Hapus semua'),
                      ),
                  ],
                ),
                if (items.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Text('Geser ke kiri untuk menghapus satu transaksi',
                        style: TextStyle(color: AppColors.hint, fontSize: 12)),
                  ),
                const SizedBox(height: 16),
                if (items.isEmpty)
                  const _EmptyState()
                else
                  ...items.map((t) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Dismissible(
                          key: ValueKey(t.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 16),
                            decoration: BoxDecoration(
                                color: const Color(0xFFFFF1F0),
                                borderRadius: BorderRadius.circular(16)),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFDAD6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.delete_outline_rounded,
                                      color: AppColors.expense, size: 18),
                                  SizedBox(width: 4),
                                  Text(
                                    'Hapus',
                                    style: TextStyle(
                                      color: AppColors.expense,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          confirmDismiss: (_) => _confirm(
                              context,
                              'Hapus transaksi?',
                              '"${t.title}" akan dihapus permanen.',
                              'Hapus'),
                          onDismissed: (_) {
                            fs.delete(t.id);
                            showToast(context, 'Transaksi dihapus');
                          },
                          child: _TxRow(
                            tx: t,
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => TransactionDetailScreen(
                                        fs: fs, tx: t))),
                          ),
                        ),
                      )),
              ],
            );
          },
        ),
      ),
    );
  }
}

// Menampilkan sapaan, profil, dan tombol keluar.
class _Header extends StatelessWidget {
  final FirestoreService fs;
  final String? fallbackName;
  final VoidCallback onLogout;
  const _Header(
      {required this.fs, required this.fallbackName, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: fs.userStream(),
      builder: (context, snap) {
        final name = (snap.data?.data()?['name'] as String?) ??
            fallbackName ??
            'Pengguna';
        return Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => ProfileScreen(fs: fs))),
              child: UserAvatar(
                  name: name,
                  photoBase64: snap.data?.data()?['photoBase64'] as String?,
                  size: 48),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Selamat datang,',
                      style: TextStyle(color: AppColors.hint, fontSize: 12)),
                  Text(name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Keluar',
              onPressed: onLogout,
              style: IconButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  side: const BorderSide(color: AppColors.borderSoft)),
              icon: const Icon(Icons.logout_rounded,
                  color: AppColors.primary, size: 20),
            ),
          ],
        );
      },
    );
  }
}

// Menampilkan saldo serta total pemasukan dan pengeluaran.
class _HeroCard extends StatelessWidget {
  final double balance, income, expense;
  const _HeroCard(
      {required this.balance, required this.income, required this.expense});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: heroGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
              color: Color(0x401D72B8), blurRadius: 32, offset: Offset(0, 12))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total Saldo',
              style: TextStyle(color: Colors.white.soft(0.8), fontSize: 14)),
          const SizedBox(height: 4),
          Text(rupiah(balance),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  fontFeatures: tnum)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                  child: _MiniFlow(
                      icon: Icons.arrow_downward_rounded,
                      label: 'Pemasukan',
                      value: income)),
              const SizedBox(width: 12),
              Expanded(
                  child: _MiniFlow(
                      icon: Icons.arrow_upward_rounded,
                      label: 'Pengeluaran',
                      value: expense)),
            ],
          ),
        ],
      ),
    );
  }
}

// Menampilkan nilai untuk satu jenis arus dana.
class _MiniFlow extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  const _MiniFlow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.white.soft(0.16),
            borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                  color: Colors.white.soft(0.2), shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          color: Colors.white.soft(0.8), fontSize: 10)),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(rupiah(value),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            fontFeatures: tnum)),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

// Menampilkan jumlah transaksi tercatat.
class _StatCard extends StatelessWidget {
  final int total;
  const _StatCard({required this.total});

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
              child: const Icon(Icons.receipt_long_rounded,
                  color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Total transaksi tercatat',
                  style: TextStyle(color: AppColors.hint, fontSize: 14)),
            ),
            Text('$total',
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    fontFeatures: tnum)),
          ],
        ),
      );
}

// Menampilkan satu transaksi pada daftar riwayat.
class _TxRow extends StatelessWidget {
  final TransactionModel tx;
  final VoidCallback onTap;
  const _TxRow({required this.tx, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderSoft),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                    color: AppColors.secondary, shape: BoxShape.circle),
                child: Icon(
                    tx.isIncome
                        ? Icons.south_west_rounded
                        : Icons.north_east_rounded,
                    color: AppColors.primary,
                    size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tx.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(
                        '${tx.isIncome ? 'Pemasukan' : 'Pengeluaran'} • ${DateFormat('d MMM yyyy', 'id_ID').format(tx.date)}',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.hint)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text('${tx.isIncome ? '+' : '-'}${rupiah(tx.amount)}',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontFeatures: tnum,
                      color: tx.isIncome ? AppColors.income : AppColors.text)),
            ],
          ),
        ),
      ),
    );
  }
}

// Menjelaskan kondisi saat belum ada transaksi.
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        decoration: cardDecoration(),
        child: const Column(
          children: [
            Icon(Icons.spa_outlined, size: 40, color: AppColors.primary),
            SizedBox(height: 12),
            Text('Belum ada transaksi',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 4),
            Text('Tekan tombol "Transaksi" untuk mencatat yang pertama.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.hint, fontSize: 12)),
          ],
        ),
      );
}
