# Browser Form & Password Tracking Guide

## How It Works Now

The browser tracking has been significantly improved to capture form submissions and passwords, especially on complex sites like Google.

## Enhanced Features

### 1. **Improved Form Tracking**
- Monitors all form submissions in real-time
- Tracks input field changes (blur and change events)
- Captures email and text fields
- Detects password fields automatically
- Works with dynamic forms (like Google login)

### 2. **Smart Password Detection**
- Listens to password field changes
- Automatically finds associated username/email
- Stores credentials securely
- Shows notification when password is saved

### 3. **Dynamic Form Support**
- Uses MutationObserver to detect new forms
- Works with JavaScript-heavy sites
- Tracks forms added after page load
- Compatible with Google, Facebook, etc.

### 4. **Data Storage Method**
- JavaScript stores data in localStorage
- Flutter reads from localStorage periodically
- Data is transferred and cleared automatically
- Checks every 3 seconds for new data

## What Gets Tracked

### Form Submissions:
- ✅ URL where form was submitted
- ✅ Domain name
- ✅ All form fields (except passwords)
- ✅ Password field indicator
- ✅ Timestamp

### Password Entries:
- ✅ URL where password was entered
- ✅ Domain name
- ✅ Username/Email associated
- ✅ Password indicator (actual password not stored in plain text)
- ✅ Timestamp

## Testing the Feature

### Test on Google Login:
1. Open browser in the app
2. Go to accounts.google.com
3. Enter your email
4. Enter your password
5. Submit the form
6. Wait 2-3 seconds
7. Check analytics - you should see:
   - Form submission recorded
   - Password entry saved
   - Notification shown

### Test on Other Sites:
- Facebook login
- GitHub login
- Any website with forms
- Newsletter signups
- Contact forms

## Notifications

You'll see notifications when:
- ✅ Form data is captured
- ✅ Password is saved (shows username)

## Privacy & Security

### What's Stored:
- Username/email in plain text
- Password as `***SECURED***` (not actual password)
- Form field names and non-sensitive values
- URLs and domains

### What's NOT Stored:
- ❌ Actual password values
- ❌ Credit card numbers
- ❌ Sensitive personal data

### Security Measures:
- All data stored locally only
- Passwords marked as secured
- No transmission to external servers
- User can clear all data anytime

## Troubleshooting

### If tracking doesn't work:

1. **Wait a few seconds** - Data is checked every 3 seconds
2. **Check JavaScript is enabled** - Required for tracking
3. **Try submitting the form** - Tracking happens on submit
4. **Check analytics** - Data might be there already
5. **Look for notifications** - They confirm data was saved

### Common Issues:

**Q: Google login not tracked?**
A: Wait 3-5 seconds after submitting. Google uses complex JavaScript that takes time to process.

**Q: No password saved?**
A: Make sure you actually changed the password field (not just focused it). The tracking happens on 'change' event.

**Q: Form data empty?**
A: Some sites use non-standard forms. The tracker captures what it can detect.

**Q: Too many notifications?**
A: This is normal on sites with multiple forms. Each form submission is tracked.

## Technical Details

### JavaScript Tracking:
```javascript
- Form submit event listener
- Input change/blur listeners
- Password field monitoring
- MutationObserver for dynamic content
- localStorage for data transfer
```

### Flutter Integration:
```dart
- Periodic localStorage checks (every 3 seconds)
- JavaScript execution for data retrieval
- Automatic data parsing and storage
- User notifications via SnackBar
```

### Data Flow:
1. User fills form on website
2. JavaScript captures data → localStorage
3. Flutter checks localStorage (every 3s)
4. Data parsed and saved to SharedPreferences
5. localStorage cleared
6. User notified

## Viewing Your Data

### In Analytics Dashboard:
1. Tap analytics icon in browser
2. Go to "Forms" tab - see all form submissions
3. Go to "Passwords" tab - see all saved credentials
4. Each entry shows:
   - Domain
   - Username
   - Timestamp
   - Last used date

## Clearing Data

### To clear tracked data:
1. Open analytics dashboard
2. Tap delete icon (top right)
3. Choose what to clear:
   - History only
   - Forms only
   - Passwords only
   - All data

## Best Practices

### For Accurate Tracking:
- ✅ Wait 3-5 seconds after form submission
- ✅ Make sure fields are filled before submitting
- ✅ Check analytics to verify data was saved
- ✅ Use the browser regularly to build history

### For Privacy:
- ✅ Clear data regularly if sharing device
- ✅ Don't share screenshots of password tab
- ✅ Remember data is local but visible in app
- ✅ Use app lock if available

## Future Improvements

Potential enhancements:
- Real-time tracking without delay
- Better password encryption
- Auto-fill capabilities
- Password strength checker
- Export data feature
- Backup and restore
- Biometric protection for password tab

## Support

If you encounter issues:
1. Check Flutter console for errors
2. Verify JavaScript is enabled in WebView
3. Test on simple forms first
4. Check analytics after 5 seconds
5. Try clearing app data and testing again

---

**Note**: This tracking is designed for personal use and privacy awareness. Always respect website terms of service and privacy policies.
