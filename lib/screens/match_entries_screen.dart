import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/match.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../theme/responsive.dart';

class MatchEntriesScreen extends StatefulWidget {
  const MatchEntriesScreen({super.key});

  @override
  State<MatchEntriesScreen> createState() => _MatchEntriesScreenState();
}

class _MatchEntriesScreenState extends State<MatchEntriesScreen> {
  List<Map<String, dynamic>> _entries = [];
  bool _isLoading = true;
  String? _error;
  Match? _match;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_match == null) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      _match = args?['match'] as Match?;
      if (_match != null) _loadEntries();
    }
  }

  Future<void> _loadEntries() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final entries = await ApiService.getMatchEntries(_match!.matchId);
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
    final hPad = Responsive.horizontalPadding(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(_match != null
            ? 'Match ${_match!.matchId}: ${_match!.team1} vs ${_match!.team2}'
            : 'Match Entries'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadEntries,
        color: AppTheme.accentOrange,
        child: _isLoading
            ? const Center(
                child:
                    CircularProgressIndicator(color: AppTheme.accentOrange))
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
                            onPressed: _loadEntries,
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
                            Icon(Icons.people_outline,
                                size: 56,
                                color: Colors.white.withAlpha(50)),
                            const SizedBox(height: 14),
                            Text(
                              'No entries yet',
                              style: TextStyle(
                                  color: Colors.white.withAlpha(140),
                                  fontSize: 15),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Entries are visible after the match starts',
                              style: TextStyle(
                                  color: Colors.white.withAlpha(70),
                                  fontSize: 13),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(
                            horizontal: hPad, vertical: 8),
                        itemCount: _entries.length,
                        itemBuilder: (context, index) {
                          final entry = _entries[index];
                          return ResponsiveCenter(
                            child: _EntryCard(
                              entry: entry,
                              rank: index + 1,
                              team1: _match!.team1,
                              team2: _match!.team2,
                            )
                                .animate()
                                .fadeIn(
                                    delay:
                                        Duration(milliseconds: 60 * index))
                                .slideY(begin: 0.05),
                          );
                        },
                      ),
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  final Map<String, dynamic> entry;
  final int rank;
  final String team1;
  final String team2;

  const _EntryCard({
    required this.entry,
    required this.rank,
    required this.team1,
    required this.team2,
  });

  @override
  Widget build(BuildContext context) {
    final name = entry['user_name'] ?? 'Unknown';
    final points = entry['points'] ?? 0;
    final toss = entry['toss_winner'] ?? '-';
    final winner = entry['match_winner'] ?? '-';
    final score = entry['score'] ?? 0;
    final wickets = entry['total_wickets'] ?? 0;
    final highestScore = entry['highest_score'] ?? 0;
    final mom = entry['mom'] ?? '-';
    final isCompact = Responsive.isNarrowMobile(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(10)),
      ),
      child: Padding(
        padding: EdgeInsets.all(isCompact ? 14 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppTheme.deepPurple.withAlpha(50),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (points > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.gold.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$points pts',
                      style: const TextStyle(
                        color: AppTheme.gold,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const Divider(color: Colors.white12, height: 20),
            _PredictionRow(label: 'Toss Winner', value: toss),
            _PredictionRow(label: 'Match Winner', value: winner),
            _PredictionRow(label: '1st Innings Score', value: '$score'),
            _PredictionRow(label: 'Total Wickets', value: '$wickets'),
            _PredictionRow(label: 'Highest Score', value: '$highestScore'),
            _PredictionRow(label: 'MOM (Team)', value: mom),
          ],
        ),
      ),
    );
  }
}

class _PredictionRow extends StatelessWidget {
  final String label;
  final String value;

  const _PredictionRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style:
                  TextStyle(color: Colors.white.withAlpha(120), fontSize: 13),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value.isEmpty ? '-' : value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
