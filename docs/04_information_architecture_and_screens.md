# GigLedger — Information Architecture & Screen Responsibilities

## Purpose

This document defines:
- The complete MVP screen list
- Navigation structure
- Screen responsibilities
- Mobile-first behavior with web parity

It serves as the **source of truth** for UX, routing, and feature ownership.

---

## 1. Navigation Model

### Primary Navigation (Mobile)
- Bottom navigation bar with [N] tabs:
  1. [Tab 1]
  2. [Tab 2]
  3. [Tab 3]
  4. [Tab 4]

### Primary Navigation (Web)
- Left-side navigation rail:
  - [Tab 1]
  - [Tab 2]
  - [Tab 3]
  - [Tab 4]

Routing logic is shared across platforms.

---

## 2. Screen Map (MVP)

```txt
Auth
└── Onboarding
└── [Main Entry Point]
├── [Screen 1]
│   ├── [Child Screen 1a]
│   │   └── [Grandchild Screen]
│   └── [Child Screen 1b]
├── [Screen 2]
│   └── [Child Screen 2a]
├── [Screen 3]
└── [Screen 4]
```

---

## 3. Screen Responsibilities

### 3.1 Authentication
**Purpose:** Secure access and personalization

**Responsibilities:**
- Sign in / Sign up
- Account recovery
- Token handling via [auth provider]

**Non-Responsibilities:**
- No social features
- No guest mode (MVP)

---

### 3.2 Onboarding
**Purpose:** Personalization and intent capture for new users

**Flow:**
```
Welcome → [Selection Step 1] → [Selection Step 2] → Preferences → Home
    ↓ (Skip at any step)
   Home (with defaults)
```

**Steps:**

1. **Welcome Step**
   - App introduction and value proposition
   - Feature highlights
   - Entry point to onboarding flow

2. **[Selection Step 1]**
   - [What user selects]
   - [Search/filter capabilities]
   - [Data source]

3. **[Selection Step 2]**
   - [What user selects]
   - [Selection UI pattern]
   - [Data source]

4. **Preferences Step**
   - [Preference 1]
   - [Preference 2]
   - [Preference 3]

**Navigation Patterns:**
- Linear flow with Back/Next navigation
- Skip button available on all steps
- Progress indicator shows current step
- Onboarding cannot be re-accessed after completion

**Persistence:**
- All selections saved to [storage]
- `hasCompletedOnboarding` flag prevents re-showing
- Preferences can be edited later in Profile/Settings

---

### 3.3 [Main Tab 1]
**Purpose:** [Purpose description]

**Responsibilities:**
- [Responsibility 1]
- [Responsibility 2]
- [Responsibility 3]
- [Responsibility 4]

---

### 3.4 [Main Tab 2]
**Purpose:** [Purpose description]

**Responsibilities:**
- [Responsibility 1]
- [Responsibility 2]
- [Responsibility 3]

**Non-Responsibilities:**
- [What it doesn't do]

---

### 3.5 [Detail Screen 1]
**Purpose:** [Purpose description]

**Responsibilities:**
- [Responsibility 1]
- [Responsibility 2]
- [Responsibility 3]
- Entry points to deeper analysis

**Child Screens:**
- [Child screen 1]
- [Child screen 2]

---

### 3.6 [Core Feature Screen] (Core Screen)
**Purpose:** [Core purpose]

**Responsibilities:**
- [Responsibility 1]
- [Responsibility 2]
- [Responsibility 3]
- [Responsibility 4]

**Constraints:**
- No [constraint 1]
- No [constraint 2]

---

### 3.7 [List Screen]
**Purpose:** Browsable [items] overview

**Responsibilities:**
- Display all [items] in list format
- Search/filter by [criteria]
- Sort by:
  - [Sort option 1] (default)
  - [Sort option 2]
  - [Sort option 3]
- Navigate to individual detail screens

**Access:**
- Entry point from [parent screen]
- Provides list-based browsing vs [alternative view]

---

### 3.8 [Detail Screen 2]
**Purpose:** Individual [item] breakdown

**Responsibilities:**
- [Responsibility 1]
- [Responsibility 2]
- [Responsibility 3]
- [Responsibility 4]

---

### 3.9 [Feature Screen]
**Purpose:** [Purpose description]

**Responsibilities:**
- [Responsibility 1]
- [Responsibility 2]
- [Responsibility 3]

**Access Rules:**
- Available for [conditions]
- [Access restriction] (configurable)

---

### 3.10 Profile / Settings
**Purpose:** Account management

**Responsibilities:**
- Edit preferences
- Manage subscription (if applicable)
- App settings

---

## 4. Mobile vs Web Considerations

### Mobile
- Vertical-first layouts
- Collapsible sections
- Gesture-based navigation

### Web
- Wider layouts
- Persistent navigation
- More visible comparisons

Logic remains shared; layout adapts responsively.

---

## 5. MVP UX Principles

1. Always show **context before data**
2. Never show raw tables without explanation
3. Allow drilling down progressively
4. Avoid deep navigation stacks

---

## 6. Navigation Non-Goals

- No infinite nesting
- No multi-window views
- No custom dashboards (post-MVP)

---

## 7. Dependencies

- Requires data from backend
- Requires consistent identifiers
- Requires cached data for performance

---

## 8. Route Definitions

| Route | Screen | Parameters |
|-------|--------|------------|
| `/` | Home | - |
| `/[tab1]` | [Tab 1 Screen] | - |
| `/[item]/:id` | [Item Detail] | `id` |
| `/[feature]/:id` | [Feature Screen] | `id` |
| `/[tab3]` | [Tab 3 Screen] | - |
| `/profile` | Profile | - |
| `/settings` | Settings | - |

---

## 9. Exit Criteria

This document is complete when:
- Every MVP feature maps to a screen
- No screen owns ambiguous responsibilities
- Mobile and web paths are clearly defined
