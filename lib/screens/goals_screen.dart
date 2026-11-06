import 'package:flutter/material.dart';
import '../models/goal_model.dart';
import '../services/firestore_service.dart';
import '../theme.dart';
import '../widgets/amount_input.dart';
import '../widgets/common.dart';
import '../widgets/goal_ring.dart';

const _sheetShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(24)));

// Membuka formulir tambah atau ubah target.
Future<void> showGoalForm(BuildContext context, FirestoreService fs,
    {GoalModel? goal}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: _sheetShape,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: _GoalForm(fs: fs, goal: goal),
    ),
  );
}

// Membuka panel pengelolaan target.
Future<void> showGoalManage(
    BuildContext context, FirestoreService fs, GoalModel goal) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: _sheetShape,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: _GoalManage(fs: fs, goal: goal),
    ),
  );
}

/// Persentase target.
class PercentLabel extends StatelessWidget {
  final GoalModel goal;
  final double fontSize;
  const PercentLabel({super.key, required this.goal, this.fontSize = 14});

  @override
  Widget build(BuildContext context) {
    final label =
        (goal.saved > 0 && goal.percent == 0) ? '<1%' : '${goal.percent}%';
    return Text(label,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: goal.done ? AppColors.income : AppColors.text,
            fontFeatures: tnum));
  }
}

// Menampilkan pegangan panel bawah.
class _Handle extends StatelessWidget {
  const _Handle();
  @override
  Widget build(BuildContext context) => Center(
        child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(9999))),
      );
}

// Dasbor.
class GoalsSection extends StatelessWidget {
  final FirestoreService fs;
  const GoalsSection({super.key, required this.fs});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<GoalModel>>(
      stream: fs.goals(),
      builder: (context, snap) {
        final goals = snap.data ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text('Dompet Tabungan',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                ),
                TextButton(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => GoalsScreen(fs: fs))),
                  child: const Text('Lihat semua'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (goals.isEmpty)
              GestureDetector(
                onTap: () => showGoalForm(context, fs),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: cardDecoration(),
                  child: const Row(
                    children: [
                      CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.secondary,
                          child: Icon(Icons.savings_outlined,
                              color: AppColors.primary)),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Buat target tabungan',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w700)),
                            SizedBox(height: 2),
                            Text('Mis. beli laptop, liburan, dana darurat.',
                                style: TextStyle(
                                    color: AppColors.hint, fontSize: 12)),
                          ],
                        ),
                      ),
                      Icon(Icons.add_rounded, color: AppColors.primary),
                    ],
                  ),
                ),
              )
            else
              SizedBox(
                height: 170,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  itemCount: goals.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, i) {
                    if (i == goals.length) return _AddCard(fs: fs);
                    final g = goals[i];
                    return GestureDetector(
                      onTap: () => showGoalManage(context, fs, g),
                      child: Container(
                        width: 140,
                        padding: const EdgeInsets.all(16),
                        decoration: cardDecoration(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GoalRing(
                              progress: g.progress,
                              size: 72,
                              stroke: 8,
                              child: PercentLabel(goal: g, fontSize: 14),
                            ),
                            const SizedBox(height: 12),
                            Text(g.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(rupiah(g.saved),
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.hint,
                                      fontFeatures: tnum)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

// Kartu untuk menambahkan target baru.
class _AddCard extends StatelessWidget {
  final FirestoreService fs;
  const _AddCard({required this.fs});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => showGoalForm(context, fs),
        child: Container(
          width: 100,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.secondary, width: 1.5),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.secondary,
                  child: Icon(Icons.add_rounded, color: AppColors.primary)),
              SizedBox(height: 8),
              Text('Baru',
                  style: TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
}

// Daftar target.
class GoalsScreen extends StatelessWidget {
  final FirestoreService fs;
  const GoalsScreen({super.key, required this.fs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dompet Tabungan')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Target Baru',
            style: TextStyle(fontWeight: FontWeight.w600)),
        onPressed: () => showGoalForm(context, fs),
      ),
      body: SafeArea(
        child: StreamBuilder<List<GoalModel>>(
          stream: fs.goals(),
          builder: (context, snap) {
            if (snap.hasError) {
              return Center(child: Text('Gagal memuat: ${snap.error}'));
            }
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final goals = snap.data!;
            if (goals.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.savings_outlined,
                          size: 48, color: AppColors.primary),
                      SizedBox(height: 12),
                      Text('Belum ada target tabungan',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      SizedBox(height: 4),
                      Text('Tekan "Target Baru" untuk memulai.',
                          style:
                              TextStyle(color: AppColors.hint, fontSize: 12)),
                    ],
                  ),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 112),
              itemCount: goals.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, i) {
                final g = goals[i];
                return InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () => showGoalManage(context, fs, g),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: cardDecoration(),
                    child: Row(
                      children: [
                        GoalRing(
                          progress: g.progress,
                          size: 80,
                          stroke: 9,
                          child: PercentLabel(goal: g, fontSize: 16),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(g.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(rupiah(g.saved),
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                      fontFeatures: tnum)),
                              Text('dari ${rupiah(g.target)}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.hint,
                                      fontFeatures: tnum)),
                              if (g.done) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                      color: AppColors.income.soft(0.12),
                                      borderRadius:
                                          BorderRadius.circular(9999)),
                                  child: const Text('Tercapai',
                                      style: TextStyle(
                                          color: AppColors.income,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700)),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// Form target.
// Formulir tambah dan ubah target.
class _GoalForm extends StatefulWidget {
  final FirestoreService fs;
  final GoalModel? goal;
  const _GoalForm({required this.fs, this.goal});

  @override
  State<_GoalForm> createState() => _GoalFormState();
}

// Mengelola validasi dan penyimpanan target.
class _GoalFormState extends State<_GoalForm> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.goal?.name ?? '');
  late final _target = TextEditingController(
      text: widget.goal == null ? '' : formatNumber(widget.goal!.target));
  bool _busy = false;

  /// Melepas pengendali formulir.
  @override
  void dispose() {
    _name.dispose();
    _target.dispose();
    super.dispose();
  }

  /// Menyimpan target baru atau perubahan.
  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      final name = _name.text.trim();
      final target = parseRupiah(_target.text)!;
      if (widget.goal == null) {
        await widget.fs.addGoal(name: name, target: target);
      } else {
        await widget.fs.updateGoal(widget.goal!.id, name: name, target: target);
      }
      if (mounted) {
        showToast(context, 'Target tabungan disimpan');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        showToast(context, 'Gagal menyimpan: $e');
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.goal != null;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Handle(),
              const SizedBox(height: 16),
              Text(editing ? 'Ubah Target' : 'Target Baru',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                    labelText: 'Nama target', hintText: 'cth. Beli laptop'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _target,
                keyboardType: TextInputType.number,
                inputFormatters: [ThousandsFormatter()],
                decoration: const InputDecoration(
                    labelText: 'Nominal target', prefixText: 'Rp '),
                validator: (v) {
                  final n = parseRupiah(v);
                  return (n == null || n <= 0)
                      ? 'Masukkan nominal lebih dari 0'
                      : null;
                },
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _busy ? null : _save,
                child: Text(editing ? 'Simpan Perubahan' : 'Buat Target'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Kelola target.
// Panel untuk mengelola dana dan detail target.
class _GoalManage extends StatefulWidget {
  final FirestoreService fs;
  final GoalModel goal;
  const _GoalManage({required this.fs, required this.goal});

  @override
  State<_GoalManage> createState() => _GoalManageState();
}

// Mengelola setor, tarik, dan penghapusan target.
class _GoalManageState extends State<_GoalManage> {
  final _form = GlobalKey<FormState>();
  final _amount = TextEditingController();
  bool _deposit = true, _busy = false;

  /// Melepas pengendali nominal.
  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  /// Menambah atau menarik dana dari target.
  Future<void> _apply() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      final v = parseRupiah(_amount.text)!;
      final g = widget.goal;
      await widget.fs.setGoalSaved(g.id, _deposit ? g.saved + v : g.saved - v);
      if (mounted) {
        showToast(context, _deposit ? 'Dana ditambahkan' : 'Dana ditarik');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        showToast(context, 'Gagal menyimpan: $e');
        setState(() => _busy = false);
      }
    }
  }

  /// Meminta konfirmasi lalu menghapus target.
  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus target?',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
        content: Text('"${widget.goal.name}" akan dihapus permanen.',
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
    try {
      await widget.fs.deleteGoal(widget.goal.id);
      if (mounted) {
        showToast(context, 'Target dihapus');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) showToast(context, 'Gagal menghapus: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final g = widget.goal;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Handle(),
              const SizedBox(height: 20),
              Row(
                children: [
                  GoalRing(
                    progress: g.progress,
                    size: 96,
                    stroke: 10,
                    child: PercentLabel(goal: g, fontSize: 18),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(g.name,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(rupiah(g.saved),
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                                fontFeatures: tnum)),
                        Text('dari ${rupiah(g.target)}',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.hint)),
                        const SizedBox(height: 4),
                        Text(
                            g.done
                                ? 'Target tercapai'
                                : 'Sisa ${rupiah(g.remaining)} lagi',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: g.done
                                    ? AppColors.income
                                    : AppColors.hint)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(children: [
                TypeChip(
                  label: 'Setor',
                  icon: Icons.add_rounded,
                  active: _deposit,
                  onTap: () => setState(() => _deposit = true),
                ),
                const SizedBox(width: 12),
                TypeChip(
                  label: 'Tarik',
                  icon: Icons.remove_rounded,
                  active: !_deposit,
                  activeColor: AppColors.pending,
                  onTap: () => setState(() => _deposit = false),
                ),
              ]),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amount,
                keyboardType: TextInputType.number,
                inputFormatters: [ThousandsFormatter()],
                decoration: const InputDecoration(
                    labelText: 'Nominal', prefixText: 'Rp '),
                validator: (v) {
                  final n = parseRupiah(v);
                  if (n == null || n <= 0)
                    return 'Masukkan nominal lebih dari 0';
                  if (!_deposit && n > g.saved) {
                    return 'Melebihi dana terkumpul';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _busy ? null : _apply,
                child: Text(_deposit ? 'Setor Dana' : 'Tarik Dana'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        showGoalForm(context, widget.fs, goal: g);
                      },
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Ubah target'),
                    ),
                  ),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: _delete,
                      style: TextButton.styleFrom(
                          foregroundColor: AppColors.expense),
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      label: const Text('Hapus'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
