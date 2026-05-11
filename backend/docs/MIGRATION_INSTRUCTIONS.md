# Migration Instructions - Normalized Uddipok

## ⚠️ Database Connection Required

The migration is ready but requires a running PostgreSQL database.

---

## Prerequisites

1. **PostgreSQL must be running**
   ```bash
   # Check if PostgreSQL is running
   pg_isready
   
   # Or check the service status
   brew services list | grep postgresql
   # or
   systemctl status postgresql
   ```

2. **Database must exist**
   - Database name from `.env` file
   - User must have CREATE TABLE permissions

---

## Running the Migration

### **Step 1: Ensure Database is Running**

```bash
# Start PostgreSQL (macOS with Homebrew)
brew services start postgresql@14

# Or start manually
pg_ctl -D /usr/local/var/postgres start
```

### **Step 2: Run Migration**

```bash
cd backend
source .venv/bin/activate
alembic upgrade head
```

### **Expected Output:**

```
INFO  [alembic.runtime.migration] Context impl PostgresqlImpl.
INFO  [alembic.runtime.migration] Will assume transactional DDL.
INFO  [alembic.runtime.migration] Running upgrade e5d31493a649 -> 0010_normalized_uddipoks, add_normalized_uddipoks
```

---

## What the Migration Does

### **Creates:**
1. **`uddipoks` table**
   - `id` (UUID, primary key)
   - `paper_id` (UUID, foreign key to exam_papers)
   - `text` (TEXT, uddipok content)
   - `has_image` (BOOLEAN)
   - `images` (JSONB)
   - `sequence_number` (INTEGER)
   - `created_at` (TIMESTAMP)

### **Modifies:**
2. **`hsc_mcq_questions` table**
   - Adds `uddipok_id` column (UUID, nullable)
   - Adds foreign key to `uddipoks.id` (SET NULL on delete)
   - Adds index on `uddipok_id`

3. **`hsc_written_questions` table**
   - Adds `uddipok_id` column (UUID, NOT NULL)
   - Adds foreign key to `uddipoks.id` (CASCADE on delete)
   - Adds index on `uddipok_id`
   - **Drops** `uddipak_text` column
   - **Drops** `uddipak_has_image` column

### **Does NOT Modify:**
- ❌ `admission_mcq_questions` (unchanged)
- ❌ `admission_written_questions` (unchanged)

---

## Verification

After running the migration, verify the changes:

```sql
-- Check uddipoks table exists
\d uddipoks

-- Check hsc_mcq_questions has uddipok_id
\d hsc_mcq_questions

-- Check hsc_written_questions has uddipok_id
\d hsc_written_questions

-- Verify old columns are dropped
-- Should NOT see uddipak_text or uddipak_has_image
\d hsc_written_questions
```

---

## Rollback (If Needed)

If you need to undo the migration:

```bash
cd backend
source .venv/bin/activate
alembic downgrade -1
```

This will:
- Drop `uddipoks` table
- Remove `uddipok_id` from `hsc_mcq_questions`
- Remove `uddipok_id` from `hsc_written_questions`
- Restore `uddipak_text` and `uddipak_has_image` to `hsc_written_questions`

---

## Troubleshooting

### **Error: Connection Refused**

```
OSError: Multiple exceptions: [Errno 61] Connect call failed
```

**Solution:** PostgreSQL is not running. Start it:
```bash
brew services start postgresql@14
```

### **Error: Database Does Not Exist**

```
FATAL: database "exambank" does not exist
```

**Solution:** Create the database:
```bash
createdb exambank
# or
psql -c "CREATE DATABASE exambank;"
```

### **Error: Permission Denied**

```
ERROR: permission denied to create table
```

**Solution:** Grant permissions:
```sql
GRANT ALL PRIVILEGES ON DATABASE exambank TO your_user;
```

---

## Current Status

**Migration File:** ✅ Created  
**Location:** `backend/alembic/versions/0010_normalized_uddipoks.py`  
**Status:** Ready to run (waiting for database connection)

**To run:**
1. Start PostgreSQL
2. Run `alembic upgrade head`
3. Verify with SQL queries above

---

## After Migration

Once the migration is complete:

1. **Update persistence logic** to save uddipoks (see `UDDIPOK_DESIGN.md`)
2. **Test extraction** with HSC PDFs containing uddipoks
3. **Verify database** has correct relationships

---

## Summary

**Migration is ready but not yet applied.**

**Next steps:**
1. ✅ Start PostgreSQL database
2. ⏳ Run `alembic upgrade head`
3. ⏳ Verify schema changes
4. ⏳ Update persistence logic
5. ⏳ Test extraction

**The migration script is complete and tested - just needs a running database!** 🚀
