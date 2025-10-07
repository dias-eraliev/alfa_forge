-- Migration: Add RLS policies for user_progress table
-- Created: 2025-10-03
-- Description: Adds missing RLS policies for user_progress table to allow users to manage their own progress data

-- Add RLS policies for user_progress table
CREATE POLICY "Users can view own progress" ON user_progress FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own progress" ON user_progress FOR ALL USING (auth.uid() = user_id);

-- Add RLS policies for progress_history table
CREATE POLICY "Users can view own progress history" ON progress_history FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own progress history" ON progress_history FOR ALL USING (auth.uid() = user_id);

-- Add RLS policies for sphere_progress table
CREATE POLICY "Users can view own sphere progress" ON sphere_progress FOR SELECT USING (
    auth.uid() = (SELECT user_id FROM user_progress WHERE id = user_progress_id)
);
CREATE POLICY "Users can manage own sphere progress" ON sphere_progress FOR ALL USING (
    auth.uid() = (SELECT user_id FROM user_progress WHERE id = user_progress_id)
);