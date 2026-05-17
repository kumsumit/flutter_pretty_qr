import 'package:qr/qr.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pretty_qr_code/src/painting/pretty_qr_scannability.dart';
import 'package:pretty_qr_code/src/painting/decoration/pretty_qr_decoration.dart';
import 'package:pretty_qr_code/src/painting/decoration/pretty_qr_decoration_image.dart';
import 'package:pretty_qr_code/src/painting/extensions/pretty_qr_decoration_safety_extension.dart';

void main() {
  group('PrettyQrDecorationSafetyExtension', () {
    const decoration = PrettyQrDecoration(
      image: PrettyQrDecorationImage(image: AssetImage('logo.png'), scale: 0.6),
    );

    test('estimates covered fraction', () {
      expect(decoration.estimatedCoveredFraction, closeTo(0.36, 0.001));
    });

    test('reports risky decoration', () {
      final report = decoration.estimateScannability(
        errorCorrectLevel: QrErrorCorrectLevel.low,
      );

      expect(report.scannability, PrettyQrScannability.risky);
      expect(report.recommendedErrorCorrectLevel, QrErrorCorrectLevel.high);
    });

    test('clamps embedded image scale', () {
      final safeDecoration = decoration.withSafeImage(
        errorCorrectLevel: QrErrorCorrectLevel.high,
      );

      expect(safeDecoration.image!.scale, lessThan(decoration.image!.scale));
    });
  });
}
