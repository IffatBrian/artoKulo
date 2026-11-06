import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../services/firestore_service.dart';
import '../theme.dart';
import '../widgets/amount_input.dart';
import '../widgets/common.dart';

// Form untuk mencatat transaksi baru.
class TransactionFormScreen extends StatefulWidget {
  final FirestoreService fs;
  const TransactionFormScreen({super.key, required this.fs});

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

// Mengelola input dan penyimpanan transaksi.
class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _amount = TextEditingController();
  final _note = TextEditingController();
  TxType _type = TxType.expense;
  DateTime _date = DateTime.now();
  bool _saving = false;

  /// Melepas semua pengendali input.
  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  /// Memilih tanggal transaksi.
  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d != null) setState(() => _date = d);
  }

  /// Memvalidasi dan menyimpan transaksi.
  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final now = DateTime.now();
      // Gabungkan tanggal pilihan dengan jam saat ini agar urutan akurat.
      final when = DateTime(
          _date.year, _date.month, _date.day, now.hour, now.minute, now.second);
      await widget.fs.add(
        title: _title.text.trim(),
        amount: parseRupiah(_amount.text)!,
        type: _type,
        note: _note.text.trim(),
        date: when,
      );
      if (mounted) {
        Navigator.pop(context);
        showToast(context, 'Transaksi berhasil disimpan');
      }
    } catch (e) {
      if (mounted) showToast(context, 'Gagal menyimpan: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Transaksi')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tipe transaksi',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(children: [
                  TypeChip(
                    label: 'Pengeluaran',
                    icon: Icons.north_east_rounded,
                    active: _type == TxType.expense,
                    activeColor: AppColors.expense,
                    onTap: () => setState(() => _type = TxType.expense),
                  ),
                  const SizedBox(width: 12),
                  TypeChip(
                    label: 'Pemasukan',
                    icon: Icons.south_west_rounded,
                    active: _type == TxType.income,
                    activeColor: AppColors.income,
                    onTap: () => setState(() => _type = TxType.income),
                  ),
                ]),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _title,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                      labelText: 'Judul transaksi',
                      hintText: 'cth. Makan siang'),
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
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                        labelText: 'Tanggal',
                        suffixIcon: Icon(Icons.calendar_today_rounded,
                            size: 18, color: AppColors.primary)),
                    child: Text(
                        DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_date)),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _note,
                  maxLines: 3,
                  decoration: const InputDecoration(
                      labelText: 'Catatan (opsional)',
                      alignLabelWithHint: true),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Simpan Transaksi'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
