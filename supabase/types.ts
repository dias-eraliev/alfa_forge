// Alfa Forge Supabase Types
// Generated types for TypeScript usage with Supabase client

export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export interface Database {
  public: {
    Tables: {
      users: {
        Row: {
          id: string
          email: string
          username: string | null
          full_name: string | null
          phone: string | null
          city: string | null
          avatar_url: string | null
          bio: string | null
          date_of_birth: string | null
          gender: string | null
          height_cm: number | null
          weight_kg: number | null
          created_at: string
          updated_at: string
          last_login_at: string | null
          is_active: boolean
          onboarding_completed: boolean
        }
        Insert: {
          id?: string
          email: string
          username?: string | null
          full_name?: string | null
          phone?: string | null
          city?: string | null
          avatar_url?: string | null
          bio?: string | null
          date_of_birth?: string | null
          gender?: string | null
          height_cm?: number | null
          weight_kg?: number | null
          created_at?: string
          updated_at?: string
          last_login_at?: string | null
          is_active?: boolean
          onboarding_completed?: boolean
        }
        Update: {
          id?: string
          email?: string
          username?: string | null
          full_name?: string | null
          phone?: string | null
          city?: string | null
          avatar_url?: string | null
          bio?: string | null
          date_of_birth?: string | null
          gender?: string | null
          height_cm?: number | null
          weight_kg?: number | null
          created_at?: string
          updated_at?: string
          last_login_at?: string | null
          is_active?: boolean
          onboarding_completed?: boolean
        }
      }
      habits: {
        Row: {
          id: string
          name: string
          icon: string | null
          description: string | null
          category: string | null
          difficulty: string
          is_default: boolean
          created_at: string
        }
        Insert: {
          id: string
          name: string
          icon?: string | null
          description?: string | null
          category?: string | null
          difficulty?: string
          is_default?: boolean
          created_at?: string
        }
        Update: {
          id?: string
          name?: string
          icon?: string | null
          description?: string | null
          category?: string | null
          difficulty?: string
          is_default?: boolean
          created_at?: string
        }
      }
      user_habits: {
        Row: {
          id: string
          user_id: string
          habit_id: string
          is_active: boolean
          target_value: number
          unit: string
          reminder_time: string | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          user_id: string
          habit_id: string
          is_active?: boolean
          target_value?: number
          unit?: string
          reminder_time?: string | null
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          user_id?: string
          habit_id?: string
          is_active?: boolean
          target_value?: number
          unit?: string
          reminder_time?: string | null
          created_at?: string
          updated_at?: string
        }
      }
      habit_logs: {
        Row: {
          id: string
          user_habit_id: string
          user_id: string
          logged_date: string
          actual_value: number
          notes: string | null
          mood_rating: number | null
          created_at: string
        }
        Insert: {
          id?: string
          user_habit_id: string
          user_id: string
          logged_date: string
          actual_value?: number
          notes?: string | null
          mood_rating?: number | null
          created_at?: string
        }
        Update: {
          id?: string
          user_habit_id?: string
          user_id?: string
          logged_date?: string
          actual_value?: number
          notes?: string | null
          mood_rating?: number | null
          created_at?: string
        }
      }
      goals: {
        Row: {
          id: string
          user_id: string
          name: string
          emoji: string | null
          current_value: number
          target_value: number
          unit: string
          goal_type: string
          color_hex: string
          days_passed: number
          created_at: string
          updated_at: string
          completed_at: string | null
          is_active: boolean
        }
        Insert: {
          id?: string
          user_id: string
          name: string
          emoji?: string | null
          current_value?: number
          target_value: number
          unit: string
          goal_type: string
          color_hex?: string
          days_passed?: number
          created_at?: string
          updated_at?: string
          completed_at?: string | null
          is_active?: boolean
        }
        Update: {
          id?: string
          user_id?: string
          name?: string
          emoji?: string | null
          current_value?: number
          target_value?: number
          unit?: string
          goal_type?: string
          color_hex?: string
          days_passed?: number
          created_at?: string
          updated_at?: string
          completed_at?: string | null
          is_active?: boolean
        }
      }
      goal_history: {
        Row: {
          id: string
          goal_id: string
          date: string
          value: number
          notes: string | null
          created_at: string
        }
        Insert: {
          id?: string
          goal_id: string
          date: string
          value: number
          notes?: string | null
          created_at?: string
        }
        Update: {
          id?: string
          goal_id?: string
          date?: string
          value?: number
          notes?: string | null
          created_at?: string
        }
      }
      user_progress: {
        Row: {
          id: string
          user_id: string
          total_steps: number
          current_streak: number
          longest_streak: number
          total_xp: number
          current_zone: string
          last_active_date: string
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          user_id: string
          total_steps?: number
          current_streak?: number
          longest_streak?: number
          total_xp?: number
          current_zone?: string
          last_active_date?: string
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          user_id?: string
          total_steps?: number
          current_streak?: number
          longest_streak?: number
          total_xp?: number
          current_zone?: string
          last_active_date?: string
          created_at?: string
          updated_at?: string
        }
      }
      progress_history: {
        Row: {
          id: string
          user_progress_id: string
          user_id: string
          date: string
          steps_completed: number
          xp_earned: number
          calories_burned: number
          tasks_completed: number
          zone: string | null
          notes: string | null
          created_at: string
        }
        Insert: {
          id?: string
          user_progress_id: string
          user_id: string
          date: string
          steps_completed?: number
          xp_earned?: number
          calories_burned?: number
          tasks_completed?: number
          zone?: string | null
          notes?: string | null
          created_at?: string
        }
        Update: {
          id?: string
          user_progress_id?: string
          user_id?: string
          date?: string
          steps_completed?: number
          xp_earned?: number
          calories_burned?: number
          tasks_completed?: number
          zone?: string | null
          notes?: string | null
          created_at?: string
        }
      }
      sphere_progress: {
        Row: {
          id: string
          user_progress_id: string
          user_id: string
          sphere_name: string
          progress_percentage: number
          updated_at: string
        }
        Insert: {
          id?: string
          user_progress_id: string
          user_id: string
          sphere_name: string
          progress_percentage?: number
          updated_at?: string
        }
        Update: {
          id?: string
          user_progress_id?: string
          user_id?: string
          sphere_name?: string
          progress_percentage?: number
          updated_at?: string
        }
      }
      exercises: {
        Row: {
          id: string
          name: string
          description: string | null
          icon: string | null
          difficulty: string
          category: string | null
          instructions: string[] | null
          tips: Json
          is_active: boolean
          created_at: string
        }
        Insert: {
          id: string
          name: string
          description?: string | null
          icon?: string | null
          difficulty?: string
          category?: string | null
          instructions?: string[] | null
          tips?: Json
          is_active?: boolean
          created_at?: string
        }
        Update: {
          id?: string
          name?: string
          description?: string | null
          icon?: string | null
          difficulty?: string
          category?: string | null
          instructions?: string[] | null
          tips?: Json
          is_active?: boolean
          created_at?: string
        }
      }
      workout_sessions: {
        Row: {
          id: string
          user_id: string
          start_time: string
          end_time: string | null
          status: string
          total_reps_completed: number
          average_quality: number
          duration: string | null
          calories_burned: number
          notes: string | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          user_id: string
          start_time: string
          end_time?: string | null
          status?: string
          total_reps_completed?: number
          average_quality?: number
          duration?: string | null
          calories_burned?: number
          notes?: string | null
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          user_id?: string
          start_time?: string
          end_time?: string | null
          status?: string
          total_reps_completed?: number
          average_quality?: number
          duration?: string | null
          calories_burned?: number
          notes?: string | null
          created_at?: string
          updated_at?: string
        }
      }
      workout_exercises: {
        Row: {
          id: string
          workout_session_id: string
          exercise_id: string
          target_reps: number
          completed_reps: number
          average_quality: number
          duration: string | null
          rest_time: string | null
          order_index: number
          notes: string | null
          created_at: string
        }
        Insert: {
          id?: string
          workout_session_id: string
          exercise_id: string
          target_reps: number
          completed_reps?: number
          average_quality?: number
          duration?: string | null
          rest_time?: string | null
          order_index: number
          notes?: string | null
          created_at?: string
        }
        Update: {
          id?: string
          workout_session_id?: string
          exercise_id?: string
          target_reps?: number
          completed_reps?: number
          average_quality?: number
          duration?: string | null
          rest_time?: string | null
          order_index?: number
          notes?: string | null
          created_at?: string
        }
      }
      tasks: {
        Row: {
          id: string
          user_id: string
          title: string
          description: string | null
          priority: string
          status: string
          due_date: string | null
          completed_at: string | null
          estimated_duration: string | null
          actual_duration: string | null
          tags: string[] | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          user_id: string
          title: string
          description?: string | null
          priority?: string
          status?: string
          due_date?: string | null
          completed_at?: string | null
          estimated_duration?: string | null
          actual_duration?: string | null
          tags?: string[] | null
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          user_id?: string
          title?: string
          description?: string | null
          priority?: string
          status?: string
          due_date?: string | null
          completed_at?: string | null
          estimated_duration?: string | null
          actual_duration?: string | null
          tags?: string[] | null
          created_at?: string
          updated_at?: string
        }
      }
      brotherhood_posts: {
        Row: {
          id: string
          user_id: string
          title: string | null
          content: string
          post_type: string
          media_url: string | null
          is_pinned: boolean
          is_featured: boolean
          likes_count: number
          comments_count: number
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          user_id: string
          title?: string | null
          content: string
          post_type?: string
          media_url?: string | null
          is_pinned?: boolean
          is_featured?: boolean
          likes_count?: number
          comments_count?: number
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          user_id?: string
          title?: string | null
          content?: string
          post_type?: string
          media_url?: string | null
          is_pinned?: boolean
          is_featured?: boolean
          likes_count?: number
          comments_count?: number
          created_at?: string
          updated_at?: string
        }
      }
      brotherhood_comments: {
        Row: {
          id: string
          post_id: string
          user_id: string
          parent_comment_id: string | null
          content: string
          likes_count: number
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          post_id: string
          user_id: string
          parent_comment_id?: string | null
          content: string
          likes_count?: number
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          post_id?: string
          user_id?: string
          parent_comment_id?: string | null
          content?: string
          likes_count?: number
          created_at?: string
          updated_at?: string
        }
      }
      brotherhood_likes: {
        Row: {
          id: string
          user_id: string
          post_id: string | null
          comment_id: string | null
          created_at: string
        }
        Insert: {
          id?: string
          user_id: string
          post_id?: string | null
          comment_id?: string | null
          created_at?: string
        }
        Update: {
          id?: string
          user_id?: string
          post_id?: string | null
          comment_id?: string | null
          created_at?: string
        }
      }
      user_achievements: {
        Row: {
          id: string
          user_id: string
          achievement_type: string
          title: string
          description: string | null
          icon: string | null
          xp_reward: number
          unlocked_at: string
        }
        Insert: {
          id?: string
          user_id: string
          achievement_type: string
          title: string
          description?: string | null
          icon?: string | null
          xp_reward?: number
          unlocked_at?: string
        }
        Update: {
          id?: string
          user_id?: string
          achievement_type?: string
          title?: string
          description?: string | null
          icon?: string | null
          xp_reward?: number
          unlocked_at?: string
        }
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      update_user_streak: {
        Args: {
          user_uuid: string
        }
        Returns: undefined
      }
      calculate_goal_progress: {
        Args: {
          goal_uuid: string
        }
        Returns: number
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}