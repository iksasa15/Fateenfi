import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart'; // لاختيار الصور من الألبوم
import 'package:shared_preferences/shared_preferences.dart'; // لتخزين IP الخادم

class AimingPage extends StatefulWidget {
  const AimingPage({Key? key}) : super(key: key);

  @override
  State<AimingPage> createState() => _AimingPageState();
}

class _AimingPageState extends State<AimingPage> with WidgetsBindingObserver {
  // كاميرا
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitializing = false;
  bool _isCameraActive = false;

  // تحليل
  bool _isAnalyzing = false;
  String _resultText = "";
  String _extractedText = "";
  bool _hasError = false;
  Timer? _analyzeTimer;

  // ملف الصورة من الألبوم
  File? _galleryImage;

  // عنوان API الخاص بالباك إند
  String _apiBaseUrl = "http://192.168.1.100:5000"; // قيمة افتراضية
  final TextEditingController _ipController = TextEditingController();

  // اختيار الصور
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSavedIP();
    _initializeCamera();
  }

  // تحميل عنوان IP المحفوظ
  Future<void> _loadSavedIP() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIP = prefs.getString('api_base_url');
    if (savedIP != null && savedIP.isNotEmpty) {
      setState(() {
        _apiBaseUrl = savedIP;
        _ipController.text = savedIP;
      });
    } else {
      _ipController.text = _apiBaseUrl;
    }
  }

  // حفظ عنوان IP
  Future<void> _saveIP(String ip) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_base_url', ip);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // إدارة دورة حياة الكاميرا عند تغير حالة التطبيق
    final CameraController? cameraController = _cameraController;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _stopCamera();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopCamera();
    _analyzeTimer?.cancel();
    _ipController.dispose();
    super.dispose();
  }

  // تهيئة الكاميرا
  Future<void> _initializeCamera() async {
    if (_isCameraInitializing) return;

    setState(() {
      _isCameraInitializing = true;
    });

    try {
      _cameras = await availableCameras();

      if (_cameras.isNotEmpty) {
        final CameraController cameraController = CameraController(
          _cameras[0], // استخدام الكاميرا الخلفية
          ResolutionPreset.medium, // دقة متوسطة لتوفير الموارد
          enableAudio: false, // لا حاجة للصوت
          imageFormatGroup: ImageFormatGroup.jpeg,
        );

        await cameraController.initialize();

        if (!mounted) return;

        setState(() {
          _cameraController = cameraController;
          _isCameraInitializing = false;
        });
      } else {
        setState(() {
          _isCameraInitializing = false;
          _hasError = true;
          _resultText = "لم يتم العثور على كاميرا في الجهاز";
        });
      }
    } on CameraException catch (e) {
      setState(() {
        _isCameraInitializing = false;
        _hasError = true;
        _resultText = "خطأ في تهيئة الكاميرا: ${e.description}";
      });
    } catch (e) {
      setState(() {
        _isCameraInitializing = false;
        _hasError = true;
        _resultText = "خطأ غير متوقع: $e";
      });
    }
  }

  // إيقاف الكاميرا
  Future<void> _stopCamera() async {
    _analyzeTimer?.cancel();

    final CameraController? cameraController = _cameraController;
    if (cameraController != null && cameraController.value.isInitialized) {
      await cameraController.dispose();
      if (mounted) {
        setState(() {
          _cameraController = null;
          _isCameraActive = false;
        });
      }
    }
  }

  // بدء تشغيل الكاميرا والتحليل
  void _startCamera() {
    setState(() {
      _isCameraActive = true;
      _galleryImage = null; // إلغاء الصورة من الألبوم إن وجدت
    });

    // بدء التحليل التلقائي
    _startAnalyzing();
  }

  // التوقف مؤقتاً عن التحليل
  void _pauseAnalyzing() {
    _analyzeTimer?.cancel();
  }

  // بدء التحليل الدوري
  void _startAnalyzing() {
    // إلغاء المؤقت الحالي إذا كان موجوداً
    _analyzeTimer?.cancel();

    // إنشاء مؤقت جديد لالتقاط إطار وتحليله كل فترة زمنية
    _analyzeTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_cameraController != null &&
          _cameraController!.value.isInitialized &&
          _isCameraActive &&
          !_isAnalyzing) {
        _captureFrameAndAnalyze();
      }
    });
  }

  // التقاط إطار وتحليله
  Future<void> _captureFrameAndAnalyze() async {
    if (_isAnalyzing) return;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final XFile imageFile = await _cameraController!.takePicture();

      // تحليل الصورة
      await _analyzeImage(File(imageFile.path));
    } catch (e) {
      setState(() {
        _hasError = true;
        _resultText = "خطأ أثناء التقاط الإطار: $e";
        _isAnalyzing = false;
      });
    }
  }

  // اختيار صورة من الألبوم
  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _galleryImage = File(pickedFile.path);
          _isCameraActive = false; // إيقاف الكاميرا
          _pauseAnalyzing(); // إيقاف التحليل الدوري
          _isAnalyzing = true; // بدء التحليل للصورة المختارة
          _resultText = "";
          _extractedText = "";
          _hasError = false;
        });

        // تحليل الصورة المختارة
        await _analyzeImage(_galleryImage!);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("حدث خطأ أثناء اختيار الصورة: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // تحليل الصورة باستخدام API
  Future<void> _analyzeImage(File imageFile) async {
    try {
      // تحويل الصورة إلى base64
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      // إعداد طلب API
      final response = await http
          .post(
            Uri.parse("$_apiBaseUrl/analyze-image"),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'image': base64Image,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        // تحليل الرد من API
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        setState(() {
          _hasError = !responseData['success'];
          _resultText =
              responseData['analysis'] ?? "لم يتم العثور على نتائج تحليل";

          // استخراج النص المتعرف عليه ضوئياً
          if (responseData.containsKey('extracted_text')) {
            _extractedText = responseData['extracted_text'] ?? "";
          }
        });
      } else {
        throw Exception("فشل الاتصال بالخادم: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _resultText = "خطأ أثناء التحليل: $e";
      });
    } finally {
      // إعادة تعيين مؤشر التحليل
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  // عرض مربع حوار لتغيير عنوان IP
  void _showChangeIPDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'تغيير عنوان IP الخادم',
          style: TextStyle(
            fontFamily: 'SYMBIOAR+LT',
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        content: TextField(
          controller: _ipController,
          decoration: const InputDecoration(
            hintText: "مثال: http://192.168.1.100:5000",
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            hintStyle: TextStyle(fontFamily: 'SYMBIOAR+LT', fontSize: 12),
          ),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.left,
          style: const TextStyle(fontFamily: 'SYMBIOAR+LT'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'إلغاء',
              style: TextStyle(
                fontFamily: 'SYMBIOAR+LT',
                color: Colors.red,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final newIP = _ipController.text.trim();
              if (newIP.isNotEmpty) {
                setState(() {
                  _apiBaseUrl = newIP;
                });
                _saveIP(newIP);
              }
              Navigator.pop(context);

              // عرض رسالة تأكيد
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("تم تغيير عنوان الخادم إلى: $newIP"),
                  backgroundColor: Colors.green,
                ),
              );

              // اختبار الاتصال بالخادم الجديد
              _testServerConnection();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4338CA),
            ),
            child: const Text(
              'حفظ',
              style: TextStyle(fontFamily: 'SYMBIOAR+LT'),
            ),
          ),
        ],
      ),
    );
  }

  // اختبار الاتصال بالخادم
  Future<void> _testServerConnection() async {
    try {
      final response = await http
          .get(
            Uri.parse("$_apiBaseUrl/test-api"),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("تم الاتصال بالخادم بنجاح: ${data['message']}"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception("استجابة غير متوقعة من الخادم: ${response.statusCode}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("فشل الاتصال بالخادم: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFDFDFF),
        appBar: AppBar(
          title: const Text(
            "تحليل الصور المباشر",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF374151),
              fontFamily: 'SYMBIOAR+LT',
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xFF4338CA),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            // زر تغيير عنوان IP
            IconButton(
              icon: const Icon(
                Icons.settings,
                color: Color(0xFF4338CA),
              ),
              tooltip: "إعدادات الخادم",
              onPressed: _showChangeIPDialog,
            ),
            // زر اختيار صورة من الألبوم
            IconButton(
              icon: const Icon(
                Icons.photo_library,
                color: Color(0xFF4338CA),
              ),
              tooltip: "اختيار من الألبوم",
              onPressed: _pickImageFromGallery,
            ),
            // زر تشغيل/إيقاف الكاميرا
            IconButton(
              icon: Icon(
                _isCameraActive ? Icons.pause : Icons.play_arrow,
                color: const Color(0xFF4338CA),
              ),
              onPressed: () {
                setState(() {
                  _isCameraActive = !_isCameraActive;
                  _galleryImage =
                      null; // إلغاء الصورة من الألبوم عند تشغيل الكاميرا
                });

                if (_isCameraActive) {
                  _startAnalyzing();
                } else {
                  _pauseAnalyzing();
                }
              },
            ),
          ],
        ),
        body: SafeArea(
          child: _buildBody(),
        ),
        // زر لإعادة التحليل
        floatingActionButton: (_isCameraActive || _galleryImage != null)
            ? FloatingActionButton(
                backgroundColor: const Color(0xFF4338CA),
                onPressed: _isAnalyzing
                    ? null
                    : () {
                        if (_galleryImage != null) {
                          _analyzeImage(_galleryImage!);
                        } else if (_isCameraActive) {
                          _captureFrameAndAnalyze();
                        }
                      },
                child: const Icon(Icons.refresh),
              )
            : null,
      ),
    );
  }

  Widget _buildBody() {
    if (_isCameraInitializing) {
      return _buildLoadingState("جاري تهيئة الكاميرا...");
    } else if (_galleryImage != null) {
      // عرض الصورة من الألبوم
      return _buildGalleryImageWithResults();
    } else if (_cameraController == null) {
      return _buildErrorState();
    } else if (!_isCameraActive) {
      return _buildCameraInactiveState();
    } else {
      return _buildCameraPreviewWithResults();
    }
  }

  Widget _buildLoadingState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Color(0xFF4338CA),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF374151),
              fontFamily: 'SYMBIOAR+LT',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 72,
            ),
            const SizedBox(height: 24),
            Text(
              "حدث خطأ",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _resultText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF4B5563),
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _initializeCamera,
                icon: const Icon(Icons.refresh),
                label: const Text(
                  "إعادة المحاولة",
                  style: TextStyle(fontFamily: 'SYMBIOAR+LT', fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4338CA),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGalleryImageWithResults() {
    return Column(
      children: [
        // عرض الصورة من الألبوم
        Expanded(
          flex: 3,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(4.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // الصورة
                  Image.file(
                    _galleryImage!,
                    fit: BoxFit.contain,
                  ),

                  // مؤشر التحليل
                  if (_isAnalyzing)
                    Container(
                      color: Colors.black.withOpacity(0.3),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

        // عرض النتائج
        Expanded(
          flex: 2,
          child: _buildResultsPanel(),
        ),
      ],
    );
  }

  Widget _buildCameraPreviewWithResults() {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        // عرض الكاميرا
        Expanded(
          flex: 3,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(4.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // معاينة الكاميرا
                  CameraPreview(_cameraController!),

                  // مؤشر التحليل
                  if (_isAnalyzing)
                    Container(
                      color: Colors.black.withOpacity(0.3),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      ),
                    ),

                  // إطار التصويب
                  Center(
                    child: Container(
                      width: screenWidth * 0.7,
                      height: screenWidth * 0.7,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // عرض النتائج
        Expanded(
          flex: 2,
          child: _buildResultsPanel(),
        ),
      ],
    );
  }

  Widget _buildResultsPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الحالة
          Row(
            children: [
              Icon(
                _hasError ? Icons.error_outline : Icons.search,
                color: _hasError ? Colors.red : const Color(0xFF4338CA),
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                _hasError ? "خطأ في التحليل" : "نتائج التحليل",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _hasError ? Colors.red : const Color(0xFF374151),
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
              const Spacer(),
              if (_isAnalyzing)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4338CA).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          color: Color(0xFF4338CA),
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 6),
                      Text(
                        "جارٍ التحليل",
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'SYMBIOAR+LT',
                          color: Color(0xFF4338CA),
                        ),
                      ),
                    ],
                  ),
                ),
              // عرض IP الخادم الحالي
              InkWell(
                onTap: _showChangeIPDialog,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "الخادم",
                    style: TextStyle(
                      fontSize: 10,
                      fontFamily: 'SYMBIOAR+LT',
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // عرض النص المستخرج إذا كان متوفراً
          if (_extractedText.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.text_fields,
                        color: Color(0xFF4338CA),
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        "النص المستخرج:",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4B5563),
                          fontFamily: 'SYMBIOAR+LT',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _extractedText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF4B5563),
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                  ),
                ],
              ),
            ),
          ],

          // نتائج التحليل
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Text(
                _resultText.isEmpty
                    ? (_galleryImage != null
                        ? "اضغط على زر التحليل لتحليل الصورة..."
                        : "وجّه الكاميرا إلى الشيء المراد تحليله...")
                    : _resultText,
                style: TextStyle(
                  fontSize: 15,
                  color: _resultText.isEmpty
                      ? Colors.grey.shade500
                      : (_hasError ? Colors.red : const Color(0xFF4B5563)),
                  fontFamily: 'SYMBIOAR+LT',
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraInactiveState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF5F3FF),
                border: Border.all(
                  color: const Color(0xFFE3E0F8),
                  width: 1.0,
                ),
              ),
              child: const Icon(
                Icons.videocam,
                color: Color(0xFF4338CA),
                size: 64,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "تحليل الصور",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF374151),
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "اختر إحدى الطرق التالية لتحليل الصور",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
            const SizedBox(height: 40),

            // أزرار الخيارات
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // زر فتح الكاميرا
                Expanded(
                  child: _buildOptionButton(
                    icon: Icons.videocam,
                    label: "الكاميرا المباشرة",
                    onPressed: () {
                      setState(() {
                        _isCameraActive = true;
                        _galleryImage = null;
                      });
                      _startAnalyzing();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // زر اختيار صورة من الألبوم
                Expanded(
                  child: _buildOptionButton(
                    icon: Icons.photo_library,
                    label: "اختيار من الألبوم",
                    onPressed: _pickImageFromGallery,
                  ),
                ),
              ],
            ),

            // عرض معلومات الاتصال بالخادم
            const SizedBox(height: 40),

            InkWell(
              onTap: _showChangeIPDialog,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.settings,
                          size: 14,
                          color: Color(0xFF4338CA),
                        ),
                        SizedBox(width: 4),
                        Text(
                          "إعدادات الخادم",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'SYMBIOAR+LT',
                            color: Color(0xFF4338CA),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _apiBaseUrl,
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: 'SYMBIOAR+LT',
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(
      {required IconData icon,
      required String label,
      required VoidCallback onPressed}) {
    return SizedBox(
      height: 110,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4338CA),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 36,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
