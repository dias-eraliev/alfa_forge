import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../app/theme.dart';
import '../models/measurement_model.dart';

class AdvancedAddMeasurementDialog extends StatefulWidget {
  final Function(Map<String, double>) onMeasurementsAdded;

  const AdvancedAddMeasurementDialog({
    super.key,
    required this.onMeasurementsAdded,
  });

  @override
  State<AdvancedAddMeasurementDialog> createState() => _AdvancedAddMeasurementDialogState();
}

class _AdvancedAddMeasurementDialogState extends State<AdvancedAddMeasurementDialog>
    with TickerProviderStateMixin {
  
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late PageController _pageController;
  
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  int _currentStep = 0;
  final int _totalSteps = 4;

  // Данные формы
  MeasurementCategory? _selectedCategory;
  List<MeasurementType> _selectedTypes = [];
  final Map<String, double> _values = {};
  final Map<String, String> _conditions = {};
  String? _notes;
  String? _mood;
  double _confidence = 1.0;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _pageController = PageController();
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _submitForm() {
    // Валидация
    if (_values.isEmpty) {
      _showErrorSnackBar('Добавьте хотя бы одно измерение');
      return;
    }

    // Отправляем данные
    widget.onMeasurementsAdded(_values);
    Navigator.of(context).pop();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: PRIMETheme.warn,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        height: screenHeight * 0.9,
        decoration: const BoxDecoration(
          color: PRIMETheme.bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Заголовок и прогресс
              _buildHeader(),
              
              // Контент страниц
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStep1CategorySelection(),
                    _buildStep2MeasurementTypes(),
                    _buildStep3Values(),
                    _buildStep4ConditionsAndNotes(),
                  ],
                ),
              ),
              
              // Навигационные кнопки
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Полоска сверху
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: PRIMETheme.line,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          
          // Заголовок
          Row(
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
                  Icons.add_circle_outline,
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
                      _getStepTitle(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    Text(
                      _getStepSubtitle(),
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
          const SizedBox(height: 20),
          
          // Прогресс-бар
          _buildProgressBar(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Шаг ${_currentStep + 1} из $_totalSteps',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: PRIMETheme.sandWeak,
              ),
            ),
            Text(
              '${((_currentStep + 1) / _totalSteps * 100).toInt()}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: PRIMETheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (_currentStep + 1) / _totalSteps,
            backgroundColor: PRIMETheme.line,
            valueColor: const AlwaysStoppedAnimation<Color>(PRIMETheme.primary),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Выберите категорию';
      case 1:
        return 'Типы измерений';
      case 2:
        return 'Введите значения';
      case 3:
        return 'Условия и заметки';
      default:
        return 'Добавление измерений';
    }
  }

  String _getStepSubtitle() {
    switch (_currentStep) {
      case 0:
        return 'Какие показатели хотите измерить?';
      case 1:
        return 'Выберите конкретные измерения';
      case 2:
        return 'Укажите результаты измерений';
      case 3:
        return 'Добавьте дополнительную информацию';
      default:
        return '';
    }
  }

  // ШАГ 1: Выбор категории
  Widget _buildStep1CategorySelection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Выберите категорию измерений:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          ...MeasurementCategory.values.map((category) {
            final isSelected = _selectedCategory == category;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                      _selectedTypes.clear();
                      _values.clear();
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [
                                category.color.withOpacity(0.2),
                                category.color.withOpacity(0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isSelected ? null : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected 
                            ? category.color 
                            : PRIMETheme.line,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: category.color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            category.icon,
                            color: category.color,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            category.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: isSelected ? category.color : null,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: category.color,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          
          const SizedBox(height: 20),
          
          // Популярные измерения
          if (_selectedCategory == null) ...[
            Text(
              'Или выберите из популярных:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: MeasurementTypes.getPopular().map((type) {
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedCategory = type.category;
                        _selectedTypes = [type];
                      });
                      _nextStep();
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            type.category.color.withOpacity(0.15),
                            type.category.color.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: type.category.color.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            type.icon,
                            color: type.category.color,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            type.shortName,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: type.category.color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  // ШАГ 2: Выбор типов измерений
  Widget _buildStep2MeasurementTypes() {
    if (_selectedCategory == null) {
      return const Center(
        child: Text('Сначала выберите категорию'),
      );
    }

    final typesInCategory = MeasurementTypes.getByCategory(_selectedCategory!);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Выберите измерения в категории "${_selectedCategory!.name}":',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          ...typesInCategory.map((type) {
            final isSelected = _selectedTypes.contains(type);
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedTypes.remove(type);
                        _values.remove(type.id);
                      } else {
                        _selectedTypes.add(type);
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [
                                _selectedCategory!.color.withOpacity(0.2),
                                _selectedCategory!.color.withOpacity(0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isSelected ? null : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected 
                            ? _selectedCategory!.color 
                            : PRIMETheme.line,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _selectedCategory!.color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            type.icon,
                            color: _selectedCategory!.color,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                type.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: isSelected ? _selectedCategory!.color : null,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              if (type.description != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  type.description!,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: PRIMETheme.sandWeak,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 4),
                              Text(
                                'Единица: ${type.unit.symbol}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: _selectedCategory!.color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: _selectedCategory!.color,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          
          if (_selectedTypes.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    PRIMETheme.success.withOpacity(0.15),
                    PRIMETheme.success.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: PRIMETheme.success.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: PRIMETheme.success,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Выбрано: ${_selectedTypes.length} измерений',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: PRIMETheme.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ШАГ 3: Ввод значений
  Widget _buildStep3Values() {
    if (_selectedTypes.isEmpty) {
      return const Center(
        child: Text('Сначала выберите типы измерений'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Введите значения измерений:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          ..._selectedTypes.map((type) {
            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: _MeasurementValueInput(
                type: type,
                value: _values[type.id],
                onChanged: (value) {
                  setState(() {
                    if (value != null && value > 0) {
                      _values[type.id] = value;
                    } else {
                      _values.remove(type.id);
                    }
                  });
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  // ШАГ 4: Условия и заметки
  Widget _buildStep4ConditionsAndNotes() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Условия измерения
          Text(
            'Условия измерения (опционально):',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildConditionSection(
            'Время дня',
            'time_of_day',
            MeasurementConditions.timeOfDay,
            PRIMETheme.primary,
          ),
          const SizedBox(height: 16),
          
          _buildConditionSection(
            'Одежда',
            'clothing',
            MeasurementConditions.clothing,
            const Color(0xFF66BB6A),
          ),
          const SizedBox(height: 16),
          
          _buildConditionSection(
            'Состояние',
            'body_state',
            MeasurementConditions.bodyState,
            const Color(0xFFFF7043),
          ),
          const SizedBox(height: 16),
          
          _buildConditionSection(
            'Настроение',
            'mood',
            MeasurementConditions.mood,
            const Color(0xFF9C27B0),
          ),
          const SizedBox(height: 24),
          
          // Уверенность в измерении
          Text(
            'Уверенность в точности:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: PRIMETheme.primary,
              inactiveTrackColor: PRIMETheme.line,
              thumbColor: PRIMETheme.primary,
              overlayColor: PRIMETheme.primary.withOpacity(0.2),
            ),
            child: Slider(
              value: _confidence,
              min: 0.1,
              max: 1.0,
              divisions: 9,
              label: '${(_confidence * 100).toInt()}%',
              onChanged: (value) {
                setState(() {
                  _confidence = value;
                });
              },
            ),
          ),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Неуверен',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: PRIMETheme.sandWeak,
                ),
              ),
              Text(
                'Полностью уверен',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: PRIMETheme.sandWeak,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Заметки
          Text(
            'Заметки (опционально):',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          TextField(
            onChanged: (value) {
              _notes = value.isEmpty ? null : value;
            },
            maxLines: 3,
            style: const TextStyle(color: PRIMETheme.sand),
            decoration: InputDecoration(
              hintText: 'Добавьте комментарий к измерениям...',
              hintStyle: const TextStyle(color: PRIMETheme.sandWeak),
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: PRIMETheme.line),
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: PRIMETheme.line),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: PRIMETheme.primary),
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Theme.of(context).cardColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionSection(
    String title,
    String key,
    List<MeasurementCondition> conditions,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: conditions.map((condition) {
            final isSelected = _conditions[key] == condition.id;
            
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _conditions.remove(key);
                    } else {
                      _conditions[key] = condition.id;
                    }
                  });
                },
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [color, color.withOpacity(0.8)],
                          )
                        : null,
                    color: isSelected ? null : color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? color : color.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        condition.icon,
                        color: isSelected ? Colors.white : color,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        condition.name,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isSelected ? Colors.white : color,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Кнопка "Назад"
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: PRIMETheme.line),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.arrow_back,
                      color: PRIMETheme.sandWeak,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Назад',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: PRIMETheme.sandWeak,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          if (_currentStep > 0) const SizedBox(width: 12),
          
          // Кнопка "Далее" или "Сохранить"
          Expanded(
            flex: _currentStep == 0 ? 1 : 1,
            child: ElevatedButton(
              onPressed: _canProceed() 
                  ? (_currentStep == _totalSteps - 1 ? _submitForm : _nextStep)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: PRIMETheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _currentStep == _totalSteps - 1 ? 'Сохранить' : 'Далее',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _currentStep == _totalSteps - 1 ? Icons.save : Icons.arrow_forward,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _selectedCategory != null;
      case 1:
        return _selectedTypes.isNotEmpty;
      case 2:
        return _values.isNotEmpty;
      case 3:
        return true; // Условия опциональны
      default:
        return false;
    }
  }
}

// Виджет для ввода значения измерения
class _MeasurementValueInput extends StatefulWidget {
  final MeasurementType type;
  final double? value;
  final Function(double?) onChanged;

  const _MeasurementValueInput({
    required this.type,
    this.value,
    required this.onChanged,
  });

  @override
  State<_MeasurementValueInput> createState() => _MeasurementValueInputState();
}

class _MeasurementValueInputState extends State<_MeasurementValueInput> {
  late TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.value?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validateAndNotify(String value) {
    setState(() {
      _errorText = null;
    });

    if (value.isEmpty) {
      widget.onChanged(null);
      return;
    }

    final parsedValue = double.tryParse(value);
    if (parsedValue == null) {
      setState(() {
        _errorText = 'Введите корректное число';
      });
      widget.onChanged(null);
      return;
    }

    // Проверка диапазона
    if (widget.type.minValue != null && parsedValue < widget.type.minValue!) {
      setState(() {
        _errorText = 'Минимум: ${widget.type.minValue}';
      });
      widget.onChanged(null);
      return;
    }

    if (widget.type.maxValue != null && parsedValue > widget.type.maxValue!) {
      setState(() {
        _errorText = 'Максимум: ${widget.type.maxValue}';
      });
      widget.onChanged(null);
      return;
    }

    widget.onChanged(parsedValue);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.type.category.color.withOpacity(0.1),
            widget.type.category.color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _errorText != null 
              ? PRIMETheme.warn 
              : widget.type.category.color.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.type.category.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  widget.type.icon,
                  color: widget.type.category.color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.type.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: widget.type.category.color,
                  ),
                ),
              ),
              Text(
                widget.type.unit.symbol,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: widget.type.category.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          TextField(
            controller: _controller,
            onChanged: _validateAndNotify,
            keyboardType: widget.type.allowsDecimal 
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.number,
            style: const TextStyle(
              color: PRIMETheme.sand,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: _getHintText(),
              hintStyle: const TextStyle(color: PRIMETheme.sandWeak),
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: _errorText != null ? PRIMETheme.warn : PRIMETheme.line,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: _errorText != null ? PRIMETheme.warn : PRIMETheme.line,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: _errorText != null ? PRIMETheme.warn : widget.type.category.color,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Theme.of(context).cardColor,
              errorText: _errorText,
            ),
          ),
          
          if (widget.type.minValue != null || widget.type.maxValue != null) ...[
            const SizedBox(height: 8),
            Text(
              'Диапазон: ${widget.type.minValue ?? '?'} - ${widget.type.maxValue ?? '?'} ${widget.type.unit.symbol}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: PRIMETheme.sandWeak,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getHintText() {
    if (widget.type.defaultValue != null) {
      return 'Например: ${widget.type.defaultValue}';
    }
    
    if (widget.type.minValue != null && widget.type.maxValue != null) {
      final mid = (widget.type.minValue! + widget.type.maxValue!) / 2;
      return 'Например: ${widget.type.allowsDecimal ? mid.toStringAsFixed(1) : mid.toInt()}';
    }
    
    return 'Введите значение';
  }
}
