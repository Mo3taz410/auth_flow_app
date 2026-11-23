import 'package:equatable/equatable.dart';

abstract class EmailAuthEvent extends Equatable {
  const EmailAuthEvent();

  @override
  List<Object?> get props => [];
}

class SignUpWithEmailEvent extends EmailAuthEvent {
  final String email;
  final String password;
  final String displayName;

  const SignUpWithEmailEvent({required this.email, required this.password, required this.displayName});

  @override
  List<Object?> get props => [email, password, displayName];
}

class SignInWithEmailEvent extends EmailAuthEvent {
  final String email;
  final String password;

  const SignInWithEmailEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class ResetPasswordEvent extends EmailAuthEvent {
  final String email;

  const ResetPasswordEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

class SendMagicLinkEvent extends EmailAuthEvent {
  final String email;

  const SendMagicLinkEvent({required this.email});

  @override
  List<Object?> get props => [email];
}
