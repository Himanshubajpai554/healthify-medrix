import '../../models/hospital_model.dart';
import '../../queries/domain_queries.dart';
import '../repositories/review_repository.dart';

class MockReviewRepository implements ReviewRepository {
  final List<HospitalRating> _reviews = [
    HospitalRating(
      id: 'REV-1001',
      hospitalId: 'HOSP-101',
      patientId: 'PAT-8842',
      ratingScore: 5.0,
      feedback: 'Outstanding medical care and friendly staff in the cardiology department!',
      date: DateTime.now().subtract(const Duration(days: 3)),
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    HospitalRating(
      id: 'REV-1002',
      hospitalId: 'HOSP-101',
      patientId: 'PAT-1002',
      ratingScore: 4.5,
      feedback: 'Very quick emergency triage response. High level of professionalism.',
      date: DateTime.now().subtract(const Duration(days: 7)),
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    HospitalRating(
      id: 'REV-1003',
      hospitalId: 'HOSP-002',
      patientId: 'PAT-1003',
      ratingScore: 4.0,
      feedback: 'Clean facilities and comprehensive diagnostic labs.',
      date: DateTime.now().subtract(const Duration(days: 12)),
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
      updatedAt: DateTime.now().subtract(const Duration(days: 12)),
    ),
  ];

  @override
  Future<List<HospitalRating>> getReviews(ReviewQuery query) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _reviews.where((r) => r.hospitalId == query.targetId).toList();
  }

  @override
  Future<HospitalRating> createReview(CreateReviewRequest request) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final newReview = HospitalRating(
      id: 'REV-${DateTime.now().millisecondsSinceEpoch}',
      hospitalId: request.targetId,
      patientId: request.patientId,
      ratingScore: request.rating,
      feedback: request.reviewText,
      date: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _reviews.insert(0, newReview);
    return newReview;
  }

  @override
  Future<double> getAverageRating({required String targetType, required String targetId}) async {
    final matches = _reviews.where((r) => r.hospitalId == targetId).toList();
    if (matches.isEmpty) return 4.7;
    final total = matches.fold(0.0, (sum, r) => sum + r.ratingScore);
    return double.parse((total / matches.length).toStringAsFixed(1));
  }
}
