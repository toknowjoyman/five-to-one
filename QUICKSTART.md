# Quick Start Guide - Deploy to Render.io

Get your Five to One app running on Render.io in under 20 minutes!

## Prerequisites

- Supabase account (free): https://supabase.com
- Render account (free): https://render.com
- Canny account (free): https://canny.io
- GitHub account

---

## Step 1: Enable Flutter Web (2 minutes)

On your local machine:

```bash
cd five_to_one_mobile
flutter config --enable-web
flutter create --platforms=web .
```

Test it:
```bash
flutter run -d chrome
```

---

## Step 2: Set Up Supabase (3 minutes)

1. **Create Project**: https://app.supabase.com → New Project
2. **Run Migration**:
   - Go to SQL Editor
   - Copy & run `five_to_one_mobile/supabase_schema.sql`
3. **Get Credentials**:
   - Settings → API
   - Copy Project URL and anon key
   - Save them for Step 4

---

## Step 3: Set Up Canny (5 minutes)

1. **Create Account**: https://canny.io → Sign up
2. **Create Board**:
   - Settings → Boards → Create Board
   - Name: "Feedback"
   - Type: Feature Requests
3. **Get Credentials**:
   - **Subdomain**: Your Canny URL (e.g., `myapp` from `myapp.canny.io`)
   - **Board Token**: Settings → Boards → Your Board → Board Token
   - **App ID**: Settings → General → App ID
   - Save these for Step 4

---

## Step 4: Deploy to Render (8 minutes)

1. **Push to GitHub**:
   ```bash
   git add .
   git commit -m "Add deployment configuration"
   git push origin main
   ```

2. **Create Web Service**:
   - Go to https://dashboard.render.com
   - New → Web Service
   - Connect your GitHub repo

3. **Configure Environment Variables**:
   - Runtime: Docker
   - Add these variables:
     - `SUPABASE_URL`: Your Supabase project URL
     - `SUPABASE_ANON_KEY`: Your Supabase anon key
     - `CANNY_SUBDOMAIN`: Your Canny subdomain
     - `CANNY_BOARD_TOKEN`: Your Canny board token
     - `CANNY_APP_ID`: Your Canny app ID

4. **Deploy**: Click "Create Web Service"

5. **Wait**: First deploy takes ~10 minutes

---

## You're Done! 🎉

Your app is now live at: `https://your-app-name.onrender.com`

### Share with test users:
- Send them the URL
- They can submit feedback via Settings → Send Feedback
- Feedback opens in your Canny board

### Manage feedback:
- Log in to https://canny.io
- View all feedback, set priorities, update status
- Respond to users with comments
- Track your roadmap

---

## Next Steps

- Read [DEPLOYMENT.md](./DEPLOYMENT.md) for full deployment details
- Read [CANNY_SETUP.md](./CANNY_SETUP.md) to learn feedback management
- Customize your app name in Render
- Set up custom domain (optional)
- Configure Canny roadmap and categories

---

## Troubleshooting

**App won't build?**
- Check Flutter version: `flutter --version` (need 3.0+)
- Ensure all environment variables are set in Render

**Feedback button says "Not Configured"?**
- Verify Canny environment variables are set in Render
- Check for typos in variable names
- Redeploy after adding variables

**Feedback opens but shows wrong board?**
- Check `CANNY_BOARD_TOKEN` is correct
- Get the token from Settings → Boards in Canny

**More help**: See [DEPLOYMENT.md](./DEPLOYMENT.md) Troubleshooting section

---

## Free Tier Limits

**Supabase**: 500MB database, plenty for testing
**Render**: App spins down after 15 min of inactivity (restarts in ~30s)
**Canny**: Up to 50 users, unlimited feedback

All services are free forever for small projects!
