-- Добавить колонку frequency в user_habits, если её нет (идемпотентно)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name='user_habits' AND column_name='frequency'
    ) THEN
        ALTER TABLE user_habits ADD COLUMN frequency text DEFAULT 'daily';
    END IF;
END $$;
-- Sample queries and test data for Alfa Forge database

-- ===========================================
-- ROW LEVEL SECURITY POLICIES
-- ===========================================

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_habits ENABLE ROW LEVEL SECURITY;
ALTER TABLE habit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE goal_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE workout_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE workout_exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE brotherhood_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE brotherhood_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE brotherhood_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE sphere_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE progress_history ENABLE ROW LEVEL SECURITY;

-- Users table policies
CREATE POLICY "Users can view their own profile" ON users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON users
    FOR UPDATE USING (auth.uid() = id);

-- User progress policies
CREATE POLICY "Users can view their own progress" ON user_progress
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own progress" ON user_progress
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own progress" ON user_progress
    FOR UPDATE USING (auth.uid() = user_id);

-- User habits policies
CREATE POLICY "Users can view their own habits" ON user_habits
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own habits" ON user_habits
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own habits" ON user_habits
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own habits" ON user_habits
    FOR DELETE USING (auth.uid() = user_id);

-- Habit logs policies
CREATE POLICY "Users can view their own habit logs" ON habit_logs
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM user_habits uh
            WHERE uh.id = habit_logs.user_habit_id
            AND uh.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert their own habit logs" ON habit_logs
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM user_habits uh
            WHERE uh.id = habit_logs.user_habit_id
            AND uh.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can update their own habit logs" ON habit_logs
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM user_habits uh
            WHERE uh.id = habit_logs.user_habit_id
            AND uh.user_id = auth.uid()
        )
    );

-- Goals policies
CREATE POLICY "Users can view their own goals" ON goals
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own goals" ON goals
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own goals" ON goals
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own goals" ON goals
    FOR DELETE USING (auth.uid() = user_id);

-- Goal history policies
CREATE POLICY "Users can view their own goal history" ON goal_history
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM goals g
            WHERE g.id = goal_history.goal_id
            AND g.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert their own goal history" ON goal_history
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM goals g
            WHERE g.id = goal_history.goal_id
            AND g.user_id = auth.uid()
        )
    );

-- Workout sessions policies
CREATE POLICY "Users can view their own workout sessions" ON workout_sessions
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own workout sessions" ON workout_sessions
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own workout sessions" ON workout_sessions
    FOR UPDATE USING (auth.uid() = user_id);

-- Workout exercises policies
CREATE POLICY "Users can view their own workout exercises" ON workout_exercises
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM workout_sessions ws
            WHERE ws.id = workout_exercises.workout_session_id
            AND ws.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert their own workout exercises" ON workout_exercises
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM workout_sessions ws
            WHERE ws.id = workout_exercises.workout_session_id
            AND ws.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can update their own workout exercises" ON workout_exercises
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM workout_sessions ws
            WHERE ws.id = workout_exercises.workout_session_id
            AND ws.user_id = auth.uid()
        )
    );

-- Brotherhood posts policies (public read, authenticated write)
CREATE POLICY "Anyone can view brotherhood posts" ON brotherhood_posts
    FOR SELECT USING (true);

CREATE POLICY "Authenticated users can create posts" ON brotherhood_posts
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own posts" ON brotherhood_posts
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own posts" ON brotherhood_posts
    FOR DELETE USING (auth.uid() = user_id);

-- Brotherhood comments policies
CREATE POLICY "Anyone can view brotherhood comments" ON brotherhood_comments
    FOR SELECT USING (true);

CREATE POLICY "Authenticated users can create comments" ON brotherhood_comments
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own comments" ON brotherhood_comments
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own comments" ON brotherhood_comments
    FOR DELETE USING (auth.uid() = user_id);

-- Brotherhood likes policies
CREATE POLICY "Anyone can view brotherhood likes" ON brotherhood_likes
    FOR SELECT USING (true);

CREATE POLICY "Authenticated users can create likes" ON brotherhood_likes
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own likes" ON brotherhood_likes
    FOR DELETE USING (auth.uid() = user_id);

-- Sphere progress policies
CREATE POLICY "Users can view their own sphere progress" ON sphere_progress
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own sphere progress" ON sphere_progress
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own sphere progress" ON sphere_progress
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own sphere progress" ON sphere_progress
    FOR DELETE USING (auth.uid() = user_id);

-- Progress history policies
CREATE POLICY "Users can view their own progress history" ON progress_history
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own progress history" ON progress_history
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own progress history" ON progress_history
    FOR UPDATE USING (auth.uid() = user_id);

-- ===========================================
-- TEST DATA INSERTION
-- ===========================================

-- Insert test user
INSERT INTO users (email, username, full_name, city, onboarding_completed) VALUES
('test@example.com', 'testuser', 'Тестовый Пользователь', 'Москва', true);

-- Get user ID for further inserts
-- (Replace with actual UUID after insertion)

-- ===========================================
-- COMMON QUERIES
-- ===========================================

-- Get user profile with progress
SELECT
    u.*,
    up.total_steps,
    up.current_streak,
    up.total_xp,
    up.current_zone
FROM users u
LEFT JOIN user_progress up ON u.id = up.user_id
WHERE u.id = 'user-uuid-here';

-- Get user's active habits
SELECT
    uh.*,
    h.name,
    h.icon,
    h.description
FROM user_habits uh
JOIN habits h ON uh.habit_id = h.id
WHERE uh.user_id = 'user-uuid-here' AND uh.is_active = true;

-- Get user's goals with progress
SELECT
    g.*,
    ROUND((g.current_value / g.target_value) * 100, 2) as progress_percentage
FROM goals g
WHERE g.user_id = 'user-uuid-here' AND g.is_active = true
ORDER BY g.created_at DESC;

-- Get today's habit logs
SELECT
    hl.*,
    h.name,
    h.icon
FROM habit_logs hl
JOIN user_habits uh ON hl.user_habit_id = uh.id
JOIN habits h ON uh.habit_id = h.id
WHERE hl.logged_date = CURRENT_DATE
AND uh.user_id = 'user-uuid-here';

-- Get recent workout sessions
SELECT
    ws.*,
    COUNT(we.id) as exercises_count,
    SUM(we.completed_reps) as total_reps
FROM workout_sessions ws
LEFT JOIN workout_exercises we ON ws.id = we.workout_session_id
WHERE ws.user_id = 'user-uuid-here'
GROUP BY ws.id
ORDER BY ws.start_time DESC
LIMIT 10;

-- Get brotherhood posts with engagement
SELECT
    bp.*,
    u.username,
    u.avatar_url,
    COUNT(bl.id) as likes_count,
    COUNT(bc.id) as comments_count
FROM brotherhood_posts bp
JOIN users u ON bp.user_id = u.id
LEFT JOIN brotherhood_likes bl ON bp.id = bl.post_id
LEFT JOIN brotherhood_comments bc ON bp.id = bc.post_id
WHERE bp.created_at >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY bp.id, u.username, u.avatar_url
ORDER BY bp.created_at DESC;

-- ===========================================
-- ANALYTICS QUERIES
-- ===========================================

-- Weekly progress summary
SELECT
    DATE_TRUNC('week', ph.date) as week,
    SUM(ph.steps_completed) as total_steps,
    SUM(ph.xp_earned) as total_xp,
    SUM(ph.calories_burned) as total_calories,
    COUNT(DISTINCT ph.date) as active_days
FROM progress_history ph
WHERE ph.user_id = 'user-uuid-here'
AND ph.date >= CURRENT_DATE - INTERVAL '4 weeks'
GROUP BY DATE_TRUNC('week', ph.date)
ORDER BY week DESC;

-- Habit completion rate
SELECT
    h.name,
    COUNT(hl.id) as total_logs,
    COUNT(CASE WHEN hl.actual_value >= uh.target_value THEN 1 END) as completed_days,
    ROUND(
        COUNT(CASE WHEN hl.actual_value >= uh.target_value THEN 1 END)::decimal /
        NULLIF(COUNT(hl.id), 0) * 100, 2
    ) as completion_rate
FROM user_habits uh
JOIN habits h ON uh.habit_id = h.id
LEFT JOIN habit_logs hl ON uh.id = hl.user_habit_id
WHERE uh.user_id = 'user-uuid-here'
AND uh.is_active = true
AND hl.logged_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY uh.id, h.name;

-- Goal progress over time
SELECT
    g.name,
    gh.date,
    gh.value,
    g.target_value,
    ROUND((gh.value / g.target_value) * 100, 2) as progress_percentage
FROM goals g
JOIN goal_history gh ON g.id = gh.goal_id
WHERE g.user_id = 'user-uuid-here'
AND g.is_active = true
ORDER BY g.name, gh.date;

-- ===========================================
-- MAINTENANCE QUERIES
-- ===========================================

-- Update user streaks (run daily)
SELECT update_user_streak('user-uuid-here');

-- Clean up old data (optional)
-- DELETE FROM habit_logs WHERE logged_date < CURRENT_DATE - INTERVAL '1 year';
-- DELETE FROM progress_history WHERE date < CURRENT_DATE - INTERVAL '1 year';

-- ===========================================
-- DASHBOARD QUERIES
-- ===========================================

-- Today's summary
SELECT
    -- Today's habits
    (SELECT COUNT(*) FROM habit_logs hl
     JOIN user_habits uh ON hl.user_habit_id = uh.id
     WHERE uh.user_id = 'user-uuid-here'
     AND hl.logged_date = CURRENT_DATE) as habits_completed_today,

    -- Today's workouts
    (SELECT COUNT(*) FROM workout_sessions
     WHERE user_id = 'user-uuid-here'
     AND DATE(start_time) = CURRENT_DATE
     AND status = 'completed') as workouts_completed_today,

    -- Current streak
    (SELECT current_streak FROM user_progress
     WHERE user_id = 'user-uuid-here') as current_streak,

    -- Active goals
    (SELECT COUNT(*) FROM goals
     WHERE user_id = 'user-uuid-here'
     AND is_active = true) as active_goals;

-- Weekly stats
SELECT
    SUM(steps_completed) as weekly_steps,
    SUM(xp_earned) as weekly_xp,
    SUM(calories_burned) as weekly_calories,
    COUNT(DISTINCT date) as active_days
FROM progress_history
WHERE user_id = 'user-uuid-here'
AND date >= DATE_TRUNC('week', CURRENT_DATE);