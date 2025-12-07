import '../../domain/commands/Command.dart';
import '../../infrastructure/cli/CliInterface.dart';
import '../../domain/boards/Board.dart';
import '../../domain/utils/PositionParser.dart';

class CommandFlag extends Command {
  final Board board;

  CommandFlag(this.board);

  @override
  bool execute(CliInterface cli, List<String> args) {
    if (args.isEmpty) {
      cli.displayWarningMessage("Falta la coordenada. Ús: E1 flag");
      return true;
    }

    final coordinate = args[0];
    final position = PositionParser.parseCoordinate(coordinate);

    if (position == null) {
      cli.displayErrorMessage("Coordenada invàlida.");
      return true;
    }

    final x = position.getX();
    final y = position.getY();

    if (board.isOutOfBounds(x, y)) {
      cli.displayErrorMessage("Coordenada fora dels límits del tauler.");
      return true;
    }

    final cell = board.getCell(x, y);

    if (cell.getHasFlag()) {
      cell.removeFlag();
      cli.displayMessage("🏳️ Bandera retirada de $coordinate.");
    } else if (cell.isCovered()) {
      cell.setupFlag();
      cli.displayMessage("🚩 Bandera posada a $coordinate.");
    } else {
      cli.displayWarningMessage(
        "No pots posar una bandera en una casella destapada.",
      );
    }

    cli.displayMessage(board.printBoard());

    return true;
  }
}
