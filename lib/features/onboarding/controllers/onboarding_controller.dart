import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/onboarding_data.dart';
import '../models/habit_model.dart';
import '../models/development_sphere_model.dart';
import '../../../core/services/onboarding_service.dart';
import '../../../core/services/auth_service.dart';

class OnboardingController extends ChangeNotifier {
  static const String _keyOnboardingData = 'onboarding_data';
  static const String _keyOnboardingCompleted = 'onboarding_completed';

  OnboardingData _data = const OnboardingData();
  bool _isLoading = false;

  // Состояние для выбора сфер
  final List<DevelopmentSphere> _selectedSpheres = [];
  bool _isInHabitSelectionMode = false;
  
  // Фильтры и пагинация привычек
  final List<String> _activeSphereFilters = [];
  static const int _habitPageSize = 24;
  int _visibleHabitsLimit = _habitPageSize;

  OnboardingData get data => _data;
  bool get isLoading => _isLoading;
  
  // Геттеры для профильных данных
  String? get fullName => _data.fullName;
  String? get email => _data.email;
  String? get phone => _data.phone;
  String? get city => _data.city;
  String? get username => _data.username;
  List<HabitModel> get selectedHabits => _data.selectedHabits;
  bool get isCompleted => _data.isCompleted;

  // Геттеры для сфер развития
  List<DevelopmentSphere> get selectedSpheres => _selectedSpheres;
  bool get isInHabitSelectionMode => _isInHabitSelectionMode;
  List<HabitModel> get availableHabits => DevelopmentSpheresData.getHabitsForSpheres(
    _selectedSpheres.map((sphere) => sphere.id).toList()
  );
  
  // Активные фильтры (ids сфер). Если пусто -> показываем все выбранные сферы.
  List<String> get activeSphereFilters => _activeSphereFilters;
  
  // Отфильтрованный и ограниченный список
  List<HabitModel> get filteredHabits {
    final base = availableHabits;
    final filtered = _activeSphereFilters.isEmpty
        ? base
        : base.where((h) {
            // находим сферу по наличию id в списке (поиск среди _selectedSpheres)
            return _selectedSpheres.any((s) =>
                _activeSphereFilters.contains(s.id) &&
                s.habits.contains(h));
          }).toList();
    if (filtered.length <= _visibleHabitsLimit) return filtered;
    return filtered.sublist(0, _visibleHabitsLimit);
  }
  
  bool get canShowMoreHabits {
    final baseCount = _activeSphereFilters.isEmpty
        ? availableHabits.length
        : availableHabits.where((h) {
            return _selectedSpheres.any((s) =>
                _activeSphereFilters.contains(s.id) &&
                s.habits.contains(h));
          }).length;
    return _visibleHabitsLimit < baseCount;
  }

  // Валидация для каждого шага
  bool get isProfileValid => _data.fullName != null && 
                            _data.fullName!.trim().isNotEmpty &&
                            _data.email != null &&
                            _data.email!.trim().isNotEmpty &&
                            _data.phone != null &&
                            _data.phone!.trim().isNotEmpty &&
                            _data.city != null &&
                            _data.city!.trim().isNotEmpty;

  bool get isUsernameValid => _data.username != null && 
                             _data.username!.trim().isNotEmpty &&
                             _data.username!.trim().length >= 3 &&
                             _data.username!.trim().length <= 20;
  
  bool get areHabitsValid => _data.selectedHabits.isNotEmpty;
  
  bool get canComplete => isProfileValid && isUsernameValid && areHabitsValid;

  // Методы для сохранения профильных данных
  void setProfileData({
    required String fullName,
    required String email,
    required String phone,
    required String city,
  }) {
    _data = _data.copyWith(
      fullName: fullName.trim(),
      email: email.trim(),
      phone: phone.trim(),
      city: city.trim(),
    );
    notifyListeners();
  }

  void setUsername(String username) {
    _data = _data.copyWith(username: username.trim());
    notifyListeners();
  }

  void toggleHabit(HabitModel habit) {
    final currentHabits = List<HabitModel>.from(_data.selectedHabits);
    
    if (currentHabits.contains(habit)) {
      currentHabits.remove(habit);
    } else {
      // Максимум 5 привычек
      if (currentHabits.length < 5) {
        currentHabits.add(habit);
      }
    }
    
    _data = _data.copyWith(selectedHabits: currentHabits);
    notifyListeners();
  }

  bool isHabitSelected(HabitModel habit) {
    return _data.selectedHabits.contains(habit);
  }

  // Методы для работы со сферами развития
  void toggleSphere(DevelopmentSphere sphere) {
    if (_selectedSpheres.contains(sphere)) {
      _selectedSpheres.remove(sphere);
    } else {
      // Максимум 3 сферы
      if (_selectedSpheres.length < 3) {
        _selectedSpheres.add(sphere);
      }
    }
    notifyListeners();
  }

  bool isSphereSelected(DevelopmentSphere sphere) {
    return _selectedSpheres.contains(sphere);
  }

  void enterHabitSelectionMode() {
    if (_selectedSpheres.length >= 2) {
      _isInHabitSelectionMode = true;
      // Инициализируем фильтры выбранными сферами
      _activeSphereFilters
        ..clear()
        ..addAll(_selectedSpheres.map((e) => e.id));
      _visibleHabitsLimit = _habitPageSize;
      // Сбрасываем выбранные привычки (начинаем с нуля)
      _data = _data.copyWith(selectedHabits: []);
      notifyListeners();
    }
  }

  void exitHabitSelectionMode() {
    _isInHabitSelectionMode = false;
    notifyListeners();
  }

  // Валидация сфер
  bool get areSpheresValid => _selectedSpheres.length >= 2 && _selectedSpheres.length <= 3;
  
  // Обновляем общую валидацию
  bool get canProceedFromSpheres => areSpheresValid;

  Future<void> completeOnboarding() async {
    if (!canComplete) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Сначала обновляем профиль на backend
      final onboardingService = OnboardingService();
      
      // Обновляем профиль пользователя
      final profileResponse = await onboardingService.updateProfile(
        fullName: _data.fullName,
        phone: _data.phone,
        city: _data.city,
      );
      
      if (!profileResponse.isSuccess) {
        throw Exception('Failed to update profile: ${profileResponse.error}');
      }
      
      // Завершаем онбординг на backend
      final completeResponse = await onboardingService.completeOnboarding();
      
      if (!completeResponse.isSuccess) {
        throw Exception('Failed to complete onboarding: ${completeResponse.error}');
      }
      
      // Обновляем локальные данные
      _data = _data.copyWith(isCompleted: true);
      await _saveData();
      
      // Также сохраняем флаг завершения отдельно для быстрой проверки
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyOnboardingCompleted, true);
      await prefs.setBool('onboarding_completed', true);
      
      debugPrint('✅ Onboarding completed successfully');
      
    } catch (e) {
      debugPrint('❌ Error completing onboarding: $e');
      // Не обновляем локальное состояние если backend запрос не удался
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final dataJson = prefs.getString(_keyOnboardingData);
      
      if (dataJson != null) {
        _data = OnboardingData.fromJsonString(dataJson);
      }
    } catch (e) {
      debugPrint('Error loading onboarding data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyOnboardingData, _data.toJsonString());
    } catch (e) {
      debugPrint('Error saving onboarding data: $e');
    }
  }

  Future<void> resetOnboarding() async {
    _data = const OnboardingData();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyOnboardingData);
      await prefs.setBool(_keyOnboardingCompleted, false);
      await prefs.setBool('onboarding_completed', false);
    } catch (e) {
      debugPrint('Error resetting onboarding: $e');
    }
    
    notifyListeners();
  }
  
  // ------- Новые методы для фильтрации / пагинации привычек -------
  void toggleSphereFilter(String sphereId) {
    if (_activeSphereFilters.contains(sphereId)) {
      _activeSphereFilters.remove(sphereId);
    } else {
      _activeSphereFilters.add(sphereId);
    }
    _visibleHabitsLimit = _habitPageSize; // сбрасываем пагинацию при смене фильтра
    notifyListeners();
  }
  
  void clearSphereFilters() {
    _activeSphereFilters.clear();
    _visibleHabitsLimit = _habitPageSize;
    notifyListeners();
  }
  
  void showMoreHabits() {
    _visibleHabitsLimit += _habitPageSize;
    notifyListeners();
  }
  // ---------------------------------------------------------------
  
  // Статический метод для проверки завершения онбординга
  static Future<bool> isOnboardingCompleted() async {
    try {
      // Если пользователь авторизован, проверяем статус на backend
      final authService = AuthService();
      if (authService.isAuthenticated) {
        try {
          final onboardingService = OnboardingService();
          final response = await onboardingService.getCurrentProfile();
          
          if (response.isSuccess && response.data != null) {
            final user = response.data!;
            final isCompleted = user.profile?.onboardingCompleted ?? false;
            
            // Синхронизируем с локальным хранилищем
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool(_keyOnboardingCompleted, isCompleted);
            await prefs.setBool('onboarding_completed', isCompleted);
            
            debugPrint('📋 Backend onboarding status: $isCompleted');
            return isCompleted;
          }
        } catch (e) {
          debugPrint('⚠️ Failed to check backend onboarding status: $e');
          // Fallback к локальному хранилищу при ошибке API
        }
      }
      
      // Fallback: проверяем локальное хранилище
      final prefs = await SharedPreferences.getInstance();
      final localStatus = prefs.getBool(_keyOnboardingCompleted) ?? 
                         prefs.getBool('onboarding_completed') ?? 
                         false;
      debugPrint('📋 Local onboarding status: $localStatus');
      return localStatus;
      
    } catch (e) {
      debugPrint('❌ Error checking onboarding completion: $e');
      return false;
    }
  }

  // Статический метод для получения сохраненных данных
  static Future<OnboardingData?> getSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataJson = prefs.getString(_keyOnboardingData);
      
      if (dataJson != null) {
        return OnboardingData.fromJsonString(dataJson);
      }
    } catch (e) {
      debugPrint('Error loading saved onboarding data: $e');
    }
    return null;
  }
}
