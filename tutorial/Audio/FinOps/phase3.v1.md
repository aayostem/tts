---

CONSOLIDATED SERIES 3 SRT

Here is the complete consolidated Series 3:

---

Series 3: Kubernetes Cost Visibility — Kubecost on EKS
Consolidated 12-Segment SRT — 1hr 45min

---

SEGMENT 1: Why Cost Explorer Is Not Enough & Installing Kubecost
Timestamp: 00:00 – 10:00

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
The financial-rag namespace: fourteen thousand two hundred dollars a month at zero point four eight efficiency. They were wasting fifty-two percent of their requested compute.

15
00:02:20,000 --> 00:02:30,000
The riskoracle namespace: nine thousand dollars a month at zero point six one efficiency. Wasting thirty-nine percent. Kube-system plus monitoring: three thousand eight hundred dollars a month.

16
00:02:30,000 --> 00:02:40,000
We applied the rightsizing recommendations. CPU requests reduced sixty percent. Memory requests reduced forty percent. Karpenter removed the now-empty nodes.

17
00:02:40,000 --> 00:02:50,000
The financial-rag namespace dropped from fourteen thousand two hundred to eight thousand eight hundred. Riskoracle dropped from nine thousand to five thousand six hundred.

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
▶ Pronounced as: "Now I'm verifying our cluster with kubectl get nodes."

22
00:03:30,000 --> 00:03:40,000
Now, look at that output. You should see three or more nodes with status Ready. If you see nothing, your cluster is not running or your kubeconfig is wrong.

23
00:03:40,000 --> 00:03:50,000
[Types: kubectl cluster-info]
▶ Pronounced as: "Now kubectl cluster-info to confirm the control plane is accessible."

24
00:03:50,000 --> 00:04:00,000
Now, look at that output. You should see your Kubernetes control plane URL. This confirms kubectl is configured correctly.

25
00:04:00,000 --> 00:04:10,000
[Types: helm version]
▶ Pronounced as: "Now helm version to verify Helm is installed."

26
00:04:10,000 --> 00:04:20,000
Now, look at that output. You should see version information for Helm. If you get "command not found", install Helm first.

27
00:04:20,000 --> 00:04:30,000
[Types: aws ce get-cost-and-usage --time-period Start=$START,End=$END --granularity MONTHLY --metrics BlendedCost --query 'ResultsByTime[0].Total.BlendedCost.Amount' --output text]
▶ Pronounced as: "Now AWS C-E get-cost-and-usage to confirm Cost Explorer access for the cloud integration."

28
00:04:30,000 --> 00:04:40,000
Now, look at that output. This confirms Cost Explorer access for the cloud integration. Kubecost needs this to pull your actual AWS pricing.

29
00:04:40,000 --> 00:04:50,000
Now let's add the Kubecost Helm repository. This is where we get the Kubecost charts.

30
00:04:50,000 --> 00:05:00,000
[Types: helm repo add kubecost https://kubecost.github.io/cost-analyzer/]
▶ Pronounced as: "Now helm repo add kubecost with the Kubecost repository URL."

31
00:05:00,000 --> 00:05:10,000
[Types: helm repo update]
▶ Pronounced as: "Now helm repo update to refresh the repository index."

32
00:05:10,000 --> 00:05:20,000
Now, look at that output. You should see "Successfully got an update from the kubecost repository." This confirms Helm can access the charts.

33
00:05:20,000 --> 00:05:30,000
Now let's create the kubecost namespace. This is where all Kubecost components will live.

34
00:05:30,000 --> 00:05:40,000
[Types: kubectl create namespace kubecost]
▶ Pronounced as: "Now kubectl create namespace kubecost."

35
00:05:40,000 --> 00:05:50,000
[Types: kubectl get namespace kubecost]
▶ Pronounced as: "Now kubectl get namespace kubecost to verify it was created."

36
00:05:50,000 --> 00:06:00,000
Now, look at that output. You should see the kubecost namespace with status Active. This is where your cost data will live.

37
00:06:00,000 --> 00:06:10,000
Now let's install Kubecost. This is the main installation command. Follow along with me.

38
00:06:10,000 --> 00:06:20,000
[Types: helm install kubecost kubecost/cost-analyzer --namespace kubecost --set kubecostToken="your-email@company.com" --set global.aws.enabled=true --set global.aws.cloudIntegrationEnabled=true --set prometheus.server.persistentVolume.enabled=false --set kubecostProductConfigs.clusterName="finops-cluster" --set kubecostProductConfigs.currencyCode="USD"]
▶ Pronounced as: "Now helm install kubecost. We're passing flags to enable AWS pricing, cloud integration, and set the cluster name."

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
▶ Pronounced as: "Now kubectl get pods -n kubecost -w to watch the pods come up."

45
00:07:20,000 --> 00:07:30,000
Now, look at that output. You should see these pods starting: kubecost-cost-analyzer, prometheus-server, kubecost-grafana, kubecost-network-costs, and kubecost-agent.

46
00:07:30,000 --> 00:07:40,000
If a pod stays in CrashLoopBackOff, check the logs. The most common causes are insufficient node memory, missing IAM permissions, or Prometheus failing to scrape metrics.

47
00:07:40,000 --> 00:07:50,000
[Types: kubectl logs -n kubecost <pod-name> --previous]
▶ Pronounced as: "Now kubectl logs -n kubecost with the pod name and --previous flag to see the crash logs."

48
00:07:50,000 --> 00:08:00,000
Now let's access the Kubecost dashboard. We'll use port-forwarding to access it from your browser.

49
00:08:00,000 --> 00:08:10,000
[Types: kubectl port-forward --namespace kubecost service/kubecost-cost-analyzer 9090:9090 &]
▶ Pronounced as: "Now kubectl port-forward to expose the Kubecost service on localhost port 9090."

50
00:08:10,000 --> 00:08:20,000
Now open your browser and go to http://localhost:9090. You should see the Kubecost homepage with cluster cost data.

51
00:08:20,000 --> 00:08:30,000
If you see "No data yet", wait five to ten minutes for the first metric scrape to complete. Kubecost needs time to collect data.

52
00:08:30,000 --> 00:08:40,000
Kubecost is now fully installed and operational. You have visibility into your cluster costs.

53
00:08:40,000 --> 00:08:50,000
In the next segment, we explore cost by namespace in depth and find the expensive workloads.

54
00:08:50,000 --> 00:09:00,000
See you in Segment 2.
```

---

SEGMENT 2: Cost by Namespace & Rightsizing Recommendations
Timestamp: 10:00 – 20:00

```
55
00:10:00,000 --> 00:10:10,000
Now let's explore cost by namespace. This is where you find the expensive workloads.

56
00:10:10,000 --> 00:10:20,000
Click Allocation in the left menu. You will see a table showing cost by namespace. This is where the real visibility begins.

57
00:10:20,000 --> 00:10:30,000
You'll see namespaces like financial-rag, riskoracle, kube-system, monitoring, and kubecost. Each row shows CPU cost, RAM cost, storage, network, total cost, and efficiency.

58
00:10:30,000 --> 00:10:40,000
Let me show you what a typical output looks like. The financial-rag namespace might show fourteen thousand two hundred dollars total with zero point four eight efficiency.

59
00:10:40,000 --> 00:10:50,000
The riskoracle namespace might show nine thousand dollars total with zero point six one efficiency. And kube-system might show three thousand eight hundred dollars.

60
00:10:50,000 --> 00:11:00,000
Your numbers will differ—these illustrate the pattern. But the insight is the same: you now know exactly where your money is going inside the cluster.

61
00:11:00,000 --> 00:11:10,000
Now let's get the same data from the CLI. This is how you automate cost reporting.

62
00:11:10,000 --> 00:11:20,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/allocation?window=30d&aggregate=namespace&accumulate=true' | jq -r '.data[0] | to_entries[] | "\(.key)\t\(.value.totalCost | . * 100 | round / 100)"' | sort -t$'\t' -k2 -rn | awk 'BEGIN{print "NAMESPACE\t\tCOST/MONTH"} {printf "%-30s\t$%s\n", $1, $2}']
▶ Pronounced as: "Now kubectl exec and curl the allocation API with a 30-day window, aggregating by namespace. We're extracting namespace and total cost, sorting, and formatting as a table."

63
00:11:20,000 --> 00:11:30,000
Now, look at that output. You should see each namespace with its monthly cost. This is your starting point for optimization.

64
00:11:30,000 --> 00:11:40,000
Now let's look at the efficiency breakdown. This shows you how much compute you are wasting.

65
00:11:40,000 --> 00:11:50,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/allocation?window=30d&aggregate=namespace&accumulate=true' | jq -r '.data[0] | to_entries[] | "\(.key)\t\(.value.cpuEfficiency | . * 100 | round)%\t\(.value.ramEfficiency | . * 100 | round)%"' | awk 'BEGIN{print "NAMESPACE\t\t\tCPU EFF\t\tMEM EFF"} {printf "%-30s\t%s\t\t%s\n", $1, $2, $3}']
▶ Pronounced as: "Now extracting CPU and RAM efficiency percentages."

66
00:11:50,000 --> 00:12:00,000
Now, look at that output. If you see efficiency below fifty percent, that namespace is wasting more than half its requested compute.

67
00:12:00,000 --> 00:12:10,000
The efficiency score is calculated as actual usage divided by requested resources. If a pod requests 2 CPU cores and uses 1, efficiency is fifty percent.

68
00:12:10,000 --> 00:12:20,000
The target range for production workloads is seventy to eighty-five percent. Below sixty percent is waste. Below forty percent is significant waste.

69
00:12:20,000 --> 00:12:30,000
Now let's look at cost by deployment. This tells you which deployment in a namespace is the most expensive.

70
00:12:30,000 --> 00:12:40,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/allocation?window=30d&aggregate=deployment&accumulate=true' | jq -r '.data[0] | to_entries[] | select(.value.totalCost > 0) | "\(.key)\t\(.value.totalCost | . * 100 | round / 100)"' | sort -t$'\t' -k2 -rn | head -10 | awk 'BEGIN{print "DEPLOYMENT\t\tCOST/MONTH"} {printf "%-30s\t$%s\n", $1, $2}']
▶ Pronounced as: "Now aggregating by deployment, taking the top 10."

71
00:12:40,000 --> 00:12:50,000
Now, look at that output. You should see the top ten deployments by cost. This is where to focus your optimization efforts.

72
00:12:50,000 --> 00:13:00,000
The llm-ingest deployment is often the top contributor in RAG systems. It handles the heavy lifting of document ingestion and embedding generation.

73
00:13:00,000 --> 00:13:10,000
Now let's look at rightsizing recommendations. This is where the savings really start.

74
00:13:10,000 --> 00:13:20,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/savings/requestSizing?window=30d&targetCPUUtilization=0.75&targetRAMUtilization=0.75' | jq -r '.recommendations[] | "\(.containerName)\t\(.currentCPUReq)→\(.recommendedCPUReq)\t\(.currentRAMReq)→\(.recommendedRAMReq)\t$\(.monthlySavings)"' | sort -t'$' -k2 -rn | head -10 | awk 'BEGIN{print "CONTAINER\t\tCPU\t\tRAM\t\tSAVINGS/MONTH"} {printf "%-25s\t%s\t%s\t%s\n", $1, $2, $3, $4}']
▶ Pronounced as: "Now curling the savings requestSizing API with a 30-day window and 75 percent target utilization. We're extracting container name, current and recommended CPU and RAM, and monthly savings."

75
00:13:20,000 --> 00:13:30,000
Now, look at that output. You should see recommendations for each container. Each row shows current CPU and RAM requests, recommended values, and monthly savings.

76
00:13:30,000 --> 00:13:40,000
The target CPU utilization is seventy-five percent. This leaves twenty-five percent headroom for traffic spikes. This is the safe default.

77
00:13:40,000 --> 00:13:50,000
Apply the recommendation for one deployment first. Start with a non-critical service.

78
00:13:50,000 --> 00:14:00,000
[Types: kubectl patch deployment rag-retrieval --namespace financial-rag --type=merge -p '{"spec":{"template":{"spec":{"containers":[{"name":"rag-retrieval","resources":{"requests":{"cpu":"280m","memory":"800Mi"},"limits":{"cpu":"560m","memory":"1.6Gi"}}}]}}}}']
▶ Pronounced as: "Now kubectl patch deployment rag-retrieval with new resource requests and limits."

79
00:14:00,000 --> 00:14:10,000
[Types: kubectl rollout status deployment/rag-retrieval -n financial-rag]
▶ Pronounced as: "Now kubectl rollout status to wait for the new pods to be ready."

80
00:14:10,000 --> 00:14:20,000
Now, look at that output. You should see "deployment successfully rolled out" when the new pods are ready.

81
00:14:20,000 --> 00:14:30,000
[Types: kubectl top pods -n financial-rag -l app=rag-retrieval --containers]
▶ Pronounced as: "Now kubectl top pods to see current CPU and memory usage."

82
00:14:30,000 --> 00:14:40,000
Now, look at that output. This shows the current CPU and memory usage of your pods. Verify it is within the new limits.

83
00:14:40,000 --> 00:14:50,000
If you see CPU usage consistently hitting the new limit, increase it by twenty percent and re-apply.

84
00:14:50,000 --> 00:15:00,000
If you see usage at forty to sixty percent of the new limit, you have headroom to spare and the rightsizing was correct.

85
00:15:00,000 --> 00:15:10,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/metrics' | grep -c "throttled" || echo "0"]
▶ Pronounced as: "Now checking for CPU throttling."

86
00:15:10,000 --> 00:15:20,000
Now, look at that output. This checks for CPU throttling. If you see a number greater than zero, some containers are being throttled.

87
00:15:20,000 --> 00:15:30,000
[Types: kubectl describe pod -n financial-rag -l app=rag-retrieval | grep -A5 "OOMKilled" || echo "No OOMKills"]
▶ Pronounced as: "Now checking for OOMKills."

88
00:15:30,000 --> 00:15:40,000
Now, look at that output. This checks for OOMKills. If a pod was killed due to memory pressure, increase the memory limit.

89
00:15:40,000 --> 00:15:50,000
Apply the next recommendation. Work through each container one at a time. Monitor after each change.

90
00:15:50,000 --> 00:16:00,000
In the next segment, we look at savings summary and update the baseline.

91
00:16:00,000 --> 00:16:10,000
See you in Segment 3.
```

---

SEGMENT 3: Savings Summary & Baseline Update
Timestamp: 20:00 – 25:00

```
92
00:20:00,000 --> 00:20:10,000
Now let's look at the total savings from rightsizing.

93
00:20:10,000 --> 00:20:20,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/savings/requestSizing?window=30d&targetCPUUtilization=0.75&targetRAMUtilization=0.75' | jq '.totalMonthlySavings']
▶ Pronounced as: "Now curling the savings API and extracting totalMonthlySavings."

94
00:20:20,000 --> 00:20:30,000
Now, look at that output. This is your total monthly savings from rightsizing recommendations.

95
00:20:30,000 --> 00:20:40,000
After applying rightsizing across the financial-rag and riskoracle namespaces, here is what the numbers look like.

96
00:20:40,000 --> 00:20:50,000
Before rightsizing: financial-rag at fourteen thousand two hundred dollars a month, forty-eight percent efficiency.

97
00:20:50,000 --> 00:21:00,000
After rightsizing: eight thousand eight hundred dollars a month, seventy-eight percent efficiency.

98
00:21:00,000 --> 00:21:10,000
Riskoracle before: nine thousand dollars a month, sixty-one percent efficiency. After: five thousand six hundred dollars a month, eighty-two percent efficiency.

99
00:21:10,000 --> 00:21:20,000
Combined namespace savings from rightsizing: eight thousand eight hundred dollars a month. One hundred and five thousand six hundred dollars a year.

100
00:21:20,000 --> 00:21:30,000
This is before Karpenter. Rightsizing reduces what each pod requests. Karpenter reduces the nodes needed to schedule those smaller pods.

101
00:21:30,000 --> 00:21:40,000
They compound. Rightsized pods mean fewer nodes to pack them onto. Karpenter then continuously right-sizes the node fleet.

102
00:21:40,000 --> 00:21:50,000
Update the baseline document:

103
00:21:50,000 --> 00:22:00,000
[Types: echo "" >> ~/finops-baseline.txt]
[Types: echo "=== SERIES 3: KUBECOST RIGHTSIZING ===" >> ~/finops-baseline.txt]
[Types: echo "Date: $(date)" >> ~/finops-baseline.txt]
[Types: echo "" >> ~/finops-baseline.txt]
[Types: echo "financial-rag namespace: \$14,200 → \$8,800/month (48% → 78% efficiency)" >> ~/finops-baseline.txt]
[Types: echo "riskoracle namespace: \$9,000 → \$5,600/month (61% → 82% efficiency)" >> ~/finops-baseline.txt]
[Types: echo "Total namespace savings: \$8,800/month | \$105,600/year" >> ~/finops-baseline.txt]
[Types: echo "" >> ~/finops-baseline.txt]
▶ Pronounced as: "Now appending the rightsizing savings summary to our baseline document."

104
00:22:00,000 --> 00:22:10,000
Now, look at that output. Your baseline document is updated with the rightsizing savings.

105
00:22:10,000 --> 00:22:20,000
Kubecost also surfaces network cost attribution and PV cost attribution.

106
00:22:20,000 --> 00:22:30,000
Network cost shows how much cross-AZ data transfer each namespace generates. PV cost shows which persistent volume claims are consuming storage.

107
00:22:30,000 --> 00:22:40,000
Both of these are in the full source material in the companion repository.

108
00:22:40,000 --> 00:22:50,000
In the next segment, we explore cost by team label for chargeback-ready data.

109
00:22:50,000 --> 00:23:00,000
See you in Segment 4.
```

---

SEGMENT 4: Cost by Team Label — Chargeback-Ready Data
Timestamp: 25:00 – 30:00

```
110
00:25:00,000 --> 00:25:10,000
Now let's look at cost by team label. This is chargeback-ready data.

111
00:25:10,000 --> 00:25:20,000
Before you can query cost by team, you need to add team labels to your namespaces.

112
00:25:20,000 --> 00:25:30,000
[Types: kubectl label namespace financial-rag team=financial-rag]
[Types: kubectl label namespace riskoracle team=riskoracle]
[Types: kubectl label namespace monitoring team=platform]
▶ Pronounced as: "Now kubectl label namespace to add the team label to each namespace."

113
00:25:30,000 --> 00:25:40,000
[Types: kubectl get namespaces --show-labels | grep team]
▶ Pronounced as: "Now kubectl get namespaces with --show-labels and grepping for team to verify."

114
00:25:40,000 --> 00:25:50,000
Now, look at that output. You should see each namespace with its team label.

115
00:25:50,000 --> 00:26:00,000
Now query cost by team:

116
00:26:00,000 --> 00:26:10,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/allocation?window=30d&aggregate=label:team&accumulate=true' | jq -r '.data[0] | to_entries[] | "\(.key)\t\(.value.totalCost | . * 100 | round / 100)"' | sort -t$'\t' -k2 -rn | awk 'BEGIN{print "TEAM\t\tCOST/MONTH"} {printf "%-25s\t$%s\n", $1, $2}']
▶ Pronounced as: "Now aggregating by label:team to group by the team label."

117
00:26:10,000 --> 00:26:20,000
Now, look at that output. This shows you cost by team. This is the data your finance team needs for chargeback.

118
00:26:20,000 --> 00:26:30,000
The financial-rag team might show fourteen thousand two hundred dollars. The riskoracle team might show nine thousand dollars.

119
00:26:30,000 --> 00:26:40,000
This is specific accountability. Each team sees their cost. No more collective blame.

120
00:26:40,000 --> 00:26:50,000
Now let's update the baseline document with this data.

121
00:26:50,000 --> 00:27:00,000
[Types: echo "" >> ~/finops-baseline.txt]
[Types: echo "--- COST BY TEAM ---" >> ~/finops-baseline.txt]
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/allocation?window=30d&aggregate=label:team&accumulate=true' | jq -r '.data[0] | to_entries[] | "\(.key): $\(.value.totalCost | . * 100 | round / 100)"' >> ~/finops-baseline.txt]
▶ Pronounced as: "Now appending cost by team to the baseline document."

122
00:27:00,000 --> 00:27:10,000
Now, look at that output. Your baseline document now includes cost by team.

123
00:27:10,000 --> 00:27:20,000
Now let's look at efficiency by team. This shows you which teams are wasting the most compute.

124
00:27:20,000 --> 00:27:30,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/allocation?window=30d&aggregate=label:team&accumulate=true' | jq -r '.data[0] | to_entries[] | "\(.key)\t\(.value.cpuEfficiency | . * 100 | round)%\t\(.value.ramEfficiency | . * 100 | round)%"' | awk 'BEGIN{print "TEAM\t\t\tCPU EFF\t\tMEM EFF"} {printf "%-25s\t%s\t\t%s\n", $1, $2, $3}']
▶ Pronounced as: "Now extracting efficiency by team as well."

125
00:27:30,000 --> 00:27:40,000
Now, look at that output. If a team has low efficiency, they are wasting compute. Have a conversation with that team.

126
00:27:40,000 --> 00:27:50,000
The framing is important. Do not say "you are wasting money." Say "we found an opportunity to save money in your namespace. Here is how."

127
00:27:50,000 --> 00:28:00,000
Specific accountability produces action. Collective accountability produces nothing.

128
00:28:00,000 --> 00:28:10,000
In the next segment, we dive deeper into idle cost analysis and network cost attribution.

129
00:28:10,000 --> 00:28:20,000
See you in Segment 5.
```

---

SEGMENT 5: Idle Cost Analysis & Network Cost Attribution
Timestamp: 30:00 – 40:00

```
130
00:30:00,000 --> 00:30:10,000
Now let's look at idle costs. This is where the real waste lives.

131
00:30:10,000 --> 00:30:20,000
Idle costs are resources you are paying for but not using—the gap between requested and actual.

132
00:30:20,000 --> 00:30:30,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/allocation?window=30d&aggregate=namespace&idle=true&accumulate=true' | jq -r '.data[0] | to_entries[] | "\(.key)\t\(.value.idleCost | . * 100 | round / 100)\t\(.value.totalCost | . * 100 | round / 100)"' | awk 'BEGIN{print "NAMESPACE\t\tIDLE COST\tTOTAL COST"} {printf "%-30s\t$%s\t\t$%s\n", $1, $2, $3}' | sort -t$'\t' -k2 -rn]
▶ Pronounced as: "Now curling the allocation API with idle=true to include idle cost."

133
00:30:30,000 --> 00:30:40,000
Now, look at that output. You should see each namespace with its idle cost and total cost.

134
00:30:40,000 --> 00:30:50,000
This is the waste that rightsizing recovers. Every idle dollar is an opportunity to save.

135
00:30:50,000 --> 00:31:00,000
Now let's look at cluster-wide efficiency. This single number tells your CTO how efficiently you are running.

136
00:31:00,000 --> 00:31:10,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/allocation?window=30d&aggregate=cluster&accumulate=true' | jq -r '.data[0] | to_entries[] | "Cluster efficiency: \(.value.cpuEfficiency | . * 100 | round)% | \(.value.ramEfficiency | . * 100 | round)%"']
▶ Pronounced as: "Now aggregating by cluster to get overall efficiency."

137
00:31:10,000 --> 00:31:20,000
Now, look at that output. Below sixty percent efficiency is a serious conversation about overprovisioning.

138
00:31:20,000 --> 00:31:30,000
Above eighty-five percent is a conversation about reliability risk. The target is seventy to eighty-five percent.

139
00:31:30,000 --> 00:31:40,000
Now let's look at network cost attribution. This is where you find silent waste in traffic patterns.

140
00:31:40,000 --> 00:31:50,000
[Types: kubectl get pods -n kubecost -l app=kubecost-network-costs]
▶ Pronounced as: "Now verifying the network-costs DaemonSet is running."

141
00:31:50,000 --> 00:32:00,000
Now, look at that output. You should see one network cost pod per node. This uses eBPF to capture traffic at the kernel level.

142
00:32:00,000 --> 00:32:10,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/allocation?window=30d&aggregate=namespace&accumulate=true' | jq -r '.data[0] | to_entries[] | "\(.key)\t\(.value.networkCost | . * 100 | round / 100)\t\(.value.networkCrossZoneCost | . * 100 | round / 100)\t\(.value.networkInternetCost | . * 100 | round / 100)"' | awk 'BEGIN{print "NAMESPACE\t\tNETWORK\tCROSS-ZONE\tINTERNET"} {printf "%-30s\t$%s\t$%s\t$%s\n", $1, $2, $3, $4}' | sort -t$'\t' -k2 -rn]
▶ Pronounced as: "Now extracting networkCost, networkCrossZoneCost, and networkInternetCost."

143
00:32:10,000 --> 00:32:20,000
Now, look at that output. Two things to look for.

144
00:32:20,000 --> 00:32:30,000
First, crossZoneCost high. That means services are making cross-AZ calls unnecessarily.

145
00:32:30,000 --> 00:32:40,000
Ensure replica pods and their database are in the same AZ. Use topology-aware routing.

146
00:32:40,000 --> 00:32:50,000
Second, internetCost high. That means something is calling external APIs excessively.

147
00:32:50,000 --> 00:33:00,000
Check for retry storms, missing caches, or misconfigured polling intervals.

148
00:33:00,000 --> 00:33:10,000
Let me give you a real case. A client's ingestion namespace had eight hundred dollars a month in internetCost.

149
00:33:10,000 --> 00:33:20,000
Investigation revealed the ingestion service was re-downloading SEC filings it had already processed.

150
00:33:20,000 --> 00:33:30,000
The SHA-256 deduplication check had a bug that always returned false. Fix: one-line code change. Savings: eight hundred dollars a month permanently.

151
00:33:30,000 --> 00:33:40,000
Now let's update the baseline document with the network cost data.

152
00:33:40,000 --> 00:33:50,000
[Types: echo "" >> ~/finops-baseline.txt]
[Types: echo "--- NETWORK COST BY NAMESPACE ---" >> ~/finops-baseline.txt]
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/allocation?window=30d&aggregate=namespace&accumulate=true' | jq -r '.data[0] | to_entries[] | "\(.key): network cost $\(.value.networkCost | . * 100 | round / 100)"' >> ~/finops-baseline.txt]
▶ Pronounced as: "Now appending network cost data to the baseline document."

153
00:33:50,000 --> 00:34:00,000
Now, look at that output. Your baseline document now includes network cost data.

154
00:34:00,000 --> 00:34:10,000
In the next segment, we look at storage cost attribution.

155
00:34:10,000 --> 00:34:20,000
See you in Segment 6.
```

---

SEGMENT 6: Storage Cost Attribution — Finding PVC Waste
Timestamp: 40:00 – 45:00

```
156
00:40:00,000 --> 00:40:10,000
Now let's look at persistent volume cost attribution. Storage costs are often invisible until they compound.

157
00:40:10,000 --> 00:40:20,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/allocation?window=30d&aggregate=namespace&accumulate=true' | jq -r '.data[0] | to_entries[] | "\(.key)\t\(.value.storageCost | . * 100 | round / 100)"' | awk 'BEGIN{print "NAMESPACE\t\tSTORAGE COST"} {printf "%-30s\t$%s\n", $1, $2}' | sort -t$'\t' -k2 -rn]
▶ Pronounced as: "Now extracting storageCost by namespace."

158
00:40:20,000 --> 00:40:30,000
Now, look at that output. This shows storage cost by namespace.

159
00:40:30,000 --> 00:40:40,000
Three common findings. First, PVCs provisioned at five hundred gigabytes but only twenty percent used. Resize them.

160
00:40:40,000 --> 00:40:50,000
Second, PVCs for terminated pods still allocated. Delete them. Third, multiple PVCs for the same data. Consolidate them.

161
00:40:50,000 --> 00:41:00,000
[Types: kubectl get pvc --all-namespaces -o custom-columns='NAMESPACE:.metadata.namespace,NAME:.metadata.name,CAPACITY:.spec.resources.requests.storage,STATUS:.status.phase' | grep -v "Bound"]
▶ Pronounced as: "Now finding PVCs that are not in Bound status."

162
00:41:00,000 --> 00:41:10,000
Now, look at that output. This shows you all PVCs that are not in Bound status. These are candidates for cleanup.

163
00:41:10,000 --> 00:41:20,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/allocation?window=30d&aggregate=pvc&accumulate=true' | jq -r '.data[0] | to_entries[] | "\(.key)\t\(.value.storageCost | . * 100 | round / 100)"' | awk 'BEGIN{print "PVC\t\tSTORAGE COST"} {printf "%-40s\t$%s\n", $1, $2}' | sort -t$'\t' -k2 -rn | head -10]
▶ Pronounced as: "Now aggregating by PVC to see the top 10 most expensive persistent volume claims."

164
00:41:20,000 --> 00:41:30,000
Now, look at that output. This shows the top ten PVCs by storage cost.

165
00:41:30,000 --> 00:41:40,000
For each expensive PVC, check if it is still needed. If not, delete it. If it is needed, verify it is provisioned at the right size.

166
00:41:40,000 --> 00:41:50,000
Now let's update the baseline document with the storage cost data.

167
00:41:50,000 --> 00:42:00,000
[Types: echo "" >> ~/finops-baseline.txt]
[Types: echo "--- STORAGE COST BY NAMESPACE ---" >> ~/finops-baseline.txt]
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/allocation?window=30d&aggregate=namespace&accumulate=true' | jq -r '.data[0] | to_entries[] | "\(.key): storage cost $\(.value.storageCost | . * 100 | round / 100)"' >> ~/finops-baseline.txt]
▶ Pronounced as: "Now appending storage cost data to the baseline document."

168
00:42:00,000 --> 00:42:10,000
Now, look at that output. Your baseline document now includes storage cost data.

169
00:42:10,000 --> 00:42:20,000
In the next segment, we look at how to set up cost alerts and custom dashboards in Kubecost.

170
00:42:20,000 --> 00:42:30,000
See you in Segment 7.
```

---

SEGMENT 7: Cost Alerts & Custom Dashboards
Timestamp: 45:00 – 50:00

```
171
00:45:00,000 --> 00:45:10,000
Now let's set up cost alerts in Kubecost. This is how you get notified when costs exceed thresholds.

172
00:45:10,000 --> 00:45:20,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s -X POST 'http://localhost:9090/alerts' -H 'Content-Type: application/json' -d '{"alerts":[{"type":"anomaly","threshold":50,"slackWebhookUrl":"https://hooks.slack.com/services/your-webhook","window":"1d"}]}']
▶ Pronounced as: "Now creating an anomaly alert with a 50 dollar threshold."

173
00:45:20,000 --> 00:45:30,000
This creates an anomaly alert that triggers when a daily cost spike exceeds fifty dollars.

174
00:45:30,000 --> 00:45:40,000
You can also set budget alerts by namespace.

175
00:45:40,000 --> 00:45:50,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s -X POST 'http://localhost:9090/alerts' -H 'Content-Type: application/json' -d '{"alerts":[{"type":"budget","namespace":"financial-rag","threshold":1000,"slackWebhookUrl":"https://hooks.slack.com/services/your-webhook","window":"monthly"}]}']
▶ Pronounced as: "Now creating a budget alert for the financial-rag namespace."

176
00:45:50,000 --> 00:46:00,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s -X POST 'http://localhost:9090/alerts' -H 'Content-Type: application/json' -d '{"alerts":[{"type":"efficiency","namespace":"financial-rag","threshold":60,"slackWebhookUrl":"https://hooks.slack.com/services/your-webhook"}]}']
▶ Pronounced as: "Now creating an efficiency alert with a 60 percent threshold."

177
00:46:00,000 --> 00:46:10,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/alerts' | jq '.alerts[] | {type: .type, namespace: .namespace, threshold: .threshold}']
▶ Pronounced as: "Now listing all active alerts."

178
00:46:10,000 --> 00:46:20,000
Now, look at that output. This shows you all active alerts in Kubecost.

179
00:46:20,000 --> 00:46:30,000
Now let's create custom dashboards. This is how you monitor what matters to your team.

180
00:46:30,000 --> 00:46:40,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/dashboards' | jq '.dashboards[] | {name: .name, description: .description}']
▶ Pronounced as: "Now listing available dashboards."

181
00:46:40,000 --> 00:46:50,000
Now, look at that output. This shows you the default dashboards available in Kubecost.

182
00:46:50,000 --> 00:47:00,000
You can create custom dashboards by saving specific filters and views in the Kubecost UI.

183
00:47:00,000 --> 00:47:10,000
For example, you can create a dashboard for the financial-rag team that only shows their namespace cost.

184
00:47:10,000 --> 00:47:20,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/dashboards/save' -H 'Content-Type: application/json' -d '{"name":"Financial RAG Team Cost","description":"Cost view for the financial-rag team","filter":{"namespace":"financial-rag"},"aggregate":"namespace"}']
▶ Pronounced as: "Now saving a custom dashboard for the financial-rag team."

185
00:47:20,000 --> 00:47:30,000
Dashboards can be shared with teams. They are useful for weekly cost review meetings.

186
00:47:30,000 --> 00:47:40,000
In the next segment, we look at exporting Kubecost data and integrating with Slack.

187
00:47:40,000 --> 00:47:50,000
See you in Segment 8.
```

---

SEGMENT 8: Exporting Data & Slack Integration
Timestamp: 50:00 – 55:00

```
188
00:50:00,000 --> 00:50:10,000
Now let's look at exporting Kubecost data for reporting.

189
00:50:10,000 --> 00:50:20,000
Kubecost exports data in CSV, JSON, and API formats. You can integrate it with your existing reporting tools.

190
00:50:20,000 --> 00:50:30,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/allocation?window=30d&aggregate=namespace&format=csv' --output /tmp/kubecost-allocation.csv]
▶ Pronounced as: "Now exporting allocation data as CSV."

191
00:50:30,000 --> 00:50:40,000
[Types: cat /tmp/kubecost-allocation.csv | head -20]
▶ Pronounced as: "Now viewing the first 20 lines of the CSV."

192
00:50:40,000 --> 00:50:50,000
Now, look at that output. This shows the CSV export of Kubecost allocation data.

193
00:50:50,000 --> 00:51:00,000
You can also export data to S3 for long-term storage.

194
00:51:00,000 --> 00:51:10,000
[Types: aws s3 cp /tmp/kubecost-allocation.csv s3://your-bucket/kubecost-data/allocation-$(date +%Y-%m-%d).csv]
▶ Pronounced as: "Now copying the CSV export to S3 with a date-stamped filename."

195
00:51:10,000 --> 00:51:20,000
Now let's integrate Kubecost with Slack. This is how you get cost alerts where your team works.

196
00:51:20,000 --> 00:51:30,000
First, create a Slack webhook. Go to Slack → Apps → Incoming Webhooks → Create a new webhook.

197
00:51:30,000 --> 00:51:40,000
Copy the webhook URL. It looks like: https://hooks.slack.com/services/T123456/B789012/abc123def456

198
00:51:40,000 --> 00:51:50,000
Now configure Kubecost to send alerts to Slack.

199
00:51:50,000 --> 00:52:00,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s -X POST 'http://localhost:9090/alerts' -H 'Content-Type: application/json' -d '{"alerts":[{"type":"anomaly","threshold":50,"slackWebhookUrl":"https://hooks.slack.com/services/your-webhook","window":"1d","channel":"#finops-alerts"}]}']
▶ Pronounced as: "Now creating an anomaly alert with Slack webhook integration."

200
00:52:00,000 --> 00:52:10,000
You can also send daily cost summaries to Slack.

201
00:52:10,000 --> 00:52:20,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s -X POST 'http://localhost:9090/slack' -H 'Content-Type: application/json' -d '{"channel":"#finops-alerts","message":"Daily cost summary: $2,345.67 | Top namespace: financial-rag ($1,234.56)"}']
▶ Pronounced as: "Now sending a daily cost summary message to Slack."

202
00:52:20,000 --> 00:52:30,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/slack/status']
▶ Pronounced as: "Now checking Slack connection status."

203
00:52:30,000 --> 00:52:40,000
Now, look at that output. If Slack is connected, you will see a status of "connected".

204
00:52:40,000 --> 00:52:50,000
Slack integration makes cost monitoring visible to the whole team. It creates shared accountability.

205
00:52:50,000 --> 00:53:00,000
In the next segment, we do a workshop on analyzing your cluster costs.

206
00:53:00,000 --> 00:53:10,000
See you in Segment 9.
```

---

SEGMENT 9: Workshop — Analyzing Your Cluster Costs
Timestamp: 55:00 – 65:00

```
207
00:55:00,000 --> 00:55:10,000
This is the workshop segment. We are going to analyze your cluster costs together.

208
00:55:10,000 --> 00:55:20,000
Run each command. Look at the output. Write down your findings. This is where you apply what you learned.

209
00:55:20,000 --> 00:55:30,000
Command 1: What is the total cost of your cluster?

210
00:55:30,000 --> 00:55:40,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/allocation?window=30d&aggregate=cluster' | jq -r '.data[0] | to_entries[] | "Total cluster cost: $\(.value.totalCost | . * 100 | round / 100)"']
▶ Pronounced as: "Now aggregating by cluster to get total cluster cost."

211
00:55:40,000 --> 00:55:50,000
Write this number down. This is your cluster cost.

212
00:55:50,000 --> 00:56:00,000
Command 2: What are the top three namespaces by cost?

213
00:56:00,000 --> 00:56:10,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/allocation?window=30d&aggregate=namespace' | jq -r '.data[0] | to_entries[] | "\(.key): $\(.value.totalCost | . * 100 | round / 100)"' | head -3]
▶ Pronounced as: "Now aggregating by namespace and taking the top 3."

214
00:56:10,000 --> 00:56:20,000
Write these down. These are your optimization priorities.

215
00:56:20,000 --> 00:56:30,000
Command 3: What is the efficiency of your most expensive namespace?

216
00:56:30,000 --> 00:56:40,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/allocation?window=30d&aggregate=namespace' | jq -r '.data[0] | to_entries[] | select(.key=="financial-rag") | "\(.key) efficiency: \(.value.cpuEfficiency | . * 100 | round)%"']
▶ Pronounced as: "Now filtering for the financial-rag namespace to get its efficiency."

217
00:56:40,000 --> 00:56:50,000
If efficiency is below seventy percent, you have an optimization opportunity.

218
00:56:50,000 --> 00:57:00,000
Command 4: What are the top rightsizing recommendations?

219
00:57:00,000 --> 00:57:10,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/savings/requestSizing?window=30d' | jq -r '.recommendations[:3][] | "\(.containerName): save $\(.monthlySavings | . * 100 | round / 100)/month"']
▶ Pronounced as: "Now getting the top 3 rightsizing recommendations."

220
00:57:10,000 --> 00:57:20,000
Write these down. These are your immediate savings opportunities.

221
00:57:20,000 --> 00:57:30,000
Command 5: What is the idle cost in your most expensive namespace?

222
00:57:30,000 --> 00:57:40,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/allocation?window=30d&aggregate=namespace&idle=true' | jq -r '.data[0] | to_entries[] | select(.key=="financial-rag") | "\(.key) idle cost: $\(.value.idleCost | . * 100 | round / 100)"']
▶ Pronounced as: "Now getting idle cost for the financial-rag namespace."

223
00:57:40,000 --> 00:57:50,000
Idle cost is the gap between requested and actual. This is the waste you can recover.

224
00:57:50,000 --> 00:58:00,000
Now you have your cluster cost analysis. Use this data to prioritize your optimization work.

225
00:58:00,000 --> 00:58:10,000
In the next segment, we look at optimizing Kubernetes resource requests and understanding HPA.

226
00:58:10,000 --> 00:58:20,000
See you in Segment 10.
```

---

SEGMENT 10: Optimizing Resource Requests & Understanding HPA
Timestamp: 65:00 – 75:00

```
227
01:05:00,000 --> 01:05:10,000
Now let's talk about optimizing Kubernetes resource requests.

228
01:05:10,000 --> 01:05:20,000
Resource requests are the foundation of Kubernetes scheduling and cost. Every pod has CPU and memory requests.

229
01:05:20,000 --> 01:05:30,000
CPU requests determine how much CPU the pod is guaranteed. Memory requests determine how much memory the pod is guaranteed.

230
01:05:30,000 --> 01:05:40,000
The problem: most engineers set requests based on gut feeling. They guess. And they guess high.

231
01:05:40,000 --> 01:05:50,000
This is why efficiency scores are so low. Engineers request resources they do not use.

232
01:05:50,000 --> 01:06:00,000
The solution: use Kubecost recommendations. They are based on actual usage data.

233
01:06:00,000 --> 01:06:10,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/savings/requestSizing?window=30d&targetCPUUtilization=0.75&targetRAMUtilization=0.75' | jq -r '.recommendations[] | "\(.containerName): CPU \(.currentCPUReq) → \(.recommendedCPUReq) | RAM \(.currentRAMReq) → \(.recommendedRAMReq) | save $\(.monthlySavings)"' | head -5]
▶ Pronounced as: "Now getting the top 5 rightsizing recommendations."

234
01:06:10,000 --> 01:06:20,000
Now, look at that output. This shows you how much you can save by adjusting resource requests.

235
01:06:20,000 --> 01:06:30,000
Apply recommendations one at a time. Monitor after each change.

236
01:06:30,000 --> 01:06:40,000
[Types: kubectl patch deployment llm-ingest --namespace financial-rag --type=merge -p '{"spec":{"template":{"spec":{"containers":[{"name":"llm-ingest","resources":{"requests":{"cpu":"450m","memory":"1.2Gi"},"limits":{"cpu":"900m","memory":"2.4Gi"}}}]}}}}']
▶ Pronounced as: "Now patching the llm-ingest deployment with new CPU and memory values."

237
01:06:40,000 --> 01:06:50,000
[Types: kubectl rollout status deployment/llm-ingest -n financial-rag]
▶ Pronounced as: "Now checking rollout status."

238
01:06:50,000 --> 01:07:00,000
[Types: kubectl top pods -n financial-rag -l app=llm-ingest]
▶ Pronounced as: "Now checking pod resource usage."

239
01:07:00,000 --> 01:07:10,000
Now, look at that output. Verify the new resource requests are working.

240
01:07:10,000 --> 01:07:20,000
If you see CPU throttling, increase the CPU limit. If you see OOMKills, increase the memory limit.

241
01:07:20,000 --> 01:07:30,000
The goal is to find the minimum resources that support your workload. Not the maximum.

242
01:07:30,000 --> 01:07:40,000
Now let's talk about the Horizontal Pod Autoscaler and cost implications.

243
01:07:40,000 --> 01:07:50,000
HPA automatically scales the number of replicas based on CPU utilization or custom metrics.

244
01:07:50,000 --> 01:08:00,000
When configured correctly, HPA saves money by scaling down during low traffic.

245
01:08:00,000 --> 01:08:10,000
When configured incorrectly, HPA wastes money by scaling up too aggressively.

246
01:08:10,000 --> 01:08:20,000
[Types: kubectl get hpa --all-namespaces]
▶ Pronounced as: "Now listing all Horizontal Pod Autoscalers."

247
01:08:20,000 --> 01:08:30,000
Now, look at that output. This shows you all HPAs in your cluster.

248
01:08:30,000 --> 01:08:40,000
The key parameters: minReplicas, maxReplicas, targetCPUUtilizationPercentage.

249
01:08:40,000 --> 01:08:50,000
Set minReplicas to the minimum number of replicas you need during low traffic. Set maxReplicas to the maximum you need during high traffic.

250
01:08:50,000 --> 01:09:00,000
Set targetCPUUtilizationPercentage to seventy percent. This gives you headroom for traffic spikes.

251
01:09:00,000 --> 01:09:10,000
[Types: kubectl patch hpa llm-ingest-hpa --namespace financial-rag --type=merge -p '{"spec":{"minReplicas":2,"maxReplicas":10,"targetCPUUtilizationPercentage":70,"behavior":{"scaleDown":{"stabilizationWindowSeconds":300}}}}']
▶ Pronounced as: "Now configuring the HPA for cost optimization."

252
01:09:10,000 --> 01:09:20,000
[Types: kubectl get hpa llm-ingest-hpa -n financial-rag]
▶ Pronounced as: "Now verifying the HPA configuration."

253
01:09:20,000 --> 01:09:30,000
In the next segment, we cover Kubecost best practices for production and a condensed Q&A.

254
01:09:30,000 --> 01:09:40,000
See you in Segment 11.
```

---

SEGMENT 11: Kubecost Best Practices for Production & Q&A
Timestamp: 75:00 – 85:00

```
255
01:15:00,000 --> 01:15:10,000
Now let's look at Kubecost best practices for production.

256
01:15:10,000 --> 01:15:20,000
Kubecost is a powerful tool. But it needs to be configured correctly for production use.

257
01:15:20,000 --> 01:15:30,000
Best practice 1: Use persistent storage for Prometheus. Without persistent storage, you lose historical data on restarts.

258
01:15:30,000 --> 01:15:40,000
[Types: helm upgrade kubecost kubecost/cost-analyzer --namespace kubecost --set prometheus.server.persistentVolume.enabled=true --set prometheus.server.persistentVolume.size=50Gi]
▶ Pronounced as: "Now enabling persistent storage for Prometheus with 50Gi."

259
01:15:40,000 --> 01:15:50,000
Best practice 2: Set up multi-cluster monitoring. If you have multiple clusters, Kubecost can aggregate cost across all of them.

260
01:15:50,000 --> 01:16:00,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/allocation?window=30d&aggregate=cluster' | jq -r '.data[0] | to_entries[] | "\(.key): $\(.value.totalCost | . * 100 | round / 100)"']
▶ Pronounced as: "Now aggregating by cluster to see multi-cluster cost."

261
01:16:00,000 --> 01:16:10,000
Best practice 3: Set up cost sharing for shared namespaces like kube-system.

262
01:16:10,000 --> 01:16:20,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s -X POST 'http://localhost:9090/config/costShares' -H 'Content-Type: application/json' -d '{"sharedNamespaces":["kube-system","monitoring","cert-manager"]}']
▶ Pronounced as: "Now configuring cost shares for shared namespaces."

263
01:16:20,000 --> 01:16:30,000
Best practice 4: Set up backup and restore for Kubecost data.

264
01:16:30,000 --> 01:16:40,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/backup' --output /tmp/kubecost-backup.json]
▶ Pronounced as: "Now creating a backup of Kubecost data."

265
01:16:40,000 --> 01:16:50,000
Best practice 5: Monitor Kubecost itself. Kubecost should be monitored like any other critical service.

266
01:16:50,000 --> 01:17:00,000
[Types: kubectl get pods -n kubecost -w]
▶ Pronounced as: "Now watching Kubecost pods for health."

267
01:17:00,000 --> 01:17:10,000
Best practice 6: Keep Kubecost updated. New versions include bug fixes and performance improvements.

268
01:17:10,000 --> 01:17:20,000
[Types: helm repo update && helm upgrade kubecost kubecost/cost-analyzer --namespace kubecost]
▶ Pronounced as: "Now updating Helm repo and upgrading Kubecost."

269
01:17:20,000 --> 01:17:30,000
Now let's answer the most common questions about Kubecost.

270
01:17:30,000 --> 01:17:40,000
Question 1: "I deployed Kubecost but I see no data. What is wrong?" Wait five to ten minutes for the first metric scrape to complete.

271
01:17:40,000 --> 01:17:50,000
Question 2: "My efficiency scores are very low. What should I do?" Apply the rightsizing recommendations. Start with the highest monthly savings container first.

272
01:17:50,000 --> 01:18:00,000
Question 3: "I applied rightsizing and my pods crashed. What happened?" You cut resources too aggressively. Increase the memory limit by fifty percent and re-apply.

273
01:18:00,000 --> 01:18:10,000
Question 4: "How often should I review Kubecost data?" Weekly. Set up a recurring calendar invite for a weekly cost review. Fifteen minutes a week.

274
01:18:10,000 --> 01:18:20,000
Question 5: "What is the difference between Kubecost and AWS Cost Explorer?" Cost Explorer shows you EC2 cost. Kubecost shows you pod cost. Kubecost gives you Kubernetes-level granularity.

275
01:18:20,000 --> 01:18:30,000
In the next segment, we do the knowledge check and look ahead to Series 4.

276
01:18:30,000 --> 01:18:40,000
See you in Segment 12.
```

---

SEGMENT 12: Knowledge Check & Next Steps
Timestamp: 85:00 – 95:00

```
277
01:25:00,000 --> 01:25:10,000
This is the knowledge check for Series 3.

278
01:25:10,000 --> 01:25:20,000
Let's test your understanding. Answer these questions in your own words.

279
01:25:20,000 --> 01:25:30,000
Question 1: What command deploys Kubecost on EKS?

280
01:25:30,000 --> 01:25:40,000
Question 2: How do you access the Kubecost dashboard?

281
01:25:40,000 --> 01:25:50,000
Question 3: What command gets cost by namespace from the Kubecost API?

282
01:25:50,000 --> 01:26:00,000
Question 4: What is a good efficiency score target for production workloads?

283
01:26:00,000 --> 01:26:10,000
Question 5: What does efficiency score measure?

284
01:26:10,000 --> 01:26:20,000
Question 6: What is idle cost?

285
01:26:20,000 --> 01:26:30,000
Question 7: What command applies a rightsizing recommendation?

286
01:26:30,000 --> 01:26:40,000
Question 8: What is the target CPU utilization for rightsizing recommendations?

287
01:26:40,000 --> 01:26:50,000
Pause the video. Write down your answers. Then compare them to what you learned.

288
01:26:50,000 --> 01:27:00,000
If you got all eight correct, you understand Series 3. If you missed any, review the relevant segment.

289
01:27:00,000 --> 01:27:10,000
Now let's look ahead to Series 4.

290
01:27:10,000 --> 01:27:20,000
In Series 4, you deploy Karpenter. Karpenter makes your cluster continuously self-optimizing.

291
01:27:20,000 --> 01:27:30,000
It launches nodes in seconds instead of minutes. It picks the cheapest available instance type. It continuously consolidates underutilized nodes.

292
01:27:30,000 --> 01:27:40,000
Before you start Series 4, verify these things.

293
01:27:40,000 --> 01:27:50,000
One: Kubecost is running. Check with kubectl get pods -n kubecost.

294
01:27:50,000 --> 01:28:00,000
Two: You have rightsized your workloads. Check with kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/savings/requestSizing'.

295
01:28:00,000 --> 01:28:10,000
Three: You have updated your baseline document.

296
01:28:10,000 --> 01:28:20,000
Series 3 is complete. You now have Kubernetes cost visibility. You know exactly where your money is going inside the cluster.

297
01:28:20,000 --> 01:28:30,000
See you in Series 4.
```

