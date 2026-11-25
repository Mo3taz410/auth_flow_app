import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class VerifyOtpForm extends StatelessWidget {
  final String email;
  final TextEditingController otpController;
  final VoidCallback onVerifyOtpPressed;
  final VoidCallback onChangeEmailPressed;

  const VerifyOtpForm({
    super.key,
    required this.email,
    required this.otpController,
    required this.onVerifyOtpPressed,
    required this.onChangeEmailPressed,
  });

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 50,
      height: 56,
      textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blueAccent),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        const Text('Step 2 of 3: Verify OTP', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Please enter the 6-digit code sent to $email.', style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 32),
        Center(
          child: Pinput(
            length: 6,
            controller: otpController,
            defaultPinTheme: defaultPinTheme,
            focusedPinTheme: defaultPinTheme.copyWith(
              decoration: defaultPinTheme.decoration?.copyWith(border: Border.all(color: Colors.blue, width: 2)),
            ),
            onCompleted: (_) => onVerifyOtpPressed(),
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: onVerifyOtpPressed,
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          child: const Text('Verify Code'),
        ),
        const SizedBox(height: 12),
        TextButton(onPressed: onChangeEmailPressed, child: const Text('Change Email')),
      ],
    );
  }
}
