import 'package:flutter/material.dart';

class NextButton extends StatelessWidget {
  const NextButton({super.key, this.onTap, this.label = '다음으로'});

  final VoidCallback? onTap;
  final String label;

  static const _activeColor = Color(0xFF208484);
  static const _inactiveColor = Color(0xFFE9F7F7);
  static const _activeTextColor = Color(0xFFF4F4F4);
  static const _inactiveTextColor = Color(0xFFDADFE5);

  @override
  Widget build(BuildContext context) {
    final active = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 54,
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: active ? _activeColor : _inactiveColor,
            borderRadius: BorderRadius.circular(1000),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F000000),
                blurRadius: 8,
                offset: Offset(0, 1),
              ),
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w600,
                fontSize: 16,
                height: 22 / 16,
                color: active ? _activeTextColor : _inactiveTextColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
