import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';

class ContactService {
  static const String developerEmail = 'nadimm.dev@gmail.com';
  static const String githubUrl = 'https://github.com/DevNadimm';
  static const String linkedinUrl = 'https://www.linkedin.com/in/devnadimm/';

  static Future<void> reportBug() async {
    final String subject = Uri.encodeComponent('Bug Report: ClearTask App');
    final Uri emailLaunchUri = Uri.parse('mailto:$developerEmail?subject=$subject');

    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback for some devices where canLaunchUrl returns false
        await launchUrl(emailLaunchUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launching bug report email: $e');
    }
  }

  static Future<void> openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  static Future<void> openGithub() => openUrl(githubUrl);
  static Future<void> openLinkedin() => openUrl(linkedinUrl);
}
