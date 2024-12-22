import 'package:flutter/material.dart';

class AddReviewForm extends StatelessWidget {
  final TextEditingController reviewController;
  final int selectedRating;
  final Function(int) onRatingSelected;
  final VoidCallback onSubmit;
  final bool isLoading;

  const AddReviewForm({
    required this.reviewController,
    required this.selectedRating,
    required this.onRatingSelected,
    required this.onSubmit,
    required this.isLoading,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return IconButton(
              onPressed: isLoading ? null : () => onRatingSelected(index + 1),
              icon: Icon(
                Icons.star,
                size: 40, // Lebih besar agar lebih terlihat
                color:
                    index < selectedRating ? Colors.orange : Colors.grey[400],
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: reviewController,
          enabled: !isLoading,
          decoration: InputDecoration(
            hintText: 'Tulis ulasan Anda di sini...',
            hintStyle: TextStyle(color: Colors.grey[500]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.orange, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.orange, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.deepOrange, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          maxLines: 3,
          style: const TextStyle(color: Colors.black),
        ),
        const SizedBox(height: 16),
        Center(
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.orange)
              : ElevatedButton(
                  onPressed: onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 40,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Kirim Ulasan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
