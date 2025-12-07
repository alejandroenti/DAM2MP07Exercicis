import 'dart:io';

import '../../domain/boards/Board.dart';
import '../../domain/commands/Command.dart';
import '../../application/commands/CommandAjuda.dart';
import '../../application/commands/CommandUncover.dart';
import '../../application/commands/CommandFlag.dart';
import '../../application/commands/CommandCheat.dart';
import '../../application/commands/CommandExit.dart';

// Class responsible for handling user input and output
class CliInterface {
  final Board board;
  final Map<String, Command> commands;

  CliInterface(this.board)
    : commands = {
        'ajuda': CommandAjuda(),
        'help': CommandAjuda(),
        'cheat': CommandCheat(board),
        'trampes': CommandCheat(board),
        'sortir': CommandExit(),
        'exit': CommandExit(),
      };

  void displayMessage(String message) {
    print(message);
  }

  void displayWarningMessage(String message) {
    print('⚠️ $message');
  }

  void displayErrorMessage(String message) {
    print('🛑 $message');
  }

  List<String> _parseInputOption(String input) {
    return input.trim().toLowerCase().split(RegExp(r'\s+'));
  }

  Future<void> startLoop() async {
    bool isPlaying = true;
    displayMessage(board.printBoard());

    while (isPlaying) {
      stdout.write("Escriu una comanda: ");
      final input = stdin.readLineSync();

      if (input == null || input.trim().isEmpty) {
        continue;
      }

      final parts = _parseInputOption(input);
      final firstWord = parts[0];
      final remainingArgs = parts.sublist(1);

      Command? command = commands[firstWord];

      List<String> commandArgs = [];

      if (remainingArgs.isNotEmpty &&
          (remainingArgs[0] == 'flag' || remainingArgs[0] == 'bandera')) {
        command = CommandFlag(board);
        commandArgs.add(firstWord); // La coordenada és el primer argument
      } else if (command != null) {
        commandArgs = remainingArgs;
      } else {
        command = CommandUncover(board);
        commandArgs.add(firstWord); // La coordenada és el primer argument
      }

      try {
        isPlaying = command.execute(this, commandArgs);
      } catch (e) {
        displayErrorMessage("S'ha produït un error inesperat: $e");
        isPlaying = false; // Potser hauria d'aturar el joc
      }
    }

    // El missatge de final de partida ja es gestiona a CommandUncover o CommandExit.
  }
}
