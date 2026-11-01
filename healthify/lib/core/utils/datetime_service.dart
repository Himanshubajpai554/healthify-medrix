/// DateTime Utility Service for Healthify Platform
/// Standardizes date formatting, relative time calculation, and timezone display across
/// both Hospital and Patient applications.
class DateTimeService {
  /// Returns human-readable relative time (e.g., "Updated 5 min ago", "2 hours ago", "Just now")
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return 'Updated ${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return 'Updated ${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return 'Updated ${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    }
  }

  /// Formats date into standard string: "Oct 3, 2026"
  static String formatDate(DateTime dateTime) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
  }

  /// Formats time into standard string: "10:30 AM"
  static String formatTime(DateTime dateTime) {
    final hour = dateTime.hour == 0 ? 12 : (dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour);
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    final minuteStr = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minuteStr $period';
  }

  /// Formats date and time: "Oct 3, 2026 • 10:30 AM"
  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} • ${formatTime(dateTime)}';
  }
}
