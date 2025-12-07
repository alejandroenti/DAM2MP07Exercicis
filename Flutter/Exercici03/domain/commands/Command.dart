import '../../infrastructure/cli/CliInterface.dart';

abstract class Command {
  bool execute(CliInterface cli, List<String> args);
}