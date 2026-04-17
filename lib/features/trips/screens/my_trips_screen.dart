import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/mock_data.dart';

// ── Mock trip data ────────────────────────────────────────────────────────────

enum _TripStatus { upcoming, ongoing, completed, cancelled }

class _MockTrip {
  final String id;
  final String title;
  final String location;
  final String imageUrl;
  final DateTime startDate;
  final DateTime endDate;
  final _TripStatus status;
  final int buddyCount;
  final double amountPaid;
  final String packageId;

  const _MockTrip({
    required this.id,
    required this.title,
    required this.location,
    required this.imageUrl,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.buddyCount,
    required this.amountPaid,
    required this.packageId,
  });

  int get durationDays => endDate.difference(startDate).inDays + 1;

  int get daysUntil => startDate.difference(DateTime.now()).inDays;
}

final _mockTrips = [
  _MockTrip(
    id: 't1',
    title: 'Ladakh Expedition',
    location: 'Leh, Ladakh',
    imageUrl:
        'https://images.unsplash.com/photo-1589308078059-be1415eab4c3?w=800',
    startDate: DateTime.now().add(const Duration(days: 12)),
    endDate: DateTime.now().add(const Duration(days: 17)),
    status: _TripStatus.upcoming,
    buddyCount: 4,
    amountPaid: 8500,
    packageId: 'p1',
  ),
  _MockTrip(
    id: 't2',
    title: 'Munnar Tea Valley',
    location: 'Munnar, Kerala',
    imageUrl:
        'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=800',
    startDate: DateTime.now().subtract(const Duration(days: 1)),
    endDate: DateTime.now().add(const Duration(days: 2)),
    status: _TripStatus.ongoing,
    buddyCount: 2,
    amountPaid: 3500,
    packageId: 'p2',
  ),
  _MockTrip(
    id: 't3',
    title: 'Rajasthan Royal Tour',
    location: 'Jaipur, Rajasthan',
    imageUrl:
        'https://images.unsplash.com/photo-1477587458883-47145ed6979e?w=800',
    startDate: DateTime.now().subtract(const Duration(days: 30)),
    endDate: DateTime.now().subtract(const Duration(days: 24)),
    status: _TripStatus.completed,
    buddyCount: 6,
    amountPaid: 6500,
    packageId: 'p4',
  ),
  _MockTrip(
    id: 't4',
    title: 'Goa Beach Getaway',
    location: 'North Goa',
    imageUrl:
        'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?w=800',
    startDate: DateTime.now().subtract(const Duration(days: 90)),
    endDate: DateTime.now().subtract(const Duration(days: 86)),
    status: _TripStatus.completed,
    buddyCount: 3,
    amountPaid: 4200,
    packageId: 'p3',
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({super.key});

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  List<_MockTrip> _tripsFor(_TripStatus status) =>
      _mockTrips.where((t) => t.status == status).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: AppColors.textPrimary,
          onPressed: () => context.pop(),
        ),
        title: Text('My Trips', style: AppTextStyles.headlineMedium),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            color: AppColors.primary,
            onPressed: () => context.push('/shell/explore'),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabCtrl,
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
                Tab(text: 'Active'),
                Tab(text: 'Upcoming'),
                Tab(text: 'Past'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          // Active = ongoing
          _TripsList(
            trips: _tripsFor(_TripStatus.ongoing),
            emptyIcon: Icons.flight_takeoff_rounded,
            emptyLabel: 'No active trips',
            emptySubLabel: 'Your ongoing adventures will appear here',
          ),
          // Upcoming
          _TripsList(
            trips: _tripsFor(_TripStatus.upcoming),
            emptyIcon: Icons.luggage_rounded,
            emptyLabel: 'No upcoming trips',
            emptySubLabel: 'Start exploring and book your next adventure!',
            emptyAction: _ExploreButton(),
          ),
          // Past = completed + cancelled
          _TripsList(
            trips: [
              ..._tripsFor(_TripStatus.completed),
              ..._tripsFor(_TripStatus.cancelled),
            ],
            emptyIcon: Icons.history_rounded,
            emptyLabel: 'No past trips',
            emptySubLabel: 'Your completed trips will appear here',
          ),
        ],
      ),
    );
  }
}

class _ExploreButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: GestureDetector(
        onTap: () => context.push('/shell/explore'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            'Explore Packages',
            style: AppTextStyles.labelLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Trips List ────────────────────────────────────────────────────────────────

class _TripsList extends StatelessWidget {
  final List<_MockTrip> trips;
  final IconData emptyIcon;
  final String emptyLabel;
  final String emptySubLabel;
  final Widget? emptyAction;

  const _TripsList({
    required this.trips,
    required this.emptyIcon,
    required this.emptyLabel,
    required this.emptySubLabel,
    this.emptyAction,
  });

  @override
  Widget build(BuildContext context) {
    if (trips.isEmpty) {
      return _EmptyTrips(
        icon: emptyIcon,
        label: emptyLabel,
        subLabel: emptySubLabel,
        action: emptyAction,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      itemCount: trips.length,
      itemBuilder: (context, index) => _TripCard(
        trip: trips[index],
        index: index,
      ),
    );
  }
}

// ── Trip Card ─────────────────────────────────────────────────────────────────

class _TripCard extends StatefulWidget {
  final _MockTrip trip;
  final int index;

  const _TripCard({required this.trip, required this.index});

  @override
  State<_TripCard> createState() => _TripCardState();
}

class _TripCardState extends State<_TripCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _enterCtrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fade = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut));
    Future.delayed(Duration(milliseconds: 80 * widget.index), () {
      if (mounted) _enterCtrl.forward();
    });
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    super.dispose();
  }

  void _openDetail() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TripDetailSheet(trip: widget.trip),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: GestureDetector(
          onTap: _openDetail,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withAlpha(12),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image header
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20)),
                  child: Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 2.4,
                        child: Image.network(
                          widget.trip.imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Container(color: AppColors.shimmerBase);
                          },
                        ),
                      ),
                      // Gradient
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withAlpha(160),
                              ],
                              stops: const [0.4, 1.0],
                            ),
                          ),
                        ),
                      ),
                      // Status badge
                      Positioned(
                        top: 12,
                        right: 12,
                        child: _StatusBadge(status: widget.trip.status),
                      ),
                      // Countdown for upcoming
                      if (widget.trip.status == _TripStatus.upcoming)
                        Positioned(
                          top: 12,
                          left: 12,
                          child: _CountdownBadge(
                              daysUntil: widget.trip.daysUntil),
                        ),
                      // Title overlay
                      Positioned(
                        left: 14,
                        right: 14,
                        bottom: 12,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.trip.title,
                              style: AppTextStyles.headlineSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.location_on_rounded,
                                    color: Colors.white70, size: 13),
                                const SizedBox(width: 3),
                                Text(
                                  widget.trip.location,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Info row
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      _InfoChip(
                        icon: Icons.calendar_today_rounded,
                        label: _formatDateRange(
                          widget.trip.startDate,
                          widget.trip.endDate,
                        ),
                      ),
                      const SizedBox(width: 10),
                      _InfoChip(
                        icon: Icons.access_time_rounded,
                        label: '${widget.trip.durationDays}D',
                      ),
                      const SizedBox(width: 10),
                      _InfoChip(
                        icon: Icons.people_rounded,
                        label: '${widget.trip.buddyCount} buddies',
                      ),
                      const Spacer(),
                      Text(
                        '₹${widget.trip.amountPaid.toStringAsFixed(0)}',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),

                // Progress bar for ongoing trips
                if (widget.trip.status == _TripStatus.ongoing)
                  _OngoingProgress(trip: widget.trip),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDateRange(DateTime start, DateTime end) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${start.day} ${months[start.month - 1]} – ${end.day} ${months[end.month - 1]}';
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textHint),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final _TripStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case _TripStatus.ongoing:
        color = const Color(0xFF4CAF50);
        label = '● Live';
        break;
      case _TripStatus.upcoming:
        color = AppColors.primary;
        label = 'Upcoming';
        break;
      case _TripStatus.completed:
        color = AppColors.textSecondary;
        label = 'Completed';
        break;
      case _TripStatus.cancelled:
        color = AppColors.error;
        label = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _CountdownBadge extends StatelessWidget {
  final int daysUntil;

  const _CountdownBadge({required this.daysUntil});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(140),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.hourglass_top_rounded,
              color: Colors.amber, size: 12),
          const SizedBox(width: 4),
          Text(
            daysUntil == 0 ? 'Tomorrow!' : '$daysUntil days left',
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _OngoingProgress extends StatefulWidget {
  final _MockTrip trip;

  const _OngoingProgress({required this.trip});

  @override
  State<_OngoingProgress> createState() => _OngoingProgressState();
}

class _OngoingProgressState extends State<_OngoingProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _progress;

  double get _tripProgress {
    final total =
        widget.trip.endDate.difference(widget.trip.startDate).inHours;
    final elapsed =
        DateTime.now().difference(widget.trip.startDate).inHours;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _progress = Tween<double>(begin: 0, end: _tripProgress).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    Future.delayed(const Duration(milliseconds: 300), () {
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Trip Progress',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textHint,
                ),
              ),
              AnimatedBuilder(
                animation: _progress,
                builder: (context, child) => Text(
                  '${(_progress.value * 100).round()}%',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: AnimatedBuilder(
              animation: _progress,
              builder: (context, child) => LinearProgressIndicator(
                value: _progress.value,
                backgroundColor: AppColors.border,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                minHeight: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Trip Detail Sheet ─────────────────────────────────────────────────────────

class _TripDetailSheet extends StatefulWidget {
  final _MockTrip trip;

  const _TripDetailSheet({required this.trip});

  @override
  State<_TripDetailSheet> createState() => _TripDetailSheetState();
}

class _TripDetailSheetState extends State<_TripDetailSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _enterCtrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    )..forward();
    _fade = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);
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
      child: DraggableScrollableSheet(
        initialChildSize: 0.72,
        minChildSize: 0.5,
        maxChildSize: 0.92,
        builder: (context, scrollCtrl) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                    children: [
                      // Title section
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.trip.title,
                                  style: AppTextStyles.headlineMedium,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined,
                                        size: 14,
                                        color: AppColors.textSecondary),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.trip.location,
                                      style: AppTextStyles.bodySmall,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          _StatusBadge(status: widget.trip.status),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Stats row
                      Row(
                        children: [
                          _DetailStat(
                            icon: Icons.calendar_today_rounded,
                            label: 'Duration',
                            value: '${widget.trip.durationDays} Days',
                          ),
                          const SizedBox(width: 12),
                          _DetailStat(
                            icon: Icons.people_rounded,
                            label: 'Buddies',
                            value: '${widget.trip.buddyCount} People',
                          ),
                          const SizedBox(width: 12),
                          _DetailStat(
                            icon: Icons.currency_rupee_rounded,
                            label: 'Paid',
                            value:
                                '₹${widget.trip.amountPaid.toStringAsFixed(0)}',
                            valueColor: AppColors.primary,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      const Divider(height: 1),
                      const SizedBox(height: 20),

                      // Dates
                      _SheetSection(
                        icon: Icons.event_rounded,
                        title: 'Travel Dates',
                        child: _DateRange(trip: widget.trip),
                      ),

                      const SizedBox(height: 20),

                      // Travel buddies
                      _SheetSection(
                        icon: Icons.people_rounded,
                        title: 'Travel Buddies',
                        child: _BuddyAvatars(
                          count: widget.trip.buddyCount),
                      ),

                      const SizedBox(height: 20),

                      // Quick actions
                      _SheetSection(
                        icon: Icons.grid_view_rounded,
                        title: 'Quick Actions',
                        child: _QuickActions(trip: widget.trip),
                      ),

                      const SizedBox(height: 24),

                      // View package button
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/package/${widget.trip.packageId}');
                        },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              'View Full Package Details',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DetailStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailStat({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(height: 6),
            Text(
              value,
              style: AppTextStyles.labelLarge.copyWith(
                fontWeight: FontWeight.w700,
                color: valueColor,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              label,
              style: AppTextStyles.labelSmall
                  .copyWith(color: AppColors.textHint),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SheetSection({
    required this.icon,
    required this.title,
    required this.child,
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
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _DateRange extends StatelessWidget {
  final _MockTrip trip;

  const _DateRange({required this.trip});

  @override
  Widget build(BuildContext context) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return Row(
      children: [
        _DateBox(
          day: trip.startDate.day.toString(),
          month: months[trip.startDate.month - 1],
          label: 'Start',
        ),
        Expanded(
          child: Column(
            children: [
              const Divider(endIndent: 0, indent: 0),
              Text(
                '${trip.durationDays} Days',
                style: AppTextStyles.labelSmall
                    .copyWith(color: AppColors.textHint),
              ),
            ],
          ),
        ),
        _DateBox(
          day: trip.endDate.day.toString(),
          month: months[trip.endDate.month - 1],
          label: 'End',
          isPrimary: true,
        ),
      ],
    );
  }
}

class _DateBox extends StatelessWidget {
  final String day;
  final String month;
  final String label;
  final bool isPrimary;

  const _DateBox({
    required this.day,
    required this.month,
    required this.label,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isPrimary ? AppColors.primarySurface : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: isPrimary
            ? Border.all(color: AppColors.primary.withAlpha(80))
            : null,
      ),
      child: Column(
        children: [
          Text(
            day,
            style: AppTextStyles.headlineMedium.copyWith(
              color: isPrimary ? AppColors.primary : AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            month,
            style: AppTextStyles.labelSmall.copyWith(
              color: isPrimary ? AppColors.primary : AppColors.textHint,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textHint,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _BuddyAvatars extends StatelessWidget {
  final int count;

  const _BuddyAvatars({required this.count});

  @override
  Widget build(BuildContext context) {
    final users = MockData.suggestedUsers;
    final show = count.clamp(0, users.length);
    return Row(
      children: [
        SizedBox(
          height: 44,
          width: show * 30.0 + 14,
          child: Stack(
            children: List.generate(show, (i) {
              return Positioned(
                left: i * 30.0,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: Colors.white, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage:
                        NetworkImage(users[i].avatarUrl),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$count travel buddies joined',
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  final _MockTrip trip;

  const _QuickActions({required this.trip});

  @override
  Widget build(BuildContext context) {
    final actions = [
      (Icons.chat_bubble_outline_rounded, 'Group Chat', AppColors.primary),
      (Icons.map_outlined, 'Itinerary', const Color(0xFF5B8DEF)),
      (Icons.receipt_long_outlined, 'Booking', const Color(0xFFF4A623)),
      (Icons.share_outlined, 'Share Trip', const Color(0xFF6CC17A)),
    ];

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: actions.map((a) {
        return _QuickActionBtn(
          icon: a.$1,
          label: a.$2,
          color: a.$3,
        );
      }).toList(),
    );
  }
}

class _QuickActionBtn extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _QuickActionBtn({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  State<_QuickActionBtn> createState() => _QuickActionBtnState();
}

class _QuickActionBtnState extends State<_QuickActionBtn>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.9,
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
      onTapUp: (_) => _pressCtrl.forward(),
      onTapCancel: () => _pressCtrl.forward(),
      child: ScaleTransition(
        scale: _pressCtrl,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: widget.color.withAlpha(20),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: widget.color.withAlpha(60)),
              ),
              child: Icon(widget.icon,
                  color: widget.color, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              widget.label,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyTrips extends StatefulWidget {
  final IconData icon;
  final String label;
  final String subLabel;
  final Widget? action;

  const _EmptyTrips({
    required this.icon,
    required this.label,
    required this.subLabel,
    this.action,
  });

  @override
  State<_EmptyTrips> createState() => _EmptyTripsState();
}

class _EmptyTripsState extends State<_EmptyTrips>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _float;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _float = Tween<double>(begin: 0, end: -12).animate(
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
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: Icon(widget.icon,
                  size: 48, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 24),
          Text(widget.label, style: AppTextStyles.headlineMedium),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              widget.subLabel,
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
          if (widget.action != null) widget.action!,
        ],
      ),
    );
  }
}
