import 'package:flutter/services.dart';

String normalizeBrazilianPhone(String value) {
  return value.replaceAll(RegExp(r'\D'), '');
}

String formatBrazilianPhone(String value) {
  final digits = normalizeBrazilianPhone(value);
  final limited = digits.length > 11 ? digits.substring(0, 11) : digits;
  if (limited.isEmpty) return '';
  if (limited.length <= 2) return '($limited';

  final area = limited.substring(0, 2);
  final number = limited.substring(2);
  if (number.length <= 5) return '($area) $number';
  return '($area) ${number.substring(0, 5)}-${number.substring(5)}';
}

class BrazilianPhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = formatBrazilianPhone(newValue.text);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
