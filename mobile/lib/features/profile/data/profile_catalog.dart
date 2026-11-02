/// Static option lists for profile setup. Will move to the API so they can
/// be updated without an app release.
abstract final class ProfileCatalog {
  static const popularCities = [
    'Bengaluru',
    'Mumbai',
    'Delhi',
    'Hyderabad',
    'Pune',
    'Chennai',
  ];

  static const interestGroups = <String, List<String>>{
    'Sports & fitness': [
      'Cricket',
      'Football',
      'Badminton',
      'Gym',
      'Yoga',
      'Running',
      'Trekking',
    ],
    'Music & arts': [
      'Indie music',
      'Bollywood',
      'Live gigs',
      'Classical music',
      'Dance',
      'Painting',
      'Poetry',
    ],
    'Food & drink': [
      'Street food',
      'Cooking',
      'Coffee',
      'Chai',
      'Baking',
      'Trying new cafés',
    ],
    'Entertainment': [
      'Movies',
      'Web series',
      'Anime',
      'Stand-up comedy',
      'Gaming',
      'Board games',
    ],
    'Lifestyle': [
      'Travel',
      'Photography',
      'Reading',
      'Pets',
      'Volunteering',
      'Fashion',
      'Spirituality',
    ],
  };

  static const prompts = [
    'My ideal Sunday',
    'A green flag I look for',
    "I'm weirdly competitive about",
    'Two truths and a lie',
    'The way to win me over is',
    'My most controversial food opinion',
    "Let's debate this topic",
    'I geek out on',
    'A perfect first date',
    "I'm looking for someone who",
  ];
}
