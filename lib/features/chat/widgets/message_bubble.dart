import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/mock_data.dart';

class MessageBubble extends StatelessWidget {
  final MockMessage message;
  final bool isMine;
  final bool showAvatar;
  final bool isFirst;   // first in a group from same sender
  final bool isLast;    // last in a group from same sender
  final String? avatarUrl;
  final String senderName;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
    this.showAvatar = false,
    this.isFirst = true,
    this.isLast = true,
    this.avatarUrl,
    required this.senderName,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      builder: (_, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(isMine ? 20 * (1 - value) : -20 * (1 - value), 0),
          child: child,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: isMine ? 60 : 16,
          right: isMine ? 16 : 60,
          top: isFirst ? 6 : 2,
          bottom: isLast ? 6 : 2,
        ),
        child: Row(
          mainAxisAlignment:
              isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Avatar (received side only, last in group)
            if (!isMine) ...[
              if (isLast)
                _MiniAvatar(
                  url: avatarUrl,
                  name: senderName,
                )
              else
                const SizedBox(width: 32),
              const SizedBox(width: 8),
            ],

            // Bubble
            Flexible(
              child: Column(
                crossAxisAlignment: isMine
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  _BubbleBody(
                    message: message,
                    isMine: isMine,
                    isFirst: isFirst,
                    isLast: isLast,
                  ),
                  if (isLast)
                    Padding(
                      padding: const EdgeInsets.only(top: 3, left: 4, right: 4),
                      child: _TimeAndStatus(
                          message: message, isMine: isMine),
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

class _BubbleBody extends StatelessWidget {
  final MockMessage message;
  final bool isMine;
  final bool isFirst;
  final bool isLast;

  const _BubbleBody({
    required this.message,
    required this.isMine,
    required this.isFirst,
    required this.isLast,
  });

  BorderRadius get _borderRadius {
    const r = Radius.circular(18);
    const rSmall = Radius.circular(4);
    if (isMine) {
      return BorderRadius.only(
        topLeft: r,
        topRight: isFirst ? r : rSmall,
        bottomLeft: r,
        bottomRight: isLast ? rSmall : rSmall,
      );
    } else {
      return BorderRadius.only(
        topLeft: isFirst ? r : rSmall,
        topRight: r,
        bottomLeft: isLast ? rSmall : rSmall,
        bottomRight: r,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isMine ? AppColors.primary : AppColors.surfaceVariant,
        borderRadius: _borderRadius,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        message.text,
        style: AppTextStyles.bodyMedium.copyWith(
          color: isMine ? Colors.white : AppColors.textPrimary,
          height: 1.4,
        ),
      ),
    );
  }
}

class _TimeAndStatus extends StatelessWidget {
  final MockMessage message;
  final bool isMine;

  const _TimeAndStatus({required this.message, required this.isMine});

  String _formatTime(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _formatTime(message.timestamp),
          style: AppTextStyles.labelSmall.copyWith(fontSize: 10),
        ),
        if (isMine) ...[
          const SizedBox(width: 4),
          Icon(
            message.isRead
                ? Icons.done_all_rounded
                : Icons.done_rounded,
            size: 14,
            color: message.isRead
                ? AppColors.primary
                : AppColors.textHint,
          ),
        ],
      ],
    );
  }
}

class _MiniAvatar extends StatelessWidget {
  final String? url;
  final String name;

  const _MiniAvatar({this.url, required this.name});

  @override
  Widget build(BuildContext context) {
    final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border),
      ),
      child: ClipOval(
        child: url != null && url!.isNotEmpty
            ? Image.network(url!, fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => _initials(initials))
            : _initials(initials),
      ),
    );
  }

  Widget _initials(String text) => Center(
        child: Text(
          text,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.primary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}

// ── Date Divider ──────────────────────────────────────────────────────────────

class DateDivider extends StatelessWidget {
  final String label;

  const DateDivider({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          const Expanded(child: Divider(color: AppColors.border)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(label, style: AppTextStyles.labelSmall),
            ),
          ),
          const Expanded(child: Divider(color: AppColors.border)),
        ],
      ),
    );
  }
}
