import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/melo_button.dart';
import '../data/mock_auth_repository.dart';
import '../../../core/widgets/form_step_scaffold.dart';

enum OtpChannel { sms, email }

/// Arguments passed to the OTP route via GoRouter `extra`.
class OtpArgs {
  const OtpArgs({required this.destination, required this.channel});

  final String destination;
  final OtpChannel channel;
}

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.args});

  static const codeLength = 6;
  static const resendCooldown = 30;

  final OtpArgs args;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  bool _verifying = false;
  bool _resending = false;
  String? _error;
  int _secondsLeft = OtpScreen.resendCooldown;
  Timer? _timer;

  bool get _complete => _controller.text.length == OtpScreen.codeLength;

  @override
  void initState() {
    super.initState();
    _startCooldown();
    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged() {
    // Keep an error visible after the field is cleared; drop it once the
    // user starts typing again.
    setState(() {
      if (_controller.text.isNotEmpty) _error = null;
    });
    if (_complete && !_verifying) _verify();
  }

  void _startCooldown() {
    _timer?.cancel();
    setState(() => _secondsLeft = OtpScreen.resendCooldown);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) timer.cancel();
      setState(() => _secondsLeft--);
    });
  }

  Future<void> _verify() async {
    if (!_complete) return;
    setState(() => _verifying = true);
    try {
      await authRepository.verifyCode(
        widget.args.destination,
        _controller.text,
      );
      if (!mounted) return;
      _focusNode.unfocus();
      // Replace the auth stack: back from profile setup shouldn't return here.
      context.go(AppRoutes.setupBasics);
    } on AuthException catch (e) {
      if (!mounted) return;
      _controller.clear();
      setState(() {
        _error = e.message;
        _verifying = false;
      });
      // The field is disabled while verifying; refocus once it has been
      // rebuilt as enabled so the keyboard comes straight back.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNode.requestFocus();
      });
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  Future<void> _resend() async {
    setState(() => _resending = true);
    try {
      await authRepository.sendCode(widget.args.destination);
      if (!mounted) return;
      _controller.clear();
      _startCooldown();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('New code sent to ${widget.args.destination}')),
      );
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final via = widget.args.channel == OtpChannel.sms ? 'texted' : 'emailed';

    return FormStepScaffold(
      title: 'Enter your code',
      subtitle: Text.rich(
        TextSpan(
          text: 'We $via a 6-digit code to ',
          children: [
            TextSpan(
              text: widget.args.destination,
              style: const TextStyle(
                color: AppColors.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
            const TextSpan(text: '.'),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CodeField(
            controller: _controller,
            focusNode: _focusNode,
            hasError: _error != null,
            enabled: !_verifying,
          ),
          AnimatedSize(
            duration: AppMotion.fast,
            child: _error == null
                ? const SizedBox(width: double.infinity)
                : Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: Text(
                      _error!,
                      style: text.bodySmall?.copyWith(color: AppColors.error),
                    ),
                  ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Text("Didn't get it?", style: text.bodyMedium),
              if (_secondsLeft > 0)
                Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.xs),
                  child: Text(
                    'Resend in 0:${_secondsLeft.toString().padLeft(2, '0')}',
                    style: text.bodyMedium?.copyWith(
                      color: AppColors.inkSubtle,
                    ),
                  ),
                )
              else
                MeloButton.text(
                  label: _resending ? 'Sending…' : 'Resend code',
                  onPressed: _resending || _verifying ? null : _resend,
                ),
            ],
          ),
          if (kDebugMode) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              'Demo: any code works except ${MockAuthRepository.failingCode}.',
              style: text.bodySmall?.copyWith(color: AppColors.inkSubtle),
            ),
          ],
        ],
      ),
      action: MeloButton(
        label: 'Verify',
        isLoading: _verifying,
        onPressed: _complete ? _verify : null,
      ),
    );
  }
}

/// Six visual boxes backed by a single invisible text field, so paste,
/// SMS autofill and backspace all behave natively.
class _CodeField extends StatelessWidget {
  const _CodeField({
    required this.controller,
    required this.focusNode,
    required this.hasError,
    required this.enabled,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasError;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListenableBuilder(
          listenable: Listenable.merge([controller, focusNode]),
          builder: (context, _) {
            final code = controller.text;
            return Row(
              children: [
                for (var i = 0; i < OtpScreen.codeLength; i++) ...[
                  if (i > 0) const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: _CodeBox(
                      digit: i < code.length ? code[i] : null,
                      active:
                          focusNode.hasFocus &&
                          (i == code.length ||
                              (i == OtpScreen.codeLength - 1 &&
                                  code.length == OtpScreen.codeLength)),
                      hasError: hasError,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
        Positioned.fill(
          child: Opacity(
            opacity: 0,
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: true,
              enabled: enabled,
              keyboardType: TextInputType.number,
              autofillHints: const [AutofillHints.oneTimeCode],
              showCursor: false,
              enableInteractiveSelection: false,
              maxLength: OtpScreen.codeLength,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                filled: false,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CodeBox extends StatelessWidget {
  const _CodeBox({
    required this.digit,
    required this.active,
    required this.hasError,
  });

  final String? digit;
  final bool active;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final borderColor = hasError
        ? AppColors.error
        : active
        ? AppColors.plum
        : AppColors.border;
    return AnimatedContainer(
      duration: AppMotion.fast,
      height: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.input,
        border: Border.all(color: borderColor, width: active ? 1.5 : 1),
      ),
      child: Text(
        digit ?? '',
        style: const TextStyle(
          fontFamily: AppTypography.display,
          fontWeight: FontWeight.w600,
          fontSize: 26,
          color: AppColors.ink,
        ),
      ),
    );
  }
}
