import 'dart:typed_data';

import 'package:qr/qr.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pretty_qr_code/src/widgets/pretty_qr_view.dart';

void main() {
  group('PrettyQrView', () {
    testWidgets('creates from string data', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: PrettyQrView.data(
            data: 'pretty qr',
            minTypeNumber: 4,
            maskPattern: 2,
            errorCorrectLevel: QrErrorCorrectLevel.high,
          ),
        ),
      );

      expect(find.byType(PrettyQrView), findsOneWidget);
    });

    testWidgets('creates from payload', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: PrettyQrView.payload(
            payload: QrPayload.fromString('pretty qr'),
          ),
        ),
      );

      expect(find.byType(PrettyQrView), findsOneWidget);
    });

    testWidgets('creates from typed data', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: PrettyQrView.typedData(data: Uint8List.fromList([1, 2, 3])),
        ),
      );

      expect(find.byType(PrettyQrView), findsOneWidget);
    });

    test('validates data', () {
      final validation = PrettyQrView.validateData(
        data: 'pretty qr',
        typeNumber: 1,
        errorCorrectLevel: QrErrorCorrectLevel.low,
      );

      expect(validation.isValid, isTrue);
      expect(validation.qrCode, isNotNull);
    });
  });
}
