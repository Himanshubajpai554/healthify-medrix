import '../../models/hospital_model.dart';
import '../../queries/domain_queries.dart';

abstract class ReviewRepository {
  Future<List<HospitalRating>> getReviews(ReviewQuery query);
  Future<HospitalRating> createReview(CreateReviewRequest request);
  Future<double> getAverageRating({required String targetType, required String targetId});
}
