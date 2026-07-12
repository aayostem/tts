1
00:00:00,000 --> 00:00:06,000
Welcome to Phase 9. This is where we build the network security layer for our Financial RAG Agent.

2
00:00:06,000 --> 00:00:12,000
We've deployed the application to EKS. But right now, pods can talk to anything. There are no restrictions. This is a security risk.

3
00:00:12,000 --> 00:00:18,000
Think of it like an office building. Without security, anyone can walk into any room. The CISO wouldn't allow that.

4
00:00:18,000 --> 00:00:24,000
We need to implement zero-trust networking. Zero-trust means: never trust, always verify. Every connection must be explicitly allowed.

5
00:00:24,000 --> 00:00:30,000
Cilium is our tool for this. It provides eBPF-based networking, security, and observability for Kubernetes.

6
00:00:30,000 --> 00:00:36,000
Let me show you why Cilium is special. Traditional Kubernetes network policies use iptables. They work at L3 and L4. They don't understand HTTP.

7
00:00:36,000 --> 00:00:42,000
Cilium uses eBPF. It works at the kernel level. It can enforce L3, L4, and L7 policies. It can see HTTP methods and paths.

8
00:00:42,000 --> 00:00:48,000
This is important. We want to allow the API to call the agent, but only on POST /infer. Not on any other path.

9
00:00:48,000 --> 00:00:54,000
Open your terminal. We'll install Cilium using the Helm chart.

10
00:00:54,000 --> 00:01:00,000
First, add the Cilium Helm repository.
[Types: helm repo add cilium https://helm.cilium.io/]

11
00:01:00,000 --> 00:01:06,000
This adds the official Cilium Helm chart repository. It contains the latest Cilium releases.

12
00:01:06,000 --> 00:01:12,000
[Types: helm repo update]

13
00:01:12,000 --> 00:01:18,000
Now let's create the Cilium namespace.
[Types: kubectl create namespace kube-system --dry-run=client -o yaml | kubectl apply -f -]

14
00:01:18,000 --> 00:01:24,000
Cilium runs in kube-system. This is the standard location for cluster-wide networking components.

15
00:01:24,000 --> 00:01:30,000
Now let's install Cilium with the required configuration.
[Types: helm upgrade --install cilium cilium/cilium --namespace kube-system --set kubeProxyReplacement=strict --set ipam.mode=kubernetes --set hubble.relay.enabled=true --set hubble.ui.enabled=true --set cluster.name=financial-rag-prod-cluster --set cluster.id=1 --set rollOutCiliumPods=true]

16
00:01:30,000 --> 00:01:36,000
Let me explain each setting. kubeProxyReplacement=strict enables full eBPF kube-proxy replacement. This means Cilium handles all service routing and load balancing in eBPF.

17
00:01:36,000 --> 00:01:42,000
ipam.mode=kubernetes uses the Kubernetes API for IP address management. This is the standard mode for EKS.

18
00:01:42,000 --> 00:01:48,000
hubble.relay.enabled=true and hubble.ui.enabled=true enable Hubble. Hubble provides flow visibility and service map. It's like a security camera for your network.

19
00:01:48,000 --> 00:01:54,000
cluster.name sets the cluster name. This is used for multi-cluster networking. cluster.id=1 sets the cluster ID. This must be unique per cluster.

20
00:01:54,000 --> 00:02:00,000
rollOutCiliumPods=true triggers a rollout of all Cilium pods. This ensures all Cilium components are running the latest version.

21
00:02:00,000 --> 00:02:06,000
Wait for Cilium to be ready.
[Types: kubectl wait --for=condition=ready pod -l k8s-app=cilium -n kube-system --timeout=300s]

22
00:02:06,000 --> 00:02:12,000
This command waits for all Cilium pods to be ready. It will time out after 5 minutes if they're not ready.

23
00:02:12,000 --> 00:02:18,000
[Types: kubectl get pods -n kube-system -l k8s-app=cilium]

24
00:02:18,000 --> 00:02:24,000
You should see Cilium pods running on each node. Each pod is the Cilium agent.

25
00:02:24,000 --> 00:02:30,000
Now let's verify the Cilium status.
[Types: kubectl exec -n kube-system -it $(kubectl get pods -n kube-system -l k8s-app=cilium -o name | head -1) -- cilium status]

26
00:02:30,000 --> 00:02:36,000
This shows the Cilium status. You should see everything is healthy. The kube-proxy replacement should be in Strict mode.

27
00:02:36,000 --> 00:02:42,000
Now let's verify Hubble is running.
[Types: kubectl port-forward -n kube-system svc/hubble-ui 12000:80]

28
00:02:42,000 --> 00:02:48,000
Open http://localhost:12000. You should see the Hubble UI. This shows the flow of traffic in your cluster.

29
00:02:48,000 --> 00:02:54,000
Now let's create our first network policy. The default-deny policy.

30
00:02:54,000 --> 00:03:00,000
Open your editor and create `cilium/network-policies/default-deny-all.yaml`.

31
00:03:00,000 --> 00:03:06,000
This is the most important policy. It blocks all traffic by default. Every connection must be explicitly allowed.

32
00:03:06,000 --> 00:03:12,000
[Types: apiVersion: "cilium.io/v2"]

33
00:03:12,000 --> 00:03:18,000
We use cilium.io/v2. This is the stable API version for CiliumNetworkPolicy.

34
00:03:18,000 --> 00:03:24,000
[Types: kind: CiliumNetworkPolicy]

35
00:03:24,000 --> 00:03:30,000
CiliumNetworkPolicy is the CRD that defines network policies. It's more powerful than standard Kubernetes NetworkPolicy.

36
00:03:30,000 --> 00:03:36,000
[Types: metadata: name: default-deny-all namespace: financial-rag]

37
00:03:36,000 --> 00:03:42,000
The policy applies to the financial-rag namespace. This is our application namespace.

38
00:03:42,000 --> 00:03:48,000
[Types: spec: endpointSelector: {}]

39
00:03:48,000 --> 00:03:54,000
An empty endpointSelector matches all pods in the namespace. This policy applies to everything.

40
00:03:54,000 --> 00:04:00,000
[Types: ingress: []]

41
00:04:00,000 --> 00:04:06,000
ingress: [] means no incoming traffic is allowed. All ingress traffic is blocked.

42
00:04:06,000 --> 00:04:12,000
[Types: egress: - toEndpoints: - matchLabels: k8s:io.kubernetes.pod.namespace: kube-system k8s-app: kube-dns toPorts: - ports: - port: "53" protocol: UDP - port: "53" protocol: TCP]

43
00:04:12,000 --> 00:04:18,000
We need one exception. DNS resolution must work. We allow egress traffic to CoreDNS in kube-system.

44
00:04:18,000 --> 00:04:24,000
CoreDNS runs on port 53. We allow both UDP and TCP. UDP is the default for DNS. TCP is used for large responses.

45
00:04:24,000 --> 00:04:30,000
This is the only allowed egress traffic. Everything else is blocked. This is true zero-trust.

46
00:04:30,000 --> 00:04:36,000
Now let's apply this policy.
[Types: kubectl apply -f cilium/network-policies/default-deny-all.yaml]

47
00:04:36,000 --> 00:04:42,000
This applies the policy to the cluster. All traffic in the financial-rag namespace is now blocked except DNS.

48
00:04:42,000 --> 00:04:48,000
This is a moment of truth. Our application should still work because we haven't applied any other policies yet.

49
00:04:48,000 --> 00:04:54,000
But if we try to make a request from the API to the agent, it will fail. Let's test this.

50
00:04:54,000 --> 00:05:00,000
[Types: kubectl exec -n financial-rag deploy/financial-rag-agent-api -- curl -s -o /dev/null -w "%{http_code}\n" http://financial-rag-agent-agent:8001/health]

51
00:05:00,000 --> 00:05:06,000
This should fail. The connection is blocked by the default-deny policy.

52
00:05:06,000 --> 00:05:12,000
Let me explain why we do this. Starting with default-deny forces us to be explicit about every connection. We must think about each connection and decide if it's needed.

53
00:05:12,000 --> 00:05:18,000
This is the principle of least privilege. Only the necessary connections are allowed. Everything else is denied.

54
00:05:18,000 --> 00:05:24,000
Now let's check the Hubble UI to see the blocked traffic.
[Types: kubectl port-forward -n kube-system svc/hubble-ui 12000:80]

55
00:05:24,000 --> 00:05:30,000
Open http://localhost:12000. You should see the blocked connections. They appear as red flows.

56
00:05:30,000 --> 00:05:36,000
This is powerful. We can see exactly what's being blocked. This helps us understand our application's dependencies.

57
00:05:36,000 --> 00:05:42,000
Now let's verify the Cilium installation one more time.

58
00:05:42,000 --> 00:05:48,000
[Types: kubectl exec -n kube-system -it $(kubectl get pods -n kube-system -l k8s-app=cilium -o name | head -1) -- cilium endpoint list]

59
00:05:48,000 --> 00:05:54,000
This shows all endpoints in the cluster. Each endpoint is a pod. You'll see the policy status for each endpoint.

60
00:05:54,000 --> 00:06:00,000
[Types: kubectl exec -n kube-system -it $(kubectl get pods -n kube-system -l k8s-app=cilium -o name | head -1) -- cilium policy get]

61
00:06:00,000 --> 00:06:06,000
This shows all active policies. You should see the default-deny policy.

62
00:06:06,000 --> 00:06:12,000
Now let me recap what we've built in Part 1.

63
00:06:12,000 --> 00:06:18,000
We installed Cilium with eBPF kube-proxy replacement. We enabled Hubble for flow visibility.

64
00:06:18,000 --> 00:06:24,000
We created the default-deny policy. This blocks all traffic except DNS.

65
00:06:24,000 --> 00:06:30,000
We verified the policy is working. Traffic between pods is blocked.

66
00:06:30,000 --> 00:06:36,000
This is the foundation of zero-trust networking. Every connection must be explicitly allowed.

67
00:06:36,000 --> 00:06:42,000
In Part 2, we'll create the L7 HTTP policies for the API and Agent. This will allow specific HTTP requests.

68
00:06:42,000 --> 00:06:48,000
We'll allow the API to call the agent only on POST /infer. No other paths. This is fine-grained security.

69
00:06:48,000 --> 00:06:54,000
Thank you for watching. I'll see you in Part 2.

70
00:06:54,000 --> 00:06:58,000
[End of Part 1]

1
00:00:00,000 --> 00:00:06,000
Welcome back to Phase 9. In Part 2, we build the Cilium L7 HTTP policies.

2
00:00:06,000 --> 00:00:12,000
In Part 1, we built the default-deny policy. That blocked all traffic. Now we open specific doors with precise rules.

3
00:00:12,000 --> 00:00:18,000
Think of L7 policies as bouncers at a nightclub. They check your ID, they check your invitation, and they decide if you get in.

4
00:00:18,000 --> 00:00:24,000
But instead of checking age, they check HTTP methods and paths. Instead of letting people in, they let HTTP requests through.

5
00:00:24,000 --> 00:00:30,000
Open your editor and create `cilium/network-policies/api-l7-policy.yaml`.

6
00:00:30,000 --> 00:00:36,000
We'll start with the apiVersion and kind.
[Types: apiVersion: "cilium.io/v2"]

7
00:00:36,000 --> 00:00:42,000
We use cilium.io/v2. This is the stable version for CiliumNetworkPolicy.

8
00:00:42,000 --> 00:00:48,000
[Types: kind: CiliumNetworkPolicy]

9
00:00:48,000 --> 00:00:54,000
CiliumNetworkPolicy is a custom resource that defines network policies for Cilium.

10
00:00:54,000 --> 00:01:00,000
Now the metadata section.
[Types: metadata: name: api-l7-policy]

11
00:01:00,000 --> 00:01:06,000
The name identifies this policy. It should be descriptive of what it does.

12
00:01:06,000 --> 00:01:12,000
[Types: namespace: financial-rag]

13
00:01:12,000 --> 00:01:18,000
This policy applies only to the financial-rag namespace. It doesn't affect other namespaces.

14
00:01:18,000 --> 00:01:24,000
Now the spec section. This defines who this policy applies to.
[Types: spec: endpointSelector: matchLabels: app.kubernetes.io/component: api]

15
00:01:24,000 --> 00:01:30,000
This policy applies to pods with the label app.kubernetes.io/component: api. That's our API pods.

16
00:01:30,000 --> 00:01:36,000
Now the ingress section. This defines what traffic is allowed in.
[Types: ingress:]

17
00:01:36,000 --> 00:01:42,000
Ingress rules control traffic coming into the API pods.

18
00:01:42,000 --> 00:01:48,000
The first rule allows traffic from the world. This is the ALB traffic.
[Types: - fromEntities: - world]

19
00:01:48,000 --> 00:01:54,000
fromEntities: world allows traffic from outside the cluster. This includes traffic from the AWS Load Balancer.

20
00:01:54,000 --> 00:02:00,000
[Types: toPorts: - ports: - port: "8000" protocol: TCP]

21
00:02:00,000 --> 00:02:06,000
This allows traffic on port 8000. That's the API port.

22
00:02:06,000 --> 00:02:12,000
Now the L7 rules. This is where the magic happens.
[Types: rules: http:]

23
00:02:12,000 --> 00:02:18,000
The http rules apply L7 filtering. Cilium inspects the HTTP request and decides if it's allowed.

24
00:02:18,000 --> 00:02:24,000
First rule: health check.
[Types: - method: "GET" path: "/health"]

25
00:02:24,000 --> 00:02:30,000
Only GET requests to /health are allowed. This is the liveness and readiness probe.

26
00:02:30,000 --> 00:02:36,000
Second rule: query endpoint.
[Types: - method: "POST" path: "/query"]

27
00:02:36,000 --> 00:02:42,000
Only POST requests to /query are allowed. This is the main RAG endpoint.

28
00:02:42,000 --> 00:02:48,000
Third rule: metrics endpoint.
[Types: - method: "GET" path: "/metrics"]

29
00:02:48,000 --> 00:02:54,000
Only GET requests to /metrics are allowed. This is for Prometheus scraping.

30
00:02:54,000 --> 00:03:00,000
Fourth rule: versioned API endpoints.
[Types: - method: "POST" path: "/v1/query" - method: "GET" path: "/v1/health"]

31
00:03:00,000 --> 00:03:06,000
These are the versioned endpoints. They match the unversioned ones but with /v1 prefix.

32
00:03:06,000 --> 00:03:12,000
Now let me explain what's not allowed. Any request that doesn't match these rules is blocked.

33
00:03:12,000 --> 00:03:18,000
GET /docs is blocked. POST /anything-else is blocked. This is the principle of least privilege.

34
00:03:18,000 --> 00:03:24,000
Now the second ingress rule. This is for Prometheus scraping.
[Types: - fromEndpoints: - matchLabels: k8s:io.kubernetes.pod.namespace: monitoring]

35
00:03:24,000 --> 00:03:30,000
This allows traffic from pods in the monitoring namespace. That's where Prometheus runs.

36
00:03:30,000 --> 00:03:36,000
[Types: toPorts: - ports: - port: "8000" protocol: TCP rules: http: - method: "GET" path: "/metrics"]

37
00:03:36,000 --> 00:03:42,000
Prometheus can only access /metrics. It can't access /health or /query.

38
00:03:42,000 --> 00:03:48,000
Now the egress section. This defines what traffic the API can send out.
[Types: egress:]

39
00:03:48,000 --> 00:03:54,000
Egress rules control traffic leaving the API pods.

40
00:03:54,000 --> 00:04:00,000
First egress rule: talk to the agent pool.
[Types: - toEndpoints: - matchLabels: app.kubernetes.io/component: agent]

41
00:04:00,000 --> 00:04:06,000
The API can send traffic to agent pods. This is for inference requests.

42
00:04:06,000 --> 00:04:12,000
[Types: toPorts: - ports: - port: "8001" protocol: TCP rules: http: - method: "POST" path: "/infer" - method: "POST" path: "/v1/infer"]

43
00:04:12,000 --> 00:04:18,000
The API can only POST to /infer or /v1/infer. This is the inference endpoint.

44
00:04:18,000 --> 00:04:24,000
Second egress rule: talk to pgvector.
[Types: - toEndpoints: - matchLabels: app.kubernetes.io/component: pgvector toPorts: - ports: - port: "5432" protocol: TCP]

45
00:04:24,000 --> 00:04:30,000
The API can connect to pgvector on port 5432. This is the PostgreSQL port. No HTTP rules here because it's not HTTP traffic.

46
00:04:30,000 --> 00:04:36,000
Third egress rule: talk to Redis.
[Types: - toEndpoints: - matchLabels: app.kubernetes.io/component: redis toPorts: - ports: - port: "6379" protocol: TCP]

47
00:04:36,000 --> 00:04:42,000
The API can connect to Redis on port 6379. This is the Redis port.

48
00:04:42,000 --> 00:04:48,000
Fourth egress rule: talk to external APIs.
[Types: - toEntities: - world toPorts: - ports: - port: "443" protocol: TCP]

49
00:04:48,000 --> 00:04:54,000
The API can connect to external services on port 443. This is HTTPS. This allows calls to OpenAI and Groq.

50
00:04:54,000 --> 00:05:00,000
Now let's create the agent L7 policy. Open `cilium/network-policies/agent-l7-policy.yaml`.

51
00:05:00,000 --> 00:05:06,000
[Types: apiVersion: "cilium.io/v2" kind: CiliumNetworkPolicy metadata: name: agent-l7-policy namespace: financial-rag]

52
00:05:06,000 --> 00:05:12,000
This policy applies to agent pods. The structure is similar to the API policy.

53
00:05:12,000 --> 00:05:18,000
[Types: spec: endpointSelector: matchLabels: app.kubernetes.io/component: agent]

54
00:05:18,000 --> 00:05:24,000
This applies to pods with the agent label. That's our agent pool.

55
00:05:24,000 --> 00:05:30,000
Now the ingress section.
[Types: ingress: - fromEndpoints: - matchLabels: app.kubernetes.io/component: api]

56
00:05:30,000 --> 00:05:36,000
The agent only accepts traffic from the API. No traffic from the outside world.

57
00:05:36,000 --> 00:05:42,000
[Types: toPorts: - ports: - port: "8001" protocol: TCP rules: http: - method: "POST" path: "/infer" - method: "POST" path: "/v1/infer" - method: "GET" path: "/health"]

58
00:05:42,000 --> 00:05:48,000
The agent accepts POST requests to /infer and /v1/infer. It also accepts GET requests to /health.

59
00:05:48,000 --> 00:05:54,000
[Types: - fromEndpoints: - matchLabels: k8s:io.kubernetes.pod.namespace: monitoring toPorts: - ports: - port: "8001" protocol: TCP rules: http: - method: "GET" path: "/metrics"]

60
00:05:54,000 --> 00:06:00,000
Prometheus can scrape the agent's /metrics endpoint. This gives us visibility into agent performance.

61
00:06:00,000 --> 00:06:06,000
Now the egress section.
[Types: egress: - toEndpoints: - matchLabels: app.kubernetes.io/component: pgvector toPorts: - ports: - port: "5432" protocol: TCP]

62
00:06:06,000 --> 00:06:12,000
The agent can talk to pgvector on port 5432. This is for retrieving chunks.

63
00:06:12,000 --> 00:06:18,000
[Types: - toEndpoints: - matchLabels: app.kubernetes.io/component: redis toPorts: - ports: - port: "6379" protocol: TCP]

64
00:06:18,000 --> 00:06:24,000
The agent can talk to Redis on port 6379. This is for caching.

65
00:06:24,000 --> 00:06:30,000
[Types: - toEntities: - world toPorts: - ports: - port: "443" protocol: TCP]

66
00:06:30,000 --> 00:06:36,000
The agent can talk to external APIs on port 443. This is for LLM calls.

67
00:06:36,000 --> 00:06:42,000
Now let's apply both policies.

68
00:06:42,000 --> 00:06:48,000
[Types: kubectl apply -f cilium/network-policies/api-l7-policy.yaml]

69
00:06:48,000 --> 00:06:54,000
[Types: kubectl apply -f cilium/network-policies/agent-l7-policy.yaml]

70
00:06:54,000 --> 00:07:00,000
Wait for the policies to be applied. Cilium propagates policies to all nodes.

71
00:07:00,000 --> 00:07:06,000
[Types: kubectl get ciliumnetworkpolicies -n financial-rag]

72
00:07:06,000 --> 00:07:12,000
You should see both policies. default-deny-all, api-l7-policy, and agent-l7-policy.

73
00:07:12,000 --> 00:07:18,000
Now let's test the L7 policies. Make a request to /health.

74
00:07:18,000 --> 00:07:24,000
[Types: curl -s -o /dev/null -w "%{http_code}\n" http://api-service:8000/health]

75
00:07:24,000 --> 00:07:30,000
This should return 200. The L7 policy allows GET /health.

76
00:07:30,000 --> 00:07:36,000
Now make a request to a blocked path.

77
00:07:36,000 --> 00:07:42,000
[Types: curl -s -o /dev/null -w "%{http_code}\n" -X POST http://api-service:8000/admin]

78
00:07:42,000 --> 00:07:48,000
This should return 403. The L7 policy blocks POST /admin because it's not in the allowed list.

79
00:07:48,000 --> 00:07:54,000
Now test the agent policy. Make a POST request to /infer.

80
00:07:54,000 --> 00:08:00,000
[Types: curl -s -o /dev/null -w "%{http_code}\n" -X POST http://agent-service:8001/infer]

81
00:08:00,000 --> 00:08:06,000
This should return 200 or 400 depending on the payload. The L7 policy allows POST /infer.

82
00:08:06,000 --> 00:08:12,000
Now let me explain the security benefits of L7 policies.

83
00:08:12,000 --> 00:08:18,000
L3/L4 policies block traffic at the IP and port level. They say "you can talk to this IP on this port."

84
00:08:18,000 --> 00:08:24,000
L7 policies go deeper. They say "you can make this HTTP method to this path."

85
00:08:24,000 --> 00:08:30,000
If an attacker compromises the API pod, they can't make arbitrary requests. They're limited to the allowed paths.

86
00:08:30,000 --> 00:08:36,000
This is defense in depth. Even if one layer fails, the other layers protect you.

87
00:08:36,000 --> 00:08:42,000
Now let's check the Hubble flow logs. This shows us the traffic.

88
00:08:42,000 --> 00:08:48,000
[Types: kubectl exec -n kube-system -l k8s-app=cilium -o name | head -1 - | xargs kubectl exec -n kube-system -- hubble observe --from-namespace financial-rag -t drop -t l7]

89
00:08:48,000 --> 00:08:54,000
This shows dropped traffic. You should see the blocked requests in the logs.

90
00:08:54,000 --> 00:09:00,000
Now let me recap what we've built in Part 2.

91
00:09:00,000 --> 00:09:06,000
We built the API L7 policy. It allows specific HTTP methods and paths from the ALB and Prometheus.

92
00:09:06,000 --> 00:09:12,000
It allows POST /query, GET /health, and GET /metrics. Everything else is blocked.

93
00:09:12,000 --> 00:09:18,000
We built the Agent L7 policy. It allows POST /infer from the API and GET /metrics from Prometheus.

94
00:09:18,000 --> 00:09:24,000
We applied both policies. We tested them with curl. We verified the blocking works.

95
00:09:24,000 --> 00:09:30,000
This is zero-trust networking. Every request is authenticated and authorized. Nothing is trusted by default.

96
00:09:30,000 --> 00:09:36,000
In Part 3, we'll deploy Istio for mTLS and service mesh capabilities.

97
00:09:36,000 --> 00:09:42,000
Thank you for watching. I'll see you in Part 3.

98
00:09:42,000 --> 00:09:46,000
[End of Part 2]

1
00:00:00,000 --> 00:00:06,000
Welcome back to Phase 9. In Part 3, we build the Cilium network policies.

2
00:00:06,000 --> 00:00:12,000
Cilium is our eBPF-based networking layer. It provides security, observability, and networking at the kernel level.

3
00:00:12,000 --> 00:00:18,000
Network policies are the firewall rules for your Kubernetes cluster. They control which pods can talk to which other pods.

4
00:00:18,000 --> 00:00:24,000
Think of network policies like security guards at the entrance of a building. They check IDs. They verify access. They block unauthorized entry.

5
00:00:24,000 --> 00:00:30,000
Open your editor and create `cilium/network-policies/default-deny-all.yaml`.

6
00:00:30,000 --> 00:00:36,000
We start with the API version. This is the CiliumNetworkPolicy CRD.
[Types: apiVersion: "cilium.io/v2"]

7
00:00:36,000 --> 00:00:42,000
CiliumNetworkPolicy is the custom resource that defines network policies in Cilium.

8
00:00:42,000 --> 00:00:48,000
Now the kind.
[Types: kind: CiliumNetworkPolicy]

9
00:00:48,000 --> 00:00:54,000
This is the kind that tells Kubernetes this is a Cilium-specific network policy.

10
00:00:54,000 --> 00:01:00,000
Now the metadata.
[Types: metadata: name: default-deny-all namespace: financial-rag]

11
00:01:00,000 --> 00:01:06,000
The policy is applied to the financial-rag namespace. This is where our application runs.

12
00:01:06,000 --> 00:01:12,000
Now the spec. This defines the policy behavior.
[Types: spec: endpointSelector: {}]

13
00:01:12,000 --> 00:01:18,000
An empty endpointSelector means this policy applies to ALL pods in the namespace.

14
00:01:18,000 --> 00:01:24,000
[Types: ingress: []]

15
00:01:24,000 --> 00:01:30,000
ingress: [] means no incoming traffic is allowed by default. This is the deny-all rule.

16
00:01:30,000 --> 00:01:36,000
[Types: egress: - toEndpoints: - matchLabels: k8s:io.kubernetes.pod.namespace: kube-system k8s-app: kube-dns toPorts: - ports: - port: "53" protocol: UDP - port: "53" protocol: TCP]

17
00:01:36,000 --> 00:01:42,000
Egress allows DNS resolution. This is an exception to the deny-all rule.

18
00:01:42,000 --> 00:01:48,000
Without DNS, pods can't resolve service names. This would break everything.

19
00:01:48,000 --> 00:01:54,000
DNS is the only allowed egress traffic. Everything else is blocked.

20
00:01:54,000 --> 00:02:00,000
This is the zero-trust default. No traffic is allowed unless explicitly permitted.

21
00:02:00,000 --> 00:02:06,000
Now let's create the API L7 policy. Open `cilium/network-policies/api-l7-policy.yaml`.

22
00:02:06,000 --> 00:02:12,000
[Types: apiVersion: "cilium.io/v2" kind: CiliumNetworkPolicy metadata: name: api-l7-policy namespace: financial-rag]

23
00:02:12,000 --> 00:02:18,000
This policy applies to the API service. It controls what traffic can reach the API.

24
00:02:18,000 --> 00:02:24,000
[Types: spec: endpointSelector: matchLabels: app.kubernetes.io/component: api]

25
00:02:24,000 --> 00:02:30,000
The endpointSelector targets only pods with the component: api label.

26
00:02:30,000 --> 00:02:36,000
[Types: ingress: - fromEntities: - world toPorts: - ports: - port: "8000" protocol: TCP rules: http: - method: "GET" path: "/health" - method: "POST" path: "/query" - method: "GET" path: "/metrics" - method: "POST" path: "/v1/query" - method: "GET" path: "/v1/health"]

27
00:02:36,000 --> 00:02:42,000
This is the L7 HTTP policy. It allows specific HTTP methods on specific paths.

28
00:02:42,000 --> 00:02:48,000
fromEntities: world means traffic from outside the cluster. This is the ALB traffic.

29
00:02:48,000 --> 00:02:54,000
Only GET /health, POST /query, GET /metrics, POST /v1/query, and GET /v1/health are allowed.

30
00:02:54,000 --> 00:03:00,000
Any other path or method is blocked at the eBPF layer. The request never reaches FastAPI.

31
00:03:00,000 --> 00:03:06,000
[Types: - fromEndpoints: - matchLabels: k8s:io.kubernetes.pod.namespace: monitoring toPorts: - ports: - port: "8000" protocol: TCP rules: http: - method: "GET" path: "/metrics"]

32
00:03:06,000 --> 00:03:12,000
This allows Prometheus to scrape metrics from the monitoring namespace.

33
00:03:12,000 --> 00:03:18,000
Prometheus runs in the monitoring namespace. It needs access to /metrics.

34
00:03:18,000 --> 00:03:24,000
[Types: egress: - toEndpoints: - matchLabels: app.kubernetes.io/component: agent toPorts: - ports: - port: "8001" protocol: TCP rules: http: - method: "POST" path: "/infer" - method: "POST" path: "/v1/infer"]

35
00:03:24,000 --> 00:03:30,000
This allows the API to call the agent. Only POST /infer and POST /v1/infer are allowed.

36
00:03:30,000 --> 00:03:36,000
[Types: - toEndpoints: - matchLabels: app.kubernetes.io/component: pgvector toPorts: - ports: - port: "5432" protocol: TCP]

37
00:03:36,000 --> 00:03:42,000
This allows the API to talk to PostgreSQL on port 5432. No HTTP rules because PostgreSQL uses its own protocol.

38
00:03:42,000 --> 00:03:48,000
[Types: - toEndpoints: - matchLabels: app.kubernetes.io/component: redis toPorts: - ports: - port: "6379" protocol: TCP]

39
00:03:48,000 --> 00:03:54,000
This allows the API to talk to Redis on port 6379.

40
00:03:54,000 --> 00:04:00,000
[Types: - toEntities: - world toPorts: - ports: - port: "443" protocol: TCP]

41
00:04:00,000 --> 00:04:06,000
This allows outbound HTTPS traffic to the world. This is for LLM API calls and external services.

42
00:04:06,000 --> 00:04:12,000
Now let's create the Agent L7 policy. Open `cilium/network-policies/agent-l7-policy.yaml`.

43
00:04:12,000 --> 00:04:18,000
[Types: apiVersion: "cilium.io/v2" kind: CiliumNetworkPolicy metadata: name: agent-l7-policy namespace: financial-rag]

44
00:04:18,000 --> 00:04:24,000
This policy applies to the Agent Pool. It controls what traffic can reach the agent.

45
00:04:24,000 --> 00:04:30,000
[Types: spec: endpointSelector: matchLabels: app.kubernetes.io/component: agent]

46
00:04:30,000 --> 00:04:36,000
The endpointSelector targets only pods with the component: agent label.

47
00:04:36,000 --> 00:04:42,000
[Types: ingress: - fromEndpoints: - matchLabels: app.kubernetes.io/component: api toPorts: - ports: - port: "8001" protocol: TCP rules: http: - method: "POST" path: "/infer" - method: "POST" path: "/v1/infer" - method: "GET" path: "/health"]

48
00:04:42,000 --> 00:04:48,000
Only the API can call the agent. Only POST /infer, POST /v1/infer, and GET /health are allowed.

49
00:04:48,000 --> 00:04:54,000
[Types: - fromEndpoints: - matchLabels: k8s:io.kubernetes.pod.namespace: monitoring toPorts: - ports: - port: "8001" protocol: TCP rules: http: - method: "GET" path: "/metrics"]

50
00:04:54,000 --> 00:05:00,000
Prometheus can scrape agent metrics from the monitoring namespace.

51
00:05:00,000 --> 00:05:06,000
[Types: egress: - toEndpoints: - matchLabels: app.kubernetes.io/component: pgvector toPorts: - ports: - port: "5432" protocol: TCP]

52
00:05:06,000 --> 00:05:12,000
The agent can talk to PostgreSQL. This is for vector search and storing results.

53
00:05:12,000 --> 00:05:18,000
[Types: - toEndpoints: - matchLabels: app.kubernetes.io/component: redis toPorts: - ports: - port: "6379" protocol: TCP]

54
00:05:18,000 --> 00:05:24,000
The agent can talk to Redis. This is for caching.

55
00:05:24,000 --> 00:05:30,000
[Types: - toEntities: - world toPorts: - ports: - port: "443" protocol: TCP]

56
00:05:30,000 --> 00:05:36,000
The agent can make outbound HTTPS calls. This is for LLM API calls.

57
00:05:36,000 --> 00:05:42,000
Now let's apply the policies. First, the default deny policy.

58
00:05:42,000 --> 00:05:48,000
[Types: kubectl apply -f cilium/network-policies/default-deny-all.yaml]

59
00:05:48,000 --> 00:05:54,000
This applies the deny-all policy. Immediately, all traffic between pods is blocked.

60
00:05:54,000 --> 00:06:00,000
The API will stop responding. This is expected. We haven't applied the allow policies yet.

61
00:06:00,000 --> 00:06:06,000
Now apply the API policy.
[Types: kubectl apply -f cilium/network-policies/api-l7-policy.yaml]

62
00:06:06,000 --> 00:06:12,000
The API can now receive traffic from the ALB and talk to the agent, PostgreSQL, and Redis.

63
00:06:12,000 --> 00:06:18,000
Now apply the Agent policy.
[Types: kubectl apply -f cilium/network-policies/agent-l7-policy.yaml]

64
00:06:18,000 --> 00:06:24,000
The agent can now receive traffic from the API and talk to PostgreSQL, Redis, and external HTTPS services.

65
00:06:24,000 --> 00:06:30,000
Now let's verify the policies are working. Check the Cilium status.

66
00:06:30,000 --> 00:06:36,000
[Types: kubectl get ciliumnetworkpolicies -n financial-rag]

67
00:06:36,000 --> 00:06:42,000
You should see default-deny-all, api-l7-policy, and agent-l7-policy in the list.

68
00:06:42,000 --> 00:06:48,000
Now test the API endpoint. It should work.
[Types: curl http://localhost:8000/health]

69
00:06:48,000 --> 00:06:54,000
The health endpoint should return a 200 OK. This confirms the policy allows GET /health.

70
00:06:54,000 --> 00:07:00,000
Now test a blocked path.
[Types: curl -X POST http://localhost:8000/not-allowed]

71
00:07:00,000 --> 00:07:06,000
This should be blocked. Cilium drops the request at the eBPF layer. It never reaches FastAPI.

72
00:07:06,000 --> 00:07:12,000
Now test the agent endpoint. The API should be able to call the agent.
[Types: kubectl exec -n financial-rag deploy/financial-rag-agent-api -- curl -s -X POST http://financial-rag-agent-agent:8001/infer -H "Content-Type: application/json" -d '{"query": "test"}']

73
00:07:12,000 --> 00:07:18,000
This should work. The API pod can talk to the agent pod on port 8001.

74
00:07:18,000 --> 00:07:24,000
Now let's check Cilium's policy enforcement. Cilium provides visibility into what traffic is allowed and denied.

75
00:07:24,000 --> 00:07:30,000
[Types: kubectl exec -n kube-system deploy/cilium-operator -- cilium endpoint list -o json | jq '.[] | {id, labels, policy}']

76
00:07:30,000 --> 00:07:36,000
This shows the policy state of all endpoints. Each pod has a policy enforcement status.

77
00:07:36,000 --> 00:07:42,000
Now let's use Hubble to see the flows. Hubble is Cilium's observability layer.

78
00:07:42,000 --> 00:07:48,000
[Types: kubectl exec -n kube-system deploy/hubble-relay -- hubble observe -n financial-rag]

79
00:07:48,000 --> 00:07:54,000
This shows all flows in the financial-rag namespace. You'll see allowed and denied flows.

80
00:07:54,000 --> 00:08:00,000
Denied flows are shown with "dropped" status. This is how you audit blocked traffic.

81
00:08:00,000 --> 00:08:06,000
Now let me recap what we've built in Part 3.

82
00:08:06,000 --> 00:08:12,000
We built the default-deny-all policy. This blocks all traffic by default. Only DNS is allowed.

83
00:08:12,000 --> 00:08:18,000
We built the API L7 policy. This allows specific HTTP methods on specific paths. It allows the API to talk to the agent, PostgreSQL, and Redis.

84
00:08:18,000 --> 00:08:24,000
We built the Agent L7 policy. This allows the agent to receive traffic from the API. It allows the agent to talk to PostgreSQL, Redis, and external HTTPS services.

85
00:08:24,000 --> 00:08:30,000
We applied all policies and verified they work. Traffic is allowed and blocked according to the rules.

86
00:08:30,000 --> 00:08:36,000
In Part 4, we'll set up Istio for service mesh. This adds mTLS encryption and authorization.

87
00:08:36,000 --> 00:08:42,000
Thank you for watching. I'll see you in Part 4.

88
00:08:42,000 --> 00:08:46,000
[End of Part 3]

1
00:00:00,000 --> 00:00:06,000
Welcome back to Phase 9. In Part 4, we build the Cilium L7 HTTP policies.

2
00:00:06,000 --> 00:00:12,000
We already have L3 and L4 policies. They control which IPs and ports can communicate. Now we go deeper. We control the actual HTTP methods and paths.

3
00:00:12,000 --> 00:00:18,000
Think of L3/L4 policies like a bouncer at a club. The bouncer checks your ID and lets you in. That's IP and port filtering.

4
00:00:18,000 --> 00:00:24,000
L7 policies are like a waiter inside the club. The waiter only lets you order from the menu. You can't order anything not on the menu.

5
00:00:24,000 --> 00:00:30,000
HTTP L7 policies inspect the actual HTTP request. They check the method, the path, and the headers. If the request doesn't match the policy, it's rejected.

6
00:00:30,000 --> 00:00:36,000
Open your editor and create `cilium/network-policies/api-l7-policy.yaml`.

7
00:00:36,000 --> 00:00:42,000
We'll start with the API version and kind.
[Types: apiVersion: "cilium.io/v2"]

8
00:00:42,000 --> 00:00:48,000
We use cilium.io/v2. This is the current stable version for CiliumNetworkPolicy.

9
00:00:48,000 --> 00:00:54,000
[Types: kind: CiliumNetworkPolicy]

10
00:00:54,000 --> 00:01:00,000
The kind is CiliumNetworkPolicy. This defines network policies in Cilium.

11
00:01:00,000 --> 00:01:06,000
Now the metadata.
[Types: metadata: name: api-l7-policy namespace: financial-rag]

12
00:01:06,000 --> 00:01:12,000
The name is api-l7-policy. The namespace is financial-rag. This policy applies only to this namespace.

13
00:01:12,000 --> 00:01:18,000
Now the spec.
[Types: spec: endpointSelector: matchLabels: app.kubernetes.io/component: api]

14
00:01:18,000 --> 00:01:24,000
This policy applies to pods with the label app.kubernetes.io/component: api. These are our API pods.

15
00:01:24,000 --> 00:01:30,000
Now the ingress section.
[Types: ingress:]

16
00:01:30,000 --> 00:01:36,000
Ingress rules control incoming traffic to the API pods.

17
00:01:36,000 --> 00:01:42,000
The first rule allows traffic from the ALB.
[Types: - fromEntities: - world]

18
00:01:42,000 --> 00:01:48,000
fromEntities: world allows traffic from outside the cluster. This is how users reach our API.

19
00:01:48,000 --> 00:01:54,000
[Types: toPorts: - ports: - port: "8000" protocol: TCP]

20
00:01:54,000 --> 00:02:00,000
The traffic must be on port 8000 with TCP protocol. This is the API port.

21
00:02:00,000 --> 00:02:06,000
Now the L7 HTTP rules.
[Types: rules: http:]

22
00:02:06,000 --> 00:02:12,000
The http rules define allowed HTTP requests. This is the L7 inspection.

23
00:02:12,000 --> 00:02:18,000
First, the health check.
[Types: - method: "GET" path: "/health"]

24
00:02:18,000 --> 00:02:24,000
The health check is a GET request to /health. This is allowed.

25
00:02:24,000 --> 00:02:30,000
Second, the query endpoint.
[Types: - method: "POST" path: "/query"]

26
00:02:30,000 --> 00:02:36,000
The query endpoint is a POST request to /query. This is the main RAG endpoint.

27
00:02:36,000 --> 00:02:42,000
Third, the versioned query endpoint.
[Types: - method: "POST" path: "/v1/query"]

28
00:02:42,000 --> 00:02:48,000
We also allow the versioned path. This is for future compatibility.

29
00:02:48,000 --> 00:02:54,000
Fourth, the versioned health check.
[Types: - method: "GET" path: "/v1/health"]

30
00:02:54,000 --> 00:03:00,000
The versioned health check is also allowed.

31
00:03:00,000 --> 00:03:06,000
Fifth, the metrics endpoint.
[Types: - method: "GET" path: "/metrics"]

32
00:03:06,000 --> 00:03:12,000
The metrics endpoint is a GET request to /metrics. This is for Prometheus scraping.

33
00:03:12,000 --> 00:03:18,000
Now the second ingress rule. This allows Prometheus to scrape metrics.
[Types: - fromEndpoints: - matchLabels: k8s:io.kubernetes.pod.namespace: monitoring]

34
00:03:18,000 --> 00:03:24,000
This rule allows traffic from pods in the monitoring namespace. These are Prometheus pods.

35
00:03:24,000 --> 00:03:30,000
[Types: toPorts: - ports: - port: "8000" protocol: TCP rules: http: - method: "GET" path: "/metrics"]

36
00:03:30,000 --> 00:03:36,000
Prometheus can only access /metrics. It can't access /query or /health.

37
00:03:36,000 --> 00:03:42,000
Now the egress section. This controls outgoing traffic from the API.
[Types: egress:]

38
00:03:42,000 --> 00:03:48,000
First, egress to the agent pool.
[Types: - toEndpoints: - matchLabels: app.kubernetes.io/component: agent]

39
00:03:48,000 --> 00:03:54,000
The API can talk to the agent pool. This is where it sends inference requests.

40
00:03:54,000 --> 00:04:00,000
[Types: toPorts: - ports: - port: "8001" protocol: TCP rules: http: - method: "POST" path: "/infer" - method: "POST" path: "/v1/infer"]

41
00:04:00,000 --> 00:04:06,000
The API can only send POST requests to /infer or /v1/infer. It can't GET anything from the agent.

42
00:04:06,000 --> 00:04:12,000
Second, egress to pgvector.
[Types: - toEndpoints: - matchLabels: app.kubernetes.io/component: pgvector]

43
00:04:12,000 --> 00:04:18,000
The API can talk to pgvector. This is where it retrieves embeddings.

44
00:04:18,000 --> 00:04:24,000
[Types: toPorts: - ports: - port: "5432" protocol: TCP]

45
00:04:24,000 --> 00:04:30,000
PostgreSQL uses TCP port 5432. There are no L7 rules here because PostgreSQL doesn't use HTTP.

46
00:04:30,000 --> 00:04:36,000
Third, egress to Redis.
[Types: - toEndpoints: - matchLabels: app.kubernetes.io/component: redis]

47
00:04:36,000 --> 00:04:42,000
The API can talk to Redis. This is where it caches results.

48
00:04:42,000 --> 00:04:48,000
[Types: toPorts: - ports: - port: "6379" protocol: TCP]

49
00:04:48,000 --> 00:04:54,000
Redis uses TCP port 6379. No L7 rules for Redis.

50
00:04:54,000 --> 00:05:00,000
Fourth, egress to external services.
[Types: - toEntities: - world toPorts: - ports: - port: "443" protocol: TCP]

51
00:05:00,000 --> 00:05:06,000
The API can talk to external services on port 443. This is HTTPS traffic. This includes OpenAI and Groq API calls.

52
00:05:06,000 --> 00:05:12,000
Now let's create the agent L7 policy. Open `cilium/network-policies/agent-l7-policy.yaml`.

53
00:05:12,000 --> 00:05:18,000
[Types: apiVersion: "cilium.io/v2" kind: CiliumNetworkPolicy metadata: name: agent-l7-policy namespace: financial-rag]

54
00:05:18,000 --> 00:05:24,000
The metadata is similar. The name is agent-l7-policy.

55
00:05:24,000 --> 00:05:30,000
[Types: spec: endpointSelector: matchLabels: app.kubernetes.io/component: agent]

56
00:05:30,000 --> 00:05:36,000
This policy applies to agent pods.

57
00:05:36,000 --> 00:05:42,000
Now the ingress section.
[Types: ingress: - fromEndpoints: - matchLabels: app.kubernetes.io/component: api]

58
00:05:42,000 --> 00:05:48,000
Only the API can talk to the agent. No other service can reach the agent.

59
00:05:48,000 --> 00:05:54,000
[Types: toPorts: - ports: - port: "8001" protocol: TCP rules: http: - method: "POST" path: "/infer" - method: "POST" path: "/v1/infer" - method: "GET" path: "/health"]

60
00:05:54,000 --> 00:06:00,000
The agent allows POST to /infer and /v1/infer for inference requests. It also allows GET to /health for liveness checks.

61
00:06:00,000 --> 00:06:06,000
Now the egress section.
[Types: egress: - toEndpoints: - matchLabels: app.kubernetes.io/component: pgvector]

62
00:06:06,000 --> 00:06:12,000
The agent can talk to pgvector. This is where it retrieves documents.

63
00:06:12,000 --> 00:06:18,000
[Types: toPorts: - ports: - port: "5432" protocol: TCP]

64
00:06:18,000 --> 00:06:24,000
PostgreSQL uses TCP port 5432.

65
00:06:24,000 --> 00:06:30,000
[Types: - toEndpoints: - matchLabels: app.kubernetes.io/component: redis]

66
00:06:30,000 --> 00:06:36,000
The agent can talk to Redis for caching.

67
00:06:36,000 --> 00:06:42,000
[Types: toPorts: - ports: - port: "6379" protocol: TCP]

68
00:06:42,000 --> 00:06:48,000
Redis uses TCP port 6379.

69
00:06:48,000 --> 00:06:54,000
[Types: - toEntities: - world toPorts: - ports: - port: "443" protocol: TCP]

70
00:06:54,000 --> 00:07:00,000
The agent can talk to external services on port 443. This includes LLM API calls.

71
00:07:00,000 --> 00:07:06,000
Now let's apply the policies.

72
00:07:06,000 --> 00:07:12,000
[Types: kubectl apply -f cilium/network-policies/api-l7-policy.yaml]

73
00:07:12,000 --> 00:07:18,000
[Types: kubectl apply -f cilium/network-policies/agent-l7-policy.yaml]

74
00:07:18,000 --> 00:07:24,000
Wait a few seconds for the policies to be applied. Cilium updates the eBPF programs in the kernel.

75
00:07:24,000 --> 00:07:30,000
Now let's test the policies.

76
00:07:30,000 --> 00:07:36,000
First, test the health endpoint. This should work.

77
00:07:36,000 --> 00:07:42,000
[Types: curl -s -o /dev/null -w "%{http_code}\n" http://localhost:8000/health]

78
00:07:42,000 --> 00:07:48,000
You should get 200 OK. The health endpoint is allowed.

79
00:07:48,000 --> 00:07:54,000
Now test the query endpoint. This should work.

80
00:07:54,000 --> 00:08:00,000
[Types: curl -s -X POST http://localhost:8000/query -H "Content-Type: application/json" -d '{"question":"test"}' -w "%{http_code}\n" -o /dev/null]

81
00:08:00,000 --> 00:08:06,000
This should work. The query endpoint is allowed.

82
00:08:06,000 --> 00:08:12,000
Now test a disallowed path. This should be blocked.

83
00:08:12,000 --> 00:08:18,000
[Types: curl -s -X GET http://localhost:8000/admin -w "%{http_code}\n" -o /dev/null]

84
00:08:18,000 --> 00:08:24,000
You should get 403 Forbidden. The /admin path is not in the L7 policy.

85
00:08:24,000 --> 00:08:30,000
Now test a disallowed method on a allowed path.

86
00:08:30,000 --> 00:08:36,000
[Types: curl -s -X DELETE http://localhost:8000/health -w "%{http_code}\n" -o /dev/null]

87
00:08:36,000 --> 00:08:42,000
You should get 403 Forbidden. The health endpoint only allows GET.

88
00:08:42,000 --> 00:08:48,000
Now let's verify the policies in Hubble.

89
00:08:48,000 --> 00:08:54,000
[Types: kubectl port-forward -n kube-system svc/hubble-metrics 9965:9965]

90
00:08:54,000 --> 00:09:00,000
[Types: curl -s http://localhost:9965/metrics | grep -i "drop"]

91
00:09:00,000 --> 00:09:06,000
You should see metrics for dropped packets. This confirms Cilium is enforcing the policies.

92
00:09:06,000 --> 00:09:12,000
Now let me recap what we've built in Part 4.

93
00:09:12,000 --> 00:09:18,000
We built the API L7 policy. It allows GET to /health, POST to /query, and GET to /metrics.
It allows POST to /infer on the agent. It blocks all other HTTP requests.

94
00:09:18,000 --> 00:09:24,000
We built the Agent L7 policy. It allows POST to /infer from the API.
It allows GET to /health for liveness checks. It blocks all other HTTP requests.

95
00:09:24,000 --> 00:09:30,000
We applied the policies and tested them. Allowed requests work. Disallowed requests get 403.

96
00:09:30,000 --> 00:09:36,000
This is zero-trust networking at L7. Every HTTP request is inspected. Only allowed requests pass.

97
00:09:36,000 --> 00:09:42,000
In Part 5, we'll build the Istio service mesh. This adds mTLS and advanced traffic management.

98
00:09:42,000 --> 00:09:48,000
Thank you for watching. I'll see you in Part 5.

99
00:09:48,000 --> 00:09:52,000
[End of Part 4]

1
00:00:00,000 --> 00:00:06,000
Welcome back to Phase 9. In Part 5, we build the Istio Authorization Policies and enforce strict mTLS.

2
00:00:06,000 --> 00:00:12,000
We've built the network policies with Cilium. We've built the L7 HTTP policies. Now we add the application-layer security with Istio.

3
00:00:12,000 --> 00:00:18,000
Think of it this way. Cilium is the building security guard. It checks who enters the building. Istio is the office security guard. It checks who enters each room.

4
00:00:18,000 --> 00:00:24,000
Authorization Policies define which services can talk to which other services. They enforce the principle of least privilege at the application layer.

5
00:00:24,000 --> 00:00:30,000
Open your editor and create `istio-mesh/authorization-policies.yaml`.

6
00:00:30,000 --> 00:00:36,000
We'll start with the deny-all policy. This is the default. Everything is denied unless explicitly allowed.
[Types: apiVersion: security.istio.io/v1beta1]

7
00:00:36,000 --> 00:00:42,000
We use security.istio.io/v1beta1. This is the stable version for Istio security policies.

8
00:00:42,000 --> 00:00:48,000
Now the kind.
[Types: kind: AuthorizationPolicy]

9
00:00:48,000 --> 00:00:54,000
AuthorizationPolicy defines who can access what. It's like an ACL for your services.

10
00:00:54,000 --> 00:01:00,000
Now the metadata section.
[Types: metadata: name: deny-all namespace: financial-rag]

11
00:01:00,000 --> 00:01:06,000
The deny-all policy is the baseline. It denies all traffic by default. This is zero-trust.

12
00:01:06,000 --> 00:01:12,000
[Types: spec: {}]

13
00:01:12,000 --> 00:01:18,000
An empty spec means deny all. No traffic is allowed. This is the safest default.

14
00:01:18,000 --> 00:01:24,000
Now let's define the allow-gateway-to-api policy. This allows the Istio gateway to talk to the API.
[Types: --- apiVersion: security.istio.io/v1beta1 kind: AuthorizationPolicy]

15
00:01:24,000 --> 00:01:30,000
We create a new policy for the API service.

16
00:01:30,000 --> 00:01:36,000
[Types: metadata: name: allow-gateway-to-api namespace: financial-rag]

17
00:01:36,000 --> 00:01:42,000
The name describes what this policy does. It allows the gateway to reach the API.

18
00:01:42,000 --> 00:01:48,000
[Types: spec: selector: matchLabels: app.kubernetes.io/component: api]

19
00:01:48,000 --> 00:01:54,000
The selector applies this policy to the API pods. Only pods with this label are affected.

20
00:01:54,000 --> 00:02:00,000
[Types: rules: - from: - source: principals: - "cluster.local/ns/istio-system/sa/istio-ingressgateway"]

21
00:02:00,000 --> 00:02:06,000
The source is the Istio ingress gateway. The principal format is cluster.local/ns/NAMESPACE/sa/SERVICE_ACCOUNT. This identifies the gateway service account.

22
00:02:06,000 --> 00:02:12,000
[Types: to: - operation: methods: ["GET", "POST"] ports: ["8000"]]

23
00:02:12,000 --> 00:02:18,000
This allows GET and POST requests on port 8000. The API only accepts these methods.

24
00:02:18,000 --> 00:02:24,000
Now let's define the allow-api-to-agent policy. This allows the API to call the agent.
[Types: --- apiVersion: security.istio.io/v1beta1 kind: AuthorizationPolicy]

25
00:02:24,000 --> 00:02:30,000
[Types: metadata: name: allow-api-to-agent namespace: financial-rag]

26
00:02:30,000 --> 00:02:36,000
This policy enables communication between the API and the agent pool.

27
00:02:36,000 --> 00:02:42,000
[Types: spec: selector: matchLabels: app.kubernetes.io/component: agent]

28
00:02:42,000 --> 00:02:48,000
The selector applies this policy to the agent pods.

29
00:02:48,000 --> 00:02:54,000
[Types: rules: - from: - source: principals: - "cluster.local/ns/financial-rag/sa/financial-rag-prod-api"]

30
00:02:54,000 --> 00:03:00,000
The source is the API service account. Only the API can talk to the agent.

31
00:03:00,000 --> 00:03:06,000
[Types: to: - operation: methods: ["POST"] ports: ["8001"]]

32
00:03:06,000 --> 00:03:12,000
The agent only accepts POST requests on port 8001. This is the inference endpoint.

33
00:03:12,000 --> 00:03:18,000
Now let's define the allow-prometheus-scrape policy. This allows Prometheus to scrape metrics.
[Types: --- apiVersion: security.istio.io/v1beta1 kind: AuthorizationPolicy]

34
00:03:18,000 --> 00:03:24,000
[Types: metadata: name: allow-prometheus-scrape namespace: financial-rag]

35
00:03:24,000 --> 00:03:30,000
This policy enables Prometheus to scrape metrics from all services.

36
00:03:30,000 --> 00:03:36,000
[Types: spec: rules: - from: - source: principals: - "cluster.local/ns/monitoring/sa/kube-prometheus-stack-prometheus"]

37
00:03:36,000 --> 00:03:42,000
The source is the Prometheus service account. This is in the monitoring namespace.

38
00:03:42,000 --> 00:03:48,000
[Types: to: - operation: methods: ["GET"] paths: ["/metrics", "/health"]]

39
00:03:48,000 --> 00:03:54,000
Prometheus can only access /metrics and /health. It uses GET requests.

40
00:03:54,000 --> 00:04:00,000
Now let's define the strict mTLS policy. This enforces mTLS for all services in the namespace.
[Types: --- apiVersion: security.istio.io/v1beta1]

41
00:04:00,000 --> 00:04:06,000
We use PeerAuthentication for mTLS. This configures how services authenticate to each other.

42
00:04:06,000 --> 00:04:12,000
[Types: kind: PeerAuthentication]

43
00:04:12,000 --> 00:04:18,000
PeerAuthentication defines the mTLS mode. STRICT means mTLS is required for all connections.

44
00:04:18,000 --> 00:04:24,000
[Types: metadata: name: financial-rag-strict-mtls namespace: financial-rag]

45
00:04:24,000 --> 00:04:30,000
This applies to the financial-rag namespace.

46
00:04:30,000 --> 00:04:36,000
[Types: spec: selector: {}]

47
00:04:36,000 --> 00:04:42,000
An empty selector means all workloads in the namespace are affected.

48
00:04:42,000 --> 00:04:48,000
[Types: mtls: mode: STRICT]

49
00:04:48,000 --> 00:04:54,000
STRICT mode means all connections must use mTLS. Plaintext connections are rejected.

50
00:04:54,000 --> 00:05:00,000
Now let's apply the default strict mTLS policy for the entire mesh.
[Types: --- apiVersion: security.istio.io/v1beta1 kind: PeerAuthentication]

51
00:05:00,000 --> 00:05:06,000
[Types: metadata: name: default-strict-mtls namespace: istio-system]

52
00:05:06,000 --> 00:05:12,000
This applies to the entire service mesh. It's the fallback for any namespace without its own policy.

53
00:05:12,000 --> 00:05:18,000
[Types: spec: selector: {} mtls: mode: STRICT]

54
00:05:18,000 --> 00:05:24,000
STRICT mTLS for the entire mesh. Every service must use mTLS.

55
00:05:24,000 --> 00:05:30,000
Now let's deploy the authorization policies.

56
00:05:30,000 --> 00:05:36,000
[Types: kubectl apply -f istio-mesh/authorization-policies.yaml]

57
00:05:36,000 --> 00:05:42,000
This creates all the AuthorizationPolicies and PeerAuthentications.

58
00:05:42,000 --> 00:05:48,000
[Types: kubectl get authorizationpolicies -n financial-rag]

59
00:05:48,000 --> 00:05:54,000
You should see deny-all, allow-gateway-to-api, allow-api-to-agent, and allow-prometheus-scrape.

60
00:05:54,000 --> 00:06:00,000
[Types: kubectl get peerauthentications -n financial-rag]

61
00:06:00,000 --> 00:06:06,000
You should see financial-rag-strict-mtls. This confirms mTLS is enforced.

62
00:06:06,000 --> 00:06:12,000
Now let's test the policies. Make a request without mTLS.

63
00:06:12,000 --> 00:06:18,000
[Types: kubectl run test-pod --image=busybox --rm -it --restart=Never -n financial-rag -- wget -q -O- http://financial-rag-agent-api:8000/health]

64
00:06:18,000 --> 00:06:24,000
This should fail. The pod doesn't have an Istio sidecar, so it can't use mTLS. The request is rejected.

65
00:06:24,000 --> 00:06:30,000
Now test with the Istio sidecar. Use a pod that's part of the mesh.

66
00:06:30,000 --> 00:06:36,000
[Types: kubectl exec -it $(kubectl get pods -n financial-rag -l app.kubernetes.io/component=api -o name | head -1) -n financial-rag -c istio-proxy -- curl -s http://localhost:15000/health]

67
00:06:36,000 --> 00:06:42,000
This should succeed. The Istio proxy handles mTLS automatically.

68
00:06:42,000 --> 00:06:48,000
Now let's test the authorization policies. Try to access the API from a source that isn't allowed.

69
00:06:48,000 --> 00:06:54,000
[Types: kubectl run unauthorized --image=busybox --rm -it --restart=Never -n default -- wget -q -O- http://financial-rag-agent-api.financial-rag.svc.cluster.local:8000/health]

70
00:06:54,000 --> 00:07:00,000
This should fail. The source isn't in the allowed list. The request is denied.

71
00:07:00,000 --> 00:07:06,000
Now test the agent access. Only the API should access the agent.

72
00:07:06,000 --> 00:07:12,000
[Types: kubectl run test-agent-access --image=busybox --rm -it --restart=Never -n financial-rag -- wget -q -O- http://financial-rag-agent-agent:8001/health]

73
00:07:12,000 --> 00:07:18,000
This should fail. The pod doesn't have the API service account. The authorization policy blocks it.

74
00:07:18,000 --> 00:07:24,000
Now let's view the Istio proxy logs. This shows the authorization decisions.

75
00:07:24,000 --> 00:07:30,000
[Types: kubectl logs $(kubectl get pods -n financial-rag -l app.kubernetes.io/component=api -o name | head -1) -n financial-rag -c istio-proxy | grep "authorization" | tail -5]

76
00:07:30,000 --> 00:07:36,000
You should see log entries showing "allowed" or "denied". This confirms the policies are working.

77
00:07:36,000 --> 00:07:42,000
Now let me recap what we've built in Part 5.

78
00:07:42,000 --> 00:07:48,000
We built the deny-all policy. This is the default. Everything is denied unless explicitly allowed.

79
00:07:48,000 --> 00:07:54,000
We built the allow-gateway-to-api policy. This allows the Istio gateway to call the API.

80
00:07:54,000 --> 00:08:00,000
We built the allow-api-to-agent policy. This allows the API to call the agent.

81
00:08:00,000 --> 00:08:06,000
We built the allow-prometheus-scrape policy. This allows Prometheus to scrape metrics.

82
00:08:06,000 --> 00:08:12,000
We built the strict mTLS policy. This enforces mTLS for all services in the namespace.

83
00:08:12,000 --> 00:08:18,000
We built the default strict mTLS policy for the entire mesh. This is the fallback.

84
00:08:18,000 --> 00:08:24,000
We tested the policies. Unauthorized requests are denied. Authorized requests are allowed.

85
00:08:24,000 --> 00:08:30,000
This is the final piece of Istio security. Every service has a verified identity. Every connection is encrypted.

86
00:08:30,000 --> 00:08:36,000
In Part 6, we'll build the Destination Rules. These configure load balancing, connection pools, and circuit breakers.

87
00:08:36,000 --> 00:08:42,000
Thank you for watching. I'll see you in Part 6.

88
00:08:42,000 --> 00:08:46,000
[End of Part 5]

1
00:00:00,000 --> 00:00:06,000
Welcome back to Phase 9. In Part 6, we build the Istio Gateway and VirtualService.

2
00:00:06,000 --> 00:00:12,000
The Gateway is how traffic enters your mesh. It's like the front door of your application.
The VirtualService is how traffic is routed inside your mesh. It's like the hallways and rooms.

3
00:00:12,000 --> 00:00:18,000
Think of it this way. The Gateway is the entrance to a building. The VirtualService
is the map that directs visitors to the right department. Different paths lead to
different services.

4
00:00:18,000 --> 00:00:24,000
Open your editor and create `gitops/envs/istio-mesh/gateway.yaml`.

5
00:00:24,000 --> 00:00:30,000
We'll start with the apiVersion. Istio networking v1beta1 is the stable version.
[Types: apiVersion: networking.istio.io/v1beta1]

6
00:00:30,000 --> 00:00:36,000
Now the kind.
[Types: kind: Gateway]

7
00:00:36,000 --> 00:00:42,000
Gateway defines the entry point for external traffic. It's the load balancer
for your service mesh.

8
00:00:42,000 --> 00:00:48,000
Now the metadata.
[Types: metadata: name: financial-rag-gateway namespace: financial-rag]

9
00:00:48,000 --> 00:00:54,000
The Gateway lives in the financial-rag namespace. It serves traffic for our
application only.

10
00:00:54,000 --> 00:01:00,000
Now the spec. This defines what the Gateway does.
[Types: spec: selector: istio: ingressgateway]

11
00:01:00,000 --> 00:01:06,000
The selector attaches this Gateway to the Istio ingress gateway service.
The ingress gateway is the pod that actually receives traffic.

12
00:01:06,000 --> 00:01:12,000
Now the servers section. This defines the ports and protocols.
[Types: servers: - port: number: 443 name: https protocol: HTTPS]

13
00:01:12,000 --> 00:01:18,000
We define an HTTPS server on port 443. This is standard for production APIs.

14
00:01:18,000 --> 00:01:24,000
[Types: tls: mode: SIMPLE credentialName: financial-rag-tls]

15
00:01:24,000 --> 00:01:30,000
mode: SIMPLE means standard TLS termination. The credentialName refers to a Kubernetes
secret containing the TLS certificate.

16
00:01:30,000 --> 00:01:36,000
[Types: hosts: - api.financial-rag.cloudfrugal.com]

17
00:01:36,000 --> 00:01:42,000
The hosts field defines which domain this Gateway serves. Only traffic for this
domain is accepted.

18
00:01:42,000 --> 00:01:48,000
Now let's add an HTTP server for redirection. This redirects HTTP to HTTPS.
[Types: - port: number: 80 name: http protocol: HTTP]

19
00:01:48,000 --> 00:01:54,000
Port 80 is standard HTTP. We redirect it to HTTPS for security.

20
00:01:54,000 --> 00:02:00,000
[Types: tls: httpsRedirect: true]

21
00:02:00,000 --> 00:02:06,000
httpsRedirect: true automatically redirects HTTP to HTTPS. This is a security best practice.

22
00:02:06,000 --> 00:02:12,000
[Types: hosts: - api.financial-rag.cloudfrugal.com]

23
00:02:12,000 --> 00:02:18,000
The same hosts field. Both HTTP and HTTPS serve the same domain.

24
00:02:18,000 --> 00:02:24,000
Now let's create the VirtualService. Open `gitops/envs/istio-mesh/virtual-services.yaml`.

25
00:02:24,000 --> 00:02:30,000
[Types: apiVersion: networking.istio.io/v1beta1 kind: VirtualService]

26
00:02:30,000 --> 00:02:36,000
VirtualService defines how traffic is routed. It's the internal routing map.

27
00:02:36,000 --> 00:02:42,000
[Types: metadata: name: financial-rag-api namespace: financial-rag]

28
00:02:42,000 --> 00:02:48,000
The VirtualService is in the same namespace as the services it routes to.

29
00:02:48,000 --> 00:02:54,000
Now the spec.
[Types: spec: hosts: - financial-rag-agent-api.financial-rag.svc.cluster.local - api.financial-rag.cloudfrugal.com]

30
00:02:54,000 --> 00:03:00,000
The hosts field defines which destinations this VirtualService applies to.
The internal service name and the external domain name.

31
00:03:00,000 --> 00:03:06,000
[Types: gateways: - financial-rag-gateway - mesh]

32
00:03:06,000 --> 00:03:12,000
The gateways field tells Istio which Gateways this VirtualService applies to.
mesh means internal traffic within the mesh.

33
00:03:12,000 --> 00:03:18,000
Now the http section. This defines the routing rules.
[Types: http: - match: - uri: exact: /health]

34
00:03:18,000 --> 00:03:24,000
The first rule matches the /health endpoint. This is the health check endpoint.

35
00:03:24,000 --> 00:03:30,000
[Types: route: - destination: host: financial-rag-agent-api.financial-rag.svc.cluster.local port: number: 8000]

36
00:03:30,000 --> 00:03:36,000
The route sends traffic to the API service on port 8000.

37
00:03:36,000 --> 00:03:42,000
[Types: timeout: 5s]

38
00:03:42,000 --> 00:03:48,000
Health checks have a 5-second timeout. This is reasonable for a simple health check.

39
00:03:48,000 --> 00:03:54,000
Now let's add the query endpoint rule.
[Types: - match: - uri: prefix: /query]

40
00:03:54,000 --> 00:04:00,000
The query endpoint matches any path starting with /query. This includes
/query and any sub-paths.

41
00:04:00,000 --> 00:04:06,000
[Types: route: - destination: host: financial-rag-agent-api.financial-rag.svc.cluster.local port: number: 8000]

42
00:04:06,000 --> 00:04:12,000
The route sends traffic to the API service on port 8000.

43
00:04:12,000 --> 00:04:18,000
[Types: timeout: 120s]

44
00:04:18,000 --> 00:04:24,000
Query endpoints can take up to 120 seconds. This is the LLM generation timeout.

45
00:04:24,000 --> 00:04:30,000
[Types: retries: attempts: 2 perTryTimeout: 60s retryOn: gateway-error,connect-failure]

46
00:04:30,000 --> 00:04:36,000
Retries handle transient failures. 2 attempts with a 60-second per-try timeout.
Retry on gateway errors and connection failures.

47
00:04:36,000 --> 00:04:42,000
Now let's add the default rule. This handles all other paths.
[Types: - route: - destination: host: financial-rag-agent-api.financial-rag.svc.cluster.local port: number: 8000 timeout: 30s]

48
00:04:42,000 --> 00:04:48,000
The default rule is a catch-all. It routes any unmatched traffic to the API service
with a 30-second timeout.

49
00:04:48,000 --> 00:04:54,000
Now let's apply these resources. The GitOps system will apply them automatically.

50
00:04:54,000 --> 00:05:00,000
[Types: kubectl apply -f gitops/envs/istio-mesh/]

51
00:05:00,000 --> 00:05:06,000
This applies all files in the istio-mesh directory. The gateway and virtual service
are now active.

52
00:05:06,000 --> 00:05:12,000
Now let's verify the Gateway is created.
[Types: kubectl get gateway -n financial-rag]

53
00:05:12,000 --> 00:05:18,000
You should see financial-rag-gateway. The status should be "Accepted".

54
00:05:18,000 --> 00:05:24,000
[Types: kubectl describe gateway financial-rag-gateway -n financial-rag]

55
00:05:24,000 --> 00:05:30,000
This shows the Gateway details. The hosts, ports, and TLS configuration.

56
00:05:30,000 --> 00:05:36,000
Now let's verify the VirtualService.
[Types: kubectl get virtualservice -n financial-rag]

57
00:05:36,000 --> 00:05:42,000
You should see financial-rag-api. The status should be "Available".

58
00:05:42,000 --> 00:05:48,000
Now let's test the routing. Make a request to the health endpoint.

59
00:05:48,000 --> 00:05:54,000
[Types: curl -v https://api.financial-rag.cloudfrugal.com/health]

60
00:05:54,000 --> 00:06:00,000
You should get a 200 response. The health check works.

61
00:06:00,000 --> 00:06:06,000
Now test the query endpoint.
[Types: curl -v https://api.financial-rag.cloudfrugal.com/query -X POST -H "Content-Type: application/json" -d '{"question":"What is Apple's revenue?"}']

62
00:06:06,000 --> 00:06:12,000
This should route correctly and return a response. The query endpoint works.

63
00:06:12,000 --> 00:06:18,000
Now let me explain the routing hierarchy. This is important.

64
00:06:18,000 --> 00:06:24,000
First, traffic hits the Gateway. The Gateway checks the domain name.
If the domain is api.financial-rag.cloudfrugal.com, it accepts the traffic.

65
00:06:24,000 --> 00:06:30,000
Then the VirtualService takes over. It checks the path.
If the path is /health, it uses the health rule. If it's /query, it uses the query rule.
If it's anything else, it uses the default rule.

66
00:06:30,000 --> 00:06:36,000
The VirtualService also handles retries and timeouts. This is where you configure
the circuit breaker and load balancing.

67
00:06:36,000 --> 00:06:42,000
Now let me give you a practical tip. The timeout for the query endpoint is 120 seconds.
This is because LLM generation can take a long time. The timeout should be generous.

68
00:06:42,000 --> 00:06:48,000
The retry policy is also important. If the API pod is restarting, the retry can
handle it gracefully. The user doesn't see an error.

69
00:06:48,000 --> 00:06:54,000
Now let's add a new route. Suppose we want to add a /v2 endpoint for a new API version.

70
00:06:54,000 --> 00:07:00,000
[Types: - match: - uri: prefix: /v2 route: - destination: host: financial-rag-agent-api-v2.financial-rag.svc.cluster.local port: number: 8000 timeout: 120s]

71
00:07:00,000 --> 00:07:06,000
This routes /v2 traffic to a different service. This is how you version your APIs.

72
00:07:06,000 --> 00:07:12,000
Now let me recap what we've built in Part 6.

73
00:07:12,000 --> 00:07:18,000
We built the Istio Gateway. It defines how external traffic enters the mesh.
It terminates TLS and redirects HTTP to HTTPS.

74
00:07:18,000 --> 00:07:24,000
We built the Istio VirtualService. It defines how traffic is routed inside the mesh.
It matches paths and routes to the correct service.

75
00:07:24,000 --> 00:07:30,000
We configured timeouts and retries. This makes our API resilient to failures.

76
00:07:30,000 --> 00:07:36,000
We verified the Gateway and VirtualService are working. Traffic routes correctly.

77
00:07:36,000 --> 00:07:42,000
In Part 7, we'll configure the mTLS policies. This will enforce authentication
between services.

78
00:07:42,000 --> 00:07:48,000
Thank you for watching. I'll see you in Part 7.

79
00:07:48,000 --> 00:07:52,000
[End of Part 6]
1
00:00:00,000 --> 00:00:06,000
Welcome back to Phase 9. In Part 7, we configure mTLS and authorization policies.

2
00:00:06,000 --> 00:00:12,000
mTLS stands for mutual TLS. It means both sides of the connection authenticate each other.
The client authenticates the server. The server authenticates the client.

3
00:00:12,000 --> 00:00:18,000
Think of it like a two-way ID check at a secure facility. You show your ID to enter.
The guard also shows you their ID so you know they're legitimate.

4
00:00:18,000 --> 00:00:24,000
In our mesh, every service has an identity. Every service authenticates every other service.
No unauthenticated traffic is allowed.

5
00:00:24,000 --> 00:00:30,000
Open your editor and create `gitops/envs/istio-mesh/peer-auth-strict-mtls.yaml`.

6
00:00:30,000 --> 00:00:36,000
We'll start with the apiVersion. Security Istio v1beta1 is the stable version.
[Types: apiVersion: security.istio.io/v1beta1]

7
00:00:36,000 --> 00:00:42,000
Now the kind.
[Types: kind: PeerAuthentication]

8
00:00:42,000 --> 00:00:48,000
PeerAuthentication defines the mTLS policy. It tells Istio how services should authenticate.

9
00:00:48,000 --> 00:00:54,000
Now the metadata. The first policy is for the financial-rag namespace.
[Types: metadata: name: financial-rag-strict-mtls namespace: financial-rag]

10
00:00:54,000 --> 00:01:00,000
This policy applies to all services in the financial-rag namespace.

11
00:01:00,000 --> 00:01:06,000
Now the spec.
[Types: spec: selector: {}]

12
00:01:06,000 --> 00:01:12,000
The empty selector applies to all workloads in the namespace. Every service gets mTLS.

13
00:01:12,000 --> 00:01:18,000
[Types: mtls: mode: STRICT]

14
00:01:18,000 --> 00:01:24,000
STRICT mode requires mTLS. If a client doesn't present a valid certificate,
the connection is rejected.

15
00:01:24,000 --> 00:01:30,000
Now let's create a second PeerAuthentication for the istio-system namespace.
[Types: --- apiVersion: security.istio.io/v1beta1 kind: PeerAuthentication]

16
00:01:30,000 --> 00:01:36,000
The separator creates a second resource in the same file.

17
00:01:36,000 --> 00:01:42,000
[Types: metadata: name: default-strict-mtls namespace: istio-system]

18
00:01:42,000 --> 00:01:48,000
This policy applies to all services in the istio-system namespace. This includes
the ingress gateway.

19
00:01:48,000 --> 00:01:54,000
[Types: spec: selector: {} mtls: mode: STRICT]

20
00:01:54,000 --> 00:02:00,000
Same as before. STRICT mode for all services in the istio-system namespace.

21
00:02:00,000 --> 00:02:06,000
Now let's create the authorization policies. Open
`gitops/envs/istio-mesh/authorization-policies.yaml`.

22
00:02:06,000 --> 00:02:12,000
Authorization policies control WHO can access WHAT. They define which identities
can talk to which services.

23
00:02:12,000 --> 00:02:18,000
[Types: apiVersion: security.istio.io/v1beta1 kind: AuthorizationPolicy]

24
00:02:18,000 --> 00:02:24,000
AuthorizationPolicy defines access control rules. It's like a firewall for the mesh.

25
00:02:24,000 --> 00:02:30,000
[Types: metadata: name: deny-all namespace: financial-rag]

26
00:02:30,000 --> 00:02:36,000
The first policy is deny-all. This is the baseline. Nothing is allowed by default.

27
00:02:36,000 --> 00:02:42,000
[Types: spec: {}]

28
00:02:42,000 --> 00:02:48,000
An empty spec means deny all traffic. This is the principle of zero-trust.

29
00:02:48,000 --> 00:02:54,000
Now let's create the allow-gateway-to-api policy.
[Types: --- apiVersion: security.istio.io/v1beta1 kind: AuthorizationPolicy]

30
00:02:54,000 --> 00:03:00,000
[Types: metadata: name: allow-gateway-to-api namespace: financial-rag]

31
00:03:00,000 --> 00:03:06,000
This policy allows the ingress gateway to talk to the API service.

32
00:03:06,000 --> 00:03:12,000
[Types: spec: selector: matchLabels: app.kubernetes.io/component: api]

33
00:03:12,000 --> 00:03:18,000
The selector applies this policy to the API service. Only traffic to the API is affected.

34
00:03:18,000 --> 00:03:24,000
[Types: rules: - from: - source: principals: - "cluster.local/ns/istio-system/sa/istio-ingressgateway"]

35
00:03:24,000 --> 00:03:30,000
The source principal is the identity of the caller. This is the Istio ingress gateway
service account. Only traffic from this identity is allowed.

36
00:03:30,000 --> 00:03:36,000
[Types: to: - operation: methods: ["GET", "POST"] ports: ["8000"]]

37
00:03:36,000 --> 00:03:42,000
The operation defines what actions are allowed. Only GET and POST on port 8000.

38
00:03:42,000 --> 00:03:48,000
Now let's create the allow-api-to-agent policy.
[Types: --- apiVersion: security.istio.io/v1beta1 kind: AuthorizationPolicy]

39
00:03:48,000 --> 00:03:54,000
[Types: metadata: name: allow-api-to-agent namespace: financial-rag]

40
00:03:54,000 --> 00:04:00,000
[Types: spec: selector: matchLabels: app.kubernetes.io/component: agent]

41
00:04:00,000 --> 00:04:06,000
This policy applies to the Agent service. It controls who can talk to the agent.

42
00:04:06,000 --> 00:04:12,000
[Types: rules: - from: - source: principals: - "cluster.local/ns/financial-rag/sa/financial-rag-agent-api"]

43
00:04:12,000 --> 00:04:18,000
Only the API service account can talk to the agent. No other service is allowed.

44
00:04:18,000 --> 00:04:24,000
[Types: to: - operation: methods: ["POST"] ports: ["8001"]]

45
00:04:24,000 --> 00:04:30,000
Only POST requests on port 8001 are allowed. This is the inference endpoint.

46
00:04:30,000 --> 00:04:36,000
Now let's create the allow-prometheus-scrape policy.
[Types: --- apiVersion: security.istio.io/v1beta1 kind: AuthorizationPolicy]

47
00:04:36,000 --> 00:04:42,000
[Types: metadata: name: allow-prometheus-scrape namespace: financial-rag]

48
00:04:42,000 --> 00:04:48,000
[Types: spec: rules: - from: - source: principals: - "cluster.local/ns/monitoring/sa/kube-prometheus-stack-prometheus"]

49
00:04:48,000 --> 00:04:54,000
This allows Prometheus to scrape metrics. Only the Prometheus service account is allowed.

50
00:04:54,000 --> 00:05:00,000
[Types: to: - operation: methods: ["GET"] paths: ["/metrics", "/health"]]

51
00:05:00,000 --> 00:05:06,000
Only GET requests to /metrics and /health are allowed. This is the metrics scraping endpoint.

52
00:05:06,000 --> 00:05:12,000
Now let's apply all these policies. The GitOps system will apply them automatically.

53
00:05:12,000 --> 00:05:18,000
[Types: kubectl apply -f gitops/envs/istio-mesh/]

54
00:05:18,000 --> 00:05:24,000
This applies all files in the istio-mesh directory. All policies are now active.

55
00:05:24,000 --> 00:05:30,000
Now let's verify mTLS is working.

56
00:05:30,000 --> 00:05:36,000
[Types: kubectl get peerauthentication -n financial-rag]

57
00:05:36,000 --> 00:05:42,000
You should see financial-rag-strict-mtls. The status should be "Active".

58
00:05:42,000 --> 00:05:48,000
[Types: kubectl describe peerauthentication financial-rag-strict-mtls -n financial-rag]

59
00:05:48,000 --> 00:05:54,000
This shows the mTLS configuration. Mode is STRICT.

60
00:05:54,000 --> 00:06:00,000
Now let's verify the authorization policies.

61
00:06:00,000 --> 00:06:06,000
[Types: kubectl get authorizationpolicies -n financial-rag]

62
00:06:06,000 --> 00:06:12,000
You should see deny-all, allow-gateway-to-api, allow-api-to-agent,
and allow-prometheus-scrape.

63
00:06:12,000 --> 00:06:18,000
Now let's test the authorization. Make a request from outside the mesh.

64
00:06:18,000 --> 00:06:24,000
[Types: curl -v https://api.financial-rag.cloudfrugal.com/health]

65
00:06:24,000 --> 00:06:30,000
This should work. The gateway is allowed to talk to the API.

66
00:06:30,000 --> 00:06:36,000
Now let's test a request from inside the mesh. Exec into the API pod.

67
00:06:36,000 --> 00:06:42,000
[Types: kubectl exec -it deploy/financial-rag-agent-api -n financial-rag -- /bin/sh]

68
00:06:42,000 --> 00:06:48,000
[Types: curl -v http://financial-rag-agent-agent:8001/health]

69
00:06:48,000 --> 00:06:54,000
This should work. The API is allowed to talk to the agent.

70
00:06:54,000 --> 00:07:00,000
Now let's test a forbidden request. Exec into the ingestion pod.

71
00:07:00,000 --> 00:07:06,000
[Types: kubectl exec -it job/financial-rag-agent-ingestion -n financial-rag -- /bin/sh]

72
00:07:06,000 --> 00:07:12,000
[Types: curl -v http://financial-rag-agent-agent:8001/health]

73
00:07:12,000 --> 00:07:18,000
This should fail. The ingestion service is not allowed to talk to the agent.
The connection should be rejected.

74
00:07:18,000 --> 00:07:24,000
This is the power of zero-trust. Services can only talk to authorized services.
Nothing else is allowed.

75
00:07:24,000 --> 00:07:30,000
Now let me explain the security model.

76
00:07:30,000 --> 00:07:36,000
Every service has an identity. The identity is based on the Kubernetes service account.
Istio creates a certificate for each identity. That certificate is used for mTLS.

77
00:07:36,000 --> 00:07:42,000
When a service makes a request, Istio checks the certificate. It verifies the identity.
It checks if the identity is allowed to make the request.

78
00:07:42,000 --> 00:07:48,000
If the identity is not allowed, the request is rejected. No traffic flows.

79
00:07:48,000 --> 00:07:54,000
This is defense in depth. Cilium enforces network policies. Istio enforces
mTLS and authorization. They work together.

80
00:07:54,000 --> 00:08:00,000
Now let me recap what we've built in Part 7.

81
00:08:00,000 --> 00:08:06,000
We built the mTLS policies. STRICT mode requires mutual authentication.

82
00:08:06,000 --> 00:08:12,000
We built the authorization policies. deny-all baseline. allow-gateway-to-api.
allow-api-to-agent. allow-prometheus-scrape.

83
00:08:12,000 --> 00:08:18,000
We verified mTLS is working. All traffic is encrypted and authenticated.

84
00:08:18,000 --> 00:08:24,000
We verified authorization is working. Allowed traffic passes. Forbidden traffic is rejected.

85
00:08:24,000 --> 00:08:30,000
This is the complete security stack. Cilium for network policies. Istio for
mTLS and authorization. Falco for runtime security.

86
00:08:30,000 --> 00:08:36,000
Phase 9 is now complete. You have a fully secure service mesh.

87
00:08:36,000 --> 00:08:42,000
Thank you for watching. I'll see you in Phase 10.

88
00:08:42,000 --> 00:08:46,000
[End of Part 7]