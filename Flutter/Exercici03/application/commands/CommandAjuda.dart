import '../../domain/commands/Command.dart';
import '../../infrastructure/cli/CliInterface.dart';

class CommandAjuda extends Command {
  @override
  bool execute(CliInterface cli, List<String> args) {
    cli.displayMessage(
      "\nLlista de comandes:\n" +
          " - ajuda|help - Mostra aquest menú\n" +
          " - [Fila][Columna] - Escull una casella per destapar (Ex: C3)\n" +
          " - [Fila][Columna] flag|bandera - Posa o treu una bandera (Ex: E1 flag)\n" +
          " - cheat|trampes - Mostra o amaga el tauler de mines (trucs)\n" +
          " - sortir|exit - Surt de la partida\n",
    );
    return true;
  }
}
// Line Example
