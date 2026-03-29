import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/leaderboard_entry.dart';
import '../models/match.dart';
import '../models/group.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../theme/responsive.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  List<LeaderboardEntry> _entries = [];
  List<Map<String, dynamic>> _details = [];
  List<Map<String, dynamic>> _breakdown = [];
  List<Group> _groups = [];
  List<Match> _allMatches = [];
  String? _selectedGroupId;
  String _selectedGroupName = '';
  String? _breakdownMatchId;
  bool _isLoading = true;
  bool _isDetailsLoading = true;
  bool _isBreakdownLoading = false;
  String? _error;
  late TabController _tabController;

  bool get _isAdmin => AuthService.isAdmin;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedGroupId = AuthService.groupId;
    _selectedGroupName = AuthService.groupName;
    _init();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    if (_isAdmin) {
      try {
        final groups = await ApiService.getAllGroups();
        if (mounted) setState(() => _groups = groups);
      } catch (_) {}
    }
    try {
      final matches = await ApiService.getAllMatches();
      if (mounted) setState(() => _allMatches = matches);
    } catch (_) {}
    await Future.wait([_loadLeaderboard(), _loadDetails()]);
  }

  Future<void> _loadLeaderboard() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final entries =
          await ApiService.getLeaderboard(groupId: _selectedGroupId);
      entries.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));
      if (mounted) {
        setState(() {
          _entries = entries;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadDetails() async {
    setState(() => _isDetailsLoading = true);
    try {
      final details =
          await ApiService.getLeaderboardDetails(groupId: _selectedGroupId);
      if (mounted) {
        setState(() {
          _details = details;
          _isDetailsLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isDetailsLoading = false);
    }
  }

  Future<void> _loadBreakdown() async {
    if (_breakdownMatchId == null) return;
    setState(() => _isBreakdownLoading = true);
    try {
      final data = await ApiService.getMatchBreakdown(
        _breakdownMatchId!,
        groupId: _selectedGroupId,
      );
      if (mounted) {
        setState(() {
          _breakdown = data;
          _isBreakdownLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isBreakdownLoading = false);
    }
  }

  void _onGroupChanged(Group group) {
    setState(() {
      _selectedGroupId = group.id;
      _selectedGroupName = group.name;
    });
    _loadLeaderboard();
    _loadDetails();
    if (_breakdownMatchId != null) _loadBreakdown();
  }

  Future<void> _refresh() async {
    await Future.wait([_loadLeaderboard(), _loadDetails()]);
    if (_breakdownMatchId != null) _loadBreakdown();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(_selectedGroupName.isNotEmpty
            ? '$_selectedGroupName Leaderboard'
            : 'Leaderboard'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accentOrange,
          labelColor: AppTheme.accentOrange,
          unselectedLabelColor: Colors.white54,
          labelStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Standings'),
            Tab(text: 'Points Split'),
            Tab(text: 'Match Detail'),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_isAdmin && _groups.length > 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(10),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(3),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _groups.map((group) {
                      final isSelected = group.id == _selectedGroupId;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: GestureDetector(
                          onTap: () => _onGroupChanged(group),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.accentOrange.withAlpha(40)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.accentOrange.withAlpha(100)
                                    : Colors.transparent,
                              ),
                            ),
                            child: Text(
                              group.name,
                              style: TextStyle(
                                color: isSelected
                                    ? AppTheme.accentOrange
                                    : Colors.white54,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildStandingsTab(),
                _buildPointsSplitTab(),
                _buildMatchBreakdownTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStandingsTab() {
    final hPad = Responsive.horizontalPadding(context);

    return RefreshIndicator(
      onRefresh: _refresh,
      color: AppTheme.accentOrange,
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.accentOrange))
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline,
                            size: 48, color: Colors.red.shade400),
                        const SizedBox(height: 12),
                        Text(_error!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.red.shade400)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadLeaderboard,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : _entries.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.leaderboard_outlined,
                              size: 56, color: Colors.white.withAlpha(50)),
                          const SizedBox(height: 14),
                          Text(
                            'No scores yet',
                            style: TextStyle(
                                color: Colors.white.withAlpha(140),
                                fontSize: 15),
                          ),
                        ],
                      ),
                    )
                  : CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        if (_entries.length >= 3)
                          SliverToBoxAdapter(
                            child: ResponsiveCenter(
                              child: _TopThree(entries: _entries)
                                  .animate()
                                  .fadeIn(duration: 500.ms),
                            ),
                          ),
                        SliverToBoxAdapter(
                          child: ResponsiveCenter(
                            padding: EdgeInsets.symmetric(
                              horizontal: hPad,
                              vertical: 8,
                            ),
                            child: Column(
                              children: List.generate(
                                _entries.length >= 3
                                    ? _entries.length - 3
                                    : _entries.length,
                                (index) {
                                  final startIdx =
                                      _entries.length >= 3 ? 3 : 0;
                                  final actualIdx = startIdx + index;
                                  return _LeaderboardRow(
                                    rank: actualIdx + 1,
                                    entry: _entries[actualIdx],
                                  )
                                      .animate()
                                      .fadeIn(
                                          delay: Duration(
                                              milliseconds: 80 * index))
                                      .slideX(begin: 0.04);
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildPointsSplitTab() {
    if (_isDetailsLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.accentOrange));
    }

    if (_details.isEmpty) {
      return Center(
        child: Text(
          'No points data yet',
          style: TextStyle(color: Colors.white.withAlpha(140), fontSize: 15),
        ),
      );
    }

    final matchIds = <String>{};
    final userMap = <String, Map<String, int>>{};
    final userTotals = <String, int>{};

    for (final row in _details) {
      final name = row['user_name'] as String? ?? '';
      final matchId = row['match_id'] as String? ?? '';
      final pts = (row['points'] as num?)?.toInt() ?? 0;

      matchIds.add(matchId);
      userMap.putIfAbsent(name, () => {});
      userMap[name]![matchId] = pts;
      userTotals[name] = (userTotals[name] ?? 0) + pts;
    }

    final sortedMatchIds = matchIds.toList()
      ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));
    final sortedUsers = userTotals.keys.toList()
      ..sort((a, b) => (userTotals[b] ?? 0).compareTo(userTotals[a] ?? 0));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor:
              WidgetStateProperty.all(AppTheme.deepPurple.withAlpha(40)),
          dataRowColor: WidgetStateProperty.all(AppTheme.cardDark),
          border: TableBorder.all(
            color: Colors.white.withAlpha(15),
            borderRadius: BorderRadius.circular(10),
          ),
          columnSpacing: 14,
          horizontalMargin: 12,
          headingRowHeight: 44,
          dataRowMinHeight: 38,
          dataRowMaxHeight: 44,
          columns: [
            const DataColumn(
              label: Text('Name',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppTheme.accentOrange)),
            ),
            ...sortedMatchIds.map((id) => DataColumn(
                  label: Text('M$id',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: AppTheme.accentOrange)),
                )),
            const DataColumn(
              label: Text('Total',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppTheme.gold)),
            ),
          ],
          rows: sortedUsers.asMap().entries.map((e) {
            final i = e.key;
            final name = e.value;
            final total = userTotals[name] ?? 0;

            return DataRow(
              color: WidgetStateProperty.all(
                i.isEven ? AppTheme.cardDark : AppTheme.surfaceDark,
              ),
              cells: [
                DataCell(SizedBox(
                  width: 100,
                  child: Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 12),
                      overflow: TextOverflow.ellipsis),
                )),
                ...sortedMatchIds.map((mid) {
                  final pts = userMap[name]?[mid] ?? 0;
                  return DataCell(Text(
                    pts > 0 ? '$pts' : '-',
                    style: TextStyle(
                      fontSize: 12,
                      color: pts > 0 ? Colors.white : Colors.white30,
                      fontWeight:
                          pts > 0 ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ));
                }),
                DataCell(Text(
                  '$total',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: total > 0 ? AppTheme.gold : Colors.white54,
                  ),
                )),
              ],
            );
          }).toList(),
        ),
      ).animate().fadeIn(),
    );
  }

  Widget _buildMatchBreakdownTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withAlpha(15)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _breakdownMatchId,
                hint: const Text('Select a match',
                    style: TextStyle(color: Colors.white54, fontSize: 14)),
                dropdownColor: AppTheme.cardDark,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down,
                    color: AppTheme.accentOrange),
                items: _allMatches.map((m) {
                  return DropdownMenuItem<String>(
                    value: m.matchId,
                    child: Text(
                      'M${m.matchId}: ${m.team1} vs ${m.team2}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() => _breakdownMatchId = val);
                  _loadBreakdown();
                },
              ),
            ),
          ),
        ),
        Expanded(
          child: _breakdownMatchId == null
              ? Center(
                  child: Text(
                    'Select a match to view points breakdown',
                    style: TextStyle(
                        color: Colors.white.withAlpha(100), fontSize: 14),
                  ),
                )
              : _isBreakdownLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.accentOrange))
                  : _breakdown.isEmpty
                      ? Center(
                          child: Text(
                            'No scored predictions for this match',
                            style: TextStyle(
                                color: Colors.white.withAlpha(100),
                                fontSize: 14),
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.all(
                                  AppTheme.deepPurple.withAlpha(40)),
                              dataRowColor: WidgetStateProperty.all(
                                  AppTheme.cardDark),
                              border: TableBorder.all(
                                color: Colors.white.withAlpha(15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              columnSpacing: 12,
                              horizontalMargin: 10,
                              headingRowHeight: 44,
                              dataRowMinHeight: 38,
                              dataRowMaxHeight: 44,
                              columns: const [
                                DataColumn(
                                    label: Text('Name',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                            color: AppTheme.accentOrange))),
                                DataColumn(
                                    label: Text('Toss',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                            color: AppTheme.accentOrange))),
                                DataColumn(
                                    label: Text('Winner',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                            color: AppTheme.accentOrange))),
                                DataColumn(
                                    label: Text('Score',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                            color: AppTheme.accentOrange))),
                                DataColumn(
                                    label: Text('HS',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                            color: AppTheme.accentOrange))),
                                DataColumn(
                                    label: Text('Wkts',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                            color: AppTheme.accentOrange))),
                                DataColumn(
                                    label: Text('MOM',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                            color: AppTheme.accentOrange))),
                                DataColumn(
                                    label: Text('Bonus',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                            color: AppTheme.accentOrange))),
                                DataColumn(
                                    label: Text('Total',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                            color: AppTheme.gold))),
                              ],
                              rows: _breakdown.asMap().entries.map((e) {
                                final i = e.key;
                                final row = e.value;
                                return DataRow(
                                  color: WidgetStateProperty.all(
                                    i.isEven
                                        ? AppTheme.cardDark
                                        : AppTheme.surfaceDark,
                                  ),
                                  cells: [
                                    DataCell(SizedBox(
                                      width: 90,
                                      child: Text(
                                        row['user_name'] ?? '-',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 11),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )),
                                    _ptsCell(row['toss_pts']),
                                    _ptsCell(row['winner_pts']),
                                    _ptsCell(row['score_pts']),
                                    _ptsCell(row['hs_pts']),
                                    _ptsCell(row['wickets_pts']),
                                    _ptsCell(row['mom_pts']),
                                    _ptsCell(row['bonus_pts']),
                                    DataCell(Text(
                                      '${row['total_pts'] ?? 0}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: (row['total_pts'] ?? 0) > 0
                                            ? AppTheme.gold
                                            : Colors.white54,
                                      ),
                                    )),
                                  ],
                                );
                              }).toList(),
                            ),
                          ).animate().fadeIn(),
                        ),
        ),
      ],
    );
  }

  DataCell _ptsCell(dynamic value) {
    final pts = (value as num?)?.toInt() ?? 0;
    return DataCell(Text(
      pts > 0 ? '$pts' : '-',
      style: TextStyle(
        fontSize: 12,
        color: pts > 0 ? Colors.greenAccent : Colors.white30,
        fontWeight: pts > 0 ? FontWeight.w600 : FontWeight.normal,
      ),
    ));
  }
}

class _TopThree extends StatelessWidget {
  final List<LeaderboardEntry> entries;

  const _TopThree({required this.entries});

  @override
  Widget build(BuildContext context) {
    final isCompact = Responsive.isNarrowMobile(context);
    final podiumWidth = isCompact ? 70.0 : 80.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (entries.length > 1)
            _PodiumItem(
              rank: 2,
              entry: entries[1],
              height: isCompact ? 80 : 100,
              width: podiumWidth,
              color: const Color(0xFFC0C0C0),
            ),
          _PodiumItem(
            rank: 1,
            entry: entries[0],
            height: isCompact ? 105 : 130,
            width: podiumWidth,
            color: AppTheme.gold,
          ),
          if (entries.length > 2)
            _PodiumItem(
              rank: 3,
              entry: entries[2],
              height: isCompact ? 65 : 80,
              width: podiumWidth,
              color: const Color(0xFFCD7F32),
            ),
        ],
      ),
    );
  }
}

class _PodiumItem extends StatelessWidget {
  final int rank;
  final LeaderboardEntry entry;
  final double height;
  final double width;
  final Color color;

  const _PodiumItem({
    required this.rank,
    required this.entry,
    required this.height,
    required this.width,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final avatarRadius = rank == 1 ? 26.0 : 22.0;
    final nameFontSize = rank == 1 ? 13.0 : 12.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: avatarRadius,
          backgroundColor: color.withAlpha(45),
          child: Text(
            entry.name.isNotEmpty ? entry.name[0].toUpperCase() : '?',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: rank == 1 ? 20 : 17,
            ),
          ),
        ),
        const SizedBox(height: 5),
        SizedBox(
          width: width,
          child: Text(
            entry.name,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: nameFontSize,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${entry.totalPoints} pts',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color.withAlpha(70), color.withAlpha(25)],
            ),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
            ),
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final int rank;
  final LeaderboardEntry entry;

  const _LeaderboardRow({required this.rank, required this.entry});

  @override
  Widget build(BuildContext context) {
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
              '#$rank',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.white.withAlpha(100),
              ),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.deepPurple.withAlpha(50),
            child: Text(
              entry.name.isNotEmpty ? entry.name[0].toUpperCase() : '?',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              entry.name,
              style: const TextStyle(
                  fontWeight: FontWeight.w500, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${entry.totalPoints}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.accentOrange,
              fontSize: 15,
            ),
          ),
          Text(
            ' pts',
            style: TextStyle(
              color: Colors.white.withAlpha(80),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
