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
    image: "images/onboarding_1.png",
    tittle: "Request Ride",
    text: "Request a ride get picked up by a nearby community driver",
  ),
  OnboardingData(
    image: "images/onboarding_2.png",
    tittle: "Confirm Your Driver",
    text: "Huge drivers network helps you find comforable, safe and cheap ride",
  ),
  OnboardingData(
    image: "images/onboarding_3.png",
    tittle: "Track your ride",
    text:"Know your driver in advance and be able to view current location in real time on the map",
  ),
];
