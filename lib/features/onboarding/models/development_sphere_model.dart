import 'habit_model.dart';

class DevelopmentSphere {
  final String id;
  final String name;
  final String icon;
  final List<HabitModel> habits;

  const DevelopmentSphere({
    required this.id,
    required this.name,
    required this.icon,
    required this.habits,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DevelopmentSphere &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DevelopmentSpheresData {
  static const List<DevelopmentSphere> spheres = [
    DevelopmentSphere(
      id: 'body',
      name: 'ТЕЛО',
      icon: '🏋️',
      habits: [
        HabitModel(
          id: 'morning_exercise',
          name: 'Утренняя зарядка',
          icon: '🏃',
          description: '10 мин',
        ),
        HabitModel(
          id: 'steps_10k',
          name: '10 000 шагов',
          icon: '👟',
          description: 'в день',
        ),
        HabitModel(
          id: 'light_jog',
          name: 'Лёгкая пробежка',
          icon: '🏃‍♂️',
          description: 'утром/вечером',
        ),
        HabitModel(
          id: 'gym_workout',
          name: 'Тренировка в зале',
          icon: '💪',
          description: '3 раза в неделю',
        ),
        HabitModel(
          id: 'evening_stretch',
          name: 'Растяжка вечером',
          icon: '🤸',
          description: '15 мин',
        ),
        HabitModel(
          id: 'sleep_before_23',
          name: 'Сон до 23:00',
          icon: '🌙',
          description: 'каждый день',
        ),
        HabitModel(
          id: 'sleep_8h',
          name: '8 часов сна',
          icon: '😴',
          description: 'полноценный отдых',
        ),
        HabitModel(
          id: 'cold_shower',
          name: 'Холодный душ',
          icon: '🚿',
          description: '2-3 мин',
        ),
        HabitModel(
          id: 'water_2l',
          name: '2 литра воды',
          icon: '💧',
          description: 'в день',
        ),
        HabitModel(
          id: 'no_elevator',
          name: 'Отказ от лифта',
          icon: '🚶',
          description: 'по лестнице',
        ),
        HabitModel(
          id: 'contrast_shower',
          name: 'Контрастный душ',
          icon: '🌡️',
          description: 'горячая-холодная',
        ),
        HabitModel(
          id: 'no_sweets',
          name: 'Нет сладкого',
          icon: '🚫',
          description: 'без сахара',
        ),
        HabitModel(
          id: 'no_fastfood',
          name: 'Нет фастфуда',
          icon: '🥗',
          description: 'здоровая еда',
        ),
        HabitModel(
          id: 'no_soda',
          name: 'Нет газировки',
          icon: '🥤',
          description: 'чистая вода',
        ),
        HabitModel(
          id: 'no_alcohol',
          name: 'Нет алкоголя',
          icon: '🚭',
          description: 'трезвый образ жизни',
        ),
        HabitModel(
          id: 'no_cigarettes',
          name: 'Нет сигарет',
          icon: '🚭',
          description: 'здоровые лёгкие',
        ),
        HabitModel(
          id: 'fresh_air_walk',
          name: 'Прогулка',
          icon: '🌳',
          description: 'на свежем воздухе',
        ),
        HabitModel(
          id: 'abs_pushups',
          name: 'Пресс/отжимания',
          icon: '💪',
          description: 'каждый день',
        ),
        HabitModel(
          id: 'track_weight',
          name: 'Отслеживание веса',
          icon: '⚖️',
          description: 'ежедневно',
        ),
        HabitModel(
          id: 'plank_1min',
          name: 'Планка 1 мин',
          icon: '🏋️',
          description: 'каждое утро',
        ),
      ],
    ),
    DevelopmentSphere(
      id: 'will',
      name: 'ВОЛЯ',
      icon: '⚡',
      habits: [
        HabitModel(
          id: 'no_sugar',
          name: 'Нет сахара',
          icon: '🚫',
          description: 'чистое питание',
        ),
        HabitModel(
          id: 'no_fastfood_will',
          name: 'Нет фастфуда',
          icon: '🥗',
          description: 'сила воли',
        ),
        HabitModel(
          id: 'no_alcohol_will',
          name: 'Нет алкоголя',
          icon: '🚭',
          description: 'контроль себя',
        ),
        HabitModel(
          id: 'no_nicotine',
          name: 'Нет никотина',
          icon: '🚭',
          description: 'чистые лёгкие',
        ),
        HabitModel(
          id: 'no_caffeine',
          name: 'Нет кофеина',
          icon: '☕',
          description: 'естественная энергия',
        ),
        HabitModel(
          id: 'sleep_schedule',
          name: 'Режим сна',
          icon: '⏰',
          description: 'без сбоев',
        ),
        HabitModel(
          id: 'hard_task_daily',
          name: '1 трудное дело',
          icon: '💪',
          description: 'в день',
        ),
        HabitModel(
          id: 'no_excuses',
          name: 'Нет оправданий',
          icon: '⚡',
          description: 'только действие',
        ),
        HabitModel(
          id: 'no_phone_1h',
          name: '1 час без телефона',
          icon: '📵',
          description: 'цифровой детокс',
        ),
        HabitModel(
          id: 'no_social_24h',
          name: '24ч без соцсетей',
          icon: '🚫',
          description: 'раз в неделю',
        ),
        HabitModel(
          id: 'cleaning_no_excuses',
          name: 'Уборка',
          icon: '🧹',
          description: 'без отговорок',
        ),
        HabitModel(
          id: 'workout_through_dont_want',
          name: 'Тренировка',
          icon: '💪',
          description: 'через "не хочу"',
        ),
        HabitModel(
          id: 'discipline_5min',
          name: '5 мин дисциплины',
          icon: '⚡',
          description: 'утром',
        ),
        HabitModel(
          id: 'no_complaints',
          name: 'Нет жалоб',
          icon: '🤐',
          description: 'позитивный настрой',
        ),
        HabitModel(
          id: 'no_laziness',
          name: 'Нет лени',
          icon: '🚀',
          description: 'всегда в действии',
        ),
        HabitModel(
          id: 'no_procrastination',
          name: 'Нет прокрастинации',
          icon: '⏱️',
          description: 'делать сейчас',
        ),
        HabitModel(
          id: 'do_immediately',
          name: 'Делать сразу',
          icon: '⚡',
          description: 'не откладывать',
        ),
        HabitModel(
          id: 'keep_word',
          name: 'Держать слово',
          icon: '🤝',
          description: 'всегда',
        ),
        HabitModel(
          id: 'first_alarm',
          name: 'Вставать',
          icon: '⏰',
          description: 'при первом будильнике',
        ),
        HabitModel(
          id: 'overcome_weakness',
          name: '1 победа',
          icon: '🏆',
          description: 'над слабостью',
        ),
      ],
    ),
    DevelopmentSphere(
      id: 'focus',
      name: 'ФОКУС',
      icon: '🎯',
      habits: [
        HabitModel(
          id: 'morning_plan',
          name: 'План на день',
          icon: '📝',
          description: 'утром',
        ),
        HabitModel(
          id: 'three_main_tasks',
          name: '3 главные задачи',
          icon: '🎯',
          description: 'дня',
        ),
        HabitModel(
          id: 'no_phone_until_9',
          name: 'Без телефона',
          icon: '📵',
          description: 'до 9:00',
        ),
        HabitModel(
          id: 'no_social_until_lunch',
          name: 'Без соцсетей',
          icon: '🚫',
          description: 'до обеда',
        ),
        HabitModel(
          id: 'deep_work_2h',
          name: '2 часа deep work',
          icon: '🧠',
          description: 'без отвлечений',
        ),
        HabitModel(
          id: 'pomodoro',
          name: 'Техника Помидора',
          icon: '🍅',
          description: '25/5 мин',
        ),
        HabitModel(
          id: 'limit_notifications',
          name: 'Ограничить уведомления',
          icon: '🔕',
          description: 'только важные',
        ),
        HabitModel(
          id: 'task_list',
          name: 'Список задач',
          icon: '📋',
          description: 'ведение',
        ),
        HabitModel(
          id: 'evening_review',
          name: 'Разбор дня',
          icon: '🔍',
          description: 'вечером',
        ),
        HabitModel(
          id: 'no_multitasking',
          name: 'Нет многозадачности',
          icon: '🎯',
          description: 'одно дело',
        ),
        HabitModel(
          id: 'work_by_priority',
          name: 'По приоритету',
          icon: '📈',
          description: 'важное сначала',
        ),
        HabitModel(
          id: 'study_1h_focused',
          name: '1 час учёбы',
          icon: '📚',
          description: 'без отвлечений',
        ),
        HabitModel(
          id: 'daily_goal',
          name: 'Цель дня',
          icon: '🎯',
          description: 'одна главная',
        ),
        HabitModel(
          id: 'weekly_goal',
          name: 'Цель недели',
          icon: '📅',
          description: 'планирование',
        ),
        HabitModel(
          id: 'no_extra_tabs',
          name: 'Нет лишних вкладок',
          icon: '💻',
          description: 'чистый браузер',
        ),
        HabitModel(
          id: 'productivity_journal',
          name: 'Дневник продуктивности',
          icon: '📊',
          description: 'отслеживание',
        ),
        HabitModel(
          id: 'weekly_plan',
          name: 'План на неделю',
          icon: '📋',
          description: 'каждое воскресенье',
        ),
        HabitModel(
          id: 'project_step',
          name: 'Шаг к проекту',
          icon: '🚀',
          description: 'каждый день',
        ),
        HabitModel(
          id: 'clear_schedule',
          name: 'Чёткое расписание',
          icon: '⏰',
          description: 'по времени',
        ),
        HabitModel(
          id: 'no_morning_news',
          name: 'Без новостей',
          icon: '📰',
          description: 'утром',
        ),
      ],
    ),
    DevelopmentSphere(
      id: 'mind',
      name: 'РАЗУМ',
      icon: '📚',
      habits: [
        HabitModel(
          id: 'reading_10min',
          name: 'Чтение 10 мин',
          icon: '📖',
          description: 'каждый день',
        ),
        HabitModel(
          id: 'reading_20min',
          name: 'Чтение 20 мин',
          icon: '📚',
          description: 'углублённое',
        ),
        HabitModel(
          id: 'thoughts_diary',
          name: 'Дневник мыслей',
          icon: '✍️',
          description: 'рефлексия',
        ),
        HabitModel(
          id: 'write_goals',
          name: 'Запись целей',
          icon: '🎯',
          description: 'каждое утро',
        ),
        HabitModel(
          id: 'learn_new_skill',
          name: 'Новый навык',
          icon: '🧠',
          description: 'изучение',
        ),
        HabitModel(
          id: 'watch_lecture',
          name: 'Просмотр лекции',
          icon: '🎓',
          description: 'образование',
        ),
        HabitModel(
          id: 'listen_podcast',
          name: 'Слушать подкаст',
          icon: '🎧',
          description: 'во время прогулки',
        ),
        HabitModel(
          id: 'online_course',
          name: 'Онлайн-курс',
          icon: '💻',
          description: '30 мин в день',
        ),
        HabitModel(
          id: 'make_notes',
          name: 'Конспект',
          icon: '📝',
          description: 'прочитанного',
        ),
        HabitModel(
          id: 'new_word',
          name: 'Новое слово',
          icon: '🔤',
          description: 'англ/др. язык',
        ),
        HabitModel(
          id: 'daily_memo',
          name: 'Памятка дня',
          icon: '📋',
          description: 'ключевая идея',
        ),
        HabitModel(
          id: 'focused_study',
          name: 'Учёба',
          icon: '🎯',
          description: 'без отвлечений',
        ),
        HabitModel(
          id: 'new_idea',
          name: '1 новая идея',
          icon: '💡',
          description: 'каждый день',
        ),
        HabitModel(
          id: 'solve_problems',
          name: 'Решение задач',
          icon: '🧮',
          description: 'мат/логика',
        ),
        HabitModel(
          id: 'letter_to_self',
          name: 'Письмо себе',
          icon: '✉️',
          description: 'раз в неделю',
        ),
        HabitModel(
          id: 'analyze_mistakes',
          name: 'Разбор ошибок',
          icon: '🔍',
          description: 'дня',
        ),
        HabitModel(
          id: 'learn_quote',
          name: 'Учить цитату',
          icon: '💭',
          description: 'мудрость',
        ),
        HabitModel(
          id: 'take_notes',
          name: 'Вести заметки',
          icon: '📝',
          description: 'важные мысли',
        ),
        HabitModel(
          id: 'knowledge_map',
          name: 'Карта знаний',
          icon: '🗺️',
          description: 'ведение',
        ),
        HabitModel(
          id: 'mindful_news',
          name: 'Осмысленное чтение',
          icon: '📰',
          description: 'новостей',
        ),
      ],
    ),
    DevelopmentSphere(
      id: 'peace',
      name: 'СПОКОЙСТВИЕ',
      icon: '🧘',
      habits: [
        HabitModel(
          id: 'meditation_5min',
          name: 'Медитация 5 мин',
          icon: '🧘‍♂️',
          description: 'каждое утро',
        ),
        HabitModel(
          id: 'meditation_10min',
          name: 'Медитация 10 мин',
          icon: '🧘‍♀️',
          description: 'углублённая',
        ),
        HabitModel(
          id: 'breathing_4444',
          name: 'Дыхание 4-4-4-4',
          icon: '💨',
          description: 'техника',
        ),
        HabitModel(
          id: 'mindful_walk',
          name: 'Осознанная прогулка',
          icon: '🚶‍♂️',
          description: 'без спешки',
        ),
        HabitModel(
          id: 'gratitude_note',
          name: 'Записать благодарность',
          icon: '🙏',
          description: '3 вещи',
        ),
        HabitModel(
          id: 'three_accomplishments',
          name: '3 дела',
          icon: '✅',
          description: 'что сделал сегодня',
        ),
        HabitModel(
          id: 'no_phone_30min_evening',
          name: 'Без телефона',
          icon: '📵',
          description: '30 мин вечером',
        ),
        HabitModel(
          id: 'no_screen_before_sleep',
          name: 'Без экрана',
          icon: '🌙',
          description: 'за час до сна',
        ),
        HabitModel(
          id: 'yoga_stretch',
          name: 'Йога/растяжка',
          icon: '🤸‍♀️',
          description: 'расслабление',
        ),
        HabitModel(
          id: 'instrumental_music',
          name: 'Музыка без слов',
          icon: '🎵',
          description: 'для концентрации',
        ),
        HabitModel(
          id: 'morning_breathing',
          name: 'Утреннее дыхание',
          icon: '🌅',
          description: '5 мин',
        ),
        HabitModel(
          id: 'mindful_eating',
          name: 'Осознанное питание',
          icon: '🍽️',
          description: 'без спешки',
        ),
        HabitModel(
          id: 'pause_before_reaction',
          name: 'Пауза',
          icon: '⏸️',
          description: 'перед реакцией',
        ),
        HabitModel(
          id: 'act_of_kindness',
          name: '1 акт доброты',
          icon: '❤️',
          description: 'в день',
        ),
        HabitModel(
          id: 'write_emotions',
          name: 'Записать эмоции',
          icon: '😌',
          description: 'понимание себя',
        ),
        HabitModel(
          id: 'evening_without_negative',
          name: 'Вечер без негатива',
          icon: '🌅',
          description: 'позитивные мысли',
        ),
        HabitModel(
          id: 'goal_visualization',
          name: 'Визуализация цели',
          icon: '🎯',
          description: '10 мин',
        ),
        HabitModel(
          id: 'letting_go_technique',
          name: 'Техника отпускания',
          icon: '🕊️',
          description: 'освобождение',
        ),
        HabitModel(
          id: 'reading_before_sleep',
          name: 'Чтение',
          icon: '📖',
          description: 'перед сном',
        ),
        HabitModel(
          id: 'walk_without_headphones',
          name: 'Прогулка',
          icon: '🚶',
          description: 'без наушников',
        ),
      ],
    ),
    DevelopmentSphere(
      id: 'money',
      name: 'ДЕНЬГИ',
      icon: '💼',
      habits: [
        HabitModel(
          id: 'track_expenses',
          name: 'Записать расходы',
          icon: '💸',
          description: 'каждый день',
        ),
        HabitModel(
          id: 'track_income',
          name: 'Записать доходы',
          icon: '💰',
          description: 'учёт всех',
        ),
        HabitModel(
          id: 'make_budget',
          name: 'Составить бюджет',
          icon: '📊',
          description: 'на месяц',
        ),
        HabitModel(
          id: 'no_unnecessary_spending',
          name: 'Не тратить',
          icon: '🚫',
          description: 'на лишнее',
        ),
        HabitModel(
          id: 'save_10_percent',
          name: 'Откладывать 10%',
          icon: '🏦',
          description: 'с дохода',
        ),
        HabitModel(
          id: 'save_20_percent',
          name: 'Откладывать 20%',
          icon: '💎',
          description: 'агрессивные сбережения',
        ),
        HabitModel(
          id: 'invest_step',
          name: 'Инвестировать',
          icon: '📈',
          description: '1 шаг',
        ),
        HabitModel(
          id: 'study_investments',
          name: 'Изучить инвестиции',
          icon: '📚',
          description: '30 мин в день',
        ),
        HabitModel(
          id: 'read_business',
          name: 'Чтение про бизнес',
          icon: '📖',
          description: 'развитие',
        ),
        HabitModel(
          id: 'project_step',
          name: '1 шаг по проекту',
          icon: '🚀',
          description: 'каждый день',
        ),
        HabitModel(
          id: 'weekly_income_plan',
          name: 'План по доходу',
          icon: '📋',
          description: 'недели',
        ),
        HabitModel(
          id: 'daily_expense_review',
          name: 'Разбор трат',
          icon: '🔍',
          description: 'за день',
        ),
        HabitModel(
          id: 'weekly_expense_review',
          name: 'Разбор трат',
          icon: '📊',
          description: 'за неделю',
        ),
        HabitModel(
          id: 'monthly_income_goal',
          name: 'Цель по доходу',
          icon: '🎯',
          description: 'месяца',
        ),
        HabitModel(
          id: 'save_on_coffee',
          name: 'Экономия',
          icon: '☕',
          description: 'на кофе/еду',
        ),
        HabitModel(
          id: 'save_for_dream',
          name: 'Откладывать',
          icon: '💫',
          description: 'на мечту',
        ),
        HabitModel(
          id: 'no_credits',
          name: 'Не брать кредиты',
          icon: '🚫',
          description: 'жить по средствам',
        ),
        HabitModel(
          id: 'sell_unnecessary',
          name: 'Продажа ненужного',
          icon: '🏷️',
          description: 'доп. доход',
        ),
        HabitModel(
          id: 'financial_diary',
          name: 'Фин. дневник',
          icon: '📔',
          description: 'вести',
        ),
        HabitModel(
          id: 'money_talk_partner',
          name: 'Разговор о деньгах',
          icon: '💬',
          description: 'с партнёром',
        ),
      ],
    ),
  ];

  static DevelopmentSphere? findById(String id) {
    try {
      return spheres.firstWhere((sphere) => sphere.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<HabitModel> getHabitsForSpheres(List<String> sphereIds) {
    final List<HabitModel> habits = [];
    for (final sphereId in sphereIds) {
      final sphere = findById(sphereId);
      if (sphere != null) {
        habits.addAll(sphere.habits);
      }
    }
    return habits;
  }
}
