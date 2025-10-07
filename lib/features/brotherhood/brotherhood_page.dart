import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../shared/bottom_nav_scaffold.dart';
import '../../app/theme.dart';

class BrotherhoodPage extends StatefulWidget {
  const BrotherhoodPage({super.key});

  @override
  State<BrotherhoodPage> createState() => _BrotherhoodPageState();
}

class _BrotherhoodPageState extends State<BrotherhoodPage> with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;
  
  // Состояние реакций и сообщений
  final Map<String, Map<String, bool>> _userReactions = {};
  final Map<String, List<Message>> _messagesCache = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fabScaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _fabAnimationController.repeat(reverse: true);
    _loadInitialMessages();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _loadInitialMessages() {
    _messagesCache['feed'] = _getAllMessages();
    _messagesCache['topics'] = _getTopicMessages();
    _messagesCache['my'] = _getMyMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BottomNavScaffold(
        currentRoute: '/brotherhood',
        child: SafeArea(
          child: Column(
            children: [
              // Упрощенные табы
              _TabHeader(),
              
              // Контент вкладок
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _FeedTab(),
                    _TopicsTab(),
                    _MyPostsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _FloatingCreateButton(),
    );
  }

  Widget _TabHeader() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: PRIMETheme.line, width: 0.5)),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: PRIMETheme.primary,
        indicatorWeight: 2,
        labelColor: PRIMETheme.sand,
        unselectedLabelColor: PRIMETheme.sandWeak,
        labelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.normal,
        ),
        tabs: const [
          Tab(text: 'Лента'),
          Tab(text: 'Темы'),
          Tab(text: 'Мои'),
        ],
      ),
    );
  }

  Widget _FeedTab() {
    return _MessagesList(_getAllMessages());
  }

  Widget _TopicsTab() {
    return _MessagesList(_getTopicMessages());
  }

  Widget _MyPostsTab() {
    return _MessagesList(_getMyMessages());
  }

  Widget _MessagesList(List<Message> messages) {
    return RefreshIndicator(
      onRefresh: () async {
        // Здесь можно добавить обновление данных
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: messages.length,
        itemBuilder: (context, index) => _MessageThread(
          message: messages[index], 
          messageId: 'msg_$index',
        ),
      ),
    );
  }

  Widget _MessageThread({required Message message, required String messageId}) {
    return InkWell(
      onTap: () => _showPostDetails(message),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: PRIMETheme.line, width: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Основной пост
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _GradientAvatar(
                  initials: message.authorInitials,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            message.author,
                            style: const TextStyle(
                              color: PRIMETheme.sand,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '• ${message.time}',
                            style: const TextStyle(
                              color: PRIMETheme.sandWeak,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message.text,
                        style: const TextStyle(
                          color: PRIMETheme.sand,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Компактные реакции
            Row(
              children: [
                _CompactReactionButton(
                  emoji: '🔥',
                  count: message.fireReactions,
                  isActive: _userReactions[messageId]?['fire'] ?? false,
                  onTap: () => _toggleReaction(messageId, 'fire'),
                ),
                const SizedBox(width: 16),
                _CompactReactionButton(
                  emoji: '👍',
                  count: message.thumbsUpReactions,
                  isActive: _userReactions[messageId]?['thumbs'] ?? false,
                  onTap: () => _toggleReaction(messageId, 'thumbs'),
                ),
                const SizedBox(width: 16),
                InkWell(
                  onTap: () => _showCreatePostSheet(replyTo: message.author),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.reply,
                          size: 16,
                          color: PRIMETheme.sandWeak,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          message.replies.isNotEmpty ? '${message.replies.length}' : 'Ответить',
                          style: const TextStyle(
                            color: PRIMETheme.sandWeak,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            // Упрощенные ответы
            if (message.replies.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...message.replies.take(2).map((reply) => Container(
                margin: const EdgeInsets.only(left: 28, bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _GradientAvatar(
                      initials: reply.authorInitials,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                reply.author,
                                style: const TextStyle(
                                  color: PRIMETheme.sand,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '• ${reply.time}',
                                style: const TextStyle(
                                  color: PRIMETheme.sandWeak,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            reply.text,
                            style: const TextStyle(
                              color: PRIMETheme.sand,
                              fontSize: 13,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
              if (message.replies.length > 2)
                Container(
                  margin: const EdgeInsets.only(left: 28),
                  child: InkWell(
                    onTap: () => _showPostDetails(message),
                    child: Text(
                      'Показать еще ${message.replies.length - 2} ответов',
                      style: const TextStyle(
                        color: PRIMETheme.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _CompactReactionButton({
    required String emoji,
    required int count,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isActive 
              ? PRIMETheme.primary.withOpacity(0.1)
              : Colors.transparent,
          border: Border.all(
            color: isActive 
                ? PRIMETheme.primary.withOpacity(0.3)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isActive ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 150),
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: isActive ? PRIMETheme.primary : PRIMETheme.sandWeak,
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
                child: Text(count.toString()),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _GradientAvatar({required String initials, required double size}) {
    // Генерируем градиент на основе инициалов
    final hash = initials.hashCode;
    final colors = [
      [const Color(0xFF660000), const Color(0xFF990000)], // Красный
      [const Color(0xFF2563EB), const Color(0xFF3B82F6)], // Синий
      [const Color(0xFF059669), const Color(0xFF10B981)], // Зеленый
      [const Color(0xFF7C3AED), const Color(0xFF8B5CF6)], // Фиолетовый
      [const Color(0xFFDC2626), const Color(0xFFEF4444)], // Алый
      [const Color(0xFF0891B2), const Color(0xFF06B6D4)], // Циан
    ];
    
    final colorPair = colors[hash.abs() % colors.length];
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colorPair,
        ),
        boxShadow: [
          BoxShadow(
            color: colorPair[0].withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _FloatingCreateButton() {
    return AnimatedBuilder(
      animation: _fabScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _fabScaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF660000),
                  Color(0xFF990000),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: PRIMETheme.primary.withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                _showCreatePostSheet();
              },
              backgroundColor: Colors.transparent,
              foregroundColor: PRIMETheme.sand,
              elevation: 0,
              child: const Icon(Icons.add, size: 28),
            ),
          ),
        );
      },
    );
  }

  void _showCreatePostSheet({String? replyTo}) {
    final TextEditingController controller = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      replyTo != null ? 'Ответ для $replyTo' : 'Новый пост',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: PRIMETheme.sand,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: PRIMETheme.sandWeak),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  autofocus: true,
                  maxLength: 240,
                  maxLines: 5,
                  style: const TextStyle(
                    fontSize: 16,
                    color: PRIMETheme.sand,
                  ),
                  decoration: InputDecoration(
                    hintText: replyTo != null ? 'Напишите ответ...' : 'Что у вас нового?',
                    hintStyle: const TextStyle(color: PRIMETheme.sandWeak),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: PRIMETheme.line),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: PRIMETheme.line),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: PRIMETheme.primary, width: 2),
                    ),
                    filled: true,
                    fillColor: PRIMETheme.cardBg,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (controller.text.trim().isNotEmpty) {
                        _showSnackBar(replyTo != null ? 'Ответ отправлен' : 'Пост опубликован');
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PRIMETheme.primary,
                      foregroundColor: PRIMETheme.sand,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      replyTo != null ? 'Ответить' : 'Опубликовать',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPostDetails(Message message) {
    // Здесь можно показать детальный вид поста с полными ответами
    _showSnackBar('Детальный вид поста: ${message.author}');
  }

  void _toggleReaction(String messageId, String reactionType) {
    setState(() {
      _userReactions[messageId] ??= {};
      _userReactions[messageId]![reactionType] = 
          !(_userReactions[messageId]![reactionType] ?? false);
    });
    
    _showSnackBar('Реакция ${reactionType == 'fire' ? '🔥' : '👍'} ${_userReactions[messageId]![reactionType]! ? 'добавлена' : 'убрана'}');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: PRIMETheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  List<Message> _getAllMessages() {
    // Объединяем все сообщения для ленты
    final allMessages = <Message>[];
    allMessages.addAll(_getDailyReportMessages());
    allMessages.addAll(_getTopicMessages('Здоровье'));
    allMessages.addAll(_getTopicMessages('Деньги'));
    allMessages.addAll(_getTopicMessages('Навык'));
    allMessages.addAll(_getTopicMessages('Дом'));
    
    // Сортируем по времени (упрощенная логика)
    allMessages.shuffle();
    return allMessages;
  }

  List<Message> _getTopicMessages([String? topic]) {
    final messages = <Message>[];
    messages.addAll(_getDailyReportMessages());
    
    // Добавляем сообщения из разных тем
    messages.addAll([
      Message(
        author: 'Серік Ж.',
        authorInitials: 'СЖ',
        time: '2ч',
        text: 'Братаны, кто пробовал интервальное голодание 16:8? Планирую начать с понедельника 🤔',
        fireReactions: 4,
        thumbsUpReactions: 8,
        replies: [
          Reply(
            author: 'Дәурен Б.',
            authorInitials: 'ДБ',
            time: '1ч',
            text: 'Делаю уже полгода! Первые 3 дня - ад, но потом привыкаешь 😅',
          ),
        ],
      ),
      Message(
        author: 'Арман С.',
        authorInitials: 'АС',
        time: '4ч',
        text: 'Братцы, разбираюсь с криптой и ETF-ми уже месяц - голова кругом! 🤯 Кто инвестирует в долгосрок?',
        fireReactions: 2,
        thumbsUpReactions: 7,
        replies: [],
      ),
    ]);
    
    return messages;
  }

  List<Message> _getMyMessages() {
    // Возвращаем только "мои" посты для демо
    return [
      Message(
        author: 'Вы',
        authorInitials: 'Я',
        time: '30м',
        text: 'Сегодня был отличный день! Закончил рефакторинг Brotherhood страницы 💪',
        fireReactions: 5,
        thumbsUpReactions: 3,
        replies: [
          Reply(
            author: 'Ерлан Қ.',
            authorInitials: 'ЕҚ',
            time: '20м',
            text: 'Круто! Теперь намного чище выглядит 🔥',
          ),
        ],
      ),
    ];
  }

  List<Message> _getDailyReportMessages() {
    return [
      Message(
        author: 'Ерлан Қ.',
        authorInitials: 'ЕҚ',
        time: '3ч',
        text: '🔥 Братья, сегодня был ОГОНЬ! Встал в 5:30, пробежал 7км по морозцу (-15°C). Закрыл проект для клиента на 2 недели раньше срока!',
        fireReactions: 12,
        thumbsUpReactions: 8,
        replies: [
          Reply(
            author: 'Мақсат А.',
            authorInitials: 'МА',
            time: '2ч',
            text: 'Машаллах брат! А как в -15 бегать умудряешься? 😅',
          ),
          Reply(
            author: 'Дәурен Б.',
            authorInitials: 'ДБ',
            time: '2ч',
            text: 'Красава! Поделись секретом мотивации! 🏃‍♂️',
          ),
        ],
      ),
      Message(
        author: 'Нұрлан Т.',
        authorInitials: 'НТ',
        time: '4ч',
        text: 'Реальный talk - сегодня был провал дня... 😔 Планировал встать в 6:00, проспал до 8:30. НО! Завтра взять реванш!',
        fireReactions: 8,
        thumbsUpReactions: 15,
        replies: [
          Reply(
            author: 'Арман С.',
            authorInitials: 'АС',
            time: '3ч',
            text: 'Брат, у всех бывают такие дни! Главное - не сдаваться 💪',
          ),
        ],
      ),
      Message(
        author: 'Дәурен Б.',
        authorInitials: 'ДБ',
        time: '5ч',
        text: 'Братаны, сегодня было эпично! 🚀 В зале сделал новый личник в жиме лёжа - 85кг! Вечером приготовил ужин для жены - борщ получился огонь!',
        fireReactions: 9,
        thumbsUpReactions: 6,
        replies: [
          Reply(
            author: 'Мақсат А.',
            authorInitials: 'МА',
            time: '4ч',
            text: 'Личник в жиме - респект! 💪 Рецепт борща в студию! 👨‍🍳',
          ),
        ],
      ),
    ];
  }
}

class Message {
  final String author;
  final String authorInitials;
  final String time;
  final String text;
  final int fireReactions;
  final int thumbsUpReactions;
  final List<Reply> replies;

  Message({
    required this.author,
    required this.authorInitials,
    required this.time,
    required this.text,
    required this.fireReactions,
    required this.thumbsUpReactions,
    required this.replies,
  });
}

class Reply {
  final String author;
  final String authorInitials;
  final String time;
  final String text;

  Reply({
    required this.author,
    required this.authorInitials,
    required this.time,
    required this.text,
  });
}
