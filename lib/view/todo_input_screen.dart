import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/todo.dart';
import 'todo_input.dart';

class TodoInputScreen extends StatelessWidget {
  const TodoInputScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final model = context.read<TodoModel>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: TodoInput(
            onSubmit: (value) {
              value = value.trim();

              if (value.isNotEmpty) {
                model.addItem(value);
              }

              Navigator.pop(context);
            },
            // onCancel: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }
}
