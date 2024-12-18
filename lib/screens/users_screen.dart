import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../models/friendship.dart';
import '../models/user.dart';
import 'chat/chat_room_screen.dart';
import '../theme/phix_theme.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: PhixTheme.backgroundColor,
        appBar: AppBar(
          title: const Text('Quản lý bạn bè'),
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: const [
              Tab(
                icon: Icon(Icons.people_outline),
                text: 'Tất cả',
              ),
              Tab(
                icon: Icon(Icons.group),
                text: 'Bạn bè',
              ),
              Tab(
                icon: Icon(Icons.person_add_alt),
                text: 'Lời mời',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _AllUsersTab(),
            _FriendsTab(),
            _FriendRequestsTab(),
          ],
        ),
      ),
    );
  }
}

class _AllUsersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final users = chatProvider.allUsers;
        
        if (users.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Không tìm thấy người dùng nào',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            final friendshipStatus = chatProvider.getFriendshipStatus(user.id);
            
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(8),
                leading: CircleAvatar(
                  radius: 24,
                  backgroundImage: user.avatarUrl != null
                      ? NetworkImage(user.avatarUrl!)
                      : null,
                  child: user.avatarUrl == null
                      ? Text(
                          user.name[0],
                          style: const TextStyle(fontSize: 20),
                        )
                      : null,
                ),
                title: Text(
                  user.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(user.email),
                trailing: _buildActionButton(context, chatProvider, user.id, friendshipStatus),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActionButton(BuildContext context, ChatProvider chatProvider, 
      String userId, FriendshipStatus? status) {
    switch (status) {
      case FriendshipStatus.pending:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Đã gửi lời mời',
            style: TextStyle(color: Colors.grey),
          ),
        );
      case FriendshipStatus.accepted:
        return ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: PhixTheme.errorColor.withOpacity(0.1),
            foregroundColor: PhixTheme.errorColor,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          icon: const Icon(Icons.person_remove),
          label: const Text('Hủy kết bạn'),
          onPressed: () => chatProvider.unfriend(userId),
        );
      case FriendshipStatus.declined:
        return ElevatedButton.icon(
          style: PhixTheme.primaryButton,
          icon: const Icon(Icons.refresh),
          label: const Text('Gửi lại'),
          onPressed: () => chatProvider.sendFriendRequest(userId),
        );
      default:
        return ElevatedButton.icon(
          style: PhixTheme.primaryButton,
          icon: const Icon(Icons.person_add),
          label: const Text('Kết bạn'),
          onPressed: () => chatProvider.sendFriendRequest(userId),
        );
    }
  }
}

class _FriendsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final friends = chatProvider.friends;
        
        if (friends.isEmpty) {
          return const Center(
            child: Text('Chưa có bạn bè nào'),
          );
        }
        
        return ListView.builder(
          itemCount: friends.length,
          itemBuilder: (context, index) {
            final friend = friends[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: friend.avatarUrl != null 
                    ? NetworkImage(friend.avatarUrl!) 
                    : null,
                child: friend.avatarUrl == null ? Text(friend.name[0]) : null,
              ),
              title: Text(friend.name),
              trailing: ElevatedButton(
                onPressed: () => chatProvider.unfriend(friend.id),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Hủy kết bạn'),
              ),
              onTap: () {
                chatProvider.selectUser(friend.id);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatRoomScreen(user: friend),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _FriendRequestsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final requests = chatProvider.friendRequests;
        
        if (requests.isEmpty) {
          return const Center(
            child: Text('Không có lời mời kết bạn nào'),
          );
        }
        
        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final user = requests[index];
            
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: user.avatarUrl != null 
                    ? NetworkImage(user.avatarUrl!) 
                    : null,
                child: user.avatarUrl == null ? Text(user.name[0]) : null,
              ),
              title: Text(user.name),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () => chatProvider.acceptFriendRequest(user.id),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => chatProvider.declineFriendRequest(user.id),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
} 