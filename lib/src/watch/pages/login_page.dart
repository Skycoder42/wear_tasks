import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../common/localization/localization.dart';

class LoginPage extends HookConsumerWidget {
  final String? redirectTo;

  const LoginPage({
    super.key,
    this.redirectTo,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
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
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          alignLabelWithHint: true,
                          label:
                              Text(context.strings.login_page_username_label),
                        ),
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          alignLabelWithHint: true,
                          label:
                              Text(context.strings.login_page_password_label),
                        ),
                        obscureText: true,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          alignLabelWithHint: true,
                          label: Text(
                            context.strings.login_page_server_url_label,
                          ),
                        ),
                        keyboardType: TextInputType.url,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('redirectTo', redirectTo));
  }
}
