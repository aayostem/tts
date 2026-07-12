1
00:00:00,000 --> 00:00:06,000
Welcome to Phase 6 of the Financial ai Agent series. This is where everything changes.

2
00:00:06,000 --> 00:00:12,000
In this phase, we transform how our application handles secrets. We move from static credentials in .env files to dynamic, rotating credentials managed by HashiCorp Vault.

3
00:00:12,000 --> 00:00:18,000
This is a mental shift. Up until now, we have been operating with trust. We trust that nobody steals our .env file. We trust that our database password doesn't leak.

4
00:00:18,000 --> 00:00:24,000
In production, trust is not a security strategy. We need to move to Zero-Trust. And Vault is the tool that gets us there.

5
00:00:24,000 --> 00:00:30,000
Before we install anything, let me explain the problem Vault solves. This is the most important part. If you understand the problem, the solution makes sense.

6
00:00:30,000 --> 00:00:36,000
In Phases 1 through 5, we used a .env file. POSTGRES_PASSWORD, OPENAI_API_KEY, REDIS_PASSWORD. All stored in plain text.

7
00:00:36,000 --> 00:00:42,000
This works for development. But in production, it creates three serious problems.

8
00:00:42,000 --> 00:00:48,000
Problem one: Static credentials. If POSTGRES_PASSWORD leaks, it works forever. Until someone manually rotates it, the attacker has access.

9
00:00:48,000 --> 00:00:54,000
Problem two: Shared credentials. Every pod uses the same password. If the ingestion service is compromised, the attacker has database access identical to the API service.

10
00:00:54,000 --> 00:01:00,000
Problem three: Environment variable exposure. Any process in the container can read os.environ. Secrets in files with restricted permissions are harder to exfiltrate.

11
00:01:00,000 --> 00:01:06,000
Vault solves all three problems. It provides dynamic credentials that rotate automatically. It provides per-role credentials. And it injects secrets as files, not environment variables.

12
00:01:06,000 --> 00:01:12,000
Now let me show you the architecture. This is how Vault works in Kubernetes.

13
00:01:12,000 --> 00:01:18,000
The Vault server runs in the cluster. It stores secrets and issues credentials. The Vault Agent sidecar runs alongside each pod. It handles authentication and secret renewal.

14
00:01:18,000 --> 00:01:24,000
The application container reads secrets from files in /vault/secrets/. It never talks to Vault directly.

15
00:01:24,000 --> 00:01:30,000
This separation is important. The application doesn't need to know about Vault. It just reads files. The Vault Agent handles all the complexity.

16
00:01:30,000 --> 00:01:36,000
Let me explain this using an analogy. Imagine a post office. The Vault server is the post office headquarters. It holds all the packages.

17
00:01:36,000 --> 00:01:42,000
The Vault Agent is the courier. It delivers packages to specific mailboxes. The Kubernetes service account JWT is the courier's passport. It proves identity.

18
00:01:42,000 --> 00:01:48,000
The Vault policy is the courier's clearance level. It determines which packages can be delivered. The /vault/secrets/ directory is the private mailbox.

19
00:01:48,000 --> 00:01:54,000
Only the application container can open it. The application never talks to the post office. It just opens the mailbox.

20
00:01:54,000 --> 00:02:00,000
This is the zero-trust model. Credentials are not stored in the application. They are not stored in Git. They are injected on demand and automatically rotated.

21
00:02:00,000 --> 00:02:06,000
Now let me show you the file tree for Phase 6. This is everything we are going to build.

22
00:02:06,000 --> 00:02:12,000
`infrastructure/vault/vault-bootstrap.sh`. This is the main setup script. It enables engines, configures connections, creates policies, and sets up auth.

23
00:02:12,000 --> 00:02:18,000
`infrastructure/vault/vault-agent-config.hcl`. This is the sidecar configuration. It tells Vault Agent which secrets to fetch and where to write them.

24
00:02:18,000 --> 00:02:24,000
`infrastructure/vault/policies/api-policy.hcl`. This defines what secrets the API service can access. Least privilege is the principle.

25
00:02:24,000 --> 00:02:30,000
`infrastructure/vault/policies/agent-policy.hcl`. This defines what secrets the agent pool can access. Different from the API.

26
00:02:30,000 --> 00:02:36,000
`infrastructure/vault/policies/ingestion-policy.hcl`. This defines what secrets the ingestion service can access. Even more restricted.

27
00:02:36,000 --> 00:02:42,000
`infrastructure/k8s/service-accounts.yaml`. One service account per workload. Vault binds to these.

28
00:02:42,000 --> 00:02:48,000
`src/financial_rag/security/vault.py`. This is the Python client. It reads secrets from Vault Agent files in production. It falls back to direct Vault API in development.

29
00:02:48,000 --> 00:02:54,000
Now let me explain the three Vault engines we will use. Each engine serves a different purpose.

30
00:02:54,000 --> 00:03:00,000
The Database Secrets Engine generates dynamic database credentials. When a pod requests a credential, Vault creates a new PostgreSQL user with a random password. That user is deleted when the lease expires.

31
00:03:00,000 --> 00:03:06,000
The PKI Secrets Engine issues TLS certificates. We use this for service-to-service mTLS. Each service gets a unique certificate.

32
00:03:06,000 --> 00:03:12,000
The Kubernetes Auth Method authenticates pods using their service account JWT. This is how Vault knows which pod is making a request.

33
00:03:12,000 --> 00:03:18,000
Now let's install Vault. We'll use the HashiCorp Helm chart.

34
00:03:18,000 --> 00:03:24,000
First, add the HashiCorp Helm repository.
[Types: helm repo add hashicorp https://helm.releases.hashicorp.com]

35
00:03:24,000 --> 00:03:30,000
This adds the HashiCorp repository to Helm. It contains the Vault chart.
[Types: helm repo update]

36
00:03:30,000 --> 00:03:36,000
We update the repository to get the latest charts.

37
00:03:36,000 --> 00:03:42,000
Create the vault namespace.
[Types: kubectl create namespace vault]

38
00:03:42,000 --> 00:03:48,000
This creates a dedicated namespace for Vault. We keep it separate from our application.

39
00:03:48,000 --> 00:03:54,000
Now install Vault in dev mode.
[Types: helm install vault hashicorp/vault --namespace vault --create-namespace --set "server.dev.enabled=true" --set "injector.enabled=true"]

40
00:03:54,000 --> 00:04:00,000
Dev mode is for learning only. It starts unsealed. It stores everything in memory. It loses all data on restart.

41
00:04:00,000 --> 00:04:06,000
We will upgrade to production HA at the end of this phase. But for now, dev mode is perfect. We can learn Vault without the operational overhead.

42
00:04:06,000 --> 00:04:12,000
Wait for Vault to be ready.
[Types: kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=vault -n vault --timeout=120s]

43
00:04:12,000 --> 00:04:18,000
This command waits for the Vault pod to be ready. It checks the pod status. It returns when the pod is running.

44
00:04:18,000 --> 00:04:24,000
Verify the installation.
[Types: kubectl exec -n vault vault-0 -- vault status]

45
00:04:24,000 --> 00:04:30,000
You should see Initialized: true. Sealed: false. Version: 1.15.x. This confirms Vault is running.

46
00:04:30,000 --> 00:04:36,000
If you see Sealed: true, Vault is locked. In dev mode, this should not happen. In production mode, sealed is the default state.

47
00:04:36,000 --> 00:04:42,000
Now let's test our installation. We'll use the Vault CLI to interact with Vault.

48
00:04:42,000 --> 00:04:48,000
[Types: kubectl exec -n vault vault-0 -- vault kv put secret/test message="Hello from Vault"]

49
00:04:48,000 --> 00:04:54,000
This writes a test secret to Vault. It's a simple key-value pair. It confirms that Vault is working.

50
00:04:54,000 --> 00:05:00,000
[Types: kubectl exec -n vault vault-0 -- vault kv get secret/test]

51
00:05:00,000 --> 00:05:06,000
This reads the test secret. You should see: Key: message. Value: Hello from Vault.

52
00:05:06,000 --> 00:05:12,000
If this works, Vault is installed correctly. You can write and read secrets. The basic functionality is working.

53
00:05:12,000 --> 00:05:18,000
Now let me explain the components we are about to configure. This is the roadmap for Phase 6.

54
00:05:18,000 --> 00:05:24,000
In Part 2, we run the bootstrap script. We enable the database engine. We create dynamic database roles.

55
00:05:24,000 --> 00:05:30,000
In Part 3, we enable PKI. We configure Kubernetes auth. We write the policies.

56
00:05:30,000 --> 00:05:36,000
In Part 4, we create the service accounts. We deploy the Vault Agent sidecar. We test the secret injection.

57
00:05:36,000 --> 00:05:42,000
In Part 5, we build the Python Vault client. We integrate it with our application. We see dynamic credentials in action.

58
00:05:42,000 --> 00:05:48,000
In Part 6, we configure production HA. We set up Raft storage. We enable AWS KMS auto-unseal. We set up snapshot backups.

59
00:05:48,000 --> 00:05:54,000
Now let me give you the mental model for Vault.

60
00:05:54,000 --> 00:06:00,000
Think of Vault as a security guard at the entrance of a building. The guard checks ID. The guard checks clearance level. The guard gives access only to the rooms you are authorized to enter.

61
00:06:00,000 --> 00:06:06,000
The building is your infrastructure. The rooms are your secrets. The ID is your service account JWT. The clearance level is your Vault policy.

62
00:06:06,000 --> 00:06:12,000
The guard never gives you the master key. The guard gives you a temporary key that works only for one hour. When the hour is up, the key stops working.

63
00:06:12,000 --> 00:06:18,000
This is the zero-trust model. Trust is not assumed. It is verified every single time a secret is requested.

64
00:06:18,000 --> 00:06:24,000
Now let me recap what we have covered in Part 1.

65
00:06:24,000 --> 00:06:30,000
We understood the problem. Static credentials are dangerous. They leak forever. They are shared across workloads. They are exposed in environment variables.

66
00:06:30,000 --> 00:06:36,000
We understood the solution. Vault provides dynamic credentials that rotate automatically. It provides per-role credentials for least privilege. It injects secrets as files, not environment variables.

67
00:06:36,000 --> 00:06:42,000
We understood the architecture. Vault server, Vault Agent sidecar, application container. The sidecar handles authentication and renewal. The app just reads files.

68
00:06:42,000 --> 00:06:48,000
We understood the three engines. Database Secrets Engine for dynamic DB credentials. PKI Engine for TLS certificates. Kubernetes Auth Method for pod authentication.

69
00:06:48,000 --> 00:06:54,000
We installed Vault in dev mode. We verified the installation. We tested basic functionality.

70
00:06:54,000 --> 00:07:00,000
In Part 2, we run the bootstrap script. We enable the database engine. We create dynamic database roles for each service.

71
00:07:00,000 --> 00:07:06,000
Thank you for watching. I'll see you in Part 2.

72
00:07:06,000 --> 00:07:10,000
[End of Part 1]
1
00:00:00,000 --> 00:00:06,000
Welcome back to Phase 6. In Part 2, we run the bootstrap script and configure the Database Secrets Engine.

2
00:00:06,000 --> 00:00:12,000
This is where Vault starts generating dynamic credentials. We move from static passwords to credentials that are created on demand and automatically expire.

3
00:00:12,000 --> 00:00:18,000
Open your editor and create `infrastructure/vault/vault-bootstrap.sh`.

4
00:00:18,000 --> 00:00:24,000
We'll start with the shebang. This tells the system to run the script with bash.
[Types: #!/usr/bin/env bash]

5
00:00:24,000 --> 00:00:30,000
We set error handling. `set -e` exits on error. `set -u` exits on undefined variables.
`set -o pipefail` exits if any command in a pipe fails.
[Types: set -euo pipefail]

6
00:00:30,000 --> 00:00:36,000
Now let's define the environment variables. These can be overridden.
[Types: VAULT_ADDR="${VAULT_ADDR:-http://127.0.0.1:8200}"]

7
00:00:36,000 --> 00:00:42,000
VAULT_ADDR is the address where Vault is running. Default is localhost:8200.
[Types: VAULT_TOKEN="${VAULT_TOKEN:-root}"]

8
00:00:42,000 --> 00:00:48,000
VAULT_TOKEN is the authentication token. Default is "root" for dev mode.
[Types: POSTGRES_ADMIN_PASSWORD="${POSTGRES_ADMIN_PASSWORD:?Required}"]

9
00:00:48,000 --> 00:00:54,000
POSTGRES_ADMIN_PASSWORD is required. The `:?Required` syntax means the script
exits if this variable is not set. This prevents running without credentials.

10
00:00:54,000 --> 00:01:00,000
Now let's export the variables so they're available to Vault commands.
[Types: export VAULT_ADDR VAULT_TOKEN]

11
00:01:00,000 --> 00:01:06,000
Now let's define helper functions for logging.
[Types: log() { echo "[$(date +%H:%M:%S)] $*"; }]

12
00:01:06,000 --> 00:01:12,000
The log function prints a timestamp followed by the message. This makes logs
easier to read and debug.

13
00:01:12,000 --> 00:01:18,000
[Types: success() { echo "[$(date +%H:%M:%S)] ✅ $*"; }]

14
00:01:18,000 --> 00:01:24,000
The success function adds a checkmark emoji. This makes successful operations
visually distinct in the logs.

15
00:01:24,000 --> 00:01:30,000
Now let's enable the database secrets engine. This is Component 54.
[Types: vault secrets enable database 2>/dev/null || log "database engine already enabled"]

16
00:01:30,000 --> 00:01:36,000
The `2>/dev/null` redirects error output to null. This prevents errors when
the engine is already enabled. The `||` runs the log command if the enable fails.

17
00:01:36,000 --> 00:01:42,000
[Types: success "Database secrets engine ready"]

18
00:01:42,000 --> 00:01:48,000
Now let's configure the PostgreSQL connection. This is Component 55.
[Types: vault write database/config/financial-ai \]

19
00:01:48,000 --> 00:01:54,000
The backslash tells bash to continue the command on the next line. This makes
the command more readable.

20
00:01:54,000 --> 00:02:00,000
[Types: plugin_name=postgresql-database-plugin \]

21
00:02:00,000 --> 00:02:06,000
We specify the PostgreSQL database plugin. Vault has plugins for many databases.
PostgreSQL is one of the most common.

22
00:02:06,000 --> 00:02:12,000
[Types: allowed_roles="api-role,agent-role,ingestion-role" \]

23
00:02:12,000 --> 00:02:18,000
Allowed_roles lists which Vault roles can use this connection. We have three roles:
api-role, agent-role, and ingestion-role.

24
00:02:18,000 --> 00:02:24,000
[Types: connection_url="postgresql://{{username}}:{{password}}@postgres.financial-rag.svc.cluster.local:5432/financial_rag?sslmode=require" \]

25
00:02:24,000 --> 00:02:30,000
The connection_url uses placeholders. `{{username}}` and `{{password}}` are
filled in by Vault when it creates a credential. This is the dynamic part.

26
00:02:30,000 --> 00:02:36,000
The host is `postgres.financial-rag.svc.cluster.local`. This is the Kubernetes
service name for PostgreSQL. It works inside the cluster.

27
00:02:36,000 --> 00:02:42,000
`sslmode=require` forces TLS encryption. This is a security best practice.
All database connections should be encrypted.

28
00:02:42,000 --> 00:02:48,000
[Types: username="finrag_admin" \]

29
00:02:48,000 --> 00:02:54,000
The username is the PostgreSQL admin user. Vault uses this to create new users.
This account must have CREATE ROLE permission.

30
00:02:54,000 --> 00:03:00,000
[Types: password="${POSTGRES_ADMIN_PASSWORD}" \]

31
00:03:00,000 --> 00:03:06,000
The password is from the environment variable we defined earlier.
Never hardcode passwords. Always use environment variables.

32
00:03:06,000 --> 00:03:12,000
[Types: password_authentication="scram-sha-256"]

33
00:03:12,000 --> 00:03:18,000
We use scram-sha-256 authentication. This is the most secure password
authentication method supported by PostgreSQL.

34
00:03:18,000 --> 00:03:24,000
[Types: success "PostgreSQL connection configured"]

35
00:03:24,000 --> 00:03:30,000
Now let's create the database roles. This is Component 56. One role per service.
[Types: vault write database/roles/api-role \]

36
00:03:30,000 --> 00:03:36,000
[Types: db_name=financial-ai \]

37
00:03:36,000 --> 00:03:42,000
db_name must match the name we used in the connection configuration.
This links the role to the PostgreSQL connection.

38
00:03:42,000 --> 00:03:48,000
[Types: creation_statements=" CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; GRANT SELECT ON filings, financial_chunks, analysis_history TO \"{{name}}\"; GRANT INSERT ON analysis_history TO \"{{name}}\"; " \]

39
00:03:48,000 --> 00:03:54,000
The creation_statements are the SQL commands Vault runs when creating a credential.
`{{name}}`, `{{password}}`, and `{{expiration}}` are placeholders.

40
00:03:54,000 --> 00:04:00,000
First, we create a new PostgreSQL role with a random name and password.
The role is valid until the expiration time. This is the dynamic part.

41
00:04:00,000 --> 00:04:06,000
Second, we grant SELECT on filings, financial_chunks, and analysis_history.
The API needs read access to all these tables.

42
00:04:06,000 --> 00:04:12,000
Third, we grant INSERT on analysis_history. The API writes to the audit trail.
This is the only write permission the API needs.

43
00:04:12,000 --> 00:04:18,000
[Types: default_ttl="1h" \]

44
00:04:18,000 --> 00:04:24,000
default_ttl is 1 hour. The credential expires after 1 hour. This limits the
window of exposure if a credential is compromised.

45
00:04:24,000 --> 00:04:30,000
[Types: max_ttl="24h"]

46
00:04:30,000 --> 00:04:36,000
max_ttl is 24 hours. The credential can be renewed up to 24 hours.
After 24 hours, a new credential must be created.

47
00:04:36,000 --> 00:04:42,000
[Types: success "API role created"]

48
00:04:42,000 --> 00:04:48,000
Now let's create the agent role. This is similar to the API role.
[Types: vault write database/roles/agent-role \]

49
00:04:48,000 --> 00:04:54,000
[Types: db_name=financial-ai \]

50
00:04:54,000 --> 00:05:00,000
[Types: creation_statements=" CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; GRANT SELECT ON filings, financial_chunks TO \"{{name}}\"; GRANT SELECT, INSERT ON analysis_history TO \"{{name}}\"; " \]

51
00:05:00,000 --> 00:05:06,000
The agent role has the same privileges as the API role. It needs read access
to filings and chunks. It also writes to analysis_history.

52
00:05:06,000 --> 00:05:12,000
[Types: default_ttl="1h" \]

53
00:05:12,000 --> 00:05:18,000
[Types: max_ttl="24h"]

54
00:05:18,000 --> 00:05:24,000
[Types: success "Agent role created"]

55
00:05:24,000 --> 00:05:30,000
Now let's create the ingestion role. This has more privileges.
[Types: vault write database/roles/ingestion-role \]

56
00:05:30,000 --> 00:05:36,000
[Types: db_name=financial-ai \]

57
00:05:36,000 --> 00:05:42,000
[Types: creation_statements=" CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; GRANT SELECT, INSERT, UPDATE ON filings, financial_chunks TO \"{{name}}\"; GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO \"{{name}}\"; " \]

58
00:05:42,000 --> 00:05:48,000
The ingestion role needs more privileges. It needs INSERT and UPDATE on
filings and chunks. It writes data during ingestion.

59
00:05:48,000 --> 00:05:54,000
It also needs USAGE on sequences. Sequences are used for auto-incrementing IDs.
Without this, INSERT operations would fail.

60
00:05:54,000 --> 00:06:00,000
[Types: default_ttl="2h" \]

61
00:06:00,000 --> 00:06:06,000
default_ttl is 2 hours. Ingestion runs daily and can take a while.
2 hours gives it enough time to complete.

62
00:06:06,000 --> 00:06:12,000
[Types: max_ttl="6h"]

63
00:06:12,000 --> 00:06:18,000
max_ttl is 6 hours. If the ingestion job takes longer than 2 hours,
it can renew the credential up to 6 hours.

64
00:06:18,000 --> 00:06:24,000
[Types: success "Ingestion role created"]

65
00:06:24,000 --> 00:06:30,000
Now let's make the script executable and run it.
[Types: chmod +x infrastructure/vault/vault-bootstrap.sh]

66
00:06:30,000 --> 00:06:36,000
Set the required environment variables.
[Types: export VAULT_ADDR="http://127.0.0.1:8200"]
[Types: export VAULT_TOKEN="root"]
[Types: export POSTGRES_ADMIN_PASSWORD="your-admin-password"]

67
00:06:36,000 --> 00:06:42,000
Run the bootstrap script.
[Types: ./infrastructure/vault/vault-bootstrap.sh]

68
00:06:42,000 --> 00:06:48,000
You should see output like this showing each step being executed.
[15:30:15] Enabling database secrets engine...
[15:30:15] ✅ Database secrets engine ready
[15:30:15] Configuring PostgreSQL connection...
[15:30:16] ✅ PostgreSQL connection configured
[15:30:16] Creating database roles...
[15:30:17] ✅ Database roles created (api-role, agent-role, ingestion-role)

69
00:06:48,000 --> 00:06:54,000
Now let's verify the database roles. Read a dynamic credential.
[Types: vault read database/creds/api-role]

70
00:06:54,000 --> 00:07:00,000
You should see output like this:
Key: lease_id
Value: database/creds/api-role/AbCdEfGhIjKlMn
Key: lease_duration
Value: 1h
Key: username
Value: v-k8s-api-role-AbCdEf123456
Key: password
Value: A1b2C3d4-E5f6-G7h8-I9j0-K1L2M3N4O5P6

71
00:07:00,000 --> 00:07:06,000
This is a dynamic credential. It was created on demand. It expires in 1 hour.
The username and password are random and unique.

72
00:07:06,000 --> 00:07:12,000
Now let's verify the credential works in PostgreSQL.
[Types: PGPASSWORD="A1b2C3d4-E5f6-G7h8-I9j0-K1L2M3N4O5P6" psql -h localhost -U "v-k8s-api-role-AbCdEf123456" -d financial_rag -c "SELECT count(*) FROM financial_chunks;"]

73
00:07:12,000 --> 00:07:18,000
This command connects to PostgreSQL using the dynamic credential.
It runs a simple query. If it works, the credential is valid.

74
00:07:18,000 --> 00:07:24,000
Now let me show you what happens when the credential expires.
Wait 1 hour. Then run the same command.

75
00:07:24,000 --> 00:07:30,000
FATAL: password authentication failed for user "v-k8s-api-role-AbCdEf123456"

76
00:07:30,000 --> 00:07:36,000
The credential has expired. Vault deleted the user from PostgreSQL.
Even if an attacker stole the credential, it stops working after 1 hour.

77
00:07:36,000 --> 00:07:42,000
Now let me recap what we've built in Part 2.

78
00:07:42,000 --> 00:07:48,000
We built the bootstrap script. It enables the database secrets engine.
It configures the PostgreSQL connection. It creates three database roles.

79
00:07:48,000 --> 00:07:54,000
Each role has different privileges. API and agent have read access.
Ingestion has write access. This is the principle of least privilege.

80
00:07:54,000 --> 00:08:00,000
Each role has a different TTL. API and agent have 1 hour. Ingestion has 2 hours.
Short TTL limits the window of exposure.

81
00:08:00,000 --> 00:08:06,000
We verified the dynamic credentials. vault read database/creds/api-role.
The credential is valid. It expires in 1 hour.

82
00:08:06,000 --> 00:08:12,000
We tested the credential in PostgreSQL. It works.
After 1 hour, it stops working. Vault deletes the PostgreSQL user automatically.

83
00:08:12,000 --> 00:08:18,000
This is the power of dynamic credentials. They manage themselves.
You don't need to rotate passwords manually. Vault does it automatically.

84
00:08:18,000 --> 00:08:24,000
In Part 3, we enable the PKI secrets engine. We generate the root certificate.
We create PKI roles for service-to-service mTLS.

85
00:08:24,000 --> 00:08:30,000
Thank you for watching. I'll see you in Part 3.

86
00:08:30,000 --> 00:08:34,000
[End of Part 2]
1
00:00:00,000 --> 00:00:06,000
Welcome back to Phase 6. In Part 3, we configure two critical components of Vault.

2
00:00:06,000 --> 00:00:12,000
The PKI engine for TLS certificates. And the Kubernetes auth method for pod authentication.

3
00:00:12,000 --> 00:00:18,000
In Part 2, we set up the database secrets engine. We created dynamic database credentials for each service.
Now we need to complete the picture.

4
00:00:18,000 --> 00:00:24,000
Let me explain why we need both PKI and Kubernetes auth before we configure them.

5
00:00:24,000 --> 00:00:30,000
The Kubernetes auth method is how Vault knows who is making a request.
It authenticates pods using their service account JWT.

6
00:00:30,000 --> 00:00:36,000
The PKI engine issues TLS certificates. These certificates encrypt traffic between services
and verify identity. This is service-to-service mTLS.

7
00:00:36,000 --> 00:00:42,000
Together, they enable zero-trust networking. Every service has an identity.
Every connection is encrypted. Nothing is trusted by default.

8
00:00:42,000 --> 00:00:48,000
Without Kubernetes auth, Vault has no way to verify that a pod is who it claims to be.
Without PKI, services have no way to encrypt traffic or verify identity.

9
00:00:48,000 --> 00:00:54,000
Open `infrastructure/vault/vault-bootstrap.sh` in your editor.
We are going to add the PKI section.

10
00:00:54,000 --> 00:01:00,000
The first step is enabling the PKI engine. This activates the PKI plugin.
[Types: vault secrets enable pki 2>/dev/null]

11
00:01:00,000 --> 00:01:06,000
We use 2>/dev/null to suppress the error if the engine is already enabled.
This makes the script idempotent. You can run it multiple times.

12
00:01:06,000 --> 00:01:12,000
Now we tune the PKI engine to allow a maximum lease TTL of one year.
[Types: vault secrets tune -max-lease-ttl=8760h pki]

13
00:01:12,000 --> 00:01:18,000
8760 hours is exactly one year. The root certificate is valid for one year.
We rotate it annually. This is a common enterprise practice.

14
00:01:18,000 --> 00:01:24,000
Now let's generate the root certificate. This is the root of trust.
[Types: vault write -field=certificate pki/root/generate/internal common_name="financial-rag-agent CA" ttl=8760h > /tmp/finrag-ca.crt]

15
00:01:24,000 --> 00:01:30,000
The -field=certificate flag extracts only the certificate from the response.
We save it to /tmp/finrag-ca.crt. This certificate is used by clients to verify
certificates issued by Vault.

16
00:01:30,000 --> 00:01:36,000
The private key stays in Vault. We never extract it. This is a security best practice.
The certificate is public. The private key is secret.

17
00:01:36,000 --> 00:01:42,000
Now let's configure the certificate URLs. This tells clients where to find
the CA certificate and certificate revocation list.
[Types: vault write pki/config/urls issuing_certificates="${VAULT_ADDR}/v1/pki/ca" crl_distribution_points="${VAULT_ADDR}/v1/pki/crl"]

18
00:01:42,000 --> 00:01:48,000
The issuing_certificates URL is where clients get the CA certificate.
The crl_distribution_points URL is where clients get the revocation list.

19
00:01:48,000 --> 00:01:54,000
Now let's create the PKI role. This defines the certificate parameters.
[Types: vault write pki/roles/financial-ai allowed_domains="financial-rag.svc.cluster.local,financial-rag.internal" allow_subdomains=true max_ttl=72h require_cn=false]

20
00:01:54,000 --> 00:02:00,000
allowed_domains restricts which domains can be issued certificates.
financial-rag.svc.cluster.local is the Kubernetes internal domain.

21
00:02:00,000 --> 00:02:06,000
allow_subdomains means we can issue certificates for any subdomain.
api.financial-rag.svc.cluster.local. agent.financial-rag.svc.cluster.local.
pgvector-0.pgvector-headless.financial-rag.svc.cluster.local.

22
00:02:06,000 --> 00:02:12,000
max_ttl=72h means certificates are valid for up to 3 days.
This is a balance between security and operational overhead.

23
00:02:12,000 --> 00:02:18,000
require_cn=false means we don't require a Common Name in the certificate subject.
We use Subject Alternative Names instead. This is more flexible and modern.

24
00:02:18,000 --> 00:02:24,000
Now let's test the PKI engine. We'll issue a certificate for the API service.
[Types: vault write pki/issue/financial-ai common_name="api.financial-rag.svc.cluster.local" ttl=24h]

25
00:02:24,000 --> 00:02:30,000
This issues a certificate valid for 24 hours. The output includes the certificate,
the private key, and the CA chain.

26
00:02:30,000 --> 00:02:36,000
This certificate can be used for TLS termination. It can be used for mTLS authentication.
It can be mounted as a secret in the pod.

27
00:02:36,000 --> 00:02:42,000
Now let's move to the Kubernetes auth method. This is how Vault authenticates pods.

28
00:02:42,000 --> 00:02:48,000
The first step is enabling the auth method.
[Types: vault auth enable kubernetes 2>/dev/null]

29
00:02:48,000 --> 00:02:54,000
Again, we use 2>/dev/null to suppress the error if it's already enabled.
This makes the script idempotent.

30
00:02:54,000 --> 00:03:00,000
Now we need to configure the auth method. This is where we tell Vault how to verify JWT tokens.

31
00:03:00,000 --> 00:03:06,000
First, we get the Kubernetes API server endpoint from your kubeconfig.
[Types: K8S_HOST=$(kubectl config view --raw --minify --flatten -o jsonpath='{.clusters[].cluster.server}')]

32
00:03:06,000 --> 00:03:12,000
This extracts the API server URL. Vault needs this to verify JWT tokens with the Kubernetes API server.

33
00:03:12,000 --> 00:03:18,000
Now we configure the auth method with the Kubernetes API server endpoint.
[Types: vault write auth/kubernetes/config kubernetes_host="${K8S_HOST}" kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt token_reviewer_jwt=@/var/run/secrets/kubernetes.io/serviceaccount/token]

34
00:03:18,000 --> 00:03:24,000
The kubernetes_ca_cert is the CA certificate of the Kubernetes API server.
This is used to verify the server's identity.

35
00:03:24,000 --> 00:03:30,000
The token_reviewer_jwt is a JWT token from the service account in the Vault pod.
Vault uses this to call the Kubernetes TokenReview API.

36
00:03:30,000 --> 00:03:36,000
Now let's create the Kubernetes auth roles. One for each service.
First, the API role.
[Types: vault write auth/kubernetes/role/financial-rag-api bound_service_account_names="financial-rag-agent-api" bound_service_account_namespaces="financial-rag" policies="api-policy" ttl=1h max_ttl=24h]

37
00:03:36,000 --> 00:03:42,000
bound_service_account_names binds this role to a specific service account.
Only pods with that service account can authenticate.

38
00:03:42,000 --> 00:03:48,000
bound_service_account_namespaces restricts the role to a specific namespace.
This prevents pods from other namespaces from using this role.

39
00:03:48,000 --> 00:03:54,000
policies attaches the Vault policy to this role.
When a pod authenticates, it receives the attached policies.

40
00:03:54,000 --> 00:04:00,000
ttl=1h means the Vault token is valid for 1 hour.
max_ttl=24h means it can be renewed up to 24 hours.

41
00:04:00,000 --> 00:04:06,000
Now the Agent role.
[Types: vault write auth/kubernetes/role/financial-rag-agent bound_service_account_names="financial-rag-agent-agent" bound_service_account_namespaces="financial-rag" policies="agent-policy" ttl=1h max_ttl=24h]

42
00:04:06,000 --> 00:04:12,000
This is the same pattern but for the agent service account and agent policy.

43
00:04:12,000 --> 00:04:18,000
Now the Ingestion role.
[Types: vault write auth/kubernetes/role/financial-rag-ingestion bound_service_account_names="financial-rag-agent-ingestion" bound_service_account_namespaces="financial-rag" policies="ingestion-policy" ttl=2h max_ttl=6h]

44
00:04:18,000 --> 00:04:24,000
The TTL is 2 hours because ingestion jobs may run longer.
The max TTL is 6 hours. This gives ingestion jobs enough time to complete.

45
00:04:24,000 --> 00:04:30,000
Now let's create the Vault policies. These define what each service can access.
Open `infrastructure/vault/policies/api-policy.hcl`.

46
00:04:30,000 --> 00:04:36,000
The API policy grants read access to three static secrets.
[Types: path "secret/data/financial-rag/prod/llm" { capabilities = ["read"] }]

47
00:04:36,000 --> 00:04:42,000
This gives the API access to the LLM API key and model configuration.

48
00:04:42,000 --> 00:04:48,000
[Types: path "secret/data/financial-rag/prod/redis" { capabilities = ["read"] }]
This gives the API access to the Redis password and connection details.

49
00:04:48,000 --> 00:04:54,000
[Types: path "secret/data/financial-rag/prod/config" { capabilities = ["read"] }]
This gives the API access to the application configuration.

50
00:04:54,000 --> 00:05:00,000
[Types: path "database/creds/api-role" { capabilities = ["read"] }]
This gives the API access to dynamic database credentials.
When the API reads this path, Vault generates a new credential.

51
00:05:00,000 --> 00:05:06,000
[Types: path "pki/issue/financial-rag" { capabilities = ["create", "update"] }]
This gives the API access to the PKI engine. It can request TLS certificates.

52
00:05:06,000 --> 00:05:12,000
Now open `infrastructure/vault/policies/agent-policy.hcl`.
This is the Agent policy.

53
00:05:12,000 --> 00:05:18,000
[Types: path "secret/data/financial-rag/prod/llm" { capabilities = ["read"] }]
The agent needs the LLM API key for inference.

54
00:05:18,000 --> 00:05:24,000
[Types: path "secret/data/financial-rag/prod/redis" { capabilities = ["read"] }]
The agent needs Redis for caching.

55
00:05:24,000 --> 00:05:30,000
[Types: path "database/creds/agent-role" { capabilities = ["read"] }]
The agent uses a different database role. The agent-role has different privileges.

56
00:05:30,000 --> 00:05:36,000
[Types: path "pki/issue/financial-rag" { capabilities = ["create", "update"] }]
The agent also needs TLS certificates for mTLS.

57
00:05:36,000 --> 00:05:42,000
Now open `infrastructure/vault/policies/ingestion-policy.hcl`.
This is the Ingestion policy.

58
00:05:42,000 --> 00:05:48,000
[Types: path "secret/data/financial-rag/prod/edgar" { capabilities = ["read"] }]
The ingestion service needs EDGAR credentials to download filings.

59
00:05:48,000 --> 00:05:54,000
[Types: path "secret/data/financial-rag/prod/redis" { capabilities = ["read"] }]
The ingestion service needs Redis for caching.

60
00:05:54,000 --> 00:06:00,000
[Types: path "database/creds/ingestion-role" { capabilities = ["read"] }]
The ingestion service uses a different database role. It needs write access.

61
00:06:00,000 --> 00:06:06,000
Notice the pattern. Each service gets exactly what it needs. Nothing more.
This is the principle of least privilege.

62
00:06:06,000 --> 00:06:12,000
The API does not get EDGAR credentials. The ingestion service does not get LLM keys.
If one service is compromised, the others are still secure.

63
00:06:12,000 --> 00:06:18,000
Now let's write these policies to Vault. We use the vault policy write command.

64
00:06:18,000 --> 00:06:24,000
[Types: vault policy write api-policy - <<'EOF' path "secret/data/financial-rag/prod/llm" { capabilities = ["read"] } path "database/creds/api-role" { capabilities = ["read"] } path "pki/issue/financial-rag" { capabilities = ["create", "update"] } EOF]

65
00:06:24,000 --> 00:06:30,000
[Types: vault policy write agent-policy - <<'EOF' path "secret/data/financial-rag/prod/llm" { capabilities = ["read"] } path "database/creds/agent-role" { capabilities = ["read"] } path "pki/issue/financial-rag" { capabilities = ["create", "update"] } EOF]

66
00:06:30,000 --> 00:06:36,000
[Types: vault policy write ingestion-policy - <<'EOF' path "secret/data/financial-rag/prod/edgar" { capabilities = ["read"] } path "database/creds/ingestion-role" { capabilities = ["read"] } EOF]

67
00:06:36,000 --> 00:06:42,000
Now let's test the Kubernetes auth. Create a test pod with the API service account.

68
00:06:42,000 --> 00:06:48,000
[Types: kubectl apply -f - <<'EOF' apiVersion: v1 kind: Pod metadata: name: auth-test namespace: financial-ai annotations: vault.hashicorp.com/agent-inject: "true" vault.hashicorp.com/role: "financial-rag-api" spec: serviceAccountName: financial-rag-agent-api containers: - name: app image: busybox command: ["sleep", "3600"] restartPolicy: Never EOF]

69
00:06:48,000 --> 00:06:54,000
Wait for the pod to start.
[Types: kubectl wait --for=condition=ready pod/auth-test -n financial-ai --timeout=60s]

70
00:06:54,000 --> 00:07:00,000
Check the Vault Agent logs.
[Types: kubectl logs -n financial-ai auth-test -c vault-agent]

71
00:07:00,000 --> 00:07:06,000
You should see something like "authenticated successfully" and "fetched token from Vault".
This confirms the Kubernetes auth method is working.

72
00:07:06,000 --> 00:07:12,000
Now check the Vault token.
[Types: kubectl exec -n financial-ai auth-test -c vault-agent -- cat /vault/secrets/.vault-token]

73
00:07:12,000 --> 00:07:18,000
This is the Vault token. It was issued by Vault after successful authentication.
It is valid for 1 hour.

74
00:07:18,000 --> 00:07:24,000
Clean up the test pod.
[Types: kubectl delete pod auth-test -n financial-rag]

75
00:07:24,000 --> 00:07:30,000
Now let me recap what we've built in Part 3.

76
00:07:30,000 --> 00:07:36,000
We enabled the PKI secrets engine. We generated a root certificate.
We created a PKI role for issuing service certificates.

77
00:07:36,000 --> 00:07:42,000
We enabled the Kubernetes auth method. We configured it with the Kubernetes API server endpoint.
We created auth roles for each service account.

78
00:07:42,000 --> 00:07:48,000
We wrote three Vault policies. One for API, one for Agent, one for Ingestion.
Each grants exactly the permissions needed. Nothing more.

79
00:07:48,000 --> 00:07:54,000
We tested the Kubernetes auth with a test pod. We verified the Vault Agent
could authenticate and fetch a token.

80
00:07:54,000 --> 00:08:00,000
This is the zero-trust model. Identity is verified every time.
Credentials are not stored. They are issued on demand.

81
00:08:00,000 --> 00:08:06,000
Let me give you a security tip. The Kubernetes auth method relies on trust in
the Kubernetes API server. The API server signs the service account JWT.

82
00:08:06,000 --> 00:08:12,000
Vault verifies the signature using the API server's CA certificate.
If the signature is valid, Vault trusts the token.

83
00:08:12,000 --> 00:08:18,000
This means Vault inherits the security of Kubernetes. If Kubernetes is compromised,
Vault is compromised. This is the accepted security model in Kubernetes environments.

84
00:08:18,000 --> 00:08:24,000
In Part 4, we create the Vault Agent sidecar configuration. We deploy the sidecar.
We test the complete secret injection flow.

85
00:08:24,000 --> 00:08:30,000
Let me leave you with a question. Why should we use Kubernetes auth instead of a static token?

86
00:08:30,000 --> 00:08:36,000
A static token is like a password. It can be stolen. It can be shared.
It is hard to rotate. Kubernetes auth is like a key card that expires.
It is automatically rotated. It is bound to the pod's identity.

87
00:08:36,000 --> 00:08:42,000
This is the zero-trust model. Identity is verified every time.
Credentials are not stored. They are issued on demand.

88
00:08:42,000 --> 00:08:48,000
Thank you for watching. I'll see you in Part 4.

89
00:08:48,000 --> 00:08:52,000
[End of Part 3]
1
00:00:00,000 --> 00:00:06,000
Welcome back to Phase 6. In Part 4, we create the Vault policies and service accounts.

2
00:00:06,000 --> 00:00:12,000
We have Vault running. We have the database engine configured. We have Kubernetes
auth set up. Now we need to define who can access what.

3
00:00:12,000 --> 00:00:18,000
This is where the principle of least privilege comes to life. Every service gets
exactly the secrets it needs. Nothing more. Nothing less.

4
00:00:18,000 --> 00:00:24,000
Think of it like a building with different security clearances. The API service
has a badge that opens certain doors. The Agent service has a different badge.
The Ingestion service has its own badge.

5
00:00:24,000 --> 00:00:30,000
No badge opens every door. Each badge opens only the doors needed for that job.
This is the principle of least privilege.

6
00:00:30,000 --> 00:00:36,000
Open your editor and create `infrastructure/k8s/service-accounts.yaml`.

7
00:00:36,000 --> 00:00:42,000
We'll start with the API service account. This is used by the API pods.
[Types: apiVersion: v1]

8
00:00:42,000 --> 00:00:48,000
We specify the kind as ServiceAccount.
[Types: kind: ServiceAccount]

9
00:00:48,000 --> 00:00:54,000
We give it a descriptive name.
[Types: metadata: name: financial-rag-agent-api]

10
00:00:54,000 --> 00:01:00,000
We place it in the financial-ai namespace.
[Types: namespace: financial-rag]

11
00:01:00,000 --> 00:01:06,000
We add labels for identification.
[Types: labels: app.kubernetes.io/name: financial-rag-agent app.kubernetes.io/component: api]

12
00:01:06,000 --> 00:01:12,000
Now let's define the Agent service account. This is used by the agent pool.
[Types: --- apiVersion: v1 kind: ServiceAccount metadata: name: financial-rag-agent-agent namespace: financial-ai labels: app.kubernetes.io/name: financial-rag-agent app.kubernetes.io/component: agent]

13
00:01:12,000 --> 00:01:18,000
The Agent service account is similar to the API. Different name, different component label.

14
00:01:18,000 --> 00:01:24,000
Now let's define the Ingestion service account. This is used by the ingestion CronJob.
[Types: --- apiVersion: v1 kind: ServiceAccount metadata: name: financial-rag-agent-ingestion namespace: financial-ai labels: app.kubernetes.io/name: financial-rag-agent app.kubernetes.io/component: ingestion]

15
00:01:24,000 --> 00:01:30,000
Each service account represents a workload. Vault binds to these identities.

16
00:01:30,000 --> 00:01:36,000
Now let's apply the service accounts.

17
00:01:36,000 --> 00:01:42,000
[Types: kubectl apply -f infrastructure/k8s/service-accounts.yaml]

18
00:01:42,000 --> 00:01:48,000
Now let's create the Vault policies. Open `infrastructure/vault/policies/api-policy.hcl`.

19
00:01:48,000 --> 00:01:54,000
We'll start with the API policy. This defines what secrets the API can access.
[Types: # API Policy — least privilege for the API service]

20
00:01:54,000 --> 00:02:00,000
The API needs to read the LLM API key. This is a static secret.
[Types: path "secret/data/financial-rag/prod/llm" { capabilities = ["read"] }]

21
00:02:00,000 --> 00:02:06,000
The API needs to read the Redis password. This is also a static secret.
[Types: path "secret/data/financial-rag/prod/redis" { capabilities = ["read"] }]

22
00:02:06,000 --> 00:02:12,000
The API needs to read the application configuration.
[Types: path "secret/data/financial-rag/prod/config" { capabilities = ["read"] }]

23
00:02:12,000 --> 00:02:18,000
Now the dynamic credentials. The API needs database credentials.
[Types: path "database/creds/api-role" { capabilities = ["read"] }]

24
00:02:18,000 --> 00:02:24,000
When the API reads this path, Vault generates a new credential and returns it.

25
00:02:24,000 --> 00:02:30,000
The API also needs TLS certificates for mTLS.
[Types: path "pki/issue/financial-rag" { capabilities = ["create", "update"] }]

26
00:02:30,000 --> 00:02:36,000
This allows the API to request certificates from the PKI engine.

27
00:02:36,000 --> 00:02:42,000
Now let's create the Agent policy. Open `infrastructure/vault/policies/agent-policy.hcl`.

28
00:02:42,000 --> 00:02:48,000
The Agent needs the LLM API key. Same as the API.
[Types: path "secret/data/financial-rag/prod/llm" { capabilities = ["read"] }]

29
00:02:48,000 --> 00:02:54,000
The Agent needs the Redis password. Same as the API.
[Types: path "secret/data/financial-rag/prod/redis" { capabilities = ["read"] }]

30
00:02:54,000 --> 00:03:00,000
But the Agent uses a different database role. The agent-role has different privileges.
[Types: path "database/creds/agent-role" { capabilities = ["read"] }]

31
00:03:00,000 --> 00:03:06,000
The Agent-role has read and write access to analysis_history. The API-role only has read.

32
00:03:06,000 --> 00:03:12,000
Now let's create the Ingestion policy. Open `infrastructure/vault/policies/ingestion-policy.hcl`.

33
00:03:12,000 --> 00:03:18,000
The Ingestion service needs EDGAR credentials. This is a static secret.
[Types: path "secret/data/financial-rag/prod/edgar" { capabilities = ["read"] }]

34
00:03:18,000 --> 00:03:24,000
The Ingestion service needs the Redis password. Same as the others.
[Types: path "secret/data/financial-rag/prod/redis" { capabilities = ["read"] }]

35
00:03:24,000 --> 00:03:30,000
But notice what's missing. The Ingestion policy does NOT have access to the LLM API key.
This is the principle of least privilege.

36
00:03:30,000 --> 00:03:36,000
The Ingestion service doesn't need the LLM API key. It only ingests data.
It never makes LLM calls. So it shouldn't have access.

37
00:03:36,000 --> 00:03:42,000
The Ingestion service uses a different database role. The ingestion-role has
write access to filings and chunks.
[Types: path "database/creds/ingestion-role" { capabilities = ["read"] }]

38
00:03:42,000 --> 00:03:48,000
Now let's apply the policies to Vault.

39
00:03:48,000 --> 00:03:54,000
[Types: vault policy write api-policy infrastructure/vault/policies/api-policy.hcl]

40
00:03:54,000 --> 00:04:00,000
[Types: vault policy write agent-policy infrastructure/vault/policies/agent-policy.hcl]

41
00:04:00,000 --> 00:04:06,000
[Types: vault policy write ingestion-policy infrastructure/vault/policies/ingestion-policy.hcl]

42
00:04:06,000 --> 00:04:12,000
Now let's create the Kubernetes auth roles. These bind service accounts to Vault policies.

43
00:04:12,000 --> 00:04:18,000
The API role binds the API service account to the api-policy.
[Types: vault write auth/kubernetes/role/financial-rag-api bound_service_account_names="financial-rag-agent-api" bound_service_account_namespaces="financial-rag" policies="api-policy" ttl=1h max_ttl=24h]

44
00:04:18,000 --> 00:04:24,000
The Agent role binds the Agent service account to the agent-policy.
[Types: vault write auth/kubernetes/role/financial-rag-agent bound_service_account_names="financial-rag-agent-agent" bound_service_account_namespaces="financial-rag" policies="agent-policy" ttl=1h max_ttl=24h]

45
00:04:24,000 --> 00:04:30,000
The Ingestion role binds the Ingestion service account to the ingestion-policy.
[Types: vault write auth/kubernetes/role/financial-rag-ingestion bound_service_account_names="financial-rag-agent-ingestion" bound_service_account_namespaces="financial-rag" policies="ingestion-policy" ttl=2h max_ttl=6h]

46
00:04:30,000 --> 00:04:36,000
Notice the TTL differences. API and Agent have 1 hour. Ingestion has 2 hours.
The TTL matches the workload. Ingestion jobs run longer.

47
00:04:36,000 --> 00:04:42,000
Now let's verify the policies. Check that each policy has the correct capabilities.

48
00:04:42,000 --> 00:04:48,000
[Types: vault policy read api-policy]

49
00:04:48,000 --> 00:04:54,000
You should see the policy content with the correct paths and capabilities.

50
00:04:54,000 --> 00:05:00,000
[Types: vault policy read agent-policy]

51
00:05:00,000 --> 00:05:06,000
[Types: vault policy read ingestion-policy]

52
00:05:06,000 --> 00:05:12,000
Now let's verify the Kubernetes auth roles.

53
00:05:12,000 --> 00:05:18,000
[Types: vault read auth/kubernetes/role/financial-rag-api]

54
00:05:18,000 --> 00:05:24,000
You should see the bound_service_account_names, bound_service_account_namespaces,
policies, ttl, and max_ttl.

55
00:05:24,000 --> 00:05:30,000
Now let's test the authentication. Create a test pod with the API service account.

56
00:05:30,000 --> 00:05:36,000
[Types: kubectl run auth-test --image=alpine --namespace=financial-ai --labels="app.kubernetes.io/component=api" --restart=Never -- sleep 600 --serviceaccount=financial-rag-agent-api]

57
00:05:36,000 --> 00:05:42,000
Wait for the pod to start.
[Types: kubectl wait --for=condition=ready pod/auth-test -n financial-ai --timeout=60s]

58
00:05:42,000 --> 00:05:48,000
Now check the Vault Agent logs. The Agent should authenticate successfully.

59
00:05:48,000 --> 00:05:54,000
[Types: kubectl logs -n financial-ai auth-test -c vault-agent]

60
00:05:54,000 --> 00:06:00,000
You should see something like "authenticated successfully" and "fetched token from Vault".

61
00:06:00,000 --> 00:06:06,000
Now let me explain the blast radius. This is the most important concept.

62
00:06:06,000 --> 00:06:12,000
If the Ingestion service is compromised, the attacker gets EDGAR credentials
and database write access. They do NOT get the LLM API key.

63
00:06:12,000 --> 00:06:18,000
If the API service is compromised, the attacker gets the LLM API key and
database read access. They do NOT get EDGAR credentials.

64
00:06:18,000 --> 00:06:24,000
Compartmentalization limits the blast radius. Each service is isolated from
the others. A breach in one service doesn't compromise the others.

65
00:06:24,000 --> 00:06:30,000
This is the principle of least privilege. Every service gets exactly what it needs.
Nothing more. Nothing less.

66
00:06:30,000 --> 00:06:36,000
Now let me recap what we've built in Part 4.

67
00:06:36,000 --> 00:06:42,000
We created three service accounts. API, Agent, and Ingestion.
Each service account represents a workload. Vault binds to these identities.

68
00:06:42,000 --> 00:06:48,000
We created three Vault policies. API, Agent, and Ingestion.
Each policy defines what secrets the workload can access.

69
00:06:48,000 --> 00:06:54,000
The API policy allows LLM API key, Redis password, and database read access.
The Agent policy allows LLM API key, Redis password, and database read/write access.
The Ingestion policy allows EDGAR credentials, Redis password, and database write access.

70
00:06:54,000 --> 00:07:00,000
We created three Kubernetes auth roles. Each role binds a service account to a policy.
The API role binds financial-rag-agent-api to api-policy.
The Agent role binds financial-rag-agent-agent to agent-policy.
The Ingestion role binds financial-rag-agent-ingestion to ingestion-policy.

71
00:07:00,000 --> 00:07:06,000
We tested the authentication. We created a test pod with the API service account.
The Vault Agent authenticated successfully.

72
00:07:06,000 --> 00:07:12,000
This is the complete policy and identity layer. Every service has a clear identity.
Every service has clear permissions. The blast radius is limited.

73
00:07:12,000 --> 00:07:18,000
In Part 5, we'll build the Python Vault client. We'll integrate it with our
application and test the complete secret injection flow.

74
00:07:18,000 --> 00:07:24,000
Thank you for watching. I'll see you in Part 5.

75
00:07:24,000 --> 00:07:28,000
[End of Part 4]
1
00:00:00,000 --> 00:00:06,000
Welcome back to Phase 6. In Part 5, we build the Python Vault client.

2
00:00:06,000 --> 00:00:12,000
We have Vault running. We have policies created. We have the Vault Agent sidecar
injecting secrets into pods. Now we need our application to read those secrets.

3
00:00:12,000 --> 00:00:18,000
The application doesn't talk to Vault directly. It reads secrets from files
in the /vault/secrets/ directory. The Vault Agent sidecar writes these files.

4
00:00:18,000 --> 00:00:24,000
Think of it like a mailbox. The Vault Agent is the mail carrier. It delivers
secrets to the mailbox. The application opens the mailbox and reads the mail.
The application never talks to the post office directly.

5
00:00:24,000 --> 00:00:30,000
Open your editor and create `src/financial_rag/security/vault.py`.

6
00:00:30,000 --> 00:00:36,000
We'll start with the imports. The __future__ import enables forward references.
[Types: from __future__ import annotations]

7
00:00:36,000 --> 00:00:42,000
We import logging for structured logging throughout the client.
[Types: import logging]

8
00:00:42,000 --> 00:00:48,000
We import os for environment variable access.
[Types: import os]

9
00:00:48,000 --> 00:00:54,000
We import Path from pathlib for file system operations.
[Types: from pathlib import Path]

10
00:00:54,000 --> 00:01:00,000
Now let's define the Vault secrets directory path.
[Types: _VAULT_SECRETS_DIR = Path("/vault/secrets")]

11
00:01:00,000 --> 00:01:06,000
This is the path where Vault Agent writes secrets. In Kubernetes, this path exists
because of the shared volume between the sidecar and the application container.

12
00:01:06,000 --> 00:01:12,000
Now let's define the VaultSecretReader class. This is the main client.
[Types: class VaultSecretReader:]

13
00:01:12,000 --> 00:01:18,000
We define the read method. This is the primary interface for reading secrets.
[Types: def read(self, secret_name: str) -> dict[str, str]:]

14
00:01:18,000 --> 00:01:24,000
First, we try to read from the Vault Agent file. This is the production path.
[Types: file_path = _VAULT_SECRETS_DIR / f"{secret_name}.env"]

15
00:01:24,000 --> 00:01:30,000
If the file exists, we parse it and return the values.
[Types: if file_path.exists(): return self._parse_env_file(file_path)]

16
00:01:30,000 --> 00:01:36,000
The file is a simple KEY=VALUE format. We parse it into a dictionary.

17
00:01:36,000 --> 00:01:42,000
If the file doesn't exist, we check for direct Vault API access.
[Types: vault_addr = os.environ.get("VAULT_ADDR")]
[Types: vault_token = os.environ.get("VAULT_TOKEN")]

18
00:01:42,000 --> 00:01:48,000
The VAULT_ADDR is the URL of the Vault server. The VAULT_TOKEN is the
authentication token. These are used for direct API access.

19
00:01:48,000 --> 00:01:54,000
If both are set, we try direct API access.
[Types: if vault_addr and vault_token: return self._read_from_vault_api(secret_name, vault_addr, vault_token)]

20
00:01:54,000 --> 00:02:00,000
Direct API access is used in development. It allows you to test without
the Vault Agent sidecar.

21
00:02:00,000 --> 00:02:06,000
If all else fails, we return an empty dictionary.
[Types: return {}]

22
00:02:06,000 --> 00:02:12,000
The caller should use environment variables as a fallback.

23
00:02:12,000 --> 00:02:18,000
Now let's define the read_database_credentials method. This is a convenience method.
[Types: def read_database_credentials(self) -> dict[str, str]:]

24
00:02:18,000 --> 00:02:24,000
We call read with the secret name "database".
[Types: creds = self.read("database")]

25
00:02:24,000 --> 00:02:30,000
If we got credentials, we log the username for debugging.
[Types: if creds: logger.info("Database credentials loaded from Vault (user=%s)", creds.get("POSTGRES_USER", "unknown")[:20] + "...")]

26
00:02:30,000 --> 00:02:36,000
We truncate the username to prevent logging sensitive data.
[Types: return creds]

27
00:02:36,000 --> 00:02:42,000
Now let's define the _parse_env_file method. This parses KEY=VALUE files.
[Types: def _parse_env_file(self, path: Path) -> dict[str, str]:]

28
00:02:42,000 --> 00:02:48,000
We create an empty result dictionary.
[Types: result: dict[str, str] = {}]

29
00:02:48,000 --> 00:02:54,000
We read the file and iterate over each line.
[Types: for line in path.read_text().splitlines():]

30
00:02:54,000 --> 00:03:00,000
We skip empty lines and comments.
[Types: if not line or line.startswith("#") or "=" not in line: continue]

31
00:03:00,000 --> 00:03:06,000
We split on the first equals sign.
[Types: key, _, value = line.partition("=")]

32
00:03:06,000 --> 00:03:12,000
We strip whitespace and store in the result dictionary.
[Types: result[key.strip()] = value.strip()]

33
00:03:12,000 --> 00:03:18,000
[Types: return result]

34
00:03:18,000 --> 00:03:24,000
Now let's define the _read_from_vault_api method. This makes direct API calls.
[Types: def _read_from_vault_api(self, secret_name: str, vault_addr: str, vault_token: str) -> dict[str, str]:]

35
00:03:24,000 --> 00:03:30,000
We import hvac inside the method. This is a soft dependency.
[Types: import hvac]

36
00:03:30,000 --> 00:03:36,000
We create the hvac client with the Vault address and token.
[Types: client = hvac.Client(url=vault_addr, token=vault_token)]

37
00:03:36,000 --> 00:03:42,000
We check if the client is authenticated.
[Types: if not client.is_authenticated(): logger.warning("Vault token is invalid or expired") return {}]

38
00:03:42,000 --> 00:03:48,000
If the token is invalid, we log a warning and return empty.

39
00:03:48,000 --> 00:03:54,000
We try to read the secret from the KV v2 engine.
[Types: try: response = client.secrets.kv.v2.read_secret_version(path=f"financial-rag/prod/{secret_name}") return {k: str(v) for k, v in response["data"]["data"].items()}]

40
00:03:54,000 --> 00:04:00,000
The KV v2 engine stores secrets at paths like secret/data/financial-rag/prod/llm.
We extract the data field from the response.

41
00:04:00,000 --> 00:04:06,000
If the KV v2 read fails, we try the database secrets engine.
[Types: except: pass]

42
00:04:06,000 --> 00:04:12,000
[Types: if secret_name == "database": try: response = client.secrets.database.generate_credentials(name="api-role") return {"POSTGRES_USER": response["data"]["username"], "POSTGRES_PASSWORD": response["data"]["password"]}]

43
00:04:12,000 --> 00:04:18,000
The database engine generates dynamic credentials. The name parameter specifies
which database role to use.

44
00:04:18,000 --> 00:04:24,000
If all else fails, we return an empty dictionary.
[Types: except: pass]
[Types: return {}]

45
00:04:24,000 --> 00:04:30,000
Now let's define the singleton accessor. This is at the bottom of the file.
[Types: _vault_reader: VaultSecretReader | None = None]

46
00:04:30,000 --> 00:04:36,000
[Types: def get_vault_reader() -> VaultSecretReader: global _vault_reader if _vault_reader is None: _vault_reader = VaultSecretReader() return _vault_reader]

47
00:04:36,000 --> 00:04:42,000
This is the singleton pattern. get_vault_reader always returns the same instance.
This ensures we only have one VaultSecretReader per process.

48
00:04:42,000 --> 00:04:48,000
Now let's update the security __init__.py file.
Open `src/financial_rag/security/__init__.py`.

49
00:04:48,000 --> 00:04:54,000
We import get_vault_reader from the module.
[Types: from .vault import get_vault_reader]

50
00:04:54,000 --> 00:05:00,000
We add get_vault_reader to __all__.
[Types: __all__ = ["get_vault_reader"]]

51
00:05:00,000 --> 00:05:06,000
Now let's integrate the Vault client into the application.

52
00:05:06,000 --> 00:05:12,000
Open `src/financial_rag/storage/database.py`.

53
00:05:12,000 --> 00:05:18,000
We need to import get_vault_reader from security.
[Types: from financial_rag.security import get_vault_reader]

54
00:05:18,000 --> 00:05:24,000
In the _build_engine function, we try to read from Vault first.
[Types: vault_reader = get_vault_reader()]
[Types: db_creds = vault_reader.read_database_credentials()]

55
00:05:24,000 --> 00:05:30,000
If we got credentials from Vault, we use them.
[Types: if db_creds: POSTGRES_USER = db_creds.get("POSTGRES_USER", settings.POSTGRES_USER) POSTGRES_PASSWORD = db_creds.get("POSTGRES_PASSWORD", settings.POSTGRES_PASSWORD)]

56
00:05:30,000 --> 00:05:36,000
If not, we fall back to environment variables.

57
00:05:36,000 --> 00:05:42,000
This is the priority order. Vault Agent files are first. Direct Vault API
is second. Environment variables are last.

58
00:05:42,000 --> 00:05:48,000
Now let's test the Vault client. Open a Python shell.

59
00:05:48,000 --> 00:05:54,000
[Types: python]

60
00:05:54,000 --> 00:06:00,000
First, let's simulate a Vault Agent file. We'll create a temporary file.
[Types: from pathlib import Path]
[Types: test_dir = Path("/tmp/vault_test")]
[Types: test_dir.mkdir(exist_ok=True)]

61
00:06:00,000 --> 00:06:06,000
We write a test secret to the file.
[Types: (test_dir / "database.env").write_text("POSTGRES_USER=test_user\nPOSTGRES_PASSWORD=test_password\n")]

62
00:06:06,000 --> 00:06:12,000
Now we need to override the secrets directory for testing.
[Types: import financial_rag.security.vault as vault_module]
[Types: vault_module._VAULT_SECRETS_DIR = test_dir]

63
00:06:12,000 --> 00:06:18,000
We create the VaultSecretReader and read the secret.
[Types: from financial_rag.security import get_vault_reader]
[Types: reader = get_vault_reader()]
[Types: creds = reader.read_database_credentials()]

64
00:06:18,000 --> 00:06:24,000
[Types: print(creds)]

65
00:06:24,000 --> 00:06:30,000
You should see the credentials from the file.
{'POSTGRES_USER': 'test_user', 'POSTGRES_PASSWORD': 'test_password'}

66
00:06:30,000 --> 00:06:36,000
Now let's test the fallback to environment variables.
[Types: import os]
[Types: os.environ["VAULT_ADDR"] = "http://localhost:8200"]
[Types: os.environ["VAULT_TOKEN"] = "test-token"]

67
00:06:36,000 --> 00:06:42,000
But we need to mock the hvac client for this test.

68
00:06:42,000 --> 00:06:48,000
Let me show you a cleaner way to test. We'll use a mock.

69
00:06:48,000 --> 00:06:54,000
[Types: from unittest.mock import MagicMock, patch]

70
00:06:54,000 --> 00:07:00,000
[Types: with patch("hvac.Client") as mock_client: mock_instance = MagicMock() mock_instance.is_authenticated.return_value = True mock_instance.secrets.kv.v2.read_secret_version.return_value = {"data": {"data": {"OPENAI_API_KEY": "sk-test-key"}}} mock_client.return_value = mock_instance creds = reader._read_from_vault_api("llm", "http://localhost:8200", "test-token") print(creds)]

71
00:07:00,000 --> 00:07:06,000
You should see the mocked credentials.
{'OPENAI_API_KEY': 'sk-test-key'}

72
00:07:06,000 --> 00:07:12,000
Now let me explain the priority order in detail.

73
00:07:12,000 --> 00:07:18,000
In production, the Vault Agent sidecar writes secrets to /vault/secrets/.
The application reads from those files. This is the primary path.

74
00:07:18,000 --> 00:07:24,000
In development, you might not have the Vault Agent sidecar.
You can set VAULT_ADDR and VAULT_TOKEN to use direct API access.

75
00:07:24,000 --> 00:07:30,000
In local development, you might not have Vault at all.
The application uses environment variables as a fallback.

76
00:07:30,000 --> 00:07:36,000
This three-tier priority system ensures the application works everywhere.
Development, testing, and production.

77
00:07:36,000 --> 00:07:42,000
Now let me give you a production tip. The Vault Agent file format is
important. Vault Agent writes files in KEY=VALUE format. That's what
we parse in _parse_env_file.

78
00:07:42,000 --> 00:07:48,000
The Vault Agent uses templates to generate these files. We defined
those templates in vault-agent-config.hcl in Part 4.

79
00:07:48,000 --> 00:07:54,000
If you need to add a new secret, you update the Vault Agent template
and the application code. The application reads it automatically.

80
00:07:54,000 --> 00:08:00,000
Now let me show you the complete vault.py file.

81
00:08:00,000 --> 00:08:06,000
[Show complete vault.py file]

82
00:08:06,000 --> 00:08:12,000
Let me recap what we've built in Part 5.

83
00:08:12,000 --> 00:08:18,000
We built the VaultSecretReader class. It reads secrets from three sources.
Vault Agent files are the primary source. Direct Vault API is the secondary
source. Environment variables are the fallback.

84
00:08:18,000 --> 00:08:24,000
We built the read method. This is the main interface. It takes a secret name
and returns a dictionary of key-value pairs.

85
00:08:24,000 --> 00:08:30,000
We built the read_database_credentials method. This is a convenience method
for reading database credentials. It logs the username for debugging.

86
00:08:30,000 --> 00:08:36,000
We built the _parse_env_file method. This parses KEY=VALUE files written by
the Vault Agent sidecar.

87
00:08:36,000 --> 00:08:42,000
We built the _read_from_vault_api method. This makes direct API calls to Vault
using the hvac library. It supports both KV v2 secrets and dynamic database
credentials.

88
00:08:42,000 --> 00:08:48,000
We created the singleton accessor. get_vault_reader returns the same instance
every time. This ensures efficient resource usage.

89
00:08:48,000 --> 00:08:54,000
We integrated the Vault client into the application. The database client
now uses Vault credentials. The priority order is Vault Agent files first,
direct API second, environment variables last.

90
00:08:54,000 --> 00:09:00,000
We tested the Vault client. We simulated Vault Agent files and direct API calls.
Everything works as expected.

91
00:09:00,000 --> 00:09:06,000
This is the complete Python Vault client. It reads secrets from Vault Agent files
in production. It falls back to direct API in development. It uses environment
variables as a last resort.

92
00:09:06,000 --> 00:09:12,000
The application is now fully integrated with Vault. Secrets are dynamic.
Credentials rotate automatically. The system is secure.

93
00:09:12,000 --> 00:09:18,000
Phase 6 is now complete. You have a complete Vault integration.
The application reads secrets from Vault. The credentials are dynamic.
The system is secure by default.

94
00:09:18,000 --> 00:09:24,000
Thank you for watching. I'll see you in Phase 7.

95
00:09:24,000 --> 00:09:28,000
[End of Phase 6]