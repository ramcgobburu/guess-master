import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/match.dart';
import '../theme/app_theme.dart';

class MatchCard extends StatelessWidget {
  final Match match;
  final VoidCallback onPredict;

  const MatchCard({
    super.key,
    required this.match,
    required this.onPredict,
  });

  @override
  Widget build(BuildContext context) {
    final team1Color = TeamColors.getColor(match.team1);
    final team2Color = TeamColors.getColor(match.team2);
    final canPredict = match.canPredict;
    final screenW = MediaQuery.sizeOf(context).width;
    final isCompact = screenW < 375;
    final badgeSize = isCompact ? 56.0 : 64.0;
    final cardPad = isCompact ? 14.0 : 18.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            team1Color.withAlpha(50),
            AppTheme.cardDark,
            team2Color.withAlpha(50),
          ],
          stops: const [0.0, 0.5, 1.0],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        border: Border.all(color: Colors.white.withAlpha(12)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: canPredict ? onPredict : null,
          child: Padding(
            padding: EdgeInsets.all(cardPad),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Match ${match.matchId}',
                      style: TextStyle(
                        color: Colors.white.withAlpha(100),
                        fontSize: 11,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (match.venue.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Icon(Icons.location_on,
                          size: 10, color: Colors.white.withAlpha(80)),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          match.venue.split(',').first,
                          style: TextStyle(
                            color: Colors.white.withAlpha(80),
                            fontSize: 10,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: isCompact ? 12 : 14),
                Row(
                  children: [
                    Expanded(
                      child: _TeamBadge(
                        team: match.team1,
                        color: team1Color,
                        size: badgeSize,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(12),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              'VS',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isCompact ? 12 : 13,
                                color: AppTheme.accentOrange,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            DateFormat('MMM dd, hh:mm a')
                                .format(match.startDateTime.toLocal()),
                            style: TextStyle(
                              color: Colors.white.withAlpha(160),
                              fontSize: isCompact ? 10 : 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _TeamBadge(
                        team: match.team2,
                        color: team2Color,
                        size: badgeSize,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isCompact ? 12 : 14),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: canPredict
                      ? ElevatedButton(
                          onPressed: onPredict,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: const Text('Make Prediction'),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white.withAlpha(8),
                          ),
                          child: const Center(
                            child: Text(
                              'Predictions Locked',
                              style: TextStyle(
                                color: Colors.white30,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TeamBadge extends StatelessWidget {
  final String team;
  final Color color;
  final double size;

  const _TeamBadge({
    required this.team,
    required this.color,
    this.size = 64,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withAlpha(25),
            border: Border.all(color: color.withAlpha(80), width: 2),
          ),
          child: ClipOval(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Image.asset(
                TeamColors.getLogoAsset(team),
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Center(
                  child: Text(
                    team,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: size < 60 ? 13 : 15,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          TeamColors.getFullName(team),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: size < 60 ? 10 : 11,
            color: Colors.white60,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
