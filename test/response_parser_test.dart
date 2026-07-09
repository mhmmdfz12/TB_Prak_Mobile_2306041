import 'package:flutter_test/flutter_test.dart';
import 'package:tb_2306041/core/helpers/response_parser.dart';

void main() {
  group('mapFrom', () {
    test('mengambil data user yang dibungkus di dalam data.user', () {
      final response = {
        'data': {
          'user': {'full_name': 'Budi Santoso', 'phone': '081234567890'},
        },
      };

      expect(mapFrom(response), {
        'full_name': 'Budi Santoso',
        'phone': '081234567890',
      });
    });

    test(
      'mengambil data profil ketika respons langsung berisi field profil',
      () {
        final response = {'full_name': 'Sari', 'phone': '082345678901'};

        expect(mapFrom(response), response);
      },
    );
  });
}
