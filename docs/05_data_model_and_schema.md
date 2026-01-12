# GigLedger — Data Model & Schema

## Purpose

This document defines:
- Database collections/tables and documents
- Data ownership and lifecycle
- DTO vs domain model separation
- Caching and cost-control strategy

This is a **critical document** to ensure scalability, correctness, and cost efficiency.

---

## 1. Core Data Philosophy

### Key Principles
1. **[Principle 1 - e.g., Clients never talk directly to external APIs]**
2. **[Principle 2 - e.g., Database stores snapshots and derived insights]**
3. **[Principle 3 - e.g., Heavy computation happens server-side]**
4. **[Principle 4 - e.g., Client models are optimized for UI]**

---

## 2. Data Flow Overview

```txt
[External Source]
    ↓
[Backend Layer] (Proxy + Aggregation)
    ↓
[Database] (Cached Snapshots + Insights)
    ↓
[Client App] (Read-Optimized Models)
```

---

## 3. Database Collections/Tables (MVP)

**Implementation Note:** [Describe your structural decisions and why]

All collections below are **[access pattern]** for clients.

### 3.1 users/{uid}
Stores user profile and preferences.

```json
{
  "uid": "user123",
  "displayName": "User Name",
  "email": "user@example.com",
  "favorites": {
    "[category1]": ["item1", "item2"],
    "[category2]": ["itemA"]
  },
  "preferences": {
    "[preference1]": "value",
    "[preference2]": true
  },
  "hasCompletedOnboarding": true,
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

**Security:** Users can read/write only their own document.

---

### 3.2 [collection2]/{id}

[Description of what this collection stores]

```json
{
  "id": "123",
  "field1": "value",
  "field2": 123,
  "metadata": {
    "cachedAt": 1234567890,
    "expiresAt": 9999999999,
    "status": "completed",
    "source": "derived"
  }
}
```

**Cache:** [Cache strategy]

---

### 3.3 [collection3]/{id}

[Description]

```json
{
  "id": "456",
  "parentId": "123",
  "name": "Example",
  "data": {
    "field1": "value",
    "field2": []
  },
  "metadata": { ... }
}
```

**Cache:** [Cache duration/strategy]

---

### 3.4 [collection4]/{id}

**[Description - mark if this is a critical collection]**

```json
{
  "id": "789",
  "parentId": "456",
  "items": [
    {
      "subField1": "value",
      "subField2": 123
    }
  ],
  "summary": {
    "computedField1": 0.0,
    "computedField2": "value"
  },
  "metadata": { ... }
}
```

**Cache:**
- [Cache rule 1]
- [Cache rule 2]
- [Cache rule 3]

---

### 3.5 [collection5]/{parentId}/[subcollection]

[Description of subcollection]

```json
{
  "field1": "value",
  "field2": 123,
  "timestamp": "2024-01-01T00:00:00Z"
}
```

**Access:** [Access pattern]

**Query Pattern:**
```dart
final snapshot = await database
    .collection('[collection5]')
    .doc(parentId)
    .collection('[subcollection]')
    .orderBy('[field]')
    .get();
```

---

## 4. DTO vs Domain Models

### DTOs (Data Layer)
**Characteristics:**
- Match database structure exactly
- All fields nullable (defensive)
- Flat structure
- Include database-specific types
- Live in `lib/features/{feature}/data/dto/` or `data/models/`

**Example:**
```dart
class [Item]DTO {
  final String? id;
  final String? name;
  final Timestamp? createdAt;

  [Item]DTO.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        createdAt = json['createdAt'];

  [Item] toDomain() {
    return [Item](
      id: id ?? '',
      name: name ?? '',
      createdAt: createdAt?.toDate(),
    );
  }
}
```

### Domain Models (Domain Layer)
**Characteristics:**
- Optimized for application logic
- Non-null where possible (required fields)
- Rich behavior (methods, computed properties)
- Framework-agnostic
- Live in `lib/features/{feature}/domain/models/`

**Example:**
```dart
class [Item] {
  final String id;
  final String name;
  final DateTime? createdAt;

  [Item]({
    required this.id,
    required this.name,
    this.createdAt,
  });

  // Computed property
  bool get isNew => createdAt != null &&
      DateTime.now().difference(createdAt!).inDays < 7;
}
```

---

## 5. Indexing Strategy

**Required indexes:**
- [collection] by [field]
- [collection] by [field]
- [collection] by [field]

**Avoid:**
- Compound indexes on large collections
- Unbounded queries

---

## 6. Caching & Invalidation

### Cache Rules
- **[Data type 1]:** [cache strategy]
- **[Data type 2]:** [cache strategy]
- **User data:** always source-of-truth from database

### Invalidation
- [Trigger] → cache becomes [state]
- Manual refresh via backend if needed

---

## 7. Cost Control Safeguards

- No [expensive pattern 1]
- No [expensive pattern 2]
- Pagination on [list types]
- Aggregations stored once, reused many times

---

## 8. Security Rules (High-Level)

- Users can only read/write their own profile
- All [data type] data is read-only for clients
- No client-side writes to [protected collections]

See `12_security_rules.md` for detailed rules.

---

## 9. Non-Goals

- No [non-goal 1]
- No [non-goal 2]
- No [non-goal 3]

---

## 10. Exit Criteria

This schema is complete when:
- All MVP screens are supported
- No unbounded growth paths exist
- Derived data covers core feature needs
