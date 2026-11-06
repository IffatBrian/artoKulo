import 'package:cloud_firestore/cloud_firestore.dart';

/// Jenis transaksi keuangan.
enum TxType { income, expense }

/// Data transaksi pemasukan atau pengeluaran.
class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final TxType type;
  final String note;
  final DateTime date;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.note,
    required this.date,
  });

  /// Memeriksa apakah transaksi berupa pemasukan.
  bool get isIncome => type == TxType.income;

  /// Membuat model dari dokumen Firestore.
  factory TransactionModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? {};
    return TransactionModel(
      id: d.id,
      title: (m['title'] ?? '') as String,
      amount: ((m['amount'] ?? 0) as num).toDouble(),
      type: m['type'] == 'income' ? TxType.income : TxType.expense,
      note: (m['note'] ?? '') as String,
      date: ((m['date'] as Timestamp?) ?? Timestamp.now()).toDate(),
    );
  }

  /// Mengubah data transaksi ke format Firestore.
  static Map<String, dynamic> toMap({
    required String title,
    required double amount,
    required TxType type,
    required String note,
    required DateTime date,
  }) =>
      {
        'title': title,
        'amount': amount,
        'type': type == TxType.income ? 'income' : 'expense',
        'note': note,
        'date': Timestamp.fromDate(date),
      };
}
