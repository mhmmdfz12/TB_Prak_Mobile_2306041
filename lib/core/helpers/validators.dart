class Validators {
  Validators._();

  static String? requiredText(String? value, String message) {
    if ((value ?? '').trim().isEmpty) return message;
    return null;
  }

  static String? email(String? value) {
    final email = value ?? '';
    final valid = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
    return valid ? null : 'Email tidak valid';
  }

  static String? password(String? value) {
    return (value ?? '').length < 6 ? 'Password minimal 6 karakter' : null;
  }
}
