import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:simple_todo/models/settings.dart';
import 'package:simple_todo/utils/text.dart';

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
  late TextEditingController _controller;
  var _length = 0;
  var _maxLength = 0;
  bool get _isEmpty => _length == 0;

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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final textStyle = _getTextStyle(context);

          _maxLength = _calculateMaxLength(textStyle, constraints);
          final isFull = _controller.text.length >= _maxLength;

          return TextField(
            controller: _controller,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
            style: textStyle.copyWith(
              color: isFull ? theme.colorScheme.error : textStyle.color,
            ),
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(16.0),
              border: const UnderlineInputBorder(),
              hintText: t.todoInputHint,
              errorText: isFull ? t.todoInputMaxLengthReached : null,
              suffixIcon: isFull
                  ? const Icon(Icons.error)
                  : !_isEmpty
                      ? IconButton(
                          onPressed: _controller.clear,
                          icon: const Icon(Icons.cancel_outlined),
                        )
                      : null,
            ),
            focusNode: widget.focusNode,
            onSubmitted: (value) {
              widget.onSubmit(value);
              _controller.clear();
            },
            maxLength: _maxLength,
          );
        },
      ),
    );
  }

  int _calculateMaxLength(TextStyle style, BoxConstraints constraints) {
    final em = getTextSize('M', style).width;
    final width = constraints.maxWidth - (16 * 2 + 16 + 24);
    final rawLength = width ~/ em;
    final conservativeWidth = rawLength * em - rawLength ~/ 2;
    return conservativeWidth ~/ em;
  }

  TextStyle _getTextStyle(BuildContext context) {
    final fontSize =
        context.select<SettingsModel, FontSize>((value) => value.fontSize);
    final theme = Theme.of(context);

    return (fontSize == FontSize.small
        ? theme.textTheme.headlineSmall
        : fontSize == FontSize.medium
            ? theme.textTheme.headlineMedium
            : theme.textTheme.headlineLarge)!;
  }
}
