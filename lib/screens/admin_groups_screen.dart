import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/group.dart';
import '../models/leaderboard_entry.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../theme/responsive.dart';

class AdminGroupsScreen extends StatefulWidget {
  const AdminGroupsScreen({super.key});

  @override
  State<AdminGroupsScreen> createState() => _AdminGroupsScreenState();
}

class _AdminGroupsScreenState extends State<AdminGroupsScreen> {
  List<GroupStats> _groups = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final groups = await ApiService.getGroupStats();
      if (mounted) setState(() { _groups = groups; _isLoading = false; });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red.shade700),
        );
      }
    }
  }

  void _showCreateGroupDialog() {
    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Create Group', style: TextStyle(fontSize: 18)),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Group Name',
                  hintText: 'e.g. Office League',
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter a name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: codeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Group Code',
                  hintText: 'e.g. OFFICE2026',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter a code';
                  if (v.trim().length < 3) return 'Code must be 3+ characters';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              try {
                await ApiService.createGroup(
                  name: nameCtrl.text.trim(),
                  code: codeCtrl.text.trim(),
                );
                if (ctx.mounted) Navigator.pop(ctx);
                _loadData();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Group "${nameCtrl.text.trim()}" created!'),
                      backgroundColor: Colors.green.shade700,
                    ),
                  );
                }
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(
                      content: Text(e.toString().contains('duplicate')
                          ? 'Code already exists'
                          : e.toString()),
                      backgroundColor: Colors.red.shade700,
                    ),
                  );
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showGroupDetail(GroupStats group) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _GroupDetailScreen(group: group),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hPad = Responsive.horizontalPadding(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Groups Dashboard'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateGroupDialog,
        backgroundColor: AppTheme.accentOrange,
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppTheme.accentOrange,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.accentOrange))
            : _groups.isEmpty
                ? const Center(child: Text('No groups yet'))
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 8),
                    itemCount: _groups.length,
                    itemBuilder: (context, index) {
                      final group = _groups[index];
                      return ResponsiveCenter(
                        child: _GroupCard(
                          group: group,
                          onTap: () => _showGroupDetail(group),
                        )
                            .animate()
                            .fadeIn(delay: Duration(milliseconds: 60 * index))
                            .slideY(begin: 0.05),
                      );
                    },
                  ),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final GroupStats group;
  final VoidCallback onTap;

  const _GroupCard({required this.group, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withAlpha(10)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.deepPurple.withAlpha(40),
                  ),
                  child: Center(
                    child: Icon(Icons.group, color: AppTheme.accentOrange, size: 22),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.groupName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppTheme.accentOrange.withAlpha(20),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Code: ${group.groupCode}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.accentOrange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${group.memberCount}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppTheme.accentOrange,
                      ),
                    ),
                    Text(
                      'members',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withAlpha(80),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, color: Colors.white.withAlpha(60), size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GroupDetailScreen extends StatefulWidget {
  final GroupStats group;
  const _GroupDetailScreen({required this.group});

  @override
  State<_GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<_GroupDetailScreen> {
  List<Map<String, dynamic>> _members = [];
  List<LeaderboardEntry> _leaderboard = [];
  bool _isLoading = true;
  bool _showLeaderboard = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        ApiService.getGroupMembers(widget.group.groupId),
        ApiService.getLeaderboard(groupId: widget.group.groupId),
      ]);
      if (mounted) {
        setState(() {
          _members = results[0] as List<Map<String, dynamic>>;
          _leaderboard = results[1] as List<LeaderboardEntry>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hPad = Responsive.horizontalPadding(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.group.groupName),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.accentOrange))
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 8),
                  child: Row(
                    children: [
                      _StatChip(
                          label: 'Code', value: widget.group.groupCode),
                      const SizedBox(width: 10),
                      _StatChip(
                          label: 'Members',
                          value: '${_members.length}'),
                      const SizedBox(width: 10),
                      _StatChip(
                          label: 'Predictions',
                          value: '${widget.group.predictionCount}'),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 4),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _showLeaderboard = true),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: _showLeaderboard
                                    ? AppTheme.accentOrange.withAlpha(40)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  'Leaderboard',
                                  style: TextStyle(
                                    color: _showLeaderboard
                                        ? AppTheme.accentOrange
                                        : Colors.white54,
                                    fontWeight: _showLeaderboard
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _showLeaderboard = false),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: !_showLeaderboard
                                    ? AppTheme.accentOrange.withAlpha(40)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  'Members',
                                  style: TextStyle(
                                    color: !_showLeaderboard
                                        ? AppTheme.accentOrange
                                        : Colors.white54,
                                    fontWeight: !_showLeaderboard
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: _showLeaderboard
                      ? _buildLeaderboard(hPad)
                      : _buildMembers(hPad),
                ),
              ],
            ),
    );
  }

  Widget _buildLeaderboard(double hPad) {
    if (_leaderboard.isEmpty) {
      return Center(
        child: Text('No scores yet',
            style: TextStyle(color: Colors.white.withAlpha(120))),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 4),
      itemCount: _leaderboard.length,
      itemBuilder: (_, i) {
        final entry = _leaderboard[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.cardDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withAlpha(8)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 30,
                child: Text(
                  '#${i + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: i < 3
                        ? AppTheme.accentOrange
                        : Colors.white.withAlpha(100),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.deepPurple.withAlpha(50),
                child: Text(
                  entry.name.isNotEmpty ? entry.name[0].toUpperCase() : '?',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(entry.name,
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                    overflow: TextOverflow.ellipsis),
              ),
              Text('${entry.totalPoints}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentOrange,
                      fontSize: 15)),
              Text(' pts',
                  style: TextStyle(
                      color: Colors.white.withAlpha(80), fontSize: 11)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMembers(double hPad) {
    if (_members.isEmpty) {
      return Center(
        child: Text('No members yet',
            style: TextStyle(color: Colors.white.withAlpha(120))),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 4),
      itemCount: _members.length,
      itemBuilder: (_, i) {
        final m = _members[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.cardDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withAlpha(8)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.deepPurple.withAlpha(50),
                child: Text(
                  (m['name'] ?? '?')[0].toString().toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(m['name'] ?? '',
                        style: const TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 14)),
                    Text(m['email'] ?? '',
                        style: TextStyle(
                            color: Colors.white.withAlpha(80), fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppTheme.accentOrange)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    fontSize: 10, color: Colors.white.withAlpha(80))),
          ],
        ),
      ),
    );
  }
}
