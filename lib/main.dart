import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_storage/get_storage.dart';

import 'package:PregMate/app/modules/artikel/controllers/artikel_controller.dart';
import 'package:PregMate/app/modules/home/controllers/home_controller.dart';
import 'package:PregMate/app/modules/jadwal/controllers/jadwal_controller.dart';
import 'package:PregMate/app/modules/profil/controllers/profil_controller.dart';
import 'package:PregMate/app/modules/histori/controllers/histori_controller.dart';

import 'app/routes/app_pages.dart';
import 'app/services/firebase_notification_service.dart';
import 'package:PregMate/config/api_config.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Widget buildApp() {
  return GetMaterialApp(
    title: "PregMate",
    initialRoute: AppPages.INITIAL,
    getPages: AppPages.routes,
    debugShowCheckedModeBanner: false,
  );
}

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  /// ✅ INIT STORAGE
  await GetStorage.init();

  /// INIT FIREBASE
  await Firebase.initializeApp();

  await FirebaseMessaging.instance.requestPermission();

  FirebaseMessaging.onBackgroundMessage(
    _firebaseMessagingBackgroundHandler
  );

  await FirebaseNotificationService().init();

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.notification != null) {
      Get.snackbar(
        message.notification!.title ?? "Notifikasi",
        message.notification!.body ?? "",
      );
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    Get.toNamed(Routes.INFORMASI);
  });

  ApiConfig.init();

  /// ✅ LAZY CONTROLLER (FIX)
  Get.lazyPut(() => HistoriController());
  Get.lazyPut(() => ProfileController());
  Get.lazyPut(() => JadwalController());
  Get.lazyPut(() => ArtikelController());
  Get.lazyPut(() => HomeController());

  runApp(buildApp());
}