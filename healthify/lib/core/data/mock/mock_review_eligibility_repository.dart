import '../../queries/domain_queries.dart';
import '../repositories/review_eligibility_repository.dart';

class MockReviewEligibilityRepository implements ReviewEligibilityRepository {
  @override
  Future<bool> checkEligibility(ReviewEligibilityQuery query) async {
    await Future.delayed(const Duration(milliseconds: 30));
    // Patient PAT-8842 or any completed appointment patient is eligible
    if (query.patientId.isNotEmpty && query.targetId.isNotEmpty) {
      return true;
    }
    return false;
  }
}
