import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/prediction.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../theme/responsive.dart';

class MyPredictionsScreen extends StatefulWidget {
  const MyPredictionsScreen({super.key});

  @override
  State<MyPredictionsScreen> createState() => _MyPredictionsScreenState();
}

class _MyPredictionsScreenState extends State<MyPredictionsScreen> {
  List<Prediction> _predictions = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPredictions();
  }

  Future<void> _loadPredictions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final predictions =
          await ApiService.getMyPredictions(AuthService.userId);
      if (mounted) {
        setState(() {
          _predictions = predictions;
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
        title: const Text('My Predictions'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadPredictions,
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
                            onPressed: _loadPredictions,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                : _predictions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lightbulb_outline,
                                size: 56,
                                color: Colors.white.withAlpha(50)),
                            const SizedBox(height: 14),
                            Text(
                              'No predictions yet',
                              style: TextStyle(
                                  color: Colors.white.withAlpha(140),
                                  fontSize: 15),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Go to Home to make your first prediction!',
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
                        itemCount: _predictions.length,
                        itemBuilder: (context, index) {
                          final p = _predictions[index];
                          return ResponsiveCenter(
                            child: _PredictionCard(prediction: p)
                                .animate()
                                .fadeIn(
                                    delay: Duration(
                                        milliseconds: 60 * index))
                                .slideY(begin: 0.05),
                          );
                        },
                      ),
      ),
    );
  }
}

class _PredictionCard extends StatelessWidget {
  final Prediction prediction;

  const _PredictionCard({required this.prediction});

  @override
  Widget build(BuildContext context) {
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accentOrange.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Match ${prediction.matchId}',
                    style: const TextStyle(
                      color: AppTheme.accentOrange,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                if (prediction.points > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.gold.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${prediction.points} pts',
                      style: const TextStyle(
                        color: AppTheme.gold,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _InfoRow(label: 'Toss Winner', value: prediction.tossWinner),
            _InfoRow(label: 'Match Winner', value: prediction.matchWinner),
            _InfoRow(
                label: '1st Innings Score',
                value: prediction.score.toString()),
            _InfoRow(
                label: 'Total Wickets',
                value: prediction.totalWickets.toString()),
            _InfoRow(
                label: 'Highest Score',
                value: prediction.highestScore.toString()),
            _InfoRow(label: 'Man of the Match', value: prediction.mom),
            if (prediction.pointsBreakdown != null) ...[
              const Divider(color: Colors.white12, height: 20),
              _BreakdownSection(breakdown: prediction.pointsBreakdown!),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                  color: Colors.white.withAlpha(120), fontSize: 13),
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

class _BreakdownSection extends StatelessWidget {
  final Map<String, dynamic> breakdown;

  const _BreakdownSection({required this.breakdown});

  static const _labels = {
    'toss': 'Toss',
    'winner': 'Winner',
    'score': 'Score',
    'highest_score': 'Highest Score',
    'bonus': 'Bonus (HS+Score)',
    'wickets': 'Wickets',
    'mom': 'MOM',
  };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: _labels.entries.map((entry) {
        final pts = breakdown[entry.key] ?? 0;
        final hasPoints = pts > 0;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: hasPoints
                ? Colors.green.withAlpha(20)
                : Colors.white.withAlpha(5),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: hasPoints
                  ? Colors.green.withAlpha(50)
                  : Colors.white.withAlpha(8),
            ),
          ),
          child: Text(
            '${entry.value}: $pts',
            style: TextStyle(
              fontSize: 11,
              fontWeight: hasPoints ? FontWeight.w600 : FontWeight.normal,
              color: hasPoints ? Colors.green.shade300 : Colors.white30,
            ),
          ),
        );
      }).toList(),
    );
  }
}
