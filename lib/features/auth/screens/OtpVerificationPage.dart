import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:provider/provider.dart';
import 'package:sahtek/core/widgets/buttons.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:sahtek/features/auth/controllers/otp_controller.dart';

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({super.key});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  static const int otpLength = 6; // changed to 6 to match backend
  static const int initialSeconds = 59;

  String _otpCode = '';
  int _remainingSeconds = initialSeconds;
  Timer? _timer;
  String? userId; // received from signin page
  String? email; // 👈 add this to store email for resending OTP

  bool get _canVerify => _otpCode.length == otpLength;
  bool get _canResend => _remainingSeconds == 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    userId = args?['userId'];
    email = args?['email'];
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _remainingSeconds = initialSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() => _remainingSeconds = 0);
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  String _formatTimer(int seconds) {
    return seconds.toString().padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF2F6FED);
    const textGray = Color(0xFF8B97A8);
    final otpController = Provider.of<OtpController>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text(
                'otp_verification_title'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1D2433),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'otp_verification_subtitle'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: textGray),
              ),
              const SizedBox(height: 28),

              OtpTextField(
                numberOfFields: otpLength,
                borderColor: const Color(0xFFE2E8F0),
                focusedBorderColor: primaryBlue,
                enabledBorderColor: const Color(0xFFE2E8F0),
                showFieldAsBox: true,
                borderRadius: BorderRadius.circular(10),
                fieldWidth: 45,
                filled: true,
                fillColor: const Color(0xFFF7F9FC),
                onCodeChanged: (code) {
                  setState(() => _otpCode = code.trim());
                },
                onSubmit: (verificationCode) {
                  setState(() => _otpCode = verificationCode.trim());
                  if (_canVerify && userId != null) {
                    otpController.verifyOtp(
                      userId: userId!,
                      code: verificationCode,
                      context: context,
                    );
                  }
                },
              ),

              const SizedBox(height: 14),
              Text(
                _canResend
                    ? 'code_expired'.tr()
                    : 'expires_in'.tr(
                        namedArgs: {'seconds': _formatTimer(_remainingSeconds)},
                      ),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: textGray),
              ),

              // show error if any
              if (otpController.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    otpController.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),

              const Spacer(),

              otpController.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : buttonC(
                      'verify_button'.tr(),
                      _canVerify && userId != null
                          ? () => otpController.verifyOtp(
                              userId: userId!,
                              code: _otpCode,
                              context: context,
                            )
                          : () {},
                    ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'no_code_received'.tr(),
                    style: const TextStyle(fontSize: 12, color: textGray),
                  ),
                  InkWell(
                    onTap: _canResend && !otpController.isResending
                        ? () {
                            _startTimer();
                            otpController.resendOtp(
                              userId: userId!,
                              email: email!, // 👈 add this
                              context: context,
                            );
                          }
                        : null,
                    child: otpController.isResending
                        ? const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            'resend_code'.tr(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _canResend
                                  ? primaryBlue
                                  : const Color(0xFFB0B9C6),
                            ),
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
