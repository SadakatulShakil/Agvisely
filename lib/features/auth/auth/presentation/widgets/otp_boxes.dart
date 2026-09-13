import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/theme/app_theme_colors.dart';


/// A row of single-digit OTP boxes with auto-advance and backspace handling.
class OtpBoxes extends StatefulWidget {
  final int length;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onCompleted;

  const OtpBoxes({
    super.key,
    this.length = 4,
    required this.onChanged,
    this.onCompleted,
  });

  @override
  State<OtpBoxes> createState() => _OtpBoxesState();
}

class _OtpBoxesState extends State<OtpBoxes> {
  late final List<TextEditingController> _c;
  late final List<FocusNode> _f;

  @override
  void initState() {
    super.initState();
    _c = List.generate(widget.length, (_) => TextEditingController());
    _f = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _c) c.dispose();
    for (final f in _f) f.dispose();
    super.dispose();
  }

  String get _code => _c.map((e) => e.text).join();

  void _onChanged(int i, String v) {
    if (v.isNotEmpty && i < widget.length - 1) {
      _f[i + 1].requestFocus();
    }
    widget.onChanged(_code);
    if (_code.length == widget.length && !_code.contains('')) {
      widget.onCompleted?.call(_code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(widget.length, (i) {
        return SizedBox(
          width: 56,
          height: 60,
          child: KeyboardListener(
            focusNode: FocusNode(skipTraversal: true),
            onKeyEvent: (e) {
              if (e is KeyDownEvent &&
                  e.logicalKey == LogicalKeyboardKey.backspace &&
                  _c[i].text.isEmpty &&
                  i > 0) {
                _f[i - 1].requestFocus();
                _c[i - 1].clear();
                widget.onChanged(_code);
              }
            },
            child: TextField(
              controller: _c[i],
              focusNode: _f[i],
              autofocus: i == 0,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.navy,
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: AppColors.cardLight,
                contentPadding: EdgeInsets.zero,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.dividerLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              onChanged: (v) => _onChanged(i, v),
            ),
          ),
        );
      }),
    );
  }
}
