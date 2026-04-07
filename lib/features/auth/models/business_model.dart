import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:teamup/core/utils/timestamp_converter.dart';

part 'business_model.freezed.dart';
part 'business_model.g.dart';

@freezed
abstract class BusinessModel with _$BusinessModel {
  const factory BusinessModel({
    required String id,
    required String name,
    required String ownerUid,
    String? phone,
    String? address,
    String? logoUrl,
    @TimestampConverter() required DateTime createdAt,
  }) = _BusinessModel;

  factory BusinessModel.fromJson(Map<String, dynamic> json) =>
      _$BusinessModelFromJson(json);

  factory BusinessModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return BusinessModel.fromJson({'id': doc.id, ...data});
  }
}
