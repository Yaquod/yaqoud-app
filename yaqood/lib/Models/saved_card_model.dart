class SavedCard {
  final int id;
  final String maskedPan;
  final String cardSubtype;
  final String cardholderName;

  SavedCard({
    required this.id,
    required this.maskedPan,
    required this.cardSubtype,
    required this.cardholderName,
  });

  factory SavedCard.fromJson(Map<String, dynamic> json) {
    return SavedCard(
      id: json['id'],
      maskedPan: json['maskedPan'],
      cardSubtype: json['cardSubtype'],
      cardholderName: json['cardholderName'],
    );
  }
}