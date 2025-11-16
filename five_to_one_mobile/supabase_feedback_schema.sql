-- Feedback Collection System for Five-to-One App
-- Run this migration in your Supabase SQL Editor

-- Create feedback table
CREATE TABLE IF NOT EXISTS feedback (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT, -- Optional: capture email even for non-authenticated users
  category TEXT NOT NULL CHECK (category IN ('bug', 'feature', 'improvement', 'other')),
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  screenshot_url TEXT, -- Optional: URL to uploaded screenshot
  device_info JSONB, -- Store device/browser info
  app_version TEXT,
  status TEXT NOT NULL DEFAULT 'new' CHECK (status IN ('new', 'in_progress', 'completed', 'archived')),
  priority TEXT DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'critical')),
  admin_notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_feedback_user_id ON feedback(user_id);
CREATE INDEX IF NOT EXISTS idx_feedback_status ON feedback(status);
CREATE INDEX IF NOT EXISTS idx_feedback_category ON feedback(category);
CREATE INDEX IF NOT EXISTS idx_feedback_created_at ON feedback(created_at DESC);

-- Enable Row Level Security
ALTER TABLE feedback ENABLE ROW LEVEL SECURITY;

-- Policy: Users can insert their own feedback (or anonymous feedback)
CREATE POLICY "Users can submit feedback"
  ON feedback
  FOR INSERT
  TO authenticated, anon
  WITH CHECK (
    -- Authenticated users can submit with their user_id
    (auth.uid() IS NOT NULL AND user_id = auth.uid())
    OR
    -- Anonymous users can submit without user_id
    (auth.uid() IS NULL AND user_id IS NULL)
  );

-- Policy: Users can view their own feedback
CREATE POLICY "Users can view their own feedback"
  ON feedback
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

-- Policy: Anonymous users can view their own submissions (within same session)
-- Note: This is limited - consider storing a session identifier if needed
CREATE POLICY "Anonymous users can view feedback"
  ON feedback
  FOR SELECT
  TO anon
  USING (user_id IS NULL);

-- Policy: Admin users can view all feedback
-- First, create an admin role check function
CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  -- Check if the user has an admin flag in their user metadata
  -- You'll need to set this manually in Supabase Auth for admin users
  RETURN (
    SELECT COALESCE(
      (auth.jwt() -> 'user_metadata' ->> 'is_admin')::boolean,
      false
    )
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Policy: Admins can view all feedback
CREATE POLICY "Admins can view all feedback"
  ON feedback
  FOR SELECT
  TO authenticated
  USING (is_admin());

-- Policy: Admins can update feedback (status, priority, notes)
CREATE POLICY "Admins can update feedback"
  ON feedback
  FOR UPDATE
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- Function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_feedback_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update updated_at on feedback updates
DROP TRIGGER IF EXISTS feedback_updated_at_trigger ON feedback;
CREATE TRIGGER feedback_updated_at_trigger
  BEFORE UPDATE ON feedback
  FOR EACH ROW
  EXECUTE FUNCTION update_feedback_updated_at();

-- Create a view for feedback statistics (admin only)
CREATE OR REPLACE VIEW feedback_stats AS
SELECT
  COUNT(*) as total_feedback,
  COUNT(*) FILTER (WHERE status = 'new') as new_count,
  COUNT(*) FILTER (WHERE status = 'in_progress') as in_progress_count,
  COUNT(*) FILTER (WHERE status = 'completed') as completed_count,
  COUNT(*) FILTER (WHERE category = 'bug') as bug_count,
  COUNT(*) FILTER (WHERE category = 'feature') as feature_count,
  COUNT(*) FILTER (WHERE category = 'improvement') as improvement_count,
  COUNT(*) FILTER (WHERE priority = 'critical') as critical_count,
  COUNT(*) FILTER (WHERE priority = 'high') as high_count,
  COUNT(DISTINCT user_id) as unique_users,
  MAX(created_at) as last_feedback_at
FROM feedback;

-- Grant access to feedback_stats view for admins
GRANT SELECT ON feedback_stats TO authenticated;

-- Create RLS policy for the stats view
ALTER VIEW feedback_stats SET (security_invoker = true);

COMMENT ON TABLE feedback IS 'User feedback and bug reports for the Five-to-One app';
COMMENT ON COLUMN feedback.category IS 'Type of feedback: bug, feature request, improvement, or other';
COMMENT ON COLUMN feedback.status IS 'Current status: new, in_progress, completed, or archived';
COMMENT ON COLUMN feedback.priority IS 'Priority level set by admins: low, medium, high, or critical';
COMMENT ON COLUMN feedback.device_info IS 'JSON object containing device/browser information for debugging';
