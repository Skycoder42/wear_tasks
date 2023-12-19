import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../common/localization/localization.dart';
import '../../app/watch_theme.dart';
import '../../providers/etebase_provider.dart';
import '../../widgets/checkbox_form_field.dart';
import '../../widgets/watch_scaffold.dart';

class _LoginInfo {
  String username = '';
  String password = '';
  bool useDefaultServer = true;
  Uri customServerUrl = Uri();
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
    final customServerUrlController = useTextEditingController();

    final (
      useDefaultServer,
      serverUrl,
      serverUrlErrorValidator,
    ) = _useServerUrl(context, ref);

    final resultRef = useRef(_LoginInfo());

    return WatchScaffold(
      title: Text(context.strings.login_page_title),
      body: SafeArea(
        top: false,
        left: false,
        right: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Form(
            key: formKey.value,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    alignLabelWithHint: true,
                    label: Text(context.strings.login_page_username_label),
                  ),
                  validator: (value) => _validateNotNullOrEmpty(context, value),
                  onSaved: (newValue) => resultRef.value.username = newValue!,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    alignLabelWithHint: true,
                    label: Text(context.strings.login_page_password_label),
                  ),
                  obscureText: true,
                  autocorrect: false,
                  enableIMEPersonalizedLearning: false,
                  enableSuggestions: false,
                  spellCheckConfiguration:
                      const SpellCheckConfiguration.disabled(),
                  validator: (value) => _validateNotNullOrEmpty(context, value),
                  onSaved: (newValue) => resultRef.value.password = newValue!,
                ),
                const SizedBox(height: 8),
                CheckboxFormField(
                  title: Text(
                    context.strings.login_page_use_default_url_label,
                  ),
                  subtitle: serverUrl != null ? Text(serverUrl) : null,
                  initialValue: useDefaultServer.value,
                  onChanged: (v) => useDefaultServer.value = v ?? true,
                  validator: serverUrlErrorValidator,
                  onSaved: (newValue) =>
                      resultRef.value.useDefaultServer = newValue ?? true,
                ),
                if (!useDefaultServer.value)
                  TextFormField(
                    controller: customServerUrlController,
                    decoration: InputDecoration(
                      alignLabelWithHint: true,
                      label: Text(
                        context.strings.login_page_server_url_label,
                      ),
                    ),
                    keyboardType: TextInputType.url,
                    readOnly: useDefaultServer.value,
                    validator: (v) => _validateHttpUrl(context, v),
                    onSaved: (newValue) =>
                        resultRef.value.customServerUrl = Uri.parse(newValue!),
                  ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => _submit(
                    context,
                    formKey.value.currentState!,
                  ),
                  child: Text(context.strings.login_page_login_button),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  (
    ValueNotifier<bool>,
    String?,
    String? Function(bool?),
  ) _useServerUrl(
    BuildContext context,
    WidgetRef ref,
  ) {
    final useDefaultServer = useState(true);
    final serverUrlData = ref.watch(etebaseDefaultServerUrlProvider);
    switch (serverUrlData) {
      case AsyncData(value: final serverUrl):
        return (useDefaultServer, serverUrl.toString(), (_) => null);
      case AsyncError(error: final error):
        return (useDefaultServer, null, (_) => error.toString());
      default:
        return (useDefaultServer, null, (_) => null);
    }
  }

  String? _validateNotNullOrEmpty(BuildContext context, String? value) =>
      (value?.isEmpty ?? true)
          ? context.strings.login_page_validator_not_empty
          : null;

  String? _validateHttpUrl(BuildContext context, String? value) {
    if (_validateNotNullOrEmpty(context, value) case final String error) {
      return error;
    }

    final url = Uri.tryParse(value!);
    if (url == null || !url.isAbsolute || !url.isScheme('https')) {
      return context.strings.login_page_validator_https_url;
    }

    return null;
  }

  void _submit(
    BuildContext context,
    FormState form,
  ) {
    if (!form.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: context.theme.colorScheme.error,
          content: Text(
            context.strings.login_page_invalid,
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
