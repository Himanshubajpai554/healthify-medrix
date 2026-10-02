import '../../queries/domain_queries.dart';

abstract class ReviewEligibilityRepository {
  Future<bool> checkEligibility(ReviewEligibilityQuery query);
}
