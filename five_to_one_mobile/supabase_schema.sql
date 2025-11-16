-- ================================================
-- Five-to-One: Unified Fractal Schema
-- ================================================
-- One table, infinite depth. Life areas, goals, tasks, and subtasks
-- all use the same self-referential structure.
--
-- Hierarchy Examples:
--
-- V1 (No Life Areas):
--   Item (parent_id = NULL) = Goal
--     └─ Item (parent_id = goal_id) = Task
--         └─ Item (parent_id = task_id) = Subtask
--             └─ Item (parent_id = subtask_id) = Sub-subtask...
--
-- V2 (With Life Areas):
--   Item (parent_id = NULL) = Life Area
--     └─ Item (parent_id = life_area_id) = Goal
--         └─ Item (parent_id = goal_id) = Task
--             └─ Item (parent_id = task_id) = Subtask...
-- ================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Main items table (fractal structure)
CREATE TABLE items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  parent_id UUID REFERENCES items(id) ON DELETE CASCADE,

  -- Core fields (used at all levels)
  title TEXT NOT NULL,
  position INT DEFAULT 0,

  -- Optional metadata (used at different hierarchy levels)
  priority INT,           -- Used for goals: 1-5 for top priorities, NULL for avoid list
  is_avoided BOOLEAN DEFAULT FALSE,  -- Used for goals: true for the 20 avoided items
  is_urgent BOOLEAN DEFAULT FALSE,   -- Used for tasks: Eisenhower matrix
  is_important BOOLEAN DEFAULT FALSE, -- Used for tasks: Eisenhower matrix
  color TEXT,             -- Used for life areas (V2): hex color code
  icon TEXT,              -- Used for life areas (V2): icon identifier

  -- Timestamps
  completed_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_items_user ON items(user_id);
CREATE INDEX idx_items_parent ON items(parent_id);
CREATE INDEX idx_items_priority ON items(priority) WHERE priority IS NOT NULL;
CREATE INDEX idx_items_completed ON items(completed_at) WHERE completed_at IS NOT NULL;

-- Updated timestamp trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_items_updated_at BEFORE UPDATE ON items
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Row-level security (users can only see their own data)
ALTER TABLE items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own items" ON items
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own items" ON items
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own items" ON items
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own items" ON items
  FOR DELETE USING (auth.uid() = user_id);

-- ================================================
-- Helper Functions
-- ================================================

-- Get all descendants of an item (recursive)
CREATE OR REPLACE FUNCTION get_descendants(item_uuid UUID)
RETURNS TABLE (
  id UUID,
  user_id UUID,
  parent_id UUID,
  title TEXT,
  position INT,
  priority INT,
  is_avoided BOOLEAN,
  is_urgent BOOLEAN,
  is_important BOOLEAN,
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
    id, user_id, parent_id, title, position,
    priority, is_avoided, is_urgent, is_important,
    color, icon, completed_at, created_at, depth
  FROM descendants;
$$ LANGUAGE SQL STABLE;

-- Get all ancestors of an item (recursive)
CREATE OR REPLACE FUNCTION get_ancestors(item_uuid UUID)
RETURNS TABLE (
  id UUID,
  user_id UUID,
  parent_id UUID,
  title TEXT,
  position INT,
  priority INT,
  is_avoided BOOLEAN,
  is_urgent BOOLEAN,
  is_important BOOLEAN,
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
    id, user_id, parent_id, title, position,
    priority, is_avoided, is_urgent, is_important,
    color, icon, completed_at, created_at, depth
  FROM ancestors
  ORDER BY depth DESC;
$$ LANGUAGE SQL STABLE;

-- ================================================
-- Example Queries
-- ================================================

-- V1: Get all root goals (no life areas)
-- SELECT * FROM items WHERE parent_id IS NULL AND user_id = 'user_uuid';

-- V1: Get top 5 goals
-- SELECT * FROM items
-- WHERE parent_id IS NULL
--   AND priority IS NOT NULL
--   AND user_id = 'user_uuid'
-- ORDER BY priority
-- LIMIT 5;

-- V1: Get avoid list (the 20)
-- SELECT * FROM items
-- WHERE parent_id IS NULL
--   AND is_avoided = TRUE
--   AND user_id = 'user_uuid';

-- V2: Get all life areas
-- SELECT * FROM items WHERE parent_id IS NULL AND user_id = 'user_uuid';

-- V2: Get goals for a specific life area
-- SELECT * FROM items WHERE parent_id = 'life_area_uuid';

-- Get all tasks for a goal
-- SELECT * FROM items WHERE parent_id = 'goal_uuid';

-- Get entire tree under an item
-- SELECT * FROM get_descendants('item_uuid');

-- Get breadcrumb path to an item
-- SELECT * FROM get_ancestors('item_uuid');
