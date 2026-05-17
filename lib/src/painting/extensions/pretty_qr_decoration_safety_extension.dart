import 'dart:math' as math;

import 'package:qr/qr.dart';

import 'package:pretty_qr_code/src/painting/decoration/pretty_qr_decoration.dart';
import 'package:pretty_qr_code/src/painting/decoration/pretty_qr_decoration_image.dart';
import 'package:pretty_qr_code/src/painting/pretty_qr_scannability.dart';

/// Safety helpers for decorated QR codes.
extension PrettyQrDecorationSafetyExtension on PrettyQrDecoration {
  /// Estimated fraction of the QR symbol covered by an embedded image.
  double get estimatedCoveredFraction {
    final image = this.image;
    if (image == null) return 0;
    if (image.position != PrettyQrDecorationImagePosition.embedded) return 0;
    return math.pow(image.scale.clamp(0.0, 1.0), 2).toDouble();
  }

  /// Estimates whether this decoration is likely to remain scannable.
  PrettyQrScannabilityReport estimateScannability({
    final QrErrorCorrectLevel errorCorrectLevel = QrErrorCorrectLevel.high,
  }) {
    final covered = estimatedCoveredFraction;
    final capacity = errorCorrectLevel.recoveryRate / 100;
    final recommended = _recommendedErrorCorrectLevel(covered);

    final scannability = covered <= capacity * 0.45
        ? PrettyQrScannability.good
        : covered <= capacity * 0.70
        ? PrettyQrScannability.warning
        : PrettyQrScannability.risky;

    return PrettyQrScannabilityReport(
      coveredFraction: covered,
      errorCorrectLevel: errorCorrectLevel,
      scannability: scannability,
      recommendedErrorCorrectLevel: recommended,
    );
  }

  /// Returns a copy with embedded image scale clamped for the correction level.
  PrettyQrDecoration withSafeImage({
    final QrErrorCorrectLevel errorCorrectLevel = QrErrorCorrectLevel.high,
    final double safetyFactor = 0.45,
  }) {
    final image = this.image;
    if (image == null) return this;
    if (image.position != PrettyQrDecorationImagePosition.embedded) {
      return this;
    }

    final capacity = errorCorrectLevel.recoveryRate / 100;
    final maxScale = math.sqrt(capacity * safetyFactor);
    if (image.scale <= maxScale) return this;
    return copyWith(image: image.copyWith(scale: maxScale));
  }
}

QrErrorCorrectLevel _recommendedErrorCorrectLevel(double coveredFraction) {
  for (final level in [
    QrErrorCorrectLevel.low,
    QrErrorCorrectLevel.medium,
    QrErrorCorrectLevel.quartile,
    QrErrorCorrectLevel.high,
  ]) {
    if (coveredFraction <= (level.recoveryRate / 100) * 0.45) {
      return level;
    }
  }
  return QrErrorCorrectLevel.high;
}
