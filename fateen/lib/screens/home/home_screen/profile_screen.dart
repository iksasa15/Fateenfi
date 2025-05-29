import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../home/home_screen/controllers/profile_controller.dart';
import '../../home/home_screen/constants/profileConstants.dart';
import '../../home/home_screen/components/profile_components.dart';

/// شاشة الملف الشخصي
class ProfileScreen extends StatefulWidget {
  final String? userId;

  const ProfileScreen({
    Key? key,
    this.userId,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late ProfileController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ProfileController(uid: widget.userId);
    _loadProfileData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // تحميل بيانات الملف الشخصي
  Future<void> _loadProfileData() async {
    await _controller.initialize();
  }

  // عرض مربع حوار تعديل الملف الشخصي
  void _showEditProfileDialog() async {
    // استخدام مربع حوار تعديل الملف الشخصي
    showDialog(
      context: context,
      builder: (context) => _buildEditProfileDialog(),
    ).then((updated) {
      if (updated == true && mounted) {
        _loadProfileData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(ProfileConstants.updateSuccessMessage),
            backgroundColor: ProfileConstants.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  // مربع حوار تعديل الملف الشخصي
  Widget _buildEditProfileDialog() {
    // إنشاء وحدات تحكم نصية جديدة بناءً على القيم الحالية
    final nameController = TextEditingController(text: _controller.userName);
    final majorController = TextEditingController(text: _controller.userMajor);
    final emailController = TextEditingController(text: _controller.userEmail);
    bool isLoading = false;

    // إنشاء مفتاح نموذج للتحقق من الصحة
    final formKey = GlobalKey<FormState>();

    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: const Text(
            ProfileConstants.editProfileTitle,
            style: TextStyle(
              color: ProfileConstants.kDarkPurple,
              fontWeight: FontWeight.bold,
              fontFamily: 'SYMBIOAR+LT',
            ),
            textAlign: TextAlign.right,
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // عرض النص الفرعي
                  Container(
                    alignment: Alignment.centerRight,
                    margin: const EdgeInsets.only(bottom: 15),
                    child: Text(
                      ProfileConstants.editProfileSubtext,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontFamily: 'SYMBIOAR+LT',
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),

                  // حقل الاسم
                  ProfileComponents.buildTextField(
                    label: ProfileConstants.nameFieldTitle,
                    hint: ProfileConstants.nameHint,
                    controller: nameController,
                    icon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return ProfileConstants.emptyNameError;
                      }
                      if (value.trim().length < 3) {
                        return ProfileConstants.nameErrorMessage;
                      }
                      return null;
                    },
                  ),

                  // حقل التخصص
                  ProfileComponents.buildTextField(
                    label: ProfileConstants.majorFieldTitle,
                    hint: ProfileConstants.majorHint,
                    controller: majorController,
                    icon: Icons.school_outlined,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return ProfileConstants.emptyMajorError;
                      }
                      return null;
                    },
                  ),

                  // حقل البريد الإلكتروني
                  ProfileComponents.buildTextField(
                    label: ProfileConstants.emailFieldTitle,
                    hint: ProfileConstants.emailHint,
                    controller: emailController,
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        // التحقق من صحة البريد الإلكتروني إذا تم إدخاله
                        final emailRegex = RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          caseSensitive: false,
                        );
                        if (!emailRegex.hasMatch(value.trim())) {
                          return ProfileConstants.emailErrorMessage;
                        }
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            // زر إلغاء
            TextButton(
              onPressed:
                  isLoading ? null : () => Navigator.of(context).pop(false),
              child: Text(
                ProfileConstants.cancelText,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
            ),

            // زر حفظ
            TextButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      // التحقق من صحة النموذج
                      if (formKey.currentState?.validate() != true) {
                        return;
                      }

                      setState(() {
                        isLoading = true;
                      });

                      final result = await _controller.updateProfile(
                        newName: nameController.text.trim(),
                        newMajor: majorController.text.trim(),
                        newEmail: emailController.text.trim(),
                      );

                      setState(() {
                        isLoading = false;
                      });

                      if (result) {
                        Navigator.of(context).pop(true);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              _controller.errorMessage ??
                                  ProfileConstants.updateFailMessage,
                              style: const TextStyle(fontFamily: 'SYMBIOAR+LT'),
                            ),
                            backgroundColor: ProfileConstants.dangerColor,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
              style: TextButton.styleFrom(
                foregroundColor: ProfileConstants.kDarkPurple,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      ProfileConstants.saveText,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'SYMBIOAR+LT',
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  // تغيير كلمة المرور
  void _changePassword() async {
    // استخدام مربع حوار تغيير كلمة المرور
    showDialog(
      context: context,
      builder: (context) => _buildChangePasswordDialog(),
    ).then((changed) {
      if (changed == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(ProfileConstants.passwordChangeSuccessMessage),
            backgroundColor: ProfileConstants.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  // مربع حوار تغيير كلمة المرور
  Widget _buildChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isLoading = false;
    bool showCurrentPassword = false;
    bool showNewPassword = false;
    bool showConfirmPassword = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: const Text(
            ProfileConstants.changePasswordTitle,
            style: TextStyle(
              color: ProfileConstants.kDarkPurple,
              fontWeight: FontWeight.bold,
              fontFamily: 'SYMBIOAR+LT',
            ),
            textAlign: TextAlign.right,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // حقل كلمة المرور الحالية
                ProfileComponents.buildTextField(
                  label: 'كلمة المرور الحالية',
                  hint: ProfileConstants.currentPasswordHint,
                  controller: currentPasswordController,
                  icon: Icons.lock_outline,
                  obscureText: !showCurrentPassword,
                  suffix: IconButton(
                    icon: Icon(
                      showCurrentPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        showCurrentPassword = !showCurrentPassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return ProfileConstants.emptyCurrentPasswordError;
                    }
                    return null;
                  },
                ),

                // حقل كلمة المرور الجديدة
                ProfileComponents.buildTextField(
                  label: 'كلمة المرور الجديدة',
                  hint: ProfileConstants.newPasswordHint,
                  controller: newPasswordController,
                  icon: Icons.lock_outline,
                  obscureText: !showNewPassword,
                  suffix: IconButton(
                    icon: Icon(
                      showNewPassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        showNewPassword = !showNewPassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return ProfileConstants.emptyNewPasswordError;
                    }
                    if (value.length < 6) {
                      return ProfileConstants.passwordLengthError;
                    }
                    return null;
                  },
                ),

                // حقل تأكيد كلمة المرور الجديدة
                ProfileComponents.buildTextField(
                  label: 'تأكيد كلمة المرور الجديدة',
                  hint: ProfileConstants.confirmPasswordHint,
                  controller: confirmPasswordController,
                  icon: Icons.lock_outline,
                  obscureText: !showConfirmPassword,
                  suffix: IconButton(
                    icon: Icon(
                      showConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        showConfirmPassword = !showConfirmPassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return ProfileConstants.emptyConfirmPasswordError;
                    }
                    if (value != newPasswordController.text) {
                      return ProfileConstants.passwordMismatchError;
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            // زر إلغاء
            TextButton(
              onPressed:
                  isLoading ? null : () => Navigator.of(context).pop(false),
              child: Text(
                ProfileConstants.cancelText,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
            ),

            // زر تغيير
            TextButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      // تحقق من التطابق
                      if (newPasswordController.text !=
                          confirmPasswordController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text(ProfileConstants.passwordMismatchError),
                            backgroundColor: ProfileConstants.dangerColor,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }

                      setState(() {
                        isLoading = true;
                      });

                      final result = await _controller.changePassword(
                        currentPasswordController.text,
                        newPasswordController.text,
                      );

                      setState(() {
                        isLoading = false;
                      });

                      if (result) {
                        Navigator.of(context).pop(true);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                ProfileConstants.invalidCurrentPasswordMessage),
                            backgroundColor: ProfileConstants.dangerColor,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
              style: TextButton.styleFrom(
                foregroundColor: ProfileConstants.kDarkPurple,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      ProfileConstants.changePasswordButtonText,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'SYMBIOAR+LT',
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<ProfileController>(
        builder: (context, controller, _) {
          return Scaffold(
            backgroundColor: Colors.white, // تغيير الخلفية إلى بيضاء
            appBar: AppBar(
              title: const Text(
                ProfileConstants.profileTitle,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
              centerTitle: true,
              backgroundColor: Colors.white, // تغيير خلفية الـ AppBar إلى بيضاء
              foregroundColor:
                  ProfileConstants.kDarkPurple, // تغيير لون النص إلى أزرق داكن
              elevation: 0, // إزالة الظل
              iconTheme: const IconThemeData(
                  color: ProfileConstants.kDarkPurple), // لون الأيقونات
            ),
            body: controller.isLoading
                ? ProfileComponents.buildLoadingIndicator(
                    message: ProfileConstants.loadingDataText,
                  )
                : RefreshIndicator(
                    onRefresh: _loadProfileData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // بطاقة الملف الشخصي
                            ProfileComponents.buildProfileCard(
                              name: controller.userName,
                              major: controller.userMajor,
                              email: controller.userEmail,
                              onEditPressed: _showEditProfileDialog,
                            ),

                            const SizedBox(height: 24),

                            // قسم الإعدادات الشخصية
                            ProfileComponents.buildSettingsSection(
                              title: ProfileConstants.personalSettingsTitle,
                              isFirst: true,
                              children: [
                                // تعديل الملف الشخصي
                                ProfileComponents.buildSettingItem(
                                  icon: Icons.edit,
                                  iconColor: ProfileConstants.secondaryColor,
                                  title: ProfileConstants.editProfileTitle,
                                  subtitle: ProfileConstants.editProfileSubtext,
                                  onTap: _showEditProfileDialog,
                                ),

                                // تغيير كلمة المرور
                                ProfileComponents.buildSettingItem(
                                  icon: Icons.lock_outline,
                                  iconColor: ProfileConstants.accentColor,
                                  title: ProfileConstants.changePasswordTitle,
                                  subtitle:
                                      ProfileConstants.changePasswordSubtitle,
                                  onTap: _changePassword,
                                  showDivider: false,
                                ),
                              ],
                            ),

                            // قسم الخصوصية والأمان
                            ProfileComponents.buildSettingsSection(
                              title: ProfileConstants.securitySettingsTitle,
                              children: [
                                // حذف الحساب
                                ProfileComponents.buildSettingItem(
                                  icon: Icons.delete_outline,
                                  title: ProfileConstants.deleteAccountTitle,
                                  subtitle:
                                      ProfileConstants.deleteAccountSubtitle,
                                  onTap: _showDeleteAccountDialog,
                                  showDivider: false,
                                  isDanger: true,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }

  // مربع حوار تأكيد حذف الحساب
  void _showDeleteAccountDialog() async {
    final confirm = await ProfileComponents.showConfirmationDialog(
      context: context,
      title: ProfileConstants.deleteAccountConfirmationTitle,
      message: ProfileConstants.deleteAccountConfirmationMessage,
      confirmText: ProfileConstants.deleteText,
      isDanger: true,
    );

    if (confirm == true) {
      _showPasswordConfirmationDialog();
    }
  }

  // مربع حوار تأكيد كلمة المرور للحذف
  void _showPasswordConfirmationDialog() {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          ProfileConstants.confirmPasswordTitle,
          style: TextStyle(
            color: ProfileConstants.dangerColor,
            fontWeight: FontWeight.bold,
            fontFamily: 'SYMBIOAR+LT',
          ),
          textAlign: TextAlign.right,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              ProfileConstants.confirmPasswordForDeleteMessage,
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'SYMBIOAR+LT',
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: 'SYMBIOAR+LT',
              ),
              decoration: InputDecoration(
                hintText: ProfileConstants.currentPasswordHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintStyle: const TextStyle(
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              ProfileConstants.cancelText,
              style: TextStyle(
                color: Colors.grey[700],
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteAccount(passwordController.text);
            },
            style: TextButton.styleFrom(
              foregroundColor: ProfileConstants.dangerColor,
            ),
            child: Text(
              ProfileConstants.deleteText,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // حذف الحساب
  Future<void> _deleteAccount(String password) async {
    try {
      final result = await _controller.deleteUserAccount(password);

      if (!mounted) return;

      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(ProfileConstants.deleteAccountSuccessMessage),
            backgroundColor: ProfileConstants.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // العودة إلى شاشة تسجيل الدخول
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_controller.errorMessage ??
                ProfileConstants.invalidCurrentPasswordMessage),
            backgroundColor: ProfileConstants.dangerColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${ProfileConstants.deleteAccountErrorPrefix}$e'),
            backgroundColor: ProfileConstants.dangerColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
