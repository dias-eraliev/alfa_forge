import 'package:flutter/material.dart';
import '../models/habit_model.dart';
import '../data/habit_templates.dart';
import '../widgets/frequency_selector.dart';
import '../../../app/theme.dart';

class AdvancedAddHabitDialog extends StatefulWidget {
  final Function(HabitModel) onHabitAdded;

  const AdvancedAddHabitDialog({
    super.key,
    required this.onHabitAdded,
  });

  @override
  State<AdvancedAddHabitDialog> createState() => _AdvancedAddHabitDialogState();
}

class _AdvancedAddHabitDialogState extends State<AdvancedAddHabitDialog>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  
  int _currentStep = 0;
  final int _totalSteps = 5;

  // Данные формы
  HabitTemplate? _selectedTemplate;
  bool _isCustomHabit = false;
  
  // Основная информация
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _motivationController = TextEditingController();
  IconData _selectedIcon = Icons.star;
  Color _selectedColor = const Color(0xFF2196F3);
  HabitCategory _selectedCategory = HabitCategory.other;
  
  // Настройки выполнения
  HabitFrequency _frequency = HabitFrequency(type: HabitFrequencyType.daily);
  TimeOfDay? _reminderTime;
  int? _duration;
  HabitDifficulty _difficulty = HabitDifficulty.medium;
  
  // Мотивация и цели
  final TextEditingController _goalController = TextEditingController();
  List<String> _tags = [];
  final TextEditingController _tagController = TextEditingController();
  
  // Настройки уведомлений
  bool _enableReminders = true;
  final List<String> _motivationalMessages = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
    _updateProgress();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _motivationController.dispose();
    _goalController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _updateProgress() {
    final progress = (_currentStep + 1) / _totalSteps;
    _progressController.animateTo(progress);
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
      _updateProgress();
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
      _updateProgress();
    }
  }

  void _selectTemplate(HabitTemplate template) {
    setState(() {
      _selectedTemplate = template;
      _isCustomHabit = false;
      
      // Заполняем данные из шаблона
      _nameController.text = template.name;
      _descriptionController.text = template.description;
      _motivationController.text = template.motivation;
      _selectedIcon = template.icon;
      _selectedColor = template.color;
      _selectedCategory = template.category;
      _frequency = template.defaultFrequency;
      _duration = template.defaultDuration;
      _difficulty = template.defaultDifficulty;
      _tags = List.from(template.defaultTags);
    });
    _nextStep();
  }

  void _createCustomHabit() {
    setState(() {
      _isCustomHabit = true;
      _selectedTemplate = null;
    });
    _nextStep();
  }

  void _createHabit() {
    final habit = HabitModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      motivation: _motivationController.text.trim(),
      icon: _selectedIcon,
      color: _selectedColor,
      category: _selectedCategory,
      frequency: _frequency,
      duration: _duration,
      difficulty: _difficulty,
      tags: _tags,
      enableReminders: _enableReminders,
      reminderTime: _reminderTime,
      motivationalMessages: _motivationalMessages,
      createdAt: DateTime.now(),
    );

    widget.onHabitAdded(habit);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 400;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 16 : 24,
        vertical: isSmallScreen ? 40 : 60,
      ),
      child: Container(
        width: double.infinity,
        height: screenHeight * 0.85,
        decoration: BoxDecoration(
          color: PRIMETheme.bg,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Заголовок с прогрессом
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    PRIMETheme.primary.withOpacity(0.1),
                    PRIMETheme.primary.withOpacity(0.05),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        color: PRIMETheme.primary,
                        size: isSmallScreen ? 24 : 28,
                      ),
                      SizedBox(width: isSmallScreen ? 8 : 12),
                      Expanded(
                        child: Text(
                          'Создание новой привычки',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: isSmallScreen ? 18 : 22,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: PRIMETheme.sand),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: isSmallScreen ? 16 : 20),
                  
                  // Прогресс-бар
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: PRIMETheme.line.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: _progressAnimation.value,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [PRIMETheme.primary, PRIMETheme.primary.withOpacity(0.8)],
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  SizedBox(height: isSmallScreen ? 8 : 12),
                  
                  Text(
                    'Шаг ${_currentStep + 1} из $_totalSteps',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: PRIMETheme.sandWeak,
                      fontSize: isSmallScreen ? 12 : 14,
                    ),
                  ),
                ],
              ),
            ),
            
            // Контент страниц
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildTemplateSelectionStep(),
                  _buildBasicInfoStep(),
                  _buildFrequencyStep(),
                  _buildMotivationStep(),
                  _buildSettingsStep(),
                ],
              ),
            ),
            
            // Кнопки навигации
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: PRIMETheme.line)),
              ),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: InkWell(
                        onTap: _previousStep,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: isSmallScreen ? 12 : 16,
                          ),
                          decoration: BoxDecoration(
                            color: PRIMETheme.line.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: PRIMETheme.line),
                          ),
                          child: Text(
                            'Назад',
                            style: TextStyle(
                              color: PRIMETheme.sand,
                              fontWeight: FontWeight.w600,
                              fontSize: isSmallScreen ? 16 : 18,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  
                  if (_currentStep > 0) const SizedBox(width: 12),
                  
                  Expanded(
                    flex: 2,
                    child: InkWell(
                      onTap: _currentStep == _totalSteps - 1 ? _createHabit : _nextStep,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: isSmallScreen ? 12 : 16,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [PRIMETheme.primary, PRIMETheme.primary.withOpacity(0.8)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: PRIMETheme.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          _currentStep == _totalSteps - 1 ? 'Создать привычку' : 'Далее',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: isSmallScreen ? 16 : 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateSelectionStep() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Выберите тип привычки',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 20 : 24,
            ),
          ),
          
          SizedBox(height: isSmallScreen ? 8 : 12),
          
          Text(
            'Используйте готовый шаблон или создайте свою уникальную привычку',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: PRIMETheme.sandWeak,
              fontSize: isSmallScreen ? 14 : 16,
            ),
          ),
          
          SizedBox(height: isSmallScreen ? 20 : 24),
          
          // Кнопка создания собственной привычки
          InkWell(
            onTap: _createCustomHabit,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
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
              child: Row(
                children: [
                  Container(
                    width: isSmallScreen ? 48 : 56,
                    height: isSmallScreen ? 48 : 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [PRIMETheme.primary, PRIMETheme.primary.withOpacity(0.8)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.create,
                      color: Colors.white,
                      size: isSmallScreen ? 24 : 28,
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 16 : 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Создать собственную',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: PRIMETheme.primary,
                            fontSize: isSmallScreen ? 16 : 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Настройте привычку полностью под себя',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: PRIMETheme.sandWeak,
                            fontSize: isSmallScreen ? 14 : 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: PRIMETheme.primary,
                    size: isSmallScreen ? 16 : 20,
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: isSmallScreen ? 24 : 32),
          
          Text(
            'Популярные шаблоны',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 18 : 20,
            ),
          ),
          
          SizedBox(height: isSmallScreen ? 12 : 16),
          
          // Популярные шаблоны
          ...HabitTemplatesLibrary.getPopularTemplates().map((template) => 
            _buildTemplateCard(template, isSmallScreen),
          ),
          
          SizedBox(height: isSmallScreen ? 20 : 24),
          
          Text(
            'Все категории',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 18 : 20,
            ),
          ),
          
          SizedBox(height: isSmallScreen ? 12 : 16),
          
          // Категории
          ...HabitCategory.values.map((category) => 
            _buildCategorySection(category, isSmallScreen),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(HabitTemplate template, bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 8 : 12),
      child: InkWell(
        onTap: () => _selectTemplate(template),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: template.color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: isSmallScreen ? 40 : 48,
                height: isSmallScreen ? 40 : 48,
                decoration: BoxDecoration(
                  color: template.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  template.icon,
                  color: template.color,
                  size: isSmallScreen ? 20 : 24,
                ),
              ),
              SizedBox(width: isSmallScreen ? 12 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 14 : 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      template.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: PRIMETheme.sandWeak,
                        fontSize: isSmallScreen ? 12 : 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (template.defaultTags.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        children: template.defaultTags.take(3).map((tag) =>
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: template.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                color: template.color,
                                fontSize: isSmallScreen ? 10 : 12,
                              ),
                            ),
                          ),
                        ).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: PRIMETheme.sandWeak,
                size: isSmallScreen ? 14 : 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection(HabitCategory category, bool isSmallScreen) {
    final templates = HabitTemplatesLibrary.getTemplatesByCategory(category);
    if (templates.isEmpty) return const SizedBox.shrink();

    return ExpansionTile(
      leading: Icon(category.icon, color: category.color),
      title: Text(
        category.displayName,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: isSmallScreen ? 14 : 16,
        ),
      ),
      children: templates.map((template) => 
        _buildTemplateCard(template, isSmallScreen),
      ).toList(),
    );
  }

  Widget _buildBasicInfoStep() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Основная информация',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 20 : 24,
            ),
          ),
          
          SizedBox(height: isSmallScreen ? 20 : 24),
          
          // Название
          Text(
            'Название привычки',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 16 : 18,
            ),
          ),
          
          SizedBox(height: isSmallScreen ? 8 : 12),
          
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Например: Утренняя зарядка',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: PRIMETheme.line),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: PRIMETheme.primary, width: 2),
              ),
            ),
          ),
          
          SizedBox(height: isSmallScreen ? 16 : 20),
          
          // Описание
          Text(
            'Описание (необязательно)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 16 : 18,
            ),
          ),
          
          SizedBox(height: isSmallScreen ? 8 : 12),
          
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Краткое описание того, что включает эта привычка',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: PRIMETheme.line),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: PRIMETheme.primary, width: 2),
              ),
            ),
          ),
          
          SizedBox(height: isSmallScreen ? 16 : 20),
          
          // Категория
          Text(
            'Категория',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 16 : 18,
            ),
          ),
          
          SizedBox(height: isSmallScreen ? 8 : 12),
          
          _buildCategorySelector(isSmallScreen),
          
          SizedBox(height: isSmallScreen ? 16 : 20),
          
          // Иконка и цвет
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Иконка',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 16 : 18,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 8 : 12),
                    _buildIconSelector(isSmallScreen),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Цвет',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 16 : 18,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 8 : 12),
                    _buildColorSelector(isSmallScreen),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector(bool isSmallScreen) {
    return Wrap(
      spacing: isSmallScreen ? 6 : 8,
      runSpacing: isSmallScreen ? 6 : 8,
      children: HabitCategory.values.map((category) {
        final isSelected = _selectedCategory == category;
        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = category),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12 : 16,
              vertical: isSmallScreen ? 8 : 12,
            ),
            decoration: BoxDecoration(
              color: isSelected ? category.color.withOpacity(0.2) : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? category.color : PRIMETheme.line,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  category.icon,
                  color: isSelected ? category.color : PRIMETheme.sandWeak,
                  size: isSmallScreen ? 16 : 20,
                ),
                const SizedBox(width: 6),
                Text(
                  category.displayName,
                  style: TextStyle(
                    color: isSelected ? category.color : PRIMETheme.sand,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: isSmallScreen ? 12 : 14,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildIconSelector(bool isSmallScreen) {
    final icons = [
      Icons.star, Icons.favorite, Icons.bolt, Icons.fitness_center,
      Icons.book, Icons.water_drop, Icons.music_note, Icons.palette,
      Icons.school, Icons.work, Icons.home, Icons.restaurant,
    ];

    return Container(
      height: isSmallScreen ? 60 : 80,
      padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PRIMETheme.line),
      ),
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: isSmallScreen ? 4 : 8,
          crossAxisSpacing: isSmallScreen ? 4 : 8,
        ),
        itemCount: icons.length,
        itemBuilder: (context, index) {
          final icon = icons[index];
          final isSelected = _selectedIcon == icon;
          return GestureDetector(
            onTap: () => setState(() => _selectedIcon = icon),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? _selectedColor.withOpacity(0.2) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: isSelected ? Border.all(color: _selectedColor, width: 2) : null,
              ),
              child: Icon(
                icon,
                color: isSelected ? _selectedColor : PRIMETheme.sandWeak,
                size: isSmallScreen ? 16 : 20,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildColorSelector(bool isSmallScreen) {
    final colors = [
      const Color(0xFF2196F3), const Color(0xFF4CAF50), const Color(0xFFFF9800),
      const Color(0xFFF44336), const Color(0xFF9C27B0), const Color(0xFF00BCD4),
      const Color(0xFFFFEB3B), const Color(0xFF795548), const Color(0xFF607D8B),
      const Color(0xFFE91E63), const Color(0xFF673AB7), const Color(0xFF009688),
    ];

    return Container(
      height: isSmallScreen ? 60 : 80,
      padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PRIMETheme.line),
      ),
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: isSmallScreen ? 4 : 8,
          crossAxisSpacing: isSmallScreen ? 4 : 8,
        ),
        itemCount: colors.length,
        itemBuilder: (context, index) {
          final color = colors[index];
          final isSelected = _selectedColor == color;
          return GestureDetector(
            onTap: () => setState(() => _selectedColor = color),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ] : null,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFrequencyStep() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Настройки выполнения',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 20 : 24,
            ),
          ),
          
          SizedBox(height: isSmallScreen ? 20 : 24),
          
          FrequencySelector(
            frequency: _frequency,
            onChanged: (frequency) => setState(() => _frequency = frequency),
          ),
          
          SizedBox(height: isSmallScreen ? 20 : 24),
          
          // Продолжительность
          Text(
            'Продолжительность (минуты)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 16 : 18,
            ),
          ),
          
          SizedBox(height: isSmallScreen ? 8 : 12),
          
          TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Например: 30',
              suffixText: 'мин',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: PRIMETheme.line),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: PRIMETheme.primary, width: 2),
              ),
            ),
            onChanged: (value) {
              final duration = int.tryParse(value);
              setState(() => _duration = duration);
            },
          ),
          
          SizedBox(height: isSmallScreen ? 20 : 24),
          
          // Сложность
          Text(
            'Сложность',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 16 : 18,
            ),
          ),
          
          SizedBox(height: isSmallScreen ? 8 : 12),
          
          Row(
            children: HabitDifficulty.values.map((difficulty) {
              final isSelected = _difficulty == difficulty;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _difficulty = difficulty),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                    decoration: BoxDecoration(
                      color: isSelected ? difficulty.color.withOpacity(0.2) : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? difficulty.color : PRIMETheme.line,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _getDifficultyIcon(difficulty),
                          color: isSelected ? difficulty.color : PRIMETheme.sandWeak,
                          size: isSmallScreen ? 20 : 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          difficulty.displayName,
                          style: TextStyle(
                            color: isSelected ? difficulty.color : PRIMETheme.sand,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: isSmallScreen ? 12 : 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMotivationStep() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Мотивация и цели',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 20 : 24,
            ),
          ),
          
          SizedBox(height: isSmallScreen ? 20 : 24),
          
          // Мотивация
          Text(
            'Почему эта привычка важна для вас?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 16 : 18,
            ),
          ),
          
          SizedBox(height: isSmallScreen ? 8 : 12),
          
          TextField(
            controller: _motivationController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Например: Хочу быть более энергичным и здоровым',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: PRIMETheme.line),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: PRIMETheme.primary, width: 2),
              ),
            ),
          ),
          
          SizedBox(height: isSmallScreen ? 20 : 24),
          
          // Цель
          Text(
            'Какого результата хотите достичь?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 16 : 18,
            ),
          ),
          
          SizedBox(height: isSmallScreen ? 8 : 12),
          
          TextField(
            controller: _goalController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Например: Сбросить 5 кг за 3 месяца',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: PRIMETheme.line),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: PRIMETheme.primary, width: 2),
              ),
            ),
          ),
          
          SizedBox(height: isSmallScreen ? 20 : 24),
          
          // Теги
          Text(
            'Теги (необязательно)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 16 : 18,
            ),
          ),
          
          SizedBox(height: isSmallScreen ? 8 : 12),
          
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _tagController,
                  decoration: InputDecoration(
                    hintText: 'Добавить тег',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: PRIMETheme.line),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: PRIMETheme.primary, width: 2),
                    ),
                  ),
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty && !_tags.contains(value.trim())) {
                      setState(() {
                        _tags.add(value.trim());
                        _tagController.clear();
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  final value = _tagController.text.trim();
                  if (value.isNotEmpty && !_tags.contains(value)) {
                    setState(() {
                      _tags.add(value);
                      _tagController.clear();
                    });
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                  decoration: BoxDecoration(
                    color: PRIMETheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: isSmallScreen ? 20 : 24,
                  ),
                ),
              ),
            ],
          ),
          
          if (_tags.isNotEmpty) ...[
            SizedBox(height: isSmallScreen ? 12 : 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _tags.map((tag) =>
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _selectedColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _selectedColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tag,
                        style: TextStyle(
                          color: _selectedColor,
                          fontSize: isSmallScreen ? 12 : 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => setState(() => _tags.remove(tag)),
                        child: Icon(
                          Icons.close,
                          color: _selectedColor,
                          size: isSmallScreen ? 14 : 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSettingsStep() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Финальные настройки',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 20 : 24,
            ),
          ),
          
          SizedBox(height: isSmallScreen ? 20 : 24),
          
          // Уведомления
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: PRIMETheme.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.notifications,
                      color: _enableReminders ? PRIMETheme.primary : PRIMETheme.sandWeak,
                      size: isSmallScreen ? 20 : 24,
                    ),
                    SizedBox(width: isSmallScreen ? 8 : 12),
                    Expanded(
                      child: Text(
                        'Напоминания',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 16 : 18,
                        ),
                      ),
                    ),
                    Switch(
                      value: _enableReminders,
                      onChanged: (value) => setState(() => _enableReminders = value),
                      activeThumbColor: PRIMETheme.primary,
                    ),
                  ],
                ),
                
                if (_enableReminders) ...[
                  SizedBox(height: isSmallScreen ? 12 : 16),
                  Text(
                    'Время напоминания:',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 8 : 12),
                  InkWell(
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _reminderTime ?? const TimeOfDay(hour: 9, minute: 0),
                      );
                      if (time != null) {
                        setState(() => _reminderTime = time);
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 12 : 16,
                        vertical: isSmallScreen ? 12 : 16,
                      ),
                      decoration: BoxDecoration(
                        color: PRIMETheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: PRIMETheme.primary.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: PRIMETheme.primary,
                            size: isSmallScreen ? 16 : 20,
                          ),
                          SizedBox(width: isSmallScreen ? 8 : 12),
                          Text(
                            _reminderTime != null
                                ? _reminderTime!.format(context)
                                : 'Выберите время',
                            style: TextStyle(
                              color: PRIMETheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: isSmallScreen ? 14 : 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          SizedBox(height: isSmallScreen ? 20 : 24),
          
          // Превью привычки
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _selectedColor.withOpacity(0.1),
                  _selectedColor.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _selectedColor.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: isSmallScreen ? 48 : 56,
                      height: isSmallScreen ? 48 : 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_selectedColor, _selectedColor.withOpacity(0.8)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        _selectedIcon,
                        color: Colors.white,
                        size: isSmallScreen ? 24 : 28,
                      ),
                    ),
                    SizedBox(width: isSmallScreen ? 12 : 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _nameController.text.isNotEmpty 
                                ? _nameController.text 
                                : 'Новая привычка',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _selectedColor,
                              fontSize: isSmallScreen ? 16 : 18,
                            ),
                          ),
                          if (_descriptionController.text.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              _descriptionController.text,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: PRIMETheme.sandWeak,
                                fontSize: isSmallScreen ? 14 : 16,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: isSmallScreen ? 12 : 16),
                
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _selectedColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _frequency.displayText,
                        style: TextStyle(
                          color: _selectedColor,
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 12 : 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _difficulty.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _difficulty.displayName,
                        style: TextStyle(
                          color: _difficulty.color,
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 12 : 14,
                        ),
                      ),
                    ),
                    if (_duration != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: PRIMETheme.sandWeak.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$_duration мин',
                          style: TextStyle(
                            color: PRIMETheme.sandWeak,
                            fontWeight: FontWeight.bold,
                            fontSize: isSmallScreen ? 12 : 14,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getDifficultyIcon(HabitDifficulty difficulty) {
    switch (difficulty) {
      case HabitDifficulty.easy:
        return Icons.sentiment_satisfied;
      case HabitDifficulty.medium:
        return Icons.sentiment_neutral;
      case HabitDifficulty.hard:
        return Icons.sentiment_very_dissatisfied;
    }
  }
}
