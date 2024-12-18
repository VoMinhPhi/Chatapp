import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../models/group.dart';
import 'chat/chat_room_screen.dart';
import '../theme/phix_theme.dart';

class GroupScreen extends StatelessWidget {
  const GroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: PhixTheme.backgroundColor,
        appBar: AppBar(
          title: const Text('Nhóm chat'),
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: const [
              Tab(
                icon: Icon(Icons.groups),
                text: 'Nhóm của tôi',
              ),
              Tab(
                icon: Icon(Icons.group_add),
                text: 'Tạo nhóm mới',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _MyGroupsTab(),
            _CreateGroupTab(),
          ],
        ),
      ),
    );
  }
}

class _MyGroupsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final groups = chatProvider.groups;
        
        if (groups.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.group_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Bạn chưa tham gia nhóm nào',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  style: PhixTheme.primaryButton,
                  icon: const Icon(Icons.group_add),
                  label: const Text('Tạo nhóm mới'),
                  onPressed: () {
                    DefaultTabController.of(context)?.animateTo(1);
                  },
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final group = groups[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(8),
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    group.name[0],
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.blue.shade900,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  group.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text('${group.memberIds.length} thành viên'),
                trailing: PopupMenuButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.more_vert),
                  ),
                  itemBuilder: (context) => [
                    if (group.adminId == chatProvider.currentUserId)
                      PopupMenuItem(
                        child: Row(
                          children: [
                            Icon(
                              Icons.person_add,
                              color: PhixTheme.primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            const Text('Thêm thành viên'),
                          ],
                        ),
                        value: 'add_members',
                      ),
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(
                            Icons.exit_to_app,
                            color: group.adminId == chatProvider.currentUserId
                                ? PhixTheme.errorColor
                                : Colors.orange,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            group.adminId == chatProvider.currentUserId
                                ? 'Xóa nhóm'
                                : 'Rời nhóm',
                          ),
                        ],
                      ),
                      value: 'leave',
                    ),
                  ],
                  onSelected: (value) async {
                    if (value == 'add_members') {
                      await _showAddMembersDialog(context, group);
                    } else if (value == 'leave') {
                      await chatProvider.leaveGroup(group.id);
                    }
                  },
                ),
                onTap: () {
                  chatProvider.selectGroup(group.id);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatRoomScreen(group: group),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showAddMembersDialog(BuildContext context, Group group) async {
    final chatProvider = context.read<ChatProvider>();
    final allUsers = chatProvider.allUsers
        .where((user) => !group.memberIds.contains(user.id))
        .toList();
    
    final selectedUsers = <String>[];
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm thành viên'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: allUsers.length,
            itemBuilder: (context, index) {
              final user = allUsers[index];
              return CheckboxListTile(
                title: Text(user.name),
                value: selectedUsers.contains(user.id),
                onChanged: (checked) {
                  if (checked == true) {
                    selectedUsers.add(user.id);
                  } else {
                    selectedUsers.remove(user.id);
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              chatProvider.addMembersToGroup(group.id, selectedUsers);
              Navigator.pop(context);
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }
}

class _CreateGroupTab extends StatefulWidget {
  @override
  State<_CreateGroupTab> createState() => _CreateGroupTabState();
}

class _CreateGroupTabState extends State<_CreateGroupTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _selectedUsers = <String>[];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blue.shade100,
                    child: Icon(
                      Icons.group,
                      size: 40,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: PhixTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: PhixTheme.inputDecoration('Tên nhóm').copyWith(
                prefixIcon: const Icon(Icons.group),
                hintText: 'Nhập tên nhóm...',
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập tên nhóm';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Chọn thành viên',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                final users = chatProvider.allUsers;
                return Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: users.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return CheckboxListTile(
                        title: Text(user.name),
                        subtitle: Text(user.email),
                        secondary: CircleAvatar(
                          backgroundImage: user.avatarUrl != null
                              ? NetworkImage(user.avatarUrl!)
                              : null,
                          child: user.avatarUrl == null
                              ? Text(user.name[0])
                              : null,
                        ),
                        value: _selectedUsers.contains(user.id),
                        onChanged: (checked) {
                          setState(() {
                            if (checked == true) {
                              _selectedUsers.add(user.id);
                            } else {
                              _selectedUsers.remove(user.id);
                            }
                          });
                        },
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: PhixTheme.primaryButton,
              icon: const Icon(Icons.group_add),
              label: const Text('Tạo nhóm'),
              onPressed: _selectedUsers.isEmpty
                  ? null
                  : () {
                      if (_formKey.currentState!.validate()) {
                        context.read<ChatProvider>().createGroup(
                          _nameController.text,
                          _selectedUsers,
                        );
                        Navigator.pop(context);
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }
} 