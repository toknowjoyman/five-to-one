# Canny Feedback Integration Guide

This guide will help you set up Canny for collecting and managing user feedback in your Five to One app.

## What is Canny?

Canny is a user feedback platform that helps you:
- **Collect feedback** from users through a beautiful interface
- **Track feature requests** and let users vote on them
- **Manage your roadmap** and keep users informed
- **Organize feedback** by categories and status
- **Engage with users** through comments and updates

**Free Tier**: Up to 50 users on the Starter plan

---

## Step 1: Create a Canny Account (5 minutes)

1. **Sign up** at https://canny.io
2. **Create a new company** (your app name)
3. **Skip integrations** for now (you can add them later)

---

## Step 2: Set Up Your Feedback Board (5 minutes)

### Create a Board

1. In Canny dashboard, click **Settings** → **Boards**
2. Click **Create Board**
3. Name it "Feedback" (or whatever you prefer)
4. Choose board type: **Feature Requests** (recommended)
5. Click **Create**

### Configure Board Settings

1. Go to your board → **Settings**
2. **General Settings**:
   - Set board name and description
   - Choose privacy: **Public** (recommended for transparency)
   - Enable **Voting** (let users vote on features)
   - Enable **Status labels** (New, Planned, In Progress, Complete)

3. **Categories** (optional but recommended):
   - Create categories like: Bug, Feature, Improvement
   - This helps organize feedback

4. **Custom Fields** (optional):
   - Add fields like "Priority", "Device Type", etc.

---

## Step 3: Get Your Canny Credentials (2 minutes)

You need three values to integrate Canny with your app:

### 1. Subdomain

This is your Canny URL subdomain.

- If your Canny URL is `https://myapp.canny.io`, your subdomain is **myapp**
- Find it in: Settings → General → Company URL

### 2. Board Token

This identifies which board to show in your app.

1. Go to **Settings** → **Boards**
2. Click on your "Feedback" board
3. Scroll to **Board Token**
4. Copy the token (looks like: `abc123def456...`)

### 3. App ID

This is your Canny application ID.

1. Go to **Settings** → **General**
2. Find **App ID** (looks like: `12abc34def56...`)
3. Copy the value

---

## Step 4: Configure Your Flutter App

### Option A: Set Environment Variables (Recommended for Production)

When deploying to Render.io, set these environment variables:

| Variable | Value | Example |
|----------|-------|---------|
| `CANNY_SUBDOMAIN` | Your subdomain | `myapp` |
| `CANNY_BOARD_TOKEN` | Your board token | `abc123def456...` |
| `CANNY_APP_ID` | Your app ID | `12abc34def56...` |

### Option B: Edit Config File (For Local Testing)

Edit `five_to_one_mobile/lib/config/canny_config.dart`:

```dart
class CannyConfig {
  static const String subdomain = String.fromEnvironment(
    'CANNY_SUBDOMAIN',
    defaultValue: 'myapp', // Replace with your subdomain
  );

  static const String boardToken = String.fromEnvironment(
    'CANNY_BOARD_TOKEN',
    defaultValue: 'abc123def456...', // Replace with your board token
  );

  static const String appId = String.fromEnvironment(
    'CANNY_APP_ID',
    defaultValue: '12abc34def56...', // Replace with your app ID
  );
}
```

---

## Step 5: Deploy to Render.io

### Add Environment Variables in Render

1. Go to your Render dashboard
2. Select your **five-to-one-app** service
3. Click **Environment**
4. Add three new environment variables:

| Key | Value |
|-----|-------|
| `CANNY_SUBDOMAIN` | Your Canny subdomain |
| `CANNY_BOARD_TOKEN` | Your board token |
| `CANNY_APP_ID` | Your app ID |

5. Click **Save Changes**
6. Render will **automatically redeploy** your app

---

## Step 6: Test the Integration (2 minutes)

1. **Open your deployed app** (e.g., `https://five-to-one-app.onrender.com`)
2. **Go to Settings** → **Send Feedback**
3. It should open your Canny feedback board in a new tab
4. **Submit a test post** to verify it works

---

## Using Canny with Your App

### For Users

When users tap **Settings → Send Feedback**, they'll be taken to your Canny board where they can:

1. **Browse existing feedback** to see what's been requested
2. **Vote on features** they want to see
3. **Submit new feedback**:
   - Choose a category
   - Write a title and description
   - Optionally add images
4. **Track their requests** and see status updates
5. **Comment and discuss** with you and other users

### For You (Admin)

#### Manage Feedback

1. **Log in to Canny** at https://canny.io
2. **View all feedback** in your dashboard
3. **Triage new posts**:
   - Merge duplicates
   - Assign categories
   - Set status (New, Planned, In Progress, Complete)
4. **Respond to users** with comments
5. **Update status** as you work on features

#### Organize Your Roadmap

1. Go to **Roadmap** tab
2. Drag posts to different status columns
3. Set **ETAs** for planned features
4. **Make it public** so users can see what's coming

#### Get Insights

Canny provides analytics on:
- Most requested features
- Most active users
- Feedback trends over time
- Vote counts and engagement

---

## Best Practices

### 1. Respond Quickly

- Acknowledge new feedback within 24 hours
- Even a simple "Thanks for the suggestion!" goes a long way
- Use canned responses for common requests

### 2. Keep Status Updated

- Move posts to "Planned" when you decide to build them
- Update to "In Progress" when you start working
- Mark as "Complete" when shipped
- Add a comment explaining what you built

### 3. Close the Loop

When you complete a feature:
1. Mark it **Complete**
2. Add a comment: "This is now live! Check it out in v1.2"
3. Canny will **email everyone** who voted/commented
4. Users feel heard and appreciated

### 4. Use the Changelog

1. Post to the **Changelog** when you ship features
2. Link to relevant feedback posts
3. Users can see their feedback led to real changes

### 5. Encourage Voting

- More votes = higher priority
- Ask users to vote instead of creating duplicates
- Use votes to guide your roadmap

---

## Advanced Features

### Single Sign-On (SSO)

The app already passes user information to Canny when opening the feedback widget:
- User ID
- Email address

This allows Canny to:
- Show users their own feedback history
- Pre-fill their email when posting
- Track who requested what

### Slack Integration

Get notifications in Slack:
1. Go to Canny **Settings** → **Integrations**
2. Connect Slack
3. Choose which events to notify:
   - New posts
   - New comments
   - Status changes

### Email Digests

Canny can send you:
- Daily/weekly summaries of new feedback
- Notifications for specific boards or categories
- Configure in Settings → Email Notifications

### Public Roadmap

Make your roadmap public:
1. Go to **Roadmap** settings
2. Enable **Public Roadmap**
3. Share the URL with users
4. They can see what you're working on

### Custom Branding

On paid plans, you can:
- Remove Canny branding
- Add your logo and colors
- Use a custom domain (feedback.yourapp.com)

---

## Pricing

### Free Tier
- Up to 50 users
- Unlimited feedback posts
- Basic features
- Canny branding

### Starter ($50/month)
- Up to 100 users
- Remove Canny branding
- Custom categories and fields
- Integrations

### Growth ($200/month)
- Up to 400 users
- SSO
- Custom domain
- Priority support

For most early-stage apps, the **free tier is perfect** to start!

---

## Troubleshooting

### "Feedback (Not Configured)" Shows in App

**Issue**: The Canny integration isn't configured.

**Solution**: Make sure you've set the environment variables in Render:
- `CANNY_SUBDOMAIN`
- `CANNY_BOARD_TOKEN`
- `CANNY_APP_ID`

Then redeploy your app.

### Feedback Opens to Wrong Board

**Issue**: The board token is incorrect.

**Solution**:
1. Go to Canny → Settings → Boards
2. Copy the correct board token
3. Update the `CANNY_BOARD_TOKEN` environment variable in Render
4. Redeploy

### Users Can't Post

**Issue**: Board privacy settings may be too restrictive.

**Solution**:
1. Go to your board → Settings → Privacy
2. Ensure it's set to **Public** or **Login Required**
3. For anonymous posting, choose **Public**

### Can't See User Information

**Issue**: SSO isn't working properly.

**Solution**: This is a nice-to-have feature. Users can still post feedback without SSO. They'll just need to enter their email manually.

---

## Alternatives to Canny

If Canny doesn't fit your needs, here are alternatives:

1. **Featurebase** (https://featurebase.app)
   - Similar to Canny
   - More generous free tier
   - Unlimited feedback on free plan

2. **Tally** (https://tally.so)
   - Beautiful forms
   - Completely free
   - No voting/roadmap features

3. **Google Forms** (https://forms.google.com)
   - Simplest option
   - Completely free
   - Manual management required

---

## Migration from Custom Feedback

If you previously had the custom feedback system:

1. **Export existing feedback** from Supabase:
   ```sql
   SELECT * FROM feedback;
   ```

2. **Import to Canny**:
   - There's no bulk import, so you may need to manually add important items
   - Or use Canny's API to import programmatically

3. **Notify users**:
   - Let them know feedback is now managed via Canny
   - Provide the new feedback link

---

## Conclusion

Canny provides a professional, full-featured feedback platform without the maintenance overhead of a custom system. Your users get a better experience, and you get powerful tools to manage and prioritize feedback.

Happy feedback collecting! 🚀

---

## Quick Reference

**Canny Dashboard**: https://canny.io/admin
**Documentation**: https://developers.canny.io
**Support**: support@canny.io

**Your Canny URL**: `https://[your-subdomain].canny.io`
**Your Feedback Board**: `https://[your-subdomain].canny.io/feedback`
