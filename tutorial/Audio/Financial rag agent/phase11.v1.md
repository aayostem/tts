1
00:00:00,000 --> 00:00:06,000
Welcome to Phase 12. This is the bonus phase. This is where we harden our production system and optimize costs.

2
00:00:06,000 --> 00:00:12,000
We've built a complete Financial RAG Agent. We've deployed it to EKS. We've added security, observability, and GitOps.

3
00:00:12,000 --> 00:00:18,000
But there's one thing we haven't talked about. Money. Cloud costs. FinOps.

4
00:00:18,000 --> 00:00:24,000
When you run a production system at scale, costs matter. Every CPU cycle costs money. Every gigabyte of storage costs money. Every network request costs money.

5
00:00:24,000 --> 00:00:30,000
In this phase, we install Kubecost. Kubecost is the industry standard for Kubernetes cost monitoring. It shows you exactly where your money is going.

6
00:00:30,000 --> 00:00:36,000
Open your browser and go to https://www.kubecost.com. This is the tool we're going to install.

7
00:00:36,000 --> 00:00:42,000
Kubecost gives you visibility into your Kubernetes costs. It shows you cost by namespace. Cost by deployment. Cost by pod. Cost by service.

8
00:00:42,000 --> 00:00:48,000
It shows you idle resources. It shows you over-provisioned pods. It shows you under-provisioned pods. It shows you savings opportunities.

9
00:00:48,000 --> 00:00:54,000
Think of Kubecost as your cloud financial dashboard. It's like a credit card statement for your Kubernetes cluster. Every charge is itemized. Every charge is explained.

10
00:00:54,000 --> 00:01:00,000
Open your terminal and let's install Kubecost. We'll use the Helm chart.

11
00:01:00,000 --> 00:01:06,000
First, add the Kubecost Helm repository.
[Types: helm repo add kubecost https://kubecost.github.io/cost-analyzer/]

12
00:01:06,000 --> 00:01:12,000
[Types: helm repo update]

13
00:01:12,000 --> 00:01:18,000
Now create the kubecost namespace.
[Types: kubectl create namespace kubecost]

14
00:01:18,000 --> 00:01:24,000
Now let's create the values file. This configures Kubecost for our environment.
Create `infrastructure/kubecost/values.yaml`.

15
00:01:24,000 --> 00:01:30,000
We'll start with the prometheus configuration. Kubecost needs to scrape metrics.
[Types: prometheus: server: global: scrape_interval: 60s evaluation_interval: 60s]

16
00:01:30,000 --> 00:01:36,000
[Types: prometheus: server: remoteWrite: - url: http://mimir.observability.svc:9009/api/v1/push]

17
00:01:36,000 --> 00:01:42,000
This sends metrics to Mimir for long-term storage. We already have Mimir from Phase 11.

18
00:01:42,000 --> 00:01:48,000
Now let's configure the cloud integration. This is where we tell Kubecost about AWS pricing.
[Types: cloudIntegration: enabled: true provider: "AWS" aws: region: "us-east-1"]

19
00:01:48,000 --> 00:01:54,000
[Types: cloudIntegration: aws: athena: enabled: false costAndUsage: enabled: false]

20
00:01:54,000 --> 00:02:00,000
We're not using Athena or Cost and Usage Reports yet. We'll rely on the default pricing data.

21
00:02:00,000 --> 00:02:06,000
Now let's configure the cost allocation. This is how we attribute costs to namespaces.
[Types: costAllocation: namespace: enabled: true labels: enabled: true]

22
00:02:06,000 --> 00:02:12,000
[Types: costAllocation: node: enabled: true pod: enabled: true service: enabled: true]

23
00:02:12,000 --> 00:02:18,000
This enables cost allocation at every level. You can see costs by namespace, label, node, pod, and service.

24
00:02:18,000 --> 00:02:24,000
Now let's configure the savings reports. This shows you where you can save money.
[Types: savings: enabled: true reportInterval: 24h]

25
00:02:24,000 --> 00:02:30,000
[Types: savings: recommendations: enabled: true]

26
00:02:30,000 --> 00:02:36,000
This generates savings recommendations every 24 hours. It tells you which pods are over-provisioned and which are under-provisioned.

27
00:02:36,000 --> 00:02:42,000
Now let's configure the network costs. This is important for AWS.

28
00:02:42,000 --> 00:02:48,000
Open the Kubecost values file and add the network costs section.
[Types: networkCosts: enabled: true provider: "aws" region: "us-east-1" clusterName: "financial-rag-prod-cluster" namespace: "kubecost"]

29
00:02:48,000 --> 00:02:54,000
[Types: networkCosts: prometheusServiceName: "kubecost-prometheus-server"]

30
00:02:54,000 --> 00:03:00,000
Network costs measure the cost of traffic between pods and services. This is important for understanding the cost of service mesh traffic.

31
00:03:00,000 --> 00:03:06,000
Now let's install Kubecost.
[Types: helm upgrade --install kubecost kubecost/cost-analyzer --namespace kubecost -f infrastructure/kubecost/values.yaml]

32
00:03:06,000 --> 00:03:12,000
Wait for Kubecost to start.
[Types: kubectl get pods -n kubecost]

33
00:03:12,000 --> 00:03:18,000
You should see several pods. cost-analyzer, prometheus-server, and network-costs.

34
00:03:18,000 --> 00:03:24,000
Now let's verify Kubecost is running.
[Types: kubectl port-forward -n kubecost svc/kubecost-cost-analyzer 9090:9090]

35
00:03:24,000 --> 00:03:30,000
Open http://localhost:9090. You should see the Kubecost dashboard.

36
00:03:30,000 --> 00:03:36,000
The dashboard shows you your cluster costs. Total cost per day. Cost per namespace. Cost per deployment.

37
00:03:36,000 --> 00:03:42,000
Now let's look at the cost allocation for the financial-rag namespace.
[Types: kubectl port-forward -n kubecost svc/kubecost-cost-analyzer 9090:9090]

38
00:03:42,000 --> 00:03:48,000
Open http://localhost:9090/cost-allocation. Select the financial-rag namespace.
You should see the cost breakdown. API pods. Agent pods. PostgreSQL. Redis.

39
00:03:48,000 --> 00:03:54,000
Now let me show you the savings recommendations.
[Types: kubectl port-forward -n kubecost svc/kubecost-cost-analyzer 9090:9090]

40
00:03:54,000 --> 00:04:00,000
Open http://localhost:9090/savings. This shows you where you can save money.
It recommends right-sizing pods. It recommends using spot instances. It recommends removing idle resources.

41
00:04:00,000 --> 00:04:06,000
Now let me explain the key metrics you should monitor.

42
00:04:06,000 --> 00:04:12,000
First, cost per query. This is the most important metric for FinOps.
Open the Kubecost dashboard and look at the cost per namespace.

43
00:04:12,000 --> 00:04:18,000
[Types: kubectl port-forward -n kubecost svc/kubecost-cost-analyzer 9090:9090]
[Types: curl http://localhost:9090/model/allocation?namespace=financial-rag&window=1d]

44
00:04:18,000 --> 00:04:24,000
This returns the cost allocation data in JSON format. You can use this to calculate cost per query.

45
00:04:24,000 --> 00:04:30,000
Second, resource efficiency. This tells you if your pods are using their allocated resources.
Look at the CPU and memory utilization of your pods.

46
00:04:30,000 --> 00:04:36,000
[Types: kubectl port-forward -n kubecost svc/kubecost-cost-analyzer 9090:9090]
[Types: curl http://localhost:9090/model/requested?namespace=financial-rag&window=1d]

47
00:04:36,000 --> 00:04:42,000
This shows you the requested vs actual usage. If requests are much higher than usage, you're wasting money.

48
00:04:42,000 --> 00:04:48,000
Third, idle resources. This tells you if you have pods that aren't doing anything.
Look at the idle cost report.

49
00:04:48,000 --> 00:04:54,000
[Types: kubectl port-forward -n kubecost svc/kubecost-cost-analyzer 9090:9090]
[Types: curl http://localhost:9090/model/idle?namespace=financial-rag&window=1d]

50
00:04:54,000 --> 00:05:00,000
This shows you the cost of idle resources. Idle resources are wasted money.

51
00:05:00,000 --> 00:05:06,000
Now let's set up alerts for cost anomalies.
Open the Kubecost values file and add the alert configuration.

52
00:05:06,000 --> 00:05:12,000
[Types: alerts: enabled: true slack: enabled: true webhook: "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"]

53
00:05:12,000 --> 00:05:18,000
[Types: alerts: rules: - name: "Daily Cost Spike" query: "sum(container_cost) > 100" period: "1d" threshold: 100]

54
00:05:18,000 --> 00:05:24,000
This alert fires when daily cost exceeds $100. You'll get a Slack notification.

55
00:05:24,000 --> 00:05:30,000
Now let's upgrade Kubecost with the alert configuration.
[Types: helm upgrade --install kubecost kubecost/cost-analyzer --namespace kubecost -f infrastructure/kubecost/values.yaml]

56
00:05:30,000 --> 00:05:36,000
Now let me give you a practical tip. The cost allocation data is stored in Prometheus.
You can query it directly.

57
00:05:36,000 --> 00:05:42,000
[Types: kubectl port-forward -n kubecost svc/kubecost-prometheus-server 9090:9090]

58
00:05:42,000 --> 00:05:48,000
Open http://localhost:9090/api/v1/query?query=container_cost{namespace="financial-rag"}
This returns the container cost for the financial-rag namespace.

59
00:05:48,000 --> 00:05:54,000
Now let me show you how to calculate cost per query.
Get the daily cost of the API pods and divide by the number of queries.

60
00:05:54,000 --> 00:06:00,000
[Types: API_COST=$(curl -s http://localhost:9090/model/allocation?namespace=financial-rag&window=1d | jq '.data[].totalCost')]
[Types: QUERY_COUNT=$(curl -s http://localhost:9090/api/v1/query?query=finrag_query_total | jq '.data.result[0].value[1]')]
[Types: echo "Cost per query: $((API_COST / QUERY_COUNT))"]

61
00:06:00,000 --> 00:06:06,000
This calculates the cost per query. This is your key FinOps metric.

62
00:06:06,000 --> 00:06:12,000
Now let me recap what we've covered in Part 1.

63
00:06:12,000 --> 00:06:18,000
We installed Kubecost. It gives us visibility into Kubernetes costs.
We can see cost by namespace, deployment, pod, and service.

64
00:06:18,000 --> 00:06:24,000
We configured cost allocation. Costs are attributed to the right resources.
We can track cost per query.

65
00:06:24,000 --> 00:06:30,000
We set up savings recommendations. We can identify idle resources and over-provisioned pods.
We can right-size our deployments.

66
00:06:30,000 --> 00:06:36,000
We configured cost alerts. We get notified when costs spike.
We can proactively manage costs.

67
00:06:36,000 --> 00:06:42,000
In Part 2, we'll configure Vertical Pod Autoscaler. This automatically right-sizes pods
based on their actual usage.

68
00:06:42,000 --> 00:06:48,000
Thank you for watching. I'll see you in Part 2.

69
00:06:48,000 --> 00:06:52,000
[End of Part 1]
1
00:00:00,000 --> 00:00:06,000
Welcome to Phase 12. In Part 2, we focus on production readiness and gradual promotion strategies.

2
00:00:06,000 --> 00:00:12,000
We've built a complete system. We have CI/CD. We have observability. We have security.
But being production-ready is not just about having the right components.

3
00:00:12,000 --> 00:00:18,000
Production-ready means you can deploy with confidence. It means you can rollback quickly.
It means you can verify that everything is working before users see it.

4
00:00:18,000 --> 00:00:24,000
Let's start with the production readiness checklist. This is what we've already built and what we need to verify.

5
00:00:24,000 --> 00:00:30,000
Item one: Environment parity. Development, staging, and production should be as similar as possible.
[Types: kubectl get nodes -o wide]

6
00:00:30,000 --> 00:00:36,000
This shows the nodes in your cluster. Staging should have the same node configuration as production.
Same instance types. Same scaling limits.

7
00:00:36,000 --> 00:00:42,000
Item two: Configuration management. All configuration is in version control.
[Types: git log --oneline infrastructure/helm/values.prod.yaml]

8
00:00:42,000 --> 00:00:48,000
This shows the commit history of your production values file. Every change is tracked.
You can audit who changed what and when.

9
00:00:48,000 --> 00:00:54,000
Item three: Secrets management. Secrets are stored in Vault, not in Git.
[Types: vault kv get secret/financial-rag/prod/llm]

10
00:00:54,000 --> 00:01:00,000
This verifies that production secrets are in Vault. They are encrypted. They are audited.
They are automatically rotated.

11
00:01:00,000 --> 00:01:06,000
Item four: Health checks and readiness probes. All services have working health checks.
[Types: kubectl get pods -n financial-rag -o wide]

12
00:01:06,000 --> 00:01:12,000
Check that all pods are ready. The READY column shows 1/1 for all pods.
This means the readiness probes are passing.

13
00:01:12,000 --> 00:01:18,000
Item five: Observability. Logs, metrics, and traces are working.
[Types: kubectl port-forward -n monitoring svc/grafana 3000:3000]

14
00:01:18,000 --> 00:01:24,000
Open Grafana and verify the dashboards are showing data. The LGTM stack is working.

15
00:01:24,000 --> 00:01:30,000
Item six: Alerting. Critical alerts are configured and tested.
[Types: kubectl get prometheusrules -n monitoring -l slo="true"]

16
00:01:30,000 --> 00:01:36,000
This shows the SLO alert rules. They are applied. They will fire when needed.

17
00:01:36,000 --> 00:01:42,000
Item seven: Backup and disaster recovery. Data is backed up regularly.
[Types: kubectl get cronjobs -n vault]

18
00:01:42,000 --> 00:01:48,000
This shows the Vault backup CronJob. It runs daily. It stores snapshots in S3.

19
00:01:48,000 --> 00:01:54,000
Item eight: Security hardening. CIS benchmarks and security policies are applied.
[Types: kubectl get ciliumnetworkpolicies -n financial-rag]

20
00:01:54,000 --> 00:02:00,000
This shows the Cilium network policies. They enforce zero-trust networking.

21
00:02:00,000 --> 00:02:06,000
Item nine: Performance testing. Load tests have been run and SLOs are defined.
[Types: kubectl get hpa -n financial-rag]

22
00:02:06,000 --> 00:02:12,000
The HPA shows current and target replicas. This verifies autoscaling is working.

23
00:02:12,000 --> 00:02:18,000
Item ten: Rollback procedures. You can rollback to any previous version.
[Types: helm history finrag-prod -n financial-rag]

24
00:02:18,000 --> 00:02:24,000
This shows the deployment history. You can rollback to any revision.

25
00:02:24,000 --> 00:02:30,000
Now let's implement the gradual promotion strategy. This is the path from development to production.

26
00:02:30,000 --> 00:02:36,000
[Manim Scene 1: The Promotion Pipeline]
Development → Staging → Production.
In Development, you test locally. You run unit tests and integration tests.
In Staging, you deploy to a production-like environment. You run end-to-end tests and load tests.
In Production, you deploy with a canary strategy. You verify SLOs before full rollout.
Each step has gates. Tests must pass. SLOs must be met.

27
00:02:36,000 --> 00:02:42,000
Let's implement the canary deployment strategy. This is how we deploy to production safely.

28
00:02:42,000 --> 00:02:48,000
Open `infrastructure/helm/templates/api-deployment.yaml` in your editor.

29
00:02:48,000 --> 00:02:54,000
We'll add canary annotations to the deployment.
[Types: annotations: rollme: "{{ randAlphaNum 5 | quote }}"]

30
00:02:54,000 --> 00:03:00,000
This annotation forces a rolling update when the annotation value changes.
We use it to trigger canary deployments.

31
00:03:00,000 --> 00:03:06,000
Now let's create a canary service. This routes a small percentage of traffic to the new version.
[Types: apiVersion: v1 kind: Service metadata: name: {{ include "financial-rag-agent.fullname" . }}-api-canary namespace: {{ .Values.namespace }}]

32
00:03:06,000 --> 00:03:12,000
[Types: spec: selector: {{- include "financial-rag-agent.selectorLabels" . | nindent 4 }} app.kubernetes.io/component: api version: canary]

33
00:03:12,000 --> 00:03:18,000
The canary service selects pods with the version: canary label.
This allows us to route traffic separately.

34
00:03:18,000 --> 00:03:24,000
Now let's configure the canary routing in Istio.
Open `gitops/envs/istio-mesh/virtual-services.yaml`.

35
00:03:24,000 --> 00:03:30,000
[Types: - match: - uri: prefix: /query route: - destination: host: financial-rag-agent-api.financial-rag.svc.cluster.local port: number: 8000 weight: 95 - destination: host: financial-rag-agent-api-canary.financial-rag.svc.cluster.local port: number: 8000 weight: 5]

36
00:03:30,000 --> 00:03:36,000
This routes 95% of traffic to the stable version and 5% to the canary version.
If the canary version fails, only 5% of users are affected.

37
00:03:36,000 --> 00:03:42,000
After monitoring the canary for a period of time, if everything is healthy,
we promote it to 100%. This is done by adjusting the weights.

38
00:03:42,000 --> 00:03:48,000
[Types: - destination: host: financial-rag-agent-api.financial-rag.svc.cluster.local port: number: 8000 weight: 0 - destination: host: financial-rag-agent-api-canary.financial-rag.svc.cluster.local port: number: 8000 weight: 100]

39
00:03:48,000 --> 00:03:54,000
After promotion, we update the stable deployment to match the canary version.
Then we reset the weights back to 100/0.

40
00:03:54,000 --> 00:04:00,000
Now let's implement the rollback procedure. This is how you revert to a previous version.

41
00:04:00,000 --> 00:04:06,000
First, check the deployment history.
[Types: helm history finrag-prod -n financial-rag]

42
00:04:06,000 --> 00:04:12,000
You'll see a list of revisions. Each revision has a version number and status.
[Types: REVISION UPDATED STATUS CHART APP VERSION DESCRIPTION 1 2025-01-01 10:00:00 deployed financial-rag-agent-0.1.0 1.0.0 Install complete 2 2025-01-02 14:30:00 deployed financial-rag-agent-0.1.0 1.0.0 Upgrade complete 3 2025-01-03 09:15:00 failed financial-rag-agent-0.1.0 1.0.0 Upgrade failed]

43
00:04:12,000 --> 00:04:18,000
To rollback to revision 2, use the helm rollback command.
[Types: helm rollback finrag-prod 2 -n financial-rag]

44
00:04:18,000 --> 00:04:24,000
This reverts the deployment to revision 2. The previous version is restored.
The rollback takes effect immediately.

45
00:04:24,000 --> 00:04:30,000
Now let's implement the production verification tests. These run after deployment to verify everything is working.

46
00:04:30,000 --> 00:04:36,000
Create `tests/production/test_smoke.py`.
[Types: import pytest import requests]

47
00:04:36,000 --> 00:04:42,000
[Types: class TestProductionSmoke: @pytest.mark.production def test_health_endpoint(self): response = requests.get("https://api.financial-rag.cloudfrugal.com/health") assert response.status_code == 200 data = response.json() assert data["status"] == "healthy"]

48
00:04:42,000 --> 00:04:48,000
This test verifies the health endpoint is returning 200 OK. This is the most basic production check.

49
00:04:48,000 --> 00:04:54,000
[Types: @pytest.mark.production def test_query_endpoint(self): payload = {"question": "What is Apple's revenue?", "ticker": "AAPL"} response = requests.post("https://api.financial-rag.cloudfrugal.com/query", json=payload) assert response.status_code == 200 data = response.json() assert "answer" in data assert len(data["answer"]) > 0]

50
00:04:54,000 --> 00:05:00,000
This test verifies the query endpoint returns a valid answer. This tests the end-to-end RAG pipeline.

51
00:05:00,000 --> 00:05:06,000
[Types: @pytest.mark.production def test_ingestion_endpoint(self): payload = {"ticker": "AAPL", "filing_type": "10-K", "years": 1} response = requests.post("https://api.financial-rag.cloudfrugal.com/ingest/sec", json=payload) assert response.status_code == 202]

52
00:05:06,000 --> 00:05:12,000
This test verifies the ingestion endpoint accepts requests. It returns 202 Accepted.

53
00:05:12,000 --> 00:05:18,000
Now run the production tests after deployment.
[Types: pytest tests/production -v -m production]

54
00:05:18,000 --> 00:05:24,000
These tests run in the CI/CD pipeline after deployment. If they fail, the deployment is rolled back.

55
00:05:24,000 --> 00:05:30,000
Now let's update the CI/CD workflow to include the production tests.
Open `.github/workflows/ci.yml`.

56
00:05:30,000 --> 00:05:36,000
[Types: - name: Production smoke tests run: | pytest tests/production -v -m production --base-url=${{ env.PROD_URL }} env: PROD_URL: https://api.financial-rag.cloudfrugal.com]

57
00:05:36,000 --> 00:05:42,000
This runs the production tests after deployment. The tests use the production API URL.

58
00:05:42,000 --> 00:05:48,000
If any test fails, the workflow fails. The deployment is automatically rolled back.

59
00:05:48,000 --> 00:05:54,000
Now let's document the rollback procedure. This is a runbook for the on-call engineer.

60
00:05:54,000 --> 00:06:00,000
Create `docs/runbooks/rollback.md`.
[Types: # Rollback Procedure ## Steps 1. Identify the failing revision: `helm history finrag-prod -n financial-rag` 2. Rollback to the previous revision: `helm rollback finrag-prod $(helm history finrag-prod -n financial-rag | grep -v "REVISION" | head -1 | awk '{print $1}') -n financial-rag` 3. Verify the rollback: `kubectl get pods -n financial-rag` 4. Monitor metrics: Check Grafana dashboard 5. Confirm with team: Post to #engineering Slack channel]

61
00:06:00,000 --> 00:06:06,000
This runbook is accessible to the on-call engineer. It provides step-by-step instructions.

62
00:06:06,000 --> 00:06:12,000
Now let's implement the blue-green deployment strategy as an alternative to canary.
This is useful for major version upgrades.

63
00:06:12,000 --> 00:06:18,000
[Types: apiVersion: v1 kind: Service metadata: name: {{ include "financial-rag-agent.fullname" . }}-api-blue namespace: {{ .Values.namespace }} spec: selector: {{- include "financial-rag-agent.selectorLabels" . | nindent 4 }} app.kubernetes.io/component: api version: blue]

64
00:06:18,000 --> 00:06:24,000
[Types: --- apiVersion: v1 kind: Service metadata: name: {{ include "financial-rag-agent.fullname" . }}-api-green namespace: {{ .Values.namespace }} spec: selector: {{- include "financial-rag-agent.selectorLabels" . | nindent 4 }} app.kubernetes.io/component: api version: green]

65
00:06:24,000 --> 00:06:30,000
Blue-green deployment uses two identical environments. Blue is production. Green is the new version.
Traffic is switched from blue to green atomically.

66
00:06:30,000 --> 00:06:36,000
[Types: apiVersion: v1 kind: Service metadata: name: {{ include "financial-rag-agent.fullname" . }}-api namespace: {{ .Values.namespace }} spec: selector: {{- include "financial-rag-agent.selectorLabels" . | nindent 4 }} app.kubernetes.io/component: api version: blue]

67
00:06:36,000 --> 00:06:42,000
To switch traffic, update the service selector from blue to green.
This is an atomic operation. All traffic switches at once.

68
00:06:42,000 --> 00:06:48,000
Now let's verify the complete production readiness checklist.

69
00:06:48,000 --> 00:06:54,000
[Types: # Production Readiness Checklist ## Infrastructure - [x] EKS cluster is running version 1.29 - [x] Node groups are configured with proper instance types - [x] Cluster autoscaler is enabled - [x] Karpenter is configured for auto-scaling]

70
00:06:54,000 --> 00:07:00,000
[Types: ## Networking - [x] Cilium is installed and enforcing network policies - [x] Istio is installed with mTLS enabled - [x] Ingress is configured with TLS certificates - [x] DNS is pointing to the correct load balancer]

71
00:07:00,000 --> 00:07:06,000
[Types: ## Security - [x] Vault is configured and running in HA mode - [x] Secrets are stored in Vault, not in Git - [x] Falco is running with custom rules - [x] All containers run as non-root - [x] All containers have read-only root filesystem]

72
00:07:06,000 --> 00:07:12,000
[Types: ## Observability - [x] Prometheus is scraping metrics - [x] Grafana dashboards are configured - [x] Loki is collecting logs - [x] Tempo is collecting traces - [x] SLO alerts are configured]

73
00:07:12,000 --> 00:07:18,000
[Types: ## CI/CD - [x] GitHub Actions workflow is passing - [x] ArgoCD is syncing applications - [x] Rollback procedure is documented - [x] Canary deployment is configured]

74
00:07:18,000 --> 00:07:24,000
[Types: ## Monitoring - [x] SLOs are defined - [x] Error budget alerts are configured - [x] Security alerts are configured - [x] Performance alerts are configured]

75
00:07:24,000 --> 00:07:30,000
[Types: ## Backup - [x] Vault backups are scheduled daily - [x] Database backups are enabled - [x] Backup restore procedure is documented]

76
00:07:30,000 --> 00:07:36,000
This checklist should be reviewed before every production deployment.
It ensures nothing is missed.

77
00:07:36,000 --> 00:07:42,000
Now let me recap what we've covered in Part 2.

78
00:07:42,000 --> 00:07:48,000
We reviewed the production readiness checklist. Ten items from infrastructure to backup.

79
00:07:48,000 --> 00:07:54,000
We implemented the gradual promotion strategy. Development → Staging → Production with gates.

80
00:07:54,000 --> 00:08:00,000
We implemented canary deployments with Istio. 5% of traffic goes to the new version.
If healthy, we promote to 100%.

81
00:08:00,000 --> 00:08:06,000
We implemented rollback procedures. helm rollback to revert to a previous version.
A runbook documents the steps.

82
00:08:06,000 --> 00:08:12,000
We implemented production verification tests. Smoke tests run after deployment.
They verify health, query, and ingestion endpoints.

83
00:08:12,000 --> 00:08:18,000
We implemented blue-green deployment as an alternative strategy.
Atomic switch from blue to green.

84
00:08:18,000 --> 00:08:24,000
We created a production readiness checklist. Review before every deployment.

85
00:08:24,000 --> 00:08:30,000
This is the final piece of the production puzzle. You can now deploy with confidence.

86
00:08:30,000 --> 00:08:36,000
In Part 3, we'll implement FinOps with Kubecost. This tracks cloud costs and optimizes spending.

87
00:08:36,000 --> 00:08:42,000
Thank you for watching. I'll see you in Part 3.

88
00:08:42,000 --> 00:08:46,000
[End of Part 2]
# PHASE 12 — PART 3: Velero Backup & Disaster Recovery

**Duration:** 35 minutes (00:00:00 - 00:34:59)

**Files to Build:**
- `infrastructure/velero/velero-install.yaml`
- `infrastructure/velero/backup-schedule.yaml`
- `infrastructure/velero/restore-test.yaml`

---

```srt
1
00:00:00,000 --> 00:00:06,000
Welcome to Phase 12, Part 3. This is where we build the backup and disaster recovery system using Velero.

2
00:00:06,000 --> 00:00:12,000
We have a production cluster. It's running our Financial RAG Agent. But what happens if the cluster is deleted? What happens if someone accidentally deletes a namespace?

3
00:00:12,000 --> 00:00:18,000
Without backups, you lose everything. Your database. Your secrets. Your configurations. Your service accounts. Everything is gone.

4
00:00:18,000 --> 00:00:24,000
Velero solves this. It backs up your Kubernetes resources and persistent volumes. It stores them in S3. You can restore from any backup.

5
00:00:24,000 --> 00:00:30,000
Think of Velero like a time machine for your cluster. It captures the state of your cluster at a specific point in time. You can go back to that state whenever you need.

6
00:00:30,000 --> 00:00:36,000
Open your editor and create `infrastructure/velero/velero-install.yaml`.

7
00:00:36,000 --> 00:00:42,000
We'll start by installing Velero using the Helm chart. The Velero chart deploys the Velero server and the volume snapshot controller.

8
00:00:42,000 --> 00:00:48,000
First, add the Velero Helm repository.
[Types: helm repo add vmware-tanzu https://vmware-tanzu.github.io/helm-charts]
[Types: helm repo update]

9
00:00:48,000 --> 00:00:54,000
Now let's install Velero with the necessary configuration.
[Types: helm upgrade --install velero vmware-tanzu/velero --namespace velero --create-namespace]

10
00:00:54,000 --> 00:01:00,000
We need to configure Velero to use S3 for backup storage. This is the recommended way.
[Types: --set configuration.provider=aws]
[Types: --set configuration.backupStorageLocation.name=default]
[Types: --set configuration.backupStorageLocation.bucket=financial-rag-backups]
[Types: --set configuration.backupStorageLocation.config.region=us-east-1]

11
00:01:00,000 --> 00:01:06,000
Velero uses S3 to store backups. The bucket name is financial-rag-backups. This bucket must be created before installing Velero.

12
00:01:06,000 --> 00:01:12,000
We also need to configure volume snapshot support. This allows Velero to back up persistent volumes.
[Types: --set configuration.volumeSnapshotLocation.name=default]
[Types: --set configuration.volumeSnapshotLocation.provider=aws]
[Types: --set configuration.volumeSnapshotLocation.config.region=us-east-1]

13
00:01:12,000 --> 00:01:18,000
Volume snapshots are stored in AWS. EBS snapshots are used for persistent volumes.

14
00:01:18,000 --> 00:01:24,000
Now let's create the S3 bucket. This must exist before Velero can use it.
[Types: aws s3 mb s3://financial-rag-backups --region us-east-1]

15
00:01:24,000 --> 00:01:30,000
Now let's create the IAM policy for Velero. This grants Velero access to S3 and EC2.
[Types: aws iam create-policy --policy-name VeleroBackupPolicy --policy-document file://infrastructure/velero/velero-policy.json]

16
00:01:30,000 --> 00:01:36,000
The policy document grants permissions to S3 and EC2. Let me show you what it looks like.

17
00:01:36,000 --> 00:01:42,000
[Types: cat infrastructure/velero/velero-policy.json]
[Types: { "Version": "2012-10-17", "Statement": [ { "Effect": "Allow", "Action": [ "s3:GetObject", "s3:DeleteObject", "s3:PutObject", "s3:ListBucket" ], "Resource": [ "arn:aws:s3:::financial-rag-backups", "arn:aws:s3:::financial-rag-backups/*" ] }, { "Effect": "Allow", "Action": [ "ec2:CreateSnapshot", "ec2:DeleteSnapshot", "ec2:DescribeSnapshots", "ec2:DescribeVolumes" ], "Resource": "*" } ] }]

18
00:01:42,000 --> 00:01:48,000
The S3 permissions allow Velero to read, write, and list objects in the backup bucket.
The EC2 permissions allow Velero to create and delete EBS snapshots.

19
00:01:48,000 --> 00:01:54,000
Now let's create the IAM role for Velero. This role is assumed by the Velero server.
[Types: aws iam create-role --role-name VeleroBackupRole --assume-role-policy-document file://infrastructure/velero/trust-policy.json]

20
00:01:54,000 --> 00:02:00,000
The trust policy allows the Velero service account to assume this role.
[Types: { "Version": "2012-10-17", "Statement": [ { "Effect": "Allow", "Principal": { "Federated": "arn:aws:iam::ACCOUNT_ID:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/OIDC_PROVIDER" }, "Action": "sts:AssumeRoleWithWebIdentity", "Condition": { "StringEquals": { "oidc.eks.us-east-1.amazonaws.com/id/OIDC_PROVIDER:sub": "system:serviceaccount:velero:velero" } } } ] }]

21
00:02:00,000 --> 00:02:06,000
The trust policy uses OIDC federation. This is the same approach we used for Vault and the application.

22
00:02:06,000 --> 00:02:12,000
Now let's attach the policy to the role.
[Types: aws iam attach-role-policy --role-name VeleroBackupRole --policy-arn arn:aws:iam::ACCOUNT_ID:policy/VeleroBackupPolicy]

23
00:02:12,000 --> 00:02:18,000
Now let's annotate the Velero service account with the role ARN.
[Types: kubectl annotate -n velero serviceaccount velero eks.amazonaws.com/role-arn=arn:aws:iam::ACCOUNT_ID:role/VeleroBackupRole]

24
00:02:18,000 --> 00:02:24,000
This is the same IRSA pattern we used before. The service account is bound to the IAM role.

25
00:02:24,000 --> 00:02:30,000
Now let's create the backup schedule. Open `infrastructure/velero/backup-schedule.yaml`.

26
00:02:30,000 --> 00:02:36,000
[Types: apiVersion: velero.io/v1 kind: Schedule metadata: name: daily-backup namespace: velero]

27
00:02:36,000 --> 00:02:42,000
The Schedule resource creates backups on a schedule. This is the production backup strategy.

28
00:02:42,000 --> 00:02:48,000
[Types: spec: schedule: "0 1 * * *" template: includedNamespaces: - financial-rag includedResources: - deployments - statefulsets - services - configmaps - secrets - persistentvolumeclaims]

29
00:02:48,000 --> 00:02:54,000
The schedule is 1 AM daily. We back up all resources in the financial-rag namespace.
This includes deployments, statefulsets, services, configmaps, secrets, and persistent volume claims.

30
00:02:54,000 --> 00:03:00,000
[Types: storageLocation: default ttl: 720h]

31
00:03:00,000 --> 00:03:06,000
The backup TTL is 720 hours, or 30 days. Backups older than 30 days are automatically deleted.

32
00:03:06,000 --> 00:03:12,000
[Types: snapshotVolumes: true]

33
00:03:12,000 --> 00:03:18,000
snapshotVolumes: true enables volume snapshots. This backs up the PostgreSQL and Redis data.

34
00:03:18,000 --> 00:03:24,000
[Types: hooks: resources: - name: postgres-backup-hook includedNamespaces: - financial-ragexcludedResources: - deployments kind: StatefulSet labelSelector: app: postgres pre: - exec: container: postgres command: - /bin/bash - -c - "pg_dump -U finrag -d financial_rag > /tmp/backup.sql && echo 'Backup completed'"]

35
00:03:24,000 --> 00:03:30,000
The pre-hook runs a pg_dump before the backup. This creates a consistent backup of the database.
This is important for PostgreSQL backups.

36
00:03:30,000 --> 00:03:36,000
Now let's create the weekly backup schedule for compliance.
[Types: --- apiVersion: velero.io/v1 kind: Schedule metadata: name: weekly-backup namespace: velero]

37
00:03:36,000 --> 00:03:42,000
[Types: spec: schedule: "0 3 * * 6" template: includedNamespaces: - financial-rag - monitoring - vault - argocd]

38
00:03:42,000 --> 00:03:48,000
The weekly backup runs at 3 AM on Saturday. It backs up all critical namespaces.
This is for compliance purposes. Some regulations require weekly full backups.

39
00:03:48,000 --> 00:03:54,000
[Types: storageLocation: default ttl: 2160h]

40
00:03:54,000 --> 00:04:00,000
The weekly backup TTL is 2160 hours, or 90 days. This is for long-term compliance storage.

41
00:04:00,000 --> 00:04:06,000
[Types: snapshotVolumes: true]

42
00:04:06,000 --> 00:04:12,000
Now let's apply the backup schedules.
[Types: kubectl apply -f infrastructure/velero/backup-schedule.yaml]

43
00:04:12,000 --> 00:04:18,000
[Types: kubectl get schedules -n velero]

44
00:04:18,000 --> 00:04:24,000
You should see daily-backup and weekly-backup in the list. This confirms the schedules were created.

45
00:04:24,000 --> 00:04:30,000
Now let's create a test restore. Open `infrastructure/velero/restore-test.yaml`.

46
00:04:30,000 --> 00:04:36,000
[Types: apiVersion: velero.io/v1 kind: Restore metadata: name: test-restore namespace: velero]

47
00:04:36,000 --> 00:04:42,000
[Types: spec: backupName: daily-backup-20240101-010000 includedNamespaces: - financial-rag]

48
00:04:42,000 --> 00:04:48,000
This restore would restore from a specific backup. The backupName is the name of the backup to restore.

49
00:04:48,000 --> 00:04:54,000
[Types: includedResources: - deployments - statefulsets - services - configmaps - secrets - persistentvolumeclaims]

50
00:04:54,000 --> 00:05:00,000
We restore the same resources that we backed up. This ensures a complete restore.

51
00:05:00,000 --> 00:05:06,000
[Types: restoreStatus: includedNamespaces: - financial-rag]

52
00:05:06,000 --> 00:05:12,000
[Types: hooks: resources: - name: postgres-restore-hook includedNamespaces: - financial-rag post: - exec: container: postgres command: - /bin/bash - -c - "psql -U finrag -d financial_rag < /tmp/backup.sql && echo 'Restore completed'"]

53
00:05:12,000 --> 00:05:18,000
The post-hook restores the database from the backup file. This ensures data consistency.

54
00:05:18,000 --> 00:05:24,000
Now let's test the restore process. This is a dry run to verify everything works.

55
00:05:24,000 --> 00:05:30,000
First, create a backup manually.
[Types: velero backup create manual-backup --include-namespaces financial-rag]

56
00:05:30,000 --> 00:05:36,000
[Types: velero backup describe manual-backup]

57
00:05:36,000 --> 00:05:42,000
This shows the backup status. It should show "Completed" when the backup is finished.

58
00:05:42,000 --> 00:05:48,000
Now let's simulate a disaster. Delete the financial-rag namespace.
[Types: kubectl delete namespace financial-rag]

59
00:05:48,000 --> 00:05:54,000
Everything is gone. Deployments, services, configmaps, secrets, PVCs. All gone.

60
00:05:54,000 --> 00:06:00,000
Now let's restore from the backup.
[Types: velero restore create --from-backup manual-backup]

61
00:06:00,000 --> 00:06:06,000
[Types: velero restore describe manual-backup-20240101-010000]

62
00:06:06,000 --> 00:06:12,000
The restore status should show "Completed". This confirms the restore worked.

63
00:06:12,000 --> 00:06:18,000
[Types: kubectl get pods -n financial-rag]

64
00:06:18,000 --> 00:06:24,000
All pods should be running. The application is restored.

65
00:06:24,000 --> 00:06:30,000
Now let's verify the data integrity. Check the PostgreSQL database.
[Types: kubectl exec -n financial-rag postgres-0 -- psql -U finrag -d financial_rag -c "SELECT count(*) FROM filings"]

66
00:06:30,000 --> 00:06:36,000
The count should match the pre-disaster count. This confirms the data was restored correctly.

67
00:06:36,000 --> 00:06:42,000
Now let's automate the restore verification. This is an important part of disaster recovery planning.
[Types: velero schedule create verify-restore --schedule="0 4 * * 6" --template spec.includeNamespaces=financial-rag]

68
00:06:42,000 --> 00:06:48,000
This schedule runs a verification restore every Saturday at 4 AM. It validates that the weekly backup is restorable.

69
00:06:48,000 --> 00:06:54,000
Now let me recap what we've covered in Part 3.

70
00:06:54,000 --> 00:07:00,000
We installed Velero using the Helm chart. We configured it to use S3 for backup storage.
We set up volume snapshot support for persistent volumes.

71
00:07:00,000 --> 00:07:06,000
We created the IAM policy and role for Velero. We annotated the service account with the role ARN.
This enabled IRSA for Velero.

72
00:07:06,000 --> 00:07:12,000
We created backup schedules. Daily backups at 1 AM. Weekly backups at 3 AM on Saturday.
The weekly backup is for compliance. The daily backup is for operational recovery.

73
00:07:12,000 --> 00:07:18,000
We created a test restore. We simulated a disaster by deleting the namespace.
We restored from the backup. Everything came back.

74
00:07:18,000 --> 00:07:24,000
We verified the data integrity. The database had the same data as before the disaster.

75
00:07:24,000 --> 00:07:30,000
This is a complete backup and disaster recovery solution. Your data is safe.
You can recover from any disaster in minutes.

76
00:07:30,000 --> 00:07:36,000
In Part 4, we'll integrate everything into the production readiness checklist.
We'll verify that all components are production-ready.

77
00:07:36,000 --> 00:07:42,000
Thank you for watching. I'll see you in Part 4.

78
00:07:42,000 --> 00:07:46,000
[End of Part 3]
```
# PHASE 12 — PART 4: Production Readiness Checklist

**Duration:** 35 minutes (00:00:00 - 00:34:59)

**File to Build:**
- `docs/production-readiness.md`

---

```srt
1
00:00:00,000 --> 00:00:06,000
Welcome to Phase 12. This is the final phase of the Financial RAG Agent series. In Part 4, we complete the production readiness checklist.

2
00:00:06,000 --> 00:00:12,000
We've built the application. We've secured it. We've deployed it. We've added observability. But before we call it production-ready, we need to verify everything.

3
00:00:12,000 --> 00:00:18,000
Think of this as the final inspection before a ship leaves the harbor. Every system is checked. Every component is verified. Nothing is assumed to work.

4
00:00:18,000 --> 00:00:24,000
Open your editor and create `docs/production-readiness.md`.

5
00:00:24,000 --> 00:00:30,000
We'll start with the security checklist. This is the most important section.
[Types: # Production Readiness Checklist]

6
00:00:30,000 --> 00:00:36,000
[Types: ## 1. Security]

7
00:00:36,000 --> 00:00:42,000
[Types: ### 1.1 Secrets Management]

8
00:00:42,000 --> 00:00:48,000
[Types: - [ ] Vault is deployed in production mode (3 pods, Raft consensus)]
[Types: - [ ] Vault uses AWS KMS auto-unseal]
[Types: - [ ] Dynamic database credentials are working (api-role, agent-role, ingestion-role)]
[Types: - [ ] Static secrets are stored in Vault (LLM API key, Redis password, EDGAR credentials)]
[Types: - [ ] Vault Agent sidecar is injecting secrets correctly]
[Types: - [ ] Secrets are rotated automatically (1-hour TTL for database credentials)]

9
00:00:42,000 --> 00:00:48,000
Let me walk through each item. Vault must be in production mode, not dev mode. Three pods with Raft consensus ensures high availability.

10
00:00:48,000 --> 00:00:54,000
AWS KMS auto-unseal means Vault unseals itself on startup. No human intervention is required. This is critical for automated recovery.

11
00:00:54,000 --> 00:01:00,000
Dynamic database credentials should be working. Each service should have its own database user with the right permissions. The credentials should rotate every hour.

12
00:01:00,000 --> 00:01:06,000
[Types: ### 1.2 Network Security]

13
00:01:06,000 --> 00:01:12,000
[Types: - [ ] Cilium is installed with kubeProxyReplacement=enabled]
[Types: - [ ] Default deny policy is applied to financial-rag namespace]
[Types: - [ ] L7 policies are enforced (HTTP method + path filtering)]
[Types: - [ ] Hubble is enabled for flow observability]
[Types: - [ ] Cilium network policies are working (api-l7-policy, agent-l7-policy)]

14
00:01:12,000 --> 00:01:18,000
Cilium with kubeProxyReplacement=enabled provides the most efficient networking. The default deny policy ensures nothing gets through without explicit permission.

15
00:01:18,000 --> 00:01:24,000
L7 policies filter HTTP methods and paths. For example, the API can only accept POST /query and GET /health. Everything else is blocked.

16
00:01:24,000 --> 00:01:30,000
[Types: ### 1.3 Service Mesh]

17
00:01:30,000 --> 00:01:36,000
[Types: - [ ] Istio is installed and running]
[Types: - [ ] mTLS is enforced (STRICT mode)]
[Types: - [ ] Authorization policies are applied]
[Types: - [ ] Gateway is configured with TLS termination]
[Types: - [ ] VirtualServices are routing correctly]

18
00:01:36,000 --> 00:01:42,000
mTLS in STRICT mode means every service must authenticate. No unauthenticated traffic is allowed. This prevents man-in-the-middle attacks.

19
00:01:42,000 --> 00:01:48,000
Authorization policies define which services can talk to which. The API can talk to the Agent. The Agent can talk to pgvector. Nothing else.

20
00:01:48,000 --> 00:01:54,000
[Types: ### 1.4 Runtime Security]

21
00:01:54,000 --> 00:02:00,000
[Types: - [ ] Falco is installed as a DaemonSet with eBPF driver]
[Types: - [ ] Custom Falco rules are loaded (8 rules covering threat model)]
[Types: - [ ] Falcosidekick is routing alerts to Slack, PagerDuty, and CloudWatch]
[Types: - [ ] Prometheus alerts are firing for critical events]
[Types: - [ ] Gitleaks is running in CI (pre-commit + GitHub Actions)]

22
00:02:00,000 --> 00:02:06,000
Falco with the eBPF driver is the most secure option. It doesn't require kernel modules. It works on EKS managed nodes.

23
00:02:06,000 --> 00:02:12,000
The eight custom Falco rules cover the threat model. Shell spawning, credential theft, lateral movement, crypto mining, and privilege escalation.

24
00:02:12,000 --> 00:02:18,000
Now let's move to the availability checklist.
[Types: ## 2. Availability]

25
00:02:18,000 --> 00:02:24,000
[Types: ### 2.1 High Availability]

26
00:02:24,000 --> 00:02:30,000
[Types: - [ ] API deployment has 3+ replicas with podAntiAffinity]
[Types: - [ ] Agent Pool deployment has 3+ replicas with podAntiAffinity]
[Types: - [ ] HPA is configured for API (min 3, max 10)]
[Types: - [ ] HPA is configured for Agent Pool (min 3, max 10)]
[Types: - [ ] pgvector StatefulSet has persistent storage (PVC)]
[Types: - [ ] Redis StatefulSet has persistent storage (PVC)]

27
00:02:30,000 --> 00:02:36,000
At least three replicas ensures no single point of failure. If one pod fails, the other two continue serving traffic.

28
00:02:36,000 --> 00:02:42,000
podAntiAffinity spreads pods across different nodes. If a node fails, only one pod is affected. The other pods on other nodes continue.

29
00:02:42,000 --> 00:02:48,000
[Types: ### 2.2 Disaster Recovery]

30
00:02:48,000 --> 00:02:54,000
[Types: - [ ] pgvector backups are configured (pg_dump or WAL archiving)]
[Types: - [ ] Vault snapshots are backed up to S3]
[Types: - [ ] Redis AOF persistence is enabled]
[Types: - [ ] Database credentials are recoverable from Vault]
[Types: - [ ] Restore procedure is documented and tested]

31
00:02:54,000 --> 00:03:00,000
pgvector backups should be configured. In production, this could be pg_dump daily or WAL archiving. The backup should be stored in S3.

32
00:03:00,000 --> 00:03:06,000
Vault snapshots should be backed up to S3 daily. This allows recovery if the Vault cluster is lost. The restore procedure should be documented.

33
00:03:06,000 --> 00:03:12,000
[Types: ### 2.3 Health Checks]

34
00:03:12,000 --> 00:03:18,000
[Types: - [ ] /health endpoint returns database and cache status]
[Types: - [ ] Liveness probes are configured on all containers]
[Types: - [ ] Readiness probes are configured on all containers]
[Types: - [ ] Startup probes are configured for slow-starting containers]
[Types: - [ ] Prometheus alerts fire when pods are unhealthy]

35
00:03:18,000 --> 00:03:24,000
The /health endpoint should check database and cache connectivity. It should return "unhealthy" if either is unavailable.

36
00:03:24,000 --> 00:03:30,000
Liveness probes restart unhealthy containers. Readiness probes remove unhealthy containers from the service. Startup probes give slow-starting containers extra time.

37
00:03:30,000 --> 00:03:36,000
Now let's move to the performance checklist.
[Types: ## 3. Performance]

38
00:03:36,000 --> 00:03:42,000
[Types: ### 3.1 Resource Management]

39
00:03:42,000 --> 00:03:48,000
[Types: - [ ] CPU requests and limits are set on all containers]
[Types: - [ ] Memory requests and limits are set on all containers]
[Types: - [ ] HPA thresholds are tuned for workloads]
[Types: - [ ] Vertical Pod Autoscaler is considered for production]
[Types: - [ ] Node groups are sized appropriately (Karpenter or Cluster Autoscaler)]

40
00:03:48,000 --> 00:03:54,000
CPU and memory requests are used by the scheduler to place pods. Limits prevent pods from consuming too much resources.

41
00:03:54,000 --> 00:04:00,000
HPA thresholds should be tuned based on observed behavior. In our setup, the API scales at 60% CPU and 70% memory. The Agent scales at 55% CPU and 65% memory.

42
00:04:00,000 --> 00:04:06,000
[Types: ### 3.2 Caching]

43
00:04:06,000 --> 00:04:12,000
[Types: - [ ] Redis cache is working (hit rate > 80%)]
[Types: - [ ] Query results are cached (TTL = 1 hour)]
[Types: - [ ] Embedding results are cached]
[Types: - [ ] Cache invalidation is working]
[Types: - [ ] Redis memory limit is appropriate (maxmemory-policy = allkeys-lru)]

44
00:04:12,000 --> 00:04:18,000
The cache hit rate should be monitored. A hit rate above 80% indicates the cache is effective. Below 50% indicates the cache isn't helping.

45
00:04:18,000 --> 00:04:24,000
Query results and embedding results should be cached. This reduces LLM calls and improves response time.

46
00:04:24,000 --> 00:04:30,000
[Types: ### 3.3 Cost Optimization]

47
00:04:30,000 --> 00:04:36,000
[Types: - [ ] LLM token usage is monitored (cost per query)]
48
00:04:36,000 --> 00:04:42,000
[Types: - [ ] Embedding costs are tracked]
49
00:04:42,000 --> 00:04:48,000
[Types: - [ ] Spot instances are used for non-critical workloads]
50
00:04:48,000 --> 00:04:54,000
[Types: - [ ] ECR images are scanned for vulnerabilities (Trivy)]

51
00:04:54,000 --> 00:05:00,000
LLM costs can be significant. Monitoring cost per query helps identify inefficient patterns. The semantic cache should help reduce costs.

52
00:05:00,000 --> 00:05:06,000
Spot instances can reduce infrastructure costs by 60-90%. Non-critical workloads like ingestion can run on spot instances.

53
00:05:06,000 --> 00:05:12,000
Now let's move to the observability checklist.
[Types: ## 4. Observability]

54
00:05:12,000 --> 00:05:18,000
[Types: ### 4.1 Logging]

55
00:05:18,000 --> 00:05:24,000
[Types: - [ ] Structured logging is enabled (JSON format in production)]
56
00:05:24,000 --> 00:05:30,000
[Types: - [ ] Logs are shipped to Loki or CloudWatch]
57
00:05:30,000 --> 00:05:36,000
[Types: - [ ] Logs are searchable by trace_id, service, and level]
58
00:05:36,000 --> 00:05:42,000
[Types: - [ ] Log retention is configured (30 days minimum)]
59
00:05:42,000 --> 00:05:48,000
[Types: - [ ] Audit logs are retained for compliance (analysis_history table)]

60
00:05:48,000 --> 00:05:54,000
Structured logging in JSON format is essential for log aggregation. Loki or CloudWatch can index and search JSON logs efficiently.

61
00:05:54,000 --> 00:06:00,000
Logs should be searchable by trace_id. This enables trace-to-log correlation. You can find all logs for a specific request.

62
00:06:00,000 --> 00:06:06,000
[Types: ### 4.2 Metrics]

63
00:06:06,000 --> 00:06:12,000
[Types: - [ ] Prometheus metrics are exposed (/metrics endpoint)]
64
00:06:12,000 --> 00:06:18,000
[Types: - [ ] SLO recording rules are configured]
65
00:06:18,000 --> 00:06:24,000
[Types: - [ ] SLO dashboards are created in Grafana]
66
00:06:24,000 --> 00:06:30,000
[Types: - [ ] Error budget alerts are configured]
67
00:06:30,000 --> 00:06:36,000
[Types: - [ ] Business metrics are tracked (cost per query, tokens per query)]

68
00:06:36,000 --> 00:06:42,000
Prometheus metrics should be exposed at /metrics. This is the endpoint that Prometheus scrapes.

69
00:06:42,000 --> 00:06:48,000
SLO recording rules pre-compute error rates. SLO dashboards show error budget consumption. Error budget alerts notify you before the budget is exhausted.

70
00:06:48,000 --> 00:06:54,000
[Types: ### 4.3 Tracing]

71
00:06:54,000 --> 00:07:00,000
[Types: - [ ] OpenTelemetry is configured]
72
00:07:00,000 --> 00:07:06,000
[Types: - [ ] Traces are exported to Jaeger (dev/staging) or X-Ray (prod)]
73
00:07:06,000 --> 00:07:12,000
[Types: - [ ] Tail sampling is configured (errors 100%, LLM 100%, fast 1%)]
74
00:07:12,000 --> 00:07:18,000
[Types: - [ ] Trace-to-log correlation is working (trace_id in logs)]
75
00:07:18,000 --> 00:07:24,000
[Types: - [ ] Custom RAG spans are added (embedding, search, LLM)]

76
00:07:24,000 --> 00:07:30,000
OpenTelemetry should be configured with the OTLP exporter. Traces should be exported to Jaeger or X-Ray.

77
00:07:30,000 --> 00:07:36,000
Tail sampling keeps 100% of error traces and LLM traces. It samples 1% of successful fast traces. This controls costs while maintaining visibility.

78
00:07:36,000 --> 00:07:42,000
Trace-to-log correlation means every log includes trace_id. You can click a log line and see the full trace.

79
00:07:42,000 --> 00:07:48,000
Now let's move to the CI/CD checklist.
[Types: ## 5. CI/CD]

80
00:07:48,000 --> 00:07:54,000
[Types: ### 5.1 GitHub Actions]

81
00:07:54,000 --> 00:08:00,000
[Types: - [ ] Workflow runs on every push and PR]
82
00:08:00,000 --> 00:08:06,000
[Types: - [ ] Gitleaks scans for secrets]
83
00:08:06,000 --> 00:08:12,000
[Types: - [ ] Trivy scans for vulnerabilities]
84
00:08:12,000 --> 00:08:18,000
[Types: - [ ] OPA checks Kubernetes manifests]
85
00:08:18,000 --> 00:08:24,000
[Types: - [ ] Unit tests and integration tests pass]
86
00:08:24,000 --> 00:08:30,000
[Types: - [ ] Docker image is built and pushed to ECR]

87
00:08:30,000 --> 00:08:36,000
The GitHub Actions workflow should run on every push and pull request. This catches issues early.

88
00:08:36,000 --> 00:08:42,000
Gitleaks scans for secrets. Trivy scans for vulnerabilities. OPA checks Kubernetes manifests. All tests must pass before the code is merged.

89
00:08:42,000 --> 00:08:48,000
[Types: ### 5.2 GitOps]

90
00:08:48,000 --> 00:08:54,000
[Types: - [ ] ArgoCD is installed and configured]
91
00:08:54,000 --> 00:09:00,000
[Types: - [ ] Applications are synced to Git (dev, staging, prod)]
92
00:09:00,000 --> 00:09:06,000
[Types: - [ ] Sync windows are configured for production]
93
00:09:06,000 --> 00:09:12,000
[Types: - [ ] Notifications are configured (Slack, PagerDuty)]
94
00:09:12,000 --> 00:09:18,000
[Types: - [ ] Rollback procedure is documented]

95
00:09:18,000 --> 00:09:24,000
ArgoCD should be installed and configured with the financial-rag project. The applications should be synced to Git.

96
00:09:24,000 --> 00:09:30,000
Sync windows prevent production deployments during peak hours. Notifications alert the team when deployments succeed or fail.

97
00:09:30,000 --> 00:09:36,000
[Types: ### 5.3 Deployment Strategy]

98
00:09:36,000 --> 00:09:42,000
[Types: - [ ] Rolling updates are configured (maxUnavailable=1, maxSurge=2)]
99
00:09:42,000 --> 00:09:48,000
[Types: - [ ] Blue-green or canary deployments are considered]
100
00:09:48,000 --> 00:09:54,000
[Types: - [ ] Rollback is possible (previous image tag)]
101
00:09:54,000 --> 00:10:00,000
[Types: - [ ] Database migrations are backward-compatible]
102
00:10:00,000 --> 00:10:06,000
[Types: - [ ] Feature flags are used for new features]

103
00:10:06,000 --> 00:10:12,000
Rolling updates with maxUnavailable=1 and maxSurge=2 ensure no downtime during deployments. If a deployment fails, it rolls back automatically.

104
00:10:12,000 --> 00:10:18,000
Database migrations must be backward-compatible. This means you can roll back without breaking the database schema.

105
00:10:18,000 --> 00:10:24,000
Now let's create a verification script. This will automate the checklist.
[Types: ## 6. Verification Script]

106
00:10:24,000 --> 00:10:30,000
Create `scripts/verify-prod.sh`.
[Types: #!/bin/bash]
[Types: set -e]

107
00:10:30,000 --> 00:10:36,000
[Types: echo "🔍 Running production readiness verification..."]

108
00:10:36,000 --> 00:10:42,000
Check namespace.
[Types: echo "✅ Checking namespace..."]
[Types: kubectl get namespace financial-rag || exit 1]

109
00:10:42,000 --> 00:10:48,000
Check Vault.
[Types: echo "✅ Checking Vault..."]
[Types: kubectl exec -n vault vault-0 -- vault status || exit 1]

110
00:10:48,000 --> 00:10:54,000
Check database credentials.
[Types: echo "✅ Checking database credentials..."]
[Types: kubectl exec -n vault vault-0 -- vault read database/creds/api-role || exit 1]

111
00:10:54,000 --> 00:11:00,000
Check Cilium.
[Types: echo "✅ Checking Cilium..."]
[Types: kubectl get pods -n kube-system -l k8s-app=cilium || exit 1]

112
00:11:00,000 --> 00:11:06,000
Check Falco.
[Types: echo "✅ Checking Falco..."]
[Types: kubectl get pods -n kube-system -l app.kubernetes.io/name=falco || exit 1]

113
00:11:06,000 --> 00:11:12,000
Check Istio.
[Types: echo "✅ Checking Istio..."]
[Types: kubectl get pods -n istio-system -l app=istiod || exit 1]

114
00:11:12,000 --> 00:11:18,000
Check API.
[Types: echo "✅ Checking API..."]
[Types: kubectl get pods -n financial-rag -l app.kubernetes.io/component=api || exit 1]

115
00:11:18,000 --> 00:11:24,000
Check Agent.
[Types: echo "✅ Checking Agent..."]
[Types: kubectl get pods -n financial-rag -l app.kubernetes.io/component=agent || exit 1]

116
00:11:24,000 --> 00:11:30,000
Check pgvector.
[Types: echo "✅ Checking pgvector..."]
[Types: kubectl get pods -n financial-rag -l app.kubernetes.io/component=pgvector || exit 1]

117
00:11:30,000 --> 00:11:36,000
Check Redis.
[Types: echo "✅ Checking Redis..."]
[Types: kubectl get pods -n financial-rag -l app.kubernetes.io/component=redis || exit 1]

118
00:11:36,000 --> 00:11:42,000
Check Prometheus.
[Types: echo "✅ Checking Prometheus..."]
[Types: kubectl get servicemonitor -n monitoring || exit 1]

119
00:11:42,000 --> 00:11:48,000
Check Grafana.
[Types: echo "✅ Checking Grafana..."]
[Types: kubectl get pods -n observability -l app.kubernetes.io/name=grafana || exit 1]

120
00:11:48,000 --> 00:11:54,000
Check health endpoint.
[Types: echo "✅ Checking health endpoint..."]
[Types: curl -s http://localhost:8000/health | jq '.status' || exit 1]

121
00:11:54,000 --> 00:12:00,000
[Types: echo "✅ All checks passed! The system is production-ready."]

122
00:12:00,000 --> 00:12:06,000
Make the script executable.
[Types: chmod +x scripts/verify-prod.sh]

123
00:12:06,000 --> 00:12:12,000
Run the verification script.
[Types: ./scripts/verify-prod.sh]

124
00:12:12,000 --> 00:12:18,000
If all checks pass, the system is production-ready. If any check fails, fix the issue and run the script again.

125
00:12:18,000 --> 00:12:24,000
Now let me recap what we've covered in Part 4.

126
00:12:24,000 --> 00:12:30,000
We built the production readiness checklist. Security, availability, performance, observability, and CI/CD.

127
00:12:30,000 --> 00:12:36,000
We created a verification script. It automates the checklist. It checks every component.

128
00:12:36,000 --> 00:12:42,000
This is the final step. The system is now production-ready.

129
00:12:42,000 --> 00:12:48,000
Phase 12 is complete. The Financial RAG Agent series is complete.

130
00:12:48,000 --> 00:12:54,000
Thank you for following along from Phase 1 to Phase 12. You've built a production-grade Financial RAG Agent.

131
00:12:54,000 --> 00:13:00,000
This is a significant achievement. Most developers never build a system this comprehensive.

132
00:13:00,000 --> 00:13:06,000
Go deploy your application. Get it in front of users. And keep learning.

133
00:13:06,000 --> 00:13:10,000
I'll see you in the next series.

134
00:13:10,000 --> 00:13:14,000
[End of Phase 12]
```