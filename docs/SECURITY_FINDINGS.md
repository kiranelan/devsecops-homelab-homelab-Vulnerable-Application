# Security Findings and Expected Evidence

## Scope

Authorized testing is limited to the isolated application deployed from this repository. Do not point the test script at third-party systems.

| Finding | Location | Risk | Direct-app evidence | Control / remediation |
|---|---|---|---|---|
| SQL injection | `/search?q=` | Database disclosure or modification | Boolean payload returns unintended posts | Parameterized SQL; AWS managed SQLi WAF rules provide temporary edge protection |
| Stored XSS | `/comment` and home page | Browser session/data theft | Script-capable HTML is stored and rendered with `safe` | Remove `safe`, encode output, sanitize input, add CSP; Common Rule Set blocks common payloads |
| Header-based admin bypass | `/admin` | Privilege escalation | Spoofed `X-Forwarded-For` returns admin page | Server-side identity and role authorization; strip/untrust client proxy headers |
| IDOR / information disclosure | `/user/<id>` | User data exposure | Sequential IDs return other users | Require authentication and object-level authorization; minimize returned fields |
| Debug information disclosure | `/debug` | Credential and infrastructure leakage | Environment and DB configuration are rendered | Remove endpoint, redact secrets, disable debug features |
| Weak authentication | `/login` | Account compromise | Plain-text comparison and no throttling | Argon2/bcrypt, MFA, generic errors, lockout/rate limiting, secure sessions |
| Weak session defaults | Flask configuration | Session forgery/hijacking | Lab fallback secret is predictable | Require secret injection; set Secure, HttpOnly, SameSite cookies and rotation |

## Defense-in-depth validation

Capture the following for the submission:

1. `terraform plan` summary with no secret values.
2. `kubectl get nodes` and `kubectl get pods -A`.
3. `kubectl -n vulnerable-app describe deployment vulnerable-app` security context.
4. Direct application test results showing vulnerabilities.
5. WAF-routed results showing blocked SQLi and XSS payloads.
6. WAF CloudWatch metric/log sample with sensitive headers redacted.
7. GitHub Actions security report artifacts.

## Prioritization

1. Remove `/debug` and fix SQL injection before any broader exposure.
2. Fix stored XSS and replace authentication/session handling.
3. Add object-level authorization and remove header-trust logic.
4. Retain WAF, monitoring, network isolation, secrets management, and supply-chain scanning as layered controls.
