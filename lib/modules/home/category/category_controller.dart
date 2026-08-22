import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:tin/core/socket/socket_service.dart';
import 'package:tin/data/models/category_model.dart';
import 'package:tin/data/services/category_service.dart';

class CategoryController extends GetxController with WidgetsBindingObserver {
  final CategoryService _service = CategoryService();
  final SocketService _socketService = SocketService();

  // মেইন ক্যাটাগরি লিস্ট
  var categories = <CategoryModel>[].obs;

  // ক্যাটাগরি ID অনুযায়ী সাব-ক্যাটাগরির লিস্ট ম্যাপ আকারে সেভ থাকবে (ক্যাশ)
  var subCategoryMap = <String, List<CategoryModel>>{}.obs;

  // ব্যাকগ্রাউন্ড ট্র্যাকিং (যাতে একটি সাব-ক্যাটাগরি বারবার একই সাথে লোড না হয়)
  final Set<String> _loadingSubCategoryIds = {};

  @override
  void onInit() {
    super.onInit();
    
    // ১. ব্যাকগ্রাউন্ড লাইফসাইকেল অবজারভার রেজিস্টার
    WidgetsBinding.instance.addObserver(this);

    // ২. অ্যাপ চালুর সাথে সাথে ব্যাকগ্রাউন্ডে সব ডাটা ফেচ করে রাখবে
    fetchAllCategoriesAndSubCategories();

    // ৩. সকেট কানেক্ট ও রিফ্রেশ লিসেন করা
    _listenToCategoryUpdates();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print("⚡ CATEGORY: App resumed from background! Refreshing categories...");
      _socketService.connect();
      fetchAllCategoriesAndSubCategories();
    }
  }

  void _listenToCategoryUpdates() {
    _socketService.connect();

    _socketService.listenHomeUpdated((_) async {
      print("🔥 SOCKET: Category / Home Data Updated! Refreshing local categories...");
      await fetchAllCategoriesAndSubCategories();
    });
  }

  Future<void> fetchAllCategoriesAndSubCategories() async {
    try {
      final data = await _service.getMainCategories();

      if (data is List) {
        final mainList = data
            .map((e) => CategoryModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();

        categories.assignAll(mainList);
        categories.refresh();

        // প্যারালালে সাইলেন্টলি প্রতিটি ক্যাটাগরির সাব-ক্যাটাগরি ফেচ করা
        final subTasks = mainList.map((cat) => _fetchSubCategoriesSilently(cat.id));
        await Future.wait(subTasks);
        subCategoryMap.refresh();
      }
    } catch (e) {
      print("CATEGORY FETCH ERROR: $e");
    }
  }

  Future<void> _fetchSubCategoriesSilently(String parentId) async {
    if (parentId.isEmpty || _loadingSubCategoryIds.contains(parentId)) return;

    try {
      _loadingSubCategoryIds.add(parentId);
      final data = await _service.getSubCategories(parentId);
      if (data is List) {
        final subs = data
            .map((e) => CategoryModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();

        subCategoryMap[parentId] = subs;
        subCategoryMap.refresh();

        // রিকার্সিভলি সাব-ক্যাটাগরির ভেতরে আরও সাব-ক্যাটাগরি থাকলে তাও ফেচ করে নেওয়া
        for (var sub in subs) {
          _fetchSubCategoriesSilently(sub.id);
        }
      }
    } catch (e) {
      print("SUB CATEGORY FETCH ERROR ($parentId): $e");
    } finally {
      _loadingSubCategoryIds.remove(parentId);
    }
  }

  List<CategoryModel> getSubCategoriesById(String parentId) {
    if (!subCategoryMap.containsKey(parentId) && parentId.isNotEmpty) {
      Future.microtask(() => _fetchSubCategoriesSilently(parentId));
    }
    return subCategoryMap[parentId] ?? [];
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }
}