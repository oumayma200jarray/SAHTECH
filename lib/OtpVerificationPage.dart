import 'dart:async';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:sahtek/widgets/buttons.dart';
import 'package:easy_localization/easy_localization.dart';

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({super.key});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  // Configuration OTP
  static const int otpLength = 4;
  static const int initialSeconds = 59;

  // Etat de la page
  String _otpCode = '';
  bool _isVerifying = false;
  int _remainingSeconds = initialSeconds;
  Timer? _timer;

  // Etats dérivés pour activer/désactiver les actions UI
  bool get _canVerify => _otpCode.length == otpLength && !_isVerifying;
  bool get _canResend => _remainingSeconds == 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    // Redémarre le compte à rebours à chaque ouverture/renvoi de code
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

  Future<void> _verifyOtp() async {
    // Evite un appel API invalide (code incomplet ou déjà en cours)
    if (!_canVerify) return;

    setState(() => _isVerifying = true);

    try {
      // TODO: Remplacer par l'appel API réel de vérification OTP
      await Future.delayed(const Duration(milliseconds: 900));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'code_verified_snack'.tr(namedArgs: {'code': _otpCode}),
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('verification_failed_snack'.tr())));
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  Future<void> _resendCode() async {
    if (!_canResend) return;

    // TODO: Remplacer par l'appel API réel de renvoi OTP
    _startTimer();

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('new_code_sent_snack'.tr())));
  }

  String _formatTimer(int seconds) {
    return seconds.toString().padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF2F6FED);
    const textGray = Color(0xFF8B97A8);

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
                // Composant de saisie OTP: 4 cases avec style de la maquette
                numberOfFields: otpLength,
                borderColor: const Color(0xFFE2E8F0),
                focusedBorderColor: primaryBlue,
                enabledBorderColor: const Color(0xFFE2E8F0),
                showFieldAsBox: true,
                borderRadius: BorderRadius.circular(10),
                fieldWidth: 52,
                filled: true,
                fillColor: const Color(0xFFF7F9FC),
                onCodeChanged: (code) {
                  // Mise à jour en temps réel pour activer le bouton Vérifier
                  setState(() => _otpCode = code.trim());
                },
                onSubmit: (verificationCode) {
                  // Soumission automatique quand toutes les cases sont remplies
                  setState(() => _otpCode = verificationCode.trim());
                  _verifyOtp();
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

              const Spacer(),

              // Le bouton est actif uniquement quand le code est complet
              buttonC(
                'verify_button'.tr(),
                () => _canVerify ? _verifyOtp : null,
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
                    // Renvoi disponible seulement après expiration du timer
                    onTap: _canResend ? _resendCode : null,
                    child: Text(
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
            ],
          ),
        ),
      ),
    );
  }
}
