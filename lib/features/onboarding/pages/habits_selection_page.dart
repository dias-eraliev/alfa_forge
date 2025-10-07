import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../controllers/onboarding_controller.dart';
import '../models/development_sphere_model.dart';
import '../widgets/progress_dots.dart';
import '../widgets/sphere_card.dart';
// Старый крупный вариант карточек (оставлен, но не используется)
// import '../widgets/habit_card.dart';
import '../widgets/habit_mini_card.dart';
import 'name_page.dart'; // Для доступа к provider

class HabitsSelectionPage extends ConsumerStatefulWidget {
  const HabitsSelectionPage({super.key});

  @override
  ConsumerState<HabitsSelectionPage> createState() => _HabitsSelectionPageState();
}

class _HabitsSelectionPageState extends ConsumerState<HabitsSelectionPage>
    with TickerProviderStateMixin {
  late AnimationController _transitionController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _transitionController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _transitionController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _transitionController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _transitionController.dispose();
    super.dispose();
  }

  void _switchToHabitSelection() {
    ref.read(onboardingControllerProvider).enterHabitSelectionMode();
    _transitionController.forward();
  }

  void _switchBackToSphereSelection() {
    _transitionController.reverse().then((_) {
      ref.read(onboardingControllerProvider).exitHabitSelectionMode();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(onboardingControllerProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      backgroundColor: PRIMETheme.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: PRIMETheme.sand,
            size: isSmallScreen ? 20 : 24,
          ),
          onPressed: () {
            if (controller.isInHabitSelectionMode) {
              _switchBackToSphereSelection();
            } else {
              context.go('/onboarding/name');
            }
          },
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            if (!controller.isInHabitSelectionMode)
              _buildSphereSelectionScreen(context, controller, isSmallScreen),
            if (controller.isInHabitSelectionMode)
              AnimatedBuilder(
                animation: _transitionController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: _buildHabitSelectionScreen(
                        context,
                        controller,
                        isSmallScreen,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  // ---------- ЭКРАН ВЫБОРА СФЕР ----------
  Widget _buildSphereSelectionScreen(BuildContext context,
      OnboardingController controller, bool isSmallScreen) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 32 : 64,
          vertical: 20,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            children: [
              const ProgressDots(
                totalSteps: 5,
                currentStep: 3,
              ),
              SizedBox(height: isSmallScreen ? 32 : 48),
              Column(
                children: [
                  Text(
                    'ВЫБОР СФЕР',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: isSmallScreen ? 36 : 42,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          color: PRIMETheme.sand,
                        ),
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 16),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 16 : 20,
                      vertical: isSmallScreen ? 8 : 10,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: PRIMETheme.primary, width: 2),
borderRadius: BorderRadius.circular(8),
                      color: PRIMETheme.primary.withValues(alpha: 0.1),
                    ),
                    child: Text(
                      'РАЗВИТИЯ',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: PRIMETheme.primary,
                            fontSize: isSmallScreen ? 12 : 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 20 : 28),
                  Text(
                    'Выбери 2-3 сферы развития.\nОни определят твой путь роста.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: PRIMETheme.sandWeak,
                          fontSize: isSmallScreen ? 14 : 16,
                          height: 1.5,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              SizedBox(height: isSmallScreen ? 32 : 48),
              SpheresGrid(
                spheres: DevelopmentSpheresData.spheres,
                selectedSpheres: controller.selectedSpheres,
                onSphereToggle: (sphere) {
                  ref.read(onboardingControllerProvider).toggleSphere(sphere);
                },
              ),
              SizedBox(height: isSmallScreen ? 24 : 32),
              if (controller.selectedSpheres.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 16 : 20,
                    vertical: isSmallScreen ? 8 : 10,
                  ),
                  decoration: BoxDecoration(
                    color: PRIMETheme.bg,
                    borderRadius: BorderRadius.circular(20),
border: Border.all(
                      color: PRIMETheme.primary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    boxShadow: [
BoxShadow(
                        color: PRIMETheme.primary.withValues(alpha: 0.1),
                        blurRadius: 8,
                        spreadRadius: 0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'Выбрано: ${controller.selectedSpheres.length} из 3 сфер',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: isSmallScreen ? 12 : 13,
                          color: PRIMETheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              if (controller.selectedSpheres.isNotEmpty)
                SizedBox(height: isSmallScreen ? 20 : 28),
              SizedBox(
                width: double.infinity,
                height: isSmallScreen ? 56 : 64,
                child: ElevatedButton(
                  onPressed: controller.canProceedFromSpheres
                      ? _switchToHabitSelection
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: controller.canProceedFromSpheres
                        ? PRIMETheme.primary
                        : PRIMETheme.line,
                    foregroundColor: controller.canProceedFromSpheres
                        ? PRIMETheme.sand
                        : PRIMETheme.sandWeak,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: controller.canProceedFromSpheres ? 8 : 0,
shadowColor: controller.canProceedFromSpheres
                        ? PRIMETheme.primary.withValues(alpha: 0.4)
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: isSmallScreen ? 18 : 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'ВЫБРАТЬ ПРИВЫЧКИ',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: isSmallScreen ? 24 : 32),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- ЭКРАН ВЫБОРА ПРИВЫЧЕК (НОВЫЙ КОМПАКТНЫЙ UX) ----------
  Widget _buildHabitSelectionScreen(BuildContext context,
      OnboardingController controller, bool isSmallScreen) {
    final selectedHabits = controller.selectedHabits;
    final filteredHabits = controller.filteredHabits;
    final selectedIds = selectedHabits.map((h) => h.id).toSet();
    const maxHabits = 5;
    final reachedLimit = selectedHabits.length >= maxHabits;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 24 : 64,
          vertical: 20,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Column(
            children: [
              const ProgressDots(
                totalSteps: 5,
                currentStep: 3,
              ),
              SizedBox(height: isSmallScreen ? 28 : 40),
              _buildHabitHeader(context, isSmallScreen, selectedHabits.length),
              SizedBox(height: isSmallScreen ? 28 : 40),
              _buildSphereFiltersRow(
                  context, controller, isSmallScreen, reachedLimit),
              if (selectedHabits.isNotEmpty) ...[
                SizedBox(height: isSmallScreen ? 16 : 20),
                _buildSelectedHabitsSection(
                    context, controller, selectedHabits, isSmallScreen),
              ],
              SizedBox(height: isSmallScreen ? 20 : 28),
              _buildHabitsGrid(
                context: context,
                controller: controller,
                habits: filteredHabits,
                selectedIds: selectedIds,
                reachedLimit: reachedLimit,
                isSmall: isSmallScreen,
              ),
              if (controller.canShowMoreHabits) ...[
                SizedBox(height: isSmallScreen ? 20 : 28),
                _buildShowMoreButton(context, controller),
              ],
              SizedBox(height: isSmallScreen ? 28 : 40),
              _buildBottomInfo(context, selectedHabits.length, maxHabits),
              SizedBox(height: isSmallScreen ? 24 : 32),
              _buildActivateButton(
                  context, controller, isSmallScreen, selectedHabits.length),
              SizedBox(height: isSmallScreen ? 24 : 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHabitHeader(
      BuildContext context, bool isSmall, int selectedCount) {
    return Column(
      children: [
        Text(
          'ВЫБОР ПРИВЫЧЕК',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: isSmall ? 30 : 36,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: PRIMETheme.sand,
            ),
        ),
        SizedBox(height: isSmall ? 10 : 14),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isSmall ? 14 : 18,
            vertical: isSmall ? 6 : 8,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: PRIMETheme.primary, width: 2),
borderRadius: BorderRadius.circular(8),
            color: PRIMETheme.primary.withValues(alpha: 0.1),
          ),
          child: Text(
            'ИЗ ВЫБРАННЫХ СФЕР',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: PRIMETheme.primary,
                  fontSize: isSmall ? 11 : 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
          ),
        ),
        SizedBox(height: isSmall ? 18 : 24),
        Text(
          'Выбери 5 ключевых привычек.\nОни станут твоей стартовой системой.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: PRIMETheme.sandWeak,
                fontSize: isSmall ? 13 : 15,
                height: 1.5,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSphereFiltersRow(
    BuildContext context,
    OnboardingController controller,
    bool isSmall,
    bool reachedLimit,
  ) {
    final spheres = controller.selectedSpheres;
    if (spheres.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Лимит
        Row(
          children: [
            Text(
              '${controller.selectedHabits.length} / 5',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: controller.selectedHabits.length >= 5
                        ? PRIMETheme.primary
                        : PRIMETheme.sandWeak,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
            ),
            const SizedBox(width: 12),
            if (reachedLimit)
              Text(
                'Лимит достигнут',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: PRIMETheme.primary,
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
              ),
          ],
        ),
        SizedBox(height: isSmall ? 10 : 14),
        // Фильтры сфер
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...spheres.map((s) {
                final active =
                    controller.activeSphereFilters.contains(s.id) ||
                        (controller.activeSphereFilters.isEmpty);
                final explicitActive =
                    controller.activeSphereFilters.contains(s.id);
                return GestureDetector(
                  onTap: () {
                    ref
                        .read(onboardingControllerProvider)
                        .toggleSphereFilter(s.id);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmall ? 14 : 16,
                      vertical: isSmall ? 8 : 9,
                    ),
                    decoration: BoxDecoration(
color: explicitActive
                          ? PRIMETheme.primary.withValues(alpha: 0.09)
                          : PRIMETheme.bg,
                      border: Border.all(
                        color: explicitActive
                            ? PRIMETheme.primary
                            : PRIMETheme.line,
                        width: explicitActive ? 1.2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      s.name,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight:
                            explicitActive ? FontWeight.w600 : FontWeight.w500,
                        letterSpacing: 0.4,
                        color: explicitActive
                            ? PRIMETheme.primary
                            : active
                                ? PRIMETheme.sand
                                : PRIMETheme.sandWeak,
                      ),
                    ),
                  ),
                );
              }),
              if (controller.activeSphereFilters.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    ref.read(onboardingControllerProvider).clearSphereFilters();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmall ? 14 : 16,
                      vertical: isSmall ? 8 : 9,
                    ),
                    decoration: BoxDecoration(
                      color: PRIMETheme.bg,
                      border: Border.all(
                        color: PRIMETheme.line,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Text(
                      'ВСЕ',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.4,
                        color: PRIMETheme.sandWeak,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedHabitsSection(
    BuildContext context,
    OnboardingController controller,
    List selectedHabits,
    bool isSmall,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ВЫБРАНО',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 11,
                letterSpacing: 1,
                color: PRIMETheme.sandWeak.withValues(alpha: 0.8),
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          children: selectedHabits.asMap().entries.map((e) {
            final habit = e.value;
            return SelectedHabitBadge(
              habit: habit,
              animationDelay: e.key * 40,
              onRemove: () {
                ref.read(onboardingControllerProvider).toggleHabit(habit);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildHabitsGrid({
    required BuildContext context,
    required OnboardingController controller,
    required List habits,
    required Set<String> selectedIds,
    required bool reachedLimit,
    required bool isSmall,
  }) {
    if (habits.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        decoration: BoxDecoration(
          border: Border.all(color: PRIMETheme.line, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(Icons.inbox, size: 36, color: PRIMETheme.sandWeak.withValues(alpha: 0.6)),
            const SizedBox(height: 12),
            Text(
              'Нет привычек для выбранных фильтров',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: PRIMETheme.sandWeak,
                    fontSize: 13,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Сбросьте фильтр или выберите другую сферу',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: PRIMETheme.sandWeak.withValues(alpha: 0.7),
                    fontSize: 11,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Горизонтальная прокрутка: 3 столбца * 5 строк, лишнее вправо
    const rowsPerColumn = 5;
    const targetColumns = 3;
    const vSpacing = 8.0;
    const hSpacing = 12.0;
    const cardMinHeight = 64.0;

    final maxWidth = MediaQuery.of(context).size.width.clamp(0, 620).toDouble();
    final available = maxWidth - 8; // небольшой запас как раньше
    final columnWidth = (available - hSpacing * (targetColumns - 1)) / targetColumns;

    // Разбиваем привычки по колонкам (вертикально заполняем по 5)
    final List<List> columns = [];
    for (int i = 0; i < habits.length; i++) {
      final colIndex = i ~/ rowsPerColumn;
      if (columns.length <= colIndex) {
        columns.add([]);
      }
      columns[colIndex].add(habits[i]);
    }

    const gridHeight = rowsPerColumn * cardMinHeight + (rowsPerColumn - 1) * vSpacing;

    return SizedBox(
      width: double.infinity,
      height: gridHeight,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...columns.asMap().entries.map((colEntry) {
              final colIdx = colEntry.key;
              final colHabits = colEntry.value;
              return Container(
                width: columnWidth,
                margin: EdgeInsets.only(right: colIdx == columns.length - 1 ? 0 : hSpacing),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...colHabits.asMap().entries.map((rowEntry) {
                      final rowIdx = rowEntry.key;
                      final habit = rowEntry.value;
                      final globalIndex = colIdx * rowsPerColumn + rowIdx;
                      final selected = selectedIds.contains(habit.id);
                      final disabled = reachedLimit && !selected;
                      return Padding(
                        padding: EdgeInsets.only(bottom: rowIdx == colHabits.length - 1 ? 0 : vSpacing),
                        child: HabitMiniCard(
                          habit: habit,
                          selected: selected,
                          disabled: disabled,
                          width: columnWidth,
                          animationDelay: globalIndex * 20,
                          onTap: () {
                            ref.read(onboardingControllerProvider).toggleHabit(habit);
                          },
                        ),
                      );
                    }),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildShowMoreButton(
      BuildContext context, OnboardingController controller) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          ref.read(onboardingControllerProvider).showMoreHabits();
        },
        style: OutlinedButton.styleFrom(
side: BorderSide(color: PRIMETheme.primary.withValues(alpha: 0.5), width: 1),
          foregroundColor: PRIMETheme.primary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: const Text(
          'ПОКАЗАТЬ ЕЩЁ',
          style: TextStyle(
            fontSize: 13,
            letterSpacing: 1,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomInfo(
      BuildContext context, int selectedCount, int maxHabits) {
    return Column(
      children: [
        if (selectedCount < maxHabits)
          Text(
            'Осталось выбрать: ${maxHabits - selectedCount}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: PRIMETheme.sandWeak.withValues(alpha: 0.75),
                  fontSize: 11.5,
                  letterSpacing: 0.5,
                ),
          )
        else
          Text(
            'Лимит достигнут — можно активировать',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: PRIMETheme.primary,
                  fontSize: 11.5,
                  letterSpacing: 0.5,
                ),
          ),
      ],
    );
  }

  Widget _buildActivateButton(BuildContext context,
      OnboardingController controller, bool isSmall, int selectedCount) {
    final valid = selectedCount == 5; // жестко 5
    return SizedBox(
      width: double.infinity,
      height: isSmall ? 56 : 64,
      child: ElevatedButton(
        onPressed: valid ? () => context.go('/onboarding/ready') : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: valid ? PRIMETheme.primary : PRIMETheme.line,
          foregroundColor: valid ? PRIMETheme.sand : PRIMETheme.sandWeak,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: valid ? 6 : 0,
shadowColor: valid ? PRIMETheme.primary.withValues(alpha: 0.35) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              valid ? Icons.check_circle_outline : Icons.hourglass_bottom,
              size: isSmall ? 18 : 20,
            ),
            const SizedBox(width: 8),
            Text(
              valid ? 'АКТИВИРОВАТЬ СИСТЕМУ' : 'ВЫБЕРИ ЕЩЁ',
              style: TextStyle(
                fontSize: isSmall ? 14 : 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
