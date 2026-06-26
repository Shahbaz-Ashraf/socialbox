import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static String formatDate(DateTime date) =>
      DateFormat('MMM d, y').format(date);

  static String formatTime(DateTime date) =>
      DateFormat('h:mm a').format(date);

  static String formatDateTime(DateTime date) =>
      DateFormat('MMM d, y • h:mm a').format(date);

  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now);

    if (diff.inDays > 7) return formatDate(date);
    if (diff.inDays > 0) return 'in ${diff.inDays}d';
    if (diff.inHours > 0) return 'in ${diff.inHours}h';
    if (diff.inMinutes > 0) return 'in ${diff.inMinutes}m';
    if (diff.inMinutes > -60) return '${-diff.inMinutes}m ago';
    if (diff.inHours > -24) return '${-diff.inHours}h ago';
    if (diff.inDays > -7) return '${-diff.inDays}d ago';
    return formatDate(date);
  }

  static String formatShortDate(DateTime date) =>
      DateFormat('MMM d').format(date);

  static String dayOfWeek(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[(weekday - 1) % 7];
  }

  static String repeatDaysSummary(List<int> days) {
    if (days.isEmpty) return 'No days';
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return days.map((d) => labels[(d - 1) % 7]).join(' ');
  }
}
