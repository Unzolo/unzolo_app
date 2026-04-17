import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

// Mock image URLs simulating a gallery
const List<String> _mockGalleryImages = [
  'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
  'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=400',
  'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?w=400',
  'https://images.unsplash.com/photo-1477587458883-47145ed6979e?w=400',
  'https://images.unsplash.com/photo-1589308078059-be1415eab4c3?w=400',
  'https://images.unsplash.com/photo-1599661046289-e31897846e41?w=400',
  'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=400',
  'https://images.unsplash.com/photo-1506197603052-3cc9c3a201bd?w=400',
  'https://images.unsplash.com/photo-1530103862676-de8c9debad1d?w=400',
  'https://images.unsplash.com/photo-1501854140801-50d01698950b?w=400',
  'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=400',
  'https://images.unsplash.com/photo-1434394354979-a235cd36269d?w=400',
];

class ImagePickerGrid extends StatefulWidget {
  final String? selectedUrl;
  final ValueChanged<String> onSelect;

  const ImagePickerGrid({
    super.key,
    required this.selectedUrl,
    required this.onSelect,
  });

  @override
  State<ImagePickerGrid> createState() => _ImagePickerGridState();
}

class _ImagePickerGridState extends State<ImagePickerGrid> {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: _mockGalleryImages.length,
      itemBuilder: (context, index) {
        final url = _mockGalleryImages[index];
        final isSelected = url == widget.selectedUrl;
        return _GalleryTile(
          url: url,
          isSelected: isSelected,
          index: index,
          onTap: () => widget.onSelect(url),
        );
      },
    );
  }
}

class _GalleryTile extends StatefulWidget {
  final String url;
  final bool isSelected;
  final int index;
  final VoidCallback onTap;

  const _GalleryTile({
    required this.url,
    required this.isSelected,
    required this.index,
    required this.onTap,
  });

  @override
  State<_GalleryTile> createState() => _GalleryTileState();
}

class _GalleryTileState extends State<_GalleryTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _selectCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _selectCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: widget.isSelected ? 1.0 : 0.0,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _selectCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(_GalleryTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      widget.isSelected
          ? _selectCtrl.forward()
          : _selectCtrl.reverse();
    }
  }

  @override
  void dispose() {
    _selectCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 200 + widget.index * 30),
      curve: Curves.easeOut,
      builder: (_, v, child) => Opacity(
        opacity: v,
        child: Transform.scale(scale: 0.85 + 0.15 * v, child: child),
      ),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _scaleAnim,
          builder: (_, child) => Transform.scale(
            scale: _scaleAnim.value,
            child: child,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image
              Image.network(
                widget.url,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return Container(color: AppColors.shimmerBase);
                },
              ),

              // Selection overlay
              AnimatedOpacity(
                opacity: widget.isSelected ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  color: AppColors.primary.withAlpha(100),
                  child: const Center(
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),

              // Selection number badge
              if (widget.isSelected)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: Colors.white, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        '1',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
