import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
class FileDownloadView extends StatefulWidget {
  @override
  _FileDownloadViewState createState() => _FileDownloadViewState();
}

class _FileDownloadViewState extends State<FileDownloadView> {
  String _filePath = "";

  Future<String> get _localDevicePath async {

    final _devicePath = await getExternalStorageDirectory();
    return _devicePath.path;
  }

  Future<File> _localFile({String path, String type}) async {
    String _path = await _localDevicePath;

    var _newPath = await Directory("/storage/emulated/0/$path").create();
    return File("${_newPath.path}/pdf.$type");
  }

  Future<File> createFileOfPdfUrl() async {
    Completer<File> completer = Completer();
    print("Start download file from internet!");
    try {
      // "https://berlin2017.droidcon.cod.newthinking.net/sites/global.droidcon.cod.newthinking.net/files/media/documents/Flutter%20-%2060FPS%20UI%20of%20the%20future%20%20-%20DroidconDE%2017.pdf";
      // final url = "https://pdfkit.org/docs/guide.pdf";
      final url = "http://www.pdf995.com/samples/pdf.pdf";
      final filename = url.substring(url.lastIndexOf("/") + 1);
      var request = await HttpClient().getUrl(Uri.parse(url));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      var dir = await getApplicationDocumentsDirectory();
      print("Download files");
      print("${dir.path}/$filename");
      File file = File("${dir.path}/$filename");

      await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }

    return completer.future;
  }

//  Future _downloadSamplePDF() async {
////    final _response =
////    await http.get("https://firebasestorage.googleapis.com/v0/b/text-recognition-28371.appspot.com/o/Direct%20Recruitment%202020.pdf?alt=media&token=114498c1-0e84-48e0-bda0-15d4b688f745");
////    if (_response.statusCode == 200) {
////      final _file = await _localFile(path: "MyApp", type: "pdf");
////      final _saveFile = await _file.writeAsBytes(_response.bodyBytes);
////
////      Logger().i("File write complete. File Path ${_saveFile.path}");
////      setState(() {
////        _filePath = _saveFile.path;
////      });
////    } else {
////      Logger().e(_response.statusCode);
////    }
//  }

//  Future _downloadSampleVideo() async {
//    final _response = await http.get(
//        "https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_2mb.mp4");
//    if (_response.statusCode == 200) {
//      final _file = await _localFile(type: "mp4", path: "videos");
//      final _saveFile = await _file.writeAsBytes(_response.bodyBytes);
//      Logger().i("File write complete. File Path ${_saveFile.path}");
//      setState(() {
//        _filePath = _saveFile.path;
//      });
//    } else {
//      Logger().e(_response.statusCode);
//    }
//  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FlatButton.icon(
              icon: Icon(Icons.file_download),
              label: Text("Sample Pdf"),
              onPressed: () {
                createFileOfPdfUrl();



              },
            ),
            Text(_filePath),
            FlatButton.icon(
              icon: Icon(Icons.shop_two),
              label: Text("Show"),
              onPressed: () async {
                final _openFile = await OpenFile.open(_filePath);
//                Logger().i(_openFile);
              },
            ),
          ],
        ),
      ),
    );
  }
}