import 'dart:math';

import '../cells/Cell.dart';
import '../utils/Position.dart';

abstract class Board {
  
  late int _width;
  late int _height;
  late List<List<Cell>> _cells;
  late Random _random;

  Board(int width, int height) {
    _width = width;
    _height = height;

    _random = Random();
    
    _initializeBoard();
  }

  _initializeBoard() {
    for (int i = 0; i < _width; i++) {
      List<Cell> row = List.empty(growable: true);
      for (int j = 0; j < _height; j++) {
        row.add(Cell(Position(j, i)));
      }
      _cells.add(row);
    }
  }

  _generateMines() {
    _generateMinesInQuadrant(0, 0, (_width / 2).toInt(), (_height / 2).toInt());
    _generateMinesInQuadrant(0, 0, (_width / 2).toInt(), (_height / 2).toInt());
    _generateMinesInQuadrant(0, 0, (_width / 2).toInt(), (_height / 2).toInt());
    _generateMinesInQuadrant(0, 0, (_width / 2).toInt(), (_height / 2).toInt());
  }

  _generateMinesInQuadrant(int minX, int minY, int maxX, int maxY) {

    int countMines = 0;

    do {
      int x = _random.nextInt(maxX - minX) + maxX;
      int y = _random.nextInt(maxY - minY) + maxY;

      if (_cells[y][x].getHasMine()) {
        continue;
      }

      _cells[y][x].setHasMine(true);
      countMines++;

    } while (countMines < 2);
  }
}