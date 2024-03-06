import 'package:args/args.dart';
import 'package:at_client/at_client.dart';
import 'package:at_utils/at_utils.dart';
import 'package:dart_playground/util.dart';

Future<void> main(List<String> arguments) async {
  AtSignLogger.root_level = 'SEVERE';
  // get atsign argument from ArgsParser
  final ArgParser argsParser = ArgParser();
  argsParser.addOption('atsign',
      abbr: 'a', help: 'Owner of key', mandatory: true);
  argsParser.addOption('name',
      abbr: 'k',
      help: 'Name of the AtKey',
      mandatory: false,
      defaultsTo: 'test');
  argsParser.addOption('value',
      abbr: 'v',
      help: 'Value',
      mandatory: false,
      defaultsTo: 'some encrypted value !!! 123');
  argsParser.addOption('namespace',
      abbr: 'n',
      help: 'Namespace',
      mandatory: false,
      defaultsTo: 'dart_playground');

  final ArgResults argResults;
  try {
    argResults = argsParser.parse(arguments);
  } catch (e) {
    print(argsParser.usage);
    return;
  }

  final String atSign = argResults['atsign'];
  final String atKeyName = argResults['name'];
  final String atKeyValue = argResults['value'];
  final String namespace = argResults['namespace'];

  final AtClient atClient = await onboard(atSign);

  AtKey atKey = AtKey()
        ..key = atKeyName
        ..sharedBy = atSign
        ..namespace = namespace // default namespace
      ;

  Metadata metadata = Metadata()
        ..ttl = 1000*60*60*24*7 // 7 days
        ..ccd = true
        ..ttr = 1000 * 1 * 60 // 1 minute
        ..isEncrypted = true
      ;

  atKey.metadata = metadata;

  print('Putting ${atKey.toString()} with value $atKeyValue');

  bool success = await atClient.put(atKey, atKeyValue, putRequestOptions: PutRequestOptions()..useRemoteAtServer=true);
  if(success) {
    print('Success');
  } else {
    print('Failed');
  }

  atClient.syncService.sync();
}
