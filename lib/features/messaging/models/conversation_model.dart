import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:teamup/core/utils/timestamp_converter.dart';

part 'conversation_model.freezed.dart';
part 'conversation_model.g.dart';

enum ConversationKind {
  booking(1, 'Booking'),
  direct(2, 'Direct'),
  game(3, 'Game');

  const ConversationKind(this.value, this.label);
  final int value;
  final String label;
}

@freezed
abstract class ConversationModel with _$ConversationModel {
  const factory ConversationModel({
    required String id,
    required ConversationKind kind,

    /// Set when [kind] is `booking`.
    String? bookingId,

    /// Set when [kind] is `game`.
    String? gameId,

    @Default([]) List<String> participantIds,
    String? lastMessageText,
    String? lastMessageSenderId,
    @TimestampConverter() DateTime? lastMessageAt,
    @TimestampConverter() required DateTime createdAt,
  }) = _ConversationModel;

  factory ConversationModel.fromJson(Map<String, dynamic> json) => _$ConversationModelFromJson(json);

  factory ConversationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return ConversationModel.fromJson({'id': doc.id, ...data});
  }
}
