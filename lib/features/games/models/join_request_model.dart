import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:teamup/core/enums/join_request_status.dart';
import 'package:teamup/core/enums/payment_method.dart';
import 'package:teamup/core/utils/timestamp_converter.dart';

part 'join_request_model.freezed.dart';
part 'join_request_model.g.dart';

/// A player's request to join an open game that requires host approval. Stored
/// as `games/{gameId}/requests/{userId}` (doc id = userId, so one pending
/// request per player). The share is only charged once the host approves.
@freezed
abstract class JoinRequestModel with _$JoinRequestModel {
  const factory JoinRequestModel({
    required String id,
    required String userId,
    required String gameId,
    @Default(JoinRequestStatus.pending) JoinRequestStatus status,
    @Default(PaymentMethod.card) PaymentMethod paymentMethod,
    String? message,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() DateTime? decidedAt,
  }) = _JoinRequestModel;

  factory JoinRequestModel.fromJson(Map<String, dynamic> json) => _$JoinRequestModelFromJson(json);

  factory JoinRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return JoinRequestModel.fromJson({'id': doc.id, ...data});
  }
}
