import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/mock_data.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/chat_input_bar.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;

  const ChatDetailScreen({super.key, required this.chatId});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  late ScrollController _scrollController;
  late List<MockMessage> _messages;
  late MockChat _chat;
  bool _showTyping = false;
  bool _showScrollFab = false;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);

    _chat = MockData.chats.firstWhere(
      (c) => c.id == widget.chatId,
      orElse: () => MockData.chats.first,
    );

    // Seed with some mock messages
    _messages = [
      MockMessage(
        id: 'seed1',
        senderId: _chat.participant.id,
        text: 'Hey! Are you planning to join the Himalaya trip? 🏔️',
        timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 30)),
        isRead: true,
      ),
      MockMessage(
        id: 'seed2',
        senderId: MockData.currentUser.id,
        text: 'Yes! I was checking it out. Looks amazing.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 25)),
        isRead: true,
      ),
      MockMessage(
        id: 'seed3',
        senderId: _chat.participant.id,
        text: 'The package includes paragliding and zip-lining too!',
        timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 24)),
        isRead: true,
      ),
      MockMessage(
        id: 'seed4',
        senderId: _chat.participant.id,
        text: 'I already signed up. Would be great if you join too 😊',
        timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 24)),
        isRead: true,
      ),
      MockMessage(
        id: 'seed5',
        senderId: MockData.currentUser.id,
        text: 'That sounds so good! Let me check the dates.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 40)),
        isRead: true,
      ),
      MockMessage(
        id: 'seed6',
        senderId: MockData.currentUser.id,
        text: 'What\'s the best time to book?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 39)),
        isRead: true,
      ),
      MockMessage(
        id: 'seed7',
        senderId: _chat.participant.id,
        text: 'The sooner the better! Slots fill up fast 🔥',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        isRead: false,
      ),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _onScroll() {
    final showFab = _scrollController.hasClients &&
        _scrollController.offset <
            _scrollController.position.maxScrollExtent - 200;
    if (showFab != _showScrollFab) {
      setState(() => _showScrollFab = showFab);
    }
  }

  void _scrollToBottom({bool animated = false}) {
    if (!_scrollController.hasClients) return;
    if (animated) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(
        _scrollController.position.maxScrollExtent,
      );
    }
  }

  void _onSend(String text) {
    final msg = MockMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: MockData.currentUser.id,
      text: text,
      timestamp: DateTime.now(),
      isRead: false,
    );
    setState(() => _messages.add(msg));

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollToBottom(animated: true),
    );

    // Simulate reply after a delay
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() => _showTyping = true);
      _scrollToBottom(animated: true);

      Timer(const Duration(milliseconds: 2000), () {
        if (!mounted) return;
        final replies = [
          'That\'s great! 🎉',
          'Let\'s do it!',
          'I\'ll share the booking link.',
          'Can\'t wait! 🏔️',
          'See you on the trip! ✈️',
        ];
        final reply = replies[
            DateTime.now().millisecondsSinceEpoch % replies.length];
        setState(() {
          _showTyping = false;
          _messages.add(MockMessage(
            id: 'reply_${DateTime.now().millisecondsSinceEpoch}',
            senderId: _chat.participant.id,
            text: reply,
            timestamp: DateTime.now(),
            isRead: false,
          ));
        });
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _scrollToBottom(animated: true),
        );
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: Stack(
              children: [
                ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(top: 12, bottom: 8),
                  itemCount:
                      _messages.length + (_showTyping ? 1 : 0) + 1,
                  itemBuilder: (context, index) {
                    // Date divider at top
                    if (index == 0) {
                      return const DateDivider(label: 'Today');
                    }

                    final msgIndex = index - 1;

                    // Typing indicator at the end
                    if (_showTyping && msgIndex == _messages.length) {
                      return const TypingIndicator();
                    }

                    if (msgIndex >= _messages.length) return const SizedBox();

                    final message = _messages[msgIndex];
                    final isMine =
                        message.senderId == MockData.currentUser.id;

                    // Group consecutive messages from same sender
                    final prevMsg =
                        msgIndex > 0 ? _messages[msgIndex - 1] : null;
                    final nextMsg = msgIndex < _messages.length - 1
                        ? _messages[msgIndex + 1]
                        : null;

                    final isFirst =
                        prevMsg == null ||
                        prevMsg.senderId != message.senderId;
                    final isLast =
                        nextMsg == null ||
                        nextMsg.senderId != message.senderId;

                    return MessageBubble(
                      key: ValueKey(message.id),
                      message: message,
                      isMine: isMine,
                      isFirst: isFirst,
                      isLast: isLast,
                      showAvatar: !isMine && isLast,
                      avatarUrl: _chat.participant.avatarUrl,
                      senderName: _chat.participant.fullName,
                    );
                  },
                ),

                // Scroll to bottom FAB
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  bottom: _showScrollFab ? 12 : -60,
                  right: 16,
                  child: AnimatedOpacity(
                    opacity: _showScrollFab ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: GestureDetector(
                      onTap: () => _scrollToBottom(animated: true),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withAlpha(80),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Input bar
          ChatInputBar(
            onSend: _onSend,
            onTyping: () {},
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final participant = _chat.participant;
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            size: 20, color: AppColors.textPrimary),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: GestureDetector(
        onTap: () {},
        child: Row(
          children: [
            UserAvatar(
              imageUrl: participant.avatarUrl,
              name: participant.fullName,
              size: 40,
              showOnlineIndicator: true,
              isOnline: true,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(participant.fullName,
                    style: AppTextStyles.titleLarge),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Online',
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.success),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.videocam_outlined,
              color: AppColors.textPrimary),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.more_vert_rounded,
              color: AppColors.textPrimary),
          onPressed: () => _showChatOptions(context),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.divider),
      ),
    );
  }

  void _showChatOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ChatOptionsSheet(participantName: _chat.participant.fullName),
    );
  }
}

// ── Chat Options Sheet ────────────────────────────────────────────────────────

class _ChatOptionsSheet extends StatelessWidget {
  final String participantName;

  const _ChatOptionsSheet({required this.participantName});

  @override
  Widget build(BuildContext context) {
    final options = [
      (Icons.person_outline_rounded, 'View Profile'),
      (Icons.search_rounded, 'Search in Chat'),
      (Icons.notifications_off_outlined, 'Mute Notifications'),
      (Icons.delete_outline_rounded, 'Clear Chat'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Text(participantName,
                style: AppTextStyles.headlineSmall),
          ),
          const SizedBox(height: 8),
          ...options.map((opt) => ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(opt.$1,
                      size: 20, color: AppColors.textSecondary),
                ),
                title: Text(opt.$2, style: AppTextStyles.titleMedium),
                onTap: () => Navigator.pop(context),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20),
              )),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
