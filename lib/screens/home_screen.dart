import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/match.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../theme/responsive.dart';
import '../widgets/match_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<Match> _upcomingMatches = [];
  List<Match> _allMatches = [];
  bool _isLoading = true;
  String? _error;
  bool _showAll = false;

  String get _userName => AuthService.userName;
  String get _userEmail => AuthService.userEmail;

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
      final results = await Future.wait([
        ApiService.getActiveMatches(),
        ApiService.getAllMatches(),
      ]);
      if (mounted) {
        setState(() {
          _upcomingMatches = results[0];
          _allMatches = results[1];
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

  List<Match> get _displayedMatches => _showAll ? _allMatches : _upcomingMatches;

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

  @override
  Widget build(BuildContext context) {
    final hPad = Responsive.horizontalPadding(context);

    return Scaffold(
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
                              Text(
                                _showAll ? 'All Matches' : 'Upcoming Matches',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.white54),
                              ),
                            ],
                          ),
                        ),
                        Container(
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
                            child: Icon(Icons.sports_cricket,
                                color: Colors.white, size: 22),
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
                              label: 'Upcoming',
                              isSelected: !_showAll,
                              onTap: () => setState(() => _showAll = false),
                            ),
                          ),
                          Expanded(
                            child: _FilterChip(
                              label: 'All Matches',
                              isSelected: _showAll,
                              onTap: () => setState(() => _showAll = true),
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
              else if (_displayedMatches.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today,
                            size: 56, color: Colors.white.withAlpha(50)),
                        const SizedBox(height: 14),
                        Text(
                          _showAll ? 'No matches found' : 'No upcoming matches',
                          style: TextStyle(
                              color: Colors.white.withAlpha(140),
                              fontSize: 15),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Pull down to refresh',
                          style: TextStyle(
                              color: Colors.white.withAlpha(70), fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: ResponsiveCenter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: hPad - 4),
                      child: Column(
                        children: List.generate(_displayedMatches.length, (index) {
                          final match = _displayedMatches[index];
                          final isPast = match.startDateTime.isBefore(DateTime.now().toUtc());
                          return Opacity(
                            opacity: isPast && _showAll ? 0.55 : 1.0,
                            child: MatchCard(
                              match: match,
                              onPredict: () {
                                Navigator.pushNamed(
                                  context,
                                  '/predict',
                                  arguments: {'match': match},
                                ).then((_) => _loadData());
                              },
                            ),
                          )
                              .animate()
                              .fadeIn(
                                  delay: Duration(milliseconds: 80 * (index < 8 ? index : 8)))
                              .slideY(begin: 0.08);
                        }),
                      ),
                    ),
                  ),
                ),
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
