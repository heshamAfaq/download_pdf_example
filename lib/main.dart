import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pspdfkit_flutter/pspdfkit.dart';
import 'package:text_to_speech/text_to_speech.dart';

// Filename of the PDF you'll download and save.
const fileName = '/pspdfkit-flutter-quickstart-guide.pdf';

// URL of the PDF file you'll download.
const imageUrl = 'https://pspdfkit.com/downloads$fileName';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Download and Display a PDF',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Download and Display a PDF'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Track the progress of a downloaded file here.
  double progress = 0;

  // Track if the PDF was downloaded here.
  bool didDownloadPDF = false;

  // Show the progress status to the user.
  String progressString = 'File has not been downloaded yet.';
  TextToSpeech tts = TextToSpeech();

  // This method uses Dio to download a file from the given URL
  // and saves the file to the provided `savePath`.
  Future download(Dio dio, String url, String savePath) async {
    try {
      Response response = await dio.get(
        url,
        onReceiveProgress: updateProgress,
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              return status! < 500;
            }),
      );
      var file = File(savePath).openSync(mode: FileMode.write);
      print(file.path);
      file.writeFromSync(response.data);
      await file.close();

      // Here, you're catching an error and printing it. For production
      // apps, you should display the warning to the user and give them a
      // way to restart the download.
    } catch (e) {
      print(e);
    }
  }

  // You can update the download progress here so that the user is
  // aware of the long-running task.
  void updateProgress(done, total) {
    progress = done / total;
    setState(() {
      if (progress >= 1) {
        progressString =
            '??? File has finished downloading. Try opening the file.';
        didDownloadPDF = true;
      } else {
        progressString =
            'Download progress: ${(progress * 100).toStringAsFixed(0)}% done.';
      }
    });
  }
  loadPDF() async {
    final dio = Dio();
    final Completer<PDFViewController> controller =
    Completer<PDFViewController>();
    int? pages = 0;
    int? currentPage = 0;
    bool isReady = false;
    String errorMessage = '';
    Map<String, String> headers = {
      'Content-type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };
    final response =
    await dio.get(imageUrl, options: Options(
        headers: headers,
        responseType: ResponseType.bytes,
        followRedirects: false,
        validateStatus: (status) {
          return status! < 500;
        }), );
    var tempDir = await getTemporaryDirectory();
    // final bytes = response.data;
    var file = File(tempDir.path+fileName).openSync(mode: FileMode.write);
    file.writeFromSync(response.data);
    print(file);
    await file.close();
    // print(bytes);
    // print(response.statusCode);
    // var dir = await getTemporaryDirectory();
    // File file = File(dir.path + "/data.pdf");
    // await file.writeAsBytes(bytes, flush: true);
    // PDFView(
    //   filePath: file.path,
    //   enableSwipe: true,
    //   swipeHorizontal: true,
    //   autoSpacing: false,
    //   pageFling: false,
    //   onRender: (_pages) {
    //     pages = _pages;
    //     isReady = true;
    //   },
    //   onError: (error) {
    //     print(error.toString());
    //   },
    //   onPageError: (page, error) {
    //     print('$page: ${error.toString()}');
    //   },
    //   onViewCreated: (PDFViewController pdfViewController) {
    //     controller.complete(pdfViewController);
    //   },
    //   onPageChanged: (int? page, int? total) {
    //     print('page change: $page/$total');
    //   },
    // );
    //
    // return file;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
                onPressed: () {
                loadPDF();



                  // String text = "?????? ??????";
                  // tts.speak(text);
                  // double volume = 50.0;
                  // tts.setVolume(volume);
                  // String language = 'ar';
                  // tts.setLanguage(language);
                },
                icon: const Icon(Icons.add)),
            const Text(
              'First, download a PDF file. Then open it.',
            ),
            TextButton(
              // Here, you download and store the PDF file in the temporary
              // directory.
              onPressed: didDownloadPDF
                  ? null
                  : () async {
                      var tempDir = await getTemporaryDirectory();
                      download(Dio(), imageUrl, tempDir.path + fileName);
                    },
              child: const Text('Download a PDF file'),
            ),
            Text(
              progressString,
            ),
            TextButton(
              // Disable the button if no PDF is downloaded yet. Once the
              // PDF file is downloaded, you can then open it using PSPDFKit.
              onPressed:
              // !didDownloadPDF
              //     ? null
              //     :
                  () async {
                      var tempDir = await getTemporaryDirectory();
                      await Pspdfkit.present(tempDir.path + fileName);
                    },
              child: Text('Open the downloaded file using PSPDFKit'),
            ),
          ],
        ),
      ),
    );
  }
}
