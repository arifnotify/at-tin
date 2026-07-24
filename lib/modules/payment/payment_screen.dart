import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentDialog extends StatefulWidget {
  final String paymentUrl;

  const PaymentDialog({
    super.key,
    required this.paymentUrl,
  });

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  late final WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (mounted) setState(() => isLoading = true);
            _checkUrlAndPop(url);
          },
          onPageFinished: (url) {
            if (mounted) setState(() => isLoading = false);
            _checkUrlAndPop(url);
          },
          onWebResourceError: (error) {
            if (mounted) setState(() => isLoading = false);
          },
          onNavigationRequest: (request) {
            final isHandled = _checkUrlAndPop(request.url);
            if (isHandled) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  // 🎯 URL চেকিং এবং ডায়ালগ পপ করার কমন মেথড
  bool _checkUrlAndPop(String rawUrl) {
    final url = rawUrl.toLowerCase();

    // ==========================================
    // ১. PAYMENT SUCCESS (সফল হলে)
    // ==========================================
    if (url.contains("payments/success") || 
        url.contains("payment/success") || 
        url.contains("status=success") ||
        url.contains("ssl-success")) {
      if (mounted) {
        Navigator.of(context).pop(true); // true রিটার্ন করবে
      }
      return true;
    }

    // ==========================================
    // ২. PAYMENT FAILED / CANCEL (ফেইল বা ক্যানসেল হলে)
    // ==========================================
    if (url.contains("payments/fail") || 
        url.contains("payment/fail") || 
        url.contains("payments/cancel") || 
        url.contains("payment/cancel") || 
        url.contains("status=failed") || 
        url.contains("status=cancel")) {
      if (mounted) {
        Navigator.of(context).pop(false); // false রিটার্ন করবে
      }
      return true;
    }

    return false;
  }

  // পেমেন্ট ক্যানসেল কনফার্মেশন ডায়ালগ
  Future<bool> _showCancelConfirmation() async {
    final shouldClose = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Cancel Payment?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: const Text("আপনি কি পেমেন্ট বাতিল করে ফিরে যেতে চান?", style: TextStyle(fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("NO"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("YES", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    return shouldClose ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        bool confirm = await _showCancelConfirmation();
        if (confirm && context.mounted) {
          Navigator.of(context).pop(false);
        }
      },
      child: Dialog(
        backgroundColor: Colors.white,
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: SizedBox(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.68,
          child: Column(
            children: [
              // ================= Header Bar =================
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: const Color(0xFF1D4D33),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.lock_outline, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text(
                          "SSLCommerz Payment",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () async {
                        bool confirm = await _showCancelConfirmation();
                        if (confirm && context.mounted) {
                          Navigator.of(context).pop(false);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white24,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ),

              // ================= WebView Body =================
              Expanded(
                child: Stack(
                  children: [
                    WebViewWidget(controller: controller),
                    if (isLoading)
                      const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1D4D33)),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}