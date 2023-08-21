import 'dart:io';

final String suffix = Platform.isWindows ? '.exe' : '';

void runProcess(
  String path,
  List<String> args, {
  ProcessStartMode? mode,
}) async {
  mode ??= Platform.isWindows
      ? ProcessStartMode.detached
      : ProcessStartMode.inheritStdio;
  final Process proc = await Process.start(
      path + suffix, args.isEmpty ? const [] : args.sublist(1),
      mode: mode);
  await proc.exitCode;
}

void runPassy(Directory root, List<String> args) async {
  runProcess(root.path + Platform.pathSeparator + 'passy_flutter', args);
}

void runCli(Directory root, List<String> args) async {
  runProcess(root.path + Platform.pathSeparator + 'passy_cli', args,
      mode: ProcessStartMode.inheritStdio);
}

void main(List<String> args) {
  final File resolvedExe = File(Platform.resolvedExecutable).absolute;
  final Directory passyRoot = resolvedExe.parent;
  if (args.contains('cli')) {
    return runCli(passyRoot, args);
  } else {
    return runPassy(passyRoot, args);
  }
}
