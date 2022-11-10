import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'palette.dart';
import 'utils.dart';

const _kRecentColorsKey = '__ff_recent_colors__';

const Map<ColorLabelType, List<String>> _colorTypes = {
  ColorLabelType.rgb: ['R', 'G', 'B', 'A'],
  ColorLabelType.hsv: ['H', 'S', 'V', 'A'],
  ColorLabelType.hsl: ['H', 'S', 'L', 'A'],
};

class FFColorPickerDialog extends StatefulWidget {
  const FFColorPickerDialog({
    Key? key,
    this.currentColor,
    this.showRecentColors = false,
    this.darkMode = true,
  }) : super(key: key);

  final Color? currentColor;
  final bool showRecentColors;
  final bool darkMode;

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

  Future _initRecentColors() async {
    final prefs = await SharedPreferences.getInstance();
    final strColors = prefs.getStringList(_kRecentColorsKey) ?? [];
    if (strColors.isEmpty) {
      return;
    }
    setState(
      () => recentColors =
          strColors.map((c) => Color(int.parse(c, radix: 16))).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Adjust the size of the dialog for mobile vs web.
    // TODO: Create a light mode and a dark mode version.
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
      child: AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        scrollable: true,
        content: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 610,
            color: const Color(0xFF14181B),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Choose a Color',
                        style: TextStyle(
                          fontFamily: 'Open Sans',
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                          color: Colors.white,
                        ),
                      ),
                      InkWell(
                        onTap: () =>
                            Navigator.of(context, rootNavigator: true).pop(),
                        child: const Icon(
                          Icons.clear,
                          size: 20.0,
                          color: Color(0xFF95A1AC),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(6, 0, 0, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10.0),
                        Builder(
                          builder: (context) {
                            final currentHsvColor =
                                HSVColor.fromColor(selectedColor);

                            onColorChanged(val) =>
                                setState(() => selectedColor = val);

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4.0),
                                  child: SizedBox(
                                    width: 220,
                                    height: 136,
                                    child: ColorPickerArea(
                                      currentHsvColor,
                                      (val) => onColorChanged(val.toColor()),
                                      PaletteType.hsvWithHue,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 15.0),
                                Container(
                                  width: 40.0,
                                  height: 40.0,
                                  decoration: BoxDecoration(
                                    color: selectedColor,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                ),
                                const SizedBox(width: 3.0),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 6.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 20.0,
                                          child: ColorPickerSlider(
                                            TrackType.hue,
                                            currentHsvColor,
                                            (color) =>
                                                onColorChanged(color.toColor()),
                                          ),
                                        ),
                                        const SizedBox(height: 15.0),
                                        SizedBox(
                                          height: 21.0,
                                          child: ColorPickerSlider(
                                            TrackType.alpha,
                                            currentHsvColor,
                                            (color) =>
                                                onColorChanged(color.toColor()),
                                          ),
                                        ),
                                        const SizedBox(height: 12.0),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(width: 15.0),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  height: 24.0,
                                                  child: DropdownButton<
                                                      ColorLabelType>(
                                                    value: colorType,
                                                    dropdownColor: Colors.black,
                                                    focusColor:
                                                        Colors.transparent,
                                                    underline: Container(),
                                                    icon: const Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 8.0),
                                                      child: Icon(
                                                        Icons
                                                            .keyboard_arrow_down,
                                                        size: 18.0,
                                                        color:
                                                            Color(0xFF95A1AC),
                                                      ),
                                                    ),
                                                    items: _colorTypes.keys
                                                        .map(
                                                          (type) =>
                                                              DropdownMenuItem(
                                                            value: type,
                                                            child: Text(
                                                              type
                                                                  .toString()
                                                                  .split('.')
                                                                  .last
                                                                  .toUpperCase(),
                                                              style:
                                                                  const TextStyle(
                                                                fontFamily:
                                                                    'Open Sans',
                                                                fontSize: 12,
                                                                color: Color(
                                                                    0xFF95A1AC),
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                        .toList(),
                                                    onChanged: (type) =>
                                                        setState(() =>
                                                            colorType = type),
                                                  ),
                                                ),
                                                ColorPickerInput(
                                                  currentHsvColor.toColor(),
                                                  (color) =>
                                                      onColorChanged(color),
                                                  embeddedText: false,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'Open Sans',
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(width: 12.0),
                                            ..._colorValueLabels(
                                                    currentHsvColor)
                                                .map(
                                              (w) => Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 5.0),
                                                child: w,
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        if (recentColors.isNotEmpty) ...[
                          const SizedBox(height: 16.0),
                          const Text(
                            "Recent Colors",
                            style: TextStyle(
                              color: Color(0xFF95A1AC),
                              fontFamily: 'Open Sans',
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 12.0),
                          Row(
                            children: recentColors.reversed
                                .take(15)
                                .map<Widget>(
                                  (c) => InkWell(
                                    onTap: () =>
                                        setState(() => selectedColor = c),
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: c,
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.5),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                        const SizedBox(height: 24.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              height: 40.0,
                              width: 115.0,
                              child: ElevatedButton(
                                onPressed: () =>
                                    Navigator.of(context, rootNavigator: true)
                                        .pop(),
                                style: ButtonStyle(
                                  shape:
                                      MaterialStateProperty.all<OutlinedBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  foregroundColor:
                                      MaterialStateProperty.all<Color>(
                                    Colors.white,
                                  ),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                    const Color(0xFF323B45),
                                  ),
                                  padding: MaterialStateProperty.all(
                                    const EdgeInsets.symmetric(
                                      horizontal: 12.0,
                                      vertical: 4.0,
                                    ),
                                  ),
                                  elevation:
                                      MaterialStateProperty.all<double>(2.0),
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontFamily: 'Open Sans',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            const SizedBox(width: 20.0),
                            SizedBox(
                              height: 40.0,
                              width: 103.0,
                              child: ElevatedButton(
                                onPressed: () =>
                                    Navigator.of(context, rootNavigator: true)
                                        .pop(selectedColor),
                                style: ButtonStyle(
                                  shape:
                                      MaterialStateProperty.all<OutlinedBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  foregroundColor:
                                      MaterialStateProperty.all<Color>(
                                    Colors.white,
                                  ),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                    const Color(0xFF4542e6),
                                  ),
                                  padding: MaterialStateProperty.all(
                                    const EdgeInsets.symmetric(
                                      horizontal: 12.0,
                                      vertical: 4.0,
                                    ),
                                  ),
                                  elevation:
                                      MaterialStateProperty.all<double>(2.0),
                                ),
                                child: const Text(
                                  'Use Color',
                                  style: TextStyle(
                                    fontFamily: 'Open Sans',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _colorValueLabels(HSVColor hsvColor) => _colorTypes[colorType!]!
      .map(
        (item) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 24.0),
            child: IntrinsicHeight(
              child: Column(
                children: <Widget>[
                  Text(
                    item,
                    style: const TextStyle(
                      fontFamily: 'Open Sans',
                      fontSize: 12,
                      color: Color(0xFF95A1AC),
                    ),
                  ),
                  const SizedBox(height: 19.0),
                  Expanded(
                    child: Text(
                      _colorValue(hsvColor, colorType)[
                          _colorTypes[colorType!]!.indexOf(item)],
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Open Sans',
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      )
      .toList();
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