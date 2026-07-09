import 'package:intl/intl.dart';

class AppFormatters {
  AppFormatters._();

  static final rupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static String price(dynamic value) {
    final number = value is num
        ? value
        : num.tryParse(value?.toString() ?? '') ?? 0;
    return rupiah.format(number);
  }
}
