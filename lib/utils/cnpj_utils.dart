import 'package:flutter/services.dart';

const int cnpjLength = 14;

/// Remove tudo que não for dígito.
String normalizeCnpj(String value) {
  return value.replaceAll(RegExp(r'\D'), '');
}

/// Formata como 00.000.000/0000-00 a partir dos dígitos.
String formatCnpj(String value) {
  final digits = normalizeCnpj(value);
  if (digits.isEmpty) return '';

  final buffer = StringBuffer();
  for (var i = 0; i < digits.length && i < cnpjLength; i++) {
    final d = digits[i];
    if (i == 2 || i == 5) buffer.write('.');
    if (i == 8) buffer.write('/');
    if (i == 12) buffer.write('-');
    buffer.write(d);
  }
  return buffer.toString();
}

bool isValidCnpj(String value) {
  final cnpj = normalizeCnpj(value);

  if (cnpj.length != cnpjLength) return false;
  if (RegExp(r'^(\d)\1{13}$').hasMatch(cnpj)) return false;

  const firstWeights = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
  const secondWeights = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];

  int checkDigit(String slice, List<int> weights) {
    final sum = slice.split('').asMap().entries.fold<int>(
          0,
          (acc, entry) => acc + int.parse(entry.value) * weights[entry.key],
        );
    final remainder = sum % 11;
    return remainder < 2 ? 0 : 11 - remainder;
  }

  final first = checkDigit(cnpj.substring(0, 12), firstWeights);
  final second =
      checkDigit(cnpj.substring(0, 12) + first.toString(), secondWeights);

  return cnpj.endsWith('$first$second');
}

String? validateCnpjField(String? value, {bool required = true}) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) {
    return required ? 'CNPJ obrigatório' : null;
  }
  if (!isValidCnpj(trimmed)) return 'CNPJ inválido';
  return null;
}

class CnpjInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = normalizeCnpj(newValue.text);
    if (digits.length > cnpjLength) return oldValue;

    final formatted = formatCnpj(digits);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
