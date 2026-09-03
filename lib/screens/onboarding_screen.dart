import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_strings.dart';
import 'home_screen.dart';

class _OnboardingSlide {
  final String image;
  final String titleKey;
  final String subtitleKey;
  const _OnboardingSlide({required this.image, required this.titleKey, required this.subtitleKey});
}

const _slides = [
  _OnboardingSlide(
    image: 'assets/images/onboarding_over_100_duas.png',
    titleKey: 'onboard_1_title',
    subtitleKey: 'onboard_1_subtitle',
  ),
  _OnboardingSlide(
    image: 'assets/images/onboarding_bookmarked_dua.png',
    titleKey: 'onboard_2_title',
    subtitleKey: 'onboard_2_subtitle',
  ),
  _OnboardingSlide(
    image: 'assets/images/onboarding_set_reminder.png',
    titleKey: 'onboard_3_title',
    subtitleKey: 'onboard_3_subtitle',
  ),
  _OnboardingSlide(
    image: 'assets/images/onboarding_download_dua.png',
    titleKey: 'onboard_4_title',
    subtitleKey: 'onboard_4_subtitle',
  ),
];

/// Matches the old app's 4-slide first-run walkthrough (Figma "Initial
/// onboarding" frames): Over 100 Duas / Bookmarked Dua / Set Reminder /
/// Download Dua. Shown once — see [hasCompletedOnboarding].
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_complete') ?? false;
  }

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  void _next() {
    if (_page == _slides.length - 1) {
      _finish();
    } else {
      _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isLast = _page == _slides.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Opacity(
                  opacity: isLast ? 0 : 1,
                  child: IgnorePointer(
                    ignoring: isLast,
                    child: TextButton(onPressed: _finish, child: Text(AppStrings.of(context, 'skip'))),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) {
                  final s = _slides[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(s.image, height: 220),
                        const SizedBox(height: 32),
                        Text(
                          AppStrings.of(context, s.titleKey),
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          AppStrings.of(context, s.subtitleKey),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                              ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(_slides.length, (i) {
                      final active = i == _page;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 6),
                        width: active ? 20 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: active ? scheme.primary : scheme.primary.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: scheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                    ),
                    onPressed: _next,
                    child: Text(isLast ? AppStrings.of(context, 'finish') : AppStrings.of(context, 'next')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
