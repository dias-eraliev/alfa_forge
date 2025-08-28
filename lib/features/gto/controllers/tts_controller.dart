import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';

// Provider для TTS контроллера
final ttsControllerProvider = StateNotifierProvider<TTSController, TTSState>(
  (ref) => TTSController(),
);

class TTSState {
  final bool isEnabled;
  final bool isSpeaking;
  final double speechRate;
  final double volume;
  final double pitch;
  final String? currentLanguage;
  final bool isInitialized;

  const TTSState({
    this.isEnabled = true,
    this.isSpeaking = false,
    this.speechRate = 0.5,
    this.volume = 0.8,
    this.pitch = 1.0,
    this.currentLanguage = 'ru-RU',
    this.isInitialized = false,
  });

  TTSState copyWith({
    bool? isEnabled,
    bool? isSpeaking,
    double? speechRate,
    double? volume,
    double? pitch,
    String? currentLanguage,
    bool? isInitialized,
  }) {
    return TTSState(
      isEnabled: isEnabled ?? this.isEnabled,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      speechRate: speechRate ?? this.speechRate,
      volume: volume ?? this.volume,
      pitch: pitch ?? this.pitch,
      currentLanguage: currentLanguage ?? this.currentLanguage,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

class TTSController extends StateNotifier<TTSState> {
  late FlutterTts _flutterTts;
  List<String> _speechQueue = [];
  bool _isProcessingQueue = false;

  TTSController() : super(const TTSState()) {
    _initializeTTS();
  }

  Future<void> _initializeTTS() async {
    try {
      _flutterTts = FlutterTts();

      // Настройка обработчиков событий
      _flutterTts.setStartHandler(() {
        state = state.copyWith(isSpeaking: true);
      });

      _flutterTts.setCompletionHandler(() {
        state = state.copyWith(isSpeaking: false);
        _processNextInQueue();
      });

      _flutterTts.setErrorHandler((msg) {
        debugPrint('TTS Error: $msg');
        state = state.copyWith(isSpeaking: false);
        _processNextInQueue();
      });

      _flutterTts.setCancelHandler(() {
        state = state.copyWith(isSpeaking: false);
      });

      _flutterTts.setPauseHandler(() {
        state = state.copyWith(isSpeaking: false);
      });

      _flutterTts.setContinueHandler(() {
        state = state.copyWith(isSpeaking: true);
      });

      // Установка начальных настроек
      await _applySettings();

      state = state.copyWith(isInitialized: true);
      debugPrint('TTS initialized successfully');

    } catch (e) {
      debugPrint('TTS initialization error: $e');
      state = state.copyWith(isInitialized: false);
    }
  }

  Future<void> _applySettings() async {
    try {
      await _flutterTts.setLanguage(state.currentLanguage ?? 'ru-RU');
      await _flutterTts.setSpeechRate(state.speechRate);
      await _flutterTts.setVolume(state.volume);
      await _flutterTts.setPitch(state.pitch);

      // Дополнительные настройки для Android
      if (!kIsWeb) {
        await _flutterTts.awaitSpeakCompletion(true);
      }
    } catch (e) {
      debugPrint('Error applying TTS settings: $e');
    }
  }

  // Публичные методы

  /// Произнести текст
  Future<void> speak(String text) async {
    if (!state.isEnabled || !state.isInitialized || text.trim().isEmpty) {
      return;
    }

    // Добавляем в очередь
    _speechQueue.add(text.trim());

    // Если не обрабатываем очередь, начинаем
    if (!_isProcessingQueue && !state.isSpeaking) {
      _processNextInQueue();
    }
  }

  /// Произнести мотивационную фразу
  Future<void> speakMotivational(String exerciseName, int currentReps, int targetReps) async {
    final progress = (currentReps / targetReps * 100).round();
    
    String motivationalText;
    if (progress >= 100) {
      motivationalText = 'Отлично! $exerciseName выполнено! $currentReps повторений!';
    } else if (progress >= 75) {
      motivationalText = 'Почти готово! $currentReps из $targetReps! Еще немного!';
    } else if (progress >= 50) {
      motivationalText = 'Отличная работа! $currentReps повторений! Продолжайте!';
    } else if (progress >= 25) {
      motivationalText = '$currentReps повторений! Держите темп!';
    } else {
      motivationalText = 'Начинаем $exerciseName! $currentReps повторений!';
    }
    
    await speak(motivationalText);
  }

  /// Произнести подсказку по технике
  Future<void> speakTechniqueTip(String tip) async {
    await speak(tip);
  }

  /// Произнести результат тренировки
  Future<void> speakWorkoutResult({
    required int totalReps,
    required int targetReps,
    required double averageQuality,
    required Duration duration,
  }) async {
    final qualityPercent = (averageQuality * 100).round();
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    
    String resultText = 'Тренировка завершена! ';
    resultText += 'Выполнено $totalReps повторений из $targetReps. ';
    resultText += 'Качество техники: $qualityPercent процентов. ';
    
    if (minutes > 0) {
      resultText += 'Время: $minutes минут $seconds секунд. ';
    } else {
      resultText += 'Время: $seconds секунд. ';
    }
    
    if (totalReps >= targetReps && qualityPercent >= 80) {
      resultText += 'Превосходный результат!';
    } else if (totalReps >= targetReps) {
      resultText += 'Цель достигнута! Отличная работа!';
    } else if (qualityPercent >= 80) {
      resultText += 'Отличная техника! Продолжайте в том же духе!';
    } else {
      resultText += 'Хорошая работа! Есть к чему стремиться!';
    }
    
    await speak(resultText);
  }

  /// Остановить речь
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      _speechQueue.clear();
      _isProcessingQueue = false;
      state = state.copyWith(isSpeaking: false);
    } catch (e) {
      debugPrint('Error stopping TTS: $e');
    }
  }

  /// Пауза
  Future<void> pause() async {
    try {
      await _flutterTts.pause();
    } catch (e) {
      debugPrint('Error pausing TTS: $e');
    }
  }

  /// Продолжить
  Future<void> resume() async {
    try {
      // На некоторых платформах может не поддерживаться
      // В таком случае просто продолжаем обработку очереди
      _processNextInQueue();
    } catch (e) {
      debugPrint('Error resuming TTS: $e');
    }
  }

  /// Включить/выключить TTS
  void toggleEnabled() {
    final newState = !state.isEnabled;
    state = state.copyWith(isEnabled: newState);
    
    if (!newState) {
      stop();
    }
  }

  /// Установить скорость речи (0.0 - 1.0)
  Future<void> setSpeechRate(double rate) async {
    final clampedRate = rate.clamp(0.0, 1.0);
    state = state.copyWith(speechRate: clampedRate);
    
    try {
      await _flutterTts.setSpeechRate(clampedRate);
    } catch (e) {
      debugPrint('Error setting speech rate: $e');
    }
  }

  /// Установить громкость (0.0 - 1.0)
  Future<void> setVolume(double volume) async {
    final clampedVolume = volume.clamp(0.0, 1.0);
    state = state.copyWith(volume: clampedVolume);
    
    try {
      await _flutterTts.setVolume(clampedVolume);
    } catch (e) {
      debugPrint('Error setting volume: $e');
    }
  }

  /// Установить высоту тона (0.5 - 2.0)
  Future<void> setPitch(double pitch) async {
    final clampedPitch = pitch.clamp(0.5, 2.0);
    state = state.copyWith(pitch: clampedPitch);
    
    try {
      await _flutterTts.setPitch(clampedPitch);
    } catch (e) {
      debugPrint('Error setting pitch: $e');
    }
  }

  /// Установить язык
  Future<void> setLanguage(String language) async {
    state = state.copyWith(currentLanguage: language);
    
    try {
      await _flutterTts.setLanguage(language);
    } catch (e) {
      debugPrint('Error setting language: $e');
    }
  }

  /// Получить доступные языки
  Future<List<dynamic>> getLanguages() async {
    try {
      return await _flutterTts.getLanguages ?? [];
    } catch (e) {
      debugPrint('Error getting languages: $e');
      return [];
    }
  }

  /// Получить доступные голоса
  Future<List<dynamic>> getVoices() async {
    try {
      return await _flutterTts.getVoices ?? [];
    } catch (e) {
      debugPrint('Error getting voices: $e');
      return [];
    }
  }

  // Приватные методы

  void _processNextInQueue() {
    if (_speechQueue.isEmpty || state.isSpeaking) {
      _isProcessingQueue = false;
      return;
    }

    _isProcessingQueue = true;
    final nextText = _speechQueue.removeAt(0);
    _speakNow(nextText);
  }

  Future<void> _speakNow(String text) async {
    try {
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('Error speaking text: $e');
      state = state.copyWith(isSpeaking: false);
      _processNextInQueue();
    }
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}

// Утилитарные функции для быстрого доступа
extension TTSQuickAccess on WidgetRef {
  TTSController get tts => read(ttsControllerProvider.notifier);
  TTSState get ttsState => read(ttsControllerProvider);
}
