import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:onlysign/app/data/sample/sample_document.dart';
import 'package:onlysign/app/routes/app_pages.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
      ),
      body: ListView.builder(
        itemCount: listSampleDocument.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            leading: const Icon(Icons.description),
            title: Text(listSampleDocument[index].title),
            subtitle: Text(DateFormat("dd MMM yyy HH:mm:ss").format(listSampleDocument[index].created)),
            onTap: () => Get.toNamed(Routes.VIEW_DOCUMENT, arguments: listSampleDocument[index]),
          );
        },
      ),
    );
  }
}
