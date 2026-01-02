import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/pet.dart';
import '../models/interaction_history.dart';
import '../models/minigame_stats.dart';
import '../services/storage_service.dart';
import '../utils/ml_performance_tracker.dart';

/// Pantalla de estadísticas con tabs para diferentes vistas
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
    _tabController = TabController(length: 3, vsync: this);
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
            Tab(icon: Icon(Icons.psychology), text: 'IA/ML'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDailyTab(),
          _buildGamesTab(),
          _buildMLTab(),
        ],
      ),
    );
  }

  // ==================== TAB 1: ACTIVIDADES DIARIAS ====================
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
          // Encabezado con resumen del día
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
                        '${todayInteractions.length}',
                        'Interacciones',
                        Icons.touch_app,
                        Colors.blue,
                      ),
                      _buildStatCard(
                        context,
                        '${_pet!.level}',
                        'Nivel',
                        Icons.stars,
                        Colors.amber,
                      ),
                      _buildStatCard(
                        context,
                        '${_pet!.coins}',
                        'Monedas',
                        Icons.monetization_on,
                        Colors.green,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Timeline de actividades
          Text(
            'Actividades de Hoy',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),

          if (todayInteractions.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.inbox,
                          size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'No hay actividades hoy',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            ...todayInteractions.reversed.map((interaction) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getInteractionColor(interaction.type),
                    child: Text(
                      interaction.type.emoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  title: Text(interaction.type.displayName),
                  subtitle: Text(
                    '${dateFormat.format(interaction.timestamp)} • ${interaction.timeOfDay.displayName}',
                  ),
                  trailing: interaction.wasProactive
                      ? const Icon(Icons.check_circle,
                          color: Colors.green, size: 20)
                      : interaction.wasReactive
                          ? const Icon(Icons.warning_amber,
                              color: Colors.orange, size: 20)
                          : null,
                ),
              );
            }),
        ],
      ),
    );
  }

  // ==================== TAB 2: JUEGOS ====================
  Widget _buildGamesTab() {
    if (_gameStats == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Resumen global de juegos
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resumen de Mini-Juegos',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard(
                        context,
                        '${_gameStats!.totalGamesPlayed}',
                        'Partidas',
                        Icons.gamepad,
                        Colors.purple,
                      ),
                      _buildStatCard(
                        context,
                        '${_gameStats!.totalWins}',
                        'Victorias',
                        Icons.emoji_events,
                        Colors.amber,
                      ),
                      _buildStatCard(
                        context,
                        '${_gameStats!.totalCoinsEarned}',
                        'Monedas',
                        Icons.monetization_on,
                        Colors.green,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Gráfica de win rate por juego
          if (_gameStats!.totalGamesPlayed > 0) ...[
            Text(
              'Tasa de Victoria por Juego',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  height: 200,
                  child: _buildWinRateChart(),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Estadísticas por juego
          Text(
            'Estadísticas Detalladas',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),

          ...MiniGameType.values.map((gameType) {
            final stats = _gameStats!.getStats(gameType);
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: Color(gameType.colorValue),
                  child: Text(
                    gameType.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                title: Text(gameType.displayName),
                subtitle: Text(
                  'Win Rate: ${stats.winRate.toStringAsFixed(1)}%',
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildStatRow('Partidas Jugadas', '${stats.timesPlayed}'),
                        _buildStatRow('Victorias', '${stats.timesWon}'),
                        _buildStatRow('Mejor Puntuación', '${stats.bestScore}'),
                        _buildStatRow('XP Total Ganado', '${stats.totalXpEarned}'),
                        _buildStatRow('Monedas Totales', '${stats.totalCoinsEarned}'),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ==================== TAB 3: MACHINE LEARNING ====================
  Widget _buildMLTab() {
    final tracker = MLPerformanceTracker();
    final report = tracker.generateReport();
    final globalData = report['global'] as Map<String, dynamic>;
    final modelsData = report['models'] as Map<String, dynamic>;

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Resumen global ML
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rendimiento de IA/ML',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard(
                        context,
                        '${globalData['total_inferences']}',
                        'Predicciones',
                        Icons.psychology,
                        Colors.blue,
                      ),
                      _buildStatCard(
                        context,
                        '${(globalData['success_rate'] * 100).toStringAsFixed(0)}%',
                        'Precisión',
                        Icons.check_circle,
                        Colors.green,
                      ),
                      _buildStatCard(
                        context,
                        '${globalData['average_time_ms'].toStringAsFixed(0)}ms',
                        'Tiempo Avg',
                        Icons.speed,
                        Colors.orange,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Gráfica de rendimiento por modelo
          if (modelsData.isNotEmpty) ...[
            Text(
              'Rendimiento por Modelo',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  height: 200,
                  child: _buildModelPerformanceChart(modelsData),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Detalles por modelo
          if (modelsData.isNotEmpty) ...[
            Text(
              'Detalles por Modelo',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...modelsData.entries.map((entry) {
              final modelName = entry.key;
              final data = entry.value as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.purple,
                    child: Icon(Icons.model_training, color: Colors.white),
                  ),
                  title: Text(modelName),
                  subtitle: Text(
                    'Tasa de éxito: ${(data['success_rate'] * 100).toStringAsFixed(1)}%',
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildStatRow('Total Inferencias', '${data['total_inferences']}'),
                          _buildStatRow('Exitosas', '${data['successful_inferences']}'),
                          _buildStatRow('Fallidas', '${data['failed_inferences']}'),
                          _buildStatRow('Tiempo Promedio', '${data['average_time_ms'].toStringAsFixed(1)} ms'),
                          _buildStatRow('Tiempo Mínimo', '${data['min_time_ms']} ms'),
                          _buildStatRow('Tiempo Máximo', '${data['max_time_ms']} ms'),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ] else ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.psychology_outlined,
                          size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'No hay datos ML aún',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'La IA comenzará a aprender de tus interacciones',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==================== WIDGETS HELPER ====================

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
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Color _getInteractionColor(InteractionType type) {
    switch (type) {
      case InteractionType.feed:
        return Colors.orange.shade100;
      case InteractionType.play:
        return Colors.blue.shade100;
      case InteractionType.clean:
        return Colors.green.shade100;
      case InteractionType.rest:
        return Colors.purple.shade100;
      case InteractionType.minigame:
        return Colors.pink.shade100;
      case InteractionType.customize:
        return Colors.amber.shade100;
      case InteractionType.evolve:
        return Colors.teal.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  // ==================== GRÁFICAS ====================

  Widget _buildWinRateChart() {
    final data = MiniGameType.values.map((gameType) {
      final stats = _gameStats!.getStats(gameType);
      return MapEntry(gameType, stats.winRate);
    }).toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 &&
                    value.toInt() < MiniGameType.values.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      MiniGameType.values[value.toInt()].icon,
                      style: const TextStyle(fontSize: 20),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text('${value.toInt()}%',
                    style: const TextStyle(fontSize: 10));
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 25,
        ),
        borderData: FlBorderData(show: false),
        barGroups: data.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.value,
                color: Color(entry.value.key.colorValue),
                width: 32,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildModelPerformanceChart(Map<String, dynamic> modelsData) {
    final entries = modelsData.entries.toList();
    if (entries.isEmpty) {
      return const Center(child: Text('No hay datos disponibles'));
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < entries.length) {
                  final modelName = entries[value.toInt()].key;
                  // Mostrar solo las primeras 3 letras
                  final shortName = modelName.length > 3
                      ? modelName.substring(0, 3)
                      : modelName;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      shortName,
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text('${value.toInt()}%',
                    style: const TextStyle(fontSize: 10));
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 25,
        ),
        borderData: FlBorderData(show: false),
        barGroups: entries.asMap().entries.map((entry) {
          final data = entry.value.value as Map<String, dynamic>;
          final successRate = (data['success_rate'] as double) * 100;
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: successRate,
                color: Colors.blue,
                width: 24,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
