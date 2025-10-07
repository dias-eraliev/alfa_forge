import 'package:flutter/material.dart';
import '../models/habit_model.dart';

class HabitTemplatesLibrary {
  static List<HabitTemplate> getAllTemplates() {
    return [
      ...getHealthTemplates(),
      ...getFitnessTemplates(),
      ...getProductivityTemplates(),
      ...getLearningTemplates(),
      ...getSocialTemplates(),
      ...getCreativeTemplates(),
      ...getFinancialTemplates(),
      ...getSpiritualTemplates(),
    ];
  }

  static List<HabitTemplate> getPopularTemplates() {
    return getAllTemplates().where((template) => template.isPopular).toList();
  }

  static List<HabitTemplate> getTemplatesByCategory(HabitCategory category) {
    return getAllTemplates().where((template) => template.category == category).toList();
  }

  static List<HabitTemplate> getHealthTemplates() {
    return [
      HabitTemplate(
        id: 'drink_water',
        name: 'Пить воду',
        description: 'Выпивать стакан воды каждое утро для поддержания водного баланса',
        motivation: 'Вода - основа жизни. Правильная гидратация улучшает самочувствие и работу мозга.',
        icon: Icons.water_drop,
        color: const Color(0xFF03A9F4),
        category: HabitCategory.health,
        defaultFrequency: HabitFrequency(type: HabitFrequencyType.daily),
        defaultDuration: 2,
        defaultDifficulty: HabitDifficulty.easy,
        defaultTags: ['здоровье', 'гидратация', 'утро'],
        tips: [
          'Поставьте стакан воды у кровати',
          'Добавьте лимон для вкуса',
          'Постепенно увеличивайте количество воды',
        ],
        isPopular: true,
      ),
      
      HabitTemplate(
        id: 'morning_stretching',
        name: 'Утренняя растяжка',
        description: 'Простые упражнения на растяжку после пробуждения',
        motivation: 'Растяжка поможет проснуться, улучшит гибкость и подготовит тело к дню.',
        icon: Icons.accessibility_new,
        color: const Color(0xFF8BC34A),
        category: HabitCategory.health,
        defaultFrequency: HabitFrequency(type: HabitFrequencyType.daily),
        defaultDuration: 10,
        defaultDifficulty: HabitDifficulty.easy,
        defaultTags: ['растяжка', 'утро', 'гибкость'],
        tips: [
          'Начните с простых движений',
          'Не делайте резких движений',
          'Дышите глубоко во время растяжки',
        ],
        isPopular: true,
      ),

      HabitTemplate(
        id: 'healthy_sleep',
        name: 'Здоровый сон',
        description: 'Ложиться спать в одно и то же время каждый день',
        motivation: 'Регулярный режим сна улучшает качество отдыха и общее самочувствие.',
        icon: Icons.bedtime,
        color: const Color(0xFF673AB7),
        category: HabitCategory.health,
        defaultFrequency: HabitFrequency(type: HabitFrequencyType.daily),
        defaultDifficulty: HabitDifficulty.medium,
        defaultTags: ['сон', 'режим', 'восстановление'],
        tips: [
          'Установите будильник за час до сна',
          'Избегайте экранов перед сном',
          'Создайте расслабляющую рутину',
        ],
        isPopular: true,
      ),

      HabitTemplate(
        id: 'vitamins',
        name: 'Прием витаминов',
        description: 'Принимать витамины или добавки для поддержания здоровья',
        motivation: 'Витамины помогают восполнить недостаток питательных веществ в организме.',
        icon: Icons.medication,
        color: const Color(0xFFFF9800),
        category: HabitCategory.health,
        defaultFrequency: HabitFrequency(type: HabitFrequencyType.daily),
        defaultDuration: 1,
        defaultDifficulty: HabitDifficulty.easy,
        defaultTags: ['витамины', 'здоровье', 'иммунитет'],
        tips: [
          'Принимайте во время еды',
          'Консультируйтесь с врачом',
          'Ведите запись приема',
        ],
      ),
    ];
  }

  static List<HabitTemplate> getFitnessTemplates() {
    return [
      HabitTemplate(
        id: 'daily_workout',
        name: 'Ежедневная тренировка',
        description: 'Физические упражнения для поддержания формы',
        motivation: 'Регулярные тренировки укрепляют тело, улучшают настроение и дают энергию.',
        icon: Icons.fitness_center,
        color: const Color(0xFFFF5722),
        category: HabitCategory.fitness,
        defaultFrequency: HabitFrequency(type: HabitFrequencyType.daily),
        defaultDuration: 30,
        defaultDifficulty: HabitDifficulty.medium,
        defaultTags: ['спорт', 'здоровье', 'сила'],
        tips: [
          'Начните с 15 минут',
          'Выберите упражнения по душе',
          'Постепенно увеличивайте нагрузку',
        ],
        isPopular: true,
      ),

      HabitTemplate(
        id: 'morning_run',
        name: 'Утренняя пробежка',
        description: 'Бег или быстрая ходьба на свежем воздухе',
        motivation: 'Кардио нагрузка укрепляет сердце и дает заряд энергии на весь день.',
        icon: Icons.directions_run,
        color: const Color(0xFF4CAF50),
        category: HabitCategory.fitness,
        defaultFrequency: HabitFrequency(type: HabitFrequencyType.weekly, timesPerWeek: 3),
        defaultDuration: 20,
        defaultDifficulty: HabitDifficulty.medium,
        defaultTags: ['бег', 'кардио', 'утро'],
        tips: [
          'Начните с быстрой ходьбы',
          'Разминайтесь перед бегом',
          'Следите за дыханием',
        ],
        isPopular: true,
      ),

      HabitTemplate(
        id: 'pushups',
        name: 'Отжимания',
        description: 'Ежедневные отжимания для укрепления верхней части тела',
        motivation: 'Отжимания развивают силу рук, груди и корпуса.',
        icon: Icons.sports_gymnastics,
        color: const Color(0xFFE91E63),
        category: HabitCategory.fitness,
        defaultFrequency: HabitFrequency(type: HabitFrequencyType.daily),
        defaultDuration: 5,
        defaultDifficulty: HabitDifficulty.medium,
        defaultTags: ['отжимания', 'сила', 'дома'],
        tips: [
          'Начните с отжиманий с колен',
          'Держите тело прямо',
          'Увеличивайте количество постепенно',
        ],
      ),

      HabitTemplate(
        id: 'steps_goal',
        name: '10,000 шагов',
        description: 'Проходить 10,000 шагов в день',
        motivation: 'Ходьба - простой способ поддерживать активность и здоровье.',
        icon: Icons.directions_walk,
        color: const Color(0xFF607D8B),
        category: HabitCategory.fitness,
        defaultFrequency: HabitFrequency(type: HabitFrequencyType.daily),
        defaultDifficulty: HabitDifficulty.easy,
        defaultTags: ['ходьба', 'активность', 'здоровье'],
        tips: [
          'Используйте шагомер или приложение',
          'Поднимайтесь по лестнице',
          'Паркуйтесь дальше от входа',
        ],
      ),
    ];
  }

  static List<HabitTemplate> getProductivityTemplates() {
    return [
      HabitTemplate(
        id: 'daily_planning',
        name: 'Планирование дня',
        description: 'Составлять план задач на каждый день',
        motivation: 'Планирование помогает быть более организованным и продуктивным.',
        icon: Icons.today,
        color: const Color(0xFF2196F3),
        category: HabitCategory.productivity,
        defaultFrequency: HabitFrequency(type: HabitFrequencyType.daily),
        defaultDuration: 10,
        defaultDifficulty: HabitDifficulty.easy,
        defaultTags: ['планирование', 'организация', 'продуктивность'],
        tips: [
          'Планируйте с вечера',
          'Ставьте приоритеты',
          'Оставляйте время на непредвиденное',
        ],
        isPopular: true,
      ),

      HabitTemplate(
        id: 'email_inbox_zero',
        name: 'Разбор почты',
        description: 'Проверять и обрабатывать электронную почту',
        motivation: 'Регулярная работа с почтой предотвращает накопление сообщений.',
        icon: Icons.email,
        color: const Color(0xFFFF9800),
        category: HabitCategory.productivity,
        defaultFrequency: HabitFrequency(type: HabitFrequencyType.daily),
        defaultDuration: 15,
        defaultDifficulty: HabitDifficulty.medium,
        defaultTags: ['почта', 'организация', 'работа'],
        tips: [
          'Отвечайте сразу или добавляйте в задачи',
          'Используйте фильтры и папки',
          'Отписывайтесь от ненужных рассылок',
        ],
      ),

      HabitTemplate(
        id: 'desk_cleanup',
        name: 'Уборка рабочего места',
        description: 'Поддерживать чистоту и порядок на рабочем столе',
        motivation: 'Чистое рабочее место способствует концентрации и продуктивности.',
        icon: Icons.cleaning_services,
        color: const Color(0xFF795548),
        category: HabitCategory.productivity,
        defaultFrequency: HabitFrequency(type: HabitFrequencyType.daily),
        defaultDuration: 5,
        defaultDifficulty: HabitDifficulty.easy,
        defaultTags: ['порядок', 'организация', 'работа'],
        tips: [
          'Убирайте в конце рабочего дня',
          'Найдите место для каждой вещи',
          'Минимализм - ваш друг',
        ],
      ),

      HabitTemplate(
        id: 'deep_work',
        name: 'Глубокая работа',
        description: 'Посвящать время концентрированной работе без отвлечений',
        motivation: 'Глубокая концентрация позволяет решать сложные задачи эффективнее.',
        icon: Icons.psychology,
        color: const Color(0xFF3F51B5),
        category: HabitCategory.productivity,
        defaultFrequency: HabitFrequency(type: HabitFrequencyType.daily),
        defaultDuration: 60,
        defaultDifficulty: HabitDifficulty.hard,
        defaultTags: ['концентрация', 'работа', 'эффективность'],
        tips: [
          'Отключите уведомления',
          'Выберите самое важное дело',
          'Начните с 25 минут (Pomodoro)',
        ],
      ),
    ];
  }

  static List<HabitTemplate> getLearningTemplates() {
    return [
      HabitTemplate(
        id: 'daily_reading',
        name: 'Ежедневное чтение',
        description: 'Читать книги для расширения кругозора',
        motivation: 'Чтение развивает интеллект, улучшает словарный запас и расширяет знания.',
        icon: Icons.book,
        color: const Color(0xFF9C27B0),
        category: HabitCategory.learning,
        defaultFrequency: HabitFrequency(type: HabitFrequencyType.daily),
        defaultDuration: 30,
        defaultDifficulty: HabitDifficulty.easy,
        defaultTags: ['чтение', 'книги', 'развитие'],
        tips: [
          'Читайте в одно и то же время',
          'Ведите список прочитанных книг',
          'Обсуждайте прочитанное с друзьями',
        ],
        isPopular: true,
      ),

      HabitTemplate(
        id: 'language_learning',
        name: 'Изучение языка',
        description: 'Ежедневная практика иностранного языка',
        motivation: 'Изучение языков расширяет возможности и развивает мозг.',
        icon: Icons.translate,
        color: const Color(0xFF00BCD4),
        category: HabitCategory.learning,
        defaultFrequency: HabitFrequency(type: HabitFrequencyType.daily),
        defaultDuration: 20,
        defaultDifficulty: HabitDifficulty.medium,
        defaultTags: ['язык', 'обучение', 'развитие'],
        tips: [
          'Используйте приложения для изучения',
          'Смотрите фильмы с субтитрами',
          'Практикуйтесь с носителями языка',
        ],
        isPopular: true,
      ),

      HabitTemplate(
        id: 'online_course',
        name: 'Онлайн-курс',
        description: 'Изучение нового навыка через онлайн-курсы',
        motivation: 'Постоянное обучение помогает оставаться конкурентоспособным.',
        icon: Icons.school,
        color: const Color(0xFF4CAF50),
        category: HabitCategory.learning,
        defaultFrequency: HabitFrequency(type: HabitFrequencyType.weekly, timesPerWeek: 3),
        defaultDuration: 45,
        defaultDifficulty: HabitDifficulty.medium,
        defaultTags: ['курсы', 'навыки', 'образование'],
        tips: [
          'Выберите курс по интересам',
          'Делайте заметки',
          'Применяйте знания на практике',
        ],
      ),

      HabitTemplate(
        id: 'podcast_listening',
        name: 'Подкасты',
        description: 'Слушать образовательные подкасты',
        motivation: 'Подкасты позволяют учиться в дороге и во время других дел.',
        icon: Icons.headphones,
        color: const Color(0xFFFF5722),
        category: HabitCategory.learning,
        defaultFrequency: HabitFrequency(type: HabitFrequencyType.daily),
        defaultDuration: 30,
        defaultDifficulty: HabitDifficulty.easy,
        defaultTags: ['подкасты', 'аудио', 'обучение'],
        tips: [
          'Слушайте в дороге на работу',
          'Выбирайте качественный контент',
          'Делитесь интересными выпусками',
        ],
      ),
    ];
  }

  static List<HabitTemplate> getSocialTemplates() {
    return [
      HabitTemplate(
        id: 'call_family',
        name: 'Звонок семье',
        description: 'Регулярно общаться с родными и близкими',
        motivation: 'Поддержание связи с семьей укрепляет отношения и дает эмоциональную поддержку.',
        icon: Icons.family_restroom,
        color: const Color(0xFFE91E63),
        category: HabitCategory.social,
        defaultFrequency: HabitFrequency(type: HabitFrequencyType.weekly, timesPerWeek: 2),
        defaultDuration: 15,
        defaultDifficulty: HabitDifficulty.easy,
        defaultTags: ['семья', 'общение', 'отношения'],
        tips: [
          'Назначьте конкретные дни для звонков',
          'Интересуйтесь делами близких',
          'Делитесь своими новостями',
        ],
        isPopular: true,
      ),

      HabitTemplate(
        id: 'gratitude_message',
        name: 'Благодарность',
        description: 'Выражать благодарность людям в жизни',
        motivation: 'Благодарность укрепляет отношения и улучшает настроение.',
        icon: Icons.favorite,
        color: const Color(0xFFFF9800),
        category: HabitCategory.social,
        defaultFrequency: HabitFrequency(type: HabitFrequencyType.weekly, timesPerWeek: 3),
        defaultDuration: 5,
        defaultDifficulty: HabitDifficulty.easy,
        defaultTags: ['благодарность', 'позитив', 'отношения'],
        tips: [
          'Пишите короткие сообщения',
          'Будьте искренними',
          'Благодарите за конкретные вещи',
        ],
      ),

      HabitTemplate(
        id: 'meet_friends',
        name: 'Встречи с друзьями',
        description: 'Планировать регулярные встречи с друзьями',
        motivation: 'Дружба важна для психического здоровья и счастья.',
        icon: Icons.people,
        color: const Color(0xFF2196F3),
        category: HabitCategory.social,
        defaultFrequency: HabitFrequency(type: HabitFrequencyType.weekly, timesPerWeek: 1),
        defaultDuration: 120,
        defaultDifficulty: HabitDifficulty.medium,
        defaultTags: ['друзья', 'общение', 'досуг'],
        tips: [
          'Планируйте заранее',
          'Предлагайте разные активности',
          'Будьте инициативными',
        ],
      ),
    ];
  }

  static List<HabitTemplate> getCreativeTemplates() {
    return [
      HabitTemplate(
        id: 'daily_drawing',
        name: 'Ежедневное рисование',
        description: 'Рисовать или делать наброски каждый день',
        motivation: 'Рисование развивает креативность и помогает расслабиться.',
        icon: Icons.brush,
        color: const Color(0xFFE91E63),
        category: HabitCategory.creative,
        defaultFrequency: HabitFrequency(type: HabitFrequencyType.daily),
        defaultDuration: 20,
        defaultDifficulty: HabitDifficulty.easy,
        defaultTags: ['рисование', 'творчество', 'искусство'],
        tips: [
          'Начните с простых набросков',
          'Используйте разные материалы',
          'Не стремитесь к совершенству',
        ],
      ),

      HabitTemplate(
        id: 'journaling',
        name: 'Ведение дневника',
        description: 'Записывать мысли и переживания',
        motivation: 'Дневник помогает понять себя и отслеживать прогресс.',
        icon: Icons.edit_note,
        color: const Color(0xFF795548),
        category: HabitCategory.creative,
        defaultFrequency: HabitFrequency(type: HabitFrequencyType.daily),
        defaultDuration: 15,
        defaultDifficulty: HabitDifficulty.easy,
        defaultTags: ['дневник', 'письмо', 'рефлексия'],
        tips: [
          'Пишите без цензуры',
          'Записывайте благодарности',
          'Анализируйте свои эмоции',
        ],
        isPopular: true,
      ),

      HabitTemplate(
        id: 'music_practice',
        name: 'Игра на инструменте',
        description: 'Практиковаться в игре на музыкальном инструменте',
        motivation: 'Музыка развивает мозг и приносит радость.',
        icon: Icons.music_note,
        color: const Color(0xFF9C27B0),
        category: HabitCategory.creative,
        defaultFrequency: HabitFrequency(type: HabitFrequencyType.daily),
        defaultDuration: 30,
        defaultDifficulty: HabitDifficulty.medium,
        defaultTags: ['музыка', 'инструмент', 'практика'],
        tips: [
          'Начните с простых мелодий',
          'Играйте медленно и точно',
          'Записывайте свою игру',
        ],
      ),
    ];
  }

  static List<HabitTemplate> getFinancialTemplates() {
    return [
      HabitTemplate(
        id: 'expense_tracking',
        name: 'Учет расходов',
        description: 'Записывать все траты в течение дня',
        motivation: 'Контроль расходов помогает достигать финансовых целей.',
        icon: Icons.account_balance_wallet,
        color: const Color(0xFF009688),
        category: HabitCategory.financial,
        defaultFrequency: HabitFrequency(type: HabitFrequencyType.daily),
        defaultDuration: 5,
        defaultDifficulty: HabitDifficulty.easy,
        defaultTags: ['деньги', 'бюджет', 'учет'],
        tips: [
          'Используйте приложение для учета',
          'Фотографируйте чеки',
          'Анализируйте траты еженедельно',
        ],
        isPopular: true,
      ),

      HabitTemplate(
        id: 'daily_saving',
        name: 'Ежедневные сбережения',
        description: 'Откладывать небольшую сумму каждый день',
        motivation: 'Регулярные сбережения создают финансовую подушку безопасности.',
        icon: Icons.savings,
        color: const Color(0xFF4CAF50),
        category: HabitCategory.financial,
        defaultFrequency: HabitFrequency(type: HabitFrequencyType.daily),
        defaultDuration: 2,
        defaultDifficulty: HabitDifficulty.easy,
        defaultTags: ['сбережения', 'накопления', 'финансы'],
        tips: [
          'Начните с малой суммы',
          'Автоматизируйте переводы',
          'Установите конкретную цель',
        ],
      ),

      HabitTemplate(
        id: 'financial_education',
        name: 'Финансовое образование',
        description: 'Изучать основы финансовой грамотности',
        motivation: 'Знания помогают принимать правильные финансовые решения.',
        icon: Icons.trending_up,
        color: const Color(0xFF2196F3),
        category: HabitCategory.financial,
        defaultFrequency: HabitFrequency(type: HabitFrequencyType.weekly, timesPerWeek: 3),
        defaultDuration: 20,
        defaultDifficulty: HabitDifficulty.medium,
        defaultTags: ['образование', 'инвестиции', 'финансы'],
        tips: [
          'Читайте финансовые книги',
          'Изучайте инвестиционные инструменты',
          'Следите за экономическими новостями',
        ],
      ),
    ];
  }

  static List<HabitTemplate> getSpiritualTemplates() {
    return [
      HabitTemplate(
        id: 'meditation',
        name: 'Медитация',
        description: 'Ежедневная практика осознанности и медитации',
        motivation: 'Медитация снижает стресс, улучшает концентрацию и внутренний покой.',
        icon: Icons.self_improvement,
        color: const Color(0xFF673AB7),
        category: HabitCategory.spiritual,
        defaultFrequency: HabitFrequency(type: HabitFrequencyType.daily),
        defaultDuration: 10,
        defaultDifficulty: HabitDifficulty.medium,
        defaultTags: ['медитация', 'осознанность', 'покой'],
        tips: [
          'Начните с 5 минут',
          'Найдите тихое место',
          'Используйте приложения для медитации',
        ],
        isPopular: true,
      ),

      HabitTemplate(
        id: 'gratitude_journal',
        name: 'Дневник благодарности',
        description: 'Записывать то, за что благодарны каждый день',
        motivation: 'Благодарность улучшает настроение и жизненную перспективу.',
        icon: Icons.favorite_border,
        color: const Color(0xFFFF9800),
        category: HabitCategory.spiritual,
        defaultFrequency: HabitFrequency(type: HabitFrequencyType.daily),
        defaultDuration: 5,
        defaultDifficulty: HabitDifficulty.easy,
        defaultTags: ['благодарность', 'позитив', 'дневник'],
        tips: [
          'Записывайте 3 вещи каждый день',
          'Будьте конкретными',
          'Перечитывайте записи',
        ],
        isPopular: true,
      ),

      HabitTemplate(
        id: 'nature_time',
        name: 'Время на природе',
        description: 'Проводить время на свежем воздухе каждый день',
        motivation: 'Природа восстанавливает энергию и улучшает психическое здоровье.',
        icon: Icons.nature,
        color: const Color(0xFF4CAF50),
        category: HabitCategory.spiritual,
        defaultFrequency: HabitFrequency(type: HabitFrequencyType.daily),
        defaultDuration: 30,
        defaultDifficulty: HabitDifficulty.easy,
        defaultTags: ['природа', 'воздух', 'восстановление'],
        tips: [
          'Гуляйте в парке',
          'Сидите в саду',
          'Наблюдайте за небом',
        ],
      ),
    ];
  }
}
