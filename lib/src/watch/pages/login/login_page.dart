import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../common/localization/localization.dart';
import '../../../common/providers/etebase_provider.dart';
import '../../../common/widgets/error_snack_bar.dart';
import '../../../common/widgets/success_snack_bar.dart';
import '../../widgets/checkbox_form_field.dart';
import '../../widgets/watch_scaffold.dart';
import 'login_controller.dart';

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
    final formKey = useState(GlobalKey<FormState>()).value;
    final formState = formKey.currentState;
    final customServerUrlController = useTextEditingController();

    final (
      useDefaultServer,
      defaultServerUrl,
      serverUrlErrorValidator,
    ) = _useServerUrl(context, ref);

    final resultRef = useRef(_LoginInfo());
    final loginState = ref.watch(loginControllerProvider);

    ref.listen(
      loginControllerProvider,
      (_, next) {
        switch (next) {
          case LoggedInState():
            ScaffoldMessenger.of(context).showSnackBar(
              SuccessSnackBar(
                context: context,
                content: Text(context.strings.login_page_succeeded),
              ),
            );
          case LoginFailedState(reason: final reason):
            ScaffoldMessenger.of(context).showSnackBar(
              ErrorSnackBar(
                context: context,
                content: Text(reason),
              ),
            );
          default:
            break;
        }
      },
    );

    return WatchScaffold(
      title: Text(context.strings.login_page_title),
      loadingOverlayActive: loginState is LoggingInState,
      body: SafeArea(
        top: false,
        left: false,
        right: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                TextFormField(
                  enabled: loginState.canLogin,
                  decoration: InputDecoration(
                    alignLabelWithHint: true,
                    label: Text(context.strings.login_page_username_label),
                  ),
                  validator: (value) => _validateNotNullOrEmpty(context, value),
                  onSaved: (newValue) => resultRef.value.username = newValue!,
                ),
                TextFormField(
                  enabled: loginState.canLogin,
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
                  enabled: loginState.canLogin,
                  title: Text(
                    context.strings.login_page_use_default_url_label,
                  ),
                  subtitle:
                      defaultServerUrl != null ? Text(defaultServerUrl) : null,
                  initialValue: useDefaultServer.value,
                  onChanged: (v) => useDefaultServer.value = v ?? true,
                  validator: serverUrlErrorValidator,
                  onSaved: (newValue) =>
                      resultRef.value.useDefaultServer = newValue!,
                ),
                if (!useDefaultServer.value)
                  TextFormField(
                    enabled: loginState.canLogin,
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
                  onPressed: formState != null && loginState.canLogin
                      ? () async => _submit(context, ref, formState, resultRef)
                      : null,
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
        return (
          useDefaultServer,
          null,
          (active) => (active ?? true) ? error.toString() : null
        );
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

  Future<void> _submit(
    BuildContext context,
    WidgetRef ref,
    FormState form,
    ObjectRef<_LoginInfo> loginInfo,
  ) async {
    if (!form.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        ErrorSnackBar(
          context: context,
          content: Text(context.strings.login_page_invalid),
        ),
      );
      return;
    }

    form.save();

    final result = loginInfo.value;
    await ref.read(loginControllerProvider.notifier).login(
          result.username,
          result.password,
          result.useDefaultServer ? null : result.customServerUrl,
        );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('redirectTo', redirectTo));
  }
}
