import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../constants/app_strings.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

class SettingsScreen extends StatefulWidget {
  final TextEditingController ipController;
  final TextEditingController portController;
  final Function onSave;

  const SettingsScreen({
    Key? key,
    required this.ipController,
    required this.portController,
    required this.onSave,
  }) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isTestingConnection = false;
  String _connectionStatus = '';
  bool _isConnectionSuccess = false;

  // اختبار الاتصال بالخادم
  Future<void> _testConnection() async {
    setState(() {
      _isTestingConnection = true;
      _connectionStatus = 'جاري التحقق من الاتصال...';
      _isConnectionSuccess = false;
    });

    try {
      final result = await ApiService.testConnection(
          widget.ipController.text, widget.portController.text);

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
    return Scaffold(
      appBar: AppBar(
          title: const Text(AppStrings.settingsTitle), centerTitle: true),
      body: Padding(
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
              controller: widget.ipController,
              decoration: const InputDecoration(
                labelText: AppStrings.ipAddress,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.computer),
              ),
            ),

            const SizedBox(height: AppDimensions.paddingMedium),

            TextField(
              controller: widget.portController,
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
                  color:
                      _isConnectionSuccess ? Colors.green[50] : Colors.red[50],
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
                          _isConnectionSuccess
                              ? Icons.check_circle
                              : Icons.error,
                          color:
                              _isConnectionSuccess ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: AppDimensions.paddingSmall),
                        Text(
                          'نتيجة الاختبار:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _isConnectionSuccess
                                ? Colors.green
                                : Colors.red,
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
                widget.onSave();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم حفظ الإعدادات بنجاح'),
                    duration: Duration(seconds: 2),
                  ),
                );
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
              onTap: () {
                // عرض معلومات حول التطبيق
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text(''),
                      ),
                    ],
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
