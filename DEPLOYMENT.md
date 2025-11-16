# Deployment Guide - Five to One

This guide will help you deploy your Five to One app to Render.io so your test users can access it via a web browser on their phones.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Local Setup](#local-setup)
3. [Supabase Setup](#supabase-setup)
4. [Deploying to Render.io](#deploying-to-renderio)
5. [Setting Up Admin Access](#setting-up-admin-access)
6. [Accessing the App](#accessing-the-app)
7. [Troubleshooting](#troubleshooting)

---

## Prerequisites

Before deploying, ensure you have:

- **Flutter SDK** installed (version 3.0.0 or higher)
- **Git** installed
- **Supabase account** (free tier is fine)
- **Render.io account** (free tier is fine)
- **GitHub account** (to connect your repository to Render)

---

## Local Setup

### 1. Enable Flutter Web Support

Run the provided script to enable web support:

```bash
cd /path/to/five-to-one
chmod +x scripts/enable_web.sh
./scripts/enable_web.sh
```

Or manually:

```bash
cd five_to_one_mobile
flutter config --enable-web
flutter create --platforms=web .
```

### 2. Test Locally

```bash
cd five_to_one_mobile
flutter run -d chrome
```

Your app should open in Chrome. Test the basic functionality to ensure everything works.

---

## Supabase Setup

### 1. Create a Supabase Project

1. Go to [https://app.supabase.com](https://app.supabase.com)
2. Click "New Project"
3. Fill in the project details
4. Wait for the project to be created

### 2. Run Database Migrations

In your Supabase project:

1. Go to **SQL Editor**
2. Copy the contents of `five_to_one_mobile/supabase_schema.sql`
3. Paste and run it
4. Copy the contents of `five_to_one_mobile/supabase_feedback_schema.sql`
5. Paste and run it

### 3. Get Your Supabase Credentials

1. Go to **Settings** → **API**
2. Copy:
   - **Project URL** (e.g., `https://xxxxx.supabase.co`)
   - **anon/public key** (starts with `eyJ...`)

You'll need these for Render.io deployment.

---

## Deploying to Render.io

### 1. Push Your Code to GitHub

Ensure your latest changes are committed and pushed:

```bash
git add .
git commit -m "Add Render.io deployment configuration and feedback system"
git push origin main
```

### 2. Create a New Web Service on Render

1. Go to [https://dashboard.render.com](https://dashboard.render.com)
2. Click **New** → **Web Service**
3. Connect your GitHub repository
4. Select the `five-to-one` repository

### 3. Configure the Web Service

Use these settings:

- **Name**: `five-to-one-app` (or any name you prefer)
- **Region**: Choose the closest to your users
- **Branch**: `main` (or your deployment branch)
- **Runtime**: Docker
- **Plan**: Free

### 4. Environment Variables

In the **Environment** section, add:

| Key | Value |
|-----|-------|
| `SUPABASE_URL` | Your Supabase project URL |
| `SUPABASE_ANON_KEY` | Your Supabase anon key |

**Important**: Click "Save Changes" after adding each variable.

### 5. Deploy

Click **Create Web Service**. Render will:

1. Clone your repository
2. Build the Docker image
3. Build the Flutter web app
4. Deploy it

This process takes 5-10 minutes for the first deployment.

### 6. Get Your App URL

Once deployed, you'll get a URL like:

```
https://five-to-one-app.onrender.com
```

Share this URL with your test users!

---

## Setting Up Admin Access

To manage feedback, you need to set up admin access for yourself.

### 1. Sign Up in Your App

1. Open your deployed app
2. Create an account with your email
3. Note down your email address

### 2. Set Admin Flag in Supabase

1. Go to your Supabase project
2. Navigate to **Authentication** → **Users**
3. Find your user account
4. Click on the user
5. Go to **Raw User Meta Data** section
6. Click **Edit**
7. Add this JSON:

```json
{
  "is_admin": true
}
```

8. Click **Save**

### 3. Verify Admin Access

1. Log out and log back in to your app
2. Go to **Settings**
3. You should now see **Admin Dashboard** option
4. Click it to access the feedback management interface

---

## Accessing the App

### For Test Users

Share the Render.io URL with your test users:

```
https://five-to-one-app.onrender.com
```

Users can:
- Open the app in their mobile browser
- Sign up with email or use anonymously
- Create tasks and use frameworks
- **Submit feedback** via Settings → Send Feedback

### For You (Admin)

Access the admin dashboard:

1. Open the app
2. Log in with your admin account
3. Go to **Settings** → **Admin Dashboard**

Here you can:
- **View all feedback** from users
- **Filter by status, category, priority**
- **Update feedback status** (new → in progress → completed)
- **Change priority levels**
- **Add admin notes** to respond to users
- **View statistics** about feedback

---

## Feedback System Features

### For Users

1. **Send Feedback**:
   - Go to Settings → Send Feedback
   - Choose category: Bug, Feature Request, Improvement, or Other
   - Provide title and description
   - Optionally include email for follow-up

2. **View My Feedback**:
   - Go to Settings → My Feedback
   - See all your submitted feedback
   - Check status (New, In Progress, Completed)
   - Read admin responses

### For Admins

1. **Feedback Dashboard**:
   - View all user feedback in one place
   - Filter and sort by various criteria
   - See real-time statistics

2. **Triage and Prioritize**:
   - Set priority: Low, Medium, High, Critical
   - Update status as you work on issues
   - Add notes for users

3. **Statistics Tab**:
   - Total feedback count
   - Breakdown by status
   - Breakdown by category
   - Critical issues count

---

## Updating Your App

When you make changes and want to deploy:

1. **Commit and push** your changes:
   ```bash
   git add .
   git commit -m "Your change description"
   git push origin main
   ```

2. **Render auto-deploys**: If you enabled auto-deploy, Render will automatically rebuild and deploy your app.

3. **Manual deploy**: If auto-deploy is off, go to Render dashboard and click "Manual Deploy" → "Deploy latest commit"

---

## Troubleshooting

### App Won't Build

**Check Flutter version**:
- Ensure you're using Flutter 3.0.0 or higher
- Check the Dockerfile uses the correct Flutter version

**Check dependencies**:
- Run `flutter pub get` locally to ensure all dependencies are available

### Environment Variables Not Working

**Verify in Render**:
1. Go to your web service in Render
2. Click **Environment**
3. Ensure `SUPABASE_URL` and `SUPABASE_ANON_KEY` are set correctly
4. Redeploy after adding variables

**Check for typos**:
- Variable names are case-sensitive
- Ensure no extra spaces

### Feedback Not Saving

**Check Supabase**:
1. Ensure you ran both migration files:
   - `supabase_schema.sql`
   - `supabase_feedback_schema.sql`
2. Go to **Table Editor** in Supabase
3. Verify the `feedback` table exists

**Check permissions**:
- The feedback table has Row Level Security enabled
- Users should be able to insert their own feedback
- Check the Supabase logs for any permission errors

### Admin Dashboard Not Showing

**Verify admin flag**:
1. Go to Supabase → Authentication → Users
2. Find your user
3. Check Raw User Meta Data has `"is_admin": true`
4. Log out and log back in

### App Is Slow on Mobile

**Use production build**:
- Ensure the Dockerfile uses `flutter build web --release`
- The `--web-renderer canvaskit` flag provides better performance

**Check network**:
- Render's free tier may spin down after inactivity
- First load after inactivity takes 30-60 seconds

### CORS Errors

If you see CORS errors:
1. Go to Supabase → Settings → API
2. Check that your Render URL is allowed
3. Supabase allows all origins by default, so this shouldn't be an issue

---

## Cost Breakdown

### Free Tier Limits

**Supabase (Free)**:
- 500 MB database
- 1 GB file storage
- 2 GB bandwidth per month
- Should be plenty for testing!

**Render (Free)**:
- 750 hours/month of running time
- Spins down after 15 minutes of inactivity
- Restarts when someone accesses it
- Slow restart (~30-60 seconds)

### Upgrading

If your app gets popular:

**Supabase Pro** ($25/month):
- 8 GB database
- 100 GB file storage
- 50 GB bandwidth

**Render Starter** ($7/month):
- Always on (no spin down)
- Faster restarts
- Better performance

---

## Next Steps

1. **Collect Feedback**: Share the app URL with test users
2. **Monitor Feedback**: Check the admin dashboard regularly
3. **Prioritize Issues**: Triage bugs and feature requests
4. **Iterate**: Fix issues and deploy updates
5. **Communicate**: Use admin notes to respond to users

---

## Additional Resources

- [Flutter Web Documentation](https://docs.flutter.dev/platform-integration/web)
- [Supabase Documentation](https://supabase.com/docs)
- [Render Documentation](https://render.com/docs)

---

## Support

If you encounter issues:

1. **Check the logs** in Render dashboard
2. **Check Supabase logs** for database errors
3. **Test locally** first to isolate deployment issues
4. **Consult the troubleshooting section** above

Good luck with your deployment! 🚀
