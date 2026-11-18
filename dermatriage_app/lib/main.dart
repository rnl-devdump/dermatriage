import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'views/home_view.dart';
import 'views/scan_view.dart';
import 'views/exanthems_overview_view.dart';
import 'views/benchmarks_view.dart';
import 'views/triage_history_view.dart';
import 'services/inference_service.dart';
import 'widgets/poster.dart';

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
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
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

class _Workspace {
  final String label;
  final String shortLabel;
  final IconData icon;
  final IconData selectedIcon;
  const _Workspace(this.label, this.shortLabel, this.icon, this.selectedIcon);
}

const _workspaces = [
  _Workspace('Overview', 'Home', Icons.crop_portrait_outlined, Icons.crop_portrait),
  _Workspace('Scan & Triage', 'Scan', Icons.document_scanner_outlined, Icons.document_scanner),
  _Workspace('Exanthems', 'Exanthems', Icons.menu_book_outlined, Icons.menu_book),
  _Workspace('Benchmarks', 'Benchmarks', Icons.bar_chart_outlined, Icons.bar_chart),
  _Workspace('Records', 'Records', Icons.history_outlined, Icons.history),
];

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;
  String? _preloadedSampleAsset;
  String? _preloadedSampleClass;
  String? _openExanthemId;
  final InferenceService _inference = InferenceService();
  bool _checkingHealth = false;
  /// Once the overview scrolls, the header leaves the poster and turns solid.
  bool _homeScrolled = false;

  @override
  void initState() {
    super.initState();
    _checkServer();
  }

  Future<void> _checkServer() async {
    setState(() => _checkingHealth = true);
    await _inference.checkHealth();
    if (mounted) setState(() => _checkingHealth = false);
  }

  void _navigateToTab(int index) => setState(() {
        _currentIndex = index;
        _homeScrolled = false;
      });

  void _openExanthem(String id) => setState(() {
        _openExanthemId = id;
        _currentIndex = 2;
      });

  void _navigateToScanWithSample(String assetPath, String className) {
    setState(() {
      _preloadedSampleAsset = assetPath;
      _preloadedSampleClass = className;
      _currentIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 980;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onPoster = _currentIndex == 0 && !_homeScrolled;

    final pages = [
      HomeView(onNavigate: _navigateToTab, onOpenExanthem: _openExanthem, inference: _inference),
      ScanView(
        key: ValueKey('scan_view_${_preloadedSampleAsset ?? "default"}'),
        preloadedAssetPath: _preloadedSampleAsset,
        preloadedClassName: _preloadedSampleClass,
      ),
      ExanthemsOverviewView(
        key: ValueKey('exanthems_${_openExanthemId ?? "default"}'),
        initialId: _openExanthemId,
        onSelectForScan: _navigateToScanWithSample,
      ),
      const BenchmarksView(),
      TriageHistoryView(onNavigateToScan: () => _navigateToTab(1)),
    ];

    final header = _HeaderStrip(
      isDesktop: isDesktop,
      onPoster: onPoster,
      currentIndex: _currentIndex,
      onSelect: _navigateToTab,
      isOnline: _inference.isPyTorchServerOnline,
      missingWeights: _inference.isServerMissingWeights,
      checking: _checkingHealth,
      onRecheck: _checkServer,
    );

    final content = AnimatedSwitcher(
      duration: AppMotion.medium,
      switchInCurve: AppMotion.curve,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
      child: KeyedSubtree(key: ValueKey<int>(_currentIndex), child: pages[_currentIndex]),
    );

    return Scaffold(
      backgroundColor: isDark ? AppTheme.paperDark : AppTheme.paper,
      body: Stack(
        children: [
          // On the poster the header floats over the crumpled field; elsewhere
          // content starts below it.
          Positioned.fill(
            top: _currentIndex == 0 ? 0 : _HeaderStrip.heightFor(isDesktop),
            child: NotificationListener<ScrollNotification>(
              onNotification: (n) {
                if (_currentIndex == 0 && n.depth == 0) {
                  final scrolled = n.metrics.pixels > 24;
                  if (scrolled != _homeScrolled) setState(() => _homeScrolled = scrolled);
                }
                return false;
              },
              child: content,
            ),
          ),
          Positioned(left: 0, right: 0, top: 0, child: header),
        ],
      ),
      bottomNavigationBar: isDesktop
          ? null
          : DecoratedBox(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: isDark ? AppTheme.borderSubtleDark : AppTheme.borderSubtleLight)),
              ),
              child: NavigationBar(
                selectedIndex: _currentIndex,
                onDestinationSelected: _navigateToTab,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                destinations: [
                  for (final w in _workspaces)
                    NavigationDestination(icon: Icon(w.icon), selectedIcon: Icon(w.selectedIcon), label: w.shortLabel),
                ],
              ),
            ),
    );
  }
}

class _HeaderStrip extends StatelessWidget {
  final bool isDesktop;
  final bool onPoster;
  final int currentIndex;
  final ValueChanged<int> onSelect;
  final bool isOnline;
  final bool missingWeights;
  final bool checking;
  final VoidCallback onRecheck;

  const _HeaderStrip({
    required this.isDesktop,
    required this.onPoster,
    required this.currentIndex,
    required this.onSelect,
    required this.isOnline,
    required this.missingWeights,
    required this.checking,
    required this.onRecheck,
  });

  static double heightFor(bool desktop) => desktop ? 78 : 62;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = onPoster ? AppTheme.pale : (isDark ? AppTheme.pale : AppTheme.ink);
    final soft = onPoster
        ? AppTheme.pale.withValues(alpha: 0.78)
        : (isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight);
    final hairline = onPoster
        ? AppTheme.pale.withValues(alpha: 0.22)
        : (isDark ? AppTheme.borderSubtleDark : AppTheme.borderSubtleLight);
    final pad = isDesktop ? 40.0 : 20.0;

    return AnimatedContainer(
      duration: AppMotion.medium,
      curve: AppMotion.curve,
      height: heightFor(isDesktop),
      padding: EdgeInsets.symmetric(horizontal: pad),
      decoration: BoxDecoration(
        color: onPoster ? Colors.transparent : (isDark ? AppTheme.paperDark : AppTheme.paper),
        border: Border(bottom: BorderSide(color: hairline)),
      ),
      child: Row(
        children: [
          // Stacked wordmark
          Semantics(
            header: true,
            label: 'Dermatriage',
            child: ExcludeSemantics(
              child: InkWell(
                onTap: () => onSelect(0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Display('DERMA', size: isDesktop ? 24 : 20, color: ink, height: 0.82),
                    Display('TRIAGE', size: isDesktop ? 24 : 20, color: ink, height: 0.82),
                  ],
                ),
              ),
            ),
          ),
          if (isDesktop) ...[
            const SizedBox(width: 48),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < _workspaces.length; i++)
                    _NavLink(
                      label: _workspaces[i].label,
                      selected: i == currentIndex,
                      color: ink,
                      soft: soft,
                      onTap: () => onSelect(i),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 24),
          ] else
            const Spacer(),
          _EngineStatus(isOnline: isOnline, missingWeights: missingWeights, checking: checking, onTap: onRecheck, color: ink, compact: !isDesktop),
          const SizedBox(width: 8),
          IconButton(
            tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
            onPressed: () => DermatriageApp.of(context)?.toggleTheme(),
            icon: AnimatedSwitcher(
              duration: AppMotion.medium,
              transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
              child: Icon(
                isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                key: ValueKey<bool>(isDark),
                size: 20,
                color: ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  final String label;
  final bool selected;
  final Color color;
  final Color soft;
  final VoidCallback onTap;

  const _NavLink({required this.label, required this.selected, required this.color, required this.soft, required this.onTap});

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.selected || _hover;
    return Semantics(
      button: true,
      selected: widget.selected,
      child: InkWell(
        onTap: widget.onTap,
        onHover: (h) => setState(() => _hover = h),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label.toUpperCase(),
                style: AppTheme.labelStyle(active ? widget.color : widget.soft, tracking: 0.6)
                    .copyWith(fontWeight: widget.selected ? FontWeight.w400 : FontWeight.w300),
              ),
              const SizedBox(height: 6),
              AnimatedContainer(
                duration: AppMotion.fast,
                height: 1,
                width: widget.selected ? 28 : (_hover ? 14 : 0),
                color: widget.color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EngineStatus extends StatelessWidget {
  final bool isOnline;
  final bool missingWeights;
  final bool checking;
  final VoidCallback onTap;
  final Color color;
  final bool compact;

  const _EngineStatus({required this.isOnline, required this.missingWeights, required this.checking, required this.onTap, required this.color, required this.compact});

  @override
  Widget build(BuildContext context) {
    final label = isOnline
        ? (compact ? 'Server' : 'PyTorch server')
        : missingWeights
            ? (compact ? 'No weights' : 'Server has no weights')
            : (compact ? 'Offline' : 'Offline estimate');
    return Tooltip(
      message: isOnline
          ? 'Connected to the PyTorch server. Tap to check again.'
          : missingWeights
              ? 'The model server is up but has no trained weights loaded, so the offline estimate is used. Tap to check again.'
              : 'Server unreachable: using the offline Dart estimate. Tap to check again.',
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (checking)
                SizedBox(width: 9, height: 9, child: CircularProgressIndicator(strokeWidth: 1.4, color: color))
              else
                // Filled when the server answers, a hollow ring when the offline
                // estimate is in use; urgency colours stay reserved for triage.
                Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isOnline ? color : null,
                    border: isOnline ? null : Border.all(color: color, width: 1.2),
                  ),
                ),
              const SizedBox(width: 8),
              Text(label.toUpperCase(), style: AppTheme.labelStyle(color, size: 11.2, tracking: 0.5)),
            ],
          ),
        ),
      ),
    );
  }
}
