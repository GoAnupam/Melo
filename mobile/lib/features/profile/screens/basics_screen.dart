import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/widgets/field_label.dart';
import '../../../core/widgets/form_step_scaffold.dart';
import '../../../core/widgets/melo_button.dart';
import '../../../core/widgets/selectable_chip.dart';
import '../data/profile_catalog.dart';
import '../models/profile_draft.dart';
import 'setup_progress.dart';

class BasicsScreen extends StatefulWidget {
  const BasicsScreen({super.key});

  @override
  State<BasicsScreen> createState() => _BasicsScreenState();
}

class _BasicsScreenState extends State<BasicsScreen> {
  late final ProfileDraft _draft = ProfileDraftScope.read(context);
  late final _nameController = TextEditingController(text: _draft.firstName);
  late final _cityController = TextEditingController(text: _draft.city);
  late DateTime? _birthday = _draft.birthday;
  late Gender? _gender = _draft.gender;
  late InterestedIn? _interestedIn = _draft.interestedIn;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() {}));
    _cityController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  int? get _age =>
      _birthday == null ? null : ProfileDraft.ageOn(_birthday!, DateTime.now());

  bool get _isUnderage => _age != null && _age! < ProfileDraft.minAge;

  bool get _isValid =>
      _nameController.text.trim().isNotEmpty &&
      _birthday != null &&
      !_isUnderage &&
      _gender != null &&
      _interestedIn != null &&
      _cityController.text.trim().isNotEmpty;

  Future<void> _pickBirthday() async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthday ?? DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(now.year - 100),
      lastDate: now,
      initialDatePickerMode: DatePickerMode.year,
      helpText: 'Your birthday',
    );
    if (picked != null) setState(() => _birthday = picked);
  }

  void _continue() {
    _draft.updateBasics(
      firstName: _nameController.text.trim(),
      birthday: _birthday!,
      gender: _gender!,
      interestedIn: _interestedIn!,
      city: _cityController.text.trim(),
    );
    context.push(AppRoutes.setupIntentions);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return FormStepScaffold(
      progress: SetupStep.basics.progress,
      title: 'The basics',
      subtitle: const Text("This is how you'll appear to others."),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FieldLabel('First name'),
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.givenName],
            maxLength: 30,
            decoration: const InputDecoration(
              hintText: 'Your first name',
              counterText: '',
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const FieldLabel('Birthday'),
          _BirthdayField(
            birthday: _birthday,
            age: _age,
            error: _isUnderage
                ? 'You need to be ${ProfileDraft.minAge} or older to use Melo.'
                : null,
            onTap: _pickBirthday,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Only your age is shown on your profile.',
            style: text.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          const FieldLabel('I am'),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final g in Gender.values)
                SelectableChip(
                  label: g.label,
                  selected: _gender == g,
                  onTap: () => setState(() => _gender = g),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const FieldLabel('Interested in'),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final option in InterestedIn.values)
                SelectableChip(
                  label: option.label,
                  selected: _interestedIn == option,
                  onTap: () => setState(() => _interestedIn = option),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const FieldLabel('City'),
          TextField(
            controller: _cityController,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.addressCity],
            decoration: const InputDecoration(
              hintText: 'Where do you live?',
              prefixIcon: Icon(
                Icons.location_on_outlined,
                color: AppColors.inkMuted,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final city in ProfileCatalog.popularCities)
                SelectableChip(
                  label: city,
                  selected: _cityController.text.trim() == city,
                  onTap: () {
                    _cityController.text = city;
                    FocusScope.of(context).unfocus();
                  },
                ),
            ],
          ),
        ],
      ),
      action: MeloButton(
        label: 'Continue',
        onPressed: _isValid ? _continue : null,
      ),
    );
  }
}

class _BirthdayField extends StatelessWidget {
  const _BirthdayField({
    required this.birthday,
    required this.age,
    required this.error,
    required this.onTap,
  });

  final DateTime? birthday;
  final int? age;
  final String? error;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.input,
      child: InputDecorator(
        isEmpty: birthday == null,
        decoration: InputDecoration(
          hintText: 'Select your birthday',
          errorText: error,
          prefixIcon: const Icon(
            Icons.cake_outlined,
            color: AppColors.inkMuted,
          ),
          suffixIcon: const Icon(
            Icons.expand_more_rounded,
            color: AppColors.inkMuted,
          ),
        ),
        child: birthday == null
            ? null
            : Text.rich(
                TextSpan(
                  text: formatShortDate(birthday!),
                  children: [
                    TextSpan(
                      text: '   ·   $age years',
                      style: text.bodyLarge?.copyWith(
                        color: AppColors.inkMuted,
                      ),
                    ),
                  ],
                ),
                style: text.bodyLarge,
              ),
      ),
    );
  }
}
