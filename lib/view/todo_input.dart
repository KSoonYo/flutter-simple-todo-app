import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TodoInput extends StatefulWidget {
  const TodoInput({
    super.key,
    required this.onSubmit,
    this.onCancel,
    this.initialValue,
  });

  final void Function(String value) onSubmit;
  final void Function()? onCancel;
  final String? initialValue;

  @override
  State<TodoInput> createState() => _TodoInputState();
}

class _TodoInputState extends State<TodoInput> {
  static const _maxLength = 40;

  late TextEditingController _controller;
  var _length = 0;
  bool get _isEmpty => _length == 0;
  bool get _isFull => _length == _maxLength;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  void _updateLength(int length) {
    setState(() {
      _length = length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _controller,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.done,
        style: Theme.of(context).textTheme.headlineLarge,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          border: const UnderlineInputBorder(),
          hintText: t.todoInputHint,
          counterText: '$_length/$_maxLength',
          errorText: _isFull ? t.todoInputMaxLengthReached : null,
          suffixIcon: !_isEmpty
              ? IconButton(
                  onPressed: () {
                    _controller.clear();
                    _updateLength(0);
                  },
                  icon: const Icon(Icons.clear),
                )
              : null,
        ),
        autofocus: true,
        onChanged: (value) {
          _updateLength(value.length);
        },
        onSubmitted: (value) {
          widget.onSubmit(value);
          _controller.clear();
        },
        onTapOutside: (_) => widget.onCancel?.call(),
        maxLength: _maxLength,
      ),
    );
  }
}
