import 'dart:ui';
import 'dart:convert';
import 'dart:typed_data';

import 'package:qr/qr.dart';

import 'package:pretty_qr_code/src/painting/pretty_qr_quiet_zone.dart';

/// Extensions that export a [QrImage] as SVG.
extension PrettyQrSvgExtension on QrImage {
  /// Returns a compact SVG string for this QR image.
  ///
  /// This exporter focuses on the QR matrix itself. Rich Flutter-only
  /// decorations, embedded images, and custom shapes should use
  /// [PrettyQrImageExtension.toImage] instead.
  String toSvg({
    final int? size,
    final Color dark = const Color(0xFF000000),
    final Color? background = const Color(0xFFFFFFFF),
    final PrettyQrQuietZone quietZone = PrettyQrQuietZone.standard,
  }) {
    final quietZoneModules = quietZone is PrettyQrModulesQuietZone
        ? quietZone.value
        : 0.0;
    final dimension = moduleCount + quietZoneModules * 2;
    final outputSize = size ?? dimension;
    final buffer = StringBuffer()
      ..write('<svg xmlns="http://www.w3.org/2000/svg" ')
      ..write('viewBox="0 0 $dimension $dimension" ')
      ..write('width="$outputSize" height="$outputSize" ')
      ..write('shape-rendering="crispEdges">');

    if (background != null) {
      buffer
        ..write('<rect width="100%" height="100%" fill="')
        ..write(_svgColor(background))
        ..write('"/>');
    }

    final darkColor = _svgColor(dark);
    for (var row = 0; row < moduleCount; row++) {
      for (var col = 0; col < moduleCount; col++) {
        if (!isDark(row, col)) continue;
        buffer
          ..write('<rect x="${col + quietZoneModules}" ')
          ..write('y="${row + quietZoneModules}" ')
          ..write('width="1" height="1" fill="$darkColor"/>');
      }
    }

    return (buffer..write('</svg>')).toString();
  }

  /// Returns UTF-8 encoded SVG bytes for this QR image.
  Uint8List toSvgBytes({
    final int? size,
    final Color dark = const Color(0xFF000000),
    final Color? background = const Color(0xFFFFFFFF),
    final PrettyQrQuietZone quietZone = PrettyQrQuietZone.standard,
  }) {
    return Uint8List.fromList(
      utf8.encode(
        toSvg(
          size: size,
          dark: dark,
          background: background,
          quietZone: quietZone,
        ),
      ),
    );
  }
}

String _svgColor(Color color) {
  final value = color.toARGB32().toRadixString(16).padLeft(8, '0');
  final alpha = value.substring(0, 2);
  final rgb = value.substring(2);
  if (alpha == 'ff') return '#$rgb';
  return '#$rgb${alpha == '00' ? '00' : alpha}';
}
