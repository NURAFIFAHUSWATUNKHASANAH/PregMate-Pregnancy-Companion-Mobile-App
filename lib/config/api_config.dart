class ApiConfig {
  static String _baseUrl = '';

  // Getter untuk baseUrl
  static String get baseUrl => _baseUrl;

  // Setter untuk baseUrl (dengan normalisasi)
  static set baseUrl(String url) {
    _baseUrl = url.trim();
    if (_baseUrl.endsWith('/')) {
      _baseUrl = _baseUrl.substring(0, _baseUrl.length - 1);
    }
    print('Base URL updated to: $_baseUrl');

  }
  
  // Inisialisasi baseUrl default
  static void init() {
    _baseUrl = 'https://web-production-60f9.up.railway.app';
    print('Base URL updated to: $_baseUrl');
  }
  // ---------------- Auth ----------------
  static String get registerUrl => '$_baseUrl/auth/register';
  static String get loginUrl => '$_baseUrl/auth/login';
  static String get loginGoogleUrl => '$_baseUrl/auth/google';

  // ---------------- User ----------------
  static String userProfileUrl(String userId) => '$_baseUrl/user/$userId';
  static String uploadProfilePictureUrl(String userId )=> '$_baseUrl/static/images/uploads/profile_pictures/';
  static String updateUserUrl(String userId) => '$_baseUrl/user/$userId';

  // ---------------- Histori ----------------
// ---------------- Histori ----------------
static String get historiUrl => '$_baseUrl/histori';

// ambil histori per kehamilan
static String historiByUserAndPregnancy(
  String userId,
  String kehamilanId,
) {
  return '$_baseUrl/histori/$userId/$kehamilanId';
}

// ambil statistik per kehamilan
static String historiStats(
  String userId,
  String kehamilanId,
) {
  return '$_baseUrl/histori/stats/$userId/$kehamilanId';
}
  // ---------------- Artikel ----------------
  static String get artikelUrl => '$_baseUrl/api/artikel';
  static String artikelDetailUrl(String id) => '$artikelUrl/$id';

  // ---------------- Jadwal (contoh tambahan) ----------------
  static String get jadwalUrl => '$_baseUrl/jadwal';
    // ---------------- Token ----------------
  static String get updateTokenUri => '$_baseUrl/update_token';

  // ---------------- Forgot Password ----------------
  static String get forgotPasswordUrl => '$_baseUrl/forgot_password';


  static String get verifyOtpUrl => '$_baseUrl/auth/verify-otp';

  // ---------------- Diskusi ----------------
static String get diskusiUrl => '$_baseUrl/diskusi';
static String commentUrl(String postId) => '$_baseUrl/diskusi/comment/$postId';
static String likeUrl(String postId) => '$_baseUrl/diskusi/like/$postId';

// ---------------- Pregnancy ----------------
static String get pregnancyDashboardUrl => '$_baseUrl/pregnancy/dashboard';
static String get pregnancyValidateUrl => '$_baseUrl/pregnancy/validate';
static String get pregnancyDashboardPasanganUrl => '$_baseUrl/pregnancy/dashboard/pasangan';

// ---------------- Baby Name AI ----------------
static String get generateBabyNameUrl => '$_baseUrl/ai/babyname';
static String get babyNameFavoriteUrl => '$_baseUrl/babyname/favorite';
static String deleteBabyNameFavoriteUrl(String name) => '$_baseUrl/babyname/favorite/$name';

// ---------------- Mood / Recommendation ----------------
static String get moodRecommendationUrl => '$_baseUrl/ai/recommendation';

// ---------------- KALKULATOR ----------------
static String get kalkulatorSaveUrl => '$_baseUrl/kalkulator/save';
static String get kalkulatorDashboardUrl => '$_baseUrl/kalkulator/dashboard';
static String get kalkulatorTabungUrl => '$_baseUrl/kalkulator/tabung';
static String get kalkulatorPengeluaranUrl => '$_baseUrl/kalkulator/pengeluaran';

static String get tasBersalinUrl => '$_baseUrl/tasbersalin';
static String get tasBersalinToggleUrl => '$_baseUrl/tasbersalin/toggle';

static String get tipsNewbornUrl => '$_baseUrl/tips-newborn';
static String tipsNewbornDetailUrl(String id) => '$_baseUrl/tips-newborn/$id';
}