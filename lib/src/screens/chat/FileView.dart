// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whoxachat/web_view.dart';
// import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class FileView extends StatefulWidget {
  final String file;
  const FileView({super.key, required this.file});

  @override
  State<FileView> createState() => _FileViewState();
}

class _FileViewState extends State<FileView> {
  String url = "";
  @override
  void initState() {
    setState(() {});
    super.initState();
  }

  // final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //     // leading: const Icon(Icons.arrow_back_ios),
      //     ),
      body: Material(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: PrivacyWebView(
                url: widget.file,
              )
              // SfPdfViewer.network(
              //   widget.file,
              //   key: _pdfViewerKey,
              // ),
              ),
        ).paddingOnly(top: 30),
      ),
    );
  }
}
