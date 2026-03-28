import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../theme/responsive.dart';

class PointsRubricScreen extends StatelessWidget {
  const PointsRubricScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hPad = Responsive.horizontalPadding(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Points Rubric'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 12),
        child: ResponsiveCenter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RubricSection(
                icon: Icons.swap_horiz,
                title: 'Toss Winner',
                color: Colors.cyan,
                rows: const [
                  _RubricRow('Correct prediction', '20 pts'),
                ],
              ).animate().fadeIn(delay: 0.ms).slideY(begin: 0.05),
              _RubricSection(
                icon: Icons.emoji_events,
                title: 'Match Winner',
                color: AppTheme.gold,
                rows: const [
                  _RubricRow('Correct prediction', '50 pts'),
                ],
              ).animate().fadeIn(delay: 80.ms).slideY(begin: 0.05),
              _RubricSection(
                icon: Icons.scoreboard,
                title: '1st Innings Score',
                color: Colors.greenAccent,
                rows: const [
                  _RubricRow('Exact score', '50 pts'),
                  _RubricRow('Within +/- 10 runs', '25 pts'),
                  _RubricRow('Within +/- 20 runs', '15 pts'),
                ],
              ).animate().fadeIn(delay: 160.ms).slideY(begin: 0.05),
              _RubricSection(
                icon: Icons.sports_cricket,
                title: 'Highest Individual Score',
                color: Colors.orangeAccent,
                rows: const [
                  _RubricRow('Exact score', '50 pts'),
                  _RubricRow('Within +/- 5 runs', '25 pts'),
                  _RubricRow('Within +/- 10 runs', '15 pts'),
                  _RubricRow('Two players tied for highest', '2x points'),
                ],
              ).animate().fadeIn(delay: 240.ms).slideY(begin: 0.05),
              _RubricSection(
                icon: Icons.sports,
                title: 'Total Wickets',
                color: Colors.redAccent,
                rows: const [
                  _RubricRow('Exact wickets', '40 pts'),
                  _RubricRow('Within +/- 1', '25 pts'),
                  _RubricRow('Within +/- 2', '15 pts'),
                  _RubricRow('Within +/- 3', '10 pts'),
                ],
              ).animate().fadeIn(delay: 320.ms).slideY(begin: 0.05),
              _RubricSection(
                icon: Icons.star,
                title: 'Man of the Match (Team)',
                color: Colors.purpleAccent,
                rows: const [
                  _RubricRow(
                      'Correct MOM team + correct match winner', '50 pts'),
                  _RubricRow(
                      'Correct MOM team but wrong match winner', '25 pts'),
                ],
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.05),
              _RubricSection(
                icon: Icons.auto_awesome,
                title: 'Bonus Points',
                color: AppTheme.accentOrange,
                rows: const [
                  _RubricRow(
                      'All 3 correct (Toss + Winner + MOM)', '25 pts'),
                ],
              ).animate().fadeIn(delay: 480.ms).slideY(begin: 0.05),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.accentOrange.withAlpha(15),
                  borderRadius: BorderRadius.circular(14),
                  border:
                      Border.all(color: AppTheme.accentOrange.withAlpha(40)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.info_outline,
                        color: AppTheme.accentOrange, size: 22),
                    const SizedBox(height: 8),
                    Text(
                      'Maximum possible points per match: 285',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.accentOrange.withAlpha(200),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '(20 + 50 + 50 + 100 + 40 + 50 + 25 if HS tied & all correct)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withAlpha(80),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 560.ms),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _RubricRow {
  final String description;
  final String points;
  const _RubricRow(this.description, this.points);
}

class _RubricSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final List<_RubricRow> rows;

  const _RubricSection({
    required this.icon,
    required this.title,
    required this.color,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withAlpha(10)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...rows.map((row) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.circle,
                          size: 5, color: Colors.white.withAlpha(60)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          row.description,
                          style: TextStyle(
                            color: Colors.white.withAlpha(160),
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        row.points,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
