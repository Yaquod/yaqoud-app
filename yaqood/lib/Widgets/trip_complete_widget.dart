import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:yaqood/Widgets/Primary_color.dart';

class TripCompleteWidget extends StatefulWidget {
  const TripCompleteWidget({
    super.key,
    required this.onSubmitRating,
    required this.onSkipRating,
  });

  final Function(int rating, String comment) onSubmitRating;
  final VoidCallback onSkipRating;

  @override
  State<TripCompleteWidget> createState() => _TripCompleteWidgetState();
}

class _TripCompleteWidgetState extends State<TripCompleteWidget> {
  int _selectedStars = 5;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "You Have Arrived!",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const Gap(6),
        Text(
          "How was your autonomous ride experience?",
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
        const Gap(20),
        Center(
          child: RatingBar.builder(
            initialRating: 5,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: false,
            itemCount: 5,
            itemPadding: const EdgeInsets.symmetric(horizontal: 6.0),
            itemBuilder: (context, _) =>
                const Icon(Icons.star_rounded, color: Colors.amber),
            onRatingUpdate: (rating) {
              setState(() {
                _selectedStars = rating.toInt();
              });
            },
          ),
        ),
        const Gap(24),
        TextField(
          controller: _commentController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText:
                "Tell us about the vehicle condition or ride smoothness (Optional)...",
            hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: PrimaryColor),
            ),
          ),
        ),
        const Gap(20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: PrimaryColor,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            final String cleanComment = _commentController.text.trim();

            // 🎯 أمر الطباعة للتتبع في الـ Widget
            print("============= RATING WIDGET TRIGGERED =============");
            print("Selected Stars (Rating): $_selectedStars");
            print("User Comment: '$cleanComment'");
            print("===================================================");

            widget.onSubmitRating(_selectedStars, cleanComment); //
          },
          child: const Text(
            "Submit Review",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Gap(8),
        TextButton(
          onPressed: widget.onSkipRating,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: Text(
            "Skip",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Gap(12),
      ],
    );
  }
}
