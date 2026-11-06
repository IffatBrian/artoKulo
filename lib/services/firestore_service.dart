import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/goal_model.dart';
import '../models/transaction_model.dart';

/// Struktur hirarki Firestore:
///   users (collection)
///     └─ {uid} (document)  -> name, email, createdAt
///          └─ transactions (sub-collection)
///               └─ {txId} (document) -> title, amount, type, note, date
class FirestoreService {
  final String uid;
  FirestoreService(this.uid);

  final _db = FirebaseFirestore.instance;

  /// Referensi dokumen profil pengguna.
  DocumentReference<Map<String, dynamic>> get _user =>
      _db.collection('users').doc(uid);

  /// Referensi koleksi transaksi pengguna.
  CollectionReference<Map<String, dynamic>> get _tx =>
      _user.collection('transactions');

  /// Mengalirkan perubahan profil pengguna.
  Stream<DocumentSnapshot<Map<String, dynamic>>> userStream() =>
      _user.snapshots();

  /// Mengalirkan transaksi dari tanggal terbaru.
  Stream<List<TransactionModel>> transactions() => _tx
      .orderBy('date', descending: true)
      .snapshots()
      .map((s) => s.docs.map(TransactionModel.fromDoc).toList());

  /// Menambahkan transaksi baru.
  Future<void> add({
    required String title,
    required double amount,
    required TxType type,
    required String note,
    required DateTime date,
  }) =>
      _tx.add({
        ...TransactionModel.toMap(
            title: title, amount: amount, type: type, note: note, date: date),
        'createdAt': FieldValue.serverTimestamp(),
      });

  /// Memperbarui detail transaksi.
  Future<void> update(String id,
          {required String title,
          required double amount,
          required String note}) =>
      _tx.doc(id).update({
        'title': title,
        'amount': amount,
        'note': note,
        'updatedAt': FieldValue.serverTimestamp(),
      });

  /// Menghapus satu transaksi.
  Future<void> delete(String id) => _tx.doc(id).delete();

  /// Menghapus seluruh riwayat dalam beberapa batch.
  Future<void> deleteAll() async {
    final snap = await _tx.get();
    for (var i = 0; i < snap.docs.length; i += 400) {
      final batch = _db.batch();
      for (final d in snap.docs.skip(i).take(400)) {
        batch.delete(d.reference);
      }
      await batch.commit();
    }
  }

  /// Menyimpan perubahan nama atau foto profil.
  Future<void> updateProfile({String? name, String? photoBase64}) => _user.set({
        if (name != null) 'name': name,
        if (photoBase64 != null) 'photoBase64': photoBase64,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

  /// Menghapus foto profil pengguna.
  Future<void> removePhoto() =>
      _user.set({'photoBase64': FieldValue.delete()}, SetOptions(merge: true));

  // ---------- Dompet / target tabungan: users/{uid}/goals/{goalId} ----------
  /// Referensi koleksi target tabungan.
  CollectionReference<Map<String, dynamic>> get _goals =>
      _user.collection('goals');

  /// Mengalirkan daftar target tabungan.
  Stream<List<GoalModel>> goals() => _goals
      .orderBy('createdAt')
      .snapshots()
      .map((s) => s.docs.map(GoalModel.fromDoc).toList());

  /// Membuat target tabungan baru.
  Future<void> addGoal({required String name, required double target}) =>
      _goals.add({
        'name': name,
        'target': target,
        'saved': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

  /// Memperbarui nama dan nominal target.
  Future<void> updateGoal(String id,
          {required String name, required double target}) =>
      _goals.doc(id).update({'name': name, 'target': target});

  /// Menyimpan jumlah dana pada target.
  Future<void> setGoalSaved(String id, double saved) =>
      _goals.doc(id).update({'saved': saved < 0 ? 0 : saved});

  /// Menghapus target tabungan.
  Future<void> deleteGoal(String id) => _goals.doc(id).delete();
}
