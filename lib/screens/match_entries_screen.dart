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
                ? _buildError()
                : _entries.isEmpty
                    ? _buildEmpty()
                    : _buildTable(),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
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
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_outline,
              size: 56, color: Colors.white.withAlpha(50)),
          const SizedBox(height: 14),
          Text(
            'No entries yet',
            style: TextStyle(
                color: Colors.white.withAlpha(140), fontSize: 15),
          ),
          const SizedBox(height: 6),
          Text(
            'Entries are visible after predictions lock',
            style: TextStyle(
                color: Colors.white.withAlpha(70), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildTable() {
    const headers = ['Name', 'Toss', 'Winner', 'Score', 'Wkts', 'HS', 'MOM', 'Pts'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppTheme.deepPurple.withAlpha(40)),
          dataRowColor: WidgetStateProperty.all(AppTheme.cardDark),
          border: TableBorder.all(
            color: Colors.white.withAlpha(15),
            borderRadius: BorderRadius.circular(10),
          ),
          columnSpacing: 16,
          horizontalMargin: 12,
          headingRowHeight: 44,
          dataRowMinHeight: 40,
          dataRowMaxHeight: 48,
          columns: headers
              .map((h) => DataColumn(
                    label: Text(
                      h,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: AppTheme.accentOrange,
                      ),
                    ),
                  ))
              .toList(),
          rows: _entries.asMap().entries.map((e) {
            final i = e.key;
            final entry = e.value;
            final pts = entry['points'] ?? 0;

            return DataRow(
              color: WidgetStateProperty.all(
                i.isEven ? AppTheme.cardDark : AppTheme.surfaceDark,
              ),
              cells: [
                DataCell(SizedBox(
                  width: 100,
                  child: Text(
                    entry['user_name'] ?? '-',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                )),
                _cell(entry['toss_winner']),
                _cell(entry['match_winner']),
                _cell('${entry['score'] ?? 0}'),
                _cell('${entry['total_wickets'] ?? 0}'),
                _cell('${entry['highest_score'] ?? 0}'),
                _cell(entry['mom']),
                DataCell(Text(
                  '$pts',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: pts > 0 ? AppTheme.gold : Colors.white54,
                  ),
                )),
              ],
            );
          }).toList(),
        ),
      ).animate().fadeIn(),
    );
  }

  DataCell _cell(dynamic value) {
    final v = value?.toString() ?? '-';
    return DataCell(Text(
      v.isEmpty ? '-' : v,
      style: const TextStyle(fontSize: 12),
    ));
  }
}
