---
name: schema-expert
description: Expert on GigLedger's database schema, collections, data models, DTOs, caching strategy, and cost control. Use when designing database schemas, creating DTOs, understanding data flow from database, or optimizing queries. References docs/05_data_model_and_schema.md.
---

# GigLedger Schema Expert

## Purpose

This skill provides deep expertise on GigLedger's database design:

- Collection/table structure and document schemas
- DTO (Data Transfer Object) patterns
- Domain model transformations
- Caching and invalidation strategies
- Cost control and optimization
- Security rules and access patterns

## Source of Truth

**Primary Reference:** `docs/05_data_model_and_schema.md`

This document is the authoritative source for all database design decisions.

## Core Data Philosophy

1. **Clients communicate through proper channels only**
2. **Database stores snapshots and derived insights, not raw streams**
3. **Heavy computation happens server-side**
4. **Client models are optimized for UI, not storage**

Reference: `docs/05_data_model_and_schema.md` section 1

## Database Collections (MVP)

### users/{uid}

**Purpose:** User profile and preferences

**Schema:**
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

**Access:** Read/write by authenticated user only (uid must match)

---

### [collection]/{id}

**Purpose:** [Description]

**Schema:**
```json
{
  "id": "123",
  "field1": "value",
  "field2": 123,
  "metadata": {
    "cachedAt": 1234567890,
    "status": "completed"
  }
}
```

**Access:** [Access pattern]

**Cache:** [Cache duration/strategy]

---

## DTO vs Domain Models

### DTO (Data Layer)
**Characteristics:**
- Match database structure exactly
- All fields nullable (defensive)
- Flat structure
- Include database-specific types
- Live in `lib/features/{feature}/data/dto/`

**Example:**
```
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

### Domain Model (Domain Layer)
**Characteristics:**
- Optimized for application logic
- Non-null where possible (required fields)
- Rich behavior (methods, computed properties)
- Framework-agnostic
- Live in `lib/features/{feature}/domain/models/`

**Example:**
```
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

### Transformation Pattern

Always transform in the data layer:

```
class [Database][Item]Repository implements [Item]Repository {
  @override
  Future<[Item]> get[Item](String id) async {
    final doc = await database
        .collection('[collection]')
        .doc(id)
        .get();

    // Transform DTO → Domain Model
    final dto = [Item]DTO.fromJson(doc.data()!);
    return dto.toDomain();
  }
}
```

## Caching & Invalidation

### Cache Rules

**Completed/historical data:**
- Fetch once
- Cache permanently
- Marked as immutable

**In-progress/live data:**
- Refresh on interval
- Stop polling when complete
- Update cache incrementally

**User data:**
- Always source-of-truth from database
- Use persistence for offline

### Client-Side Caching

Enable database persistence for offline support.

### Invalidation Strategy

- Data marked as completed → cache becomes permanent
- Manual refresh via backend if needed

Reference: `docs/05_data_model_and_schema.md` caching section

## Cost Control Safeguards

**Critical rules to prevent runaway costs:**

1. **No excessive granular storage** - Aggregate server-side instead
2. **No raw time-series storage** - Too granular
3. **Pagination on lists** - Use limits
4. **Aggregations stored once, reused many times**
5. **Historical data immutable** - Cache forever

Reference: `docs/05_data_model_and_schema.md` cost control section

### Query Optimization

**Good:**
```
// Limited query with specific fields
final items = await database
    .collection('[collection]')
    .where('field', isEqualTo: value)
    .limit(20)
    .get();
```

**Bad:**
```
// Unbounded query
final allItems = await database
    .collection('[collection]')
    .get();  // Could fetch thousands of documents!
```

## Security Rules (High-Level)

Reference: `docs/05_data_model_and_schema.md` and `docs/12_security_rules.md`

**User data:**
- Users can only read/write their own profile

**Protected data:**
- Read-only for clients
- Only backend can write

**No client-side writes to protected data** - Ever.

## Query Patterns

### Get Single Document

```
Future<[Item]> get[Item](String id) async {
  final doc = await database
      .collection('[collection]')
      .doc(id)
      .get();

  if (!doc.exists) {
    throw [Item]NotFoundException(id);
  }

  final dto = [Item]DTO.fromJson(doc.data()!);
  return dto.toDomain();
}
```

### Get Collection

```
Future<List<[Item]>> getAll[Items](String parentId) async {
  final snapshot = await database
      .collection('[parent]')
      .doc(parentId)
      .collection('[items]')
      .get();

  return snapshot.docs
      .map((doc) => [Item]DTO.fromJson(doc.data()).toDomain())
      .toList();
}
```

### Query with Filter

```
Future<List<[Item]>> get[Items]ByCategory(String category) async {
  final snapshot = await database
      .collection('[collection]')
      .where('category', isEqualTo: category)
      .orderBy('createdAt')
      .limit(20)
      .get();

  return snapshot.docs
      .map((doc) => [Item]DTO.fromJson(doc.data()).toDomain())
      .toList();
}
```

## Error Handling

```
Future<[Item]> get[Item](String id) async {
  try {
    final doc = await database
        .collection('[collection]')
        .doc(id)
        .get();

    if (!doc.exists) {
      throw [Item]NotFoundException('Item $id not found');
    }

    final dto = [Item]DTO.fromJson(doc.data()!);
    return dto.toDomain();
  } on DatabaseException catch (e) {
    if (e.code == 'permission-denied') {
      throw PermissionDeniedException();
    } else if (e.code == 'unavailable') {
      throw NetworkException('Database unavailable');
    }
    rethrow;
  }
}
```

## When to Use This Skill

Use this skill when:
- Designing new database collections
- Creating DTOs for existing collections
- Understanding data flow from database to domain
- Optimizing queries for cost control
- Writing repository implementations
- Transforming database data to domain models
- Setting up security rules
- Planning caching strategies

## Quick Reference Checklist

When working with database:

- [ ] Identify which collection(s) you need from `docs/05_data_model_and_schema.md`
- [ ] Create DTO in `data/dto/` matching database schema exactly
- [ ] Create domain model in `domain/models/` optimized for business logic
- [ ] Implement transformation `toDomain()` in DTO
- [ ] Create repository implementation in `data/repository_impl/`
- [ ] Use `.limit()` on all collection queries
- [ ] Handle errors (document not found, permission denied, etc.)
- [ ] Enable database persistence for offline support
- [ ] Never write to protected collections from client
- [ ] Test with emulator for integration tests

## Summary

GigLedger's database design ensures:
- Cost-effective storage (aggregated data, not raw streams)
- Client optimized for reads, not writes
- Clear DTO → Domain model separation
- Immutable historical data cached forever
- Security rules prevent unauthorized access

**Remember:** Always reference `docs/05_data_model_and_schema.md` as the ultimate source of truth for database design.
