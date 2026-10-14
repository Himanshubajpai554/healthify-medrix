import 'dart:convert';

import 'package:healthify_server_client/healthify_server_client.dart';

import '../../models/hospital_model.dart';
import '../../queries/domain_queries.dart';
import '../../queries/pagination.dart';
import '../repositories/review_eligibility_repository.dart';
import '../repositories/review_repository.dart';

class ServerpodReviewRepository implements ReviewRepository {
  ServerpodReviewRepository(this.client);

  final Client client;

  DateTime _date(Object? value) => value is String
      ? DateTime.tryParse(value) ?? DateTime.now()
      : DateTime.now();

  HospitalRating _from(Map<String, dynamic> row) => HospitalRating(
        id: '${row['id'] ?? ''}',
        hospitalId: '${row['hospitalId'] ?? ''}',
        patientId: 'Patient',
        ratingScore: (row['ratingScore'] as num?)?.toDouble() ?? 0,
        feedback: '${row['feedback'] ?? ''}',
        date: _date(row['date']),
        createdAt: _date(row['createdAt']),
        updatedAt: _date(row['updatedAt']),
      );

  @override
  Future<List<HospitalRating>> getReviews(ReviewQuery query) async {
    final raw = await client.hospital.listPatientReviews(
      query.targetType,
      query.targetId,
    );
    final rows = (jsonDecode(raw) as List)
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
    final start = query.pagination.offset.clamp(0, rows.length);
    final end = (start + query.pagination.pageSize).clamp(start, rows.length);
    return rows.sublist(start, end).map(_from).toList();
  }

  @override
  Future<HospitalRating> createReview(CreateReviewRequest request) async {
    final raw = await client.hospital.createPatientReview(
      request.targetType,
      request.targetId,
      request.rating,
      request.reviewText,
    );
    return _from(Map<String, dynamic>.from(jsonDecode(raw) as Map));
  }

  @override
  Future<double> getAverageRating({
    required String targetType,
    required String targetId,
  }) async {
    final reviews = await getReviews(
      ReviewQuery(targetType: targetType, targetId: targetId,
          pagination: const PaginationParams(pageSize: 500)),
    );
    if (reviews.isEmpty) return 0;
    final total = reviews.fold<double>(0, (sum, review) => sum + review.ratingScore);
    return double.parse((total / reviews.length).toStringAsFixed(1));
  }
}

class ServerpodReviewEligibilityRepository implements ReviewEligibilityRepository {
  ServerpodReviewEligibilityRepository(this.client);

  final Client client;

  @override
  Future<bool> checkEligibility(ReviewEligibilityQuery query) =>
      client.hospital.checkMyPatientReviewEligibility(
        query.targetType,
        query.targetId,
      );
}
