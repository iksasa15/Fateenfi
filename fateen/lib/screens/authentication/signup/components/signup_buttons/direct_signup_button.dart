import 'package:flutter/material.dart';
import '../../../../../core/constants/appColor.dart'; // Updated import
import '../../constants/signup_strings.dart';

class DirectSignupButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const DirectSignupButton({
    Key? key,
    required this.isLoading,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 24, bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      height: 56,
      child: Material(
        color: context.colorPrimaryLight, // استخدام Extension
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isLoading ? null : onPressed,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  context.colorPrimaryLight, // استخدام Extension
                  context.colorPrimaryDark, // استخدام Extension
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : const Text(
                      'إنشاء حساب',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: 'SYMBIOAR+LT',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
