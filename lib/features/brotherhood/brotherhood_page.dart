import 'package:flutter/material.dart';
import '../shared/bottom_nav_scaffold.dart';
import '../../app/theme.dart';

class BrotherhoodPage extends StatefulWidget {
  const BrotherhoodPage({super.key});

  @override
  State<BrotherhoodPage> createState() => _BrotherhoodPageState();
}

class _BrotherhoodPageState extends State<BrotherhoodPage> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _messageController = TextEditingController();
  final int _maxMessageLength = 240;
  final ScrollController _scrollController = ScrollController();
  
  // Состояние реакций и сообщений
  final Map<String, Map<String, bool>> _userReactions = {};
  final Map<String, List<Message>> _messagesCache = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _messageController.addListener(_onMessageChanged);
    _loadInitialMessages();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.removeListener(_onMessageChanged);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onMessageChanged() {
    setState(() {}); // Обновляем UI для кнопки отправки
  }

  void _loadInitialMessages() {
    _messagesCache['daily'] = _getDailyReportMessages();
    _messagesCache['Здоровье'] = _getTopicMessages('Здоровье');
    _messagesCache['Деньги'] = _getTopicMessages('Деньги');
    _messagesCache['Навык'] = _getTopicMessages('Навык');
    _messagesCache['Дом'] = _getTopicMessages('Дом');
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavScaffold(
      currentRoute: '/brotherhood',
      child: SafeArea(
        child: Column(
          children: [
            // Верхние вкладки
            _TabHeader(),
            
            // Контент вкладок
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _DailyReportTab(),
                  _TopicTab('Здоровье'),
                  _TopicTab('Деньги'),
                  _TopicTab('Навык'),
                  _TopicTab('Дом'),
                ],
              ),
            ),
            
            // Поле ввода
            _MessageInput(),
            
            // Кодекс
            _CodexFooter(),
          ],
        ),
      ),
    );
  }

  Widget _TabHeader() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: PRIMETheme.line)),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: PRIMETheme.primary,
        labelColor: PRIMETheme.sand,
        unselectedLabelColor: PRIMETheme.sandWeak,
        labelStyle: TextStyle(
          fontSize: isSmallScreen ? 12 : 14,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: isSmallScreen ? 12 : 14,
          fontWeight: FontWeight.normal,
        ),
        tabAlignment: TabAlignment.start,
        tabs: [
          Tab(text: isSmallScreen ? 'Отчёт дня' : 'Отчёт дня 21:00'),
          const Tab(text: 'Здоровье'),
          const Tab(text: 'Деньги'),
          const Tab(text: 'Навык'),
          const Tab(text: 'Дом'),
        ],
      ),
    );
  }

  Widget _DailyReportTab() {
    return _MessagesList(_getDailyReportMessages());
  }

  Widget _TopicTab(String topic) {
    return _MessagesList(_getTopicMessages(topic));
  }

  Widget _MessagesList(List<Message> messages) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth < 600 ? 12.0 : 16.0;
    
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding, 
        vertical: 12,
      ),
      itemCount: messages.length,
      itemBuilder: (context, index) => _MessageThread(
        message: messages[index], 
        messageId: 'msg_$index',
      ),
    );
  }

  Widget _MessageThread({required Message message, required String messageId}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final avatarRadius = isSmallScreen ? 14.0 : 16.0;
    final containerPadding = isSmallScreen ? 12.0 : 16.0;
    
    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
      padding: EdgeInsets.all(containerPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PRIMETheme.line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Основное сообщение
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: avatarRadius,
                backgroundColor: PRIMETheme.primary,
                child: Text(
                  message.authorInitials,
                  style: TextStyle(
                    color: PRIMETheme.sand, 
                    fontSize: isSmallScreen ? 10 : 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: isSmallScreen ? 8 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Text(
                          message.author,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          message.time,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: isSmallScreen ? 11 : 12,
                            color: PRIMETheme.sandWeak,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      message.text,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: isSmallScreen ? 14 : 16,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: isSmallScreen ? 8 : 12),
          
          // Реакции и кнопки
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _ReactionButton(
                emoji: '🔥',
                count: message.fireReactions,
                isActive: _userReactions[messageId]?['fire'] ?? false,
                onTap: () => _toggleReaction(messageId, 'fire'),
              ),
              _ReactionButton(
                emoji: '👍',
                count: message.thumbsUpReactions,
                isActive: _userReactions[messageId]?['thumbs'] ?? false,
                onTap: () => _toggleReaction(messageId, 'thumbs'),
              ),
              const SizedBox(width: 8),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showReplyDialog(messageId, message.author),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      'Ответить',
                      style: TextStyle(
                        color: PRIMETheme.primary,
                        fontSize: isSmallScreen ? 11 : 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // Ответы
          if (message.replies.isNotEmpty) ...[
            SizedBox(height: isSmallScreen ? 8 : 12),
            Container(
              padding: EdgeInsets.only(left: isSmallScreen ? 12 : 16),
              decoration: const BoxDecoration(
                border: Border(left: BorderSide(color: PRIMETheme.line, width: 2)),
              ),
              child: Column(
                children: message.replies.map((reply) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: isSmallScreen ? 10 : 12,
                        backgroundColor: PRIMETheme.line,
                        child: Text(
                          reply.authorInitials,
                          style: TextStyle(
                            color: PRIMETheme.sand, 
                            fontSize: isSmallScreen ? 8 : 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 6 : 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 6,
                              children: [
                                Text(
                                  reply.author,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: isSmallScreen ? 12 : 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  reply.time,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: isSmallScreen ? 9 : 10,
                                    color: PRIMETheme.sandWeak,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              reply.text,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontSize: isSmallScreen ? 12 : 13,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _ReactionButton({
    required String emoji,
    required int count,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 6 : 8, 
            vertical: isSmallScreen ? 3 : 4,
          ),
          decoration: BoxDecoration(
            color: isActive ? PRIMETheme.primary.withOpacity(0.2) : PRIMETheme.line,
            borderRadius: BorderRadius.circular(12),
            border: isActive ? Border.all(color: PRIMETheme.primary, width: 1) : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                emoji, 
                style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
              ),
              const SizedBox(width: 4),
              Text(
                count.toString(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: isSmallScreen ? 10 : 12,
                  color: isActive ? PRIMETheme.primary : null,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _MessageInput() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final padding = isSmallScreen ? 12.0 : 16.0;
    
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: const Border(top: BorderSide(color: PRIMETheme.line)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            TextField(
              controller: _messageController,
              maxLength: _maxMessageLength,
              minLines: 1,
              maxLines: isSmallScreen ? 3 : 4,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: isSmallScreen ? 14 : 16,
              ),
              decoration: InputDecoration(
                hintText: 'Напишите сообщение (только текст)...',
                hintStyle: TextStyle(
                  color: PRIMETheme.sandWeak,
                  fontSize: isSmallScreen ? 14 : 16,
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 12 : 16,
                  vertical: isSmallScreen ? 10 : 12,
                ),
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
                counterStyle: TextStyle(
                  color: PRIMETheme.sandWeak, 
                  fontSize: isSmallScreen ? 10 : 12,
                ),
              ),
            ),
            SizedBox(height: isSmallScreen ? 8 : 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _messageController.text.trim().isEmpty ? null : _sendMessage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _messageController.text.trim().isEmpty 
                      ? PRIMETheme.line 
                      : PRIMETheme.primary,
                  foregroundColor: _messageController.text.trim().isEmpty 
                      ? PRIMETheme.sandWeak 
                      : PRIMETheme.sand,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: isSmallScreen ? 12 : 16,
                  ),
                  elevation: _messageController.text.trim().isEmpty ? 0 : 2,
                  shadowColor: PRIMETheme.primary.withOpacity(0.3),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.send,
                      size: isSmallScreen ? 16 : 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Отправить',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _CodexFooter() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: const Border(top: BorderSide(color: PRIMETheme.line)),
      ),
      child: SafeArea(
        top: false,
        child: Text(
          'Кодекс: Конкретика и уважение. Без фото и ссылок.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: isSmallScreen ? 10 : 11,
            color: PRIMETheme.sandWeak,
            height: 1.3,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // Новые методы для функциональности
  void _toggleReaction(String messageId, String reactionType) {
    setState(() {
      _userReactions[messageId] ??= {};
      _userReactions[messageId]![reactionType] = 
          !(_userReactions[messageId]![reactionType] ?? false);
    });
    
    // Здесь можно добавить отправку реакции на сервер
    _showSnackBar('Реакция ${reactionType == 'fire' ? '🔥' : '👍'} ${_userReactions[messageId]![reactionType]! ? 'добавлена' : 'убрана'}');
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    
    final message = _messageController.text.trim();
    _messageController.clear();
    
    // Здесь можно добавить отправку сообщения на сервер
    _showSnackBar('Хабарлама жіберілді: ${message.length > 30 ? '${message.substring(0, 30)}...' : message}');
    
    // Прокрутка вниз после отправки
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showReplyDialog(String messageId, String authorName) {
    final TextEditingController replyController = TextEditingController();
    
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '$authorName дегенге жауап',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: replyController,
                  autofocus: true,
                  maxLength: 200,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Жауабыңызды жазыңыз...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (replyController.text.trim().isNotEmpty) {
                        // Здесь можно добавить отправку ответа
                        _showSnackBar('Жауап жіберілді');
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PRIMETheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Жауап жіберу'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  List<Message> _getDailyReportMessages() {
    return [
      Message(
        author: 'Ерлан Қ.',
        authorInitials: 'ЕҚ',
        time: '21:15',
        text: '🔥 Братья, сегодня был ОГОНЬ! Встал в 5:30, пробежал 7км по морозцу (-15°C) - чуть не превратился в сосульку, но дошёл до финиша! 😂 Закрыл проект для клиента на 2 недели раньше срока, теперь он в шоке от качества. Медитация 20 минут - кайф полный! Завтра начинаю изучать Rust. Кто со мной? 💪',
        fireReactions: 12,
        thumbsUpReactions: 8,
        replies: [
          Reply(
            author: 'Мақсат А.',
            authorInitials: 'МА',
            time: '21:20',
            text: 'Машаллах брат! Rust - зверь язык, я уже полгода изучаю. Если что, пиши - помогу! А как в -15 бегать умудряешься? 😅',
          ),
          Reply(
            author: 'Дәурен Б.',
            authorInitials: 'ДБ',
            time: '21:25',
            text: 'Красава! Я тоже хочу начать зимний бег, но пока только в зале. Поделись секретом мотивации! 🏃‍♂️',
          ),
        ],
      ),
      Message(
        author: 'Нұрлан Т.',
        authorInitials: 'НТ',
        time: '21:08',
        text: 'Реальный talk - сегодня был провал дня... 😔 Планировал встать в 6:00, проспал до 8:30. На работе завис с багом на 3 часа (оказалось, забыл точку с запятой 🤦‍♂️). В спортзал не попал - застрял в пробке. НО! Прочитал 30 страниц книги "Думай и богатей", сделал вечернюю растяжку и планирую завтра взять реванш! Кто меня поддержит? 🙏',
        fireReactions: 8,
        thumbsUpReactions: 15,
        replies: [
          Reply(
            author: 'Арман С.',
            authorInitials: 'АС',
            time: '21:12',
            text: 'Брат, у всех бывают такие дни! Главное - не сдаваться. Завтра покажешь класс! 💪',
          ),
          Reply(
            author: 'Серік Ж.',
            authorInitials: 'СЖ',
            time: '21:14',
            text: 'Хаха, точка с запятой - классика! У меня вчера час искал ошибку, а это была лишняя скобка 😂 Завтра будет лучше!',
          ),
        ],
      ),
      Message(
        author: 'Дәурен Б.',
        authorInitials: 'ДБ',
        time: '21:02',
        text: 'Братаны, сегодня было эпично! 🚀 Выпил свои 3 литра воды (даже больше, в туалет бегал каждые полчаса 😂), в зале сделал новый личник в жиме лёжа - 85кг! Прочитал главу про диверсификацию портфеля, теперь голова кипит от идей. Вечером приготовил ужин для жены - борщ получился огонь! Она сказала "не отравился - уже хорошо" 🤣',
        fireReactions: 9,
        thumbsUpReactions: 6,
        replies: [
          Reply(
            author: 'Мақсат А.',
            authorInitials: 'МА',
            time: '21:05',
            text: 'Личник в жиме - респект! 💪 А борщ это вообще высший пилотаж для мужика! Рецепт в студию! 👨‍🍳',
          ),
        ],
      ),
      Message(
        author: 'Арман С.',
        authorInitials: 'АС',
        time: '20:55',
        text: 'Опа, чекните! Сегодня первый раз медитировал 15 минут подряд и не заснул! 🧘‍♂️ Обычно через 5 минут уже храплю. Потом сходил на массаж (спина убивала после вчерашней тренировки), массажистка сказала что я "деревянный" 😅 На работе презентовал проект - одобрили бюджет на 2 млн! Праздную протеиновым коктейлем! 🥤',
        fireReactions: 7,
        thumbsUpReactions: 11,
        replies: [
          Reply(
            author: 'Нұрлан Т.',
            authorInitials: 'НТ',
            time: '21:00',
            text: 'Поздравляю с проектом! 🎉 2 миллиона - это серьёзно! А медитация реально помогает, я тоже начал практиковать.',
          ),
          Reply(
            author: 'Ерлан Қ.',
            authorInitials: 'ЕҚ',
            time: '21:17',
            text: '"Деревянный" - это диагноз всех айтишников 😂 Но ты молодец, что следишь за телом!',
          ),
        ],
      ),
    ];
  }

  List<Message> _getTopicMessages(String topic) {
    switch (topic) {
      case 'Здоровье':
        return [
          Message(
            author: 'Серік Ж.',
            authorInitials: 'СЖ',
            time: '18:45',
            text: 'Братаны, кто пробовал интервальное голодание 16:8? 🤔 Планирую начать с понедельника, но честно говоря - немного страшно. Вдруг сорвусь и сожру весь холодильник в обед? 😂 У кого есть опыт - поделитесь секретами выживания! 🙏',
            fireReactions: 4,
            thumbsUpReactions: 8,
            replies: [
              Reply(
                author: 'Дәурен Б.',
                authorInitials: 'ДБ',
                time: '19:15',
                text: 'Делаю уже полгода! Первые 3 дня - ад, но потом привыкаешь. Секрет: пей много воды и держи орешки под рукой 😅',
              ),
              Reply(
                author: 'Мұрат К.',
                authorInitials: 'МК',
                time: '19:30',
                text: 'У меня жена сначала думала, что я с ума сошёл! Теперь сама так питается. Главное - не переедать в окно приёма пищи! 💪',
              ),
            ],
          ),
          Message(
            author: 'Нұржан Е.',
            authorInitials: 'НЕ',
            time: '14:20',
            text: 'Вчера был в сауне первый раз в жизни - думал умру! 🔥😅 Но какой кайф после! Теперь понимаю, почему финны так помешаны на банях. Кто ещё ходит в сауну регулярно? Говорят, что для здоровья очень полезно, но хочется услышать реальные отзывы!',
            fireReactions: 6,
            thumbsUpReactions: 3,
            replies: [
              Reply(
                author: 'Ерлан Қ.',
                authorInitials: 'ЕҚ',
                time: '14:45',
                text: 'Хожу каждую неделю! Восстановление после тренировок стало в разы лучше. Плюс сон улучшился заметно! 🧘‍♂️',
              ),
            ],
          ),
        ];
      case 'Деньги':
        return [
          Message(
            author: 'Арман С.',
            authorInitials: 'АС',
            time: '16:30',
            text: 'Братцы, разбираюсь с криптой и ETF-ми уже месяц - голова кругом! 🤯 Кто инвестирует в долгосрок? Думаю начать с 10% от зарплаты откладывать, но не знаю куда лучше - в индексные фонды или всё-таки биткоин? Жена говорит "лучше в банк положи" 😂 Нужен совет от тех, кто реально зарабатывает!',
            fireReactions: 2,
            thumbsUpReactions: 7,
            replies: [
              Reply(
                author: 'Дәурен Б.',
                authorInitials: 'ДБ',
                time: '17:00',
                text: 'Правило 50/30/20 работает! 70% в надёжные ETF, 20% в крипту, 10% на эксперименты. И жену лучше посвящать в планы 😉',
              ),
            ],
          ),
          Message(
            author: 'Мақсат А.',
            authorInitials: 'МА',
            time: '12:15',
            text: 'Открыл ИИС в этом году - лучшее решение ever! 💰 13% от государства возвращается, плюс доходность от инвестиций. Братаны, кто ещё не открыл - очень рекомендую! Первые 400к в год государство доплачивает сверху. Это буквально халявные деньги! 🤑',
            fireReactions: 8,
            thumbsUpReactions: 12,
            replies: [
              Reply(
                author: 'Серік Ж.',
                authorInitials: 'СЖ',
                time: '12:45',
                text: 'А куда конкретно инвестируешь через ИИС? Акции, облигации или ETF? Хочу тоже начать, но боюсь ошибиться с выбором! 🤔',
              ),
              Reply(
                author: 'Арман С.',
                authorInitials: 'АС',
                time: '13:00',
                text: 'Блин, про ИИС не думал! Спасибо за наводку! Завтра же иду в банк разбираться 🏃‍♂️',
              ),
            ],
          ),
        ];
      case 'Навык':
        return [
          Message(
            author: 'Бауыржан Н.',
            authorInitials: 'БН',
            time: '19:45',
            text: 'Изучаю машинное обучение уже 3 месяца и чувствую себя как в фильме "Матрица" - иногда понимаю, иногда нет ничего! 🤖😅 Сегодня наконец-то смог обучить модель, которая определяет кошек и собак с точностью 85%! Небольшая победа, но я счастлив как ребёнок! Кто ещё мучается с ML?',
            fireReactions: 9,
            thumbsUpReactions: 5,
            replies: [
              Reply(
                author: 'Ерлан Қ.',
                authorInitials: 'ЕҚ',
                time: '20:00',
                text: '85% для начала - это круто! Я пока только книги читаю, но скоро тоже начну практику. Какие курсы посоветуешь? 📚',
              ),
            ],
          ),
          Message(
            author: 'Мұрат К.',
            authorInitials: 'МК',
            time: '15:20',
            text: 'Решил выучить испанский язык! 🇪🇸 Цель - через год поехать в Барселону и свободно говорить с местными. Пока что умею только "Hola" и "Donde está el baño" 😂 Кто учил иностранные языки во взрослом возрасте? Реально ли выучить за год до разговорного уровня?',
            fireReactions: 3,
            thumbsUpReactions: 11,
            replies: [
              Reply(
                author: 'Нұржан Е.',
                authorInitials: 'НЕ',
                time: '15:45',
                text: 'Год - вполне реально! Главное каждый день хотя бы 30 минут. Я так английский подтянул. Duolingo + сериалы с субтитрами = огонь! 🔥',
              ),
            ],
          ),
        ];
      case 'Дом':
        return [
          Message(
            author: 'Асхат Б.',
            authorInitials: 'АБ',
            time: '20:30',
            text: 'Братцы, помогите советом! Жена хочет ремонт в ванной, а я понятия не имею с чего начать! 🚿😱 Плитку выбирать, сантехнику менять... Голова кругом! Кто делал ремонт сам - реально ли справиться без строителей? Или лучше нанять профессионалов и не мучаться? Бюджет ограничен, но руки растут откуда надо! 🔧',
            fireReactions: 4,
            thumbsUpReactions: 9,
            replies: [
              Reply(
                author: 'Мақсат А.',
                authorInitials: 'МА',
                time: '20:45',
                text: 'Сам делал! YouTube - твой лучший друг. Главное не торопиться и всё получится. Сэкономил 200к на работе! 💪',
              ),
              Reply(
                author: 'Дәурен Б.',
                authorInitials: 'ДБ',
                time: '21:00',
                text: 'Электрику и сантехнику лучше доверить профи, а плитку можешь сам класть. У меня 3 раза переделывал, но научился! 😅',
              ),
            ],
          ),
          Message(
            author: 'Ернар Т.',
            authorInitials: 'ЕТ',
            time: '17:15',
            text: 'Купил первую квартиру в ипотеку! 🏠🎉 25 лет платить, но зато своё жильё! Родители говорят "зачем долги брать", но я считаю - лучше платить за своё, чем за чужое. Сейчас выбираю мебель и понимаю, что ремонт - это только начало трат! Кто покупал квартиру - поделитесь опытом планирования бюджета!',
            fireReactions: 12,
            thumbsUpReactions: 8,
            replies: [
              Reply(
                author: 'Серік Ж.',
                authorInitials: 'СЖ',
                time: '17:30',
                text: 'Поздравляю! 🎊 Совет - не покупай всё сразу. Мы с женой 2 года мебель собирали по частям. Зато без долгов!',
              ),
            ],
          ),
        ];
      default:
        return [
          Message(
            author: 'Администратор',
            authorInitials: 'А',
            time: '10:00',
            text: 'В разделе "$topic" скоро появятся сообщения от участников сообщества. Будьте первым, кто поделится опытом! 💪',
            fireReactions: 0,
            thumbsUpReactions: 1,
            replies: [],
          ),
        ];
    }
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
