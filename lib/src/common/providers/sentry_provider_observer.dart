import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract interface class ErrorState {
  Object get error;
  StackTrace get stackTrace;
}

class SentryProviderObserver extends ProviderObserver {
  const SentryProviderObserver();

  @override
  void didAddProvider(
    ProviderBase provider,
    Object? value,
    ProviderContainer container,
  ) {
    _logUpdate('didAddProvider', provider);
    _maybeReportStateException(provider, value);
  }

  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    _logUpdate('didUpdateProvider', provider);
    _maybeReportStateException(provider, newValue);
  }

  @override
  void didDisposeProvider(
    ProviderBase provider,
    ProviderContainer container,
  ) {
    _logUpdate('didDisposeProvider', provider);
  }

  @override
  void providerDidFail(
    ProviderBase provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    _logUpdate('providerDidFail', provider);
    _reportException(provider, error, stackTrace);
  }

  void _maybeReportStateException(ProviderBase provider, Object? value) {
    switch (value) {
      case AsyncError(error: final error, stackTrace: final stackTrace):
        _reportException(provider, error, stackTrace);
      case ErrorState(error: final error, stackTrace: final stackTrace):
        _reportException(provider, error, stackTrace);
    }
  }

  void _reportException(
    ProviderBase provider,
    Object error,
    StackTrace stackTrace,
  ) =>
      unawaited(
        Sentry.captureException(
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
        ),
      );

  List<String>? _familyTree(ProviderOrFamily provider) {
    if (provider.from case final Family from) {
      return [...?_familyTree(from), from.name ?? '<unnamed>'];
    }
    return null;
  }

  List<String?>? _toList(Iterable<ProviderOrFamily>? providers) =>
      providers?.map((p) => p.name).toList();

  void _logUpdate(String message, ProviderBase provider) => unawaited(
        Sentry.addBreadcrumb(
          Breadcrumb(
            message: '$message($provider)',
            type: 'providers',
            category: 'providers',
          ),
        ),
      );
}
