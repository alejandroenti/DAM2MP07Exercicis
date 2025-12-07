import '../utils/Position.dart';

class Cell {
  
  final Position _position;
  bool _hasMine;
  bool _hasFlag;
  bool _isCovered;
  int _adjacentMines;

  Cell(this._position) : 
    _hasMine = false,
    _hasFlag = false,
    _isCovered = true,
    _adjacentMines = 0;

  Position getPosition() => _position;
  
  bool getHasFlag() => _hasFlag;
  void setHasMine(bool value) => _hasMine = value;
  bool getHasMine() => _hasMine;
  
  bool isCovered() => _isCovered;
  void uncover() => _isCovered = false;
  
  int getAdjacentMines() => _adjacentMines;
  void setAdjacentMines(int count) => _adjacentMines = count;

  void setupFlag() {
    if (_isCovered) {
      _hasFlag = true;
    }
  }

  void removeFlag() {
    _hasFlag = false;
  }
}