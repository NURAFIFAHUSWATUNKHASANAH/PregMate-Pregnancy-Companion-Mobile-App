import 'package:get/get.dart';

import '../modules/artikel/views/all_articles_view.dart';
import '../modules/berat_badan/bindings/berat_badan_binding.dart';
import '../modules/berat_badan/views/berat_badan_view.dart';
import '../modules/bottom/bindings/bottom_binding.dart';
import '../modules/bottom/views/bottom_view.dart';
import '../modules/craving/bindings/craving_binding.dart';
import '../modules/craving/views/craving_view.dart';
import '../modules/diskusi/bindings/diskusi_binding.dart';
import '../modules/diskusi/views/diskusi_view.dart';
import '../modules/edit_profil/bindings/edit_profil_binding.dart';
import '../modules/edit_profil/views/edit_profil_view.dart';
import '../modules/forgot_password/bindings/forgot_password_binding.dart';
import '../modules/forgot_password/views/forgot_password_view.dart';
import '../modules/histori/bindings/histori_binding.dart';
import '../modules/histori/views/histori_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/home/views/home_view_pendamping.dart';
import '../modules/informasi/bindings/informasi_binding.dart';
import '../modules/informasi/views/informasi_view.dart';
import '../modules/jadwal/bindings/jadwal_binding.dart';
import '../modules/jadwal/views/jadwal_dialog.dart';
import '../modules/kalkulator_bersalin/bindings/kalkulator_bersalin_binding.dart';
import '../modules/kalkulator_bersalin/views/kalkulator_bersalin_view.dart';
import '../modules/keluhan/bindings/keluhan_binding.dart';
import '../modules/keluhan/views/keluhan_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/meditation/bindings/meditation_binding.dart';
import '../modules/meditation/views/meditation_view.dart';
import '../modules/mood/bindings/mood_binding.dart';
import '../modules/mood/views/mood_view.dart';
import '../modules/nama_bayi/bindings/nama_bayi_binding.dart';
import '../modules/nama_bayi/views/nama_bayi_view.dart';
import '../modules/profil/bindings/profil_binding.dart';
import '../modules/profil/views/profil_view.dart';
import '../modules/recipe/bindings/recipe_binding.dart';
import '../modules/recipe/views/recipe_view.dart';
import '../modules/register/bindings/register_binding.dart';
import '../modules/register/views/register_view.dart';
import '../modules/riwayat_kehamilan/bindings/riwayat_kehamilan_binding.dart';
import '../modules/riwayat_kehamilan/views/riwayat_kehamilan_view.dart';
import '../modules/senam/bindings/senam_binding.dart';
import '../modules/senam/views/senam_view.dart';
import '../modules/senam_ai/bindings/senam_ai_binding.dart';
import '../modules/senam_ai/views/senam_ai_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/tas_bersalin/bindings/tas_bersalin_binding.dart';
import '../modules/tas_bersalin/bindings/tas_bersalin_binding.dart';
import '../modules/tas_bersalin/views/tas_bersalin_view.dart';
import '../modules/tas_bersalin/views/tas_bersalin_view.dart';
import '../modules/tentang/bindings/tentang_binding.dart';
import '../modules/tentang/views/tentang_view.dart';
import '../modules/terapi/bindings/terapi_binding.dart';
import '../modules/terapi/views/terapi_view.dart';
import '../modules/tips_newborn/bindings/tips_newborn_binding.dart';
import '../modules/tips_newborn/views/tips_newborn_view.dart';
import '../modules/ukuran_janin/bindings/ukuran_janin_binding.dart';
import '../modules/ukuran_janin/views/ukuran_janin_view.dart';
import '../modules/validasi_kehamilan/bindings/validasi_kehamilan_binding.dart';
import '../modules/validasi_kehamilan/views/validasi_kehamilan_view.dart';
import '../modules/verify_otp/bindings/verify_otp_binding.dart';
import '../modules/verify_otp/views/verify_otp_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.TERAPI,
      page: () => TerapiView(),
      binding: TerapiBinding(),
    ),
    GetPage(
      name: _Paths.HISTORI,
      page: () => HistoriView(),
      binding: HistoriBinding(),
    ),
    GetPage(
      name: Routes.PROFIL,
      page: () => ProfileView(),
      binding: ProfilBinding(),
    ),
    GetPage(
      name: _Paths.BOTTOM,
      page: () => BottomScreen(),
      binding: BottomBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => RegisterView(),
      binding: RegisterBinding(),
    ),
    // GetPage(
    //   name: _Paths.REKOMENDASI,
    //   page: () => RekomendasiDialog(), // Ganti sesuai nama view kamu
    //   binding: RekomendasiBinding(),
    // ),
    GetPage(
      name: _Paths.SPLASH,
      page: () => SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.KELUHAN,
      page: () => KeluhanView(),
      binding: KeluhanBinding(),
    ),
    GetPage(
      name: _Paths.JADWAL,
      page: () => JadwalDialog(),
      binding: JadwalBinding(),
    ),
    GetPage(
      name: Routes.EDIT_PROFIL,
      page: () => const EditProfileView(),
      binding: EditProfileBinding(),
    ),
    GetPage(
      name: _Paths.TENTANG,
      page: () => const TentangView(),
      binding: TentangBinding(),
    ),
    GetPage(name: _Paths.ALL_ARTICLES, page: () => AllArtikelView()),
    GetPage(name: '/artikel', page: () => AllArtikelView()),
    GetPage(name: '/article_detail', page: () => AllArtikelView()),
    GetPage(
      name: _Paths.FORGOT_PASSWORD,
      page: () => ForgotPasswordView(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: _Paths.VERIFY_OTP,
      page: () => const VerifyOtpView(),
      binding: VerifyOtpBinding(),
    ),
    // GetPage(
    //   name: '/menu',
    //   page: () => MenuView(),
    //   binding: MenuBinding(),
    // ),
    GetPage(
      name: _Paths.MOOD,
      page: () => MoodView(),
      binding: MoodBinding(),
    ),
    GetPage(
      name: _Paths.RECIPE,
      page: () => const RecipeView(),
      binding: RecipeBinding(),
    ),
    GetPage(
      name: _Paths.DISKUSI,
      page: () => DiskusiView(),
      binding: DiskusiBinding(),
    ),
    GetPage(
      name: _Paths.MEDITATION,
      page: () => MeditationView(),
      binding: MeditationBinding(),
    ),
    GetPage(
      name: '/home-pendamping',
      page: () => HomeViewPendamping(),
    ),

    GetPage(
      name: _Paths.VALIDASI_KEHAMILAN,
      page: () => const ValidasiKehamilanView(),
      binding: ValidasiKehamilanBinding(),
    ),
    GetPage(
      name: _Paths.UKURAN_JANIN,
      page: () => const UkuranJaninView(),
      binding: UkuranJaninBinding(),
    ),
    GetPage(
      name: _Paths.BERAT_BADAN,
      page: () => BeratBadanView(),
      binding: BeratBadanBinding(),
    ),
    GetPage(
      name: _Paths.NAMA_BAYI,
      page: () => NamaBayiView(),
      binding: NamaBayiBinding(),
    ),
    GetPage(
      name: _Paths.SENAM,
      page: () => const SenamView(),
      binding: SenamBinding(),
    ),
    GetPage(
      name: _Paths.SENAM_AI,
      page: () {
        final args = Get.arguments as Map;

        return SenamAiView(
          camera: args['camera'],
          targetPose: args['pose'],
        );
      },
      binding: SenamAiBinding(),
    ),
    GetPage(
      name: _Paths.INFORMASI,
      page: () => InformasiView(),
      binding: InformasiBinding(),
    ),
    GetPage(
      name: _Paths.CRAVING,
      page: () => CravingView(),
      binding: CravingBinding(),
    ),
GetPage(
  name: '/tips-newborn',
  page: () => const TipsNewbornView(),
  binding: TipsNewbornBinding(),
),
    GetPage(
      name: _Paths.TAS_BERSALIN,
      page: () => const TasBersalinView(),
      binding: TasBersalinBinding(),
    ),
    GetPage(
      name: _Paths.KALKULATOR_BERSALIN,
      page: () => const KalkulatorBersalinView(),
      binding: KalkulatorBersalinBinding(),
    ),
    GetPage(
      name: _Paths.RIWAYAT_KEHAMILAN,
      page: () => const RiwayatKehamilanView(),
      binding: RiwayatKehamilanBinding(),
    ),
  ];
}
