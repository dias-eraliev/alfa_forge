import '../models/quote_model.dart';

/// База мотивационных цитат для мужчин
class QuotesDatabase {
  static const List<Map<String, dynamic>> _quotesData = [
    // =================== ДЕНЬГИ ===================
    {
      'id': 'money_001',
      'text': 'Деньги - это инструмент свободы, а не цель жизни',
      'author': 'Уоррен Баффет',
      'category': 'money',
      'timeContext': 'any',
      'priority': 9,
      'tags': ['свобода', 'инвестиции', 'цель'],
      'targetZones': ['ДЕНЬГИ'],
    },
    {
      'id': 'money_002',
      'text': 'Богатство состоит не в обладании большими сокровищами, а в том, чтобы иметь мало потребностей',
      'author': 'Эпиктет',
      'category': 'money',
      'timeContext': 'evening',
      'priority': 8,
      'tags': ['философия', 'потребности', 'мудрость'],
      'targetZones': ['ДЕНЬГИ', 'СПОКОЙСТВИЕ'],
    },
    {
      'id': 'money_003',
      'text': 'Инвестируй в себя. Твой мозг может дать тебе миллион долларов в год',
      'author': 'Роберт Кийосаки',
      'category': 'money',
      'timeContext': 'morning',
      'priority': 10,
      'tags': ['инвестиции', 'образование', 'развитие'],
      'targetZones': ['ДЕНЬГИ', 'РАЗУМ'],
    },
    {
      'id': 'money_004',
      'text': 'Время дороже денег. Ты можешь получить больше денег, но не можешь получить больше времени',
      'author': 'Джим Рон',
      'category': 'money',
      'timeContext': 'workday',
      'priority': 9,
      'tags': ['время', 'ценности', 'приоритеты'],
      'targetZones': ['ДЕНЬГИ', 'ФОКУС'],
    },
    {
      'id': 'money_005',
      'text': 'Не экономь на том, что работает за тебя 24/7',
      'author': 'Современная мудрость',
      'category': 'money',
      'timeContext': 'any',
      'priority': 7,
      'tags': ['инвестиции', 'активы', 'пассивный доход'],
      'targetZones': ['ДЕНЬГИ'],
    },

    // =================== ДИСЦИПЛИНА ===================
    {
      'id': 'discipline_001',
      'text': 'Дисциплина - это мост между целью и достижением',
      'author': 'Джим Рон',
      'category': 'discipline',
      'timeContext': 'morning',
      'priority': 10,
      'tags': ['цели', 'достижения', 'успех'],
      'targetZones': ['ВОЛЯ', 'ФОКУС'],
    },
    {
      'id': 'discipline_002',
      'text': 'Дисциплина - это делать то, что нужно делать, даже когда не хочется',
      'author': 'Марк Твен',
      'category': 'discipline',
      'timeContext': 'any',
      'priority': 9,
      'tags': ['обязательства', 'сила воли', 'характер'],
      'targetZones': ['ВОЛЯ'],
    },
    {
      'id': 'discipline_003',
      'text': 'Недисциплинированность - это просто отложенная боль',
      'author': 'Джордан Питерсон',
      'category': 'discipline',
      'timeContext': 'workday',
      'priority': 8,
      'tags': ['ответственность', 'последствия', 'выбор'],
      'targetZones': ['ВОЛЯ', 'РАЗУМ'],
    },
    {
      'id': 'discipline_004',
      'text': 'Самодисциплина - это способность заставить себя делать то, что должно быть сделано, когда это должно быть сделано, независимо от того, чувствуешь ли ты это или нет',
      'author': 'Элберт Хаббард',
      'category': 'discipline',
      'timeContext': 'morning',
      'priority': 9,
      'tags': ['самоконтроль', 'обязательства', 'постоянство'],
      'targetZones': ['ВОЛЯ'],
    },

    // =================== ВОЛЯ ===================
    {
      'id': 'will_001',
      'text': 'Сила воли - это мышца. Тренируй её каждый день',
      'author': 'Современная психология',
      'category': 'will',
      'timeContext': 'morning',
      'priority': 10,
      'tags': ['тренировка', 'характер', 'развитие'],
      'targetZones': ['ВОЛЯ', 'ТЕЛО'],
    },
    {
      'id': 'will_002',
      'text': 'Человек может вынести почти что угодно, если у него есть причина',
      'author': 'Виктор Франкл',
      'category': 'will',
      'timeContext': 'any',
      'priority': 9,
      'tags': ['смысл', 'выносливость', 'мотивация'],
      'targetZones': ['ВОЛЯ', 'РАЗУМ'],
    },
    {
      'id': 'will_003',
      'text': 'Твоя воля определяет твою реальность',
      'author': 'Стоическая философия',
      'category': 'will',
      'timeContext': 'evening',
      'priority': 8,
      'tags': ['реальность', 'контроль', 'выбор'],
      'targetZones': ['ВОЛЯ', 'СПОКОЙСТВИЕ'],
    },
    {
      'id': 'will_004',
      'text': 'Не жди мотивации. Действуй и мотивация придет',
      'author': 'Зиг Зиглар',
      'category': 'will',
      'timeContext': 'workday',
      'priority': 9,
      'tags': ['действие', 'мотивация', 'инициатива'],
      'targetZones': ['ВОЛЯ', 'ФОКУС'],
    },

    // =================== ФОКУС ===================
    {
      'id': 'focus_001',
      'text': 'Где внимание, там и энергия. Где энергия, там и результат',
      'author': 'Тони Роббинс',
      'category': 'focus',
      'timeContext': 'workday',
      'priority': 10,
      'tags': ['внимание', 'энергия', 'результат'],
      'targetZones': ['ФОКУС'],
    },
    {
      'id': 'focus_002',
      'text': 'Концентрация - это корень всех высших способностей человека',
      'author': 'Брюс Ли',
      'category': 'focus',
      'timeContext': 'workday',
      'priority': 9,
      'tags': ['концентрация', 'способности', 'мастерство'],
      'targetZones': ['ФОКУС', 'ТЕЛО'],
    },
    {
      'id': 'focus_003',
      'text': 'Многозадачность - это искусство делать несколько дел плохо одновременно',
      'author': 'Современная мудрость',
      'category': 'focus',
      'timeContext': 'workday',
      'priority': 8,
      'tags': ['многозадачность', 'качество', 'эффективность'],
      'targetZones': ['ФОКУС'],
    },
    {
      'id': 'focus_004',
      'text': 'Успех требует единого фокуса',
      'author': 'Стив Джобс',
      'category': 'focus',
      'timeContext': 'morning',
      'priority': 9,
      'tags': ['успех', 'приоритеты', 'простота'],
      'targetZones': ['ФОКУС', 'ДЕНЬГИ'],
    },

    // =================== СИЛА ===================
    {
      'id': 'strength_001',
      'text': 'Сильные мужчины создают хорошие времена. Хорошие времена создают слабых мужчин. Слабые мужчины создают трудные времена. Трудные времена создают сильных мужчин',
      'author': 'Г.М. Хопф',
      'category': 'strength',
      'timeContext': 'morning',
      'priority': 10,
      'tags': ['сила', 'мужественность', 'история', 'ответственность'],
      'targetZones': ['ВОЛЯ', 'ТЕЛО'],
    },
    {
      'id': 'strength_002',
      'text': 'Железо точит железо, и человек точит человека',
      'author': 'Притчи Соломона',
      'category': 'strength',
      'timeContext': 'any',
      'priority': 8,
      'tags': ['дружба', 'развитие', 'взаимопомощь'],
      'targetZones': ['ТЕЛО', 'ВОЛЯ'],
    },
    {
      'id': 'strength_003',
      'text': 'Твоя единственная конкуренция - это тот, кем ты был вчера',
      'author': 'Современная мотивация',
      'category': 'strength',
      'timeContext': 'morning',
      'priority': 9,
      'tags': ['прогресс', 'самосовершенствование', 'сравнение'],
      'targetZones': ['ТЕЛО', 'ВОЛЯ', 'РАЗУМ'],
    },

    // =================== УСПЕХ ===================
    {
      'id': 'success_001',
      'text': 'Успех - это сумма маленьких усилий день за днем',
      'author': 'Роберт Кольер',
      'category': 'success',
      'timeContext': 'evening',
      'priority': 10,
      'tags': ['постоянство', 'усилия', 'прогресс'],
      'targetZones': ['ФОКУС', 'ВОЛЯ'],
    },
    {
      'id': 'success_002',
      'text': 'Неудача - это просто возможность начать снова, но уже более разумно',
      'author': 'Генри Форд',
      'category': 'success',
      'timeContext': 'any',
      'priority': 8,
      'tags': ['неудача', 'опыт', 'мудрость'],
      'targetZones': ['РАЗУМ', 'ВОЛЯ'],
    },
    {
      'id': 'success_003',
      'text': 'Единственный способ достичь невозможного - поверить, что это возможно',
      'author': 'Чарльз Кингсли',
      'category': 'success',
      'timeContext': 'morning',
      'priority': 9,
      'tags': ['вера', 'возможности', 'мышление'],
      'targetZones': ['РАЗУМ', 'ВОЛЯ'],
    },

    // =================== МЫШЛЕНИЕ ===================
    {
      'id': 'mindset_001',
      'text': 'Измени свои мысли и ты изменишь свой мир',
      'author': 'Норман Винсент Пил',
      'category': 'mindset',
      'timeContext': 'morning',
      'priority': 9,
      'tags': ['мысли', 'перспектива', 'изменения'],
      'targetZones': ['РАЗУМ', 'СПОКОЙСТВИЕ'],
    },
    {
      'id': 'mindset_002',
      'text': 'Ум как парашют - работает только когда открыт',
      'author': 'Фрэнк Заппа',
      'category': 'mindset',
      'timeContext': 'workday',
      'priority': 7,
      'tags': ['открытость', 'обучение', 'гибкость'],
      'targetZones': ['РАЗУМ'],
    },
    {
      'id': 'mindset_003',
      'text': 'Ты не можешь контролировать все что происходит с тобой, но ты можешь контролировать свою реакцию',
      'author': 'Эпиктет',
      'category': 'mindset',
      'timeContext': 'evening',
      'priority': 8,
      'tags': ['контроль', 'реакция', 'стоицизм'],
      'targetZones': ['РАЗУМ', 'СПОКОЙСТВИЕ'],
    },

    // =================== ЛИДЕРСТВО ===================
    {
      'id': 'leadership_001',
      'text': 'Лидер - это тот, кто знает путь, идет по пути и показывает путь',
      'author': 'Джон Максвелл',
      'category': 'leadership',
      'timeContext': 'workday',
      'priority': 8,
      'tags': ['лидерство', 'пример', 'направление'],
      'targetZones': ['ВОЛЯ', 'РАЗУМ'],
    },
    {
      'id': 'leadership_002',
      'text': 'Великий лидер принимает на себя ответственность за ошибки команды и отдает команде заслуги в успехе',
      'author': 'Джон Максвелл',
      'category': 'leadership',
      'timeContext': 'workday',
      'priority': 9,
      'tags': ['ответственность', 'команда', 'смирение'],
      'targetZones': ['ВОЛЯ', 'РАЗУМ'],
    },

    // =================== РАБОТА ===================
    {
      'id': 'work_001',
      'text': 'Выбери работу по душе, и тебе не придется работать ни дня в своей жизни',
      'author': 'Конфуций',
      'category': 'work',
      'timeContext': 'workday',
      'priority': 8,
      'tags': ['призвание', 'страсть', 'удовольствие'],
      'targetZones': ['ДЕНЬГИ', 'РАЗУМ'],
    },
    {
      'id': 'work_002',
      'text': 'Гений - это 1% вдохновения и 99% пота',
      'author': 'Томас Эдисон',
      'category': 'work',
      'timeContext': 'workday',
      'priority': 9,
      'tags': ['труд', 'упорство', 'гений'],
      'targetZones': ['ФОКУС', 'ВОЛЯ'],
    },

    // =================== ЗДОРОВЬЕ ===================
    {
      'id': 'health_001',
      'text': 'Береги свое тело. Это единственное место, где тебе предстоит жить',
      'author': 'Джим Рон',
      'category': 'health',
      'timeContext': 'morning',
      'priority': 9,
      'tags': ['тело', 'здоровье', 'забота'],
      'targetZones': ['ТЕЛО'],
    },
    {
      'id': 'health_002',
      'text': 'Физическая активность - лучшее лекарство от стресса',
      'author': 'Современная медицина',
      'category': 'health',
      'timeContext': 'any',
      'priority': 8,
      'tags': ['спорт', 'стресс', 'здоровье'],
      'targetZones': ['ТЕЛО', 'СПОКОЙСТВИЕ'],
    },
    {
      'id': 'health_003',
      'text': 'Сильное тело рождает сильный дух',
      'author': 'Древняя мудрость',
      'category': 'health',
      'timeContext': 'morning',
      'priority': 9,
      'tags': ['сила', 'дух', 'единство'],
      'targetZones': ['ТЕЛО', 'ВОЛЯ'],
    },

    // =================== УТРЕННИЕ МОТИВАЦИОННЫЕ ===================
    {
      'id': 'morning_001',
      'text': 'Каждое утро у тебя есть два выбора: продолжать спать или вставать и преследовать свои мечты',
      'author': 'Современная мотивация',
      'category': 'success',
      'timeContext': 'morning',
      'priority': 10,
      'tags': ['утро', 'выбор', 'мечты'],
      'targetZones': ['ВОЛЯ', 'ФОКУС'],
    },
    {
      'id': 'morning_002',
      'text': 'Победи себя утром - и день твой',
      'author': 'Современная мудрость',
      'category': 'discipline',
      'timeContext': 'morning',
      'priority': 9,
      'tags': ['утро', 'самоконтроль', 'день'],
      'targetZones': ['ВОЛЯ'],
    },

    // =================== ВЕЧЕРНИЕ РЕФЛЕКСИВНЫЕ ===================
    {
      'id': 'evening_001',
      'text': 'Не жди понедельника. Начни прямо сейчас',
      'author': 'Современная мотивация',
      'category': 'will',
      'timeContext': 'evening',
      'priority': 9,
      'tags': ['действие', 'промедление', 'начало'],
      'targetZones': ['ВОЛЯ', 'ФОКУС'],
    },
    {
      'id': 'evening_002',
      'text': 'Каждый день - это новая возможность стать лучше',
      'author': 'Современная мудрость',
      'category': 'success',
      'timeContext': 'evening',
      'priority': 8,
      'tags': ['возможности', 'рост', 'прогресс'],
      'targetZones': ['РАЗУМ', 'ВОЛЯ'],
    },
  ];

  /// Получить все цитаты как объекты Quote
  static List<Quote> getAllQuotes() {
    return _quotesData.map((data) {
      return Quote(
        id: data['id'],
        text: data['text'],
        author: data['author'],
        category: QuoteCategory.values.firstWhere(
          (c) => c.name == data['category'],
          orElse: () => QuoteCategory.success,
        ),
        timeContext: TimeContext.values.firstWhere(
          (t) => t.name == data['timeContext'],
          orElse: () => TimeContext.any,
        ),
        priority: data['priority'] ?? 5,
        tags: List<String>.from(data['tags'] ?? []),
        targetZones: List<String>.from(data['targetZones'] ?? []),
        isPremium: data['isPremium'] ?? false,
      );
    }).toList();
  }

  /// Получить цитаты по категории
  static List<Quote> getQuotesByCategory(QuoteCategory category) {
    return getAllQuotes().where((quote) => quote.category == category).toList();
  }

  /// Получить цитаты для времени дня
  static List<Quote> getQuotesForTimeContext(TimeContext timeContext) {
    return getAllQuotes()
        .where((quote) => 
            quote.timeContext == timeContext || quote.timeContext == TimeContext.any)
        .toList();
  }

  /// Получить цитаты для зоны пользователя
  static List<Quote> getQuotesForZone(String zone) {
    return getAllQuotes()
        .where((quote) => quote.isAppropriateForZone(zone))
        .toList();
  }

  /// Получить случайную цитату с учетом контекста
  static Quote? getContextualQuote({
    required DateTime time,
    String? userZone,
    List<String>? enabledCategories,
    List<String>? excludeIds,
  }) {
    var quotes = getAllQuotes();

    // Фильтруем по времени
    quotes = quotes.where((quote) => quote.isAppropriateForTime(time)).toList();

    // Фильтруем по зоне пользователя
    if (userZone != null) {
      final zoneQuotes = quotes.where((quote) => quote.isAppropriateForZone(userZone)).toList();
      if (zoneQuotes.isNotEmpty) {
        quotes = zoneQuotes;
      }
    }

    // Фильтруем по включенным категориям
    if (enabledCategories != null && enabledCategories.isNotEmpty) {
      quotes = quotes.where((quote) => 
        enabledCategories.contains(quote.category.name)
      ).toList();
    }

    // Исключаем уже показанные цитаты
    if (excludeIds != null && excludeIds.isNotEmpty) {
      quotes = quotes.where((quote) => !excludeIds.contains(quote.id)).toList();
    }

    if (quotes.isEmpty) return null;

    // Сортируем по приоритету и выбираем из топа
    quotes.sort((a, b) => b.priority.compareTo(a.priority));
    final topQuotes = quotes.take(5).toList();
    
    // Возвращаем случайную из топовых
    topQuotes.shuffle();
    return topQuotes.first;
  }

  /// Получить статистику цитат
  static Map<String, int> getQuotesStatistics() {
    final quotes = getAllQuotes();
    final stats = <String, int>{};
    
    for (final category in QuoteCategory.values) {
      stats[category.name] = quotes.where((q) => q.category == category).length;
    }
    
    return stats;
  }
}
