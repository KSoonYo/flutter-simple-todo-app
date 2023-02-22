import 'package:flutter/material.dart';

import 'todo_input.dart';

class TodoInputScreen extends StatelessWidget {
  const TodoInputScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: TodoInput(
            onSubmit: (value) {
              Navigator.pop(context, value.trim());
            },
            // onCancel: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }
}
