1
00:00:00,000 --> 00:00:08,000
Welcome back. This is Phase 8. We're going to package our entire application for Kubernetes deployment using Helm.

2
00:00:08,000 --> 00:00:16,000
Now, you might be wondering, what exactly is Helm? Helm is the package manager for Kubernetes. Think of it like npm for Node.js or pip for Python. It packages all your Kubernetes manifests into a single, versioned artifact called a chart.

3
00:00:16,000 --> 00:00:24,000
Let me give you a mental model. Imagine you're moving into a new house. Instead of carrying each piece of furniture individually, you put everything into a moving truck. The truck is your Helm chart. It contains all the manifests you need to run your application.

4
00:00:24,000 --> 00:00:32,000
Open your editor. We're going to create our Helm chart structure. First, navigate to the infrastructure directory. Then create the helm directory. Then create the financial-rag-agent directory. This is where all our Helm files will live.

5
00:00:32,000 --> 00:00:38,000
[Types: mkdir -p infrastructure/helm/financial-rag-agent]

6
00:00:38,000 --> 00:00:44,000
Now let's create the Chart.yaml file. This is the metadata file for our Helm chart. It tells Helm what this chart is and what it depends on.

7
00:00:44,000 --> 00:00:50,000
[Types: touch infrastructure/helm/financial-rag-agent/Chart.yaml]

8
00:00:50,000 --> 00:00:56,000
Open Chart.yaml in your editor. We'll start with the apiVersion field. This defines the version of the Helm chart API we're using. For Helm v3, we use v2.

9
00:00:56,000 --> 00:01:02,000
[Types: apiVersion: v2]

10
00:01:02,000 --> 00:01:08,000
Now the name field. This is the name of our Helm chart. It should match the directory name.

11
00:01:08,000 --> 00:01:14,000
[Types: name: financial-rag-agent]

12
00:01:14,000 --> 00:01:20,000
The description field is a brief description of what this chart does. This appears in Helm repo listings.

13
00:01:20,000 --> 00:01:26,000
[Types: description: Production Helm chart for the Financial RAG Agent — a multi-agent system for SEC EDGAR ingestion, hybrid vector retrieval, and LLM-powered financial Q&A.]

14
00:01:26,000 --> 00:01:32,000
Now the type field. This tells Helm that this is an application chart. The other option is library, which is for reusable code.

15
00:01:32,000 --> 00:01:38,000
[Types: type: application]

16
00:01:38,000 --> 00:01:44,000
The version field. This is the version of your Helm chart. Every time you release a new version of your application, you increment this version.

17
00:01:44,000 --> 00:01:50,000
[Types: version: 0.1.0]

18
00:01:50,000 --> 00:01:56,000
The appVersion field. This is the version of the actual application inside the chart. This can be different from the chart version.

19
00:01:56,000 --> 00:02:02,000
[Types: appVersion: "1.0.0"]

20
00:02:02,000 --> 00:02:08,000
Now the keywords. These help users find your chart in a Helm repository.

21
00:02:08,000 --> 00:02:14,000
[Types: keywords: - rag - fintech - llm - pgvector - fastapi]

22
00:02:14,000 --> 00:02:20,000
The maintainers section. This tells users who maintains this chart and how to contact them.

23
00:02:20,000 --> 00:02:26,000
[Types: maintainers: - name: Cloudfrugal email: ayo@cloudfrugal.com]

24
00:02:26,000 --> 00:02:32,000
Finally, the dependencies section. This charts doesn't have any external dependencies. But this is where we would list them if we did.

25
00:02:32,000 --> 00:02:38,000
[Types: dependencies: []]

26
00:02:38,000 --> 00:02:44,000
Let me show you the complete Chart.yaml file. This is what you should have in your editor.

27
00:02:44,000 --> 00:02:50,000
apiVersion: v2
name: financial-rag-agent
description: Production Helm chart for the Financial RAG Agent — a multi-agent system for SEC EDGAR ingestion, hybrid vector retrieval, and LLM-powered financial Q&A.
type: application
version: 0.1.0
appVersion: "1.0.0"
keywords:
  - rag
  - fintech
  - llm
  - pgvector
  - fastapi
maintainers:
  - name: Cloudfrugal
    email: ayo@cloudfrugal.com
dependencies: []

28
00:02:50,000 --> 00:02:56,000
Now let's create the values.yaml file. This is the most important file. It defines all the configurable parameters for your Helm chart.

29
00:02:56,000 --> 00:03:02,000
[Types: touch infrastructure/helm/financial-rag-agent/values.yaml]

30
00:03:02,000 --> 00:03:08,000
Open values.yaml in your editor. We'll start with the global section. These are values that apply to all components.

31
00:03:08,000 --> 00:03:14,000
[Types: global: image: registry: ""]

32
00:03:14,000 --> 00:03:20,000
The registry is where our images are stored. In production, this would be our ECR registry URL. For development, we might use Docker Hub.

33
00:03:20,000 --> 00:03:26,000
[Types: pullPolicy: IfNotPresent]

34
00:03:26,000 --> 00:03:32,000
The pullPolicy tells Kubernetes when to pull images. IfNotPresent means it only pulls if the image isn't already on the node.

35
00:03:32,000 --> 00:03:38,000
[Types: podAnnotations: {}]

36
00:03:38,000 --> 00:03:44,000
Pod annotations can be used for monitoring tools like Prometheus.

37
00:03:44,000 --> 00:03:50,000
[Types: podLabels: {}]

38
00:03:50,000 --> 00:03:56,000
Pod labels are used for selecting and grouping pods.

39
00:03:56,000 --> 00:04:02,000
[Types: nodeSelector: {}]

40
00:04:02,000 --> 00:04:08,000
NodeSelector constrains pods to specific nodes.

41
00:04:08,000 --> 00:04:14,000
[Types: tolerations: []]

42
00:04:14,000 --> 00:04:20,000
Tolerations allow pods to schedule on nodes with taints.

43
00:04:20,000 --> 00:04:26,000
[Types: affinity: {}]

44
00:04:26,000 --> 00:04:32,000
Affinity is used for pod placement rules, like ensuring pods are spread across different nodes.

45
00:04:32,000 --> 00:04:38,000
Now let's define the API section. This configures our FastAPI service.

46
00:04:38,000 --> 00:04:44,000
[Types: api: enabled: true]

47
00:04:44,000 --> 00:04:50,000
The enabled flag controls whether this component is deployed.

48
00:04:50,000 --> 00:04:56,000
[Types: image: repository: financial-rag-agent/api tag: latest]

49
00:04:56,000 --> 00:05:02,000
The repository and tag define which container image to use. In production, we'll override the tag with a specific commit SHA.

50
00:05:02,000 --> 00:05:08,000
[Types: replicaCount: 2]

51
00:05:08,000 --> 00:05:14,000
This is the number of API pods to run. In development, 2 is fine. In production, we'll scale to 5 or more.

52
00:05:14,000 --> 00:05:20,000
[Types: resources: requests: cpu: "500m" memory: "512Mi" limits: cpu: "1000m" memory: "1Gi"]

53
00:05:20,000 --> 00:05:26,000
Resource requests and limits are critical. They ensure our pods get the resources they need and don't starve other pods.

54
00:05:26,000 --> 00:05:32,000
[Types: service: type: ClusterIP port: 8000]

55
00:05:32,000 --> 00:05:38,000
The service type is ClusterIP by default. This makes the API accessible internally within the cluster.

56
00:05:38,000 --> 00:05:44,000
[Types: ingress: enabled: false className: alb annotations: {} host: "" tls: []]

57
00:05:44,000 --> 00:05:50,000
Ingress controls external access. In production, we'll enable this with the AWS ALB controller.

58
00:05:50,000 --> 00:05:56,000
[Types: env: LOG_LEVEL: "info" WORKERS: "2"]

59
00:05:56,000 --> 00:06:02,000
Environment variables that are specific to the API service.

60
00:06:02,000 --> 00:06:08,000
[Types: envFrom: - secretRef: name: financial-rag-secrets]

61
00:06:08,000 --> 00:06:14,000
envFrom loads secrets from a Kubernetes Secret. This is where we store sensitive data like database passwords.

62
00:06:14,000 --> 00:06:20,000
[Types: livenessProbe: httpGet: path: /health port: 8000 initialDelaySeconds: 15 periodSeconds: 20]

63
00:06:20,000 --> 00:06:26,000
The livenessProbe checks if the container is alive. If it fails, Kubernetes restarts the pod.

64
00:06:26,000 --> 00:06:32,000
[Types: readinessProbe: httpGet: path: /health port: 8000 initialDelaySeconds: 10 periodSeconds: 10]

65
00:06:32,000 --> 00:06:38,000
The readinessProbe checks if the container is ready to receive traffic. If it fails, Kubernetes stops sending traffic to the pod.

66
00:06:38,000 --> 00:06:44,000
[Types: hpa: enabled: true minReplicas: 2 maxReplicas: 6 targetCPUUtilizationPercentage: 70 targetMemoryUtilizationPercentage: 80]

67
00:06:44,000 --> 00:06:50,000
The HorizontalPodAutoscaler (HPA) scales our API based on CPU and memory usage.

68
00:06:50,000 --> 00:06:56,000
Now let's define the Agent Pool section. This is for our function-calling worker pods.

69
00:06:56,000 --> 00:07:02,000
[Types: agentPool: enabled: true image: repository: financial-rag-agent/agent tag: latest replicaCount: 2]

70
00:07:02,000 --> 00:07:08,000
The agent pool has its own image and replica count. It runs the agent worker service.

71
00:07:08,000 --> 00:07:14,000
[Types: resources: requests: cpu: "500m" memory: "1Gi" limits: cpu: "2000m" memory: "2Gi"]

72
00:07:14,000 --> 00:07:20,000
Agent pods are memory-heavy because they handle LLM inference and embedding models.

73
00:07:20,000 --> 00:07:26,000
[Types: env: AGENT_CONCURRENCY: "4" LOG_LEVEL: "info"]

74
00:07:26,000 --> 00:07:32,000
The AGENT_CONCURRENCY controls how many concurrent tasks each agent pod can handle.

75
00:07:32,000 --> 00:07:38,000
[Types: hpa: enabled: true minReplicas: 2 maxReplicas: 8 targetCPUUtilizationPercentage: 65 targetMemoryUtilizationPercentage: 75]

76
00:07:38,000 --> 00:07:44,000
The agent HPA scales based on both CPU and memory. We use lower thresholds because agent tasks are often memory-spiky.

77
00:07:44,000 --> 00:07:50,000
Now let's define the Ingestion CronJob. This runs on a schedule to ingest new filings.

78
00:07:50,000 --> 00:07:56,000
[Types: ingestion: enabled: true image: repository: financial-rag-agent/ingestion tag: latest schedule: "0 2 * * *"]

79
00:07:56,000 --> 00:08:02,000
The schedule field uses cron syntax. "0 2 * * *" means every day at 2 AM UTC.

80
00:08:02,000 --> 00:08:08,000
[Types: concurrencyPolicy: Forbid]

81
00:08:08,000 --> 00:08:14,000
Forbid prevents overlapping runs. If a job is still running when the next scheduled time comes, the new job waits.

82
00:08:14,000 --> 00:08:20,000
[Types: successfulJobsHistoryLimit: 3 failedJobsHistoryLimit: 3 restartPolicy: OnFailure]

83
00:08:20,000 --> 00:08:26,000
These settings control job history retention and restart behavior.

84
00:08:26,000 --> 00:08:32,000
[Types: resources: requests: cpu: "250m" memory: "512Mi" limits: cpu: "1000m" memory: "1Gi"]

85
00:08:32,000 --> 00:08:38,000
Ingestion pods run periodically. They need enough resources to process filings, but not as much as the always-on services.

86
00:08:38,000 --> 00:08:44,000
[Types: env: INGESTION_BATCH_SIZE: "50" LOG_LEVEL: "info"]

87
00:08:44,000 --> 00:08:50,000
The batch size controls how many filings to process in one run.

88
00:08:50,000 --> 00:08:56,000
Now let's define the pgvector StatefulSet. This is our PostgreSQL database with the pgvector extension.

89
00:08:56,000 --> 00:09:02,000
[Types: pgvector: enabled: true image: repository: pgvector/pgvector tag: "pg16" replicaCount: 1]

90
00:09:02,000 --> 00:09:08,000
We use the official pgvector image. It's built on PostgreSQL 16.

91
00:09:08,000 --> 00:09:14,000
[Types: resources: requests: cpu: "500m" memory: "1Gi" limits: cpu: "2000m" memory: "4Gi"]

92
00:09:14,000 --> 00:09:20,000
pgvector needs significant memory for vector indexes and query processing.

93
00:09:20,000 --> 00:09:26,000
[Types: storage: storageClassName: gp3 size: 50Gi]

94
00:09:26,000 --> 00:09:32,000
The storageClassName defines what type of storage to use. gp3 is AWS's general-purpose SSD storage.

95
00:09:32,000 --> 00:09:38,000
[Types: service: port: 5432]

96
00:09:38,000 --> 00:09:44,000
The PostgreSQL service listens on port 5432. This is the standard PostgreSQL port.

97
00:09:44,000 --> 00:09:50,000
[Types: env: POSTGRES_DB: financial_rag POSTGRES_USER: raguser]

98
00:09:50,000 --> 00:09:56,000
These are the database name and username. The password is loaded from the secret.

99
00:09:56,000 --> 00:10:02,000
[Types: persistence: enabled: true]

100
00:10:02,000 --> 00:10:08,000
Persistence means data survives pod restarts. We use a persistent volume claim.

101
00:10:08,000 --> 00:10:14,000
[Types: livenessProbe: exec: command: ["pg_isready", "-U", "raguser", "-d", "financial_rag"] initialDelaySeconds: 30 periodSeconds: 20]

102
00:10:14,000 --> 00:10:20,000
The pg_isready command checks if PostgreSQL is accepting connections.

103
00:10:20,000 --> 00:10:26,000
[Types: readinessProbe: exec: command: ["pg_isready", "-U", "raguser", "-d", "financial_rag"] initialDelaySeconds: 10 periodSeconds: 10]

104
00:10:26,000 --> 00:10:32,000
The readiness probe uses the same command. It ensures the service is ready before it receives traffic.

105
00:10:32,000 --> 00:10:38,000
Now let's define the Redis StatefulSet. Redis is our cache layer.

106
00:10:38,000 --> 00:10:44,000
[Types: redis: enabled: true image: repository: redis tag: "7-alpine" replicaCount: 1]

107
00:10:44,000 --> 00:10:50,000
We use the official Redis Alpine image. It's small and secure.

108
00:10:50,000 --> 00:10:56,000
[Types: resources: requests: cpu: "100m" memory: "256Mi" limits: cpu: "500m" memory: "512Mi"]

109
00:10:56,000 --> 00:11:02,000
Redis is lightweight. It doesn't need much memory for caching.

110
00:11:02,000 --> 00:11:08,000
[Types: storage: storageClassName: gp3 size: 10Gi]

111
00:11:08,000 --> 00:11:14,000
Redis doesn't need much storage. 10GB is enough for caching.

112
00:11:14,000 --> 00:11:20,000
[Types: service: port: 6379]

113
00:11:20,000 --> 00:11:26,000
Redis listens on port 6379. This is the standard Redis port.

114
00:11:26,000 --> 00:11:32,000
[Types: args: - "--appendonly" - "yes" - "--maxmemory" - "400mb" - "--maxmemory-policy" - "allkeys-lru"]

115
00:11:32,000 --> 00:11:38,000
The args section passes command-line arguments to Redis. appendonly enables persistence. maxmemory sets the memory limit.

116
00:11:38,000 --> 00:11:44,000
[Types: livenessProbe: exec: command: ["redis-cli", "ping"] initialDelaySeconds: 10 periodSeconds: 15]

117
00:11:44,000 --> 00:11:50,000
The redis-cli ping command checks if Redis is responding.

118
00:11:50,000 --> 00:11:56,000
[Types: readinessProbe: exec: command: ["redis-cli", "ping"] initialDelaySeconds: 5 periodSeconds: 10]

119
00:11:56,000 --> 00:12:02,000
The readiness probe uses the same command. It ensures Redis is ready before it receives traffic.

120
00:12:02,000 --> 00:12:08,000
Finally, let's define the ServiceMonitor. This is for Prometheus metrics collection.

121
00:12:08,000 --> 00:12:14,000
[Types: serviceMonitor: enabled: false namespace: monitoring interval: 30s path: /metrics]

122
00:12:14,000 --> 00:12:20,000
The ServiceMonitor tells Prometheus where to find our metrics endpoint.

123
00:12:20,000 --> 00:12:26,000
Now let's create the production values file. This overrides the base values for production.

124
00:12:26,000 --> 00:12:32,000
[Types: touch infrastructure/helm/financial-rag-agent/values.prod.yaml]

125
00:12:32,000 --> 00:12:38,000
Open values.prod.yaml in your editor. We'll start with the global section.

126
00:12:38,000 --> 00:12:44,000
[Types: global: image: registry: "123456789.dkr.ecr.us-east-1.amazonaws.com" pullPolicy: Always]

127
00:12:44,000 --> 00:12:50,000
In production, we use ECR as our registry. We set pullPolicy to Always to ensure we always get the latest image.

128
00:12:50,000 --> 00:12:56,000
[Types: nodeSelector: role: application tolerations: - key: "dedicated" operator: "Equal" value: "application" effect: "NoSchedule"]

129
00:12:56,000 --> 00:13:02,000
These nodeSelector and tolerations ensure our pods run on the correct nodes in the cluster.

130
00:13:02,000 --> 00:13:08,000
[Types: podAnnotations: prometheus.io/scrape: "true" prometheus.io/port: "8000"]

131
00:13:08,000 --> 00:13:14,000
These annotations tell Prometheus to scrape metrics from our pods.

132
00:13:14,000 --> 00:13:20,000
Now let's override the API values for production.

133
00:13:20,000 --> 00:13:26,000
[Types: api: replicaCount: 5 resources: requests: cpu: "1000m" memory: "1Gi" limits: cpu: "2000m" memory: "2Gi"]

134
00:13:26,000 --> 00:13:32,000
In production, we run 5 replicas with higher resource limits. This handles more traffic.

135
00:13:32,000 --> 00:13:38,000
[Types: env: LOG_LEVEL: "warning" WORKERS: "4"]

136
00:13:38,000 --> 00:13:44,000
We use warning log level in production to reduce noise. We use 4 workers to handle more concurrent requests.

137
00:13:44,000 --> 00:13:50,000
[Types: ingress: enabled: true className: alb annotations: kubernetes.io/ingress.class: alb alb.ingress.kubernetes.io/scheme: internet-facing alb.ingress.kubernetes.io/target-type: ip alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS":443}]' alb.ingress.kubernetes.io/ssl-redirect: "443" alb.ingress.kubernetes.io/certificate-arn: "arn:aws:acm:us-east-1:123456789:certificate/REPLACE-ME" alb.ingress.kubernetes.io/healthcheck-path: /health host: api.financial-rag.cloudfrugal.com tls: - secretName: financial-rag-tls hosts: - api.financial-rag.cloudfrugal.com]

138
00:13:50,000 --> 00:13:56,000
The ingress configuration creates an AWS ALB. It handles SSL termination and routes traffic to our API service.

139
00:13:56,000 --> 00:14:02,000
[Types: hpa: minReplicas: 5 maxReplicas: 20 targetCPUUtilizationPercentage: 60 targetMemoryUtilizationPercentage: 70]

140
00:14:02,000 --> 00:14:08,000
In production, we scale more aggressively. 5 to 20 replicas based on CPU and memory.

141
00:14:08,000 --> 00:14:14,000
Now let's override the Agent Pool values for production.

142
00:14:14,000 --> 00:14:20,000
[Types: agentPool: replicaCount: 5 resources: requests: cpu: "2000m" memory: "4Gi" limits: cpu: "4000m" memory: "8Gi" env: AGENT_CONCURRENCY: "8" LOG_LEVEL: "warning"]

143
00:14:20,000 --> 00:14:26,000
Agent pods need more resources in production. They handle LLM inference which is resource-intensive.

144
00:14:26,000 --> 00:14:32,000
[Types: hpa: minReplicas: 5 maxReplicas: 25 targetCPUUtilizationPercentage: 55 targetMemoryUtilizationPercentage: 65]

145
00:14:32,000 --> 00:14:38,000
The Agent HPA uses lower thresholds because agent tasks are often CPU-spiky.

146
00:14:38,000 --> 00:14:44,000
Now let's override the Ingestion values for production.

147
00:14:44,000 --> 00:14:50,000
[Types: ingestion: image: tag: "1.0.0" schedule: "0 1 * * *" resources: requests: cpu: "1000m" memory: "2Gi" limits: cpu: "2000m" memory: "4Gi" env: INGESTION_BATCH_SIZE: "200" LOG_LEVEL: "warning"]

148
00:14:50,000 --> 00:14:56,000
Ingestion runs less frequently in production. It processes larger batches with more resources.

149
00:14:56,000 --> 00:15:02,000
Now let's override the pgvector values for production.

150
00:15:02,000 --> 00:15:08,000
[Types: pgvector: resources: requests: cpu: "2000m" memory: "8Gi" limits: cpu: "4000m" memory: "16Gi" storage: storageClassName: gp3-iops size: 500Gi]

151
00:15:08,000 --> 00:15:14,000
In production, pgvector needs significant resources. The vector index grows large. 500GB of storage with high IOPS.

152
00:15:14,000 --> 00:15:20,000
Now let's override the Redis values for production.

153
00:15:20,000 --> 00:15:26,000
[Types: redis: resources: requests: cpu: "500m" memory: "2Gi" limits: cpu: "1000m" memory: "4Gi" storage: size: 50Gi args: - "--appendonly" - "yes" - "--maxmemory" - "3500mb" - "--maxmemory-policy" - "allkeys-lru"]

154
00:15:26,000 --> 00:15:32,000
Production Redis needs more memory for the cache. The maxmemory is set to 3500MB to leave room for Redis itself.

155
00:15:32,000 --> 00:15:38,000
[Types: serviceMonitor: enabled: true namespace: monitoring interval: 15s]

156
00:15:38,000 --> 00:15:44,000
In production, we enable the ServiceMonitor. Prometheus scrapes our metrics every 15 seconds.

157
00:15:44,000 --> 00:15:50,000
Now let me recap what we've built in Part 1.

158
00:15:50,000 --> 00:15:56,000
We built the Chart.yaml file. This is the metadata file for our Helm chart. It defines the name, version, description, keywords, and maintainers.

159
00:15:56,000 --> 00:16:02,000
We built the values.yaml file. This is the configuration file for our Helm chart. It defines all configurable parameters for every component.

160
00:16:02,000 --> 00:16:08,000
We built the values.prod.yaml file. This overrides the base values for production. It uses ECR, sets higher resource limits, and enables the ALB Ingress.

161
00:16:08,000 --> 00:16:14,000
In Part 2, we'll build the helper templates. These are reusable templates that generate consistent labels, selectors, and annotations.

162
00:16:14,000 --> 00:16:20,000
Thank you for watching. I'll see you in Part 2.

163
00:16:20,000 --> 00:16:24,000
[End of Part 1]

1
00:00:00,000 --> 00:00:06,000
Welcome back to Phase 8. In Part 2, we build the Helm helper templates.

2
00:00:06,000 --> 00:00:12,000
Helper templates are reusable functions that generate Kubernetes manifests.
They prevent duplication and keep our templates clean.

3
00:00:12,000 --> 00:00:18,000
Think of helpers like utility functions in Python. You define them once and use them everywhere.
They handle the repetitive parts of template generation.

4
00:00:18,000 --> 00:00:24,000
Open your editor and create `infrastructure/helm/templates/_helpers.tpl`.

5
00:00:24,000 --> 00:00:30,000
We'll start by defining the name function. This generates the full name of the chart.
[Types: {{- define "financial-rag-agent.fullname" -}}]

6
00:00:30,000 --> 00:00:36,000
The define keyword creates a named template. We can call it later with include.
[Types: {{- if .Values.fullnameOverride -}}]

7
00:00:36,000 --> 00:00:42,000
If the user provides a fullnameOverride value, we use that instead of the default.
[Types: {{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}]

8
00:00:42,000 --> 00:00:48,000
We truncate to 63 characters because that's the maximum length for Kubernetes names.
We trim the suffix because Kubernetes names can't end with a dash.

9
00:00:48,000 --> 00:00:54,000
If there's no override, we use the release name and chart name.
[Types: {{- else -}}]

10
00:00:54,000 --> 00:01:00,000
[Types: {{- $name := default .Chart.Name .Values.nameOverride -}}]
We use the nameOverride if provided, otherwise the chart name.

11
00:01:00,000 --> 00:01:06,000
[Types: {{- if contains $name .Release.Name -}}]
If the release name already contains the chart name, we just use the release name.
[Types: {{- .Release.Name | trunc 63 | trimSuffix "-" -}}]

12
00:01:06,000 --> 00:01:12,000
[Types: {{- else -}}]
If not, we combine them with a dash.
[Types: {{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}]

13
00:01:12,000 --> 00:01:18,000
[Types: {{- end -}}]
[Types: {{- end -}}]
[Types: {{- end -}}]

14
00:01:18,000 --> 00:01:24,000
Now let's define the chart name function. This is simpler.
[Types: {{- define "financial-rag-agent.chart" -}}]

15
00:01:24,000 --> 01:30,000 - Replace --timeout 5m
We use the chart name and version.
[Types: {{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}]
We replace plus signs with underscores because Kubernetes doesn't allow them.

16
00:01:30,000 --> 00:01:36,000
[Types: {{- end -}}]

17
00:01:36,000 --> 00:01:42,000
Now let's define the selector labels function. These labels identify the pod.
[Types: {{- define "financial-rag-agent.selectorLabels" -}}]

18
00:01:42,000 --> 00:01:48,000
[Types: app.kubernetes.io/name: {{ include "financial-rag-agent.name" . }}]
[Types: app.kubernetes.io/instance: {{ .Release.Name }}]

19
00:01:48,000 --> 00:01:54,000
The name label identifies the application. The instance label identifies the release.
Together they form a unique selector for the pod.

20
00:01:54,000 --> 00:02:00,000
[Types: {{- end -}}]

21
00:02:00,000 --> 00:02:06,000
Now let's define the labels function. These are applied to all resources.
[Types: {{- define "financial-rag-agent.labels" -}}]

22
00:02:06,000 --> 00:02:12,000
We include the Helm standard labels for compatibility.
[Types: helm.sh/chart: {{ include "financial-rag-agent.chart" . }}]

23
00:02:12,000 --> 00:02:18,000
[Types: {{ include "financial-rag-agent.selectorLabels" . }}]
[Types: {{- if .Chart.AppVersion }}]

24
00:02:18,000 --> 00:02:24,000
[Types: app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}]
[Types: {{- end }}]

25
00:02:24,000 --> 00:02:30,000
[Types: app.kubernetes.io/managed-by: {{ .Release.Service }}]
[Types: app.kubernetes.io/part-of: financial-rag-agent]

26
00:02:30,000 --> 00:02:36,000
The managed-by label helps identify who manages the resource.
The part-of label groups all resources in the application.

27
00:02:36,000 --> 00:02:42,000
[Types: {{- with .Values.global.labels }}]
[Types: {{- toYaml . }}]
[Types: {{- end }}]

28
00:02:42,000 --> 00:02:48,000
We include any additional labels from the global configuration.
[Types: {{- end -}}]

29
00:02:48,000 --> 00:02:54,000
Now let's define the image function. This generates the full image name.
[Types: {{- define "financial-rag-agent.image" -}}]

30
00:02:54,000 --> 00:03:00,000
[Types: {{- $registry := .global.registry | default "" -}}]
[Types: {{- $repository := .image.repository -}}]
[Types: {{- $tag := .image.tag | default .global.tag | default "latest" -}}]

31
00:03:00,000 --> 00:03:06,000
We get the registry from the global config or use an empty string.
We get the repository from the image config.
We get the tag from the image config or the global tag, falling back to latest.

32
00:03:06,000 --> 00:03:12,000
[Types: {{- if $registry -}}]
[Types: {{- printf "%s/%s:%s" $registry $repository $tag -}}]

33
00:03:12,000 --> 00:03:18,000
If there's a registry, we include it in the image name.
[Types: {{- else -}}]
[Types: {{- printf "%s:%s" $repository $tag -}}]

34
00:03:18,000 --> 00:03:24,000
If there's no registry, we just use the repository and tag.
[Types: {{- end -}}]
[Types: {{- end -}}]

35
00:03:24,000 --> 00:03:30,000
Now let's define the pod annotations function. These add metadata to the pod.
[Types: {{- define "financial-rag-agent.podAnnotations" -}}]

36
00:03:30,000 --> 00:03:36,000
[Types: {{- with .Values.global.podAnnotations }}]
[Types: {{- toYaml . }}]
[Types: {{- end }}]

37
00:03:36,000 --> 00:03:42,000
We include any global annotations from the configuration.
[Types: {{- with .componentAnnotations }}]
[Types: {{- toYaml . }}]
[Types: {{- end }}]

38
00:03:42,000 --> 00:03:48,000
We include any component-specific annotations from the component configuration.
[Types: {{- end -}}]

39
00:03:48,000 --> 00:03:54,000
Now let's define the common environment variables function.
[Types: {{- define "financial-rag-agent.commonEnv" -}}]

40
00:03:54,000 --> 00:04:00,000
[Types: - name: APP_ENV]
[Types: value: {{ .Values.global.environment | default "production" }}]

41
00:04:00,000 --> 00:04:06,000
[Types: - name: APP_VERSION]
[Types: value: {{ .Chart.AppVersion }}]

42
00:04:06,000 --> 00:04:12,000
These environment variables are common to all components.

43
00:04:12,000 --> 00:04:18,000
[Types: - name: POSTGRES_HOST]
[Types: value: {{ include "financial-rag-agent.fullname" . }}-pgvector]

44
00:04:18,000 --> 00:04:24,000
[Types: - name: POSTGRES_PORT]
[Types: value: {{ .Values.pgvector.service.port | quote }}]

45
00:04:24,000 --> 00:04:30,000
[Types: - name: POSTGRES_DB]
[Types: value: {{ .Values.pgvector.env.POSTGRES_DB }}]

46
00:04:30,000 --> 00:04:36,000
[Types: - name: POSTGRES_USER]
[Types: value: {{ .Values.pgvector.env.POSTGRES_USER }}]

47
00:04:36,000 --> 00:04:42,000
[Types: - name: POSTGRES_PASSWORD]
[Types: valueFrom:]
[Types: secretKeyRef:]
[Types: name: {{ include "financial-rag-agent.fullname" . }}-secrets]
[Types: key: postgres-password]

48
00:04:42,000 --> 00:04:48,000
[Types: - name: REDIS_HOST]
[Types: value: {{ include "financial-rag-agent.fullname" . }}-redis]

49
00:04:48,000 --> 00:04:54,000
[Types: - name: REDIS_PORT]
[Types: value: {{ .Values.redis.service.port | quote }}]

50
00:04:54,000 --> 00:05:00,000
[Types: - name: REDIS_PASSWORD]
[Types: valueFrom:]
[Types: secretKeyRef:]
[Types: name: {{ include "financial-rag-agent.fullname" . }}-secrets]
[Types: key: redis-password]

51
00:05:00,000 --> 00:05:06,000
[Types: - name: LOG_LEVEL]
[Types: value: {{ .Values.api.env.LOG_LEVEL | default "info" }}]

52
00:05:06,000 --> 00:05:12,000
[Types: {{- end -}}]

53
00:05:12,000 --> 00:05:18,000
Now let me show you the complete _helpers.tpl file.

54
00:05:18,000 --> 00:05:24,000
You should have this in your editor. Let me walk through the entire file.

55
00:05:24,000 --> 00:05:30,000
{{- /*
Common labels to be used across all resources.
*/ -}}

56
00:05:30,000 --> 00:05:36,000
{{- define "financial-rag-agent.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

57
00:05:36,000 --> 00:05:42,000
This is the fullname helper. It's the most important helper in the chart.
It generates the full name of the release.

58
00:05:42,000 --> 00:05:48,000
{{- define "financial-rag-agent.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

59
00:05:48,000 --> 00:05:54,000
This generates the chart name and version for labeling.

60
00:05:54,000 --> 00:06:00,000
{{- define "financial-rag-agent.selectorLabels" -}}
app.kubernetes.io/name: {{ include "financial-rag-agent.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

61
00:06:00,000 --> 00:06:06,000
These labels are used by the pod selector. They must match exactly.

62
00:06:06,000 --> 00:06:12,000
{{- define "financial-rag-agent.labels" -}}
helm.sh/chart: {{ include "financial-rag-agent.chart" . }}
{{ include "financial-rag-agent.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: financial-rag-agent
{{- with .Values.global.labels }}
{{- toYaml . }}
{{- end }}
{{- end -}}

63
00:06:12,000 --> 00:06:18,000
These labels are applied to all resources. They provide consistent metadata.

64
00:06:18,000 --> 00:06:24,000
{{- define "financial-rag-agent.image" -}}
{{- $registry := .global.registry | default "" -}}
{{- $repository := .image.repository -}}
{{- $tag := .image.tag | default .global.tag | default "latest" -}}
{{- if $registry -}}
{{- printf "%s/%s:%s" $registry $repository $tag -}}
{{- else -}}
{{- printf "%s:%s" $repository $tag -}}
{{- end -}}
{{- end -}}

65
00:06:24,000 --> 00:06:30,000
This helper generates the full image name with registry, repository, and tag.

66
00:06:30,000 --> 00:06:36,000
{{- define "financial-rag-agent.podAnnotations" -}}
{{- with .Values.global.podAnnotations }}
{{- toYaml . }}
{{- end }}
{{- with .componentAnnotations }}
{{- toYaml . }}
{{- end }}
{{- end -}}

67
00:06:36,000 --> 00:06:42,000
This helper merges global and component-specific annotations.

68
00:06:42,000 --> 00:06:48,000
{{- define "financial-rag-agent.commonEnv" -}}
- name: APP_ENV
value: {{ .Values.global.environment | default "production" }}
- name: APP_VERSION
value: {{ .Chart.AppVersion }}
- name: POSTGRES_HOST
value: {{ include "financial-rag-agent.fullname" . }}-pgvector
- name: POSTGRES_PORT
value: {{ .Values.pgvector.service.port | quote }}
- name: POSTGRES_DB
value: {{ .Values.pgvector.env.POSTGRES_DB }}
- name: POSTGRES_USER
value: {{ .Values.pgvector.env.POSTGRES_USER }}
- name: POSTGRES_PASSWORD
valueFrom:
secretKeyRef:
name: {{ include "financial-rag-agent.fullname" . }}-secrets
key: postgres-password
- name: REDIS_HOST
value: {{ include "financial-rag-agent.fullname" . }}-redis
- name: REDIS_PORT
value: {{ .Values.redis.service.port | quote }}
- name: REDIS_PASSWORD
valueFrom:
secretKeyRef:
name: {{ include "financial-rag-agent.fullname" . }}-secrets
key: redis-password
- name: LOG_LEVEL
value: {{ .Values.api.env.LOG_LEVEL | default "info" }}
{{- end -}}

69
00:06:48,000 --> 00:06:54,000
These are the common environment variables for all pods.

70
00:06:54,000 --> 00:07:00,000
Now let me explain how these helpers are used in the templates.

71
00:07:00,000 --> 00:07:06,000
In api-deployment.yaml, we use `{{ include "financial-rag-agent.fullname" . }}-api` for the deployment name.
We use `{{ include "financial-rag-agent.labels" . }}` for the labels.
We use `{{ include "financial-rag-agent.image" (dict "global" .Values.global "image" .Values.api.image) }}` for the image.

72
00:07:06,000 --> 00:07:12,000
These helpers ensure consistency across all resources.
If we change the naming convention, we only change it in one place.

73
00:07:12,000 --> 00:07:18,000
Now let's test the helpers. Render the templates with helm template.

74
00:07:18,000 --> 00:07:24,000
[Types: helm template financial-rag ./infrastructure/helm/ --debug 2>&1 | grep -A 5 "image:"]

75
00:07:24,000 --> 00:07:30,000
This shows the rendered image name from the helper.

76
00:07:30,000 --> 00:07:36,000
Now let me recap what we've built in Part 2.

77
00:07:36,000 --> 00:07:42,000
We built the fullname helper. It generates the full name of the release.

78
00:07:42,000 --> 00:07:48,000
We built the chart helper. It generates the chart name and version.

79
00:07:48,000 --> 00:07:54,000
We built the selector labels helper. It generates the labels used by the pod selector.

80
00:07:54,000 --> 00:08:00,000
We built the labels helper. It generates all the labels applied to resources.

81
00:08:00,000 --> 00:08:06,000
We built the image helper. It generates the full image name with registry, repository, and tag.

82
00:08:06,000 --> 00:08:12,000
We built the pod annotations helper. It merges global and component annotations.

83
00:08:12,000 --> 00:08:18,000
We built the common environment variables helper. It provides common env vars for all pods.

84
00:08:18,000 --> 00:08:24,000
These helpers are the foundation of our Helm chart. They keep our templates clean and consistent.

85
00:08:24,000 --> 00:08:30,000
In Part 3, we'll build the namespace and service accounts. These are the identity resources for our application.

86
00:08:30,000 --> 00:08:36,000
Thank you for watching. I'll see you in Part 3.

87
00:08:36,000 --> 00:08:40,000
[End of Part 2]
1
00:00:00,000 --> 00:00:06,000
Welcome back to Phase 8. In Part 3, we build the StatefulSets for pgvector and Redis.

2
00:00:06,000 --> 00:00:12,000
We've built the Deployment for the API and the Agent pool. But those are stateless applications. They can be replaced at any time.

3
00:00:12,000 --> 00:00:18,000
pgvector and Redis are different. They store data. If a pod restarts, we don't want to lose all our vectors or cache data. We need persistent storage.

4
00:00:18,000 --> 00:00:24,000
That's where StatefulSets come in. StatefulSets are designed for stateful applications. They provide stable network identities and persistent storage.

5
00:00:24,000 --> 00:00:30,000
Think of a StatefulSet like a designated parking spot. Each pod gets its own spot. If the pod moves, it comes back to the same spot. The storage follows it.

6
00:00:30,000 --> 00:00:36,000
Open your editor and create `infrastructure/helm/templates/pgvector-statefulset.yaml`.

7
00:00:36,000 --> 00:00:42,000
We'll start with the pgvector StatefulSet. This is our PostgreSQL database with the pgvector extension.

8
00:00:42,000 --> 00:00:48,000
The apiVersion is apps/v1. This is the standard API version for StatefulSets.
[Types: apiVersion: apps/v1]

9
00:00:48,000 --> 00:00:54,000
The kind is StatefulSet. This tells Kubernetes we want a stateful application.
[Types: kind: StatefulSet]

10
00:00:54,000 --> 00:01:00,000
Now let's define the metadata. This is where we name our StatefulSet.
[Types: metadata: name: {{ include "financial-rag-agent.fullname" . }}-pgvector namespace: {{ .Values.namespace }} labels: {{- include "financial-rag-agent.labels" . | nindent 4 }} app.kubernetes.io/component: pgvector]

11
00:01:00,000 --> 00:01:06,000
The name uses the fullname helper. This ensures consistent naming across all components.

12
00:01:06,000 --> 00:01:12,000
Now let's define the spec. This is the core of the StatefulSet.
[Types: spec: serviceName: {{ include "financial-rag-agent.fullname" . }}-pgvector-headless replicas: {{ .Values.pgvector.replicaCount }}]

13
00:01:12,000 --> 00:01:18,000
The serviceName is the headless service name. This provides stable DNS for the StatefulSet pods.

14
00:01:18,000 --> 00:01:24,000
The replicaCount comes from values.yaml. For production, we use 1 replica. For development, we also use 1. pgvector doesn't support horizontal scaling.

15
00:01:24,000 --> 00:01:30,000
Now let's define the selector. This matches the pods managed by this StatefulSet.
[Types: selector: matchLabels: {{- include "financial-rag-agent.selectorLabels" . | nindent 6 }} app.kubernetes.io/component: pgvector]

16
00:01:30,000 --> 00:01:36,000
The selector labels must match the pod template labels. This is how Kubernetes knows which pods belong to this StatefulSet.

17
00:01:36,000 --> 00:01:42,000
Now let's define the pod template.
[Types: template: metadata: labels: {{- include "financial-rag-agent.selectorLabels" . | nindent 8 }} app.kubernetes.io/component: pgvector]

18
00:01:42,000 --> 00:01:48,000
The pod template defines what each pod looks like. The labels match the selector.

19
00:01:48,000 --> 00:01:54,000
Now let's define the pod spec. This is the actual container configuration.
[Types: spec: securityContext: runAsUser: 999 fsGroup: 999]

20
00:01:54,000 --> 00:02:00,000
We run the container as user 999. This is the postgres user. We also set fsGroup to 999 so the volume is writable by the postgres user.

21
00:02:00,000 --> 00:02:06,000
Now let's define the nodeSelector. This tells Kubernetes where to schedule the pod.
[Types: {{- with .Values.global.nodeSelector }} nodeSelector: {{- toYaml . | nindent 8 }} {{- end }}]

22
00:02:06,000 --> 00:02:12,000
The nodeSelector comes from the global values. This is used to schedule pods on specific node groups.

23
00:02:12,000 --> 00:02:18,000
Now let's define the tolerations. This allows the pod to run on nodes with taints.
[Types: {{- with .Values.global.tolerations }} tolerations: {{- toYaml . | nindent 8 }} {{- end }}]

24
00:02:18,000 --> 00:02:24,000
Tolerations are used with taints. They allow pods to schedule on nodes that have specific taints.

25
00:02:24,000 --> 00:02:30,000
Now let's define the container. This is the pgvector container.
[Types: containers: - name: pgvector image: {{ include "financial-rag-agent.image" (dict "global" .Values.global "image" .Values.pgvector.image) }} imagePullPolicy: {{ .Values.global.image.pullPolicy }}]

26
00:02:30,000 --> 00:02:36,000
We use the image helper to build the full image name. The pullPolicy comes from the global values.

27
00:02:36,000 --> 00:02:42,000
Now let's define the ports. PostgreSQL runs on port 5432.
[Types: ports: - name: postgres containerPort: 5432 protocol: TCP]

28
00:02:42,000 --> 00:02:48,000
The port name is used by the service to map to the correct port. This is a standard PostgreSQL port.

29
00:02:48,000 --> 00:02:54,000
Now let's define the environment variables.
[Types: env: {{- range $k, $v := .Values.pgvector.env }} - name: {{ $k }} value: {{ $v | quote }} {{- end }} - name: PGDATA value: /var/lib/postgresql/data/pgdata]

30
00:02:54,000 --> 00:03:00,000
The env values come from the values.yaml file. We also set PGDATA to a subdirectory of the mount path.

31
00:03:00,000 --> 00:03:06,000
Now let's define the envFrom section. This loads secrets from a Secret.
[Types: {{- with .Values.pgvector.envFrom }} envFrom: {{- toYaml . | nindent 12 }} {{- end }}]

32
00:03:06,000 --> 00:03:12,000
The envFrom section loads the POSTGRES_PASSWORD from the financial-rag-secrets Secret.

33
00:03:12,000 --> 00:03:18,000
Now let's define the resources. This controls CPU and memory limits.
[Types: resources: {{- toYaml .Values.pgvector.resources | nindent 12 }}]

34
00:03:18,000 --> 00:03:24,000
The resources come from the values.yaml file. In production, we allocate 2-4 CPU cores and 8-16 GB of memory.

35
00:03:24,000 --> 00:03:30,000
Now let's define the livenessProbe. This checks if the container is alive.
[Types: livenessProbe: {{- toYaml .Values.pgvector.livenessProbe | nindent 12 }}]

36
00:03:30,000 --> 00:03:36,000
The livenessProbe uses pg_isready to check if PostgreSQL is responding. If it fails, Kubernetes restarts the container.

37
00:03:36,000 --> 00:03:42,000
Now let's define the readinessProbe. This checks if the container is ready to receive traffic.
[Types: readinessProbe: {{- toYaml .Values.pgvector.readinessProbe | nindent 12 }}]

38
00:03:42,000 --> 00:03:48,000
The readinessProbe also uses pg_isready. If it fails, Kubernetes stops sending traffic to the pod.

39
00:03:48,000 --> 00:03:54,000
Now let's define the volumeMounts. This mounts the persistent volume.
[Types: volumeMounts: - name: pgdata mountPath: /var/lib/postgresql/data]

40
00:03:54,000 --> 00:04:00,000
The volumeMount maps the pgdata volume to the PostgreSQL data directory.

41
00:04:00,000 --> 00:04:06,000
Now let's define the volumeClaimTemplates. This creates the persistent volume for each pod.
[Types: {{- if .Values.pgvector.persistence.enabled }} volumeClaimTemplates: - metadata: name: pgdata labels: {{- include "financial-rag-agent.labels" . | nindent 10 }} app.kubernetes.io/component: pgvector spec: accessModes: ["ReadWriteOnce"] storageClassName: {{ .Values.pgvector.storage.storageClassName }} resources: requests: storage: {{ .Values.pgvector.storage.size }} {{- end }}]

42
00:04:06,000 --> 00:04:12,000
The volumeClaimTemplates create a PersistentVolumeClaim for each pod. Each pod gets its own PVC. This is how data persists across restarts.

43
00:04:12,000 --> 00:04:18,000
The accessModes is ReadWriteOnce. This means the volume can be mounted by one pod at a time. This is the standard mode for databases.

44
00:04:18,000 --> 00:04:24,000
The storageClassName comes from the values file. In production, we use gp3-iops for better performance.

45
00:04:24,000 --> 00:04:30,000
Now let's define the headless service for pgvector. This provides stable DNS for the StatefulSet.
[Types: --- apiVersion: v1 kind: Service metadata: name: {{ include "financial-rag-agent.fullname" . }}-pgvector-headless namespace: {{ .Values.namespace }} labels: {{- include "financial-rag-agent.labels" . | nindent 4 }} app.kubernetes.io/component: pgvector spec: type: ClusterIP clusterIP: None selector: {{- include "financial-rag-agent.selectorLabels" . | nindent 4 }} app.kubernetes.io/component: pgvector ports: - name: postgres port: {{ .Values.pgvector.service.port }} targetPort: postgres]

46
00:04:30,000 --> 00:04:36,000
The headless service has clusterIP: None. This creates a DNS entry for each pod, but no load balancer. This is used by the StatefulSet for stable network identity.

47
00:04:36,000 --> 00:04:42,000
Now let's define the clusterIP service for pgvector. This is used by the API and Agent pods to connect.
[Types: --- apiVersion: v1 kind: Service metadata: name: {{ include "financial-rag-agent.fullname" . }}-pgvector namespace: {{ .Values.namespace }} labels: {{- include "financial-rag-agent.labels" . | nindent 4 }} app.kubernetes.io/component: pgvector spec: type: ClusterIP selector: {{- include "financial-rag-agent.selectorLabels" . | nindent 4 }} app.kubernetes.io/component: pgvector ports: - name: postgres port: {{ .Values.pgvector.service.port }} targetPort: postgres]

48
00:04:42,000 --> 00:04:48,000
This service provides a stable IP and DNS name for the pgvector pods. The API and Agent use this to connect to the database.

49
00:04:48,000 --> 00:04:54,000
Now let's create the Redis StatefulSet. Open `infrastructure/helm/templates/redis-statefulset.yaml`.

50
00:04:54,000 --> 00:05:00,000
Redis is our cache layer. It provides high-speed data storage for frequently accessed data.

51
00:05:00,000 --> 00:05:06,000
The structure is similar to pgvector. We start with the apiVersion and kind.
[Types: apiVersion: apps/v1 kind: StatefulSet metadata: name: {{ include "financial-rag-agent.fullname" . }}-redis namespace: {{ .Values.namespace }} labels: {{- include "financial-rag-agent.labels" . | nindent 4 }} app.kubernetes.io/component: redis spec: serviceName: {{ include "financial-rag-agent.fullname" . }}-redis-headless replicas: {{ .Values.redis.replicaCount }}]

52
00:05:06,000 --> 00:05:12,000
The serviceName is the headless service name. The replicaCount comes from values.yaml.

53
00:05:12,000 --> 00:05:18,000
Now let's define the selector and pod template.
[Types: selector: matchLabels: {{- include "financial-rag-agent.selectorLabels" . | nindent 6 }} app.kubernetes.io/component: redis template: metadata: labels: {{- include "financial-rag-agent.selectorLabels" . | nindent 8 }} app.kubernetes.io/component: redis spec: securityContext: runAsNonRoot: true runAsUser: 999 fsGroup: 999]

54
00:05:18,000 --> 00:05:24,000
Redis runs as user 999. This is the redis user in the redis image. We set runAsNonRoot to true for security.

55
00:05:24,000 --> 00:05:30,000
Now let's define the container.
[Types: containers: - name: redis image: {{ include "financial-rag-agent.image" (dict "global" .Values.global "image" .Values.redis.image) }} imagePullPolicy: {{ .Values.global.image.pullPolicy }} args: {{- toYaml .Values.redis.args | nindent 12 }}]

56
00:05:30,000 --> 00:05:36,000
The args come from values.yaml. This includes the Redis server arguments like --appendonly yes and --maxmemory.

57
00:05:36,000 --> 00:05:42,000
Now let's define the ports.
[Types: ports: - name: redis containerPort: 6379 protocol: TCP]

58
00:05:42,000 --> 00:05:48,000
Redis runs on port 6379. This is the standard Redis port.

59
00:05:48,000 --> 00:05:54,000
Now let's define the resources.
[Types: resources: {{- toYaml .Values.redis.resources | nindent 12 }}]

60
00:05:54,000 --> 00:06:00,000
The resources come from values.yaml. In production, we allocate 500m CPU and 2-4 GB of memory for Redis.

61
00:06:00,000 --> 00:06:06,000
Now let's define the livenessProbe and readinessProbe.
[Types: livenessProbe: {{- toYaml .Values.redis.livenessProbe | nindent 12 }} readinessProbe: {{- toYaml .Values.redis.readinessProbe | nindent 12 }}]

62
00:06:06,000 --> 00:06:12,000
The probes use redis-cli ping to check if Redis is responding. This is the standard Redis health check.

63
00:06:12,000 --> 00:06:18,000
Now let's define the volumeMounts.
[Types: volumeMounts: - name: redis-data mountPath: /data]

64
00:06:18,000 --> 00:06:24,000
The volumeMount maps the redis-data volume to the Redis data directory.

65
00:06:24,000 --> 00:06:30,000
Now let's define the volumeClaimTemplates for Redis.
[Types: volumeClaimTemplates: - metadata: name: redis-data labels: {{- include "financial-rag-agent.labels" . | nindent 10 }} app.kubernetes.io/component: redis spec: accessModes: ["ReadWriteOnce"] storageClassName: {{ .Values.redis.storage.storageClassName }} resources: requests: storage: {{ .Values.redis.storage.size }}]

66
00:06:30,000 --> 00:06:36,000
Redis uses the same pattern as pgvector. Each pod gets its own PVC for persistent storage.

67
00:06:36,000 --> 00:06:42,000
Now let's define the headless service for Redis.
[Types: --- apiVersion: v1 kind: Service metadata: name: {{ include "financial-rag-agent.fullname" . }}-redis-headless namespace: {{ .Values.namespace }} labels: {{- include "financial-rag-agent.labels" . | nindent 4 }} app.kubernetes.io/component: redis spec: type: ClusterIP clusterIP: None selector: {{- include "financial-rag-agent.selectorLabels" . | nindent 4 }} app.kubernetes.io/component: redis ports: - name: redis port: {{ .Values.redis.service.port }} targetPort: redis]

68
00:06:42,000 --> 00:06:48,000
The headless service provides stable DNS for the Redis StatefulSet.

69
00:06:48,000 --> 00:06:54,000
Now let's define the clusterIP service for Redis.
[Types: --- apiVersion: v1 kind: Service metadata: name: {{ include "financial-rag-agent.fullname" . }}-redis namespace: {{ .Values.namespace }} labels: {{- include "financial-rag-agent.labels" . | nindent 4 }} app.kubernetes.io/component: redis spec: type: ClusterIP selector: {{- include "financial-rag-agent.selectorLabels" . | nindent 4 }} app.kubernetes.io/component: redis ports: - name: redis port: {{ .Values.redis.service.port }} targetPort: redis]

70
00:06:54,000 --> 00:07:00,000
This service provides a stable IP and DNS name for the Redis pods. The API and Agent use this to connect to Redis.

71
00:07:00,000 --> 00:07:06,000
Now let's update the values.yaml file with the pgvector and Redis configurations.

72
00:07:06,000 --> 00:07:12,000
Open `infrastructure/helm/values.yaml` and add the pgvector section.
[Types: pgvector: enabled: true image: repository: pgvector/pgvector tag: "pg16" replicaCount: 1 resources: requests: cpu: "500m" memory: "1Gi" limits: cpu: "2000m" memory: "4Gi" storage: storageClassName: gp3 size: 50Gi service: port: 5432 env: POSTGRES_DB: financial_rag POSTGRES_USER: raguser envFrom: - secretRef: name: financial-rag-secrets persistence: enabled: true livenessProbe: exec: command: ["pg_isready", "-U", "raguser", "-d", "financial_rag"] initialDelaySeconds: 30 periodSeconds: 20 readinessProbe: exec: command: ["pg_isready", "-U", "raguser", "-d", "financial_rag"] initialDelaySeconds: 10 periodSeconds: 10]

73
00:07:12,000 --> 00:07:18,000
The pgvector configuration sets the image, resources, storage, and probes. The POSTGRES_USER is raguser. The password comes from the financial-rag-secrets secret.

74
00:07:18,000 --> 00:07:24,000
Now add the Redis section.
[Types: redis: enabled: true image: repository: redis tag: "7-alpine" replicaCount: 1 resources: requests: cpu: "100m" memory: "256Mi" limits: cpu: "500m" memory: "512Mi" storage: storageClassName: gp3 size: 10Gi service: port: 6379 args: - "--appendonly" - "yes" - "--maxmemory" - "400mb" - "--maxmemory-policy" - "allkeys-lru" livenessProbe: exec: command: ["redis-cli", "ping"] initialDelaySeconds: 10 periodSeconds: 15 readinessProbe: exec: command: ["redis-cli", "ping"] initialDelaySeconds: 5 periodSeconds: 10]

75
00:07:24,000 --> 00:07:30,000
The Redis configuration sets the image, resources, storage, and probes. The args include appendonly for persistence and maxmemory for memory limits.

76
00:07:30,000 --> 00:07:36,000
Now let's test the configuration. Run `helm template infrastructure/helm/ -f infrastructure/helm/values.yaml | kubectl apply --dry-run=client -f -`.

77
00:07:36,000 --> 00:07:42,000
This validates the templates. You should see the pgvector and Redis StatefulSets rendered correctly.

78
00:07:42,000 --> 00:07:48,000
Now let me recap what we've built in Part 3.

79
00:07:48,000 --> 00:07:54,000
We built the pgvector StatefulSet. It has persistent storage, health checks, and resource limits. It uses a headless service for stable DNS.

80
00:07:54,000 --> 00:08:00,000
We built the Redis StatefulSet. It has persistent storage, health checks, and resource limits. It uses AOF persistence for durability.

81
00:08:00,000 --> 00:08:06,000
We updated the values.yaml file with the configuration for both StatefulSets.

82
00:08:06,000 --> 00:08:12,000
In Part 4, we'll build the Deployments for the API and Agent pool.

83
00:08:12,000 --> 00:08:18,000
Thank you for watching. I'll see you in Part 4.

84
00:08:18,000 --> 00:08:22,000
[End of Part 3]
1
00:00:00,000 --> 00:00:06,000
Welcome back to Phase 8. In Part 4, we build the StatefulSets for pgvector and Redis.

2
00:00:06,000 --> 00:00:12,000
Up until now, we've been using Deployments for our stateless components. The API. The Agent. The Ingestion CronJob. All stateless.

3
00:00:12,000 --> 00:00:18,000
But pgvector and Redis are different. They store data. They have state. If a pod restarts, the data must survive.

4
00:00:18,000 --> 00:00:24,000
Think of a Deployment like a disposable cup. You use it once, throw it away, get a new one. Stateless.

5
00:00:24,000 --> 00:00:30,000
Think of a StatefulSet like a reusable water bottle. It has your name on it. Even if you leave the room, your water bottle is still there. When you come back, you get the same one.

6
00:00:30,000 --> 00:00:36,000
StatefulSets provide stable, unique network identifiers. Stable, persistent storage. Ordered, graceful deployment and scaling.

7
00:00:36,000 --> 00:00:42,000
Open your editor and create `infrastructure/helm/templates/pgvector-statefulset.yaml`.

8
00:00:42,000 --> 00:00:48,000
We'll start with the StatefulSet for pgvector. This is our PostgreSQL database with the pgvector extension.

9
00:00:48,000 --> 00:00:54,000
Let me show you the structure before we type it. A StatefulSet has: apiVersion, kind, metadata, spec, and template.

10
00:00:54,000 --> 00:01:00,000
The spec has: serviceName, replicas, selector, and template. The template has: metadata and spec.

11
00:01:00,000 --> 00:01:06,000
The template spec has: containers, volumes, and volumeClaimTemplates. volumeClaimTemplates is unique to StatefulSets. It creates persistent volumes for each pod.

12
00:01:06,000 --> 00:01:12,000
Let's start typing the pgvector StatefulSet. We'll begin with the apiVersion and kind.
[Types: apiVersion: apps/v1]
[Types: kind: StatefulSet]

13
00:01:12,000 --> 00:01:18,000
We use apps/v1 because it's the stable version. StatefulSet was stable in Kubernetes 1.9 and later.

14
00:01:18,000 --> 00:01:24,000
Now the metadata. We need the name and namespace.
[Types: metadata: name: {{ include "financial-rag-agent.fullname" . }}-pgvector namespace: {{ .Values.namespace }} labels: {{- include "financial-rag-agent.labels" . | nindent 4 }} app.kubernetes.io/component: pgvector]

15
00:01:24,000 --> 00:01:30,000
The name uses the fullname helper. This ensures consistent naming across all resources.
The component label identifies this as pgvector. This is used by selectors and policies.

16
00:01:30,000 --> 00:01:36,000
Now the spec section.
[Types: spec: serviceName: {{ include "financial-rag-agent.fullname" . }}-pgvector-headless]

17
00:01:36,000 --> 00:01:42,000
The serviceName must match the headless service name. We'll create this later. It provides stable DNS.

18
00:01:42,000 --> 00:01:48,000
[Types: replicas: {{ .Values.pgvector.replicaCount }}]

19
00:01:48,000 --> 00:01:54,000
The replicas come from values.yaml. In dev it's 1. In prod it's 1.

20
00:01:54,000 --> 00:02:00,000
Now the selector. This must match the labels in the pod template.
[Types: selector: matchLabels: {{- include "financial-rag-agent.selectorLabels" . | nindent 6 }} app.kubernetes.io/component: pgvector]

21
00:02:00,000 --> 00:02:06,000
The selectorLabels helper ensures we select the correct pods. The component label adds specificity.

22
00:02:06,000 --> 00:02:12,000
Now the template. This is the pod definition.
[Types: template: metadata: labels: {{- include "financial-rag-agent.selectorLabels" . | nindent 8 }} app.kubernetes.io/component: pgvector]

23
00:02:12,000 --> 00:02:18,000
The pod labels must match the selector. This is how the StatefulSet knows which pods it owns.

24
00:02:18,000 --> 00:02:24,000
Now the pod spec. We start with securityContext.
[Types: spec: securityContext: runAsUser: 999 fsGroup: 999]

25
00:02:24,000 --> 00:02:30,000
The PostgreSQL image runs as user 999. We match that for file permissions. This ensures PostgreSQL can write to the volume.

26
00:02:30,000 --> 00:02:36,000
Now the nodeSelector. This pins pods to specific node groups.
[Types: {{- with .Values.global.nodeSelector }} nodeSelector: {{- toYaml . | nindent 8 }} {{- end }}]

27
00:02:36,000 --> 00:02:42,000
The nodeSelector controls where pods run. We use this for capacity planning and cost optimization.

28
00:02:42,000 --> 00:02:48,000
Now the tolerations. This allows pods to run on tainted nodes.
[Types: {{- with .Values.global.tolerations }} tolerations: {{- toYaml . | nindent 8 }} {{- end }}]

29
00:02:48,000 --> 00:02:54,000
Tolerations work with taints. They allow pods to schedule on nodes that have specific taints.

30
00:02:54,000 --> 00:03:00,000
Now the containers section.
[Types: containers: - name: pgvector image: {{ include "financial-rag-agent.image" (dict "global" .Values.global "image" .Values.pgvector.image) }} imagePullPolicy: {{ .Values.global.image.pullPolicy }}]

31
00:03:00,000 --> 00:03:06,000
The image uses the helper function. It combines the registry and repository. The pullPolicy comes from global settings.

32
00:03:06,000 --> 00:03:12,000
Now the ports.
[Types: ports: - name: postgres containerPort: 5432 protocol: TCP]

33
00:03:12,000 --> 00:03:18,000
PostgreSQL listens on port 5432. This is the standard port. We expose it for service routing.

34
00:03:18,000 --> 00:03:24,000
Now the environment variables.
[Types: env: {{- range $k, $v := .Values.pgvector.env }} - name: {{ $k }} value: {{ $v | quote }} {{- end }}]

35
00:03:24,000 --> 00:03:30,000
The env variables come from values.yaml. They include POSTGRES_USER and POSTGRES_DB. The password comes from a secret.

36
00:03:30,000 --> 00:03:36,000
[Types: {{- with .Values.pgvector.envFrom }} envFrom: {{- toYaml . | nindent 12 }} {{- end }}]

37
00:03:36,000 --> 00:03:42,000
envFrom allows loading variables from secrets or config maps. We use it for the database password.

38
00:03:42,000 --> 00:03:48,000
Now the resources.
[Types: resources: {{- toYaml .Values.pgvector.resources | nindent 12 }}]

39
00:03:48,000 --> 00:03:54,000
Resources include CPU and memory requests and limits. In prod, we give pgvector 4 cores and 16GB of memory.

40
00:03:54,000 --> 00:04:00,000
Now the liveness and readiness probes.
[Types: livenessProbe: {{- toYaml .Values.pgvector.livenessProbe | nindent 12 }} readinessProbe: {{- toYaml .Values.pgvector.readinessProbe | nindent 12 }}]

41
00:04:00,000 --> 00:04:06,000
The probes use pg_isready. This is the official PostgreSQL readiness check. It ensures the database is accepting connections.

42
00:04:06,000 --> 00:04:12,000
Now the volumeMounts.
[Types: volumeMounts: - name: pgdata mountPath: /var/lib/postgresql/data]

43
00:04:12,000 --> 00:04:18,000
The pgdata volume mounts to the PostgreSQL data directory. This is where all database files live.

44
00:04:18,000 --> 00:04:24,000
Now the volumeClaimTemplates. This is unique to StatefulSets. It creates a persistent volume for each pod.
[Types: volumeClaimTemplates: - metadata: name: pgdata labels: {{- include "financial-rag-agent.labels" . | nindent 10 }} app.kubernetes.io/component: pgvector spec: accessModes: ["ReadWriteOnce"] storageClassName: {{ .Values.pgvector.storage.storageClassName }} resources: requests: storage: {{ .Values.pgvector.storage.size }}]

45
00:04:24,000 --> 00:04:30,000
The volumeClaimTemplate creates a PVC for each replica. In a StatefulSet with 1 replica, it creates 1 PVC. With 3 replicas, it creates 3 PVCs.

46
00:04:30,000 --> 00:04:36,000
"ReadWriteOnce" means the volume can be mounted by only one pod. This is the standard for databases.

47
00:04:36,000 --> 00:04:42,000
The storageClassName is "gp3" in development and "gp3-iops" in production. This controls the underlying storage type.

48
00:04:42,000 --> 00:04:48,000
Now let's create the headless service for pgvector.
[Types: --- apiVersion: v1 kind: Service metadata: name: {{ include "financial-rag-agent.fullname" . }}-pgvector-headless namespace: {{ .Values.namespace }} labels: {{- include "financial-rag-agent.labels" . | nindent 4 }} app.kubernetes.io/component: pgvector spec: type: ClusterIP clusterIP: None selector: {{- include "financial-rag-agent.selectorLabels" . | nindent 4 }} app.kubernetes.io/component: pgvector ports: - name: postgres port: {{ .Values.pgvector.service.port }} targetPort: postgres]

49
00:04:48,000 --> 00:04:54,000
A headless service has no cluster IP. It provides DNS entries for each pod. This is essential for StatefulSets.

50
00:04:54,000 --> 00:05:00,000
The DNS format is pod-name.service-name.namespace.svc.cluster.local. This is how pods find each other.

51
00:05:00,000 --> 00:05:06,000
Now let's create the regular cluster IP service. This is used by the API and Agent pods.
[Types: --- apiVersion: v1 kind: Service metadata: name: {{ include "financial-rag-agent.fullname" . }}-pgvector namespace: {{ .Values.namespace }} labels: {{- include "financial-rag-agent.labels" . | nindent 4 }} app.kubernetes.io/component: pgvector spec: type: ClusterIP selector: {{- include "financial-rag-agent.selectorLabels" . | nindent 4 }} app.kubernetes.io/component: pgvector ports: - name: postgres port: {{ .Values.pgvector.service.port }} targetPort: postgres]

52
00:05:06,000 --> 00:05:12,000
This service routes traffic to the pgvector pod. It's a regular ClusterIP service. The API and Agent use this to connect.

53
00:05:12,000 --> 00:05:18,000
Now let's build the Redis StatefulSet. Open `infrastructure/helm/templates/redis-statefulset.yaml`.

54
00:05:18,000 --> 00:05:24,000
Redis also stores data. It's a cache, but it has state. We need it to survive pod restarts.

55
00:05:24,000 --> 00:05:30,000
The structure is similar to pgvector. apiVersion, kind, metadata, spec, and template.

56
00:05:30,000 --> 00:05:36,000
Let's start typing. The apiVersion and kind.
[Types: apiVersion: apps/v1]
[Types: kind: StatefulSet]

57
00:05:36,000 --> 00:05:42,000
Now the metadata.
[Types: metadata: name: {{ include "financial-rag-agent.fullname" . }}-redis namespace: {{ .Values.namespace }} labels: {{- include "financial-rag-agent.labels" . | nindent 4 }} app.kubernetes.io/component: redis]

58
00:05:42,000 --> 00:05:48,000
The name uses the fullname helper. The component label identifies this as redis.

59
00:05:48,000 --> 00:05:54,000
Now the spec.
[Types: spec: serviceName: {{ include "financial-rag-agent.fullname" . }}-redis-headless replicas: {{ .Values.redis.replicaCount }}]

60
00:05:54,000 --> 00:06:00,000
The serviceName must match the headless service. The replicas come from values.yaml.

61
00:06:00,000 --> 00:06:06,000
Now the selector.
[Types: selector: matchLabels: {{- include "financial-rag-agent.selectorLabels" . | nindent 6 }} app.kubernetes.io/component: redis]

62
00:06:06,000 --> 00:06:12,000
The selector must match the pod labels. This is how the StatefulSet owns its pods.

63
00:06:12,000 --> 00:06:18,000
Now the template.
[Types: template: metadata: labels: {{- include "financial-rag-agent.selectorLabels" . | nindent 8 }} app.kubernetes.io/component: redis]

64
00:06:18,000 --> 00:06:24,000
The pod labels match the selector. This is the identity of each Redis pod.

65
00:06:24,000 --> 00:06:30,000
Now the pod spec.
[Types: spec: securityContext: runAsNonRoot: true runAsUser: 999 fsGroup: 999]

66
00:06:30,000 --> 00:06:36,000
Redis runs as user 999. We match that for file permissions. runAsNonRoot ensures the container never runs as root.

67
00:06:36,000 --> 00:06:42,000
Now the containers section.
[Types: containers: - name: redis image: {{ include "financial-rag-agent.image" (dict "global" .Values.global "image" .Values.redis.image) }} imagePullPolicy: {{ .Values.global.image.pullPolicy }}]

68
00:06:42,000 --> 00:06:48,000
The image uses the helper function. The pullPolicy comes from global settings.

69
00:06:48,000 --> 00:06:54,000
Now the command. Redis takes command-line arguments.
[Types: args: {{- toYaml .Values.redis.args | nindent 12 }}]

70
00:06:54,000 --> 00:07:00,000
The args come from values.yaml. They include --appendonly yes for persistence and --maxmemory for memory limits.

71
00:07:00,000 --> 00:07:06,000
Now the ports.
[Types: ports: - name: redis containerPort: 6379 protocol: TCP]

72
00:07:06,000 --> 00:07:12,000
Redis listens on port 6379. This is the standard port.

73
00:07:12,000 --> 00:07:18,000
Now the resources.
[Types: resources: {{- toYaml .Values.redis.resources | nindent 12 }}]

74
00:07:18,000 --> 00:07:24,000
In prod, Redis gets 1 CPU and 4GB of memory. This is enough for a large cache.

75
00:07:24,000 --> 00:07:30,000
Now the probes.
[Types: livenessProbe: {{- toYaml .Values.redis.livenessProbe | nindent 12 }} readinessProbe: {{- toYaml .Values.redis.readinessProbe | nindent 12 }}]

76
00:07:30,000 --> 00:07:36,000
Redis uses redis-cli ping for health checks. This is the standard Redis health check.

77
00:07:36,000 --> 00:07:42,000
Now the volumeMounts.
[Types: volumeMounts: - name: redis-data mountPath: /data]

78
00:07:42,000 --> 00:07:48,000
Redis stores data in /data. This includes the AOF and RDB files.

79
00:07:48,000 --> 00:07:54,000
Now the volumeClaimTemplates.
[Types: volumeClaimTemplates: - metadata: name: redis-data labels: {{- include "financial-rag-agent.labels" . | nindent 10 }} app.kubernetes.io/component: redis spec: accessModes: ["ReadWriteOnce"] storageClassName: {{ .Values.redis.storage.storageClassName }} resources: requests: storage: {{ .Values.redis.storage.size }}]

80
00:07:54,000 --> 00:08:00,000
This creates a persistent volume for Redis data. In prod, this is 50GB. This stores the cache.

81
00:08:00,000 --> 00:08:06,000
Now let's create the headless service for Redis.
[Types: --- apiVersion: v1 kind: Service metadata: name: {{ include "financial-rag-agent.fullname" . }}-redis-headless namespace: {{ .Values.namespace }} labels: {{- include "financial-rag-agent.labels" . | nindent 4 }} app.kubernetes.io/component: redis spec: type: ClusterIP clusterIP: None selector: {{- include "financial-rag-agent.selectorLabels" . | nindent 4 }} app.kubernetes.io/component: redis ports: - name: redis port: {{ .Values.redis.service.port }} targetPort: redis]

82
00:08:06,000 --> 00:08:12,000
This headless service provides stable DNS for each Redis pod.

83
00:08:12,000 --> 00:08:18,000
Now let's create the regular cluster IP service for Redis.
[Types: --- apiVersion: v1 kind: Service metadata: name: {{ include "financial-rag-agent.fullname" . }}-redis namespace: {{ .Values.namespace }} labels: {{- include "financial-rag-agent.labels" . | nindent 4 }} app.kubernetes.io/component: redis spec: type: ClusterIP selector: {{- include "financial-rag-agent.selectorLabels" . | nindent 4 }} app.kubernetes.io/component: redis ports: - name: redis port: {{ .Values.redis.service.port }} targetPort: redis]

84
00:08:18,000 --> 00:08:24,000
This service routes traffic to the Redis pod. The API and Agent use this for caching.

85
00:08:24,000 --> 00:08:30,000
Now let me explain the persistence strategy. Both pgvector and Redis use PVCs. The PVCs are backed by EBS volumes in AWS.

86
00:08:30,000 --> 00:08:36,000
When a pod restarts, the PVC remains. The new pod attaches to the same PVC. The data survives.

87
00:08:36,000 --> 00:08:42,000
This is the key benefit of StatefulSets. Data persistence. Stable network identity. Ordered deployment.

88
00:08:42,000 --> 00:08:48,000
Now let me explain the storage classes. In development, we use gp3. It's general purpose SSD. In production, we use gp3-iops. It's provisioned IOPS for high performance.

89
00:08:48,000 --> 00:08:54,000
Let me recap what we've built in Part 4.

90
00:08:54,000 --> 00:09:00,000
We built the pgvector StatefulSet. It has a PVC for data persistence. It has a headless service for stable DNS. It has a cluster IP service for routing.

91
00:09:00,000 --> 00:09:06,000
We built the Redis StatefulSet. It has a PVC for data persistence. It has a headless service for stable DNS. It has a cluster IP service for routing.

92
00:09:06,000 --> 00:09:12,000
We configured storage classes. gp3 for development. gp3-iops for production.

93
00:09:12,000 --> 00:09:18,000
In Part 5, we'll build the Deployments for the API and Agent.

94
00:09:18,000 --> 00:09:24,000
Thank you for watching. I'll see you in Part 5.

95
00:09:24,000 --> 00:09:28,000
[End of Part 4]

1
00:00:00,000 --> 00:00:06,000
Welcome back to Phase 8. In Part 5, we build the Deployments and Horizontal Pod Autoscalers for our API and Agent services.

2
00:00:06,000 --> 00:00:12,000
A Deployment is the Kubernetes resource that manages your application pods. It handles rolling updates, scaling, and self-healing. Think of it as the manager that keeps your containers running.

3
00:00:12,000 --> 00:00:18,000
A Horizontal Pod Autoscaler automatically scales your pods based on CPU and memory usage. When traffic increases, it adds more pods. When traffic decreases, it removes pods.

4
00:00:18,000 --> 00:00:24,000
Open your editor and create `infrastructure/helm/templates/api-deployment.yaml`.

5
00:00:24,000 --> 00:00:30,000
We'll start with the API Deployment. This is a production-grade deployment with all the security and reliability features we need.

6
00:00:30,000 --> 00:00:36,000
We'll use the if statement at the top. This checks if the API is enabled in values.yaml.
[Types: {{- if .Values.api.enabled }}]

7
00:00:36,000 --> 00:00:42,000
The --- separator tells Kubernetes this is a new YAML document. It's required when you have multiple resources in one file.
[Types: ---]

8
00:00:42,000 --> 00:00:48,000
We set the apiVersion for the Deployment. We use apps/v1, which is the stable version for Deployments.
[Types: apiVersion: apps/v1]

9
00:00:48,000 --> 00:00:54,000
We set the kind to Deployment. This tells Kubernetes we're creating a Deployment resource.
[Types: kind: Deployment]

10
00:00:54,000 --> 00:01:00,000
We set the name using the fullname helper. This ensures consistent naming across all resources.
[Types: metadata: name: {{ include "financial-rag-agent.fullname" . }}-api]

11
00:01:00,000 --> 00:01:06,000
We set the namespace from the values. This allows deploying to different environments.
[Types: namespace: {{ .Values.namespace }}]

12
00:01:06,000 --> 00:01:12,000
We add labels to the metadata. This helps identify and select resources.
[Types: labels: {{- include "financial-rag-agent.labels" . | nindent 4 }} app.kubernetes.io/component: api]

13
00:01:12,000 --> 00:01:18,000
Now we define the spec. This is the desired state of the Deployment.
[Types: spec:]

14
00:01:18,000 --> 00:01:24,000
We set the number of replicas from values. This is the desired number of pods.
[Types: replicas: {{ .Values.api.replicaCount }}]

15
00:01:24,000 --> 00:01:30,000
We define the selector. This matches the pods that this Deployment manages.
[Types: selector: matchLabels: {{- include "financial-rag-agent.selectorLabels" . | nindent 6 }} app.kubernetes.io/component: api]

16
00:01:30,000 --> 00:01:36,000
Now we define the strategy. This controls how rolling updates work.
[Types: strategy: type: RollingUpdate rollingUpdate: maxUnavailable: 1 maxSurge: 2]

17
00:01:36,000 --> 00:01:42,000
maxUnavailable: 1 means only one pod can be unavailable during the update.
maxSurge: 2 means two additional pods can be created during the update.

18
00:01:42,000 --> 00:01:48,000
Now we define the pod template. This is the blueprint for each pod.
[Types: template: metadata: labels: {{- include "financial-rag-agent.selectorLabels" . | nindent 8 }} app.kubernetes.io/component: api]

19
00:01:48,000 --> 00:01:54,000
We add pod annotations for Prometheus scraping.
[Types: annotations: prometheus.io/scrape: "true" prometheus.io/port: "8000"]

20
00:01:54,000 --> 00:02:00,000
Now we define the pod spec. This is the configuration for the pod.
[Types: spec: serviceAccountName: {{ include "financial-rag-agent.fullname" . }}-api]

21
00:02:00,000 --> 00:02:06,000
We set the security context at the pod level. This runs the pod as a non-root user.
[Types: securityContext: runAsNonRoot: true runAsUser: 1000 fsGroup: 1000]

22
00:02:06,000 --> 00:02:12,000
Now we define the container. This is the main API container.
[Types: containers: - name: api]

23
00:02:12,000 --> 00:02:18,000
We set the image using the image helper. This builds the full image URL with the tag.
[Types: image: {{ include "financial-rag-agent.image" (dict "global" .Values.global "image" .Values.api.image) }}]

24
00:02:18,000 --> 00:02:24,000
We set the image pull policy from values. This controls when images are pulled.
[Types: imagePullPolicy: {{ .Values.global.image.pullPolicy }}]

25
00:02:24,000 --> 00:02:30,000
We define the container port. This is where the application listens.
[Types: ports: - name: http containerPort: 8000 protocol: TCP]

26
00:02:30,000 --> 00:02:36,000
Now we define the environment variables. These are passed from values.
[Types: env: {{- range $k, $v := .Values.api.env }} - name: {{ $k }} value: {{ $v | quote }} {{- end }}]

27
00:02:36,000 --> 00:02:42,000
We add envFrom for secrets. This injects secrets from a Secret object.
[Types: {{- with .Values.api.envFrom }} envFrom: {{- toYaml . | nindent 12 }} {{- end }}]

28
00:02:42,000 --> 00:02:48,000
We set the resource requests and limits. This is essential for the HPA to work.
[Types: resources: {{- toYaml .Values.api.resources | nindent 12 }}]

29
00:02:48,000 --> 00:02:54,000
We define the liveness probe. This checks if the container is still running.
[Types: livenessProbe: {{- toYaml .Values.api.livenessProbe | nindent 12 }}]

30
00:02:54,000 --> 00:03:00,000
We define the readiness probe. This checks if the container is ready to receive traffic.
[Types: readinessProbe: {{- toYaml .Values.api.readinessProbe | nindent 12 }}]

31
00:03:00,000 --> 00:03:06,000
Now we set the container security context. This is the principle of least privilege.
[Types: securityContext: allowPrivilegeEscalation: false readOnlyRootFilesystem: true capabilities: drop: ["ALL"]]

32
00:03:06,000 --> 00:03:12,000
We define volume mounts. The tmp volume is writable for temporary files.
[Types: volumeMounts: - name: tmp mountPath: /tmp]

33
00:03:12,000 --> 00:03:18,000
We define the volumes at the pod level. The tmp volume is an emptyDir.
[Types: volumes: - name: tmp emptyDir: {}]

34
00:03:18,000 --> 00:03:24,000
Now we close the if statement.
[Types: {{- end }}]

35
00:03:24,000 --> 00:03:30,000
Now let's create the Agent Deployment. Open `infrastructure/helm/templates/agent-deployment.yaml`.

36
00:03:30,000 --> 00:03:36,000
The Agent Deployment is similar to the API Deployment. But it has different resource requirements and uses a different port.

37
00:03:36,000 --> 00:03:42,000
[Types: {{- if .Values.agentPool.enabled }} --- apiVersion: apps/v1 kind: Deployment metadata: name: {{ include "financial-rag-agent.fullname" . }}-agent namespace: {{ .Values.namespace }} labels: {{- include "financial-rag-agent.labels" . | nindent 4 }} app.kubernetes.io/component: agent spec: replicas: {{ .Values.agentPool.replicaCount }} selector: matchLabels: {{- include "financial-rag-agent.selectorLabels" . | nindent 6 }} app.kubernetes.io/component: agent strategy: type: RollingUpdate rollingUpdate: maxUnavailable: 1 maxSurge: 2 template: metadata: labels: {{- include "financial-rag-agent.selectorLabels" . | nindent 8 }} app.kubernetes.io/component: agent annotations: prometheus.io/scrape: "true" prometheus.io/port: "8001" spec: serviceAccountName: {{ include "financial-rag-agent.fullname" . }}-agent securityContext: runAsNonRoot: true runAsUser: 1000 fsGroup: 1000 containers: - name: agent image: {{ include "financial-rag-agent.image" (dict "global" .Values.global "image" .Values.agentPool.image) }} imagePullPolicy: {{ .Values.global.image.pullPolicy }} ports: - name: health containerPort: 8001 protocol: TCP env: {{- range $k, $v := .Values.agentPool.env }} - name: {{ $k }} value: {{ $v | quote }} {{- end }} {{- with .Values.agentPool.envFrom }} envFrom: {{- toYaml . | nindent 12 }} {{- end }} resources: {{- toYaml .Values.agentPool.resources | nindent 12 }} livenessProbe: {{- toYaml .Values.agentPool.livenessProbe | nindent 12 }} readinessProbe: {{- toYaml .Values.agentPool.readinessProbe | nindent 12 }} securityContext: allowPrivilegeEscalation: false readOnlyRootFilesystem: true capabilities: drop: ["ALL"] volumeMounts: - name: tmp mountPath: /tmp - name: model-cache mountPath: /app/.cache volumes: - name: tmp emptyDir: {} - name: model-cache emptyDir: medium: Memory sizeLimit: 500Mi {{- end }}]

38
00:03:42,000 --> 00:03:48,000
The Agent uses port 8001 for health checks. It also mounts a model-cache volume in memory for faster model loading.

39
00:03:48,000 --> 00:03:54,000
Now let's create the API HPA. Open `infrastructure/helm/templates/api-hpa.yaml`.

40
00:03:54,000 --> 00:04:00,000
The HPA automatically scales the API Deployment based on CPU and memory usage.

41
00:04:00,000 --> 00:04:06,000
[Types: {{- if and .Values.api.enabled .Values.api.hpa.enabled }} --- apiVersion: autoscaling/v2 kind: HorizontalPodAutoscaler metadata: name: {{ include "financial-rag-agent.fullname" . }}-api namespace: {{ .Values.namespace }} labels: {{- include "financial-rag-agent.labels" . | nindent 4 }} app.kubernetes.io/component: api spec: scaleTargetRef: apiVersion: apps/v1 kind: Deployment name: {{ include "financial-rag-agent.fullname" . }}-api minReplicas: {{ .Values.api.hpa.minReplicas }} maxReplicas: {{ .Values.api.hpa.maxReplicas }} metrics: - type: Resource resource: name: cpu target: type: Utilization averageUtilization: {{ .Values.api.hpa.targetCPUUtilizationPercentage }} - type: Resource resource: name: memory target: type: Utilization averageUtilization: {{ .Values.api.hpa.targetMemoryUtilizationPercentage }} behavior: scaleDown: stabilizationWindowSeconds: 300 policies: - type: Pods value: 2 periodSeconds: 120 scaleUp: stabilizationWindowSeconds: 60 policies: - type: Pods value: 4 periodSeconds: 60 {{- end }}]

42
00:04:06,000 --> 00:04:12,000
The API HPA scales based on CPU and memory usage. The target CPU utilization is 70%. The target memory utilization is 80%.

43
00:04:12,000 --> 00:04:18,000
The scaleDown behavior has a 5-minute stabilization window. This prevents rapid scaling down.
The scaleUp behavior has a 1-minute stabilization window. This allows quick scaling up.

44
00:04:18,000 --> 00:04:24,000
Now let's create the Agent HPA. Open `infrastructure/helm/templates/agent-hpa.yaml`.

45
00:04:24,000 --> 00:04:30,000
The Agent HPA has lower thresholds because agent pods are CPU-spiky during LLM inference.

46
00:04:30,000 --> 00:04:36,000
[Types: {{- if and .Values.agentPool.enabled .Values.agentPool.hpa.enabled }} --- apiVersion: autoscaling/v2 kind: HorizontalPodAutoscaler metadata: name: {{ include "financial-rag-agent.fullname" . }}-agent namespace: {{ .Values.namespace }} labels: {{- include "financial-rag-agent.labels" . | nindent 4 }} app.kubernetes.io/component: agent spec: scaleTargetRef: apiVersion: apps/v1 kind: Deployment name: {{ include "financial-rag-agent.fullname" . }}-agent minReplicas: {{ .Values.agentPool.hpa.minReplicas }} maxReplicas: {{ .Values.agentPool.hpa.maxReplicas }} metrics: - type: Resource resource: name: cpu target: type: Utilization averageUtilization: {{ .Values.agentPool.hpa.targetCPUUtilizationPercentage }} - type: Resource resource: name: memory target: type: Utilization averageUtilization: {{ .Values.agentPool.hpa.targetMemoryUtilizationPercentage }} behavior: scaleDown: stabilizationWindowSeconds: 600 policies: - type: Pods value: 1 periodSeconds: 180 scaleUp: stabilizationWindowSeconds: 30 policies: - type: Pods value: 5 periodSeconds: 60 {{- end }}]

47
00:04:36,000 --> 00:04:42,000
The Agent HPA has a 10-minute scale-down stabilization window. This is because agent jobs must drain completely before scaling down.

48
00:04:42,000 --> 00:04:48,000
The scale-up behavior is more aggressive. It can add up to 5 pods per minute when traffic spikes.

49
00:04:48,000 --> 00:04:54,000
Now let me recap what we've built in Part 5.

50
00:04:54,000 --> 00:05:00,000
We built the API Deployment. It runs the FastAPI application with proper security contexts and resource limits.

51
00:05:00,000 --> 00:05:06,000
We built the Agent Deployment. It runs the agent pool with a memory-based model cache for faster LLM inference.

52
00:05:06,000 --> 00:05:12,000
We built the API HPA. It scales the API based on CPU and memory usage with a 5-minute scale-down window.

53
00:05:12,000 --> 00:05:18,000
We built the Agent HPA. It scales the agent pool with lower thresholds and a 10-minute scale-down window.

54
00:05:18,000 --> 00:05:24,000
In Part 6, we'll build the CronJob for ingestion and the ALB Ingress for external traffic.

55
00:05:24,000 --> 00:05:30,000
Thank you for watching. I'll see you in Part 6.

56
00:05:30,000 --> 00:05:34,000
[End of Part 5]

1
00:00:00,000 --> 00:00:06,000
Welcome back to Phase 8. In Part 6, we build the Agent Pool deployment and its Horizontal Pod Autoscaler.

2
00:00:06,000 --> 00:00:12,000
The Agent Pool is where the intelligence lives. It runs the LLM inference, executes tool calls, and performs the reasoning that makes our RAG system intelligent.

3
00:00:12,000 --> 00:00:18,000
Think of the Agent Pool as your team of analysts. When a query comes in, one analyst picks it up. They research, analyze, and return a report.

4
00:00:18,000 --> 00:00:24,000
As more queries arrive, you need more analysts. When queries slow down, you can scale back. That's exactly what the HPA does.

5
00:00:24,000 --> 00:00:30,000
Open your editor and create `infrastructure/helm/templates/agent-deployment.yaml`.

6
00:00:30,000 --> 00:00:36,000
We'll start with the conditional block. This ensures the agent is only created if enabled.
[Types: {{- if .Values.agentPool.enabled }}]

7
00:00:36,000 --> 00:00:42,000
The separator ensures YAML formatting is correct between multiple resources.
[Types: ---]

8
00:00:42,000 --> 00:00:48,000
Now let's define the Deployment resource.
[Types: apiVersion: apps/v1]

9
00:00:48,000 --> 00:00:54,000
We use apps/v1 for Deployments. This is the stable version since Kubernetes 1.9.

10
00:00:54,000 --> 00:01:00,000
Now the kind.
[Types: kind: Deployment]

11
00:01:00,000 --> 00:01:06,000
Deployment manages a set of identical pods. It handles rollouts, rollbacks, and scaling.

12
00:01:06,000 --> 00:01:12,000
Now the metadata section.
[Types: metadata: name: {{ include "financial-rag-agent.fullname" . }}-agent]

13
00:01:12,000 --> 00:01:18,000
The fullname helper generates a consistent name for all resources. The -agent suffix identifies this as the agent deployment.

14
00:01:18,000 --> 00:01:24,000
[Types: namespace: {{ .Values.namespace }}]

15
00:01:24,000 --> 00:01:30,000
The namespace is defined in values.yaml. This ensures all resources are in the same namespace.

16
00:01:30,000 --> 00:01:36,000
Now the labels.
[Types: labels: {{- include "financial-rag-agent.labels" . | nindent 4 }} app.kubernetes.io/component: agent]

17
00:01:36,000 --> 00:01:42,000
The labels helper adds standard labels like app.kubernetes.io/name and app.kubernetes.io/instance. We add component: agent for service selection.

18
00:01:42,000 --> 00:01:48,000
Now the spec section. This defines the desired state.
[Types: spec: replicas: {{ .Values.agentPool.replicaCount }}]

19
00:01:48,000 --> 00:01:54,000
The replica count is from values.yaml. In production, this is 5. In development, it's 2.

20
00:01:54,000 --> 00:02:00,000
Now the selector. This determines which pods this Deployment manages.
[Types: selector: matchLabels: {{- include "financial-rag-agent.selectorLabels" . | nindent 6 }} app.kubernetes.io/component: agent]

21
00:02:00,000 --> 00:02:06,000
The selector must match the labels on the pod template. This connects the Deployment to its pods.

22
00:02:06,000 --> 00:02:12,000
Now the strategy. This defines how updates are performed.
[Types: strategy: type: RollingUpdate rollingUpdate: maxUnavailable: 1 maxSurge: 2]

23
00:02:12,000 --> 00:02:18,000
RollingUpdate ensures no downtime during updates. maxUnavailable: 1 means only one pod can be down at a time. maxSurge: 2 means we can create up to 2 extra pods during the update.

24
00:02:18,000 --> 00:02:24,000
Now the template section. This defines the pod that will be created.
[Types: template:]

25
00:02:24,000 --> 00:02:30,000
The metadata for the pod.
[Types: metadata: labels: {{- include "financial-rag-agent.selectorLabels" . | nindent 8 }} app.kubernetes.io/component: agent {{- with .Values.global.podLabels }} {{- toYaml . | nindent 8 }} {{- end }}]

26
00:02:30,000 --> 00:02:36,000
The selectorLabels match the selector above. The podLabels allow custom labels from values.

27
00:02:36,000 --> 00:02:42,000
Now the annotations.
[Types: annotations: {{- include "financial-rag-agent.podAnnotations" (dict "Values" .Values "componentAnnotations" .Values.agentPool.podAnnotations) | nindent 8 }}]

28
00:02:42,000 --> 00:02:48,000
The podAnnotations helper merges global and component-specific annotations. This is used for Prometheus scraping and Istio injection.

29
00:02:48,000 --> 00:02:54,000
Now the pod spec.
[Types: spec: serviceAccountName: {{ include "financial-rag-agent.fullname" . }}-agent]

30
00:02:54,000 --> 00:03:00,000
The service account is used for RBAC and IRSA. We'll create this in a separate file.

31
00:03:00,000 --> 00:03:06,000
Now the security context. This is our security baseline.
[Types: securityContext: runAsNonRoot: true runAsUser: 1000 fsGroup: 1000]

32
00:03:06,000 --> 00:03:12,000
runAsNonRoot: true prevents the container from running as root. runAsUser: 1000 runs as user 1000. fsGroup: 1000 sets the file system group.

33
00:03:12,000 --> 00:03:18,000
These are the same security settings we used in Phase 7. Consistency is key.

34
00:03:18,000 --> 00:03:24,000
Now the node selector.
[Types: {{- with .Values.global.nodeSelector }} nodeSelector: {{- toYaml . | nindent 8 }} {{- end }}]

35
00:03:24,000 --> 00:03:30,000
Node selector schedules pods on specific nodes. In production, we use nodes with the role: application label.

36
00:03:30,000 --> 00:03:36,000
Now the tolerations.
[Types: {{- with .Values.global.tolerations }} tolerations: {{- toYaml . | nindent 8 }} {{- end }}]

37
00:03:36,000 --> 00:03:42,000
Tolerations allow pods to schedule on nodes with specific taints. In production, we tolerate the dedicated=application taint.

38
00:03:42,000 --> 00:03:48,000
Now the affinity.
[Types: {{- with .Values.global.affinity }} affinity: {{- toYaml . | nindent 8 }} {{- end }}]

39
00:03:48,000 --> 00:03:54,000
Affinity controls scheduling preferences. We use podAntiAffinity to spread pods across nodes.

40
00:03:54,000 --> 00:04:00,000
Now the containers section.
[Types: containers: - name: agent]

41
00:04:00,000 --> 00:04:06,000
The container name is agent. This identifies the container in logs and metrics.

42
00:04:06,000 --> 00:04:12,000
Now the image.
[Types: image: {{ include "financial-rag-agent.image" (dict "global" .Values.global "image" .Values.agentPool.image) }}]

43
00:04:12,000 --> 00:04:18,000
The image helper builds the full image name. It combines the registry, repository, and tag.

44
00:04:18,000 --> 00:04:24,000
[Types: imagePullPolicy: {{ .Values.global.image.pullPolicy }}]

45
00:04:24,000 --> 00:04:30,000
imagePullPolicy determines when the image is pulled. In production, it's Always. In development, it's IfNotPresent.

46
00:04:30,000 --> 00:04:36,000
Now the ports.
[Types: ports: - name: health containerPort: 8001 protocol: TCP]

47
00:04:36,000 --> 00:04:42,000
The agent exposes port 8001 for health checks. The API talks to the agent on this port.

48
00:04:42,000 --> 00:04:48,000
Now the environment variables.
[Types: env: {{- range $k, $v := .Values.agentPool.env }} - name: {{ $k }} value: {{ $v | quote }} {{- end }}]

49
00:04:48,000 --> 00:04:54,000
The env variables are from values.yaml. These include AGENT_CONCURRENCY and LOG_LEVEL.

50
00:04:54,000 --> 00:05:00,000
[Types: {{- with .Values.agentPool.envFrom }} envFrom: {{- toYaml . | nindent 12 }} {{- end }}]

51
00:05:00,000 --> 00:05:06,000
envFrom loads environment variables from a secret. This is where Vault secrets are injected.

52
00:05:06,000 --> 00:05:12,000
Now the resources.
[Types: resources: {{- toYaml .Values.agentPool.resources | nindent 12 }}]

53
00:05:12,000 --> 00:05:18,000
The resources define CPU and memory requests and limits. The agent needs more memory because it loads the LLM model.

54
00:05:18,000 --> 00:05:24,000
Now the liveness probe.
[Types: livenessProbe: {{- toYaml .Values.agentPool.livenessProbe | nindent 12 }}]

55
00:05:24,000 --> 00:05:30,000
The liveness probe checks if the container is alive. If it fails, the pod is restarted.

56
00:05:30,000 --> 00:05:36,000
Now the readiness probe.
[Types: readinessProbe: {{- toYaml .Values.agentPool.readinessProbe | nindent 12 }}]

57
00:05:36,000 --> 00:05:42,000
The readiness probe checks if the container is ready to receive traffic. If it fails, the pod is removed from the service.

58
00:05:42,000 --> 00:05:48,000
Now the container security context.
[Types: securityContext: allowPrivilegeEscalation: false readOnlyRootFilesystem: true capabilities: drop: ["ALL"]]

59
00:05:48,000 --> 00:05:54,000
These are the same security settings as Phase 7. allowPrivilegeEscalation: false prevents privilege escalation. readOnlyRootFilesystem: true makes the filesystem read-only. capabilities.drop: ["ALL"] drops all capabilities.

60
00:05:54,000 --> 00:06:00,000
Now the volume mounts.
[Types: volumeMounts: - name: tmp mountPath: /tmp - name: model-cache mountPath: /app/.cache]

61
00:06:00,000 --> 00:06:06,000
The tmp volume is for temporary files. The model-cache volume caches the embedding model.

62
00:06:06,000 --> 00:06:12,000
Now the volumes section.
[Types: volumes: - name: tmp emptyDir: {} - name: model-cache emptyDir: medium: Memory sizeLimit: 500Mi]

63
00:06:12,000 --> 00:06:18,000
The tmp volume uses emptyDir. The model-cache volume uses Memory medium, which mounts a tmpfs. This is faster than disk and keeps the model in RAM.

64
00:06:18,000 --> 00:06:24,000
sizeLimit: 500Mi limits the cache size. This prevents memory exhaustion.

65
00:06:24,000 --> 00:06:30,000
Now let's create the agent service. This is a ClusterIP service for internal access.
[Types: --- apiVersion: v1 kind: Service]

66
00:06:30,000 --> 00:06:36,000
The service exposes the agent pods to other services in the cluster.

67
00:06:36,000 --> 00:06:42,000
[Types: metadata: name: {{ include "financial-rag-agent.fullname" . }}-agent namespace: {{ .Values.namespace }} labels: {{- include "financial-rag-agent.labels" . | nindent 4 }} app.kubernetes.io/component: agent]

68
00:06:42,000 --> 00:06:48,000
The service name matches the deployment name. The labels are consistent.

69
00:06:48,000 --> 00:06:54,000
[Types: spec: type: ClusterIP selector: {{- include "financial-rag-agent.selectorLabels" . | nindent 4 }} app.kubernetes.io/component: agent]

70
00:06:54,000 --> 00:07:00,000
The selector matches the pod labels. This routes traffic to the agent pods.

71
00:07:00,000 --> 00:07:06,000
[Types: ports: - name: health port: 8001 targetPort: health protocol: TCP]

72
00:07:06,000 --> 00:07:12,000
The port 8001 is exposed internally. Other services can reach the agent at service-name:8001.

73
00:07:12,000 --> 00:07:18,000
Now let's create the service account.
[Types: --- apiVersion: v1 kind: ServiceAccount]

74
00:07:18,000 --> 00:07:24,000
The service account is used for RBAC and IRSA. It gives the pods their identity.

75
00:07:24,000 --> 00:07:30,000
[Types: metadata: name: {{ include "financial-rag-agent.fullname" . }}-agent namespace: {{ .Values.namespace }} labels: {{- include "financial-rag-agent.labels" . | nindent 4 }} annotations: # eks.amazonaws.com/role-arn: arn:aws:iam::ACCOUNT_ID:role/financial-rag-agent]

76
00:07:30,000 --> 00:07:36,000
The annotation is for IRSA. It's commented out because the role ARN is environment-specific. You'll uncomment it with your actual role ARN.

77
00:07:36,000 --> 00:07:42,000
[Types: {{- end }}]

78
00:07:42,000 --> 00:07:48,000
This closes the conditional block. The agent is only created if agentPool.enabled is true.

79
00:07:48,000 --> 00:07:54,000
Now let's create the Horizontal Pod Autoscaler. Open `infrastructure/helm/templates/agent-hpa.yaml`.

80
00:07:54,000 --> 00:08:00,000
[Types: {{- if and .Values.agentPool.enabled .Values.agentPool.hpa.enabled }}]

81
00:08:00,000 --> 00:08:06,000
The HPA is only created if the agent is enabled and HPA is enabled.

82
00:08:06,000 --> 00:08:12,000
[Types: --- apiVersion: autoscaling/v2 kind: HorizontalPodAutoscaler]

83
00:08:12,000 --> 00:08:18,000
We use autoscaling/v2. This version supports multiple metrics and custom behaviors.

84
00:08:18,000 --> 00:08:24,000
[Types: metadata: name: {{ include "financial-rag-agent.fullname" . }}-agent namespace: {{ .Values.namespace }} labels: {{- include "financial-rag-agent.labels" . | nindent 4 }} app.kubernetes.io/component: agent]

85
00:08:24,000 --> 00:08:30,000
The HPA name matches the deployment name. This makes it easy to identify the relationship.

86
00:08:30,000 --> 00:08:36,000
[Types: spec: scaleTargetRef: apiVersion: apps/v1 kind: Deployment name: {{ include "financial-rag-agent.fullname" . }}-agent]

87
00:08:36,000 --> 00:08:42,000
The scaleTargetRef points to the deployment. The HPA will scale this deployment.

88
00:08:42,000 --> 00:08:48,000
[Types: minReplicas: {{ .Values.agentPool.hpa.minReplicas }} maxReplicas: {{ .Values.agentPool.hpa.maxReplicas }}]

89
00:08:48,000 --> 00:08:54,000
minReplicas and maxReplicas define the scaling range. In production, minReplicas is 5 and maxReplicas is 25.

90
00:08:54,000 --> 00:09:00,000
[Types: metrics: - type: Resource resource: name: cpu target: type: Utilization averageUtilization: {{ .Values.agentPool.hpa.targetCPUUtilizationPercentage }}]

91
00:09:00,000 --> 00:09:06,000
The first metric is CPU utilization. When CPU exceeds 55%, HPA scales up.

92
00:09:06,000 --> 00:09:12,000
[Types: - type: Resource resource: name: memory target: type: Utilization averageUtilization: {{ .Values.agentPool.hpa.targetMemoryUtilizationPercentage }}]

93
00:09:12,000 --> 00:09:18,000
The second metric is memory utilization. When memory exceeds 65%, HPA scales up.

94
00:09:18,000 --> 00:09:24,000
[Types: behavior: scaleDown: stabilizationWindowSeconds: 600 policies: - type: Pods value: 1 periodSeconds: 180]

95
00:09:24,000 --> 00:09:30,000
scaleDown has a 10-minute stabilization window. It only removes 1 pod every 3 minutes.
This prevents thrashing when load drops briefly.

96
00:09:30,000 --> 00:09:36,000
[Types: scaleUp: stabilizationWindowSeconds: 30 policies: - type: Pods value: 5 periodSeconds: 60]

97
00:09:36,000 --> 00:09:42,000
scaleUp has a 30-second stabilization window. It can add up to 5 pods every minute.
This allows quick scaling when load spikes.

98
00:09:42,000 --> 00:09:48,000
[Types: {{- end }}]

99
00:09:48,000 --> 00:09:54,000
This closes the HPA conditional block.

100
00:09:54,000 --> 00:10:00,000
Now let me recap what we've built in Part 6.

101
00:10:00,000 --> 00:10:06,000
We built the Agent Deployment. It runs the agent container with the right resources, security context, and health checks.

102
00:10:06,000 --> 00:10:12,000
We built the Agent Service. It exposes the agent internally on port 8001.

103
00:10:12,000 --> 00:10:18,000
We built the Agent ServiceAccount. It provides identity for RBAC and IRSA.

104
00:10:18,000 --> 00:10:24,000
We built the Agent HPA. It scales the agent based on CPU and memory utilization.
It scales up fast and scales down slowly.

105
00:10:24,000 --> 00:10:30,000
The agent is memory-heavy because it loads the LLM model. The HPA thresholds are lower than the API.
55% CPU and 65% memory. This ensures we scale before performance degrades.

106
00:10:30,000 --> 00:10:36,000
In Part 7, we'll build the Ingestion CronJob. This runs the nightly ingestion pipeline.

107
00:10:36,000 --> 00:10:42,000
Thank you for watching. I'll see you in Part 7.

108
00:10:42,000 --> 00:10:46,000
[End of Part 6]

1
00:00:00,000 --> 00:00:06,000
Welcome back to Phase 8. In Part 7, we build the Ingestion CronJob.

2
00:00:06,000 --> 00:00:12,000
The Ingestion CronJob is what keeps our system up to date. It runs on a schedule,
downloads the latest SEC filings, and adds them to our vector store.

3
00:00:12,000 --> 00:00:18,000
Think of this as your daily newspaper delivery. Every morning, fresh filings are
delivered to your system. You wake up, and the data is already there.

4
00:00:18,000 --> 00:00:24,000
Open your editor and create `infrastructure/helm/templates/ingestion-cronjob.yaml`.

5
00:00:24,000 --> 00:00:30,000
We'll start with the conditional block. This ensures the CronJob is only created if enabled.
[Types: {{- if .Values.ingestion.enabled }}]

6
00:00:30,000 --> 00:00:36,000
The separator ensures YAML formatting is correct.
[Types: ---]

7
00:00:36,000 --> 00:00:42,000
Now let's define the CronJob resource.
[Types: apiVersion: batch/v1]

8
00:00:42,000 --> 00:00:48,000
We use batch/v1 for CronJobs. This is the stable version since Kubernetes 1.21.

9
00:00:48,000 --> 00:00:54,000
Now the kind.
[Types: kind: CronJob]

10
00:00:54,000 --> 00:01:00,000
CronJob runs Jobs on a schedule. It's like a cron job in Linux, but for Kubernetes.

11
00:01:00,000 --> 00:01:06,000
Now the metadata section.
[Types: metadata: name: {{ include "financial-rag-agent.fullname" . }}-ingestion]

12
00:01:06,000 --> 00:01:12,000
The fullname helper generates a consistent name. The -ingestion suffix identifies this as the ingestion cronjob.

13
00:01:12,000 --> 00:01:18,000
[Types: namespace: {{ .Values.namespace }}]

14
00:01:18,000 --> 00:01:24,000
The namespace is from values.yaml. All resources share the same namespace.

15
00:01:24,000 --> 00:01:30,000
Now the labels.
[Types: labels: {{- include "financial-rag-agent.labels" . | nindent 4 }} app.kubernetes.io/component: ingestion]

16
00:01:30,000 --> 00:01:36,000
The labels helper adds standard labels. component: ingestion identifies this as the ingestion service.

17
00:01:36,000 --> 00:01:42,000
Now the spec section. This defines the CronJob's behavior.
[Types: spec: schedule: {{ .Values.ingestion.schedule | quote }}]

18
00:01:42,000 --> 00:01:48,000
The schedule is from values.yaml. By default, it's "0 2 * * *" which means 2 AM UTC every day.

19
00:01:48,000 --> 00:01:54,000
[Types: concurrencyPolicy: {{ .Values.ingestion.concurrencyPolicy }}]

20
00:01:54,000 --> 00:02:00,000
concurrencyPolicy controls what happens if a job is still running when the next scheduled time arrives. We use "Forbid" to prevent overlapping runs.

21
00:02:00,000 --> 00:02:06,000
[Types: successfulJobsHistoryLimit: {{ .Values.ingestion.successfulJobsHistoryLimit }}]

22
00:02:06,000 --> 00:02:12,000
This keeps the last 3 successful jobs for debugging. If something goes wrong, you can check the logs of previous runs.

23
00:02:12,000 --> 00:02:18,000
[Types: failedJobsHistoryLimit: {{ .Values.ingestion.failedJobsHistoryLimit }}]

24
00:02:18,000 --> 00:02:24,000
This keeps the last 3 failed jobs for debugging. You can examine why a job failed.

25
00:02:24,000 --> 00:02:30,000
Now the jobTemplate section. This defines the Job that will be created.
[Types: jobTemplate: spec:]

26
00:02:30,000 --> 00:02:36,000
[Types: backoffLimit: 2]

27
00:02:36,000 --> 00:02:42,000
backoffLimit controls how many times the job retries before failing. We use 2 retries.

28
00:02:42,000 --> 00:02:48,000
[Types: activeDeadlineSeconds: 10800]

29
00:02:48,000 --> 00:02:54,000
activeDeadlineSeconds is a hard cap. The job will be killed after 3 hours. This prevents runaway jobs.

30
00:02:54,000 --> 00:03:00,000
Now the pod template.
[Types: template: metadata: labels: {{- include "financial-rag-agent.selectorLabels" . | nindent 12 }} app.kubernetes.io/component: ingestion]

31
00:03:00,000 --> 00:03:06,000
The selectorLabels match the pod. component: ingestion identifies this as an ingestion pod.

32
00:03:06,000 --> 00:03:12,000
Now the pod annotations.
[Types: annotations: {{- include "financial-rag-agent.podAnnotations" (dict "Values" .Values "componentAnnotations" dict) | nindent 12 }}]

33
00:03:12,000 --> 00:03:18,000
The podAnnotations helper adds global annotations. This is used for Prometheus scraping.

34
00:03:18,000 --> 00:03:24,000
Now the pod spec.
[Types: spec: restartPolicy: {{ .Values.ingestion.restartPolicy }}]

35
00:03:24,000 --> 00:03:30,000
restartPolicy controls what happens when the job completes. We use "OnFailure" so the job retries on failure.

36
00:03:30,000 --> 00:03:36,000
[Types: serviceAccountName: {{ include "financial-rag-agent.fullname" . }}-ingestion]

37
00:03:36,000 --> 00:03:42,000
The service account is used for RBAC and IRSA. The ingestion service needs different permissions than the API.

38
00:03:42,000 --> 00:03:48,000
Now the security context.
[Types: securityContext: runAsNonRoot: true runAsUser: 1000 fsGroup: 1000]

39
00:03:48,000 --> 00:03:54,000
runAsNonRoot: true prevents the container from running as root. runAsUser: 1000 runs as user 1000. fsGroup: 1000 sets the file system group.

40
00:03:54,000 --> 00:04:00,000
These are the same security settings we used in Phase 7. Consistency is key.

41
00:04:00,000 --> 00:04:06,000
Now the node selector.
[Types: {{- with .Values.global.nodeSelector }} nodeSelector: {{- toYaml . | nindent 12 }} {{- end }}]

42
00:04:06,000 --> 00:04:12,000
Node selector schedules pods on specific nodes. In production, we use ingestion nodes.

43
00:04:12,000 --> 00:04:18,000
Now the tolerations.
[Types: {{- with .Values.global.tolerations }} tolerations: {{- toYaml . | nindent 12 }} {{- end }}]

44
00:04:18,000 --> 00:04:24,000
Tolerations allow pods to schedule on nodes with specific taints.

45
00:04:24,000 --> 00:04:30,000
Now the containers section.
[Types: containers: - name: ingestion]

46
00:04:30,000 --> 00:04:36,000
The container name is ingestion. This identifies the container in logs.

47
00:04:36,000 --> 00:04:42,000
Now the image.
[Types: image: {{ include "financial-rag-agent.image" (dict "global" .Values.global "image" .Values.ingestion.image) }}]

48
00:04:42,000 --> 00:04:48,000
The image helper builds the full image name. It uses the same image as the API and agent.

49
00:04:48,000 --> 00:04:54,000
[Types: imagePullPolicy: {{ .Values.global.image.pullPolicy }}]

50
00:04:54,000 --> 00:05:00,000
imagePullPolicy determines when the image is pulled. In production, it's Always.

51
00:05:00,000 --> 00:05:06,000
Now the environment variables.
[Types: env: {{- range $k, $v := .Values.ingestion.env }} - name: {{ $k }} value: {{ $v | quote }} {{- end }}]

52
00:05:06,000 --> 00:05:12,000
The env variables are from values.yaml. These include INGESTION_BATCH_SIZE and LOG_LEVEL.

53
00:05:12,000 --> 00:05:18,000
[Types: {{- with .Values.ingestion.envFrom }} envFrom: {{- toYaml . | nindent 16 }} {{- end }}]

54
00:05:18,000 --> 00:05:24,000
envFrom loads environment variables from a secret. This is where Vault secrets are injected.

55
00:05:24,000 --> 00:05:30,000
Now the resources.
[Types: resources: {{- toYaml .Values.ingestion.resources | nindent 16 }}]

56
00:05:30,000 --> 00:05:36,000
The resources define CPU and memory requests and limits. Ingestion needs more CPU for parsing and embedding.

57
00:05:36,000 --> 00:05:42,000
Now the container security context.
[Types: securityContext: allowPrivilegeEscalation: false readOnlyRootFilesystem: true capabilities: drop: ["ALL"]]

58
00:05:42,000 --> 00:05:48,000
These are the same security settings as Phase 7. allowPrivilegeEscalation: false prevents privilege escalation. readOnlyRootFilesystem: true makes the filesystem read-only. capabilities.drop: ["ALL"] drops all capabilities.

59
00:05:48,000 --> 00:05:54,000
Now the volume mounts.
[Types: volumeMounts: - name: tmp mountPath: /tmp]

60
00:05:54,000 --> 00:06:00,000
The tmp volume is for temporary files during parsing and chunking.

61
00:06:00,000 --> 00:06:06,000
Now the volumes section.
[Types: volumes: - name: tmp emptyDir: {}]

62
00:06:06,000 --> 00:06:12,000
The tmp volume uses emptyDir. It's deleted when the pod completes.

63
00:06:12,000 --> 00:06:18,000
[Types: {{- end }}]

64
00:06:18,000 --> 00:06:24,000
This closes the ingestion conditional block.

65
00:06:24,000 --> 00:06:30,000
Now let's create the ingestion service account.
[Types: --- apiVersion: v1 kind: ServiceAccount metadata: name: {{ include "financial-rag-agent.fullname" . }}-ingestion namespace: {{ .Values.namespace }} labels: {{- include "financial-rag-agent.labels" . | nindent 4 }} annotations: # eks.amazonaws.com/role-arn: arn:aws:iam::ACCOUNT_ID:role/financial-rag-ingestion]

66
00:06:30,000 --> 00:06:36,000
The service account is used for RBAC and IRSA. The ingestion service has different IAM permissions than the API.

67
00:06:36,000 --> 00:06:42,000
The annotation is for IRSA. It's commented out because the role ARN is environment-specific.

68
00:06:42,000 --> 00:06:48,000
Now let me explain the schedule. "0 2 * * *" means 2 AM UTC every day.

69
00:06:48,000 --> 00:06:54,000
Why 2 AM? The SEC updates its EDGAR system overnight. By 2 AM, the previous day's filings are available.

70
00:06:54,000 --> 00:07:00,000
The concurrencyPolicy: Forbid ensures we don't have two ingestion jobs running at the same time. This prevents duplicate processing and database conflicts.

71
00:07:00,000 --> 00:07:06,000
The activeDeadlineSeconds: 10800 means the job will be killed after 3 hours. If the SEC is slow or there's a network issue, the job won't run forever.

72
00:07:06,000 --> 00:07:12,000
The backoffLimit: 2 means the job retries twice before failing. This handles transient network errors.

73
00:07:12,000 --> 00:07:18,000
Now let me show you how to test the ingestion CronJob.

74
00:07:18,000 --> 00:07:24,000
[Types: kubectl create job --from=cronjob/financial-rag-ingestion manual-ingest -n financial-rag]

75
00:07:24,000 --> 00:07:30,000
This creates a one-time job from the CronJob. It's useful for testing and debugging.

76
00:07:30,000 --> 00:07:36,000
[Types: kubectl logs -n financial-rag job/manual-ingest]

77
00:07:36,000 --> 00:07:42,000
This shows the logs of the ingestion job. You can see which filings were downloaded and how many chunks were stored.

78
00:07:42,000 --> 00:07:48,000
Now let's look at the values that configure the CronJob.

79
00:07:48,000 --> 00:07:54,000
In `values.yaml`, ingestion has these settings:
schedule: "0 2 * * *"
concurrencyPolicy: Forbid
successfulJobsHistoryLimit: 3
failedJobsHistoryLimit: 3
restartPolicy: OnFailure

80
00:07:54,000 --> 00:08:00,000
In production, we might change the schedule to run multiple times a day during earnings season.
We might increase the history limits for debugging.

81
00:08:00,000 --> 00:08:06,000
Now let me show you the complete file. You should have this in your editor.

82
00:08:06,000 --> 00:08:12,000
[Show complete ingestion-cronjob.yaml]

83
00:08:12,000 --> 00:08:18,000
Let me recap what we've built in Part 7.

84
00:08:18,000 --> 00:08:24,000
We built the Ingestion CronJob. It runs on a schedule defined in values.yaml.
It uses the same image as the API and agent but with different environment variables and resources.

85
00:08:24,000 --> 00:08:30,000
We configured concurrencyPolicy: Forbid to prevent overlapping runs.
We configured activeDeadlineSeconds: 10800 to prevent runaway jobs.
We configured backoffLimit: 2 for retries.

86
00:08:30,000 --> 00:08:36,000
We created the ingestion service account for RBAC and IRSA.

87
00:08:36,000 --> 00:08:42,000
The CronJob runs nightly at 2 AM UTC. It downloads new filings from the SEC and adds them to the vector store.

88
00:08:42,000 --> 00:08:48,000
In Part 8, we'll build the pgvector StatefulSet. This is where our vector data is stored.

89
00:08:48,000 --> 00:08:54,000
Thank you for watching. I'll see you in Part 8.

90
00:08:54,000 --> 00:08:58,000
[End of Part 7]
1
00:00:00,000 --> 00:00:06,000
Welcome back to Phase 8. In Part 8, we build the ServiceMonitor and integrate everything with GitOps.

2
00:00:06,000 --> 00:00:12,000
The ServiceMonitor is how Prometheus discovers our application metrics. It tells Prometheus which endpoints to scrape and how often.

3
00:00:12,000 --> 00:00:18,000
Think of the ServiceMonitor as a security camera that's always watching. It's configured to watch specific services at specific intervals. It collects data for our dashboards and alerts.

4
00:00:18,000 --> 00:00:24,000
Open your editor and create `infrastructure/helm/templates/servicemonitor.yaml`.

5
00:00:24,000 --> 00:00:30,000
We'll start with the conditional block. The ServiceMonitor is only created if enabled.
[Types: {{- if .Values.serviceMonitor.enabled }}]

6
00:00:30,000 --> 00:00:36,000
The separator ensures YAML formatting is correct between multiple resources.
[Types: ---]

7
00:00:36,000 --> 00:00:42,000
Now let's define the ServiceMonitor resource.
[Types: apiVersion: monitoring.coreos.com/v1]

8
00:00:42,000 --> 00:00:48,000
We use monitoring.coreos.com/v1. This is the standard API version for Prometheus Operator ServiceMonitors.

9
00:00:48,000 --> 00:00:54,000
Now the kind.
[Types: kind: ServiceMonitor]

10
00:00:54,000 --> 00:01:00,000
The ServiceMonitor is a custom resource that tells Prometheus how to scrape metrics from a service.

11
00:01:00,000 --> 00:01:06,000
Now the metadata section.
[Types: metadata: name: {{ include "financial-rag-agent.fullname" . }}-api]

12
00:01:06,000 --> 00:01:12,000
The name matches the API service. This makes it easy to identify which service is being scraped.

13
00:01:12,000 --> 00:01:18,000
[Types: namespace: {{ .Values.serviceMonitor.namespace }}]

14
00:01:18,000 --> 00:01:24,000
The ServiceMonitor is usually deployed in the monitoring namespace. This keeps observability resources separate from application resources.

15
00:01:24,000 --> 00:01:30,000
[Types: labels: {{- include "financial-rag-agent.labels" . | nindent 4 }} release: kube-prometheus-stack]

16
00:01:30,000 --> 00:01:36,000
The release label is critical. The kube-prometheus-stack uses this label to discover ServiceMonitors. If this label doesn't match, Prometheus ignores the ServiceMonitor.

17
00:01:36,000 --> 00:01:42,000
Now the spec section. This defines what to scrape.
[Types: spec:]

18
00:01:42,000 --> 00:01:48,000
The namespaceSelector tells Prometheus which namespaces to look in.
[Types: namespaceSelector: matchNames: - {{ .Values.namespace }}]

19
00:01:48,000 --> 00:01:54,000
We only scrape services in the financial-rag namespace. This keeps monitoring focused on our application.

20
00:01:54,000 --> 00:02:00,000
Now the selector. This selects which services to scrape.
[Types: selector: matchLabels: {{- include "financial-rag-agent.selectorLabels" . | nindent 6 }} app.kubernetes.io/component: api]

21
00:02:00,000 --> 00:02:06,000
The selector matches services with the app.kubernetes.io/component: api label. This selects our API service.

22
00:02:06,000 --> 00:02:12,000
Now the endpoints section. This defines how to scrape.
[Types: endpoints: - port: http]

23
00:02:12,000 --> 00:02:18,000
The port must match the port name in the Service. In our API Service, we named the port "http".

24
00:02:18,000 --> 00:02:24,000
[Types: path: {{ .Values.serviceMonitor.path }}]

25
00:02:24,000 --> 00:02:30,000
The path is /metrics by default. This is where our Prometheus metrics are exposed.

26
00:02:30,000 --> 00:02:36,000
[Types: interval: {{ .Values.serviceMonitor.interval }}]

27
00:02:36,000 --> 00:02:42,000
The interval is how often Prometheus scrapes metrics. 30 seconds is a good balance between freshness and resource usage.

28
00:02:42,000 --> 00:02:48,000
[Types: scheme: http]

29
00:02:48,000 --> 00:02:54,000
We use HTTP for metrics scraping. In production with Istio, this would be HTTPS.

30
00:02:54,000 --> 00:03:00,000
[Types: honorLabels: true]

31
00:03:00,000 --> 00:03:06,000
honorLabels: true prevents Prometheus from overwriting labels with its own. This preserves our service-specific labels.

32
00:03:06,000 --> 00:03:12,000
[Types: {{- end }}]

33
00:03:12,000 --> 00:03:18,000
This closes the conditional block. The ServiceMonitor is only created if serviceMonitor.enabled is true.

34
00:03:18,000 --> 00:03:24,000
Now let's verify the ServiceMonitor works. First, apply the Helm chart.

35
00:03:24,000 --> 00:03:30,000
[Types: helm upgrade --install finrag-staging ./infrastructure/helm/ --namespace financial-rag --create-namespace -f infrastructure/helm/values.yaml -f infrastructure/helm/values.staging.yaml]

36
00:03:30,000 --> 00:03:36,000
This deploys the application with the ServiceMonitor. The ServiceMonitor is created in the monitoring namespace.

37
00:03:36,000 --> 00:03:42,000
Now check the ServiceMonitor status.
[Types: kubectl get servicemonitor -n monitoring]

38
00:03:42,000 --> 00:03:48,000
You should see the financial-rag-agent-api ServiceMonitor in the list.

39
00:03:48,000 --> 00:03:54,000
Now check the Prometheus targets.
[Types: kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090]

40
00:03:54,000 --> 00:04:00,000
Open http://localhost:9090/targets. You should see the financial-rag-agent-api target with status UP.

41
00:04:00,000 --> 00:04:06,000
If the target is DOWN, check the ServiceMonitor configuration. Make sure the service name and port match.

42
00:04:06,000 --> 00:04:12,000
Now let's integrate everything with GitOps. We'll use ArgoCD to deploy the Helm chart automatically.

43
00:04:12,000 --> 00:04:18,000
Open the ArgoCD ApplicationSet from Phase 8, Part 1. The ApplicationSet deploys the Helm chart to all environments.

44
00:04:18,000 --> 00:04:24,000
The ApplicationSet uses the apps-appset.yaml file. It defines how to deploy the application across environments.

45
00:04:24,000 --> 00:04:30,000
Let's verify the ApplicationSet syncs successfully.
[Types: kubectl get applicationsets -n argocd]

46
00:04:30,000 --> 00:04:36,000
You should see the apps-appset ApplicationSet with status Synced.

47
00:04:36,000 --> 00:04:42,000
Now check the individual applications.
[Types: kubectl get applications -n argocd | grep financial-rag]

48
00:04:42,000 --> 00:04:48,000
You should see applications for each environment: dev, staging, and prod.

49
00:04:48,000 --> 00:04:54,000
Let's trigger a deployment by pushing a change. Add a new feature and push to develop.

50
00:04:54,000 --> 00:05:00,000
[Types: git add . git commit -m "feat: add new metric" git push origin develop]

51
00:05:00,000 --> 00:05:06,000
Watch ArgoCD sync automatically.
[Types: argocd app sync financial-rag-dev]

52
00:05:06,000 --> 00:05:12,000
The application should sync and the new metric should appear in Prometheus.

53
00:05:12,000 --> 00:05:18,000
Now let me recap what we've built in Part 8.

54
00:05:18,000 --> 00:05:24,000
We built the ServiceMonitor. It tells Prometheus how to scrape metrics from our API service.

55
00:05:24,000 --> 00:05:30,000
We configured the ServiceMonitor with the correct namespace selector, label selector, and endpoint.

56
00:05:30,000 --> 00:05:36,000
We verified the ServiceMonitor is active by checking Prometheus targets.

57
00:05:36,000 --> 00:05:42,000
We integrated everything with GitOps. The ApplicationSet deploys the Helm chart to all environments.

58
00:05:42,000 --> 00:05:48,000
We triggered a deployment and verified ArgoCD syncs automatically.

59
00:05:48,000 --> 00:05:54,000
This completes the GitOps and monitoring integration. Every environment is automatically deployed. Every environment is monitored.

60
00:05:54,000 --> 00:06:00,000
In Part 9, we'll build the Karpenter node pool configurations. This provides auto-scaling infrastructure.

61
00:06:00,000 --> 00:06:06,000
Thank you for watching. I'll see you in Part 9.

62
00:06:06,000 --> 00:06:10,000
[End of Part 8]
1
00:00:00,000 --> 00:00:06,000
Welcome back to Phase 8. In Part 9, we configure Karpenter for automatic node provisioning.

2
00:00:06,000 --> 00:00:12,000
Karpenter is a Kubernetes node autoscaler. It automatically provisions new nodes when your cluster needs more capacity. It's faster and more flexible than the traditional Cluster Autoscaler.

3
00:00:12,000 --> 00:00:18,000
Think of Karpenter like a smart real estate agent. When your cluster needs more space, it finds the best available nodes at the lowest cost. When space frees up, it removes them.

4
00:00:18,000 --> 00:00:24,000
Open your editor and create `infrastructure/helm/karpenter/ec2nodeclass.yaml`.

5
00:00:24,000 --> 00:00:30,000
We'll start with the EC2NodeClass resource. This defines the EC2 configuration for nodes.
[Types: apiVersion: karpenter.k8s.aws/v1beta1]

6
00:00:30,000 --> 00:00:36,000
We use the karpenter.k8s.aws/v1beta1 API version. This is the latest stable version for AWS-specific configuration.

7
00:00:36,000 --> 00:00:42,000
Now the kind.
[Types: kind: EC2NodeClass]

8
00:00:42,000 --> 00:00:48,000
EC2NodeClass is the Karpenter resource that defines how EC2 instances are configured.

9
00:00:48,000 --> 00:00:54,000
Now the metadata.
[Types: metadata: name: default]

10
00:00:54,000 --> 00:01:00,000
We name it "default" because it will be used as the default node class for all node pools.

11
00:01:00,000 --> 00:01:06,000
Now the spec section.
[Types: spec: amiFamily: AL2023]

12
00:01:06,000 --> 00:01:12,000
amiFamily: AL2023 uses Amazon Linux 2023. This is the latest AMI family from AWS. It's optimized for EKS and includes the latest security updates.

13
00:01:12,000 --> 00:01:18,000
Now the subnet selector.
[Types: subnetSelectorTerms: - tags: karpenter.sh/discovery: financial-rag-prod-cluster]

14
00:01:18,000 --> 00:01:24,000
The subnet selector finds subnets with this tag. This ensures Karpenter only launches instances in our VPC subnets.

15
00:01:24,000 --> 00:01:30,000
Now the security group selector.
[Types: securityGroupSelectorTerms: - tags: aws:eks:cluster-name: financial-rag-prod-cluster]

16
00:01:30,000 --> 00:01:36,000
The security group selector finds the security groups attached to our EKS cluster. This ensures nodes have the correct network policies.

17
00:01:36,000 --> 00:01:42,000
Now the instance profile.
[Types: instanceProfile: financial-rag-prod-karpenter-node]

18
00:01:42,000 --> 00:01:48,000
The instance profile is an IAM role that Karpenter assumes when launching instances. It gives the nodes permissions to join the cluster and access AWS services.

19
00:01:48,000 --> 00:01:54,000
Now the block device mappings.
[Types: blockDeviceMappings: - deviceName: /dev/xvda ebs: volumeSize: 100Gi volumeType: gp3 encrypted: true deleteOnTermination: true]

20
00:01:54,000 --> 00:02:00,000
This configures the root volume. 100Gi is enough for our workloads. gp3 provides good performance at a reasonable cost. encrypted: true ensures data at rest encryption.

21
00:02:00,000 --> 00:02:06,000
deleteOnTermination: true ensures the volume is deleted when the node is terminated. This prevents orphaned volumes.

22
00:02:06,000 --> 00:02:12,000
Now the metadata options.
[Types: metadataOptions: httpEndpoint: enabled httpProtocolIPv6: disabled httpPutResponseHopLimit: 1 httpTokens: required]

23
00:02:12,000 --> 00:02:18,000
These are the EC2 instance metadata service options. httpTokens: required enables IMDSv2, which is more secure than IMDSv1.

24
00:02:18,000 --> 00:02:24,000
Now the tags.
[Types: tags: Project: financial-rag ManagedBy: karpenter]

25
00:02:24,000 --> 00:02:30,000
These tags help identify resources created by Karpenter. They're useful for cost tracking and resource management.

26
00:02:30,000 --> 00:02:36,000
Now let's create the NodePool. Open `infrastructure/helm/karpenter/nodepool-application.yaml`.

27
00:02:36,000 --> 00:02:42,000
[Types: apiVersion: karpenter.sh/v1beta1 kind: NodePool]

28
00:02:42,000 --> 00:02:48,000
NodePool is the Karpenter resource that defines which nodes to provision and when.

29
00:02:48,000 --> 00:02:54,000
[Types: metadata: name: application]

30
00:02:54,000 --> 00:03:00,000
We name it "application" because it's for the application workloads.

31
00:03:00,000 --> 00:03:06,000
Now the template section.
[Types: spec: template: metadata: labels: role: application]

32
00:03:06,000 --> 00:03:12,000
The labels help identify nodes for scheduling. We use role: application to target our workloads.

33
00:03:12,000 --> 00:03:18,000
Now the node class reference.
[Types: spec: nodeClassRef: apiVersion: karpenter.k8s.aws/v1beta1 kind: EC2NodeClass name: default]

34
00:03:18,000 --> 00:03:24,000
This references the EC2NodeClass we just created. The NodePool uses this class to configure nodes.

35
00:03:24,000 --> 00:03:30,000
Now the requirements.
[Types: requirements: - key: karpenter.k8s.aws/instance-family operator: In values: ["m5", "m5a", "m6i", "m6a", "m7i", "r5", "r6i"]]

36
00:03:30,000 --> 00:03:36,000
We prefer instance families with a good balance of CPU and memory. m5 and m6i are general purpose. r5 and r6i are memory optimized.

37
00:03:36,000 --> 00:03:42,000
[Types: - key: karpenter.k8s.aws/instance-size operator: In values: ["xlarge", "2xlarge", "4xlarge"]]

38
00:03:42,000 --> 00:03:48,000
We prefer larger instances for better performance. xlarge, 2xlarge, and 4xlarge provide enough CPU and memory for our workloads.

39
00:03:48,000 --> 00:03:54,000
[Types: - key: kubernetes.io/arch operator: In values: ["amd64"]]

40
00:03:54,000 --> 00:04:00,000
We only use amd64 architecture. ARM is not supported by all our dependencies yet.

41
00:04:00,000 --> 00:04:06,000
[Types: - key: karpenter.sh/capacity-type operator: In values: ["spot", "on-demand"]]

42
00:04:06,000 --> 00:04:12,000
We allow both spot and on-demand instances. Spot instances are cheaper but can be interrupted. On-demand are more reliable but more expensive.

43
00:04:12,000 --> 00:04:18,000
Now the taints.
[Types: taints: - key: dedicated value: application effect: NoSchedule]

44
00:04:18,000 --> 00:04:24,000
Taints prevent pods from scheduling on these nodes unless they have matching tolerations. This ensures only our application pods run on these nodes.

45
00:04:24,000 --> 00:04:30,000
Now the disruption section.
[Types: disruption: consolidationPolicy: WhenUnderutilized consolidateAfter: 30s expireAfter: 720h]

46
00:04:30,000 --> 00:04:36,000
consolidationPolicy: WhenUnderutilized means Karpenter will remove nodes that are underutilized. consolidateAfter: 30s means it will wait 30 seconds before consolidating.

47
00:04:36,000 --> 00:04:42,000
expireAfter: 720h means nodes are replaced after 30 days. This ensures you always have fresh nodes with the latest security patches.

48
00:04:42,000 --> 00:04:48,000
Now the limits.
[Types: limits: cpu: "200" memory: 800Gi]

49
00:04:48,000 --> 00:04:54,000
limits caps the total resources. This prevents Karpenter from provisioning too many nodes. 200 CPU and 800Gi memory is enough for our workloads.

50
00:04:54,000 --> 00:05:00,000
Now let's create the spot burst NodePool. Open `infrastructure/helm/karpenter/nodepool-spot.yaml`.

51
00:05:00,000 --> 00:05:06,000
[Types: apiVersion: karpenter.sh/v1beta1 kind: NodePool metadata: name: spot-burst]

52
00:05:06,000 --> 00:05:12,000
The spot-burst NodePool is for workloads that can tolerate interruptions. It uses spot instances to save costs.

53
00:05:12,000 --> 00:05:18,000
[Types: spec: template: spec: nodeClassRef: apiVersion: karpenter.k8s.aws/v1beta1 kind: EC2NodeClass name: default]

54
00:05:18,000 --> 00:05:24,000
It uses the same EC2NodeClass as the application pool.

55
00:05:24,000 --> 00:05:30,000
[Types: requirements: - key: karpenter.k8s.aws/instance-family operator: In values: ["m5", "m5a", "m6i", "m6a", "c5", "c6i", "r5", "r6i"]]

56
00:05:30,000 --> 00:05:36,000
We add c5 and c6i compute-optimized instances. These are good for CPU-intensive workloads.

57
00:05:36,000 --> 00:05:42,000
[Types: - key: karpenter.k8s.aws/instance-size operator: In values: ["xlarge", "2xlarge"]]

58
00:05:42,000 --> 00:05:48,000
We only use xlarge and 2xlarge for spot instances. Larger instances are less likely to be interrupted.

59
00:05:48,000 --> 00:05:54,000
[Types: - key: karpenter.sh/capacity-type operator: In values: ["spot"]]

60
00:05:54,000 --> 00:06:00,000
This pool only uses spot instances. It's cheaper but less reliable.

61
00:06:00,000 --> 00:06:06,000
[Types: disruption: consolidationPolicy: WhenUnderutilized consolidateAfter: 2m expireAfter: 24h]

62
00:06:06,000 --> 00:06:12,000
expireAfter: 24h means spot nodes are replaced after 24 hours. This is because spot instances can be interrupted at any time.

63
00:06:12,000 --> 00:06:18,000
[Types: weight: 10 limits: cpu: "100" memory: 400Gi]

64
00:06:18,000 --> 00:06:24,000
weight: 10 gives this pool a higher priority. Karpenter will prefer spot instances when possible.

65
00:06:24,000 --> 00:06:30,000
Now let's create the ingestion NodePool. Open `infrastructure/helm/karpenter/nodepool-ingestion.yaml`.

66
00:06:30,000 --> 00:06:36,000
[Types: apiVersion: karpenter.sh/v1beta1 kind: NodePool metadata: name: ingestion]

67
00:06:36,000 --> 00:06:42,000
The ingestion NodePool is for the ingestion CronJob. It uses compute-optimized instances.

68
00:06:42,000 --> 00:06:48,000
[Types: spec: template: metadata: labels: role: ingestion]

69
00:06:48,000 --> 00:06:54,000
We label these nodes with role: ingestion. This allows us to schedule the ingestion jobs on these nodes.

70
00:06:54,000 --> 00:07:00,000
[Types: spec: nodeClassRef: apiVersion: karpenter.k8s.aws/v1beta1 kind: EC2NodeClass name: default]

71
00:07:00,000 --> 00:07:06,000
It uses the same EC2NodeClass as the other pools.

72
00:07:06,000 --> 00:07:12,000
[Types: requirements: - key: karpenter.k8s.aws/instance-family operator: In values: ["c5", "c5a", "c6i", "c6a", "c7i"]]

73
00:07:12,000 --> 00:07:18,000
We only use compute-optimized instances. Ingestion is CPU-intensive. These instances have more CPU per memory.

74
00:07:18,000 --> 00:07:24,000
[Types: - key: karpenter.k8s.aws/instance-size operator: In values: ["large", "xlarge", "2xlarge"]]

75
00:07:24,000 --> 00:07:30,000
We use smaller instances for ingestion. The ingestion job doesn't need as much memory as the application.

76
00:07:30,000 --> 00:07:36,000
[Types: - key: karpenter.sh/capacity-type operator: In values: ["spot"]]

77
00:07:36,000 --> 00:07:42,000
We only use spot instances for ingestion. Ingestion is tolerant to interruptions because it can retry.

78
00:07:42,000 --> 00:07:48,000
[Types: taints: - key: dedicated value: ingestion effect: NoSchedule]

79
00:07:48,000 --> 00:07:54,000
Taints ensure only ingestion pods schedule on these nodes.

80
00:07:54,000 --> 00:08:00,000
[Types: disruption: consolidationPolicy: WhenEmpty consolidateAfter: 5m expireAfter: 168h]

81
00:08:00,000 --> 00:08:06,000
consolidationPolicy: WhenEmpty means nodes are removed when they have no pods. This saves costs when ingestion isn't running.

82
00:08:06,000 --> 00:08:12,000
expireAfter: 168h means nodes are replaced after 7 days. Ingestion runs daily, so this is sufficient.

83
00:08:12,000 --> 00:08:18,000
[Types: limits: cpu: "32" memory: 128Gi]

84
00:08:18,000 --> 00:08:24,000
limits are lower for ingestion because it's a batch workload. It doesn't need to scale as much as the application.

85
00:08:24,000 --> 00:08:30,000
Now let me recap what we've built in Part 9.

86
00:08:30,000 --> 00:08:36,000
We built the EC2NodeClass. It defines the EC2 configuration for all nodes. AMI family, subnets, security groups, instance profile, block device mappings, and metadata options.

87
00:08:36,000 --> 00:08:42,000
We built three NodePools. The application pool for our main workloads. The spot-burst pool for cost savings. The ingestion pool for batch workloads.

88
00:08:42,000 --> 00:08:48,000
Each pool has different instance families, sizes, and capacity types. This gives us flexibility and cost optimization.

89
00:08:48,000 --> 00:08:54,000
Karpenter automatically provisions nodes when needed. It removes nodes when they're underutilized. It replaces old nodes with fresh ones.

90
00:08:54,000 --> 00:09:00,000
This is the foundation of our autoscaling strategy. Karpenter handles the nodes. HPA handles the pods. Together, they ensure our cluster is always sized correctly.

91
00:09:00,000 --> 00:09:06,000
In Part 10, we'll build the Terragrunt configuration. This manages our infrastructure as code.

92
00:09:06,000 --> 00:09:12,000
Thank you for watching. I'll see you in Part 10.

93
00:09:12,000 --> 00:09:16,000
[End of Part 9]

1
00:00:00,000 --> 00:00:06,000
Welcome back to Phase 8. In Part 10, we build the ServiceMonitor and verify our GitOps setup.

2
00:00:06,000 --> 00:00:12,000
A ServiceMonitor is a Prometheus Operator CRD that tells Prometheus which services to scrape for metrics.

3
00:00:12,000 --> 00:00:18,000
Think of it as a configuration file that says: "Prometheus, please scrape metrics from these pods every 30 seconds."

4
00:00:18,000 --> 00:00:24,000
Open your editor and create `infrastructure/helm/templates/servicemonitor.yaml`.

5
00:00:24,000 --> 00:00:30,000
We'll start with the conditional block. The ServiceMonitor is only created if enabled.
[Types: {{- if .Values.serviceMonitor.enabled }}]

6
00:00:30,000 --> 00:00:36,000
The separator ensures proper YAML formatting.
[Types: ---]

7
00:00:36,000 --> 00:00:42,000
Now let's define the ServiceMonitor resource.
[Types: apiVersion: monitoring.coreos.com/v1]

8
00:00:42,000 --> 00:00:48,000
We use monitoring.coreos.com/v1. This is the stable version for Prometheus Operator.

9
00:00:48,000 --> 00:00:54,000
Now the kind.
[Types: kind: ServiceMonitor]

10
00:00:54,000 --> 00:01:00,000
ServiceMonitor tells Prometheus what to scrape. It's like a target list for the Prometheus Operator.

11
00:01:00,000 --> 00:01:06,000
Now the metadata section.
[Types: metadata: name: {{ include "financial-rag-agent.fullname" . }}-api]

12
00:01:06,000 --> 00:01:12,000
The name includes the fullname helper and -api suffix. This identifies this ServiceMonitor.

13
00:01:12,000 --> 00:01:18,000
[Types: namespace: {{ .Values.serviceMonitor.namespace }}]

14
00:01:18,000 --> 00:01:24,000
The ServiceMonitor is created in the monitoring namespace. This is where Prometheus Operator watches for ServiceMonitors.

15
00:01:24,000 --> 00:01:30,000
Now the labels.
[Types: labels: {{- include "financial-rag-agent.labels" . | nindent 4 }} release: kube-prometheus-stack]

16
00:01:30,000 --> 00:01:36,000
The release label is critical. It must match the Prometheus Operator's label selector. In our setup, it's kube-prometheus-stack.

17
00:01:36,000 --> 00:01:42,000
If this label doesn't match, the ServiceMonitor is ignored. No metrics will be scraped.

18
00:01:42,000 --> 00:01:48,000
Now the spec section.
[Types: spec:]

19
00:01:48,000 --> 00:01:54,000
[Types: namespaceSelector: matchNames: - {{ .Values.namespace }}]

20
00:01:54,000 --> 00:02:00,000
This tells Prometheus to look for services in the financial-rag namespace. Only services in this namespace will be scraped.

21
00:02:00,000 --> 00:02:06,000
Now the selector.
[Types: selector: matchLabels: {{- include "financial-rag-agent.selectorLabels" . | nindent 6 }} app.kubernetes.io/component: api]

22
00:02:06,000 --> 00:02:12,000
The selector matches the API service labels. This tells Prometheus which service to scrape.

23
00:02:12,000 --> 00:02:18,000
[Types: endpoints: - port: http]

24
00:02:18,000 --> 00:02:24,000
The port name must match the service port name. In our API service, the port is named http.

25
00:02:24,000 --> 00:02:30,000
[Types: path: {{ .Values.serviceMonitor.path }}]

26
00:02:30,000 --> 00:02:36,000
The path is /metrics. This is where Prometheus metrics are exposed.

27
00:02:36,000 --> 00:02:42,000
[Types: interval: {{ .Values.serviceMonitor.interval }}]

28
00:02:42,000 --> 00:02:48,000
The interval is 30 seconds. Prometheus scrapes metrics every 30 seconds.

29
00:02:48,000 --> 00:02:54,000
[Types: scheme: http]

30
00:02:54,000 --> 00:03:00,000
We use http. In production with Istio, this could be https with mTLS.

31
00:03:00,000 --> 00:03:06,000
[Types: honorLabels: true]

32
00:03:06,000 --> 00:03:12,000
honorLabels: true tells Prometheus to use the labels in the metrics instead of its own labels. This preserves our custom labels.

33
00:03:12,000 --> 00:03:18,000
[Types: {{- end }}]

34
00:03:18,000 --> 00:03:24,000
This closes the conditional block. The ServiceMonitor is only created if serviceMonitor.enabled is true.

35
00:03:24,000 --> 00:03:30,000
Now let's verify the ServiceMonitor works. Deploy the Helm chart and check the ServiceMonitor.

36
00:03:30,000 --> 00:03:36,000
[Types: helm upgrade --install fra-staging ./infrastructure/helm/ --namespace financial-rag --create-namespace -f infrastructure/helm/values.yaml -f infrastructure/helm/values.staging.yaml]

37
00:03:36,000 --> 00:03:42,000
This deploys the chart with staging values. The ServiceMonitor should be created.

38
00:03:42,000 --> 00:03:48,000
[Types: kubectl get servicemonitor -n monitoring]

39
00:03:48,000 --> 00:03:54,000
You should see financial-rag-agent-api in the list. This confirms the ServiceMonitor was created.

40
00:03:54,000 --> 00:04:00,000
[Types: kubectl describe servicemonitor financial-rag-agent-api -n monitoring]

41
00:04:00,000 --> 00:04:06,000
This shows the ServiceMonitor details. You'll see the namespace selector, the service selector, and the endpoint configuration.

42
00:04:06,000 --> 00:04:12,000
Now let's verify Prometheus is scraping metrics.

43
00:04:12,000 --> 00:04:18,000
[Types: kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090]

44
00:04:18,000 --> 00:04:24,000
Open http://localhost:9090/targets. You should see the financial-rag-agent-api target. It should be UP.

45
00:04:24,000 --> 00:04:30,000
[Types: http://localhost:9090/api/v1/query?query=finrag_query_total]

46
00:04:30,000 --> 00:04:36,000
This queries the metrics. You should see data if any queries have been made.

47
00:04:36,000 --> 00:04:42,000
Now let's verify the GitOps flow. This is the end-to-end process.

48
00:04:42,000 --> 00:04:48,000
[Types: git add . git commit -m "feat: add ServiceMonitor for API metrics" git push origin develop]

49
00:04:48,000 --> 00:04:54,000
Push the changes to develop. This triggers the CI/CD pipeline.

50
00:04:54,000 --> 00:05:00,000
Watch the GitHub Actions workflow. It should run through all stages.

51
00:05:00,000 --> 00:05:06,000
Stage 1: Secret scan. Stage 2: Vulnerability scan. Stage 3: OPA policy check. Stage 4: Unit tests. Stage 5: Integration tests.

52
00:05:06,000 --> 00:05:12,000
Stage 6: Build image. Stage 7: Deploy staging. The ServiceMonitor should be created in staging.

53
00:05:12,000 --> 00:05:18,000
After staging deployment, check the staging environment.

54
00:05:18,000 --> 00:05:24,000
[Types: kubectl get servicemonitor -n monitoring --context staging]

55
00:05:24,000 --> 00:05:30,000
You should see the ServiceMonitor in the staging cluster. This confirms the GitOps flow works.

56
00:05:30,000 --> 00:05:36,000
Now let's verify the complete GitOps setup. Open the ArgoCD UI.

57
00:05:36,000 --> 00:05:42,000
[Types: kubectl port-forward -n argocd svc/argocd-server 8080:443]

58
00:05:42,000 --> 00:05:48,000
Open http://localhost:8080. Login with the admin credentials.

59
00:05:48,000 --> 00:05:54,000
You should see the applications. financial-rag-dev, financial-rag-staging, financial-rag-prod.

60
00:05:54,000 --> 00:06:00,000
Click on financial-rag-staging. You'll see the resources. The Deployment, Service, HPA, ServiceMonitor, and other resources.

61
00:06:00,000 --> 00:06:06,000
The sync status should be Synced. The health status should be Healthy. This confirms GitOps is working.

62
00:06:06,000 --> 00:06:12,000
Now let's verify the ApplicationSets. This is the ArgoCD magic.

63
00:06:12,000 --> 00:06:18,000
[Types: kubectl get applicationsets -n argocd]

64
00:06:18,000 --> 00:06:24,000
You should see apps-appset and env-appset. These generate the applications.

65
00:06:24,000 --> 00:06:30,000
[Types: kubectl describe applicationset apps-appset -n argocd]

66
00:06:30,000 --> 00:06:36,000
This shows the ApplicationSet configuration. It defines how applications are generated.

67
00:06:36,000 --> 00:06:42,000
The apps-appset uses a list generator. It creates applications for dev, staging, and prod environments.

68
00:06:42,000 --> 00:06:48,000
The env-appset uses a matrix generator. It combines environments with environment-specific configuration.

69
00:06:48,000 --> 00:06:54,000
Now let's test a full deployment. Make a change to the Helm chart.

70
00:06:54,000 --> 00:07:00,000
[Types: echo "# test change" >> infrastructure/helm/templates/servicemonitor.yaml git add infrastructure/helm/templates/servicemonitor.yaml git commit -m "test: modify ServiceMonitor" git push origin develop]

71
00:07:00,000 --> 00:07:06,000
Watch ArgoCD. In a few minutes, the staging application should sync. The ServiceMonitor should be updated.

72
00:07:06,000 --> 00:07:12,000
This is the power of GitOps. The cluster state is defined in Git. Any change to Git is automatically applied to the cluster.

73
00:07:12,000 --> 00:07:18,000
Now let's test a promotion to production. Create a pull request from develop to main.

74
00:07:18,000 --> 00:07:24,000
The PR triggers the CI pipeline. Tests run. If all pass, the PR can be merged.

75
00:07:24,000 --> 00:07:30,000
[Types: git checkout -b release/v1.0 git push origin release/v1.0]

76
00:07:30,000 --> 00:07:36,000
Create a PR from release/v1.0 to main. Approve and merge.

77
00:07:36,000 --> 00:07:42,000
ArgoCD detects the change to main. It syncs the production application. The new version is deployed.

78
00:07:42,000 --> 00:07:48,000
This is the complete GitOps flow. CI builds and tests. CD deploys to staging. Manual promotion to production.

79
00:07:48,000 --> 00:07:54,000
Now let me recap what we've built in Part 10.

80
00:07:54,000 --> 00:08:00,000
We built the ServiceMonitor. It tells Prometheus to scrape metrics from the API service every 30 seconds.

81
00:08:00,000 --> 00:08:06,000
We verified the ServiceMonitor works. Prometheus shows the target as UP. Metrics are available.

82
00:08:06,000 --> 00:08:12,000
We verified the GitOps flow. Changes to Git are automatically applied to the cluster.

83
00:08:12,000 --> 00:08:18,000
We verified the promotion flow. Changes go from develop to staging. Manual approval promotes to production.

84
00:08:18,000 --> 00:08:24,000
This is the complete CI/CD and GitOps pipeline. Every change is tested, built, and deployed automatically.

85
00:08:24,000 --> 00:08:30,000
Phase 8 is now complete. You have a fully deployed Financial RAG Agent on EKS with full observability.

86
00:08:30,000 --> 00:08:36,000
Thank you for watching. I'll see you in Phase 9.

87
00:08:36,000 --> 00:08:40,000
[End of Part 10]

