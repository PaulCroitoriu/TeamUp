import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

class TimestampConverter implements JsonConverter<DateTime, dynamic> {
  const TimestampConverter();

  @override
  DateTime fromJson(dynamic json) {
    if (json is Timestamp) return json.toDate();
    if (json is String) return DateTime.parse(json);
    return DateTime.now();
  }

  @override
  Timestamp toJson(DateTime date) => Timestamp.fromDate(date);
}
