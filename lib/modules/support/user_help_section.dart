import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tin/modules/support/support_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class UserHelpSection
    extends StatelessWidget {
  const UserHelpSection({
    super.key,
  });

  Future<void> openLink(
    String url,
  ) async {
    if (url.isEmpty) return;

    await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> callPhone(
    String phone,
  ) async {
    if (phone.isEmpty) return;

    await launchUrl(
      Uri.parse("tel:$phone"),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller =
        Get.put(
      SupportController(),
    );

    return Obx(() {
      if (controller.isLoading.value) {
        return const SizedBox();
      }

      final support =
          controller.support.value;

      if (support == null) {
        return const SizedBox();
      }

      return Container(
        width: double.infinity,
        margin:
            const EdgeInsets.symmetric(
          vertical: 10,
        ),
        padding:
            const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(
            0xffF5F5F5,
          ),
          borderRadius:
              BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              "Need help?",
              style: TextStyle(
                fontSize: 28,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _HelpButton(
                    icon: Icons.call,
                    title: "Call",
                    onTap: () {
                      callPhone(
                        support.phone,
                      );
                    },
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _HelpButton(
                    icon: Icons.message,
                    title: "WhatsApp",
                    onTap: () {
                      openLink(
                        support.whatsapp,
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _HelpButton(
                    icon: Icons.facebook,
                    title: "Facebook",
                    onTap: () {
                      openLink(
                        support.facebook,
                      );
                    },
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _HelpButton(
                    icon: Icons.camera_alt,
                    title: "Instagram",
                    onTap: () {
                      openLink(
                        support.instagram,
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Center(
              child: SizedBox(
                width: 180,
                child: _HelpButton(
                  icon: Icons.forum,
                  title: "Messenger",
                  onTap: () {
                    openLink(
                      support.messenger,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _HelpButton
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _HelpButton({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius:
          BorderRadius.circular(40),
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(
            40,
          ),
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color:
                  Colors.deepPurple,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color:
                    Colors.deepPurple,
                fontWeight:
                    FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}