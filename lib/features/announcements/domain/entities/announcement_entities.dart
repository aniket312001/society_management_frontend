import 'package:equatable/equatable.dart';

class AnnouncementEntity extends Equatable {
  final int id;
  final int societyId;
  final int createdBy;
  final String? createdByName;
  final String title;
  final String body;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;

  const AnnouncementEntity({
    required this.id,
    required this.societyId,
    required this.createdBy,
    this.createdByName,
    required this.title,
    required this.body,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
  });

  bool get isActive {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    return !todayDate.isBefore(startDate) && !todayDate.isAfter(endDate);
  }

  @override
  List<Object?> get props => [
    id,
    societyId,
    createdBy,
    createdByName,
    title,
    body,
    startDate,
    endDate,
    createdAt,
  ];
}
