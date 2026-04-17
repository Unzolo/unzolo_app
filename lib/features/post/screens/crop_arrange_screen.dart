import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class CropArrangeScreen extends StatefulWidget {
  final String imageUrl;

  const CropArrangeScreen({super.key, required this.imageUrl});

  @override
  State<CropArrangeScreen> createState() => _CropArrangeScreenState();
}

enum _AspectRatio { square, portrait, story, landscape, classic }

extension _AspectRatioX on _AspectRatio {
  String get label {
    switch (this) {
      case _AspectRatio.square:
        return 'Square';
      case _AspectRatio.portrait:
        return 'Portrait';
      case _AspectRatio.story:
        return 'Story';
      case _AspectRatio.landscape:
        return 'Landscape';
      case _AspectRatio.classic:
        return 'Classic';
    }
  }

  double get ratio {
    switch (this) {
      case _AspectRatio.square:
        return 1.0;
      case _AspectRatio.portrait:
        return 4 / 5;
      case _AspectRatio.story:
        return 9 / 16;
      case _AspectRatio.landscape:
        return 16 / 9;
      case _AspectRatio.classic:
        return 4 / 3;
    }
  }

}

class _CropArrangeScreenState extends State<CropArrangeScreen>
    with SingleTickerProviderStateMixin {
  _AspectRatio _selected = _AspectRatio.square;
  bool _showGrid = true;

  late AnimationController _ratioCtrl;
  late Animation<double> _ratioAnim;

  @override
  void initState() {
    super.initState();
    _ratioCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
    _ratioAnim = CurvedAnimation(parent: _ratioCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ratioCtrl.dispose();
    super.dispose();
  }

  void _selectRatio(_AspectRatio ratio) {
    if (ratio == _selected) return;
    setState(() => _selected = ratio);
    _ratioCtrl
      ..reset()
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          'Crop & Arrange',
          style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(_selected),
            child: Text(
              'Next',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Image preview with crop grid
          Expanded(
            child: Center(
              child: AnimatedBuilder(
                animation: _ratioAnim,
                builder: (context, child) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width,
                      maxHeight: MediaQuery.of(context).size.width * 1.2,
                    ),
                    child: AspectRatio(
                      aspectRatio: _selected.ratio,
                      child: child,
                    ),
                  );
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Image
                    Image.network(
                      widget.imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: AppColors.shimmerBase,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                    ),

                    // Crop grid overlay
                    if (_showGrid) const _CropGridOverlay(),

                    // Grid toggle button
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: () => setState(() => _showGrid = !_showGrid),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _showGrid
                                ? Colors.white.withAlpha(200)
                                : Colors.black.withAlpha(120),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.grid_on_rounded,
                            size: 18,
                            color: _showGrid ? Colors.black : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Aspect ratio selector
          Container(
            color: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                // Label
                Text(
                  'Aspect Ratio',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: Colors.white70,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),

                // Ratio chips
                SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: _AspectRatio.values.map((ratio) {
                      final isSelected = ratio == _selected;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _RatioChip(
                          ratio: ratio,
                          isSelected: isSelected,
                          onTap: () => _selectRatio(ratio),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Bottom safe area
          Container(
            color: Colors.black,
            height: MediaQuery.of(context).padding.bottom,
          ),
        ],
      ),
    );
  }
}

class _RatioChip extends StatefulWidget {
  final _AspectRatio ratio;
  final bool isSelected;
  final VoidCallback onTap;

  const _RatioChip({
    required this.ratio,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_RatioChip> createState() => _RatioChipState();
}

class _RatioChipState extends State<_RatioChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: widget.isSelected ? 1.0 : 0.0,
    );
    _scale = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );
  }

  @override
  void didUpdateWidget(_RatioChip old) {
    super.didUpdateWidget(old);
    if (widget.isSelected != old.isSelected) {
      widget.isSelected ? _ctrl.forward() : _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isSelected ? AppColors.primary : Colors.white12,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: widget.isSelected ? AppColors.primary : Colors.white24,
              width: 1.5,
            ),
          ),
          child: Text(
            widget.ratio.label,
            style: AppTextStyles.labelMedium.copyWith(
              color: widget.isSelected ? Colors.white : Colors.white70,
              fontWeight: widget.isSelected
                  ? FontWeight.w700
                  : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class _CropGridOverlay extends StatelessWidget {
  const _CropGridOverlay();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GridPainter(),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(60)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    // Rule-of-thirds grid (3x3)
    for (int i = 1; i < 3; i++) {
      final x = size.width * i / 3;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);

      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Corner brackets
    final bracketPaint = Paint()
      ..color = Colors.white.withAlpha(200)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const len = 20.0;
    const inset = 0.0;

    // Top-left
    canvas.drawLine(const Offset(inset, inset), const Offset(inset + len, inset), bracketPaint);
    canvas.drawLine(const Offset(inset, inset), const Offset(inset, inset + len), bracketPaint);

    // Top-right
    canvas.drawLine(Offset(size.width - inset, inset), Offset(size.width - inset - len, inset), bracketPaint);
    canvas.drawLine(Offset(size.width - inset, inset), Offset(size.width - inset, inset + len), bracketPaint);

    // Bottom-left
    canvas.drawLine(Offset(inset, size.height - inset), Offset(inset + len, size.height - inset), bracketPaint);
    canvas.drawLine(Offset(inset, size.height - inset), Offset(inset, size.height - inset - len), bracketPaint);

    // Bottom-right
    canvas.drawLine(Offset(size.width - inset, size.height - inset), Offset(size.width - inset - len, size.height - inset), bracketPaint);
    canvas.drawLine(Offset(size.width - inset, size.height - inset), Offset(size.width - inset, size.height - inset - len), bracketPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
