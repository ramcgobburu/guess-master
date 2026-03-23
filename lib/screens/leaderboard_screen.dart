import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/leaderboard_entry.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../theme/responsive.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<LeaderboardEntry> _entries = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final entries = await ApiService.getLeaderboard();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Leaderboard'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadLeaderboard,
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
                                size: 56,
                                color: Colors.white.withAlpha(50)),
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
                                horizontal:
                                    Responsive.horizontalPadding(context),
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
      ),
    );
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
