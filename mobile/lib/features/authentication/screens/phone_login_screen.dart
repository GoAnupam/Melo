import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/melo_button.dart';
import '../data/mock_auth_repository.dart';
import '../models/country_code.dart';
import '../../../core/widgets/form_step_scaffold.dart';
import 'otp_screen.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _controller = TextEditingController();
  CountryCode _country = CountryCode.india;
  String? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      // Clear the error as soon as the user edits; rebuild for button state.
      setState(() => _error = null);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickCountry() async {
    final picked = await showModalBottomSheet<CountryCode>(
      context: context,
      backgroundColor: AppColors.ivory,
      showDragHandle: true,
      builder: (context) => _CountrySheet(selected: _country),
    );
    if (picked != null && picked != _country) {
      setState(() => _country = picked);
    }
  }

  Future<void> _submit() async {
    final digits = _controller.text;
    if (!_country.isValidNumber(digits)) {
      setState(() {
        _error = _country.minDigits == _country.maxDigits
            ? 'Enter a ${_country.minDigits}-digit mobile number.'
            : 'Enter a valid mobile number.';
      });
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    final destination = '${_country.dialCode} $digits';
    try {
      await authRepository.sendCode(destination);
      if (!mounted) return;
      context.push(
        AppRoutes.otp,
        extra: OtpArgs(destination: destination, channel: OtpChannel.sms),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = "We couldn't send a code. Please try again.");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return FormStepScaffold(
      title: "What's your number?",
      subtitle: const Text(
        "We'll text you a code to confirm it's you. "
        'Your number is never shown on your profile.',
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            color: AppColors.surface,
            shape: const RoundedRectangleBorder(
              borderRadius: AppRadii.input,
              side: BorderSide(color: AppColors.border),
            ),
            child: InkWell(
              onTap: _loading ? null : _pickCountry,
              customBorder: const RoundedRectangleBorder(
                borderRadius: AppRadii.input,
              ),
              child: SizedBox(
                height: 58,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      Text(_country.flag, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 6),
                      Text(_country.dialCode, style: text.titleMedium),
                      const Icon(
                        Icons.expand_more_rounded,
                        color: AppColors.inkMuted,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: true,
              enabled: !_loading,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.telephoneNumberNational],
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(_country.maxDigits),
              ],
              style: text.titleMedium?.copyWith(letterSpacing: 1),
              decoration: InputDecoration(
                hintText: 'Mobile number',
                errorText: _error,
                errorMaxLines: 2,
              ),
              onSubmitted: (_) => _submit(),
            ),
          ),
        ],
      ),
      action: MeloButton(
        label: 'Send code',
        isLoading: _loading,
        onPressed: _controller.text.isEmpty ? null : _submit,
      ),
      footer: MeloButton.text(
        label: 'Use email instead',
        onPressed: _loading
            ? null
            : () => context.pushReplacement(AppRoutes.emailLogin),
      ),
    );
  }
}

class _CountrySheet extends StatelessWidget {
  const _CountrySheet({required this.selected});

  final CountryCode selected;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenH,
              0,
              AppSpacing.screenH,
              AppSpacing.sm,
            ),
            child: Text('Country', style: text.headlineSmall),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final c in CountryCode.supported)
                  ListTile(
                    contentPadding: AppSpacing.screenPadding,
                    leading: Text(c.flag, style: const TextStyle(fontSize: 22)),
                    title: Text(c.name, style: text.titleMedium),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(c.dialCode, style: text.bodyMedium),
                        if (c == selected) ...[
                          const SizedBox(width: AppSpacing.sm),
                          const Icon(
                            Icons.check_rounded,
                            color: AppColors.plum,
                          ),
                        ],
                      ],
                    ),
                    onTap: () => Navigator.of(context).pop(c),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
