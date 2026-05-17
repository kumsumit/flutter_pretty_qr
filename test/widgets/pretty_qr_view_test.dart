import 'dart:typed_data';

import 'package:qr/qr.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pretty_qr_code/src/widgets/pretty_qr_view.dart';
import 'package:pretty_qr_code/src/painting/decoration/pretty_qr_decoration.dart';
import 'package:pretty_qr_code/src/painting/decoration/pretty_qr_decoration_image.dart';

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

    testWidgets('creates from string data with safe decoration', (
      tester,
    ) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: PrettyQrView.safeData(
            data: 'pretty qr',
            decoration: PrettyQrDecoration(
              image: PrettyQrDecorationImage(
                image: MemoryImage(Uint8List.fromList(_transparentPng)),
                scale: 0.6,
              ),
            ),
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

const _transparentPng = [
  0x89,
  0x50,
  0x4e,
  0x47,
  0x0d,
  0x0a,
  0x1a,
  0x0a,
  0x00,
  0x00,
  0x00,
  0x0d,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1f,
  0x15,
  0xc4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0a,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9c,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0d,
  0x0a,
  0x2d,
  0xb4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4e,
  0x44,
  0xae,
  0x42,
  0x60,
  0x82,
];
