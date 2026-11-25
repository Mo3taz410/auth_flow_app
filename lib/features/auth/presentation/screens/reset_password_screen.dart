import 'package:auth_flow_app/core/di/injection_container.dart';
import 'package:auth_flow_app/features/auth/presentation/bloc/email_auth/email_auth_bloc.dart';
import 'package:auth_flow_app/features/auth/presentation/bloc/email_auth/email_auth_event.dart';
import 'package:auth_flow_app/features/auth/presentation/bloc/email_auth/email_auth_state.dart';
import 'package:auth_flow_app/features/auth/presentation/components/request_reset_email_form.dart';
import 'package:auth_flow_app/features/auth/presentation/components/update_password_form.dart';
import 'package:auth_flow_app/features/auth/presentation/components/verify_otp_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => sl<EmailAuthBloc>(), child: const ResetPasswordView());
  }
}

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({super.key});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  int _currentStep = 0;

  final _step1FormKey = GlobalKey<FormState>();
  final _step3FormKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSendCodePressed() {
    if (_step1FormKey.currentState!.validate()) {
      context.read<EmailAuthBloc>().add(ResetPasswordEvent(email: _emailController.text.trim()));
    }
  }

  void _onVerifyOtpPressed() {
    if (_otpController.text.trim().length == 6) {
      context.read<EmailAuthBloc>().add(
        VerifyOtpEvent(email: _emailController.text.trim(), otp: _otpController.text.trim()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit OTP code'), backgroundColor: Colors.orange),
      );
    }
  }

  void _onUpdatePasswordPressed() {
    if (_step3FormKey.currentState!.validate()) {
      context.read<EmailAuthBloc>().add(UpdatePasswordEvent(password: _passwordController.text));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_getAppBarTitle())),
      body: BlocListener<EmailAuthBloc, EmailAuthState>(
        listener: (context, state) {
          if (state is EmailAuthError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
          } else if (state is EmailSent) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
            setState(() {
              _currentStep = 1;
            });
          } else if (state is PasswordOtpVerified) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('OTP code verified successfully'), backgroundColor: Colors.green),
            );
            setState(() {
              _currentStep = 2;
            });
          } else if (state is PasswordUpdated) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.green));
            Navigator.of(context).pushReplacementNamed('/login');
          }
        },
        child: BlocBuilder<EmailAuthBloc, EmailAuthState>(
          builder: (context, state) {
            if (state is EmailAuthLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(padding: const EdgeInsets.all(24.0), child: _buildCurrentStepWidget());
          },
        ),
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_currentStep) {
      case 0:
        return 'Reset Password';
      case 1:
        return 'Verify OTP';
      case 2:
        return 'New Password';
      default:
        return 'Reset Password';
    }
  }

  Widget _buildCurrentStepWidget() {
    switch (_currentStep) {
      case 0:
        return RequestResetEmailForm(
          formKey: _step1FormKey,
          emailController: _emailController,
          onSendCodePressed: _onSendCodePressed,
        );
      case 1:
        return VerifyOtpForm(
          email: _emailController.text,
          otpController: _otpController,
          onVerifyOtpPressed: _onVerifyOtpPressed,
          onChangeEmailPressed: () {
            setState(() {
              _currentStep = 0;
            });
          },
        );
      case 2:
        return UpdatePasswordForm(
          formKey: _step3FormKey,
          passwordController: _passwordController,
          confirmPasswordController: _confirmPasswordController,
          onUpdatePasswordPressed: _onUpdatePasswordPressed,
        );
      default:
        return RequestResetEmailForm(
          formKey: _step1FormKey,
          emailController: _emailController,
          onSendCodePressed: _onSendCodePressed,
        );
    }
  }
}
