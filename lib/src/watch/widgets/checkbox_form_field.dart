import 'package:flutter/material.dart';

import '../app/watch_theme.dart';

class CheckboxFormField extends FormField<bool> {
  CheckboxFormField({
    super.key,
    Widget? title,
    void Function(bool?)? onChanged,
    super.onSaved,
    super.validator,
    bool super.initialValue = false,
    super.enabled,
    super.autovalidateMode,
    super.restorationId,
  }) : super(
          builder: (state) => CheckboxListTile(
            dense: state.hasError,
            title: title,
            value: state.value,
            onChanged: (v) {
              state.didChange(v);
              onChanged?.call(v);
            },
            isError: state.hasError,
            subtitle: state.hasError
                ? Builder(
                    builder: (context) => Text(
                      state.errorText ?? '',
                      style: TextStyle(color: context.theme.colorScheme.error),
                    ),
                  )
                : null,
            controlAffinity: ListTileControlAffinity.leading,
            enabled: enabled,
          ),
        );
}
