import 'package:qr/qr.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pretty_qr_code/src/painting/extensions/pretty_qr_svg_extension.dart';

void main() {
  test('PrettyQrSvgExtension exports svg', () {
    final qrCode = QrCode(
      payload: QrPayload.fromString('pretty qr'),
      errorCorrectLevel: QrErrorCorrectLevel.low,
    );
    final svg = QrImage(qrCode).toSvg(size: 128);

    expect(svg, startsWith('<svg'));
    expect(svg, contains('width="128"'));
    expect(svg, contains('<rect'));
    expect(svg, endsWith('</svg>'));
  });
}
