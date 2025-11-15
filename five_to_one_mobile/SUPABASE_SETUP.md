# Supabase Setup Guide

This guide will help you set up Supabase as the backend for Five-to-One.

## Step 1: Create Supabase Project

1. **Go to [supabase.com](https://supabase.com)**
2. **Sign up** or log in
3. **Create a new project**
   - Click "New Project"
   - Organization: Select or create one
   - Name: `five-to-one`
   - Database Password: **Save this somewhere safe!** (e.g., `YourSecurePassword123!`)
   - Region: Choose closest to you (e.g., `US West`)
   - Pricing plan: Free tier is fine
   - Click "Create new project"

Wait 1-2 minutes for the project to provision.

---

## Step 2: Run Database Schema

1. **Open SQL Editor**
   - In your Supabase project dashboard
   - Click "SQL Editor" in the left sidebar
   - Click "New query"

2. **Copy and paste the entire schema**
   - Open `/five_to_one_mobile/supabase_schema.sql`
   - Copy all contents
   - Paste into the SQL Editor

3. **Run the query**
   - Click "Run" (or press Cmd/Ctrl + Enter)
   - You should see: `Success. No rows returned`

4. **Verify tables were created**
   - Click "Table Editor" in the left sidebar
   - You should see the `items` table

---

## Step 3: Get API Credentials

1. **Go to Settings → API**
   - Click the gear icon (⚙️) in the left sidebar
   - Click "API" under "Project Settings"

2. **Copy these values:**
   - **Project URL**: `https://xxxxxxxxxxxxx.supabase.co`
   - **anon public key**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...` (long string)

3. **Keep these safe** - you'll add them to your Flutter app next

---

## Step 4: Configure Flutter App

1. **Create environment file**

Create `lib/config/supabase_config.dart`:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'YOUR_PROJECT_URL_HERE';
  static const String supabaseAnonKey = 'YOUR_ANON_KEY_HERE';
}
```

**Replace with your actual values from Step 3!**

⚠️ **Security Note**: For production, use environment variables or Flutter's `--dart-define`. For now, this is fine for development.

2. **Add to .gitignore** (if making repo public)

Add to `/five_to_one_mobile/.gitignore`:
```
lib/config/supabase_config.dart
```

Create a template file `lib/config/supabase_config.example.dart`:
```dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://YOUR_PROJECT.supabase.co';
  static const String supabaseAnonKey = 'YOUR_ANON_KEY_HERE';
}
```

---

## Step 5: Enable Email Authentication

1. **Go to Authentication → Providers**
   - Click "Authentication" in left sidebar
   - Click "Providers" tab

2. **Enable Email provider**
   - Email is enabled by default
   - Optionally disable "Confirm email" for easier testing
     - Scroll to "Email" provider settings
     - Turn OFF "Enable email confirmations" (for development only!)

3. **Optional: Set up email templates**
   - Click "Email Templates" tab
   - Customize welcome/confirmation emails (optional)

---

## Step 6: Test the Connection

After running the Flutter app with Supabase configured:

1. **Check Authentication**
   - Go to Authentication → Users in Supabase dashboard
   - You should see users appear when they sign up

2. **Check Data**
   - Go to Table Editor → items
   - You should see items appear when created in the app

3. **Check Logs** (if issues)
   - Go to Logs → API
   - See real-time API requests

---

## Troubleshooting

### "Invalid API key"
- Double-check you copied the **anon** key, not the service_role key
- Make sure there are no extra spaces

### "relation 'items' does not exist"
- The SQL schema didn't run successfully
- Go back to Step 2 and run it again
- Check for any error messages in the SQL Editor

### "Row Level Security policy violation"
- Make sure you're logged in (authenticated)
- Check that RLS policies were created in the schema

### "CORS error" (web only)
- Supabase allows all origins by default
- If you have issues, go to Settings → API → CORS
- Add your localhost URL

---

## Next Steps

After setup is complete:

1. ✅ Flutter app will initialize Supabase on startup
2. ✅ Users can sign up/login
3. ✅ Goals and tasks save to database
4. ✅ Data persists across sessions
5. ✅ Sync across devices (if same user)

---

## Useful Supabase Dashboard Features

- **Table Editor**: View/edit data directly
- **Authentication**: Manage users
- **SQL Editor**: Run queries
- **Logs**: Debug API calls
- **Storage**: Add file uploads later (optional)

---

## Database Schema Summary

Our `items` table supports:

**V1 (Current)**:
```
Items (parent_id = NULL) = Goals
  └─ Items (parent_id = goal_id) = Tasks
      └─ Items (parent_id = task_id) = Subtasks...
```

**V2 (Future)**:
```
Items (parent_id = NULL) = Life Areas
  └─ Items (parent_id = area_id) = Goals
      └─ Items (parent_id = goal_id) = Tasks...
```

See [FRACTAL_SCHEMA.md](FRACTAL_SCHEMA.md) for details.

---

## Security Notes

- ✅ Row Level Security (RLS) is enabled
- ✅ Users can only see their own data
- ✅ Auth required for all operations
- ✅ `anon` key is safe for client-side use
- ❌ **Never** commit your `service_role` key to git!

---

Ready to proceed? The Flutter code is already set up to use Supabase!
