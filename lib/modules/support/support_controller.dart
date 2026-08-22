import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tin/core/socket/socket_service.dart';
import 'package:tin/data/models/support_model.dart';
import 'package:tin/data/services/support_service.dart';

class SupportController extends GetxController {
  final service = SupportService();
  final _box = GetStorage(); // GetStorage Instance
  final String _storageKey = 'support_links_data';

  RxBool isLoading = false.obs;
  Rxn<SupportLinkModel> support = Rxn<SupportLinkModel>();

  @override
  void onInit() {
    super.onInit();

    // ১. প্রথমে ক্যাশ/লোকাল স্টোরেজ থেকে দ্রুত ডাটা লোড করা
    _loadFromStorage();

    // ২. সার্ভার থেকে লেটেস্ট ডাটা ফেচ করা
    loadSupportLinks();

    // Socket Listener
    SocketService().listenSupportLinksUpdated(() {
      print("📞 Support links updated");
      loadSupportLinks();
    });
  }

  // লোকাল স্টোরেজ থেকে রিড করার মেথড
  void _loadFromStorage() {
    final cachedData = _box.read(_storageKey);
    if (cachedData != null) {
      // String বা Map থেকে Model এ কনভার্ট করা
      final decodedData = cachedData is String ? jsonDecode(cachedData) : cachedData;
      support.value = SupportLinkModel.fromJson(decodedData);
    }
  }

  Future<void> loadSupportLinks() async {
    try {
      // যদি লোকাল ডাটা না থাকে কেবল তখনই ফুল স্ক্রিন লোডার দেখাবে
      if (support.value == null) {
        isLoading.value = true;
      }

      final data = await service.getSupportLinks();

      // Model আপডেট
      support.value = SupportLinkModel.fromJson(data);

      // ৩. লোকাল স্টোরেজে নতুন ডাটা সেভ করা (Cache Update)
      _box.write(_storageKey, data);
    } catch (e) {
      print("Error loading support links: $e");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    SocketService().socket?.off('support_links_updated');
    super.onClose();
  }
}