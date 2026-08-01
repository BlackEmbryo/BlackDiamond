
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app.dart';
import '../screens/login_screen.dart';
import '../services/session_service.dart';
import 'pin_auth_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotCtrl;
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    // Rotating diamond — 8s linear infinite (matches CSS rotateDiamond)
    _rotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // Pulse glow — 2s ease-in-out infinite (matches CSS pulse)
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Navigate after 3 s (matches JS setTimeout 3000)
    Future.delayed(const Duration(seconds: 3), () async {
      final user = await SessionService.getUser();
      if (!mounted) return;
      
      Widget nextScreen = const LoginScreen();
      if (user != null && user.mobile.isNotEmpty) {
        nextScreen = PinAuthScreen(mobile: user.mobile);
      }
      
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, a, __) => nextScreen,
          transitionsBuilder: (_, a, __, child) =>
              FadeTransition(opacity: a, child: child),
          transitionDuration: const Duration(milliseconds: 350),
        ),
      );
    });
  }

  @override
  void dispose() {
    _rotCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [Color(0xFF0D0D1A), Color(0xFF050508)],
            stops: [0.0, 0.7],
          ),
        ),
        child: Stack(
          children: [
            // Particle overlay
            const _ParticleOverlay(),
            // Main content
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Rotating diamond SVG equivalent
                  AnimatedBuilder(
                    animation: _rotCtrl,
                    builder: (_, __) => Transform.rotate(
                      angle: _rotCtrl.value * 2 * 3.14159265,
                      child: AnimatedBuilder(
                        animation: _pulseCtrl,
                        builder: (_, __) => Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.gold.withValues(alpha:
                                    0.3 + _pulseCtrl.value * 0.25),
                                blurRadius: 20 + _pulseCtrl.value * 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: CustomPaint(painter: _DiamondPainter()),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // "BLACK" title
                  Text(
                    'BLACK',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 6,
                      color: AppColors.textPrimary,
                      shadows: [
                        Shadow(
                          color: AppColors.gold.withValues(alpha: 0.3),
                          blurRadius: 30,
                        ),
                      ],
                    ),
                  ),
                  // "DIAMOND" in gold
                  Text(
                    'DIAMOND',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 6,
                      color: AppColors.gold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'INVEST IN WHAT LASTS FOREVER',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      letterSpacing: 3,
                      color: AppColors.goldDim,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Progress bar — matches CSS loadProgress 2.5s
                  _SplashProgressBar(),
                ],
              )
                  .animate()
                  .fadeIn(duration: 800.ms)
                  .slideY(begin: 0.3, end: 0, duration: 800.ms, curve: Curves.easeOut),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Diamond CustomPainter (replaces inline SVG) ────────────────────────────
class _DiamondPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Outer hexagon fill with dark blue gradient
    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final outerPath = _hexPath(cx, cy, cx - 2);
    canvas.drawPath(outerPath, fillPaint);

    // Gold stroke gradient
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFD4A853), Color(0xFFFFD700), Color(0xFFC8860A)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(outerPath, strokePaint);

    // Inner lines
    final dimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..color = AppColors.gold.withOpacity(0.2);
    canvas.drawLine(Offset(cx, 2), Offset(cx, size.height - 2), dimPaint);
    canvas.drawLine(Offset(2, cy - 12), Offset(size.width - 2, cy + 12), dimPaint);
    canvas.drawLine(Offset(2, cy + 12), Offset(size.width - 2, cy - 12), dimPaint);
  }

  Path _hexPath(double cx, double cy, double r) {
    final path = Path();
    // Hexagon points matching SVG polygon "30,2 58,18 58,42 30,58 2,42 2,18"
    // normalised to our canvas
    final points = [
      Offset(cx, 2),
      Offset(cx + r * 0.97, cy - r * 0.4),
      Offset(cx + r * 0.97, cy + r * 0.4),
      Offset(cx, cy * 2 - 2),
      Offset(cx - r * 0.97, cy + r * 0.4),
      Offset(cx - r * 0.97, cy - r * 0.4),
    ];
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) path.lineTo(points[i].dx, points[i].dy);
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(_DiamondPainter old) => false;
}

// ── Particle background ────────────────────────────────────────────────────
class _ParticleOverlay extends StatelessWidget {
  const _ParticleOverlay();
  @override
  Widget build(BuildContext context) {
    // Static gold dots scattered across screen
    return IgnorePointer(
      child: CustomPaint(
        size: MediaQuery.of(context).size,
        painter: _ParticlePainter(),
      )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .fadeIn(begin: 0.5, duration: 3.seconds),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> _particles = const [
    _Particle(0.20, 0.30, 0.6),
    _Particle(0.80, 0.20, 0.4),
    _Particle(0.60, 0.70, 0.5),
    _Particle(0.40, 0.80, 0.3),
    _Particle(0.90, 0.60, 0.6),
    _Particle(0.10, 0.60, 0.5),
    _Particle(0.70, 0.40, 0.4),
    _Particle(0.50, 0.10, 0.7),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particles) {
      canvas.drawCircle(
        Offset(size.width * p.x, size.height * p.y),
        p.size,
        Paint()..color = AppColors.gold.withValues(alpha: p.opacity),
      );
    }
  }

  // QUAL-5 fix: return true so the painter re-draws when the overlay fades in/out
  @override
  bool shouldRepaint(_ParticlePainter _) => true;
}

class _Particle {
  final double x, y, opacity;
  final double size;
  const _Particle(this.x, this.y, this.opacity, {this.size = 1.5});
}

// ── Progress Bar ───────────────────────────────────────────────────────────
class _SplashProgressBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 2,
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(2),
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 2500),
        builder: (_, value, __) => FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: value,
          child: Container(
            decoration: BoxDecoration(
              gradient: AppGradients.gold,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}
