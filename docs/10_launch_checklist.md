# GigLedger — Launch Checklist

## Purpose

This checklist ensures GigLedger is **production-ready** across:
- Engineering
- Product
- Operations
- App store compliance

This is the final gate before public release.

---

## 0. Project Bootstrap

### Project Setup
- [ ] Project initialized for [platforms]
- [ ] Folder structure follows architecture docs
- [ ] main entry point boots placeholder app
- [ ] Web support enabled and verified (if applicable)
- [ ] [Backend] dependencies added to project
- [ ] [Backend] initialization code in main
- [ ] [Backend] project created in console
- [ ] CLI configuration completed
- [ ] [State management] dependency added
- [ ] [Router] dependency added
- [ ] Navigation structure implemented

---

## 1. Engineering Readiness

### Backend
- [ ] [Data proxy/functions] stable and tested
  - [ ] [List backend functions/endpoints]
  - [ ] Functions are callable from client
- [ ] Derived insights validated against known test cases
- [ ] Database security rules locked
- [ ] Rate limiting verified
- [ ] Error logging enabled

### Frontend
- [ ] All MVP screens implemented
  - [ ] [List all screens]
- [ ] Responsive layouts verified (mobile + web)
  - [ ] Navigation adapts to screen size
  - [ ] Form constraints for appropriate pages
  - [ ] Consistent spacing system
  - [ ] Multi-column layouts for tablet/desktop (post-MVP)
- [ ] Loading and error states present
  - [ ] All main pages have proper async handling
  - [ ] Empty state widget used for empty data
  - [ ] Error state widget used for error recovery
  - [ ] Skeleton/shimmer loading states on data-driven pages
- [ ] [Complex UI components] tested with large data sets
- [ ] No direct [external API] calls from client

### Onboarding & User Experience
- [ ] Test onboarding flow with fresh users
- [ ] Verify skip functionality works correctly
- [ ] Ensure preferences are saved to database
- [ ] Test router redirects (auth → onboarding → home)
- [ ] Verify onboarding cannot be accessed after completion
- [ ] Test Back/Next navigation through all steps
- [ ] Verify [selection step 1] works
- [ ] Verify [selection step 2] works
- [ ] Test preferences step
- [ ] Confirm accessibility with screen readers
- [ ] Test onboarding with slow/offline network
- [ ] Verify onboarding UI on different screen sizes

---

## 2. Data Validation

- [ ] [Core data type] summaries reviewed for accuracy
- [ ] [Chart/visualization data] spot-checked
- [ ] [Feature comparisons] validated
- [ ] Known [test cases] used as regression fixtures

---

## 3. Performance & Stability

- [ ] Cold start time acceptable
- [ ] Web [complex UI] rendering performant
- [ ] Database reads minimized
- [ ] Offline cache tested
- [ ] Memory usage within limits

---

## 4. Security & Privacy

- [ ] No API keys in client (or keys properly restricted)
  - [ ] Restrict API keys in backend console (recommended)
- [ ] Database rules audited
  - [ ] Users can only read/write own profile
  - [ ] [Protected data] read-only for all authenticated users
  - [ ] UID tampering prevented on create/update
- [ ] Auth flows secured
- [ ] User data isolated per UID
- [ ] No PII stored unnecessarily

---

## 5. App Store Readiness

### iOS
- [ ] App Store metadata written
- [ ] Screenshots prepared
- [ ] Privacy policy linked
- [ ] Subscription disclosures complete (if applicable)

### Android
- [ ] Play Store listing created
- [ ] Internal testing track configured
- [ ] Subscription policy reviewed (if applicable)

---

## 6. Web Deployment

- [ ] [Hosting provider] configured
- [ ] HTTPS enforced
- [ ] SEO metadata added
- [ ] Fallback error pages

---

## 7. Monetization Readiness

- [ ] Free vs Pro gating verified
  - [ ] [Pro feature 1] gated behind Pro subscription
  - [ ] Paywall page/sheet implemented
  - [ ] Debug subscription panel (only in debug mode)
- [ ] Subscription purchase flow tested
  - [ ] In-app purchase package integrated
  - [ ] Real billing implementation tested
- [ ] Restore purchases tested
  - [ ] Restore UI ready
  - [ ] Actual store connection implemented
- [ ] Grace period handling implemented

---

## 8. Analytics & Feedback

- [ ] Basic usage analytics
- [ ] Feature engagement tracking
- [ ] Error monitoring (Crashlytics or equivalent)
  - [ ] SDK integrated
  - [ ] Platform-specific configuration done
  - [ ] Logger integrated with crash reporting
  - [ ] Test crash verified in console
- [ ] Feedback channel available

---

## 9. Legal & Compliance

- [ ] Privacy policy published
- [ ] Terms of service published
- [ ] Disclaimer regarding data accuracy (if applicable)
- [ ] [External service] attribution included (if required)

---

## 10. Soft Launch Checklist

- [ ] Invite limited beta users
- [ ] Monitor database costs
- [ ] Collect qualitative feedback
- [ ] Fix critical issues only

---

## 11. Public Launch Checklist

- [ ] Production build deployed
- [ ] App stores approved
- [ ] Web live
- [ ] Monitoring dashboards active

---

## 12. Post-Launch

- [ ] Review metrics after 7 days
- [ ] Identify MVP gaps
- [ ] Decide on [future capability] investment
- [ ] Lock next roadmap iteration
