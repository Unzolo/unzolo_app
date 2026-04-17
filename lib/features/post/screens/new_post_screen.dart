import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../widgets/image_picker_grid.dart';
import '../widgets/tag_input.dart';
import 'crop_arrange_screen.dart';

class NewPostScreen extends StatefulWidget {
  const NewPostScreen({super.key});

  @override
  State<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen>
    with TickerProviderStateMixin {
  final _captionCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  String? _selectedImageUrl;
  List<String> _tags = [];
  bool _showGallery = false;
  bool _isSharing = false;
  bool _shared = false;

  late AnimationController _shareCtrl;
  late Animation<double> _shareFade;
  late Animation<double> _shareScale;

  late AnimationController _successCtrl;
  late Animation<double> _successScale;

  @override
  void initState() {
    super.initState();

    _shareCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _shareFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
          parent: _shareCtrl,
          curve: const Interval(0.0, 0.5, curve: Curves.easeIn)),
    );
    _shareScale = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _shareCtrl, curve: Curves.easeIn),
    );

    _successCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _successScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _successCtrl, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _captionCtrl.dispose();
    _scrollCtrl.dispose();
    _shareCtrl.dispose();
    _successCtrl.dispose();
    super.dispose();
  }

  Future<void> _share() async {
    if (_captionCtrl.text.trim().isEmpty && _selectedImageUrl == null) {
      _showEmptyWarning();
      return;
    }
    setState(() => _isSharing = true);

    // Animate out form
    await _shareCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 200));

    setState(() => _shared = true);
    await _successCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) Navigator.of(context).pop();
  }

  void _showEmptyWarning() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Add a photo or caption to share'),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _openCropScreen() {
    if (_selectedImageUrl == null) return;
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (ctx, a1, a2) =>
            CropArrangeScreen(imageUrl: _selectedImageUrl!),
        transitionsBuilder: (ctx, anim, a2, child) => SlideTransition(
          position: Tween(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_shared) return _SuccessView(scaleAnim: _successScale);

    return AnimatedBuilder(
      animation: _shareCtrl,
      builder: (_, child) => Opacity(
        opacity: _shareFade.value,
        child: Transform.scale(scale: _shareScale.value, child: child),
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                controller: _scrollCtrl,
                slivers: [
                  // Selected image preview
                  SliverToBoxAdapter(
                    child: _ImagePreviewSection(
                      imageUrl: _selectedImageUrl,
                      onAddImage: () =>
                          setState(() => _showGallery = !_showGallery),
                      onCrop: _openCropScreen,
                    ),
                  ),

                  // Caption field
                  SliverToBoxAdapter(
                    child: _CaptionSection(controller: _captionCtrl),
                  ),

                  // Tags input
                  SliverToBoxAdapter(
                    child: _TagsSection(
                      tags: _tags,
                      onChanged: (t) => setState(() => _tags = t),
                    ),
                  ),

                  // Options row
                  SliverToBoxAdapter(
                    child: _PostOptionsRow(),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                ],
              ),
            ),

            // Gallery panel (slides up)
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOut,
              height: _showGallery ? 320 : 0,
              child: _showGallery
                  ? ImagePickerGrid(
                      selectedUrl: _selectedImageUrl,
                      onSelect: (url) =>
                          setState(() => _selectedImageUrl = url),
                    )
                  : const SizedBox.shrink(),
            ),

            // Share bar
            _ShareBar(
              isSharing: _isSharing,
              onShare: _share,
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text('New Post', style: AppTextStyles.headlineMedium),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.divider),
      ),
    );
  }
}

// ── Image Preview Section ─────────────────────────────────────────────────────

class _ImagePreviewSection extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback onAddImage;
  final VoidCallback onCrop;

  const _ImagePreviewSection({
    required this.imageUrl,
    required this.onAddImage,
    required this.onCrop,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      builder: (_, v, child) =>
          Opacity(opacity: v, child: Transform.scale(scale: 0.95 + 0.05 * v, child: child)),
      child: Container(
        margin: const EdgeInsets.all(20),
        height: 240,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: imageUrl != null ? AppColors.border : AppColors.primary.withAlpha(60),
            width: imageUrl != null ? 1 : 1.5,
            style: imageUrl != null ? BorderStyle.solid : BorderStyle.solid,
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: imageUrl != null
              ? _PreviewImage(
                  key: ValueKey(imageUrl),
                  imageUrl: imageUrl!,
                  onCrop: onCrop,
                  onReplace: onAddImage,
                )
              : _AddImagePlaceholder(onAdd: onAddImage),
        ),
      ),
    );
  }
}

class _PreviewImage extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onCrop;
  final VoidCallback onReplace;

  const _PreviewImage({
    super.key,
    required this.imageUrl,
    required this.onCrop,
    required this.onReplace,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(imageUrl, fit: BoxFit.cover),

          // Action buttons overlay
          Positioned(
            top: 10,
            right: 10,
            child: Row(
              children: [
                _OverlayButton(
                  icon: Icons.crop_rounded,
                  label: 'Crop',
                  onTap: onCrop,
                ),
                const SizedBox(width: 8),
                _OverlayButton(
                  icon: Icons.swap_horiz_rounded,
                  label: 'Change',
                  onTap: onReplace,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OverlayButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _OverlayButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_OverlayButton> createState() => _OverlayButtonState();
}

class _OverlayButtonState extends State<_OverlayButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(130),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 14, color: Colors.white),
              const SizedBox(width: 4),
              Text(
                widget.label,
                style: AppTextStyles.labelSmall.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddImagePlaceholder extends StatefulWidget {
  final VoidCallback onAdd;
  const _AddImagePlaceholder({required this.onAdd});

  @override
  State<_AddImagePlaceholder> createState() => _AddImagePlaceholderState();
}

class _AddImagePlaceholderState extends State<_AddImagePlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatCtrl;
  late Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -8, end: 0).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onAdd,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _floatAnim,
            builder: (_, child) => Transform.translate(
              offset: Offset(0, _floatAnim.value),
              child: child,
            ),
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withAlpha(80),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.add_photo_alternate_outlined,
                size: 32,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text('Add Photo', style: AppTextStyles.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Tap to choose from gallery',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}

// ── Caption Section ───────────────────────────────────────────────────────────

class _CaptionSection extends StatefulWidget {
  final TextEditingController controller;
  const _CaptionSection({required this.controller});

  @override
  State<_CaptionSection> createState() => _CaptionSectionState();
}

class _CaptionSectionState extends State<_CaptionSection> {
  final _focus = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      builder: (_, v, child) =>
          Opacity(opacity: v, child: Transform.translate(offset: Offset(0, 10 * (1 - v)), child: child)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: _focused
                  ? AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary, fontWeight: FontWeight.w600)
                  : AppTextStyles.labelMedium
                      .copyWith(color: AppColors.textSecondary),
              child: const Text('Caption'),
            ),
            const SizedBox(height: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: _focused
                    ? AppColors.primarySurface
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _focused ? AppColors.primary : AppColors.border,
                  width: _focused ? 1.5 : 1,
                ),
              ),
              child: TextField(
                controller: widget.controller,
                focusNode: _focus,
                maxLines: 4,
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Write a caption...',
                  hintStyle: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textHint),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tags Section ──────────────────────────────────────────────────────────────

class _TagsSection extends StatelessWidget {
  final List<String> tags;
  final ValueChanged<List<String>> onChanged;

  const _TagsSection({required this.tags, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      builder: (_, v, child) =>
          Opacity(opacity: v, child: child),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tags',
                style: AppTextStyles.labelMedium
                    .copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            TagInput(tags: tags, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}

// ── Post Options Row ──────────────────────────────────────────────────────────

class _PostOptionsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (_, v, child) => Opacity(opacity: v, child: child),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            _OptionChip(icon: Icons.location_on_outlined, label: 'Location'),
            const SizedBox(width: 10),
            _OptionChip(icon: Icons.people_outline, label: 'Tag People'),
            const SizedBox(width: 10),
            _OptionChip(icon: Icons.public_outlined, label: 'Public'),
          ],
        ),
      ),
    );
  }
}

class _OptionChip extends StatefulWidget {
  final IconData icon;
  final String label;
  const _OptionChip({required this.icon, required this.label});

  @override
  State<_OptionChip> createState() => _OptionChipState();
}

class _OptionChipState extends State<_OptionChip> {
  bool _active = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _active = !_active),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _active ? AppColors.primarySurface : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _active ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon,
                size: 14,
                color: _active ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: 5),
            Text(
              widget.label,
              style: AppTextStyles.labelSmall.copyWith(
                color: _active ? AppColors.primary : AppColors.textSecondary,
                fontWeight: _active ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Share Bar ─────────────────────────────────────────────────────────────────

class _ShareBar extends StatelessWidget {
  final bool isSharing;
  final VoidCallback onShare;

  const _ShareBar({required this.isSharing, required this.onShare});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: AppButton(
            label: 'Share Post',
            onPressed: isSharing ? null : onShare,
            isLoading: isSharing,
            icon: Icons.send_rounded,
          ),
        ),
      ),
    );
  }
}

// ── Success View ──────────────────────────────────────────────────────────────

class _SuccessView extends StatelessWidget {
  final Animation<double> scaleAnim;

  const _SuccessView({required this.scaleAnim});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: AnimatedBuilder(
          animation: scaleAnim,
          builder: (_, child) =>
              Transform.scale(scale: scaleAnim.value, child: child),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated check circle
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 3),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 52,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text('Post Shared!', style: AppTextStyles.headlineLarge),
              const SizedBox(height: 8),
              Text(
                'Your post is live for everyone to see.',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
