import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/mock_data.dart';
import '../../../shared/widgets/user_avatar.dart';

// ── Mock destination data ─────────────────────────────────────────────────────

class _Destination {
  final String name;
  final String country;
  final String image;
  final String tag;
  final double rating;
  final int tripCount;

  const _Destination({
    required this.name,
    required this.country,
    required this.image,
    required this.tag,
    required this.rating,
    required this.tripCount,
  });
}

const _destinations = [
  _Destination(
    name: 'Ladakh',
    country: 'India',
    image: 'https://images.unsplash.com/photo-1589308078059-be1415eab4c3?w=600',
    tag: 'Adventure',
    rating: 4.9,
    tripCount: 128,
  ),
  _Destination(
    name: 'Munnar',
    country: 'Kerala',
    image: 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=600',
    tag: 'Nature',
    rating: 4.7,
    tripCount: 94,
  ),
  _Destination(
    name: 'Jaipur',
    country: 'Rajasthan',
    image: 'https://images.unsplash.com/photo-1524492412937-b28074a5d7da?w=600',
    tag: 'Culture',
    rating: 4.8,
    tripCount: 211,
  ),
  _Destination(
    name: 'Goa Beaches',
    country: 'Goa',
    image: 'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?w=600',
    tag: 'Beach',
    rating: 4.6,
    tripCount: 342,
  ),
  _Destination(
    name: 'Andaman',
    country: 'Andaman Islands',
    image: 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=600',
    tag: 'Island',
    rating: 4.8,
    tripCount: 87,
  ),
  _Destination(
    name: 'Coorg',
    country: 'Karnataka',
    image: 'https://images.unsplash.com/photo-1501854140801-50d01698950b?w=600',
    tag: 'Nature',
    rating: 4.5,
    tripCount: 156,
  ),
];

const _destCategories = [
  'All',
  'Adventure',
  'Nature',
  'Culture',
  'Beach',
  'Island',
];

// ── ExploreScreen ─────────────────────────────────────────────────────────────

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  bool _searchActive = false;
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _searchCtrl.addListener(() => setState(() => _query = _searchCtrl.text));
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _openSearch() {
    setState(() => _searchActive = true);
    Future.delayed(const Duration(milliseconds: 80), () {
      _searchFocus.requestFocus();
    });
  }

  void _closeSearch() {
    _searchFocus.unfocus();
    _searchCtrl.clear();
    setState(() {
      _searchActive = false;
      _query = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: _searchActive
                    ? _SearchBar(
                        key: const ValueKey('search'),
                        controller: _searchCtrl,
                        focusNode: _searchFocus,
                        onClose: _closeSearch,
                      )
                    : _ExploreHeader(
                        key: const ValueKey('header'),
                        onSearchTap: _openSearch,
                      ),
              ),
            ),

            // ── Search results overlay ───────────────────────────────────
            if (_searchActive && _query.isNotEmpty)
              Expanded(child: _SearchResults(query: _query))
            else ...[
              // ── Tab bar ──────────────────────────────────────────────
              const SizedBox(height: 16),
              _ExploreTabBar(controller: _tabCtrl),

              // ── Tab body ─────────────────────────────────────────────
              Expanded(
                child: TabBarView(
                  controller: _tabCtrl,
                  children: const [
                    _DestinationsTab(),
                    _PeopleTab(),
                    _PackagesTab(),
                  ],
                ),
              ),
            ],

            if (_searchActive && _query.isEmpty)
              Expanded(child: _SearchSuggestions()),
          ],
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _ExploreHeader extends StatelessWidget {
  final VoidCallback onSearchTap;

  const _ExploreHeader({super.key, required this.onSearchTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Explore', style: AppTextStyles.headlineLarge),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onSearchTap,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                const Icon(Icons.search, color: AppColors.textHint, size: 20),
                const SizedBox(width: 10),
                Text(
                  'Where to next?',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textHint),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Search Bar ────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onClose;

  const _SearchBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary, width: 1.5),
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                const Icon(Icons.search,
                    color: AppColors.primary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    style: AppTextStyles.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'Search destinations, people...',
                      hintStyle: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textHint),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (controller.text.isNotEmpty)
                  GestureDetector(
                    onTap: controller.clear,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(Icons.close_rounded,
                          color: AppColors.textHint, size: 18),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: onClose,
          child: Text(
            'Cancel',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Tab Bar ───────────────────────────────────────────────────────────────────

class _ExploreTabBar extends StatelessWidget {
  final TabController controller;

  const _ExploreTabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(9),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTextStyles.labelMedium
            .copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: AppTextStyles.labelMedium,
        tabs: const [
          Tab(text: 'Destinations'),
          Tab(text: 'People'),
          Tab(text: 'Packages'),
        ],
      ),
    );
  }
}

// ── Destinations Tab ──────────────────────────────────────────────────────────

class _DestinationsTab extends StatefulWidget {
  const _DestinationsTab();

  @override
  State<_DestinationsTab> createState() => _DestinationsTabState();
}

class _DestinationsTabState extends State<_DestinationsTab> {
  String _activeCategory = 'All';

  List<_Destination> get _filtered => _activeCategory == 'All'
      ? _destinations
      : _destinations
          .where((d) => d.tag == _activeCategory)
          .toList();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Category chips
        SliverToBoxAdapter(
          child: _CategoryChips(
            categories: _destCategories,
            active: _activeCategory,
            onSelect: (c) => setState(() => _activeCategory = c),
          ),
        ),

        // Trending label
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                const Icon(Icons.local_fire_department_rounded,
                    color: AppColors.accent, size: 18),
                const SizedBox(width: 6),
                Text('Trending Destinations',
                    style: AppTextStyles.headlineSmall),
              ],
            ),
          ),
        ),

        // Destinations grid
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index >= _filtered.length) return null;
                return _DestinationCard(
                  dest: _filtered[index],
                  index: index,
                );
              },
              childCount: _filtered.length,
            ),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
          ),
        ),

        // Trending vibes section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Text('Trending Vibes',
                style: AppTextStyles.headlineSmall),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: MockData.trendingVibes.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(width: 10),
              itemBuilder: (context, index) {
                return _VibeChip(
                  label: MockData.trendingVibes[index],
                  index: index,
                );
              },
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

class _CategoryChips extends StatelessWidget {
  final List<String> categories;
  final String active;
  final ValueChanged<String> onSelect;

  const _CategoryChips({
    required this.categories,
    required this.active,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isActive = cat == active;
          return GestureDetector(
            onTap: () => onSelect(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive
                      ? AppColors.primary
                      : AppColors.border,
                ),
              ),
              child: Text(
                cat,
                style: AppTextStyles.labelMedium.copyWith(
                  color: isActive
                      ? Colors.white
                      : AppColors.textSecondary,
                  fontWeight: isActive
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DestinationCard extends StatefulWidget {
  final _Destination dest;
  final int index;

  const _DestinationCard({required this.dest, required this.index});

  @override
  State<_DestinationCard> createState() => _DestinationCardState();
}

class _DestinationCardState extends State<_DestinationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _enterCtrl;
  late Animation<double> _fade;
  late Animation<double> _scale;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fade = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut),
    );
    Future.delayed(Duration(milliseconds: 60 * widget.index), () {
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
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: widget.dest.image,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(color: AppColors.shimmerBase),
              ),
              // Gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withAlpha(200),
                    ],
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),
              // Tag
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.dest.tag,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
              // Save
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => setState(() => _saved = !_saved),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: _saved
                          ? AppColors.primary
                          : Colors.black.withAlpha(80),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _saved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
              // Info
              Positioned(
                left: 10,
                right: 10,
                bottom: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.dest.name,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded,
                            color: Colors.white70, size: 11),
                        const SizedBox(width: 2),
                        Text(
                          widget.dest.country,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.star_rounded,
                            color: Color(0xFFFFD700), size: 12),
                        const SizedBox(width: 2),
                        Text(
                          widget.dest.rating.toString(),
                          style: AppTextStyles.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.dest.tripCount} trips',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white60,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VibeChip extends StatefulWidget {
  final String label;
  final int index;

  const _VibeChip({required this.label, required this.index});

  @override
  State<_VibeChip> createState() => _VibeChipState();
}

class _VibeChipState extends State<_VibeChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  bool _selected = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 0,
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    Future.delayed(Duration(milliseconds: 60 * widget.index), () {
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
      opacity: _anim,
      child: GestureDetector(
        onTap: () => setState(() => _selected = !_selected),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: _selected ? AppColors.primary : AppColors.primarySurface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: _selected
                  ? AppColors.primary
                  : AppColors.primary.withAlpha(80),
            ),
          ),
          child: Text(
            widget.label,
            style: AppTextStyles.labelMedium.copyWith(
              color: _selected ? Colors.white : AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

// ── People Tab ────────────────────────────────────────────────────────────────

class _PeopleTab extends StatefulWidget {
  const _PeopleTab();

  @override
  State<_PeopleTab> createState() => _PeopleTabState();
}

class _PeopleTabState extends State<_PeopleTab> {
  String _activeFilter = 'All';
  final List<String> _filters = [
    'All',
    'Solo',
    'Group',
    'Couple',
    'Adventure',
  ];

  List<MockUser> get _filtered {
    if (_activeFilter == 'All') return MockData.suggestedUsers;
    return MockData.suggestedUsers.where((u) {
      if (['Solo', 'Group', 'Couple'].contains(_activeFilter)) {
        return u.travelStyle == _activeFilter;
      }
      return u.interests.contains(_activeFilter);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Filter row
        SliverToBoxAdapter(
          child: _CategoryChips(
            categories: _filters,
            active: _activeFilter,
            onSelect: (f) => setState(() => _activeFilter = f),
          ),
        ),

        // Section label
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                const Icon(Icons.people_rounded,
                    color: AppColors.primary, size: 18),
                const SizedBox(width: 6),
                Text('Explorers Like You',
                    style: AppTextStyles.headlineSmall),
              ],
            ),
          ),
        ),

        // People grid
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: _filtered.isEmpty
              ? SliverToBoxAdapter(child: _EmptyFilter())
              : SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _PersonCard(
                      user: _filtered[index],
                      index: index,
                    ),
                    childCount: _filtered.length,
                  ),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

class _PersonCard extends StatefulWidget {
  final MockUser user;
  final int index;

  const _PersonCard({required this.user, required this.index});

  @override
  State<_PersonCard> createState() => _PersonCardState();
}

class _PersonCardState extends State<_PersonCard>
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
    _enterAnim =
        CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);
    Future.delayed(Duration(milliseconds: 70 * widget.index), () {
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
      opacity: _enterAnim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(_enterAnim),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar
              UserAvatar(
                imageUrl: widget.user.avatarUrl,
                name: widget.user.fullName,
                size: 60,
              ),
              const SizedBox(height: 10),

              // Name
              Text(
                widget.user.fullName,
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              // Location
              if (widget.user.location != null) ...[
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 11, color: AppColors.textHint),
                    const SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        widget.user.location!,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textHint,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              // Travel style badge
              if (widget.user.travelStyle != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    widget.user.travelStyle!,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],

              // Shared interests
              const SizedBox(height: 8),
              _SharedInterests(interests: widget.user.interests),

              const SizedBox(height: 8),

              // Connect button
              GestureDetector(
                onTap: () => setState(() => _connected = !_connected),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _connected
                        ? AppColors.primarySurface
                        : AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                    border: _connected
                        ? Border.all(color: AppColors.primary)
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _connected
                            ? Icons.check_rounded
                            : Icons.person_add_alt_1_rounded,
                        size: 14,
                        color: _connected
                            ? AppColors.primary
                            : Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _connected ? 'Connected' : 'Connect',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: _connected
                              ? AppColors.primary
                              : Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
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

class _SharedInterests extends StatelessWidget {
  final List<String> interests;

  const _SharedInterests({required this.interests});

  @override
  Widget build(BuildContext context) {
    final show = interests.take(2).toList();
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      alignment: WrapAlignment.center,
      children: show.map((i) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            i,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 9,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _EmptyFilter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded,
              size: 48, color: AppColors.textHint),
          const SizedBox(height: 12),
          Text('No explorers found',
              style: AppTextStyles.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Try a different filter',
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}

// ── Packages Tab ──────────────────────────────────────────────────────────────

class _PackagesTab extends StatelessWidget {
  const _PackagesTab();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: MockData.popularEscapes.length,
      itemBuilder: (context, index) {
        final escape = MockData.popularEscapes[index];
        return _EscapeCard(escape: escape, index: index);
      },
    );
  }
}

class _EscapeCard extends StatefulWidget {
  final Map<String, String> escape;
  final int index;

  const _EscapeCard({required this.escape, required this.index});

  @override
  State<_EscapeCard> createState() => _EscapeCardState();
}

class _EscapeCardState extends State<_EscapeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    Future.delayed(Duration(milliseconds: 60 * widget.index), () {
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
      child: ScaleTransition(
        scale: _scale,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: widget.escape['image']!,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(color: AppColors.shimmerBase),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withAlpha(180),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Text(
                  widget.escape['name']!,
                  style: AppTextStyles.titleLarge
                      .copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Search Results ────────────────────────────────────────────────────────────

class _SearchResults extends StatelessWidget {
  final String query;

  const _SearchResults({required this.query});

  @override
  Widget build(BuildContext context) {
    final q = query.toLowerCase();

    final matchedDests = _destinations
        .where((d) =>
            d.name.toLowerCase().contains(q) ||
            d.country.toLowerCase().contains(q) ||
            d.tag.toLowerCase().contains(q))
        .toList();

    final matchedPeople = MockData.suggestedUsers
        .where((u) =>
            u.fullName.toLowerCase().contains(q) ||
            u.username.toLowerCase().contains(q) ||
            (u.location?.toLowerCase().contains(q) ?? false) ||
            u.interests.any((i) => i.toLowerCase().contains(q)))
        .toList();

    if (matchedDests.isEmpty && matchedPeople.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded,
                size: 56, color: AppColors.textHint),
            const SizedBox(height: 16),
            Text('No results for "$query"',
                style: AppTextStyles.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Try searching for a destination or person',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textHint),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      children: [
        if (matchedDests.isNotEmpty) ...[
          _SearchSectionLabel(
              icon: Icons.explore_rounded, label: 'Destinations'),
          const SizedBox(height: 10),
          ...matchedDests.map(
            (d) => _SearchDestRow(dest: d),
          ),
          const SizedBox(height: 20),
        ],
        if (matchedPeople.isNotEmpty) ...[
          _SearchSectionLabel(
              icon: Icons.people_rounded, label: 'People'),
          const SizedBox(height: 10),
          ...matchedPeople.map(
            (u) => _SearchPersonRow(user: u),
          ),
        ],
      ],
    );
  }
}

class _SearchSectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SearchSectionLabel(
      {required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(label,
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            )),
      ],
    );
  }
}

class _SearchDestRow extends StatelessWidget {
  final _Destination dest;

  const _SearchDestRow({required this.dest});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(13)),
            child: CachedNetworkImage(
              imageUrl: dest.image,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  Container(color: AppColors.shimmerBase),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dest.name,
                    style: AppTextStyles.labelLarge
                        .copyWith(fontWeight: FontWeight.w700)),
                Text(dest.country,
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.textHint)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: Color(0xFFFFD700), size: 12),
                    const SizedBox(width: 2),
                    Text(
                      dest.rating.toString(),
                      style: AppTextStyles.labelSmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withAlpha(30),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        dest.tag,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.accent,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

class _SearchPersonRow extends StatefulWidget {
  final MockUser user;

  const _SearchPersonRow({required this.user});

  @override
  State<_SearchPersonRow> createState() => _SearchPersonRowState();
}

class _SearchPersonRowState extends State<_SearchPersonRow> {
  bool _connected = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          UserAvatar(
            imageUrl: widget.user.avatarUrl,
            name: widget.user.fullName,
            size: 46,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.user.fullName,
                    style: AppTextStyles.labelLarge
                        .copyWith(fontWeight: FontWeight.w700)),
                Text('@${widget.user.username}',
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.textHint)),
                if (widget.user.location != null)
                  Text(widget.user.location!,
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.textHint)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _connected = !_connected),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: _connected
                    ? AppColors.primarySurface
                    : AppColors.primary,
                borderRadius: BorderRadius.circular(20),
                border: _connected
                    ? Border.all(color: AppColors.primary)
                    : null,
              ),
              child: Text(
                _connected ? 'Connected' : 'Connect',
                style: AppTextStyles.labelSmall.copyWith(
                  color: _connected ? AppColors.primary : Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Search Suggestions (empty query) ─────────────────────────────────────────

class _SearchSuggestions extends StatelessWidget {
  final List<String> _recent = const [
    'Ladakh', 'Kerala backwaters', 'Goa beaches', 'Rajasthan'
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        Text('Recent Searches',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            )),
        const SizedBox(height: 10),
        ..._recent.map((s) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.history_rounded,
                    size: 16, color: AppColors.textHint),
              ),
              title: Text(s, style: AppTextStyles.bodyMedium),
              trailing: const Icon(Icons.north_west_rounded,
                  size: 14, color: AppColors.textHint),
            )),
        const SizedBox(height: 20),
        Text('Popular Searches',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            )),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: MockData.trendingVibes.map((v) {
            return Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppColors.primary.withAlpha(80)),
              ),
              child: Text(v,
                  style: AppTextStyles.labelMedium
                      .copyWith(color: AppColors.primary)),
            );
          }).toList(),
        ),
      ],
    );
  }
}
