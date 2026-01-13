# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

GigLedger is a Flutter, Firebase, Riverpod-based mobile app that helps freelancers manage their business finances - invoicing, expense tracking, client management, and financial insights - all in one place.

**Core Philosophy:** Speed over features. Every action should feel instant. We prioritize simplicity over comprehensiveness, making freelance finances effortless rather than powerful.

## Claude Skills

This project includes specialized Claude skills in `.claude/skills/` that reference the documentation as the source of truth. These skills are automatically available when working in this repository.

### Available Skills

1. **gigledger-dev** (Main Orchestrator)
   - Coordinates all development with documentation as source of truth
   - Manages GitHub project tickets from https://github.com/users/kamal-haider/projects/6
   - Updates launch checklist in `docs/10_launch_checklist.md`
   - Enforces architectural constraints and code standards
   - Use for: Any feature implementation, ticket management, checklist updates

2. **architecture-expert**
   - Deep expertise on Clean Architecture pattern
   - Riverpod state management patterns
   - Feature module structure and layer responsibilities
   - References: `docs/07_app_architecture.md`
   - Use for: Creating features, understanding architecture, code reviews

3. **schema-expert**
   - Firestore collections, schemas, and DTOs
   - Domain model transformations (Invoice, Expense, Client)
   - Caching strategies and cost control
   - References: `docs/05_data_model_and_schema.md`
   - Use for: Database design, DTOs, query optimization

4. **integration-expert**
   - Stripe integration via Cloud Functions (post-MVP)
   - Firebase Cloud Functions patterns
   - Email sending for invoices
   - References: `docs/06_integration_spec.md`
   - Use for: Backend integration, API endpoints, data fetching

5. **mvp-validator**
   - Quick scope validation against MVP requirements
   - Identifies scope creep and future roadmap items
   - References: `docs/02_mvp_prd.md`
   - Use for: Validating feature requests, checking acceptance criteria

### How to Use Skills

Skills are automatically invoked when you ask questions that match their expertise. You can also explicitly reference them:

- "Use the architecture-expert skill to help me create a new feature module"
- "Check with mvp-validator if this feature is in scope"
- "Use gigledger-dev to implement this GitHub ticket"

All skills reference the `docs/` folder as the single source of truth.

## Ticket Selection

When choosing which GitHub issues to work on, **always reference `docs/11_ticket_selection_guide.md`** for the current prioritization strategy.

### Quick Selection Rules

1. **Pick tickets with `ready-to-work` label (without `post-mvp`)** - These are your top priority
2. **IMMEDIATELY set issue to "In Progress"** - Prevents duplicate work by others
3. **Avoid tickets with `blocked` or `blocked-by-pr` labels** - Wait for dependencies
4. **Save `post-mvp` tickets for later** - Tests, analytics, performance should come after core features
5. **Handle `user-config` tickets as needed** - These require manual setup, not code changes

### Starting Work on a Ticket

**As soon as you decide to work on an issue:**

```bash
# Method 1: Update in GitHub Projects board
# Visit: https://github.com/users/kamal-haider/projects/6
# Drag issue to "In Progress" column

# Method 2: Add label and comment
gh issue edit <number> --add-label "in-progress"
gh issue comment <number> --body "Started working on this"
```

**This prevents others from picking the same work.**

### Filter Commands

```bash
# What should I work on now?
gh issue list --label "ready-to-work" --search "-label:post-mvp"

# What's blocked (don't pick)?
gh issue list --label "blocked"
gh issue list --label "blocked-by-pr"

# What's for post-MVP phase?
gh issue list --label "post-mvp"
```

**Full details:** See `docs/11_ticket_selection_guide.md`

## Git Workflow & Branch Strategy

### Branch Naming Convention

**CRITICAL RULE: NEVER push directly to `main`. Always use feature branches and create pull requests.**

### ⚠️ MANDATORY: Agent Pre-Commit Checklist

**STOP! Before ANY commit, verify:**

```
□ Am I on a feature branch? (NOT main)
  → Run: git branch --show-current
  → If "main", STOP and create feature branch first!

□ Does an issue exist for this work?
  → If no, create one first with gh issue create

□ Is the issue marked "in-progress"?
  → If no, mark it: gh issue edit <num> --add-label "in-progress"
```

**If on main branch, fix immediately:**
```bash
# 1. Create the feature branch with your commits
git branch feature/your-feature-name

# 2. Reset main to origin
git checkout main
git reset --hard origin/main

# 3. Switch to feature branch and continue
git checkout feature/your-feature-name
```

**Branch protection is enabled** - Direct pushes to `main` will be rejected. See `docs/13_branch_protection_setup.md` for details.

Branch naming format:
```
feature/<descriptive-name>
bugfix/<descriptive-name>
docs/<descriptive-name>
refactor/<descriptive-name>
```

**Examples:**
- `feature/onboarding-flow` - New onboarding feature
- `feature/user-profile` - User profile implementation
- `bugfix/auth-error` - Fix authentication bug
- `docs/update-architecture` - Documentation updates
- `refactor/clean-architecture` - Architecture refactoring

**Creating a feature branch:**
```bash
# Create and switch to new branch
git checkout -b feature/your-feature-name

# Push and set upstream
git push -u origin feature/your-feature-name
```

### Pull Request Workflow

1. **Create feature branch** from `main`
2. **Implement feature** with commits
3. **Push branch** to GitHub
4. **Create PR** targeting `main`
5. **Wait for review** - do not merge without approval
6. **Address feedback** by pushing new commits to same branch
7. **Merge after approval** - maintainer will merge

### Multi-PR Feature Development

For complex features that require multiple PRs, use this workflow to enable parallel development while maintaining quality gates:

**Key Principles:**
- PRs can be merged into feature branches **without user review**
- Only PRs from feature branches to `main` require **user UAT approval**
- Features don't go into `main` until ready for MVP validation

**Workflow:**

1. **Create main feature branch** from `main`
   ```bash
   git checkout main && git pull
   git checkout -b feature/invoicing
   git push -u origin feature/invoicing
   ```

2. **Create sub-branches for incremental work**
   ```bash
   # First, switch to the feature branch
   git checkout feature/invoicing
   # Then create sub-branches from it
   git checkout -b feature/invoicing-domain
   # (repeat for other sub-branches)
   git checkout feature/invoicing
   git checkout -b feature/invoicing-data
   ```

3. **Create PRs targeting the feature branch** (not main)
   ```bash
   # PR targets feature/invoicing, not main
   gh pr create --base feature/invoicing --title "Add invoice domain models"
   ```

4. **Merge sub-PRs without user review**
   - These can be merged autonomously using squash merge:
     ```bash
     gh pr merge <number> --squash --delete-branch
     ```
   - Run `flutter analyze` and `flutter test` before merging
   - Periodically sync feature branch with main to avoid conflicts:
     ```bash
     git checkout feature/invoicing
     git merge main
     # Resolve any conflicts, then push
     git push
     ```

5. **When feature is complete, create PR to main**
   ```bash
   gh pr create --base main --title "feat: Implement Invoicing Feature"
   ```
   - This PR requires **user UAT approval**
   - Summarize all changes from sub-PRs
   - Include test plan for end-to-end validation

6. **After PR to main is merged, clean up**
   ```bash
   # The feature branch will be deleted automatically if using --delete-branch
   # Pull latest main
   git checkout main && git pull
   ```

**Handling Merge Conflicts:**

If conflicts arise when merging sub-PRs or syncing with main:
1. Checkout the branch with conflicts
2. Merge the target branch: `git merge feature/invoicing` (or `main`)
3. Resolve conflicts in your editor
4. Commit the resolution: `git add . && git commit -m "Resolve merge conflicts"`
5. Push the resolved branch

**Using Git Worktrees for Parallel Development:**

Git worktrees allow you to have multiple branches checked out simultaneously in different directories, enabling true parallel development without constantly switching branches.

```bash
# Create worktrees for parallel feature development
git worktree add ../GigLedger-clients feature/clients
git worktree add ../GigLedger-expenses feature/expenses
git worktree add ../GigLedger-settings feature/settings

# Work in each worktree independently
cd ../GigLedger-clients
# ... make changes, commit, push, create PR

# Clean up worktrees when done
git worktree remove ../GigLedger-clients
```

**Review Gates Summary:**
| PR Target | Review Required | Who Merges |
|-----------|-----------------|------------|
| Feature branch | No | Developer/Claude |
| `main` | Yes (UAT) | User after testing |

### Merging a PR (Standard Process)

When asked to merge a PR, follow this complete process:

1. **Merge the PR**
   ```bash
   gh pr merge <number> --squash --delete-branch
   ```

2. **Close the related issue** (if not auto-closed)
   ```bash
   gh issue close <number> --comment "Completed via PR #<pr-number>"
   ```

3. **Update issue labels** - Remove work-in-progress labels
   ```bash
   gh issue edit <number> --remove-label "in-progress,ready-to-work"
   ```

4. **Check for unblocked issues** - Find issues that were blocked by this work
   ```bash
   gh issue list --search "#<number> in:body,comments" --state open
   gh issue list --label "blocked" --limit 20
   ```

5. **Unblock dependent issues** - For each issue that was blocked by this:
   ```bash
   gh issue edit <blocked-number> --remove-label "blocked" --add-label "ready-to-work"
   gh issue comment <blocked-number> --body "Unblocked by #<completed-number>"
   ```

6. **Pull latest main**
   ```bash
   git checkout main && git pull
   ```

### Handling PR Review Feedback

When told that a review came back for a PR, or asked to check/address PR reviews:

1. **Review the feedback** - Read all review comments on the PR

2. **Fix issues** - Address any problems identified in the review
   - Make necessary code changes
   - Run tests to ensure fixes work
   - Run analyze/lint commands to check for issues

3. **Create follow-up issues** - For items that should be deferred:
   - Check if an issue already exists for the topic
   - If not, create a new issue with clear description
   - Add appropriate labels (`post-mvp`, `enhancement`, `bug`, etc.)
   ```bash
   gh issue create --title "Description" --body "Details"
   gh issue edit <number> --add-label "post-mvp,enhancement"
   ```

4. **Commit and push** - Push fixes to the same branch
   ```bash
   git add . && git commit -m "Address PR review feedback"
   git push
   ```

5. **Add PR comment** - Summarize what was addressed
   ```bash
   gh pr comment <number> --body "## Review Feedback Addressed

   - Fixed: [description]
   - Created issue #X for [deferred item]
   "
   ```

### Commit Message Format

Use descriptive commit messages with the Claude Code footer:

```
Brief summary of change (50 chars or less)

More detailed explanation if needed. Explain what and why,
not how. Wrap at 72 characters.

- Bullet points for specific changes
- Reference issue numbers: #123

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <model-name> <noreply@anthropic.com>
```

## Backlog Management

### Creating New Issues

When you identify work that needs tracking:

**1. Create the issue:**
```bash
gh issue create --title "Descriptive title" --body "Description with context"
```

**2. Add appropriate labels:**
```bash
# For work that's ready immediately
gh issue edit <number> --add-label "ready-to-work"

# For work blocked by something
gh issue edit <number> --add-label "blocked"
gh issue comment <number> --body "Blocked by #123"

# For post-MVP work
gh issue edit <number> --add-label "post-mvp"

# Add category labels
gh issue edit <number> --add-label "enhancement,[tech-label]"
```

**3. Link to related issues/PRs if applicable:**
```bash
gh issue comment <number> --body "Related to #123\nBlocks #456"
```

### Issue Template

Use this format for well-structured issues:

```markdown
## Description

Brief explanation of what needs to be done and why.

## Current Problem

What issue does this solve? What's the current behavior?

## Proposed Solution

How should this be implemented? What's the approach?

## Acceptance Criteria

- [ ] Specific requirement 1
- [ ] Specific requirement 2
- [ ] Tests added/updated
- [ ] Documentation updated

## References

- Related issue: #123
- Documentation: docs/[relevant-doc].md

## Priority

Low/Medium/High - explanation of urgency
```

### When to Create Issues vs Fix Directly

**Create an issue when:**
- Work takes more than 30 minutes
- Multiple files will be changed
- Needs discussion or design decisions
- Should be tracked for project management
- Might be deferred to post-MVP

**Fix directly (no issue needed):**
- Typos in comments or docs
- Obvious bugs with clear 1-line fixes
- Formatting/linting issues
- Quick documentation updates

**Quick fixes still need:**
- Descriptive commit message
- PR for review (don't push to main!)

## Commands

### Development
```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Run on specific platform (if applicable)
flutter run -d chrome        # Web
flutter run -d macos          # macOS
flutter run -d ios            # iOS simulator
```

### Testing
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/path/to/test_file.dart

# Run tests with coverage
flutter test --coverage
```

### Code Quality
```bash
# Analyze code
flutter analyze

# Format code
flutter format lib/
```

### Build
```bash
# Build for production
flutter build apk           # Android
flutter build ios           # iOS
flutter build web           # Web
```

## Architecture

### High-Level Structure
The app follows **Clean Architecture + Feature-Based Structure** with four layers:

1. **Presentation** - UI widgets/components, pages, state management
2. **Application** - Use cases, business logic services
3. **Domain** - Models, repository interfaces
4. **Data** - DTOs, data sources, repository implementations

### Directory Layout
```
lib/
├── core/              # Shared utilities, errors, constants, networking
├── features/          # Feature modules
│   └── [feature]/
│       ├── presentation/  # Pages, widgets, state
│       ├── application/   # Use cases, services
│       ├── domain/        # Models, repository interfaces
│       └── data/          # DTOs, data sources, repository implementations
├── app/
│   ├── app.[ext]
│   └── router.[ext]
└── main.[ext]
```

Each feature follows the same four-layer structure internally.

### State Management
- **Riverpod** is the chosen state management solution
- One state object per screen
- Immutable state patterns
- Async data handled via AsyncValue

### Data Flow
```
UI Component → State Provider → Use Case → Repository (Domain)
  → Repository Impl (Data) → Firestore/Backend
```

## Critical Architectural Rules

### Backend Communication
- **NEVER call Stripe API directly from the client** (post-MVP payment processing)
- All external API calls must be proxied through Cloud Functions
- Client only communicates with:
  - Firestore (read/write user-scoped data)
  - Firebase Storage (receipt image uploads)
  - Cloud Functions (email sending, Stripe operations)

### Data Storage Philosophy
1. Database stores **snapshots and derived insights**, not raw streams
2. Heavy computation happens **server-side**
3. Client models are optimized for UI, not storage
4. Completed data is immutable and cached permanently
5. Avoid storing raw time-series data (cost control)

### DTO vs Domain Models
- **DTOs** (data layer): Match database structure, flat, nullable, defensive
- **Domain Models** (domain/application layers): Computed fields allowed, non-null where possible
- Example: `[Item]DTO` → `[Item]`

## Database Collections (MVP)

Key collections:
- `users/{uid}` - User profiles, business settings, preferences
  - `clients/{clientId}` - Client contact info and notes
  - `invoices/{invoiceId}` - Invoice data with denormalized client info
  - `expenses/{expenseId}` - Expense records with receipt URLs
- `invoiceTemplates/{templateId}` - Shared invoice templates (read-only)

All user data is scoped to `users/{uid}` and only accessible by that user. Invoice templates are read-only for clients.

## Documentation Structure

All product decisions live in `docs/` - **this is the source of truth**:

| Document | Purpose |
|----------|---------|
| `00_document_usage_guide.md` | When to reference each doc |
| `01_vision_and_positioning.md` | Product identity & differentiation |
| `02_mvp_prd.md` | MVP scope & acceptance criteria |
| `03_user_personas_and_jobs.md` | Target users & motivations |
| `04_information_architecture_and_screens.md` | Screen map & navigation |
| `05_data_model_and_schema.md` | Database structure & caching |
| `06_integration_spec.md` | External API integration |
| `07_app_architecture.md` | App structure |
| `08_monetization_and_pricing.md` | Free vs Pro model |
| `09_roadmap.md` | Development phases |
| `10_launch_checklist.md` | Production readiness |
| `11_ticket_selection_guide.md` | GitHub issue prioritization & labels |
| `12_security_rules.md` | Security rules documentation |

**Rule:** If it's not in the docs, it's not a requirement.

## MVP Scope

### In Scope
- **Authentication**: Google, Apple, Email/Password sign-in
- **Dashboard**: Income/expense/profit summary, quick actions, recent activity
- **Invoicing**: Create, send, track invoices with templates (Draft/Sent/Paid/Overdue)
- **Expenses**: Add expenses with photo receipts, categorization, filtering
- **Clients**: Client database with contact info, notes, invoice history
- **Reports**: Basic income vs expense charts, top clients, category breakdown
- **Settings**: Business profile, currency, tax rate, payment instructions
- **Freemium**: Free tier (5 clients, 10 invoices/mo) + Pro tier ($9.99/mo)

### Explicitly Out of Scope (Future Roadmap)
- Recurring invoices
- In-app payment processing (Stripe checkout)
- Bank account sync (Plaid)
- OCR receipt scanning
- Time tracking
- Multi-currency per invoice
- Team/multi-user accounts
- Estimates/quotes
- Mileage tracking

## Development Guidelines

### Feature Implementation
1. Reference the relevant documentation before coding
2. Validate against acceptance criteria in PRD
3. Follow the four-layer architecture pattern
4. Ensure client never bypasses domain layer
5. Add use cases to application layer for business logic
6. Keep DTOs in data layer, domain models elsewhere

### Code Organization
- Keep features isolated in their own directories
- Share common code via `core/`
- Use declarative routing with named routes per feature

### Testing Strategy
- **Unit tests**: Domain models, use cases, aggregation logic
- **Widget/Component tests**: Core screens, critical interactions
- **Integration tests**: Database read flows, navigation paths

### Platform Considerations
- Responsive layouts
- Test performance on all target platforms
- Avoid platform-specific code where possible

### Security
- No API keys or secrets in client code
- All data scoped to authenticated user (`users/{uid}/...`)
- Users can only read/write their own data (enforced by Firestore rules)
- Receipt images stored in user-specific Firebase Storage paths

### Performance
- Enable database persistence for offline support
- Use in-memory caching for expensive operations
- Avoid rebuilding expensive UI unnecessarily
- Prefer server-aggregated data over client-side computation
- Use pagination for large data sets

## Scope Management

GigLedger is designed to be built deliberately, not rushed. When implementing features:

- Check the docs **first** before making architectural decisions
- If something is unclear and not documented, **update the docs before writing code**
- Avoid scope creep - future ideas go to the roadmap, not MVP
- Checkbox statuses should be updated in `10_launch_checklist.md` as things progress
- Any questions that come up that could affect the development should be tracked
