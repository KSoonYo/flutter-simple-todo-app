import 'package:flutter/material.dart';

class TodoInput extends StatefulWidget {
  const TodoInput({super.key, required this.onSubmit, this.initialValue});

  final void Function(String value) onSubmit;
  final String? initialValue;

  @override
  State<TodoInput> createState() => _TodoInputState();
}

class _TodoInputState extends State<TodoInput> {
  late TextEditingController _controller;

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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _controller,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.done,
        onSubmitted: (value) {
          widget.onSubmit(value);
          _controller.clear();
        },
        decoration: const InputDecoration(
          border: UnderlineInputBorder(),
        ),
      ),
    );
  }
}
