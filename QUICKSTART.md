# Quick Start Guide - Deploy to Render.io

Get your Five to One app running on Render.io in under 15 minutes!

## Prerequisites

- Supabase account (free): https://supabase.com
- Render account (free): https://render.com
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

## Step 2: Set Up Supabase (5 minutes)

1. **Create Project**: https://app.supabase.com → New Project
2. **Run Migrations**:
   - Go to SQL Editor
   - Copy & run `five_to_one_mobile/supabase_schema.sql`
   - Copy & run `five_to_one_mobile/supabase_feedback_schema.sql`
3. **Get Credentials**:
   - Settings → API
   - Copy Project URL and anon key
   - Save them for Step 3

---

## Step 3: Deploy to Render (5 minutes)

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

3. **Configure**:
   - Runtime: Docker
   - Add environment variables:
     - `SUPABASE_URL`: Your Supabase project URL
     - `SUPABASE_ANON_KEY`: Your Supabase anon key

4. **Deploy**: Click "Create Web Service"

5. **Wait**: First deploy takes ~10 minutes

---

## Step 4: Set Up Admin Access (3 minutes)

1. **Sign up** in your deployed app
2. **Go to Supabase**:
   - Authentication → Users
   - Find your user → Edit
   - Raw User Meta Data:
     ```json
     {
       "is_admin": true
     }
     ```
   - Save

3. **Verify**: Settings → Admin Dashboard should now appear

---

## You're Done! 🎉

Your app is now live at: `https://your-app-name.onrender.com`

### Share with test users:
- Send them the URL
- They can submit feedback via Settings → Send Feedback

### Manage feedback:
- Settings → Admin Dashboard
- View all feedback, set priorities, add notes

---

## Next Steps

- Read [DEPLOYMENT.md](./DEPLOYMENT.md) for full details
- Read [FEEDBACK_GUIDE.md](./FEEDBACK_GUIDE.md) to learn feedback management
- Customize your app name in Render
- Set up custom domain (optional)

---

## Troubleshooting

**App won't build?**
- Check Flutter version: `flutter --version` (need 3.0+)
- Ensure environment variables are set in Render

**Can't see admin dashboard?**
- Log out and back in after setting admin flag
- Check Supabase user metadata is saved correctly

**Feedback not saving?**
- Verify both migration files were run in Supabase
- Check Table Editor → feedback table exists

**More help**: See [DEPLOYMENT.md](./DEPLOYMENT.md) Troubleshooting section

---

## Free Tier Limits

**Supabase**: 500MB database, plenty for testing
**Render**: App spins down after 15 min of inactivity (restarts in ~30s)

Both services are free forever for small projects!
