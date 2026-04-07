import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:PregMate/app/widgets/keluhan_dialog.dart';
import '../controllers/keluhan_controller.dart';


class KeluhanView extends GetView<KeluhanController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pilih Keluhan')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Get.dialog(KeluhanDialog(trimester: null,));
          },
          child: Text('Pilih Keluhan Anda'),
        ),
      ),
    );
  }
}
