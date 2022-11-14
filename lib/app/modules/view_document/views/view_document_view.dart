import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

import '../controllers/view_document_controller.dart';

class ViewDocumentView extends GetView<ViewDocumentController> {
  ViewDocumentView({Key? key}) : super(key: key);

  final String file = Get.arguments;

  final GlobalKey<SfSignaturePadState> signaturePadGlobalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ViewDocumentController>(builder: (controller) {
      return Scaffold(
        appBar: AppBar(
          actions: [
            // sign button
            (controller.signedDocument != null)
                ? IconButton(
                    onPressed: () async {
                      // save document
                      await controller.shareDocument(byte: controller.signedDocumentByte);
                    },
                    icon: const Icon(Icons.share),
                  )
                : IconButton(
                    onPressed: () {
                      // open sign dialog
                      controller.showSignaturePad.value = !controller.showSignaturePad.value;
                      controller.update();
                    },
                    icon: const Icon(Icons.gesture),
                  )
          ],
        ),
        body: Column(
          children: [
            // view document
            Expanded(
              child: (controller.signedDocument == null)
                  ? SfPdfViewer.asset(
                      file,
                      enableDoubleTapZooming: true,
                    )
                  : SfPdfViewer.memory(controller.signedDocument!),
            ),

            // view signature pad
            (controller.showSignaturePad.value)
                ? Column(
                    children: [
                      const Divider(
                        height: 0.0,
                        thickness: 2.0,
                      ),
                      SfSignaturePad(
                        key: signaturePadGlobalKey,
                      ),
                      Container(
                        color: Colors.white,
                        child: Flex(
                          direction: Axis.horizontal,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // sign document
                            ElevatedButton(
                              onPressed: () async {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) {
                                    return const AlertDialog(
                                      content: Text("Signing..."),
                                    );
                                  },
                                );
                                // build signature image
                                await controller.signAndSaveDocument(
                                  orginalFile: file,
                                  signaturePadGlobalKey: signaturePadGlobalKey,
                                );
                              },
                              child: const Text("Sign document"),
                            ),

                            // clear signature pad
                            ElevatedButton(
                              onPressed: () {
                                signaturePadGlobalKey.currentState!.clear();
                              },
                              child: const Text("Clear"),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Container()
          ],
        ),
      );
    });
  }
}
