import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'views/home_view.dart';
import 'views/scan_view.dart';
import 'views/exanthems_overview_view.dart';
import 'views/benchmarks_view.dart';
import 'views/triage_history_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DermatriageApp());
}

class DermatriageApp extends StatelessWidget {
  const DermatriageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dermatriage - Exanthem Clinical Triage',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
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

    final pages = [
      HomeView(onNavigate: _navigateToTab),
      ScanView(
        key: ValueKey('scan_view_${_preloadedSampleAsset ?? "default"}'),
        preloadedAssetPath: _preloadedSampleAsset,
        preloadedClassName: _preloadedSampleClass,
      ),
      ExanthemsOverviewView(onSelectForScan: _navigateToScanWithSample),
      const BenchmarksView(),
      const TriageHistoryView(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFF006A6B),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.health_and_safety_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dermatriage',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'Cross-Attention Exanthem Classification',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFE6FFFA),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF26A69A).withValues(alpha: 0.4)),
            ),
            child: const Row(
              children: [
                Icon(Icons.hub_rounded, size: 14, color: Color(0xFF006A6B)),
                SizedBox(width: 6),
                Text(
                  'Dual-Branch CNN–ViT',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF006A6B),
                  ),
                ),
              ],
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: Row(
        children: [
          if (isDesktop)
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: _navigateToTab,
              labelType: NavigationRailLabelType.all,
              backgroundColor: Colors.white,
              selectedIconTheme: const IconThemeData(color: Color(0xFF006A6B)),
              selectedLabelTextStyle: const TextStyle(
                color: Color(0xFF006A6B),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
              unselectedLabelTextStyle: const TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
                fontSize: 11.5,
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
                  label: Text('Scan & Classify'),
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
          if (isDesktop) const VerticalDivider(thickness: 1, width: 1, color: Color(0xFFE2E8F0)),
          Expanded(child: pages[_currentIndex]),
        ],
      ),
      bottomNavigationBar: isDesktop
          ? null
          : NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: _navigateToTab,
              backgroundColor: Colors.white,
              indicatorColor: const Color(0xFFE6FFFA),
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
