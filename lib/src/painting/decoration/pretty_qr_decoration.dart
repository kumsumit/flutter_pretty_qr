import 'dart:ui';

import 'package:meta/meta.dart';
import 'package:flutter/foundation.dart';

import 'package:pretty_qr_code/src/painting/pretty_qr_brush.dart';
import 'package:pretty_qr_code/src/painting/pretty_qr_shape.dart';
import 'package:pretty_qr_code/src/painting/pretty_qr_painter.dart';
import 'package:pretty_qr_code/src/painting/pretty_qr_quiet_zone.dart';
import 'package:pretty_qr_code/src/painting/shapes/pretty_qr_dots_symbol.dart';
import 'package:pretty_qr_code/src/painting/shapes/pretty_qr_smooth_symbol.dart';
import 'package:pretty_qr_code/src/painting/shapes/pretty_qr_squares_symbol.dart';
import 'package:pretty_qr_code/src/painting/decoration/pretty_qr_decoration_image.dart';

/// Built-in QR decoration presets.
enum PrettyQrDecorationPreset {
  /// Square modules with no additional styling.
  classic,

  /// Smooth modules with softened joins.
  smooth,

  /// Circular data modules.
  dots,

  /// Dense square modules with rounded corners.
  rounded,
}

/// {@template pretty_qr_code.painting.PrettyQrDecoration}
/// An immutable description of how to paint a QR image.
/// {@endtemplate}
@sealed
@immutable
class PrettyQrDecoration with Diagnosticable {
  /// The color or brush to fill in the background of the QR code.
  @nonVirtual
  final Color? background;

  /// The QR modules shape.
  @nonVirtual
  final PrettyQrShape shape;

  /// {@macro pretty_qr_code.painting.PrettyQrQuietZone}
  ///
  /// {@macro pretty_qr_code.painting.PrettyQrQuietZone.standard}
  @nonVirtual
  final PrettyQrQuietZone? quietZone;

  /// The image will be embed to the center of the QR code.
  @nonVirtual
  final PrettyQrDecorationImage? image;

  /// The default QR code shape.
  ///
  /// This value is used by default to paint QR codes.
  @Deprecated(
    'Please use `PrettyQrTheme.fallback` instead. '
    'This feature was deprecated after v3.3.0.',
  )
  static const kDefaultDecorationShape = PrettyQrSmoothSymbol();

  /// Creates a QR image decoration.
  @literal
  const PrettyQrDecoration({
    this.image,
    this.quietZone,
    this.background,
    // ignore: deprecated_member_use_from_same_package, backward compatibility.
    this.shape = kDefaultDecorationShape,
  });

  /// Creates a decoration from one of the built-in presets.
  factory PrettyQrDecoration.fromPreset(
    PrettyQrDecorationPreset preset, {
    final Color? background,
    final Color color = const Color(0xFF000000),
    final PrettyQrQuietZone? quietZone,
    final PrettyQrDecorationImage? image,
  }) {
    return PrettyQrDecoration(
      image: image,
      quietZone: quietZone,
      background: background,
      shape: switch (preset) {
        PrettyQrDecorationPreset.classic => PrettyQrSquaresSymbol(
          color: color,
          density: 1,
          rounding: 0,
        ),
        PrettyQrDecorationPreset.smooth => PrettyQrSmoothSymbol(color: color),
        PrettyQrDecorationPreset.dots => PrettyQrDotsSymbol(color: color),
        PrettyQrDecorationPreset.rounded => PrettyQrSquaresSymbol(
          color: color,
          density: 0.86,
          rounding: 0.5,
        ),
      },
    );
  }

  @override
  String toStringShort() {
    return objectRuntimeType(this, 'PrettyQrDecoration');
  }

  /// Creates a copy of this [PrettyQrDecoration] but with the given fields
  /// replaced with the new values.
  @factory
  @useResult
  PrettyQrDecoration copyWith({
    final PrettyQrDecorationImage? image,
    final PrettyQrQuietZone? quietZone,
    final Color? background,
    final PrettyQrShape? shape,
  }) {
    return PrettyQrDecoration(
      image: image ?? this.image,
      quietZone: quietZone ?? this.quietZone,
      background: background ?? this.background,
      shape: shape ?? this.shape,
    );
  }

  /// Returns a [PrettyQrPainter] that will paint QR code with this decoration.
  @nonVirtual
  PrettyQrPainter createPainter(VoidCallback onChanged) {
    return PrettyQrPainter(decoration: this, onChanged: onChanged);
  }

  /// Linearly interpolates between two [PrettyQrDecoration]s.
  ///
  /// {@macro dart.ui.shadow.lerp}
  @factory
  static PrettyQrDecoration? lerp(
    final PrettyQrDecoration? a,
    final PrettyQrDecoration? b,
    final double t,
  ) {
    if (identical(a, b)) {
      return a;
    }

    if (a != null && b != null) {
      if (t == 0.0) return a;
      if (t == 1.0) return b;
    }

    return PrettyQrDecoration(
      image: PrettyQrDecorationImage.lerp(a?.image, b?.image, t),
      quietZone: PrettyQrQuietZone.lerp(a?.quietZone, b?.quietZone, t),
      background: PrettyQrBrush.lerp(a?.background, b?.background, t),
      shape: PrettyQrShape.lerp(a?.shape, b?.shape, t)!,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('image', image, defaultValue: null))
      ..add(DiagnosticsProperty('quietZone', quietZone, defaultValue: null))
      ..add(DiagnosticsProperty('background', background, defaultValue: null))
      ..add(DiagnosticsProperty('shape', shape));
  }

  @override
  int get hashCode {
    return Object.hash(image, background, shape, quietZone);
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) {
      return true;
    }

    return other is PrettyQrDecoration &&
        other.image == image &&
        other.quietZone == quietZone &&
        other.background == background &&
        other.shape == shape;
  }
}
