import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

typedef SaveCallback = void Function(String key, dynamic value);
typedef FormBuilder = Widget Function(
  BuildContext context,
  SaveCallback onSaved,
  VoidCallback onSubmit,
);
typedef SubmitCallback = void Function(Map<String, dynamic> result);

class SubmitForm extends HookWidget {
  final FormBuilder builder;
  final SubmitCallback onSubmit;
  final VoidCallback? onValidationFailed;

  const SubmitForm({
    super.key,
    required this.builder,
    required this.onSubmit,
    this.onValidationFailed,
  });

  @override
  Widget build(BuildContext context) {
    final formKey = useState(GlobalKey<FormState>()).value;
    final savedResult = useRef(<String, dynamic>{});
    final onSaved = useCallback<SaveCallback>(
      (key, value) {
        savedResult.value[key] = value;
      },
      [savedResult],
    );
    final onSubmit = useCallback<VoidCallback>(
      () {
        final formState = formKey.currentState;
        if (formState == null) {
          return;
        }

        if (!formState.validate()) {
          onValidationFailed?.call();
          return;
        }

        savedResult.value.clear();
        formState.save();
        this.onSubmit(savedResult.value);
      },
      [formKey, savedResult, onValidationFailed, this.onSubmit],
    );

    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: builder(context, onSaved, onSubmit),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(ObjectFlagProperty<FormBuilder>.has('builder', builder))
      ..add(ObjectFlagProperty<SubmitCallback>.has('onSubmit', onSubmit))
      ..add(
        ObjectFlagProperty<VoidCallback?>.has(
          'onValidationFailed',
          onValidationFailed,
        ),
      );
  }
}
