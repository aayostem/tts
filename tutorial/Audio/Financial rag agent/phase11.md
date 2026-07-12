# Phase 11: Observability & Governance — Part 1 (00:00:00 - 00:25:00)

## The LGTM Stack & OpenTelemetry — Complete SRT Script

```srt
1
00:00:00,000 --> 00:00:08,000
Welcome to Phase 11 of the Financial RAG Agent series. This is where we move from building features to operating a production system at scale.

2
00:00:08,000 --> 00:00:16,000
Think of this phase as installing the cockpit instruments in a plane. We have a working application. It flies. It works. But we have no instruments.

3
00:00:16,000 --> 00:00:24,000
We don't know how fast we are going. We don't know if the engine is overheating. We don't know if we are about to fly into a mountain. We are flying blind.

4
00:00:24,000 --> 00:00:32,000
That's what observability gives us. It gives us the instruments to fly through the storm. It gives us the data to make decisions. It gives us confidence to deploy to production.

5
00:00:32,000 --> 00:00:40,000
Before we install anything, let me show you what we are building. This is the LGTM stack. LGTM stands for Loki, Grafana, Tempo, and Mimir.

6
00:00:40,000 --> 00:00:48,000
Each component serves a specific purpose in our observability pipeline. Together, they give us complete visibility into our system. Logs, metrics, and traces. All in one place.

7
00:00:48,000 --> 00:00:56,000
Let me explain the architecture. An HTTP request enters our cluster. It generates three types of signals. Logs. Metrics. Traces.

8
00:00:56,000 --> 00:01:04,000
Loki stores the logs. Prometheus scrapes the metrics. Tempo stores the traces. Mimir provides long-term metrics storage. Grafana is the unified visualization layer. It queries all three backends. You can see logs, metrics, and traces on the same dashboard.

9
00:01:04,000 --> 00:01:12,000
This is the magic of the LGTM stack. Everything is connected. Everything is correlated. You can click from a log line to the full trace. You can click from a trace to the relevant metrics. This is how you debug production issues quickly.

10
00:01:12,000 --> 00:01:20,000
Let me explain each component in detail. Understanding what each one does is the first step to using them effectively.

11
00:01:20,000 --> 00:01:28,000
Loki is the log aggregation system. It stores structured logs from our application. It is designed to be cost-effective. It indexes only labels, not the full text.

12
00:01:28,000 --> 00:01:36,000
Traditional log systems index the full text. This makes searches fast, but it's expensive. With Elasticsearch, you pay for every indexed field. At scale, this costs thousands of dollars per month.

13
00:01:36,000 --> 00:01:44,000
Loki takes a different approach. It only indexes labels. It uses a technique called "log streaming" to query the full text when needed. This is much more cost-effective. About 10 times cheaper for the same volume of logs.

14
00:01:44,000 --> 00:01:52,000
Grafana is the visualization layer. It provides dashboards. It queries Loki, Prometheus, Tempo, and Mimir. It correlates logs, metrics, and traces.

15
00:01:52,000 --> 00:02:00,000
Grafana is the single pane of glass. You don't need to switch between tools. You can see everything in one place. You can build custom dashboards. You can set up alerts. You can explore your data.

16
00:02:00,000 --> 00:02:08,000
Tempo is the distributed tracing system. It stores traces from OpenTelemetry. It enables trace-to-log correlation. You can click a log line and see the full trace.

17
00:02:08,000 --> 00:02:16,000
Tempo is designed for scale. It stores traces in object storage. It doesn't index the trace data. It stores them as blocks and queries them on demand. This makes it much more cost-effective than traditional tracing systems.

18
00:02:16,000 --> 00:02:24,000
Mimir is the long-term metrics storage. Prometheus stores metrics for a short period. Mimir stores them for months or years. It enables historical analysis.

19
00:02:24,000 --> 00:02:32,000
Prometheus is great for short-term monitoring. But it's not designed for long-term storage. It stores metrics on the local disk. If a pod restarts, the metrics are lost. Mimir extends Prometheus to months or years. It stores metrics in S3.

20
00:02:32,000 --> 00:02:40,000
Now let me show you the file tree for Phase 11. This is everything we are going to build. Open your editor and follow along.

21
00:02:40,000 --> 00:02:48,000
`src/financial_rag/telemetry/__init__.py`. This is the Python package for telemetry. It exports the configure_tracing and get_tracer functions.

22
00:02:48,000 --> 00:02:56,000
`src/financial_rag/telemetry/tracing.py`. This is the tracer provider configuration. It sets up OpenTelemetry for our application. It instruments FastAPI, SQLAlchemy, Redis, and httpx.

23
00:02:56,000 --> 00:03:04,000
`observability/tracing/tracer-provider.yaml`. This is the OpenTelemetry Collector deployment. It receives spans from our application. It applies tail sampling. It exports to Tempo and X-Ray.

24
00:03:04,000 --> 00:03:12,000
`observability/tracing/jaeger-install.yaml`. This is for dev and staging only. Jaeger provides a UI for trace visualization. In production, we use X-Ray.

25
00:03:12,000 --> 00:03:20,000
`observability/slo/slo-rules.yaml`. This defines the SLO recording rules. It pre-computes error rates over different time windows. It calculates the error budget remaining.

26
00:03:20,000 --> 00:03:28,000
`observability/slo/slo-alerts.yaml`. This defines the SLO alerting rules. It implements multi-window burn-rate alerts. It sends critical alerts to PagerDuty. It sends warnings to Slack.

27
00:03:28,000 --> 00:03:36,000
`argocd/notifications/templates.yaml`. This is for ArgoCD Slack and PagerDuty notifications. It defines the message format for sync success, sync failure, and health degradation.

28
00:03:36,000 --> 00:03:44,000
`policies/rego/helm_policy.rego`. This validates Helm manifests. It catches deprecated API versions. It enforces best practices.

29
00:03:44,000 --> 00:03:52,000
`policies/rego/k8s_admission.rego`. This validates pod admission. It enforces security contexts. It requires resource requests and limits. It blocks :latest image tags.

30
00:03:52,000 --> 00:04:00,000
`policies/rego/terraform_policy.rego`. This validates Terraform plans. It requires S3 public access blocks. It requires RDS encryption. It enforces infrastructure security.

31
00:04:00,000 --> 00:04:08,000
Now let's install the LGTM stack. We'll use Helm to install all components in the observability namespace.

32
00:04:08,000 --> 00:04:16,000
First, create the namespaces. Open your terminal and run these commands.

33
00:04:16,000 --> 00:04:24,000
kubectl create namespace observability
kubectl create namespace monitoring

34
00:04:24,000 --> 00:04:32,000
These namespaces will host our observability components. The monitoring namespace is for Prometheus and Grafana. The observability namespace is for Loki, Tempo, and Mimir.

35
00:04:32,000 --> 00:04:40,000
Add the Grafana Helm repository. This is where the LGTM charts are hosted.

36
00:04:40,000 --> 00:04:48,000
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

37
00:04:48,000 --> 00:04:56,000
Now install Loki. This is our log aggregation system. It will store all our application logs.

38
00:04:56,000 --> 00:05:04,000
helm upgrade --install loki grafana/loki --namespace observability --set loki.storage.type=s3 --set loki.storage.s3.bucketNames.chunks=financial-rag-loki-chunks --set loki.storage.s3.bucketNames.ruler=financial-rag-loki-ruler --set loki.storage.s3.region=us-east-1

39
00:05:04,000 --> 00:05:12,000
Let me explain why we use S3 for Loki storage. Loki stores logs in object storage. S3 costs about $0.023 per gigabyte per month. EBS costs about $0.10 per gigabyte per month.

40
00:05:12,000 --> 00:05:20,000
At production scale with months of logs, this difference is significant. The LGTM stack is designed for S3. Use it. It's the most cost-effective option. You get durable, scalable storage at a fraction of the cost.

41
00:05:20,000 --> 00:05:28,000
Now install Tempo. This is our distributed tracing storage. It will store all our traces.

42
00:05:28,000 --> 00:05:36,000
helm upgrade --install tempo grafana/tempo-distributed --namespace observability --set storage.trace.backend=s3 --set storage.trace.s3.bucket=financial-rag-tempo-traces --set storage.trace.s3.region=us-east-1

43
00:05:36,000 --> 00:05:44,000
Tempo is designed for S3 storage. It stores traces as blocks in S3. It queries them on demand. This is cost-effective for large trace volumes. You don't pay for indexing. You pay for storage.

44
00:05:44,000 --> 00:05:52,000
Now install Mimir. This is our long-term metrics storage. It will store all our metrics.

45
00:05:52,000 --> 00:06:00,000
helm upgrade --install mimir grafana/mimir-distributed --namespace observability --set mimir.structuredConfig.common.storage.backend=s3 --set mimir.structuredConfig.common.storage.s3.bucket_name=financial-rag-mimir-metrics --set mimir.structuredConfig.common.storage.s3.region=us-east-1

46
00:06:00,000 --> 00:06:08,000
Mimir is the long-term store for Prometheus metrics. Prometheus stores metrics for a short period. Mimir stores them for months or years. This enables historical analysis. You can see trends over time.

47
00:06:08,000 --> 00:06:16,000
Now install Grafana. This is our visualization layer. This is where we will see all our data.

48
00:06:16,000 --> 00:06:24,000
helm upgrade --install grafana grafana/grafana --namespace observability --set persistence.enabled=true --set adminPassword="${GRAFANA_PASSWORD}" --set datasources."datasources\.yaml".apiVersion=1 --set-file datasources."datasources\.yaml".datasources[0]=observability/grafana/datasources.yaml

49
00:06:24,000 --> 00:06:32,000
Grafana is the unified dashboard. It queries Loki for logs. It queries Prometheus and Mimir for metrics. It queries Tempo for traces. All from one interface. This is the single pane of glass.

50
00:06:32,000 --> 00:06:40,000
Let me show you what the Grafana data source configuration looks like. This is the magic of the LGTM stack. Open `observability/grafana/datasources.yaml` in your editor.

51
00:06:40,000 --> 00:06:48,000
apiVersion: 1
datasources:
  - name: Prometheus
    type: prometheus
    url: http://kube-prometheus-stack-prometheus.monitoring.svc:9090
    access: proxy

52
00:06:48,000 --> 00:06:56,000
The Prometheus data source connects to the Prometheus server. This gives us access to all our metrics. CPU, memory, request rates, error rates, latency. Everything.

53
00:06:56,000 --> 00:07:04,000
  - name: Loki
    type: loki
    url: http://loki.observability.svc:3100
    access: proxy

54
00:07:04,000 --> 00:07:12,000
The Loki data source connects to the Loki server. This gives us access to all our logs. Application logs, access logs, audit logs. Everything.

55
00:07:12,000 --> 00:07:20,000
  - name: Tempo
    type: tempo
    url: http://tempo.observability.svc:3100
    access: proxy

56
00:07:20,000 --> 00:07:28,000
The Tempo data source connects to the Tempo server. This gives us access to all our traces. Request traces, database traces, API traces. Everything.

57
00:07:28,000 --> 00:07:36,000
  - name: Mimir
    type: prometheus
    url: http://mimir.observability.svc:9009/prometheus
    access: proxy

58
00:07:36,000 --> 00:07:44,000
The Mimir data source connects to the Mimir server. This gives us access to long-term metrics. Historical data, trends, capacity planning. Everything.

59
00:07:44,000 --> 00:07:52,000
With these four data sources, Grafana can correlate logs, metrics, and traces. This is the unified observability experience. You can see the entire picture.

60
00:07:52,000 --> 00:08:00,000
Now let's verify the installations. Check the pods in the observability namespace.

61
00:08:00,000 --> 00:08:08,000
kubectl get pods -n observability

62
00:08:08,000 --> 00:08:16,000
You should see Loki pods running. Tempo pods running. Mimir pods running. Grafana pods running. Wait for all pods to become ready. This may take a few minutes.

63
00:08:16,000 --> 00:08:24,000
The distributed systems need time to initialize. They need to create buckets in S3. They need to establish connections. They need to start their internal services. Be patient.

64
00:08:24,000 --> 00:08:32,000
Check the status of each deployment. `kubectl rollout status deployment/loki -n observability`. This shows the progress of the rollout.

65
00:08:32,000 --> 00:08:40,000
Now let me show you why we need OpenTelemetry. The LGTM stack is the backend. OpenTelemetry is the instrumentation that sends data to it.

66
00:08:40,000 --> 00:08:48,000
OpenTelemetry is the future of observability. It's a CNCF project. It's backed by all the major cloud providers. It provides a single API for logs, metrics, and traces.

67
00:08:48,000 --> 00:08:56,000
Our application is written in Python. OpenTelemetry provides libraries that instrument our code. FastAPI is auto-instrumented. SQLAlchemy is auto-instrumented. Redis is auto-instrumented. httpx is auto-instrumented.

68
00:08:56,000 --> 00:09:04,000
We add custom spans for RAG operations. Embedding, search, LLM generation. The OpenTelemetry SDK sends spans to the OTel Collector. The Collector processes them. Tail sampling. Batching. Filtering.

69
00:09:04,000 --> 00:09:12,000
Then the Collector exports to Tempo for traces. To Loki for logs. To Prometheus for metrics. This is the complete pipeline.

70
00:09:12,000 --> 00:09:20,000
Now let's install the OpenTelemetry dependencies. We need to add them to pyproject.toml. Open `src/financial_rag/pyproject.toml` in your editor.

71
00:09:20,000 --> 00:09:28,000
Add these dependencies to the dependencies section.

72
00:09:28,000 --> 00:09:36,000
"opentelemetry-api>=1.24.0". This is the core API. It defines the tracer, span, and context interfaces. This is what we import in our code.

73
00:09:36,000 --> 00:09:44,000
"opentelemetry-sdk>=1.24.0". This is the SDK implementation. It provides the actual tracer that generates spans. It creates and manages the span lifecycle.

74
00:09:44,000 --> 00:09:52,000
"opentelemetry-exporter-otlp-proto-grpc>=1.24.0". This exports spans to the OTel Collector using gRPC and Protocol Buffers. This is the most efficient transport.

75
00:09:52,000 --> 00:10:00,000
"opentelemetry-instrumentation-fastapi>=0.45b0". This auto-instruments FastAPI. Every HTTP request becomes a span. You get request duration, status code, path, method. Everything.

76
00:10:00,000 --> 00:10:08,000
"opentelemetry-instrumentation-sqlalchemy>=0.45b0". This auto-instruments SQLAlchemy. Every database query becomes a span. You get query duration, SQL statement, parameters. Everything.

77
00:10:08,000 --> 00:10:16,000
"opentelemetry-instrumentation-redis>=0.45b0". This auto-instruments Redis. Every cache operation becomes a span. You get command duration, command name, key. Everything.

78
00:10:16,000 --> 00:10:24,000
"opentelemetry-instrumentation-httpx>=0.45b0". This auto-instruments httpx. Every outbound HTTP request becomes a span. You get request duration, URL, status code. Everything.

79
00:10:24,000 --> 00:10:32,000
"opentelemetry-instrumentation-logging>=0.45b0". This injects trace IDs into logs. It correlates logs and traces. Every log line includes the trace_id and span_id.

80
00:10:32,000 --> 00:10:40,000
Now install the dependencies. This may take a moment.

81
00:10:40,000 --> 00:10:48,000
pip install -e ".[dev]"

82
00:10:48,000 --> 00:10:56,000
This installs all packages. The auto-instrumentation libraries are now available. We will use them in the next part.

83
00:10:56,000 --> 00:11:04,000
Let me explain what each instrumentation does in practice. This is the value of OpenTelemetry. This is why it's the industry standard.

84
00:11:04,000 --> 00:11:12,000
FastAPI instrumentation creates a span for every HTTP request. It captures the path, method, status code, and latency. It propagates trace headers. This means you can trace a request from the user to the database.

85
00:11:12,000 --> 00:11:20,000
SQLAlchemy instrumentation creates a span for every database query. It captures the SQL statement, the parameters, and the latency. It adds a SQL comment with the trace ID. When you see a slow query in PostgreSQL, you can extract the trace ID and find the exact request.

86
00:11:20,000 --> 00:11:28,000
Redis instrumentation creates a span for every Redis command. It captures the command name, the key, and the latency. You can see which operations are slow. You can optimize your cache usage.

87
00:11:28,000 --> 00:11:36,000
httpx instrumentation creates a span for every outbound HTTP request. It captures the URL, method, status code, and latency. This includes calls to OpenAI and Groq. You can see exactly how much time you spend on LLM calls.

88
00:11:36,000 --> 00:11:44,000
Logging instrumentation injects trace_id and span_id into every log record. This enables trace-to-log correlation. You can click a log line and jump to the trace. You can click a trace and see all the logs.

89
00:11:44,000 --> 00:11:52,000
Now let me show you the complete observability architecture with OpenTelemetry. This is the big picture.

90
00:11:52,000 --> 00:12:00,000
A user sends a request to the API. FastAPI instrumentation creates a span. The API queries the database. SQLAlchemy instrumentation creates a child span. The API calls Redis. Redis instrumentation creates another child span. The API calls the LLM via httpx. httpx instrumentation creates a span.

91
00:12:00,000 --> 00:12:08,000
All spans are sent to the OTel Collector. The Collector applies tail sampling. It keeps errors, slow traces, and LLM traces. It samples the rest. Then it exports to Tempo for traces, Loki for logs, and Prometheus for metrics.

92
00:12:08,000 --> 00:12:16,000
Grafana queries all three backends. The user sees the complete picture. Logs, metrics, and traces on the same dashboard. This is the power of OpenTelemetry.

93
00:12:16,000 --> 00:12:24,000
Now let me explain the cost considerations. OpenTelemetry generates a lot of data. A single API request to /query might generate 10 spans. FastAPI, SQLAlchemy queries, Redis calls, httpx to LLM.

94
00:12:24,000 --> 00:12:32,000
At 1000 requests per second, that's 10,000 spans per second. At 1000 requests per second, that's 10,000 spans per second. Without sampling, you would drown in data.

95
00:12:32,000 --> 00:12:40,000
The OTel Collector uses tail sampling to control costs. Tail sampling keeps 100% of error traces. It keeps 100% of slow traces. It keeps 100% of LLM traces. It keeps 1% of successful fast traces.

96
00:12:40,000 --> 00:12:48,000
This gives you full visibility into problems while controlling costs. You see every error. You see every slow request. You see every LLM call. You sample the healthy traffic.

97
00:12:48,000 --> 00:12:56,000
Let me give you a concrete example. At 1000 requests per second, 99% of requests are successful. That's 990 successful requests per second. At 1% sampling, we keep 9.9 successful requests per second.

98
00:12:56,000 --> 00:13:04,000
But we keep all 10 failed requests per second. We keep all slow requests. We keep all LLM calls. The result is about 25 spans per second. That's 2 million spans per day. Tempo compresses and stores them in S3.

99
00:13:04,000 --> 00:13:12,000
The cost is about $0.10 per million spans stored. At 2 million spans per day, that's $0.20 per day. About $6 per month. This is a reasonable cost for full visibility into your production system.

100
00:13:12,000 --> 00:13:20,000
The alternative is flying blind and debugging outages manually. A single outage can cost thousands of dollars in lost revenue. Observability is an investment that pays for itself many times over.

101
00:13:20,000 --> 00:13:28,000
Now let me give you the mental model for observability. Think of logs, metrics, and traces as three views of the same system. They tell different stories about the same event.

102
00:13:28,000 --> 00:13:36,000
Logs tell you what happened. "User X queried ticker AAPL at 14:32:05. The response was 500." This is the narrative.

103
00:13:36,000 --> 00:13:44,000
Metrics tell you how bad it was. "The API error rate spiked to 15% at 14:32. The average latency increased to 250ms." This is the measurement.

104
00:13:44,000 --> 00:13:52,000
Traces tell you where it happened. "The request for AAPL took 300ms. 200ms was spent on the LLM call. 50ms on the vector search. 50ms on the database." This is the root cause.

105
00:13:52,000 --> 00:14:00,000
Together, they give you the complete picture. You know what happened, how bad it was, and where it happened. This is the foundation of observability.

106
00:14:00,000 --> 00:14:08,000
Now let me show you what this looks like in practice. After we deploy the LGTM stack, you can open Grafana and see everything.

107
00:14:08,000 --> 00:14:16,000
You can query Loki for logs. `{service_name="financial-rag-api"} |= "error"`. This shows all error logs from the API service. You can filter by time. You can filter by trace_id.

108
00:14:16,000 --> 00:14:24,000
You can query Prometheus for metrics. `rate(http_requests_total{status=~"5.."}[5m])`. This shows the error rate over time. You can create dashboards. You can set up alerts.

109
00:14:24,000 --> 00:14:32,000
You can query Tempo for traces. `{service.name="financial-rag-api"}`. This shows all traces from the API service. You can click on a trace and see the flame graph. You can see every span. You can see every attribute.

110
00:14:32,000 --> 00:14:40,000
This is the power of the LGTM stack. Everything is connected. Everything is correlated. Everything is searchable.

111
00:14:40,000 --> 00:14:48,000
Now let me recap what we have covered in Part 1. This is the foundation of observability.

112
00:14:48,000 --> 00:14:56,000
We installed the LGTM stack. Loki for logs. Grafana for visualization. Tempo for traces. Mimir for long-term metrics. The LGTM stack is the backend of our observability pipeline.

113
00:14:56,000 --> 00:15:04,000
We installed OpenTelemetry dependencies. The instrumentation libraries for FastAPI, SQLAlchemy, Redis, httpx, and logging. OpenTelemetry is the instrumentation that sends data to the LGTM stack.

114
00:15:04,000 --> 00:15:12,000
We understood the architecture. The LGTM stack is the backend. OpenTelemetry is the instrumentation. The OTel Collector is the pipeline. This is the complete observability stack.

115
00:15:12,000 --> 00:15:20,000
We understood the cost considerations. Tail sampling controls the volume of traces. Keep errors and slow traces. Sample the rest. This gives you visibility at a reasonable cost.

116
00:15:20,000 --> 00:15:28,000
We understood the three pillars of observability. Logs tell you what happened. Metrics tell you how bad it was. Traces tell you where it happened. Together, they give you the complete picture.

117
00:15:28,000 --> 00:15:36,000
In Part 2, we configure the tracer provider. We set up the sampler. We add custom RAG spans for embedding, search, and LLM calls. We wire everything into the application.

118
00:15:36,000 --> 00:15:44,000
This is where the rubber meets the road. This is where we turn our application into an observable system.

119
00:15:44,000 --> 00:15:52,000
But before we go to Part 2, let me share a quick story. At a previous company, we had a production outage that lasted 4 hours. We couldn't figure out what was wrong. We had logs. We had metrics. But we couldn't correlate them.

120
00:15:52,000 --> 00:16:00,000
We spent 4 hours guessing. We restarted pods. We scaled replicas. We changed configurations. Nothing worked. Eventually, we found the issue. A single slow query in the database.

121
00:16:00,000 --> 00:16:08,000
If we had traces, we would have found it in 5 minutes. The trace would have shown the slow database query. We would have fixed it immediately. We wasted 4 hours because we lacked observability.

122
00:16:08,000 --> 00:16:16,000
This is why observability matters. It saves time. It reduces frustration. It prevents outages. It gives you confidence.

123
00:16:16,000 --> 00:16:24,000
So when we implement this stack, remember that story. Remember why we are doing this. It's not just about installing tools. It's about gaining insight. It's about operating with confidence.

124
00:16:24,000 --> 00:16:32,000
I'll see you in Part 2.

125
00:16:32,000 --> 00:16:36,000
[End of Part 1]
```

# Phase 11: Observability & Governance — Part 2 (00:25:00 - 00:50:00)

## Tracer Provider & Custom RAG Spans — Complete SRT Script

```srt
1
00:25:00,000 --> 00:25:08,000
Welcome back to Phase 11. In Part 2, we configure the tracer provider and add custom RAG spans. This is where observability becomes real.

2
00:25:08,000 --> 00:25:16,000
We installed the LGTM stack. We installed OpenTelemetry dependencies. Now we wire it all together. This is where we turn our application into an observable system.

3
00:25:16,000 --> 00:25:24,000
Every request will generate traces. Every trace will be correlated with logs and metrics. Every log line will include a trace ID. Every metric will have a trace context.

4
00:25:24,000 --> 00:25:32,000
Open your editor and create `src/financial_rag/telemetry/__init__.py`. This is the telemetry package for our application. It's going to be small but important.

5
00:25:32,000 --> 00:25:40,000
Type the following into the file.

6
00:25:40,000 --> 00:25:48,000
from financial_rag.telemetry.tracing import configure_tracing, get_tracer
__all__ = ["configure_tracing", "get_tracer"]

7
00:25:48,000 --> 00:25:56,000
This exports two functions. `configure_tracing` sets up the global tracer provider. It's called once at application startup. `get_tracer` returns a named tracer for manual instrumentation. It's used throughout the application.

8
00:25:56,000 --> 00:26:04,000
Now create `src/financial_rag/telemetry/tracing.py`. This is the tracer provider configuration file. It is the most important file in this phase. Let me walk through this file line by line. We are going to build it from scratch.

9
00:26:04,000 --> 00:26:12,000
First, import the necessary modules. These are the building blocks of OpenTelemetry.

10
00:26:12,000 --> 00:26:20,000
import logging
import os
from typing import Optional

11
00:26:20,000 --> 00:26:28,000
from opentelemetry import trace
This is the OpenTelemetry API. It provides the tracer and span interfaces. This is what we use to create spans.

12
00:26:28,000 --> 00:26:36,000
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
This exports spans to the OTel Collector using gRPC. It's the recommended transport for production.

13
00:26:36,000 --> 00:26:44,000
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
This auto-instruments FastAPI applications. Every HTTP request becomes a span. You don't need to write any code for this.

14
00:26:44,000 --> 00:26:52,000
from opentelemetry.instrumentation.httpx import HTTPXClientInstrumentor
This auto-instruments httpx clients. Every outbound HTTP request becomes a span. This includes LLM API calls.

15
00:26:52,000 --> 00:27:00,000
from opentelemetry.instrumentation.logging import LoggingInstrumentor
This injects trace IDs into log records. Every log line includes the trace_id and span_id.

16
00:27:00,000 --> 00:27:08,000
from opentelemetry.instrumentation.redis import RedisInstrumentor
This auto-instruments Redis clients. Every cache operation becomes a span.

17
00:27:08,000 --> 00:27:16,000
from opentelemetry.instrumentation.sqlalchemy import SQLAlchemyInstrumentor
This auto-instruments SQLAlchemy engines. Every database query becomes a span.

18
00:27:16,000 --> 00:27:24,000
from opentelemetry.sdk.resources import Resource
This defines resource attributes for the service. Service name, version, environment. These attributes appear on every span.

19
00:27:24,000 --> 00:27:32,000
from opentelemetry.sdk.trace import TracerProvider
This is the SDK tracer provider. It creates and manages spans. It's the core of the tracing system.

20
00:27:32,000 --> 00:27:40,000
from opentelemetry.sdk.trace.export import BatchSpanProcessor, ConsoleSpanExporter
These export spans in batches. BatchSpanProcessor improves performance. ConsoleSpanExporter is for debugging.

21
00:27:40,000 --> 00:27:48,000
from opentelemetry.sdk.trace.sampling import ParentBased, TraceIdRatioBased
These are samplers. ParentBased respects upstream sampling decisions. TraceIdRatioBased samples a percentage of traces.

22
00:27:48,000 --> 00:27:56,000
Now define the configuration variables. These control how the tracer behaves.

23
00:27:56,000 --> 00:28:04,000
OTEL_ENDPOINT = os.getenv("OTEL_EXPORTER_OTLP_ENDPOINT", "http://financial-rag-otel-collector:4317")

24
00:28:04,000 --> 00:28:12,000
This is the OTLP endpoint. By default, it points to the OTel Collector in the financial-rag namespace. You can override it with an environment variable for testing.

25
00:28:12,000 --> 00:28:20,000
SERVICE_NAME = os.getenv("OTEL_SERVICE_NAME", "financial-rag-api")
This is the service name. It appears in traces and logs. It helps differentiate traces from different services.

26
00:28:20,000 --> 00:28:28,000
ENVIRONMENT = os.getenv("ENVIRONMENT", "dev")
This is the environment name. It helps differentiate traces from dev, staging, and production. You can filter by environment in Grafana.

27
00:28:28,000 --> 00:28:36,000
SAMPLING_RATE = float(os.getenv("OTEL_TRACE_SAMPLE_RATE", "0.01"))
This is the sampling rate. 0.01 means 1% of traces are sampled. This is the default for production.

28
00:28:36,000 --> 00:28:44,000
Let me explain why 1% is the default. A single API request to /query can generate 10 spans. FastAPI, SQLAlchemy queries, Redis calls, httpx to LLM. At 1000 requests per second, that's 10,000 spans per second. At 1% sampling, that's 100 spans per second. That's manageable.

29
00:28:44,000 --> 00:28:52,000
Now define the configure_tracing function. This is the main entry point. It sets up the tracer provider and instruments all frameworks.

30
00:28:52,000 --> 00:29:00,000
def configure_tracing(app=None, engine=None) -> TracerProvider:
    """Configure OpenTelemetry tracing for the application."""
    ...

31
00:29:00,000 --> 00:29:08,000
It takes an optional FastAPI app and an optional SQLAlchemy engine. It returns the TracerProvider. We call this once at application startup.

32
00:29:08,000 --> 00:29:16,000
First, create the resource. This identifies the service in traces.

33
00:29:16,000 --> 00:29:24,000
resource = Resource.create({
    "service.name": SERVICE_NAME,
    "service.version": os.getenv("APP_VERSION", "unknown"),
    "service.namespace": "financial-rag",
    "deployment.environment": ENVIRONMENT,
    "k8s.namespace.name": os.getenv("K8S_NAMESPACE", "financial-rag"),
    "k8s.pod.name": os.getenv("HOSTNAME", "unknown"),
})

34
00:29:24,000 --> 00:29:32,000
The resource includes the service name, version, environment, and Kubernetes metadata. This allows filtering by service in Grafana. This is how you distinguish traces from different services.

35
00:29:32,000 --> 00:29:40,000
Next, create the sampler. This decides which traces to sample.

36
00:29:40,000 --> 00:29:48,000
sampler = ParentBased(root=TraceIdRatioBased(SAMPLING_RATE))

37
00:29:48,000 --> 00:29:56,000
ParentBased respects upstream sampling decisions. If a request is already sampled, we keep it. If not, we use the probability sampler. This ensures consistency across services.

38
00:29:56,000 --> 00:30:04,000
Then create the tracer provider. This is the core of the tracing system.

39
00:30:04,000 --> 00:30:12,000
provider = TracerProvider(resource=resource, sampler=sampler)

40
00:30:12,000 --> 00:30:20,000
The TracerProvider creates spans. It manages the span lifecycle. It exports spans to processors.

41
00:30:20,000 --> 00:30:28,000
Now create the OTLP exporter. This sends spans to the OTel Collector.

42
00:30:28,000 --> 00:30:36,000
otlp_exporter = OTLPSpanExporter(
    endpoint=OTEL_ENDPOINT,
    insecure=ENVIRONMENT != "prod",
)

43
00:30:36,000 --> 00:30:44,000
In dev and staging, we use insecure connections. In production, we use TLS. The OTel Collector handles TLS termination. This is standard practice for Kubernetes environments.

44
00:30:44,000 --> 00:30:52,000
Add the exporter to the provider. This is where the spans go.

45
00:30:52,000 --> 00:31:00,000
provider.add_span_processor(BatchSpanProcessor(
    otlp_exporter,
    max_queue_size=2048,
    max_export_batch_size=512,
    export_timeout_millis=5000,
))

46
00:31:00,000 --> 00:31:08,000
BatchSpanProcessor exports spans in batches. This improves performance. `max_queue_size=2048` holds up to 2048 spans in memory. `max_export_batch_size=512` exports 512 spans at a time.

47
00:31:08,000 --> 00:31:16,000
`export_timeout_millis=5000` means the batch is exported every 5 seconds or when the batch is full. This balances latency and throughput.

48
00:31:16,000 --> 00:31:24,000
Add a console exporter in development. This is for debugging.

49
00:31:24,000 --> 00:31:32,000
if ENVIRONMENT == "dev":
    provider.add_span_processor(BatchSpanProcessor(ConsoleSpanExporter()))

50
00:31:32,000 --> 00:31:40,000
The console exporter prints spans to stdout. This is useful for debugging during development. In production, we don't want this noise.

51
00:31:40,000 --> 00:31:48,000
Set the global tracer provider. This makes the tracer available everywhere in the application.

52
00:31:48,000 --> 00:31:56,000
trace.set_tracer_provider(provider)

53
00:31:56,000 --> 00:32:04,000
Now instrument FastAPI. This is where the auto-instrumentation magic happens.

54
00:32:04,000 --> 00:32:12,000
if app is not None:
    FastAPIInstrumentor.instrument_app(
        app,
        excluded_urls="/health,/metrics",
        server_request_hook=_add_request_attributes,
    )

55
00:32:12,000 --> 00:32:20,000
`excluded_urls="/health,/metrics"` skips health checks and Prometheus scrapes. These generate thousands of spans with zero debugging value. Excluding them saves your sampling budget.

56
00:32:20,000 --> 00:32:28,000
`server_request_hook` adds custom attributes to every HTTP span. We define `_add_request_attributes` to add component and query type attributes.

57
00:32:28,000 --> 00:32:36,000
Now instrument SQLAlchemy. This creates spans for every database query.

58
00:32:36,000 --> 00:32:44,000
if engine is not None:
    SQLAlchemyInstrumentor().instrument(
        engine=engine.sync_engine,
        enable_commenter=True,
        commenter_options={"db_framework": True},
    )

59
00:32:44,000 --> 00:32:52,000
`enable_commenter=True` adds a SQL comment to every query. The comment includes the trace ID. When you see a slow query in PostgreSQL, you can extract the trace ID and find the exact request.

60
00:32:52,000 --> 00:33:00,000
`commenter_options={"db_framework": True}` adds the framework name to the comment. This helps identify which part of the application made the query.

61
00:33:00,000 --> 00:33:08,000
Now instrument Redis. This creates spans for every cache operation.

62
00:33:08,000 --> 00:33:16,000
RedisInstrumentor().instrument()

63
00:33:16,000 --> 00:33:24,000
This instruments all Redis commands. Every cache operation becomes a span. You can see exactly how much time is spent on caching.

64
00:33:24,000 --> 00:33:32,000
Now instrument httpx. This creates spans for every outbound HTTP request.

65
00:33:32,000 --> 00:33:40,000
HTTPXClientInstrumentor().instrument(
    request_hook=_add_llm_attributes,
)

66
00:33:40,000 --> 00:33:48,000
`request_hook` adds custom attributes to httpx spans. We define `_add_llm_attributes` to add the LLM provider name. This helps distinguish OpenAI calls from Groq calls.

67
00:33:48,000 --> 00:33:56,000
Now instrument logging. This injects trace IDs into logs.

68
00:33:56,000 --> 00:34:04,000
LoggingInstrumentor().instrument(set_logging_format=True)

69
00:34:04,000 --> 00:34:12,000
`set_logging_format=True` adds the trace ID to the log format. This enables trace-to-log correlation. You can click a log line and jump to the trace.

70
00:34:12,000 --> 00:34:20,000
Now define the request hook for FastAPI. This adds custom attributes to HTTP spans.

71
00:34:20,000 --> 00:34:28,000
def _add_request_attributes(span, scope):
    if span and span.is_recording():
        if "/query" in scope.get("path", ""):
            span.set_attribute("component", "query-endpoint")
            span.set_attribute("financial_rag.query_type", "rag")

72
00:34:28,000 --> 00:34:36,000
This adds two attributes to every /query span. `component="query-endpoint"` identifies this as a query endpoint. `financial_rag.query_type="rag"` identifies it as a RAG query.

73
00:34:36,000 --> 00:34:44,000
These attributes allow filtering in Grafana. You can query traces where `financial_rag.query_type` is "rag". This helps analyze RAG-specific performance.

74
00:34:44,000 --> 00:34:52,000
Now define the request hook for httpx. This adds custom attributes to LLM API calls.

75
00:34:52,000 --> 00:35:00,000
def _add_llm_attributes(span, request):
    if span and span.is_recording():
        url = str(request.url)
        if "openai" in url:
            span.set_attribute("llm.provider", "openai")
            span.set_attribute("component", "llm-client")
        elif "groq" in url:
            span.set_attribute("llm.provider", "groq")
            span.set_attribute("component", "llm-client")

76
00:35:00,000 --> 00:35:08,000
This adds attributes to LLM API calls. `llm.provider` identifies the provider. `component` identifies this as an LLM client call. This allows filtering by LLM provider.

77
00:35:08,000 --> 00:35:16,000
Now define the get_tracer function. This returns a named tracer for manual instrumentation.

78
00:35:16,000 --> 00:35:24,000
def get_tracer(name: str):
    return trace.get_tracer(name, schema_url="https://opentelemetry.io/schemas/1.24.0")

79
00:35:24,000 --> 00:35:32,000
This returns a named tracer. We use it for manual instrumentation. The name identifies the component. For example, "financial_rag.embeddings" or "financial_rag.search".

80
00:35:32,000 --> 00:35:40,000
Now let me show you the complete `tracer_config.py` file. This is what you should have in your editor.

81
00:35:40,000 --> 00:35:48,000
[Show complete tracer_config.py]

82
00:35:48,000 --> 00:35:56,000
Now let's wire this into the application. Open `src/financial_rag/api/server.py`. We need to call `configure_tracing` in the lifespan function.

83
00:35:56,000 --> 00:36:04,000
At the top of the file, add the import.

84
00:36:04,000 --> 00:36:12,000
from financial_rag.telemetry.tracing import configure_tracing

85
00:36:12,000 --> 00:36:20,000
In the lifespan function, before `initialise_dependencies`, add the following code.

86
00:36:20,000 --> 00:36:28,000
if settings.APP_ENV != "testing":
    from financial_rag.telemetry.tracing import configure_tracing
    from financial_rag.storage.database import get_db_client
    db = await get_db_client()
    configure_tracing(app=app, engine=db._engine)

87
00:36:28,000 --> 00:36:36,000
We skip tracing in testing. Tests don't need traces. They would just clutter the output. We pass the FastAPI app and the SQLAlchemy engine. This instruments FastAPI and SQLAlchemy at startup. All requests and database queries are now traced.

88
00:36:36,000 --> 00:36:44,000
Now let's add custom RAG spans. Auto-instrumentation covers HTTP, DB, and Redis. But the RAG-specific operations need manual spans.

89
00:36:44,000 --> 00:36:52,000
Open `src/financial_rag/retrieval/embeddings.py`. We are going to add a span around the embedding call.

90
00:36:52,000 --> 00:37:00,000
At the top of the file, add the import.

91
00:37:00,000 --> 00:37:08,000
from financial_rag.telemetry.tracing import get_tracer
_tracer = get_tracer("financial_rag.embeddings")

92
00:37:08,000 --> 00:37:16,000
Now wrap the `embed_texts` method.

93
00:37:16,000 --> 00:37:24,000
async def embed_texts(self, texts: list[str]) -> list[list[float]]:
    with _tracer.start_as_current_span("rag.embedding") as span:
        span.set_attribute("embedding.provider", self.provider_name)
        span.set_attribute("embedding.text_count", len(texts))
        span.set_attribute("embedding.dimensions", self.dimensions)
        return await self._embed_batch(texts)

94
00:37:24,000 --> 00:37:32,000
Let me explain what this does. `start_as_current_span` creates a new span. The span is active for the duration of the with block. When the block exits, the span is closed.

95
00:37:32,000 --> 00:37:40,000
We add three attributes. `embedding.provider` identifies the embedding provider. `embedding.text_count` is the number of texts being embedded. `embedding.dimensions` is the vector dimensions.

96
00:37:40,000 --> 00:37:48,000
These attributes help us understand embedding performance. We can see the average embedding time per provider, per text count, per dimensions. This helps optimize our embedding strategy.

97
00:37:48,000 --> 00:37:56,000
Open `src/financial_rag/retrieval/hybrid_search.py`. Add a span around the hybrid search call.

98
00:37:56,000 --> 00:38:04,000
from financial_rag.telemetry.tracing import get_tracer
_tracer = get_tracer("financial_rag.search")

99
00:38:04,000 --> 00:38:12,000
async def search(self, question: str, ...) -> list[RetrievalResult]:
    with _tracer.start_as_current_span("rag.search") as span:
        span.set_attribute("search.type", "hybrid")
        span.set_attribute("search.question_length", len(question))
        span.set_attribute("search.alpha", effective_alpha)
        result = await self._search(question, ...)
        span.set_attribute("search.results_count", len(result))
        return result

100
00:38:12,000 --> 00:38:20,000
This adds a span for every hybrid search. We track the search type, the question length, the alpha parameter, and the number of results returned. This helps us understand search performance.

101
00:38:20,000 --> 00:38:28,000
Open `src/financial_rag/retrieval/query_engine.py`. Add a span around the LLM generation call.

102
00:38:28,000 --> 00:38:36,000
from financial_rag.telemetry.tracing import get_tracer
_tracer = get_tracer("financial_rag.llm")

103
00:38:36,000 --> 00:38:44,000
async def _generate_answer(self, *, question, context, analysis_style):
    with _tracer.start_as_current_span("rag.llm") as span:
        span.set_attribute("llm.model", self._settings.LLM_MODEL)
        span.set_attribute("llm.provider", self._settings.LLM_PROVIDER)
        span.set_attribute("llm.analysis_style", analysis_style)
        span.set_attribute("llm.context_length", len(context))
        response = await self._llm.chat.completions.create(...)
        span.set_attribute("llm.response_length", len(response))
        return response

104
00:38:44,000 --> 00:38:52,000
This adds a span for every LLM generation. We track the model, provider, analysis style, context length, and response length. This helps us understand LLM performance and cost.

105
00:38:52,000 --> 00:39:00,000
Now let me show you the complete flame graph that these spans produce.

106
00:39:00,000 --> 00:39:08,000
An HTTP POST /query request arrives. FastAPI instrumentation creates the root span. The root span has four child spans. `rag.embedding` takes 45ms. This is the embedding call. `rag.search` takes 180ms. This is the hybrid search. Under `rag.search`, pgvector query takes 90ms. Redis get takes 5ms. `rag.llm` takes 170ms. This is the LLM generation. Under `rag.llm`, httpx POST takes 165ms. This is the LLM API call.

107
00:39:08,000 --> 00:39:16,000
The total request takes 400ms. You can see exactly where time is spent. 45ms on embedding. 180ms on search. 170ms on LLM. This is how you identify bottlenecks.

108
00:39:16,000 --> 00:39:24,000
This flame graph is visible in Jaeger. You can click on any span. You can see the attributes. You can see the logs. You can see the full trace context. This is the power of distributed tracing.

109
00:39:24,000 --> 00:39:32,000
Let me show you how to view traces. Port-forward Jaeger.

110
00:39:32,000 --> 00:39:40,000
kubectl port-forward -n monitoring svc/jaeger-query 16686:16686

111
00:39:40,000 --> 00:39:48,000
Open http://localhost:16686. Select the service "financial-rag-api". Click Find Traces. You will see a list of traces.

112
00:39:48,000 --> 00:39:56,000
Click on a trace. You will see the flame graph. You can zoom in. You can see every span. You can see the attributes. You can see the full trace.

113
00:39:56,000 --> 00:40:04,000
Now let me show you trace-to-log correlation. In Grafana, open a Loki log entry. Click the "View Trace" button. It opens the trace in Tempo. This is the power of OpenTelemetry.

114
00:40:04,000 --> 00:40:12,000
Now let me explain the cost implications of these spans. Each span adds overhead. The embedding span adds the embedding time. The search span adds the search time. The LLM span adds the LLM time.

115
00:40:12,000 --> 00:40:20,000
The overhead is minimal. The spans are created in memory. They are exported in batches. The CPU overhead is less than 1% in our testing. This is negligible for most applications.

116
00:40:20,000 --> 00:40:28,000
The cost comes from storing traces. At 1% sampling, we store about 100 spans per second. That's about 8.6 million spans per day. Tempo compresses and stores them in S3.

117
00:40:28,000 --> 00:40:36,000
The cost is about $0.10 per million spans stored. At 8.6 million spans per day, that's about $0.86 per day. About $26 per month. This is a reasonable cost for full visibility into your production system.

118
00:40:36,000 --> 00:40:44,000
Now let me show you how to test the tracing setup. Trigger a request to the API.

119
00:40:44,000 --> 00:40:52,000
curl -X POST http://localhost:8000/query \
  -H "Content-Type: application/json" \
  -d '{"question": "What was Apple's revenue in 2024?"}'

120
00:40:52,000 --> 00:41:00,000
Then check Jaeger. You should see a trace for this request. It should have the root span and all child spans.

121
00:41:00,000 --> 00:41:08,000
Check that the custom attributes are present. `embedding.provider` should be set. `search.alpha` should be set. `llm.model` should be set. This confirms the manual spans are working.

122
00:41:08,000 --> 00:41:16,000
Now check the logs. `kubectl logs -n financial-rag deployment/financial-rag-agent-api`. The logs should include `trace_id` and `span_id` fields. This confirms the logging instrumentation is working.

123
00:41:16,000 --> 00:41:24,000
Now check Loki. In Grafana, go to Explore. Select Loki. Query `{service_name="financial-rag-api"}`. You should see the logs with trace IDs.

124
00:41:24,000 --> 00:41:32,000
Click on a log line. Click the "View Trace" button. It should open the trace in Tempo. This confirms trace-to-log correlation is working.

125
00:41:32,000 --> 00:41:40,000
This is the complete observability pipeline. Logs, metrics, and traces are correlated. You can jump from logs to traces in one click. This is how you debug production issues quickly.

126
00:41:40,000 --> 00:41:48,000
Now let me recap what we have covered in Part 2.

127
00:41:48,000 --> 00:41:56,000
We created the telemetry package. `__init__.py` exports `configure_tracing` and `get_tracer`. This is the public interface for telemetry.

128
00:41:56,000 --> 00:42:04,000
We created the tracer provider configuration. `tracing.py` sets up the tracer provider. It instruments FastAPI, SQLAlchemy, Redis, httpx, and logging. This is the core of observability.

129
00:42:04,000 --> 00:42:12,000
We added custom RAG spans. `rag.embedding` for embedding calls. `rag.search` for hybrid search. `rag.llm` for LLM generation. These spans give us visibility into RAG-specific operations.

130
00:42:12,000 --> 00:42:20,000
We wired everything into the application. `configure_tracing` is called in the lifespan function. All requests are now traced. This is the complete instrumentation.

131
00:42:20,000 --> 00:42:28,000
We tested the setup. Traces appear in Jaeger. Logs include trace IDs. Trace-to-log correlation works. This confirms everything is working.

132
00:42:28,000 --> 00:42:36,000
This is the foundation of observability. In Part 3, we configure the OpenTelemetry Collector. We set up tail sampling. We connect to Loki and Tempo. We make the pipeline production-ready.

133
00:42:36,000 --> 00:42:44,000
But before we go to Part 3, let me share a quick debugging story. At a previous company, we had a performance regression. The API went from 200ms to 2 seconds. We didn't know why.

134
00:42:44,000 --> 00:42:52,000
We had logs. We had metrics. But we couldn't figure out what changed. We spent hours looking at code. We couldn't find the issue. Then we enabled tracing.

135
00:42:52,000 --> 00:43:00,000
The trace showed the problem immediately. A new SQL query was added to the code. It was executing in a loop. It was called 100 times per request. This was the bottleneck.

136
00:43:00,000 --> 00:43:08,000
We fixed the code. The API went back to 200ms. The fix took 5 minutes. The trace found the issue in 5 seconds. This is the power of distributed tracing.

137
00:43:08,000 --> 00:43:16,000
Without tracing, we would have wasted hours. With tracing, we found the issue immediately. This is why observability matters. This is why we are building this stack.

138
00:43:16,000 --> 00:43:24,000
I'll see you in Part 3.

139
00:43:24,000 --> 00:43:28,000
[End of Part 2]
```

# Phase 11: Observability & Governance — Part 3 (00:50:00 - 01:15:00)

## OpenTelemetry Collector & Structured Logging — Complete SRT Script

```srt
1
00:50:00,000 --> 00:50:08,000
Welcome back to Phase 11. In Part 3, we deploy the OpenTelemetry Collector and configure structured logging. This is where everything comes together.

2
00:50:08,000 --> 00:50:16,000
We have the LGTM stack installed. We have the OpenTelemetry dependencies installed. We have the tracer provider configured. Now we need the pipeline that connects them.

3
00:50:16,000 --> 00:50:24,000
The OpenTelemetry Collector is the pipeline. It receives spans from our application. It processes them. It exports them to Tempo, Loki, and Prometheus. It is the heart of our observability stack.

4
00:50:24,000 --> 00:50:32,000
Without the Collector, our application would send spans directly to Tempo. That would work for small systems. But at scale, you need processing. You need sampling. You need batching. You need filtering. That's what the Collector provides.

5
00:50:32,000 --> 00:50:40,000
Let me show you the architecture of the Collector before we deploy it. Understanding this will help you configure it correctly.

6
00:50:40,000 --> 00:50:48,000
The Collector has three main components. Receivers, Processors, and Exporters. Receivers accept data from the application. The OTLP receiver listens for gRPC and HTTP traffic.

7
00:50:48,000 --> 00:50:56,000
Processors transform the data. The batch processor groups spans together. This reduces network overhead. The tail sampling processor decides which traces to keep. This controls costs.

8
00:50:56,000 --> 00:51:04,000
Exporters send data to backends. The Tempo exporter sends traces. The Loki exporter sends logs. The Prometheus exporter sends metrics. Each exporter is configured with the endpoint of the backend.

9
00:51:04,000 --> 00:51:12,000
The Collector is stateless. It runs as a Deployment with two replicas. It scales horizontally. It is fault-tolerant. If one replica fails, the other continues processing.

10
00:51:12,000 --> 00:51:20,000
Now let's deploy the Collector. Open `observability/tracing/tracer-provider.yaml` in your editor. This file defines the OpenTelemetry Collector Custom Resource.

11
00:51:20,000 --> 00:51:28,000
It is a Kubernetes CRD provided by the OpenTelemetry Operator. We installed the Operator in Phase 9. It manages the Collector lifecycle. It handles upgrades. It manages the configuration.

12
00:51:28,000 --> 00:51:36,000
Let me walk through the configuration. The file starts with the apiVersion and kind.

13
00:51:36,000 --> 00:51:44,000
apiVersion: opentelemetry.io/v1alpha1
kind: OpenTelemetryCollector
metadata:
  name: financial-rag-otel-collector
  namespace: financial-rag

14
00:51:44,000 --> 00:51:52,000
We name the Collector `financial-rag-otel-collector`. It runs in the `financial-rag` namespace. This is where our application runs. The Collector is close to the application. This reduces latency.

15
00:51:52,000 --> 00:52:00,000
Now the spec. This defines how the Collector runs.

16
00:52:00,000 --> 00:52:08,000
mode: Deployment
replicas: 2
image: otel/opentelemetry-collector-contrib:0.96.0

17
00:52:08,000 --> 00:52:16,000
We use the contrib image. It includes all the processors and exporters we need. The standard image is smaller but lacks some features. The contrib image has everything.

18
00:52:16,000 --> 00:52:24,000
Now the config section. This is the heart of the Collector. It defines the receivers, processors, and exporters. This is where all the magic happens.

19
00:52:24,000 --> 00:52:32,000
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318

20
00:52:32,000 --> 00:52:40,000
The OTLP receiver listens on two ports. gRPC on 4317. HTTP on 4318. Our application will send traces to these endpoints. The application uses the OTLP exporter. It connects to the Collector's service.

21
00:52:40,000 --> 00:52:48,000
Now the processors. This is where the magic happens. This is where we transform and filter data.

22
00:52:48,000 --> 00:52:56,000
resource:
  attributes:
    - key: service.namespace
      value: financial-rag
      action: upsert
    - key: deployment.environment
      from_attribute: k8s.namespace.name
      action: upsert

23
00:52:56,000 --> 00:53:04,000
The resource processor adds attributes to every span. It tags spans with the service namespace and environment. This helps us filter traces by environment. We can see traces from dev, staging, and prod separately.

24
00:53:04,000 --> 00:53:12,000
batch:
  timeout: 5s
  send_batch_size: 1024
  send_batch_max_size: 2048

25
00:53:12,000 --> 00:53:20,000
The batch processor groups spans together. It sends them in batches. This reduces network overhead. It improves throughput. `timeout: 5s` means it waits up to 5 seconds for a batch to fill. `send_batch_size: 1024` means it sends a batch when it reaches 1024 spans.

26
00:53:20,000 --> 00:53:28,000
This is a balance between latency and efficiency. If you send too often, you waste network bandwidth. If you wait too long, you increase latency. 5 seconds and 1024 spans is a good balance for most systems.

27
00:53:28,000 --> 00:53:36,000
Now the tail sampling processor. This is the most important configuration. This is how we control costs.

28
00:53:36,000 --> 00:53:44,000
tail_sampling:
  decision_wait: 10s
  num_traces: 100000
  expected_new_traces_per_sec: 500

29
00:53:44,000 --> 00:53:52,000
`decision_wait: 10s` means the Collector waits 10 seconds for all spans of a trace to arrive before deciding. This is critical for tail sampling. You need the complete trace to make a decision. If you don't wait, you might sample a trace that later becomes an error.

30
00:53:52,000 --> 00:54:00,000
`num_traces: 100000` means it tracks up to 100,000 traces in memory. This is the in-flight trace cache. It holds traces while waiting for all spans to arrive. 100,000 traces is enough for most systems.

31
00:54:00,000 --> 00:54:08,000
`expected_new_traces_per_sec: 500` is the expected rate of new traces. This helps the Collector size its internal buffers. If you expect more traces, increase this value.

32
00:54:08,000 --> 00:54:16,000
Now the sampling policies. This is where we decide which traces to keep. This is the heart of the configuration.

33
00:54:16,000 --> 00:54:24,000
policies:
  - name: errors-policy
    type: status_code
    status_code: {status_codes: [ERROR]}

34
00:54:24,000 --> 00:54:32,000
The errors-policy keeps 100% of error traces. If any span in the trace has an error status code, the entire trace is kept. This is critical for debugging failures. You want to see every error.

35
00:54:32,000 --> 00:54:40,000
This is why tail sampling is better than head sampling. Head sampling decides at the beginning of the trace. It might drop a trace that later becomes an error. Tail sampling sees the complete trace. It knows if there was an error.

36
00:54:40,000 --> 00:54:48,000
  - name: slow-traces-policy
    type: latency
    latency: {threshold_ms: 2000}

37
00:54:48,000 --> 00:54:56,000
The slow-traces-policy keeps 100% of traces that take longer than 2 seconds. Our query endpoint has a 120-second timeout. But we want to capture traces that are approaching that limit.

38
00:54:56,000 --> 00:55:04,000
If a request takes 5 seconds, it's still within the timeout. But it's slow. We want to know why. We want to optimize it. This policy ensures we see every slow request.

39
00:55:04,000 --> 00:55:12,000
  - name: llm-traces-policy
    type: string_attribute
    string_attribute:
      key: component
      values: [llm-client, agent]

40
00:55:12,000 --> 00:55:20,000
The llm-traces-policy keeps 100% of traces that have an LLM component. This is for cost analysis and performance monitoring. Every LLM call is worth capturing.

41
00:55:20,000 --> 00:55:28,000
LLM calls are expensive. They cost money. They take time. We want to understand how they are performing. We want to optimize them. This policy ensures we see every LLM call.

42
00:55:28,000 --> 00:55:36,000
  - name: probabilistic-policy
    type: probabilistic
    probabilistic: {sampling_percentage: 1}

43
00:55:36,000 --> 00:55:44,000
The probabilistic-policy keeps 1% of all other traces. This gives us representative sampling of successful, fast traces. We don't need to see every successful request. But we want to see a sample.

44
00:55:44,000 --> 00:55:52,000
The policies are evaluated in order. If a trace matches errors-policy, it is kept. If not, it goes to slow-traces-policy. If not, it goes to llm-traces-policy. If not, it goes to probabilistic-policy.

45
00:55:52,000 --> 00:56:00,000
This is why tail sampling is powerful. It sees the complete trace. It applies policies in order. The result is an efficient sample that captures all the important traces.

46
00:56:00,000 --> 00:56:08,000
Now the memory limiter processor. This prevents the Collector from running out of memory.

47
00:56:08,000 --> 00:56:16,000
memory_limiter:
  check_interval: 1s
  limit_mib: 512
  spike_limit_mib: 128

48
00:56:16,000 --> 00:56:24,000
`limit_mib: 512` means the Collector will not exceed 512 MB of memory. `spike_limit_mib: 128` means it allows short spikes up to 640 MB. If memory exceeds the limit, the Collector drops spans.

49
00:56:24,000 --> 00:56:32,000
This is important. If the Collector runs out of memory, it crashes. That would lose traces. The memory limiter prevents this. It drops spans instead of crashing.

50
00:56:32,000 --> 00:56:40,000
Now the exporters. This is where the Collector sends the data.

51
00:56:40,000 --> 00:56:48,000
exporters:
  jaeger:
    endpoint: jaeger-collector.monitoring.svc.cluster.local:14250
    tls:
      insecure: true

52
00:56:48,000 --> 00:56:56,000
The Jaeger exporter sends traces to Jaeger. In production, this would be Tempo. But Jaeger is easier for development. It provides a UI for trace visualization. We use Jaeger in dev and staging.

53
00:56:56,000 --> 00:57:04,000
  awsxray:
    region: us-east-1
    no_verify_ssl: false
    local_mode: false

54
00:57:04,000 --> 00:57:12,000
The AWS X-Ray exporter sends traces to AWS X-Ray. This is for production. X-Ray provides integration with AWS services. It stores traces for 30 days. It's the production trace store.

55
00:57:12,000 --> 00:57:20,000
  prometheus:
    endpoint: "0.0.0.0:8889"
    namespace: financial_rag
    const_labels:
      project: financial-rag-agent

56
00:57:20,000 --> 00:57:28,000
The Prometheus exporter exposes metrics about the Collector itself. This is for monitoring the monitoring system. The metrics are scraped by Prometheus. This is how we know if the Collector is healthy.

57
00:57:28,000 --> 00:57:36,000
Now the service section. This defines the pipelines.

58
00:57:36,000 --> 00:57:44,000
service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [memory_limiter, resource, tail_sampling, batch]
      exporters: [jaeger, awsxray]

59
00:57:44,000 --> 00:57:52,000
The traces pipeline receives OTLP data. It applies the memory limiter, resource processor, tail sampling, and batching. It exports to Jaeger and X-Ray. This is the complete trace pipeline.

60
00:57:52,000 --> 00:58:00,000
    metrics:
      receivers: [otlp]
      processors: [memory_limiter, resource, batch]
      exporters: [prometheus]

61
00:58:00,000 --> 00:58:08,000
The metrics pipeline receives OTLP metrics. It applies the memory limiter, resource processor, and batching. It exports to Prometheus. This is the complete metrics pipeline.

62
00:58:08,000 --> 00:58:16,000
Now let's deploy the Collector.

63
00:58:16,000 --> 00:58:24,000
kubectl apply -f observability/tracing/tracer-provider.yaml

64
00:58:24,000 --> 00:58:32,000
Wait for the Collector to start.

65
00:58:32,000 --> 00:58:40,000
kubectl get pods -n financial-rag -l app.kubernetes.io/name=otel-collector

66
00:58:40,000 --> 00:58:48,000
You should see two Collector pods running. Each on a different node. This provides high availability.

67
00:58:48,000 --> 00:58:56,000
Now let's configure structured logging. This is how we correlate logs with traces.

68
00:58:56,000 --> 00:59:04,000
Open `src/financial_rag/telemetry/tracing.py`. We need to add the logging instrumentation.

69
00:59:04,000 --> 00:59:12,000
At the top of the file, import the logging instrumentation.

70
00:59:12,000 --> 00:59:20,000
from opentelemetry.instrumentation.logging import LoggingInstrumentor

71
00:59:20,000 --> 00:59:28,000
In the `configure_tracing` function, add this line.

72
00:59:28,000 --> 00:59:36,000
LoggingInstrumentor().instrument(set_logging_format=True)

73
00:59:36,000 --> 00:59:44,000
This injects `trace_id` and `span_id` into every log record. Every log line will include the trace ID of the current request.

74
00:59:44,000 --> 00:59:52,000
Let me show you what this looks like in practice. A log line without instrumentation: "API request completed in 150ms". A log line with instrumentation: "API request completed in 150ms trace_id=abc123 span_id=def456".

75
00:59:52,000 --> 01:00:00,000
Now you can correlate logs and traces. In Grafana, you can click on a log line and see the full trace. In Tempo, you can click on a trace and see all the logs.

76
01:00:00,000 --> 01:00:08,000
This is trace-to-log correlation. It is one of the most powerful features of the LGTM stack. It saves hours of debugging time.

77
01:00:08,000 --> 01:00:16,000
Now let's configure structured JSON logging. We want our logs to be JSON. This makes them parsable by Loki.

78
01:00:16,000 --> 01:00:24,000
Create `src/financial_rag/api/logging_config.py`. This file configures structlog for JSON output.

79
01:00:24,000 --> 01:00:32,000
Let me walk through this file line by line. First, import the necessary modules.

80
01:00:32,000 --> 01:00:40,000
import logging
import structlog
from financial_rag.config import get_settings

81
01:00:40,000 --> 01:00:48,000
Now define the `configure_logging` function. This is the main entry point.

82
01:00:48,000 --> 01:00:56,000
def configure_logging():
    settings = get_settings()

83
01:00:56,000 --> 01:01:04,000
shared_processors = [
    structlog.contextvars.merge_contextvars,
    structlog.stdlib.add_logger_name,
    structlog.stdlib.add_log_level,
    structlog.processors.TimeStamper(fmt="iso"),
    _add_trace_context
]

84
01:01:04,000 --> 01:01:12,000
These are the shared processors. They apply to every log line. `merge_contextvars` merges context variables. `add_logger_name` adds the logger name. `add_log_level` adds the log level. `TimeStamper` adds a timestamp.

85
01:01:12,000 --> 01:01:20,000
`_add_trace_context` is our custom processor. It adds the trace_id and span_id. We define this function next.

86
01:01:20,000 --> 01:01:28,000
def _add_trace_context(logger, method, event_dict):
    from opentelemetry import trace
    span = trace.get_current_span()
    if span and span.is_recording():
        ctx = span.get_span_context()
        event_dict["trace_id"] = format(ctx.trace_id, "032x")
        event_dict["span_id"] = format(ctx.span_id, "016x")
    return event_dict

87
01:01:28,000 --> 01:01:36,000
This function gets the current span from OpenTelemetry. It extracts the trace_id and span_id. It adds them to the event_dict. This is how we inject trace IDs into logs.

88
01:01:36,000 --> 01:01:44,000
Now the JSON renderer. This is what makes the logs JSON.

89
01:01:44,000 --> 01:01:52,000
if settings.LOG_FORMAT == "json":
    shared_processors.append(structlog.processors.JSONRenderer())
else:
    shared_processors.append(structlog.dev.ConsoleRenderer())

90
01:01:52,000 --> 01:02:00,000
If the LOG_FORMAT is "json", we use the JSON renderer. This outputs JSON. If it's "console", we use the console renderer. This outputs human-readable logs.

91
01:02:00,000 --> 01:02:08,000
Now configure structlog.

92
01:02:08,000 --> 01:02:16,000
structlog.configure(
    processors=shared_processors,
    wrapper_class=structlog.make_filtering_bound_logger(logging.getLevelName(settings.LOG_LEVEL)),
    logger_factory=structlog.PrintLoggerFactory()
)

93
01:02:16,000 --> 01:02:24,000
This sets up structlog with our processors. The wrapper class filters logs by level. The logger factory outputs logs to stdout.

94
01:02:24,000 --> 01:02:32,000
Now call `configure_logging()` at the start of the lifespan function in `server.py`. This must happen before any other imports.

95
01:02:32,000 --> 01:02:40,000
@asynccontextmanager
async def lifespan(app: FastAPI):
    from financial_rag.api.logging_config import configure_logging
    configure_logging()
    # ... rest of the lifespan

96
01:02:40,000 --> 01:02:48,000
Now restart the API pod.

97
01:02:48,000 --> 01:02:56,000
kubectl rollout restart deployment/financial-rag-agent-api -n financial-rag

98
01:02:56,000 --> 01:03:04,000
After the pod restarts, send a request.

99
01:03:04,000 --> 01:03:12,000
curl -X POST http://localhost:8000/query -H "Content-Type: application/json" -d '{"question": "What was Apple's revenue in 2024?"}'

100
01:03:12,000 --> 01:03:20,000
Check the logs.

101
01:03:20,000 --> 01:03:28,000
kubectl logs -n financial-rag deployment/financial-rag-agent-api | head -20

102
01:03:28,000 --> 01:03:36,000
You should see JSON logs with trace_id and span_id. The logs look like this: `{"event": "API request completed", "level": "info", "trace_id": "abc123", "span_id": "def456", "duration_ms": 150}`.

103
01:03:36,000 --> 01:03:44,000
Now let's verify the trace-to-log correlation in Grafana.

104
01:03:44,000 --> 01:03:52,000
First, port-forward Grafana.

105
01:03:52,000 --> 01:04:00,000
kubectl port-forward -n observability svc/grafana 3000:3000

106
01:04:00,000 --> 01:04:08,000
Open http://localhost:3000. Login with admin/admin. Go to Explore. Select the Loki data source.

107
01:04:08,000 --> 01:04:16,000
Run a query. `{service_name="financial-rag-api"}`. You should see log entries. Each entry has a trace_id field.

108
01:04:16,000 --> 01:04:24,000
Click on a log entry. You will see the trace_id field. Click on it. It will take you to the trace in Tempo.

109
01:04:24,000 --> 01:04:32,000
This is trace-to-log correlation. You can go from a log line to the full trace. This is how you debug production issues.

110
01:04:32,000 --> 01:04:40,000
Let me show you a real example. Suppose a user reports a slow query. You look at the logs. You see a log line with `duration_ms: 5000`. You click the trace_id. You see the full trace in Tempo.

111
01:04:40,000 --> 01:04:48,000
You see that 4500ms was spent on the LLM call. You see the LLM provider. You see the model. You see the input length. You now know exactly what caused the slowness.

112
01:04:48,000 --> 01:04:56,000
This is the power of observability. You go from log to trace in seconds. You identify the root cause quickly. You fix it. The user is happy.

113
01:04:56,000 --> 01:05:04,000
Now let me explain the cost considerations for the Collector.

114
01:05:04,000 --> 01:05:12,000
The Collector uses memory and CPU. The tail sampling processor uses the most memory. It stores traces in memory while waiting for all spans.

115
01:05:12,000 --> 01:05:20,000
`num_traces: 100000` means it stores up to 100,000 traces. Each trace has an average of 10 spans. That's 1 million spans in memory. At 1 KB per span, that's 1 GB of memory.

116
01:05:20,000 --> 01:05:28,000
Monitor the Collector memory usage.

117
01:05:28,000 --> 01:05:36,000
kubectl top pods -n financial-rag -l app.kubernetes.io/name=otel-collector

118
01:05:36,000 --> 01:05:44,000
If memory is high, reduce `num_traces` or increase the memory limit. You can also reduce the `decision_wait` time. But be careful. Reducing `decision_wait` might cause the Collector to drop traces before all spans arrive.

119
01:05:44,000 --> 01:05:52,000
The Collector also uses network bandwidth. It sends traces to Tempo and X-Ray. Monitor the network usage. If bandwidth is high, reduce the sampling rate.

120
01:05:52,000 --> 01:06:00,000
Now let me show you how to scale the Collector. If you have high trace volume, you might need more replicas.

121
01:06:00,000 --> 01:06:08,000
kubectl scale deployment/financial-rag-otel-collector -n financial-rag --replicas=3

122
01:06:08,000 --> 01:06:16,000
The Collector is stateless. It can scale horizontally. Each replica processes a portion of the traces.

123
01:06:16,000 --> 01:06:24,000
Now let's recap what we have covered in Part 3.

124
01:06:24,000 --> 01:06:32,000
We deployed the OpenTelemetry Collector. It has receivers, processors, and exporters. The tail sampling processor is the most important. It keeps errors, slow traces, LLM traces, and samples the rest.

125
01:06:32,000 --> 01:06:40,000
We configured structured logging. We added trace_id and span_id to every log record. We configured JSON output.

126
01:06:40,000 --> 01:06:48,000
We enabled trace-to-log correlation. We can go from a log line to the full trace in Grafana. This saves hours of debugging time.

127
01:06:48,000 --> 01:06:56,000
We understood the cost considerations. The Collector uses memory, CPU, and network bandwidth. Monitor these and adjust the sampling rate.

128
01:06:56,000 --> 01:07:04,000
Now our application is instrumented. We have traces. We have logs. We have metrics. We have correlation. This is the foundation of observability.

129
01:07:04,000 --> 01:07:12,000
In Part 4, we define SLO recording rules and multi-window burn-rate alerts. We build the error budget dashboard. We turn our metrics into actionable insights.

130
01:07:12,000 --> 01:07:20,000
But before we go, let me share one more story. A few years ago, I was debugging a production issue. The application was slow. Users were complaining. We had logs. We had metrics. But we couldn't find the cause.

131
01:07:20,000 --> 01:07:28,000
We spent hours looking at logs. We spent hours looking at metrics. We couldn't correlate them. We were flying blind.

132
01:07:28,000 --> 01:07:36,000
Then we deployed OpenTelemetry. Within minutes, we found the issue. A single slow database query. The trace showed it clearly. We fixed it immediately.

133
01:07:36,000 --> 01:07:44,000
That experience taught me the value of observability. It's not just about tools. It's about being able to understand your system. It's about being able to fix problems quickly.

134
01:07:44,000 --> 01:07:52,000
You now have that capability. You have the LGTM stack. You have OpenTelemetry. You have the Collector. You have structured logging. You have trace-to-log correlation.

135
01:07:52,000 --> 01:08:00,000
This is the foundation of modern observability. This is how you operate at scale.

136
01:08:00,000 --> 01:08:08,000
I'll see you in Part 4.

137
01:08:08,000 --> 01:08:12,000
[End of Part 3]
```

# Phase 11: Observability & Governance — Part 4 (01:15:00 - 01:40:00)

## SLOs & Multi-Window Burn-Rate Alerts — Complete SRT Script

```srt
1
01:15:00,000 --> 01:15:08,000
Welcome back to Phase 11. In Part 4, we define Service Level Objectives and build the alerting system that protects them. This is where we move from reactive monitoring to proactive SRE.

2
01:15:08,000 --> 01:15:16,000
Let me start with a concept that changes how you think about reliability. The error budget. This is the most important concept in modern site reliability engineering.

3
01:15:16,000 --> 01:15:24,000
Think of your SLO like a financial budget. You have 3 hours and 39 minutes of "downtime money" for the month. That's 0.5% of 730 hours. That's your error budget.

4
01:15:24,000 --> 01:15:32,000
If you spend that budget in one hour, that's an emergency — page someone. If you spend it slowly over 30 days, that's just maintenance — investigate when you have time.

5
01:15:32,000 --> 01:15:40,000
The error budget is your allowance for failure. It gives you permission to deploy, to experiment, to take calculated risks. You don't have to be perfect. You just have to stay within your budget.

6
01:15:40,000 --> 01:15:48,000
This is the Google SRE philosophy. Reliability is not about being perfect. It's about being predictably reliable. You choose your tolerance for failure. You measure against it. You alert when you exceed it.

7
01:15:48,000 --> 01:15:56,000
We are going to define three SLOs for the Financial RAG Agent. Each SLO has a target and an error budget.

8
01:15:56,000 --> 01:16:04,000
SLO-1 is API availability. The target is 99.5%. The error budget is 0.5%. That's 3 hours and 39 minutes of downtime per month. This is our most important SLO.

9
01:16:04,000 --> 01:16:12,000
SLO-2 is query latency. The target is P99 latency under 120 seconds for 95% of requests. The error budget is 5% of requests can be slow. This ensures our users get fast responses.

10
01:16:12,000 --> 01:16:20,000
SLO-3 is ingestion success rate. The target is 99%. The error budget is 1% of filings can fail. This ensures our data is complete.

11
01:16:20,000 --> 01:16:28,000
Now let me show you the recording rules. These are Prometheus rules that pre-compute the metrics we need for alerting. Open `observability/slo/slo-rules.yaml` in your editor.

12
01:16:28,000 --> 01:16:36,000
Let me walk through the first SLO. API availability. The target is 99.5%. The error budget is 0.5%.

13
01:16:36,000 --> 01:16:44,000
We need to measure the error rate. Good requests are non-5xx status codes. We calculate the success rate over a 5-minute window.

14
01:16:44,000 --> 01:16:52,000
```
- record: financial_rag:api_request_success:rate5m
  expr: |
    sum(rate(http_requests_total{namespace="financial-rag",component="api",status!~"5.."}[5m]))
    /
    sum(rate(http_requests_total{namespace="financial-rag",component="api"}[5m]))
```

15
01:16:52,000 --> 01:17:00,000
This gives us the percentage of requests that succeeded in the last 5 minutes. We use this for dashboards and trend analysis. It's a good indicator of current health.

16
01:17:00,000 --> 01:17:08,000
Now we need the error rate for alerting. We calculate this over different time windows. 1 hour, 6 hours, 24 hours, and 72 hours. Each window serves a different purpose.

17
01:17:08,000 --> 01:17:16,000
```
- record: financial_rag:api_error_rate:rate1h
  expr: |
    1 - (
      sum(rate(http_requests_total{namespace="financial-rag",component="api",status!~"5.."}[1h]))
      /
      sum(rate(http_requests_total{namespace="financial-rag",component="api"}[1h]))
    )
```

18
01:17:16,000 --> 01:17:24,000
The 1-hour window catches short-term spikes. If something is wrong right now, this will show it. We use this for fast burn alerts.

19
01:17:24,000 --> 01:17:32,000
```
- record: financial_rag:api_error_rate:rate6h
  expr: |
    1 - (
      sum(rate(http_requests_total{namespace="financial-rag",component="api",status!~"5.."}[6h]))
      /
      sum(rate(http_requests_total{namespace="financial-rag",component="api"}[6h]))
    )
```

20
01:17:32,000 --> 01:17:40,000
The 6-hour window catches sustained issues. If something has been wrong for 6 hours, this will show it. We use this for both fast burn and slow burn alerts.

21
01:17:40,000 --> 01:17:48,000
```
- record: financial_rag:api_error_rate:rate24h
  expr: |
    1 - (
      sum(rate(http_requests_total{namespace="financial-rag",component="api",status!~"5.."}[24h]))
      /
      sum(rate(http_requests_total{namespace="financial-rag",component="api"}[24h]))
    )
```

22
01:17:48,000 --> 01:17:56,000
The 24-hour window catches gradual degradation. If you have a slow leak of errors over a day, this will show it. We use this for slow burn alerts.

23
01:17:56,000 --> 01:18:04,000
```
- record: financial_rag:api_error_rate:rate72h
  expr: |
    1 - (
      sum(rate(http_requests_total{namespace="financial-rag",component="api",status!~"5.."}[72h]))
      /
      sum(rate(http_requests_total{namespace="financial-rag",component="api"}[72h]))
    )
```

24
01:18:04,000 --> 01:18:12,000
The 72-hour window catches long-term trends. This is used for the error budget calculation. It shows how much budget you've consumed over the last 3 days.

25
01:18:12,000 --> 01:18:20,000
Now let me explain the multi-window burn-rate alerting methodology. This is from the Google SRE Workbook, Chapter 5. It's the industry standard for SLO alerting.

26
01:18:20,000 --> 01:18:28,000
We have two alert tiers. Critical and Warning. Critical pages immediately. Warning alerts you to investigate today.

27
01:18:28,000 --> 01:18:36,000
Critical requires two windows. The 1-hour error rate AND the 6-hour error rate must both be high. This means the burn rate is fast. You're consuming budget quickly. Page someone now.

28
01:18:36,000 --> 01:18:44,000
Warning requires the 6-hour error rate AND the 24-hour error rate to be high. This means the burn rate is slower. You're consuming budget gradually. Investigate today.

29
01:18:44,000 --> 01:18:52,000
Why two windows? A single spike in one window triggers false alerts. Requiring both windows to be elevated simultaneously means the burn rate is sustained, not a one-off blip. This dramatically reduces alert fatigue.

30
01:18:52,000 --> 01:19:00,000
Let me show you the math. For SLO-1, the target is 99.5%. The error budget is 0.5%. The error rate threshold is 0.005. This is the maximum allowed error rate.

31
01:19:00,000 --> 01:19:08,000
The fast burn rate is 14.4x. This burns 2% of the monthly budget in 1 hour. The threshold is 14.4 times 0.005 equals 0.072. That's a 7.2% error rate.

32
01:19:08,000 --> 01:19:16,000
The slow burn rate is 6x. This burns 5% of the monthly budget in 6 hours. The threshold is 6 times 0.005 equals 0.03. That's a 3% error rate.

33
01:19:16,000 --> 01:19:24,000
Now let me show you the alert rules. Open `observability/slo/slo-alerts.yaml` in your editor. This is where the magic happens.

34
01:19:24,000 --> 01:19:32,000
The fast burn alert:
```
- alert: SLOAvailabilityFastBurn
  expr: |
    financial_rag:api_error_rate:rate1h > (14.4 * 0.005)
    and
    financial_rag:api_error_rate:rate6h > (14.4 * 0.005)
  for: 0m
```

35
01:19:32,000 --> 01:19:40,000
The condition requires BOTH windows to be elevated. The 1-hour error rate must be above 7.2%. AND the 6-hour error rate must be above 7.2%.

36
01:19:40,000 --> 01:19:48,000
If both are true, the alert fires immediately. `for: 0m`. No waiting period. When the error budget is burning this fast, you need to know right now. Every second counts.

37
01:19:48,000 --> 01:19:56,000
The labels tell us who to page:
```
  labels:
    severity: critical
    slo: availability
    project: financial-rag
```

38
01:19:56,000 --> 01:20:04,000
The annotations tell us what to do:
```
  annotations:
    summary: "SLO-1 CRITICAL: API availability fast burn rate"
    description: |
      Error rate: 1h={{ $value | humanizePercentage }}.
      Burn rate: 14.4x. At this rate the monthly error budget
      (3.65 hours) will be exhausted in 1 hour.
      Immediate action required.
    runbook: "https://github.com/aayostem/financial-rag-agent/docs/runbooks/slo-availability.md"
```

39
01:20:04,000 --> 01:20:12,000
This gives the responder everything they need. The error rate. The burn rate. The impact. Where to go for more information. This is an actionable alert.

40
01:20:12,000 --> 01:20:20,000
The slow burn alert:
```
- alert: SLOAvailabilitySlowBurn
  expr: |
    financial_rag:api_error_rate:rate6h > (6 * 0.005)
    and
    financial_rag:api_error_rate:rate24h > (6 * 0.005)
  for: 0m
```

41
01:20:20,000 --> 01:20:28,000
This requires the 6-hour error rate AND the 24-hour error rate to be above 3%. If both are true, the alert fires as a warning. Investigate today.

42
01:20:28,000 --> 01:20:36,000
The labels for the slow burn:
```
  labels:
    severity: warning
    slo: availability
```

43
01:20:36,000 --> 01:20:44,000
The annotations for the slow burn:
```
  annotations:
    summary: "SLO-1 WARNING: API availability slow burn rate"
    description: |
      Error rate: 6h={{ $value | humanizePercentage }}.
      Burn rate: 6x. Budget will exhaust in ~5 days if sustained.
```

44
01:20:44,000 --> 01:20:52,000
This is a warning. It doesn't page anyone. It just sends a Slack message. The team can investigate during business hours. There's no urgency.

45
01:20:52,000 --> 01:21:00,000
Now let me show you the latency SLO. SLO-2 is query latency P99 under 120 seconds for 95% of requests.

46
01:21:00,000 --> 01:21:08,000
We measure this with a histogram. `http_request_duration_seconds_bucket`. We count requests that complete within 120 seconds.

47
01:21:08,000 --> 01:21:16,000
```
- record: financial_rag:query_latency_slo:rate5m
  expr: |
    sum(rate(http_request_duration_seconds_bucket{
      namespace="financial-rag",component="api",path=~"/query.*",le="120"
    }[5m]))
    /
    sum(rate(http_request_duration_seconds_count{
      namespace="financial-rag",component="api",path=~"/query.*"
    }[5m]))
```

48
01:21:16,000 --> 01:21:24,000
This gives us the percentage of queries that completed within 120 seconds in the last 5 minutes. The target is 95%. If this drops below 95%, we're violating the SLO.

49
01:21:24,000 --> 01:21:32,000
The error rate for latency is the percentage of queries that took longer than 120 seconds. The error budget is 5% of requests can be slow.

50
01:21:32,000 --> 01:21:40,000
```
- record: financial_rag:query_latency_error_rate:rate1h
  expr: |
    1 - (
      sum(rate(http_request_duration_seconds_bucket{
        namespace="financial-rag",component="api",path=~"/query.*",le="120"
      }[1h]))
      /
      sum(rate(http_request_duration_seconds_count{
        namespace="financial-rag",component="api",path=~"/query.*"
      }[1h]))
    )
```

51
01:21:40,000 --> 01:21:48,000
The fast burn threshold for latency is 14.4 times 0.05 equals 0.72. That's a 72% slow request rate. The slow burn threshold is 6 times 0.05 equals 0.3. That's a 30% slow request rate.

52
01:21:48,000 --> 01:21:56,000
The latency alerts use the same structure as the availability alerts. Fast burn pages. Slow burn warns.

53
01:21:56,000 --> 01:22:04,000
```
- alert: SLOLatencyFastBurn
  expr: |
    financial_rag:query_latency_error_rate:rate1h > (14.4 * 0.05)
    and
    financial_rag:query_latency_error_rate:rate6h > (14.4 * 0.05)
  labels:
    severity: critical
    slo: latency
  annotations:
    summary: "SLO-2 CRITICAL: Query latency fast burn rate"
    description: "More than 5% of queries exceeding 120s P99 latency SLO. Burn rate 14.4x."
```

54
01:22:04,000 --> 01:22:12,000
Now let me show you the ingestion SLO. SLO-3 is ingestion success rate of 99%.

55
01:22:12,000 --> 01:22:20,000
This is a different type of SLO. It's not about API requests. It's about batch jobs. We measure the success rate of ingestion jobs.

56
01:22:20,000 --> 01:22:28,000
```
- record: financial_rag:ingestion_success_rate:rate24h
  expr: |
    sum(financial_rag_ingestion_filings_processed_total)
    /
    (sum(financial_rag_ingestion_filings_processed_total)
     + sum(financial_rag_ingestion_filings_failed_total))
```

57
01:22:28,000 --> 01:22:36,000
This calculates the success rate over 24 hours. Processed filings divided by total filings. The target is 99%.

58
01:22:36,000 --> 01:22:44,000
The alert for ingestion is simpler. If the success rate drops below 99% for 30 minutes, fire a warning.

59
01:22:44,000 --> 01:22:52,000
```
- alert: SLOIngestionFailureRate
  expr: |
    financial_rag:ingestion_success_rate:rate24h < 0.99
  for: 30m
  labels:
    severity: warning
    slo: ingestion
  annotations:
    summary: "SLO-3: Ingestion success rate below 99%"
    description: "Ingestion success rate: {{ $value | humanizePercentage }}. Check EDGAR API connectivity and SHA-256 dedup logic."
```

60
01:22:52,000 --> 01:23:00,000
Now let me show you the error budget remaining metric. This is a recording rule used in dashboards.

61
01:23:00,000 --> 01:23:08,000
```
- record: financial_rag:slo_availability:error_budget_remaining
  expr: |
    (1 - (financial_rag:api_error_rate:rate72h / 0.005)) * 100
```

62
01:23:08,000 --> 01:23:16,000
This calculates the percentage of error budget remaining. 100% means you haven't used any budget. 0% means you've exhausted the budget. This is the key metric for the SLO dashboard.

63
01:23:16,000 --> 01:23:24,000
We have two alerts for the error budget. One when it falls below 10%. One when it reaches 0%.

64
01:23:24,000 --> 01:23:32,000
```
- alert: SLOErrorBudgetAlmostExhausted
  expr: financial_rag:slo_availability:error_budget_remaining < 10
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Less than 10% of monthly error budget remaining"
    description: "{{ $value | humanize }}% of availability error budget remains this month."
```

65
01:23:32,000 --> 01:23:40,000
When you're down to 10% of your budget, you need to slow down deployments. You need to focus on stability. You're running low on your allowance for failure.

66
01:23:40,000 --> 01:23:48,000
```
- alert: SLOErrorBudgetExhausted
  expr: financial_rag:slo_availability:error_budget_remaining <= 0
  for: 0m
  labels:
    severity: critical
  annotations:
    summary: "Monthly error budget fully exhausted"
    description: "100% of the monthly availability error budget has been consumed. All remaining errors exceed the SLO."
```

67
01:23:48,000 --> 01:23:56,000
When your budget is exhausted, you can't have any more errors. Every additional error violates the SLO. This is a critical situation. You need to stop deploying and fix the issues.

68
01:23:56,000 --> 01:24:04,000
Now let me show you the cost per query metric. This is for the FinOps dashboard.

69
01:24:04,000 --> 01:24:12,000
```
- record: financial_rag:cost_per_query_cents:1h
  expr: |
    (financial_rag_llm_cost_usd_total + financial_rag_infra_cost_usd_total)
    /
    financial_rag_queries_total * 100
```

70
01:24:12,000 --> 01:24:20,000
This combines LLM cost and infrastructure cost. It divides by the number of queries. It gives the cost per query in cents. This is the key metric for the FinOps team.

71
01:24:20,000 --> 01:24:28,000
If the cost per query goes up, you need to investigate. Are you using a more expensive model? Are you retrieving more chunks? Is the infrastructure cost increasing? This metric helps you track efficiency.

72
01:24:28,000 --> 01:24:36,000
Now let's apply the recording rules and alerts. These will be loaded by the Prometheus operator.

73
01:24:36,000 --> 01:24:44,000
kubectl apply -f observability/slo/slo-rules.yaml
kubectl apply -f observability/slo/slo-alerts.yaml

74
01:24:44,000 --> 01:24:52,000
Wait a few minutes for Prometheus to load the new rules. Prometheus scrapes for new rules every minute. It will take a moment to register them.

75
01:24:52,000 --> 01:25:00,000
Check the rules. `kubectl get prometheusrules -n monitoring`. You should see the financial-rag-slos PrometheusRule. This contains all the recording rules and alerts.

76
01:25:00,000 --> 01:25:08,000
Now let's verify the rules are working. Open Prometheus. Port-forward the Prometheus service.

77
01:25:08,000 --> 01:25:16,000
kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090

78
01:25:16,000 --> 01:25:24,000
Open http://localhost:9090/targets. Check that all targets are up. Then go to Status -> Rules. You should see the financial_rag recording rules.

79
01:25:24,000 --> 01:25:32,000
Check the alerts. In the Prometheus UI, go to Alerts. You should see the SLO alerts. SLOAvailabilityFastBurn. SLOAvailabilitySlowBurn. SLOErrorBudgetAlmostExhausted.

80
01:25:32,000 --> 01:25:40,000
The alerts will be inactive until triggered. That's good. It means we are within our SLO. Everything is healthy.

81
01:25:40,000 --> 01:25:48,000
Now let me show you the error budget dashboard in Grafana. Port-forward Grafana.

82
01:25:48,000 --> 01:25:56,000
kubectl port-forward -n observability svc/grafana 3000:3000

83
01:25:56,000 --> 01:26:04,000
Open http://localhost:3000. Go to Explore. Select the Prometheus data source.

84
01:26:04,000 --> 01:26:12,000
Query `financial_rag:slo_availability:error_budget_remaining`. This shows the percentage of error budget remaining. It should be near 100% if everything is healthy.

85
01:26:12,000 --> 01:26:20,000
Query `financial_rag:api_error_rate:rate1h`. This shows the current error rate. It should be near 0% in a healthy system.

86
01:26:20,000 --> 01:26:28,000
Query `financial_rag:query_latency_error_rate:rate1h`. This shows the percentage of slow queries. It should be below 5%.

87
01:26:28,000 --> 01:26:36,000
Query `financial_rag:ingestion_success_rate:rate24h`. This shows the ingestion success rate. It should be above 99%.

88
01:26:36,000 --> 01:26:44,000
Now let me show you how to build a complete SLO dashboard. This is what you'll use every day to monitor your system.

89
01:26:44,000 --> 01:26:52,000
Create a new dashboard in Grafana. Add a panel for the error budget remaining. This is a gauge. It shows the percentage of budget left.

90
01:26:52,000 --> 01:27:00,000
Add a panel for the error rate. This is a graph. It shows the error rate over time. You can see trends and spikes.

91
01:27:00,000 --> 01:27:08,000
Add a panel for the latency. This is a graph. It shows the P99 latency over time. You can see if it's trending up.

92
01:27:08,000 --> 01:27:16,000
Add a panel for the ingestion success rate. This is a graph. It shows the success rate over time. You can see if it's dropping.

93
01:27:16,000 --> 01:27:24,000
This dashboard gives you everything you need. You can see if you're within your SLOs. You can see if you need to take action.

94
01:27:24,000 --> 01:27:32,000
Now let me simulate a failure to test the alerts. We'll introduce a 10% error rate on the API. This is a demonstration. Do not do this in production.

95
01:27:32,000 --> 01:27:40,000
We'll use a test endpoint that intentionally fails. This simulates a real outage. It lets us see the alerts in action.

96
01:27:40,000 --> 01:27:48,000
After introducing the error rate, wait a few minutes. The error rate will increase. The fast burn alert will trigger.

97
01:27:48,000 --> 01:27:56,000
Check Prometheus alerts. You should see SLOAvailabilityFastBurn firing. Check Slack. You should see the alert message. Check PagerDuty. You should see an incident created.

98
01:27:56,000 --> 01:28:04,000
The alert message in Slack will say: "SLO-1 CRITICAL: API availability fast burn rate. Error rate: 7.5%. Burn rate: 14.4x. At this rate the monthly error budget will be exhausted in 1 hour. Immediate action required."

99
01:28:04,000 --> 01:28:12,000
This is the complete alerting pipeline. Falco detects the error. Prometheus calculates the error rate. Alertmanager routes the alert. Slack gets the message. PagerDuty gets the incident.

100
01:28:12,000 --> 01:28:20,000
The on-call engineer gets paged. They investigate. They find the cause. They fix it. The error rate drops. The alert resolves.

101
01:28:20,000 --> 01:28:28,000
This is the SRE lifecycle. Define SLOs. Measure error rates. Alert on fast burn. Investigate and fix. Learn and improve.

102
01:28:28,000 --> 01:28:36,000
Let me explain what happens when an alert fires. The alert sends to Alertmanager. Alertmanager routes to Slack and PagerDuty.

103
01:28:36,000 --> 01:28:44,000
Slack gets a message. PagerDuty gets an incident. The on-call engineer gets a notification. They acknowledge the alert. They start investigating.

104
01:28:44,000 --> 01:28:52,000
The engineer looks at the dashboard. They see the error rate. They look at the traces. They see which request is failing. They look at the logs. They see the error message.

105
01:28:52,000 --> 01:29:00,000
They find the cause. They fix it. They deploy the fix. The error rate drops. The alert resolves. The incident is closed.

106
01:29:00,000 --> 01:29:08,000
This whole process takes minutes, not hours. Because the system is observable. Because the alerts are actionable. Because the team knows what to do.

107
01:29:08,000 --> 01:29:16,000
Now let me share some best practices for SLOs. These are lessons learned from running production systems at scale.

108
01:29:16,000 --> 01:29:24,000
Start with a conservative SLO. 99.5% is good for a new system. You can always increase it later. It's better to under-promise and over-deliver.

109
01:29:24,000 --> 01:29:32,000
Monitor your error budget usage. If you're consistently using less than 50% of your budget, you can consider increasing the SLO. If you're consistently using more than 80%, you need to improve reliability.

110
01:29:32,000 --> 01:29:40,000
Review your SLOs quarterly. As your system evolves, your SLOs should evolve too. New features, new users, new requirements. Keep them current.

111
01:29:40,000 --> 01:29:48,000
Use the error budget to guide deployment decisions. If you have a full budget, you can deploy aggressively. If you have a depleted budget, you should slow down and focus on stability.

112
01:29:48,000 --> 01:29:56,000
This is the essence of SRE. It's not about preventing all failures. It's about managing risk. It's about making informed decisions. It's about balancing innovation and reliability.

113
01:29:56,000 --> 01:30:04,000
Now let me recap what we have covered in Part 4.

114
01:30:04,000 --> 01:30:12,000
We defined three SLOs. API availability at 99.5%. Query latency P99 under 120 seconds for 95% of requests. Ingestion success rate at 99%.

115
01:30:12,000 --> 01:30:20,000
We built recording rules. We calculated error rates over 1-hour, 6-hour, 24-hour, and 72-hour windows. These are the building blocks of SLO alerting.

116
01:30:20,000 --> 01:30:28,000
We built multi-window burn-rate alerts. Two tiers. Critical pages immediately. Warning alerts you to investigate today. This is the Google SRE methodology.

117
01:30:28,000 --> 01:30:36,000
We applied the rules. We verified them in Prometheus. We saw them in Grafana. The rules are loaded and working.

118
01:30:36,000 --> 01:30:44,000
We simulated a failure. We saw the alert fire. We understood the investigation loop. The alerts are actionable and effective.

119
01:30:44,000 --> 01:30:52,000
We shared best practices. Start conservative. Monitor usage. Review quarterly. Use the error budget to guide decisions.

120
01:30:52,000 --> 01:31:00,000
This is SRE. This is how you manage reliability at scale. You choose your tolerance for failure. You measure against it. You alert when you exceed it.

121
01:31:00,000 --> 01:31:08,000
In Part 5, we set up ArgoCD notifications and OPA Rego policies. We complete the GitOps and policy-as-code stack. This is the final part of Phase 11.

122
01:31:08,000 --> 01:31:16,000
Thank you for following along. I'll see you in Part 5.

123
01:31:16,000 --> 01:31:20,000
[End of Part 4]
```

# Phase 11: Observability & Governance — Part 5 (01:40:00 - 02:00:00)

## ArgoCD Notifications & OPA Rego Policies — Complete SRT Script

```srt
1
01:40:00,000 --> 01:40:08,000
Welcome back to Phase 11. This is Part 5. This is where we add the final pieces of our observability and governance stack. This is where we bring everything together.

2
01:40:08,000 --> 01:40:16,000
We have the LGTM stack. We have OpenTelemetry. We have SLOs and alerts. We have dashboards and traces. But we're missing two things that are absolutely critical for operating at scale.

3
01:40:16,000 --> 01:40:24,000
First, ArgoCD notifications. When a deployment succeeds or fails, we want to know. We want Slack messages. We want PagerDuty alerts. We want to know immediately, not when someone happens to check the ArgoCD UI.

4
01:40:24,000 --> 01:40:32,000
Second, OPA Rego policies. We want to enforce rules at the code level. Before code reaches the cluster, we check it. This is policy-as-code. This is how we prevent mistakes from ever reaching production.

5
01:40:32,000 --> 01:40:40,000
Let me show you what we are building. This is the complete notification and policy pipeline.

6
01:40:40,000 --> 01:40:48,000
ArgoCD detects a sync event. Sync succeeded. Sync failed. Health degraded. It sends an event to the notification controller. The controller processes the event. It routes to Slack for warnings. It routes to PagerDuty for critical failures. The team gets immediate feedback on deployment status.

7
01:40:48,000 --> 01:40:56,000
At the same time, a developer writes a Helm chart. They push to GitHub. Conftest runs in CI. It checks the Helm templates against OPA policies. If the policy passes, the chart is merged. If it fails, the PR is blocked. The policy also runs at admission time. Gatekeeper enforces it in the cluster.

8
01:40:56,000 --> 01:41:04,000
This is the complete governance loop. Policies prevent mistakes. Notifications tell you when something happens. Together, they give you confidence to deploy at scale.

9
01:41:04,000 --> 01:41:12,000
First, let's configure ArgoCD notifications. Open `argocd/notifications/templates.yaml` in your editor. This file defines three things. The notification services. The templates. The triggers.

10
01:41:12,000 --> 01:41:20,000
Let me walk through the services section. This is where we configure where notifications go.

11
01:41:20,000 --> 01:41:28,000
service.slack:
  token: $slack-token
  username: ArgoCD
  icon: ":argo:"

12
01:41:28,000 --> 01:41:36,000
The Slack service uses a token stored in a Kubernetes secret. The secret is created by the bootstrap script. It contains the Slack webhook URL. This is how ArgoCD sends messages to Slack.

13
01:41:36,000 --> 01:41:44,000
service.pagerduty:
  serviceKeys:
    prod-oncall: $pagerduty-prod-key

14
01:41:44,000 --> 01:41:52,000
The PagerDuty service uses a routing key. Only critical events go to PagerDuty. This prevents alert fatigue. You don't want to be paged for every sync. Only the ones that matter.

15
01:41:52,000 --> 01:42:00,000
Now the templates. These define the format of the notifications. This is what people will see in Slack. Make it clear. Make it actionable. Make it useful.

16
01:42:00,000 --> 01:42:08,000
template.app-sync-succeeded:
  slack:
    attachments: |
      [{
        "color": "#18be52",
        "title": "✅ {{.app.metadata.name}} synced",
        "fields": [
          {"title": "Environment", "value": "{{.app.metadata.labels.environment}}", "short": true},
          {"title": "Revision", "value": "{{.app.status.sync.revision}}", "short": true}
        ]
      }]

17
01:42:08,000 --> 01:42:16,000
The sync-succeeded template creates a green Slack message. It shows the app name, environment, and revision. The green color indicates success. This gives immediate positive feedback to the developer. They know their deployment worked. They can move on to the next task.

18
01:42:16,000 --> 01:42:24,000
template.app-sync-failed:
  slack:
    attachments: |
      [{
        "color": "#e51b00",
        "title": "❌ {{.app.metadata.name}} sync FAILED",
        "fields": [
          {"title": "Environment", "value": "{{.app.metadata.labels.environment}}", "short": true},
          {"title": "Error", "value": "{{.app.status.operationState.message}}", "short": false}
        ]
      }]
  pagerduty:
    summary: "ArgoCD sync failed: {{.app.metadata.name}}"
    severity: error

19
01:42:24,000 --> 01:42:32,000
The sync-failed template creates a red Slack message. It includes the error message. This is critical. The developer needs to know why the deployment failed. It also triggers a PagerDuty alert. This is a critical event. Someone needs to fix this now.

20
01:42:32,000 --> 01:42:40,000
template.app-health-degraded:
  slack:
    attachments: |
      [{
        "color": "#f4c030",
        "title": "⚠️ {{.app.metadata.name}} health DEGRADED",
        "fields": [
          {"title": "Health", "value": "{{.app.status.health.status}}", "short": true}
        ]
      }]
  pagerduty:
    summary: "App degraded: {{.app.metadata.name}}"
    severity: warning

21
01:42:40,000 --> 01:42:48,000
The health-degraded template creates a yellow Slack message. It shows the health status. It also triggers a PagerDuty warning. This is less critical but still requires attention. The app is running but something is wrong. Investigate before it becomes a critical failure.

22
01:42:48,000 --> 01:42:56,000
Now the triggers. These define when notifications are sent. This is the logic that decides what event triggers which notification.

23
01:42:56,000 --> 01:43:04,000
trigger.on-sync-succeeded:
  - when: app.status.operationState.phase in ['Succeeded']
    send: [app-sync-succeeded]

24
01:43:04,000 --> 01:43:12,000
trigger.on-sync-failed:
  - when: app.status.operationState.phase in ['Error', 'Failed']
    send: [app-sync-failed]

25
01:43:12,000 --> 01:43:20,000
trigger.on-health-degraded:
  - when: app.status.health.status == 'Degraded'
    send: [app-health-degraded]

26
01:43:20,000 --> 01:43:28,000
defaultTriggers:
  - on-sync-failed
  - on-health-degraded

27
01:43:28,000 --> 01:43:36,000
The default triggers apply to all applications. Sync failures and health degradation always send notifications. Success notifications are opt-in. This ensures critical failures are never missed.

28
01:43:36,000 --> 01:43:44,000
Now let's apply the notification templates.

29
01:43:44,000 --> 01:43:52,000
kubectl apply -f argocd/notifications/templates.yaml

30
01:43:52,000 --> 01:44:00,000
This creates the ConfigMap in the argocd namespace. ArgoCD watches this ConfigMap. It automatically picks up changes. You don't need to restart anything. It's hot-reload.

31
01:44:00,000 --> 01:44:08,000
Now let's test the notifications. Trigger a sync of the dev application.

32
01:44:08,000 --> 01:44:16,000
argocd app sync financial-rag-dev

33
01:44:16,000 --> 01:44:24,000
Check Slack. You should see a green message. "financial-rag-dev synced". Environment: dev. Revision: HEAD. This is the positive feedback loop. The developer knows their change is live.

34
01:44:24,000 --> 01:44:32,000
Now trigger a failure. Break the Helm chart. Remove a required field. Commit and push. The app will go OutOfSync.

35
01:44:32,000 --> 01:44:40,000
Check Slack. You should see a red message. "financial-rag-dev sync FAILED". Error: "field is immutable". This is the critical alert. Someone needs to fix this. The on-call engineer gets a PagerDuty notification.

36
01:44:40,000 --> 01:44:48,000
This is the feedback loop. Developers know immediately when a deployment fails. They don't need to check the ArgoCD UI. They get a Slack message. They can investigate immediately. The on-call engineer gets paged if it's critical.

37
01:44:48,000 --> 01:44:56,000
Now let's move to OPA Rego policies. This is policy-as-code. We write rules that enforce standards. This is how we prevent mistakes before they happen.

38
01:44:56,000 --> 01:45:04,000
A developer writes a Helm chart. It has a container with the :latest tag. Conftest runs in CI. It evaluates the policy. The policy says :latest is not allowed. The PR is blocked. The developer fixes the tag. Conftest passes. The PR is merged.

39
01:45:04,000 --> 01:45:12,000
This is policy-as-code. It catches mistakes before they reach production. It saves time. It prevents outages. It enforces standards automatically. It's the ultimate gatekeeper.

40
01:45:12,000 --> 01:45:20,000
Open `policies/rego/k8s_admission.rego` in your editor. This is the admission policy for Kubernetes pods. Let me walk through the rules.

41
01:45:20,000 --> 01:45:28,000
The first rule denies :latest image tags. This is the most common mistake. Developers often forget to tag their images.

42
01:45:28,000 --> 01:45:36,000
deny contains msg if {
  container := input.review.object.spec.containers[_]
  endswith(container.image, ":latest")
  msg := sprintf("Container '%v' uses ':latest' tag. Pin to an immutable SHA or semver tag.", [container.name])
}

43
01:45:36,000 --> 01:45:44,000
This rule checks every container image. If it ends with :latest, the policy denies it. The message tells the developer exactly what to fix. "Pin to an immutable SHA or semver tag."

44
01:45:44,000 --> 01:45:52,000
Why is :latest dangerous? Because it changes. Today it might be version 1.0. Tomorrow it might be version 1.1. If you deploy twice, you get different versions. You can't reproduce bugs. You can't rollback safely. This is why :latest is forbidden in production.

45
01:45:52,000 --> 01:46:00,000
The second rule requires resource requests and limits. This is essential for the Horizontal Pod Autoscaler and cluster stability.

46
01:46:00,000 --> 01:46:08,000
deny contains msg if {
  container := input.review.object.spec.containers[_]
  not container.resources.requests.cpu
  msg := sprintf("Container '%v' missing resources.requests.cpu. HPA cannot function without CPU requests.", [container.name])
}

47
01:46:08,000 --> 01:46:16,000
This rule checks for CPU requests. Without requests, the Horizontal Pod Autoscaler cannot function. It doesn't know how much CPU each pod is using. It can't scale properly. The scheduler also can't make placement decisions.

48
01:46:16,000 --> 01:46:24,000
The third rule requires readOnlyRootFilesystem. This is a security best practice.

49
01:46:24,000 --> 01:46:32,000
deny contains msg if {
  container := input.review.object.spec.containers[_]
  not container.securityContext.readOnlyRootFilesystem == true
  msg := sprintf("Container '%v': securityContext.readOnlyRootFilesystem must be true. Use emptyDir for writable paths.", [container.name])
}

50
01:46:32,000 --> 01:46:40,000
This rule enforces the security baseline. All containers must have readOnlyRootFilesystem. This prevents post-exploit persistence. If an attacker gets in, they can't write to the filesystem. They can't install malware. They can't persist.

51
01:46:40,000 --> 01:46:48,000
The fourth rule requires allowPrivilegeEscalation to be false.

52
01:46:48,000 --> 01:46:56,000
deny contains msg if {
  container := input.review.object.spec.containers[_]
  not container.securityContext.allowPrivilegeEscalation == false
  msg := sprintf("Container '%v': securityContext.allowPrivilegeEscalation must be false.", [container.name])
}

53
01:46:56,000 --> 01:47:04,000
This prevents setuid binaries from escalating privileges. It blocks a common container escape technique. If an attacker finds a vulnerability in your application, they can't escalate to root. The container stays contained.

54
01:47:04,000 --> 01:47:12,000
The fifth rule requires capabilities to be dropped.

55
01:47:12,000 --> 01:47:20,000
deny contains msg if {
  container := input.review.object.spec.containers[_]
  not container.securityContext.capabilities.drop
  msg := sprintf("Container '%v': securityContext.capabilities.drop must be set. Require drop: [ALL].", [container.name])
}

56
01:47:20,000 --> 01:47:28,000
This rule requires ALL capabilities to be dropped. No container needs capabilities in production. This reduces the attack surface. Less capabilities means less attack surface. It's that simple.

57
01:47:28,000 --> 01:47:36,000
Now open `policies/rego/helm_policy.rego`. This is the policy for Helm manifests. It catches Kubernetes API version issues.

58
01:47:36,000 --> 01:47:44,000
The first rule denies deprecated API versions. This is important for upgrading Kubernetes.

59
01:47:44,000 --> 01:47:52,000
removed_apis := {
  "flowcontrol.apiserver.k8s.io/v1beta1",
  "flowcontrol.apiserver.k8s.io/v1beta2",
  "autoscaling/v2beta1",
  "autoscaling/v2beta2",
  "batch/v1beta1"
}
deny contains msg if {
  input.apiVersion
  removed_apis[input.apiVersion]
  msg := sprintf("Resource '%v' uses removed API version '%v' — not supported in Kubernetes 1.29+.", [input.metadata.name, input.apiVersion])
}

60
01:47:52,000 --> 01:48:00,000
This rule catches deprecated APIs. If you use an old API version, the policy denies it. This prevents failed upgrades. When you upgrade Kubernetes, your manifests will still work. This is proactive governance.

61
01:48:00,000 --> 01:48:08,000
The second rule requires HPA to use autoscaling/v2.

62
01:48:08,000 --> 01:48:16,000
deny contains msg if {
  input.kind == "HorizontalPodAutoscaler"
  input.apiVersion == "autoscaling/v1"
  msg := sprintf("HPA '%v' uses autoscaling/v1 — must use autoscaling/v2 for CPU+memory dual-metric scaling.", [input.metadata.name])
}

63
01:48:16,000 --> 01:48:24,000
autoscaling/v2 supports multiple metrics. autoscaling/v2 supports custom metrics. autoscaling/v1 is limited to CPU. This rule enforces the better API. It's a quality check.

64
01:48:24,000 --> 01:48:32,000
Now open `policies/rego/terraform_policy.rego`. This is the policy for Terraform infrastructure. It catches security issues in infrastructure code.

65
01:48:32,000 --> 01:48:40,000
The first rule requires S3 buckets to block public access.

66
01:48:40,000 --> 01:48:48,000
deny contains msg if {
  resource := input.planned_values.root_module.resources[_]
  resource.type == "aws_s3_bucket_public_access_block"
  resource.values.block_public_acls != true
  msg := sprintf("S3 bucket '%v' does not block public ACLs — all buckets must block public access.", [resource.name])
}

67
01:48:48,000 --> 01:48:56,000
This rule checks the S3 public access block. If it's not configured, the policy denies it. This prevents accidental public exposure. Your data stays private. This is a critical security control.

68
01:48:56,000 --> 01:49:04,000
The second rule requires RDS encryption.

69
01:49:04,000 --> 01:49:12,000
deny contains msg if {
  resource := input.planned_values.root_module.resources[_]
  resource.type == "aws_db_instance"
  not resource.values.storage_encrypted == true
  msg := sprintf("RDS instance '%v' storage_encrypted must be true.", [resource.name])
}

70
01:49:12,000 --> 01:49:20,000
This rule requires RDS encryption at rest. Financial data must be encrypted. The policy enforces this. You can't accidentally create an unencrypted database. Compliance is baked into the process.

71
01:49:20,000 --> 01:49:28,000
Now let's test the policies. First, install conftest.

72
01:49:28,000 --> 01:49:36,000
brew install conftest

73
01:49:36,000 --> 01:49:44,000
Run the admission policy tests.

74
01:49:44,000 --> 01:49:52,000
conftest verify --policy policies/rego/ --namespace financial_rag

75
01:49:52,000 --> 01:50:00,000
The tests are in `policies/tests/k8s_admission_test.rego`. They verify that the policies work correctly. Let me show you a test.

76
01:50:00,000 --> 01:50:08,000
test_deny_latest_tag if {
  result := admission.deny with input as {
    "review": {"object": {
      "spec": {"containers": [{"image": "my-image:latest"}]}
    }}
  }
  count(result) > 0
  some msg in result
  contains(msg, ":latest")
}

77
01:50:08,000 --> 01:50:16,000
This test creates a pod with a :latest tag. It asserts that the policy denies it. The test passes if the policy works. This gives us confidence in our policies. We can refactor with confidence.

78
01:50:16,000 --> 01:50:24,000
Now test the Helm policy.

79
01:50:24,000 --> 01:50:32,000
helm template infrastructure/helm/ -f infrastructure/helm/values.yaml | conftest test - --policy policies/rego/

80
01:50:32,000 --> 01:50:40,000
This renders the Helm templates and passes them to conftest. The policy evaluates the generated manifests. If any deny rule triggers, the test fails. The developer fixes the issue.

81
01:50:40,000 --> 01:50:48,000
Now test the Terraform policy.

82
01:50:48,000 --> 01:50:56,000
cd infrastructure/terraform/environments/prod/vpc
terragrunt plan -out plan.out
terraform show -json plan.out | conftest test - --policy policies/rego/

83
01:50:56,000 --> 01:51:04,000
This runs Terraform plan, converts it to JSON, and passes it to conftest. The policy evaluates the infrastructure changes. If you try to create an unencrypted RDS, the policy will fail. The PR is blocked.

84
01:51:04,000 --> 01:51:12,000
Now let me show you the CI integration. In `.github/workflows/ci.yml`, we added a conftest step.

85
01:51:12,000 --> 01:51:20,000
- name: OPA policy check
  run: |
    curl -L https://github.com/open-policy-agent/conftest/releases/download/v0.50.0/conftest_0.50.0_Linux_x86_64.tar.gz | tar xz -C /usr/local/bin
    conftest test policies/test_fixtures/ --policy policies/rego/

86
01:51:20,000 --> 01:51:28,000
This step runs in CI. It catches policy violations before the code is merged. The PR is blocked if any policy fails. This is how we enforce standards automatically.

87
01:51:28,000 --> 01:51:36,000
Let me show you what happens when a policy fails in CI. The developer gets a message. "Container 'api' uses ':latest' tag. Pin to an immutable SHA or semver tag." They fix it. They push again. The policy passes. The PR is merged.

88
01:51:36,000 --> 01:51:44,000
This is the beauty of policy-as-code. It prevents mistakes before they happen. It saves time. It reduces frustration. It improves quality. It's a win-win.

89
01:51:44,000 --> 01:51:52,000
Now let me explain the difference between deny and warn. Deny blocks the PR. Warn only reports the issue.

90
01:51:52,000 --> 01:52:00,000
warn contains msg if {
  container := input.review.object.spec.containers[_]
  not container.livenessProbe
  msg := sprintf("Container '%v' has no livenessProbe. Unhealthy pods will not be restarted automatically.", [container.name])
}

91
01:52:00,000 --> 01:52:08,000
This rule warns about missing liveness probes. It doesn't block the PR. It's a best practice recommendation, not a requirement. The developer can choose to ignore it.

92
01:52:08,000 --> 01:52:16,000
We use deny for security-critical things. :latest tags. Missing resource requests. Missing security contexts. These are non-negotiable.

93
01:52:16,000 --> 01:52:24,000
We use warn for best practices. Missing liveness probes. Missing readiness probes. These are important but not security-critical.

94
01:52:24,000 --> 01:52:32,000
Now let me show you the complete governance loop. This is how policies and notifications work together.

95
01:52:32,000 --> 01:52:40,000
A developer writes code. They push to GitHub. CI runs. Conftest checks the policies. If the policies pass, the code is merged. If they fail, the PR is blocked.

96
01:52:40,000 --> 01:52:48,000
ArgoCD detects the new commit. It syncs the application. If the sync succeeds, Slack gets a green message. If the sync fails, Slack gets a red message. PagerDuty gets a critical alert.

97
01:52:48,000 --> 01:52:56,000
If the application health degrades, Slack gets a yellow message. PagerDuty gets a warning. The team investigates. They fix the issue. The health recovers.

98
01:52:56,000 --> 01:53:04,000
This is the complete governance loop. Policies prevent mistakes. Notifications tell you what happened. Together, they give you control over your infrastructure.

99
01:53:04,000 --> 01:53:12,000
Now let me recap what we have covered in this entire Phase 11.

100
01:53:12,000 --> 01:53:20,000
Part 1: The LGTM Stack & OpenTelemetry. We installed Loki for logs. Grafana for visualization. Tempo for traces. Mimir for long-term metrics. We understood the three pillars of observability.

101
01:53:20,000 --> 01:53:28,000
Part 2: Tracer Provider & Custom RAG Spans. We created the telemetry package. We configured the tracer provider. We added custom RAG spans for embedding, search, and LLM calls. We wired everything into the application.

102
01:53:28,000 --> 01:53:36,000
Part 3: OpenTelemetry Collector & Structured Logging. We deployed the Collector. We configured tail sampling. We enabled structured JSON logging. We implemented trace-to-log correlation.

103
01:53:36,000 --> 01:53:44,000
Part 4: SLOs & Multi-Window Burn-Rate Alerts. We defined three SLOs. API availability at 99.5%. Query latency P99 under 120 seconds for 95% of requests. Ingestion success rate at 99%. We built recording rules. We implemented multi-window burn-rate alerts.

104
01:53:44,000 --> 01:53:52,000
Part 5: ArgoCD Notifications & OPA Rego Policies. We configured ArgoCD notifications. Slack for all events. PagerDuty for critical failures. We wrote OPA Rego policies. k8s_admission for pod security. helm_policy for Helm manifests. terraform_policy for infrastructure.

105
01:53:52,000 --> 01:54:00,000
We tested the policies with conftest. We integrated them into CI. We understood the difference between deny and warn. Deny blocks. Warn reports.

106
01:54:00,000 --> 01:54:08,000
This is the complete observability and governance stack. From logs to metrics to traces. From SLOs to alerts to policies. From development to production.

107
01:54:08,000 --> 01:54:16,000
This is what it means to operate a production system at scale. You have visibility. You have control. You have confidence. You can sleep at night knowing your system is monitored and protected.

108
01:54:16,000 --> 01:54:24,000
Let me share my final thoughts on the entire Financial RAG Agent series.

109
01:54:24,000 --> 01:54:32,000
We started with a simple Python script. We built a multi-agent RAG system. We added SEC EDGAR ingestion. We added hybrid search. We added LLM reasoning.

110
01:54:32,000 --> 01:54:40,000
We containerized the application. We deployed it to Kubernetes. We added Cilium for network security. We added Istio for service mesh. We added Falco for runtime security. We added the LGTM stack for observability.

111
01:54:40,000 --> 01:54:48,000
We built CI/CD with ArgoCD. We managed infrastructure with Terraform. We enforced policies with OPA. We monitored SLOs with Prometheus.

112
01:54:48,000 --> 01:54:56,000
This is a complete production system. It is secure. It is scalable. It is maintainable. It is observable. It is governed.

113
01:54:56,000 --> 01:55:04,000
This is what it takes to build modern AI applications. It's not just about the model. It's about the entire stack. The infrastructure. The security. The observability. The governance.

114
01:55:04,000 --> 01:55:12,000
You now have the skills to build, deploy, and operate production-grade AI systems. This is a rare and valuable skill. Use it wisely.

115
01:55:12,000 --> 01:55:20,000
Thank you for following along from Phase 1 to Phase 11. This has been an incredible journey. We built something real. Something production-ready. Something that solves a real problem.

116
01:55:20,000 --> 01:55:28,000
What comes next? You have a working system. Now you can extend it. Add more data sources. Add more agents. Add more features. The foundation is solid. The rest is up to you.

117
01:55:28,000 --> 01:55:36,000
If you want to learn more about specific topics, check out the resources in the description. The JSM Masterclass experience covers all of this in even more depth. With mentors. With real projects. With job placement support.

118
01:55:36,000 --> 01:55:44,000
If this video reaches 20,000 likes, I'll record a bonus phase. Phase 12. Production hardening. Kubecost for FinOps. VPA for right-sizing. Velero for backup. The production readiness checklist.

119
01:55:44,000 --> 01:55:52,000
Subscribe to the channel. Turn on the notification bell. Join the Discord. The link is in the description. 18,000 members and growing. We have a forum for the Financial RAG Agent. You can ask questions. You can get answers. You can help others.

120
01:55:52,000 --> 01:56:00,000
Thank you again for watching. Thank you for building. Thank you for learning. This is how you become a software engineer. This is how you build things that matter.

121
01:56:00,000 --> 01:56:08,000
I'll see you in the next video.

122
01:56:08,000 --> 01:56:12,000
[End of Phase 11 and the Financial RAG Agent Series]
```

