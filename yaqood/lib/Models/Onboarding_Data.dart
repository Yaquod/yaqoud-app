class OnboardingData {
  final String image;
  final String tittle;
  final String text;

  OnboardingData({
    required this.image,
    required this.tittle,
    required this.text,
  });
}

List<OnboardingData> onboardingData = [
  OnboardingData(
    image: "assets/images/onboarding_1.png",
    tittle: "Future of Mobility",
    text:
        "Experience stress-free travel with Yaqood. No driver, just the road ahead",
  ),
  OnboardingData(
    image: "assets/images/onboarding_2.png",
    tittle: "Smart & Secure",
    text: "Advanced AI and LiDAR technology ensure your safety in every mile",
  ),
  OnboardingData(
    image: "assets/images/onboarding_3.png",
    tittle: "Your Private Lounge",
    text:
        "Relax or work in total privacy. Customize your ride with a single tap",
  ),
];
