import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_strings.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../services/api_service.dart';
import 'text_extractor_screen.dart';
import 'live_camera_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // كونترولر لإدارة الإعدادات
  final TextEditingController _ipController = TextEditingController(
    text: '192.168.1.100',
  );
  final TextEditingController _portController = TextEditingController(
    text: '5003',
  );

  bool _isTestingConnection = false;
  String _connectionStatus = '';
  bool _isConnectionSuccess = false;
  bool _showSettings = false;

  @override
  void initState() {
    super.initState();
    _loadSavedIpAndPort();
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }

  // حفظ عنوان IP والبورت
  Future<void> _saveIpAndPort() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_ip', _ipController.text);
    await prefs.setString('server_port', _portController.text);
  }

  // تحميل عنوان IP والبورت المحفوظ
  Future<void> _loadSavedIpAndPort() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ip = prefs.getString('server_ip');
      final port = prefs.getString('server_port');

      if (ip != null && ip.isNotEmpty) {
        setState(() {
          _ipController.text = ip;
        });
      }

      if (port != null && port.isNotEmpty) {
        setState(() {
          _portController.text = port;
        });
      }
    } catch (e) {
      // تجاهل الأخطاء في حالة عدم القدرة على تحميل الإعدادات
    }
  }

  // اختبار الاتصال بالخادم
  Future<void> _testConnection() async {
    setState(() {
      _isTestingConnection = true;
      _connectionStatus = 'جاري التحقق من الاتصال...';
      _isConnectionSuccess = false;
    });

    try {
      final result = await ApiService.testConnection(
          _ipController.text, _portController.text);

      setState(() {
        _connectionStatus = result['message'];
        _isConnectionSuccess = result['success'];
        _isTestingConnection = false;
      });
    } finally {
      setState(() {
        _isTestingConnection = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // مشاركة إعدادات الخادم مع جميع الشاشات
    final String serverIp = _ipController.text;
    final String serverPort = _portController.text;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appTitle),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_showSettings ? Icons.close : Icons.settings),
            onPressed: () {
              setState(() {
                _showSettings = !_showSettings;
              });
            },
          ),
        ],
      ),
      body: _showSettings
          ? _buildSettingsPanel()
          : _buildMainContent(serverIp, serverPort),
    );
  }

  // بناء لوحة الإعدادات
  Widget _buildSettingsPanel() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.serverSettings,
            style: TextStyle(
                fontSize: AppDimensions.fontSizeLarge,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),

          TextField(
            controller: _ipController,
            decoration: const InputDecoration(
              labelText: AppStrings.ipAddress,
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.computer),
            ),
          ),

          const SizedBox(height: AppDimensions.paddingMedium),

          TextField(
            controller: _portController,
            decoration: const InputDecoration(
              labelText: AppStrings.port,
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.settings_ethernet),
            ),
            keyboardType: TextInputType.number,
          ),

          const SizedBox(height: AppDimensions.paddingLarge),

          // زر اختبار الاتصال
          ElevatedButton.icon(
            onPressed: _isTestingConnection ? null : _testConnection,
            icon: const Icon(Icons.network_check),
            label: Text(
              _isTestingConnection
                  ? 'جاري الاختبار...'
                  : AppStrings.testConnection,
            ),
            style: ElevatedButton.styleFrom(
              minimumSize:
                  const Size(double.infinity, AppDimensions.buttonHeight),
              backgroundColor: AppColors.secondaryColor,
            ),
          ),

          // عرض حالة الاتصال
          if (_connectionStatus.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: AppDimensions.paddingMedium),
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              decoration: BoxDecoration(
                color: _isConnectionSuccess ? Colors.green[50] : Colors.red[50],
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadiusMedium),
                border: Border.all(
                  color: _isConnectionSuccess ? Colors.green : Colors.red,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _isConnectionSuccess ? Icons.check_circle : Icons.error,
                        color: _isConnectionSuccess ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: AppDimensions.paddingSmall),
                      Text(
                        'نتيجة الاختبار:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                              _isConnectionSuccess ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.paddingSmall),
                  Text(
                    _connectionStatus,
                    style: TextStyle(
                      color: _isConnectionSuccess
                          ? Colors.green[800]
                          : Colors.red[800],
                    ),
                  ),
                  if (!_isConnectionSuccess)
                    Padding(
                      padding: const EdgeInsets.only(
                          top: AppDimensions.paddingMedium),
                      child: Text(
                        '📌 نصائح للتصحيح:\n'
                        '1. تأكد من أن خادم بايثون يعمل\n'
                        '2. تأكد من أن عنوان IP هو عنوان الجهاز الذي يشغل الخادم (وليس 127.0.0.1)\n'
                        '3. تأكد من أن المنفذ صحيح وغير محجوب\n'
                        '4. تأكد من أن الخادم والهاتف على نفس الشبكة',
                        style: TextStyle(color: Colors.red[800]),
                      ),
                    ),
                  if (_isConnectionSuccess)
                    const Padding(
                      padding:
                          EdgeInsets.only(top: AppDimensions.paddingMedium),
                      child: Text(
                        '✅ الخادم جاهز ومتصل بنجاح!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                ],
              ),
            ),

          const SizedBox(height: AppDimensions.paddingLarge),

          // زر حفظ الإعدادات
          ElevatedButton.icon(
            onPressed: () {
              _saveIpAndPort();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم حفظ الإعدادات بنجاح'),
                  duration: Duration(seconds: 2),
                ),
              );
              setState(() {
                _showSettings = false;
              });
            },
            icon: const Icon(Icons.save),
            label: const Text(AppStrings.saveSettings),
            style: ElevatedButton.styleFrom(
              minimumSize:
                  const Size(double.infinity, AppDimensions.buttonHeight),
            ),
          ),

          const SizedBox(height: AppDimensions.paddingLarge),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.info_outline),
            onTap: () {
              // عرض معلومات حول التطبيق
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('إغلاق'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // بناء المحتوى الرئيسي
  Widget _buildMainContent(String serverIp, String serverPort) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              '       ',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            const Text(
              'يمكنك استخدام الكاميرا المباشرة للتحليل الفوري أو رفع صورة من المعرض',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 50),

            // زر الكاميرا المباشرة
            ElevatedButton.icon(
              icon: const Icon(
                Icons.camera_alt,
                size: 32,
              ),
              label: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'الكاميرا المباشرة',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 70),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.borderRadiusMedium),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LiveCameraScreen(
                      serverIp: serverIp,
                      serverPort: serverPort,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // زر رفع صورة
            ElevatedButton.icon(
              icon: const Icon(
                Icons.image,
                size: 32,
              ),
              label: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'استخراج النص من صورة',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 70),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.borderRadiusMedium),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TextExtractorScreen(
                      serverIp: serverIp,
                      serverPort: serverPort,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
