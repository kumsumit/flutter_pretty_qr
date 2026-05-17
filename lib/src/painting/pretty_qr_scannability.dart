import 'package:qr/qr.dart';
import 'package:meta/meta.dart';
import 'package:flutter/foundation.dart';

/// A conservative scan-quality estimate for a QR decoration.
enum PrettyQrScannability {
  /// The decoration is unlikely to affect readability.
  good,

  /// The decoration may scan, but should be tested with target devices.
  warning,

  /// The decoration is likely to make the QR code difficult to scan.
  risky,
}

/// A scannability estimate for a decorated QR code.
@immutable
class PrettyQrScannabilityReport with Diagnosticable {
  /// Estimated covered fraction of the QR symbol.
  @nonVirtual
  final double coveredFraction;

  /// Error correction level used for this estimate.
  @nonVirtual
  final QrErrorCorrectLevel errorCorrectLevel;

  /// Scan-quality estimate.
  @nonVirtual
  final PrettyQrScannability scannability;

  /// Suggested correction level for the current decoration.
  @nonVirtual
  final QrErrorCorrectLevel recommendedErrorCorrectLevel;

  /// Creates a scannability report.
  @literal
  const PrettyQrScannabilityReport({
    required this.coveredFraction,
    required this.errorCorrectLevel,
    required this.scannability,
    required this.recommendedErrorCorrectLevel,
  });

  /// Returns whether the decoration is likely to scan reliably.
  bool get isSafe => scannability == PrettyQrScannability.good;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DoubleProperty('coveredFraction', coveredFraction))
      ..add(EnumProperty('errorCorrectLevel', errorCorrectLevel))
      ..add(EnumProperty('scannability', scannability))
      ..add(
        EnumProperty(
          'recommendedErrorCorrectLevel',
          recommendedErrorCorrectLevel,
        ),
      );
  }
}
