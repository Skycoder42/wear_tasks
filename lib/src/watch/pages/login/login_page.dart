import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../common/localization/localization.dart';
import '../../app/watch_theme.dart';
import '../../providers/etebase_provider.dart';
import '../../widgets/checkbox_form_field.dart';

class _LoginInfo {
  String username = '';
  String password = '';
  Uri serverUrl = Uri();
}

class LoginPage extends HookConsumerWidget {
  final String? redirectTo;

  const LoginPage({
    super.key,
    this.redirectTo,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useState(GlobalKey<FormState>());
    final useDefaultServer = useState(true);
    final defaultServerUrlController = useTextEditingController();
    final customServerUrlController = useTextEditingController();
    final serverUrlController = useDefaultServer.value
        ? defaultServerUrlController
        : customServerUrlController;

    final serverUrlValidator = _useServerUrl(
      context,
      ref,
      defaultServerUrlController,
      useDefaultServer,
    );

    final resultRef = useRef(_LoginInfo());

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(context.strings.login_page_title),
            pinned: true,
          ),
          SliverToBoxAdapter(
            child: SafeArea(
              top: false,
              child: Form(
                key: formKey.value,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        alignLabelWithHint: true,
                        label: Text(context.strings.login_page_username_label),
                      ),
                      validator: (value) => _validateNotEmpty(context, value),
                      onSaved: (newValue) =>
                          resultRef.value.username = newValue!,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        alignLabelWithHint: true,
                        label: Text(context.strings.login_page_password_label),
                      ),
                      obscureText: true,
                      validator: (value) => _validateNotEmpty(context, value),
                      onSaved: (newValue) =>
                          resultRef.value.password = newValue!,
                    ),
                    CheckboxFormField(
                      title: Text(
                        context.strings.login_page_use_default_url_label,
                      ),
                      initialValue: useDefaultServer.value,
                      onChanged: (v) => useDefaultServer.value = v ?? true,
                    ),
                    TextFormField(
                      controller: serverUrlController,
                      decoration: InputDecoration(
                        alignLabelWithHint: true,
                        label: Text(
                          context.strings.login_page_server_url_label,
                        ),
                      ),
                      keyboardType: TextInputType.url,
                      readOnly: useDefaultServer.value,
                      validator: serverUrlValidator,
                      onSaved: (newValue) =>
                          resultRef.value.serverUrl = Uri.parse(newValue!),
                    ),
                    ElevatedButton(
                      onPressed: () =>
                          _submit(context, formKey.value.currentState!),
                      child: Text(context.strings.login_page_login_button),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? Function(String?) _useServerUrl(
    BuildContext context,
    WidgetRef ref,
    TextEditingController defaultServerUrlController,
    ValueNotifier<bool> useDefaultServer,
  ) {
    final serverUrlData = ref.watch(etebaseDefaultServerUrlProvider);

    useEffect(
      () {
        final serverUrl = serverUrlData.value;
        if (serverUrl != null) {
          defaultServerUrlController.text = serverUrlData.value.toString();
        }

        return null;
      },
      [serverUrlData.value],
    );

    return useCallback(
      // ignore: avoid_types_on_closure_parameters
      (String? serverUrl) => useDefaultServer.value && serverUrlData.hasError
          ? serverUrlData.error.toString()
          : _validateNotEmpty(context, serverUrl),
      [context, useDefaultServer.value, serverUrlData],
    );
  }

  String? _validateNotEmpty(BuildContext context, String? value) =>
      (value?.isEmpty ?? true)
          ? context.strings.login_page_validator_not_empty
          : null;

  void _submit(BuildContext context, FormState form) {
    final sm = ScaffoldMessenger.of(context);
    if (!form.validate()) {
      sm.showSnackBar(
        SnackBar(
          backgroundColor: context.theme.colorScheme.error,
          content: Text(
            'TODO',
            style: TextStyle(color: context.theme.colorScheme.onError),
          ),
        ),
      );
      return;
    }

    form.save();
    // TODO process data
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('redirectTo', redirectTo));
  }
}
