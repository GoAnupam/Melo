/// Profile setup steps, used for the progress bar. The preview is not a step.
enum SetupStep {
  basics,
  intentions,
  interests,
  photos,
  prompts;

  double get progress => (index + 1) / values.length;
}
