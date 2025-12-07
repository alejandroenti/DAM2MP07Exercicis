import 'dart:math';

import '../cells/Cell.dart';
import '../utils/Position.dart';

class Board {
  static const int BOARD_WIDTH = 10;
  static const int BOARD_HEIGHT = 6;
  static const int TOTAL_MINES = 8;

  final int _width = BOARD_WIDTH;
  final int _height = BOARD_HEIGHT;
  late List<List<Cell>> _cells;
  final Random _random = Random();

  bool _isGameOver = false;
  bool _cheatsActive = false;
  bool _isFirstPlay = true;
  int _triesCount = 0;

  Board() {
    _cells = List.generate(
      _height,
      (y) => List.generate(_width, (x) => Cell(Position(x, y))),
    );
  }

  int getWidth() => _width;
  int getHeight() => _height;
  bool isGameOver() => _isGameOver;
  bool isCheatsActive() => _cheatsActive;
  int getTriesCount() => _triesCount;
  Cell getCell(int x, int y) => _cells[y][x];

  void initializeBoard() {
    // Generem exactament 2 mines per quadrant (2 * 4 = 8)
    _generateMinesInQuadrant(0, 0, 4, 2);
    _generateMinesInQuadrant(5, 0, 9, 2);
    _generateMinesInQuadrant(0, 3, 4, 5);
    _generateMinesInQuadrant(5, 3, 9, 5);

    _calculateAdjacentMines();
  }

  void _generateMinesInQuadrant(int minX, int minY, int maxX, int maxY) {
    int countMines = 0;
    int rangeX = maxX - minX + 1;
    int rangeY = maxY - minY + 1;

    do {
      int x = _random.nextInt(rangeX) + minX;
      int y = _random.nextInt(rangeY) + minY;

      if (_cells[y][x].getHasMine()) {
        continue;
      }

      _cells[y][x].setHasMine(true);
      countMines++;
    } while (countMines < 2);
  }

  void _calculateAdjacentMines() {
    for (int y = 0; y < _height; y++) {
      for (int x = 0; x < _width; x++) {
        if (!_cells[y][x].getHasMine()) {
          _cells[y][x].setAdjacentMines(_countMinesAround(x, y));
        }
      }
    }
  }

  int _countMinesAround(int x, int y) {
    int count = 0;
    for (int dy = -1; dy <= 1; dy++) {
      for (int dx = -1; dx <= 1; dx++) {
        if (dx == 0 && dy == 0) continue;

        int newX = x + dx;
        int newY = y + dy;

        if (newX >= 0 && newX < _width && newY >= 0 && newY < _height) {
          if (_cells[newY][newX].getHasMine()) {
            count++;
          }
        }
      }
    }
    return count;
  }

  bool isOutOfBounds(int x, int y) {
    return x < 0 || x >= _width || y < 0 || y >= _height;
  }

  List<int> _getQuadrantBounds(int x, int y) {
    int minX, minY, maxX, maxY;

    // Límits X
    if (x >= 0 && x <= 4) {
      minX = 0;
      maxX = 4;
    } else {
      minX = 5;
      maxX = 9;
    }

    // Límits Y
    if (y >= 0 && y <= 2) {
      minY = 0;
      maxY = 2;
    } else {
      minY = 3;
      maxY = 5;
    }

    return [minX, minY, maxX, maxY];
  }

  void _moveMine(int oldX, int oldY) {
    _cells[oldY][oldX].setHasMine(false);

    final bounds = _getQuadrantBounds(oldX, oldY);
    final minX = bounds[0];
    final minY = bounds[1];
    final maxX = bounds[2];
    final maxY = bounds[3];

    final rangeX = maxX - minX + 1;
    final rangeY = maxY - minY + 1;

    int newX, newY;

    do {
      newX = _random.nextInt(rangeX) + minX;
      newY = _random.nextInt(rangeY) + minY;
    } while (_cells[newY][newX].getHasMine());

    _cells[newY][newX].setHasMine(true);
  }

  bool uncoverCell(int x, int y, bool isUserPlay) {
    if (isOutOfBounds(x, y)) {
      return false;
    }

    Cell cell = _cells[y][x];

    if (!cell.isCovered() || cell.getHasFlag()) {
      return false;
    }

    if (isUserPlay) {
      _triesCount++;
    }

    if (cell.getHasMine()) {
      if (_isFirstPlay) {
        _moveMine(x, y);
        _calculateAdjacentMines();

        _isFirstPlay = false;
        return uncoverCell(x, y, false);
      } else if (isUserPlay) {
        _isGameOver = true;
        return true;
      } else {
        return false;
      }
    }

    _isFirstPlay = false;
    cell.uncover();

    if (cell.getAdjacentMines() == 0) {
      for (int dy = -1; dy <= 1; dy++) {
        for (int dx = -1; dx <= 1; dx++) {
          if (dx == 0 && dy == 0) continue;
          uncoverCell(x + dx, y + dy, false);
        }
      }
    }

    return false;
  }

  void toggleCheats() {
    _cheatsActive = !_cheatsActive;
  }

  bool hasWon() {
    for (int y = 0; y < _height; y++) {
      for (int x = 0; x < _width; x++) {
        if (_cells[y][x].isCovered() && !_cells[y][x].getHasMine()) {
          return false;
        }
      }
    }
    return true;
  }

  String getCellChar(int x, int y, {bool isFinalReveal = false}) {
    Cell cell = _cells[y][x];

    if (cell.getHasFlag()) {
      if (isFinalReveal) return cell.getHasMine() ? 'T' : 'X';
      return '#';
    }

    if (cell.isCovered() && !isFinalReveal) {
      return '·';
    }

    if (cell.getHasMine()) {
      return '*';
    }

    int adjacentMines = cell.getAdjacentMines();
    if (adjacentMines > 0) {
      return adjacentMines.toString();
    } else {
      return ' ';
    }
  }

  String printBoard() {
    String output = '';

    String xLabels = ' 0123456789';
    output += xLabels;
    if (_cheatsActive) {
      output += '        $xLabels';
    }
    output += '\n';

    for (int y = 0; y < _height; y++) {
      String yLabel = String.fromCharCode('A'.codeUnitAt(0) + y) + ' ';

      String gameRow = yLabel;
      for (int x = 0; x < _width; x++) {
        gameRow += getCellChar(x, y);
      }

      output += gameRow;

      if (_cheatsActive) {
        String cheatRow = '      $yLabel';
        for (int x = 0; x < _width; x++) {
          final cell = getCell(x, y);
          cheatRow += cell.getHasMine()
              ? '*'
              : getCellChar(x, y, isFinalReveal: true);
        }
        output += cheatRow;
      }
      output += '\n';
    }
    return output;
  }

  String printFinalBoard() {
    String output = '\n\n=== TAULER FINAL ===\n';
    String xLabels = '  0123456789';
    output += xLabels + '\n';

    for (int y = 0; y < _height; y++) {
      String yLabel = String.fromCharCode('A'.codeUnitAt(0) + y) + ' ';
      String gameRow = yLabel;
      for (int x = 0; x < _width; x++) {
        gameRow += getCellChar(x, y, isFinalReveal: true);
      }
      output += gameRow + '\n';
    }
    return output;
  }
}
