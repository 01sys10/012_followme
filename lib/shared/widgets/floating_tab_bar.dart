import 'package:flutter/material.dart';

class FloatingTabBar extends StatelessWidget {
  const FloatingTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;

  static const _tabs = [
    (icon: Icons.calendar_month, label: '주간 일정'),
    (icon: Icons.task_alt, label: '미션'),
    (icon: Icons.settings, label: '설정'),
  ];

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      heightFactor: 1.0,
      child: Container(
        width: 302,
        height: 62,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(296),
          color: const Color(0xFFF7F7F7),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1F000000),
              blurRadius: 40,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: List.generate(_tabs.length, (i) {
            final selected = i == selectedIndex;
            return Expanded(
              child: GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 62,
                  decoration: selected
                      ? BoxDecoration(
                          color: const Color(0xFFEDEDED),
                          borderRadius: BorderRadius.circular(100),
                        )
                      : null,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _tabs[i].icon,
                        size: 24,
                        color: selected
                            ? const Color(0xFF208484)
                            : const Color(0xFF1A1A1A),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _tabs[i].label,
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          height: 12 / 10,
                          color: selected
                              ? const Color(0xFF208484)
                              : const Color(0xFF1A1A1A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
