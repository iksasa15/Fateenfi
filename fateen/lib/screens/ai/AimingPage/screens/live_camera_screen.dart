import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import '../controllers/live_camera_controller.dart';
import '../components/live_camera_components.dart';
import '../constants/app_strings.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

class LiveCameraScreen extends StatefulWidget {
  final String serverIp;
  final String serverPort;

  const LiveCameraScreen({
    Key? key,
    required this.serverIp,
    required this.serverPort,
  }) : super(key: key);

  @override
  State<LiveCameraScreen> createState() => _LiveCameraScreenState();
}

class _LiveCameraScreenState extends State<LiveCameraScreen>
    with WidgetsBindingObserver {
  late LiveCameraController _controller;
  List<CameraDescription> cameras = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = LiveCameraController();
    _controller.updateServerSettings(widget.serverIp, widget.serverPort);
    _initCameras();
  }

  Future<void> _initCameras() async {
    try {
      cameras = await availableCameras();
      await _controller.initCamera(cameras);
    } on CameraException catch (e) {
      // تعامل مع أخطاء الكاميرا
      print('خطأ في الوصول للكاميرا: ${e.description}');
    }
  }

  @override
  void didUpdateWidget(covariant LiveCameraScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.serverIp != widget.serverIp ||
        oldWidget.serverPort != widget.serverPort) {
      _controller.updateServerSettings(widget.serverIp, widget.serverPort);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCameras();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<LiveCameraController>(
        builder: (context, controller, _) => _buildContent(context, controller),
      ),
    );
  }

  Widget _buildContent(BuildContext context, LiveCameraController controller) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(AppStrings.liveCameraTitle), centerTitle: true),
      body: Column(
        children: [
          // عرض مشكلات الاتصال أو الأخطاء
          ErrorMessageBanner(errorMessage: controller.errorMessage),

          // عرض الكاميرا
          Expanded(
            flex: 3,
            child: CameraPreviewWidget(
              controller: controller.cameraController,
              isAnalyzing: controller.isAnalyzing,
              autoSpeak: controller.autoSpeak,
              isSingleAnalyzing: controller.isSingleAnalyzing,
            ),
          ),

          // عرض نتيجة التحليل
          Expanded(
            flex: 2,
            child: AnalysisResultPanel(
              analysisResult: controller.analysisResult,
              isPlayingAudio: controller.isPlayingAudio,
              autoSpeak: controller.autoSpeak,
              onCopy: () {
                Clipboard.setData(
                  ClipboardData(text: controller.analysisResult),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم نسخ التحليل إلى الحافظة'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              onSpeak: () {
                if (controller.isPlayingAudio) {
                  controller.stopAudio();
                } else {
                  controller.convertTextToSpeech(controller.analysisResult);
                }
              },
              onAutoSpeakToggle: () {
                controller.toggleAutoSpeak();
                // عرض رسالة توضيحية
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      controller.autoSpeak
                          ? AppStrings.autoAudioEnabled
                          : AppStrings.autoAudioDisabled,
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // زر التحليل المستمر
          FloatingActionButton(
            heroTag: 'continuous',
            onPressed: controller.isSingleAnalyzing
                ? null
                : () => controller.toggleAnalysisTimer(),
            backgroundColor:
                controller.isAnalyzing ? Colors.red : AppColors.primaryColor,
            child: Icon(controller.isAnalyzing ? Icons.stop : Icons.play_arrow),
            tooltip: controller.isAnalyzing
                ? 'إيقاف التحليل المستمر'
                : 'بدء التحليل المستمر',
          ),
          const SizedBox(width: 16),

          // زر التقاط صورة واحدة
          FloatingActionButton(
            heroTag: 'capture',
            onPressed: (controller.isSingleAnalyzing || controller.isAnalyzing)
                ? null
                : () => controller.captureAndAnalyzeOnce(),
            backgroundColor: AppColors.secondaryColor,
            child: const Icon(Icons.camera_alt),
            tooltip: 'التقاط وتحليل',
          ),
        ],
      ),
    );
  }
}
