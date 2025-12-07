import '../../domain/commands/Command.dart';
import '../../infrastructure/cli/CliInterface.dart';
import '../../domain/boards/Board.dart';

class CommandCheat extends Command {
  final Board board;

  CommandCheat(this.board);

  @override
  bool execute(CliInterface cli, List<String> args) {
    board.toggleCheats();
    final status = board.isCheatsActive() ? "ACTIVADES" : "DESACTIVADES";
    cli.displayMessage("Mode trampes $status.");
    cli.displayMessage(board.printBoard());
    return true;
  }
}
