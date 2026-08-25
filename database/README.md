# Database Configuration

This directory contains PostgreSQL database configuration and test data.

## Files

- **`init-db.sql`** - Database initialization script with test data
- **`postgres-values.yaml`** - Helm values for PostgreSQL deployment

## Test Data Included

- **Users** - 9 test users including admin accounts
- **Posts** - 11 test posts with security-focused content
- **Comments** - 6 test comments including XSS payloads
- **Additional objects** - A view and a PostgreSQL SQL function

## Usage

1. Deploy PostgreSQL using Helm:
   ```bash
   kubectl create namespace database
   kubectl -n database create secret generic postgres-credentials \
     --from-literal=postgres-password='<generated-admin-password>' \
     --from-literal=password='<generated-app-password>'
   helm upgrade --install postgresql \
     oci://registry-1.docker.io/bitnamicharts/postgresql \
     -n database -f postgres-values.yaml
   ```

2. Import test data:
   ```bash
   kubectl -n database cp init-db.sql postgresql-0:/tmp/init-db.sql
   kubectl -n database exec -it postgresql-0 -- \
     psql -U appuser -d vulnerable_app -f /tmp/init-db.sql
   ```

3. Verify data import:
   ```bash
   kubectl -n database exec -it postgresql-0 -- \
     psql -U appuser -d vulnerable_app -c "SELECT COUNT(*) FROM users;"
   ```

## Security Note

The test data contains intentionally vulnerable content for security testing purposes.
