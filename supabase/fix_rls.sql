-- Fix RLS policies for Alfa Forge database
-- Run this script to fix Row Level Security issues

-- ===========================================
-- DROP EXISTING POLICIES (if they exist)
-- ===========================================

-- Drop existing policies for user_progress
DROP POLICY IF EXISTS "Users can view their own progress" ON user_progress;
DROP POLICY IF EXISTS "Users can insert their own progress" ON user_progress;
DROP POLICY IF EXISTS "Users can update their own progress" ON user_progress;

-- Drop existing policies for sphere_progress
DROP POLICY IF EXISTS "Users can view their own sphere progress" ON sphere_progress;
DROP POLICY IF EXISTS "Users can insert their own sphere progress" ON sphere_progress;
DROP POLICY IF EXISTS "Users can update their own sphere progress" ON sphere_progress;
DROP POLICY IF EXISTS "Users can delete their own sphere progress" ON sphere_progress;

-- ===========================================
-- CREATE CORRECT RLS POLICIES
-- ===========================================

-- User progress policies (UPSERT support)
CREATE POLICY "Users can view their own progress" ON user_progress
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own progress" ON user_progress
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own progress" ON user_progress
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can upsert their own progress" ON user_progress
    FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- Sphere progress policies
CREATE POLICY "Users can view their own sphere progress" ON sphere_progress
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own sphere progress" ON sphere_progress
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own sphere progress" ON sphere_progress
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own sphere progress" ON sphere_progress
    FOR DELETE USING (auth.uid() = user_id);

-- ===========================================
-- VERIFY POLICIES
-- ===========================================

-- Check if RLS is enabled
SELECT schemaname, tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
AND tablename IN ('user_progress', 'sphere_progress', 'user_habits', 'habit_logs')
ORDER BY tablename;

-- List all policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies
WHERE schemaname = 'public'
AND tablename IN ('user_progress', 'sphere_progress', 'user_habits', 'habit_logs')
ORDER BY tablename, policyname;