import 'package:amiludo/layers/functional/Random/domain/entities/random_tools.dart';
import 'package:amiludo/layers/functional/Random/domain/sheet/sheet_tables.dart';

class SheetDate {
  const SheetDate(this.year, this.month, this.day);
  final int year, month, day;

  static SheetDate? parse(String text) {
    final parts = text.trim().split('/');
    if (parts.length != 3) return null;
    final d = int.tryParse(parts[0]), m = int.tryParse(parts[1]);
    final y = int.tryParse(parts[2]);
    if (d == null || m == null || y == null) return null;
    if (d < 1 || d > 31 || m < 1 || m > 12) return null;
    return SheetDate(y, m, d);
  }

  @override
  String toString() =>
      '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year';
}

abstract final class SheetDates {
  static const minAge = 16;
  static const maxAge = 70;

  static int ageAt(SheetEra era, SheetDate birth) {
    final reached =
        birth.month < era.month ||
        (birth.month == era.month && birth.day <= era.day);
    return era.year - birth.year - (reached ? 0 : 1);
  }

  static SheetDate birthFor(SheetEra era, int age, RandomTools random) {
    final month = random.integer(1, 12), day = random.integer(1, 28);
    final reached = month < era.month || (month == era.month && day <= era.day);
    return SheetDate(era.year - age - (reached ? 0 : 1), month, day);
  }
}
