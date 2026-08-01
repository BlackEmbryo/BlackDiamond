/// Shared reusable widgets for modals
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app.dart';

class ModalCloseButton extends StatelessWidget {
  const ModalCloseButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        width: 30, height: 30,
        decoration: BoxDecoration(
          color: AppColors.bgSecondary,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
        ),
        alignment: Alignment.center,
        child: Text('✕',
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary)),
      ),
    );
  }
}
