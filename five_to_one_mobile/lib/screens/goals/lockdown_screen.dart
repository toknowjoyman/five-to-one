import 'package:flutter/material.dart';
import 'dart:ui';
import '../../theme/app_theme.dart';

class LockdownScreen extends StatefulWidget {
  final List<String> topFive;
  final List<String> avoidList;
  final VoidCallback onComplete;

  const LockdownScreen({
    super.key,
    required this.topFive,
    required this.avoidList,
    required this.onComplete,
  });

  @override
  State<LockdownScreen> createState() => _LockdownScreenState();
}

class _LockdownScreenState extends State<LockdownScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _nextPage() {
    if (_currentPage == 0) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        children: [
          _buildTopFiveScreen(),
          _buildAvoidListScreen(),
        ],
      ),
    );
  }

  Widget _buildTopFiveScreen() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryPurple.withOpacity(0.4),
            AppTheme.darkBackground,
            AppTheme.accentOrange.withOpacity(0.3),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Title
              Text(
                'These 5.',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.accentOrange,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                'Nothing else.',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: 28,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Top 5 list
              ...widget.topFive.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPurple.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.accentOrange.withOpacity(0.6),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: AppTheme.accentOrange,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${entry.key + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),

              const Spacer(),

              // Continue button
              Column(
                children: [
                  Text(
                    'Swipe up to continue',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Icon(
                    Icons.keyboard_arrow_up,
                    color: AppTheme.textSecondary,
                    size: 32,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: _nextPage,
                child: const Text('Continue'),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvoidListScreen() {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.darkBackground,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Title
              Text(
                'AVOID AT ALL COSTS',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.urgentRed,
                  letterSpacing: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Blurred avoid list
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.avoidGray.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: ListView.builder(
                        itemCount: widget.avoidList.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Opacity(
                              opacity: 0.4,
                              child: Text(
                                '${index + 6}. ${widget.avoidList[index]}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  decoration: TextDecoration.lineThrough,
                                  color: AppTheme.avoidGray,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Quote
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.cardBackground.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '"Trade in your hours\nfor a handful of dimes"',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 24),

              // Explanation
              Text(
                'These ${widget.avoidList.length} goals are now locked.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                'You cannot work on them until\nyou complete your top 5.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                "They're not bad goals.\nThey're distractions.",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppTheme.urgentRed,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Got it button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onComplete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentOrange,
                  ),
                  child: const Text('Got it →'),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
