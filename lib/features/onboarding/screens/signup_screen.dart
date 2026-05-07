import 'package:flutter/material.dart';
import 'package:follow_me/core/services/user_data_service.dart';
import 'package:follow_me/shared/widgets/next_button.dart';
import 'onboarding_my_personality_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  static const _bgColor = Color(0xFFFFFFFF);
  static const _fieldBg = Color(0xFFE9F7F7);
  static const _titleColor = Color(0xFF262626);
  static const _labelColor = Color(0xFF6F6F6F);
  static const _hintColor = Color(0xFF8D8D8D);
  static const _inputColor = Color(0xFF222222);
  static const _selectedBg = Color(0xFF208484);
  static const _selectedText = Color(0xFFF4F4F4);

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  DateTime? _birthDate;
  String? _gender;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _nameCtrl.text.isNotEmpty &&
      _birthDate != null &&
      _gender != null;

  String get _formattedDate {
    if (_birthDate == null) return '';
    final m = _birthDate!.month.toString().padLeft(2, '0');
    final d = _birthDate!.day.toString().padLeft(2, '0');
    return '${_birthDate!.year}.$m.$d';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(2002, 1, 10),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  InputDecoration _decor(String hint, {Widget? suffix}) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: _hintColor,
        ),
        filled: true,
        fillColor: _fieldBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        counterText: '',
        isDense: true,
        suffixIcon: suffix,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 33),
                    const Text(
                      '회원가입',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                        height: 32 / 24,
                        color: _titleColor,
                      ),
                    ),
                    const SizedBox(height: 33),

                    _label('이름'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _nameCtrl,
                      maxLength: 10,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: _inputColor,
                      ),
                      onChanged: (_) => setState(() {}),
                      decoration: _decor('소연수'),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${_nameCtrl.text.length}/10',
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          letterSpacing: 0.4,
                          color: _hintColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 11),

                    _label('생년월일'),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: _fieldBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _formattedDate.isEmpty
                              ? '2002.01.10'
                              : _formattedDate,
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: _birthDate == null
                                ? _hintColor
                                : _inputColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 27),

                    _label('성별'),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _genderBtn('남', 'M'),
                        const SizedBox(width: 8),
                        _genderBtn('여', 'F'),
                      ],
                    ),
                    const SizedBox(height: 27),

                    // _label('이메일'),
                    // const SizedBox(height: 6),
                    // TextField(
                    //   controller: _emailCtrl,
                    //   keyboardType: TextInputType.emailAddress,
                    //   style: const TextStyle(
                    //     fontFamily: 'Pretendard',
                    //     fontWeight: FontWeight.w500,
                    //     fontSize: 16,
                    //     color: _inputColor,
                    //   ),
                    //   onChanged: (_) => setState(() {}),
                    //   decoration: _decor('example@email.com'),
                    // ),
                    // const SizedBox(height: 27),

                    // _label('비밀번호'),
                    // const SizedBox(height: 6),
                    // TextField(
                    //   controller: _passwordCtrl,
                    //   obscureText: _obscurePassword,
                    //   style: const TextStyle(
                    //     fontFamily: 'Pretendard',
                    //     fontWeight: FontWeight.w500,
                    //     fontSize: 16,
                    //     color: _inputColor,
                    //   ),
                    //   onChanged: (_) => setState(() {}),
                    //   decoration: _decor(
                    //     '비밀번호',
                    //     suffix: GestureDetector(
                    //       onTap: () => setState(
                    //         () => _obscurePassword = !_obscurePassword,
                    //       ),
                    //       child: Icon(
                    //         _obscurePassword
                    //             ? Icons.visibility_off_outlined
                    //             : Icons.visibility_outlined,
                    //         color: _hintColor,
                    //         size: 20,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: NextButton(
                onTap: _isValid
                    ? () async {
                        await UserDataService.saveProfile(
                          name: _nameCtrl.text,
                          birthdate: _birthDate!,
                          gender: _gender!,
                        );
                        if (!context.mounted) return;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => OnboardingMyPersonalityScreen(
                              userName: _nameCtrl.text,
                            ),
                          ),
                        );
                      }
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.w400,
          fontSize: 15,
          height: 22 / 15,
          color: _labelColor,
        ),
      );

  Widget _genderBtn(String label, String value) {
    final selected = _gender == value;
    return GestureDetector(
      onTap: () => setState(() => _gender = value),
      child: Container(
        width: 92,
        height: 52,
        decoration: BoxDecoration(
          color: selected ? _selectedBg : _fieldBg,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w500,
            fontSize: 16,
            height: 22 / 16,
            color: selected ? _selectedText : _hintColor,
          ),
        ),
      ),
    );
  }

}
