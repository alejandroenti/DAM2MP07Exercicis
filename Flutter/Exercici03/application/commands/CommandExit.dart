import '../../domain/commands/Command.dart';
import '../../infrastructure/cli/CliInterface.dart';

class CommandExit extends Command {
  @override
  bool execute(CliInterface cli, List<String> args) {
    cli.displayMessage("👋 Sortint del Buscamines. Fins aviat!");
    return false;
  }
}
