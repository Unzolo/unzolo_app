import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/mock_data.dart';
import '../../../shared/widgets/app_button.dart';
import '../widgets/itinerary_timeline.dart';
import '../widgets/included_section.dart';
import '../widgets/highlights_section.dart';
import '../widgets/things_to_carry_section.dart';

class PackageDetailScreen extends StatefulWidget {
  final String packageId;

  const PackageDetailScreen({super.key, required this.packageId});

  @override
  State<PackageDetailScreen> createState() => _PackageDetailScreenState();
}

class _PackageDetailScreenState extends State<PackageDetailScreen>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late TabController _tabController;
  double _headerOpacity = 0.0;

  static const double _headerHeight = 320.0;
  static const double _appBarHeight = 60.0;

  MockPackage? _package;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _tabController = TabController(length: 3, vsync: this);
    _package = MockData.packages.firstWhere(
      (p) => p.id == widget.packageId,
      orElse: () => MockData.packages.first,
    );
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    final opacity =
        (offset / (_headerHeight - _appBarHeight)).clamp(0.0, 1.0);
    if ((opacity - _headerOpacity).abs() > 0.01) {
      setState(() => _headerOpacity = opacity);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final package = _package;
    if (package == null) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(package),
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: _ParallaxHeader(
                  package: package,
                  scrollController: _scrollController,
                  height: _headerHeight,
                ),
              ),
              SliverToBoxAdapter(
                child: _PackageContent(
                  package: package,
                  tabController: _tabController,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
          _StickyJoinBar(package: package),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(MockPackage package) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(_appBarHeight),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        color: AppColors.background
            .withAlpha((_headerOpacity * 255).toInt()),
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                _CircleNavButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onDark: _headerOpacity < 0.5,
                  onTap: () => Navigator.of(context).pop(),
                ),
                const Spacer(),
                AnimatedOpacity(
                  opacity: _headerOpacity,
                  duration: const Duration(milliseconds: 150),
                  child: Text(package.title,
                      style: AppTextStyles.titleLarge),
                ),
                const Spacer(),
                _CircleNavButton(
                  icon: Icons.favorite_border_rounded,
                  onDark: _headerOpacity < 0.5,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Parallax Header ───────────────────────────────────────────────────────────

class _ParallaxHeader extends StatelessWidget {
  final MockPackage package;
  final ScrollController scrollController;
  final double height;

  const _ParallaxHeader({
    required this.package,
    required this.scrollController,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Parallax image
          AnimatedBuilder(
            animation: scrollController,
            builder: (context, child) {
              final offset = scrollController.hasClients
                  ? scrollController.offset
                  : 0.0;
              return Transform.translate(
                offset: Offset(0, offset * 0.4),
                child: child,
              );
            },
            child: Hero(
              tag: 'package_image_${package.id}',
              child: CachedNetworkImage(
                imageUrl: package.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: height,
              ),
            ),
          ),

          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withAlpha(40),
                  Colors.transparent,
                  Colors.black.withAlpha(190),
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),

          // Header info
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category badge
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                  builder: (_, value, child) => Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(-20 * (1 - value), 0),
                      child: child,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      package.category,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Title
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                  builder: (_, value, child) => Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 16 * (1 - value)),
                      child: child,
                    ),
                  ),
                  child: Text(
                    package.title,
                    style: AppTextStyles.displayMedium
                        .copyWith(color: Colors.white),
                  ),
                ),

                const SizedBox(height: 6),

                // Location + Rating
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOut,
                  builder: (_, value, child) =>
                      Opacity(opacity: value, child: child),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          size: 14, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(
                        package.location,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: Colors.white70),
                      ),
                      const Spacer(),
                      // Rating pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(30),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.white.withAlpha(60)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded,
                                size: 14, color: AppColors.warning),
                            const SizedBox(width: 4),
                            Text(
                              '${package.rating} (${package.reviewCount})',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Package Content ───────────────────────────────────────────────────────────

class _PackageContent extends StatelessWidget {
  final MockPackage package;
  final TabController tabController;

  const _PackageContent({
    required this.package,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      transform: Matrix4.translationValues(0, -28, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Quick stats
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
            builder: (_, value, child) => Opacity(
              opacity: value,
              child: Transform.translate(
                  offset: Offset(0, 12 * (1 - value)), child: child),
            ),
            child: _QuickStatsRow(package: package),
          ),

          const SizedBox(height: 24),

          // Tab bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _ContentTabBar(tabController: tabController),
          ),

          const SizedBox(height: 24),

          _SectionWrapper(
            title: 'Package Highlights',
            child: HighlightsSection(highlights: package.highlights),
          ),
          _SectionWrapper(
            title: 'Included in Package',
            child: IncludedSection(items: package.included),
          ),
          _SectionWrapper(
            title: 'Daily Itinerary',
            child: ItineraryTimeline(days: package.itinerary),
          ),
          _SectionWrapper(
            title: 'Things to Carry',
            child: ThingsToCarrySection(items: package.thingsToCarry),
          ),
        ],
      ),
    );
  }
}

// ── Quick Stats ───────────────────────────────────────────────────────────────

class _QuickStatsRow extends StatelessWidget {
  final MockPackage package;

  const _QuickStatsRow({required this.package});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _StatCard(
            icon: Icons.calendar_today_outlined,
            value: '${package.durationDays} Days',
            label: 'Duration',
          ),
          const SizedBox(width: 12),
          _StatCard(
            icon: Icons.people_outline_rounded,
            value: '${package.reviewCount}+',
            label: 'Explorers',
          ),
          const SizedBox(width: 12),
          _StatCard(
            icon: Icons.currency_rupee_rounded,
            value: '₹${_fmt(package.price)}',
            label: 'Per person',
            valueColor: AppColors.accent,
          ),
        ],
      ),
    );
  }

  String _fmt(double price) => price
      .toStringAsFixed(0)
      .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color? valueColor;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(height: 6),
            Text(
              value,
              style: AppTextStyles.titleLarge.copyWith(
                color: valueColor ?? AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            Text(label, style: AppTextStyles.labelSmall),
          ],
        ),
      ),
    );
  }
}

// ── Tab Bar ───────────────────────────────────────────────────────────────────

class _ContentTabBar extends StatelessWidget {
  final TabController tabController;

  const _ContentTabBar({required this.tabController});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: tabController,
        indicator: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(9),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTextStyles.labelMedium
            .copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: AppTextStyles.labelMedium,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Itinerary'),
          Tab(text: 'Details'),
        ],
      ),
    );
  }
}

// ── Section Wrapper ───────────────────────────────────────────────────────────

class _SectionWrapper extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionWrapper({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.headlineSmall),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ── Circle Nav Button ─────────────────────────────────────────────────────────

class _CircleNavButton extends StatefulWidget {
  final IconData icon;
  final bool onDark;
  final VoidCallback onTap;

  const _CircleNavButton({
    required this.icon,
    required this.onDark,
    required this.onTap,
  });

  @override
  State<_CircleNavButton> createState() => _CircleNavButtonState();
}

class _CircleNavButtonState extends State<_CircleNavButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: widget.onDark
                ? Colors.white.withAlpha(50)
                : AppColors.surfaceVariant,
            shape: BoxShape.circle,
          ),
          child: Icon(
            widget.icon,
            size: 18,
            color: widget.onDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

// ── Sticky Join Bar ───────────────────────────────────────────────────────────

class _StickyJoinBar extends StatefulWidget {
  final MockPackage package;

  const _StickyJoinBar({required this.package});

  @override
  State<_StickyJoinBar> createState() => _StickyJoinBarState();
}

class _StickyJoinBarState extends State<_StickyJoinBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideAnim = Tween<double>(begin: 80, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, child) => Opacity(
          opacity: _fadeAnim.value,
          child: Transform.translate(
            offset: Offset(0, _slideAnim.value),
            child: child,
          ),
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 20,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Row(
                children: [
                  // Price column
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Starting from',
                          style: AppTextStyles.labelSmall),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '₹',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(
                              text: widget.package.price
                                  .toStringAsFixed(0)
                                  .replaceAllMapped(
                                    RegExp(
                                        r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                    (m) => '${m[1]},',
                                  ),
                              style:
                                  AppTextStyles.headlineMedium.copyWith(
                                color: AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 16),

                  // Join button
                  Expanded(
                    child: AppButton(
                      label: 'Join Package',
                      onPressed: () =>
                          _showJoinSheet(context, widget.package),
                      icon: Icons.rocket_launch_outlined,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showJoinSheet(BuildContext context, MockPackage package) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _JoinBottomSheet(package: package),
    );
  }
}

// ── Join Bottom Sheet ─────────────────────────────────────────────────────────

class _JoinBottomSheet extends StatefulWidget {
  final MockPackage package;

  const _JoinBottomSheet({required this.package});

  @override
  State<_JoinBottomSheet> createState() => _JoinBottomSheetState();
}

class _JoinBottomSheetState extends State<_JoinBottomSheet> {
  int _travelers = 1;

  @override
  Widget build(BuildContext context) {
    final total = widget.package.price * _travelers;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          Text('Book Your Spot', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 4),
          Text(widget.package.title, style: AppTextStyles.bodySmall),
          const SizedBox(height: 24),

          // Travelers counter
          Row(
            children: [
              Text('Number of Travelers',
                  style: AppTextStyles.titleMedium),
              const Spacer(),
              _CounterButton(
                icon: Icons.remove,
                onTap: () {
                  if (_travelers > 1) setState(() => _travelers--);
                },
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, anim) => ScaleTransition(
                    scale: anim,
                    child: child,
                  ),
                  child: Text(
                    '$_travelers',
                    key: ValueKey(_travelers),
                    style: AppTextStyles.headlineSmall,
                  ),
                ),
              ),
              _CounterButton(
                icon: Icons.add,
                onTap: () => setState(() => _travelers++),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Total amount
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Text('Total Amount',
                    style: AppTextStyles.titleMedium),
                const Spacer(),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    '₹${total.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                    key: ValueKey(total),
                    style: AppTextStyles.headlineMedium
                        .copyWith(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          AppButton(
            label: 'Confirm Booking',
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Booking confirmed for $_travelers traveler${_travelers > 1 ? 's' : ''}!',
                  ),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _CounterButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CounterButton({required this.icon, required this.onTap});

  @override
  State<_CounterButton> createState() => _CounterButtonState();
}

class _CounterButtonState extends State<_CounterButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(widget.icon, size: 18, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
