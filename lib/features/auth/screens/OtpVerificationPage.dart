// Redesigned following SAHTECK brand guidelines
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:iconsax/iconsax.dart';
import 'package:sahtek/features/auth/controllers/otp_controller.dart';

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({super.key});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage>
    with SingleTickerProviderStateMixin {
  static const int otpLength = 6;
  static const int initialSeconds = 59;

  static const _primaryBlue = Color(0xFF0052FF);
  static const _gradientEnd = Color(0xFF00A3FF);
  static const _background = Color(0xFFF8FAFF);
  static const _surface = Color(0xFFFFFFFF);
  static const _textPrimary = Color(0xFF0A0F1E);
  static const _textGray = Color(0xFF64748B);

  String _otpCode = '';
  int _remainingSeconds = initialSeconds;
  Timer? _timer;
  String? userId;
  String? email;
  String _otpType = 'EMAIL_VERIFICATION';

  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  bool get _canVerify => _otpCode.length == otpLength;
  bool get _canResend => _remainingSeconds == 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    userId = args?['userId'];
    email = args?['email'];
    _otpType = args?['type'] ?? 'EMAIL_VERIFICATION';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _remainingSeconds = initialSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() => _remainingSeconds = 0);
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  String _formatTimer(int seconds) {
    return '00:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final otpController = Provider.of<OtpController>(context);

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _background,
        foregroundColor: _textPrimary,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, size: 20),
          onPressed: () => Navigator.of(context).pop(),
          splashRadius: 22,
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.sizeOf(context).height -
                      MediaQuery.paddingOf(context).vertical -
                      kToolbarHeight -
                      24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),

                    // ── Hero Icon ──────────────────────────────────────────
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [_primaryBlue, _gradientEnd],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _primaryBlue.withValues(alpha: 0.28),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Iconsax.shield_tick,
                          size: 36,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Title ──────────────────────────────────────────────
                    Text(
                      'otp_verification_title'.tr(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'otp_verification_subtitle'.tr(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: _textGray,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Email Badge ────────────────────────────────────────
                    if (email != null)
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: _primaryBlue.withValues(alpha: 0.18),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Iconsax.sms,
                                size: 16,
                                color: _primaryBlue,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  email!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _primaryBlue,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

                    // ── OTP Card ───────────────────────────────────────────
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                      decoration: BoxDecoration(
                        color: _surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: _primaryBlue.withValues(alpha: 0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final availableWidth = constraints.maxWidth;
                              final fieldWidth =
                                  ((availableWidth - otpLength * 8) /
                                          otpLength)
                                      .clamp(32.0, 46.0)
                                      .toDouble();

                              return Center(
                                child: OtpTextField(
                                  numberOfFields: otpLength,
                                  borderColor: const Color(0xFFE2E8F0),
                                  focusedBorderColor: _primaryBlue,
                                  enabledBorderColor: const Color(0xFFE2E8F0),
                                  showFieldAsBox: true,
                                  borderRadius: BorderRadius.circular(10),
                                  fieldWidth: fieldWidth,
                                  filled: true,
                                  fillColor: const Color(0xFFF1F5F9),
                                  textStyle: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: _textPrimary,
                                  ),
                                  onCodeChanged: (code) {
                                    setState(() => _otpCode = code.trim());
                                  },
                                  onSubmit: (verificationCode) {
                                    setState(
                                      () => _otpCode = verificationCode.trim(),
                                    );
                                    if (_canVerify && userId != null) {
                                      otpController.verifyOtp(
                                        userId: userId!,
                                        code: verificationCode,
                                        type: _otpType,
                                        context: context,
                                      );
                                    }
                                  },
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 16),

                          // ── Timer Badge ────────────────────────────────
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: _canResend
                                  ? const Color(0xFFFEF2F2)
                                  : const Color(0xFFF8FAFF),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _canResend
                                    ? const Color(0xFFEF4444).withValues(alpha: 0.2)
                                    : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Iconsax.timer_1,
                                  size: 14,
                                  color: _canResend
                                      ? const Color(0xFFEF4444)
                                      : _textGray,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _canResend
                                      ? 'code_expired'.tr()
                                      : 'expires_in'.tr(
                                          namedArgs: {
                                            'seconds': _formatTimer(
                                              _remainingSeconds,
                                            ),
                                          },
                                        ),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: _canResend
                                        ? const Color(0xFFEF4444)
                                        : _textGray,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Error Banner ───────────────────────────────────────
                    if (otpController.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 1),
                                child: Icon(
                                  Iconsax.close_circle,
                                  size: 16,
                                  color: Color(0xFFEF4444),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  otpController.errorMessage!,
                                  style: const TextStyle(
                                    color: Color(0xFFEF4444),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

                    // ── Verify Button ──────────────────────────────────────
                    otpController.isLoading
                        ? const Center(
                            child: SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(
                                  _primaryBlue,
                                ),
                                strokeWidth: 3,
                              ),
                            ),
                          )
                        : _PrimaryButton(
                            text: 'verify_button'.tr(),
                            enabled: _canVerify && userId != null,
                            onTap: _canVerify && userId != null
                                ? () => otpController.verifyOtp(
                                      userId: userId!,
                                      code: _otpCode,
                                      type: _otpType,
                                      context: context,
                                    )
                                : null,
                          ),

                    const SizedBox(height: 20),

                    // ── Resend Row ─────────────────────────────────────────
                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 4,
                        children: [
                          Text(
                            'no_code_received'.tr(),
                            style: const TextStyle(
                              fontSize: 13,
                              color: _textGray,
                            ),
                          ),
                          GestureDetector(
                            onTap: _canResend && !otpController.isResending
                                ? () {
                                    _startTimer();
                                    otpController.resendOtp(
                                      userId: userId!,
                                      email: email!,
                                      type: _otpType,
                                      context: context,
                                    );
                                  }
                                : null,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 200),
                              opacity: _canResend && !otpController.isResending
                                  ? 1.0
                                  : 0.45,
                              child: otpController.isResending
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation(
                                          _primaryBlue,
                                        ),
                                      ),
                                    )
                                  : Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Iconsax.refresh,
                                          size: 13,
                                          color: _canResend
                                              ? _primaryBlue
                                              : const Color(0xFFB0B9C6),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'resend_code'.tr(),
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: _canResend
                                                ? _primaryBlue
                                                : const Color(0xFFB0B9C6),
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Primary CTA Button ─────────────────────────────────────────────────────────
class _PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool enabled;

  static const _primaryBlue = Color(0xFF0052FF);
  static const _gradientEnd = Color(0xFF00A3FF);

  const _PrimaryButton({
    super.key,
    required this.text,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        decoration: BoxDecoration(
          gradient: enabled
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_primaryBlue, _gradientEnd],
                )
              : null,
          color: enabled ? null : const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(24),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: _primaryBlue.withValues(alpha: 0.22),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
          border: enabled
              ? null
              : Border.all(color: const Color(0xFFE6EAF2)),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: enabled ? Colors.white : const Color(0xFF64748B),
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
