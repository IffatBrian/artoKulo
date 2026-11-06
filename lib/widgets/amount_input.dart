import 'package:flutter/services.dart';

/// Memformat digit dengan pemisah ribuan.
String formatThousands(String digits) {
  final b = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    final fromEnd = digits.length - i;
    b.write(digits[i]);
    if (fromEnd > 1 && fromEnd % 3 == 1) b.write('.');
  }
  return b.toString();
}

/// Memformat angka bulat untuk ditampilkan.
String formatNumber(num n) => formatThousands(n.round().toString());

/// Mengubah teks rupiah menjadi angka.
double? parseRupiah(String? s) {
  if (s == null) return null;
  return double.tryParse(s.replaceAll('.', ''));
}

/// Formatter input: hanya angka, otomatis diberi pemisah ribuan saat mengetik.
class ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue(text: '');
    digits = digits.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    if (digits.length > 12) digits = digits.substring(0, 12);
    final text = formatThousands(digits);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
