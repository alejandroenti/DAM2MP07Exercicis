import '../utils/Position.dart';

class Cell {
  
  late Position _position;
  late bool _hasMine;
  late bool _hasFlag;

  Cell(Position position) {
    _position = position;
    _hasMine = false;
    _hasFlag = false;
  }

  Position getPosition() {
    return _position;
  }

  bool getHasFlag() {
    return _hasFlag;
  }

  void setHasMine(bool value) {
    _hasMine = value;
  }

  bool getHasMine() {
    return _hasMine;
  }

  void setupFlag() {
    _hasFlag = true;
  }

  void removeFlag() {
    _hasFlag = false;
  }
}