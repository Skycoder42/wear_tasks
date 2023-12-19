import 'package:flutter/material.dart';

import '../app/watch_theme.dart';

class CheckboxFormField extends FormField<bool> {
  CheckboxFormField({
    super.key,
    Widget? title,
    Widget? subtitle,
    void Function(bool?)? onChanged,
    super.onSaved,
    super.validator,
    bool super.initialValue = false,
    super.enabled,
    super.autovalidateMode,
    super.restorationId,
  }) : super(
          builder: (state) => CheckboxListTile(
            dense: state.hasError || subtitle != null,
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
                : subtitle,
            controlAffinity: ListTileControlAffinity.leading,
            enabled: enabled,
          ),
        );
}
