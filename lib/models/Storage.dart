import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class Storage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    print(directory);
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/data.txt');
  }

  Future<String> readData() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      return contents;
    } catch (e) {
      return "";
    }
  }

  Future<void> writeData(String data) async {
    final file = await _localFile;
    await file.writeAsString(data);
  }
}
