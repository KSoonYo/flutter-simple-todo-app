import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorPickerDialog extends StatefulWidget {
  const ColorPickerDialog({
    super.key,
    required this.initialColor,
    required this.onPick,
  });

  final Color initialColor;
  final void Function(Color color) onPick;

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late Color _currentColor = widget.initialColor;

  void _setCurrentColor(Color color) {
    setState(() {
      _currentColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: ColorPicker(
        pickerColor: _currentColor,
        onColorChanged: _setCurrentColor,
        enableAlpha: false,
        portraitOnly: true,
        labelTypes: const [],
      ),
      actions: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.cancel_outlined),
        ),
        IconButton(
          onPressed: () {
            widget.onPick(_currentColor);
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.check),
        ),
      ],
    );
  }
}
