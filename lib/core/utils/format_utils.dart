import 'package:intl/intl.dart';

class Fmt {
  Fmt._();

  static String time(DateTime t) => DateFormat.jm().format(t);
  static String dateShort(DateTime d) => DateFormat('d MMM').format(d);
  static String dateMedium(DateTime d) => DateFormat('d MMM yyyy').format(d);
  static String dateFull(DateTime d) => DateFormat('EEEE, d MMMM yyyy').format(d);
  static String monthYear(DateTime d) => DateFormat('MMMM yyyy').format(d);
  static String monthShortYear(DateTime d) => DateFormat('MMM yyyy').format(d);

  static String dateRange(DateTime start, DateTime end) {
    if (start.month == end.month && start.year == end.year) {
      return '${start.day} – ${dateShort(end)}';
    }
    return '${dateShort(start)} – ${dateShort(end)}';
  }

  /// 453 -> "07h 33m"
  static String duration(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '${h.toString().padLeft(2, '0')}h ${m.toString().padLeft(2, '0')}m';
  }

  static const Map<String, String> _symbols = {'GBP': '£', 'USD': '\$', 'EUR': '€'};

  static String money(double amount, String currency) {
    final symbol = _symbols[currency] ?? '$currency ';
    return symbol + NumberFormat('#,##0.00').format(amount);
  }

  static String relative(DateTime from, {DateTime? now}) {
    final nowTime = now ?? DateTime.now();
    final diff = nowTime.difference(from);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return dateShort(from);
  }

  static String greeting(DateTime now) {
    final h = now.hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  static String initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    final first = parts.first[0];
    final last = parts.length > 1 ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }
}