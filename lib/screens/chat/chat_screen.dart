import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../theme/phix_theme.dart';
import '../users_screen.dart';
import '../group_screen.dart';
import 'chat_room_screen.dart';
import '../profile/edit_profile_screen.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ChatProvider, AuthProvider>(
      builder: (context, chatProvider, authProvider, child) {
        final currentUser = authProvider.currentUser;
        if (currentUser == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: PhixTheme.primaryColor,
              ),
            ),
          );
        }
        
        return Scaffold(
          backgroundColor: PhixTheme.backgroundColor,
          appBar: AppBar(
            title: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white,
                  child: Text(
                    'P',
                    style: TextStyle(
                      color: PhixTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text('PhiX Chat'),
              ],
            ),
            actions: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.person_add_rounded),
                  tooltip: 'Thêm bạn',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const UsersScreen()),
                    );
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.group_add_rounded),
                  tooltip: 'Tạo nhóm',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const GroupScreen()),
                    );
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 4, right: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: PopupMenuButton<String>(
                  icon: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.white,
                    backgroundImage: currentUser.avatarUrl != null
                        ? NetworkImage(currentUser.avatarUrl!)
                        : null,
                    child: currentUser.avatarUrl == null
                        ? Text(
                            currentUser.name[0],
                            style: TextStyle(
                              color: PhixTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  offset: const Offset(0, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  itemBuilder: (context) => <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      enabled: false,
                      height: 70,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundImage: currentUser.avatarUrl != null
                                ? NetworkImage(currentUser.avatarUrl!)
                                : null,
                            child: currentUser.avatarUrl == null
                                ? Text(
                                    currentUser.name[0],
                                    style: const TextStyle(fontSize: 20),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  currentUser.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  currentUser.email,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem<String>(
                      value: 'edit_profile',
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: PhixTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.edit,
                              color: PhixTheme.primaryColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text('Chỉnh sửa hồ sơ'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem<String>(
                      value: 'logout',
                      height: 48,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: PhixTheme.errorColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.logout_rounded,
                              color: PhixTheme.errorColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Đăng xuất',
                            style: TextStyle(
                              color: PhixTheme.errorColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case 'edit_profile':
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfileScreen(),
                          ),
                        );
                        break;
                      case 'logout':
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Row(
                              children: [
                                Icon(
                                  Icons.logout_rounded,
                                  color: PhixTheme.errorColor,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                const Text('Đăng xuất'),
                              ],
                            ),
                            content: const Text(
                              'Bạn có chắc muốn đăng xuất khỏi tài khoản này?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Hủy'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  authProvider.logout();
                                  chatProvider.reset();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: PhixTheme.errorColor,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Đăng xuất'),
                              ),
                            ],
                          ),
                        );
                        break;
                    }
                  },
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // Thanh tìm kiếm
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: PhixTheme.inputDecoration('Tìm kiếm')
                      .copyWith(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Tìm kiếm bạn bè hoặc nhóm chat...',
                      ),
                ),
              ),

              // Danh sách chat
              Expanded(
                child: Consumer<ChatProvider>(
                  builder: (context, chatProvider, child) {
                    final friends = chatProvider.users;
                    final groups = chatProvider.groups;
                    
                    if (friends.isEmpty && groups.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Chưa có cuộc trò chuyện nào',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              style: PhixTheme.primaryButton,
                              icon: const Icon(Icons.person_add),
                              label: const Text('Thêm bạn'),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const UsersScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView(
                      children: [
                        if (groups.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Text(
                              'Nhóm',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                          ...groups.map((group) => ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade100,
                              child: Text(group.name[0]),
                            ),
                            title: Text(group.name),
                            subtitle: Text(
                              '${group.memberIds.length} thành viên',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                              ),
                            ),
                            onTap: () {
                              chatProvider.selectGroup(group.id);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatRoomScreen(
                                    group: group,
                                  ),
                                ),
                              );
                            },
                          )),
                        ],

                        if (friends.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Text(
                              'Bạn bè',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                          ...friends.map((friend) => ListTile(
                            leading: CircleAvatar(
                              backgroundImage: friend.avatarUrl != null
                                  ? NetworkImage(friend.avatarUrl!)
                                  : null,
                              child: friend.avatarUrl == null
                                  ? Text(friend.name[0])
                                  : null,
                            ),
                            title: Text(friend.name),
                            subtitle: const Text('Nhấn để bắt đầu chat'),
                            onTap: () {
                              chatProvider.selectUser(friend.id);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatRoomScreen(
                                    user: friend,
                                  ),
                                ),
                              );
                            },
                          )),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: PhixTheme.primaryColor,
            icon: const Icon(Icons.chat_rounded),
            label: const Text('Chat mới'),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: PhixTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.person_add_rounded,
                          color: PhixTheme.primaryColor,
                        ),
                      ),
                      title: const Text('Thêm bạn'),
                      subtitle: const Text('Tìm và kết bạn với người dùng mới'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UsersScreen(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: PhixTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.group_add_rounded,
                          color: PhixTheme.primaryColor,
                        ),
                      ),
                      title: const Text('Tạo nhóm mới'),
                      subtitle: const Text('Tạo nhóm chat với nhiều người'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GroupScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
} 