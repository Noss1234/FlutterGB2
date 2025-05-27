class RoutineTime {
  final int hour;
  final int minute;

  RoutineTime({required this.hour, required this.minute});

  String format() => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() => {
        'hour': hour,
        'minute': minute,
      };

  factory RoutineTime.fromJson(Map<String, dynamic> json) {
    return RoutineTime(
      hour: json['hour'],
      minute: json['minute'],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoutineTime && runtimeType == other.runtimeType && hour == other.hour && minute == other.minute;

  @override
  int get hashCode => hour.hashCode ^ minute.hashCode;
}
