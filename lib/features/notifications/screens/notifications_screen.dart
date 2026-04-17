import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/user_avatar.dart';

// ── Mock Notification Data ────────────────────────────────────────────────────

enum _NotifType { tripRequest, connection, like, comment, tripUpdate, system }

class _MockNotif {
  final String id;
  final _NotifType type;
  final String avatarUrl;
  final String actorName;
  final String body;
  final String timeAgo;
  bool isRead;

  _MockNotif({
    required this.id,
    required this.type,
    required this.avatarUrl,
    required this.actorName,
    required this.body,
    required this.timeAgo,
    this.isRead = false,
  });
}

final _mockNotifications = <_MockNotif>[
  _MockNotif(
    id: 'n1',
    type: _NotifType.tripRequest,
    avatarUrl: 'https://i.pravatar.cc/150?img=5',
    actorName: 'Priya Sharma',
    body: 'wants to join your Ladakh trip.',
    timeAgo: '2m ago',
    isRead: false,
  ),
  _MockNotif(
    id: 'n2',
    type: _NotifType.connection,
    avatarUrl: 'https://i.pravatar.cc/150?img=12',
    actorName: 'Arjun Nair',
    body: 'sent you a connection request.',
    timeAgo: '15m ago',
    isRead: false,
  ),
  _MockNotif(
    id: 'n3',
    type: _NotifType.like,
    avatarUrl: 'https://i.pravatar.cc/150?img=22',
    actorName: 'Meera Pillai',
    body: 'liked your post about Munnar.',
    timeAgo: '1h ago',
    isRead: false,
  ),
  _MockNotif(
    id: 'n4',
    type: _NotifType.comment,
    avatarUrl: 'https://i.pravatar.cc/150?img=33',
    actorName: 'Rohit Kumar',
    body: 'commented: "Absolutely stunning view! 😍"',
    timeAgo: '2h ago',
    isRead: true,
  ),
  _MockNotif(
    id: 'n5',
    type: _NotifType.tripUpdate,
    avatarUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=80',
    actorName: 'Ladakh Expedition',
    body: 'Your trip starts in 3 days. Check the itinerary.',
    timeAgo: '5h ago',
    isRead: true,
  ),
  _MockNotif(
    id: 'n6',
    type: _NotifType.connection,
    avatarUrl: 'https://i.pravatar.cc/150?img=44',
    actorName: 'Sneha Reddy',
    body: 'accepted your connection request.',
    timeAgo: '1d ago',
    isRead: true,
  ),
  _MockNotif(
    id: 'n7',
    type: _NotifType.like,
    avatarUrl: 'https://i.pravatar.cc/150?img=55',
    actorName: 'Vikram Singh',
    body: 'and 12 others liked your Goa album.',
    timeAgo: '1d ago',
    isRead: true,
  ),
  _MockNotif(
    id: 'n8',
    type: _NotifType.system,
    avatarUrl: '',
    actorName: 'Unzolo',
    body: 'New travel buddies found near Coorg. Explore now!',
    timeAgo: '2d ago',
    isRead: true,
  ),
  _MockNotif(
    id: 'n9',
    type: _NotifType.tripRequest,
    avatarUrl: 'https://i.pravatar.cc/150?img=66',
    actorName: 'Ananya Das',
    body: 'wants to join your Kerala Backwaters trip.',
    timeAgo: '3d ago',
    isRead: true,
  ),
  _MockNotif(
    id: 'n10',
    type: _NotifType.comment,
    avatarUrl: 'https://i.pravatar.cc/150?img=77',
    actorName: 'Kabir Mehta',
    body: 'replied to your comment: "We should definitely go!"',
    timeAgo: '4d ago',
    isRead: true,
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final List<_MockNotif> _notifs =
      List.from(_mockNotifications);

  int get _unreadCount => _notifs.where((n) => !n.isRead).length;

  void _markAllRead() {
    setState(() {
      for (final n in _notifs) {
        n.isRead = true;
      }
    });
  }

  void _dismiss(String id) {
    setState(() => _notifs.removeWhere((n) => n.id == id));
  }

  void _markRead(String id) {
    setState(() {
      final idx = _notifs.indexWhere((n) => n.id == id);
      if (idx >= 0) _notifs[idx].isRead = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final newNotifs = _notifs.where((n) => !n.isRead).toList();
    final earlierNotifs = _notifs.where((n) => n.isRead).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Notifications', style: AppTextStyles.headlineMedium),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: Text(
                'Mark all read',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
      body: _notifs.isEmpty
          ? _EmptyState()
          : ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                if (newNotifs.isNotEmpty) ...[
                  _SectionHeader(
                    label: 'New',
                    count: newNotifs.length,
                  ),
                  ...newNotifs.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final notif = entry.value;
                    return _NotifTile(
                      key: ValueKey(notif.id),
                      notif: notif,
                      index: idx,
                      onDismiss: () => _dismiss(notif.id),
                      onTap: () => _markRead(notif.id),
                    );
                  }),
                  const SizedBox(height: 8),
                ],
                if (earlierNotifs.isNotEmpty) ...[
                  _SectionHeader(label: 'Earlier'),
                  ...earlierNotifs.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final notif = entry.value;
                    return _NotifTile(
                      key: ValueKey(notif.id),
                      notif: notif,
                      index: newNotifs.length + idx,
                      onDismiss: () => _dismiss(notif.id),
                      onTap: () {},
                    );
                  }),
                ],
              ],
            ),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final int? count;

  const _SectionHeader({required this.label, this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: [
          Text(
            label,
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Notification Tile ─────────────────────────────────────────────────────────

class _NotifTile extends StatefulWidget {
  final _MockNotif notif;
  final int index;
  final VoidCallback onDismiss;
  final VoidCallback onTap;

  const _NotifTile({
    super.key,
    required this.notif,
    required this.index,
    required this.onDismiss,
    required this.onTap,
  });

  @override
  State<_NotifTile> createState() => _NotifTileState();
}

class _NotifTileState extends State<_NotifTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _enterCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnim = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: 40 * widget.index), () {
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
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Dismissible(
          key: ValueKey(widget.notif.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            color: Colors.red.shade400,
            child: const Icon(Icons.delete_outline_rounded,
                color: Colors.white, size: 24),
          ),
          onDismissed: (_) => widget.onDismiss(),
          child: _TileContent(
            notif: widget.notif,
            onTap: widget.onTap,
          ),
        ),
      ),
    );
  }
}

class _TileContent extends StatelessWidget {
  final _MockNotif notif;
  final VoidCallback onTap;

  const _TileContent({required this.notif, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        color: notif.isRead
            ? Colors.transparent
            : AppColors.primarySurface.withAlpha(80),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar / Icon
            _NotifAvatar(notif: notif),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.45,
                      ),
                      children: [
                        TextSpan(
                          text: '${notif.actorName} ',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        TextSpan(text: notif.body),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.timeAgo,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),

                  // Action buttons for actionable notifs
                  if (!notif.isRead &&
                      (notif.type == _NotifType.tripRequest ||
                          notif.type == _NotifType.connection))
                    _ActionButtons(type: notif.type),
                ],
              ),
            ),

            // Unread dot
            if (!notif.isRead)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 8),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NotifAvatar extends StatelessWidget {
  final _MockNotif notif;

  const _NotifAvatar({required this.notif});

  @override
  Widget build(BuildContext context) {
    if (notif.type == _NotifType.system) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.accent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.explore_rounded, color: Colors.white, size: 24),
      );
    }

    return Stack(
      children: [
        UserAvatar(
          imageUrl: notif.avatarUrl,
          name: notif.actorName,
          size: 48,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: _typeColor(notif.type),
              shape: BoxShape.circle,
              border: const Border.fromBorderSide(
                BorderSide(color: Colors.white, width: 2),
              ),
            ),
            child: Icon(
              _typeIcon(notif.type),
              size: 10,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Color _typeColor(_NotifType type) {
    switch (type) {
      case _NotifType.tripRequest:
        return AppColors.primary;
      case _NotifType.connection:
        return const Color(0xFF5B8DEF);
      case _NotifType.like:
        return const Color(0xFFE05C5C);
      case _NotifType.comment:
        return const Color(0xFFF4A623);
      case _NotifType.tripUpdate:
        return const Color(0xFF6CC17A);
      case _NotifType.system:
        return AppColors.primary;
    }
  }

  IconData _typeIcon(_NotifType type) {
    switch (type) {
      case _NotifType.tripRequest:
        return Icons.backpack_rounded;
      case _NotifType.connection:
        return Icons.person_add_rounded;
      case _NotifType.like:
        return Icons.favorite_rounded;
      case _NotifType.comment:
        return Icons.chat_bubble_rounded;
      case _NotifType.tripUpdate:
        return Icons.event_rounded;
      case _NotifType.system:
        return Icons.notifications_rounded;
    }
  }
}

class _ActionButtons extends StatefulWidget {
  final _NotifType type;

  const _ActionButtons({required this.type});

  @override
  State<_ActionButtons> createState() => _ActionButtonsState();
}

class _ActionButtonsState extends State<_ActionButtons> {
  bool _accepted = false;
  bool _declined = false;

  @override
  Widget build(BuildContext context) {
    if (_accepted) {
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: AppColors.primary, size: 16),
            const SizedBox(width: 4),
            Text(
              widget.type == _NotifType.tripRequest ? 'Request accepted' : 'Connected',
              style: AppTextStyles.labelSmall
                  .copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    if (_declined) {
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Row(
          children: [
            Icon(Icons.cancel_rounded, color: Colors.grey.shade400, size: 16),
            const SizedBox(width: 4),
            Text(
              'Declined',
              style: AppTextStyles.labelSmall
                  .copyWith(color: AppColors.textHint),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          _SmallButton(
            label: widget.type == _NotifType.tripRequest ? 'Accept' : 'Connect',
            isPrimary: true,
            onTap: () => setState(() => _accepted = true),
          ),
          const SizedBox(width: 8),
          _SmallButton(
            label: 'Decline',
            isPrimary: false,
            onTap: () => setState(() => _declined = true),
          ),
        ],
      ),
    );
  }
}

class _SmallButton extends StatefulWidget {
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  const _SmallButton({
    required this.label,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  State<_SmallButton> createState() => _SmallButtonState();
}

class _SmallButtonState extends State<_SmallButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.94,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _pressCtrl;
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
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          decoration: BoxDecoration(
            color: widget.isPrimary ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isPrimary ? AppColors.primary : AppColors.border,
              width: 1.5,
            ),
          ),
          child: Text(
            widget.label,
            style: AppTextStyles.labelSmall.copyWith(
              color: widget.isPrimary ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatefulWidget {
  @override
  State<_EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<_EmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatCtrl;
  late Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: 0, end: -12).animate(
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _floatAnim,
            builder: (context, child) => Transform.translate(
              offset: Offset(0, _floatAnim.value),
              child: child,
            ),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_outlined,
                size: 48,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('All caught up!', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 8),
          Text(
            "You'll find your trip updates\nand connection requests here.",
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
