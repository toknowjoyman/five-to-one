-- ================================================
-- Migration: Add Framework System Support
-- ================================================
-- This migration adds support for multiple framework plugins
-- Run this if you already have the items table created
-- ================================================

-- Add framework_ids column
ALTER TABLE items ADD COLUMN IF NOT EXISTS framework_ids TEXT[] DEFAULT '{}';

-- Add Time Blocking framework columns
ALTER TABLE items ADD COLUMN IF NOT EXISTS scheduled_for TIMESTAMP;
ALTER TABLE items ADD COLUMN IF NOT EXISTS duration_minutes INT;

-- Add Kanban framework columns
ALTER TABLE items ADD COLUMN IF NOT EXISTS kanban_column TEXT;
ALTER TABLE items ADD COLUMN IF NOT EXISTS column_position INT;

-- Add indexes for framework queries
CREATE INDEX IF NOT EXISTS idx_items_framework ON items USING GIN(framework_ids);
CREATE INDEX IF NOT EXISTS idx_items_scheduled ON items(scheduled_for) WHERE scheduled_for IS NOT NULL;

-- Update get_descendants function to include new fields
CREATE OR REPLACE FUNCTION get_descendants(item_uuid UUID)
RETURNS TABLE (
  id UUID,
  user_id UUID,
  parent_id UUID,
  title TEXT,
  "position" INT,
  framework_ids TEXT[],
  priority INT,
  is_avoided BOOLEAN,
  is_urgent BOOLEAN,
  is_important BOOLEAN,
  scheduled_for TIMESTAMP,
  duration_minutes INT,
  kanban_column TEXT,
  column_position INT,
  color TEXT,
  icon TEXT,
  completed_at TIMESTAMP,
  created_at TIMESTAMP,
  depth INT
) AS $$
  WITH RECURSIVE descendants AS (
    -- Base case: the item itself
    SELECT
      i.*,
      0 as depth
    FROM items i
    WHERE i.id = item_uuid

    UNION ALL

    -- Recursive case: children of descendants
    SELECT
      i.*,
      d.depth + 1
    FROM items i
    INNER JOIN descendants d ON i.parent_id = d.id
  )
  SELECT
    id, user_id, parent_id, title, position, framework_ids,
    priority, is_avoided, is_urgent, is_important,
    scheduled_for, duration_minutes, kanban_column, column_position,
    color, icon, completed_at, created_at, depth
  FROM descendants;
$$ LANGUAGE SQL STABLE;

-- Update get_ancestors function to include new fields
CREATE OR REPLACE FUNCTION get_ancestors(item_uuid UUID)
RETURNS TABLE (
  id UUID,
  user_id UUID,
  parent_id UUID,
  title TEXT,
  "position" INT,
  framework_ids TEXT[],
  priority INT,
  is_avoided BOOLEAN,
  is_urgent BOOLEAN,
  is_important BOOLEAN,
  scheduled_for TIMESTAMP,
  duration_minutes INT,
  kanban_column TEXT,
  column_position INT,
  color TEXT,
  icon TEXT,
  completed_at TIMESTAMP,
  created_at TIMESTAMP,
  depth INT
) AS $$
  WITH RECURSIVE ancestors AS (
    -- Base case: the item itself
    SELECT
      i.*,
      0 as depth
    FROM items i
    WHERE i.id = item_uuid

    UNION ALL

    -- Recursive case: parent of ancestors
    SELECT
      i.*,
      a.depth - 1
    FROM items i
    INNER JOIN ancestors a ON i.id = a.parent_id
  )
  SELECT
    id, user_id, parent_id, title, position, framework_ids,
    priority, is_avoided, is_urgent, is_important,
    scheduled_for, duration_minutes, kanban_column, column_position,
    color, icon, completed_at, created_at, depth
  FROM ancestors
  ORDER BY depth DESC;
$$ LANGUAGE SQL STABLE;
