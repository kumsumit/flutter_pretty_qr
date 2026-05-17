import 'dart:typed_data';

import 'package:qr/qr.dart';
import 'package:meta/meta.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';

import 'package:pretty_qr_code/src/rendering/pretty_qr_render_view.dart';
import 'package:pretty_qr_code/src/painting/decoration/pretty_qr_decoration.dart';

import 'package:pretty_qr_code/src/widgets/pretty_qr_theme.dart';
import 'package:pretty_qr_code/src/widgets/pretty_qr_data_view.dart';
import 'package:pretty_qr_code/src/painting/extensions/pretty_qr_decoration_safety_extension.dart';
import 'package:pretty_qr_code/src/widgets/extensions/pretty_qr_decoration_theme_extension.dart';

/// {@template pretty_qr_code.widgets.PrettyQrView}
/// A widget that displays a QR code symbol.
/// {@endtemplate}
///
/// {@tool snippet}
///
/// This sample code shows how to use `PrettyQrView` to display QR code image.
///
/// ```dart
/// PrettyQrView.data(
///   data: '...',
///   errorCorrectLevel: QrErrorCorrectLevel.high,
///   decoration: const PrettyQrDecoration(
///     shape: PrettyQrSmoothSymbol(),
///     image: PrettyQrDecorationImage(
///       image: AssetImage('images/flutter.png'),
///       position: PrettyQrDecorationImagePosition.embedded,
///     ),
///     quietZone: PrettyQrQuietZone.modules(2),
///   ),
/// )
/// ```
/// {@end-tool}
@sealed
class PrettyQrView extends LeafRenderObjectWidget {
  /// {@macro pretty_qr_code.rendering.PrettyQrRenderView.qrImage}
  @protected
  final QrImage qrImage;

  /// {@macro pretty_qr_code.rendering.PrettyQrRenderView.decoration}
  @protected
  final PrettyQrDecoration? decoration;

  /// Creates a widget that displays an QR symbol obtained from a [qrImage].
  @literal
  const PrettyQrView({required this.qrImage, super.key, this.decoration});

  /// Creates a widget that displays an QR symbol obtained from a [data].
  @factory
  static Widget data({
    required final String data,
    final Key? key,
    final PrettyQrDecoration? decoration,
    final ImageErrorWidgetBuilder? errorBuilder,
    final int? maskPattern,
    final int minTypeNumber = 1,
    final QrErrorCorrectLevel errorCorrectLevel = QrErrorCorrectLevel.low,
  }) {
    return PrettyQrDataView(
      key: key,
      data: data,
      decoration: decoration,
      maskPattern: maskPattern,
      minTypeNumber: minTypeNumber,
      errorCorrectLevel: errorCorrectLevel,
      errorBuilder: errorBuilder,
    );
  }

  /// Creates a QR symbol from [data] with conservative logo safety defaults.
  ///
  /// When [decoration] contains an embedded image, this constructor clamps an
  /// oversized image and raises the error correction level when appropriate.
  @factory
  static Widget safeData({
    required final String data,
    final Key? key,
    final PrettyQrDecoration? decoration,
    final ImageErrorWidgetBuilder? errorBuilder,
    final int? maskPattern,
    final int minTypeNumber = 1,
    final QrErrorCorrectLevel errorCorrectLevel = QrErrorCorrectLevel.low,
  }) {
    final safeErrorCorrectLevel =
        decoration?.recommendedErrorCorrectLevel(
          errorCorrectLevel: errorCorrectLevel,
        ) ??
        errorCorrectLevel;
    return PrettyQrDataView(
      key: key,
      data: data,
      decoration: decoration?.withSafeImage(
        errorCorrectLevel: safeErrorCorrectLevel,
      ),
      maskPattern: maskPattern,
      minTypeNumber: minTypeNumber,
      errorCorrectLevel: safeErrorCorrectLevel,
      errorBuilder: errorBuilder,
    );
  }

  /// Creates a widget that displays a QR symbol obtained from a [payload].
  @factory
  static Widget payload({
    required final QrPayload payload,
    final Key? key,
    final PrettyQrDecoration? decoration,
    final ImageErrorWidgetBuilder? errorBuilder,
    final int? maskPattern,
    final int minTypeNumber = 1,
    final QrErrorCorrectLevel errorCorrectLevel = QrErrorCorrectLevel.low,
  }) {
    return PrettyQrDataView.payload(
      key: key,
      payload: payload,
      decoration: decoration,
      maskPattern: maskPattern,
      minTypeNumber: minTypeNumber,
      errorCorrectLevel: errorCorrectLevel,
      errorBuilder: errorBuilder,
    );
  }

  /// Creates a widget that displays a QR symbol obtained from binary [data].
  @factory
  static Widget typedData({
    required final TypedData data,
    final Key? key,
    final PrettyQrDecoration? decoration,
    final ImageErrorWidgetBuilder? errorBuilder,
    final int? maskPattern,
    final int minTypeNumber = 1,
    final QrErrorCorrectLevel errorCorrectLevel = QrErrorCorrectLevel.low,
  }) {
    return PrettyQrDataView.typedData(
      key: key,
      data: data,
      decoration: decoration,
      maskPattern: maskPattern,
      minTypeNumber: minTypeNumber,
      errorCorrectLevel: errorCorrectLevel,
      errorBuilder: errorBuilder,
    );
  }

  /// Validates string [data] against a QR type and error correction level.
  static QrValidationResult validateData({
    required final String data,
    required final int typeNumber,
    final QrErrorCorrectLevel errorCorrectLevel = QrErrorCorrectLevel.low,
  }) {
    return validatePayload(
      payload: QrPayload.fromString(data),
      typeNumber: typeNumber,
      errorCorrectLevel: errorCorrectLevel,
    );
  }

  /// Validates [payload] against a QR type and error correction level.
  static QrValidationResult validatePayload({
    required final QrPayload payload,
    required final int typeNumber,
    final QrErrorCorrectLevel errorCorrectLevel = QrErrorCorrectLevel.low,
  }) {
    return QrValidationResult.fromPayload(
      payload: payload,
      typeNumber: typeNumber,
      errorCorrectLevel: errorCorrectLevel,
    );
  }

  @override
  PrettyQrRenderView createRenderObject(BuildContext context) {
    return PrettyQrRenderView(
      qrImage: qrImage,
      configuration: createLocalImageConfiguration(context),
      decoration: decoration.applyDefaults(PrettyQrTheme.of(context)),
    );
  }

  @override
  void updateRenderObject(
    final BuildContext context,
    final PrettyQrRenderView renderObject,
  ) {
    // ignore: avoid-mutating-parameters, updates the current render object.
    renderObject
      ..qrImage = qrImage
      ..configuration = createLocalImageConfiguration(context)
      ..decoration = decoration.applyDefaults(PrettyQrTheme.of(context));
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<QrImage>('qrImage', qrImage))
      ..add(DiagnosticsProperty<PrettyQrDecoration>('decoration', decoration));
  }
}
