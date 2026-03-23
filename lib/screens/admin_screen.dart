import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../models/match.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../theme/responsive.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<Match> _matches = [];
  Map<String, bool> _hasActuals = {};
  Map<String, int> _predictionCounts = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final matches = await ApiService.getAllMatches();
      final hasActuals = <String, bool>{};
      final predCounts = <String, int>{};

      for (final match in matches) {
        final actual = await ApiService.getActual(match.matchId);
        hasActuals[match.matchId] = actual != null;
        predCounts[match.matchId] =
            await ApiService.getPredictionCountForMatch(match.matchId);
      }

      if (mounted) {
        setState(() {
          _matches = matches;
          _hasActuals = hasActuals;
          _predictionCounts = predCounts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red.shade700,
          ),
        );
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
        title: const Text('Admin Panel'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppTheme.accentOrange,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.accentOrange))
            : _matches.isEmpty
                ? const Center(child: Text('No matches found'))
                : ListView.builder(
                    padding:
                        EdgeInsets.symmetric(horizontal: hPad, vertical: 8),
                    itemCount: _matches.length,
                    itemBuilder: (context, index) {
                      final match = _matches[index];
                      final hasActual =
                          _hasActuals[match.matchId] ?? false;
                      final predCount =
                          _predictionCounts[match.matchId] ?? 0;

                      return ResponsiveCenter(
                        child: _AdminMatchCard(
                          match: match,
                          hasActual: hasActual,
                          predictionCount: predCount,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/admin-enter-result',
                              arguments: {'match': match},
                            ).then((_) => _loadData());
                          },
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

class _AdminMatchCard extends StatelessWidget {
  final Match match;
  final bool hasActual;
  final int predictionCount;
  final VoidCallback onTap;

  const _AdminMatchCard({
    required this.match,
    required this.hasActual,
    required this.predictionCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasActual
              ? Colors.green.withAlpha(60)
              : Colors.white.withAlpha(10),
        ),
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
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: hasActual
                        ? Colors.green.withAlpha(30)
                        : AppTheme.accentOrange.withAlpha(25),
                  ),
                  child: Center(
                    child: Text(
                      match.matchId,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: hasActual
                            ? Colors.green
                            : AppTheme.accentOrange,
                      ),
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
                      const SizedBox(height: 3),
                      Text(
                        DateFormat('MMM dd, hh:mm a')
                            .format(match.startDateTime.toLocal()),
                        style: TextStyle(
                          color: Colors.white.withAlpha(100),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: hasActual
                            ? Colors.green.withAlpha(25)
                            : Colors.white.withAlpha(8),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        hasActual ? 'Scored' : 'Pending',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: hasActual
                              ? Colors.green
                              : Colors.white54,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$predictionCount predictions',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withAlpha(80),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right,
                  color: Colors.white.withAlpha(60),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
