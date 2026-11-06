import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../services/firestore_service.dart';
import '../theme.dart';
import '../widgets/amount_input.dart';
import '../widgets/common.dart';

// Menampilkan dan mengubah detail transaksi.
class TransactionDetailScreen extends StatefulWidget {
  final FirestoreService fs;
  final TransactionModel tx;
  const TransactionDetailScreen(
      {super.key, required this.fs, required this.tx});

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

// Mengelola mode lihat, ubah, dan hapus.
class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  final _form = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.tx.title);
  late final _amount =
      TextEditingController(text: formatNumber(widget.tx.amount));
  late final _note = TextEditingController(text: widget.tx.note);
  bool _editing = false, _busy = false;

  /// Melepas semua pengendali input.
  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  /// Menyimpan perubahan transaksi.
  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await widget.fs.update(widget.tx.id,
          title: _title.text.trim(),
          amount: parseRupiah(_amount.text)!,
          note: _note.text.trim());
      if (mounted) {
        Navigator.pop(context);
        showToast(context, 'Perubahan disimpan');
      }
    } catch (e) {
      if (mounted) {
        showToast(context, 'Gagal menyimpan: $e');
        setState(() => _busy = false);
      }
    }
  }

  /// Meminta konfirmasi lalu menghapus transaksi.
  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus transaksi?',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
        content: Text('"${widget.tx.title}" akan dihapus permanen.',
            style: const TextStyle(color: AppColors.hint)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child:
                  const Text('Batal', style: TextStyle(color: AppColors.hint))),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus',
                  style: TextStyle(color: AppColors.expense))),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _busy = true);
    try {
      await widget.fs.delete(widget.tx.id);
      if (mounted) {
        Navigator.pop(context);
        showToast(context, 'Transaksi dihapus');
      }
    } catch (e) {
      if (mounted) {
        showToast(context, 'Gagal menghapus: $e');
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tx = widget.tx;
    final color = tx.isIncome ? AppColors.income : AppColors.expense;

    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? 'Ubah Transaksi' : 'Detail Transaksi'),
        actions: [
          if (!_editing)
            IconButton(
                tooltip: 'Ubah',
                onPressed: () => setState(() => _editing = true),
                icon:
                    const Icon(Icons.edit_outlined, color: AppColors.primary)),
          IconButton(
              tooltip: 'Hapus',
              onPressed: _busy ? null : _delete,
              icon: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.expense)),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: cardDecoration(),
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                            color: color.soft(0.12), shape: BoxShape.circle),
                        child: Icon(
                            tx.isIncome
                                ? Icons.south_west_rounded
                                : Icons.north_east_rounded,
                            color: color),
                      ),
                      const SizedBox(height: 16),
                      Text('${tx.isIncome ? '+' : '-'}${rupiah(tx.amount)}',
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: color,
                              fontFeatures: tnum)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(9999)),
                        child: Text(tx.isIncome ? 'Pemasukan' : 'Pengeluaran',
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (!_editing) ...[
                  _InfoRow(label: 'Judul', value: tx.title),
                  _InfoRow(
                      label: 'Tanggal',
                      value: DateFormat('EEEE, d MMMM yyyy • HH:mm', 'id_ID')
                          .format(tx.date)),
                  _InfoRow(
                      label: 'Catatan', value: tx.note.isEmpty ? '-' : tx.note),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => setState(() => _editing = true),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Ubah Nominal / Catatan'),
                  ),
                ] else ...[
                  TextFormField(
                    controller: _title,
                    decoration: const InputDecoration(labelText: 'Judul'),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Judul wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _amount,
                    keyboardType: TextInputType.number,
                    inputFormatters: [ThousandsFormatter()],
                    decoration: const InputDecoration(
                        labelText: 'Nominal', prefixText: 'Rp '),
                    validator: (v) {
                      final n = parseRupiah(v);
                      return (n == null || n <= 0)
                          ? 'Masukkan nominal lebih dari 0'
                          : null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _note,
                    maxLines: 3,
                    decoration: const InputDecoration(
                        labelText: 'Catatan', alignLabelWithHint: true),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _busy ? null : _save,
                    child: _busy
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Simpan Perubahan'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => setState(() => _editing = false),
                    child: const Text('Batal'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Menampilkan satu baris informasi transaksi.
class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSoft),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(color: AppColors.hint, fontSize: 12)),
            const SizedBox(height: 4),
            Text(value,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      );
}
