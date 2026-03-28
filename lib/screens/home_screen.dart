import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../models/match.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../theme/responsive.dart';
import '../widgets/match_card.dart';
import '../widgets/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<Match> _allMatches = [];
  bool _isLoading = true;
  String? _error;
  int _tabIndex = 0; // 0=Predict, 1=Schedule, 2=Entries

  String get _userName => AuthService.userName;
  String get _userEmail => AuthService.userEmail;
  String get _groupName => AuthService.groupName;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final matches = await ApiService.getAllMatches();
      if (mounted) {
        setState(() {
          _allMatches = matches;
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

  Match? get _nextPredictableMatch {
    for (int i = 0; i < _allMatches.length; i++) {
      final match = _allMatches[i];
      final prev = i > 0 ? _allMatches[i - 1] : null;
      if (match.statusInContext(prev) == MatchStatus.open) {
        return match;
      }
    }
    return null;
  }

  Match? _getPreviousMatch(Match match) {
    final idx = _allMatches.indexWhere((m) => m.matchId == match.matchId);
    if (idx <= 0) return null;
    return _allMatches[idx - 1];
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushNamed(context, '/my-predictions').then((_) {
          setState(() => _currentIndex = 0);
        });
        break;
      case 2:
        Navigator.pushNamed(context, '/leaderboard').then((_) {
          setState(() => _currentIndex = 0);
        });
        break;
      case 3:
        _showProfileSheet();
        setState(() => _currentIndex = 0);
        break;
    }
  }

  void _showProfileSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 32,
                backgroundColor: AppTheme.accentOrange.withAlpha(40),
                child: Text(
                  _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentOrange,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _userName,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                _userEmail,
                style: TextStyle(
                    color: Colors.white.withAlpha(120), fontSize: 13),
              ),
              const SizedBox(height: 20),
              if (AuthService.isAdmin)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.pushNamed(context, '/admin');
                      },
                      icon: const Icon(Icons.admin_panel_settings, size: 20),
                      label: const Text('Admin Panel', style: TextStyle(fontSize: 14)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.deepPurple,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await AuthService.signOut();
                    if (ctx.mounted) {
                      Navigator.of(ctx).pushNamedAndRemoveUntil(
                          '/login', (route) => false);
                    }
                  },
                  icon: const Icon(Icons.logout, color: Colors.redAccent, size: 20),
                  label: const Text('Logout',
                      style: TextStyle(color: Colors.redAccent, fontSize: 14)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPredictTab(double hPad) {
    final nextMatch = _nextPredictableMatch;

    if (nextMatch == null) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.hourglass_empty,
                  size: 56, color: Colors.white.withAlpha(50)),
              const SizedBox(height: 14),
              Text(
                'No match open for prediction',
                style: TextStyle(
                    color: Colors.white.withAlpha(140), fontSize: 15),
              ),
              const SizedBox(height: 6),
              Text(
                'Next match opens once the current one starts',
                style: TextStyle(
                    color: Colors.white.withAlpha(70), fontSize: 13),
              ),
              const SizedBox(height: 18),
              TextButton(
                onPressed: () => setState(() => _tabIndex = 1),
                child: const Text('View Schedule',
                    style: TextStyle(color: AppTheme.accentOrange)),
              ),
            ],
          ),
        ),
      );
    }

    final timeUntilLock = nextMatch.lockTime.difference(DateTime.now().toUtc());
    final hoursLeft = timeUntilLock.inHours;
    final minsLeft = timeUntilLock.inMinutes % 60;
    String countdown;
    if (hoursLeft > 24) {
      final days = (hoursLeft / 24).floor();
      countdown = '${days}d ${hoursLeft % 24}h left to predict';
    } else if (hoursLeft > 0) {
      countdown = '${hoursLeft}h ${minsLeft}m left to predict';
    } else {
      countdown = '${timeUntilLock.inMinutes}m left to predict';
    }

    return SliverToBoxAdapter(
      child: ResponsiveCenter(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad - 4),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.accentOrange.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.accentOrange.withAlpha(50)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.timer_outlined,
                        size: 16, color: AppTheme.accentOrange),
                    const SizedBox(width: 6),
                    Text(
                      countdown,
                      style: const TextStyle(
                        color: AppTheme.accentOrange,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(),
              const SizedBox(height: 12),
              MatchCard(
                match: nextMatch,
                matchStatus: MatchStatus.open,
                onPredict: () {
                  Navigator.pushNamed(
                    context,
                    '/predict',
                    arguments: {'match': nextMatch},
                  ).then((_) => _loadData());
                },
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.08),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleTab(double hPad) {
    if (_allMatches.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_today,
                  size: 56, color: Colors.white.withAlpha(50)),
              const SizedBox(height: 14),
              Text(
                'No matches found',
                style: TextStyle(
                    color: Colors.white.withAlpha(140), fontSize: 15),
              ),
            ],
          ),
        ),
      );
    }

    return SliverToBoxAdapter(
      child: ResponsiveCenter(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad - 4),
          child: Column(
            children: List.generate(_allMatches.length, (index) {
              final match = _allMatches[index];
              final prev = index > 0 ? _allMatches[index - 1] : null;
              final status = match.statusInContext(prev);

              return MatchCard(
                match: match,
                matchStatus: status,
                onPredict: () {
                  if (status == MatchStatus.open) {
                    Navigator.pushNamed(
                      context,
                      '/predict',
                      arguments: {'match': match},
                    ).then((_) => _loadData());
                  }
                },
              )
                  .animate()
                  .fadeIn(delay: Duration(milliseconds: 50 * (index < 10 ? index : 10)))
                  .slideY(begin: 0.06);
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildEntriesTab(double hPad) {
    final startedMatches =
        _allMatches.where((m) => m.hasStarted).toList().reversed.toList();

    if (startedMatches.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.people_outline,
                  size: 56, color: Colors.white.withAlpha(50)),
              const SizedBox(height: 14),
              Text(
                'No matches have started yet',
                style: TextStyle(
                    color: Colors.white.withAlpha(140), fontSize: 15),
              ),
              const SizedBox(height: 6),
              Text(
                'Entries become visible once a match begins',
                style: TextStyle(
                    color: Colors.white.withAlpha(70), fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return SliverToBoxAdapter(
      child: ResponsiveCenter(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad - 4),
          child: Column(
            children: List.generate(startedMatches.length, (index) {
              final match = startedMatches[index];
              return _EntriesMatchCard(
                match: match,
                onTap: () {
                  Navigator.pushNamed(context, '/match-entries',
                      arguments: {'match': match});
                },
              )
                  .animate()
                  .fadeIn(
                      delay: Duration(
                          milliseconds: 50 * (index < 10 ? index : 10)))
                  .slideY(begin: 0.06);
            }),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hPad = Responsive.horizontalPadding(context);

    return Scaffold(
      drawer: const AppDrawer(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: AppTheme.accentOrange,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: ResponsiveCenter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hey, ${_userName.split(' ').first}!',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: Responsive.fontSize(context, 24),
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Text(
                                    _tabIndex == 0
                                        ? 'Next Prediction'
                                        : _tabIndex == 1
                                            ? 'Match Schedule'
                                            : 'Group Entries',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: Colors.white54),
                                  ),
                                  if (_groupName.isNotEmpty) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppTheme.deepPurple.withAlpha(60),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        _groupName,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: AppTheme.accentOrange,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Scaffold.of(context).openDrawer(),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [AppTheme.accentOrange, AppTheme.deepPurple],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.accentOrange.withAlpha(50),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(10),
                              child: Icon(Icons.menu,
                                  color: Colors.white, size: 22),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms),
              ),
              SliverToBoxAdapter(
                child: ResponsiveCenter(
                  child: Padding(
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
                            child: _FilterChip(
                              label: 'Predict',
                              isSelected: _tabIndex == 0,
                              onTap: () => setState(() => _tabIndex = 0),
                            ),
                          ),
                          Expanded(
                            child: _FilterChip(
                              label: 'Schedule',
                              isSelected: _tabIndex == 1,
                              onTap: () => setState(() => _tabIndex = 1),
                            ),
                          ),
                          Expanded(
                            child: _FilterChip(
                              label: 'Entries',
                              isSelected: _tabIndex == 2,
                              onTap: () => setState(() => _tabIndex = 2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (_isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                        color: AppTheme.accentOrange),
                  ),
                )
              else if (_error != null)
                SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline,
                              size: 48, color: Colors.red.shade400),
                          const SizedBox(height: 12),
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.red.shade400),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadData,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else if (_tabIndex == 1)
                _buildScheduleTab(hPad)
              else if (_tabIndex == 2)
                _buildEntriesTab(hPad)
              else
                _buildPredictTab(hPad),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Predictions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard_outlined),
            activeIcon: Icon(Icons.leaderboard),
            label: 'Leaderboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _EntriesMatchCard extends StatelessWidget {
  final Match match;
  final VoidCallback onTap;

  const _EntriesMatchCard({required this.match, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM d, yyyy').format(match.startDateTime.toLocal());

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withAlpha(10)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.accentOrange.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '#${match.matchId}',
                style: const TextStyle(
                  color: AppTheme.accentOrange,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${match.team1} vs ${match.team2}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateStr,
                    style: TextStyle(
                      color: Colors.white.withAlpha(80),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: Colors.white38, size: 22),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentOrange.withAlpha(40) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.accentOrange.withAlpha(100) : Colors.transparent,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppTheme.accentOrange : Colors.white54,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
