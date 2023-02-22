import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'shake.dart';

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

class _TodoInputState extends State<TodoInput>
    with SingleTickerProviderStateMixin {
  static const _maxLength = 40;

  late TextEditingController _controller;
  var _length = 0;
  bool get _isEmpty => _length == 0;
  bool get _isFull => _length == _maxLength;

  late AnimationController _animationController;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(text: widget.initialValue);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = _animationController
        .drive(CurveTween(curve: Shake()))
        .drive(Animatable.fromCallback((value) => Offset(value * 0.01, 0)));
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();

    super.dispose();
  }

  void _updateLength(int length) {
    if (_length != length && length == _maxLength) {
      _animationController.forward().then((_) => _animationController.reset());
    }

    setState(() {
      _length = length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return SlideTransition(
      position: _animation,
      child: Padding(
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
      ),
    );
  }
}
