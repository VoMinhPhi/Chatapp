import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../models/user.dart';
import '../models/message.dart';
import '../models/group.dart';
import 'group/group_info_sheet.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group?.name ?? widget.user!.name),
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
        actions: [
          if (widget.group != null)
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showGroupInfo(context, widget.group!),
            ),
        ],
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
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isCurrentUser 
                        ? Colors.blue 
                        : Colors.grey[200],
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(
                        isCurrentUser || !showAvatar ? 20 : 4,
                      ),
                      bottomRight: Radius.circular(
                        isCurrentUser && !showAvatar ? 4 : 20,
                      ),
                    ),
                  ),
                  child: Text(
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
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Nhập tin nhắn...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  Icons.send,
                  color: _isComposing ? Colors.blue : Colors.grey,
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