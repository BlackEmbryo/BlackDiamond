import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app.dart';

enum ToastType { gold, success, error, normal }

class ToastService {
  static OverlayEntry? _current;

  static void show(BuildContext context, String message, {ToastType type = ToastType.gold}) {
    if (_current?.mounted == true) {
      _current?.remove();
    }
    _current = null;

    Color borderColor;
    Color textColor;
    switch (type) {
      case ToastType.success:
        borderColor = AppColors.green.withValues(alpha: 0.4);
        textColor   = AppColors.green;
        break;
      case ToastType.error:
        borderColor = AppColors.red.withValues(alpha: 0.4);
        textColor   = AppColors.red;
        break;
      case ToastType.gold:
        borderColor = AppColors.borderBright;
        textColor   = AppColors.gold;
        break;
      case ToastType.normal:
        borderColor = AppColors.border;
        textColor   = AppColors.textPrimary;
        break;
    }

    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (_) => _ToastWidget(message: message, borderColor: borderColor, textColor: textColor),
    );
    _current = entry;
    overlay.insert(entry);

    Future.delayed(const Duration(seconds: 3), () {
      if (entry.mounted) {
        entry.remove();
      }
      if (_current == entry) _current = null;
    });
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final Color borderColor;
  final Color textColor;
  const _ToastWidget({required this.message, required this.borderColor, required this.textColor});

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide   = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 100,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _opacity,
          child: Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                border: Border.all(color: widget.borderColor),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 20)],
              ),
              child: Text(
                widget.message,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: widget.textColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
