import 'package:clear_task/core/constants/colors.dart';
import 'package:clear_task/core/services/contact_service.dart';
import 'package:clear_task/core/utils/widgets/custom_container.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

class DeveloperInfoScreen extends StatelessWidget {
  const DeveloperInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Info'),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            HugeIcons.strokeRoundedArrowLeft01,
            size: 30,
            color: context.primaryFontColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryColor.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: CircleAvatar(
                    backgroundColor: context.cardColor,
                    radius: 45,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.asset('assets/images/nadim-corporate.png'),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Nadim Chowdhury',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: context.primaryFontColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Full-Stack Flutter Developer',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: context.secondaryFontColor,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 32),

            CustomContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About Me',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: context.primaryFontColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Passionate about building stunning, highly functional mobile applications with Flutter. I love creating tools that improve productivity and user experience.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: context.secondaryFontColor,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialButton(
                  context: context,
                  icon: HugeIcons.strokeRoundedGithub,
                  label: 'GitHub',
                  onTap: () => ContactService.openGithub(),
                ),
                const SizedBox(width: 16),
                _buildSocialButton(
                  context: context,
                  icon: HugeIcons.strokeRoundedLinkedin01,
                  label: 'LinkedIn',
                  onTap: () => ContactService.openLinkedin(),
                ),
              ],
            ),
            const SizedBox(height: 40),

            Text(
              '© 2026 ClearTask - Built with ❤️',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: context.secondaryFontColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: CustomContainer(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: AppColors.primaryColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: context.primaryFontColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
