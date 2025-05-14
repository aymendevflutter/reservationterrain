import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import '../models/review_model.dart';
import '../services/auth_service.dart';

class ReviewList extends StatelessWidget {
  final List<ReviewModel> reviews;
  final String? currentUserId;
  final Function(ReviewModel)? onEdit;
  final Function(String)? onDelete;

  const ReviewList({
    Key? key,
    required this.reviews,
    this.currentUserId,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Aucun avis pour le moment',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final review = reviews[index];
        final isCurrentUser = currentUserId == review.userId;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: review.userImage != null
                          ? NetworkImage(review.userImage!)
                          : null,
                      child: review.userImage == null
                          ? Text(review.userName[0].toUpperCase())
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review.userName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            DateFormat('dd/MM/yyyy').format(review.createdAt),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isCurrentUser) ...[
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => onEdit?.call(review),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => onDelete?.call(review.id),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                RatingBar.builder(
                  initialRating: review.rating,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemSize: 20,
                  ignoreGestures: true,
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {},
                ),
                const SizedBox(height: 8),
                Text(
                  review.comment,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
