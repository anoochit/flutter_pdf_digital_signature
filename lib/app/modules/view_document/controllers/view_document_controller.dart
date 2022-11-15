import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:onlysign/app/data/model/document_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

class ViewDocumentController extends GetxController {
  final showSignaturePad = false.obs;

  Uint8List? signedDocument;
  List<int>? signedDocumentByte;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> shareDocument({required DocumentModel sourceDocument}) async {
    // get document
    final directory = await getApplicationSupportDirectory();
    final path = directory.path;
    // share document
    Share.shareXFiles([XFile('$path/${sourceDocument.id}_output.pdf')]);
  }

  Future<void> signAndSaveDocument(
      {required GlobalKey<SfSignaturePadState> signaturePadGlobalKey, required DocumentModel sourceDocument}) async {
    final image = await signaturePadGlobalKey.currentState!.toImage(pixelRatio: 3.0);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    // load cerificate
    ByteData certBytes = await rootBundle.load("assets/certificate/certificate.pfx");
    final Uint8List certificateBytes = certBytes.buffer.asUint8List();

    // load pdf document
    final ByteData docBytes = await rootBundle.load(sourceDocument.file);
    final Uint8List documentBytes = docBytes.buffer.asUint8List();

    // create new pdf document
    PdfDocument document = PdfDocument(inputBytes: documentBytes);

    // goto last page
    int pageCount = document.pages.count;
    PdfPage page = document.pages[pageCount - 1];

    // create signature field
    PdfSignatureField signatureField = PdfSignatureField(
      page,
      'signature',
      bounds: const Rect.fromLTRB(300, 500, 550, 700),
      signature: PdfSignature(
        //Create a certificate instance from the PFX file with a private key.
        certificate: PdfCertificate(certificateBytes, 'password'),
        contactInfo: 'anoochit@gmail.com',
        reason: 'Approved document.',
        digestAlgorithm: DigestAlgorithm.sha256,
        cryptographicStandard: CryptographicStandard.cms,
      ),
    );

    PdfGraphics? graphics = signatureField.appearance.normal.graphics;

    // add signature field to document
    graphics?.drawImage(
      PdfBitmap(bytes!.buffer.asUint8List()),
      const Rect.fromLTWH(0, 0, 250, 200),
    );

    document.form.fields.add(signatureField);

    // flatten document
    document.form.flattenAllFields();

    // build a signed pdf document
    signedDocumentByte = await document.save();

    // save document
    final directory = await getApplicationSupportDirectory();
    final path = directory.path;
    File file = File('$path/${sourceDocument.id}_output.pdf');
    await file.writeAsBytes(signedDocumentByte!, flush: true);

    // set signed doc to pdf viewer
    signedDocument = Uint8List.fromList(signedDocumentByte!);
    document.dispose();

    // hide signature pad
    showSignaturePad.value = false;

    Get.back(closeOverlays: true);
    update();
  }
}
