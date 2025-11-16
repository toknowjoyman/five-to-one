# Deployment Guide - Five to One

This comprehensive guide will help you deploy your Five to One app to Render.io with Canny feedback integration.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Local Setup](#local-setup)
3. [Supabase Setup](#supabase-setup)
4. [Canny Setup](#canny-setup)
5. [Deploying to Render.io](#deploying-to-renderio)
6. [Accessing the App](#accessing-the-app)
7. [Troubleshooting](#troubleshooting)

---

## Prerequisites

Before deploying, ensure you have:

- **Flutter SDK** installed (version 3.0.0 or higher)
- **Git** installed
- **Supabase account** (free tier): https://supabase.com
- **Canny account** (free tier): https://canny.io
- **Render.io account** (free tier): https://render.com
- **GitHub account**

---

## Local Setup

### 1. Enable Flutter Web Support

Run the provided script:

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

Your app should open in Chrome. Test the basic functionality.

---

## Supabase Setup

### 1. Create a Supabase Project

1. Go to https://app.supabase.com
2. Click "New Project"
3. Fill in the project details
4. Wait for the project to be created

### 2. Run Database Migration

In your Supabase project:

1. Go to **SQL Editor**
2. Copy the contents of `five_to_one_mobile/supabase_schema.sql`
3. Paste and run it

### 3. Get Your Supabase Credentials

1. Go to **Settings** → **API**
2. Copy:
   - **Project URL** (e.g., `https://xxxxx.supabase.co`)
   - **anon/public key** (starts with `eyJ...`)

Save these for Render.io deployment.

---

## Canny Setup

Canny is used for collecting and managing user feedback. It's much simpler than managing a custom feedback system!

### 1. Create a Canny Account

1. Go to https://canny.io
2. Sign up for a free account
3. Create your company (use your app name)

### 2. Create a Feedback Board

1. Go to **Settings** → **Boards**
2. Click **Create Board**
3. Name it "Feedback" (or your preference)
4. Choose board type: **Feature Requests**
5. Click **Create**

### 3. Configure Board Settings

1. Go to your board → **Settings**
2. Set privacy to **Public** (users don't need to log in)
3. Enable **Voting** (let users vote on features)
4. Enable **Status labels** (New, Planned, In Progress, Complete)

Optional: Add categories like "Bug", "Feature", "Improvement"

### 4. Get Your Canny Credentials

You need three values:

**Subdomain**:
- Your Canny URL subdomain (e.g., `myapp` from `myapp.canny.io`)
- Find in: Settings → General → Company URL

**Board Token**:
- Settings → Boards → Click your board → Board Token
- Copy the token

**App ID**:
- Settings → General → App ID
- Copy the value

Save all three for Render.io deployment.

**See [CANNY_SETUP.md](./CANNY_SETUP.md) for detailed Canny configuration guide.**

---

## Deploying to Render.io

### 1. Push Your Code to GitHub

Ensure your latest changes are committed and pushed:

```bash
git add .
git commit -m "Add Render.io deployment with Canny feedback"
git push origin main
```

### 2. Create a New Web Service on Render

1. Go to https://dashboard.render.com
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

In the **Environment** section, add these variables:

#### Supabase Configuration

| Key | Value |
|-----|-------|
| `SUPABASE_URL` | Your Supabase project URL |
| `SUPABASE_ANON_KEY` | Your Supabase anon key |

#### Canny Configuration

| Key | Value |
|-----|-------|
| `CANNY_SUBDOMAIN` | Your Canny subdomain |
| `CANNY_BOARD_TOKEN` | Your Canny board token |
| `CANNY_APP_ID` | Your Canny app ID |

**Important**: Click "Save Changes" after adding variables.

### 5. Deploy

1. Click **Create Web Service**
2. Render will:
   - Clone your repository
   - Build the Docker image
   - Build the Flutter web app
   - Deploy it

This process takes 5-10 minutes for the first deployment.

### 6. Get Your App URL

Once deployed, you'll get a URL like:

```
https://five-to-one-app.onrender.com
```

Share this URL with your test users!

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
- **Submit feedback** via Settings → Send Feedback (opens Canny)

### Feedback System

When users click **Settings → Send Feedback**:

1. Opens your Canny board in a new tab
2. Users can:
   - Browse existing feedback
   - Vote on features they want
   - Submit new feedback
   - Track status of their requests
3. You manage everything in the Canny dashboard

### For You (Admin)

Access Canny dashboard to manage feedback:

1. Log in at https://canny.io
2. View all feedback in one place
3. Triage and prioritize
4. Update status as you work on features
5. Respond to users
6. Manage your public roadmap

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
- Run `flutter pub get` locally to ensure all dependencies resolve
- Check for any dependency version conflicts

**View build logs**:
- In Render dashboard, click on your service
- Go to "Logs" tab to see build errors

### Environment Variables Not Working

**Verify in Render**:
1. Go to your web service in Render
2. Click **Environment**
3. Ensure all 5 variables are set correctly
4. Redeploy after adding/updating variables

**Check for typos**:
- Variable names are case-sensitive
- Ensure no extra spaces
- Verify values are correct (copy-paste from source)

### Feedback Button Says "Not Configured"

**Issue**: Canny environment variables aren't set.

**Solution**:
1. Go to Render → Environment
2. Verify these are set:
   - `CANNY_SUBDOMAIN`
   - `CANNY_BOARD_TOKEN`
   - `CANNY_APP_ID`
3. Redeploy the app

### Feedback Opens Wrong Board

**Issue**: Board token is incorrect.

**Solution**:
1. Go to Canny → Settings → Boards
2. Copy the correct board token
3. Update `CANNY_BOARD_TOKEN` in Render
4. Redeploy

### App Is Slow on Mobile

**Use production build**:
- Ensure the Dockerfile uses `flutter build web --release`
- The `--web-renderer canvaskit` flag provides better performance

**Check network**:
- Render's free tier may spin down after inactivity
- First load after inactivity takes 30-60 seconds
- This is normal for the free tier

### CORS Errors

If you see CORS errors:
1. Go to Supabase → Settings → API
2. Check that your Render URL is allowed
3. Supabase allows all origins by default

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
- Restarts when someone accesses it (30-60 seconds)

**Canny (Free)**:
- Up to 50 users
- Unlimited feedback posts
- All core features
- Canny branding

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

**Canny Starter** ($50/month):
- Up to 100 users
- Remove branding
- Custom categories

---

## Next Steps

1. **Share with test users**: Send them your Render URL
2. **Set up Canny**: Configure categories, roadmap, and branding
3. **Collect feedback**: Monitor Canny for user submissions
4. **Iterate**: Fix bugs and add features based on feedback
5. **Communicate**: Use Canny to update users on progress

---

## Additional Resources

- **Flutter Web Documentation**: https://docs.flutter.dev/platform-integration/web
- **Supabase Documentation**: https://supabase.com/docs
- **Render Documentation**: https://render.com/docs
- **Canny Documentation**: https://developers.canny.io

---

## Related Guides

- **[QUICKSTART.md](./QUICKSTART.md)** - Get up and running in 15 minutes
- **[CANNY_SETUP.md](./CANNY_SETUP.md)** - Detailed Canny configuration and best practices

---

## Support

If you encounter issues:

1. **Check the logs** in Render dashboard
2. **Check Supabase logs** for database errors
3. **Check Canny dashboard** for feedback system issues
4. **Test locally** first to isolate deployment issues
5. **Consult the troubleshooting section** above

Good luck with your deployment! 🚀
