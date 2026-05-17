// ignore_for_file: deprecated_member_use

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

import 'package:pretty_qr_code_example/features/save_image_io.dart'
    if (dart.library.js_interop) 'package:pretty_qr_code_example/features/save_image_web.dart';

void main() {
  runApp(const PrettyQrExampleApp());
}

class PrettyQrExampleApp extends StatelessWidget {
  const PrettyQrExampleApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black,
        ),
      ),
      home: const PrettyQrHomePage(),
    );
  }
}

class PrettyQrHomePage extends StatefulWidget {
  const PrettyQrHomePage({
    super.key,
  });

  @override
  State<PrettyQrHomePage> createState() => _PrettyQrHomePageState();
}

class _PrettyQrHomePageState extends State<PrettyQrHomePage> {
  @protected
  late final TextEditingController dataEditingController;

  @protected
  late QrCode qrCode;

  @protected
  late QrImage qrImage;

  @protected
  late PrettyQrDecoration decoration;

  @protected
  QrErrorCorrectLevel errorCorrectLevel = QrErrorCorrectLevel.high;

  @protected
  int minTypeNumber = 1;

  @protected
  int? maskPattern;

  @override
  void initState() {
    super.initState();

    dataEditingController = TextEditingController(
      text: 'https://pub.dev/packages/pretty_qr_code',
    );

    decoration = const PrettyQrDecoration(
      shape: PrettyQrSmoothSymbol(
        color: _PrettyQrSettings.kDefaultQrDecorationBrush,
      ),
      image: _PrettyQrSettings.kDefaultQrDecorationImage,
      background: Colors.transparent,
      quietZone: PrettyQrQuietZone.zero,
    );

    updateQrImage();
  }

  @protected
  void updateQrImage() {
    try {
      qrCode = QrCode(
        payload: QrPayload.fromString(dataEditingController.text),
        errorCorrectLevel: errorCorrectLevel,
        minTypeNumber: minTypeNumber,
      );

      qrImage = maskPattern == null
          ? QrImage(qrCode)
          : QrImage.withMaskPattern(qrCode, maskPattern!);
    } on Exception {
      // Keep the last valid QR image visible while validation explains the
      // current input issue.
    }
  }

  @protected
  QrValidationResult get validation {
    return PrettyQrView.validateData(
      data: dataEditingController.text,
      typeNumber: minTypeNumber,
      errorCorrectLevel: errorCorrectLevel,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Pretty QR Code'),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1024,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final safePadding = MediaQuery.of(context).padding;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (constraints.maxWidth >= 720)
                    Flexible(
                      flex: 3,
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: safePadding.left + 24,
                          right: safePadding.right + 24,
                          bottom: 24,
                        ),
                        child: _PrettyQrAnimatedView(
                          qrImage: qrImage,
                          decoration: decoration,
                        ),
                      ),
                    ),
                  Flexible(
                    flex: 2,
                    child: Column(
                      children: [
                        if (constraints.maxWidth < 720)
                          Padding(
                            padding: safePadding.copyWith(
                              top: 0,
                              bottom: 0,
                            ),
                            child: _PrettyQrAnimatedView(
                              qrImage: qrImage,
                              decoration: decoration,
                            ),
                          ),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: safePadding.copyWith(top: 0),
                            child: _PrettyQrSettings(
                              decoration: decoration,
                              maskPattern: maskPattern,
                              minTypeNumber: minTypeNumber,
                              validation: validation,
                              errorCorrectLevel: errorCorrectLevel,
                              dataEditingController: dataEditingController,
                              onMaskPatternChanged: (value) => setState(() {
                                maskPattern = value;
                                updateQrImage();
                              }),
                              onMinTypeNumberChanged: (value) => setState(() {
                                minTypeNumber = value;
                                updateQrImage();
                              }),
                              onErrorCorrectLevelChanged: (value) =>
                                  setState(() {
                                errorCorrectLevel = value;
                                updateQrImage();
                              }),
                              onDataChanged: (_) => setState(updateQrImage),
                              onChanged: (value) => setState(() {
                                decoration = value;
                              }),
                              onExportPressed: (size) {
                                return qrImage.exportAsImage(
                                  context,
                                  size: size,
                                  decoration: decoration,
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    dataEditingController.dispose();
    super.dispose();
  }
}

class _PrettyQrAnimatedView extends StatefulWidget {
  @protected
  final QrImage qrImage;

  @protected
  final PrettyQrDecoration decoration;

  const _PrettyQrAnimatedView({
    required this.qrImage,
    required this.decoration,
  });

  @override
  State<_PrettyQrAnimatedView> createState() => _PrettyQrAnimatedViewState();
}

class _PrettyQrAnimatedViewState extends State<_PrettyQrAnimatedView> {
  @protected
  late PrettyQrDecoration previosDecoration;

  @override
  void initState() {
    super.initState();

    previosDecoration = widget.decoration;
  }

  @override
  void didUpdateWidget(
    covariant _PrettyQrAnimatedView oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (widget.decoration != oldWidget.decoration) {
      previosDecoration = oldWidget.decoration;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TweenAnimationBuilder<PrettyQrDecoration>(
        tween: PrettyQrDecorationTween(
          begin: previosDecoration,
          end: widget.decoration,
        ),
        curve: Curves.ease,
        duration: const Duration(
          milliseconds: 240,
        ),
        builder: (context, decoration, child) {
          return PrettyQrView(
            qrImage: widget.qrImage,
            decoration: decoration,
          );
        },
      ),
    );
  }
}

class _PrettyQrSettings extends StatefulWidget {
  @protected
  final TextEditingController dataEditingController;

  @protected
  final PrettyQrDecoration decoration;

  @protected
  final QrValidationResult validation;

  @protected
  final QrErrorCorrectLevel errorCorrectLevel;

  @protected
  final int minTypeNumber;

  @protected
  final int? maskPattern;

  @protected
  final Future<String?> Function(int)? onExportPressed;

  @protected
  final ValueChanged<PrettyQrDecoration>? onChanged;

  @protected
  final ValueChanged<String>? onDataChanged;

  @protected
  final ValueChanged<QrErrorCorrectLevel>? onErrorCorrectLevelChanged;

  @protected
  final ValueChanged<int>? onMinTypeNumberChanged;

  @protected
  final ValueChanged<int?>? onMaskPatternChanged;

  @visibleForTesting
  static const kDefaultQrDecorationImage = PrettyQrDecorationImage(
    image: AssetImage('images/flutter.png'),
    padding: EdgeInsets.all(8),
    clipper: PrettyQrFlutterLogoClipper(),
    position: PrettyQrDecorationImagePosition.embedded,
  );

  @visibleForTesting
  static const kDefaultQrDecorationBrush = Color(0xFF74565F);

  const _PrettyQrSettings({
    required this.dataEditingController,
    required this.decoration,
    required this.errorCorrectLevel,
    required this.maskPattern,
    required this.minTypeNumber,
    required this.validation,
    this.onChanged,
    this.onDataChanged,
    this.onMaskPatternChanged,
    this.onExportPressed,
    this.onMinTypeNumberChanged,
    this.onErrorCorrectLevelChanged,
  });

  @override
  State<_PrettyQrSettings> createState() => _PrettyQrSettingsState();
}

class _PrettyQrSettingsState extends State<_PrettyQrSettings> {
  @protected
  Color brush = _PrettyQrSettings.kDefaultQrDecorationBrush;

  @protected
  final random = Random(DateTime.now().microsecondsSinceEpoch);

  @protected
  late final TextEditingController imageSizeEditingController;

  @override
  void initState() {
    super.initState();

    imageSizeEditingController = TextEditingController(
      text: ' 512w',
    );
  }

  @protected
  int get imageSize {
    final rawValue = imageSizeEditingController.text;
    return int.parse(rawValue.replaceAll('w', '').replaceAll(' ', ''));
  }

  @protected
  bool? get isRoundedBorders {
    var shape = widget.decoration.shape;
    if (shape is PrettyQrDotsSymbol) {
      return null;
    } else if (shape is PrettyQrCustomShape) {
      return null;
    } else if (shape is PrettyQrSmoothSymbol) {
      return shape.roundFactor > 0;
    } else if (shape is PrettyQrSquaresSymbol) {
      return shape.rounding > 0;
    }
    return false;
  }

  @protected
  String get shapeName {
    var shape = widget.decoration.shape;
    if (shape is PrettyQrDotsSymbol) {
      return 'Dots';
    } else if (shape is PrettyQrCustomShape) {
      return 'Custom';
    } else if (shape is PrettyQrSmoothSymbol) {
      return 'Smooth';
    } else if (shape is PrettyQrSquaresSymbol) {
      return 'Squares';
    }
    return '';
  }

  @protected
  void showExportPath(String? path) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(path == null ? 'Saved' : 'Saved to $path')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: TextField(
            controller: widget.dataEditingController,
            minLines: 1,
            maxLines: 3,
            onChanged: widget.onDataChanged,
            decoration: const InputDecoration(
              labelText: 'Data',
              prefixIcon: Icon(Icons.qr_code_2),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            return PopupMenuButton<QrErrorCorrectLevel>(
              onSelected: widget.onErrorCorrectLevelChanged,
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              initialValue: widget.errorCorrectLevel,
              itemBuilder: (context) {
                return QrErrorCorrectLevel.values.map((level) {
                  return PopupMenuItem(
                    value: level,
                    child: Text(level.name),
                  );
                }).toList();
              },
              child: ListTile(
                leading: const Icon(Icons.health_and_safety_outlined),
                title: const Text('Error correction'),
                trailing: Text(
                  widget.errorCorrectLevel.name,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.pin_outlined),
          title: const Text('Minimum version'),
          subtitle: Slider(
            min: 1,
            max: 40,
            divisions: 39,
            value: widget.minTypeNumber.toDouble(),
            label: widget.minTypeNumber.toString(),
            onChanged: (value) {
              widget.onMinTypeNumberChanged?.call(value.round());
            },
          ),
          trailing: Text(
            widget.minTypeNumber.toString(),
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            return PopupMenuButton<int?>(
              onSelected: widget.onMaskPatternChanged,
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              initialValue: widget.maskPattern,
              itemBuilder: (context) {
                return [
                  const PopupMenuItem(
                    value: null,
                    child: Text('Automatic'),
                  ),
                  for (var pattern = 0; pattern < 8; pattern++)
                    PopupMenuItem(
                      value: pattern,
                      child: Text('Pattern $pattern'),
                    ),
                ];
              },
              child: ListTile(
                leading: const Icon(Icons.grid_view_outlined),
                title: const Text('Mask pattern'),
                trailing: Text(
                  widget.maskPattern?.toString() ?? 'Auto',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            );
          },
        ),
        ListTile(
          leading: Icon(
            widget.validation.isValid
                ? Icons.check_circle_outline
                : Icons.error_outline,
          ),
          title: Text(
            widget.validation.isValid ? 'Valid QR options' : 'Data too long',
          ),
          subtitle: Text(
            widget.validation.isValid
                ? 'Rendered version ${widget.validation.qrCode!.typeNumber}'
                : 'Try a larger version or lower correction level',
          ),
        ),
        if (widget.decoration.image?.position ==
            PrettyQrDecorationImagePosition.embedded)
          ListTile(
            leading: Icon(
              widget.decoration
                      .estimateScannability(
                        errorCorrectLevel: widget.errorCorrectLevel,
                      )
                      .isSafe
                  ? Icons.verified_outlined
                  : Icons.warning_amber_outlined,
            ),
            title: const Text('Logo safety'),
            subtitle: Text(scannabilityLabel),
            trailing: TextButton(
              onPressed: applySafeImage,
              child: const Text('Fix'),
            ),
          ),
        const Divider(),
        SwitchListTile.adaptive(
          value: widget.decoration.quietZone != PrettyQrQuietZone.zero,
          onChanged: (value) => toggleQuietZone(),
          secondary: const Icon(Icons.border_outer),
          title: const Text('Quiet Zone'),
        ),
        const Divider(),
        LayoutBuilder(
          builder: (context, constraints) {
            return PopupMenuButton<Object>(
              onSelected: changeShape,
              constraints: BoxConstraints(
                minWidth: constraints.maxWidth,
              ),
              initialValue: widget.decoration.shape.runtimeType,
              itemBuilder: (context) {
                return [
                  const PopupMenuItem(
                    value: PrettyQrDotsSymbol,
                    child: Text('Dots'),
                  ),
                  const PopupMenuItem(
                    value: PrettyQrSmoothSymbol,
                    child: Text('Smooth'),
                  ),
                  const PopupMenuItem(
                    value: PrettyQrSquaresSymbol,
                    child: Text('Squares'),
                  ),
                  const PopupMenuItem(
                    value: PrettyQrCustomShape,
                    child: Text('Custom'),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: PrettyQrDecorationPreset.classic,
                    child: Text('Classic preset'),
                  ),
                  const PopupMenuItem(
                    value: PrettyQrDecorationPreset.rounded,
                    child: Text('Rounded preset'),
                  ),
                  const PopupMenuItem(
                    value: PrettyQrDecorationPreset.dots,
                    child: Text('Dots preset'),
                  ),
                ];
              },
              child: ListTile(
                leading: const Icon(Icons.format_paint_outlined),
                title: const Text('Style'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.decoration.shape is PrettyQrCustomShape) ...[
                      OutlinedButton(
                        onPressed: () {
                          changeShape(PrettyQrCustomShape);
                        },
                        child: Row(
                          children: [
                            Text(shapeName),
                            const SizedBox(width: 8),
                            const Icon(Icons.refresh),
                          ],
                        ),
                      ),
                    ] else
                      Text(
                        shapeName,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                  ],
                ),
              ),
            );
          },
        ),
        if (widget.decoration.shape is! PrettyQrCustomShape)
          LayoutBuilder(
            builder: (context, constraints) {
              return PopupMenuButton(
                onSelected: toggleColor,
                constraints: BoxConstraints(
                  minWidth: constraints.maxWidth,
                ),
                initialValue:
                    brush == _PrettyQrSettings.kDefaultQrDecorationBrush,
                itemBuilder: (context) {
                  return [
                    const PopupMenuItem(
                      value: true,
                      child: Text('Color'),
                    ),
                    const PopupMenuItem(
                      value: false,
                      child: Text('Gradient'),
                    ),
                  ];
                },
                child: ListTile(
                  leading: const Icon(Icons.color_lens_outlined),
                  title: const Text('Brush'),
                  trailing: Text(
                    brush is! PrettyQrGradientBrush ? 'Color' : 'Gradient',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              );
            },
          ),
        SwitchListTile.adaptive(
          value: widget.decoration.background != Colors.transparent,
          onChanged: (value) => toggleBackground(),
          secondary: const Icon(Icons.format_color_fill),
          title: const Text('Background'),
        ),
        if (isRoundedBorders != null)
          SwitchListTile.adaptive(
            value: isRoundedBorders ?? true,
            onChanged: isRoundedBorders == null
                ? null
                : (value) => toggleRoundedCorners(),
            secondary: const Icon(Icons.rounded_corner),
            title: const Text('Rounded corners'),
          ),
        const Divider(),
        SwitchListTile.adaptive(
          value: widget.decoration.image != null,
          onChanged: (value) => toggleImage(),
          secondary: Icon(
            widget.decoration.image != null
                ? Icons.image_outlined
                : Icons.hide_image_outlined,
          ),
          title: const Text('Image'),
        ),
        if (widget.decoration.image != null)
          ListTile(
            enabled: widget.decoration.image != null,
            leading: const Icon(Icons.layers_outlined),
            title: const Text('Image position'),
            trailing: PopupMenuButton(
              onSelected: changeImagePosition,
              initialValue: widget.decoration.image?.position,
              itemBuilder: (context) {
                return [
                  const PopupMenuItem(
                    value: PrettyQrDecorationImagePosition.embedded,
                    child: Text('Embedded'),
                  ),
                  const PopupMenuItem(
                    value: PrettyQrDecorationImagePosition.foreground,
                    child: Text('Foreground'),
                  ),
                  const PopupMenuItem(
                    value: PrettyQrDecorationImagePosition.background,
                    child: Text('Background'),
                  ),
                ];
              },
            ),
          ),
        if (widget.onExportPressed != null) ...[
          const Divider(),
          ListTile(
            leading: const Icon(Icons.save_alt_outlined),
            title: const Text('Export'),
            onTap: () async {
              final path = await widget.onExportPressed?.call(imageSize);
              showExportPath(path);
            },
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PopupMenuButton(
                  initialValue: imageSize,
                  onSelected: (value) {
                    imageSizeEditingController.text = ' ${value}w';
                    setState(() {});
                  },
                  itemBuilder: (context) {
                    return [
                      const PopupMenuItem(
                        value: 256,
                        child: Text('256w'),
                      ),
                      const PopupMenuItem(
                        value: 512,
                        child: Text('512w'),
                      ),
                      const PopupMenuItem(
                        value: 1024,
                        child: Text('1024w'),
                      ),
                    ];
                  },
                  child: SizedBox(
                    width: 72,
                    height: 36,
                    child: TextField(
                      enabled: false,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                      controller: imageSizeEditingController,
                      decoration: InputDecoration(
                        filled: true,
                        counterText: '',
                        contentPadding: EdgeInsets.zero,
                        fillColor: Theme.of(context).colorScheme.surface,
                        disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  @protected
  void changeShape(
    final Object type,
  ) {
    if (type is PrettyQrDecorationPreset) {
      widget.onChanged?.call(
        PrettyQrDecoration.fromPreset(
          type,
          color: brush,
          image: widget.decoration.image,
          quietZone: widget.decoration.quietZone,
          background: widget.decoration.background,
        ),
      );
      return;
    }

    var shape = widget.decoration.shape;
    switch (type) {
      case PrettyQrDotsSymbol:
        shape = PrettyQrDotsSymbol(color: brush);
        break;
      case PrettyQrSmoothSymbol:
        shape = PrettyQrSmoothSymbol(color: brush);
        break;
      case PrettyQrSquaresSymbol:
        shape = PrettyQrSquaresSymbol(
          color: brush,
          density: 0.86,
          rounding: 0.5,
        );
        break;
      case PrettyQrCustomShape:
        shape = randomShape();
        break;
      default:
    }
    widget.onChanged?.call(widget.decoration.copyWith(shape: shape));
  }

  @protected
  void toggleColor(bool value) {
    brush = value
        ? _PrettyQrSettings.kDefaultQrDecorationBrush
        : PrettyQrBrush.gradient(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.teal[200]!,
                Colors.blue[200]!,
                Colors.red[200]!,
              ],
            ),
          );

    var shape = widget.decoration.shape;
    if (shape is PrettyQrDotsSymbol) {
      shape = PrettyQrDotsSymbol(
        color: brush,
      );
    } else if (shape is PrettyQrSmoothSymbol) {
      shape = PrettyQrSmoothSymbol(
        color: brush,
        roundFactor: shape.roundFactor,
      );
    } else if (shape is PrettyQrSquaresSymbol) {
      shape = PrettyQrSquaresSymbol(
        color: brush,
        density: shape.density,
        rounding: shape.rounding,
      );
    }

    widget.onChanged?.call(widget.decoration.copyWith(shape: shape));
  }

  @protected
  void toggleQuietZone() {
    widget.onChanged?.call(
      widget.decoration.copyWith(
        quietZone: widget.decoration.quietZone != PrettyQrQuietZone.zero
            ? PrettyQrQuietZone.zero
            : PrettyQrQuietZone.standart,
      ),
    );
  }

  @protected
  void toggleBackground() {
    widget.onChanged?.call(
      widget.decoration.copyWith(
        background: widget.decoration.background != Colors.transparent
            ? Colors.transparent
            : _PrettyQrSettings.kDefaultQrDecorationBrush.withOpacity(0.1),
      ),
    );
  }

  @protected
  void toggleRoundedCorners() {
    var shape = widget.decoration.shape;

    if (shape is PrettyQrSmoothSymbol) {
      shape = PrettyQrSmoothSymbol(
        color: shape.color,
        roundFactor: isRoundedBorders! ? 0 : 1,
      );
    } else if (shape is PrettyQrSquaresSymbol) {
      shape = PrettyQrSquaresSymbol(
        color: shape.color,
        density: shape.density,
        rounding: isRoundedBorders! ? 0 : 0.5,
      );
    }

    widget.onChanged?.call(widget.decoration.copyWith(shape: shape));
  }

  @protected
  void toggleImage() {
    const defaultImage = _PrettyQrSettings.kDefaultQrDecorationImage;
    final image = widget.decoration.image != null ? null : defaultImage;

    widget.onChanged?.call(PrettyQrDecoration(
      image: image,
      shape: widget.decoration.shape,
      quietZone: widget.decoration.quietZone,
      background: widget.decoration.background,
    ));
  }

  @protected
  void changeImagePosition(
    final PrettyQrDecorationImagePosition value,
  ) {
    final image = widget.decoration.image?.copyWith(position: value);
    widget.onChanged?.call(widget.decoration.copyWith(image: image));
  }

  @protected
  String get scannabilityLabel {
    final report = widget.decoration.estimateScannability(
      errorCorrectLevel: widget.errorCorrectLevel,
    );
    final percent = (report.coveredFraction * 100).toStringAsFixed(1);
    final recommended = report.recommendedErrorCorrectLevel.name;
    switch (report.scannability) {
      case PrettyQrScannability.good:
        return '$percent% covered';
      case PrettyQrScannability.warning:
        return '$percent% covered; test before release';
      case PrettyQrScannability.risky:
        return '$percent% covered; try $recommended';
    }
  }

  @protected
  void applySafeImage() {
    widget.onChanged?.call(
      widget.decoration.withSafeImage(
        errorCorrectLevel: widget.errorCorrectLevel,
      ),
    );
  }

  @protected
  PrettyQrShape randomShape() {
    const colors = [
      Color(0xFF90CAF9),
      Color(0xFFEF9A9A),
      Color(0xFF8C9EFF),
      Color(0xFFB39DDB),
      Color(0xFF9FA8DA),
      Color(0xFF80CBC4),
      Color(0xFFF06292),
      Color(0xFF4DB6AC),
      PrettyQrBrush.gradient(
        gradient: LinearGradient(
          colors: [Color(0xFF90CAF9), Color(0xFF80CBC4)],
        ),
      ),
    ];

    final types = [
      PrettyQrDotsSymbol(
        color: colors[random.nextInt(colors.length)],
        unifiedFinderPattern: random.nextBool(),
        unifiedAlignmentPatterns: random.nextBool(),
      ),
      PrettyQrSmoothSymbol(
        color: colors[random.nextInt(colors.length)],
      ),
      PrettyQrSquaresSymbol(
        color: colors[random.nextInt(colors.length)],
        density: 0.86,
        unifiedFinderPattern: random.nextBool(),
      ),
    ];

    return PrettyQrShape.custom(
      types[random.nextInt(types.length)],
      finderPattern: types[random.nextInt(types.length)],
      alignmentPatterns: types[random.nextInt(types.length)],
      timingPatterns: types[random.nextInt(types.length)],
    );
  }

  @override
  void dispose() {
    imageSizeEditingController.dispose();

    super.dispose();
  }
}

class PrettyQrFlutterLogoClipper implements PrettyQrClipper {
  const PrettyQrFlutterLogoClipper();

  @override
  Path getClip(Size size) {
    final logoPath = Path()
      ..moveTo(0.566, 0.001)
      ..lineTo(0.004, 0.514)
      ..lineTo(0.525, 1.001)
      ..lineTo(0.986, 1.001)
      ..lineTo(0.681, 0.723)
      ..lineTo(0.986, 0.445)
      ..lineTo(0.577, 0.445)
      ..lineTo(0.546, 0.417)
      ..lineTo(1.004, 0.001)
      ..close();

    return logoPath.transform(
      (Matrix4.identity()..scale(size.width, size.height)).storage,
    );
  }
}
