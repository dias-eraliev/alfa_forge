import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../app/theme.dart';
import '../models/measurement_model.dart';
import '../models/measurement_history_model.dart';

class MeasurementHistoryDialog extends StatefulWidget {
  final List<BodyMeasurement> initialMeasurements;

  const MeasurementHistoryDialog({
    super.key,
    this.initialMeasurements = const [],
  });

  @override
  State<MeasurementHistoryDialog> createState() => _MeasurementHistoryDialogState();
}

class _MeasurementHistoryDialogState extends State<MeasurementHistoryDialog>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _chartController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _chartAnimation;

  int _selectedTab = 0;
  final List<String> _tabs = ['История', 'Графики', 'Статистика'];
  
  HistoryFilter _filter = HistoryFilter();
  late MeasurementHistory _history;
  late List<BodyMeasurement> _allMeasurements;
  
  String? _selectedMeasurementType;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    // Используем только реальные данные из API; без моков.
    // Если список пуст — показываем пустое состояние.
    _allMeasurements = List.from(widget.initialMeasurements);
    
    _updateHistory();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _chartController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack));
    
    _chartAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _chartController, curve: Curves.easeOutQuart),
    );

    _slideController.forward();
    _chartController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _chartController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _updateHistory() {
    _history = MeasurementHistory.fromMeasurements(_allMeasurements, _filter.period);
  }

  void _updateFilter(HistoryFilter newFilter) {
    setState(() {
      _filter = newFilter;
      _updateHistory();
    });
    _chartController.reset();
    _chartController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: PRIMETheme.bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Заголовок
            _buildHeader(),
            
            // Фильтры
            _buildFilters(),
            
            // Табы
            _buildTabs(),
            
            // Контент
            Expanded(
              child: _buildTabContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  PRIMETheme.primary,
                  PRIMETheme.primary.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.history,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'История измерений',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_history.getTotalMeasurements()} измерений за ${_filter.period.name.toLowerCase()}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: PRIMETheme.sandWeak,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: PRIMETheme.sandWeak),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          // Период и поиск
          Row(
            children: [
              // Селектор периода
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: PRIMETheme.line.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: PRIMETheme.line),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<HistoryPeriod>(
                      value: _filter.period,
                      icon: const Icon(Icons.keyboard_arrow_down, color: PRIMETheme.primary),
                      isExpanded: true,
                      style: Theme.of(context).textTheme.bodyMedium,
                      onChanged: (HistoryPeriod? value) {
                        if (value != null) {
                          _updateFilter(_filter.copyWith(period: value));
                        }
                      },
                      items: HistoryPeriod.values.map((period) {
                        return DropdownMenuItem<HistoryPeriod>(
                          value: period,
                          child: Text(period.name),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Поиск
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Поиск измерений...',
                    prefixIcon: const Icon(Icons.search, color: PRIMETheme.sandWeak),
                    filled: true,
                    fillColor: PRIMETheme.line.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: PRIMETheme.line),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: PRIMETheme.line),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: PRIMETheme.primary),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                  onChanged: (value) {
                    _updateFilter(_filter.copyWith(searchQuery: value.isEmpty ? null : value));
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Фильтр по типам измерений
          if (_history.getActiveMeasurementTypes().isNotEmpty)
            SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _history.getActiveMeasurementTypes().length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: const Text('Все'),
                        selected: _filter.selectedTypes.isEmpty,
                        onSelected: (selected) {
                          if (selected) {
                            _updateFilter(_filter.copyWith(selectedTypes: {}));
                          }
                        },
                        backgroundColor: PRIMETheme.line.withOpacity(0.1),
                        selectedColor: PRIMETheme.primary.withOpacity(0.2),
                        checkmarkColor: PRIMETheme.primary,
                        labelStyle: TextStyle(
                          color: _filter.selectedTypes.isEmpty 
                            ? PRIMETheme.primary 
                            : PRIMETheme.sandWeak,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }
                  
                  final typeId = _history.getActiveMeasurementTypes()[index - 1];
                  final measurementType = MeasurementTypes.getById(typeId);
                  if (measurementType == null) return const SizedBox.shrink();
                  final isSelected = _filter.selectedTypes.contains(typeId);
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(measurementType.name),
                      selected: isSelected,
                      onSelected: (selected) {
                        final newSelectedTypes = Set<String>.from(_filter.selectedTypes);
                        if (selected) {
                          newSelectedTypes.add(typeId);
                        } else {
                          newSelectedTypes.remove(typeId);
                        }
                        _updateFilter(_filter.copyWith(selectedTypes: newSelectedTypes));
                      },
                      backgroundColor: PRIMETheme.line.withOpacity(0.1),
                      selectedColor: PRIMETheme.primary.withOpacity(0.2),
                      checkmarkColor: PRIMETheme.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? PRIMETheme.primary : PRIMETheme.sandWeak,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: PRIMETheme.line.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: _tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final title = entry.value;
          final isSelected = _selectedTab == index;
          
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTab = index;
                });
                _chartController.reset();
                _chartController.forward();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected ? LinearGradient(
                    colors: [
                      PRIMETheme.primary,
                      PRIMETheme.primary.withOpacity(0.8),
                    ],
                  ) : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected ? Colors.white : PRIMETheme.sandWeak,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent() {
    return AnimatedBuilder(
      animation: _chartAnimation,
      builder: (context, child) {
        switch (_selectedTab) {
          case 0:
            return _buildHistoryTab();
          case 1:
            return _buildChartsTab();
          case 2:
            return _buildStatisticsTab();
          default:
            return _buildHistoryTab();
        }
      },
    );
  }

  Widget _buildHistoryTab() {
    final measurements = _history.getAllMeasurements();
    final measurementsByDate = _history.getMeasurementsByDate();
    
    if (measurements.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Краткая статистика
          _buildQuickStats(),
          const SizedBox(height: 24),
          
          // Временная линия
          Text(
            'Временная линия',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Группировка по датам
          ...measurementsByDate.entries.map((entry) {
            final date = entry.key;
            final dayMeasurements = entry.value;
            
            return _buildDayMeasurements(date, dayMeasurements);
          }),
        ],
      ),
    );
  }

  Widget _buildChartsTab() {
    final activeTypes = _history.getActiveMeasurementTypes();
    
    if (activeTypes.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Селектор типа измерения для детального графика
          _buildMeasurementTypeSelector(),
          const SizedBox(height: 24),
          
          // Детальный график выбранного типа
          if (_selectedMeasurementType != null) ...[
            _buildDetailedChart(_selectedMeasurementType!),
            const SizedBox(height: 24),
          ],
          
          // Мини-графики всех типов
          Text(
            'Обзор всех измерений',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          ...activeTypes.map((typeId) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildMiniChart(typeId),
          )),
        ],
      ),
    );
  }

  Widget _buildStatisticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Общая статистика
          _buildOverallStatistics(),
          const SizedBox(height: 24),
          
          // Статистика по каждому типу
          Text(
            'Детальная статистика',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          ..._history.getActiveMeasurementTypes().map((typeId) {
            final stats = _history.getStatisticsForType(typeId);
            if (stats == null) return const SizedBox.shrink();
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildTypeStatistics(typeId, stats),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: PRIMETheme.line.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.timeline,
              size: 48,
              color: PRIMETheme.sandWeak,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Нет данных за выбранный период',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: PRIMETheme.sandWeak,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Добавьте измерения или измените период',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: PRIMETheme.sandWeak,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final totalMeasurements = _history.getTotalMeasurements();
    final uniqueDays = _history.getUniqueMeasurementDates().length;
    final activeTypes = _history.getActiveMeasurementTypes().length;
    
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Измерений',
            totalMeasurements.toString(),
            Icons.straighten,
            PRIMETheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Дней',
            uniqueDays.toString(),
            Icons.calendar_today,
            PRIMETheme.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Типов',
            activeTypes.toString(),
            Icons.category,
            const Color(0xFFFF7043),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: PRIMETheme.sandWeak,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayMeasurements(DateTime date, List<BodyMeasurement> measurements) {
    final now = DateTime.now();
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
    final isYesterday = date.year == now.year && date.month == now.month && date.day == now.day - 1;
    
    String dateText;
    if (isToday) {
      dateText = 'Сегодня';
    } else if (isYesterday) {
      dateText = 'Вчера';
    } else {
      dateText = '${date.day}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок дня
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isToday ? PRIMETheme.primary : PRIMETheme.sandWeak,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  dateText,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isToday ? PRIMETheme.primary : null,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: PRIMETheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${measurements.length}',
                    style: const TextStyle(
                      color: PRIMETheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Карточки измерений
          ...measurements.map((measurement) => _buildMeasurementCard(measurement)),
        ],
      ),
    );
  }

  Widget _buildMeasurementCard(BodyMeasurement measurement) {
    final measurementType = MeasurementTypes.getById(measurement.typeId);
    if (measurementType == null) return const SizedBox.shrink();
    final category = measurementType.category;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PRIMETheme.line),
      ),
      child: Row(
        children: [
          // Иконка категории
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: category.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              measurementType.icon,
              color: category.color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          
          // Информация об измерении
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  measurementType.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                if (measurement.notes?.isNotEmpty == true)
                  Text(
                    measurement.notes!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: PRIMETheme.sandWeak,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          
          // Значение и время
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${measurement.value.toStringAsFixed(measurementType.decimalPlaces)}${measurementType.unit.symbol}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: category.color,
                ),
              ),
              Text(
                '${measurement.timestamp.hour.toString().padLeft(2, '0')}:${measurement.timestamp.minute.toString().padLeft(2, '0')}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: PRIMETheme.sandWeak,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementTypeSelector() {
    final activeTypes = _history.getActiveMeasurementTypes();
    if (activeTypes.isEmpty) return const SizedBox.shrink();
    
    // Устанавливаем первый тип по умолчанию
    _selectedMeasurementType ??= activeTypes.first;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Детальный график',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: activeTypes.length,
            itemBuilder: (context, index) {
              final typeId = activeTypes[index];
              final measurementType = MeasurementTypes.getById(typeId);
              if (measurementType == null) return const SizedBox.shrink();
              final isSelected = _selectedMeasurementType == typeId;
              
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMeasurementType = typeId;
                    });
                    _chartController.reset();
                    _chartController.forward();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: isSelected ? LinearGradient(
                        colors: [
                          PRIMETheme.primary,
                          PRIMETheme.primary.withOpacity(0.8),
                        ],
                      ) : null,
                      color: isSelected ? null : PRIMETheme.line.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? PRIMETheme.primary : PRIMETheme.line,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          measurementType.icon,
                          color: isSelected ? Colors.white : PRIMETheme.sandWeak,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          measurementType.name,
                          style: TextStyle(
                            color: isSelected ? Colors.white : PRIMETheme.sandWeak,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedChart(String typeId) {
    final measurements = _history.getMeasurementsForType(typeId);
    final measurementType = MeasurementTypes.getById(typeId);
    if (measurementType == null) return const SizedBox.shrink();
    final stats = _history.getStatisticsForType(typeId);
    
    if (measurements.isEmpty || stats == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            PRIMETheme.primary.withOpacity(0.1),
            PRIMETheme.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PRIMETheme.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок графика
          Row(
            children: [
              Icon(measurementType.icon, color: PRIMETheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  measurementType.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: stats.trend.color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      stats.trend.icon,
                      color: Colors.white,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      stats.getChangeText(measurementType.unit),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // График
          SizedBox(
            height: 200,
            child: CustomPaint(
              size: const Size(double.infinity, 200),
              painter: _DetailedChartPainter(
                measurements: measurements,
                measurementType: measurementType,
                animation: _chartAnimation.value,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Статистика под графиком
          Row(
            children: [
              Expanded(
                child: _buildChartStat('Текущее', stats.currentValue, measurementType.unit),
              ),
              Expanded(
                child: _buildChartStat('Среднее', stats.avgValue, measurementType.unit),
              ),
              Expanded(
                child: _buildChartStat('Мин', stats.minValue, measurementType.unit),
              ),
              Expanded(
                child: _buildChartStat('Макс', stats.maxValue, measurementType.unit),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartStat(String label, double? value, MeasurementUnit unit) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: PRIMETheme.sandWeak,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value != null 
            ? '${value.toStringAsFixed(1)}${unit.symbol}'
            : '-',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: PRIMETheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniChart(String typeId) {
    final measurements = _history.getMeasurementsForType(typeId);
    final measurementType = MeasurementTypes.getById(typeId);
    if (measurementType == null) return const SizedBox.shrink();
    final stats = _history.getStatisticsForType(typeId);
    
    if (measurements.isEmpty || stats == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PRIMETheme.line),
      ),
      child: Row(
        children: [
          // Иконка и название
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(measurementType.icon, color: PRIMETheme.primary, size: 20),
              const SizedBox(height: 4),
              Text(
                measurementType.name,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${stats.totalMeasurements} измерений',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: PRIMETheme.sandWeak,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          
          // Мини-график
          Expanded(
            child: SizedBox(
              height: 60,
              child: CustomPaint(
                size: const Size(double.infinity, 60),
                painter: _MiniChartPainter(
                  measurements: measurements,
                  animation: _chartAnimation.value,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Значение и тренд
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${stats.currentValue?.toStringAsFixed(measurementType.decimalPlaces)}${measurementType.unit.symbol}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: stats.trend.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      stats.trend.icon,
                      color: stats.trend.color,
                      size: 12,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      stats.getChangeText(measurementType.unit),
                      style: TextStyle(
                        color: stats.trend.color,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverallStatistics() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            PRIMETheme.success.withOpacity(0.15),
            PRIMETheme.success.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PRIMETheme.success.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: PRIMETheme.success, size: 24),
              const SizedBox(width: 12),
              Text(
                'Общая статистика за ${_filter.period.name.toLowerCase()}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildOverallStatCard(
                  'Всего измерений',
                  _history.getTotalMeasurements().toString(),
                  Icons.straighten,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildOverallStatCard(
                  'Активных дней',
                  _history.getUniqueMeasurementDates().length.toString(),
                  Icons.calendar_today,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildOverallStatCard(
                  'Типов измерений',
                  _history.getActiveMeasurementTypes().length.toString(),
                  Icons.category,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildOverallStatCard(
                  'Улучшений',
                  _history.statistics.values.where((s) => s.trend == TrendDirection.down || s.trend == TrendDirection.up).length.toString(),
                  Icons.trending_up,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverallStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: PRIMETheme.success, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: PRIMETheme.success,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: PRIMETheme.sandWeak,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeStatistics(String typeId, MeasurementStatistics stats) {
    final measurementType = MeasurementTypes.getById(typeId);
    if (measurementType == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PRIMETheme.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок
          Row(
            children: [
              Icon(measurementType.icon, color: PRIMETheme.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  measurementType.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: stats.trend.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(stats.trend.icon, color: stats.trend.color, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      stats.trend.name,
                      style: TextStyle(
                        color: stats.trend.color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Статистические показатели
          Row(
            children: [
              Expanded(
                child: _buildStatValue(
                  'Текущее',
                  stats.currentValue,
                  measurementType.unit,
                ),
              ),
              Expanded(
                child: _buildStatValue(
                  'Среднее',
                  stats.avgValue,
                  measurementType.unit,
                ),
              ),
              Expanded(
                child: _buildStatValue(
                  'Изменение',
                  stats.changeAmount,
                  measurementType.unit,
                  showSign: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildStatValue(
                  'Минимум',
                  stats.minValue,
                  measurementType.unit,
                ),
              ),
              Expanded(
                child: _buildStatValue(
                  'Максимум',
                  stats.maxValue,
                  measurementType.unit,
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Измерений',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: PRIMETheme.sandWeak,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stats.totalMeasurements.toString(),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatValue(String label, double? value, MeasurementUnit unit, {bool showSign = false}) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: PRIMETheme.sandWeak,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value != null 
            ? '${showSign && value >= 0 ? '+' : ''}${value.toStringAsFixed(1)}${unit.symbol}'
            : '-',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: showSign && value != null
              ? (value >= 0 ? PRIMETheme.success : const Color(0xFF2196F3))
              : null,
          ),
        ),
      ],
    );
  }
}

// Кастомные пейнтеры для графиков
class _DetailedChartPainter extends CustomPainter {
  final List<BodyMeasurement> measurements;
  final MeasurementType measurementType;
  final double animation;

  _DetailedChartPainter({
    required this.measurements,
    required this.measurementType,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (measurements.isEmpty) return;

    // Сортируем измерения по времени
    final sortedMeasurements = List<BodyMeasurement>.from(measurements)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final values = sortedMeasurements.map((m) => m.value).toList();
    final minValue = values.reduce(math.min);
    final maxValue = values.reduce(math.max);
    final range = maxValue - minValue;
    
    if (range == 0) return;

    // Настройка красок
    final linePaint = Paint()
      ..color = PRIMETheme.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final gradientPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          PRIMETheme.primary.withOpacity(0.3),
          PRIMETheme.primary.withOpacity(0.1),
          Colors.transparent,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final pointPaint = Paint()
      ..color = PRIMETheme.primary
      ..style = PaintingStyle.fill;

    // Создание путей
    final path = Path();
    final fillPath = Path();
    
    final animatedLength = (sortedMeasurements.length * animation).round();
    
    for (int i = 0; i < animatedLength; i++) {
      final x = (i / (sortedMeasurements.length - 1)) * size.width;
      final normalizedValue = (sortedMeasurements[i].value - minValue) / range;
      final y = size.height - (normalizedValue * size.height * 0.8 + size.height * 0.1);
      
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    
    // Заливка под графиком
    if (animatedLength > 0) {
      final lastX = ((animatedLength - 1) / (sortedMeasurements.length - 1)) * size.width;
      fillPath.lineTo(lastX, size.height);
      fillPath.close();
      canvas.drawPath(fillPath, gradientPaint);
    }
    
    // Линия графика
    canvas.drawPath(path, linePaint);
    
    // Точки
    for (int i = 0; i < animatedLength; i++) {
      final x = (i / (sortedMeasurements.length - 1)) * size.width;
      final normalizedValue = (sortedMeasurements[i].value - minValue) / range;
      final y = size.height - (normalizedValue * size.height * 0.8 + size.height * 0.1);
      
      // Внешняя точка
      canvas.drawCircle(Offset(x, y), 6, pointPaint);
      
      // Внутренняя точка
      final innerPaint = Paint()..color = Colors.white;
      canvas.drawCircle(Offset(x, y), 3, innerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _MiniChartPainter extends CustomPainter {
  final List<BodyMeasurement> measurements;
  final double animation;

  _MiniChartPainter({
    required this.measurements,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (measurements.isEmpty) return;

    final sortedMeasurements = List<BodyMeasurement>.from(measurements)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final values = sortedMeasurements.map((m) => m.value).toList();
    final minValue = values.reduce(math.min);
    final maxValue = values.reduce(math.max);
    final range = maxValue - minValue;
    
    if (range == 0) return;

    final paint = Paint()
      ..color = PRIMETheme.primary.withOpacity(0.8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final animatedLength = (sortedMeasurements.length * animation).round();
    
    for (int i = 0; i < animatedLength; i++) {
      final x = (i / (sortedMeasurements.length - 1)) * size.width;
      final normalizedValue = (sortedMeasurements[i].value - minValue) / range;
      final y = size.height - (normalizedValue * size.height * 0.8 + size.height * 0.1);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
