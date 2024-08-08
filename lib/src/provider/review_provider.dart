import 'package:flutter/material.dart';
import 'package:heathbridge_lao/package.dart';
import 'package:heathbridge_lao/src/models/review_model.dart'; // Adjust import as per your project structure

class ReviewProvider extends ChangeNotifier {
  List<ReviewModel> _reviews = [];
  List<ReviewModel> _userReviews = []; // New list for user-specific reviews

  List<ReviewModel> get reviews => _reviews;
  List<ReviewModel> get userReviews =>
      _userReviews; // Getter for user-specific reviews

  bool isPosting = false;
  bool isLoading = false;
  final HasuraConnect _hasuraConnect = HasuraHelper.hasuraHelper;
  Future<void> fetchUserReviews(String userId) async {
    const String fetchUserReviewsQuery = r'''
      query MyQuery2($_eq: uuid!) {
        reviews(where: {user_id: {_eq: $_eq}}) {
          created_at
          description
          rating
          facility {
            name
          }
          status
        }
      }
    ''';

    try {
      isLoading = true;
      notifyListeners();

      final response = await _hasuraConnect
          .query(fetchUserReviewsQuery, variables: {'_eq': userId});

      isLoading = false;
      notifyListeners();

      if (response['data'] != null) {
        _userReviews = (response['data']['reviews'] as List)
            .map((json) => ReviewModel.fromJson(json))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
      debugPrint('Error fetching user reviews: $e');
      rethrow;
    }
  }

  Future<void> dismissReview(String reviewId) async {
    const String dismissReviewMutation = """
    mutation dismissReview(\$reviewId: uuid!, \$status: Int!) {
      update_reviews(where: {review_id: {_eq: \$reviewId}}, _set: {status: \$status}) {
        affected_rows
      }
    }
  """;

    try {
      final response =
          await _hasuraConnect.mutation(dismissReviewMutation, variables: {
        'reviewId': reviewId,
        'status': 0, // Set status to 0 to dismiss
      });

      if (response['data'] != null &&
          response['data']['update_reviews']['affected_rows'] > 0) {
        debugPrint("Review dismissed successfully.");
        // Optionally, update the local list of reviews
        _reviews.removeWhere((review) => review.reviewId == reviewId);
        notifyListeners();
      } else {
        debugPrint("Failed to dismiss review.");
      }
    } catch (e) {
      debugPrint("Error dismissing review: $e");
    }
  }

  Future<bool> postReview({
    required ReviewModel review,
    required String facilityId,
    required String userId,
  }) async {
    const String insertReviewMutation = """
    mutation insertReview(\$createdAt: timestamptz!, \$description: String!, \$facId: uuid!, \$rating: numeric!, \$status: Int!, \$userId: uuid!) {
      insert_reviews(objects: {created_at: \$createdAt, description: \$description, fac_id: \$facId, rating: \$rating, status: \$status, user_id: \$userId}) {
        affected_rows
      }
    }
    """;

    try {
      isPosting = true;
      notifyListeners();

      final response =
          await _hasuraConnect.mutation(insertReviewMutation, variables: {
        'createdAt': DateTime.now().toIso8601String(),
        'description': review.description,
        'facId': facilityId,
        'rating':
            review.rating!.toDouble(), // Ensure rating is passed as numeric
        'status': 1,
        'userId': userId,
      });

      isPosting = false;
      notifyListeners();

      if (response['data'] != null &&
          response['data']['insert_reviews']['affected_rows'] > 0) {
        await fetchReviews(facilityId); // Fetch reviews again after posting
        await updateFacilityRatingCount(
            facilityId); // Update facility rating count
        return true;
      }
      return false;
    } catch (e) {
      isPosting = false;
      notifyListeners();
      debugPrint("Error posting review: $e");
      return false;
    }
  }

  Future<void> fetchReviews(String facId) async {
    const String fetchReviewsQuery = r'''
      query MyQuery($_eq: uuid!) {
        reviews(where: {fac_id: {_eq: $_eq}}) {
          created_at
          description
          rating
          status
          fac_id
          review_id
          user {
            firstname
            lastname
            email
            tel
            user_id
          }
          facility {
            name
          }
        }
      }
    ''';

    try {
      isLoading = true;
      notifyListeners();

      final response = await _hasuraConnect
          .query(fetchReviewsQuery, variables: {'_eq': facId});

      isLoading = false;
      notifyListeners();

      if (response['data'] != null) {
        _reviews = (response['data']['reviews'] as List)
            .map((json) => ReviewModel.fromJson(json))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
      debugPrint('Error fetching reviews: $e');
      rethrow;
    }
  }

  Future<void> refreshReviews(String facId) async {
    await fetchReviews(facId);
  }

  Future<void> updateFacilityRatingCount(String facId) async {
    final int totalReviews = _reviews.length;
    final double averageRating =
        _reviews.map((review) => review.rating!).reduce((a, b) => a + b) /
            totalReviews;

    const String updateFacilityMutation = """
    mutation MyMutation(\$_eq1: uuid!, \$rating_count: String!) {
      update_facilities(where: {fac_id: {_eq: \$_eq1}}, _set: {rating_count: \$rating_count}) {
        affected_rows
        returning {
          rating_count
        }
      }
    }
    """;

    try {
      final response =
          await _hasuraConnect.mutation(updateFacilityMutation, variables: {
        '_eq1': facId,
        'rating_count':
            averageRating.toStringAsFixed(2), // format to 2 decimal places
      });

      if (response['data'] != null &&
          response['data']['update_facilities']['affected_rows'] > 0) {
        debugPrint("Facility rating count updated successfully.");
      } else {
        debugPrint("Failed to update facility rating count.");
      }
    } catch (e) {
      debugPrint("Error updating facility rating count: $e");
    }
  }
}
