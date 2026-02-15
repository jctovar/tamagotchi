import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/pet.dart';
import '../models/interaction_history.dart';
import '../models/minigame_stats.dart';
import '../services/storage_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final StorageService _storage = StorageService();

  Pet? _pet;
  InteractionHistory? _history;
  MiniGameStats? _gameStats;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final pet = await _storage.loadPetState();
    final history = await _storage.loadInteractionHistory();
    final gameStats = await _storage.loadMiniGameStats();

    setState(() {
      _pet = pet;
      _history = history;
      _gameStats = gameStats;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.today), text: 'Hoy'),
            Tab(icon: Icon(Icons.sports_esports), text: 'Juegos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildDailyTab(), _buildGamesTab()],
      ),
    );
  }

  Widget _buildDailyTab() {
    if (_history == null || _pet == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final todayInteractions = _history!.todayInteractions;
    final dateFormat = DateFormat('HH:mm');

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resumen de Hoy',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard(
                        context,
                        'Total de interacciones',
                        '${todayInteractions.length}',
                        Icons.touch_app,
                        Colors.blue,
                      ),
                      _buildStatCard(
                        context,
                        'Interacciones proactivas',
                        '${(_history!.proactiveRatio * 100).toStringAsFixed(1)}%',
                        Icons.check_circle,
                        Colors.green,
                      ),
                      _buildStatCard(
                        context,
                        'Última interacción',
                        todayInteractions.isNotEmpty
                            ? dateFormat.format(
                                todayInteractions.last.timestamp,
                              )
                            : 'N/A',
                        Icons.history,
                        Colors.purple,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          ...todayInteractions.map((interaction) {
            return _buildInteractionCard(interaction);
          }),
        ],
      ),
    );
  }

  Widget _buildInteractionCard(Interaction interaction) {
    final minutesAgo = DateTime.now()
        .difference(interaction.timestamp)
        .inMinutes;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  interaction.type.displayName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '$minutesAgo minutos atrás',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Wrap(
              children: [
                _buildInteractionChip(
                  interaction.hungerBefore,
                  'Hambre',
                  interaction.hungerBefore > 70,
                ),
                _buildInteractionChip(
                  interaction.happinessBefore,
                  'Felicidad',
                  interaction.happinessBefore > 70,
                ),
                _buildInteractionChip(
                  interaction.energyBefore,
                  'Energía',
                  interaction.energyBefore > 70,
                ),
                _buildInteractionChip(
                  interaction.healthBefore,
                  'Salud',
                  interaction.healthBefore > 70,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractionChip(double value, String label, bool wasLow) {
    return Chip(
      label: Text(label),
      avatar: CircleAvatar(
        backgroundColor: wasLow ? Colors.red.shade100 : Colors.green.shade100,
        child: Icon(
          wasLow ? Icons.warning : Icons.check_circle,
          color: Colors.white,
          size: 14,
        ),
      ),
      side: BorderSide(color: wasLow ? Colors.red : Colors.green, width: 1),
    );
  }

  Widget _buildGamesTab() {
    if (_gameStats == null || _pet == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resumen de Juegos',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard(
                        context,
                        'Total de juegos',
                        '${_gameStats!.totalGamesPlayed}',
                        Icons.sports_esports,
                        Colors.blue,
                      ),
                      _buildStatCard(
                        context,
                        'Victorias',
                        '${_gameStats!.totalWins}',
                        Icons.emoji_events,
                        Colors.green,
                      ),
                      _buildStatCard(
                        context,
                        'Tasa de victoria',
                        _gameStats!.totalGamesPlayed > 0
                            ? '${(_gameStats!.totalWins / _gameStats!.totalGamesPlayed * 100).toStringAsFixed(1)}%'
                            : '0%',
                        Icons.trending_up,
                        Colors.orange,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          ...MiniGameType.values.map((gameType) {
            return _buildGameTypeCard(gameType);
          }),
        ],
      ),
    );
  }

  Widget _buildGameTypeCard(MiniGameType gameType) {
    final stats = _gameStats!.getStats(gameType);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  gameType.displayName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  'Victorias: ${stats.timesWon}/${stats.timesPlayed}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 4),
            _buildWinRateChart(stats),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Mejor puntuación: ${stats.bestScore}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWinRateChart(GameStats stats) {
    final color = stats.winRate >= 70
        ? Colors.green
        : stats.winRate >= 40
        ? Colors.orange
        : Colors.red;

    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(4),
                  right: Radius.circular(4),
                ),
              ),
              child: FractionallySizedBox(
                widthFactor: stats.winRate / 100,
                alignment: Alignment.centerLeft,
                child: Container(color: color),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${stats.winRate.toStringAsFixed(0)}%',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
