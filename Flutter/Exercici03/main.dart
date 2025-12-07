import 'dart:io';
import 'domain/boards/Board.dart';
import 'infrastructure/cli/CliInterface.dart';

void main() async {
  final board = Board();
  board.initializeBoard();
  final cli = CliInterface(board);

  try {
    await cli.startLoop();
  } catch (e) {
    cli.displayErrorMessage("Error fatal de l'aplicació: $e");
  }

  exit(0);
}
