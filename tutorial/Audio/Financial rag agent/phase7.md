1
00:00:00,000 --> 00:00:06,000
Welcome to Phase 7. This is where we build the CI/CD pipeline. We move from manual deployments to automated, reliable, and secure releases.

2
00:00:06,000 --> 00:00:12,000
Up until now, we've been running everything locally. We've been building containers manually. We've been deploying to Kubernetes by hand. This works for development, but it doesn't scale.

3
00:00:12,000 --> 00:00:18,000
In production, we need automation. We need consistency. We need reliability. We need to catch errors before they reach the cluster. That's what CI/CD gives us.

4
00:00:18,000 --> 00:00:24,000
Open your editor and create `.github/workflows/ci.yml`.

5
00:00:24,000 --> 00:00:30,000
We'll start with the workflow name. This appears in the GitHub Actions UI.
[Types: name: "CI/CD Pipeline"]

6
00:00:30,000 --> 00:00:36,000
The name tells you what the workflow does. "CI/CD Pipeline" is clear and descriptive.

7
00:00:36,000 --> 00:00:42,000
Now let's define when the workflow runs. This is the "on" section.
[Types: on:]

8
00:00:42,000 --> 00:00:48,000
We want to run on push to main and develop branches.
[Types: push: branches: [main, develop]]

9
00:00:48,000 --> 00:00:54,000
Every push to main or develop triggers the workflow. This ensures every change is tested.

10
00:00:54,000 --> 00:01:00,000
We want to run on pull requests targeting main.
[Types: pull_request: branches: [main]]

11
00:01:00,000 --> 00:01:06,000
Pull request runs catch issues before they merge. This is where we gate quality.

12
00:01:06,000 --> 00:01:12,000
We want to allow manual triggering from the GitHub UI.
[Types: workflow_dispatch:]

13
00:01:12,000 --> 00:01:18,000
Workflow dispatch is useful for testing and debugging. You can run the workflow manually.

14
00:01:18,000 --> 00:01:24,000
Now let's define the first job. This is the secret scan job.
[Types: jobs:]

15
00:01:24,000 --> 00:01:30,000
We'll start with the Gitleaks secret scan.
[Types: secrets-scan:]

16
00:01:30,000 --> 00:01:36,000
We give it a display name.
[Types: name: "🔐 Secret Scan"]

17
00:01:36,000 --> 00:01:42,000
We specify the runner. Ubuntu is the standard choice.
[Types: runs-on: ubuntu-latest]

18
00:01:42,000 --> 00:01:48,000
Now let's define the steps. The first step is checkout.
[Types: steps: - name: Checkout uses: actions/checkout@v4 with: fetch-depth: 0]

19
00:01:48,000 --> 00:01:54,000
We use actions/checkout@v4 to check out the repository. fetch-depth: 0 means full history. This is needed for Gitleaks to scan all commits.

20
00:01:54,000 --> 00:02:00,000
Now let's run Gitleaks.
[Types: - name: Run Gitleaks uses: gitleaks/gitleaks-action@v2 env: GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }} GITLEAKS_LICENSE: ${{ secrets.GITLEAKS_LICENSE }} with: args: --config=.gitleaks.toml --verbose --redact]

21
00:02:00,000 --> 00:02:06,000
Gitleaks scans the code for hardcoded secrets. It uses our configuration file.
The --verbose flag gives detailed output. The --redact flag masks secrets in logs.

22
00:02:06,000 --> 00:02:12,000
If Gitleaks finds a secret, the job fails. The workflow stops. The developer must fix the issue.

23
00:02:12,000 --> 00:02:18,000
Now let's define the second job. This is the vulnerability scan.
[Types: vulnerability-scan: name: "🐛 Vulnerability Scan" runs-on: ubuntu-latest needs: secrets-scan]

24
00:02:18,000 --> 00:02:24,000
We use needs: secrets-scan to ensure this job only runs after the secret scan passes.

25
00:02:24,000 --> 00:02:30,000
Now let's define the steps for vulnerability scan.
[Types: steps: - name: Checkout uses: actions/checkout@v4]

26
00:02:30,000 --> 00:02:36,000
We checkout the code again. Each job gets a fresh checkout.

27
00:02:36,000 --> 00:02:42,000
Now let's run Trivy.
[Types: - name: Run Trivy uses: aquasecurity/trivy-action@master with: scan-type: fs scan-ref: . security-checks: vuln,secret severity: CRITICAL,HIGH]

28
00:02:42,000 --> 00:02:48,000
Trivy scans the file system for vulnerabilities. It checks dependencies and configuration files. It looks for critical and high severity issues.

29
00:02:48,000 --> 00:02:54,000
If Trivy finds a vulnerability, the job fails. The workflow stops. The developer must fix the issue.

30
00:02:54,000 --> 00:03:00,000
Now let's define the third job. This is the OPA policy check.
[Types: opa-policy-check: name: "📋 OPA Policy Check" runs-on: ubuntu-latest needs: [secrets-scan, vulnerability-scan]]

31
00:03:00,000 --> 00:03:06,000
We depend on both security scans. OPA runs after they pass.

32
00:03:06,000 --> 00:03:12,000
Now let's define the steps for OPA policy check.
[Types: steps: - name: Checkout uses: actions/checkout@v4]

33
00:03:12,000 --> 00:03:18,000
We checkout the code again.

34
00:03:18,000 --> 00:03:24,000
Now let's install Conftest.
[Types: - name: Install Conftest run: curl -L https://github.com/open-policy-agent/conftest/releases/download/v0.50.0/conftest_0.50.0_Linux_x86_64.tar.gz | tar xz -C /usr/local/bin]

35
00:03:24,000 --> 00:03:30,000
Conftest is the tool that evaluates OPA policies against configuration files.

36
00:03:30,000 --> 00:03:36,000
Now let's check the Helm templates.
[Types: - name: Check Helm templates run: helm template infrastructure/helm/ -f infrastructure/helm/values.yaml | conftest test - --policy policies/rego/ --namespace financial_rag]

37
00:03:36,000 --> 00:03:42,000
This renders the Helm templates and checks them against our OPA policies. If any policy fails, the job fails.

38
00:03:42,000 --> 00:03:48,000
Now let's define the fourth job. This is the unit tests.
[Types: unit-tests: name: "🧪 Unit Tests" runs-on: ubuntu-latest needs: [secrets-scan, vulnerability-scan, opa-policy-check]]

39
00:03:48,000 --> 00:03:54,000
We depend on all previous checks. Unit tests run after they pass.

40
00:03:54,000 --> 00:04:00,000
Now let's define the steps for unit tests.
[Types: steps: - name: Checkout uses: actions/checkout@v4]

41
00:04:00,000 --> 00:04:06,000
We checkout the code again.

42
00:04:06,000 --> 00:04:12,000
Now let's set up Python.
[Types: - name: Setup Python uses: actions/setup-python@v5 with: python-version: "3.11"]

43
00:04:12,000 --> 00:04:18,000
We use actions/setup-python to install Python 3.11.

44
00:04:18,000 --> 00:04:24,000
Now let's install dependencies.
[Types: - name: Install dependencies run: pip install -e ".[dev]"]

45
00:04:24,000 --> 00:04:30,000
This installs the package in editable mode with development dependencies.

46
00:04:30,000 --> 00:04:36,000
Now let's run the tests.
[Types: - name: Run tests run: pytest tests/unit -v --cov=src --cov-report=term-missing]

47
00:04:36,000 --> 00:04:42,000
We run pytest on the unit tests. The --cov flag measures code coverage. The --cov-report=term-missing shows uncovered lines.

48
00:04:42,000 --> 00:04:48,000
If any test fails, the job fails. The workflow stops.

49
00:04:48,000 --> 00:04:54,000
Now let's define the fifth job. This is the integration tests.
[Types: integration-tests: name: "🔗 Integration Tests" runs-on: ubuntu-latest needs: [unit-tests]]

50
00:04:54,000 --> 00:05:00,000
We depend on unit tests. Integration tests run after they pass.

51
00:05:00,000 --> 00:05:06,000
Now let's define the services for integration tests.
[Types: services: postgres: image: pgvector/pgvector:pg17 env: POSTGRES_PASSWORD: postgres options: > --health-cmd pg_isready --health-interval 10s --health-timeout 5s --health-retries 5 ports: - 5432:5432 redis: image: redis:7-alpine env: REDIS_PASSWORD: redis options: > --health-cmd "redis-cli ping" --health-interval 10s --health-timeout 5s --health-retries 5 ports: - 6379:6379]

52
00:05:06,000 --> 00:05:12,000
We start a PostgreSQL container with pgvector for the tests. We start a Redis container for the tests. Both have health checks to ensure they're ready.

53
00:05:12,000 --> 00:05:18,000
Now let's define the steps for integration tests.
[Types: steps: - name: Checkout uses: actions/checkout@v4]

54
00:05:18,000 --> 00:05:24,000
We checkout the code again.

55
00:05:24,000 --> 00:05:30,000
Now let's set up Python.
[Types: - name: Setup Python uses: actions/setup-python@v5 with: python-version: "3.11"]

56
00:05:30,000 --> 00:05:36,000
We use actions/setup-python to install Python 3.11.

57
00:05:36,000 --> 00:05:42,000
Now let's install dependencies.
[Types: - name: Install dependencies run: pip install -e ".[dev]"]

58
00:05:42,000 --> 00:05:48,000
This installs the package in editable mode with development dependencies.

59
00:05:48,000 --> 00:05:54,000
Now let's run the integration tests.
[Types: - name: Run integration tests run: pytest tests/integration -v -m integration]

60
00:05:54,000 --> 00:06:00,000
We run pytest on the integration tests. The -m integration flag runs only tests marked with the integration marker.

61
00:06:00,000 --> 00:06:06,000
If any test fails, the job fails. The workflow stops.

62
00:06:06,000 --> 00:06:12,000
Now let's define the sixth job. This is the build image job.
[Types: build-image: name: "🐳 Build Image" runs-on: ubuntu-latest needs: [integration-tests] if: github.event_name == 'push' && (github.ref == 'refs/heads/main' || github.ref == 'refs/heads/develop')]

63
00:06:12,000 --> 00:06:18,000
We only build the image on push to main or develop. We don't build on pull requests. This saves time and resources.

64
00:06:18,000 --> 00:06:24,000
Now let's define the steps for build image.
[Types: steps: - name: Checkout uses: actions/checkout@v4]

65
00:06:24,000 --> 00:06:30,000
We checkout the code again.

66
00:06:30,000 --> 00:06:36,000
Now let's configure AWS credentials.
[Types: - name: Configure AWS credentials uses: aws-actions/configure-aws-credentials@v4 with: aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }} aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }} aws-region: us-east-1]

67
00:06:36,000 --> 00:06:42,000
This configures AWS credentials for ECR access. The credentials are stored in GitHub secrets.

68
00:06:42,000 --> 00:06:48,000
Now let's login to ECR.
[Types: - name: Login to ECR uses: aws-actions/amazon-ecr-login@v2]

69
00:06:48,000 --> 00:06:54,000
This logs in to Amazon ECR so we can push images.

70
00:06:54,000 --> 00:07:00,000
Now let's build and push the image.
[Types: - name: Build and push env: REGISTRY: ${{ secrets.ECR_REGISTRY }} REPOSITORY: financial-rag-agent IMAGE_TAG: ${{ github.sha }} run: | docker build -f infrastructure/docker/Dockerfile -t $REGISTRY/$REPOSITORY:$IMAGE_TAG . docker tag $REGISTRY/$REPOSITORY:$IMAGE_TAG $REGISTRY/$REPOSITORY:latest docker push $REGISTRY/$REPOSITORY:$IMAGE_TAG docker push $REGISTRY/$REPOSITORY:latest]

71
00:07:00,000 --> 00:07:06,000
We build the Docker image using our Dockerfile. We tag it with the commit SHA for versioning. We also tag it as latest. We push both tags to ECR.

72
00:07:06,000 --> 00:07:12,000
Now let's define the seventh job. This is the deploy staging job.
[Types: deploy-staging: name: "🚀 Deploy Staging" runs-on: ubuntu-latest needs: [build-image] if: github.ref == 'refs/heads/develop']

73
00:07:12,000 --> 00:07:18,000
We only deploy staging on push to develop. This is the development branch.

74
00:07:18,000 --> 00:07:24,000
Now let's define the steps for deploy staging.
[Types: steps: - name: Checkout uses: actions/checkout@v4]

75
00:07:24,000 --> 00:07:30,000
We checkout the code again.

76
00:07:30,000 --> 00:07:36,000
Now let's configure kubectl.
[Types: - name: Configure kubectl uses: azure/setup-kubectl@v4]

77
00:07:36,000 --> 00:07:42,000
This installs kubectl for interacting with the Kubernetes cluster.

78
00:07:42,000 --> 00:07:48,000
Now let's configure AWS credentials.
[Types: - name: Configure AWS credentials uses: aws-actions/configure-aws-credentials@v4 with: aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }} aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }} aws-region: us-east-1]

79
00:07:48,000 --> 00:07:54,000
We need AWS credentials to update the kubeconfig for EKS.

80
00:07:54,000 --> 00:08:00,000
Now let's update the kubeconfig.
[Types: - name: Update kubeconfig run: aws eks update-kubeconfig --region us-east-1 --name financial-rag-staging-cluster]

81
00:08:00,000 --> 00:08:06,000
This updates the kubeconfig to point to the staging EKS cluster.

82
00:08:06,000 --> 00:08:12,000
Now let's deploy with Helm.
[Types: - name: Helm upgrade run: | helm upgrade --install finrag-staging ./infrastructure/helm/ --namespace financial-rag --create-namespace -f infrastructure/helm/values.yaml -f infrastructure/helm/values.staging.yaml --set global.image.tag=${{ github.sha }} --wait --timeout 10m]

83
00:08:12,000 --> 00:08:18,000
We deploy the application to staging. We use the staging values file. We set the image tag to the commit SHA. We wait for the deployment to be ready.

84
00:08:18,000 --> 00:08:24,000
Now let's define the eighth job. This is the deploy production job.
[Types: deploy-prod: name: "🚀 Deploy Production" runs-on: ubuntu-latest needs: [deploy-staging] if: github.ref == 'refs/heads/main']

85
00:08:24,000 --> 00:08:30,000
We only deploy production on push to main. We depend on staging deployment being successful.

86
00:08:30,000 --> 00:08:36,000
Now let's define the steps for deploy production.
[Types: steps: - name: Checkout uses: actions/checkout@v4]

87
00:08:36,000 --> 00:08:42,000
We checkout the code again.

88
00:08:42,000 --> 00:08:48,000
Now let's configure AWS credentials.
[Types: - name: Configure AWS credentials uses: aws-actions/configure-aws-credentials@v4 with: aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }} aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }} aws-region: us-east-1]

89
00:08:48,000 --> 00:08:54,000
We need AWS credentials to update the kubeconfig for EKS.

90
00:08:54,000 --> 00:09:00,000
Now let's update the kubeconfig.
[Types: - name: Update kubeconfig run: aws eks update-kubeconfig --region us-east-1 --name financial-rag-prod-cluster]

91
00:09:00,000 --> 00:09:06,000
This updates the kubeconfig to point to the production EKS cluster.

92
00:09:06,000 --> 00:09:12,000
Now let's deploy with Helm.
[Types: - name: Helm upgrade run: | helm upgrade --install finrag-prod ./infrastructure/helm/ --namespace financial-rag --create-namespace -f infrastructure/helm/values.yaml -f infrastructure/helm/values.prod.yaml --set global.image.tag=${{ github.sha }} --wait --timeout 10m]

93
00:09:12,000 --> 00:09:18,000
We deploy the application to production. We use the production values file. We set the image tag to the commit SHA. We wait for the deployment to be ready.

94
00:09:18,000 --> 00:09:24,000
Now let me recap what we've built in Part 1.

95
00:09:24,000 --> 00:09:30,000
We built the GitHub Actions workflow with eight jobs. Secret scan, vulnerability scan, OPA policy check, unit tests, integration tests, build image, deploy staging, and deploy production.

96
00:09:30,000 --> 00:09:36,000
We understood the conditional execution. Some jobs only run on certain branches. Some jobs depend on other jobs. This saves time and resources.

97
00:09:36,000 --> 00:09:42,000
We set up GitHub secrets. AWS credentials, ECR registry, Gitleaks license, Slack webhook. These are required for the workflow to run.

98
00:09:42,000 --> 00:09:48,000
In Part 2, we'll build the multi-stage Dockerfile. We'll optimize the image for production with layer caching and security hardening.

99
00:09:48,000 --> 00:09:54,000
Thank you for watching. I'll see you in Part 2.

100
00:09:54,000 --> 00:09:58,000
[End of Part 1]

1
00:00:00,000 --> 00:00:06,000
Welcome back to Phase 7. In Part 2, we build the multi-stage Dockerfile.

2
00:00:06,000 --> 00:00:12,000
A Dockerfile is a recipe for building container images. But a simple Dockerfile
is not enough for production. We need a multi-stage Dockerfile.

3
00:00:12,000 --> 00:00:18,000
Why multi-stage? Because the build environment has tools we don't need in production.
Compilers, package managers, development dependencies. These increase the image
size and attack surface.

4
00:00:18,000 --> 00:00:24,000
With multi-stage, we build the application in one stage. We copy only the artifacts
to the final stage. The final stage is small, secure, and fast.

5
00:00:24,000 --> 00:00:30,000
Open your editor and create `infrastructure/docker/Dockerfile`.

6
00:00:30,000 --> 00:00:36,000
We'll start with the builder stage. This is where we install dependencies.
[Types: # ── Stage 1: builder ──────────────────────────────────────────────────────────]

7
00:00:36,000 --> 00:00:42,000
We use the slim Python image as our base. This is smaller than the full image.
[Types: FROM python:3.11-slim AS builder]

8
00:00:42,000 --> 00:00:48,000
Now we add security updates. This fixes known CVEs in the base image.
[Types: RUN apt-get update && \ apt-get upgrade -y --no-install-recommends && \ apt-get install -y --no-install-recommends \ ca-certificates \ curl \ && \ apt-get clean && \ rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*]

9
00:00:48,000 --> 00:00:54,000
The apt-get update refreshes the package list. The upgrade installs all security updates.
We install ca-certificates for HTTPS connections and curl for health checks.
Then we clean up the apt cache to reduce image size.

10
00:00:54,000 --> 00:01:00,000
Now we set the working directory.
[Types: WORKDIR /app]

11
00:01:00,000 --> 00:01:06,000
All subsequent commands run in this directory. This is where our code lives.

12
00:01:06,000 --> 00:01:12,000
We install build dependencies. These are needed for compiling Python packages.
[Types: RUN apt-get update && apt-get install -y --no-install-recommends \ build-essential \ libpq-dev \ && apt-get clean && \ rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*]

13
00:01:12,000 --> 00:01:18,000
build-essential provides compilers like gcc. libpq-dev provides PostgreSQL client libraries.
These are needed to install packages like psycopg2 and pgvector.

14
00:01:18,000 --> 00:01:24,000
Now we copy the dependency files first. This enables layer caching.
[Types: COPY pyproject.toml README.md ./]

15
00:01:24,000 --> 00:01:30,000
We copy pyproject.toml before the source code. If pyproject.toml doesn't change,
Docker reuses the cached layer. This speeds up builds.

16
00:01:30,000 --> 00:01:36,000
We copy the source code.
[Types: COPY src/ ./src/]

17
00:01:36,000 --> 00:01:42,000
Now we create a virtual environment and install dependencies.
[Types: RUN python -m venv /app/venv && \ /app/venv/bin/pip install --upgrade pip setuptools wheel && \ /app/venv/bin/pip install -e "." --no-cache-dir]

18
00:01:42,000 --> 00:01:48,000
python -m venv creates a virtual environment at /app/venv. We upgrade pip, setuptools, and wheel.
Then we install our package in editable mode. --no-cache-dir reduces image size.

19
00:01:48,000 --> 00:01:54,000
This completes the builder stage. Now let's start the production stage.
[Types: # ── Stage 2: production ───────────────────────────────────────────────────────]

20
00:01:54,000 --> 00:02:00,000
We use the bookworm slim image. This is the Debian version of the Python image.
[Types: FROM python:3.11-slim-bookworm AS production]

21
00:02:00,000 --> 00:02:06,000
We set the working directory again.
[Types: WORKDIR /app]

22
00:02:06,000 --> 00:02:12,000
We install runtime system dependencies.
[Types: RUN apt-get update && \ apt-get upgrade -y --no-install-recommends && \ apt-get install -y --no-install-recommends \ libpq5 \ curl \ ca-certificates \ && \ apt-get clean && \ rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*]

23
00:02:12,000 --> 00:02:18,000
libpq5 is the PostgreSQL client library. curl is for health checks.
ca-certificates is for HTTPS connections. These are the only runtime dependencies.

24
00:02:18,000 --> 00:02:24,000
Now we create a non-root user for security.
[Types: RUN groupadd -r finrag && useradd -r -g finrag finrag && \ mkdir -p /app/data && \ chown -R finrag:finrag /app]

25
00:02:24,000 --> 00:02:30,000
groupadd creates a system group called finrag. useradd creates a system user called finrag.
We create the /app/data directory and change ownership to finrag.

26
00:02:30,000 --> 00:02:36,000
Now we copy the virtual environment from the builder stage.
[Types: COPY --from=builder --chown=finrag:finrag /app/venv /app/venv]

27
00:02:36,000 --> 00:02:42,000
We copy the source code from the builder stage.
[Types: COPY --from=builder --chown=finrag:finrag /app/src /app/src]

28
00:02:42,000 --> 00:02:48,000
We copy the pyproject.toml file.
[Types: COPY --from=builder --chown=finrag:finrag /app/pyproject.toml /app/pyproject.toml]

29
00:02:48,000 --> 00:02:54,000
Now we set the environment variables.
[Types: ENV PATH="/app/venv/bin:$PATH" \ PYTHONUNBUFFERED=1 \ PYTHONDONTWRITEBYTECODE=1 \ PYTHONPATH="/app/src" \ TZ="UTC"]

30
00:02:54,000 --> 00:03:00,000
PATH includes the virtual environment binaries. PYTHONUNBUFFERED forces Python to flush stdout immediately.
PYTHONDONTWRITEBYTECODE prevents writing .pyc files. PYTHONPATH points to our source code.

31
00:03:00,000 --> 00:03:06,000
We do some security hardening. Remove unnecessary files.
[Types: RUN find /app -type f -name "*.pyc" -delete && \ find /app -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true]

32
00:03:06,000 --> 00:03:12,000
.pyc files and __pycache__ directories are not needed in production.
Removing them reduces image size and improves security.

33
00:03:12,000 --> 00:03:18,000
Now we switch to the non-root user.
[Types: USER finrag]

34
00:03:18,000 --> 00:03:24,000
All subsequent commands run as finrag. This is the principle of least privilege.

35
00:03:24,000 --> 00:03:30,000
We add a health check.
[Types: HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \ CMD python -c "import requests; requests.get('http://localhost:8000/health')" || exit 1]

36
00:03:30,000 --> 00:03:36,000
The health check runs every 30 seconds. It calls the /health endpoint.
If the endpoint fails, Kubernetes restarts the container.

37
00:03:36,000 --> 00:03:42,000
We expose port 8000.
[Types: EXPOSE 8000]

38
00:03:42,000 --> 00:03:48,000
This is the port the application listens on. Kubernetes routes traffic to this port.

39
00:03:48,000 --> 00:03:54,000
We define the command to run the application.
[Types: CMD ["uvicorn", "financial_rag.api.server:app", \ "--host", "0.0.0.0", \ "--port", "8000", \ "--workers", "2", \ "--loop", "asyncio", \ "--access-log"]]

40
00:03:54,000 --> 00:04:00,000
We start uvicorn with the server app. We bind to 0.0.0.0 so it listens on all interfaces.
We use 2 workers for concurrency. We use the asyncio loop. We enable access logging.

41
00:04:00,000 --> 00:04:06,000
Now let's add an optional test stage. This is for running tests inside the container.
[Types: # ── Stage 3: test ────────────────────────────────────────────────────────────]

42
00:04:06,000 --> 00:04:12,000
[Types: FROM builder AS test]

43
00:04:12,000 --> 00:04:18,000
We extend the builder stage. This gives us all build dependencies.

44
00:04:18,000 --> 00:04:24,000
We install test dependencies.
[Types: RUN /app/venv/bin/pip install pytest pytest-asyncio pytest-cov httpx]

45
00:04:24,000 --> 00:04:30,000
These are only needed for testing. They are not included in the production image.

46
00:04:30,000 --> 00:04:36,000
We define the test command.
[Types: CMD ["pytest", "tests/", "-v", "--cov=src", "--cov-report=term-missing"]]

47
00:04:36,000 --> 00:04:42,000
This runs all tests with coverage reporting. This is used in CI.

48
00:04:42,000 --> 00:04:48,000
Now let me show you the complete Dockerfile. You should have this in your editor.

49
00:04:48,000 --> 00:04:54,000
Let me explain the layer caching in more detail.

50
00:04:54,000 --> 00:05:00,000
Docker caches each instruction. If a layer hasn't changed, Docker reuses the cached layer.
The order of instructions matters. We copy pyproject.toml before the source code.

51
00:05:00,000 --> 00:05:06,000
This means dependency installation is cached unless pyproject.toml changes.
If pyproject.toml doesn't change, Docker reuses the cached layer. The build is fast.

52
00:05:06,000 --> 00:05:12,000
If pyproject.toml changes, Docker rebuilds the layer. The build is slower but correct.

53
00:05:12,000 --> 00:05:18,000
Now let's build the image.
[Types: docker build -f infrastructure/docker/Dockerfile -t financial-rag-agent:latest .]

54
00:05:18,000 --> 00:05:24,000
The -f flag specifies the Dockerfile path. The -t flag tags the image.
The dot at the end specifies the build context. This is the current directory.

55
00:05:24,000 --> 00:05:30,000
The build process takes about 2 minutes on a fast machine. It downloads base images,
installs dependencies, and copies the source code.

56
00:05:30,000 --> 00:05:36,000
Now let's test the image. Run the container and check the health endpoint.

57
00:05:36,000 --> 00:05:42,000
[Types: docker run -d --name finrag-test -p 8000:8000 financial-rag-agent:latest]

58
00:05:42,000 --> 00:05:48,000
The -d flag runs the container in detached mode. The --name flag gives it a name.
The -p flag maps port 8000 from the container to the host.

59
00:05:48,000 --> 00:05:54,000
Wait for the application to start. Then check the health endpoint.
[Types: sleep 10]
[Types: curl http://localhost:8000/health]

60
00:05:54,000 --> 00:06:00,000
You should see `{"status":"healthy"}`. This confirms the application is running.

61
00:06:00,000 --> 00:06:06,000
Now let's check the image size.
[Types: docker images financial-rag-agent:latest]

62
00:06:06,000 --> 00:06:12,000
The image should be about 200MB. This is reasonable for a Python application.
The base image is about 100MB. Dependencies add about 50MB. Source code adds about 50MB.

63
00:06:12,000 --> 00:06:18,000
Now let's scan the image for vulnerabilities.
[Types: trivy image --severity CRITICAL,HIGH financial-rag-agent:latest]

64
00:06:18,000 --> 00:06:24,000
Trivy scans the image for critical and high severity vulnerabilities.
If vulnerabilities are found, we need to fix them. This might mean updating base images.

65
00:06:24,000 --> 00:06:30,000
Now let me explain the security hardening in the Dockerfile.

66
00:06:30,000 --> 00:06:36,000
The non-root user is the most important. The container runs as finrag, not root.
If an attacker compromises the container, they don't have root access.

67
00:06:36,000 --> 00:06:42,000
The read-only root filesystem is also important. In the Kubernetes pod spec,
we will set readOnlyRootFilesystem: true. This prevents attackers from writing
to the filesystem.

68
00:06:42,000 --> 00:06:48,000
The health check is important for Kubernetes. It allows Kubernetes to detect
unhealthy containers and restart them.

69
00:06:48,000 --> 00:06:54,000
Now let me recap what we've built in Part 2.

70
00:06:54,000 --> 00:07:00,000
We built a multi-stage Dockerfile. The builder stage installs dependencies.
The production stage copies the artifacts. The test stage runs tests.

71
00:07:00,000 --> 00:07:06,000
We implemented layer caching. We copy pyproject.toml before the source code.
This speeds up builds when dependencies don't change.

72
00:07:06,000 --> 00:07:12,000
We added a non-root user. The container runs as finrag, not root.
This improves security.

73
00:07:12,000 --> 00:07:18,000
We added a health check. Kubernetes uses this to monitor the container.

74
00:07:18,000 --> 00:07:24,000
We tested the image. We ran the container and checked the health endpoint.
We scanned the image with Trivy.

75
00:07:24,000 --> 00:07:30,000
In Part 3, we'll set up the pre-commit hooks and OPA policies.

76
00:07:30,000 --> 00:07:36,000
Thank you for watching. I'll see you in Part 3.

77
00:07:36,000 --> 00:07:40,000
[End of Part 2]

1
00:00:00,000 --> 00:00:06,000
Welcome back to Phase 7. In Part 3, we set up the pre-commit hooks and OPA policies.

2
00:00:06,000 --> 00:00:12,000
Pre-commit hooks run locally before code is committed. They catch issues early.
They prevent bad code from reaching the repository.

3
00:00:12,000 --> 00:00:18,000
OPA policies run in CI. They enforce standards across all code.
They prevent bad configurations from reaching the cluster.

4
00:00:18,000 --> 00:00:24,000
Think of pre-commit hooks as the first line of defense. They catch mistakes
before they leave your machine. OPA policies are the second line. They catch
mistakes before they reach production.

5
00:00:24,000 --> 00:00:30,000
Open your editor and create `.pre-commit-config.yaml` in the project root.

6
00:00:30,000 --> 00:00:36,000
We'll start with the Ruff hook. Ruff is our linter and formatter.
[Types: repos: - repo: https://github.com/astral-sh/ruff-pre-commit]

7
00:00:36,000 --> 00:00:42,000
We use Ruff because it's fast. It replaces flake8, isort, and black.
One tool. One configuration. Fast execution.

8
00:00:42,000 --> 00:00:48,000
We specify the revision. This pins the version for consistency.
[Types: rev: v0.4.9]

9
00:00:48,000 --> 00:00:54,000
Now we define the hooks.
[Types: hooks: - id: ruff args: [--fix]]

10
00:00:54,000 --> 00:01:00,000
The first hook runs ruff with --fix. This automatically fixes many issues.
It corrects import ordering, removes unused imports, and fixes style violations.

11
00:01:00,000 --> 00:01:06,000
The second hook runs ruff-format. This formats the code.
[Types: - id: ruff-format]

12
00:01:06,000 --> 00:01:12,000
Ruff format is like black. It enforces consistent code style across the project.
This eliminates formatting debates in code reviews.

13
00:01:12,000 --> 00:01:18,000
Now let's add the Mypy hook. Mypy is our type checker.
[Types: - repo: https://github.com/pre-commit/mirrors-mypy]

14
00:01:18,000 --> 00:01:24,000
We specify the revision.
[Types: rev: v1.10.0]

15
00:01:24,000 --> 00:01:30,000
[Types: hooks: - id: mypy additional_dependencies: [pydantic, sqlalchemy]]

16
00:01:30,000 --> 00:01:36,000
Mypy verifies type annotations. It catches type errors before runtime.
The additional_dependencies tell mypy about pydantic and sqlalchemy types.

17
00:01:36,000 --> 00:01:42,000
Now let's add the Gitleaks hook. Gitleaks detects secrets.
[Types: - repo: https://github.com/gitleaks/gitleaks]

18
00:01:42,000 --> 00:01:48,000
We specify the revision.
[Types: rev: v8.18.0]

19
00:01:48,000 --> 00:01:54,000
[Types: hooks: - id: gitleaks args: [--config=.gitleaks.toml]]

20
00:01:54,000 --> 00:02:00,000
Gitleaks scans for hardcoded secrets like API keys and passwords.
The config file tells it what to look for and what to ignore.

21
00:02:00,000 --> 00:02:06,000
Now let's install the pre-commit hooks. Open your terminal.
[Types: pre-commit install]

22
00:02:06,000 --> 00:02:12,000
This command installs the hooks in your local repository. The hooks run
automatically on `git commit`.

23
00:02:12,000 --> 00:02:18,000
Now let's test the hooks. Make a small change and commit it.
[Types: git add . git commit -m "test: pre-commit hooks"]

24
00:02:18,000 --> 00:02:24,000
You should see Ruff running, Mypy running, and Gitleaks running.
If all pass, the commit succeeds.

25
00:02:24,000 --> 00:02:30,000
Now let's build the OPA policies. Open your editor and create
`policies/rego/k8s_admission.rego`.

26
00:02:30,000 --> 00:02:36,000
This is the admission policy for Kubernetes pods. It enforces security standards.
[Types: package financial_rag.k8s.admission]

27
00:02:36,000 --> 00:02:42,000
The package name groups related policies together.
[Types: import future.keywords.if import future.keywords.in import future.keywords.contains]

28
00:02:42,000 --> 00:02:48,000
We import future keywords for modern Rego syntax. This makes the policies
more readable and maintainable.

29
00:02:48,000 --> 00:02:54,000
Now let's write the first rule. It denies :latest image tags.
[Types: deny contains msg if { container := input.review.object.spec.containers[_] endswith(container.image, ":latest") msg := sprintf("Container '%v' uses ':latest' tag. Pin to an immutable SHA or semver tag.", [container.name]) }]

30
00:02:54,000 --> 00:03:00,000
The rule finds every container. If the image ends with :latest, it denies.
The message tells the developer exactly what to fix.

31
00:03:00,000 --> 00:03:06,000
Why is :latest dangerous? Because it changes. Today it might be version 1.0.
Tomorrow it might be version 1.1. You can't reproduce bugs. You can't rollback safely.

32
00:03:06,000 --> 00:03:12,000
Now let's write the second rule. It requires resource requests and limits.
[Types: deny contains msg if { container := input.review.object.spec.containers[_] not container.resources.requests.cpu msg := sprintf("Container '%v' missing resources.requests.cpu. HPA cannot function without CPU requests.", [container.name]) }]

33
00:03:12,000 --> 00:03:18,000
Without CPU requests, the Horizontal Pod Autoscaler cannot function.
It doesn't know how much CPU each pod uses. It can't scale properly.

34
00:03:18,000 --> 00:03:24,000
[Types: deny contains msg if { container := input.review.object.spec.containers[_] not container.resources.requests.memory msg := sprintf("Container '%v' missing resources.requests.memory.", [container.name]) }]

35
00:03:24,000 --> 00:03:30,000
Memory requests are equally important. Without them, the scheduler can't
make placement decisions. Pods might run on nodes without enough memory.

36
00:03:30,000 --> 00:03:36,000
Now let's write the third rule. It requires readOnlyRootFilesystem.
[Types: deny contains msg if { container := input.review.object.spec.containers[_] not container.securityContext.readOnlyRootFilesystem == true msg := sprintf("Container '%v': securityContext.readOnlyRootFilesystem must be true. Use emptyDir for writable paths.", [container.name]) }]

37
00:03:36,000 --> 00:03:42,000
This is a security best practice. All containers must have readOnlyRootFilesystem.
This prevents post-exploit persistence. If an attacker gets in, they can't write.

38
00:03:42,000 --> 00:03:48,000
Now let's write the fourth rule. It requires allowPrivilegeEscalation to be false.
[Types: deny contains msg if { container := input.review.object.spec.containers[_] not container.securityContext.allowPrivilegeEscalation == false msg := sprintf("Container '%v': securityContext.allowPrivilegeEscalation must be false.", [container.name]) }]

39
00:03:48,000 --> 00:03:54,000
This prevents setuid binaries from escalating privileges. It blocks a common
container escape technique. No privilege escalation is allowed.

40
00:03:54,000 --> 00:04:00,000
Now let's write the fifth rule. It requires capabilities to be dropped.
[Types: deny contains msg if { container := input.review.object.spec.containers[_] not container.securityContext.capabilities.drop msg := sprintf("Container '%v': securityContext.capabilities.drop must be set. Require drop: [ALL].", [container.name]) }]

41
00:04:00,000 --> 00:04:06,000
ALL capabilities must be dropped. No container needs capabilities in production.
This reduces the attack surface significantly.

42
00:04:06,000 --> 00:04:12,000
Now let's write the sixth rule. It requires running as a non-root user.
[Types: deny contains msg if { container := input.review.object.spec.containers[_] container.securityContext.runAsUser == 0 msg := sprintf("Container '%v' runs as UID 0 (root). Set runAsUser to a non-zero UID.", [container.name]) }]

43
00:04:12,000 --> 00:04:18,000
Running as root is dangerous. If an attacker compromises the container,
they have root privileges on the container. Set runAsUser to a non-zero UID.

44
00:04:18,000 --> 00:04:24,000
Now let's create the Helm policy. Open `policies/rego/helm_policy.rego`.
[Types: package financial_rag.helm import future.keywords.if import future.keywords.in import future.keywords.contains]

45
00:04:24,000 --> 00:04:30,000
The Helm policy validates Helm manifests. It catches Kubernetes API issues.

46
00:04:30,000 --> 00:04:36,000
We define the removed APIs. These are APIs removed in Kubernetes 1.29+.
[Types: removed_apis := { "flowcontrol.apiserver.k8s.io/v1beta1", "flowcontrol.apiserver.k8s.io/v1beta2", "autoscaling/v2beta1", "autoscaling/v2beta2", "batch/v1beta1" }]

47
00:04:36,000 --> 00:04:42,000
These API versions are deprecated. They will not work on newer Kubernetes clusters.
Using them leads to failed upgrades.

48
00:04:42,000 --> 00:04:48,000
We write the rule that denies removed APIs.
[Types: deny contains msg if { input.apiVersion removed_apis[input.apiVersion] msg := sprintf("Resource '%v' uses removed API version '%v' — not supported in Kubernetes 1.29+.", [input.metadata.name, input.apiVersion]) }]

49
00:04:48,000 --> 00:04:54,000
If a manifest uses a removed API, the policy denies it. This prevents failed upgrades.

50
00:04:54,000 --> 00:05:00,000
Now let's write the HPA rule. It requires HPA to use autoscaling/v2.
[Types: deny contains msg if { input.kind == "HorizontalPodAutoscaler" input.apiVersion == "autoscaling/v1" msg := sprintf("HPA '%v' uses autoscaling/v1 — must use autoscaling/v2 for CPU+memory dual-metric scaling.", [input.metadata.name]) }]

51
00:05:00,000 --> 00:05:06,000
autoscaling/v2 supports multiple metrics. autoscaling/v1 is limited to CPU.
This rule enforces the better API for autoscaling.

52
00:05:06,000 --> 00:05:12,000
Now let's create the Terraform policy. Open `policies/rego/terraform_policy.rego`.
[Types: package financial_rag.terraform import future.keywords.if import future.keywords.in import future.keywords.contains]

53
00:05:12,000 --> 00:05:18,000
The Terraform policy validates infrastructure as code. It catches security issues.

54
00:05:18,000 --> 00:05:24,000
We write the S3 rule. It requires S3 buckets to block public access.
[Types: deny contains msg if { resource := input.planned_values.root_module.resources[_] resource.type == "aws_s3_bucket_public_access_block" resource.values.block_public_acls != true msg := sprintf("S3 bucket '%v' does not block public ACLs — all buckets must block public access.", [resource.name]) }]

55
00:05:24,000 --> 00:05:30,000
This rule checks the public access block. If it's not configured, the policy denies.
This prevents accidental public exposure of S3 buckets.

56
00:05:30,000 --> 00:05:36,000
[Types: deny contains msg if { resource := input.planned_values.root_module.resources[_] resource.type == "aws_s3_bucket_public_access_block" resource.values.restrict_public_buckets != true msg := sprintf("S3 bucket '%v' does not restrict public buckets.", [resource.name]) }]

57
00:05:36,000 --> 00:05:42,000
The restrict_public_buckets setting is an additional security control.
It ensures buckets aren't publicly accessible even if the ACL is misconfigured.

58
00:05:42,000 --> 00:05:48,000
Now we write the RDS rule. It requires RDS encryption.
[Types: deny contains msg if { resource := input.planned_values.root_module.resources[_] resource.type == "aws_db_instance" not resource.values.storage_encrypted == true msg := sprintf("RDS instance '%v' storage_encrypted must be true.", [resource.name]) }]

59
00:05:48,000 --> 00:05:54,000
Financial data must be encrypted at rest. This rule enforces that requirement.
No unencrypted RDS instances are allowed.

60
00:05:54,000 --> 00:06:00,000
[Types: deny contains msg if { resource := input.planned_values.root_module.resources[_] resource.type == "aws_db_instance" resource.values.publicly_accessible == true msg := sprintf("RDS instance '%v' must not be publicly accessible.", [resource.name]) }]

61
00:06:00,000 --> 00:06:06,000
RDS instances must not be publicly accessible. This prevents direct database
access from the internet. All access should go through the application.

62
00:06:06,000 --> 00:06:12,000
Now let's run the policies with conftest. First, install conftest.
[Types: brew install conftest]

63
00:06:12,000 --> 00:06:18,000
Now test the admission policies.
[Types: conftest verify --policy policies/rego/ --namespace financial_rag]

64
00:06:18,000 --> 00:06:24,000
The verify command runs the test fixtures. It ensures the policies work correctly.

65
00:06:24,000 --> 00:06:30,000
Now test a Kubernetes manifest against the policies.
[Types: conftest test --policy policies/rego/ --input kubernetes/deployment.yaml]

66
00:06:30,000 --> 00:06:36,000
If the manifest violates a policy, conftest will fail. The error message
tells you exactly which rule was violated.

67
00:06:36,000 --> 00:06:42,000
Now let me recap what we've built in Part 3.

68
00:06:42,000 --> 00:06:48,000
We set up pre-commit hooks. Ruff for linting and formatting. Mypy for type checking.
Gitleaks for secret detection. These run on every commit.

69
00:06:48,000 --> 00:06:54,000
We wrote OPA policies for Kubernetes admission. They enforce security standards
like readOnlyRootFilesystem, no privilege escalation, and no :latest tags.

70
00:06:54,000 --> 00:07:00,000
We wrote OPA policies for Helm manifests. They catch deprecated API versions
and enforce HPA best practices.

71
00:07:00,000 --> 00:07:06,000
We wrote OPA policies for Terraform. They enforce S3 security and RDS encryption.

72
00:07:06,000 --> 00:07:12,000
These policies run in CI on every PR. They prevent bad code from reaching
production. They are your quality gates.

73
00:07:12,000 --> 00:07:18,000
In Part 4, we'll set up the utility scripts for local development.
Start.sh, stop.sh, and cleanup.sh for managing the development environment.

74
00:07:18,000 --> 00:07:24,000
Thank you for watching. I'll see you in Part 4.

75
00:07:24,000 --> 00:07:28,000
[End of Part 3]

1
00:00:00,000 --> 00:00:06,000
Welcome back to Phase 7. In Part 4, we build the utility scripts for local development.

2
00:00:06,000 --> 00:00:12,000
Local development should be easy. Developers should be able to start the environment
with a single command. They should be able to stop it with a single command.

3
00:00:12,000 --> 00:00:18,000
Think of it like a light switch. One command to turn everything on. One command to
turn everything off. No complexity. No remembering multiple commands.

4
00:00:18,000 --> 00:00:24,000
Open your terminal and create the scripts directory.
[Types: mkdir -p scripts]

5
00:00:24,000 --> 00:00:30,000
Now create the start script. Open `scripts/start.sh` in your editor.

6
00:00:30,000 --> 00:00:36,000
The shebang tells the system to use bash to run this script.
[Types: #!/bin/bash]

7
00:00:36,000 --> 00:00:42,000
We set -e to exit on error. This ensures the script stops if something fails.
[Types: set -euo pipefail]

8
00:00:42,000 --> 00:00:48,000
We define a helper function for logging. This makes the output consistent.
[Types: log() { echo "$*"; }]

9
00:00:48,000 --> 00:00:54,000
We define a success function for positive feedback.
[Types: success() { echo "✅ $*"; }]

10
00:00:54,000 --> 00:01:00,000
We define an error function for failure feedback.
[Types: error() { echo "❌ $*" >&2; exit 1; }]

11
00:01:00,000 --> 00:01:06,000
Now we need a function to wait for a container to become healthy.
[Types: wait_healthy() { local container=$1 local retries=30 log "Waiting for $container to be healthy..." until [ "$(docker inspect --format='{{.State.Health.Status}}' "$container" 2>/dev/null)" == "healthy" ]; do ((retries--)) || error "$container did not become healthy in time" sleep 2 done success "$container is healthy" }]

12
00:01:06,000 --> 00:01:12,000
This function uses Docker's inspect command to check the container health status.
It retries up to 30 times with 2-second intervals.

13
00:01:12,000 --> 00:01:18,000
Now we perform the preflight check. We ensure the .env file exists.
[Types: [ -f .env ] || error ".env file not found. Copy .env.example and configure it."]

14
00:01:18,000 --> 00:01:24,000
The .env file is required. It contains all the environment variables for the application.
Without it, the services won't start correctly.

15
00:01:24,000 --> 00:01:30,000
We source the .env file to load the environment variables.
[Types: set -a; source .env; set +a]

16
00:01:30,000 --> 00:01:36,000
The set -a exports all variables. The set +a stops exporting. This makes
the environment variables available to docker-compose.

17
00:01:36,000 --> 00:01:42,000
We check that Docker is installed and running.
[Types: command -v docker &>/dev/null || error "Docker is not installed or not in PATH" docker info &>/dev/null || error "Docker daemon is not running"]

18
00:01:42,000 --> 00:01:48,000
The command -v check ensures Docker is installed. The docker info check ensures
the Docker daemon is actually running.

19
00:01:48,000 --> 00:01:54,000
Now we start the core services.
[Types: log "Starting PostgreSQL and Redis..." docker compose up -d postgres redis]

20
00:01:54,000 --> 00:02:00,000
We use docker compose up -d to start the services in detached mode. The -d flag
means the containers run in the background.

21
00:02:00,000 --> 00:02:06,000
We wait for PostgreSQL to become healthy.
[Types: wait_healthy "${POSTGRES_CONTAINER:-finrag-postgres}"]

22
00:02:06,000 --> 00:02:12,000
The POSTGRES_CONTAINER variable comes from the .env file. If it's not set,
it defaults to finrag-postgres.

23
00:02:12,000 --> 00:02:18,000
We wait for Redis to become healthy.
[Types: wait_healthy "${REDIS_CONTAINER:-finrag-redis}"]

24
00:02:18,000 --> 00:02:24,000
The REDIS_CONTAINER variable comes from the .env file. If it's not set,
it defaults to finrag-redis.

25
00:02:24,000 --> 00:02:30,000
We show the status of all running containers.
[Types: docker compose ps]

26
00:02:30,000 --> 00:02:36,000
Now we ask the user if they want to start the management tools.
[Types: read -r -p "Start management tools (pgAdmin, Redis Commander)? (y/n) " start_tools echo]

27
00:02:36,000 --> 00:02:42,000
Management tools include pgAdmin for PostgreSQL management and Redis Commander
for Redis management.

28
00:02:42,000 --> 00:02:48,000
We check if the user answered yes.
[Types: if [[ $start_tools =~ ^[Yy]$ ]]; then log "Starting management tools..." docker compose --profile tools up -d success "Management tools started" fi]

29
00:02:48,000 --> 00:02:54,000
The --profile tools flag starts only the services marked with the tools profile.
This keeps the core services separate from the management tools.

30
00:02:54,000 --> 00:03:00,000
We print a summary of the running services.
[Types: echo success "Development environment ready!" echo " PostgreSQL  →  localhost:${POSTGRES_PORT:-5432}" echo " Redis       →  localhost:${REDIS_PORT:-6379}"]

31
00:03:00,000 --> 00:03:06,000
If the user started the management tools, we print their URLs as well.
[Types: if [[ $start_tools =~ ^[Yy]$ ]]; then echo " pgAdmin     →  http://localhost:5050  (admin@finrag.local / admin)" echo " Redis UI    →  http://localhost:8081" fi]

32
00:03:06,000 --> 00:03:12,000
This completes the start script. Now let's create the stop script.

33
00:03:12,000 --> 00:03:18,000
Open `scripts/stop.sh` in your editor.

34
00:03:18,000 --> 00:03:24,000
The shebang tells the system to use bash.
[Types: #!/bin/bash]

35
00:03:24,000 --> 00:03:30,000
We print a message indicating we're stopping services.
[Types: echo "🛑 Stopping all services..."]

36
00:03:30,000 --> 00:03:36,000
We run docker compose down to stop and remove all containers.
[Types: docker compose down]

37
00:03:36,000 --> 00:03:42,000
The down command stops all running containers and removes them. It also removes
the networks created by docker-compose.

38
00:03:42,000 --> 00:03:48,000
We print a confirmation message.
[Types: echo "✅ Services stopped"]

39
00:03:48,000 --> 00:03:54,000
This completes the stop script. Now let's create the cleanup script.

40
00:03:54,000 --> 00:04:00,000
Open `scripts/cleanup.sh` in your editor.

41
00:04:00,000 --> 00:04:06,000
The shebang tells the system to use bash.
[Types: #!/bin/bash]

42
00:04:06,000 --> 00:04:12,000
We print a warning message because cleanup is destructive.
[Types: echo "⚠️  WARNING: This will remove all containers and volumes!"]

43
00:04:12,000 --> 00:04:18,000
We ask the user to confirm.
[Types: read -p "Are you sure? (y/n) " -n 1 -r echo]

44
00:04:18,000 --> 00:04:24,000
This gives the user a chance to cancel if they didn't mean to run cleanup.

45
00:04:24,000 --> 00:04:30,000
We check if the user answered yes.
[Types: if [[ $REPLY =~ ^[Yy]$ ]]; then echo "🗑️  Removing containers and volumes..." docker compose down -v echo "✅ Cleanup complete" fi]

46
00:04:30,000 --> 00:04:36,000
The -v flag removes the volumes associated with the containers. This deletes
all data stored in PostgreSQL and Redis.

47
00:04:36,000 --> 00:04:42,000
Now we need to make the scripts executable.
[Types: chmod +x scripts/start.sh scripts/stop.sh scripts/cleanup.sh]

48
00:04:42,000 --> 00:04:48,000
This allows the scripts to be run directly from the terminal.

49
00:04:48,000 --> 00:04:54,000
Now let's test the start script. First, make sure you have a .env file.
[Types: cp .env.example .env]

50
00:04:54,000 --> 00:05:00,000
Then run the start script.
[Types: ./scripts/start.sh]

51
00:05:00,000 --> 00:05:06,000
You should see the services starting. PostgreSQL and Redis should become healthy.
You should see the status of all running containers.

52
00:05:06,000 --> 00:05:12,000
Now test the stop script.
[Types: ./scripts/stop.sh]

53
00:05:12,000 --> 00:05:18,000
All containers should stop and be removed.

54
00:05:18,000 --> 00:05:24,000
Now test the cleanup script.
[Types: ./scripts/cleanup.sh]

55
00:05:24,000 --> 00:05:30,000
You should see the warning message. If you answer yes, all containers and volumes
will be removed.

56
00:05:30,000 --> 00:05:36,000
Now let's look at the development docker-compose file. This is what the scripts
actually run.
[Types: cat infrastructure/docker/docker-compose.dev.yml]

57
00:05:36,000 --> 00:05:42,000
The docker-compose file defines the postgres, redis, and management services.
The start script uses this file to start the services.

58
00:05:42,000 --> 00:05:48,000
Now let me recap what we've built in Part 4.

59
00:05:48,000 --> 00:05:54,000
We built the start script. It checks for .env, starts PostgreSQL and Redis,
waits for them to be healthy, and optionally starts management tools.

60
00:05:54,000 --> 00:06:00,000
We built the stop script. It stops and removes all containers.

61
00:06:00,000 --> 00:06:06,000
We built the cleanup script. It stops containers and removes volumes.
This deletes all data for a fresh start.

62
00:06:06,000 --> 00:06:12,000
We made the scripts executable with chmod +x.

63
00:06:12,000 --> 00:06:18,000
We tested all three scripts. The development environment starts and stops correctly.

64
00:06:18,000 --> 00:06:24,000
These scripts make development easy. One command to start. One command to stop.
No complexity. No forgetting which services to start.

65
00:06:24,000 --> 00:06:30,000
In Part 5, we'll set up the Gitleaks standalone workflow. This runs in CI
on every PR to catch secrets.

66
00:06:30,000 --> 00:06:36,000
Thank you for watching. I'll see you in Part 5.

67
00:06:36,000 --> 00:06:40,000
[End of Part 4]
1
00:00:00,000 --> 00:00:06,000
Welcome back to Phase 7. In Part 5, we build the Gitleaks standalone workflow.

2
00:00:06,000 --> 00:00:12,000
This is the final part of our CI/CD pipeline. We already have Gitleaks in the
pre-commit hook, but that can be bypassed. This workflow runs in CI on every PR.

3
00:00:12,000 --> 00:00:18,000
Think of this as a second layer of defense. Even if a developer uses --no-verify,
the CI workflow will catch the secret before it reaches production.

4
00:00:18,000 --> 00:00:24,000
Open your editor and create `.github/workflows/gitleaks.yml`.

5
00:00:24,000 --> 00:00:30,000
We'll start with the workflow name. This appears in the GitHub Actions UI.
[Types: name: "Gitleaks Secret Detection"]

6
00:00:30,000 --> 00:00:36,000
Now let's define when the workflow runs.
[Types: on:]

7
00:00:36,000 --> 00:00:42,000
We run on every push to main and develop branches.
[Types: push: branches: [main, develop]]

8
00:00:42,000 --> 00:00:48,000
We run on every pull request targeting main.
[Types: pull_request: branches: [main]]

9
00:00:48,000 --> 00:00:54,000
We run a weekly scheduled scan to catch secrets in old commits.
[Types: schedule: # Scan full history weekly — catches secrets in old commits - cron: "0 3 * * 1"]

10
00:00:54,000 --> 00:01:00,000
The weekly scan is important. It catches secrets that were committed before
Gitleaks was installed.

11
00:01:00,000 --> 00:01:06,000
We also allow manual triggering for debugging.
[Types: workflow_dispatch: inputs: scan-depth: description: "Git log depth to scan (0 = full history)" default: "0"]

12
00:01:06,000 --> 00:01:12,000
Manual triggering lets us scan the full history on demand if needed.

13
00:01:12,000 --> 00:01:18,000
Now let's define the permissions. These control what the workflow can access.
[Types: permissions: contents: read security-events: write pull-requests: write]

14
00:01:18,000 --> 00:01:24,000
We need read access to the repository contents. We need write access to security events
to upload the SARIF report. We need write access to pull requests to post comments.

15
00:01:24,000 --> 00:01:30,000
Now let's define the job.
[Types: jobs: gitleaks: name: "🔐 Gitleaks Secret Scan" runs-on: ubuntu-latest]

16
00:01:30,000 --> 00:01:36,000
The job runs on the latest Ubuntu runner. This is the standard for GitHub Actions.

17
00:01:36,000 --> 00:01:42,000
Now let's define the first step. We check out the repository.
[Types: steps: - name: Checkout (full history for scheduled runs) uses: actions/checkout@v4 with: fetch-depth: ${{ github.event_name == 'schedule' && 0 || 50 }}]

18
00:01:42,000 --> 00:01:48,000
For scheduled runs, we check out the full history. This ensures we scan every commit.
For other runs, we check out the last 50 commits. This is faster.

19
00:01:48,000 --> 00:01:54,000
Now let's define the main Gitleaks step for PRs and pushes.
[Types: - name: Run Gitleaks — PR/push mode if: github.event_name != 'schedule' uses: gitleaks/gitleaks-action@v2 env: GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }} GITLEAKS_LICENSE: ${{ secrets.GITLEAKS_LICENSE }} with: args: > --config=.gitleaks.toml --verbose --redact --report-format=sarif --report-path=gitleaks-results.sarif --log-level=info]

20
00:01:54,000 --> 00:02:00,000
This step runs on every PR and push. It uses the official Gitleaks GitHub Action.
We pass the GITHUB_TOKEN for authentication and GITLEAKS_LICENSE for organizations.

21
00:02:00,000 --> 00:02:06,000
The --config flag specifies our custom configuration. The --verbose flag provides
detailed output. The --redact flag redacts secrets from logs.

22
00:02:06,000 --> 00:02:12,000
The --report-format=sarif flag generates a SARIF report. SARIF is the standard
format for security scanning reports. It's compatible with GitHub's Security tab.

23
00:02:12,000 --> 00:02:18,000
Now let's define the Gitleaks step for scheduled runs.
[Types: - name: Run Gitleaks — full history mode (scheduled) if: github.event_name == 'schedule' uses: gitleaks/gitleaks-action@v2 env: GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }} with: args: > --config=.gitleaks.toml --verbose --redact --report-format=sarif --report-path=gitleaks-results.sarif --log-opts="--all --full-history"]

24
00:02:18,000 --> 00:02:24,000
The --log-opts="--all --full-history" flag tells Gitleaks to scan every commit
in the repository. This catches secrets that were committed before Gitleaks was installed.

25
00:02:24,000 --> 00:02:30,000
Now let's upload the SARIF report to GitHub's Security tab.
[Types: - name: Upload SARIF to GitHub Security tab uses: github/codeql-action/upload-sarif@v3 if: always() with: sarif_file: gitleaks-results.sarif category: gitleaks]

26
00:02:30,000 --> 00:02:36,000
The if: always() ensures this step runs even if the previous step failed.
This is important because we want to see the results even when secrets are found.

27
00:02:36,000 --> 00:02:42,000
The SARIF file is uploaded to the Security tab. This is where we can review
all security findings in one place.

28
00:02:42,000 --> 00:02:48,000
Now let's post a PR comment when a secret is detected.
[Types: - name: Post PR comment on secret detection uses: actions/github-script@v7 if: failure() && github.event_name == 'pull_request' with: script: | github.rest.issues.createComment({ issue_number: context.issue.number, owner: context.repo.owner, repo: context.repo.repo, body: `## 🚨 Secret Detected — PR Blocked Gitleaks has detected a potential secret in this PR. **Immediate actions required:** 1. **Rotate the exposed credential NOW** — assume it is compromised 2. Check \`git log --all\` to identify when it was introduced 3. Remove the secret from the commit history (git-filter-repo or BFG) 4. Review the Gitleaks findings in the [Security tab](${context.serverUrl}/${context.repo.owner}/${context.repo.repo}/security/code-scanning) This PR cannot be merged until all findings are resolved.` })]

29
00:02:48,000 --> 00:02:54,000
This step only runs if the workflow fails and it's a pull request event.
It posts a comment to the PR with instructions on how to fix the issue.

30
00:02:54,000 --> 00:03:00,000
The comment tells the developer to rotate the credential immediately.
Assume it's compromised. Then remove the secret from the commit history.

31
00:03:00,000 --> 00:03:06,000
Now let's send a Slack alert to the security channel.
[Types: - name: Alert security channel on secret detection if: failure() env: SLACK_WEBHOOK: ${{ secrets.SLACK_SECURITY_WEBHOOK }} run: | curl -s -X POST $SLACK_WEBHOOK -H 'Content-type: application/json' -d '{ "text": "🚨 *SECRET DETECTED* in financial-rag-agent", "attachments": [{ "color": "#ff0000", "fields": [ {"title": "Repository", "value": "${{ github.repository }}", "short": true}, {"title": "Branch", "value": "${{ github.ref_name }}", "short": true}, {"title": "Commit", "value": "${{ github.sha }}", "short": true}, {"title": "Actor", "value": "${{ github.actor }}", "short": true}, {"title": "Action required", "value": "Rotate the exposed credential immediately", "short": false} ] }] }']

32
00:03:06,000 --> 00:03:12,000
This step sends a Slack alert when a secret is detected. The alert includes the
repository, branch, commit, and the actor who pushed the code.

33
00:03:12,000 --> 00:03:18,000
The color #ff0000 is red. This indicates urgency. The message tells the security
team to rotate the credential immediately.

34
00:03:18,000 --> 00:03:24,000
Now let me show you the complete file. This is what you should have in your editor.

35
00:03:24,000 --> 00:03:30,000
[Show the complete gitleaks.yml file]

36
00:03:30,000 --> 00:03:36,000
Now let's test the workflow. Push a commit that contains a test secret.

37
00:03:36,000 --> 00:03:42,000
[Types: echo "AWS_SECRET_KEY=AKIAIMNOJVGFDXXXE4OA" >> test_secret.txt]
[Types: git add test_secret.txt]
[Types: git commit -m "test: secret detection"]
[Types: git push origin develop]

38
00:03:42,000 --> 00:03:48,000
Go to GitHub Actions. You should see the workflow running. It will fail when
Gitleaks detects the secret.

39
00:03:48,000 --> 00:03:54,000
Check the PR comments. You should see the "Secret Detected — PR Blocked" comment.
Check Slack. You should see the security alert.

40
00:03:54,000 --> 00:04:00,000
Now let's remove the secret and verify the workflow passes.

41
00:04:00,000 --> 00:04:06,000
[Types: git rm test_secret.txt]
[Types: git commit -m "fix: remove test secret"]
[Types: git push origin develop]

42
00:04:06,000 --> 00:04:12,000
The workflow should pass. The PR should be mergable.

43
00:04:12,000 --> 00:04:18,000
Now let me explain what the Gitleaks configuration looks like.
Open `.gitleaks.toml` in your editor.

44
00:04:18,000 --> 00:04:24,000
[Types: extend: useDefault = true]
We use the default Gitleaks rules. This detects common secrets like AWS keys,
GitHub tokens, and passwords.

45
00:04:24,000 --> 00:04:30,000
[Types: allowlist: description = "Global allow list" paths = [ '''gitleaks\.toml''', '''\.env\.example''', '''.*\.lock''', '''.*\.mod''' ] regexes = [ '''219-09-9999''', '''078-05-1120''' ]]

46
00:04:30,000 --> 00:04:36,000
The allowlist ignores certain files and patterns. This reduces false positives.
The config file itself is ignored. .env.example contains placeholders, not real secrets.

47
00:04:36,000 --> 00:04:42,000
Now let me recap what we've built in Part 5.

48
00:04:42,000 --> 00:04:48,000
We built the Gitleaks standalone workflow. It runs on every PR, push to main,
and weekly to scan the full history.

49
00:04:48,000 --> 00:04:54,000
The workflow produces a SARIF report. The report is uploaded to GitHub Security.
This centralizes all security findings.

50
00:04:54,000 --> 00:05:00,000
If a secret is detected, the workflow posts a PR comment. It tells the developer
what to do and blocks the PR from being merged.

51
00:05:00,000 --> 00:05:06,000
It also sends a Slack alert to the security channel. This notifies the security
team immediately.

52
00:05:06,000 --> 00:05:12,000
The weekly scan catches secrets in old commits. This is an ongoing security
maintenance task.

53
00:05:12,000 --> 00:05:18,000
This is the second line of defense. Pre-commit hooks catch secrets locally.
The standalone workflow catches secrets in CI.

54
00:05:18,000 --> 00:05:24,000
Phase 7 is now complete. You have a production-grade CI/CD pipeline with
secret detection, vulnerability scanning, OPA policies, testing, and deployment.

55
00:05:24,000 --> 00:05:30,000
Thank you for watching. I'll see you in Phase 8.

56
00:05:30,000 --> 00:05:34,000
[End of Phase 7]