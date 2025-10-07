# PRIME Forge - Комплексное приложение для саморазвития

## 📖 Обзор проекта

PRIME Forge - это мобильное приложение на Flutter, предназначенное для комплексного саморазвития пользователя. Приложение объединяет трекинг привычек, управление задачами, мониторинг здоровья и социальную составляющую в единую экосистему личностного роста.

### 🎯 Основная концепция
Приложение построено на концепции "Альфа-личности" - системе развития через:
- **XP (Experience Points)** - опыт за выполненные задачи
- **RESPECT** - система уважения и достижений
- **Привычки** - ежедневные практики для роста
- **Физическое развитие** - мониторинг здоровья и тела
- **Братство** - сообщество единомышленников

## 🏗️ Архитектура приложения

### Технологический стек
- **Frontend**: Flutter SDK
- **Навигация**: GoRouter
- **Управление состоянием**: Riverpod
- **UI/UX**: Material Design 3
- **Шрифты**: Google Fonts (PRIME Slab One, JetBrains Mono)
- **Графики и аналитика**: FL Chart
- **Анимации**: Flutter Animation Framework

### Структура проекта
```
lib/
├── app/
│   ├── app.dart           # Главный виджет приложения
│   ├── router.dart        # Конфигурация маршрутизации
│   └── theme.dart         # Кастомная тема приложения
├── features/
│   ├── auth/              # Модуль авторизации
│   ├── path/              # Главная страница (путь развития)
│   ├── habits/            # Модуль привычек
│   ├── body/              # Модуль здоровья и тела
│   ├── tasks/             # Модуль задач
│   ├── brotherhood/       # Модуль сообщества
│   └── shared/            # Общие компоненты
└── main.dart              # Точка входа
```

## 🎨 Дизайн система

### Цветовая палитра
- **Background**: `#000000` (Чистый черный)
- **Primary**: `#660000` (Темно-бордовый)
- **Sand**: `#E9E1D1` (Песочный для текста)
- **Surface**: `#1A1A1A` (Поверхности)
- **Error**: `#FF6B6B` (Ошибки)

### Типографика
- **Заголовки**: PRIME Slab One (брутальный serif)
- **Код/Данные**: JetBrains Mono (моноширинный)
- **Основной текст**: System default

### Принципы дизайна
- **Темная тема** как основная
- **Минимализм** в интерфейсе
- **Акцент на функциональности**
- **Консистентность** во всех модулях

## 🚀 Детальное описание модулей

### 0. Модуль онбординга (Onboarding)

**Файлы**: 
- `lib/features/onboarding/controllers/onboarding_controller.dart`
- `lib/features/onboarding/models/onboarding_data.dart`
- `lib/features/onboarding/models/habit_model.dart`
- `lib/features/onboarding/pages/intro_page.dart`
- `lib/features/onboarding/pages/name_page.dart`
- `lib/features/onboarding/pages/habits_selection_page.dart`
- `lib/features/onboarding/pages/ready_page.dart`
- `lib/features/onboarding/widgets/`

#### Функциональность:
- 4-этапный процесс знакомства с приложением
- Персонализация через выбор имени героя
- Выбор начальных привычек (максимум 4 из предустановленных)
- Сохранение данных в SharedPreferences
- Валидация на каждом этапе
- Динамическое перенаправление в навигации

#### Бизнес-логика онбординга:
```dart
class OnboardingController extends ChangeNotifier {
  OnboardingData _data = const OnboardingData();
  bool _isLoading = false;
  
  // Валидация каждого шага
  bool get isNameValid => _data.heroName != null && 
                         _data.heroName!.trim().isNotEmpty &&
                         _data.heroName!.trim().length <= 20;
  
  bool get areHabitsValid => _data.selectedHabits.isNotEmpty;
  bool get canComplete => isNameValid && areHabitsValid;
  
  // Управление привычками с ограничением
  void toggleHabit(HabitModel habit) {
    final currentHabits = List<HabitModel>.from(_data.selectedHabits);
    
    if (currentHabits.contains(habit)) {
      currentHabits.remove(habit);
    } else {
      if (currentHabits.length < 4) { // Максимум 4 привычки
        currentHabits.add(habit);
      }
    }
    
    _data = _data.copyWith(selectedHabits: currentHabits);
    notifyListeners();
  }
}
```

#### Этапы онбординга:

1. **Intro Page** - Приветствие и знакомство с концепцией PRIME
2. **Name Page** - Ввод имени героя с валидацией (до 20 символов)
3. **Habits Selection Page** - Выбор начальных привычек из предустановленного списка
4. **Ready Page** - Финализация и переход к основному приложению

#### Модель данных онбординга:
```dart
class OnboardingData {
  final String? heroName;        // Имя героя (до 20 символов)
  final List<HabitModel> selectedHabits; // Выбранные привычки (до 4)
  final bool isCompleted;        // Флаг завершения
  
  // JSON сериализация для SharedPreferences
  String toJsonString() => jsonEncode(toJson());
  factory OnboardingData.fromJsonString(String jsonString);
  
  bool get isValid => heroName != null && 
                     heroName!.isNotEmpty && 
                     selectedHabits.isNotEmpty;
}
```

#### Предустановленные привычки:
```dart
class DefaultHabits {
  static const List<HabitModel> habits = [
    HabitModel(
      id: 'early_rise',
      name: 'Ранний подъём', 
      icon: '🌅',
      description: 'Просыпаться в 6:00',
    ),
    HabitModel(
      id: 'reading',
      name: 'Чтение',
      icon: '📚', 
      description: '30 минут чтения',
    ),
    HabitModel(
      id: 'workout',
      name: 'Тренировка',
      icon: '🏋️‍♂️',
      description: 'Физические упражнения',
    ),
    HabitModel(
      id: 'meditation', 
      name: 'Медитация',
      icon: '🧘',
      description: '10 минут медитации',
    ),
  ];
}
```

#### Интеграция с навигацией:
```dart
// В router.dart - проверка завершения онбординга
redirect: (context, state) async {
  final isOnboardingComplete = await OnboardingController.isOnboardingCompleted();
  
  if (!isOnboardingComplete && !state.matchedLocation.startsWith('/onboarding')) {
    return '/onboarding/intro';
  }
  
  if (isOnboardingComplete && state.matchedLocation.startsWith('/onboarding')) {
    return '/';
  }
  
  return null;
}
```

#### Persistence стратегия:
- **SharedPreferences** для локального хранения
- **Двойное сохранение**: полные данные + флаг завершения
- **Статические методы** для быстрой проверки состояния
- **Сброс данных** для тестирования и отладки

#### UI компоненты онбординга:
- **LogoWithGlow** - анимированный логотип с свечением
- **OnboardingButton** - стилизованные кнопки навигации
- **HabitCard** - карточки привычек с selection состоянием
- **ProgressDots** - индикатор прогресса по этапам
- **HeroNameInput** - кастомное поле ввода имени

### 1. Модуль авторизации (Auth)

**Файл**: `lib/features/auth/login_page.dart`

#### Функциональность:
- Адаптивный дизайн для разных размеров экрана
- Анимированный заголовок с эффектом появления
- Валидация форм в реальном времени
- Демо-режим для тестирования

#### Бизнес-логика:
```dart
// Валидация email
bool _isValidEmail(String email) {
  return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
}

// Процесс входа
void _login() async {
  if (_isValidEmail(_emailController.text) && 
      _passwordController.text.isNotEmpty) {
    // Демо: автоматический успешный вход
    context.go('/');
  }
}
```

#### UI компоненты:
- **ResponsiveContainer** - адаптивная обертка
- **AnimatedTitle** - анимированный заголовок
- **CustomTextField** - поля ввода с валидацией
- **GradientButton** - кнопка входа с градиентом

### 2. Главная страница - Путь (Path)

**Файл**: `lib/features/path/path_page.dart`

#### Функциональность:
- Отображение метрик XP и RESPECT
- Ежедневные задачи с чекбоксами
- Трекер привычек с прогресс-барами
- Фокус-таймер с модальными окнами
- Интерактивные элементы управления

#### Бизнес-логика метрик:
```dart
class UserMetrics {
  int xp = 2847;           // Опыт пользователя
  int respect = 156;       // Уровень уважения
  int dailyStreak = 23;    // Дневная серия
  double todayProgress = 0.74; // Прогресс дня
}

// Расчет прогресса дня
double calculateDayProgress() {
  int completedTasks = dailyTasks.where((task) => task.isCompleted).length;
  return completedTasks / dailyTasks.length;
}
```

#### Ежедневные задачи:
- Медитация (10 мин)
- Тренировка (45 мин) 
- Чтение (30 мин)
- Холодный душ
- Планирование дня

#### Трекер привычек:
```dart
List<Habit> habits = [
  Habit('Просыпание в 6:00', 0.85, '17/20'),
  Habit('Зарядка', 0.90, '18/20'),
  Habit('Чтение', 0.75, '15/20'),
  // ...
];
```

#### Фокус-таймер:
- Pomodoro техника (25/5 минут)
- Звуковые уведомления
- Статистика сессий
- Настройка длительности

### 3. Модуль привычек (Habits)

**Файл**: `lib/features/habits/habits_page.dart`

#### Функциональность:
- Календарная сетка для трекинга (7x4 недели)
- Система подсчета streak'ов
- Детальная аналитика с графиками
- Управление привычками (добавление/удаление)

#### Алгоритм силы привычки:
```dart
double calculateHabitStrength(List<bool> completions) {
  if (completions.isEmpty) return 0.0;
  
  double weight = 1.0;
  double totalWeight = 0.0;
  double weightedSum = 0.0;
  
  // Более недавние дни имеют больший вес
  for (int i = completions.length - 1; i >= 0; i--) {
    totalWeight += weight;
    if (completions[i]) weightedSum += weight;
    weight *= 0.95; // Экспоненциальное затухание
  }
  
  return weightedSum / totalWeight;
}
```

## 🔌 Интеграция с Supabase (Backend)

Приложение подключено к Supabase для аутентификации и хранения данных. Для локального запуска:

1) Создайте проект на https://supabase.com и скопируйте:
  - Project URL
  - Public anon key

2) Создайте файл `.env` в корне проекта (есть пример `.env.example`):
  - SUPABASE_URL=https://<your-project-ref>.supabase.co
  - SUPABASE_ANON_KEY=eyJ...

3) Настройте Redirect URLs в Supabase Dashboard → Authentication → URL Configuration:
  - Добавьте `alfaforge://auth/callback`
  - (опционально для Web) ваш локальный/прод домен

4) Мобильные платформы уже настроены:
  - Android: `android/app/src/main/AndroidManifest.xml` содержит intent-filter под схему `alfaforge://auth/callback`
  - iOS: `ios/Runner/Info.plist` содержит `CFBundleURLSchemes` со значением `alfaforge`

5) Инициализация происходит в `lib/main.dart` через `flutter_dotenv` и `Supabase.initialize`.

Если при подтверждении email появляется ошибка redirect, убедитесь, что URL из п.3 совпадает с конфигурацией в Dashboard.

#### Система streak'ов:
```dart
int calculateStreak(List<bool> completions) {
  int streak = 0;
  for (int i = completions.length - 1; i >= 0; i--) {
    if (completions[i]) {
      streak++;
    } else {
      break;
    }
  }
  return streak;
}
```

#### Аналитика:
- **Текущий streak**: Количество дней подряд
- **Лучший streak**: Максимальная серия
- **Сила привычки**: 0-100% на основе консистентности
- **Недельная статистика**: График выполнения
- **Прогноз**: Вероятность выполнения завтра

### 4. Модуль здоровья и тела (Body)

**Файл**: `lib/features/body/body_page.dart`

#### Функциональность:
- Калькулятор и трекинг BMI
- Измерения тела (вес, рост, объемы)
- Жизненные показатели (пульс, давление, сон)
- Продвинутая аналитика с кастомными графиками

#### Расчет BMI:
```dart
class BMICalculator {
  static double calculate(double weight, double height) {
    return weight / (height * height);
  }
  
  static String getCategory(double bmi) {
    if (bmi < 18.5) return 'Недовес';
    if (bmi < 25) return 'Норма';
    if (bmi < 30) return 'Избыток';
    return 'Ожирение';
  }
  
  static Color getCategoryColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }
}
```

#### Трекинг измерений:
```dart
class BodyMeasurements {
  double weight;     // Вес в кг
  double height;     // Рост в см  
  double chest;      // Грудь в см
  double waist;      // Талия в см
  double hips;       // Бедра в см
  double bodyFat;    // % жира
  DateTime date;     // Дата измерения
}
```

#### Жизненные показатели:
```dart
class VitalSigns {
  int restingHeartRate;    // Пульс покоя
  int maxHeartRate;        // Максимальный пульс
  String bloodPressure;    // Давление "120/80"
  double sleepHours;       // Часы сна
  int sleepQuality;        // Качество сна 1-10
  double stressLevel;      // Уровень стресса 1-10
}
```

#### Кастомный график (CircularProgressPainter):
```dart
class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color primaryColor;
  final Color backgroundColor;
  
  // Рисует кольцевой прогресс-бар для BMI
  void paint(Canvas canvas, Size size) {
    // Фон кольца
    Paint bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;
    
    // Прогресс кольца  
    Paint progressPaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    double radius = size.width / 2 - 4;
    Offset center = Offset(size.width / 2, size.height / 2);
    
    // Рисуем фон
    canvas.drawCircle(center, radius, bgPaint);
    
    // Рисуем прогресс
    double sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }
}
```

### 5. Модуль задач (Tasks)

**Файл**: `lib/features/tasks/tasks_page.dart`

#### Функциональность:
- Kanban доска с drag-and-drop
- Фокус-режим для концентрации
- Управление приоритетами и дедлайнами
- Система статусов задач

#### Модель задачи:
```dart
enum TaskStatus { backlog, inProgress, review, done }
enum TaskPriority { low, medium, high, urgent }

class Task {
  String id;
  String title;
  String description;
  TaskStatus status;
  TaskPriority priority;
  DateTime? deadline;
  List<String> tags;
  bool isFocused;
  int estimatedMinutes;
  int actualMinutes;
  
  // Цвет приоритета
  Color get priorityColor {
    switch (priority) {
      case TaskPriority.low: return Colors.grey;
      case TaskPriority.medium: return Colors.blue;
      case TaskPriority.high: return Colors.orange;
      case TaskPriority.urgent: return Colors.red;
    }
  }
}
```

#### Kanban логика:
```dart
class KanbanController {
  List<Task> backlogTasks = [];
  List<Task> inProgressTasks = [];
  List<Task> reviewTasks = [];
  List<Task> doneTasks = [];
  
  void moveTask(Task task, TaskStatus newStatus) {
    // Убираем из текущего столбца
    _removeFromCurrentColumn(task);
    
    // Добавляем в новый столбец
    task.status = newStatus;
    _addToColumn(task, newStatus);
    
    // Логирование перемещения
    _logTaskMovement(task, newStatus);
  }
}
```

#### Фокус-режим:
```dart
class FocusMode {
  Task? currentTask;
  Duration focusTime = Duration(minutes: 25);
  Timer? timer;
  bool isActive = false;
  
  void startFocus(Task task) {
    currentTask = task;
    isActive = true;
    task.isFocused = true;
    
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      focusTime = focusTime - Duration(seconds: 1);
      if (focusTime.inSeconds <= 0) {
        _completeFocusSession();
      }
    });
  }
}
```

### 6. Модуль сообщества - Братство (Brotherhood)

**Файл**: `lib/features/brotherhood/brotherhood_page.dart`

#### Функциональность:
- Система табов (Лента, Темы, Отчеты)
- Система сообщений и реакций
- Ежедневные отчеты участников
- Обсуждения по темам с функцией ответов

#### Модель поста:
```dart
class Post {
  String id;
  String authorName;
  String content;
  DateTime timestamp;
  int likes;
  int comments;
  PostType type; // report, discussion, achievement
  List<String> tags;
  bool isLiked;
  
  String get timeAgo {
    final difference = DateTime.now().difference(timestamp);
    if (difference.inDays > 0) return '${difference.inDays}д назад';
    if (difference.inHours > 0) return '${difference.inHours}ч назад';
    return '${difference.inMinutes}м назад';
  }
}
```

#### Система реакций:
```dart
enum ReactionType { like, fire, strong, respect, mind }

class ReactionSystem {
  Map<String, List<Reaction>> postReactions = {};
  
  void addReaction(String postId, ReactionType type, String userId) {
    if (!postReactions.containsKey(postId)) {
      postReactions[postId] = [];
    }
    
    // Удаляем предыдущую реакцию пользователя
    postReactions[postId]!.removeWhere((r) => r.userId == userId);
    
    // Добавляем новую реакцию
    postReactions[postId]!.add(Reaction(type, userId, DateTime.now()));
  }
  
  int getReactionCount(String postId, ReactionType type) {
    return postReactions[postId]
        ?.where((r) => r.type == type)
        .length ?? 0;
  }
}
```

#### Ежедневные отчеты:
```dart
class DailyReport {
  String authorName;
  List<String> completedHabits;
  List<String> completedTasks;
  String reflection;
  int energyLevel; // 1-10
  int moodLevel;   // 1-10
  String challenges;
  String wins;
  
  String generateSummary() {
    return '''
    ✅ Привычки: ${completedHabits.join(', ')}
    📋 Задачи: ${completedTasks.length} выполнено
    💪 Энергия: $energyLevel/10
    😊 Настроение: $moodLevel/10
    
    Победы дня: $wins
    Вызовы: $challenges
    
    Размышления: $reflection
    ''';
  }
}
```

## 🧭 Навигационная система

### GoRouter конфигурация:
```dart
final router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (_, __) => LoginPage()),
    ShellRoute(
      builder: (context, state, child) => BottomNavScaffold(child: child),
      routes: [
        GoRoute(path: '/', builder: (_, __) => PathPage()),
        GoRoute(path: '/habits', builder: (_, __) => HabitsPage()),
        GoRoute(path: '/body', builder: (_, __) => BodyPage()),
        GoRoute(path: '/tasks', builder: (_, __) => TasksPage()),
        GoRoute(path: '/brotherhood', builder: (_, __) => BrotherhoodPage()),
      ],
    ),
  ],
);
```

### Bottom Navigation:
```dart
class BottomNavScaffold extends StatelessWidget {
  final List<NavItem> items = [
    NavItem('Путь', Icons.track_changes, '/'),
    NavItem('Привычки', Icons.repeat, '/habits'),
    NavItem('Тело', Icons.fitness_center, '/body'),
    NavItem('Задачи', Icons.task_alt, '/tasks'),
    NavItem('Братство', Icons.groups, '/brotherhood'),
  ];
}
```

## 📊 Система аналитики

### Типы графиков:
1. **LineChart** - динамика метрик во времени
2. **BarChart** - сравнение показателей
3. **PieChart** - распределение категорий
4. **CircularProgress** - кольцевые прогресс-бары
5. **CustomPainter** - специализированные визуализации

### Метрики приложения:
- **Пользовательские**: XP, RESPECT, streak'и
- **Привычки**: сила, консистентность, прогресс
- **Здоровье**: BMI, вес, измерения, показатели
- **Задачи**: производительность, время фокуса
- **Социальные**: активность в сообществе, реакции

## 🔄 Бизнес-процессы

### 1. Цикл развития пользователя:
1. **Планирование** - установка целей и привычек
2. **Выполнение** - ежедневная работа над задачами
3. **Трекинг** - отслеживание прогресса
4. **Анализ** - изучение аналитики и корректировка
5. **Социализация** - обмен опытом в сообществе

### 2. Система мотивации:
- **XP за задачи**: немедленное вознаграждение
- **Streak'и привычек**: долгосрочная мотивация
- **RESPECT**: социальное признание
- **Прогресс-бары**: визуальная обратная связь
- **Сообщество**: поддержка и вдохновение

### 3. Алгоритм персонализации:
- Анализ активности пользователя
- Адаптация сложности задач
- Рекомендации новых привычек
- Персональные инсайты и советы

## 🚀 Технические особенности

### Производительность:
- **Lazy loading** виджетов и данных
- **Кеширование** частых вычислений
- **Оптимизированные списки** с `ListView.builder`
- **Эффективные анимации** с `AnimationController`

### Архитектурные паттерны:
- **Feature-based** структура модулей
- **Provider/Riverpod** для управления состоянием
- **Repository pattern** для работы с данными
- **Clean Architecture** принципы

### Адаптивность:
- **Responsive design** для разных экранов
- **SafeArea** для корректного отображения
- **Overflow handling** для длинного контента
- **Accessibility** поддержка

## 📱 Пользовательский опыт

### Принципы UX:
1. **Простота** - интуитивно понятный интерфейс
2. **Консистентность** - единые паттерны взаимодействия
3. **Обратная связь** - немедленная реакция на действия
4. **Прогрессивность** - постепенное усложнение
5. **Мотивация** - постоянные поощрения и цели

### Сценарии использования:
- **Утренняя рутина**: проверка задач на день
- **В течение дня**: отметка выполненных привычек
- **Вечерняя рефлексия**: анализ прогресса
- **Социализация**: общение в сообществе
- **Планирование**: установка новых целей

## 🔮 Потенциал развития

### Возможные дополнения:
1. **Push уведомления** для напоминаний
2. **Синхронизация** между устройствами
3. **Интеграция** с фитнес-трекерами
4. **AI-рекомендации** персональных планов
5. **Gamification** - достижения и награды
6. **Социальные челленджи** и соревнования
7. **Экспорт данных** и аналитика
8. **Темная/светлая тема** переключение

### Технические улучшения:
- **Offline-first** архитектура
- **Backend интеграция** для синхронизации
- **Automated testing** покрытие
- **CI/CD pipeline** для деплоя
- **Analytics integration** для метрик

## 📋 Заключение

PRIME Forge представляет собой комплексную систему саморазвития, объединяющую:
- **Личную эффективность** через задачи и привычки
- **Физическое здоровье** через трекинг тела
- **Социальную поддержку** через сообщество
- **Аналитику прогресса** через детальную статистику

Приложение построено на современных принципах Flutter разработки с акцентом на производительность, масштабируемость и пользовательский опыт. Модульная архитектура позволяет легко добавлять новые функции и развивать платформу в соответствии с потребностями пользователей.

**Версия документации**: 1.0.0  
**Дата обновления**: 18.08.2025  
**Автор**: PRIME Team
