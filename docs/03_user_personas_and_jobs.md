# GigLedger — User Personas & Jobs-To-Be-Done

## Purpose

This document defines the **core user personas** for GigLedger and maps their
primary **Jobs-To-Be-Done (JTBD)**.

These personas guide:
- Feature prioritization
- UX decisions
- Monetization strategy
- Messaging and positioning

---

## Persona 1: Sarah the Solo Designer (Primary)

### Profile
- 32 years old, freelance graphic designer
- 4 years freelancing full-time, $75K/year revenue
- Works with 8-12 active clients at any time
- Tech-savvy but hates accounting software
- Works primarily from home office and coffee shops

### Pain Points
- Spends 4+ hours/month creating and chasing invoices
- Loses receipts and misses tax deductions
- Uses 4 different apps (invoicing, expenses, notes, spreadsheet)
- Dreads quarterly tax estimates

### Jobs-To-Be-Done
- **"Help me send professional invoices without feeling like an accountant"**
- **"Track my expenses so I don't panic at tax time"**
- **"Know at a glance if I'm actually making money this month"**
- **"Keep client details organized so I don't look unprofessional"**

### Success Criteria
- Invoice creation feels as easy as sending a text
- Tax time takes hours, not days
- Can answer "How's business?" with actual numbers

---

## Persona 2: Marcus the Side Hustler

### Profile
- 28 years old, full-time software developer
- Freelance web development on weekends, $15K/year side income
- 3-5 clients per year, project-based
- Wants minimal admin overhead
- Values simplicity over features

### Pain Points
- Forgets to invoice clients (leaves money on table)
- Mixes personal and business expenses
- Doesn't know if side hustle is actually profitable
- Overwhelmed by "enterprise" accounting tools

### Jobs-To-Be-Done
- **"Help me invoice quickly so I can get back to actual work"**
- **"Separate my freelance finances from personal spending"**
- **"Tell me if my side hustle is worth the time"**

### Success Criteria
- Spends less than 15 minutes/month on admin
- Clear separation of business vs personal finances
- Easy year-end summary for tax filing

---

## Persona 3: Elena the Established Consultant

### Profile
- 45 years old, management consultant
- 10+ years freelancing, $150K/year revenue
- 15-20 clients, mix of retainer and project work
- Previously used QuickBooks, found it overkill
- Needs professional appearance for corporate clients

### Pain Points
- QuickBooks too complex for solo business
- Needs polished invoices for enterprise clients
- Tracks expenses across multiple projects
- Wants quarterly tax estimates to avoid surprises

### Jobs-To-Be-Done
- **"Make my business look established and professional"**
- **"See profitability by client to focus on best relationships"**
- **"Prepare for quarterly estimated taxes without an accountant"**
- **"Have all client history in one place before meetings"**

### Success Criteria
- Invoices impress corporate clients
- Can answer "Which clients should I fire?" with data
- Quarterly taxes are predictable, not stressful

---

## Persona 4: Alex the Creative Freelancer (Secondary)

### Profile
- 25 years old, photographer and videographer
- 2 years freelancing, $40K/year and growing
- Mostly shoots events and small business content
- Heavy mobile user, rarely at a desk
- Price-sensitive, watches every expense

### Pain Points
- Needs to invoice on-site immediately after shoots
- Many small expenses (equipment, props, travel)
- Irregular income makes budgeting hard
- Free tools feel janky, paid tools too expensive

### Jobs-To-Be-Done
- **"Invoice from my phone right after a gig"**
- **"Snap receipts before I lose them"**
- **"Know if I can afford to buy new equipment"**
- **"Find an affordable tool that doesn't suck"**

### Success Criteria
- Can complete all tasks from phone
- Never loses another receipt
- Free tier is genuinely useful, not crippled

---

## Key JTBD Summary Table

| Job | Persona(s) |
|-----|------------|
| Create invoices quickly (< 60 sec) | 1, 2, 4 |
| Track expenses with receipts | 1, 3, 4 |
| See profit/loss at a glance | 1, 2, 3 |
| Manage client relationships | 1, 3 |
| Prepare for tax time | 1, 2, 3 |
| Look professional to clients | 1, 3 |
| Work entirely from mobile | 4 |
| Minimal learning curve | 2, 4 |

---

## Implications for MVP

### What This Means for Features
- Invoice creation must be under 60 seconds (all personas)
- Receipt photo capture is essential (mobile-first for Alex)
- Dashboard must show profit clearly (everyone asks "am I making money?")
- Client history view before invoicing (Sarah, Elena)
- Export for tax prep is a must-have (all personas)

### What This Means for Monetization
- Free tier must be useful, not frustrating (attracts Alex, Marcus)
- Pro upgrade for volume users (Sarah, Elena hit limits)
- Professional invoice templates drive upgrades (Elena needs polish)
- Price point must be < QuickBooks ($9.99/mo ceiling)

---

## Design Principles Derived

1. **Speed over features** — Every screen should be completable in under 30 seconds
2. **Mobile-first** over desktop-optional — Design for phone, scale up to tablet
3. **Clarity over comprehensiveness** — Show what matters, hide the rest
4. **Approachable** over powerful — Feel like a consumer app, not accounting software

These principles guide all future design and engineering decisions.

---

## Exit Criteria

This document is complete when:
- All primary personas are defined
- Jobs-to-be-done are clear and actionable
- Design principles can guide decisions
