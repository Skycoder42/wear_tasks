import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../localization/error_localizer.dart';
import '../widgets/error_snack_bar.dart';

extension WidgetRefX on WidgetRef {
  void listenForErrors<T>(
    BuildContext context,
    ProviderListenable<AsyncValue<T>> provider,
  ) =>
      listen(
        provider.select((value) => value.error),
        (_, error) {
          if (error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              ErrorSnackBar(
                context: context,
                content: Text(read(errorLocalizerProvider).localize(error)),
              ),
            );
          }
        },
      );
}
