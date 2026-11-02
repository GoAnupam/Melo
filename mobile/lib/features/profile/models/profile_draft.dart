import 'package:flutter/material.dart';

enum Gender {
  woman('Woman'),
  man('Man'),
  nonBinary('Non-binary');

  const Gender(this.label);
  final String label;
}

enum InterestedIn {
  women('Women'),
  men('Men'),
  everyone('Everyone');

  const InterestedIn(this.label);
  final String label;
}

enum DatingIntention {
  longTerm(
    'Long-term relationship',
    'Looking for my person',
    Icons.favorite_border_rounded,
  ),
  shortTerm(
    'Short-term dating',
    'Fun, and open to where it goes',
    Icons.local_cafe_outlined,
  ),
  friendship(
    'Friendship',
    'New people, no pressure',
    Icons.people_outline_rounded,
  ),
  figuringOut(
    'Still figuring it out',
    "I'll know it when I feel it",
    Icons.explore_outlined,
  );

  const DatingIntention(this.label, this.description, this.icon);
  final String label;
  final String description;
  final IconData icon;
}

/// Placeholder for an uploaded photo until real image picking is wired up.
@immutable
class ProfilePhoto {
  const ProfilePhoto({required this.id, required this.tone});

  final int id;
  final Color tone;
}

@immutable
class PromptAnswer {
  const PromptAnswer({required this.question, required this.answer});

  final String question;
  final String answer;
}

/// The profile being built during onboarding. Held in memory for now;
/// will be persisted through the API later.
class ProfileDraft extends ChangeNotifier {
  static const minAge = 18;
  static const minInterests = 3;
  static const maxInterests = 7;
  static const minPhotos = 2;
  static const maxPhotos = 6;
  static const maxPrompts = 3;

  String firstName = '';
  DateTime? birthday;
  Gender? gender;
  InterestedIn? interestedIn;
  String city = '';
  DatingIntention? intention;
  final Set<String> interests = {};
  final List<ProfilePhoto> photos = [];
  final List<PromptAnswer> prompts = [];

  int? get age => birthday == null ? null : ageOn(birthday!, DateTime.now());

  static int ageOn(DateTime birthday, DateTime today) {
    var age = today.year - birthday.year;
    final hadBirthday =
        today.month > birthday.month ||
        (today.month == birthday.month && today.day >= birthday.day);
    if (!hadBirthday) age--;
    return age;
  }

  void updateBasics({
    required String firstName,
    required DateTime birthday,
    required Gender gender,
    required InterestedIn interestedIn,
    required String city,
  }) {
    this.firstName = firstName;
    this.birthday = birthday;
    this.gender = gender;
    this.interestedIn = interestedIn;
    this.city = city;
    notifyListeners();
  }

  void setIntention(DatingIntention value) {
    intention = value;
    notifyListeners();
  }

  /// Returns false if the limit has been reached.
  bool toggleInterest(String interest) {
    if (interests.contains(interest)) {
      interests.remove(interest);
    } else {
      if (interests.length >= maxInterests) return false;
      interests.add(interest);
    }
    notifyListeners();
    return true;
  }

  void addPhoto(ProfilePhoto photo) {
    if (photos.length >= maxPhotos) return;
    photos.add(photo);
    notifyListeners();
  }

  /// Re-inserts a photo, e.g. when undoing a removal.
  void insertPhoto(int index, ProfilePhoto photo) {
    if (photos.length >= maxPhotos) return;
    photos.insert(index.clamp(0, photos.length), photo);
    notifyListeners();
  }

  void removePhoto(int id) {
    photos.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void movePhoto(int from, int to) {
    if (from == to) return;
    final photo = photos.removeAt(from);
    photos.insert(to, photo);
    notifyListeners();
  }

  /// Adds a new prompt or replaces the one with the same question.
  void savePrompt(PromptAnswer prompt) {
    final i = prompts.indexWhere((p) => p.question == prompt.question);
    if (i >= 0) {
      prompts[i] = prompt;
    } else if (prompts.length < maxPrompts) {
      prompts.add(prompt);
    }
    notifyListeners();
  }

  void removePrompt(String question) {
    prompts.removeWhere((p) => p.question == question);
    notifyListeners();
  }
}

/// Makes the [ProfileDraft] available to every profile-setup screen.
class ProfileDraftScope extends InheritedNotifier<ProfileDraft> {
  const ProfileDraftScope({
    super.key,
    required ProfileDraft draft,
    required super.child,
  }) : super(notifier: draft);

  /// Returns the draft and rebuilds the caller when it changes.
  static ProfileDraft of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<ProfileDraftScope>()!
      .notifier!;

  /// Returns the draft without subscribing to changes (for callbacks).
  static ProfileDraft read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<ProfileDraftScope>()!.notifier!;
}
