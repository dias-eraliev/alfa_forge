# Модуль Финансы - PRIME App

Полнофункциональный модуль финансового планирования и управления бюджетом для приложения PRIME.

## 🎯 Основные возможности

### ✅ Реализовано в MVP
- **Safe-to-Spend** - умный расчет доступных средств на сегодня
- **Net Cash Flow** - чистый денежный поток за период
- **Savings Rate** - процент сбережений от дохода
- **Автораспределение** - 50/30/20 правило и Pay-yourself-first
- **Быстрый ввод трат** - через FAB за 3 тапа
- **Бюджетирование** - Zero-based и конверты
- **Финансовые цели** - с автоматическими отчислениями
- **Аналитика и отчеты** - с экспортом в CSV
- **Offline-first** - вся работа без интернета

### 🔮 Запланировано в v2
- **Подписки** - автодетект и управление регулярными платежами
- **Долги** - стратегии Snowball/Avalanche
- **Симулятор "что если"** - моделирование сценариев
- **Автокатегоризация** - машинное обучение на основе паттернов
- **Микро-обучение** - встроенные финансовые советы

## 🏗️ Архитектура

### Структура проекта
```
lib/features/finance/
├── data/
│   ├── models/          # Drift таблицы
│   ├── database/        # Основная БД и миграции
│   └── repositories/    # Репозитории для работы с данными
├── providers/           # Riverpod провайдеры
└── ui/                 # UI экраны и компоненты
```

### Технологический стек
- **Flutter 3.x** + **Dart**
- **Riverpod** - управление состоянием
- **Drift (SQLite)** - offline-first база данных
- **intl** - форматирование валюты (KZT)
- **go_router** - навигация

## 💾 Модели данных

### Account (Счета)
```dart
- id: int (PK)
- name: string (Наличные, Карта)
- type: enum (cash, card)
- currency: string (KZT)
- balance: int (в тийынах)
- isActive: bool
- createdAt/updatedAt: DateTime
```

### Transaction (Транзакции)
```dart
- id: int (PK)
- accountId: int (FK)
- date: DateTime
- type: enum (expense, income, transfer)
- amount: int (в тийынах)
- categoryId: int (FK)
- merchant: string?
- note: string?
- tags: string? (JSON массив)
- isRecurring: bool
- createdAt/updatedAt: DateTime
```

### Category (Категории)
```dart
- id: int (PK)
- name: string
- parentId: int? (для иерархии)
- icon: string
- color: string (hex)
- type: enum (expense, income)
- sortOrder: int
- isActive/isSystem: bool
```

### Budget (Бюджеты)
```dart
- id: int (PK)
- period: enum (month)
- categoryId: int (FK)
- limit: int (в тийынах)
- spent: int (в тийынах)
- rollover: bool (перенос остатка)
- periodStart/End: DateTime
- isActive: bool
```

### Goal (Цели)
```dart
- id: int (PK)
- name: string
- description: string?
- targetAmount: int (в тийынах)
- savedAmount: int (в тийынах)
- deadline: DateTime?
- priority: int
- type: enum (emergency, travel, purchase)
- autoContribution: bool
- contributionAmount: int?
```

### Setting (Настройки)
```dart
- id: int (PK)
- key: string (уникальный)
- value: string
- valueType: enum (string, int, bool, double)
- description: string?
- group: string?
```

## 🧮 Ключевые расчеты

### Safe-to-Spend (сегодня)
```dart
(Σ лимитов переменных категорий - потрачено - предстоящие фиксированные) / дни до конца месяца
```

### Net Cash Flow
```dart
Σ доходов - Σ расходов за период
```

### Savings Rate
```dart
(Сбережения / Чистый доход) × 100%
```

### Monthly Goal Payment
```dart
ceil((targetAmount - savedAmount) / monthsLeft)
```

## 🎨 UI Компоненты

### Навигация
4 основных вкладки:
- **Home** - дашборд с ключевыми метриками
- **Transactions** - история операций
- **Budget** - бюджеты и лимиты
- **Goals** - финансовые цели

### Ключевые экраны

#### FinanceHomeScreen
- Safe-to-Spend карточка
- Net Cash Flow за месяц
- Прогресс целей
- Предстоящие платежи
- Совет недели

#### TransactionsScreen
- Лента транзакций с фильтрами
- Поиск по мерчанту/категории
- Экспорт в CSV
- Массовая перекатегоризация

#### BudgetScreen
- Переключатель Zero-based/Конверты
- Лимиты категорий с прогресс-барами
- Календарь предстоящих платежей
- Safe-to-Spend расчеты

#### GoalsScreen
- Список целей с прогрессом
- Рекомендации по ежемесячным отчислениям
- Кнопка "Отложить сейчас"

## 💰 Валюта и форматирование

- **Базовая валюта**: KZT (казахстанский тенге)
- **Формат**: точки как разделители тысяч (`1.250.000 ₸`)
- **Хранение**: все суммы в тийынах (1 тенге = 100 тийын)
- **Таймзона**: Asia/Almaty (UTC+6)

## 🔄 Провайдеры состояния

### FinanceProviders
```dart
// База данных
final financeDatabaseProvider = Provider<FinanceDatabase>

// Репозитории
final financeRepositoryProvider = Provider<FinanceRepository>
final transactionRepositoryProvider = Provider<TransactionRepository>

// Данные
final accountsProvider = FutureProvider<List<Account>>
final categoriesProvider = FutureProvider<List<Category>>
final goalsProvider = FutureProvider<List<Goal>>

// Расчеты
final safeToSpendProvider = FutureProvider<double>
final netCashFlowProvider = FutureProvider<double>
final savingsRateProvider = FutureProvider<double>
```

## 🚀 Быстрый старт

### 1. Навигация к модулю
```dart
context.go('/finance');
```

### 2. Демо-экран
```dart
Navigator.push(context, MaterialPageRoute(
  builder: (context) => const FinanceDemoScreen(),
));
```

### 3. Основной экран
```dart
Navigator.push(context, MaterialPageRoute(
  builder: (context) => const FinanceMainScreen(),
));
```

## 📊 Данные для демонстрации

Модуль включает хардкод данные для демонстрации:

### Счета
- Наличные: 125.500 ₸
- Kaspi Gold: 423.750 ₸

### Категории (расходы)
- Еда, Транспорт, Подписки, Досуг
- Здоровье, Дом, Образование, Прочее

### Категории (доходы)
- Зарплата, Фриланс, Подарки, Прочее

### Цели
- Подушка безопасности: 600.000 ₸ (прогресс 45%)
- Путешествие в Европу: 300.000 ₸ (прогресс 30%)

### Бюджеты
- Еда: 150.000 ₸/мес (потрачено 78.500 ₸)
- Транспорт: 50.000 ₸/мес (потрачено 23.200 ₸)
- Досуг: 40.000 ₸/мес (потрачено 31.800 ₸)

## ⚡ Производительность

- **Индексы БД** на Transaction.date, categoryId, merchant
- **Ленивая загрузка** данных через FutureProvider
- **Оптимизированные запросы** с JOIN для аналитики
- **Офлайн-first** подход для моментального отклика

## 🔐 Приватность

- **100% локальное хранение** (SQLite)
- **Опциональный экспорт** в CSV
- **Без отправки PII** на серверы
- **Локальные уведомления** без внешних сервисов

## 🧪 Тестирование

### Юнит-тесты
```bash
flutter test test/features/finance/
```

### Приемочные тесты
- ✅ Онбординг: ввод дохода → план распределения
- ✅ FAB: 3 тапа → создание расхода
- ✅ Safe-to-Spend: корректный расчет
- ✅ Цели: Monthly Goal Payment
- ✅ CSV импорт/экспорт
- ✅ Net Cash Flow точность
- ✅ Офлайн работа

## 📱 Интеграция с PRIME

Модуль полностью интегрирован в экосистему PRIME:
- Следует дизайн-системе (тёмная/светлая темы)
- Использует общий роутинг через go_router
- Совместим с модулем привычек
- Поддерживает локализацию RU/KK

## 🔧 Разработка

### Генерация Drift кода
```bash
dart run build_runner build
```

### Анализ кода
```bash
flutter analyze lib/features/finance/
```

### Форматирование
```bash
dart format lib/features/finance/
```

## 📈 Метрики для отслеживания

### Пользовательские
- D1/D7/D30 retention
- Количество транзакций/неделю
- Доля пользователей с Savings Rate ≥ 15%
- Доля пользователей с Net CF ≥ 0 три месяца подряд

### Технические
- Время загрузки экранов
- Размер локальной БД
- Производительность запросов

---

## 👥 Команда

Разработано для PRIME App в рамках комплексного подхода к личностному развитию.

**Статус**: ✅ MVP готов к демонстрации
**Версия**: 1.0.0-demo
**Последнее обновление**: Август 2025
