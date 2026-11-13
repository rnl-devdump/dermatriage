import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import '../services/inference_service.dart';
import '../services/history_service.dart';
import '../models/triage_result.dart';
import '../widgets/urgency_badge_widget.dart';
import '../widgets/probability_bar_widget.dart';
import '../widgets/attention_heatmap_widget.dart';
import '../widgets/sample_selector_dialog.dart';
import '../theme/app_theme.dart';

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
          horizontal: isMobilePadding ? 14 : 24,
          vertical: isMobilePadding ? 14 : 20,
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
                    Text(
                      'Local Clinical Lesion Triage & Scan',
                      style: TextStyle(
                        fontSize: isCompact ? 19 : 22,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppTheme.textPrimaryDark
                            : AppTheme.textPrimaryLight,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Evaluates skin lesions locally using Proposed Dual-Branch CNN-ViT Cross-Attention',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppTheme.textSecondaryDark
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                );

                final statusBadge = InkWell(
                  onTap: () async {
                    await _inference.checkHealth();
                    setState(() {});
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isOnline
                          ? (isDark
                                ? const Color(0xFF064E3B)
                                : const Color(0xFFECFDF5))
                          : (isDark
                                ? const Color(0xFF451A03)
                                : const Color(0xFFFFFBEB)),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isOnline
                            ? (isDark
                                  ? const Color(0xFF059669)
                                  : const Color(0xFF10B981))
                            : (isDark
                                  ? const Color(0xFFD97706)
                                  : const Color(0xFFF59E0B)),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isOnline
                              ? Icons.check_circle_rounded
                              : Icons.info_outline_rounded,
                          size: 16,
                          color: isOnline
                              ? const Color(0xFF059669)
                              : const Color(0xFFD97706),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isOnline
                                  ? 'Local PyTorch Engine Connected'
                                  : 'Standalone Dart Engine Active',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: isOnline
                                    ? const Color(0xFF059669)
                                    : const Color(0xFFD97706),
                              ),
                            ),
                            Text(
                              isOnline
                                  ? 'Proposed Fold-1 Best Checkpoint (127.0.0.1:8000)'
                                  : 'Tap to refresh local server status',
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark
                                    ? AppTheme.textMutedDark
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ],
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
                  borderRadius: BorderRadius.circular(12),
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
                            backgroundColor: isDark
                                ? AppTheme.primaryTeal
                                : AppTheme.primaryTeal,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          icon: _isScanning
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.refresh_rounded, size: 18),
                          label: Text(
                            _isScanning
                                ? 'Extracting Attention Tokens...'
                                : 'Re-Classify Lesion',
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
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _selectedImageBytes != null
              ? (isDark ? AppTheme.tealAccentDark : AppTheme.primaryTeal)
              : (isDark ? AppTheme.borderFocusedDark : const Color(0xFFCBD5E1)),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: _selectedImageBytes == null
          ? InkWell(
              onTap: _pickImageFile,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.primaryTeal.withValues(alpha: 0.2)
                          : const Color(0xFFE6FFFA),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add_a_photo_outlined,
                      size: 38,
                      color: isDark
                          ? AppTheme.tealAccentDark
                          : AppTheme.primaryTeal,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Select or Drop Skin Lesion Photo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
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
                      'Supports JPEG, PNG, or select verified MSLD v2.0 clinical cases',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppTheme.textSecondaryDark
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton.icon(
                    onPressed: _showSamplePicker,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0284C7),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    icon: const Icon(
                      Icons.collections_bookmark_rounded,
                      size: 16,
                    ),
                    label: const Text('Select Verified Test Case'),
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
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0xFF2DD4BF),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
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
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _selectedFileName ?? 'Loaded Image',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
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
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Actual: $_knownGroundTruth',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
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
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.borderFocusedDark : const Color(0xFFE2E8F0),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.biotech_rounded,
              size: 52,
              color: isDark ? AppTheme.textMutedDark : Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Awaiting Skin Lesion Image',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppTheme.textPrimaryDark
                    : const Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Upload a clinical photo or choose a verified MSLD v2.0 test case on the left to generate local neural classification, cross-attention patch maps, and triage protocols.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppTheme.textSecondaryDark
                    : const Color(0xFF64748B),
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
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppTheme.borderFocusedDark : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Diagnosis Title Row: Adaptive layout
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 460;

              final titleInfo = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      Text(
                        res.condition,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppTheme.textPrimaryDark
                              : const Color(0xFF0F172A),
                          letterSpacing: -0.5,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color:
                              (isDark
                                      ? AppTheme.tealAccentDark
                                      : const Color(0xFF006A6B))
                                  .withValues(alpha: isDark ? 0.2 : 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          res.confidencePercent,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppTheme.tealAccentDark
                                : const Color(0xFF006A6B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Classified via ${res.isLocalPyTorchEngine ? "PyTorch Dual-Branch Cross-Attn" : "Standalone Local Dart Engine"}',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isDark
                          ? AppTheme.textMutedDark
                          : Colors.grey.shade600,
                    ),
                  ),
                ],
              );

              final urgencyBadge = UrgencyBadgeWidget(
                urgency: res.urgency,
                isLarge: !isCompact,
              );

              if (isCompact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleInfo,
                    const SizedBox(height: 10),
                    urgencyBadge,
                  ],
                );
              } else {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: titleInfo),
                    const SizedBox(width: 10),
                    urgencyBadge,
                  ],
                );
              }
            },
          ),

          Divider(
            height: 24,
            color: isDark
                ? AppTheme.borderFocusedDark
                : AppTheme.borderSubtleLight,
          ),

          // Required Action & Isolation Alert Box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.getUrgencyBg(res.urgency, isDark),
              borderRadius: BorderRadius.circular(12),
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
                      color: AppTheme.getUrgencyColor(res.urgency),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Triage Protocol: ${res.isolationProtocol}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.getUrgencyColor(res.urgency),
                        ),
                        overflow: TextOverflow.ellipsis,
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
                        ? const Color(0xFFF1F5F9)
                        : const Color(0xFF1E3A8B),
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
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppTheme.textPrimaryDark
                  : const Color(0xFF0F172A),
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
    );
  }
}
