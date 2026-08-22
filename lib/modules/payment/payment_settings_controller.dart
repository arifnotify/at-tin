import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tin/core/socket/socket_service.dart';
import 'package:tin/data/models/payment_settings_model.dart';
import 'package:tin/data/services/payment_settings_service.dart';

class PaymentSettingsController extends GetxController {
  final service = PaymentSettingsService();
  final _box = GetStorage(); // 📦 Local Storage Instance

  // Keys for Storage
  static const String _keyCod = 'cod_enabled';
  static const String _keySsl = 'ssl_enabled';

  RxBool codEnabled = false.obs;
  RxBool sslcommerzEnabled = false.obs;

  @override
  void onInit() {
    super.onInit();

    // 1️⃣ প্রথমে ক্যাশ (স্টোরেজ) থেকে আগে সেভ থাকা মান লোড করুন (ইনস্ট্যান্ট UI রেন্ডার)
    _loadFromStorage();

    // 2️⃣ ব্যাকগ্রাউন্ডে API থেকে লেটেস্ট সেটিংস ফ্যাচ করুন (সাইলেন্টলি)
    fetchPaymentSettings();

    // 3️⃣ 🔥 Socket Listener: অ্যাডমিন আপডেট করলে ব্যাকগ্রাউন্ডে সাইন-ইন হবে
    SocketService().listenPaymentSettingsUpdated(() {
      fetchPaymentSettings();
    });
  }

  /// 📦 লোকাল স্টোরেজ থেকে তাৎক্ষণিক মান রিড করা
  void _loadFromStorage() {
    codEnabled.value = _box.read(_keyCod) ?? false;
    sslcommerzEnabled.value = _box.read(_keySsl) ?? false;
  }

  /// 🌐 API থেকে ব্যাকগ্রাউন্ডে ডেটা এনে মেমোরি ও UI সাইলেন্টলি আপডেট করা
  Future<void> fetchPaymentSettings() async {
    try {
      final PaymentSettingsModel data = await service.getPaymentSettings();

      // স্টোরেজে সেভ করা
      _box.write(_keyCod, data.codEnabled);
      _box.write(_keySsl, data.sslcommerzEnabled);

      // UI স্টেট আপডেট করা
      codEnabled.value = data.codEnabled;
      sslcommerzEnabled.value = data.sslcommerzEnabled;

      print("✅ Payment Settings Silent Update Completed");
    } catch (e) {
      print("Payment Settings Error: $e");
    }
  }

  @override
  void onClose() {
    SocketService().removePaymentSettingsListener();
    super.onClose();
  }
}