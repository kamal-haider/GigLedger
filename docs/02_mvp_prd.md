# GigLedger — MVP Product Requirements Document (PRD)

## Document Info
- Product: GigLedger
- Version: MVP v1
- Platforms: iOS, Android
- Stack: Flutter, Firebase, Riverpod
- Mode: Freemium (Free tier with Pro upgrade)

---

## 1. Purpose

This document defines the **Minimum Viable Product (MVP)** for GigLedger.

The MVP focuses on:
- Creating and sending invoices quickly
- Tracking expenses with receipt photos
- Managing clients in one place
- Viewing basic financial insights
- Clean foundations for future expansion

Anything not explicitly included here is **out of scope** for MVP.

---

## 2. MVP Goals

### Primary Goals
1. Enable freelancers to create and send a professional invoice in under 60 seconds
2. Allow expense tracking with photo receipts and basic categorization
3. Provide a unified client database accessible during invoicing
4. Show a simple dashboard with income, expenses, and profit summary

### Success Metrics
- 60% of users create their first invoice within 5 minutes of signup
- Average invoice creation time < 60 seconds after first use
- 40% of users log at least 3 expenses in first week
- 30-day retention rate > 40%
- App Store rating > 4.5 stars

---

## 3. In-Scope Features

### 3.1 Authentication & User Profile
- Sign in with Google, Apple, and Email/Password
- Store user preferences:
  - Business name and logo
  - Default currency (USD, EUR, GBP, etc.)
  - Tax rate for invoices
  - Payment instructions (bank details, PayPal, etc.)

---

### 3.2 Dashboard (Home Screen)
**Purpose:** Financial overview and quick actions

**Requirements:**
- Display total income (current month + YTD)
- Display total expenses (current month + YTD)
- Display net profit (income - expenses)
- Quick action buttons: New Invoice, Add Expense, Add Client
- Recent activity list (last 5 invoices/expenses)
- Pull-to-refresh for data sync

---

### 3.3 Invoicing (Core Feature)
**Purpose:** Create, send, and track professional invoices

**Requirements:**
- Create invoice with:
  - Client selection (from client database)
  - Line items (description, quantity, rate, amount)
  - Tax calculation (configurable rate)
  - Due date selection
  - Notes/terms field
- Invoice templates (2-3 professional designs)
- Send invoice via email (in-app) or share link
- Invoice statuses: Draft, Sent, Viewed, Paid, Overdue
- Mark invoice as paid (manual)
- View invoice history per client
- Edit/duplicate existing invoices

**Non-Goals:**
- No partial payments in MVP
- No recurring invoices in MVP
- No in-app payment processing (Stripe integration is post-MVP)

---

### 3.4 Expense Tracking (Core Feature)
**Purpose:** Log and categorize business expenses

**Requirements:**
- Add expense with:
  - Amount and date
  - Category (dropdown: Travel, Office, Software, Marketing, Meals, Equipment, Other)
  - Vendor/description
  - Photo receipt attachment (camera or gallery)
- View expense list with filters (date range, category)
- Edit/delete expenses
- Monthly expense summary by category

**Non-Goals:**
- No OCR auto-extraction in MVP (manual entry)
- No bank sync in MVP
- No mileage tracking in MVP

---

### 3.5 Client Management
**Purpose:** Maintain client database for invoicing

**Requirements:**
- Add client with:
  - Name (person or company)
  - Email address
  - Phone (optional)
  - Address (optional)
  - Notes field
- View client list with search
- View client detail page showing:
  - Contact info
  - Invoice history
  - Total billed / Total paid
- Edit/delete clients
- Quick-add client during invoice creation

---

### 3.6 Reports & Insights
**Purpose:** Basic financial visibility

**Requirements:**
- Income vs Expenses chart (monthly, last 6 months)
- Top clients by revenue (list)
- Expense breakdown by category (pie chart)
- Exportable summary (PDF) for tax prep
- Available only on dashboard and dedicated Reports tab

---

### 3.7 Settings
**Purpose:** App configuration

**Requirements:**
- Edit business profile (name, logo, address)
- Set default currency
- Set default tax rate
- Configure payment instructions
- Notification preferences
- Sign out / Delete account

---

### 3.8 Notifications (Limited)
**Purpose:** Payment reminders

**Requirements:**
- Push notification when invoice becomes overdue
- Optional: Weekly summary notification (configurable)
- No email automation in MVP
- No SMS notifications in MVP

---

### 3.9 Onboarding (MVP+)
- 3-screen intro carousel explaining key features
- Business profile setup wizard on first launch
- Skip option for returning users

---

## 4. Out of Scope (Explicit)

- Recurring invoices
- In-app payment processing (Stripe checkout)
- Bank account sync
- OCR receipt scanning (auto-extraction)
- Time tracking
- Project management features
- Multi-currency per invoice (single currency per account)
- Team/multi-user accounts
- Estimates/quotes (separate from invoices)
- Contract/proposal generation
- Mileage tracking
- Inventory management

These are **future roadmap items**, not MVP.

---

## 5. Monetization (MVP-Compatible)

### Free Tier
- Up to 5 clients
- Up to 10 invoices/month
- Up to 20 expenses/month
- Basic reports
- GigLedger branding on invoices

### Pro Tier ($9.99/month or $79.99/year)
- Unlimited clients
- Unlimited invoices
- Unlimited expenses
- Advanced reports & exports
- Remove GigLedger branding
- Priority support
- Custom invoice templates (post-MVP)

Pricing details in `08_monetization_and_pricing.md`.

---

## 6. Technical Constraints

### Firestore
- User data stored under `users/{uid}` document
- Invoices, expenses, clients as subcollections
- Denormalized client info on invoices for read performance
- Security rules enforce user-only access

### Stripe (Post-MVP)
- Will be used for subscription management
- Payment links for invoice payments (future)
- All Stripe calls via Cloud Functions

### Flutter + Riverpod
- Offline-first with Firestore persistence
- State management via Riverpod providers
- Feature-based module structure
- Shared design system in `core/`

---

## 7. Acceptance Criteria (High-Level)

- [ ] User can sign up/sign in and set up business profile
- [ ] User can create and send an invoice in under 60 seconds
- [ ] User can add an expense with a photo receipt
- [ ] User can add/edit/view clients
- [ ] User can see dashboard with income/expense/profit summary
- [ ] User can mark invoices as paid
- [ ] User can view basic reports
- [ ] App runs consistently on iOS and Android
- [ ] No sensitive credentials exposed client-side
- [ ] Free tier limits are enforced

---

## 8. MVP Exit Criteria

MVP is considered complete when:
- All in-scope features are implemented and tested
- Performance is acceptable on mid-range devices (< 3s cold start)
- Data accuracy is validated (invoice totals, expense sums)
- App is deployable to App Store and Google Play
- Core user flows have < 2% crash rate

---

## 9. Future Considerations (Not Implemented)

- Recurring invoices with auto-send
- Stripe payment processing for invoices
- Bank account sync (Plaid integration)
- OCR receipt scanning
- Time tracking with project association
- Multi-currency support
- Team accounts with permissions
- AI-powered expense categorization
- Tax form generation (1099, Schedule C)

These will be addressed in the roadmap (`09_roadmap.md`).
