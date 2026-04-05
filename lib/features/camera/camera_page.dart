import 'dart:io';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:filmtrace_hk/core/constants/local_stills.dart';
import 'package:filmtrace_hk/core/routing/app_routes.dart';
import 'package:filmtrace_hk/core/theme/app_colors.dart';
import 'package:filmtrace_hk/features/location_detail/providers/location_detail_providers.dart';
import 'package:filmtrace_hk/features/share/share_payload.dart';

/// 名场面打卡 - AR 画中画 / 打卡相机（阶段 4）
/// 4.0：权限 + CameraPreview；4.2：locationId + 剧照叠层；4.3：透明度 Slider；4.4：快门截图并跳转 /share。
/// 方案 D：相機頁偏好橫屏，劇照為橫屏時成圖更佳（PLAN_CAMERA_LANDSCAPE）。
///
/// 當作為底部 tab 使用時（IndexedStack），切換 tab 不會 dispose。
/// AppShell 切換回打卡 tab 時會調用 [onTabResumeCallback]，以恢復預覽與橫屏。
class CameraPage extends ConsumerStatefulWidget {
  const CameraPage({super.key, this.locationId});

  final String? locationId;

  /// 由 AppShell 在切換回打卡 tab 時調用；CameraPage 註冊後會執行 resumePreview + _lockLandscape
  static void Function()? onTabResumeCallback;

  @override
  ConsumerState<CameraPage> createState() => _CameraPageState();
}

enum _CameraUiState {
  loading,
  permissionDenied,
  noCamera,
  ready,
  error,
}

class _CameraPageState extends ConsumerState<CameraPage> {
  _CameraUiState _uiState = _CameraUiState.loading;
  CameraController? _controller;
  String _errorMessage = '';

  /// 4.3：剧照叠层透明度 0.0–1.0，由右侧 Slider 更新。
  double _overlayOpacity = 0.5;

  /// 4.4：截图用 RepaintBoundary；iOS 上 CameraPreview 可能为 Platform View，截图中相机区域或为黑，真机需验证。
  final GlobalKey _captureKey = GlobalKey();
  bool _isCapturing = false;

  /// 方案 D：橫屏提示 Overlay，ready 後顯示 2 秒或點擊關閉
  bool _showLandscapeHint = true;

  @override
  void initState() {
    super.initState();
    _lockLandscape();
    _initCamera();
    // 僅 tab 內的相機（locationId == null）註冊，避免從詳情 push 的相機頁覆蓋
    if (widget.locationId == null) {
      CameraPage.onTabResumeCallback = _onTabResume;
    }
  }

  @override
  void dispose() {
    if (widget.locationId == null && CameraPage.onTabResumeCallback == _onTabResume) {
      CameraPage.onTabResumeCallback = null;
    }
    _restoreOrientation();
    _controller?.dispose();
    super.dispose();
  }

  void _onTabResume() {
    if (!mounted) return;
    _lockLandscape();
    _controller?.resumePreview();
  }

  void _lockLandscape() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _lockPortrait() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  void _restoreOrientation() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  }

  Future<void> _initCamera() async {
    if (!mounted) return;
    setState(() {
      _uiState = _CameraUiState.loading;
      _errorMessage = '';
    });

    final status = await Permission.camera.request();
    if (!mounted) return;
    if (status.isDenied || status.isPermanentlyDenied) {
      setState(() => _uiState = _CameraUiState.permissionDenied);
      return;
    }

    try {
      final cameras = await availableCameras();
      if (!mounted) return;
      if (cameras.isEmpty) {
        setState(() {
          _uiState = _CameraUiState.noCamera;
          _errorMessage = '未檢測到相機設備（模擬器可能無相機）';
        });
        return;
      }

      final controller = CameraController(
        cameras.first,
        ResolutionPreset.low,
        imageFormatGroup: ImageFormatGroup.jpeg,
        enableAudio: false,
      );
      await controller.initialize().timeout(
        const Duration(seconds: 20),
        onTimeout: () => throw Exception('相機啟動逾時，請重試'),
      );
      if (!mounted) return;
      setState(() {
        _controller = controller;
        _uiState = _CameraUiState.ready;
      });
      Future<void>.delayed(const Duration(seconds: 2), () {
        if (mounted && _showLandscapeHint) {
          setState(() => _showLandscapeHint = false);
        }
      });
    } on CameraException catch (e) {
      if (!mounted) return;
      setState(() {
        _uiState = _CameraUiState.error;
        _errorMessage = e.description ?? e.code;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _uiState = _CameraUiState.error;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  /// 4.4：截取 RepaintBoundary 内容，写入临时 PNG，跳转 /share。像素比限制 2.0 以控制内存。
  Future<void> _captureAndNavigate() async {
    if (_isCapturing || !mounted) return;
    setState(() => _isCapturing = true);
    try {
      final boundary =
          _captureKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('截圖失敗')),
          );
        }
        return;
      }
      const pixelRatio = 2.0;
      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null || !mounted) return;
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/filmtrace_capture_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(path);
      await file.writeAsBytes(byteData.buffer.asUint8List());
      if (!mounted) return;
      _lockPortrait();
      await context.push<void>(
        '/share',
        extra: SharePayload(imagePath: path, locationId: widget.locationId),
      );
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _lockLandscape();
        });
      }
      // 从分享页返回后恢复相机预览，避免定格在上一帧（从底部「打卡」进入时页面未销毁，需主动 resume）
      if (mounted && _controller != null) await _controller!.resumePreview();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('截圖失敗: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Stack(
          children: [
            _buildBody(),
            Positioned(
              top: 12,
              left: 12,
              child: Material(
                color: AppColors.zoomBarBackground,
                borderRadius: BorderRadius.circular(24),
                child: InkWell(
                  onTap: () {
                    if (widget.locationId != null) {
                      context.pop();
                    } else {
                      _restoreOrientation();
                      context.go(AppRoutePaths.map);
                    }
                  },
                  borderRadius: BorderRadius.circular(24),
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Icon(
                      Icons.arrow_back,
                      color: AppColors.primaryNeonCyan,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_uiState) {
      case _CameraUiState.loading:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primaryNeonCyan,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '正在啟動相機…',
                style: TextStyle(color: AppColors.bodyText),
              ),
              const SizedBox(height: 8),
              Text(
                '若長時間無反應請點下方重試',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.hintText,
                    ),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: _initCamera,
                icon: const Icon(Icons.refresh, size: 20),
                label: const Text('重試'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryNeonCyan,
                ),
              ),
            ],
          ),
        );
      case _CameraUiState.permissionDenied:
        return _buildPlaceholder(
          icon: Icons.camera_alt_outlined,
          title: '需要相機權限',
          subtitle: '請在設定中允許港片映迹使用相機，以進行名場面打卡拍照。若設定裡沒有「相機」選項，請先點下方按鈕觸發權限對話框後再進入設定。',
          actionLabel: '打開設定',
          actionIcon: Icons.settings_outlined,
          onAction: () async {
            // 先再請求一次，讓 iOS 在「設定 → 本 App」裡顯示「相機」選項（僅在至少請求過一次後才會出現）
            await Permission.camera.request();
            if (!mounted) return;
            openAppSettings();
          },
        );
      case _CameraUiState.noCamera:
      case _CameraUiState.error:
        return _buildPlaceholder(
          icon: Icons.camera_alt_outlined,
          title: '相機不可用',
          subtitle: _errorMessage.isNotEmpty
              ? _errorMessage
              : '請在真機上使用，或檢查設備是否支援相機。',
          actionLabel: '重試',
          actionIcon: Icons.refresh,
          onAction: _initCamera,
        );
      case _CameraUiState.ready:
        return _buildCameraWithStillOverlay(_controller!, widget.locationId);
    }
  }

  /// 4.2/4.3：叠层剧照（有 locationId 用剧照，無則用占位）；透明度由 _overlayOpacity 控制，右侧垂直 Slider 调节。4.4：RepaintBoundary + 快门。
  Widget _buildCameraWithStillOverlay(
      CameraController controller, String? locationId) {
    final hasLocation = locationId != null && locationId.isNotEmpty;
    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          key: _captureKey,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CameraPreview(controller),
              Positioned.fill(
                child: Opacity(
                  opacity: _overlayOpacity.clamp(0.0, 1.0),
                  child: hasLocation
                      ? _LocationStillOverlay(locationId: locationId!)
                      : _PlaceholderOverlay(),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 12,
          top: 0,
          bottom: 0,
          child: Center(
            child: _OpacitySlider(
              value: _overlayOpacity,
              onChanged: (v) => setState(() => _overlayOpacity = v),
            ),
          ),
        ),
        _buildShutterButton(),
        if (_showLandscapeHint) _buildLandscapeHintOverlay(),
      ],
    );
  }

  /// 方案 D：橫屏提示，2 秒後自動消失或點擊關閉
  Widget _buildLandscapeHintOverlay() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () {
          if (_showLandscapeHint) {
            setState(() => _showLandscapeHint = false);
          }
        },
        child: Container(
          color: Colors.black54,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.screen_rotation,
                    size: 56,
                    color: AppColors.primaryNeonCyan,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '橫屏拍攝，與電影畫面更貼近',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.bodyText,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '點擊任意處關閉',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.hintText,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShutterButton() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 24,
      child: Center(
        child: Material(
          color: AppColors.zoomBarBackground,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: _isCapturing ? null : _captureAndNavigate,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: 64,
              height: 64,
              child: _isCapturing
                  ? const Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryNeonCyan,
                      ),
                    )
                  : const Icon(
                      Icons.camera_alt,
                      size: 36,
                      color: AppColors.primaryNeonRed,
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder({
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionLabel,
    required IconData actionIcon,
    required VoidCallback onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: AppColors.accentGold),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.primaryNeonCyan,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.bodyText,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAction,
              icon: Icon(actionIcon, size: 20),
              label: Text(actionLabel),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryNeonRed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 無 locationId 時的占位叠层，提示從地圖/詳情頁進入「名場面打卡」可疊加劇照。
class _PlaceholderOverlay extends StatelessWidget {
  const _PlaceholderOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.placeholderBackground.withValues(alpha: 0.5),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.photo_library_outlined,
                size: 48,
                color: AppColors.placeholderIcon.withValues(alpha: 0.9),
              ),
              const SizedBox(height: 12),
              Text(
                '從地圖或詳情頁點「名場面打卡」\n可疊加劇照',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.placeholderIcon.withValues(alpha: 0.9),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 有 locationId 時依 locationDetail 載入劇照叠层（loading 時顯示載入中）。
class _LocationStillOverlay extends ConsumerWidget {
  const _LocationStillOverlay({required this.locationId});

  final String locationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncLocation = ref.watch(locationDetailProvider(locationId));
    return asyncLocation.when(
      data: (location) => _StillOverlay(
        locationId: locationId,
        stillUrl: location?.stillUrl,
      ),
      loading: () => Container(
        color: AppColors.placeholderBackground.withValues(alpha: 0.5),
        child: const Center(
          child: SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primaryNeonCyan,
            ),
          ),
        ),
      ),
      error: (_, __) => _StillOverlay(
        locationId: locationId,
        stillUrl: null,
      ),
    );
  }
}

/// 4.3：右侧垂直透明度滑块，0.0–1.0；样式使用 AppColors。
class _OpacitySlider extends StatelessWidget {
  const _OpacitySlider({
    required this.value,
    required this.onChanged,
  });

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.zoomBarBackground,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: SizedBox(
          height: 160,
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primaryNeonCyan,
              inactiveTrackColor: AppColors.divider,
              thumbColor: AppColors.primaryNeonCyan,
              overlayColor: AppColors.primaryNeonCyan.withValues(alpha: 0.2),
            ),
            child: RotatedBox(
              quarterTurns: 3,
              child: Slider(
                value: value.clamp(0.0, 1.0),
                onChanged: onChanged,
                min: 0.0,
                max: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 剧照叠层：与 discovery/map 一致，localStills 优先 → stillUrl → 占位。
class _StillOverlay extends StatelessWidget {
  const _StillOverlay({
    required this.locationId,
    this.stillUrl,
  });

  final String locationId;
  final String? stillUrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (localStills.containsKey(locationId)) {
      return Image.asset(
        localStills[locationId]!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => _placeholder(context),
      );
    }
    final url = stillUrl?.trim();
    if (url == null || url.isEmpty) return _placeholder(context);
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: AppColors.placeholderBackground,
          child: const Center(
            child: SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
      errorBuilder: (_, __, ___) => _placeholder(context),
    );
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      color: AppColors.placeholderBackground.withValues(alpha: 0.6),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.movie_outlined,
              size: 48,
              color: AppColors.placeholderIcon,
            ),
            const SizedBox(height: 8),
            Text(
              '暫無劇照',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.placeholderIcon,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
