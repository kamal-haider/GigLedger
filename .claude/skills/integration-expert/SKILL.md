---
name: integration-expert
description: Expert on external API integration, backend proxy architecture, backend functions, rate limiting, and data fetching strategies. Use when integrating with external services, designing backend functions, or understanding how data flows from external sources to the database. References docs/06_integration_spec.md.
---

# GigLedger Integration Expert

## Purpose

This skill provides deep expertise on external API integration:

- Backend proxy architecture
- External endpoint usage patterns
- Rate limiting and throttling strategies
- Historical vs live data fetching
- Derived data computation server-side
- Error handling and fallbacks

## Source of Truth

**Primary Reference:** `docs/06_integration_spec.md`

This document is the authoritative source for all integration decisions.

## Integration Principles

**CRITICAL RULES:**

1. **No client communicates directly with external services**
2. **All external access is proxied through backend**
3. **Data is cached and reused**
4. **Derived insights are computed server-side**
5. **MVP avoids complex streaming protocols**

Reference: `docs/06_integration_spec.md` section 1

## Architecture Overview

```
Client App
  ↓ (HTTPS only)
Backend Functions (Proxy + Aggregation)
  ↓
External API
  ↓
Backend Functions (Process & Aggregate)
  ↓
Database (Cache + Derived Insights)
  ↓
Client App (Read-Only)
```

### Why This Architecture?

**Security:**
- No API keys exposed in client
- No direct external access from user devices
- Centralized rate limiting control

**Cost Control:**
- Deduplicate identical requests
- Aggressive server-side caching
- Store aggregated data, not raw streams

**Platform Safety:**
- No complex streaming protocols in MVP
- No token management on client
- Simpler review process

Reference: `docs/06_integration_spec.md` sections 1 & 2

## Access Mode (MVP)

### What We Use
- **Historical/REST endpoints** (read-only)
- **[Authentication type]**
- **Polling for live data** (controlled intervals)

### What We DON'T Use (MVP)
- Real-time streaming
- WebSockets
- Complex authenticated feeds
- Live telemetry streams

Reference: `docs/06_integration_spec.md` section 2

## Backend Components

### Backend Functions

**Purpose:** Proxy, aggregate, and cache external data

**Tech Stack:** [Your backend tech]

**Responsibilities:**

| Responsibility | Example |
|----------------|---------|
| API Proxy | Forward client requests to external services |
| Aggregation | Compute averages, summaries |
| Validation | Ensure data completeness before storing |
| Caching | Store results in database |
| Rate Limiting | Throttle identical requests |

**Example Function:**
```
export const get[Data] = functions.https.onCall(async (data, context) => {
  const { id } = data;

  // Check cache first
  const cached = await database
    .collection('[collection]')
    .doc(id)
    .get();

  if (cached.exists) {
    // Return cached data
    return cached.data();
  }

  // Fetch from external service
  const externalData = await fetchFromExternal(id);

  // Aggregate server-side
  const processed = processData(externalData);

  // Store in database
  await store[Data](id, processed);

  return processed;
});
```

## Data Fetch Strategy

### Historical/Completed Data
- Fetch once
- Cache permanently in database
- Mark as immutable
- Never refetch

**Backend Logic:**
```
async function fetchHistorical[Data](id: string) {
  // Check if already cached
  const cached = await database
    .collection('[collection]')
    .doc(id)
    .get();

  if (cached.exists && cached.data()?.status === 'completed') {
    return cached.data();  // Return cached, don't refetch
  }

  // Fetch from external service
  const data = await fetchFromExternal(id);

  // Store permanently
  await database
    .collection('[collection]')
    .doc(id)
    .set({ ...data, status: 'completed', immutable: true });

  return data;
}
```

---

### Live/In-Progress Data
- Poll at controlled intervals
- Update snapshots in database
- Stop polling when complete
- Mark as immutable once complete

---

## Derived Data (Critical)

**Key Principle:** Compute insights server-side, store results in database

### Aggregation Example

**Input:** Raw data from external service

**Output:** Aggregated insights in `[collection]`

**Computation:**
```
function computeInsights(rawData: RawType[], relatedData: RelatedType[]) {
  const computed = rawData.map(item => ({
    field1: calculateField1(item),
    field2: calculateField2(item, relatedData),
  }));

  return {
    items: computed,
    summary: computeSummary(computed),
  };
}
```

**Stored in:** `[collection]/{id}`

Reference: `docs/06_integration_spec.md` section 6

---

## Rate Limiting & Throttling

### Backend Controls

**Deduplication:**
```
const requestCache = new Map<string, Promise<any>>();

async function fetchWithDedup(url: string) {
  if (requestCache.has(url)) {
    return requestCache.get(url);
  }

  const promise = fetch(url).then(r => r.json());
  requestCache.set(url, promise);
  promise.finally(() => requestCache.delete(url));

  return promise;
}
```

### Client Controls

**Client NEVER:**
- Polls external service directly
- Requests raw endpoints
- Uses snapshot listeners excessively

**Client ONLY:**
- Calls backend functions
- Reads from database (cached data)
- Uses snapshot listeners sparingly (live data only)

Reference: `docs/06_integration_spec.md` section 7

---

## Error Handling

### External Service Errors

**Timeout:**
```
async function fetchWithRetry(url: string, retries = 3) {
  for (let i = 0; i < retries; i++) {
    try {
      const response = await fetch(url, { timeout: 5000 });
      return response.json();
    } catch (error) {
      if (i === retries - 1) throw error;
      await sleep(1000 * Math.pow(2, i));  // Exponential backoff
    }
  }
}
```

**Partial Data:**
```
async function fetchData(id: string) {
  try {
    const results = await Promise.allSettled([
      fetchPart1(id),
      fetchPart2(id),
      fetchPart3(id),
    ]);

    // Mark as degraded if any failed
    const degraded = results.some(r => r.status === 'rejected');

    return {
      part1: results[0].status === 'fulfilled' ? results[0].value : [],
      part2: results[1].status === 'fulfilled' ? results[1].value : [],
      part3: results[2].status === 'fulfilled' ? results[2].value : [],
      degraded,
    };
  } catch (error) {
    throw new Error('Failed to fetch data');
  }
}
```

### Client Behavior
- Show graceful degraded UI
- Never block navigation
- Display data freshness indicators

Reference: `docs/06_integration_spec.md` section 8

---

## Security Considerations

1. **No API keys exposed** - All in backend environment variables
2. **No client write access** - External data is read-only via proxy
3. **Backend validates all inputs** - Prevent injection attacks
4. **Rate limiting** - Prevent abuse of backend functions

---

## Non-Goals (MVP)

**NOT implemented in MVP:**
- Live telemetry replay
- Real-time streaming
- Predictive modeling
- Sub-second updates

**These are future roadmap items.**

Reference: `docs/06_integration_spec.md` section 11

---

## When to Use This Skill

Use this skill when:
- Designing backend functions to proxy external services
- Understanding which external endpoints to use
- Planning server-side aggregation logic
- Implementing rate limiting or throttling
- Handling external service errors and fallbacks
- Optimizing data fetching strategies
- Deciding what to cache vs recompute

## Quick Reference Checklist

When integrating external services:

- [ ] Never call external service from client - always use backend functions
- [ ] Identify which endpoints are needed
- [ ] Design aggregation logic for derived insights
- [ ] Implement caching in database
- [ ] Add rate limiting and deduplication
- [ ] Handle errors with retries and fallbacks
- [ ] Mark historical data as immutable
- [ ] Use polling (not streaming) for live data
- [ ] Transform external schema to internal format
- [ ] Test with known data to validate accuracy

## Summary

GigLedger's integration ensures:
- Secure backend-only access to external services
- Cost-effective caching and aggregation
- Client isolated from external schema changes
- Rate limiting prevents abuse
- Graceful degradation on errors

**Remember:** Always reference `docs/06_integration_spec.md` as the ultimate source of truth for integration.
