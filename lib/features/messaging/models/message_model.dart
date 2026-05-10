import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:teamup/core/utils/timestamp_converter.dart';

part 'message_model.freezed.dart';
part 'message_model.g.dart';

@freezed
abstract class MessageModel with _$MessageModel {
  const factory MessageModel({
    required String id,
    required String senderId,
    required String text,

    /// Mirrored from the parent conversation. Lets Firestore security
    /// rules verify membership without a cross-doc lookup, which avoids
    /// `getAfter` edge cases on first-message creation.
    @Default(<String>[]) List<String> participantIds,
    @TimestampConverter() required DateTime sentAt,
  }) = _MessageModel;

  factory MessageModel.fromJson(Map<String, dynamic> json) => _$MessageModelFromJson(json);

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return MessageModel.fromJson({'id': doc.id, ...data});
  }
}
