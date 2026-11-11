import 'dart:math';

import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../data/repositories/game_session_repository.dart';
import 'parent_access_repository.dart';

class ParentGateScreen extends StatefulWidget {
  const ParentGateScreen({
    required this.repository,
    required this.onAuthenticated,
    super.key,
  });

  final ParentAccessRepository repository;
  final VoidCallback onAuthenticated;

  @override
  State<ParentGateScreen> createState() => _ParentGateScreenState();
}

class _ParentGateScreenState extends State<ParentGateScreen> {
  final _answer = TextEditingController();
  final _pin = TextEditingController();
  late int _a;
  late int _b;
  bool _loading = true;
  bool _submitting = false;
  bool _hasPin = false;
  String _step = 'adult';
  String? _pendingPin;
  String? _error;
  int _failures = 0;

  @override
  void initState() {
    super.initState();
    _newChallenge();
    _load();
  }

  void _newChallenge() {
    final random = Random.secure();
    _a = 21 + random.nextInt(29);
    _b = 11 + random.nextInt(19);
  }

  Future<void> _load() async {
    try {
      final hasPin = await widget.repository.hasPin();
      if (!mounted) return;
      setState(() {
        _hasPin = hasPin;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Parent access could not be loaded. Please try again.';
      });
    }
  }

  Future<void> _submit() async {
    if (_submitting || _loading) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      switch (_step) {
        case 'adult':
          if (int.tryParse(_answer.text.trim()) != _a * _b) {
            _newChallenge();
            _answer.clear();
            _error = 'Incorrect answer. Try the new adult check.';
          } else {
            _answer.clear();
            _step = _hasPin ? 'unlock' : 'create';
          }
          break;
        case 'create':
          final value = _pin.text.trim();
          if (value.length != 6 ||
              value.codeUnits.any((unit) => unit < 48 || unit > 57)) {
            _error = 'Choose a PIN with exactly six digits.';
          } else {
            _pendingPin = value;
            _pin.clear();
            _step = 'confirm';
          }
          break;
        case 'confirm':
          if (_pin.text.trim() != _pendingPin) {
            _pin.clear();
            _pendingPin = null;
            _step = 'create';
            _error = 'The PINs did not match. Please create it again.';
          } else {
            await widget.repository.setPin(_pendingPin!);
            widget.onAuthenticated();
            return;
          }
          break;
        case 'unlock':
          final valid = await widget.repository.verifyPin(_pin.text.trim());
          _pin.clear();
          if (valid) {
            widget.onAuthenticated();
            return;
          }
          _failures++;
          if (_failures >= 5) {
            _failures = 0;
            _step = 'adult';
            _newChallenge();
            _error = 'Complete the adult check again before retrying.';
          } else {
            _error = 'Incorrect PIN. ${5 - _failures} attempts left.';
          }
          break;
      }
    } catch (_) {
      _error = 'We could not save or verify parent access. Please try again.';
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _answer.dispose();
    _pin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adult = _step == 'adult';
    final pinStep = _step != 'adult';
    final title = switch (_step) {
      'adult' => 'A quick adult check',
      'create' => 'Create your parent PIN',
      'confirm' => 'Confirm your parent PIN',
      _ => 'Enter your parent PIN',
    };
    final description = switch (_step) {
      'adult' => 'Parents and grown-ups only. Solve this multiplication question to continue.',
      'create' => 'Create a six-digit PIN. Keep it private from children.',
      'confirm' => 'Enter the same six digits one more time.',
      _ => 'Enter the six-digit PIN created for this device.',
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FC),
      appBar: AppBar(
        title: const Text('Parent access'),
        backgroundColor: const Color(0xFFF4F6FC),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const CircleAvatar(
                            radius: 34,
                            backgroundColor: Color(0xFFE9EEFF),
                            child: Icon(Icons.family_restroom_rounded,
                                size: 34, color: AppTheme.ink),
                          ),
                          const SizedBox(height: 18),
                          Text(title,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineSmall),
                          const SizedBox(height: 8),
                          Text(description, textAlign: TextAlign.center),
                          const SizedBox(height: 22),
                          if (adult) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 18, horizontal: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F5FF),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Text('$_a × $_b = ?',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.ink,
                                  )),
                            ),
                            const SizedBox(height: 14),
                            TextField(
                              key: const Key('parent_adult_answer'),
                              controller: _answer,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              decoration: const InputDecoration(
                                labelText: 'Your answer',
                                border: OutlineInputBorder(),
                              ),
                              onSubmitted: (_) => _submit(),
                            ),
                          ],
                          if (pinStep)
                            TextField(
                              key: const Key('parent_pin_field'),
                              controller: _pin,
                              keyboardType: TextInputType.number,
                              obscureText: true,
                              maxLength: 6,
                              textInputAction: TextInputAction.done,
                              decoration: const InputDecoration(
                                labelText: 'Six-digit PIN',
                                counterText: '',
                                border: OutlineInputBorder(),
                              ),
                              onSubmitted: (_) => _submit(),
                            ),
                          if (_error != null) ...[
                            const SizedBox(height: 12),
                            Text(_error!,
                                key: const Key('parent_gate_error'),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFFB42318),
                                  fontWeight: FontWeight.w600,
                                )),
                          ],
                          const SizedBox(height: 18),
                          FilledButton(
                            key: const Key('parent_gate_continue'),
                            onPressed: _submitting ? null : _submit,
                            child: _submitting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2))
                                : Text(switch (_step) {
                                    'adult' => 'Verify adult',
                                    'create' => 'Continue',
                                    'confirm' => 'Save parent PIN',
                                    _ => 'Unlock parent area',
                                  }),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => Navigator.of(context).maybePop(),
                            child: const Text('Back to kids area'),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({
    required this.parentRepository,
    required this.gameSessionRepository,
    required this.onLock,
    super.key,
  });

  final ParentAccessRepository parentRepository;
  final GameSessionRepository gameSessionRepository;
  final VoidCallback onLock;

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  late Future<ParentControls> _controls;
  late Future<List<GameSession>> _sessions;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    _controls = widget.parentRepository.loadControls();
    _sessions = widget.gameSessionRepository.recentSessions(limit: 200);
  }

  Future<void> _save(ParentControls next) async {
    await widget.parentRepository.saveControls(next);
    if (mounted) setState(() => _controls = Future.value(next));
  }

  Future<int?> _chooseTime(BuildContext context, int currentMinute) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: currentMinute ~/ 60,
        minute: currentMinute % 60,
      ),
    );
    return selected == null ? null : selected.hour * 60 + selected.minute;
  }

  String _formatTime(int minute) => TimeOfDay(
        hour: minute ~/ 60,
        minute: minute % 60,
      ).format(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FC),
      appBar: AppBar(
        title: const Text('Parent dashboard'),
        backgroundColor: const Color(0xFFF4F6FC),
        actions: [
          IconButton(
            key: const Key('parent_lock_button'),
            tooltip: 'Lock parent area',
            onPressed: widget.onLock,
            icon: const Icon(Icons.lock_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          const Text('A clear view of learning on this device.',
              style: TextStyle(color: Color(0xFF667085))),
          const SizedBox(height: 16),
          FutureBuilder<List<GameSession>>(
            future: _sessions,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const _ParentInfoCard(
                  title: 'Progress unavailable',
                  message: 'Saved activity could not be loaded.',
                );
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final sessions = snapshot.data!;
              final correct = sessions.fold<int>(
                  0, (total, item) => total + item.score);
              final questions = sessions.fold<int>(
                  0, (total, item) => total + item.totalRounds);
              final accuracy =
                  questions == 0 ? 0 : (correct / questions * 100).round();
              return Row(
                children: [
                  Expanded(
                    child: _ParentMetric(
                      value: sessions.length.toString(),
                      label: 'Games played',
                      icon: Icons.sports_esports_rounded,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ParentMetric(
                      value: '$accuracy%',
                      label: 'Answer accuracy',
                      icon: Icons.track_changes_rounded,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 22),
          Text('Family settings',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          FutureBuilder<ParentControls>(
            future: _controls,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final value = snapshot.data!;
              return Column(
                children: [
                  _ParentSettingCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Daily app-time target',
                            style: TextStyle(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        const Text(
                          'Choose a family target for daily app use.',
                          style: TextStyle(color: Color(0xFF667085)),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          key: const Key('parent_daily_limit'),
                          initialValue: value.dailyLimitMinutes,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: const [30, 45, 60, 90, 120]
                              .map((minutes) => DropdownMenuItem(
                                    value: minutes,
                                    child: Text('$minutes minutes'),
                                  ))
                              .toList(),
                          onChanged: (minutes) {
                            if (minutes != null) {
                              _save(value.copyWith(
                                  dailyLimitMinutes: minutes));
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  _ParentSettingCard(
                    child: Column(
                      children: [
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Bedtime schedule',
                              style: TextStyle(fontWeight: FontWeight.w800)),
                          subtitle: const Text(
                              'Save the hours when app access should be paused.'),
                          value: value.bedtimeEnabled,
                          onChanged: (enabled) => _save(
                              value.copyWith(bedtimeEnabled: enabled)),
                        ),
                        const Divider(height: 12),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Bedtime starts'),
                          trailing:
                              Text(_formatTime(value.bedtimeStartMinute)),
                          onTap: () async {
                            final minute = await _chooseTime(
                                context, value.bedtimeStartMinute);
                            if (minute != null) {
                              _save(value.copyWith(
                                  bedtimeStartMinute: minute));
                            }
                          },
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Bedtime ends'),
                          trailing:
                              Text(_formatTime(value.bedtimeEndMinute)),
                          onTap: () async {
                            final minute = await _chooseTime(
                                context, value.bedtimeEndMinute);
                            if (minute != null) {
                              _save(value.copyWith(
                                  bedtimeEndMinute: minute));
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  _ParentSettingCard(
                    child: Column(
                      children: [
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Game sounds',
                              style: TextStyle(fontWeight: FontWeight.w800)),
                          subtitle:
                              const Text('Family preference for audio.'),
                          value: value.soundEnabled,
                          onChanged: (enabled) => _save(
                              value.copyWith(soundEnabled: enabled)),
                        ),
                        const Divider(height: 12),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Reduce motion',
                              style: TextStyle(fontWeight: FontWeight.w800)),
                          subtitle: const Text(
                              'Preference for calmer movement and transitions.'),
                          value: value.reducedMotion,
                          onChanged: (enabled) => _save(
                              value.copyWith(reducedMotion: enabled)),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          const _ParentInfoCard(
            title: 'Settings are saved offline',
            message:
                'The parent PIN is stored in encrypted secure storage. Time targets and bedtime preferences are saved on this device. Their enforcement is a separate release task and is not yet active.',
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: widget.onLock,
            icon: const Icon(Icons.lock_outline_rounded),
            label: const Text('Lock parent area'),
          ),
        ],
      ),
    );
  }
}

class _ParentMetric extends StatelessWidget {
  const _ParentMetric({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.ink),
          const SizedBox(height: 8),
          Text(value,
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _ParentSettingCard extends StatelessWidget {
  const _ParentSettingCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      );
}

class _ParentInfoCard extends StatelessWidget {
  const _ParentInfoCard({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => _ParentSettingCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.privacy_tip_outlined, color: AppTheme.ink),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 5),
                  Text(message, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      );
}
