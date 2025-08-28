import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import 'controllers/workout_controller.dart';

class GTOPage extends ConsumerStatefulWidget {
  const GTOPage({super.key});

  @override
  ConsumerState<GTOPage> createState() => _GTOPageState();
}

class _GTOPageState extends ConsumerState<GTOPage> {
  int selectedAgeGroup = 0;
  String selectedGender = 'male';
  
  final List<Map<String, dynamic>> ageGroups = [
    {'name': '18-24 года', 'id': '18-24'},
    {'name': '25-29 лет', 'id': '25-29'},
    {'name': '30-34 года', 'id': '30-34'},
    {'name': '35-39 лет', 'id': '35-39'},
    {'name': '40-44 года', 'id': '40-44'},
    {'name': '45-49 лет', 'id': '45-49'},
    {'name': '50-59 лет', 'id': '50-59'},
  ];

  // Нормативы ГТО (примерные)
  Map<String, Map<String, Map<String, String>>> gtoNorms = {
    '18-24': {
      'male': {
        'run_100m': '13.5 сек',
        'run_3000m': '12:30 мин',
        'pullups': '13 раз',
        'pushups': '44 раза',
        'abs': '47 раз',
        'jump': '2.30 м',
        'flexibility': '+13 см',
      },
      'female': {
        'run_100m': '16.5 сек',
        'run_2000m': '10:50 мин',
        'pullups': '11 раз',
        'pushups': '16 раз',
        'abs': '40 раз',
        'jump': '1.90 м',
        'flexibility': '+16 см',
      },
    },
    '25-29': {
      'male': {
        'run_100m': '13.8 сек',
        'run_3000m': '13:00 мин',
        'pullups': '12 раз',
        'pushups': '42 раза',
        'abs': '45 раз',
        'jump': '2.25 м',
        'flexibility': '+12 см',
      },
      'female': {
        'run_100m': '17.0 сек',
        'run_2000m': '11:15 мин',
        'pullups': '10 раз',
        'pushups': '14 раз',
        'abs': '38 раз',
        'jump': '1.85 м',
        'flexibility': '+15 см',
      },
    },
  };

  List<Map<String, String>> get currentNorms {
    final ageGroupId = ageGroups[selectedAgeGroup]['id'];
    final norms = gtoNorms[ageGroupId]?[selectedGender] ?? {};
    
    return [
      {'name': 'Бег 100м', 'norm': norms['run_100m'] ?? 'Н/Д', 'icon': '🏃‍♂️'},
      {'name': selectedGender == 'male' ? 'Бег 3000м' : 'Бег 2000м', 'norm': norms[selectedGender == 'male' ? 'run_3000m' : 'run_2000m'] ?? 'Н/Д', 'icon': '🏃‍♀️'},
      {'name': 'Подтягивания', 'norm': norms['pullups'] ?? 'Н/Д', 'icon': '💪'},
      {'name': 'Отжимания', 'norm': norms['pushups'] ?? 'Н/Д', 'icon': '🤲'},
      {'name': 'Пресс', 'norm': norms['abs'] ?? 'Н/Д', 'icon': '🏋️‍♂️'},
      {'name': 'Прыжок в длину', 'norm': norms['jump'] ?? 'Н/Д', 'icon': '🦘'},
      {'name': 'Гибкость', 'norm': norms['flexibility'] ?? 'Н/Д', 'icon': '🤸‍♀️'},
    ];
  }

  Future<void> _startGTOWorkout() async {
    try {
      // Создаем ГТО тренировку (отжимания 10 раз)
      await ref.read(workoutControllerProvider.notifier).createGTOWorkout();
      
      // Переходим на страницу AI-Motion
      if (mounted) {
        context.push('/gto/workout');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка запуска тренировки: $e'),
            backgroundColor: PRIMETheme.warn,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text(
          'ГТО',
          style: TextStyle(
            color: PRIMETheme.sand,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: PRIMETheme.sand),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Описание ГТО
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: PRIMETheme.line),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Готов к Труду и Обороне',
                      style: TextStyle(
                        color: PRIMETheme.sand,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'ГТО - это всероссийский физкультурно-спортивный комплекс. Здесь вы можете посмотреть нормативы для вашего возраста и пола.',
                      style: TextStyle(
                        color: PRIMETheme.sandWeak,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Выбор пола
              const Text(
                'Пол:',
                style: TextStyle(
                  color: PRIMETheme.sand,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => selectedGender = 'male'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selectedGender == 'male' ? PRIMETheme.primary : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: PRIMETheme.line),
                        ),
                        child: Center(
                          child: Text(
                            '👨 Мужской',
                            style: TextStyle(
                              color: selectedGender == 'male' ? PRIMETheme.sand : PRIMETheme.sandWeak,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => selectedGender = 'female'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selectedGender == 'female' ? PRIMETheme.primary : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: PRIMETheme.line),
                        ),
                        child: Center(
                          child: Text(
                            '👩 Женский',
                            style: TextStyle(
                              color: selectedGender == 'female' ? PRIMETheme.sand : PRIMETheme.sandWeak,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Выбор возрастной группы
              const Text(
                'Возрастная группа:',
                style: TextStyle(
                  color: PRIMETheme.sand,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: ageGroups.length,
                  itemBuilder: (context, index) {
                    final isSelected = selectedAgeGroup == index;
                    return GestureDetector(
                      onTap: () => setState(() => selectedAgeGroup = index),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? PRIMETheme.primary : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: PRIMETheme.line),
                        ),
                        child: Center(
                          child: Text(
                            ageGroups[index]['name'],
                            style: TextStyle(
                              color: isSelected ? PRIMETheme.sand : PRIMETheme.sandWeak,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Нормативы
              const Text(
                'Нормативы на золотой значок:',
                style: TextStyle(
                  color: PRIMETheme.sand,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              Expanded(
                child: ListView.builder(
                  itemCount: currentNorms.length,
                  itemBuilder: (context, index) {
                    final norm = currentNorms[index];
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
                          Text(
                            norm['icon']!,
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              norm['name']!,
                              style: const TextStyle(
                                color: PRIMETheme.sand,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            norm['norm']!,
                            style: const TextStyle(
                              color: PRIMETheme.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Кнопка "Начать тренировку"
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _startGTOWorkout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PRIMETheme.primary,
                    foregroundColor: PRIMETheme.sand,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'AI-ТРЕНИРОВКА: ОТЖИМАНИЯ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
