// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'login_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$LoginState {}

/// @nodoc
abstract class $LoginStateCopyWith<$Res> {
  factory $LoginStateCopyWith(
          LoginState value, $Res Function(LoginState) then) =
      _$LoginStateCopyWithImpl<$Res, LoginState>;
}

/// @nodoc
class _$LoginStateCopyWithImpl<$Res, $Val extends LoginState>
    implements $LoginStateCopyWith<$Res> {
  _$LoginStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$LoggedOutStateImplCopyWith<$Res> {
  factory _$$LoggedOutStateImplCopyWith(_$LoggedOutStateImpl value,
          $Res Function(_$LoggedOutStateImpl) then) =
      __$$LoggedOutStateImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoggedOutStateImplCopyWithImpl<$Res>
    extends _$LoginStateCopyWithImpl<$Res, _$LoggedOutStateImpl>
    implements _$$LoggedOutStateImplCopyWith<$Res> {
  __$$LoggedOutStateImplCopyWithImpl(
      _$LoggedOutStateImpl _value, $Res Function(_$LoggedOutStateImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$LoggedOutStateImpl extends LoggedOutState with DiagnosticableTreeMixin {
  const _$LoggedOutStateImpl() : super._();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'LoginState.loggedOut()';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('type', 'LoginState.loggedOut'));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoggedOutStateImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;
}

abstract class LoggedOutState extends LoginState {
  const factory LoggedOutState() = _$LoggedOutStateImpl;
  const LoggedOutState._() : super._();
}

/// @nodoc
abstract class _$$LoggingInStateImplCopyWith<$Res> {
  factory _$$LoggingInStateImplCopyWith(_$LoggingInStateImpl value,
          $Res Function(_$LoggingInStateImpl) then) =
      __$$LoggingInStateImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoggingInStateImplCopyWithImpl<$Res>
    extends _$LoginStateCopyWithImpl<$Res, _$LoggingInStateImpl>
    implements _$$LoggingInStateImplCopyWith<$Res> {
  __$$LoggingInStateImplCopyWithImpl(
      _$LoggingInStateImpl _value, $Res Function(_$LoggingInStateImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$LoggingInStateImpl extends LoggingInState with DiagnosticableTreeMixin {
  const _$LoggingInStateImpl() : super._();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'LoginState.loggingIn()';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('type', 'LoginState.loggingIn'));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoggingInStateImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;
}

abstract class LoggingInState extends LoginState {
  const factory LoggingInState() = _$LoggingInStateImpl;
  const LoggingInState._() : super._();
}

/// @nodoc
abstract class _$$LoggedInStateImplCopyWith<$Res> {
  factory _$$LoggedInStateImplCopyWith(
          _$LoggedInStateImpl value, $Res Function(_$LoggedInStateImpl) then) =
      __$$LoggedInStateImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoggedInStateImplCopyWithImpl<$Res>
    extends _$LoginStateCopyWithImpl<$Res, _$LoggedInStateImpl>
    implements _$$LoggedInStateImplCopyWith<$Res> {
  __$$LoggedInStateImplCopyWithImpl(
      _$LoggedInStateImpl _value, $Res Function(_$LoggedInStateImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$LoggedInStateImpl extends LoggedInState with DiagnosticableTreeMixin {
  const _$LoggedInStateImpl() : super._();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'LoginState.loggedIn()';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('type', 'LoginState.loggedIn'));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoggedInStateImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;
}

abstract class LoggedInState extends LoginState {
  const factory LoggedInState() = _$LoggedInStateImpl;
  const LoggedInState._() : super._();
}

/// @nodoc
abstract class _$$LoginFailedStateImplCopyWith<$Res> {
  factory _$$LoginFailedStateImplCopyWith(_$LoginFailedStateImpl value,
          $Res Function(_$LoginFailedStateImpl) then) =
      __$$LoginFailedStateImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String reason});
}

/// @nodoc
class __$$LoginFailedStateImplCopyWithImpl<$Res>
    extends _$LoginStateCopyWithImpl<$Res, _$LoginFailedStateImpl>
    implements _$$LoginFailedStateImplCopyWith<$Res> {
  __$$LoginFailedStateImplCopyWithImpl(_$LoginFailedStateImpl _value,
      $Res Function(_$LoginFailedStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? reason = null,
  }) {
    return _then(_$LoginFailedStateImpl(
      null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$LoginFailedStateImpl extends LoginFailedState
    with DiagnosticableTreeMixin {
  const _$LoginFailedStateImpl(this.reason) : super._();

  @override
  final String reason;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'LoginState.loginFailed(reason: $reason)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'LoginState.loginFailed'))
      ..add(DiagnosticsProperty('reason', reason));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoginFailedStateImpl &&
            (identical(other.reason, reason) || other.reason == reason));
  }

  @override
  int get hashCode => Object.hash(runtimeType, reason);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LoginFailedStateImplCopyWith<_$LoginFailedStateImpl> get copyWith =>
      __$$LoginFailedStateImplCopyWithImpl<_$LoginFailedStateImpl>(
          this, _$identity);
}

abstract class LoginFailedState extends LoginState {
  const factory LoginFailedState(final String reason) = _$LoginFailedStateImpl;
  const LoginFailedState._() : super._();

  String get reason;
  @JsonKey(ignore: true)
  _$$LoginFailedStateImplCopyWith<_$LoginFailedStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
