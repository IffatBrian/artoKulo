import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import '../widgets/common.dart';

// Layar permintaan reset kata sandi.
class ForgotPasswordScreen extends StatefulWidget {
  final String initialEmail;
  const ForgotPasswordScreen({super.key, this.initialEmail = ''});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

// Mengelola pengiriman dan status tautan reset.
class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _form = GlobalKey<FormState>();
  late final _email = TextEditingController(text: widget.initialEmail);
  bool _loading = false, _sent = false;

  /// Melepas pengendali email.
  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  /// Mengirim permintaan reset kata sandi.
  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AuthService().resetPassword(_email.text);
      if (mounted) setState(() => _sent = true);
    } catch (e) {
      if (mounted) showToast(context, e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: _sent ? _success(context) : _formView(),
        ),
      ),
    );
  }

  /// Menyusun formulir permintaan reset.
  Widget _formView() => Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                  color: AppColors.secondary, shape: BoxShape.circle),
              child: const Icon(Icons.lock_reset_rounded,
                  color: AppColors.primary, size: 30),
            ),
            const SizedBox(height: 24),
            const Text('Lupa kata sandi?',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text(
                'Tenang, masukkan email akunmu. Kami akan mengirim tautan untuk membuat kata sandi baru.',
                style: TextStyle(color: AppColors.hint)),
            const SizedBox(height: 32),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.mail_outline_rounded)),
              validator: (v) => (v == null || !v.contains('@'))
                  ? 'Masukkan email yang valid'
                  : null,
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Kirim Tautan Reset'),
            ),
          ],
        ),
      );

  /// Menampilkan konfirmasi email terkirim.
  Widget _success(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 48),
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
                color: AppColors.income.soft(0.12), shape: BoxShape.circle),
            child: const Icon(Icons.mark_email_read_outlined,
                color: AppColors.income, size: 40),
          ),
          const SizedBox(height: 24),
          const Text('Cek emailmu',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(
              'Tautan reset kata sandi dikirim ke ${_email.text.trim()}. Jika tidak terlihat, periksa folder spam.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.hint)),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kembali ke Masuk'),
          ),
          TextButton(
            onPressed: () => setState(() => _sent = false),
            child: const Text('Kirim ulang'),
          ),
        ],
      );
}
