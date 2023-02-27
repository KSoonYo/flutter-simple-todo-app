import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'shake.dart';

class TodoInput extends StatefulWidget {
  const TodoInput({
    super.key,
    this.focusNode,
    required this.onSubmit,
    this.onCancel,
    this.initialValue,
  });

  final FocusNode? focusNode;
  final void Function(String value) onSubmit;
  final void Function()? onCancel;
  final String? initialValue;

  @override
  State<TodoInput> createState() => _TodoInputState();
}

class _TodoInputState extends State<TodoInput>
    with SingleTickerProviderStateMixin {
  static const _maxLength = 40;

  late TextEditingController _controller;
  var _length = 0;
  bool get _isEmpty => _length == 0;
  bool get _isFull => _length >= _maxLength;

  late AnimationController _animationController;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(text: widget.initialValue);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _offsetAnimation = _animationController
        .drive(CurveTween(curve: Shake()))
        .drive(Tween(begin: const Offset(0, 0), end: const Offset(0.01, 0)));

    _controller.addListener(() => _updateLength(_controller.text.length));
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();

    super.dispose();
  }

  void _updateLength(int length) {
    if (length != _length && length >= _maxLength) {
      _animationController.forward().then((_) => _animationController.reset());
    }

    setState(() => _length = length);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;

    return SlideTransition(
      position: _offsetAnimation,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _controller,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.done,
          style: theme.textTheme.headlineLarge?.copyWith(
            color: _isFull
                ? theme.colorScheme.error
                : theme.textTheme.headlineLarge?.color,
          ),
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            border: const UnderlineInputBorder(),
            hintText: t.todoInputHint,
            errorText: _isFull ? t.todoInputMaxLengthReached : null,
            suffixIcon: _isFull
                ? const Icon(Icons.error)
                : !_isEmpty
                    ? IconButton(
                        onPressed: _controller.clear,
                        icon: const Icon(Icons.clear),
                      )
                    : null,
          ),
          focusNode: widget.focusNode,
          onSubmitted: (value) {
            widget.onSubmit(value);
            _controller.clear();
          },
          maxLength: _maxLength,
        ),
      ),
    );
  }
}
