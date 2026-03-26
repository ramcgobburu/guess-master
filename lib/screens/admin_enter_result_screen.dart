import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/match.dart';
import '../models/actual.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../theme/responsive.dart';

class AdminEnterResultScreen extends StatefulWidget {
  const AdminEnterResultScreen({super.key});

  @override
  State<AdminEnterResultScreen> createState() =>
      _AdminEnterResultScreenState();
}

class _AdminEnterResultScreenState extends State<AdminEnterResultScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scoreController = TextEditingController();
  final _wicketsController = TextEditingController();
  final _highestScoreController = TextEditingController();

  String? _tossWinner;
  String? _matchWinner;
  String? _momTeam;
  bool _highestScoreTied = false;
  bool _isSaving = false;
  bool _isScoring = false;
  bool _isLoadingExisting = true;
  Match? _match;
  Actual? _existingActual;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && _match == null) {
      _match = args['match'] as Match;
      _loadExisting();
    }
  }

  Future<void> _loadExisting() async {
    try {
      final existing = await ApiService.getActual(_match!.matchId);
      if (existing != null) {
        _existingActual = existing;
        _tossWinner = existing.tossWinner;
        _matchWinner = existing.matchWinner;
        _momTeam = existing.mom;
        _scoreController.text = existing.score.toString();
        _wicketsController.text = existing.totalWickets.toString();
        _highestScoreController.text = existing.highestScore.toString();
        _highestScoreTied = existing.highestScoreTied;
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoadingExisting = false);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_tossWinner == null || _matchWinner == null || _momTeam == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select toss winner, match winner, and MOM team'),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final actual = Actual(
        matchId: _match!.matchId,
        tossWinner: _tossWinner!,
        score: int.parse(_scoreController.text),
        matchWinner: _matchWinner!,
        mom: _momTeam!,
        totalWickets: int.parse(_wicketsController.text),
        highestScore: int.parse(_highestScoreController.text),
        highestScoreTied: _highestScoreTied,
      );
      await ApiService.submitActual(actual);
      _existingActual = actual;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Result saved!'),
            backgroundColor: Colors.green.shade700,
          ),
        );
        setState(() {});
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
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _runScoring() async {
    setState(() => _isScoring = true);
    try {
      final count = await ApiService.calculatePoints(_match!.matchId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Scored $count predictions!'),
            backgroundColor: Colors.green.shade700,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Scoring error: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isScoring = false);
    }
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _wicketsController.dispose();
    _highestScoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_match == null) {
      return const Scaffold(body: Center(child: Text('No match data')));
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
        title: Text('Match ${_match!.matchId} Result',
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
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.deepPurple.withAlpha(25),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppTheme.deepPurple.withAlpha(60)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.admin_panel_settings,
                                color: AppTheme.accentOrange, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '$team1 vs $team2 — Enter actual match result',
                                style: TextStyle(
                                  color: Colors.white.withAlpha(180),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(),

                      SizedBox(height: sectionGap),
                      const _SectionTitle(title: 'Toss Winner'),
                      const SizedBox(height: 8),
                      Row(
                        children: teams.map((team) {
                          final isSelected = _tossWinner == team;
                          final color =
                              TeamColors.getColor(team);
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  right: team == team1 ? 5 : 0,
                                  left: team == team2 ? 5 : 0),
                              child: _TeamChip(
                                team: team,
                                color: color,
                                isSelected: isSelected,
                                onTap: () =>
                                    setState(() => _tossWinner = team),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      SizedBox(height: sectionGap),
                      const _SectionTitle(title: 'Match Winner'),
                      const SizedBox(height: 8),
                      Row(
                        children: teams.map((team) {
                          final isSelected = _matchWinner == team;
                          final color =
                              TeamColors.getColor(team);
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  right: team == team1 ? 5 : 0,
                                  left: team == team2 ? 5 : 0),
                              child: _TeamChip(
                                team: team,
                                color: color,
                                isSelected: isSelected,
                                onTap: () =>
                                    setState(() => _matchWinner = team),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      SizedBox(height: sectionGap),
                      const _SectionTitle(title: '1st Innings Score'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _scoreController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: const InputDecoration(
                          hintText: 'e.g. 185',
                          prefixIcon: Icon(Icons.scoreboard_outlined),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          final n = int.tryParse(v);
                          if (n == null || n < 0 || n > 400) {
                            return 'Valid score (0-400)';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: sectionGap),
                      const _SectionTitle(title: 'Total Wickets (Match)'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _wicketsController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: const InputDecoration(
                          hintText: 'e.g. 12',
                          prefixIcon: Icon(Icons.sports),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          final n = int.tryParse(v);
                          if (n == null || n < 0 || n > 20) {
                            return 'Valid wickets (0-20)';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: sectionGap),
                      const _SectionTitle(title: 'Highest Individual Score'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _highestScoreController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: const InputDecoration(
                          hintText: 'e.g. 78',
                          prefixIcon: Icon(Icons.emoji_events_outlined),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          final n = int.tryParse(v);
                          if (n == null || n < 0 || n > 300) {
                            return 'Valid score (0-300)';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: sectionGap),
                      GestureDetector(
                        onTap: () => setState(
                            () => _highestScoreTied = !_highestScoreTied),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: _highestScoreTied
                                ? AppTheme.gold.withAlpha(20)
                                : AppTheme.cardDark,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _highestScoreTied
                                  ? AppTheme.gold.withAlpha(80)
                                  : Colors.white.withAlpha(15),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _highestScoreTied
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                                color: _highestScoreTied
                                    ? AppTheme.gold
                                    : Colors.white38,
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Two players tied for highest score (2x points)',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: _highestScoreTied
                                        ? AppTheme.gold
                                        : Colors.white54,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: sectionGap),
                      const _SectionTitle(title: 'Man of the Match (Team)'),
                      const SizedBox(height: 8),
                      Row(
                        children: teams.map((team) {
                          final isSelected = _momTeam == team;
                          final color = TeamColors.getColor(team);
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  right: team == team1 ? 5 : 0,
                                  left: team == team2 ? 5 : 0),
                              child: _TeamChip(
                                team: team,
                                color: color,
                                isSelected: isSelected,
                                onTap: () =>
                                    setState(() => _momTeam = team),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _save,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.save_outlined, size: 20),
                          label: Text(_existingActual != null
                              ? 'Update Result'
                              : 'Save Result'),
                        ),
                      ),

                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed:
                              (_existingActual == null || _isScoring)
                                  ? null
                                  : _runScoring,
                          icon: _isScoring
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppTheme.accentOrange),
                                )
                              : const Icon(Icons.calculate_outlined,
                                  size: 20),
                          label: const Text('Calculate Points'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.accentOrange,
                            side: BorderSide(
                              color: (_existingActual == null || _isScoring)
                                  ? Colors.white12
                                  : AppTheme.accentOrange,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),

                      if (_existingActual == null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Save the result first before calculating points',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withAlpha(60),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      SizedBox(
                          height:
                              MediaQuery.paddingOf(context).bottom + 32),
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

class _TeamChip extends StatelessWidget {
  final String team;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _TeamChip({
    required this.team,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
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
            SizedBox(
              width: 40,
              height: 40,
              child: ClipOval(
                child: Image.asset(
                  TeamColors.getLogoAsset(team),
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Center(
                    child: Text(
                      team,
                      style: TextStyle(
                        color: isSelected ? Colors.white : color,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              TeamColors.getFullName(team),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
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
