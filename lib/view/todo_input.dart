import 'package:flutter/material.dart';

class TodoInput extends StatefulWidget {
  const TodoInput({
    super.key,
    required this.onSubmit,
    required this.onCancel,
    this.focusNode,
    this.initialValue,
  });

  final void Function(String value) onSubmit;
  final void Function() onCancel;
  final FocusNode? focusNode;
  final String? initialValue;

  @override
  State<TodoInput> createState() => _TodoInputState();
}

class _TodoInputState extends State<TodoInput> {
  late TextEditingController _controller;
  var _isEmpty = true;

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

  void _setEmpty(bool empty) {
    setState(() {
      _isEmpty = empty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _controller,
        focusNode: widget.focusNode,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.done,
        style: Theme.of(context).primaryTextTheme.headlineLarge,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          border: const UnderlineInputBorder(),
          hintText: "What's up?",
          suffixIcon: !_isEmpty
              ? IconButton(
                  onPressed: _controller.clear,
                  icon: const Icon(Icons.clear),
                )
              : null,
        ),
        onChanged: (value) => _setEmpty(value.isEmpty),
        onSubmitted: (value) {
          widget.onSubmit(value);
          _controller.clear();
        },
        onTapOutside: (_) => widget.onCancel(),
      ),
    );
  }
}
