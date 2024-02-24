import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class SentryProviderObserver extends ProviderObserver {
  const SentryProviderObserver();

  @override
  Future<void> providerDidFail(
    ProviderBase provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) async {
    await Sentry.captureException(
      error,
      stackTrace: stackTrace,
      withScope: (scope) async => Future.wait([
        if (provider.name case final String name)
          scope.setTag('provider', name),
        scope.setContexts('Provider', {
          'identifier': provider.toString(),
          'name': provider.name,
          'providerType': provider.runtimeType.toString(),
          'argument': provider.argument?.toString(),
          'familyTree': _familyTree(provider),
          'dependencies': _toList(provider.dependencies),
          'allTransitiveDependencies':
              _toList(provider.allTransitiveDependencies),
        }),
      ]),
    );
  }

  List<String>? _familyTree(ProviderOrFamily provider) {
    if (provider.from case final Family from) {
      return [...?_familyTree(from), from.name ?? '<unnamed>'];
    }
    return null;
  }

  List<String?>? _toList(Iterable<ProviderOrFamily>? providers) =>
      providers?.map((p) => p.name).toList();
}
