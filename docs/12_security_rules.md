# Security Rules

**Document ID:** 12
**Last Updated:** 2026-01-13
**Status:** Active

## Overview

This document describes the Firestore security rules implemented for GigLedger, explaining the security model and access control policies for each collection.

## Security Principles

1. **Principle of Least Privilege** - Users only have access to their own data
2. **Authentication Required** - All access requires valid Firebase Authentication
3. **Data Integrity** - Prevent tampering with system-managed fields (createdAt, userId)
4. **Field Validation** - Required fields are validated on create/update
5. **Default Deny** - All paths not explicitly allowed are denied

## Rules Location

- **File:** `firestore.rules` (project root)
- **Deploy Command:** `firebase deploy --only firestore:rules`
- **Test with Emulator:** `firebase emulators:start`

## Collection-by-Collection Rules

### Users Collection (`/users/{uid}`)

**Purpose:** Store user profile and business settings.

**Access Rules:**
```javascript
match /users/{uid} {
  // Read: Users can only read their own profile
  allow read: if isOwner(uid);

  // Create: Users can create their own profile with required fields
  allow create: if isOwner(uid)
                && hasRequiredFields(['email', 'currency', 'createdAt', 'updatedAt']);

  // Update: Users can update their own profile (createdAt immutable)
  allow update: if isOwner(uid)
                && request.resource.data.createdAt == resource.data.createdAt;

  // Delete: Users can delete their own profile
  allow delete: if isOwner(uid);
}
```

**Required Fields (create):**
- `email` - Non-empty string
- `currency` - Non-empty string (e.g., "USD")
- `createdAt` - Timestamp
- `updatedAt` - Timestamp

**Immutable Fields:**
- `createdAt` - Cannot be modified after creation

---

### Clients Collection (`/users/{uid}/clients/{clientId}`)

**Purpose:** Store client contact information and billing history.

**Access Rules:**
```javascript
match /clients/{clientId} {
  allow read: if isOwner(uid);
  allow create: if isOwner(uid)
                && request.resource.data.userId == request.auth.uid
                && hasRequiredFields(['name', 'createdAt', 'updatedAt']);
  allow update: if isOwner(uid)
                && preservesImmutableFields(['userId', 'createdAt']);
  allow delete: if isOwner(uid);
}
```

**Required Fields (create):**
- `userId` - Must match authenticated user's UID
- `name` - Non-empty string
- `createdAt` - Timestamp
- `updatedAt` - Timestamp

**Immutable Fields:**
- `userId` - Cannot be changed
- `createdAt` - Cannot be changed

---

### Expenses Collection (`/users/{uid}/expenses/{expenseId}`)

**Purpose:** Store expense records with optional receipt URLs.

**Access Rules:**
```javascript
match /expenses/{expenseId} {
  allow read: if isOwner(uid);
  allow create: if isOwner(uid)
                && request.resource.data.userId == request.auth.uid
                && hasRequiredFields(['amount', 'category', 'date', 'createdAt', 'updatedAt']);
  allow update: if isOwner(uid)
                && preservesImmutableFields(['userId', 'createdAt']);
  allow delete: if isOwner(uid);
}
```

**Required Fields (create):**
- `userId` - Must match authenticated user's UID
- `amount` - Number (can be 0)
- `category` - Non-empty string
- `date` - Timestamp
- `createdAt` - Timestamp
- `updatedAt` - Timestamp

**Immutable Fields:**
- `userId` - Cannot be changed
- `createdAt` - Cannot be changed

---

### Invoices Collection (`/users/{uid}/invoices/{invoiceId}`)

**Purpose:** Store invoice data with client reference and line items.

**Access Rules:**
```javascript
match /invoices/{invoiceId} {
  allow read: if isOwner(uid);
  allow create: if isOwner(uid)
                && request.resource.data.userId == request.auth.uid
                && hasRequiredFields(['clientId', 'status', 'createdAt', 'updatedAt']);
  allow update: if isOwner(uid)
                && preservesImmutableFields(['userId', 'createdAt']);
  allow delete: if isOwner(uid);
}
```

**Required Fields (create):**
- `userId` - Must match authenticated user's UID
- `clientId` - Non-empty string (reference to client)
- `status` - Non-empty string (draft, sent, paid, overdue)
- `createdAt` - Timestamp
- `updatedAt` - Timestamp

**Immutable Fields:**
- `userId` - Cannot be changed
- `createdAt` - Cannot be changed

---

### Invoice Templates (`/invoiceTemplates/{templateId}`)

**Purpose:** Shared invoice templates (read-only for clients).

**Access Rules:**
```javascript
match /invoiceTemplates/{templateId} {
  allow read: if isAuthenticated();
  allow write: if false; // Admin-only via Firebase Console
}
```

---

### Default Deny Rule

All other collections not explicitly matched are denied:

```javascript
match /{document=**} {
  allow read, write: if false;
}
```

This ensures new collections are secure by default.

## Helper Functions

### `isAuthenticated()`

```javascript
function isAuthenticated() {
  return request.auth != null;
}
```

### `isOwner(uid)`

```javascript
function isOwner(uid) {
  return isAuthenticated() && request.auth.uid == uid;
}
```

### `isNonEmptyString(field)`

```javascript
function isNonEmptyString(field) {
  return field is string && field.size() > 0;
}
```

### `isValidTimestamp(field)`

```javascript
function isValidTimestamp(field) {
  return field is timestamp;
}
```

## Deployment

### Deploy Rules

```bash
firebase deploy --only firestore:rules
```

### Verify Deployment

After deploying, test by:
1. Signing in as a user
2. Attempting to read/write own data (should succeed)
3. Attempting to access another user's data (should fail)

## Testing with Emulator

1. **Start Emulator:**
   ```bash
   firebase emulators:start
   ```

2. **Test scenarios:**
   - User can read their own profile ✓
   - User can create clients/expenses ✓
   - User cannot read another user's data ✗
   - User cannot modify userId/createdAt ✗
   - Required field validation works ✓

## Security Checklist

### Implemented
- [x] Users can only access their own data
- [x] Authentication required for all operations
- [x] userId tampering prevention
- [x] createdAt immutability
- [x] Required field validation
- [x] Default deny for unknown collections

### Future Considerations
- [ ] Rate limiting via Cloud Functions
- [ ] Audit logging for sensitive operations
- [ ] Field-level encryption for sensitive data

## Related Documentation

- [Data Model and Schema](./05_data_model_and_schema.md)
- [App Architecture](./07_app_architecture.md)

## Change Log

| Date | Version | Changes |
|------|---------|---------|
| 2026-01-13 | 1.0 | Initial security rules implementation |

---

**Last Reviewed:** 2026-01-13
**Next Review:** Before production launch
