-- Seed default habits for onboarding and user_habits FKs
-- Run this after the initial schema is applied

-- Core defaults (also present in initial schema; kept for idempotency)
INSERT INTO habits (id, name, icon, description, category, difficulty, is_default)
VALUES
  ('early_rise', 'Ранний подъём', '🌅', 'Просыпаться в 6:00', 'body', 'medium', TRUE),
  ('reading', 'Чтение', '📚', '30 минут чтения', 'mind', 'easy', TRUE),
  ('workout', 'Тренировка', '🏋️‍♂️', 'Физические упражнения', 'body', 'hard', TRUE),
  ('meditation', 'Медитация', '🧘', '10 минут медитации', 'peace', 'easy', TRUE)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  icon = EXCLUDED.icon,
  description = EXCLUDED.description,
  category = EXCLUDED.category,
  difficulty = EXCLUDED.difficulty,
  is_default = EXCLUDED.is_default;

-- Body (ТЕЛО)
INSERT INTO habits (id, name, icon, description, category, difficulty, is_default) VALUES
  ('morning_exercise', 'Утренняя зарядка', '🏃', '10 мин', 'body', 'medium', TRUE),
  ('steps_10k', '10 000 шагов', '👟', 'в день', 'body', 'medium', TRUE),
  ('light_jog', 'Лёгкая пробежка', '🏃‍♂️', 'утром/вечером', 'body', 'medium', TRUE),
  ('gym_workout', 'Тренировка в зале', '💪', '3 раза в неделю', 'body', 'medium', TRUE),
  ('evening_stretch', 'Растяжка вечером', '🤸', '15 мин', 'body', 'easy', TRUE),
  ('sleep_before_23', 'Сон до 23:00', '🌙', 'каждый день', 'body', 'medium', TRUE),
  ('sleep_8h', '8 часов сна', '😴', 'полноценный отдых', 'body', 'medium', TRUE),
  ('cold_shower', 'Холодный душ', '🚿', '2-3 мин', 'body', 'medium', TRUE),
  ('water_2l', '2 литра воды', '💧', 'в день', 'body', 'easy', TRUE),
  ('no_elevator', 'Отказ от лифта', '🚶', 'по лестнице', 'body', 'easy', TRUE),
  ('contrast_shower', 'Контрастный душ', '🌡️', 'горячая-холодная', 'body', 'medium', TRUE),
  ('no_sweets', 'Нет сладкого', '🚫', 'без сахара', 'body', 'medium', TRUE),
  ('no_fastfood', 'Нет фастфуда', '🥗', 'здоровая еда', 'body', 'medium', TRUE),
  ('no_soda', 'Нет газировки', '🥤', 'чистая вода', 'body', 'easy', TRUE),
  ('no_alcohol', 'Нет алкоголя', '🚭', 'трезвый образ жизни', 'body', 'medium', TRUE),
  ('no_cigarettes', 'Нет сигарет', '🚭', 'здоровые лёгкие', 'body', 'medium', TRUE),
  ('fresh_air_walk', 'Прогулка', '�', 'на свежем воздухе', 'body', 'easy', TRUE),
  ('abs_pushups', 'Пресс/отжимания', '💪', 'каждый день', 'body', 'medium', TRUE),
  ('track_weight', 'Отслеживание веса', '⚖️', 'ежедневно', 'body', 'easy', TRUE),
  ('plank_1min', 'Планка 1 мин', '�🏋️', 'каждое утро', 'body', 'medium', TRUE)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name, icon = EXCLUDED.icon, description = EXCLUDED.description,
  category = EXCLUDED.category, difficulty = EXCLUDED.difficulty, is_default = EXCLUDED.is_default;

-- Will (ВОЛЯ)
INSERT INTO habits (id, name, icon, description, category, difficulty, is_default) VALUES
  ('no_sugar', 'Нет сахара', '🚫', 'чистое питание', 'will', 'medium', TRUE),
  ('no_fastfood_will', 'Нет фастфуда', '🥗', 'сила воли', 'will', 'medium', TRUE),
  ('no_alcohol_will', 'Нет алкоголя', '🚭', 'контроль себя', 'will', 'medium', TRUE),
  ('no_nicotine', 'Нет никотина', '🚭', 'чистые лёгкие', 'will', 'medium', TRUE),
  ('no_caffeine', 'Нет кофеина', '☕', 'естественная энергия', 'will', 'medium', TRUE),
  ('sleep_schedule', 'Режим сна', '⏰', 'без сбоев', 'will', 'medium', TRUE),
  ('hard_task_daily', '1 трудное дело', '💪', 'в день', 'will', 'medium', TRUE),
  ('no_excuses', 'Нет оправданий', '⚡', 'только действие', 'will', 'medium', TRUE),
  ('no_phone_1h', '1 час без телефона', '📵', 'цифровой детокс', 'will', 'medium', TRUE),
  ('no_social_24h', '24ч без соцсетей', '🚫', 'раз в неделю', 'will', 'medium', TRUE),
  ('cleaning_no_excuses', 'Уборка', '🧹', 'без отговорок', 'will', 'easy', TRUE),
  ('workout_through_dont_want', 'Тренировка', '💪', 'через "не хочу"', 'will', 'hard', TRUE),
  ('discipline_5min', '5 мин дисциплины', '⚡', 'утром', 'will', 'easy', TRUE),
  ('no_complaints', 'Нет жалоб', '🤐', 'позитивный настрой', 'will', 'medium', TRUE),
  ('no_laziness', 'Нет лени', '🚀', 'всегда в действии', 'will', 'medium', TRUE),
  ('no_procrastination', 'Нет прокрастинации', '⏱️', 'делать сейчас', 'will', 'medium', TRUE),
  ('do_immediately', 'Делать сразу', '⚡', 'не откладывать', 'will', 'medium', TRUE),
  ('keep_word', 'Держать слово', '🤝', 'всегда', 'will', 'medium', TRUE),
  ('first_alarm', 'Вставать', '⏰', 'при первом будильнике', 'will', 'medium', TRUE),
  ('overcome_weakness', '1 победа', '🏆', 'над слабостью', 'will', 'medium', TRUE)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name, icon = EXCLUDED.icon, description = EXCLUDED.description,
  category = EXCLUDED.category, difficulty = EXCLUDED.difficulty, is_default = EXCLUDED.is_default;

-- Focus (ФОКУС)
INSERT INTO habits (id, name, icon, description, category, difficulty, is_default) VALUES
  ('morning_plan', 'План на день', '📝', 'утром', 'focus', 'easy', TRUE),
  ('three_main_tasks', '3 главные задачи', '🎯', 'дня', 'focus', 'medium', TRUE),
  ('no_phone_until_9', 'Без телефона', '📵', 'до 9:00', 'focus', 'medium', TRUE),
  ('no_social_until_lunch', 'Без соцсетей', '🚫', 'до обеда', 'focus', 'medium', TRUE),
  ('deep_work_2h', '2 часа deep work', '🧠', 'без отвлечений', 'focus', 'hard', TRUE),
  ('pomodoro', 'Техника Помидора', '🍅', '25/5 мин', 'focus', 'medium', TRUE),
  ('limit_notifications', 'Ограничить уведомления', '🔕', 'только важные', 'focus', 'medium', TRUE),
  ('task_list', 'Список задач', '📋', 'ведение', 'focus', 'easy', TRUE),
  ('evening_review', 'Разбор дня', '🔍', 'вечером', 'focus', 'easy', TRUE),
  ('no_multitasking', 'Нет многозадачности', '🎯', 'одно дело', 'focus', 'medium', TRUE),
  ('work_by_priority', 'По приоритету', '📈', 'важное сначала', 'focus', 'medium', TRUE),
  ('study_1h_focused', '1 час учёбы', '📚', 'без отвлечений', 'focus', 'medium', TRUE),
  ('daily_goal', 'Цель дня', '🎯', 'одна главная', 'focus', 'medium', TRUE),
  ('weekly_goal', 'Цель недели', '📅', 'планирование', 'focus', 'medium', TRUE),
  ('no_extra_tabs', 'Нет лишних вкладок', '💻', 'чистый браузер', 'focus', 'easy', TRUE),
  ('productivity_journal', 'Дневник продуктивности', '📊', 'отслеживание', 'focus', 'medium', TRUE),
  ('weekly_plan', 'План на неделю', '📋', 'каждое воскресенье', 'focus', 'medium', TRUE),
  ('project_step', 'Шаг к проекту', '🚀', 'каждый день', 'focus', 'medium', TRUE),
  ('clear_schedule', 'Чёткое расписание', '⏰', 'по времени', 'focus', 'medium', TRUE),
  ('no_morning_news', 'Без новостей', '📰', 'утром', 'focus', 'easy', TRUE)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name, icon = EXCLUDED.icon, description = EXCLUDED.description,
  category = EXCLUDED.category, difficulty = EXCLUDED.difficulty, is_default = EXCLUDED.is_default;

-- Mind (РАЗУМ)
INSERT INTO habits (id, name, icon, description, category, difficulty, is_default) VALUES
  ('reading_10min', 'Чтение 10 мин', '📖', 'каждый день', 'mind', 'easy', TRUE),
  ('reading_20min', 'Чтение 20 мин', '📚', 'углублённое', 'mind', 'medium', TRUE),
  ('thoughts_diary', 'Дневник мыслей', '✍️', 'рефлексия', 'mind', 'easy', TRUE),
  ('write_goals', 'Запись целей', '🎯', 'каждое утро', 'mind', 'easy', TRUE),
  ('learn_new_skill', 'Новый навык', '🧠', 'изучение', 'mind', 'medium', TRUE),
  ('watch_lecture', 'Просмотр лекции', '🎓', 'образование', 'mind', 'medium', TRUE),
  ('listen_podcast', 'Слушать подкаст', '🎧', 'во время прогулки', 'mind', 'easy', TRUE),
  ('online_course', 'Онлайн-курс', '💻', '30 мин в день', 'mind', 'medium', TRUE),
  ('make_notes', 'Конспект', '📝', 'прочитанного', 'mind', 'easy', TRUE),
  ('new_word', 'Новое слово', '🔤', 'англ/др. язык', 'mind', 'easy', TRUE),
  ('daily_memo', 'Памятка дня', '📋', 'ключевая идея', 'mind', 'easy', TRUE),
  ('focused_study', 'Учёба', '🎯', 'без отвлечений', 'mind', 'medium', TRUE),
  ('new_idea', '1 новая идея', '💡', 'каждый день', 'mind', 'easy', TRUE),
  ('solve_problems', 'Решение задач', '🧮', 'мат/логика', 'mind', 'medium', TRUE),
  ('letter_to_self', 'Письмо себе', '✉️', 'раз в неделю', 'mind', 'easy', TRUE),
  ('analyze_mistakes', 'Разбор ошибок', '🔍', 'дня', 'mind', 'easy', TRUE),
  ('learn_quote', 'Учить цитату', '💭', 'мудрость', 'mind', 'easy', TRUE),
  ('take_notes', 'Вести заметки', '📝', 'важные мысли', 'mind', 'easy', TRUE),
  ('knowledge_map', 'Карта знаний', '🗺️', 'ведение', 'mind', 'medium', TRUE),
  ('mindful_news', 'Осмысленное чтение', '📰', 'новостей', 'mind', 'easy', TRUE)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name, icon = EXCLUDED.icon, description = EXCLUDED.description,
  category = EXCLUDED.category, difficulty = EXCLUDED.difficulty, is_default = EXCLUDED.is_default;

-- Peace (СПОКОЙСТВИЕ)
INSERT INTO habits (id, name, icon, description, category, difficulty, is_default) VALUES
  ('meditation_5min', 'Медитация 5 мин', '🧘‍♂️', 'каждое утро', 'peace', 'easy', TRUE),
  ('meditation_10min', 'Медитация 10 мин', '🧘‍♀️', 'углублённая', 'peace', 'easy', TRUE),
  ('breathing_4444', 'Дыхание 4-4-4-4', '💨', 'техника', 'peace', 'easy', TRUE),
  ('mindful_walk', 'Осознанная прогулка', '🚶‍♂️', 'без спешки', 'peace', 'easy', TRUE),
  ('gratitude_note', 'Записать благодарность', '🙏', '3 вещи', 'peace', 'easy', TRUE),
  ('three_accomplishments', '3 дела', '✅', 'что сделал сегодня', 'peace', 'easy', TRUE),
  ('no_phone_30min_evening', 'Без телефона', '📵', '30 мин вечером', 'peace', 'easy', TRUE),
  ('no_screen_before_sleep', 'Без экрана', '🌙', 'за час до сна', 'peace', 'easy', TRUE),
  ('yoga_stretch', 'Йога/растяжка', '🤸‍♀️', 'расслабление', 'peace', 'easy', TRUE),
  ('instrumental_music', 'Музыка без слов', '🎵', 'для концентрации', 'peace', 'easy', TRUE),
  ('morning_breathing', 'Утреннее дыхание', '🌅', '5 мин', 'peace', 'easy', TRUE),
  ('mindful_eating', 'Осознанное питание', '🍽️', 'без спешки', 'peace', 'easy', TRUE),
  ('pause_before_reaction', 'Пауза', '⏸️', 'перед реакцией', 'peace', 'easy', TRUE),
  ('act_of_kindness', '1 акт доброты', '❤️', 'в день', 'peace', 'easy', TRUE),
  ('write_emotions', 'Записать эмоции', '😌', 'понимание себя', 'peace', 'easy', TRUE),
  ('evening_without_negative', 'Вечер без негатива', '🌅', 'позитивные мысли', 'peace', 'easy', TRUE),
  ('goal_visualization', 'Визуализация цели', '🎯', '10 мин', 'peace', 'easy', TRUE),
  ('letting_go_technique', 'Техника отпускания', '🕊️', 'освобождение', 'peace', 'easy', TRUE),
  ('reading_before_sleep', 'Чтение', '📖', 'перед сном', 'peace', 'easy', TRUE),
  ('walk_without_headphones', 'Прогулка', '🚶', 'без наушников', 'peace', 'easy', TRUE)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name, icon = EXCLUDED.icon, description = EXCLUDED.description,
  category = EXCLUDED.category, difficulty = EXCLUDED.difficulty, is_default = EXCLUDED.is_default;

-- Money (ДЕНЬГИ)
INSERT INTO habits (id, name, icon, description, category, difficulty, is_default) VALUES
  ('track_expenses', 'Записать расходы', '💸', 'каждый день', 'money', 'easy', TRUE),
  ('track_income', 'Записать доходы', '💰', 'учёт всех', 'money', 'easy', TRUE),
  ('make_budget', 'Составить бюджет', '📊', 'на месяц', 'money', 'medium', TRUE),
  ('no_unnecessary_spending', 'Не тратить', '🚫', 'на лишнее', 'money', 'medium', TRUE),
  ('save_10_percent', 'Откладывать 10%', '🏦', 'с дохода', 'money', 'medium', TRUE),
  ('save_20_percent', 'Откладывать 20%', '💎', 'агрессивные сбережения', 'money', 'hard', TRUE),
  ('invest_step', 'Инвестировать', '📈', '1 шаг', 'money', 'medium', TRUE),
  ('study_investments', 'Изучить инвестиции', '📚', '30 мин в день', 'money', 'medium', TRUE),
  ('read_business', 'Чтение про бизнес', '📖', 'развитие', 'money', 'medium', TRUE),
  -- 'project_step' уже добавлен в категории focus, не дублируем
  ('weekly_income_plan', 'План по доходу', '📋', 'недели', 'money', 'medium', TRUE),
  ('daily_expense_review', 'Разбор трат', '🔍', 'за день', 'money', 'easy', TRUE),
  ('weekly_expense_review', 'Разбор трат', '📊', 'за неделю', 'money', 'medium', TRUE),
  ('monthly_income_goal', 'Цель по доходу', '🎯', 'месяца', 'money', 'medium', TRUE),
  ('save_on_coffee', 'Экономия', '☕', 'на кофе/еду', 'money', 'easy', TRUE),
  ('save_for_dream', 'Откладывать', '💫', 'на мечту', 'money', 'medium', TRUE),
  ('no_credits', 'Не брать кредиты', '🚫', 'жить по средствам', 'money', 'medium', TRUE),
  ('sell_unnecessary', 'Продажа ненужного', '🏷️', 'доп. доход', 'money', 'medium', TRUE),
  ('financial_diary', 'Фин. дневник', '📔', 'вести', 'money', 'easy', TRUE),
  ('money_talk_partner', 'Разговор о деньгах', '💬', 'с партнёром', 'money', 'easy', TRUE)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name, icon = EXCLUDED.icon, description = EXCLUDED.description,
  category = EXCLUDED.category, difficulty = EXCLUDED.difficulty, is_default = EXCLUDED.is_default;