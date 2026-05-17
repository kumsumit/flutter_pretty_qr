// ignore_for_file: deprecated_member_use_from_same_package

import 'package:qr/qr.dart';
import 'package:meta/meta.dart';
import 'package:flutter/widgets.dart';

import 'package:pretty_qr_code/src/widgets/pretty_qr_view.dart';
import 'package:pretty_qr_code/src/painting/shapes/pretty_qr_smooth_symbol.dart';
import 'package:pretty_qr_code/src/painting/decoration/pretty_qr_decoration.dart';
import 'package:pretty_qr_code/src/painting/decoration/pretty_qr_decoration_image.dart';

/// {@macro pretty_qr_code.widgets.PrettyQrView}
@Deprecated(
  'Please use `PrettyQrView.data` instead. '
  'This feature was deprecated after v3.0.0.',
)
class PrettyQr extends StatefulWidget {
  /// Widget size.
  @nonVirtual
  final double size;

  /// Qr code data.
  @nonVirtual
  final String data;

  /// Square color.
  @nonVirtual
  final Color elementColor;

  /// Error correct level.
  @nonVirtual
  final QrErrorCorrectLevel errorCorrectLevel;

  /// Round the corners.
  @nonVirtual
  final bool roundEdges;

  /// Number of type generation (1 to 40 or null for auto).
  @nonVirtual
  final int? typeNumber;

  /// The mask pattern to use, or `null` to use the best mask pattern.
  @nonVirtual
  final int? maskPattern;

  /// The image to be painted into QR code.
  @nonVirtual
  final ImageProvider? image;

  @literal
  @Deprecated(
    'Please use `PrettyQrView.data` instead. '
    'This feature was deprecated after v3.0.0.',
  )
  const PrettyQr({
    required this.data,
    super.key,
    this.image,
    this.typeNumber,
    this.maskPattern,
    this.size = 100,
    this.roundEdges = false,
    this.elementColor = const Color(0xFF000000),
    this.errorCorrectLevel = QrErrorCorrectLevel.medium,
  });

  @override
  State<PrettyQr> createState() => _PrettyQrState();
}

@sealed
class _PrettyQrState extends State<PrettyQr> {
  @protected
  late QrImage qrImage;

  @override
  void initState() {
    super.initState();
    prepareQrImage();
  }

  @override
  void didUpdateWidget(covariant PrettyQr oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.data != widget.data) {
      prepareQrImage();
    } else if (oldWidget.typeNumber != widget.typeNumber) {
      prepareQrImage();
    } else if (oldWidget.errorCorrectLevel != widget.errorCorrectLevel) {
      prepareQrImage();
    } else if (oldWidget.maskPattern != widget.maskPattern) {
      prepareQrImage();
    }
  }

  @protected
  void prepareQrImage() {
    if (widget.typeNumber == null) {
      final qrCode = QrCode(
        payload: QrPayload.fromString(widget.data),
        errorCorrectLevel: widget.errorCorrectLevel,
      );

      qrImage = widget.maskPattern == null
          ? QrImage(qrCode)
          : QrImage.withMaskPattern(qrCode, widget.maskPattern!);
    } else {
      final qrCode = QrCode(
        payload: QrPayload.fromString(widget.data),
        errorCorrectLevel: widget.errorCorrectLevel,
        minTypeNumber: widget.typeNumber!,
      );

      qrImage = widget.maskPattern == null
          ? QrImage(qrCode)
          : QrImage.withMaskPattern(qrCode, widget.maskPattern!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: widget.size,
      child: PrettyQrView(
        qrImage: qrImage,
        decoration: PrettyQrDecoration(
          shape: PrettyQrSmoothSymbol(
            color: widget.elementColor,
            roundFactor: widget.roundEdges ? 1 : 0,
          ),
          image: widget.image == null
              ? null
              : PrettyQrDecorationImage(
                  image: widget.image!,
                  scale: 0.25,
                  position: PrettyQrDecorationImagePosition.embedded,
                ),
        ),
      ),
    );
  }
}
