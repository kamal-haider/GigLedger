# Security Rules

**Document ID:** 12
**Last Updated:** [DATE]
**Status:** Active

## Overview

This document describes the security rules implemented for GigLedger, explaining the security model and access control policies for each collection/resource.

## Security Principles

1. **Principle of Least Privilege** - Users only have access to data they need
2. **Authentication Required** - All access requires valid authentication (except public read-only data)
3. **Data Integrity** - Prevent tampering with system-managed fields (UIDs, timestamps, etc.)
4. **Backend-Controlled Writes** - [Protected data type] data is read-only for clients

## Rules Location

- **File:** `[rules file name]` (project root or config location)
- **Deploy Command:** `[deploy command]`
- **Test with Emulator:** `[emulator command]`

## Collection-by-Collection Rules

### Users Collection (`/users/{uid}`)

**Purpose:** Store user profile data including preferences, favorites, and onboarding status.

**Access Rules:**
```javascript
match /users/{uid} {
  // Read: Users can only read their own profile
  allow read: if isOwner(uid);

  // Create: Users can create their own profile with matching UID
  allow create: if isOwner(uid)
                && request.resource.data.uid == request.auth.uid;

  // Update: Users can update their own profile but cannot change UID
  allow update: if isOwner(uid)
                && request.resource.data.uid == resource.data.uid;

  // Delete: Users can delete their own profile
  allow delete: if isOwner(uid);
}
```

**Security Measures:**
- Users can only access their own profile
- UID tampering prevented during creation
- UID modification prevented during updates
- Fields like `hasCompletedOnboarding` can be modified by user (intentional)

---

### [Protected Data] Collections (Read-Only)

The following collections contain [data type] populated by backend. Users can read this data but cannot modify it.

**Collections:**
- `/[collection1]/{id}` - [Description]
- `/[collection2]/{id}` - [Description]
- `/[collection3]/{id}` - [Description]
- `/[collection4]/{id}` - [Description]

**Access Rules:**
```javascript
match /[collection]/{id} {
  allow read: if true;       // Public read access
  allow write: if false;     // No client writes allowed
}
```

**Security Rationale:**
- Data integrity must be maintained
- Only backend should populate this data
- Users need read access to display information
- `allow read: if true` is safe because data is non-sensitive and public

---

### Default Deny Rule

All other collections not explicitly matched are denied by default:

```javascript
match /{document=**} {
  allow read, write: if false;
}
```

This ensures new collections are secure by default.

## Helper Functions

### `isAuthenticated()`

Checks if request has valid authentication.

```javascript
function isAuthenticated() {
  return request.auth != null;
}
```

### `isOwner(uid)`

Checks if authenticated user owns the resource.

```javascript
function isOwner(uid) {
  return isAuthenticated() && request.auth.uid == uid;
}
```

## Testing Security Rules

### Using Emulator

1. **Start Emulator:**
   ```bash
   [emulator start command]
   ```

2. **Run the app against emulator**

3. **Test scenarios:**
   - User can read their own profile
   - User can update their own profile
   - User cannot read another user's profile
   - User cannot write to another user's document
   - User cannot tamper with UID during create/update
   - User can read [protected data]
   - User cannot write [protected data]

### Automated Testing (Future Enhancement)

Consider using [testing framework] for unit testing security rules.

## Deployment

### Deploy Rules

```bash
[deploy command]
```

### Verify deployment

```bash
[verify command]
```

## Compliance & Best Practices

### Implemented

- Users can only access their own data
- Authentication required for user data access
- UID tampering protection
- Read-only enforcement for backend-managed collections
- Default deny for unknown collections

### Future Considerations

- **Field-level validation** - Could add validation for specific fields
- **Rate limiting** - Consider backend rate limiting for write-heavy operations
- **Audit logging** - Enable audit logs in production for security monitoring
- **Data encryption** - Already handled by [provider] (encryption at rest by default)

## Related Documentation

- [Data Model and Schema](./05_data_model_and_schema.md)
- [App Architecture](./07_app_architecture.md)

## Change Log

| Date | Version | Changes |
|------|---------|---------|
| [DATE] | 1.0 | Initial security rules |

## Security Contacts

For security concerns or questions about these rules, please:
1. Create a GitHub issue with `security` label
2. For critical vulnerabilities, contact the team privately

---

**Last Reviewed:** [DATE]
**Next Review:** Before production launch
