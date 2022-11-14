import 'package:get/get.dart';

import '../controllers/view_document_controller.dart';

class ViewDocumentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ViewDocumentController>(
      () => ViewDocumentController(),
    );
  }
}
