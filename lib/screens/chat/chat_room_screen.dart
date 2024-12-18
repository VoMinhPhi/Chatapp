import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../models/user.dart';
import '../../models/group.dart';
import '../../models/message.dart';
import '../../theme/phix_theme.dart';
import '../group/group_info_sheet.dart';
import '../../widgets/sticker_picker.dart';

class ChatRoomScreen extends StatefulWidget {
  final User? user;
  final Group? group;

  const ChatRoomScreen({
    super.key,
    this.user,
    this.group,
  }) : assert(user != null || group != null);

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late final AnimationController _animationController;
  bool _isAtBottom = true;
  Timer? _typingTimer;
  bool _isSearching = false;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        final isAtBottom = _scrollController.offset >= 
            _scrollController.position.maxScrollExtent - 50;
        if (isAtBottom != _isAtBottom) {
          setState(() => _isAtBottom = isAtBottom);
        }
      }
    });
    
    // Đánh dấu tin nhắn đã đọc khi mở chat
    if (widget.user != null) {
      context.read<ChatProvider>().markAllMessagesAsRead(widget.user!.id);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    _searchController.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  void _scrollToBottom({bool animated = true}) {
    if (!_scrollController.hasClients) return;

    if (animated) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    } else {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  void _showGroupInfo(BuildContext context, Group group) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => GroupInfoSheet(group: group),
    );
  }

  void _showUserProfile(BuildContext context, User user) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: user.avatarUrl != null
                  ? NetworkImage(user.avatarUrl!)
                  : null,
              child: user.avatarUrl == null
                  ? Text(
                      user.name[0],
                      style: const TextStyle(fontSize: 32),
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              user.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              user.email,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildProfileAction(
                  icon: Icons.chat_bubble_outline,
                  label: 'Nhắn tin',
                  onTap: () => Navigator.pop(context),
                ),
                _buildProfileAction(
                  icon: Icons.block_outlined,
                  label: context.read<ChatProvider>().isUserBlocked(user.id)
                      ? 'Bỏ chặn'
                      : 'Chặn',
                  onTap: () {
                    context.read<ChatProvider>().toggleBlockUser(user.id);
                    Navigator.pop(context);
                  },
                ),
                _buildProfileAction(
                  icon: Icons.report_outlined,
                  label: 'Báo cáo',
                  onTap: () {
                    Navigator.pop(context);
                    _showReportDialog(context, user);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28),
            const SizedBox(height: 4),
            Text(label),
          ],
        ),
      ),
    );
  }

  void _showReportDialog(BuildContext context, User user) {
    final reasons = [
      'Spam',
      'Nội dung không phù hợp',
      'Quấy rối',
      'Lừa đảo',
      'Khác',
    ];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Báo cáo người dùng'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Chọn lý do báo cáo ${user.name}:'),
            const SizedBox(height: 16),
            ...reasons.map((reason) => ListTile(
              title: Text(reason),
              onTap: () {
                context.read<ChatProvider>().reportUser(user.id, reason);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Đã gửi báo cáo'),
                    backgroundColor: PhixTheme.successColor,
                  ),
                );
              },
            )),
          ],
        ),
      ),
    );
  }

  void _handleTyping() {
    final chatProvider = context.read<ChatProvider>();
    final currentUserId = chatProvider.currentUserId;
    if (currentUserId != null) {
      chatProvider.setTypingStatus(currentUserId, true);
      
      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(seconds: 2), () {
        chatProvider.setTypingStatus(currentUserId, false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PhixTheme.backgroundColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(_isSearching ? 120 : 60),
        child: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              final chatProvider = context.read<ChatProvider>();
              if (widget.group != null) {
                chatProvider.selectGroup(null);
              } else {
                chatProvider.selectUser(null);
              }
              Navigator.pop(context);
            },
          ),
          title: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: widget.user?.avatarUrl != null
                    ? NetworkImage(widget.user!.avatarUrl!)
                    : null,
                backgroundColor: widget.group != null
                    ? Colors.blue.shade100
                    : null,
                child: widget.user?.avatarUrl == null
                    ? Text(
                        widget.group?.name[0] ?? widget.user!.name[0],
                        style: TextStyle(
                          color: widget.group != null
                              ? Colors.blue.shade900
                              : null,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.group?.name ?? widget.user!.name,
                      style: const TextStyle(fontSize: 16),
                    ),
                    if (widget.group != null)
                      Text(
                        '${widget.group!.memberIds.length} thành viên',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    _searchController.clear();
                    context.read<ChatProvider>().setSearchQuery('');
                  }
                });
              },
            ),
            if (widget.group != null)
              IconButton(
                icon: const Icon(Icons.info_outline),
                tooltip: 'Thông tin nhóm',
                onPressed: () => _showGroupInfo(context, widget.group!),
              ),
            if (widget.user != null)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'view_profile',
                    child: ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: const Text('Xem thông tin'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'block',
                    child: Consumer<ChatProvider>(
                      builder: (context, chatProvider, child) {
                        final isBlocked = chatProvider.isUserBlocked(widget.user!.id);
                        return ListTile(
                          leading: Icon(
                            isBlocked ? Icons.block : Icons.block_outlined,
                            color: isBlocked ? PhixTheme.errorColor : null,
                          ),
                          title: Text(
                            isBlocked ? 'Bỏ chặn' : 'Chặn người dùng',
                            style: TextStyle(
                              color: isBlocked ? PhixTheme.errorColor : null,
                            ),
                          ),
                          contentPadding: EdgeInsets.zero,
                        );
                      },
                    ),
                  ),
                  PopupMenuItem(
                    value: 'mute',
                    child: Consumer<ChatProvider>(
                      builder: (context, chatProvider, child) {
                        final isMuted = chatProvider.isUserMuted(widget.user!.id);
                        return ListTile(
                          leading: Icon(
                            isMuted ? Icons.notifications_off : Icons.notifications_outlined,
                          ),
                          title: Text(isMuted ? 'Bật thông báo' : 'Tắt thông báo'),
                          contentPadding: EdgeInsets.zero,
                        );
                      },
                    ),
                  ),
                  PopupMenuItem(
                    value: 'clear',
                    child: ListTile(
                      leading: const Icon(Icons.delete_outline),
                      title: const Text('Xóa lịch sử chat'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'report',
                    child: ListTile(
                      leading: Icon(
                        Icons.report_outlined,
                        color: PhixTheme.errorColor,
                      ),
                      title: Text(
                        'Báo cáo',
                        style: TextStyle(color: PhixTheme.errorColor),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
                onSelected: (value) async {
                  switch (value) {
                    case 'view_profile':
                      _showUserProfile(context, widget.user!);
                      break;
                    case 'block':
                      final chatProvider = context.read<ChatProvider>();
                      final isBlocked = chatProvider.isUserBlocked(widget.user!.id);
                      if (isBlocked) {
                        chatProvider.toggleBlockUser(widget.user!.id);
                      } else {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Chặn người dùng'),
                            content: Text(
                              'Bạn có chắc muốn chặn ${widget.user!.name}? '
                              'Người này sẽ không thể nhắn tin cho bạn.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Hủy'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: PhixTheme.errorColor,
                                ),
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Chặn'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          chatProvider.toggleBlockUser(widget.user!.id);
                        }
                      }
                      break;
                    case 'mute':
                      context.read<ChatProvider>().toggleMuteUser(widget.user!.id);
                      break;
                    case 'clear':
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Xóa lịch sử chat'),
                          content: const Text(
                            'Bạn có chắc muốn xóa toàn bộ tin nhắn trong cuộc trò chuyện này? '
                            'Hành động này không thể hoàn tác.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Hủy'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: PhixTheme.errorColor,
                              ),
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Xóa'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        context.read<ChatProvider>().clearChatHistory(widget.user!.id);
                      }
                      break;
                    case 'report':
                      _showReportDialog(context, widget.user!);
                      break;
                  }
                },
              ),
          ],
          bottom: _isSearching
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(60),
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    color: Theme.of(context).primaryColor,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm tin nhắn...',
                        hintStyle: const TextStyle(color: Colors.white70),
                        prefixIcon: const Icon(Icons.search, color: Colors.white70),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                      ),
                      style: const TextStyle(color: Colors.white),
                      onChanged: (value) {
                        context.read<ChatProvider>().setSearchQuery(value);
                      },
                    ),
                  ),
                )
              : null,
        ),
      ),
      body: Column(
        children: [
          if (widget.group != null)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.grey[200],
              child: Text('${widget.group!.memberIds.length} thành viên'),
            ),
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                final messages = chatProvider.messages;
                
                if (_isAtBottom) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToBottom(animated: false);
                  });
                }

                return Stack(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.7,
                    ),
                    ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.7,
                        bottom: 16,
                      ),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isFirstMessage = index == 0;
                        final showAvatar = isFirstMessage || 
                            _shouldShowAvatar(messages, index);
                        
                        final isLatestMessage = index == messages.length - 1;
                        return isLatestMessage && _isAtBottom
                            ? _buildAnimatedMessageItem(message, showAvatar)
                            : MessageBubble(
                                message: message,
                                showAvatar: showAvatar,
                              );
                      },
                    ),
                    if (!_isAtBottom)
                      Positioned(
                        right: 16,
                        bottom: 16,
                        child: FloatingActionButton(
                          mini: true,
                          backgroundColor: Colors.blue.withOpacity(0.9),
                          child: const Icon(Icons.arrow_downward),
                          onPressed: () => _scrollToBottom(),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          MessageInput(
            isGroup: widget.group != null,
            onSent: () {
              _scrollToBottom();
            },
          ),
          if (widget.user != null)
            Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                final user = widget.user!;
                final isTyping = chatProvider.isUserTyping(user.id);
                final isOnline = user.isOnline;
                final lastSeen = user.lastSeen;

                if (isTyping) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    color: Colors.grey[100],
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 40,
                          child: LoadingDots(),
                        ),
                        Text('đang gõ...'),
                      ],
                    ),
                  );
                }

                if (isOnline) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    color: Colors.grey[100],
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.circle, size: 12, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Đang hoạt động'),
                      ],
                    ),
                  );
                }

                if (lastSeen != null) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    color: Colors.grey[100],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.circle, size: 12, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text('Hoạt động ${_formatLastSeen(lastSeen)}'),
                      ],
                    ),
                  );
                }

                return const SizedBox();
              },
            ),
        ],
      ),
    );
  }

  bool _shouldShowAvatar(List<Message> messages, int currentIndex) {
    if (currentIndex == 0) return true;
    
    final currentMessage = messages[currentIndex];
    final previousMessage = messages[currentIndex - 1];
    
    return currentMessage.senderId != previousMessage.senderId ||
           currentMessage.timestamp.difference(previousMessage.timestamp).inMinutes > 5;
  }

  Widget _buildAnimatedMessageItem(Message message, bool showAvatar) {
    _animationController.forward(from: 0);
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      )),
      child: FadeTransition(
        opacity: _animationController,
        child: MessageBubble(
          message: message,
          showAvatar: showAvatar,
        ),
      ),
    );
  }

  String _formatLastSeen(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'vừa xong';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} giờ trước';
    } else {
      return '${difference.inDays} ngày trước';
    }
  }
}

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool showAvatar;

  const MessageBubble({
    super.key,
    required this.message,
    this.showAvatar = false,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = message.senderId == context.read<ChatProvider>().currentUserId;
    final sender = context.read<ChatProvider>().getUserById(message.senderId);

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 4,
        bottom: showAvatar ? 12 : 4,
      ),
      child: Row(
        mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isCurrentUser && showAvatar) ...[
            CircleAvatar(
              radius: 16,
              backgroundImage: sender?.avatarUrl != null 
                  ? NetworkImage(sender!.avatarUrl!) 
                  : null,
              child: sender?.avatarUrl == null 
                  ? Text(sender?.name[0] ?? '') 
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          if (!isCurrentUser && !showAvatar)
            const SizedBox(width: 40),
          
          Flexible(
            child: Column(
              crossAxisAlignment: isCurrentUser 
                  ? CrossAxisAlignment.end 
                  : CrossAxisAlignment.start,
              children: [
                if (showAvatar && !isCurrentUser)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 4),
                    child: Text(
                      sender?.name ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                Container(
                  constraints: BoxConstraints(
                    maxWidth: message.type == MessageType.sticker
                        ? 40  // Kích thước nhỏ hơn cho emoji
                        : MediaQuery.of(context).size.width * 0.7,
                  ),
                  padding: message.type == MessageType.sticker
                      ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
                      : const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: message.type == MessageType.sticker
                        ? Colors.transparent
                        : isCurrentUser 
                            ? PhixTheme.primaryColor 
                            : Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: message.type == MessageType.sticker
                      ? Text(
                          message.content,  // Hiển thị emoji trực tiếp
                          style: const TextStyle(
                            fontSize: 30,  // Kích thước lớn cho emoji
                          ),
                        )
                      : Text(
                          message.content,
                          style: TextStyle(
                            color: isCurrentUser ? Colors.white : Colors.black,
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                  child: Text(
                    _formatTime(message.timestamp),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                ),
                if (isCurrentUser) ...[
                  Icon(
                    message.status == MessageStatus.sent
                        ? Icons.check
                        : message.status == MessageStatus.delivered
                            ? Icons.done_all
                            : Icons.done_all,
                    size: 16,
                    color: message.status == MessageStatus.read
                        ? Colors.blue
                        : Colors.grey,
                  ),
                  const SizedBox(width: 4),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class MessageInput extends StatefulWidget {
  final bool isGroup;
  final VoidCallback onSent;
  
  const MessageInput({
    super.key,
    required this.isGroup,
    required this.onSent,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isComposing = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final isComposing = _controller.text.isNotEmpty;
      if (isComposing != _isComposing) {
        setState(() => _isComposing = isComposing);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.emoji_emotions_outlined,
                color: PhixTheme.primaryColor,
              ),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => StickerPicker(
                    onStickerSelected: (stickerId) {
                      Navigator.pop(context);
                      if (widget.isGroup) {
                        context.read<ChatProvider>().sendGroupMessage(
                          stickerId,
                          type: MessageType.sticker,
                        );
                      } else {
                        context.read<ChatProvider>().sendMessage(
                          stickerId,
                          type: MessageType.sticker,
                        );
                      }
                      widget.onSent();
                    },
                  ),
                );
              },
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: widget.isGroup ? 'Nhắn tin đến nhóm...' : 'Nhắn tin...',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                minLines: 1,
                maxLines: 5,
                onSubmitted: _isComposing ? (_) => _handleSubmitted() : null,
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: IconButton(
                icon: Icon(
                  Icons.send_rounded,
                  color: _isComposing ? PhixTheme.primaryColor : Colors.grey,
                ),
                onPressed: _isComposing ? _handleSubmitted : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmitted() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    if (widget.isGroup) {
      context.read<ChatProvider>().sendGroupMessage(text);
    } else {
      context.read<ChatProvider>().sendMessage(text);
    }
    
    _controller.clear();
    widget.onSent();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}

// Widget hiển thị dấu chấm loading
class LoadingDots extends StatefulWidget {
  const LoadingDots({super.key});

  @override
  State<LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: _controller,
            curve: Interval(
              index * 0.3,
              (index + 1) * 0.3,
              curve: Curves.easeInOut,
            ),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 2),
            child: CircleAvatar(radius: 3),
          ),
        );
      }),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}