class CountryCode {
  const CountryCode({
    required this.name,
    required this.flag,
    required this.dialCode,
    required this.minDigits,
    required this.maxDigits,
  });

  final String name;
  final String flag;
  final String dialCode;
  final int minDigits;
  final int maxDigits;

  bool isValidNumber(String digits) =>
      digits.length >= minDigits && digits.length <= maxDigits;

  static const india = CountryCode(
    name: 'India',
    flag: '🇮🇳',
    dialCode: '+91',
    minDigits: 10,
    maxDigits: 10,
  );

  static const supported = [
    india,
    CountryCode(
      name: 'United States',
      flag: '🇺🇸',
      dialCode: '+1',
      minDigits: 10,
      maxDigits: 10,
    ),
    CountryCode(
      name: 'United Kingdom',
      flag: '🇬🇧',
      dialCode: '+44',
      minDigits: 10,
      maxDigits: 10,
    ),
    CountryCode(
      name: 'United Arab Emirates',
      flag: '🇦🇪',
      dialCode: '+971',
      minDigits: 9,
      maxDigits: 9,
    ),
    CountryCode(
      name: 'Singapore',
      flag: '🇸🇬',
      dialCode: '+65',
      minDigits: 8,
      maxDigits: 8,
    ),
    CountryCode(
      name: 'Australia',
      flag: '🇦🇺',
      dialCode: '+61',
      minDigits: 9,
      maxDigits: 9,
    ),
  ];
}
