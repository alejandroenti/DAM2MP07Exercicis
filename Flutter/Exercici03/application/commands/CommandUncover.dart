import '../../domain/commands/Command.dart';
import '../../infrastructure/cli/CliInterface.dart';
import '../../domain/boards/Board.dart';
import '../../domain/utils/PositionParser.dart';

class CommandUncover extends Command {
  final Board board;

  CommandUncover(this.board);

  @override
  bool execute(CliInterface cli, List<String> args) {
    if (args.isEmpty) {
      cli.displayWarningMessage("Falta la coordenada. Ús: C3");
      return true;
    }

    final coordinate = args[0];
    final position = PositionParser.parseCoordinate(coordinate);

    if (position == null) {
      cli.displayErrorMessage(
        "Coordenada invàlida. Ha de ser del tipus L# (Ex: A0 o F9).",
      );
      return true;
    }

    final x = position.getX();
    final y = position.getY();

    if (board.isOutOfBounds(x, y)) {
      cli.displayErrorMessage("Coordenada fora dels límits del tauler.");
      return true;
    }

    final hasExploded = board.uncoverCell(x, y, true);

    if (hasExploded) {
      cli.displayMessage(board.printFinalBoard());
      cli.displayMessage("\n💥 Bomba explotada! Has perdut!");
      cli.displayMessage("Número de tirades: ${board.getTriesCount()}");
      return false;
    }

    cli.displayMessage(board.printBoard());

    if (board.hasWon()) {
      cli.displayMessage(board.printFinalBoard());
      cli.displayMessage("\n🎉 Has guanyat!");
      cli.displayMessage("Número de tirades: ${board.getTriesCount()}");
      return false;
    }

    return true;
  }
}
