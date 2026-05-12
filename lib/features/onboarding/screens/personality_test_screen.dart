import 'package:flutter/material.dart';

/// 본인·이상향 성향 테스트에 공용으로 쓰이는 화면.
/// [accentColor]와 [cardBgColor]로 테마를 구분하고,
/// [questions]로 사용할 질문 리스트를 지정하며,
/// [onComplete]에서 6개 카테고리 점수 리스트를 받아 다음 화면으로 연결한다.
class PersonalityTestScreen extends StatefulWidget {
  const PersonalityTestScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.cardBgColor,
    required this.questions,
    required this.onComplete,
    this.titleWidget,
    this.showExitConfirm = false,
  });

  final String title;
  final String subtitle;
  final Color accentColor;
  final Color cardBgColor;
  final List<String> questions;
  final void Function(List<int> scores) onComplete;
  final Widget? titleWidget;
  final bool showExitConfirm;

  @override
  State<PersonalityTestScreen> createState() => _PersonalityTestScreenState();
}

class _PersonalityTestScreenState extends State<PersonalityTestScreen> {
  static const _bgColor = Color(0xFFFFFFFF);
  static const _titleColor = Color(0xFF262626);
  static const _subtitleColor = Color(0xFF6F6F6F);
  static const _unselectedColor = Color(0xFFDADFE5);
  static const _textColor = Color(0xFF222222);

  int _currentIndex = 0;
  late final List<int?> _scores;
  bool _advancing = false;

  @override
  void initState() {
    super.initState();
    _scores = List.filled(widget.questions.length, null);
  }

  Future<void> _handleExit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          '검사를 그만할까요?',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          '지금까지 한 테스트가 저장되지 않아요.',
          style: TextStyle(fontFamily: 'Pretendard'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              '계속하기',
              style: TextStyle(color: Color(0xFF6F6F6F)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              '나가기',
              style: TextStyle(color: Color(0xFFD94C4C)),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) Navigator.of(context).pop();
  }

  /// 질문별 점수를 카테고리별(6개)로 합산
  /// 각 카테고리는 5개 질문 (1-5, 6-10, 11-15, 16-20, 21-25, 26-30)
  List<int> _aggregateScores() {
    final result = <int>[];
    const questionsPerCategory = 5;
    const totalCategories = 6;
    for (int i = 0; i < totalCategories; i++) {
      int sum = 0;
      for (int j = 0; j < questionsPerCategory; j++) {
        final index = i * questionsPerCategory + j;
        sum += _scores[index] ?? 0;
      }
      result.add(sum);
    }
    return result;
  }

  Future<void> _selectOption(int score) async {
    if (_advancing) return;
    setState(() {
      _scores[_currentIndex] = score;
      _advancing = true;
    });

    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;

    if (_currentIndex < widget.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _advancing = false;
      });
    } else {
      widget.onComplete(_aggregateScores());
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentIndex + 1) / widget.questions.length;

    return PopScope(
      canPop: !widget.showExitConfirm,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleExit();
      },
      child: Scaffold(
        backgroundColor: _bgColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                if (widget.showExitConfirm) ...[
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: _handleExit,
                      child: const Icon(
                        Icons.close,
                        size: 24,
                        color: Color(0xFF6F6F6F),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: _unselectedColor,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            widget.accentColor,
                          ),
                          minHeight: 4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${_currentIndex + 1}/${widget.questions.length}',
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                        color: _subtitleColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                widget.titleWidget ??
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                        height: 32 / 24,
                        color: _titleColor,
                      ),
                    ),
                const SizedBox(height: 6),
                Text(
                  widget.subtitle,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                    height: 22 / 15,
                    color: _subtitleColor,
                  ),
                ),
                const Spacer(flex: 2),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.04, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: Container(
                    key: ValueKey(_currentIndex),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: widget.cardBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.questions[_currentIndex],
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        height: 1.6,
                        color: _textColor,
                      ),
                    ),
                  ),
                ),
                const Spacer(flex: 2),
                _AnswerRow(
                  selected: _scores[_currentIndex],
                  accentColor: widget.accentColor,
                  onSelect: _selectOption,
                ),
                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnswerRow extends StatelessWidget {
  const _AnswerRow({
    required this.selected,
    required this.accentColor,
    required this.onSelect,
  });

  final int? selected;
  final Color accentColor;
  final void Function(int) onSelect;

  static const _unselected = Color(0xFFDADFE5);
  static const _maxCircleSize = 60.0;

  Widget _option(int score, String label, double size) {
    final isSelected = selected == score;
    return GestureDetector(
      onTap: () => onSelect(score),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: _maxCircleSize,
            height: _maxCircleSize,
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? accentColor : _unselected,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w500,
              fontSize: 12,
              height: 1.4,
              color: Color(0xFF222222),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _option(1, '매우 아니다', 60),
        _option(2, '아니다', 50),
        _option(3, '보통', 35),
        _option(4, '그렇다', 50),
        _option(5, '매우 그렇다', 60),
      ],
    );
  }
}
