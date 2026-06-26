import 'package:equatable/equatable.dart';

class DateRange extends Equatable {
  const DateRange({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  @override
  List<Object?> get props => [start, end];
}