import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/mock_data.dart';
import '../../../shared/widgets/package_card.dart';
import '../../../shared/widgets/user_avatar.dart';

// ── Mock feed posts ───────────────────────────────────────────────────────────

class _FeedPost {
  final String id;
  final MockUser author;
  final String imageUrl;
  final String caption;
  final String location;
  final int likeCount;
  final int commentCount;
  final String timeAgo;
  bool isLiked;
  bool isSaved;

  _FeedPost({
    required this.id,
    required this.author,
    required this.imageUrl,
    required this.caption,
    required this.location,
    required this.likeCount,
    required this.commentCount,
    required this.timeAgo,
  }) : isLiked = false, isSaved = false;
}

final _feedPosts = [
  _FeedPost(
    id: 'f1',
    author: MockData.suggestedUsers[0],
    imageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
    caption: 'The mountains are calling and I must go 🏔️ Absolutely breathtaking views at sunrise from Rohtang Pass. Worth every step of the trek!',
    location: 'Rohtang Pass, Himachal Pradesh',
    likeCount: 248,
    commentCount: 32,
    timeAgo: '2h ago',
  ),
  _FeedPost(
    id: 'f2',
    author: MockData.suggestedUsers[1],
    imageUrl: 'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?w=800',
    caption: 'Golden hour at Kovalam beach never disappoints 🌅 The coconut trees, the waves, pure Kerala magic.',
    location: 'Kovalam, Kerala',
    likeCount: 192,
    commentCount: 18,
    timeAgo: '5h ago',
  ),
  _FeedPost(
    id: 'f3',
    author: MockData.suggestedUsers[2],
    imageUrl: 'https://images.unsplash.com/photo-1524492412937-b28074a5d7da?w=800',
    caption: 'Colors of Rajasthan 🎨 Jaipur\'s streets are pure art. The culture, the food, the architecture — all 10/10.',
    location: 'Jaipur, Rajasthan',
    likeCount: 315,
    commentCount: 44,
    timeAgo: '1d ago',
  ),
  _FeedPost(
    id: 'f4',
    author: MockData.suggestedUsers[0],
    imageUrl: 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800',
    caption: 'Underwater paradise in Andaman 🐠 Never knew I\'d fall in love with scuba diving this much!',
    location: 'Havelock Island, Andaman',
    likeCount: 421,
    commentCount: 56,
    timeAgo: '2d ago',
  ),
];

// ── Banner data ───────────────────────────────────────────────────────────────

const _banners = [
  {
    'title': 'Discover Ladakh',
    'subtitle': 'Epic landscapes await',
    'image': 'https://images.unsplash.com/photo-1589308078059-be1415eab4c3?w=800',
    'tag': 'Limited Spots',
  },
  {
    'title': 'Kerala Backwaters',
    'subtitle': 'Serenity on water',
    'image': 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=800',
    'tag': 'Best Seller',
  },
  {
    'title': 'Rajasthan Royal',
    'subtitle': 'Heritage & culture',
    'image': 'https://images.unsplash.com/photo-1524492412937-b28074a5d7da?w=800',
    'tag': 'Top Rated',
  },
];

// ── HomeScreen ────────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _activeTab = 0;
  final List<String> _tabs = ['Feed', 'Packages', 'Camps', 'Events'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──────────────────────────────────────────────────────
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: AppColors.background,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            titleSpacing: 20,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'UNZOLO',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.textOnPrimary,
                      letterSpacing: 2,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () => context.push('/notifications'),
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.notifications_outlined),
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                color: AppColors.textPrimary,
              ),
              const SizedBox(width: 4),
            ],
          ),

          // ── Tab pills ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _TabPills(
              tabs: _tabs,
              selected: _activeTab,
              onSelect: (i) => setState(() => _activeTab = i),
            ),
          ),

          // ── Feed tab ─────────────────────────────────────────────────────
          if (_activeTab == 0) ...[
            // Hero banner carousel
            SliverToBoxAdapter(child: _HeroBanner()),

            // Buddy suggestions
            SliverToBoxAdapter(
              child: _BuddyRow(),
            ),

            // Feed section label
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Text('Recent Posts',
                    style: AppTextStyles.headlineSmall),
              ),
            ),

            // Feed posts
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _FeedPostCard(
                  key: ValueKey(_feedPosts[index].id),
                  post: _feedPosts[index],
                  index: index,
                  onLikeToggle: () =>
                      setState(() {
                        _feedPosts[index].isLiked =
                            !_feedPosts[index].isLiked;
                      }),
                  onSaveToggle: () =>
                      setState(() {
                        _feedPosts[index].isSaved =
                            !_feedPosts[index].isSaved;
                      }),
                ),
                childCount: _feedPosts.length,
              ),
            ),
          ],

          // ── Packages/Camps/Events tabs ───────────────────────────────────
          if (_activeTab != 0) ...[
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final package = MockData.packages[index];
                  return PackageCard(
                    package: package,
                    index: index,
                    onTap: () => context.push('/package/${package.id}'),
                  );
                },
                childCount: MockData.packages.length,
              ),
            ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

// ── Tab Pills ─────────────────────────────────────────────────────────────────

class _TabPills extends StatelessWidget {
  final List<String> tabs;
  final int selected;
  final ValueChanged<int> onSelect;

  const _TabPills({
    required this.tabs,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
        itemCount: tabs.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = selected == index;
          return GestureDetector(
            onTap: () => onSelect(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                tabs[index],
                style: AppTextStyles.labelMedium.copyWith(
                  color: isSelected
                      ? AppColors.textOnPrimary
                      : AppColors.textSecondary,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Hero Banner ───────────────────────────────────────────────────────────────

class _HeroBanner extends StatefulWidget {
  @override
  State<_HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<_HeroBanner> {
  final _pageCtrl = PageController(viewportFraction: 0.92);
  int _current = 0;

  @override
  void initState() {
    super.initState();
    // Auto-scroll every 4 seconds
    Future.delayed(const Duration(seconds: 4), _autoScroll);
  }

  void _autoScroll() {
    if (!mounted) return;
    final next = (_current + 1) % _banners.length;
    _pageCtrl.animateToPage(
      next,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    Future.delayed(const Duration(seconds: 4), _autoScroll);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageCtrl,
            itemCount: _banners.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (context, index) {
              final banner = _banners[index];
              return _BannerCard(banner: banner);
            },
          ),
        ),
        const SizedBox(height: 10),
        // Dot indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (i) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _current == i ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _current == i
                    ? AppColors.primary
                    : AppColors.border,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  final Map<String, String> banner;

  const _BannerCard({required this.banner});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              banner['image']!,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(color: AppColors.shimmerBase);
              },
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withAlpha(180),
                  ],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),
            // Tag badge
            Positioned(
              top: 14,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  banner['tag']!,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            // Text
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    banner['title']!,
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    banner['subtitle']!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Buddy Row ─────────────────────────────────────────────────────────────────

class _BuddyRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Travel Buddies Nearby',
                  style: AppTextStyles.headlineSmall),
              TextButton(
                onPressed: () {},
                child: Text(
                  'See all',
                  style: AppTextStyles.labelMedium
                      .copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: MockData.suggestedUsers.length,
            separatorBuilder: (context, index) =>
                const SizedBox(width: 12),
            itemBuilder: (context, index) => _BuddyCard(
              user: MockData.suggestedUsers[index],
              index: index,
            ),
          ),
        ),
      ],
    );
  }
}

class _BuddyCard extends StatefulWidget {
  final MockUser user;
  final int index;

  const _BuddyCard({required this.user, required this.index});

  @override
  State<_BuddyCard> createState() => _BuddyCardState();
}

class _BuddyCardState extends State<_BuddyCard>
    with SingleTickerProviderStateMixin {
  bool _connected = false;
  late AnimationController _enterCtrl;
  late Animation<double> _enterAnim;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _enterAnim = CurvedAnimation(
        parent: _enterCtrl, curve: Curves.easeOut);
    Future.delayed(
        Duration(milliseconds: 80 * widget.index),
        () { if (mounted) _enterCtrl.forward(); });
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _enterAnim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.3, 0),
          end: Offset.zero,
        ).animate(_enterAnim),
        child: Container(
          width: 110,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              UserAvatar(
                imageUrl: widget.user.avatarUrl,
                name: widget.user.fullName,
                size: 48,
              ),
              const SizedBox(height: 8),
              Text(
                widget.user.fullName.split(' ').first,
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                widget.user.location ?? '',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textHint,
                  fontSize: 10,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => setState(() => _connected = !_connected),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 26,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: _connected
                        ? AppColors.primarySurface
                        : AppColors.primary,
                    borderRadius: BorderRadius.circular(13),
                    border: _connected
                        ? Border.all(color: AppColors.primary)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      _connected ? 'Connected' : 'Connect',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: _connected
                            ? AppColors.primary
                            : Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
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

// ── Feed Post Card ────────────────────────────────────────────────────────────

class _FeedPostCard extends StatefulWidget {
  final _FeedPost post;
  final int index;
  final VoidCallback onLikeToggle;
  final VoidCallback onSaveToggle;

  const _FeedPostCard({
    super.key,
    required this.post,
    required this.index,
    required this.onLikeToggle,
    required this.onSaveToggle,
  });

  @override
  State<_FeedPostCard> createState() => _FeedPostCardState();
}

class _FeedPostCardState extends State<_FeedPostCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _enterCtrl;
  late Animation<double> _enterFade;
  late Animation<Offset> _enterSlide;

  // Like burst animation
  late AnimationController _likeCtrl;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _enterFade =
        CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);
    _enterSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _enterCtrl, curve: Curves.easeOut));

    _likeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    Future.delayed(
        Duration(milliseconds: 100 * widget.index),
        () { if (mounted) _enterCtrl.forward(); });
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    _likeCtrl.dispose();
    super.dispose();
  }

  void _handleLike() {
    widget.onLikeToggle();
    if (!widget.post.isLiked) {
      // was not liked, now will be liked → burst
      _likeCtrl.forward().then((_) => _likeCtrl.reverse());
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _enterFade,
      child: SlideTransition(
        position: _enterSlide,
        child: Container(
          margin: const EdgeInsets.fromLTRB(0, 0, 0, 2),
          color: AppColors.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Author header ────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 12, 10),
                child: Row(
                  children: [
                    UserAvatar(
                      imageUrl: widget.post.author.avatarUrl,
                      name: widget.post.author.fullName,
                      size: 40,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.post.author.fullName,
                            style: AppTextStyles.labelLarge.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined,
                                  size: 11,
                                  color: AppColors.textHint),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  widget.post.location,
                                  style: AppTextStyles.labelSmall
                                      .copyWith(
                                          color: AppColors.textHint),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Text(
                      widget.post.timeAgo,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textHint,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.more_horiz_rounded,
                        color: AppColors.textHint, size: 20),
                  ],
                ),
              ),

              // ── Image with double-tap to like ────────────────────────
              GestureDetector(
                onDoubleTap: () {
                  if (!widget.post.isLiked) _handleLike();
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: 1.0,
                      child: Image.network(
                        widget.post.imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: AppColors.shimmerBase,
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Double-tap heart burst
                    AnimatedBuilder(
                      animation: _likeCtrl,
                      builder: (context, child) {
                        final v = _likeCtrl.value;
                        return Opacity(
                          opacity: v > 0.5 ? (1 - v) * 2 : v * 2,
                          child: Transform.scale(
                            scale: 0.5 + v * 1.5,
                            child: child,
                          ),
                        );
                      },
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: Colors.white,
                        size: 80,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Actions row ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                child: Row(
                  children: [
                    _ActionBtn(
                      icon: widget.post.isLiked
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: widget.post.isLiked
                          ? Colors.red.shade500
                          : AppColors.textSecondary,
                      count: widget.post.likeCount +
                          (widget.post.isLiked ? 1 : 0),
                      onTap: _handleLike,
                    ),
                    const SizedBox(width: 16),
                    _ActionBtn(
                      icon: Icons.chat_bubble_outline_rounded,
                      color: AppColors.textSecondary,
                      count: widget.post.commentCount,
                      onTap: () {},
                    ),
                    const SizedBox(width: 16),
                    _ActionBtn(
                      icon: Icons.send_outlined,
                      color: AppColors.textSecondary,
                      onTap: () {},
                    ),
                    const Spacer(),
                    _ActionBtn(
                      icon: widget.post.isSaved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color: widget.post.isSaved
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      onTap: widget.onSaveToggle,
                    ),
                  ],
                ),
              ),

              // ── Caption ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 14),
                child: _ExpandableCaption(
                  author: widget.post.author.fullName,
                  caption: widget.post.caption,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Action Button ─────────────────────────────────────────────────────────────

class _ActionBtn extends StatefulWidget {
  final IconData icon;
  final Color color;
  final int? count;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.color,
    this.count,
    required this.onTap,
  });

  @override
  State<_ActionBtn> createState() => _ActionBtnState();
}

class _ActionBtnState extends State<_ActionBtn>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.85,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressCtrl.reverse(),
      onTapUp: (_) {
        _pressCtrl.forward();
        widget.onTap();
      },
      onTapCancel: () => _pressCtrl.forward(),
      child: ScaleTransition(
        scale: _pressCtrl,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, size: 24, color: widget.color),
            if (widget.count != null) ...[
              const SizedBox(width: 4),
              Text(
                '${widget.count}',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Expandable Caption ────────────────────────────────────────────────────────

class _ExpandableCaption extends StatefulWidget {
  final String author;
  final String caption;

  const _ExpandableCaption({
    required this.author,
    required this.caption,
  });

  @override
  State<_ExpandableCaption> createState() => _ExpandableCaptionState();
}

class _ExpandableCaptionState extends State<_ExpandableCaption> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.topLeft,
        child: RichText(
          maxLines: _expanded ? null : 2,
          overflow:
              _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          text: TextSpan(
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
              height: 1.5,
            ),
            children: [
              TextSpan(
                text: widget.author,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const TextSpan(text: '  '),
              TextSpan(text: widget.caption),
              if (!_expanded)
                TextSpan(
                  text: ' more',
                  style: TextStyle(color: AppColors.textHint),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
