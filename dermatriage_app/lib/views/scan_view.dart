import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import '../services/inference_service.dart';
import '../services/history_service.dart';
import '../models/triage_result.dart';
import '../widgets/probability_bar_widget.dart';
import '../widgets/attention_heatmap_widget.dart';
import '../widgets/sample_selector_dialog.dart';
import '../theme/app_theme.dart';
import '../widgets/poster.dart';

class ScanView extends StatefulWidget {
  final String? preloadedAssetPath;
  final String? preloadedClassName;

  const ScanView({super.key, this.preloadedAssetPath, this.preloadedClassName});

  @override
  State<ScanView> createState() => _ScanViewState();
}

class _ScanViewState extends State<ScanView>
    with SingleTickerProviderStateMixin {
  final InferenceService _inference = InferenceService();
  final HistoryService _history = HistoryService();

  Uint8List? _selectedImageBytes;
  String? _selectedFileName;
  String? _selectedAssetPath;
  String? _knownGroundTruth;

  bool _isScanning = false;
  TriageResult? _triageResult;
  String? _errorMessage;

  late AnimationController _scanAnimController;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _scanAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanAnimController, curve: Curves.easeInOut),
    );

    _inference.checkHealth().then((_) {
      if (mounted) setState(() {});
    });

    if (widget.preloadedAssetPath != null) {
      _loadSampleAsset(widget.preloadedAssetPath!, widget.preloadedClassName);
    }
  }

  @override
  void dispose() {
    _scanAnimController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFile() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
      );

      if (files.isNotEmpty) {
        final file = files.first;
        final bytes = await file.xFile.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
          _selectedFileName = file.name;
          _selectedAssetPath = null;
          _knownGroundTruth = null;
          _triageResult = null;
          _errorMessage = null;
        });
        _executeClassification();
      }
    } catch (e) {
      setState(() => _errorMessage = 'Failed to load selected image: $e');
    }
  }

  Future<void> _loadSampleAsset(String assetPath, [String? className]) async {
    try {
      final ByteData data = await rootBundle.load(assetPath);
      final bytes = data.buffer.asUint8List();
      setState(() {
        _selectedImageBytes = bytes;
        _selectedFileName = assetPath.split('/').last;
        _selectedAssetPath = assetPath;
        _knownGroundTruth = className;
        _triageResult = null;
        _errorMessage = null;
      });
      _executeClassification();
    } catch (e) {
      setState(() => _errorMessage = 'Failed to load test sample: $e');
    }
  }

  Future<void> _executeClassification() async {
    if (_selectedImageBytes == null) return;

    setState(() {
      _isScanning = true;
      _errorMessage = null;
    });

    try {
      final result = await _inference.classify(
        imageBytes: _selectedImageBytes!,
        sampleFileName: _selectedFileName,
        knownGroundTruth: _knownGroundTruth,
      );

      _history.addRecord(result);

      setState(() {
        _triageResult = result;
        _isScanning = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Classification error: $e';
        _isScanning = false;
      });
    }
  }

  void _showSamplePicker() {
    showDialog(
      context: context,
      builder: (_) => SampleSelectorDialog(
        onSelectSample: (assetPath, className) {
          _loadSampleAsset(assetPath, className);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isOnline = _inference.isPyTorchServerOnline;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobilePadding = screenWidth < 600;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.backgroundDark
          : AppTheme.backgroundLight,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isMobilePadding ? 20 : 40,
          vertical: isMobilePadding ? 24 : 40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Engine Connectivity & Header Bar
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 700;

                final titleColumn = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Display(
                      'Scan & Triage',
                      size: isCompact ? 52 : 84,
                      height: 0.86,
                      color: isDark ? AppTheme.pale : AppTheme.ink,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Upload a lesion photo or pick a verified test case. The dual-branch model classifies it and shows where it looked.',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.3,
                        fontWeight: FontWeight.w300,
                        color: isDark
                            ? AppTheme.textSecondaryDark
                            : AppTheme.textSecondaryLight,
                      ),
                    ),
                  ],
                );

                final ink = isDark ? AppTheme.pale : AppTheme.ink;
                final statusBadge = Semantics(
                  button: true,
                  label: isOnline ? 'PyTorch server connected. Check again.' : 'Offline Dart estimate in use. Check the server again.',
                  child: InkWell(
                    onTap: () async {
                      await _inference.checkHealth();
                      setState(() {});
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: isDark ? AppTheme.borderSubtleDark : AppTheme.borderSubtleLight),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isOnline ? (isDark ? AppTheme.tealAccentDark : AppTheme.primaryTeal) : null,
                              border: isOnline ? null : Border.all(color: ink, width: 1.2),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              PosterLabel(
                                isOnline
                                    ? 'PyTorch server'
                                    : (_inference.isServerMissingWeights ? 'Server has no weights' : 'Offline estimate'),
                                color: ink,
                                size: 11.2,
                                tracking: 0.5,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                isOnline
                                    ? 'Tap to check again'
                                    : (_inference.isServerMissingWeights
                                        ? 'Trained weights not loaded. Using the offline estimate'
                                        : 'Server unreachable. Tap to check again'),
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );

                if (isCompact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      titleColumn,
                      const SizedBox(height: 12),
                      statusBadge,
                    ],
                  );
                } else {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: titleColumn),
                      const SizedBox(width: 12),
                      statusBadge,
                    ],
                  );
                }
              },
            ),

            const SizedBox(height: 20),

            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF450A0A)
                      : const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.zero,
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF991B1B)
                        : const Color(0xFFFCA5A5),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Color(0xFFDC2626),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFFFECACA)
                              : const Color(0xFF991B1B),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Responsive Layout: Side-by-side on desktop, single-column stacked on mobile/tablet
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 880;
                final intakeHeight = isWide ? 400.0 : 320.0;

                final intakeColumn = Column(
                  children: [
                    _buildImageIntakeBox(intakeHeight, isDark),
                    const SizedBox(height: 16),
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _pickImageFile,
                            icon: const Icon(
                              Icons.file_upload_outlined,
                              size: 18,
                            ),
                            label: const Text('Upload Photo'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _showSamplePicker,
                            icon: const Icon(
                              Icons.collections_rounded,
                              size: 18,
                            ),
                            label: const Text('Test Samples'),
                          ),
                        ),
                      ],
                    ),
                    if (_selectedImageBytes != null) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isScanning
                              ? null
                              : _executeClassification,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          icon: _isScanning
                              ? SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Theme.of(context).colorScheme.onPrimary,
                                  ),
                                )
                              : const Icon(Icons.refresh_rounded, size: 18),
                          label: Text(
                            _isScanning
                                ? 'Classifying…'
                                : 'Classify again',
                          ),
                        ),
                      ),
                    ],
                  ],
                );

                final resultColumn = AnimatedSwitcher(
                  duration: AppMotion.fluid,
                  switchInCurve: AppMotion.curve,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.03),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: _triageResult == null
                      ? _buildEmptyState(isDark)
                      : _buildTriageResultCard(_triageResult!, isDark),
                );

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 5, child: intakeColumn),
                      const SizedBox(width: 24),
                      Expanded(flex: 7, child: resultColumn),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      intakeColumn,
                      const SizedBox(height: 24),
                      resultColumn,
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageIntakeBox(double boxHeight, bool isDark) {
    return Container(
      width: double.infinity,
      height: boxHeight,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.band,
        borderRadius: BorderRadius.zero,
        border: Border.all(
          color: _selectedImageBytes != null
              ? (isDark ? AppTheme.tealAccentDark : AppTheme.primaryTeal)
              : (isDark ? AppTheme.borderFocusedDark : AppTheme.borderSubtleLight),
          width: 1.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: _selectedImageBytes == null
          ? InkWell(
              onTap: _pickImageFile,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ArchIcon(
                    icon: Icons.add_a_photo_outlined,
                    color: isDark ? AppTheme.tealAccentDark : AppTheme.primaryTeal,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Drop a lesion photo here',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.textPrimaryLight,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'JPEG or PNG, or pick a verified MSLD v2.0 test case.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppTheme.textSecondaryDark
                            : AppTheme.textMutedLight,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton.icon(
                    onPressed: _showSamplePicker,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    icon: const Icon(
                      Icons.collections_bookmark_rounded,
                      size: 16,
                    ),
                    label: const Text('Pick a test case'),
                  ),
                ],
              ),
            )
          : Stack(
              fit: StackFit.expand,
              children: [
                Image.memory(_selectedImageBytes!, fit: BoxFit.contain),
                // Precision Medical Scanning Indicator
                if (_isScanning)
                  AnimatedBuilder(
                    animation: _scanAnimation,
                    builder: (context, _) {
                      return Positioned(
                        top: _scanAnimation.value * (boxHeight - 16),
                        left: 0,
                        right: 0,
                        child: Column(
                          children: [
                            Container(
                              height: 3,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(
                                      0xFF0284C7,
                                    ).withValues(alpha: 0.1),
                                    const Color(0xFF2DD4BF),
                                    const Color(0xFF006A6B),
                                    const Color(0xFF2DD4BF),
                                    const Color(
                                      0xFF0284C7,
                                    ).withValues(alpha: 0.1),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                // Top Tag with Image Metadata
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.zero,
                    ),
                    child: Text(
                      _selectedFileName ?? 'Loaded Image',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                if (_knownGroundTruth != null)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF006A6B).withValues(alpha: 0.92),
                        borderRadius: BorderRadius.zero,
                      ),
                      child: Text(
                        'Actual: $_knownGroundTruth',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      key: const ValueKey('scan_empty_state'),
      height: 480,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.band,
        borderRadius: BorderRadius.zero,
        border: Border.all(
          color: isDark ? AppTheme.borderFocusedDark : AppTheme.borderSubtleLight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.biotech_rounded,
              size: 52,
              color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
            ),
            const SizedBox(height: 16),
            Text(
              'No image yet',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppTheme.textPrimaryDark
                    : AppTheme.inkSlate,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Add a photo or pick a test case. The result, the attention map, and the triage protocol appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textMutedLight,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTriageResultCard(TriageResult res, bool isDark) {
    return Container(
      key: ValueKey('scan_result_${res.condition}_${res.timestamp}'),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.band,
        border: Border.all(color: isDark ? AppTheme.borderSubtleDark : AppTheme.borderSubtleLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // The urgency is the field the class name stands on.
          LayoutBuilder(builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 460;
            const onField = Colors.white;
            final soft = Colors.white.withValues(alpha: 0.86);
            return Container(
              color: urgencyFieldColor(res.urgency),
              padding: EdgeInsets.fromLTRB(24, isCompact ? 20 : 26, 24, isCompact ? 22 : 28),
              child: Semantics(
                label: '${res.condition}, ${res.confidencePercent} confidence, ${res.urgency}',
                child: ExcludeSemantics(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PosterLabel(res.urgency, color: onField, size: 12.8, tracking: 0.6),
                      const SizedBox(height: 14),
                      Display(res.condition, size: isCompact ? 56 : 84, height: 0.86, color: onField),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(res.confidencePercent, style: AppTheme.monoStyle(22, onField)),
                          const SizedBox(width: 10),
                          PosterLabel('confidence', color: soft, size: 11.2),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          Text(
            res.isLocalPyTorchEngine
                ? 'Classified by the PyTorch dual-branch model.'
                : 'Offline estimate from the Dart engine, not the trained model.',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w300,
              color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 18),
          // Required Action & Isolation Alert Box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.getUrgencyBg(res.urgency, isDark),
              borderRadius: BorderRadius.zero,
              border: Border.all(
                color: AppTheme.getUrgencyBorder(res.urgency, isDark),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.security_rounded,
                      size: 16,
                      color: urgencyTextColor(res.urgency, isDark),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Triage Protocol: ${res.isolationProtocol}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: urgencyTextColor(res.urgency, isDark),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  res.recommendedAction,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isDark
                        ? AppTheme.textPrimaryDark
                        : AppTheme.textPrimaryLight,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 6-Class Probability Breakdown
          Text(
            'Multi-Class Probability Distribution',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppTheme.textPrimaryDark
                  : AppTheme.textPrimaryLight,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 8),

          Column(
            children: res.probabilities.entries.map((entry) {
              return ProbabilityBarWidget(
                label: entry.key,
                probability: entry.value,
                isTopClass: entry.key == res.condition,
              );
            }).toList(),
          ),

          Divider(
            height: 28,
            color: isDark
                ? AppTheme.borderFocusedDark
                : AppTheme.borderSubtleLight,
          ),

          // Explainable AI: 14x14 Cross-Attention Heatmap
          AttentionHeatmapWidget(
            attentionTokens: res.attentionMap14x14,
            imageBytes: _selectedImageBytes,
            sampleAssetPath: _selectedAssetPath,
          ),

          const SizedBox(height: 20),

          // Export / Copy Triage Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  final summary =
                      'Dermatriage Assessment\nCondition: ${res.condition} (${res.confidencePercent})\nUrgency: ${res.urgency}\nProtocol: ${res.isolationProtocol}\nAction: ${res.recommendedAction}';
                  Clipboard.setData(ClipboardData(text: summary));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Triage clinical report copied to clipboard!',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.copy_rounded, size: 16),
                label: const Text('Copy Clinical Report'),
              ),
            ],
          ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
