import 'dart:async';

import 'package:etebase_flutter/etebase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../common/localization/error_localizer.dart';
import '../../../common/localization/localization.dart';
import '../../../common/providers/etebase_provider.dart';
import '../../../common/widgets/error_snack_bar.dart';
import '../../../common/widgets/success_snack_bar.dart';
import '../../services/account_service.dart';
import '../../widgets/checkbox_form_field.dart';
import '../../widgets/submit_form.dart';
import '../../widgets/watch_scaffold.dart';

class LoginPage extends HookConsumerWidget {
  static const _usernameKey = 'username';
  static const _passwordKey = 'password';
  static const _useDefaultServerKey = 'useDefaultServer';
  static const _customServerUrlKey = 'customServerUrl';

  final String? redirectTo;

  const LoginPage({
    super.key,
    this.redirectTo,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customServerUrlController = useTextEditingController();

    final (
      useDefaultServer,
      defaultServerUrl,
      serverUrlErrorValidator,
    ) = _useServerUrl(context, ref);

    final loginState = ref.watch(accountServiceProvider);
    final formEnabled = switch (loginState) {
      AsyncData(value: null) || AsyncError() => true,
      _ => false,
    };

    ref.listen(
      accountServiceProvider,
      (_, next) {
        switch (next) {
          case AsyncData(value: EtebaseAccount()):
            ScaffoldMessenger.of(context).showSnackBar(
              SuccessSnackBar(
                context: context,
                content: Text(context.strings.login_page_succeeded),
              ),
            );
            context.go(redirectTo ?? '/');
          case AsyncError(error: final error):
            ScaffoldMessenger.of(context).showSnackBar(
              ErrorSnackBar(
                context: context,
                content: Text(ref.read(errorLocalizerProvider).localize(error)),
              ),
            );
          default:
            break;
        }
      },
    );

    return WatchScaffold(
      title: Text(context.strings.login_page_title),
      loadingOverlayActive: loginState is AsyncLoading,
      body: SafeArea(
        top: false,
        left: false,
        right: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SubmitForm(
            onValidationFailed: () =>
                ScaffoldMessenger.of(context).showSnackBar(
              ErrorSnackBar(
                context: context,
                content: Text(context.strings.login_page_invalid),
              ),
            ),
            onSubmit: (result) => unawaited(
              ref.read(accountServiceProvider.notifier).login(
                    result[_usernameKey] as String,
                    result[_passwordKey] as String,
                    result[_useDefaultServerKey] as bool
                        ? null
                        : result[_customServerUrlKey] as Uri,
                  ),
            ),
            builder: (context, onSaved, onSubmit) => Column(
              children: [
                TextFormField(
                  enabled: formEnabled,
                  decoration: InputDecoration(
                    alignLabelWithHint: true,
                    label: Text(context.strings.login_page_username_label),
                  ),
                  validator: (value) => _validateNotNullOrEmpty(context, value),
                  onSaved: (newValue) => onSaved(_usernameKey, newValue),
                ),
                TextFormField(
                  enabled: formEnabled,
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
                  onSaved: (newValue) => onSaved(_passwordKey, newValue),
                ),
                const SizedBox(height: 8),
                CheckboxFormField(
                  enabled: formEnabled,
                  title: Text(
                    context.strings.login_page_use_default_url_label,
                  ),
                  subtitle:
                      defaultServerUrl != null ? Text(defaultServerUrl) : null,
                  initialValue: useDefaultServer.value,
                  onChanged: (v) => useDefaultServer.value = v ?? true,
                  validator: serverUrlErrorValidator,
                  onSaved: (newValue) =>
                      onSaved(_useDefaultServerKey, newValue),
                ),
                if (!useDefaultServer.value)
                  TextFormField(
                    enabled: formEnabled,
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
                        onSaved(_customServerUrlKey, Uri.parse(newValue!)),
                  ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: onSubmit,
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

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('redirectTo', redirectTo));
  }
}
