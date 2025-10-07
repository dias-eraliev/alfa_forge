-- Migration: Initial database schema for Alfa Forge
-- Created: 2025-10-02
-- Description: Creates all necessary tables for the fitness and personal development app

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ===========================================
-- USERS TABLE
-- ===========================================
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(100) UNIQUE,
    full_name VARCHAR(255),
    phone VARCHAR(20),
    city VARCHAR(100),
    avatar_url TEXT,
    bio TEXT,
    date_of_birth DATE,
    gender VARCHAR(20),
    height_cm INTEGER,
    weight_kg DECIMAL(5,2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_login_at TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT TRUE,
    onboarding_completed BOOLEAN DEFAULT FALSE
);

-- ===========================================
-- HABITS TABLE
-- ===========================================
CREATE TABLE habits (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    icon VARCHAR(10),
    description TEXT,
    category VARCHAR(50),
    difficulty VARCHAR(20) DEFAULT 'medium',
    is_default BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ===========================================
-- USER HABITS TABLE
-- ===========================================
CREATE TABLE user_habits (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    habit_id VARCHAR(50) NOT NULL REFERENCES habits(id) ON DELETE CASCADE,
    is_active BOOLEAN DEFAULT TRUE,
    target_value INTEGER DEFAULT 1,
    unit VARCHAR(20) DEFAULT 'times',
    reminder_time TIME,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, habit_id)
);

-- ===========================================
-- HABIT LOGS TABLE
-- ===========================================
CREATE TABLE habit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_habit_id UUID NOT NULL REFERENCES user_habits(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    logged_date DATE NOT NULL,
    actual_value INTEGER DEFAULT 1,
    notes TEXT,
    mood_rating INTEGER CHECK (mood_rating >= 1 AND mood_rating <= 5),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_habit_id, logged_date)
);

-- ===========================================
-- GOALS TABLE
-- ===========================================
CREATE TABLE goals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    emoji VARCHAR(10),
    current_value DECIMAL(10,2) DEFAULT 0,
    target_value DECIMAL(10,2) NOT NULL,
    unit VARCHAR(50) NOT NULL,
    goal_type VARCHAR(20) NOT NULL CHECK (goal_type IN ('increase', 'decrease')),
    color_hex VARCHAR(7) DEFAULT '#E9E1D1',
    days_passed INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT TRUE
);

-- ===========================================
-- GOAL HISTORY TABLE
-- ===========================================
CREATE TABLE goal_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    goal_id UUID NOT NULL REFERENCES goals(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    value DECIMAL(10,2) NOT NULL,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(goal_id, date)
);

-- ===========================================
-- USER PROGRESS TABLE
-- ===========================================
CREATE TABLE user_progress (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    total_steps INTEGER DEFAULT 0,
    current_streak INTEGER DEFAULT 0,
    longest_streak INTEGER DEFAULT 0,
    total_xp INTEGER DEFAULT 0,
    current_zone VARCHAR(50) DEFAULT 'ТЕЛО',
    last_active_date DATE DEFAULT CURRENT_DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id)
);

-- ===========================================
-- PROGRESS HISTORY TABLE
-- ===========================================
CREATE TABLE progress_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_progress_id UUID NOT NULL REFERENCES user_progress(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    steps_completed INTEGER DEFAULT 0,
    xp_earned INTEGER DEFAULT 0,
    calories_burned INTEGER DEFAULT 0,
    tasks_completed INTEGER DEFAULT 0,
    zone VARCHAR(50),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_progress_id, date)
);

-- ===========================================
-- SPHERE PROGRESS TABLE
-- ===========================================
CREATE TABLE sphere_progress (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_progress_id UUID NOT NULL REFERENCES user_progress(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    sphere_name VARCHAR(50) NOT NULL,
    progress_percentage DECIMAL(3,2) DEFAULT 0.00 CHECK (progress_percentage >= 0 AND progress_percentage <= 1),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_progress_id, sphere_name)
);

-- ===========================================
-- EXERCISES TABLE
-- ===========================================
CREATE TABLE exercises (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    icon VARCHAR(10),
    difficulty VARCHAR(20) DEFAULT 'medium',
    category VARCHAR(50),
    instructions TEXT[],
    tips JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ===========================================
-- WORKOUT SESSIONS TABLE
-- ===========================================
CREATE TABLE workout_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    end_time TIMESTAMP WITH TIME ZONE,
    status VARCHAR(20) DEFAULT 'in_progress' CHECK (status IN ('in_progress', 'completed', 'cancelled')),
    total_reps_completed INTEGER DEFAULT 0,
    average_quality DECIMAL(3,2) DEFAULT 0.00,
    duration INTERVAL DEFAULT '0 seconds',
    calories_burned INTEGER DEFAULT 0,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ===========================================
-- WORKOUT EXERCISES TABLE
-- ===========================================
CREATE TABLE workout_exercises (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    workout_session_id UUID NOT NULL REFERENCES workout_sessions(id) ON DELETE CASCADE,
    exercise_id VARCHAR(50) NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
    target_reps INTEGER NOT NULL,
    completed_reps INTEGER DEFAULT 0,
    average_quality DECIMAL(3,2) DEFAULT 0.00,
    duration INTERVAL DEFAULT '0 seconds',
    rest_time INTERVAL DEFAULT '60 seconds',
    order_index INTEGER NOT NULL,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ===========================================
-- TASKS TABLE
-- ===========================================
CREATE TABLE tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    priority VARCHAR(20) DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'cancelled')),
    due_date DATE,
    completed_at TIMESTAMP WITH TIME ZONE,
    estimated_duration INTERVAL,
    actual_duration INTERVAL,
    tags TEXT[],
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ===========================================
-- BROTHERHOOD POSTS TABLE
-- ===========================================
CREATE TABLE brotherhood_posts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255),
    content TEXT NOT NULL,
    post_type VARCHAR(20) DEFAULT 'text' CHECK (post_type IN ('text', 'image', 'video', 'link')),
    media_url TEXT,
    is_pinned BOOLEAN DEFAULT FALSE,
    is_featured BOOLEAN DEFAULT FALSE,
    likes_count INTEGER DEFAULT 0,
    comments_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ===========================================
-- BROTHERHOOD COMMENTS TABLE
-- ===========================================
CREATE TABLE brotherhood_comments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    post_id UUID NOT NULL REFERENCES brotherhood_posts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    parent_comment_id UUID REFERENCES brotherhood_comments(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    likes_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ===========================================
-- BROTHERHOOD LIKES TABLE
-- ===========================================
CREATE TABLE brotherhood_likes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    post_id UUID REFERENCES brotherhood_posts(id) ON DELETE CASCADE,
    comment_id UUID REFERENCES brotherhood_comments(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, post_id),
    UNIQUE(user_id, comment_id),
    CHECK (
        (post_id IS NOT NULL AND comment_id IS NULL) OR
        (post_id IS NULL AND comment_id IS NOT NULL)
    )
);

-- ===========================================
-- USER ACHIEVEMENTS TABLE
-- ===========================================
CREATE TABLE user_achievements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    achievement_type VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    icon VARCHAR(10),
    xp_reward INTEGER DEFAULT 0,
    unlocked_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, achievement_type)
);

-- ===========================================
-- INDEXES FOR PERFORMANCE
-- ===========================================
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_user_habits_user_id ON user_habits(user_id);
CREATE INDEX idx_habit_logs_user_habit_id ON habit_logs(user_habit_id);
CREATE INDEX idx_habit_logs_date ON habit_logs(logged_date);
CREATE INDEX idx_goals_user_id ON goals(user_id);
CREATE INDEX idx_goal_history_goal_id ON goal_history(goal_id);
CREATE INDEX idx_goal_history_date ON goal_history(date);
CREATE INDEX idx_user_progress_user_id ON user_progress(user_id);
CREATE INDEX idx_progress_history_user_id ON progress_history(user_id);
CREATE INDEX idx_progress_history_date ON progress_history(date);
CREATE INDEX idx_sphere_progress_user_id ON sphere_progress(user_id);
CREATE INDEX idx_workout_sessions_user_id ON workout_sessions(user_id);
CREATE INDEX idx_workout_sessions_start_time ON workout_sessions(start_time);
CREATE INDEX idx_workout_exercises_session_id ON workout_exercises(workout_session_id);
CREATE INDEX idx_tasks_user_id ON tasks(user_id);
CREATE INDEX idx_tasks_status ON tasks(status);
CREATE INDEX idx_tasks_due_date ON tasks(due_date);
CREATE INDEX idx_brotherhood_posts_user_id ON brotherhood_posts(user_id);
CREATE INDEX idx_brotherhood_posts_created_at ON brotherhood_posts(created_at);
CREATE INDEX idx_brotherhood_comments_post_id ON brotherhood_comments(post_id);
CREATE INDEX idx_brotherhood_likes_post_id ON brotherhood_likes(post_id);
CREATE INDEX idx_brotherhood_likes_comment_id ON brotherhood_likes(comment_id);

-- ===========================================
-- TRIGGERS FOR UPDATED_AT
-- ===========================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_user_habits_updated_at BEFORE UPDATE ON user_habits FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_goals_updated_at BEFORE UPDATE ON goals FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_user_progress_updated_at BEFORE UPDATE ON user_progress FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_workout_sessions_updated_at BEFORE UPDATE ON workout_sessions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_tasks_updated_at BEFORE UPDATE ON tasks FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_brotherhood_posts_updated_at BEFORE UPDATE ON brotherhood_posts FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_brotherhood_comments_updated_at BEFORE UPDATE ON brotherhood_comments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ===========================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ===========================================
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_habits ENABLE ROW LEVEL SECURITY;
ALTER TABLE habit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE goal_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE progress_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE sphere_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE workout_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE workout_exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE brotherhood_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE brotherhood_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE brotherhood_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_achievements ENABLE ROW LEVEL SECURITY;

-- Users can only see and modify their own data
CREATE POLICY "Users can view own profile" ON users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON users FOR UPDATE USING (auth.uid() = id);

-- Similar policies for other tables
CREATE POLICY "Users can view own habits" ON user_habits FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own habits" ON user_habits FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can view own habit logs" ON habit_logs FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own habit logs" ON habit_logs FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can view own goals" ON goals FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own goals" ON goals FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can view own goal history" ON goal_history FOR SELECT USING (
    auth.uid() = (SELECT user_id FROM goals WHERE id = goal_id)
);
CREATE POLICY "Users can manage own goal history" ON goal_history FOR ALL USING (
    auth.uid() = (SELECT user_id FROM goals WHERE id = goal_id)
);

-- And so on for other tables...

-- Tasks policies
CREATE POLICY IF NOT EXISTS "Users can view own tasks" ON tasks FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY IF NOT EXISTS "Users can insert own tasks" ON tasks FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY IF NOT EXISTS "Users can update own tasks" ON tasks FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY IF NOT EXISTS "Users can delete own tasks" ON tasks FOR DELETE USING (auth.uid() = user_id);

-- ===========================================
-- INITIAL DATA
-- ===========================================

-- Insert default habits
INSERT INTO habits (id, name, icon, description, category, difficulty) VALUES
('early_rise', 'Ранний подъём', '🌅', 'Просыпаться в 6:00', 'health', 'medium'),
('reading', 'Чтение', '📚', '30 минут чтения', 'education', 'easy'),
('workout', 'Тренировка', '🏋️‍♂️', 'Физические упражнения', 'fitness', 'hard'),
('meditation', 'Медитация', '🧘', '10 минут медитации', 'mindfulness', 'easy');

-- Insert default exercises
INSERT INTO exercises (id, name, description, icon, difficulty, category, instructions, tips) VALUES
('pushups', 'Отжимания', 'Классические отжимания от пола', '💪', 'medium', 'strength',
 ARRAY['Примите упор лежа', 'Руки на ширине плеч', 'Опускайтесь до касания грудью пола', 'Поднимайтесь в исходное положение'],
 '{"correct": "Отлично! Полная амплитуда!", "too_fast": "Медленнее! Контролируйте движение!", "too_shallow": "Ниже! Касайтесь грудью пола!", "bad_form": "Держите корпус прямо!", "good_pace": "Идеальный темп!"}'),
('squats', 'Приседания', 'Глубокие приседания', '🦵', 'medium', 'strength',
 ARRAY['Встаньте прямо, ноги на ширине плеч', 'Медленно опускайтесь вниз', 'Колени не должны выходить за носки', 'Поднимайтесь в исходное положение'],
 '{"correct": "Отлично! Глубокие приседания!", "too_shallow": "Глубже! Ниже параллели!", "knees_forward": "Колени не должны выходить за носки!", "good_form": "Идеальная техника!"}'),
('burpees', 'Берпи', 'Комплексное упражнение', '🔥', 'hard', 'cardio',
 ARRAY['Встаньте прямо', 'Присядьте и поставьте руки на пол', 'Отпрыгните ногами назад в упор лежа', 'Сделайте отжимание', 'Вернитесь в присед', 'Прыжком встаньте'],
 '{"correct": "Отлично! Полный берпи!", "no_pushup": "Не забудьте отжимание!", "no_jump": "Добавьте прыжок в конце!", "good_pace": "Идеальный темп!"}');

-- ===========================================
-- FUNCTIONS
-- ===========================================

-- Function to update user progress streaks
CREATE OR REPLACE FUNCTION update_user_streak(user_uuid UUID)
RETURNS VOID AS $$
DECLARE
    last_active DATE;
    current_streak INT;
BEGIN
    -- Get the last active date and current streak
    SELECT last_active_date, current_streak INTO last_active, current_streak
    FROM user_progress WHERE user_id = user_uuid;

    -- If last active was yesterday, increment streak
    IF last_active = CURRENT_DATE - INTERVAL '1 day' THEN
        UPDATE user_progress
        SET current_streak = current_streak + 1,
            longest_streak = GREATEST(longest_streak, current_streak + 1),
            last_active_date = CURRENT_DATE,
            updated_at = NOW()
        WHERE user_id = user_uuid;
    -- If last active was today, do nothing
    ELSIF last_active = CURRENT_DATE THEN
        -- Already updated today
        NULL;
    -- If last active was before yesterday, reset streak
    ELSE
        UPDATE user_progress
        SET current_streak = 1,
            last_active_date = CURRENT_DATE,
            updated_at = NOW()
        WHERE user_id = user_uuid;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Function to calculate goal progress
CREATE OR REPLACE FUNCTION calculate_goal_progress(goal_uuid UUID)
RETURNS DECIMAL(5,2) AS $$
DECLARE
    goal_record RECORD;
    progress DECIMAL(5,2);
BEGIN
    SELECT * INTO goal_record FROM goals WHERE id = goal_uuid;

    IF goal_record.target_value = 0 THEN
        RETURN 0.0;
    END IF;

    IF goal_record.goal_type = 'increase' THEN
        progress := (goal_record.current_value / goal_record.target_value) * 100;
    ELSE
        -- For decrease goals, calculate based on initial vs current
        -- This is a simplified calculation
        progress := ((goal_record.target_value - goal_record.current_value) / goal_record.target_value) * 100;
    END IF;

    RETURN GREATEST(0, LEAST(100, progress));
END;
$$ LANGUAGE plpgsql;