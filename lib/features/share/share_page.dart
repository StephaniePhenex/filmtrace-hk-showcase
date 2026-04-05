import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:share_plus/share_plus.dart';
import 'package:filmtrace_hk/core/auth/auth_provider.dart';
import 'package:filmtrace_hk/core/data/location_model.dart';
import 'package:filmtrace_hk/core/routing/app_routes.dart';
import 'package:filmtrace_hk/core/theme/app_colors.dart';
import 'package:filmtrace_hk/features/feed/feed_publish_payload.dart';
import 'package:filmtrace_hk/features/location_detail/providers/location_detail_providers.dart';
import 'package:filmtrace_hk/features/share/share_payload.dart';
import 'package:filmtrace_hk/features/share/services/polaroid_builder.dart';
import 'package:filmtrace_hk/features/share/widgets/polaroid_preview.dart';

/// 阶段 5：拍立得合成、導出 JPG、保存到相冊與分享；5.3 UI 與體驗。
class SharePage extends ConsumerStatefulWidget {
  const SharePage({super.key, this.payload});

  final SharePayload? payload;

  @override
  ConsumerState<SharePage> createState() => _SharePageState();
}

class _SharePageState extends ConsumerState<SharePage> {
  final GlobalKey _polaroidKey = GlobalKey();
  String? _polaroidJpgPath;
  /// 已排程過自動導出；失敗後不自動重試，直至用戶重試或 Debug 重置。
  bool _hasAttemptedExport = false;
  String? _captureError; // 導出失敗時顯示錯誤與重試
  int? _debugDelayMs; // 驗收用：加長延遲以觀察 loading 態

  /// `null` = 異步檢查中；`false` = 無路徑或文件不存在；`true` = 可進入拍立得流程
  bool? _imageExists;

  String? get _imagePath => widget.payload?.imagePath;
  String? get _locationId => widget.payload?.locationId;

  @override
  void initState() {
    super.initState();
    _checkImageExists();
  }

  @override
  void didUpdateWidget(covariant SharePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.payload?.imagePath != widget.payload?.imagePath) {
      setState(() {
        _imageExists = null;
        _polaroidJpgPath = null;
        _captureError = null;
        _hasAttemptedExport = false;
        _debugDelayMs = null;
      });
      _checkImageExists();
    }
  }

  Future<void> _checkImageExists() async {
    final path = widget.payload?.imagePath;
    if (path == null || path.isEmpty) {
      if (!mounted) return;
      setState(() => _imageExists = false);
      return;
    }
    final exists = await File(path).exists();
    if (!mounted) return;
    setState(() => _imageExists = exists);
  }

  @override
  Widget build(BuildContext context) {
    final path = _imagePath;
    final exists = _imageExists;

    if (exists == null) {
      return Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: _buildAppBar(context),
        body: _buildCheckingImageBody(context),
      );
    }

    if (exists == false || path == null || path.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: _buildAppBar(context),
        body: _buildNoImageBody(context),
      );
    }

    final locationId = _locationId;
    final asyncLocation = locationId != null
        ? ref.watch(locationDetailProvider(locationId))
        : null;

    if (locationId != null) {
      ref.listen<AsyncValue<LocationModel?>>(
        locationDetailProvider(locationId),
        (prev, next) => _onLocationDetailReadyForCapture(next),
      );
      if (asyncLocation != null) {
        _onLocationDetailReadyForCapture(asyncLocation);
      }
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: asyncLocation != null
            ? asyncLocation.when(
                data: (location) => _buildPolaroidBody(
                  context,
                  path,
                  location,
                  mountAutoCaptureSlot: false,
                ),
                loading: () => _buildLoadingBody(context, path),
                error: (_, __) => _buildPolaroidBody(
                  context,
                  path,
                  null,
                  mountAutoCaptureSlot: false,
                ),
              )
            : _buildPolaroidBody(
                context,
                path,
                null,
                mountAutoCaptureSlot: true,
              ),
      ),
    );
  }

  void _onLocationDetailReadyForCapture(AsyncValue<LocationModel?> value) {
    value.when(
      data: (_) => _scheduleAutomaticPolaroidCaptureOnce(),
      error: (_, __) => _scheduleAutomaticPolaroidCaptureOnce(),
      loading: () {},
    );
  }

  /// 自動導出僅排程一次；副作用不在 [build] 的子方法內註冊。
  void _scheduleAutomaticPolaroidCaptureOnce() {
    if (_hasAttemptedExport || !mounted) return;
    _hasAttemptedExport = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Future<void>.delayed(const Duration(milliseconds: 100), () {
        if (!mounted) return;
        _capturePolaroid();
      });
    });
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surfaceDark,
      title: const Text('拍攝結果'),
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => context.pop(),
      ),
    );
  }

  Widget _buildCheckingImageBody(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(height: 16),
          Text(
            '正在檢查圖片…',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.hintText,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoImageBody(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.image_not_supported_outlined,
            size: 64,
            color: AppColors.placeholderIcon,
          ),
          const SizedBox(height: 16),
          Text(
            '暫無圖片',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.hintText,
                ),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('返回'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingBody(BuildContext context, String path) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(height: 16),
          Text(
            '正在生成拍立得…',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.hintText,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolaroidBody(
    BuildContext context,
    String path,
    LocationModel? location, {
    required bool mountAutoCaptureSlot,
  }) {
    final movieName = location?.movieName ?? '港片映迹';
    final locationName = location?.name ?? '打卡';
    final dateStr =
        '${DateTime.now().year}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().day.toString().padLeft(2, '0')}';
    final quote = location?.quote;

    // 5.3.1：成圖展示 — 導出成功顯示 JPG，失敗則顯示原圖供重試
    final jpgPath = _polaroidJpgPath;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (mountAutoCaptureSlot)
            _PolaroidAutoCaptureSlot(
              scheduleOnce: _scheduleAutomaticPolaroidCaptureOnce,
            ),
          Center(
            child: jpgPath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.file(
                      File(jpgPath),
                      fit: BoxFit.contain,
                    ),
                  )
                : _captureError != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.file(
                          File(path),
                          fit: BoxFit.contain,
                        ),
                      )
                    : RepaintBoundary(
                        key: _polaroidKey,
                        child: PolaroidPreview(
                          imagePath: path,
                          movieName: movieName,
                          locationName: locationName,
                          dateStr: dateStr,
                          quote: quote,
                        ),
                      ),
          ),
          if (jpgPath == null) ...[
            const SizedBox(height: 16),
            if (_captureError != null) ...[
              Text(
                _captureError!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primaryNeonRed,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                '已顯示原圖，可重試導出拍立得',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.hintText,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () {
                  setState(() => _captureError = null);
                  _capturePolaroid();
                },
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('重試'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryNeonCyan,
                ),
              ),
            ] else
              Center(
                child: Text(
                  '正在導出成圖…',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.hintText,
                      ),
                ),
              ),
          ] else ...[
            const SizedBox(height: 24),
            _buildActionButtons(
              context,
              jpgPath: jpgPath,
              movieName: movieName,
              quote: quote,
              locationId: location?.id ?? _locationId ?? 'general',
              locationLabel: locationName,
            ),
            if (kDebugMode) _buildDebugAcceptanceButtons(context)!,
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context, {
    required String jpgPath,
    required String movieName,
    required String? quote,
    required String locationId,
    required String locationLabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: () => _saveToGallery(context, jpgPath),
          icon: const Icon(Icons.save_alt, size: 20),
          label: const Text('保存到相冊'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primaryNeonCyan,
            foregroundColor: AppColors.scaffoldBackground,
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _share(context, jpgPath),
          icon: const Icon(Icons.share, size: 20),
          label: const Text('分享'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryNeonCyan,
            side: const BorderSide(color: AppColors.primaryNeonCyan),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _openPublishToFanCircle(
            context,
            jpgPath: jpgPath,
            movieName: movieName,
            quote: quote,
            locationId: locationId,
            locationLabel: locationLabel,
          ),
          icon: const Icon(Icons.dynamic_feed_outlined, size: 20),
          label: const Text('發到影迷圈'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.accentGold,
            side: const BorderSide(color: AppColors.accentGold),
          ),
        ),
      ],
    );
  }

  Future<void> _openPublishToFanCircle(
    BuildContext context, {
    required String jpgPath,
    required String movieName,
    required String? quote,
    required String locationId,
    required String locationLabel,
  }) async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) {
      await context.push(AppLocations.loginRedirect(AppRoutePaths.feed));
      return;
    }
    if (!context.mounted) return;
    context.push(
      AppRoutePaths.feedPublish,
      extra: FeedPublishPayload(
        imagePath: jpgPath,
        locationId: locationId,
        movieName: movieName,
        quote: quote,
        locationLabel: locationLabel,
      ),
    );
  }

  Future<void> _saveToGallery(BuildContext context, String jpgPath) async {
    try {
      final result = await ImageGallerySaver.saveFile(jpgPath);
      if (!context.mounted) return;
      if (result['isSuccess'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('已保存到相冊'),
            backgroundColor: AppColors.primaryNeonCyan,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '保存失敗：${result['errorMessage'] ?? '未知錯誤'}',
            ),
            backgroundColor: AppColors.primaryNeonRed,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('保存失敗：$e'),
          backgroundColor: AppColors.primaryNeonRed,
        ),
      );
    }
  }

  Future<void> _share(BuildContext context, String jpgPath) async {
    try {
      await Share.shareXFiles(
        [XFile(jpgPath)],
        text: '港片映迹 · 名場面打卡',
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('分享失敗：$e'),
          backgroundColor: AppColors.primaryNeonRed,
        ),
      );
    }
  }

  Future<void> _capturePolaroid() async {
    if (!mounted) return;
    // 延遲一幀，確保 Image.file 已解碼、RepaintBoundary 已佈局完成
    final delayMs = _debugDelayMs ?? 400;
    await Future<void>.delayed(Duration(milliseconds: delayMs));
    if (!mounted) return;
    final jpgPath = await captureWidgetToJpg(_polaroidKey, pixelRatio: 2.0);
    if (!mounted) return;
    if (jpgPath != null) {
      setState(() {
        _polaroidJpgPath = jpgPath;
        _captureError = null;
        _debugDelayMs = null;
      });
    } else {
      setState(() => _captureError = '導出失敗，請點擊重試');
    }
  }

  /// 驗收用：Debug 模式下可手動觸發各態以檢查 UI
  Widget? _buildDebugAcceptanceButtons(BuildContext context) {
    if (!kDebugMode) return null;
    final jpgPath = _polaroidJpgPath;
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '驗收測試（僅 Debug）',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.hintText,
                ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (jpgPath != null)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _polaroidJpgPath = null;
                      _captureError = '模擬導出失敗（驗收測試）';
                    });
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryNeonRed,
                  ),
                  child: const Text('測試錯誤態'),
                ),
              if (jpgPath != null)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _polaroidJpgPath = null;
                      _captureError = null;
                      _hasAttemptedExport = false;
                      _debugDelayMs = 3000;
                    });
                    _scheduleAutomaticPolaroidCaptureOnce();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryNeonCyan,
                  ),
                  child: const Text('測試 loading 3 秒'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 無 `locationId` 時在首次 [initState] 後觸發一次自動導出排程（與 [ref.listen] 路徑互斥）。
class _PolaroidAutoCaptureSlot extends StatefulWidget {
  const _PolaroidAutoCaptureSlot({required this.scheduleOnce});

  final VoidCallback scheduleOnce;

  @override
  State<_PolaroidAutoCaptureSlot> createState() =>
      _PolaroidAutoCaptureSlotState();
}

class _PolaroidAutoCaptureSlotState extends State<_PolaroidAutoCaptureSlot> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.scheduleOnce();
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
