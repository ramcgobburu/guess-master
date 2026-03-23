import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/match.dart';
import '../models/prediction.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../theme/responsive.dart';

class PredictScreen extends StatefulWidget {
  const PredictScreen({super.key});

  @override
  State<PredictScreen> createState() => _PredictScreenState();
}

class _PredictScreenState extends State<PredictScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scoreController = TextEditingController();
  final _wicketsController = TextEditingController();
  final _highestScoreController = TextEditingController();
  final _momController = TextEditingController();

  String? _tossWinner;
  String? _matchWinner;
  bool _isLoading = false;
  bool _isLoadingExisting = true;
  Match? _match;
  Prediction? _existingPrediction;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && _match == null) {
      _match = args['match'] as Match;
      _loadExistingPrediction();
    }
  }

  Future<void> _loadExistingPrediction() async {
    try {
      final existing = await ApiService.getExistingPrediction(
        _match!.matchId,
        AuthService.userId,
      );
      if (existing != null) {
        _existingPrediction = existing;
        _prefillForm();
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoadingExisting = false);
  }

  void _prefillForm() {
    final p = _existingPrediction!;
    _tossWinner = p.tossWinner;
    _matchWinner = p.matchWinner;
    _scoreController.text = p.score.toString();
    _wicketsController.text = p.totalWickets.toString();
    _highestScoreController.text = p.highestScore.toString();
    _momController.text = p.mom;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_tossWinner == null || _matchWinner == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select toss winner and match winner'),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final prediction = Prediction(
        matchId: _match!.matchId,
        userId: AuthService.userId,
        email: AuthService.userEmail,
        name: AuthService.userName,
        tossWinner: _tossWinner!,
        score: int.parse(_scoreController.text),
        matchWinner: _matchWinner!,
        mom: _momController.text.trim(),
        totalWickets: int.parse(_wicketsController.text),
        highestScore: int.parse(_highestScoreController.text),
      );
      await ApiService.submitPrediction(prediction);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_existingPrediction != null
                ? 'Prediction updated!'
                : 'Prediction submitted!'),
            backgroundColor: Colors.green.shade700,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _wicketsController.dispose();
    _highestScoreController.dispose();
    _momController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_match == null) {
      return const Scaffold(
        body: Center(child: Text('No match data')),
      );
    }

    final team1 = _match!.team1;
    final team2 = _match!.team2;
    final teams = [team1, team2];
    final hPad = Responsive.horizontalPadding(context);
    final isCompact = Responsive.isNarrowMobile(context);
    final sectionGap = isCompact ? 18.0 : 22.0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('$team1 vs $team2',
            style: TextStyle(fontSize: isCompact ? 16 : 18)),
      ),
      body: _isLoadingExisting
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.accentOrange))
          : SingleChildScrollView(
              child: ResponsiveCenter(
                padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_existingPrediction != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppTheme.accentOrange.withAlpha(20),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppTheme.accentOrange.withAlpha(60)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline,
                                  color: AppTheme.accentOrange, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Editing your existing prediction.',
                                  style: TextStyle(
                                    color: AppTheme.accentOrange.withAlpha(180),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(),

                      const _SectionTitle(title: 'Toss Winner'),
                      const SizedBox(height: 8),
                      Row(
                        children: teams.map((team) {
                          final isSelected = _tossWinner == team;
                          final color = TeamColors.getColor(team);
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  right: team == team1 ? 5 : 0,
                                  left: team == team2 ? 5 : 0),
                              child: _TeamSelectButton(
                                team: team,
                                color: color,
                                isSelected: isSelected,
                                compact: isCompact,
                                onTap: () =>
                                    setState(() => _tossWinner = team),
                              ),
                            ),
                          );
                        }).toList(),
                      ).animate().fadeIn(delay: 100.ms),

                      SizedBox(height: sectionGap),
                      const _SectionTitle(title: 'Match Winner'),
                      const SizedBox(height: 8),
                      Row(
                        children: teams.map((team) {
                          final isSelected = _matchWinner == team;
                          final color = TeamColors.getColor(team);
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  right: team == team1 ? 5 : 0,
                                  left: team == team2 ? 5 : 0),
                              child: _TeamSelectButton(
                                team: team,
                                color: color,
                                isSelected: isSelected,
                                compact: isCompact,
                                onTap: () =>
                                    setState(() => _matchWinner = team),
                              ),
                            ),
                          );
                        }).toList(),
                      ).animate().fadeIn(delay: 200.ms),

                      SizedBox(height: sectionGap),
                      const _SectionTitle(title: '1st Innings Score'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _scoreController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(
                          hintText: 'e.g. 185',
                          prefixIcon: Icon(Icons.scoreboard_outlined),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Enter a score';
                          final n = int.tryParse(v);
                          if (n == null || n < 0 || n > 400) {
                            return 'Enter a valid score (0-400)';
                          }
                          return null;
                        },
                      ).animate().fadeIn(delay: 300.ms),

                      SizedBox(height: sectionGap),
                      const _SectionTitle(title: 'Total Wickets (Match)'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _wicketsController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(
                          hintText: 'e.g. 12',
                          prefixIcon: Icon(Icons.sports),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Enter wickets';
                          final n = int.tryParse(v);
                          if (n == null || n < 0 || n > 20) {
                            return 'Enter valid wickets (0-20)';
                          }
                          return null;
                        },
                      ).animate().fadeIn(delay: 400.ms),

                      SizedBox(height: sectionGap),
                      const _SectionTitle(title: 'Highest Individual Score'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _highestScoreController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(
                          hintText: 'e.g. 78',
                          prefixIcon: Icon(Icons.emoji_events_outlined),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Enter highest score';
                          final n = int.tryParse(v);
                          if (n == null || n < 0 || n > 300) {
                            return 'Enter valid score (0-300)';
                          }
                          return null;
                        },
                      ).animate().fadeIn(delay: 500.ms),

                      SizedBox(height: sectionGap),
                      const _SectionTitle(title: 'Man of the Match'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _momController,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          hintText: 'Player name',
                          prefixIcon: Icon(Icons.star_outline),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Enter player name';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) => _submit(),
                      ).animate().fadeIn(delay: 600.ms),

                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : Text(_existingPrediction != null
                                  ? 'Update Prediction'
                                  : 'Submit Prediction'),
                        ),
                      ).animate().fadeIn(delay: 700.ms),
                      SizedBox(
                          height: MediaQuery.paddingOf(context).bottom + 32),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.white60,
        letterSpacing: 0.4,
      ),
    );
  }
}

class _TeamSelectButton extends StatelessWidget {
  final String team;
  final Color color;
  final bool isSelected;
  final bool compact;
  final VoidCallback onTap;

  const _TeamSelectButton({
    required this.team,
    required this.color,
    required this.isSelected,
    this.compact = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final badgeSize = compact ? 40.0 : 46.0;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: compact ? 12 : 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isSelected ? color.withAlpha(50) : AppTheme.cardDark,
          border: Border.all(
            color: isSelected ? color : Colors.white.withAlpha(15),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: badgeSize,
              height: badgeSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withAlpha(isSelected ? 70 : 25),
              ),
              child: ClipOval(
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: Image.asset(
                    TeamColors.getLogoAsset(team),
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Center(
                      child: Text(
                        team,
                        style: TextStyle(
                          color: isSelected ? Colors.white : color,
                          fontWeight: FontWeight.bold,
                          fontSize: compact ? 12 : 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              TeamColors.getFullName(team),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: compact ? 10 : 11,
                color: isSelected ? Colors.white : Colors.white54,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: 3),
              Icon(Icons.check_circle, color: color, size: 16),
            ],
          ],
        ),
      ),
    );
  }
}
