import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/mock_data.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../../../shared/widgets/app_button.dart';

// ── Mock post images for the grid ─────────────────────────────────────────────
const _mockPostImages = [
  'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
  'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=400',
  'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?w=400',
  'https://images.unsplash.com/photo-1524492412937-b28074a5d7da?w=400',
  'https://images.unsplash.com/photo-1589308078059-be1415eab4c3?w=400',
  'https://images.unsplash.com/photo-1599661046289-e31897846e41?w=400',
  'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=400',
  'https://images.unsplash.com/photo-1530103862676-de8c9debad1d?w=400',
  'https://images.unsplash.com/photo-1501854140801-50d01698950b?w=400',
];

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = MockData.currentUser;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 0,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            title: Text(
              user.username,
              style: AppTextStyles.titleMedium,
            ),
            actions: [
              IconButton(
                onPressed: () => context.push('/notifications'),
                icon: const Icon(Icons.notifications_outlined),
                color: AppColors.textPrimary,
              ),
              IconButton(
                onPressed: () => context.push('/profile/edit'),
                icon: const Icon(Icons.edit_outlined),
                color: AppColors.textPrimary,
              ),
              const SizedBox(width: 4),
            ],
          ),

          // Profile header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar + stats row
                  _ProfileHeaderRow(user: user),
                  const SizedBox(height: 14),

                  // Name + bio + location
                  _ProfileInfo(user: user),
                  const SizedBox(height: 16),

                  // Action buttons row
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: 'Edit Profile',
                          onPressed: () => context.push('/profile/edit'),
                          height: 38,
                          isOutlined: true,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AppButton(
                          label: 'My Trips',
                          onPressed: () => context.push('/trips'),
                          height: 38,
                          icon: Icons.luggage_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),

          // Tab bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              TabBar(
                controller: _tabCtrl,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                indicatorSize: TabBarIndicatorSize.label,
                labelStyle: AppTextStyles.labelLarge
                    .copyWith(fontWeight: FontWeight.w600),
                unselectedLabelStyle: AppTextStyles.labelLarge,
                tabs: const [
                  Tab(text: 'Posts'),
                  Tab(text: 'About'),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            _PostsGrid(),
            _AboutTab(user: user),
          ],
        ),
      ),
    );
  }
}

// ── Profile Header Row ────────────────────────────────────────────────────────

class _ProfileHeaderRow extends StatefulWidget {
  final MockUser user;
  const _ProfileHeaderRow({required this.user});

  @override
  State<_ProfileHeaderRow> createState() => _ProfileHeaderRowState();
}

class _ProfileHeaderRowState extends State<_ProfileHeaderRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Row(
          children: [
            // Avatar with story-ring glow
            _StoryRingAvatar(
              imageUrl: widget.user.avatarUrl,
              name: widget.user.fullName,
            ),
            const SizedBox(width: 24),

            // Stats
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatColumn(
                    count: _mockPostImages.length.toString(),
                    label: 'Posts',
                  ),
                  _StatColumn(
                    count: widget.user.followersCount > 0
                        ? widget.user.followersCount.toString()
                        : '0',
                    label: 'Followers',
                  ),
                  _StatColumn(
                    count: widget.user.connectionsCount > 0
                        ? widget.user.connectionsCount.toString()
                        : '0',
                    label: 'Connections',
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

class _StoryRingAvatar extends StatefulWidget {
  final String imageUrl;
  final String name;
  const _StoryRingAvatar({required this.imageUrl, required this.name});

  @override
  State<_StoryRingAvatar> createState() => _StoryRingAvatarState();
}

class _StoryRingAvatarState extends State<_StoryRingAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) => Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: SweepGradient(
            colors: [
              AppColors.primary.withAlpha((255 * _pulse.value).round()),
              AppColors.accent.withAlpha((255 * _pulse.value).round()),
              AppColors.primary.withAlpha((255 * _pulse.value).round()),
            ],
          ),
        ),
        padding: const EdgeInsets.all(3),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.background,
          ),
          padding: const EdgeInsets.all(2),
          child: child,
        ),
      ),
      child: UserAvatar(
        imageUrl: widget.imageUrl,
        name: widget.name,
        size: 72,
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String count;
  final String label;

  const _StatColumn({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(count, style: AppTextStyles.headlineMedium),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }
}

// ── Profile Info ──────────────────────────────────────────────────────────────

class _ProfileInfo extends StatefulWidget {
  final MockUser user;
  const _ProfileInfo({required this.user});

  @override
  State<_ProfileInfo> createState() => _ProfileInfoState();
}

class _ProfileInfoState extends State<_ProfileInfo>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.user.fullName, style: AppTextStyles.headlineSmall),
          if (widget.user.bio != null) ...[
            const SizedBox(height: 4),
            Text(widget.user.bio!, style: AppTextStyles.bodySmall),
          ],
          if (widget.user.location != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(widget.user.location!, style: AppTextStyles.bodySmall),
              ],
            ),
          ],
          const SizedBox(height: 8),
          // Travel style badge
          if (widget.user.travelStyle != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withAlpha(80)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.explore_rounded,
                      size: 13, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.user.travelStyle} Traveler',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
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

// ── Posts Grid ────────────────────────────────────────────────────────────────

class _PostsGrid extends StatefulWidget {
  @override
  State<_PostsGrid> createState() => _PostsGridState();
}

class _PostsGridState extends State<_PostsGrid> {
  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    if (_mockPostImages.isEmpty) {
      return _EmptyPostsView();
    }

    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: _mockPostImages.length,
      itemBuilder: (context, index) {
        return _PostGridTile(
          url: _mockPostImages[index],
          index: index,
          isExpanded: _expandedIndex == index,
          onTap: () => setState(() {
            _expandedIndex = _expandedIndex == index ? null : index;
          }),
        );
      },
    );
  }
}

class _PostGridTile extends StatefulWidget {
  final String url;
  final int index;
  final bool isExpanded;
  final VoidCallback onTap;

  const _PostGridTile({
    required this.url,
    required this.index,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  State<_PostGridTile> createState() => _PostGridTileState();
}

class _PostGridTileState extends State<_PostGridTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _enterCtrl;
  late Animation<double> _enterFade;
  late Animation<double> _enterScale;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _enterFade = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);
    _enterScale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut),
    );

    Future.delayed(Duration(milliseconds: 30 * widget.index), () {
      if (mounted) _enterCtrl.forward();
    });
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _enterFade,
      child: ScaleTransition(
        scale: _enterScale,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                widget.url,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(color: AppColors.shimmerBase);
                },
              ),

              // Hover overlay with like/comment counts
              AnimatedOpacity(
                opacity: widget.isExpanded ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  color: Colors.black.withAlpha(120),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.favorite_rounded,
                              color: Colors.white, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '${(widget.index + 1) * 12}',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.chat_bubble_rounded,
                              color: Colors.white, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '${(widget.index + 1) * 3}',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
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

class _EmptyPostsView extends StatefulWidget {
  @override
  State<_EmptyPostsView> createState() => _EmptyPostsViewState();
}

class _EmptyPostsViewState extends State<_EmptyPostsView>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _float;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _float = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _float,
            builder: (context, child) => Transform.translate(
              offset: Offset(0, _float.value),
              child: child,
            ),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.grid_on_outlined,
                  size: 36, color: AppColors.textHint),
            ),
          ),
          const SizedBox(height: 16),
          Text('No posts yet', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Share your travel moments\nand connect with explorers',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 160,
            child: AppButton(
              label: 'Create First Post',
              onPressed: () {},
              height: 44,
            ),
          ),
        ],
      ),
    );
  }
}

// ── About Tab ─────────────────────────────────────────────────────────────────

class _AboutTab extends StatelessWidget {
  final MockUser user;

  const _AboutTab({required this.user});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _AboutSection(
          icon: Icons.language_rounded,
          title: 'Languages',
          children: user.languages
              .map<Widget>((l) => _Chip(label: l))
              .toList(),
        ),
        const SizedBox(height: 20),
        _AboutSection(
          icon: Icons.hiking_rounded,
          title: 'Travel Style',
          children: user.travelStyle != null
              ? [_Chip(label: user.travelStyle!, isActive: true)]
              : [],
        ),
        const SizedBox(height: 20),
        _AboutSection(
          icon: Icons.interests_rounded,
          title: 'Interests',
          children: user.interests
              .map<Widget>((i) => _Chip(label: i))
              .toList(),
        ),
      ],
    );
  }
}

class _AboutSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _AboutSection({
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(title, style: AppTextStyles.titleMedium),
          ],
        ),
        const SizedBox(height: 10),
        if (children.isEmpty)
          Text('Not set', style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textHint,
          ))
        else
          Wrap(spacing: 8, runSpacing: 8, children: children),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool isActive;

  const _Chip({required this.label, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? AppColors.primary : AppColors.border,
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelMedium.copyWith(
          color: isActive ? AppColors.textOnPrimary : AppColors.textPrimary,
        ),
      ),
    );
  }
}

// ── Tab Bar Delegate ──────────────────────────────────────────────────────────

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.background,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}
