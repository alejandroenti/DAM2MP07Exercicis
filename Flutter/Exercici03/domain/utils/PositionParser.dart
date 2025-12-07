import 'Position.dart';

class PositionParser {
  static Position? parseCoordinate(String coordinate) {
    if (coordinate.length < 2) return null;

    final yChar = coordinate[0].toUpperCase();
    final xChar = coordinate.substring(1);

    final y = yChar.codeUnitAt(0) - 'A'.codeUnitAt(0);
    final x = int.tryParse(xChar);

    if (x == null || y < 0 || y > 5 || x < 0 || x > 9) {
      return null;
    }

    return Position(x, y);
  }
}
