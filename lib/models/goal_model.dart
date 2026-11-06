import 'package:cloud_firestore/cloud_firestore.dart';

/// Data dan progres target tabungan.
class GoalModel {
  final String id;
  final String name;
  final double target;
  final double saved;

  GoalModel({
    required this.id,
    required this.name,
    required this.target,
    required this.saved,
  });

  /// Progres tersimpan dalam rentang 0 sampai 1.
  double get progress => target <= 0 ? 0 : (saved / target).clamp(0.0, 1.0);

  /// Persentase progres yang dibulatkan.
  int get percent => (progress * 100).round();

  /// Menandai target yang sudah tercapai.
  bool get done => target > 0 && saved >= target;

  /// Menghitung dana yang masih dibutuhkan.
  double get remaining => (target - saved) < 0 ? 0 : target - saved;

  /// Membuat model dari dokumen Firestore.
  factory GoalModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? {};
    return GoalModel(
      id: d.id,
      name: (m['name'] ?? '') as String,
      target: ((m['target'] ?? 0) as num).toDouble(),
      saved: ((m['saved'] ?? 0) as num).toDouble(),
    );
  }
}
