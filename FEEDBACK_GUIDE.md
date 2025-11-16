# Feedback Collection & Management Guide

This guide explains how to collect, collate, and action user feedback for the Five to One app.

## Table of Contents

1. [Overview](#overview)
2. [Collecting Feedback](#collecting-feedback)
3. [Accessing Feedback](#accessing-feedback)
4. [Organizing Feedback](#organizing-feedback)
5. [Actioning Feedback](#actioning-feedback)
6. [Best Practices](#best-practices)
7. [Feedback Workflow](#feedback-workflow)

---

## Overview

The feedback system allows you to:

- **Collect** feedback from users directly in the app
- **Categorize** feedback by type (bug, feature, improvement)
- **Prioritize** based on importance and urgency
- **Track** progress through different statuses
- **Respond** to users with admin notes
- **Analyze** trends with statistics dashboard

---

## Collecting Feedback

### User Experience

Users can submit feedback in two ways:

#### 1. Send Feedback (Settings)
- Navigate to **Settings** → **Send Feedback**
- Choose a category:
  - **Bug Report**: Technical issues or errors
  - **Feature Request**: New functionality suggestions
  - **Improvement**: Enhancements to existing features
  - **Other**: General feedback
- Provide a title and detailed description
- Optionally include email for follow-up

#### 2. My Feedback (Settings)
- Navigate to **Settings** → **My Feedback**
- View all previously submitted feedback
- See current status and admin responses
- Submit new feedback from the floating action button

### What Gets Collected

For each feedback submission, the system automatically captures:

- **User information**: User ID (if logged in), optional email
- **Feedback content**: Category, title, description
- **Device information**: Platform (web, iOS, Android), OS version
- **App version**: For debugging purposes
- **Timestamp**: When the feedback was submitted

---

## Accessing Feedback

### Admin Dashboard

1. **Enable Admin Access** (see DEPLOYMENT.md)
   - Add `"is_admin": true` to your user metadata in Supabase

2. **Access the Dashboard**
   - Open the app
   - Go to **Settings** → **Admin Dashboard**

3. **Two Main Tabs**:
   - **Feedback Tab**: View and manage all feedback
   - **Statistics Tab**: See aggregated metrics

### Direct Database Access

For advanced analysis, you can query Supabase directly:

1. Go to your Supabase project
2. Navigate to **Table Editor** → **feedback**
3. View, filter, and export data
4. Use **SQL Editor** for custom queries

Example SQL for exporting critical bugs:

```sql
SELECT
  created_at,
  title,
  description,
  email,
  device_info
FROM feedback
WHERE category = 'bug'
  AND priority = 'critical'
  AND status != 'completed'
ORDER BY created_at DESC;
```

---

## Organizing Feedback

### Filtering

In the Admin Dashboard, you can filter feedback by:

- **Status**: New, In Progress, Completed, Archived
- **Category**: Bug, Feature, Improvement, Other
- **Priority**: Low, Medium, High, Critical

### Categories Explained

| Category | Use Case | Example |
|----------|----------|---------|
| **Bug** | Technical issues, errors, crashes | "App crashes when adding subtasks" |
| **Feature** | New functionality requests | "Add ability to export tasks to CSV" |
| **Improvement** | Enhancements to existing features | "Make the priority selector easier to use" |
| **Other** | General feedback, questions | "Love the app! Great work!" |

### Priority Levels

| Priority | When to Use | Response Time |
|----------|-------------|---------------|
| **Critical** | App-breaking bugs, data loss | Immediate (same day) |
| **High** | Significant issues affecting many users | 1-2 days |
| **Medium** | Normal bugs or useful features | 3-7 days |
| **Low** | Minor issues or nice-to-have features | When time permits |

### Status Workflow

| Status | Meaning | Next Steps |
|--------|---------|------------|
| **New** | Just submitted, not reviewed | Triage and assign priority |
| **In Progress** | Actively working on it | Development in progress |
| **Completed** | Fixed/implemented | Verify and notify user |
| **Archived** | Won't fix or duplicate | Document reason in notes |

---

## Actioning Feedback

### Step-by-Step Process

#### 1. Review New Feedback Daily

Set aside 10-15 minutes daily to:
- Check the "New" filter
- Read each submission
- Categorize and prioritize

#### 2. Triage and Prioritize

For each feedback item:

1. **Assess severity**:
   - Is it blocking users?
   - How many users are affected?
   - Is there a workaround?

2. **Set priority**:
   - Tap the feedback card
   - Select appropriate priority level
   - Add initial admin notes if needed

3. **Update status**:
   - If you'll work on it soon: **In Progress**
   - If it's a duplicate or won't fix: **Archived**

#### 3. Work on Issues

When fixing a bug or implementing a feature:

1. **Update status** to "In Progress"
2. **Add notes** about what you're working on
3. **Link to related issues** if applicable

Example admin note:
```
Working on this now. Fix will be included in v1.1 release next week.
```

#### 4. Close and Communicate

After resolving:

1. **Update status** to "Completed"
2. **Add closing note** explaining the resolution
3. **Deploy the fix**

Example closing note:
```
Fixed in v1.1! The app now correctly saves subtasks when editing tasks.
Thanks for reporting this!
```

### Using Admin Notes Effectively

Good admin notes are:

- **Specific**: "Fixed the crash when adding subtasks"
- **Helpful**: "This will be available in the next update"
- **Appreciative**: "Great suggestion! Thanks for the feedback"

Example responses:

**For bugs**:
```
Thanks for reporting! We've identified the issue and are working on a fix.
You can expect it in the next update (approx. 3-5 days).
```

**For features**:
```
Great idea! We're adding this to our roadmap for Q2.
We'll update you when development begins.
```

**For duplicates**:
```
Thanks for the feedback! This is a duplicate of issue #42,
which we're currently working on.
```

---

## Best Practices

### Daily Routine

**Morning (5 minutes)**:
- Check statistics dashboard
- Note any critical issues
- Respond to urgent feedback

**Afternoon (10 minutes)**:
- Triage new feedback
- Update in-progress items
- Close completed items

### Weekly Review

**Every Monday**:
- Review all "In Progress" items
- Update priorities based on trends
- Plan week's development focus

**Every Friday**:
- Close completed items
- Archive outdated feedback
- Send summary to team if applicable

### Monthly Analysis

Use the statistics tab to:

1. **Identify trends**:
   - Are bug reports increasing?
   - What features are most requested?
   - Which categories dominate?

2. **Measure progress**:
   - Completion rate
   - Average time to resolution
   - User engagement with feedback

3. **Plan roadmap**:
   - Prioritize most-requested features
   - Address common pain points
   - Celebrate wins with users

### Communication Tips

**Be transparent**:
- Set realistic expectations
- Explain technical limitations when needed
- Update users even if there's no progress

**Be appreciative**:
- Thank users for taking time to provide feedback
- Acknowledge good ideas
- Celebrate power users who provide detailed reports

**Be human**:
- Use friendly, conversational language
- Show personality
- Don't be afraid to say "we messed up" when appropriate

---

## Feedback Workflow

### Flowchart

```
New Feedback Submitted
        ↓
    [Triage]
        ↓
   ┌────┴────┐
   ↓         ↓
Critical   Normal
   ↓         ↓
  [Fix    [Prioritize]
  ASAP]      ↓
   ↓     [Add to Sprint]
   └──→ [In Progress]
           ↓
       [Develop]
           ↓
        [Test]
           ↓
       [Deploy]
           ↓
      [Complete]
           ↓
   [Notify User]
```

### Example Scenarios

#### Scenario 1: Critical Bug

**Feedback**: "App crashes every time I try to add a subtask"

**Action**:
1. ✅ Set priority to "Critical"
2. ✅ Update status to "In Progress"
3. ✅ Add note: "Investigating now. Will have a fix within 24 hours."
4. ✅ Reproduce and fix the bug
5. ✅ Deploy hotfix
6. ✅ Update status to "Completed"
7. ✅ Add note: "Fixed in v1.0.1! Thanks for the detailed report."

**Timeline**: Same day

#### Scenario 2: Feature Request

**Feedback**: "Would love to see dark mode support"

**Action**:
1. ✅ Keep priority as "Medium"
2. ✅ Add note: "Great suggestion! Added to our roadmap for Q2."
3. ✅ Track in separate project management tool
4. ✅ Update status to "In Progress" when development starts
5. ✅ Update status to "Completed" when shipped
6. ✅ Add note: "Dark mode is now live! Check Settings to enable it."

**Timeline**: 4-6 weeks

#### Scenario 3: User Confusion

**Feedback**: "I don't understand how the priority system works"

**Action**:
1. ✅ Set priority to "High" (indicates UX problem)
2. ✅ Add note: "Thanks for the feedback! The priority system ranks items 1-5..."
3. ✅ Consider adding in-app help
4. ✅ Update status to "In Progress" while improving UX
5. ✅ Update status to "Completed" after adding tooltips/help

**Timeline**: 1-2 weeks

---

## Analytics & Reporting

### Using Supabase for Analysis

#### Export to CSV

1. Go to Supabase → Table Editor → feedback
2. Click "Export" → CSV
3. Open in Excel/Google Sheets for analysis

#### Custom Queries

**Most requested features**:
```sql
SELECT
  title,
  COUNT(*) as request_count
FROM feedback
WHERE category = 'feature'
GROUP BY title
ORDER BY request_count DESC
LIMIT 10;
```

**Average resolution time**:
```sql
SELECT
  AVG(completed_at - created_at) as avg_resolution_time
FROM feedback
WHERE status = 'completed';
```

**Feedback by date**:
```sql
SELECT
  DATE(created_at) as date,
  COUNT(*) as feedback_count
FROM feedback
GROUP BY DATE(created_at)
ORDER BY date DESC;
```

### Visualizations

Consider creating dashboards with:
- **Metabase** (open-source)
- **Google Data Studio** (free)
- **Tableau** (paid)

Connect to your Supabase PostgreSQL database and create:
- Feedback volume over time
- Category breakdown pie chart
- Status funnel
- Priority distribution

---

## Automation Ideas

### Supabase Database Functions

Create triggers for auto-responses:

```sql
-- Auto-prioritize critical keywords
CREATE OR REPLACE FUNCTION auto_prioritize_critical()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.description ILIKE '%crash%' OR
     NEW.description ILIKE '%data loss%' OR
     NEW.description ILIKE '%can''t login%' THEN
    NEW.priority = 'critical';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_auto_prioritize
  BEFORE INSERT ON feedback
  FOR EACH ROW
  EXECUTE FUNCTION auto_prioritize_critical();
```

### Email Notifications

Set up Supabase Edge Functions to:
- Email you when critical feedback is submitted
- Send weekly digests
- Notify users when their feedback is completed

### Slack Integration

Use Supabase webhooks to post to Slack:
- New critical bugs
- Milestone achievements (100 feedback items!)
- Weekly summaries

---

## Conclusion

A good feedback system is about:

1. **Listening**: Make it easy for users to share
2. **Organizing**: Keep feedback structured and searchable
3. **Acting**: Fix issues and implement features
4. **Communicating**: Keep users informed

The Five to One feedback system gives you all the tools to do this effectively. Use this guide to establish a routine that works for you and your users!

Happy feedback management! 📊✨
