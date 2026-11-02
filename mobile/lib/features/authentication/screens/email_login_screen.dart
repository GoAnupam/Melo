import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/widgets/melo_button.dart';
import '../data/mock_auth_repository.dart';
import '../../../core/widgets/form_step_scaffold.dart';
import 'otp_screen.dart';

class EmailLoginScreen extends StatefulWidget {
  const EmailLoginScreen({super.key});

  @override
  State<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends State<EmailLoginScreen> {
  static final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

  final _controller = TextEditingController();
  String? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() => _error = null));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _controller.text.trim();
    if (!_emailPattern.hasMatch(email)) {
      setState(() => _error = 'Enter a valid email address.');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    try {
      await authRepository.sendCode(email);
      if (!mounted) return;
      context.push(
        AppRoutes.otp,
        extra: OtpArgs(destination: email, channel: OtpChannel.email),
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
    return FormStepScaffold(
      title: "What's your email?",
      subtitle: const Text("We'll send a 6-digit code to sign you in."),
      body: TextField(
        controller: _controller,
        autofocus: true,
        enabled: !_loading,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.done,
        autocorrect: false,
        autofillHints: const [AutofillHints.email],
        style: Theme.of(context).textTheme.titleMedium,
        decoration: InputDecoration(
          hintText: 'you@example.com',
          errorText: _error,
        ),
        onSubmitted: (_) => _submit(),
      ),
      action: MeloButton(
        label: 'Send code',
        isLoading: _loading,
        onPressed: _controller.text.trim().isEmpty ? null : _submit,
      ),
      footer: MeloButton.text(
        label: 'Use phone number instead',
        onPressed: _loading
            ? null
            : () => context.pushReplacement(AppRoutes.phoneLogin),
      ),
    );
  }
}
