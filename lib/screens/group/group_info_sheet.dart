import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../models/group.dart';
import '../../models/user.dart';

class GroupInfoSheet extends StatelessWidget {
  final Group group;

  const GroupInfoSheet({
    super.key,
    required this.group,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final members = group.memberIds
            .map((id) => chatProvider.getUserById(id))
            .where((user) => user != null)
            .cast<User>()
            .toList();
        final currentUser = chatProvider.getUserById(chatProvider.currentUserId!);
        final isAdmin = group.adminId == chatProvider.currentUserId;

        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      group.name[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${members.length} thành viên',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Text(
                    'Thành viên',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (isAdmin)
                    TextButton.icon(
                      icon: const Icon(Icons.person_add),
                      label: const Text('Thêm'),
                      onPressed: () {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (context) => AddMembersDialog(group: group),
                        );
                      },
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final member = members[index];
                    final isGroupAdmin = member.id == group.adminId;
                    
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: member.avatarUrl != null
                            ? NetworkImage(member.avatarUrl!)
                            : null,
                        child: member.avatarUrl == null
                            ? Text(member.name[0])
                            : null,
                      ),
                      title: Row(
                        children: [
                          Text(member.name),
                          if (isGroupAdmin)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Admin',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                      subtitle: Text(member.id == currentUser?.id ? 'Bạn' : ''),
                      trailing: isAdmin && !isGroupAdmin
                          ? PopupMenuButton(
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'remove',
                                  child: Text('Xóa khỏi nhóm'),
                                ),
                              ],
                              onSelected: (value) {
                                if (value == 'remove') {
                                  chatProvider.removeMemberFromGroup(
                                    group.id,
                                    member.id,
                                  );
                                  Navigator.pop(context);
                                }
                              },
                            )
                          : null,
                    );
                  },
                ),
              ),
              if (!isAdmin)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () {
                        chatProvider.leaveGroup(group.id);
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text('Rời nhóm'),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class AddMembersDialog extends StatefulWidget {
  final Group group;

  const AddMembersDialog({
    super.key,
    required this.group,
  });

  @override
  State<AddMembersDialog> createState() => _AddMembersDialogState();
}

class _AddMembersDialogState extends State<AddMembersDialog> {
  final Set<String> _selectedUsers = {};

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final availableUsers = chatProvider.allUsers
            .where((user) => !widget.group.memberIds.contains(user.id))
            .toList();

        return AlertDialog(
          title: const Text('Thêm thành viên'),
          content: SizedBox(
            width: double.maxFinite,
            child: availableUsers.isEmpty
                ? const Center(
                    child: Text('Không có người dùng khả dụng'),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: availableUsers.length,
                    itemBuilder: (context, index) {
                      final user = availableUsers[index];
                      return CheckboxListTile(
                        title: Text(user.name),
                        subtitle: Text(user.email),
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
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: _selectedUsers.isEmpty
                  ? null
                  : () {
                      chatProvider.addMembersToGroup(
                        widget.group.id,
                        _selectedUsers.toList(),
                      );
                      Navigator.pop(context);
                    },
              child: const Text('Thêm'),
            ),
          ],
        );
      },
    );
  }
} 