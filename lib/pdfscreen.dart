import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class PdfScreenPage extends StatefulWidget {
  @override
  _PdfScreenPageState createState() => _PdfScreenPageState();
}

class _PdfScreenPageState extends State<PdfScreenPage> {
  PermissionStatus _permissionStatus;
  String remotePDFpath = "";
  RandomAccessFile randomAccessFile;

  final imgUrl = "http://www.pdf995.com/samples/pdf.pdf";
  var dio = Dio();
  File fi;
  String fullPath;

  @override
  void initState() {
    // TODO: implement initState
    requestPermission(Permission.calendar).then((value) {
      requestPermission(Permission.storage).then((value) {});
    });
    getfilePath();

    super.initState();
  }

  getfilePath() async {
    var tempDir = await getApplicationDocumentsDirectory();
    fullPath = tempDir.path + "/boo2.pdf";
    setState(() {
      fi = new File(fullPath);
    });
  }

  Future download2(Dio dio, String url, String savePath) async {
    try {
      Response response = await dio.get(
        url,
        onReceiveProgress: showDownloadProgress,
        //Received data with List<int>
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              return status < 500;
            }),
      );
      print(response.headers);

      File file = File(savePath);

      var raf = file.openSync(mode: FileMode.write);
      // response.data is List<int> type
      raf.writeFromSync(response.data);
      setState(() {
        randomAccessFile = raf;
      });

      print('---->>${raf.path}');
      await raf.close();
    } catch (e) {
      print(e);
    }
  }

  double percent = 0.0;
  void showDownloadProgress(received, total) {
    if (total != -1) {
      setState(() {
        percent = double.parse((received / total * 100).toStringAsFixed(0));
      });

      print((received / total * 100).toStringAsFixed(0) + "%");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: fi.existsSync() == false
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      RaisedButton.icon(
                          onPressed: () async {
                            download2(dio, imgUrl, fullPath);
                          },
                          icon: Icon(
                            Icons.file_download,
                            color: Colors.white,
                          ),
                          color: Colors.green,
                          textColor: Colors.white,
                          label: Text('Download Invoice')
                              ),
                      Text('$percent%')
                    ],
                  ),
                  Text(
                      "${randomAccessFile != null ? "${randomAccessFile.path}" : "--"}"),
                ],
              ),
            )
          : PDFScreen(
              path: fi.path,
            ),
    );
  }

  Future<PermissionStatus> requestPermission(Permission permission) async {
    final status = await permission.request();
    setState(() {
      print(status);
      _permissionStatus = status;
    });
    return _permissionStatus = status;
  }
}

////
class PDFScreen extends StatefulWidget {
  final String path;

  PDFScreen({Key key, this.path}) : super(key: key);

  _PDFScreenState createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> with WidgetsBindingObserver {
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  int pages = 0;
  int currentPage = 0;
  bool isReady = false;
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return PDFView(
      filePath: widget.path,
      enableSwipe: true,
      swipeHorizontal: true,
      autoSpacing: false,
      pageFling: true,
      pageSnap: true,
      defaultPage: currentPage,
      preventLinkNavigation:
          false, // if set to true the link is handled in flutter
      onRender: (_pages) {
        setState(() {
          pages = _pages;
          isReady = true;
        });
      },
      onError: (error) {
        setState(() {
          errorMessage = error.toString();
        });
        print(error.toString());
      },
      onPageError: (page, error) {
        setState(() {
          errorMessage = '$page: ${error.toString()}';
        });
        print('$page: ${error.toString()}');
      },
      onViewCreated: (PDFViewController pdfViewController) {
        _controller.complete(pdfViewController);
      },
      onLinkHandler: (String uri) {
        print('goto uri: $uri');
      },
      onPageChanged: (int page, int total) {
        print('page change: $page/$total');
        setState(() {
          currentPage = page;
        });
      },
    );
  }
}
