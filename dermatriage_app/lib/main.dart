import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'views/home_view.dart';
import 'views/scan_view.dart';
import 'views/exanthems_overview_view.dart';
import 'views/benchmarks_view.dart';
import 'views/triage_history_view.dart';
import 'services/inference_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DermatriageApp());
}

class DermatriageApp extends StatefulWidget {
  const DermatriageApp({super.key});

  static DermatriageAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<DermatriageAppState>();

  @override
  State<DermatriageApp> createState() => DermatriageAppState();
}

class DermatriageAppState extends State<DermatriageApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dermatriage - Exanthem Clinical Triage',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: const MainNavigationShell(),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;
  String? _preloadedSampleAsset;
  String? _preloadedSampleClass;
  final InferenceService _inference = InferenceService();
  bool _checkingHealth = false;

  @override
  void initState() {
    super.initState();
    _checkServer();
  }

  Future<void> _checkServer() async {
    setState(() => _checkingHealth = true);
    await _inference.checkHealth();
    if (mounted) {
      setState(() => _checkingHealth = false);
    }
  }

  void _navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _navigateToScanWithSample(String assetPath, String className) {
    setState(() {
      _preloadedSampleAsset = assetPath;
      _preloadedSampleClass = className;
      _currentIndex = 1; // Switch to Scan tab
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isOnline = _inference.isPyTorchServerOnline;

    final pages = [
      HomeView(onNavigate: _navigateToTab),
      ScanView(
        key: ValueKey('scan_view_${_preloadedSampleAsset ?? "default"}'),
        preloadedAssetPath: _preloadedSampleAsset,
        preloadedClassName: _preloadedSampleClass,
      ),
      ExanthemsOverviewView(onSelectForScan: _navigateToScanWithSample),
      const BenchmarksView(),
      TriageHistoryView(onNavigateToScan: () => _navigateToTab(1)),
    ];

    return Scaffold(
      appBar: AppBar(
        titleSpacing: width < 500 ? 12 : 16,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.tealAccentDark : AppTheme.primaryTeal,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color:
                        (isDark
                                ? AppTheme.tealAccentDark
                                : AppTheme.primaryTeal)
                            .withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.health_and_safety_rounded,
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Dermatriage',
                  style: TextStyle(
                    fontSize: 17.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: isDark
                        ? AppTheme.textPrimaryDark
                        : AppTheme.textPrimaryLight,
                  ),
                ),
                if (width >= 620)
                  Text(
                    'Cross-Attention Exanthem Decision Support',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppTheme.textMutedDark
                          : AppTheme.textSecondaryLight,
                    ),
                  ),
              ],
            ),
          ],
        ),
        actions: [
          // Engine Status Indicator Pill
          InkWell(
            onTap: _checkServer,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              padding: EdgeInsets.symmetric(
                horizontal: width < 600 ? 8 : 11,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: isOnline
                    ? (isDark
                          ? const Color(0xFF064E3B)
                          : const Color(0xFFECFDF5))
                    : (isDark
                          ? const Color(0xFF451A03)
                          : const Color(0xFFFFFBEB)),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isOnline
                      ? (isDark
                            ? const Color(0xFF059669)
                            : const Color(0xFF6EE7B7))
                      : (isDark
                            ? const Color(0xFFD97706)
                            : const Color(0xFFFCD34D)),
                  width: 1.1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_checkingHealth)
                    SizedBox(
                      width: 11,
                      height: 11,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.8,
                        color: isOnline
                            ? const Color(0xFF059669)
                            : const Color(0xFFD97706),
                      ),
                    )
                  else
                    Icon(
                      isOnline
                          ? Icons.bolt_rounded
                          : Icons.offline_bolt_rounded,
                      size: 13,
                      color: isOnline
                          ? const Color(0xFF059669)
                          : const Color(0xFFD97706),
                    ),
                  if (width >= 550) ...[
                    const SizedBox(width: 5),
                    Text(
                      isOnline ? 'PyTorch Server' : 'Standalone Dart',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isOnline
                            ? const Color(0xFF059669)
                            : const Color(0xFFD97706),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Dark / Light Mode Toggle Button
          IconButton(
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            icon: AnimatedSwitcher(
              duration: AppMotion.medium,
              transitionBuilder: (child, anim) => RotationTransition(
                turns: anim,
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                key: ValueKey<bool>(isDark),
                size: 20,
                color: isDark
                    ? const Color(0xFFFBBF24)
                    : const Color(0xFF475569),
              ),
            ),
            onPressed: () {
              DermatriageApp.of(context)?.toggleTheme();
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: isDark
                ? AppTheme.borderFocusedDark
                : AppTheme.borderSubtleLight,
            height: 1,
          ),
        ),
      ),
      body: Row(
        children: [
          if (isDesktop)
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: _navigateToTab,
              labelType: NavigationRailLabelType.all,
              backgroundColor: isDark ? AppTheme.cardDark : Colors.white,
              selectedIconTheme: IconThemeData(
                color: isDark ? AppTheme.tealAccentDark : AppTheme.primaryTeal,
              ),
              unselectedIconTheme: IconThemeData(
                color: isDark
                    ? AppTheme.textMutedDark
                    : const Color(0xFF64748B),
              ),
              selectedLabelTextStyle: TextStyle(
                color: isDark ? AppTheme.tealAccentDark : AppTheme.primaryTeal,
                fontWeight: FontWeight.w700,
                fontSize: 11.5,
              ),
              unselectedLabelTextStyle: TextStyle(
                color: isDark
                    ? AppTheme.textMutedDark
                    : const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard_rounded),
                  label: Text('Overview'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.document_scanner_outlined),
                  selectedIcon: Icon(Icons.document_scanner_rounded),
                  label: Text('Scan & Triage'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.menu_book_outlined),
                  selectedIcon: Icon(Icons.menu_book_rounded),
                  label: Text('Exanthems'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.bar_chart_outlined),
                  selectedIcon: Icon(Icons.bar_chart_rounded),
                  label: Text('Benchmarks'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.history_outlined),
                  selectedIcon: Icon(Icons.history_rounded),
                  label: Text('Records'),
                ),
              ],
            ),
          if (isDesktop)
            VerticalDivider(
              thickness: 1,
              width: 1,
              color: isDark
                  ? AppTheme.borderFocusedDark
                  : AppTheme.borderSubtleLight,
            ),
          // Fluid Animated Tab Switching
          Expanded(
            child: AnimatedSwitcher(
              duration: AppMotion.medium,
              switchInCurve: AppMotion.curve,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.015, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: KeyedSubtree(
                key: ValueKey<int>(_currentIndex),
                child: pages[_currentIndex],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: isDesktop
          ? null
          : NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: _navigateToTab,
              backgroundColor: isDark ? AppTheme.cardDark : Colors.white,
              indicatorColor: isDark
                  ? AppTheme.primaryTeal.withValues(alpha: 0.3)
                  : const Color(0xFFE6FFFA),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard_rounded),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.document_scanner_outlined),
                  selectedIcon: Icon(Icons.document_scanner_rounded),
                  label: 'Scan',
                ),
                NavigationDestination(
                  icon: Icon(Icons.menu_book_outlined),
                  selectedIcon: Icon(Icons.menu_book_rounded),
                  label: 'Exanthems',
                ),
                NavigationDestination(
                  icon: Icon(Icons.bar_chart_outlined),
                  selectedIcon: Icon(Icons.bar_chart_rounded),
                  label: 'Benchmarks',
                ),
                NavigationDestination(
                  icon: Icon(Icons.history_outlined),
                  selectedIcon: Icon(Icons.history_rounded),
                  label: 'Records',
                ),
              ],
            ),
    );
  }
}
