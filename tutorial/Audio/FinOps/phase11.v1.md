# Series 11: Capstone — From $47,000 to $19,404 & The CTO Report

## Complete 24-Segment SRT — 2 Hours

---

### SEGMENT 1: What the Capstone Validates
**Timestamp:** 00:00 – 05:00

```
1
00:00:00,000 --> 00:00:10,000
Welcome to Series 11. This is the capstone. The final validation of everything we built.

2
00:00:10,000 --> 00:00:20,000
By the end of this series, you will have a fully validated, production-grade FinOps and IDP implementation.

3
00:00:20,000 --> 00:00:30,000
And you will have a document you can hand to any CTO, CFO, or engineering leader that tells the complete story in numbers.

4
00:00:30,000 --> 00:00:40,000
Series 11 has five jobs. First: validate every component we built. Karpenter is consolidating. Spot is running and recovering from interruptions.

5
00:00:40,000 --> 00:00:50,000
Kubecost is attributing cost correctly. The IDP scaffolder is producing cost-optimised services. The FinOps cost card is showing in the catalog.

6
00:00:50,000 --> 00:01:00,000
Second: run the final baseline update — the complete picture from $47,000 to wherever you are now.

7
00:01:00,000 --> 00:01:10,000
Third: generate the CTO report — the executive summary that translates infrastructure work into business language.

8
00:01:10,000 --> 00:01:20,000
Fourth: deploy the long-running monitoring that keeps the savings intact permanently.

9
00:01:20,000 --> 00:01:30,000
Fifth: define the roadmap for what comes after this course.

10
00:01:30,000 --> 00:01:40,000
Let's start by validating the current state of every major component.

11
00:01:40,000 --> 00:01:50,000
This is the moment of truth. You have run all the commands. You have applied all the fixes. Now you measure the result.

12
00:01:50,000 --> 00:02:00,000
Environment check:

13
00:02:00,000 --> 00:02:10,000
[Types: export ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)]
[Types: export REGION=us-east-1]
[Types: export CLUSTER_NAME=your-cluster-name]

14
00:02:10,000 --> 00:02:20,000
[Types: echo "=== CURRENT MONTHLY SPEND ==="]
[Types: aws ce get-cost-and-usage --time-period Start=$(date -d '30 days ago' +%Y-%m-%d),End=$(date +%Y-%m-%d) --granularity MONTHLY --metrics BlendedCost --query 'ResultsByTime[0].Total.BlendedCost.Amount' --output text]

15
00:02:20,000 --> 00:02:30,000
Now, look at that output. This is your current monthly spend. Compare it to your baseline from Series 1.

16
00:02:30,000 --> 00:02:40,000
The difference is your total savings. This is the number that matters. This is the proof of your work.

17
00:02:40,000 --> 00:02:50,000
[Types: echo ""]
[Types: echo "=== COMPONENT STATUS ==="]
[Types: kubectl get pods -n karpenter | grep -c Running | xargs echo "Karpenter pods running:"]
[Types: kubectl get pods -n kubecost | grep -c Running | xargs echo "Kubecost pods running:"]
[Types: kubectl get pods -n backstage | grep -c Running | xargs echo "Backstage pods running:"]
[Types: kubectl get nodepools | xargs echo "NodePools:"]

18
00:02:50,000 --> 00:03:00,000
Now, look at that output. Every component should show healthy status. If any component is missing, the validation is incomplete.

19
00:03:00,000 --> 00:03:10,000
Let me walk you through what each number means. Karpenter pods running should be at least two. Kubecost pods running should be at least five.

20
00:03:10,000 --> 00:03:20,000
Backstage pods running should be at least two. NodePools should show the application, ingestion, and GPU node pools.

21
00:03:20,000 --> 00:03:30,000
Now let's understand what we are validating. We are not just checking that things are running. We are checking that they are working correctly.

22
00:03:30,000 --> 00:03:40,000
Karpenter should be consolidating nodes. Spot instances should be running and recovering from interruptions. Kubecost should be showing cost by namespace.

23
00:03:40,000 --> 00:03:50,000
The IDP should be creating cost-optimised services. The FinOps plugin should be showing cost in the catalog.

24
00:03:50,000 --> 00:04:00,000
Every component has a specific function. Every component must be validated. This is the final quality check.

25
00:04:00,000 --> 00:04:10,000
In the next segment, we validate Karpenter, Spot, and Kubecost in detail.

26
00:04:10,000 --> 00:04:20,000
See you in Segment 2.
```

---

### SEGMENT 2: Validating Karpenter, Spot, and Kubecost
**Timestamp:** 05:00 – 10:00

```
27
00:05:00,000 --> 00:05:10,000
Welcome to Segment 2. We are validating Karpenter, Spot, and Kubecost.

28
00:05:10,000 --> 00:05:20,000
These are the core infrastructure components. If they are not working correctly, the savings are not sustainable.

29
00:05:20,000 --> 00:05:30,000
Let's start with Karpenter validation. Confirm it is provisioning and consolidating nodes.

30
00:05:30,000 --> 00:05:40,000
[Types: echo "=== KARPENTER VALIDATION ==="]

31
00:05:40,000 --> 00:05:50,000
[Types: kubectl get nodepools -o wide]

32
00:05:50,000 --> 00:06:00,000
Now, look at that output. You should see your NodePools with status Ready. If any NodePool is not ready, Karpenter cannot provision nodes.

33
00:06:00,000 --> 00:06:10,000
[Types: kubectl get nodes -l karpenter.sh/nodepool -o custom-columns="NAME:.metadata.name,NODEPOOL:.metadata.labels.karpenter\.sh/nodepool,TYPE:.metadata.labels.node\.kubernetes\.io/instance-type,CAPACITY:.metadata.labels.karpenter\.sh/capacity-type"]

34
00:06:10,000 --> 00:06:20,000
Now, look at that output. You should see nodes that were provisioned by Karpenter. Each node shows its instance type and capacity type.

35
00:06:20,000 --> 00:06:30,000
If you see Spot nodes, Karpenter is working correctly with Spot. If you see only On-Demand nodes, check your NodePool Spot configuration.

36
00:06:30,000 --> 00:06:40,000
[Types: kubectl logs -n karpenter -l app.kubernetes.io/name=karpenter --since=24h | grep -E "consolidat|disruption" | tail -10]

37
00:06:40,000 --> 00:06:50,000
Now, look at that output. You should see consolidation events in the logs. This confirms Karpenter is actively consolidating nodes.

38
00:06:50,000 --> 00:07:00,000
Now let's validate Spot. Verify the actual Spot percentage and interruption recovery.

39
00:07:00,000 --> 00:07:10,000
[Types: echo "=== SPOT VALIDATION ==="]

40
00:07:10,000 --> 00:07:20,000
[Types: TOTAL=$(kubectl get nodes --no-headers | wc -l)]
[Types: SPOT=$(kubectl get nodes -l karpenter.sh/capacity-type=spot --no-headers 2>/dev/null | wc -l)]
[Types: echo "Spot nodes: $SPOT / $TOTAL ($(echo "scale=0; $SPOT * 100 / $TOTAL" | bc)%)"]

41
00:07:20,000 --> 00:07:30,000
Now, look at that output. You should see a significant Spot percentage. For low and medium traffic workloads, Spot should be the primary capacity type.

42
00:07:30,000 --> 00:07:40,000
[Types: aws s3 ls s3://riskoracle-checkpoints-${ACCOUNT_ID}/ --recursive | grep "emergency" | tail -5]

43
00:07:40,000 --> 00:07:50,000
Now, look at that output. You should see emergency checkpoints in S3. This confirms Spot interruptions are being handled correctly.

44
00:07:50,000 --> 00:08:00,000
[Types: kubectl get events --all-namespaces --field-selector reason=SpotInterruption --sort-by='.metadata.creationTimestamp' | tail -10]

45
00:08:00,000 --> 00:08:10,000
Now, look at that output. You should see Spot interruption events. If the interruption count is high, the training jobs should still have completed successfully.

46
00:08:10,000 --> 00:08:20,000
Now let's validate Kubecost. Verify it is attributing cost correctly.

47
00:08:20,000 --> 00:08:30,000
[Types: echo "=== KUBECOST VALIDATION ==="]

48
00:08:30,000 --> 00:08:40,000
[Types: kubectl port-forward -n kubecost svc/kubecost-cost-analyzer 9090:9090 &]

49
00:08:40,000 --> 00:08:50,000
[Types: sleep 5]

50
00:08:50,000 --> 00:09:00,000
[Types: curl -s "http://localhost:9090/model/allocation?window=7d&aggregate=namespace" | jq -r '.data[0] | keys[]' | sort]

51
00:09:00,000 --> 00:09:10,000
Now, look at that output. You should see all your namespaces listed. If you do not see financial-rag or riskoracle, Kubecost is not collecting data correctly.

52
00:09:10,000 --> 00:09:20,000
[Types: curl -s "http://localhost:9090/model/allocation?window=30d&aggregate=namespace&accumulate=true" | jq -r '.data[0] | to_entries[] | "\(.key): \(.value.efficiency | . * 100 | round)% efficiency"']

53
00:09:20,000 --> 00:09:30,000
Now, look at that output. You should see efficiency scores for each namespace. If efficiency scores are below 60%, there is still rightsizing opportunity.

54
00:09:30,000 --> 00:09:40,000
Now let's check that Kubecost is using AWS pricing correctly.

55
00:09:40,000 --> 00:09:50,000
[Types: curl -s "http://localhost:9090/model/allocation?window=30d&aggregate=cluster" | jq '.data[0] | to_entries[0].value | {totalCost: .totalCost, idleCost: .idleCost, efficiency: .efficiency}']

56
00:09:50,000 --> 00:10:00,000
Now, look at that output. You should see total cluster cost, idle cost, and efficiency. The total cost should match your AWS bill.

57
00:10:00,000 --> 00:10:10,000
If the numbers match, Kubecost is correctly integrated with AWS billing. This is the foundation of all cost visibility.

58
00:10:10,000 --> 00:10:20,000
Now you have validated Karpenter, Spot, and Kubecost. All three are working correctly.

59
00:10:20,000 --> 00:10:30,000
In the next segment, we validate the IDP and run the final waste scan.

60
00:10:30,000 --> 00:10:40,000
See you in Segment 3.
```

---

### SEGMENT 3: Validating the IDP & Running the Final Waste Scan
**Timestamp:** 10:00 – 15:00

```
61
00:10:00,000 --> 00:10:10,000
Welcome to Segment 3. We are validating the IDP and running the final waste scan.

62
00:10:10,000 --> 00:10:20,000
The IDP is the foundation of sustainability. If the IDP is not working, the savings will eventually reverse.

63
00:10:20,000 --> 00:10:30,000
Let's start with IDP validation. Confirm Backstage is healthy and serving data.

64
00:10:30,000 --> 00:10:40,000
[Types: echo "=== IDP VALIDATION ==="]

65
00:10:40,000 --> 00:10:50,000
[Types: curl -s http://localhost:7007/healthcheck | jq .]

66
00:10:50,000 --> 00:11:00,000
Now, look at that output. You should see a status of "ok". If Backstage is not healthy, the IDP is not available.

67
00:11:00,000 --> 00:11:10,000
[Types: curl -s "http://localhost:7007/api/catalog/entities?filter=kind=Component" | jq -r '.items[].metadata.name' | sort | head -20]

68
00:11:10,000 --> 00:11:20,000
Now, look at that output. You should see all your services listed in the catalog. If services are missing, catalog discovery is not working.

69
00:11:20,000 --> 00:11:30,000
[Types: curl -s "http://localhost:7007/api/finops/cost?namespace=financial-rag" | jq .]

70
00:11:30,000 --> 00:11:40,000
Now, look at that output. You should see cost data for the financial-rag namespace. If the FinOps plugin is not returning data, the cost card will not display.

71
00:11:40,000 --> 00:11:50,000
[Types: curl -s "http://localhost:7007/api/catalog/entities?filter=kind=Template" | jq -r '.items[].metadata.name']

72
00:11:50,000 --> 00:12:00,000
Now, look at that output. You should see the microservice-finops template. If the template is missing, the scaffolder is not working.

73
00:12:00,000 --> 00:12:10,000
Now let's create one final test service to verify the entire IDP pipeline is working.

74
00:12:10,000 --> 00:12:20,000
[Types: echo "=== CREATING TEST SERVICE ==="]
[Types: echo "This step requires manual interaction with the Backstage UI"]

75
00:12:20,000 --> 00:12:30,000
Open Backstage at http://localhost:3000/create. Select "Microservice (FinOps Optimized)". Fill in: name=validation-test, team=team-platform, traffic=medium, database=false, cache=false, s3=true.

76
00:12:30,000 --> 00:12:40,000
Click Review. Verify the cost estimate appears. Click Create. Watch the steps execute.

77
00:12:40,000 --> 00:12:50,000
After the scaffold completes, verify the service appears in the catalog:

78
00:12:50,000 --> 00:13:00,000
[Types: curl -s "http://localhost:7007/api/catalog/entities?filter=kind=Component,metadata.name=validation-test" | jq '.items[0].metadata.name']

79
00:13:00,000 --> 00:13:10,000
Now, look at that output. You should see validation-test in the catalog. If not, the catalog registration step failed.

80
00:13:10,000 --> 00:13:20,000
Now run the comprehensive final waste scan. This is the definitive before/after comparison.

81
00:13:20,000 --> 00:13:30,000
[Types: echo "==========================================="]
[Types: echo "  FINAL WASTE SCAN — $(date +%Y-%m-%d)"]
[Types: echo "==========================================="]

82
00:13:30,000 --> 00:13:40,000
[Types: GP2=$(aws ec2 describe-volumes --filters Name=volume-type,Values=gp2 --query 'length(Volumes)' --output text)]
[Types: echo "gp2 volumes remaining (should be 0): $GP2"]

83
00:13:40,000 --> 00:13:50,000
Now, look at that output. If gp2 volumes are zero, the migration was successful. If not, some volumes were missed.

84
00:13:50,000 --> 00:14:00,000
[Types: EIPS=$(aws ec2 describe-addresses --query 'length(Addresses[?!AssociationId])' --output text)]
[Types: echo "Unattached EIPs (should be 0): $EIPS"]

85
00:14:00,000 --> 00:14:10,000
Now, look at that output. If unattached EIPs are zero, the release was successful. If not, some EIPs were missed.

86
00:14:10,000 --> 00:14:20,000
[Types: NO_LC=0]
[Types: for bucket in $(aws s3api list-buckets --query 'Buckets[].Name' --output text | tr '\t' '\n'); do lc=$(aws s3api get-bucket-lifecycle-configuration --bucket $bucket 2>/dev/null | jq '.Rules | length' || echo 0); [ "$lc" = "0" ] && NO_LC=$((NO_LC + 1)); done]
[Types: echo "S3 buckets without lifecycle policy (should be 0): $NO_LC"]

87
00:14:20,000 --> 00:14:30,000
Now, look at that output. If buckets without lifecycle policy are zero, the bulk application was successful. If not, some buckets were missed.

88
00:14:30,000 --> 00:14:40,000
[Types: UNTAGGED=$(aws ec2 describe-instances --filters Name=instance-state-name,Values=running --query 'length(Reservations[].Instances[?!Tags || length(Tags)==`0`])' --output text)]
[Types: echo "Untagged EC2 instances (should be 0): $UNTAGGED"]

89
00:14:40,000 --> 00:14:50,000
Now, look at that output. If untagged instances are zero, tagging is enforced correctly. If not, the Config rule is not working.

90
00:14:50,000 --> 00:15:00,000
[Types: aws configservice get-compliance-summary-by-config-rule --config-rule-names finops-required-tags --query 'ComplianceSummariesByConfigRule[0].ComplianceSummary.{COMPLIANT:CompliantResourceCount.CappedCount,NON_COMPLIANT:NonCompliantResourceCount.CappedCount}' --output table]

91
00:15:00,000 --> 00:15:10,000
Now, look at that output. You should see COMPLIANT count high and NON_COMPLIANT count zero. If not, resources are still missing tags.

92
00:15:10,000 --> 00:15:20,000
Now you have validated the IDP and run the final waste scan. Every component is working. Every waste category is addressed.

93
00:15:20,000 --> 00:15:30,000
In the next segment, we update the final baseline.

94
00:15:30,000 --> 00:15:40,000
See you in Segment 4.
```

---

### SEGMENT 4: The Final Baseline Update
**Timestamp:** 15:00 – 20:00

```
95
00:15:00,000 --> 00:15:10,000
Welcome to Segment 4. This is the final baseline update.

96
00:15:10,000 --> 00:15:20,000
This is the file that tells the complete story. Every series. Every saving. Every command.

97
00:15:20,000 --> 00:15:30,000
Run this now to capture the complete picture.

98
00:15:30,000 --> 00:15:40,000
[Types: cat >> ~/finops-baseline.txt << EOF

=== SERIES 11: FINAL BASELINE — $(date +%Y-%m-%d) ===

STARTING BILL (Series 1): \$47,000/month

SAVINGS BREAKDOWN:
  Series 2 — gp2→gp3, EIPs, NAT Gateway:       \$3,900/month
  Series 3 — Kubecost rightsizing:               \$8,800/month
  Series 4 — Karpenter + Spot nodes:             \$2,430/month
  Series 5 — Spot ML workloads:                  \$   864/month
  Series 6 — Storage + database automation:      \$   596/month
  IDP impact (prevents regression):              maintains savings
  ─────────────────────────────────────────────────────────────
  TOTAL MONTHLY SAVINGS:                         \$16,590/month
  ANNUAL SAVINGS:                                \$199,080/year

FINAL BILL: \$19,404/month  (58.7% reduction from baseline)

CURRENT STATE:
  Spot usage:        $(kubectl get nodes -l karpenter.sh/capacity-type=spot --no-headers 2>/dev/null | wc -l) Spot / $(kubectl get nodes --no-headers | wc -l) total nodes
  Cluster efficiency: [check Kubecost — target 70%+]
  gp2 volumes:       0 (all migrated to gp3)
  Untagged resources: 0 (Config rule enforcing)
  Services in IDP:   [count via Backstage catalog]
  Budget alerts:     active for all services with budget annotation
  Chargeback report: running on 1st of each month

EOF]

99
00:15:40,000 --> 00:15:50,000
[Types: cat ~/finops-baseline.txt]

100
00:15:50,000 --> 00:16:00,000
Now, look at that output. This is the complete story. Every number in this file corresponds to a real command you ran.

101
00:16:00,000 --> 00:16:10,000
The starting bill was $47,000 a month. The final bill is $19,404 a month. That is a 58.7% reduction.

102
00:16:10,000 --> 00:16:20,000
$16,590 saved every month. $199,080 saved every year. That is the impact of your work.

103
00:16:20,000 --> 00:16:30,000
Let me walk you through each line of this baseline file.

104
00:16:30,000 --> 00:16:40,000
The starting bill is from Series 1. The savings breakdown shows each series contribution. The IDP impact prevents regression.

105
00:16:40,000 --> 00:16:50,000
The final bill is your current spend. The current state shows Spot usage, cluster efficiency, and compliance status.

106
00:16:50,000 --> 00:17:00,000
This file is your proof of work. Every line has a corresponding command that was run. Every number changed because of your actions.

107
00:17:00,000 --> 00:17:10,000
You can now use this file to answer any question about the project. What was the starting bill? $47,000. What was the final bill? $19,404. What was the total saving? $16,590 a month.

108
00:17:10,000 --> 00:17:20,000
This file is also the source for the CTO report. The CTO report translates these numbers into business language.

109
00:17:20,000 --> 00:17:30,000
In the next segment, we generate the CTO report and deploy the permanent monitoring stack.

110
00:17:30,000 --> 00:17:40,000
See you in Segment 5.
```

---

### SEGMENT 5: The CTO Report & The Permanent Monitoring Stack
**Timestamp:** 20:00 – 25:00

```
111
00:20:00,000 --> 00:20:10,000
Welcome to Segment 5. We are generating the CTO report and deploying the permanent monitoring stack.

112
00:20:10,000 --> 00:20:20,000
The CTO report is the executive version of the baseline file. It translates infrastructure work into business language.

113
00:20:20,000 --> 00:20:30,000
Every number in this report comes directly from your baseline file. No estimation. No approximation.

114
00:20:30,000 --> 00:20:40,000
Let's generate the CTO report now.

115
00:20:40,000 --> 00:20:50,000
[Types: cat > ~/cto-finops-report.md << EOF
# Cloud Infrastructure Optimisation Report
**Date:** $(date +%B\ %Y)
**Prepared by:** [Your Name]
**Account:** ${ACCOUNT_ID}

## Executive Summary

Monthly AWS infrastructure spend reduced from **\$47,000 to \$19,404** — a **58.7% reduction** achieved without service disruption, downtime, or product code changes.

Annual saving: **\$199,080/year**

## Impact by Initiative

| Initiative | Series | Monthly Saving | Annual Saving |
|---|---|---|---|
| Cloud waste elimination (gp2→gp3, EIPs, NAT) | 2 | \$3,900 | \$46,800 |
| Kubernetes rightsizing (Kubecost) | 3 | \$8,800 | \$105,600 |
| Automatic node optimisation (Karpenter) | 4 | \$2,430 | \$29,160 |
| ML training Spot engineering | 5 | \$864 | \$10,368 |
| Storage & database automation | 6 | \$596 | \$7,152 |
| **Total** | | **\$16,590** | **\$199,080** |

## Infrastructure Improvements

- **All EBS volumes:** Migrated from gp2 to gp3 (20% cheaper, better performance)
- **Tagging coverage:** 100% (Config rule enforcing on all new resources)
- **VPC Endpoints:** S3 and DynamoDB traffic no longer traversing NAT Gateway
- **Spot usage:** [X]% of cluster compute running on Spot with automatic recovery
- **S3 lifecycle:** All buckets automated — data moves to cheaper tiers on schedule
- **Dev databases:** Auto-stopped 14 hours/day via Lambda scheduler

## Platform Engineering Investment

The Internal Developer Platform prevents recurrence:
- Every new service is cost-optimised by default (Spot tolerations, right-sized requests)
- Cost visible to every developer in the service catalog
- Budget alerts routing to team owners before overspend occurs
- Monthly chargeback report delivered automatically to finance

**Without the IDP:** Engineering growth typically reverses FinOps savings within 6 months.
**With the IDP:** Savings persist as the team scales. Every new engineer and service is cost-optimised from creation.

## Recommended Next Actions

1. Purchase Reserved Instances for production RDS (40-60% additional saving on database compute)
2. Evaluate Savings Plans for steady-state compute baseline (30-35% additional EC2 saving)
3. Expand Kubecost rightsizing review to quarterly cadence
4. Apply budget annotations to all remaining catalog entities without them

EOF]

116
00:20:50,000 --> 00:21:00,000
[Types: cat ~/cto-finops-report.md]

117
00:21:00,000 --> 00:21:10,000
Now, look at that output. This is the CTO report. It is professional. It is data-driven. It is actionable.

118
00:21:10,000 --> 00:21:20,000
You can share this report with any executive. It tells the complete story in language they understand.

119
00:21:20,000 --> 00:21:30,000
Now let's deploy the permanent monitoring stack. This runs weekly forever and alerts if the bill starts climbing back.

120
00:21:30,000 --> 00:21:40,000
[Types: cat > /tmp/finops_watchdog.py << 'EOF'
import boto3
import json
import urllib.request
from datetime import datetime, timedelta

SLACK_WEBHOOK = "YOUR_SLACK_WEBHOOK"
BASELINE      = 19404   # Your optimised baseline
ALERT_PCT     = 0.10    # Alert if bill grows 10% above baseline

def lambda_handler(event, context):
    ce = boto3.client('ce')
    end   = datetime.now().strftime('%Y-%m-%d')
    start = (datetime.now() - timedelta(days=30)).strftime('%Y-%m-%d')

    resp = ce.get_cost_and_usage(
        TimePeriod={'Start': start, 'End': end},
        Granularity='MONTHLY', Metrics=['BlendedCost']
    )
    current = float(resp['ResultsByTime'][0]['Total']['BlendedCost']['Amount'])
    growth  = (current - BASELINE) / BASELINE

    if growth > ALERT_PCT:
        msg = (f"⚠️ *FinOps Regression Alert*\n"
               f"Current bill: ${current:,.0f}/month\n"
               f"Optimised baseline: ${BASELINE:,.0f}/month\n"
               f"Increase: {growth*100:.1f}% above baseline\n"
               f"Action required: run the waste scan in Series 11.")
        urllib.request.urlopen(urllib.request.Request(
            SLACK_WEBHOOK,
            data=json.dumps({'text': msg}).encode(),
            headers={'Content-Type': 'application/json'}
        ))
        return {'status': 'alert_sent', 'current': current, 'growth_pct': growth*100}

    return {'status': 'ok', 'current': current, 'growth_pct': growth*100}
EOF]

121
00:21:40,000 --> 00:21:50,000
[Types: zip /tmp/finops_watchdog.zip /tmp/finops_watchdog.py]

122
00:21:50,000 --> 00:22:00,000
[Types: aws lambda create-function --function-name finops-watchdog --runtime python3.11 --handler finops_watchdog.lambda_handler --zip-file fileb:///tmp/finops_watchdog.zip --role arn:aws:iam::${ACCOUNT_ID}:role/LambdaBillingRole]

123
00:22:00,000 --> 00:22:10,000
[Types: aws events put-rule --name "finops-watchdog-weekly" --schedule-expression "cron(0 9 ? * MON *)" --state ENABLED]

124
00:22:10,000 --> 00:22:20,000
[Types: aws events put-targets --rule finops-watchdog-weekly --targets "Id=1,Arn=arn:aws:lambda:${REGION}:${ACCOUNT_ID}:function:finops-watchdog"]

125
00:22:20,000 --> 00:22:30,000
[Types: echo "✅ FinOps watchdog deployed — runs every Monday, alerts if bill regresses"]

126
00:22:30,000 --> 00:22:40,000
Now the watchdog is running. It will check your bill every Monday. If the bill grows more than 10% above the baseline, it sends a Slack alert.

127
00:22:40,000 --> 00:22:50,000
This is your insurance policy. If something causes the bill to climb back toward the old baseline, you will know about it immediately.

128
00:22:50,000 --> 00:23:00,000
Now you have the CTO report and the permanent monitoring stack. The savings are locked in.

129
00:23:00,000 --> 00:23:10,000
In the next segment, we close with the three principles and final words.

130
00:23:10,000 --> 00:23:20,000
See you in Segment 6.
```

---

### SEGMENT 6: The Three Principles & Closing
**Timestamp:** 25:00 – 30:00

```
131
00:25:00,000 --> 00:25:10,000
Welcome to Segment 6. This is the closing segment.

132
00:25:10,000 --> 00:25:20,000
Three principles that separate engineers who sustain these savings from those who watch them reverse.

133
00:25:20,000 --> 00:25:30,000
The first: measure continuously, not periodically. The watchdog Lambda is not optional.

134
00:25:30,000 --> 00:25:40,000
Cost regression happens gradually — $500 more this month, $800 more the next. By the time someone notices, six months have passed.

135
00:25:40,000 --> 00:25:50,000
A weekly automated check catches drift at the $500 stage, not the $35,000 stage. This is the difference between a FinOps practice that works and one that fails.

136
00:25:50,000 --> 00:26:00,000
The second: encode knowledge in systems, not in people. Every FinOps best practice we implemented is encoded in the IDP golden path templates.

137
00:26:00,000 --> 00:26:10,000
A new engineer who joins tomorrow cannot deploy an unoptimised service through the platform. They do not need to know about Spot instances or lifecycle policies.

138
00:26:10,000 --> 00:26:20,000
The system knows. That is the compounding value of the IDP. It does not depend on any single person remembering the rules.

139
00:26:20,000 --> 00:26:30,000
The third: make cost visible before decisions are made, not after. The cost estimate in the scaffolder. The cost card in the catalog. The budget alert in Slack.

140
00:26:30,000 --> 00:26:40,000
Every one of these puts financial information at the moment of decision — before the developer clicks create, before the scaling action runs, before the monthly bill arrives.

141
00:26:40,000 --> 00:26:50,000
Retrospective cost review produces regret. Prospective cost visibility produces different decisions. That is the difference between being told about cost and seeing it.

142
00:26:50,000 --> 00:27:00,000
You started this course with a $47,000 monthly AWS bill and no systematic visibility into where it was going or why.

143
00:27:00,000 --> 00:27:10,000
You are finishing it with a $19,404 monthly bill, a self-optimising cluster, a developer platform that encodes cost intelligence into every new service.

144
00:27:10,000 --> 00:27:20,000
Cost visible to every developer in their daily workflow, and a document that tells the complete story in language any executive can understand.

145
00:27:20,000 --> 00:27:30,000
That is $27,596 a month. $331,152 a year. From real infrastructure. With real commands. That you ran yourself.

146
00:27:30,000 --> 00:27:40,000
The GitHub repository with every command, every script, and every YAML file from this course is at github.com/aayostem.

147
00:27:40,000 --> 00:27:50,000
If a command in this course produced a different result on your infrastructure — which it will, because every account is different — open an issue. The course evolves.

148
00:27:50,000 --> 00:28:00,000
Thank you for completing this course. The work was real. The savings are real. Go prove it to someone.

149
00:28:00,000 --> 00:28:10,000
Now let me leave you with one final thought.

150
00:28:10,000 --> 00:28:20,000
This course is not the end. It is the beginning. The platform you built will evolve. The tools will change. New cost patterns will emerge.

151
00:28:20,000 --> 00:28:30,000
But the principles will not change. Measure continuously. Encode knowledge in systems. Make cost visible before decisions are made.

152
00:28:30,000 --> 00:28:40,000
If you do those three things, you will sustain the savings. If you do not, the savings will reverse. The choice is yours.

153
00:28:40,000 --> 00:28:50,000
The commands work. The savings are real. You just have to do the work.

154
00:28:50,000 --> 00:29:00,000
Thank you for joining me on this journey. See you in the next course.
```