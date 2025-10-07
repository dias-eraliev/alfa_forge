-- Migration: Fix RLS policies for progress_history to allow safe upserts
-- Created: 2025-10-06
-- Description: Adds explicit INSERT/UPDATE/DELETE policies with WITH CHECK clauses
--              so that authenticated users can insert/upsert their own progress history
--              rows via REST (on_conflict=user_progress_id,date).

-- Clean up any existing policies to make this migration idempotent
DROP POLICY IF EXISTS "Users can manage own progress history" ON progress_history;
DROP POLICY IF EXISTS "Users can view own progress history" ON progress_history;
DROP POLICY IF EXISTS "Users can insert own progress history" ON progress_history;
DROP POLICY IF EXISTS "Users can update own progress history" ON progress_history;
DROP POLICY IF EXISTS "Users can delete own progress history" ON progress_history;

-- Read policy
CREATE POLICY "Users can view own progress history"
  ON progress_history FOR SELECT
  USING (auth.uid() = user_id);

-- Insert policy: require ownership by user_id and that user_progress_id belongs to the same user
CREATE POLICY "Users can insert own progress history"
  ON progress_history FOR INSERT
  WITH CHECK (
    auth.uid() = user_id
    AND user_progress_id IN (
      SELECT id FROM user_progress WHERE user_id = auth.uid()
    )
  );

-- Update policy: allow updating only own rows and keep ownership after update
CREATE POLICY "Users can update own progress history"
  ON progress_history FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Delete policy: allow deleting only own rows
CREATE POLICY "Users can delete own progress history"
  ON progress_history FOR DELETE
  USING (auth.uid() = user_id);
