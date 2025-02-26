import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'palette.dart';
import 'utils.dart';

const _kRecentColorsKey = '__ff_recent_colors__';

const _alphaValueIndex = 3;
const Map<ColorLabelType, List<String>> _colorTypes = {
  ColorLabelType.rgb: ['R', 'G', 'B', 'A'],
  ColorLabelType.hsv: ['H', 'S', 'V', 'A'],
  ColorLabelType.hsl: ['H', 'S', 'L', 'A'],
};

Future<Color?> showFFColorPicker(
  BuildContext context, {
  Color? currentColor,
  bool showRecentColors = false,
  bool allowOpacity = true,
  required bool displayAsBottomSheet,
  Color? textColor,
  Color? secondaryTextColor,
  Color? backgroundColor,
  Color? primaryButtonBackgroundColor,
  Color? primaryButtonTextColor,
  Color? primaryButtonBorderColor,
  TextStyle? primaryTextStyle,
  TextStyle? secondaryTextStyle,
  required ValueChanged<Color> onColorChanged,
}) {
  final colorPicker = FFColorPickerDialog(
    currentColor: currentColor,
    showRecentColors: showRecentColors,
    allowOpacity: allowOpacity,
    backgroundColor: backgroundColor ?? const Color(0xFF14181B),
    primaryButtonBackgroundColor:
        primaryButtonBackgroundColor ?? const Color(0xFF4542e6),
    primaryButtonTextColor: primaryButtonTextColor ?? Colors.white,
    primaryButtonBorderColor: primaryButtonBorderColor ?? Colors.transparent,
    displayAsBottomSheet: displayAsBottomSheet,
    primaryTextStyle: GoogleFonts.openSans(
      fontSize: 10,
      color: textColor ?? Colors.white,
    ),
    secondaryTextStyle: GoogleFonts.openSans(
      fontSize: 10,
      color: secondaryTextColor ?? const Color(0xFF95A1AC),
    ),
    onColorChanged: onColorChanged,
  );

  if (displayAsBottomSheet) {
    return showModalBottomSheet<Color?>(
      context: context,
      builder: (context) => Wrap(
        alignment: WrapAlignment.spaceAround,
        children: [colorPicker],
      ),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
    );
  }

  return showDialog<Color?>(
    context: context,
    builder: (_) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
      child: AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: colorPicker,
      ),
    ),
  );
}

class FFColorPickerDialog extends StatefulWidget {
  const FFColorPickerDialog({
    Key? key,
    this.currentColor,
    this.showRecentColors = false,
    this.allowOpacity = true,
    required this.displayAsBottomSheet,
    this.backgroundColor = const Color(0xFF14181B),
    this.primaryButtonBackgroundColor = const Color(0xFF4542e6),
    this.primaryButtonTextColor = Colors.white,
    this.primaryButtonBorderColor = Colors.transparent,
    required this.primaryTextStyle,
    required this.secondaryTextStyle,
    required this.onColorChanged,
  }) : super(key: key);

  final Color? currentColor;
  final bool showRecentColors;
  final bool allowOpacity;
  final bool displayAsBottomSheet;
  final Color backgroundColor;
  final Color primaryButtonBackgroundColor;
  final Color primaryButtonTextColor;
  final Color primaryButtonBorderColor;
  final TextStyle primaryTextStyle;
  final TextStyle secondaryTextStyle;
  final ValueChanged<Color> onColorChanged;

  @override
  _FFColorPickerDialogState createState() => _FFColorPickerDialogState();
}

class _FFColorPickerDialogState extends State<FFColorPickerDialog> {
  List<Color> recentColors = [];
  ColorLabelType? colorType = ColorLabelType.rgb;
  late Color selectedColor;

  @override
  void initState() {
    super.initState();
    selectedColor = widget.currentColor ?? Colors.black;
    if (widget.showRecentColors) {
      _initRecentColors();
    }
  }

  late SharedPreferences _prefs;

  Future _initRecentColors() async {
    _prefs = await SharedPreferences.getInstance();
    final strColors = _prefs.getStringList(_kRecentColorsKey) ?? [];
    if (strColors.isEmpty) {
      return;
    }
    setState(
      () => recentColors =
          strColors.map((c) => Color(int.parse(c, radix: 16))).toList(),
    );
  }

  void _addRecentColor(Color color) {
    final currentColors = _prefs.getStringList(_kRecentColorsKey) ?? [];
    final newColor = color.value.toInt().toRadixString(16);
    if (currentColors.contains(newColor)) {
      return;
    }
    _prefs.setStringList(_kRecentColorsKey, currentColors + [newColor]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.displayAsBottomSheet ? null : 394,
      color: widget.backgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Builder(
                builder: (context) {
                  final currentHsvColor = HSVColor.fromColor(selectedColor);

                  onColorChanged(val) {
                    setState(() => selectedColor = val);
                    widget.onColorChanged(val);
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4.0),
                        child: SizedBox(
                          width: 220,
                          height: 110,
                          child: ColorPickerArea(
                            currentHsvColor,
                            (val) => onColorChanged(val.toColor()),
                            PaletteType.hsvWithHue,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      SizedBox(
                        height: 20.0,
                        child: ColorPickerSlider(
                          TrackType.hue,
                          currentHsvColor,
                          (color) => onColorChanged(color.toColor()),
                        ),
                      ),
                      if (widget.allowOpacity) ...[
                        const SizedBox(height: 15.0),
                        SizedBox(
                          height: 21.0,
                          child: ColorPickerSlider(
                            TrackType.alpha,
                            currentHsvColor,
                            (color) => onColorChanged(color.toColor()),
                          ),
                        ),
                      ],
                      const SizedBox(height: 28.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 26.0,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 4.0,
                                      top: 6.0,
                                      bottom: 6.0,
                                    ),
                                    child: DropdownButton<ColorLabelType>(
                                      alignment: AlignmentDirectional.center,
                                      value: colorType,
                                      isDense: true,
                                      dropdownColor: Colors.white,
                                      focusColor: Colors.transparent,
                                      underline: Container(),
                                      iconSize: 16,
                                      icon: const Icon(
                                        Icons.keyboard_arrow_down,
                                        color: Colors.black,
                                      ),
                                      items: _colorTypes.keys
                                          .map(
                                            (type) => DropdownMenuItem(
                                              value: type,
                                              child: Text(
                                                type
                                                    .toString()
                                                    .split('.')
                                                    .last
                                                    .toUpperCase(),
                                                style: widget.secondaryTextStyle
                                                    .copyWith(
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (type) =>
                                          setState(() => colorType = type),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                ColorPickerInput(
                                  currentHsvColor.toColor(),
                                  (color) => onColorChanged(color),
                                  showColor: true,
                                  style: widget.primaryTextStyle.copyWith(
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 28.0),
                          Expanded(
                            child: SizedBox(
                              width: double.infinity,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                children: _colorValueLabels(
                                  currentHsvColor,
                                  widget.allowOpacity,
                                  widget.primaryTextStyle,
                                  widget.secondaryTextStyle,
                                )
                                    .map((w) => Padding(
                                          padding:
                                              const EdgeInsets.only(top: 5.0),
                                          child: w,
                                        ))
                                    .toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 7.0),
              Builder(builder: (context) {
                recentColorsWidget(double maxWidth) => Wrap(
                      runSpacing: 10.0,
                      spacing: (maxWidth - 40.0 * 7) / 6,
                      children: recentColors.reversed.take(14).map<Widget>((c) {
                        return InkWell(
                          onTap: () => setState(() => selectedColor = c),
                          child: Container(
                            width: 40.0,
                            height: 34.0,
                            decoration: BoxDecoration(
                              color: c,
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                return widget.displayAsBottomSheet
                    ? LayoutBuilder(
                        builder: (context, constraints) =>
                            recentColorsWidget(constraints.maxWidth),
                      )
                    : recentColorsWidget(394);
              }),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _colorValueLabels(
    HSVColor hsvColor,
    bool allowOpacity,
    TextStyle primaryTextStyle,
    TextStyle secondaryTextStyle,
  ) {
    final colorTypes = allowOpacity
        ? _colorTypes[colorType!]
        : _colorTypes[colorType!]!.sublist(0, _alphaValueIndex);

    return colorTypes!
        .map(
          (item) => ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 50.0),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 26,
                  child: Text(
                    item,
                    style: secondaryTextStyle.copyWith(
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 5.0),
                SizedBox(
                  height: 26,
                  child: Text(
                    _colorValue(hsvColor, colorType)[
                        _colorTypes[colorType!]!.indexOf(item)],
                    overflow: TextOverflow.ellipsis,
                    style: primaryTextStyle.copyWith(
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }
}

List<String> _colorValue(HSVColor hsvColor, ColorLabelType? colorLabelType) {
  switch (colorLabelType) {
    case ColorLabelType.rgb:
      final Color color = hsvColor.toColor();
      return [
        color.red.toString(),
        color.green.toString(),
        color.blue.toString(),
        '${(color.opacity * 100).round()}%',
      ];
    case ColorLabelType.hsv:
      return [
        '${hsvColor.hue.round()}°',
        '${(hsvColor.saturation * 100).round()}%',
        '${(hsvColor.value * 100).round()}%',
        '${(hsvColor.alpha * 100).round()}%',
      ];
    case ColorLabelType.hsl:
      HSLColor hslColor = hsvToHsl(hsvColor);
      return [
        '${hslColor.hue.round()}°',
        '${(hslColor.saturation * 100).round()}%',
        '${(hslColor.lightness * 100).round()}%',
        '${(hsvColor.alpha * 100).round()}%',
      ];
    default:
      return ['??', '??', '??', '??'];
  }
}
