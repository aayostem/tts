# Series 3: Kubernetes Cost Visibility — Kubecost on EKS

## Complete 24-Segment SRT — 2 Hours

---

### SEGMENT 1: Why Cost Explorer Is Not Enough
**Timestamp:** 00:00 – 05:00

```
1
00:00:00,000 --> 00:00:10,000
Welcome to Series 3. In Series 2, you found over twelve thousand dollars of waste at the AWS account level.

2
00:00:10,000 --> 00:00:20,000
You migrated gp2 to gp3. You released unattached EIPs. You terminated stopped instances. You created VPC endpoints.

3
00:00:20,000 --> 00:00:30,000
But that was only the tip of the iceberg. The real waste—the waste that compounds silently—is inside your Kubernetes cluster.

4
00:00:30,000 --> 00:00:40,000
AWS Cost Explorer shows you EC2 cost. It shows you EBS cost. It shows you NAT Gateway cost. But it cannot answer the question that actually matters to an engineering team running Kubernetes.

5
00:00:40,000 --> 00:00:50,000
Which namespace, which deployment, which pod is wasting my money? Cost Explorer operates at the AWS resource level. It does not know about Kubernetes concepts.

6
00:00:50,000 --> 00:01:00,000
It does not know that ten pods are sharing one EC2 instance. It does not know which namespace owns which pod. It does not know that the llm-ingest deployment requested eight CPUs and only uses two.

7
00:01:00,000 --> 00:01:10,000
Kubecost does. Kubecost sits inside your cluster. It watches every pod, namespace, deployment, and persistent volume claim.

8
00:01:10,000 --> 00:01:20,000
It collects CPU, memory, storage, and network metrics every thirty seconds. It combines those Kubernetes metrics with your AWS billing data.

9
00:01:20,000 --> 00:01:30,000
It calculates exactly how much of each EC2 instance's cost should be attributed to each pod—then rolls that up to namespace, team, and service.

10
00:01:30,000 --> 00:01:40,000
The result: you go from "our EC2 bill is twenty-two thousand dollars" to "the financial-rag namespace is spending fourteen thousand two hundred dollars at forty-eight percent efficiency."

11
00:01:40,000 --> 00:01:50,000
That is the difference between guessing and knowing. Let me show you what we found when we deployed Kubecost at that same startup.

12
00:01:50,000 --> 00:02:00,000
After the waste audit in Series 2, their bill dropped from forty-seven thousand to thirty-four thousand eight hundred dollars. They were thrilled. They thought they were done.

13
00:02:00,000 --> 00:02:10,000
But inside the cluster, there was more waste. Much more. We deployed Kubecost. Within one hour, we had the real numbers.

14
00:02:10,000 --> 00:02:20,000
The financial-rag namespace: twenty-two thousand dollars a month at zero point four eight efficiency. They were wasting fifty-two percent of their requested compute.

15
00:02:20,000 --> 00:02:30,000
The riskoracle namespace: nine thousand dollars a month at zero point six one efficiency. Wasting thirty-nine percent. Kube-system plus monitoring: three thousand eight hundred dollars a month.

16
00:02:30,000 --> 00:02:40,000
We applied the rightsizing recommendations. CPU requests reduced sixty percent. Memory requests reduced forty percent. Karpenter removed the now-empty nodes.

17
00:02:40,000 --> 00:02:50,000
The financial-rag namespace dropped from twenty-two thousand to fourteen thousand. Riskoracle dropped from nine thousand to six thousand.

18
00:02:50,000 --> 00:03:00,000
Combined with Series 2 savings: total bill went from forty-seven thousand to twenty thousand dollars. In two series.

19
00:03:00,000 --> 00:03:10,000
That is the power of Kubecost. Now let me show you how to deploy it on your own cluster.

20
00:03:10,000 --> 00:03:20,000
Before we deploy Kubecost, let's verify your environment. Follow along with me.

21
00:03:20,000 --> 00:03:30,000
[Types: kubectl get nodes]
▶ Pronounced as: "Kubectl, get, nodes"

22
00:03:30,000 --> 00:03:40,000
Now, look at that output. You should see three or more nodes with status Ready. If you see nothing, your cluster is not running or your kubeconfig is wrong.

23
00:03:40,000 --> 00:03:50,000
[Types: kubectl cluster-info]
▶ Pronounced as: "Kubectl, cluster, dash, info"

24
00:03:50,000 --> 00:04:00,000
Now, look at that output. You should see your Kubernetes control plane URL. This confirms kubectl is configured correctly.

25
00:04:00,000 --> 00:04:10,000
[Types: helm version]
▶ Pronounced as: "Helm, version"

26
00:04:10,000 --> 00:04:20,000
Now, look at that output. You should see version information for Helm. If you get "command not found", install Helm first.

27
00:04:20,000 --> 00:04:30,000
[Types: aws ce get-cost-and-usage --time-period Start=$START,End=$END --granularity MONTHLY --metrics BlendedCost --query 'ResultsByTime[0].Total.BlendedCost.Amount' --output text]
▶ Pronounced as: "AWS, C-E, get, cost, and, usage..."

28
00:04:30,000 --> 00:04:40,000
Now, look at that output. This confirms Cost Explorer access for the cloud integration. Kubecost needs this to pull your actual AWS pricing.

29
00:04:40,000 --> 00:04:50,000
Now let's add the Kubecost Helm repository. This is where we get the Kubecost charts.

30
00:04:50,000 --> 00:05:00,000
[Types: helm repo add kubecost https://kubecost.github.io/cost-analyzer/]
▶ Pronounced as: "Helm, repo, add, kubecost, H-T-T-P-S, colon, slash, slash, kubecost, dot, github, dot, io, slash, cost, dash, analyzer"

31
00:05:00,000 --> 00:05:10,000
[Types: helm repo update]
▶ Pronounced as: "Helm, repo, update"

32
00:05:10,000 --> 00:05:20,000
Now, look at that output. You should see "Successfully got an update from the kubecost repository." This confirms Helm can access the charts.

33
00:05:20,000 --> 00:05:30,000
Now let's create the kubecost namespace. This is where all Kubecost components will live.

34
00:05:30,000 --> 00:05:40,000
[Types: kubectl create namespace kubecost]
▶ Pronounced as: "Kubectl, create, namespace, kubecost"

35
00:05:40,000 --> 00:05:50,000
[Types: kubectl get namespace kubecost]
▶ Pronounced as: "Kubectl, get, namespace, kubecost"

36
00:05:50,000 --> 00:06:00,000
Now, look at that output. You should see the kubecost namespace with status Active. This is where your cost data will live.

37
00:06:00,000 --> 00:06:10,000
Now let's install Kubecost. This is the main installation command. Follow along with me.

38
00:06:10,000 --> 00:06:20,000
[Types: helm install kubecost kubecost/cost-analyzer --namespace kubecost --set kubecostToken="your-email@company.com" --set global.aws.enabled=true --set global.aws.cloudIntegrationEnabled=true --set prometheus.server.persistentVolume.enabled=false --set kubecostProductConfigs.clusterName="finops-cluster" --set kubecostProductConfigs.currencyCode="USD"]
▶ Pronounced as: "Helm, install, kubecost, kubecost, slash, cost, dash, analyzer, dash, dash, namespace, kubecost, dash, dash, set, kubecostToken, equals, quote, your-email, at, company, dot, com, quote..."

39
00:06:20,000 --> 00:06:30,000
Let me explain what each flag does. Global dot aws dot enabled equals true switches pricing from GCP defaults to AWS.

40
00:06:30,000 --> 00:06:40,000
Cloud integration enabled equals true uses your actual costs including Reserved Instance discounts, not list prices.

41
00:06:40,000 --> 00:06:50,000
Persistent volume enabled equals false saves EBS cost during learning. We enable this in production.

42
00:06:50,000 --> 00:07:00,000
Cluster name labels all cost data with your cluster name—critical for multi-cluster setups.

43
00:07:00,000 --> 00:07:10,000
Now let's wait for all pods to be running. This takes a few minutes.

44
00:07:10,000 --> 00:07:20,000
[Types: kubectl get pods -n kubecost -w]
▶ Pronounced as: "Kubectl, get, pods, dash, n, kubecost, dash, w"

45
00:07:20,000 --> 00:07:30,000
Now, look at that output. You should see these pods starting: kubecost-cost-analyzer, prometheus-server, kubecost-grafana, kubecost-network-costs, and kubecost-agent.

46
00:07:30,000 --> 00:07:40,000
If a pod stays in CrashLoopBackOff, check the logs. The most common causes are insufficient node memory, missing IAM permissions, or Prometheus failing to scrape metrics.

47
00:07:40,000 --> 00:07:50,000
[Types: kubectl logs -n kubecost <pod-name> --previous]
▶ Pronounced as: "Kubectl, logs, dash, n, kubecost, less-than, pod, dash, name, greater-than, dash, dash, previous"

48
00:07:50,000 --> 00:08:00,000
Now let's access the Kubecost dashboard. We'll use port-forwarding to access it from your browser.

49
00:08:00,000 --> 00:08:10,000
[Types: kubectl port-forward --namespace kubecost service/kubecost-cost-analyzer 9090:9090 &]
▶ Pronounced as: "Kubectl, port, dash, forward, dash, dash, namespace, kubecost, service, slash, kubecost, dash, cost, dash, analyzer, nine-zero-nine-zero, colon, nine-zero-nine-zero, ampersand"

50
00:08:10,000 --> 00:08:20,000
Now open your browser and go to http://localhost:9090. You should see the Kubecost homepage with cluster cost data.

51
00:08:20,000 --> 00:08:30,000
If you see "No data yet", wait five to ten minutes for the first metric scrape to complete. Kubecost needs time to collect data.

52
00:08:30,000 --> 00:08:40,000
Now let's look at the Allocation view. This is your primary view for ninety percent of cost investigations.

53
00:08:40,000 --> 00:08:50,000
Click Allocation in the left menu. You will see a table showing cost by namespace. This is where the real visibility begins.

54
00:08:50,000 --> 00:09:00,000
You'll see namespaces like financial-rag, riskoracle, kube-system, monitoring, and kubecost. Each row shows CPU cost, RAM cost, storage, network, total cost, and efficiency.

55
00:09:00,000 --> 00:09:10,000
Let me show you what a typical output looks like. The financial-rag namespace might show fourteen thousand two hundred dollars total with zero point four eight efficiency.

56
00:09:10,000 --> 00:09:20,000
The riskoracle namespace might show nine thousand dollars total with zero point six one efficiency. And kube-system might show three thousand eight hundred dollars.

57
00:09:20,000 --> 00:09:30,000
Your numbers will differ—these illustrate the pattern. But the insight is the same: you now know exactly where your money is going inside the cluster.

58
00:09:30,000 --> 00:09:40,000
Now let's get the same data from the CLI. This is how you automate cost reporting.

59
00:09:40,000 --> 00:09:50,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/allocation?window=7d&aggregate=namespace' | jq '.data[0] | to_entries[] | {namespace: .key, totalCost: .value.totalCost, efficiency: .value.efficiency, cpuCost: .value.cpuCost, ramCost: .value.ramCost}']
▶ Pronounced as: "Kubectl, exec, dash, n, kubecost, deploy, slash, kubecost, dash, cost, dash, analyzer, dash, dash, curl, dash, s, quote, H-T-T-P, colon, slash, slash, localhost, colon, nine-zero-nine-zero..."

60
00:09:50,000 --> 00:10:00,000
Now, look at that output. You should see a JSON list showing each namespace with its cost and efficiency. This is the same data you see in the dashboard—available from the CLI.

61
00:10:00,000 --> 00:10:10,000
Now let's talk about efficiency scores. This is the single most important number on this page.

62
00:10:10,000 --> 00:10:20,000
Efficiency equals actual usage divided by requested resources. A score of zero point five means you are using half of what you requested—you are paying for twice the compute you need.

63
00:10:20,000 --> 00:10:30,000
A score of zero point seven to zero point eight five is the target zone. You need headroom for traffic spikes, memory leaks, and bursty workloads.

64
00:10:30,000 --> 00:10:40,000
A score of one point zero means one traffic spike causes CPU throttling or OOM kills. The goal is efficient, not maxed out.

65
00:10:40,000 --> 00:10:50,000
Now let's find overprovisioned namespaces. These are the ones with efficiency below zero point seven.

66
00:10:50,000 --> 00:11:00,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/allocation?window=7d&aggregate=namespace' | jq '.data[0] | to_entries[] | select(.value.efficiency < 0.7) | {namespace: .key, efficiency: .value.efficiency, wastedCPU: .value.cpuCores, wastedRAMGB: (.value.ramBytes / 1073741824 | floor), monthlyCost: .value.totalCost}']
▶ Pronounced as: "Kubectl, exec... curl... jq... select..."

67
00:11:00,000 --> 00:11:10,000
Now, look at that output. This shows you every namespace with efficiency below zero point seven. These are your optimization opportunities.

68
00:11:10,000 --> 00:11:20,000
Now let's recap what you learned in this part. You learned why Cost Explorer is not enough for Kubernetes visibility.

69
00:11:20,000 --> 00:11:30,000
You deployed Kubecost on your EKS cluster. You accessed the dashboard. You looked at cost by namespace. You understood efficiency scores.

70
00:11:30,000 --> 00:11:40,000
And you found your first overprovisioned namespaces. In Part 2, we go deeper. We look at cost by team. We find rightsizing opportunities. We apply the fixes.

71
00:11:40,000 --> 00:11:50,000
But for now, verify Kubecost is running. Browse the dashboard. Look at your namespace costs. Get familiar with the data.

72
00:11:50,000 --> 00:12:00,000
You now have visibility into your cluster that ninety-nine percent of engineering teams never achieve. That is the foundation.

73
00:12:00,000 --> 00:12:10,000
See you in Segment 2.
```

---

### SEGMENT 2: Installing Kubecost on EKS
**Timestamp:** 10:00 – 15:00

```
74
00:12:10,000 --> 00:12:20,000
Welcome back. We are going to complete the Kubecost installation.

75
00:12:20,000 --> 00:12:30,000
In the previous segment, you started the installation. Now we verify everything is working correctly.

76
00:12:30,000 --> 00:12:40,000
[Types: kubectl get pods -n kubecost]
▶ Pronounced as: "Kubectl, get, pods, dash, n, kubecost"

77
00:12:40,000 --> 00:12:50,000
Now, look at that output. All pods should show Running and 1/1 in the READY column. If any are not running, wait a few more minutes.

78
00:12:50,000 --> 00:13:00,000
[Types: kubectl logs -n kubecost deployment/kubecost-cost-analyzer --tail=20]
▶ Pronounced as: "Kubectl, logs, dash, n, kubecost, deployment, slash, kubecost, dash, cost, dash, analyzer, dash, dash, tail, equals, twenty"

79
00:13:00,000 --> 00:13:10,000
Now, look at that output. You should see the cost-analyzer logs. Look for lines that say "Starting server" or "Kubecost started successfully."

80
00:13:10,000 --> 00:13:20,000
If you see error messages, they will tell you what is wrong. Common issues: insufficient node memory, missing IAM permissions, or network connectivity problems.

81
00:13:20,000 --> 00:13:30,000
[Types: kubectl port-forward --namespace kubecost service/kubecost-cost-analyzer 9090:9090 &]
▶ Pronounced as: "Kubectl, port, dash, forward, dash, dash, namespace, kubecost, service, slash, kubecost, dash, cost, dash, analyzer, nine-zero-nine-zero, colon, nine-zero-nine-zero, ampersand"

82
00:13:30,000 --> 00:13:40,000
Now open your browser to http://localhost:9090. You should see the Kubecost homepage.

83
00:13:40,000 --> 00:13:50,000
The dashboard shows your cluster's total cost, cost by namespace, and efficiency metrics. It may take a few minutes for all data to populate.

84
00:13:50,000 --> 00:14:00,000
If you see "No data available", wait five minutes and refresh. Kubecost needs time to scrape metrics from Prometheus.

85
00:14:00,000 --> 00:14:10,000
[Types: kubectl get pods -n kubecost -l app=kubecost-network-costs]
▶ Pronounced as: "Kubectl, get, pods, dash, n, kubecost, dash, l, app, equals, kubecost, dash, network, dash, costs"

86
00:14:10,000 --> 00:14:20,000
Now, look at that output. You should see one network-costs pod per node. This DaemonSet uses eBPF to track network traffic.

87
00:14:20,000 --> 00:14:30,000
If network-costs pods are not running, check that your cluster supports eBPF. Some older kernels do not.

88
00:14:30,000 --> 00:14:40,000
Now let's verify the cloud integration is working. This is what connects Kubecost to your AWS billing data.

89
00:14:40,000 --> 00:14:50,000
[Types: kubectl exec -n kubecost deployment/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/model/allocation?window=1d' | jq '.data[0] | keys | length']
▶ Pronounced as: "Kubectl, exec, dash, n, kubecost, deployment, slash, kubecost, dash, cost, dash, analyzer..."

90
00:14:50,000 --> 00:15:00,000
Now, look at that output. If you see a number greater than zero, Kubecost is successfully pulling allocation data.

91
00:15:00,000 --> 00:15:10,000
[Types: kubectl exec -n kubecost deployment/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/model/allocation?window=30d&aggregate=namespace' | jq '.data[0] | to_entries[] | select(.value.totalCost > 0) | .key']
▶ Pronounced as: "Kubectl, exec... curl... jq..."

92
00:15:10,000 --> 00:15:20,000
Now, look at that output. You should see a list of namespaces that have cost data. If you only see "kubecost" and "kube-system", wait longer for data to populate.

93
00:15:20,000 --> 00:15:30,000
Kubecost is now fully installed and operational. You have visibility into your cluster costs.

94
00:15:30,000 --> 00:15:40,000
In the next segment, we explore cost by namespace in depth and find the expensive workloads.

95
00:15:40,000 --> 00:15:50,000
See you in Segment 3.
```

---

### SEGMENT 3: Cost by Namespace — Finding the Expensive Workloads
**Timestamp:** 15:00 – 20:00

```
96
00:15:50,000 --> 00:16:00,000
Now let's explore cost by namespace. This is where you find the expensive workloads.

97
00:16:00,000 --> 00:16:10,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/allocation?window=30d&aggregate=namespace&accumulate=true' | jq -r '.data[0] | to_entries[] | "\(.key)\t\(.value.totalCost | . * 100 | round / 100)"' | sort -t$'\t' -k2 -rn | awk 'BEGIN{print "NAMESPACE\t\tCOST/MONTH"} {printf "%-30s\t$%s\n", $1, $2}']
▶ Pronounced as: "Kubectl, exec... curl... jq..."

98
00:16:10,000 --> 00:16:20,000
Now, look at that output. You should see each namespace with its monthly cost. This is your starting point for optimization.

99
00:16:20,000 --> 00:16:30,000
The financial-rag namespace might show fourteen thousand two hundred dollars. The riskoracle namespace might show nine thousand dollars.

100
00:16:30,000 --> 00:16:40,000
Now let's look at the efficiency breakdown. This shows you how much compute you are wasting.

101
00:16:40,000 --> 00:16:50,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/allocation?window=30d&aggregate=namespace&accumulate=true' | jq -r '.data[0] | to_entries[] | "\(.key)\t\(.value.cpuEfficiency | . * 100 | round)%\t\(.value.ramEfficiency | . * 100 | round)%"' | awk 'BEGIN{print "NAMESPACE\t\t\tCPU EFF\t\tMEM EFF"} {printf "%-30s\t%s\t\t%s\n", $1, $2, $3}']
▶ Pronounced as: "Kubectl, exec... curl... jq..."

102
00:16:50,000 --> 00:17:00,000
Now, look at that output. If you see efficiency below fifty percent, that namespace is wasting more than half its requested compute.

103
00:17:00,000 --> 00:17:10,000
The efficiency score is calculated as actual usage divided by requested resources. If a pod requests 2 CPU cores and uses 1, efficiency is fifty percent.

104
00:17:10,000 --> 00:17:20,000
The target range for production workloads is seventy to eighty-five percent. Below sixty percent is waste. Below forty percent is significant waste.

105
00:17:20,000 --> 00:17:30,000
Now let's look at cost by deployment. This tells you which deployment in a namespace is the most expensive.

106
00:17:30,000 --> 00:17:40,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/allocation?window=30d&aggregate=deployment&accumulate=true' | jq -r '.data[0] | to_entries[] | select(.value.totalCost > 0) | "\(.key)\t\(.value.totalCost | . * 100 | round / 100)"' | sort -t$'\t' -k2 -rn | head -10 | awk 'BEGIN{print "DEPLOYMENT\t\tCOST/MONTH"} {printf "%-30s\t$%s\n", $1, $2}']
▶ Pronounced as: "Kubectl, exec... curl... jq..."

107
00:17:40,000 --> 00:17:50,000
Now, look at that output. You should see the top ten deployments by cost. This is where to focus your optimization efforts.

108
00:17:50,000 --> 00:18:00,000
The llm-ingest deployment is often the top contributor in RAG systems. It handles the heavy lifting of document ingestion and embedding generation.

109
00:18:00,000 --> 00:18:10,000
Now let's look at cost by service. This shows you cost by the service label.

110
00:18:10,000 --> 00:18:20,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/allocation?window=30d&aggregate=service&accumulate=true' | jq -r '.data[0] | to_entries[] | select(.value.totalCost > 0) | "\(.key)\t\(.value.totalCost | . * 100 | round / 100)"' | sort -t$'\t' -k2 -rn | head -10 | awk 'BEGIN{print "SERVICE\t\tCOST/MONTH"} {printf "%-30s\t$%s\n", $1, $2}']
▶ Pronounced as: "Kubectl, exec... curl... jq..."

111
00:18:20,000 --> 00:18:30,000
Now, look at that output. This is chargeback-ready data. Each service has a cost. Each team can see their spend.

112
00:18:30,000 --> 00:18:40,000
Now let's update your baseline document with these findings.

113
00:18:40,000 --> 00:18:50,000
[Types: echo "=== SERIES 3: COST BY NAMESPACE ===" >> ~/finops-baseline.txt]
[Types: echo "Date: $(date)" >> ~/finops-baseline.txt]
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/allocation?window=30d&aggregate=namespace&accumulate=true' | jq -r '.data[0] | to_entries[] | "\(.key): $\(.value.totalCost | . * 100 | round / 100) (efficiency: \(.value.cpuEfficiency | . * 100 | round)%)"' >> ~/finops-baseline.txt]
▶ Pronounced as: "Echo... kubectl exec... curl... jq..."

114
00:18:50,000 --> 00:19:00,000
Now, look at that output. Your baseline document now includes cost by namespace and efficiency scores.

115
00:19:00,000 --> 00:19:10,000
In the next segment, we look at rightsizing recommendations and apply them safely.

116
00:19:10,000 --> 00:19:20,000
See you in Segment 4.
```

---

### SEGMENT 4: Rightsizing Recommendations & Applying Them Safely
**Timestamp:** 20:00 – 25:00

```
117
00:19:20,000 --> 00:19:30,000
Now let's look at rightsizing recommendations. This is where the savings really start.

118
00:19:30,000 --> 00:19:40,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/savings/requestSizing?window=30d&targetCPUUtilization=0.75&targetRAMUtilization=0.75' | jq -r '.recommendations[] | "\(.containerName)\t\(.currentCPUReq)→\(.recommendedCPUReq)\t\(.currentRAMReq)→\(.recommendedRAMReq)\t$\(.monthlySavings)"' | sort -t'$' -k2 -rn | head -10 | awk 'BEGIN{print "CONTAINER\t\tCPU\t\tRAM\t\tSAVINGS/MONTH"} {printf "%-25s\t%s\t%s\t%s\n", $1, $2, $3, $4}']
▶ Pronounced as: "Kubectl, exec... curl... jq..."

119
00:19:40,000 --> 00:19:50,000
Now, look at that output. You should see recommendations for each container. Each row shows current CPU and RAM requests, recommended values, and monthly savings.

120
00:19:50,000 --> 00:20:00,000
The target CPU utilization is seventy-five percent. This leaves twenty-five percent headroom for traffic spikes. This is the safe default.

121
00:20:00,000 --> 00:20:10,000
The llm-ingest container might show 2000m → 450m. That is two CPU cores reduced to four hundred and fifty millicores. Monthly savings: six hundred and twenty dollars.

122
00:20:10,000 --> 00:20:20,000
Apply the recommendation for one deployment first. Start with a non-critical service.

123
00:20:20,000 --> 00:20:30,000
[Types: kubectl patch deployment rag-retrieval --namespace financial-rag --type=merge -p '{"spec":{"template":{"spec":{"containers":[{"name":"rag-retrieval","resources":{"requests":{"cpu":"280m","memory":"800Mi"},"limits":{"cpu":"560m","memory":"1.6Gi"}}}]}}}}']
▶ Pronounced as: "Kubectl, patch, deployment, rag, dash, retrieval, dash, dash, namespace, financial, dash, rag..."

124
00:20:30,000 --> 00:20:40,000
This patches the deployment with the recommended resource requests and limits.

125
00:20:40,000 --> 00:20:50,000
[Types: kubectl rollout status deployment/rag-retrieval -n financial-rag]
▶ Pronounced as: "Kubectl, rollout, status, deployment, slash, rag, dash, retrieval, dash, n, financial, dash, rag"

126
00:20:50,000 --> 00:21:00,000
Now, look at that output. You should see "deployment successfully rolled out" when the new pods are ready.

127
00:21:00,000 --> 00:21:10,000
[Types: kubectl top pods -n financial-rag -l app=rag-retrieval --containers]
▶ Pronounced as: "Kubectl, top, pods, dash, n, financial, dash, rag..."

128
00:21:10,000 --> 00:21:20,000
Now, look at that output. This shows the current CPU and memory usage of your pods. Verify it is within the new limits.

129
00:21:20,000 --> 00:21:30,000
If you see CPU usage consistently hitting the new limit, increase it by twenty percent and re-apply.

130
00:21:30,000 --> 00:21:40,000
If you see usage at forty to sixty percent of the new limit, you have headroom to spare and the rightsizing was correct.

131
00:21:40,000 --> 00:21:50,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/metrics' | grep -c "throttled" || echo "0"]
▶ Pronounced as: "Kubectl, exec... curl... grep..."

132
00:21:50,000 --> 00:22:00,000
Now, look at that output. This checks for CPU throttling. If you see a number greater than zero, some containers are being throttled.

133
00:22:00,000 --> 00:22:10,000
CPU throttling is silent performance degradation. Your pods are running, but they are slow. Always check after applying rightsizing.

134
00:22:10,000 --> 00:22:20,000
[Types: kubectl describe pod -n financial-rag -l app=rag-retrieval | grep -A5 "OOMKilled" || echo "No OOMKills"]
▶ Pronounced as: "Kubectl, describe, pod..."

135
00:22:20,000 --> 00:22:30,000
Now, look at that output. This checks for OOMKills. If a pod was killed due to memory pressure, increase the memory limit.

136
00:22:30,000 --> 00:22:40,000
Apply the next recommendation. Work through each container one at a time. Monitor after each change.

137
00:22:40,000 --> 00:22:50,000
This approach is safe. You make small changes, monitor the impact, and only proceed when you are confident.

138
00:22:50,000 --> 00:23:00,000
In the next segment, we look at savings summary and update the baseline.

139
00:23:00,000 --> 00:23:10,000
See you in Segment 5.
```

---

### SEGMENT 5: Savings Summary & Baseline Update
**Timestamp:** 25:00 – 30:00

```
140
00:23:10,000 --> 00:23:20,000
Now let's look at the total savings from rightsizing.

141
00:23:20,000 --> 00:23:30,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/savings/requestSizing?window=30d&targetCPUUtilization=0.75&targetRAMUtilization=0.75' | jq '.totalMonthlySavings']
▶ Pronounced as: "Kubectl, exec... curl... jq..."

142
00:23:30,000 --> 00:23:40,000
Now, look at that output. This is your total monthly savings from rightsizing recommendations.

143
00:23:40,000 --> 00:23:50,000
After applying rightsizing across the financial-rag and riskoracle namespaces, here is what the numbers look like.

144
00:23:50,000 --> 00:24:00,000
Before rightsizing: financial-rag at fourteen thousand two hundred dollars a month, forty-eight percent efficiency.

145
00:24:00,000 --> 00:24:10,000
After rightsizing: eight thousand eight hundred dollars a month, seventy-eight percent efficiency.

146
00:24:10,000 --> 00:24:20,000
Riskoracle before: nine thousand dollars a month, sixty-one percent efficiency. After: five thousand six hundred dollars a month, eighty-two percent efficiency.

147
00:24:20,000 --> 00:24:30,000
Combined namespace savings from rightsizing alone: eight thousand eight hundred dollars a month. One hundred and five thousand six hundred dollars a year.

148
00:24:30,000 --> 00:24:40,000
This is before Karpenter. Rightsizing reduces what each pod requests. Karpenter reduces the nodes needed to schedule those smaller pods.

149
00:24:40,000 --> 00:24:50,000
They compound. Rightsized pods mean fewer nodes to pack them onto. Karpenter then continuously right-sizes the node fleet.

150
00:24:50,000 --> 00:25:00,000
Update the baseline document:

151
00:25:00,000 --> 00:25:10,000
[Types: echo "" >> ~/finops-baseline.txt]
[Types: echo "=== SERIES 3: KUBECOST RIGHTSIZING ===" >> ~/finops-baseline.txt]
[Types: echo "Date: $(date)" >> ~/finops-baseline.txt]
[Types: echo "" >> ~/finops-baseline.txt]
[Types: echo "financial-rag namespace: \$14,200 → \$8,800/month (48% → 78% efficiency)" >> ~/finops-baseline.txt]
[Types: echo "riskoracle namespace: \$9,000 → \$5,600/month (61% → 82% efficiency)" >> ~/finops-baseline.txt]
[Types: echo "Total namespace savings: \$8,800/month | \$105,600/year" >> ~/finops-baseline.txt]
[Types: echo "" >> ~/finops-baseline.txt]

152
00:25:10,000 --> 00:25:20,000
Now, look at that output. Your baseline document is updated with the rightsizing savings.

153
00:25:20,000 --> 00:25:30,000
Kubecost also surfaces network cost attribution and PV cost attribution.

154
00:25:30,000 --> 00:25:40,000
Network cost shows how much cross-AZ data transfer each namespace generates. PV cost shows which persistent volume claims are consuming storage.

155
00:25:40,000 --> 00:25:50,000
Both of these are in the full source material in the companion repository.

156
00:25:50,000 --> 00:26:00,000
In the next segment, we explore cost by team label for chargeback-ready data.

157
00:26:00,000 --> 00:26:10,000
See you in Segment 6.
```

---

### SEGMENT 6: Cost by Team Label — Chargeback-Ready Data
**Timestamp:** 30:00 – 35:00

```
158
00:30:00,000 --> 00:30:10,000
Now let's look at cost by team label. This is chargeback-ready data.

159
00:30:10,000 --> 00:30:20,000
Before you can query cost by team, you need to add team labels to your namespaces.

160
00:30:20,000 --> 00:30:30,000
[Types: kubectl label namespace financial-rag team=financial-rag]
[Types: kubectl label namespace riskoracle team=riskoracle]
[Types: kubectl label namespace monitoring team=platform]
▶ Pronounced as: "Kubectl, label, namespace, financial, dash, rag, team, equals, financial, dash, rag..."

161
00:30:30,000 --> 00:30:40,000
[Types: kubectl get namespaces --show-labels | grep team]
▶ Pronounced as: "Kubectl, get, namespaces, dash, dash, show, dash, labels..."

162
00:30:40,000 --> 00:30:50,000
Now, look at that output. You should see each namespace with its team label.

163
00:30:50,000 --> 00:31:00,000
Now query cost by team:

164
00:31:00,000 --> 00:31:10,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/allocation?window=30d&aggregate=label:team&accumulate=true' | jq -r '.data[0] | to_entries[] | "\(.key)\t\(.value.totalCost | . * 100 | round / 100)"' | sort -t$'\t' -k2 -rn | awk 'BEGIN{print "TEAM\t\tCOST/MONTH"} {printf "%-25s\t$%s\n", $1, $2}']
▶ Pronounced as: "Kubectl, exec... curl... jq..."

165
00:31:10,000 --> 00:31:20,000
Now, look at that output. This shows you cost by team. This is the data your finance team needs for chargeback.

166
00:31:20,000 --> 00:31:30,000
The financial-rag team might show fourteen thousand two hundred dollars. The riskoracle team might show nine thousand dollars.

167
00:31:30,000 --> 00:31:40,000
This is specific accountability. Each team sees their cost. No more collective blame.

168
00:31:40,000 --> 00:31:50,000
Now let's update the baseline document with this data.

169
00:31:50,000 --> 00:32:00,000
[Types: echo "" >> ~/finops-baseline.txt]
[Types: echo "--- COST BY TEAM ---" >> ~/finops-baseline.txt]
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/allocation?window=30d&aggregate=label:team&accumulate=true' | jq -r '.data[0] | to_entries[] | "\(.key): $\(.value.totalCost | . * 100 | round / 100)"' >> ~/finops-baseline.txt]
▶ Pronounced as: "Echo... kubectl exec... curl... jq..."

170
00:32:00,000 --> 00:32:10,000
Now, look at that output. Your baseline document now includes cost by team.

171
00:32:10,000 --> 00:32:20,000
Now let's look at efficiency by team. This shows you which teams are wasting the most compute.

172
00:32:20,000 --> 00:32:30,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/allocation?window=30d&aggregate=label:team&accumulate=true' | jq -r '.data[0] | to_entries[] | "\(.key)\t\(.value.cpuEfficiency | . * 100 | round)%\t\(.value.ramEfficiency | . * 100 | round)%"' | awk 'BEGIN{print "TEAM\t\t\tCPU EFF\t\tMEM EFF"} {printf "%-25s\t%s\t\t%s\n", $1, $2, $3}']
▶ Pronounced as: "Kubectl, exec... curl... jq..."

173
00:32:30,000 --> 00:32:40,000
Now, look at that output. If a team has low efficiency, they are wasting compute. Have a conversation with that team.

174
00:32:40,000 --> 00:32:50,000
The framing is important. Do not say "you are wasting money." Say "we found an opportunity to save money in your namespace. Here is how."

175
00:32:50,000 --> 00:33:00,000
Specific accountability produces action. Collective accountability produces nothing.

176
00:33:00,000 --> 00:33:10,000
In the next segment, we dive deeper into idle cost analysis.

177
00:33:10,000 --> 00:33:20,000
See you in Segment 7.
```

---

### SEGMENT 7: Idle Cost Analysis — Finding the Gap Between Requested and Actual
**Timestamp:** 35:00 – 40:00

```
178
00:35:00,000 --> 00:35:10,000
Now let's look at idle costs. This is where the real waste lives.

179
00:35:10,000 --> 00:35:20,000
Idle costs are resources you are paying for but not using—the gap between requested and actual.

180
00:35:20,000 --> 00:35:30,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/allocation?window=30d&aggregate=namespace&idle=true&accumulate=true' | jq -r '.data[0] | to_entries[] | "\(.key)\t\(.value.idleCost | . * 100 | round / 100)\t\(.value.totalCost | . * 100 | round / 100)"' | awk 'BEGIN{print "NAMESPACE\t\tIDLE COST\tTOTAL COST"} {printf "%-30s\t$%s\t\t$%s\n", $1, $2, $3}' | sort -t$'\t' -k2 -rn]
▶ Pronounced as: "Kubectl, exec... curl... jq..."

181
00:35:30,000 --> 00:35:40,000
Now, look at that output. You should see each namespace with its idle cost and total cost.

182
00:35:40,000 --> 00:35:50,000
The financial-rag namespace might show idleCost of eleven hundred and twenty dollars with totalCost of twenty-two hundred dollars.

183
00:35:50,000 --> 00:36:00,000
That means you are paying fifty-one dollars for every hundred dollars of compute. Fifty-one percent waste.

184
00:36:00,000 --> 00:36:10,000
This is the waste that rightsizing recovers. Every idle dollar is an opportunity to save.

185
00:36:10,000 --> 00:36:20,000
Now let's look at cluster-wide efficiency. This single number tells your CTO how efficiently you are running.

186
00:36:20,000 --> 00:36:30,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/allocation?window=30d&aggregate=cluster&accumulate=true' | jq -r '.data[0] | to_entries[] | "Cluster efficiency: \(.value.cpuEfficiency | . * 100 | round)% | \(.value.ramEfficiency | . * 100 | round)%"']
▶ Pronounced as: "Kubectl, exec... curl... jq..."

187
00:36:30,000 --> 00:36:40,000
Now, look at that output. Below sixty percent efficiency is a serious conversation about overprovisioning.

188
00:36:40,000 --> 00:36:50,000
Above eighty-five percent is a conversation about reliability risk. The target is seventy to eighty-five percent.

189
00:36:50,000 --> 00:37:00,000
Most clusters run at forty to sixty percent efficiency. That means they are wasting forty to sixty percent of their compute budget.

190
00:37:00,000 --> 00:37:10,000
Your goal is seventy to eighty-five percent. This is achievable with rightsizing and Karpenter.

191
00:37:10,000 --> 00:37:20,000
Now let's update the baseline document with the idle cost data.

192
00:37:20,000 --> 00:37:30,000
[Types: echo "" >> ~/finops-baseline.txt]
[Types: echo "--- IDLE COST ANALYSIS ---" >> ~/finops-baseline.txt]
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/allocation?window=30d&aggregate=namespace&idle=true&accumulate=true' | jq -r '.data[0] | to_entries[] | "\(.key): idle cost $\(.value.idleCost | . * 100 | round / 100) of $\(.value.totalCost | . * 100 | round / 100)"' >> ~/finops-baseline.txt]
▶ Pronounced as: "Echo... kubectl exec... curl... jq..."

193
00:37:30,000 --> 00:37:40,000
Now, look at that output. Your baseline document now includes idle cost data.

194
00:37:40,000 --> 00:37:50,000
In the next segment, we look at network cost attribution.

195
00:37:50,000 --> 00:38:00,000
See you in Segment 8.
```

---

### SEGMENT 8: Network Cost Attribution — Finding Traffic Pattern Waste
**Timestamp:** 40:00 – 45:00

```
196
00:40:00,000 --> 00:40:10,000
Now let's look at network cost attribution. This is where you find silent waste in traffic patterns.

197
00:40:10,000 --> 00:40:20,000
[Types: kubectl get pods -n kubecost -l app=kubecost-network-costs]
▶ Pronounced as: "Kubectl, get, pods, dash, n, kubecost, dash, l, app, equals, kubecost, dash, network, dash, costs"

198
00:40:20,000 --> 00:40:30,000
Now, look at that output. You should see one network cost pod per node. This uses eBPF to capture traffic at the kernel level.

199
00:40:30,000 --> 00:40:40,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/allocation?window=30d&aggregate=namespace&accumulate=true' | jq -r '.data[0] | to_entries[] | "\(.key)\t\(.value.networkCost | . * 100 | round / 100)\t\(.value.networkCrossZoneCost | . * 100 | round / 100)\t\(.value.networkInternetCost | . * 100 | round / 100)"' | awk 'BEGIN{print "NAMESPACE\t\tNETWORK\tCROSS-ZONE\tINTERNET"} {printf "%-30s\t$%s\t$%s\t$%s\n", $1, $2, $3, $4}' | sort -t$'\t' -k2 -rn]
▶ Pronounced as: "Kubectl, exec... curl... jq..."

200
00:40:40,000 --> 00:40:50,000
Now, look at that output. This shows network cost by namespace. Two things to look for.

201
00:40:50,000 --> 00:41:00,000
First, crossZoneCost high. That means services are making cross-AZ calls unnecessarily.

202
00:41:00,000 --> 00:41:10,000
Ensure replica pods and their database are in the same AZ. Use topology-aware routing.

203
00:41:10,000 --> 00:41:20,000
Second, internetCost high. That means something is calling external APIs excessively.

204
00:41:20,000 --> 00:41:30,000
Check for retry storms, missing caches, or misconfigured polling intervals.

205
00:41:30,000 --> 00:41:40,000
Let me give you a real case. A client's ingestion namespace had eight hundred dollars a month in internetCost.

206
00:41:40,000 --> 00:41:50,000
Investigation revealed the ingestion service was re-downloading SEC filings it had already processed.

207
00:41:50,000 --> 00:42:00,000
The SHA-256 deduplication check had a bug that always returned false. Fix: one-line code change. Savings: eight hundred dollars a month permanently.

208
00:42:00,000 --> 00:42:10,000
Now let's update the baseline document with the network cost data.

209
00:42:10,000 --> 00:42:20,000
[Types: echo "" >> ~/finops-baseline.txt]
[Types: echo "--- NETWORK COST BY NAMESPACE ---" >> ~/finops-baseline.txt]
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/allocation?window=30d&aggregate=namespace&accumulate=true' | jq -r '.data[0] | to_entries[] | "\(.key): network cost $\(.value.networkCost | . * 100 | round / 100)"' >> ~/finops-baseline.txt]
▶ Pronounced as: "Echo... kubectl exec... curl... jq..."

210
00:42:20,000 --> 00:42:30,000
Now, look at that output. Your baseline document now includes network cost data.

211
00:42:30,000 --> 00:42:40,000
In the next segment, we look at storage cost attribution.

212
00:42:40,000 --> 00:42:50,000
See you in Segment 9.
```

---

### SEGMENT 9: Storage Cost Attribution — Finding PVC Waste
**Timestamp:** 45:00 – 50:00

```
213
00:45:00,000 --> 00:45:10,000
Now let's look at persistent volume cost attribution. Storage costs are often invisible until they compound.

214
00:45:10,000 --> 00:45:20,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/allocation?window=30d&aggregate=namespace&accumulate=true' | jq -r '.data[0] | to_entries[] | "\(.key)\t\(.value.storageCost | . * 100 | round / 100)"' | awk 'BEGIN{print "NAMESPACE\t\tSTORAGE COST"} {printf "%-30s\t$%s\n", $1, $2}' | sort -t$'\t' -k2 -rn]
▶ Pronounced as: "Kubectl, exec... curl... jq..."

215
00:45:20,000 --> 00:45:30,000
Now, look at that output. This shows storage cost by namespace.

216
00:45:30,000 --> 00:45:40,000
Three common findings. First, PVCs provisioned at five hundred gigabytes but only twenty percent used. Resize them.

217
00:45:40,000 --> 00:45:50,000
Second, PVCs for terminated pods still allocated. Delete them. Third, multiple PVCs for the same data. Consolidate them.

218
00:45:50,000 --> 00:46:00,000
[Types: kubectl get pvc --all-namespaces -o custom-columns='NAMESPACE:.metadata.namespace,NAME:.metadata.name,CAPACITY:.spec.resources.requests.storage,STATUS:.status.phase' | grep -v "Bound"]
▶ Pronounced as: "Kubectl, get, pvc, dash, dash, all, dash, namespaces..."

219
00:46:00,000 --> 00:46:10,000
Now, look at that output. This shows you all PVCs that are not in Bound status. These are candidates for cleanup.

220
00:46:10,000 --> 00:46:20,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/allocation?window=30d&aggregate=pvc&accumulate=true' | jq -r '.data[0] | to_entries[] | "\(.key)\t\(.value.storageCost | . * 100 | round / 100)"' | awk 'BEGIN{print "PVC\t\tSTORAGE COST"} {printf "%-40s\t$%s\n", $1, $2}' | sort -t$'\t' -k2 -rn | head -10]
▶ Pronounced as: "Kubectl, exec... curl... jq..."

221
00:46:20,000 --> 00:46:30,000
Now, look at that output. This shows the top ten PVCs by storage cost.

222
00:46:30,000 --> 00:46:40,000
For each expensive PVC, check if it is still needed. If not, delete it. If it is needed, verify it is provisioned at the right size.

223
00:46:40,000 --> 00:46:50,000
Now let's update the baseline document with the storage cost data.

224
00:46:50,000 --> 00:47:00,000
[Types: echo "" >> ~/finops-baseline.txt]
[Types: echo "--- STORAGE COST BY NAMESPACE ---" >> ~/finops-baseline.txt]
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/allocation?window=30d&aggregate=namespace&accumulate=true' | jq -r '.data[0] | to_entries[] | "\(.key): storage cost $\(.value.storageCost | . * 100 | round / 100)"' >> ~/finops-baseline.txt]
▶ Pronounced as: "Echo... kubectl exec... curl... jq..."

225
00:47:00,000 --> 00:47:10,000
Now, look at that output. Your baseline document now includes storage cost data.

226
00:47:10,000 --> 00:47:20,000
In the next segment, we look at how to set up cost alerts in Kubecost.

227
00:47:20,000 --> 00:47:30,000
See you in Segment 10.
```

---

### SEGMENT 10: Setting Up Cost Alerts in Kubecost
**Timestamp:** 50:00 – 55:00

```
228
00:50:00,000 --> 00:50:10,000
Now let's set up cost alerts in Kubecost. This is how you get notified when costs exceed thresholds.

229
00:50:10,000 --> 00:50:20,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s -X POST 'http://localhost:9090/alerts' -H 'Content-Type: application/json' -d '{"alerts":[{"type":"anomaly","threshold":50,"slackWebhookUrl":"https://hooks.slack.com/services/your-webhook","window":"1d"}]}']
▶ Pronounced as: "Kubectl, exec... curl... X POST..."

230
00:50:20,000 --> 00:50:30,000
This creates an anomaly alert that triggers when a daily cost spike exceeds fifty dollars.

231
00:50:30,000 --> 00:50:40,000
You can also set budget alerts by namespace.

232
00:50:40,000 --> 00:50:50,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s -X POST 'http://localhost:9090/alerts' -H 'Content-Type: application/json' -d '{"alerts":[{"type":"budget","namespace":"financial-rag","threshold":1000,"slackWebhookUrl":"https://hooks.slack.com/services/your-webhook","window":"monthly"}]}']
▶ Pronounced as: "Kubectl, exec... curl... X POST..."

233
00:50:50,000 --> 00:51:00,000
This creates a budget alert for the financial-rag namespace. You get notified when monthly cost exceeds one thousand dollars.

234
00:51:00,000 --> 00:51:10,000
You can also set alerts for efficiency drops.

235
00:51:10,000 --> 00:51:20,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s -X POST 'http://localhost:9090/alerts' -H 'Content-Type: application/json' -d '{"alerts":[{"type":"efficiency","namespace":"financial-rag","threshold":60,"slackWebhookUrl":"https://hooks.slack.com/services/your-webhook"}]}']
▶ Pronounced as: "Kubectl, exec... curl... X POST..."

236
00:51:20,000 --> 00:51:30,000
This creates an efficiency alert. You get notified when efficiency drops below sixty percent.

237
00:51:30,000 --> 00:51:40,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/alerts' | jq '.alerts[] | {type: .type, namespace: .namespace, threshold: .threshold}']
▶ Pronounced as: "Kubectl, exec... curl... jq..."

238
00:51:40,000 --> 00:51:50,000
Now, look at that output. This shows you all active alerts in Kubecost.

239
00:51:50,000 --> 00:52:00,000
You can also set alerts through the Kubecost dashboard. Go to Settings → Alerts.

240
00:52:00,000 --> 00:52:10,000
This is the Operate phase. You are automating detection so you do not need to watch the dashboard constantly.

241
00:52:10,000 --> 00:52:20,000
In the next segment, we look at creating custom dashboards in Kubecost.

242
00:52:20,000 --> 00:52:30,000
See you in Segment 11.
```

---

### SEGMENT 11: Creating Custom Dashboards in Kubecost
**Timestamp:** 55:00 – 60:00

```
243
00:55:00,000 --> 00:55:10,000
Now let's create custom dashboards in Kubecost. This is how you monitor what matters to your team.

244
00:55:10,000 --> 00:55:20,000
Kubecost supports custom dashboards. You can create views that show cost by namespace, by team, by deployment, or by service.

245
00:55:20,000 --> 00:55:30,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/dashboards' | jq '.dashboards[] | {name: .name, description: .description}']
▶ Pronounced as: "Kubectl, exec... curl... jq..."

246
00:55:30,000 --> 00:55:40,000
Now, look at that output. This shows you the default dashboards available in Kubecost.

247
00:55:40,000 --> 00:55:50,000
You can create custom dashboards by saving specific filters and views in the Kubecost UI.

248
00:55:50,000 --> 00:56:00,000
For example, you can create a dashboard for the financial-rag team that only shows their namespace cost.

249
00:56:00,000 --> 00:56:10,000
To do this in the UI: go to Allocation → set namespace filter to financial-rag → save as a new dashboard.

250
00:56:10,000 --> 00:56:20,000
You can also create a dashboard for cost by service. This shows you which service is the most expensive.

251
00:56:20,000 --> 00:56:30,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/dashboards/save' -H 'Content-Type: application/json' -d '{"name":"Financial RAG Team Cost","description":"Cost view for the financial-rag team","filter":{"namespace":"financial-rag"},"aggregate":"namespace"}']
▶ Pronounced as: "Kubectl, exec... curl... X POST..."

252
00:56:30,000 --> 00:56:40,000
This saves a custom dashboard for the financial-rag team.

253
00:56:40,000 --> 00:56:50,000
Dashboards can be shared with teams. They are useful for weekly cost review meetings.

254
00:56:50,000 --> 00:57:00,000
In the next segment, we look at exporting Kubecost data for reporting.

255
00:57:00,000 --> 00:57:10,000
See you in Segment 12.
```

---

### SEGMENT 12: Exporting Kubecost Data for Reporting
**Timestamp:** 60:00 – 65:00

```
256
01:00:00,000 --> 01:00:10,000
Now let's look at exporting Kubecost data for reporting.

257
01:00:10,000 --> 01:00:20,000
Kubecost exports data in CSV, JSON, and API formats. You can integrate it with your existing reporting tools.

258
01:00:20,000 --> 01:00:30,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/allocation?window=30d&aggregate=namespace&format=csv' --output /tmp/kubecost-allocation.csv]
▶ Pronounced as: "Kubectl, exec... curl... format, equals, csv..."

259
01:00:30,000 --> 01:00:40,000
[Types: cat /tmp/kubecost-allocation.csv | head -20]
▶ Pronounced as: "Cat, slash, tmp, slash, kubecost, dash, allocation, dot, csv..."

260
01:00:40,000 --> 01:00:50,000
Now, look at that output. This shows the CSV export of Kubecost allocation data.

261
01:00:50,000 --> 01:01:00,000
You can also export data using the Kubecost API. This is how you automate reporting.

262
01:01:00,000 --> 01:01:10,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/savings/requestSizing?window=30d' | jq '.' > /tmp/kubecost-rightsizing.json]
▶ Pronounced as: "Kubectl, exec... curl... jq..."

263
01:01:10,000 --> 01:01:20,000
[Types: cat /tmp/kubecost-rightsizing.json | head -30]
▶ Pronounced as: "Cat, slash, tmp, slash, kubecost, dash, rightsizing, dot, json..."

264
01:01:20,000 --> 01:01:30,000
Now, look at that output. This shows the JSON export of Kubecost rightsizing recommendations.

265
01:01:30,000 --> 01:01:40,000
You can also export data to S3 for long-term storage.

266
01:01:40,000 --> 01:01:50,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/allocation?window=30d&aggregate=namespace&format=csv' --output /tmp/kubecost-allocation.csv]
[Types: aws s3 cp /tmp/kubecost-allocation.csv s3://your-bucket/kubecost-data/allocation-$(date +%Y-%m-%d).csv]
▶ Pronounced as: "Kubectl, exec... curl... aws, S-three, cp..."

267
01:01:50,000 --> 01:02:00,000
This uploads the allocation data to S3 for long-term storage.

268
01:02:00,000 --> 01:02:10,000
You can also schedule this as a cron job to run daily.

269
01:02:10,000 --> 01:02:20,000
In the next segment, we look at integrating Kubecost with Slack.

270
01:02:20,000 --> 01:02:30,000
See you in Segment 13.
```

---

### SEGMENT 13: Integrating Kubecost with Slack
**Timestamp:** 65:00 – 70:00

```
271
01:05:00,000 --> 01:05:10,000
Now let's integrate Kubecost with Slack. This is how you get cost alerts where your team works.

272
01:05:10,000 --> 01:05:20,000
Kubecost supports Slack webhook integration. Set it up once and receive alerts in your team's Slack channel.

273
01:05:20,000 --> 01:05:30,000
First, create a Slack webhook. Go to Slack → Apps → Incoming Webhooks → Create a new webhook.

274
01:05:30,000 --> 01:05:40,000
Copy the webhook URL. It looks like: https://hooks.slack.com/services/T123456/B789012/abc123def456

275
01:05:40,000 --> 01:05:50,000
Now configure Kubecost to send alerts to Slack.

276
01:05:50,000 --> 01:06:00,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s -X POST 'http://localhost:9090/alerts' -H 'Content-Type: application/json' -d '{"alerts":[{"type":"anomaly","threshold":50,"slackWebhookUrl":"https://hooks.slack.com/services/your-webhook","window":"1d","channel":"#finops-alerts"}]}']
▶ Pronounced as: "Kubectl, exec... curl... X POST..."

277
01:06:00,000 --> 01:06:10,000
This sends anomaly alerts to the #finops-alerts Slack channel.

278
01:06:10,000 --> 01:06:20,000
You can also send daily cost summaries to Slack.

279
01:06:20,000 --> 01:06:30,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s -X POST 'http://localhost:9090/slack' -H 'Content-Type: application/json' -d '{"channel":"#finops-alerts","message":"Daily cost summary: $2,345.67 | Top namespace: financial-rag ($1,234.56)"}']
▶ Pronounced as: "Kubectl, exec... curl... X POST..."

280
01:06:30,000 --> 01:06:40,000
This sends a daily cost summary to Slack. You can schedule this as a cron job.

281
01:06:40,000 --> 01:06:50,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s -X POST 'http://localhost:9090/slack' -H 'Content-Type: application/json' -d '{"channel":"#finops-alerts","message":"Efficiency alert: financial-rag namespace efficiency dropped to 48%!"}']
▶ Pronounced as: "Kubectl, exec... curl... X POST..."

282
01:06:50,000 --> 01:07:00,000
This sends an efficiency alert to Slack when efficiency drops below a threshold.

283
01:07:00,000 --> 01:07:10,000
Now let's verify Slack is connected:

284
01:07:10,000 --> 01:07:20,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/slack/status']
▶ Pronounced as: "Kubectl, exec... curl... status"

285
01:07:20,000 --> 01:07:30,000
Now, look at that output. If Slack is connected, you will see a status of "connected".

286
01:07:30,000 --> 01:07:40,000
Slack integration makes cost monitoring visible to the whole team. It creates shared accountability.

287
01:07:40,000 --> 01:07:50,000
In the next segment, we do a workshop — analyzing your cluster costs.

288
01:07:50,000 --> 01:08:00,000
See you in Segment 14.
```

---

### SEGMENT 14: Workshop — Analyzing Your Cluster Costs
**Timestamp:** 70:00 – 75:00

```
289
01:10:00,000 --> 01:10:10,000
Welcome to the workshop segment. We are going to analyze your cluster costs together.

290
01:10:10,000 --> 01:10:20,000
Run each command. Look at the output. Write down your findings. This is where you apply what you learned.

291
01:10:20,000 --> 01:10:30,000
Command 1: What is the total cost of your cluster?

292
01:10:30,000 --> 01:10:40,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/allocation?window=30d&aggregate=cluster' | jq -r '.data[0] | to_entries[] | "Total cluster cost: $\(.value.totalCost | . * 100 | round / 100)"']
▶ Pronounced as: "Kubectl, exec... curl... jq..."

293
01:10:40,000 --> 01:10:50,000
Write this number down. This is your cluster cost.

294
01:10:50,000 --> 01:11:00,000
Command 2: What are the top three namespaces by cost?

295
01:11:00,000 --> 01:11:10,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/allocation?window=30d&aggregate=namespace' | jq -r '.data[0] | to_entries[] | "\(.key): $\(.value.totalCost | . * 100 | round / 100)"' | head -3]
▶ Pronounced as: "Kubectl, exec... curl... jq..."

296
01:11:10,000 --> 01:11:20,000
Write these down. These are your optimization priorities.

297
01:11:20,000 --> 01:11:30,000
Command 3: What is the efficiency of your most expensive namespace?

298
01:11:30,000 --> 01:11:40,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/allocation?window=30d&aggregate=namespace' | jq -r '.data[0] | to_entries[] | select(.key=="financial-rag") | "\(.key) efficiency: \(.value.cpuEfficiency | . * 100 | round)%"']
▶ Pronounced as: "Kubectl, exec... curl... jq..."

299
01:11:40,000 --> 01:11:50,000
If efficiency is below seventy percent, you have an optimization opportunity.

300
01:11:50,000 --> 01:12:00,000
Command 4: What are the top rightsizing recommendations?

301
01:12:00,000 --> 01:12:10,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/savings/requestSizing?window=30d' | jq -r '.recommendations[:3][] | "\(.containerName): save $\(.monthlySavings | . * 100 | round / 100)/month"']
▶ Pronounced as: "Kubectl, exec... curl... jq..."

302
01:12:10,000 --> 01:12:20,000
Write these down. These are your immediate savings opportunities.

303
01:12:20,000 --> 01:12:30,000
Command 5: What is the idle cost in your most expensive namespace?

304
01:12:30,000 --> 01:12:40,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/allocation?window=30d&aggregate=namespace&idle=true' | jq -r '.data[0] | to_entries[] | select(.key=="financial-rag") | "\(.key) idle cost: $\(.value.idleCost | . * 100 | round / 100)"']
▶ Pronounced as: "Kubectl, exec... curl... jq..."

305
01:12:40,000 --> 01:12:50,000
Idle cost is the gap between requested and actual. This is the waste you can recover.

306
01:12:50,000 --> 01:13:00,000
Now you have your cluster cost analysis. Use this data to prioritize your optimization work.

307
01:13:00,000 --> 01:13:10,000
In the next segment, we look at optimizing Kubernetes resource requests.

308
01:13:10,000 --> 01:13:20,000
See you in Segment 15.
```

---

### SEGMENT 15: Optimizing Kubernetes Resource Requests
**Timestamp:** 75:00 – 80:00

```
309
01:15:00,000 --> 01:15:10,000
Now let's talk about optimizing Kubernetes resource requests.

310
01:15:10,000 --> 01:15:20,000
Resource requests are the foundation of Kubernetes scheduling and cost. Every pod has CPU and memory requests.

311
01:15:20,000 --> 01:15:30,000
CPU requests determine how much CPU the pod is guaranteed. Memory requests determine how much memory the pod is guaranteed.

312
01:15:30,000 --> 01:15:40,000
The problem: most engineers set requests based on gut feeling. They guess. And they guess high.

313
01:15:40,000 --> 01:15:50,000
This is why efficiency scores are so low. Engineers request resources they do not use.

314
01:15:50,000 --> 01:16:00,000
The solution: use Kubecost recommendations. They are based on actual usage data.

315
01:16:00,000 --> 01:16:10,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/savings/requestSizing?window=30d&targetCPUUtilization=0.75&targetRAMUtilization=0.75' | jq -r '.recommendations[] | "\(.containerName): CPU \(.currentCPUReq) → \(.recommendedCPUReq) | RAM \(.currentRAMReq) → \(.recommendedRAMReq) | save $\(.monthlySavings)"' | head -5]
▶ Pronounced as: "Kubectl, exec... curl... jq..."

316
01:16:10,000 --> 01:16:20,000
Now, look at that output. This shows you how much you can save by adjusting resource requests.

317
01:16:20,000 --> 01:16:30,000
Apply recommendations one at a time. Monitor after each change.

318
01:16:30,000 --> 01:16:40,000
[Types: kubectl patch deployment llm-ingest --namespace financial-rag --type=merge -p '{"spec":{"template":{"spec":{"containers":[{"name":"llm-ingest","resources":{"requests":{"cpu":"450m","memory":"1.2Gi"},"limits":{"cpu":"900m","memory":"2.4Gi"}}}]}}}}']
▶ Pronounced as: "Kubectl, patch, deployment..."

319
01:16:40,000 --> 01:16:50,000
[Types: kubectl rollout status deployment/llm-ingest -n financial-rag]
▶ Pronounced as: "Kubectl, rollout, status..."

320
01:16:50,000 --> 01:17:00,000
[Types: kubectl top pods -n financial-rag -l app=llm-ingest]
▶ Pronounced as: "Kubectl, top, pods..."

321
01:17:00,000 --> 01:17:10,000
Now, look at that output. Verify the new resource requests are working.

322
01:17:10,000 --> 01:17:20,000
If you see CPU throttling, increase the CPU limit. If you see OOMKills, increase the memory limit.

323
01:17:20,000 --> 01:17:30,000
The goal is to find the minimum resources that support your workload. Not the maximum.

324
01:17:30,000 --> 01:17:40,000
In the next segment, we look at understanding HPA and cost implications.

325
01:17:40,000 --> 01:17:50,000
See you in Segment 16.
```

---

### SEGMENT 16: Understanding HPA & Cost Implications
**Timestamp:** 80:00 – 85:00

```
326
01:20:00,000 --> 01:20:10,000
Now let's talk about the Horizontal Pod Autoscaler and cost implications.

327
01:20:10,000 --> 01:20:20,000
HPA automatically scales the number of replicas based on CPU utilization or custom metrics.

328
01:20:20,000 --> 01:20:30,000
When configured correctly, HPA saves money by scaling down during low traffic.

329
01:20:30,000 --> 01:20:40,000
When configured incorrectly, HPA wastes money by scaling up too aggressively.

330
01:20:40,000 --> 01:20:50,000
[Types: kubectl get hpa --all-namespaces]
▶ Pronounced as: "Kubectl, get, hpa, dash, dash, all, dash, namespaces"

331
01:20:50,000 --> 01:21:00,000
Now, look at that output. This shows you all HPAs in your cluster.

332
01:21:00,000 --> 01:21:10,000
The key parameters: minReplicas, maxReplicas, targetCPUUtilizationPercentage.

333
01:21:10,000 --> 01:21:20,000
Set minReplicas to the minimum number of replicas you need during low traffic. Set maxReplicas to the maximum you need during high traffic.

334
01:21:20,000 --> 01:21:30,000
Set targetCPUUtilizationPercentage to seventy percent. This gives you headroom for traffic spikes.

335
01:21:30,000 --> 01:21:40,000
HPA cost implications: each replica costs money. The more replicas, the higher the cost.

336
01:21:40,000 --> 01:21:50,000
The goal is to find the right balance. Enough replicas to handle traffic. Not so many that you waste money.

337
01:21:50,000 --> 01:22:00,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/hpa' | jq '.hpas[] | {name: .name, minReplicas: .minReplicas, maxReplicas: .maxReplicas, targetCPUUtilization: .targetCPUUtilization}']
▶ Pronounced as: "Kubectl, exec... curl... jq..."

338
01:22:00,000 --> 01:22:10,000
Now, look at that output. This shows you the HPA configuration from Kubecost.

339
01:22:10,000 --> 01:22:20,000
Review your HPAs regularly. Adjust min and max replicas based on observed traffic patterns.

340
01:22:20,000 --> 01:22:30,000
In the next segment, we look at Kubecost best practices for production.

341
01:22:30,000 --> 01:22:40,000
See you in Segment 17.
```

---

### SEGMENT 17: Kubecost Best Practices for Production
**Timestamp:** 85:00 – 90:00

```
342
01:25:00,000 --> 01:25:10,000
Now let's look at Kubecost best practices for production.

343
01:25:10,000 --> 01:25:20,000
Kubecost is a powerful tool. But it needs to be configured correctly for production use.

344
01:25:20,000 --> 01:25:30,000
Best practice 1: Use persistent storage for Prometheus. Without persistent storage, you lose historical data on restarts.

345
01:25:30,000 --> 01:25:40,000
[Types: helm upgrade kubecost kubecost/cost-analyzer --namespace kubecost --set prometheus.server.persistentVolume.enabled=true --set prometheus.server.persistentVolume.size=50Gi]
▶ Pronounced as: "Helm, upgrade, kubecost..."

346
01:25:40,000 --> 01:25:50,000
Best practice 2: Set up multi-cluster monitoring. If you have multiple clusters, Kubecost can aggregate cost across all of them.

347
01:25:50,000 --> 01:26:00,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/allocation?window=30d&aggregate=cluster' | jq -r '.data[0] | to_entries[] | "\(.key): $\(.value.totalCost | . * 100 | round / 100)"']
▶ Pronounced as: "Kubectl, exec... curl... jq..."

348
01:26:00,000 --> 01:26:10,000
Best practice 3: Set up cost sharing for shared namespaces like kube-system.

349
01:26:10,000 --> 01:26:20,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s -X POST 'http://localhost:9090/config/costShares' -H 'Content-Type: application/json' -d '{"sharedNamespaces":["kube-system","monitoring","cert-manager"]}']
▶ Pronounced as: "Kubectl, exec... curl... X POST..."

350
01:26:20,000 --> 01:26:30,000
Best practice 4: Set up backup and restore for Kubecost data.

351
01:26:30,000 --> 01:26:40,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/backup' --output /tmp/kubecost-backup.json]
▶ Pronounced as: "Kubectl, exec... curl... backup..."

352
01:26:40,000 --> 01:26:50,000
Best practice 5: Monitor Kubecost itself. Kubecost should be monitored like any other critical service.

353
01:26:50,000 --> 01:27:00,000
[Types: kubectl get pods -n kubecost -w]
▶ Pronounced as: "Kubectl, get, pods, dash, n, kubecost..."

354
01:27:00,000 --> 01:27:10,000
Best practice 6: Keep Kubecost updated. New versions include bug fixes and performance improvements.

355
01:27:10,000 --> 01:27:20,000
[Types: helm repo update && helm upgrade kubecost kubecost/cost-analyzer --namespace kubecost]
▶ Pronounced as: "Helm, repo, update..."

356
01:27:20,000 --> 01:27:30,000
In the next segment, we do a Q&A for Series 3.

357
01:27:30,000 --> 01:27:40,000
See you in Segment 18.
```

---

### SEGMENT 18: Series 3 Q&A — Common Questions Answered
**Timestamp:** 90:00 – 95:00

```
358
01:30:00,000 --> 01:30:10,000
Welcome to the Series 3 Q&A. Here are the most common questions.

359
01:30:10,000 --> 01:30:20,000
Question 1: "I deployed Kubecost but I see no data. What is wrong?"

360
01:30:20,000 --> 01:30:30,000
Wait five to ten minutes for the first metric scrape to complete. Kubecost needs time to collect data.

361
01:30:30,000 --> 01:30:40,000
Question 2: "My efficiency scores are very low. What should I do?"

362
01:30:40,000 --> 01:30:50,000
Apply the rightsizing recommendations. Start with the highest monthly savings container first.

363
01:30:50,000 --> 01:31:00,000
Question 3: "I applied rightsizing and my pods crashed. What happened?"

364
01:31:00,000 --> 01:31:10,000
You cut resources too aggressively. Increase the memory limit by fifty percent and re-apply.

365
01:31:10,000 --> 01:31:20,000
Question 4: "How often should I review Kubecost data?"

366
01:31:20,000 --> 01:31:30,000
Weekly. Set up a recurring calendar invite for a weekly cost review. Fifteen minutes a week.

367
01:31:30,000 --> 01:31:40,000
Question 5: "Should I run Kubecost in production?"

368
01:31:40,000 --> 01:31:50,000
Yes. Kubecost is production-ready. Use persistent storage and follow the best practices we covered.

369
01:31:50,000 --> 01:32:00,000
Question 6: "What is the cost of Kubecost itself?"

370
01:32:00,000 --> 01:32:10,000
The open-source version is free. The enterprise version has a cost but includes additional features.

371
01:32:10,000 --> 01:32:20,000
Question 7: "Does Kubecost work with EKS and other managed Kubernetes services?"

372
01:32:20,000 --> 01:32:30,000
Yes. Kubecost works with any Kubernetes distribution, including EKS, AKS, and GKE.

373
01:32:30,000 --> 01:32:40,000
Question 8: "What metrics does Kubecost collect?"

374
01:32:40,000 --> 01:32:50,000
CPU, memory, storage, and network metrics from every pod, namespace, deployment, and persistent volume claim.

375
01:32:50,000 --> 01:33:00,000
Question 9: "What is the difference between Kubecost and the AWS Cost Explorer?"

376
01:33:00,000 --> 01:33:10,000
Cost Explorer shows you EC2 cost. Kubecost shows you pod cost. Kubecost gives you Kubernetes-level granularity.

377
01:33:10,000 --> 01:33:20,000
Question 10: "How much data does Kubecost store?"

378
01:33:20,000 --> 01:33:30,000
Kubecost stores data in Prometheus. The storage size depends on your cluster size. Start with fifty gigabytes.

379
01:33:30,000 --> 01:33:40,000
In the next segment, we do the Series 3 knowledge check.

380
01:33:40,000 --> 01:33:50,000
See you in Segment 19.
```

---

### SEGMENT 19: Series 3 Knowledge Check — Part 1
**Timestamp:** 95:00 – 100:00

```
381
01:35:00,000 --> 01:35:10,000
Welcome to the Series 3 knowledge check. Answer these questions.

382
01:35:10,000 --> 01:35:20,000
Question 1: What command deploys Kubecost on EKS?

383
01:35:20,000 --> 01:35:30,000
helm install kubecost kubecost/cost-analyzer --namespace kubecost

384
01:35:30,000 --> 01:35:40,000
Question 2: How do you access the Kubecost dashboard?

385
01:35:40,000 --> 01:35:50,000
kubectl port-forward --namespace kubecost service/kubecost-cost-analyzer 9090:9090

386
01:35:50,000 --> 01:36:00,000
Question 3: What command gets cost by namespace from the Kubecost API?

387
01:36:00,000 --> 01:36:10,000
kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/allocation?window=30d&aggregate=namespace'

388
01:36:10,000 --> 01:36:20,000
Question 4: What is a good efficiency score target for production workloads?

389
01:36:20,000 --> 01:36:30,000
Seventy to eighty-five percent.

390
01:36:30,000 --> 01:36:40,000
Question 5: What does efficiency score measure?

391
01:36:40,000 --> 01:36:50,000
Actual usage divided by requested resources.

392
01:36:50,000 --> 01:37:00,000
Question 6: What is idle cost?

393
01:37:00,000 --> 01:37:10,000
The gap between requested and actual resources. Compute you are paying for but not using.

394
01:37:10,000 --> 01:37:20,000
Question 7: What command applies a rightsizing recommendation?

395
01:37:20,000 --> 01:37:30,000
kubectl patch deployment --type=merge -p '{"spec":{"template":{"spec":{"containers":[{"name":"...","resources":{"requests":{"cpu":"...","memory":"..."}}}]}}}}'

396
01:37:30,000 --> 01:37:40,000
Question 8: What is the target CPU utilization for rightsizing recommendations?

397
01:37:40,000 --> 01:37:50,000
Seventy-five percent. This leaves twenty-five percent headroom for traffic spikes.

398
01:37:50,000 --> 01:38:00,000
Write down your answers. Then compare with what you learned.

399
01:38:00,000 --> 01:38:10,000
In the next segment, we continue the knowledge check.

400
01:38:10,000 --> 01:38:20,000
See you in Segment 20.
```

---

### SEGMENT 20: Series 3 Knowledge Check — Part 2
**Timestamp:** 100:00 – 105:00

```
401
01:40:00,000 --> 01:40:10,000
Welcome back. Here are the remaining knowledge check questions.

402
01:40:10,000 --> 01:40:20,000
Question 9: What command checks for CPU throttling after rightsizing?

403
01:40:20,000 --> 01:40:30,000
kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/metrics' | grep throttled

404
01:40:30,000 --> 01:40:40,000
Question 10: What command checks for OOMKills?

405
01:40:40,000 --> 01:40:50,000
kubectl describe pod -n namespace -l app=app-name | grep -A5 OOMKilled

406
01:40:50,000 --> 01:41:00,000
Question 11: How do you add a team label to a namespace?

407
01:41:00,000 --> 01:41:10,000
kubectl label namespace namespace-name team=team-name

408
01:41:10,000 --> 01:41:20,000
Question 12: What command gets cost by team from the Kubecost API?

409
01:41:20,000 --> 01:41:30,000
kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/allocation?window=30d&aggregate=label:team'

410
01:41:30,000 --> 01:41:40,000
Question 13: What command creates a Kubecost anomaly alert for Slack?

411
01:41:40,000 --> 01:41:50,000
curl -X POST 'http://localhost:9090/alerts' -H 'Content-Type: application/json' -d '{"alerts":[{"type":"anomaly","threshold":50,"slackWebhookUrl":"https://hooks.slack.com/services/your-webhook","window":"1d"}]}'

412
01:41:50,000 --> 01:42:00,000
Question 14: What command exports Kubecost allocation data to CSV?

413
01:42:00,000 --> 01:42:10,000
kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/allocation?window=30d&aggregate=namespace&format=csv' --output /tmp/kubecost-allocation.csv

414
01:42:10,000 --> 01:42:20,000
Question 15: How do you set up persistent storage for Kubecost?

415
01:42:20,000 --> 01:42:30,000
helm upgrade kubecost kubecost/cost-analyzer --namespace kubecost --set prometheus.server.persistentVolume.enabled=true --set prometheus.server.persistentVolume.size=50Gi

416
01:42:30,000 --> 01:42:40,000
Question 16: What is cluster-wide efficiency?

417
01:42:40,000 --> 01:42:50,000
The average efficiency across all namespaces in your cluster. The target is seventy to eighty-five percent.

418
01:42:50,000 --> 01:43:00,000
Write down your answers. Compare them with the correct responses.

419
01:43:00,000 --> 01:43:10,000
If you got most of these correct, you understand Series 3.

420
01:43:10,000 --> 01:43:20,000
In the next segment, we look at cost by deployment and service.

421
01:43:20,000 --> 01:43:30,000
See you in Segment 21.
```

---

### SEGMENT 21: Cost by Deployment & Service — Advanced Attribution
**Timestamp:** 105:00 – 110:00

```
422
01:45:00,000 --> 01:45:10,000
Now let's look at cost by deployment and service. This is advanced attribution.

423
01:45:10,000 --> 01:45:20,000
Cost by namespace tells you which namespace is expensive. Cost by deployment tells you which deployment in that namespace is expensive.

424
01:45:20,000 --> 01:45:30,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/allocation?window=30d&aggregate=deployment&accumulate=true' | jq -r '.data[0] | to_entries[] | select(.value.totalCost > 0) | "\(.key)\t\(.value.totalCost | . * 100 | round / 100)"' | sort -t$'\t' -k2 -rn | head -20 | awk 'BEGIN{print "DEPLOYMENT\t\t\tCOST/MONTH"} {printf "%-35s\t$%s\n", $1, $2}']
▶ Pronounced as: "Kubectl, exec... curl... jq..."

425
01:45:30,000 --> 01:45:40,000
Now, look at that output. You should see the top twenty deployments by cost.

426
01:45:40,000 --> 01:45:50,000
This is where you focus your optimization efforts. The llm-ingest deployment is often the top contributor.

427
01:45:50,000 --> 01:46:00,000
Now let's look at cost by service. This is cost attributed by the service label.

428
01:46:00,000 --> 01:46:10,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/allocation?window=30d&aggregate=service&accumulate=true' | jq -r '.data[0] | to_entries[] | select(.value.totalCost > 0) | "\(.key)\t\(.value.totalCost | . * 100 | round / 100)"' | sort -t$'\t' -k2 -rn | head -20 | awk 'BEGIN{print "SERVICE\t\t\tCOST/MONTH"} {printf "%-35s\t$%s\n", $1, $2}']
▶ Pronounced as: "Kubectl, exec... curl... jq..."

429
01:46:10,000 --> 01:46:20,000
Now, look at that output. This shows you cost by service. This is useful for microservice cost attribution.

430
01:46:20,000 --> 01:46:30,000
If you have a microservice architecture, each microservice has a service label. You can see exactly how much each microservice costs.

431
01:46:30,000 --> 01:46:40,000
This is chargeback-ready data for service owners. Each team sees their cost.

432
01:46:40,000 --> 01:46:50,000
[Types: echo "" >> ~/finops-baseline.txt]
[Types: echo "--- COST BY DEPLOYMENT ---" >> ~/finops-baseline.txt]
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/allocation?window=30d&aggregate=deployment&accumulate=true' | jq -r '.data[0] | to_entries[] | select(.value.totalCost > 0) | "\(.key): $\(.value.totalCost | . * 100 | round / 100)"' | head -5 >> ~/finops-baseline.txt]
▶ Pronounced as: "Echo... kubectl exec... curl... jq..."

433
01:46:50,000 --> 01:47:00,000
Now, look at that output. Your baseline document now includes cost by deployment.

434
01:47:00,000 --> 01:47:10,000
In the next segment, we look at advanced HPA configuration.

435
01:47:10,000 --> 01:47:20,000
See you in Segment 22.
```

---

### SEGMENT 22: Advanced HPA Configuration
**Timestamp:** 110:00 – 115:00

```
436
01:50:00,000 --> 01:50:10,000
Now let's look at advanced HPA configuration for cost optimization.

437
01:50:10,000 --> 01:50:20,000
HPA can use custom metrics, not just CPU. You can scale based on request rate, queue length, or any custom metric.

438
01:50:20,000 --> 01:50:30,000
[Types: kubectl get hpa --all-namespaces -o yaml]
▶ Pronounced as: "Kubectl, get, hpa, dash, dash, all, dash, namespaces, dash, o, yaml"

439
01:50:30,000 --> 01:50:40,000
Now, look at that output. This shows you the full HPA configuration.

440
01:50:40,000 --> 01:50:50,000
The key parameters for cost optimization: minReplicas, maxReplicas, targetCPUUtilizationPercentage, behavior.scaleDown.stabilizationWindowSeconds.

441
01:50:50,000 --> 01:51:00,000
Set minReplicas to your steady-state minimum. This is the lowest number of replicas you need during low traffic.

442
01:51:00,000 --> 01:51:10,000
Set maxReplicas to your peak traffic maximum. This is the highest number of replicas you ever need.

443
01:51:10,000 --> 01:51:20,000
Set targetCPUUtilizationPercentage to seventy percent. This gives you headroom for traffic spikes.

444
01:51:20,000 --> 01:51:30,000
Set scaleDown.stabilizationWindowSeconds to three hundred seconds. This prevents HPA from scaling down too quickly.

445
01:51:30,000 --> 01:51:40,000
[Types: kubectl patch hpa llm-ingest-hpa --namespace financial-rag --type=merge -p '{"spec":{"minReplicas":2,"maxReplicas":10,"targetCPUUtilizationPercentage":70,"behavior":{"scaleDown":{"stabilizationWindowSeconds":300}}}}']
▶ Pronounced as: "Kubectl, patch, hpa..."

446
01:51:40,000 --> 01:51:50,000
This configures the HPA for cost optimization. It scales based on CPU utilization with a three-hundred-second stabilisation window.

447
01:51:50,000 --> 01:52:00,000
[Types: kubectl get hpa llm-ingest-hpa -n financial-rag]
▶ Pronounced as: "Kubectl, get, hpa..."

448
01:52:00,000 --> 01:52:10,000
Now, look at that output. This shows the HPA configuration applied.

449
01:52:10,000 --> 01:52:20,000
Now let's verify HPA is working correctly.

450
01:52:20,000 --> 01:52:30,000
[Types: kubectl get hpa llm-ingest-hpa -n financial-rag -w]
▶ Pronounced as: "Kubectl, get, hpa... dash, w"

451
01:52:30,000 --> 01:52:40,000
Now, look at that output. You should see the HPA scaling based on CPU utilization.

452
01:52:40,000 --> 01:52:50,000
If the HPA is not scaling, check that the metrics server is running.

453
01:52:50,000 --> 01:53:00,000
[Types: kubectl get deployment metrics-server -n kube-system]
▶ Pronounced as: "Kubectl, get, deployment, metrics, dash, server..."

454
01:53:00,000 --> 01:53:10,000
In the next segment, we look at kubecost best practices in production.

455
01:53:10,000 --> 01:53:20,000
See you in Segment 23.
```

---

### SEGMENT 23: Series 3 Q&A — Part 2
**Timestamp:** 115:00 – 120:00

```
456
01:55:00,000 --> 01:55:10,000
Welcome back. Here are more common questions from Series 3.

457
01:55:10,000 --> 01:55:20,000
Question 11: "What is the difference between CPU requests and CPU limits?"

458
01:55:20,000 --> 01:55:30,000
CPU requests are guaranteed resources. The scheduler uses them to place pods. CPU limits are maximum resources. The pod cannot exceed this limit.

459
01:55:30,000 --> 01:55:40,000
Question 12: "Should I set CPU requests and limits to the same value?"

460
01:55:40,000 --> 01:55:50,000
No. Set limits higher than requests. This prevents throttling during traffic spikes.

461
01:55:50,000 --> 01:56:00,000
Question 13: "What is the cost of running Kubecost?"

462
01:56:00,000 --> 01:56:10,000
The open-source version is free. The cost is the resources it consumes in your cluster. Typically one to two CPU cores and two to four gigabytes of memory.

463
01:56:10,000 --> 01:56:20,000
Question 14: "How long does Kubecost take to show accurate data?"

464
01:56:20,000 --> 01:56:30,000
Kubecost needs at least forty-eight hours of data to show accurate efficiency scores.

465
01:56:30,000 --> 01:56:40,000
Question 15: "Does Kubecost work with multiple clusters?"

466
01:56:40,000 --> 01:56:50,000
Yes. Kubecost supports multi-cluster monitoring. You can aggregate cost across all clusters.

467
01:56:50,000 --> 01:57:00,000
Question 16: "How do I upgrade Kubecost?"

468
01:57:00,000 --> 01:57:10,000
helm repo update && helm upgrade kubecost kubecost/cost-analyzer --namespace kubecost

469
01:57:10,000 --> 01:57:20,000
Question 17: "What is the difference between Kubecost and KubeCost?"

470
01:57:20,000 --> 01:57:30,000
They are the same product. The open-source version is called Kubecost. The enterprise version is called KubeCost.

471
01:57:30,000 --> 01:57:40,000
Question 18: "Does Kubecost support spot instances?"

472
01:57:40,000 --> 01:57:50,000
Yes. Kubecost shows the cost of spot instances at their discounted rate.

473
01:57:50,000 --> 01:58:00,000
In the next segment, we look at the future of Kubecost.

474
01:58:00,000 --> 01:58:10,000
See you in Segment 24.
```

---

### SEGMENT 24: Series 3 Conclusion & Next Steps
**Timestamp:** 120:00 – 125:00

```
475
02:00:00,000 --> 02:00:10,000
Welcome to the final segment of Series 3. Let's recap everything.

476
02:00:10,000 --> 02:00:20,000
You deployed Kubecost on your EKS cluster. You accessed the dashboard. You saw cost by namespace for the first time.

477
02:00:20,000 --> 02:00:30,000
You understood efficiency scores. You found overprovisioned namespaces. You applied rightsizing recommendations.

478
02:00:30,000 --> 02:00:40,000
You checked for CPU throttling and OOMKills. You added team labels for chargeback. You analyzed idle costs.

479
02:00:40,000 --> 02:00:50,000
You attributed network and storage costs. You set up alerts. You created custom dashboards.

480
02:00:50,000 --> 02:01:00,000
You exported data for reporting. You integrated with Slack. You learned best practices for production.

481
02:01:00,000 --> 02:01:10,000
The savings from Series 3: financial-rag namespace from fourteen thousand two hundred to eight thousand eight hundred dollars a month.

482
02:01:10,000 --> 02:01:20,000
Riskoracle from nine thousand to five thousand six hundred dollars a month. Total savings: eight thousand eight hundred dollars a month.

483
02:01:20,000 --> 02:01:30,000
Combined with Series 2 savings, you have reduced the bill from forty-seven thousand to approximately twenty thousand dollars a month.

484
02:01:30,000 --> 02:01:40,000
In Series 4, we deploy Karpenter. Karpenter makes your cluster continuously self-optimizing.

485
02:01:40,000 --> 02:01:50,000
It launches nodes in seconds instead of minutes. It picks the cheapest available instance type. It continuously consolidates underutilized nodes.

486
02:01:50,000 --> 02:02:00,000
After Series 4, the compute cost drops another thirty-five percent.

487
02:02:00,000 --> 02:02:10,000
Before you start Series 4, verify these things. Kubecost is running. You have rightsized your workloads. You have updated your baseline document.

488
02:02:10,000 --> 02:02:20,000
Series 3 is complete. You now have Kubernetes cost visibility. You know exactly where your money is going inside the cluster.

489
02:02:20,000 --> 02:02:30,000
That is the difference between guessing and knowing. And you are now in the top one percent of engineers who can answer the question: which namespace, which pod is wasting my money?

490
02:02:30,000 --> 02:02:40,000
See you in Series 4.
```