import 'package:url_launcher/url_launcher.dart';

class UrlLauncherHelper {
  /// Open any URL (YouTube, website, etc.)
  static Future<void> openUrl(String url) async {
    final Uri uri = Uri.parse(url);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw "Could not launch $url";
      }
    } catch (e) {
      print("URL Launch Error: $e");
    }
  }

  /// Open YouTube specifically
  static Future<void> openYoutube(String url) async {
    final Uri uri = Uri.parse(url);

    try {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      print("YouTube open error: $e");
    }
  }

  /// Open phone dialer
  static Future<void> call(String phone) async {
    final Uri uri = Uri.parse("tel:$phone");

    await launchUrl(uri);
  }

  /// Open email app
  static Future<void> email(String email) async {
    final Uri uri = Uri.parse("mailto:$email");

    await launchUrl(uri);
  }
}