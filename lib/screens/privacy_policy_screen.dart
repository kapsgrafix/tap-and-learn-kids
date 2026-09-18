import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A full-page Privacy Policy & Terms screen the child (or, more likely,
/// their parent) can open from the Home screen and close again. Content is
/// written to match what Nimble Kids actually does — see each paragraph —
/// which keeps it both honest and straightforward for Play Store / Google
/// Play Families Policy review.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgYellow,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 42,
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Privacy Policy',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppTheme.boldHeadingFontFamily,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 72),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          _PolicySection(
                            title: 'Overview',
                            body:
                                'Nimble Kids is an offline learning game for young children. '
                                'This policy explains, in plain language, what the app does '
                                'and does not do with information, so parents can feel '
                                'confident letting their child play.',
                          ),
                          _PolicySection(
                            title: 'No data collection',
                            body:
                                'Nimble Kids does not collect, store, transmit, or share any '
                                'personal information, and does not require an account, sign-in, '
                                'or profile of any kind. The app has no analytics, tracking, or '
                                'crash-reporting tools built in.',
                          ),
                          _PolicySection(
                            title: 'No internet access',
                            body:
                                'Nimble Kids works completely offline. It does not request '
                                'internet (network) permission and cannot send or receive any '
                                'data over the internet — everything the app needs (pictures, '
                                'sounds, and words) is bundled inside the app itself.',
                          ),
                          _PolicySection(
                            title: 'No advertising',
                            body:
                                'Nimble Kids contains no advertising and no third-party '
                                'advertising SDKs of any kind.',
                          ),
                          _PolicySection(
                            title: 'No in-app purchases',
                            body:
                                'Nimble Kids has no in-app purchases, subscriptions, or any way '
                                'to spend money inside the app.',
                          ),
                          _PolicySection(
                            title: 'Children\'s privacy (COPPA)',
                            body:
                                'Nimble Kids is designed for young children and is built to be '
                                'compliant with the Children\'s Online Privacy Protection Act '
                                '(COPPA) and Google Play Families Policy: it collects no '
                                'personal information from anyone, of any age.',
                          ),
                          _PolicySection(
                            title: 'Permissions',
                            body:
                                'Nimble Kids does not request access to your camera, microphone, '
                                'contacts, location, storage, or any other device permission '
                                'beyond what is needed to simply run the app and play sound.',
                          ),
                          _PolicySection(
                            title: 'Changes to this policy',
                            body:
                                'If this policy ever changes, the updated version will be '
                                'posted here, inside the app, with a new "last updated" date.',
                          ),
                          _PolicySection(
                            title: 'Contact us',
                            body:
                                'If you have any questions about this policy, please contact us '
                                'at kapsgrafix@gmail.com.',
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Last updated: September 2026',
                            style: TextStyle(
                              fontFamily: AppTheme.bodyFontFamily,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandCoral,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        fontFamily: AppTheme.headingFontFamily,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String title;
  final String body;

  const _PolicySection({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: AppTheme.headingFontFamily,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.brandCoral,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: const TextStyle(
              fontFamily: AppTheme.bodyFontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.4,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
