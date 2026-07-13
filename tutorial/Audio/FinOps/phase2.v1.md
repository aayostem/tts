Here is your **complete Series 2 SRT** with all `Pronounced at:` lines edited to **type-along, precedential** style. All headers, timestamps, numbering, narrative, and command blocks remain exactly as you provided.

---

**Series 2: The Cloud Cost Audit — Find & Eliminate Hidden Waste**
**Complete 24-Segment SRT — 2 Hours**

---

**SEGMENT 1: The $12,544 Story & What You'll Find Today**
*Timestamp: 00:00 – 05:00*

```
1
00:00:00,000 --> 00:00:10,000
Series 2 is where the money gets real.

2
00:00:10,000 --> 00:00:20,000
In Series 1, you built the foundation. You activated tags. You created a baseline. You understood unit economics.

3
00:00:20,000 --> 00:00:30,000
Now we stop talking about waste and start finding it. This is where the real money is.

4
00:00:30,000 --> 00:00:40,000
I want to come back to the startup from Series 1. Forty-seven thousand dollars a month. Never ran an audit.

5
00:00:40,000 --> 00:00:50,000
What we found in one day changed everything for them. And I want you to see every single finding in detail.

6
00:00:50,000 --> 00:01:00,000
Overprovisioned EC2 instances: eight thousand dollars a month. The instances were twice as large as they needed to be.

7
00:01:00,000 --> 00:01:10,000
All EBS volumes on gp2 instead of gp3: twelve hundred dollars a month. A twenty percent tax on their storage.

8
00:01:10,000 --> 00:01:20,000
Twelve unattached Elastic IPs: forty-four dollars a month. Each one is three dollars sixty-five.

9
00:01:20,000 --> 00:01:30,000
NAT Gateway carrying S3 and DynamoDB traffic: two thousand one hundred dollars a month.

10
00:01:30,000 --> 00:01:40,000
S3 without lifecycle policies: fifteen terabytes of old data. Nine hundred dollars a month.

11
00:01:40,000 --> 00:01:50,000
Stopped instances still paying for EBS volumes: three hundred dollars a month.

12
00:01:50,000 --> 00:02:00,000
Total identified waste: twelve thousand five hundred and forty-four dollars a month.

13
00:02:00,000 --> 00:02:10,000
That is one hundred and fifty thousand, five hundred and twenty-eight dollars a year.

14
00:02:10,000 --> 00:02:20,000
Found in one day. No new infrastructure. No engineering work. Just running the commands you are about to run.

15
00:02:20,000 --> 00:02:30,000
Let that sink in. One day. One engineer. The commands you are about to type.

16
00:02:30,000 --> 00:02:40,000
Every one of those findings applies to your account too. Not the exact same dollar amounts — your account is different.

17
00:02:40,000 --> 00:02:50,000
But the categories are universal. In more than fifty audits, I have never found an account without at least one of these.

18
00:02:50,000 --> 00:03:00,000
Most accounts have all of them. Yours probably does too.

19
00:03:00,000 --> 00:03:10,000
In this series we work through twelve audit steps. Each one is a specific command that finds a specific category of waste.

20
00:03:10,000 --> 00:03:20,000
Each one includes the fix. We do not just find the waste — we eliminate it today.

21
00:03:20,000 --> 00:03:30,000
By the end of Series 2, your bill is already lower. Not in theory. Actually lower.

22
00:03:30,000 --> 00:03:40,000
The commands are running on your account right now. The fixes will take effect tonight.

23
00:03:40,000 --> 00:03:50,000
Start with environment verification. Every series in this course starts with this. Do not skip it.

24
00:03:50,000 --> 00:04:00,000
[Types: export ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)]
[Types: export REGION=us-east-1]
[Types: export START=$(date -d '30 days ago' +%Y-%m-%d)]
[Types: export END=$(date +%Y-%m-%d)]
▶ Pronounced as: "Now I'm setting our environment variables. Export ACCOUNT_ID from STS, export REGION as us-east-1, export START as 30 days ago, and export END as today."

25
00:04:00,000 --> 00:04:10,000
[Types: echo "Account: $ACCOUNT_ID | Start: $START | End: $END"]
Now, look at that output. You should see your account ID and the correct date range.

26
00:04:10,000 --> 00:04:20,000
If any of these are blank, your variables are not set. Re-export them. If you are on macOS, remember to use date -v-30d instead of the Linux date syntax.

27
00:04:20,000 --> 00:04:30,000
Now confirm Cost Explorer still works. This is your gatekeeper command.

28
00:04:30,000 --> 00:04:40,000
[Types: aws ce get-cost-and-usage --time-period Start=$START,End=$END --granularity MONTHLY --metrics BlendedCost --query 'ResultsByTime[0].Total.BlendedCost.Amount' --output text]
▶ Pronounced as: "Now AWS C-E get-cost-and-usage. We're pulling our total monthly spend using the START and END variables, with MONTHLY granularity and BlendedCost metric."

29
00:04:40,000 --> 00:04:50,000
Write down that number. It is your Series 2 starting point. Every fix we make gets measured against it.

30
00:04:50,000 --> 00:05:00,000
Now let's run our first audit query. This is your opening slide. Every engagement starts here.
```

---

**SEGMENT 2: Audit Step 1 — Total Spend & Daily Trends**
*Timestamp: 05:00 – 10:00*

```
31
00:05:00,000 --> 00:05:10,000
The first question is always: where is the money going?

32
00:05:10,000 --> 00:05:20,000
[Types: aws ce get-cost-and-usage --time-period Start=$START,End=$END --granularity MONTHLY --metrics BlendedCost --group-by Type=DIMENSION,Key=SERVICE --query 'ResultsByTime[0].Groups[?Metrics.BlendedCost.Amount > `10`].[Keys[0],Metrics.BlendedCost.Amount]' --output table]
▶ Pronounced as: "Now AWS C-E get-cost-and-usage grouped by SERVICE. We're filtering to only show services with cost greater than 10 dollars."

33
00:05:20,000 --> 00:05:30,000
Now, look at that output. This shows you where your money is going. And more importantly, it shows you where you are wasting money.

34
00:05:30,000 --> 00:05:40,000
If NAT Gateway is in your top five, that is a red flag. It means S3 and DynamoDB traffic is going through NAT — and you are paying for it.

35
00:05:40,000 --> 00:05:50,000
If EC2 is more than sixty percent of your bill, your compute is almost certainly overprovisioned.

36
00:05:50,000 --> 00:06:00,000
If S3 is more than three hundred dollars a month, you probably have no lifecycle policies on old data.

37
00:06:00,000 --> 00:06:10,000
If RDS is in your top three, check for development databases running twenty-four hours a day, seven days a week.

38
00:06:10,000 --> 00:06:20,000
The second and third items on the list are almost always the biggest opportunities.

39
00:06:20,000 --> 00:06:30,000
Everyone optimizes the top item. Almost nobody looks at items two through five. That is where the hidden money lives.

40
00:06:30,000 --> 00:06:40,000
Now let's save this to your baseline document. Every time we find waste, we document it.

41
00:06:40,000 --> 00:06:50,000
[Types: echo "" >> ~/finops-baseline.txt]
[Types: echo "=== SERIES 2: WASTE AUDIT ===" >> ~/finops-baseline.txt]
[Types: echo "Date: $(date)" >> ~/finops-baseline.txt]
[Types: echo "" >> ~/finops-baseline.txt]
▶ Pronounced as: "Now I'm appending the Series 2 waste audit header to our baseline document."

42
00:06:50,000 --> 00:07:00,000
[Types: echo "=== SPEND BY SERVICE ===" >> ~/finops-baseline.txt]
[Types: aws ce get-cost-and-usage --time-period Start=$START,End=$END --granularity MONTHLY --metrics BlendedCost --group-by Type=DIMENSION,Key=SERVICE --query 'ResultsByTime[0].Groups[?Metrics.BlendedCost.Amount > `10`].[Keys[0],Metrics.BlendedCost.Amount]' --output table >> ~/finops-baseline.txt]
▶ Pronounced as: "Now appending the spend by service results to the baseline document."

43
00:07:00,000 --> 00:07:10,000
Now let's look at daily cost trends. Monthly totals hide the story. Daily trends show you the day something went wrong.

44
00:07:10,000 --> 00:07:20,000
[Types: aws ce get-cost-and-usage --time-period Start=$START,End=$END --granularity DAILY --metrics BlendedCost --query 'ResultsByTime[].[TimePeriod.Start,Total.BlendedCost.Amount]' --output table]
▶ Pronounced as: "Now AWS C-E get-cost-and-usage with DAILY granularity. We're pulling each day's total cost."

45
00:07:20,000 --> 00:07:30,000
Now, look at that output. Four things to look for.

46
00:07:30,000 --> 00:07:40,000
First, a spike on a specific date. What deployed that day? Check your deployment logs.

47
00:07:40,000 --> 00:07:50,000
Second, no drop on weekends. Your workloads run twenty-four hours a day, seven days a week — do they need to?

48
00:07:50,000 --> 00:08:00,000
Third, a gradual upward slope. That is normal growth — but is it proportional to revenue?

49
00:08:00,000 --> 00:08:10,000
Fourth, a sudden step up that never came back down. Something changed and was never reverted.

50
00:08:10,000 --> 00:08:20,000
Let me give you a real case. A client had a four hundred dollar per day spike every Tuesday for three months.

51
00:08:20,000 --> 00:08:30,000
Nobody knew why. The daily trend revealed it immediately. Root cause: a weekly batch job that spun up ten GPU instances.

52
00:08:30,000 --> 00:08:40,000
And forgot to terminate them after the job finished. Four thousand eight hundred dollars a month wasted on a bug that fit in three lines of code.

53
00:08:40,000 --> 00:08:50,000
Three lines of code cost them four thousand eight hundred dollars a month. That is the power of visibility.

54
00:08:50,000 --> 00:09:00,000
If you are not looking at daily trends, you are missing these stories.

55
00:09:00,000 --> 00:09:10,000
Now let's look at cost by region. This is where you find stray resources — instances running in regions you forgot about.

56
00:09:10,000 --> 00:09:20,000
[Types: aws ce get-cost-and-usage --time-period Start=$START,End=$END --granularity MONTHLY --metrics BlendedCost --group-by Type=DIMENSION,Key=REGION --query 'ResultsByTime[0].Groups[].[Keys[0],Metrics.BlendedCost.Amount]' --output table]
▶ Pronounced as: "Now AWS C-E get-cost-and-usage grouped by REGION instead of SERVICE."

57
00:09:20,000 --> 00:09:30,000
Now, look at that output. If you see spend in regions you do not use, someone created resources there.

58
00:09:30,000 --> 00:09:40,000
The AWS console defaults to us-east-1. Developers switch regions during testing and forget.

59
00:09:40,000 --> 00:09:50,000
I have found three thousand dollars a month of GPU instances running in ap-southeast-1 because someone ran a load test and never terminated them.

60
00:09:50,000 --> 00:10:00,000
That load test ended eighteen months ago. They were still paying for it. Every single month.
```

---

**SEGMENT 3: Audit Step 2 — gp2 to gp3 Migration**
*Timestamp: 10:00 – 15:00*

```
61
00:10:00,000 --> 00:10:10,000
Let me show you how to find stray resources. This scans every non-primary region for EC2 instances.

62
00:10:10,000 --> 00:10:20,000
[Types: for region in us-west-1 us-west-2 eu-west-1 eu-central-1 ap-southeast-1 ap-northeast-1; do count=$(aws ec2 describe-instances --region $region --query 'length(Reservations[].Instances[])' --output text 2>/dev/null || echo 0); if [ "$count" -gt "0" ]; then echo "⚠️  $count instance(s) found in $region"; aws ec2 describe-instances --region $region --query 'Reservations[].Instances[].[InstanceId,InstanceType,State.Name,Tags[?Key==`Name`].Value|[0]]' --output table; fi; done]
▶ Pronounced as: "Now a region scan loop. We're iterating through all non-primary regions, counting EC2 instances, and showing details for any that exist."

63
00:10:20,000 --> 00:10:30,000
Now, look at that output. For each stray resource: identify it, find the owner, decide — migrate, snapshot and delete, or tag and track.

64
00:10:30,000 --> 00:10:40,000
Never ignore a stray resource. Every stray resource is a dollar that could be saved.

65
00:10:40,000 --> 00:10:50,000
A zero point zero two dollar per hour test instance in the wrong region is fourteen dollars forty a month for nothing.

66
00:10:50,000 --> 00:11:00,000
Multiply that by the number of engineers who have ever had console access and the number climbs fast.

67
00:11:00,000 --> 00:11:10,000
Add this scan to your monthly FinOps review. It takes thirty seconds and catches a category of waste that almost nothing else surfaces.

68
00:11:10,000 --> 00:11:20,000
Now let's set up cost anomaly detection. This is the gift that keeps on giving.

69
00:11:20,000 --> 00:11:30,000
You set it up once. It runs forever. It watches your spend. It learns your patterns.

70
00:11:30,000 --> 00:11:40,000
It alerts you when something unexpected happens — before you see it on the bill.

71
00:11:40,000 --> 00:11:50,000
[Types: MONITOR_ARN=$(aws ce create-anomaly-monitor --anomaly-monitor '{"MonitorName":"finops-monitor","MonitorType":"DIMENSIONAL","MonitorDimension":"SERVICE"}' --query 'MonitorArn' --output text)]
[Types: echo "Monitor ARN: $MONITOR_ARN"]
▶ Pronounced as: "Now creating an anomaly monitor. AWS C-E create-anomaly-monitor with dimension SERVICE. Capturing the ARN."

72
00:11:50,000 --> 00:12:00,000
[Types: aws ce create-anomaly-subscription --anomaly-subscription "{\"SubscriptionName\":\"finops-alerts\",\"MonitorArnList\":[\"$MONITOR_ARN\"],\"Subscribers\":[{\"Address\":\"YOUR_EMAIL@company.com\",\"Type\":\"EMAIL\"}],\"Threshold\":50,\"Frequency\":\"DAILY\"}"]
▶ Pronounced as: "Now creating an anomaly subscription with daily frequency and a 50 dollar threshold."

73
00:12:00,000 --> 00:12:10,000
Set the threshold at fifty dollars, not five hundred. Small anomalies often indicate configuration drift that will compound.

74
00:12:10,000 --> 00:12:20,000
A sixty dollar anomaly this week becomes a six hundred dollar anomaly next month if unchecked.

75
00:12:20,000 --> 00:12:30,000
Now let's check for existing anomalies from the last seven days.

76
00:12:30,000 --> 00:12:40,000
[Types: aws ce get-anomalies --date-interval Start=$(date -d '7 days ago' +%Y-%m-%d),End=$END --query 'Anomalies[].[AnomalyId,RootCauses[0].Service,Impact.TotalImpact]' --output table]
▶ Pronounced as: "Now AWS C-E get-anomalies for the last 7 days. Showing anomaly ID, service, and total impact."

77
00:12:40,000 --> 00:12:50,000
Now, look at that output. If you see any anomalies, investigate them. Something is happening that you did not plan for.

78
00:12:50,000 --> 00:13:00,000
Now let's move to the highest-return action in this entire course. gp2 to gp3 migration.

79
00:13:00,000 --> 00:13:10,000
This is the easiest win in all of cloud cost optimization. Twenty percent cheaper. Zero downtime. One command.

80
00:13:10,000 --> 00:13:20,000
gp3 gives you three thousand IOPS flat, not the bursting IOPS of gp2 that degrades under sustained load.

81
00:13:20,000 --> 00:13:30,000
There is no reason to use gp2 in 2026. None. Find all your gp2 volumes:

82
00:13:30,000 --> 00:13:40,000
[Types: aws ec2 describe-volumes --filters Name=volume-type,Values=gp2 --query 'Volumes[].[VolumeId,Size,State,Tags[?Key==`Name`].Value|[0]]' --output table]
▶ Pronounced as: "Now AWS E-C-two describe-volumes filtered by volume-type gp2. Showing ID, size, state, and name tag."

83
00:13:40,000 --> 00:13:50,000
Calculate your savings:

84
00:13:50,000 --> 00:14:00,000
[Types: TOTAL_GP2_GB=$(aws ec2 describe-volumes --filters Name=volume-type,Values=gp2 --query 'sum(Volumes[].Size)' --output text)]
[Types: MONTHLY_SAVINGS=$(echo "scale=2; $TOTAL_GP2_GB * 0.02" | bc)]
[Types: echo "Total gp2 storage: ${TOTAL_GP2_GB} GB"]
[Types: echo "Monthly savings from migration: \$${MONTHLY_SAVINGS}"]
▶ Pronounced as: "Now calculating total gp2 storage and monthly savings at 2 cents per GB."

85
00:14:00,000 --> 00:14:10,000
Migrate a single volume first to verify the process:

86
00:14:10,000 --> 00:14:20,000
[Types: VOLUME_ID="vol-xxxxxxxxxxxxxxxxx"]
[Types: aws ec2 modify-volume --volume-id $VOLUME_ID --volume-type gp3 --iops 3000 --throughput 125]
▶ Pronounced as: "Now testing on a single volume. Set VOLUME_ID, then modify-volume to gp3 with 3000 IOPS and 125 throughput."

87
00:14:20,000 --> 00:14:30,000
Monitor the migration:

88
00:14:30,000 --> 00:14:40,000
[Types: aws ec2 describe-volumes-modifications --volume-ids $VOLUME_ID --query 'VolumesModifications[].[VolumeId,ModificationState,TargetVolumeType,Progress]' --output table]
▶ Pronounced as: "Now checking the migration status with describe-volumes-modifications."

89
00:14:40,000 --> 00:14:50,000
The volume is fully usable throughout. Zero downtime. Your application does not even know it is happening.

90
00:14:50,000 --> 00:15:00,000
Once you are comfortable, migrate all gp2 volumes at once.
```

---

**SEGMENT 4: Audit Step 3 — Elastic IPs & Stopped Instances**
*Timestamp: 15:00 – 20:00*

```
91
00:15:00,000 --> 00:15:10,000
[Types: aws ec2 describe-volumes --filters Name=volume-type,Values=gp2 --query 'Volumes[].VolumeId' --output text | tr '\t' '\n' | while read vol_id; do echo "Migrating $vol_id to gp3..."; aws ec2 modify-volume --volume-id $vol_id --volume-type gp3 --iops 3000 --throughput 125 --output text; done]
▶ Pronounced as: "Now bulk migrating all gp2 volumes. We list all volume IDs, loop through each, and modify to gp3."

92
00:15:10,000 --> 00:15:20,000
Note: do not run this on io1 or io2 volumes. Those are provisioned-IOPS volumes created for specific high-performance workloads.

93
00:15:20,000 --> 00:15:30,000
Now let's find unattached Elastic IPs. Each one is costing you three dollars sixty-five per month for doing nothing.

94
00:15:30,000 --> 00:15:40,000
[Types: aws ec2 describe-addresses --query 'Addresses[?!AssociationId].[AllocationId,PublicIp,Domain,Tags[?Key==`Name`].Value|[0]]' --output table]
▶ Pronounced as: "Now AWS E-C-two describe-addresses. Filtering for addresses without an AssociationId, showing allocation ID, public IP, domain, and name tag."

95
00:15:40,000 --> 00:15:50,000
Calculate the waste:

96
00:15:50,000 --> 00:16:00,000
[Types: EIP_COUNT=$(aws ec2 describe-addresses --query 'length(Addresses[?!AssociationId])' --output text)]
[Types: echo "Unattached EIPs: $EIP_COUNT"]
[Types: echo "Monthly waste: \$$(echo "scale=2; $EIP_COUNT * 3.65" | bc)"]
▶ Pronounced as: "Now counting unattached EIPs and calculating monthly waste at 3.65 dollars each."

97
00:16:00,000 --> 00:16:10,000
Before releasing — check CloudTrail to see who created each EIP and when. Some EIPs are intentionally reserved for IP whitelisting.

98
00:16:10,000 --> 00:16:20,000
[Types: aws cloudtrail lookup-events --lookup-attributes AttributeKey=EventName,AttributeValue=AllocateAddress --query 'Events[].[EventTime,Username,Resources[0].ResourceName]' --output table]
▶ Pronounced as: "Now checking CloudTrail for EIP creation events."

99
00:16:20,000 --> 00:16:30,000
Release the ones that are genuinely unused:

100
00:16:30,000 --> 00:16:40,000
[Types: aws ec2 describe-addresses --query 'Addresses[?!AssociationId].AllocationId' --output text | tr '\t' '\n' | while read alloc_id; do echo "Releasing EIP: $alloc_id"; aws ec2 release-address --allocation-id $alloc_id; done]
▶ Pronounced as: "Now releasing all unattached EIPs. List allocation IDs and release each one."

101
00:16:40,000 --> 00:16:50,000
Now stopped instances. Stopped instances do not charge for compute — but their EBS volumes still bill.

102
00:16:50,000 --> 00:17:00,000
A stopped instance with a five hundred gigabyte gp3 volume costs forty dollars a month. For doing nothing.

103
00:17:00,000 --> 00:17:10,000
[Types: aws ec2 describe-instances --filters Name=instance-state-name,Values=stopped --query 'Reservations[].Instances[].[InstanceId,InstanceType,StateTransitionReason,Tags[?Key==`Name`].Value|[0],Tags[?Key==`Owner`].Value|[0]]' --output table]
▶ Pronounced as: "Now AWS E-C-two describe-instances filtered by stopped state. Showing ID, type, transition reason, name and owner tags."

104
00:17:10,000 --> 00:17:20,000
Decision framework: stopped less than seven days — ask the owner. Stopped seven to thirty days — email, give forty-eight hour deadline.

105
00:17:20,000 --> 00:17:30,000
Stopped more than thirty days — snapshot volumes, then terminate.

106
00:17:30,000 --> 00:17:40,000
[Types: aws ec2 describe-instances --filters Name=instance-state-name,Values=stopped --query 'Reservations[].Instances[].InstanceId' --output text | tr '\t' '\n' | while read instance_id; do echo "Processing stopped instance: $instance_id"; VOLUME_IDS=$(aws ec2 describe-instances --instance-ids $instance_id --query 'Reservations[0].Instances[0].BlockDeviceMappings[].Ebs.VolumeId' --output text 2>/dev/null); for vol_id in $VOLUME_IDS; do echo "  Snapshotting $vol_id..."; aws ec2 create-snapshot --volume-id $vol_id --description "Pre-termination backup of $instance_id on $(date +%Y-%m-%d)" --tag-specifications "ResourceType=snapshot,Tags=[{Key=Source,Value=$instance_id},{Key=Date,Value=$(date +%Y-%m-%d)}]" --output text; done; echo "  Terminating instance: $instance_id"; aws ec2 terminate-instances --instance-ids $instance_id --output text; done]
▶ Pronounced as: "Now processing stopped instances. For each instance, snapshot all volumes, then terminate."

107
00:17:40,000 --> 00:17:50,000
We snapshot the volumes before termination. This is insurance. If someone needs data later, we can restore.

108
00:17:50,000 --> 00:18:00,000
Only terminate instances that have been stopped for more than thirty days. For stopped instances under thirty days, contact the owner first.

109
00:18:00,000 --> 00:18:10,000
Now let's handle unattached EBS volumes. We will snapshot them first, then delete them.

110
00:18:10,000 --> 00:18:20,000
[Types: aws ec2 describe-volumes --filters Name=status,Values=available --query 'Volumes[].VolumeId' --output text | tr '\t' '\n' | while read vol_id; do snap_id=$(aws ec2 create-snapshot --volume-id $vol_id --description "Unattached volume cleanup $(date +%Y-%m-%d)" --query 'SnapshotId' --output text); echo "Volume $vol_id → Snapshot $snap_id created"; aws ec2 delete-volume --volume-id $vol_id; echo "Volume $vol_id deleted"; done]
▶ Pronounced as: "Now handling unattached EBS volumes. For each available volume, create a snapshot, then delete the volume."

111
00:18:20,000 --> 00:18:30,000
Never delete without snapshotting first. I have seen engineers delete unattached volumes containing production database backups.

112
00:18:30,000 --> 00:18:40,000
The snapshot costs about zero point zero five dollars per GB per month — cheap insurance.

113
00:18:40,000 --> 00:18:50,000
Now let's handle old EBS snapshots. Delete snapshots older than ninety days that are not referenced by any AMI.

114
00:18:50,000 --> 00:19:00,000
[Types: aws ec2 describe-snapshots --owner-ids $ACCOUNT_ID --query "Snapshots[?StartTime<='$(date -d '90 days ago' +%Y-%m-%dT%H:%M:%S)'].SnapshotId" --output text | tr '\t' '\n' | while read snap_id; do AMI_REF=$(aws ec2 describe-images --filters "Name=block-device-mapping.snapshot-id,Values=$snap_id" --query 'Images[].ImageId' --output text 2>/dev/null); if [ -z "$AMI_REF" ]; then echo "Deleting snapshot: $snap_id"; aws ec2 delete-snapshot --snapshot-id $snap_id; else echo "Keeping snapshot: $snap_id (referenced by AMI $AMI_REF)"; fi; done]
▶ Pronounced as: "Now cleaning old snapshots. For each snapshot older than 90 days, check if it's referenced by an AMI. If not, delete it."

115
00:19:00,000 --> 00:19:10,000
This checks if each snapshot is referenced by any AMI before deleting. If it is referenced, deleting it will break the AMI.

116
00:19:10,000 --> 00:19:20,000
Now let's handle idle load balancers. Remove load balancers with no healthy targets.

117
00:19:20,000 --> 00:19:30,000
[Types: aws elbv2 describe-load-balancers --query 'LoadBalancers[].LoadBalancerArn' --output text 2>/dev/null | tr '\t' '\n' | while read lb_arn; do lb_name=$(aws elbv2 describe-load-balancers --load-balancer-arns $lb_arn --query 'LoadBalancers[0].LoadBalancerName' --output text 2>/dev/null); healthy=$(aws elbv2 describe-target-groups --load-balancer-arn $lb_arn --query 'TargetGroups[].TargetGroupArn' --output text 2>/dev/null | tr '\t' '\n' | while read tg_arn; do aws elbv2 describe-target-health --target-group-arn $tg_arn --query 'length(TargetHealthDescriptions[?TargetHealth.State==`healthy`])' --output text 2>/dev/null; done | awk '{sum+=$1} END {print sum+0}'); if [ "$healthy" = "0" ]; then echo "Removing idle load balancer: $lb_name"; aws elbv2 delete-load-balancer --load-balancer-arn $lb_arn; fi; done]
▶ Pronounced as: "Now finding idle load balancers. For each load balancer, count healthy targets. If zero, delete the load balancer."

118
00:19:30,000 --> 00:19:40,000
Each idle load balancer costs approximately sixteen dollars per month. Removing them is pure savings.

119
00:19:40,000 --> 00:19:50,000
Now let's create VPC endpoints for S3 and DynamoDB. This eliminates NAT Gateway costs.

120
00:19:50,000 --> 00:20:00,000
NAT Gateway is one of the most consistently underestimated line items in AWS accounts.
```

---

**SEGMENT 5: Audit Step 4 — NAT Gateway: The Silent Killer**
*Timestamp: 20:00 – 25:00*

```
121
00:20:00,000 --> 00:20:10,000
NAT Gateway charges zero point zero four five dollars per gigabyte of data processed. It runs twenty-four hours a day.

122
00:20:10,000 --> 00:20:20,000
And in most accounts, a significant portion of the traffic going through NAT Gateway should not be going through NAT Gateway at all.

123
00:20:20,000 --> 00:20:30,000
S3 traffic. DynamoDB traffic. All of it goes through the NAT Gateway by default — zero point zero four five dollars per GB.

124
00:20:30,000 --> 00:20:40,000
When it could go through a VPC Endpoint at zero cost. VPC Endpoints are private connections from your VPC directly to AWS services.

125
00:20:40,000 --> 00:20:50,000
No internet routing. No NAT Gateway processing charges. Free for gateway-type endpoints.

126
00:20:50,000 --> 00:21:00,000
Find your NAT Gateway cost:

127
00:21:00,000 --> 00:21:10,000
[Types: aws ce get-cost-and-usage --time-period Start=$START,End=$END --granularity MONTHLY --metrics BlendedCost --filter '{"Dimensions":{"Key":"USAGE_TYPE","Values":["NatGateway-Bytes"]}}' --query 'ResultsByTime[0].Total.BlendedCost.Amount' --output text]
▶ Pronounced as: "Now AWS C-E get-cost-and-usage filtered by NatGateway-Bytes usage type."

128
00:21:10,000 --> 00:21:20,000
Create the S3 VPC Endpoint — gateway type, free:

129
00:21:20,000 --> 00:21:30,000
[Types: VPC_ID=$(aws ec2 describe-vpcs --filters Name=isDefault,Values=true --query 'Vpcs[0].VpcId' --output text)]
[Types: RTB_ID=$(aws ec2 describe-route-tables --filters Name=vpc-id,Values=$VPC_ID Name=association.main,Values=true --query 'RouteTables[0].RouteTableId' --output text)]
▶ Pronounced as: "Now capturing our VPC ID and main route table ID."

130
00:21:30,000 --> 00:21:40,000
[Types: aws ec2 create-vpc-endpoint --vpc-id $VPC_ID --service-name com.amazonaws.$REGION.s3 --route-table-ids $RTB_ID]
[Types: echo "S3 VPC Endpoint created"]
▶ Pronounced as: "Now creating the S3 gateway VPC endpoint."

131
00:21:40,000 --> 00:21:50,000
Create the DynamoDB VPC Endpoint:

132
00:21:50,000 --> 00:22:00,000
[Types: aws ec2 create-vpc-endpoint --vpc-id $VPC_ID --service-name com.amazonaws.$REGION.dynamodb --route-table-ids $RTB_ID]
[Types: echo "DynamoDB VPC Endpoint created"]
▶ Pronounced as: "Now creating the DynamoDB gateway VPC endpoint."

133
00:22:00,000 --> 00:22:10,000
These changes take effect immediately. Any S3 or DynamoDB traffic from your VPC now routes through the private endpoint.

134
00:22:10,000 --> 00:22:20,000
Completely bypassing the NAT Gateway. The NAT Gateway processing charge for that traffic drops to zero.

135
00:22:20,000 --> 00:22:30,000
For the startup in our story, this saved two thousand one hundred dollars a month. That is twenty-five thousand two hundred dollars a year.

136
00:22:30,000 --> 00:22:40,000
From two commands that took thirty seconds to run.

137
00:22:40,000 --> 00:22:50,000
Now let's handle interface endpoints for other AWS services like ECR, Secrets Manager, and CloudWatch.

138
00:22:50,000 --> 00:23:00,000
[Types: aws ec2 create-vpc-endpoint --vpc-id $VPC_ID --service-name com.amazonaws.$REGION.ecr.api --vpc-endpoint-type Interface --subnet-ids $SUBNET_IDS --security-group-ids $SG_ID --private-dns-enabled]
[Types: aws ec2 create-vpc-endpoint --vpc-id $VPC_ID --service-name com.amazonaws.$REGION.ecr.dkr --vpc-endpoint-type Interface --subnet-ids $SUBNET_IDS --security-group-ids $SG_ID --private-dns-enabled]
▶ Pronounced as: "Now creating interface endpoints for ECR API and ECR DKR with private DNS enabled."

139
00:23:00,000 --> 00:23:10,000
These interface endpoints have a small cost — zero point zero one dollars per hour per AZ plus zero point zero one dollars per GB.

140
00:23:10,000 --> 00:23:20,000
But they break even when you are sending more than four hundred and eighty gigabytes per month through NAT.

141
00:23:20,000 --> 00:23:30,000
If your EKS cluster pulls images frequently, this pays for itself immediately.

142
00:23:30,000 --> 00:23:40,000
Now let's run the complete waste summary script. This aggregates all the waste categories.

143
00:23:40,000 --> 00:23:50,000
[Types: echo "=============================================" >> ~/finops-waste-summary.txt]
[Types: echo "  COMPLETE WASTE AUDIT — $(date +%Y-%m-%d)" >> ~/finops-waste-summary.txt]
[Types: echo "=============================================" >> ~/finops-waste-summary.txt]
▶ Pronounced as: "Now building the waste summary document with header."

144
00:23:50,000 --> 00:24:00,000
[Types: GP2_COUNT=$(aws ec2 describe-volumes --filters Name=volume-type,Values=gp2 --query 'length(Volumes)' --output text)]
[Types: GP2_GB=$(aws ec2 describe-volumes --filters Name=volume-type,Values=gp2 --query 'sum(Volumes[].Size)' --output text 2>/dev/null || echo 0)]
[Types: GP2_SAVINGS=$(echo "scale=2; ${GP2_GB:-0} * 0.02" | bc)]
▶ Pronounced as: "Now calculating gp2 volume count, total GB, and monthly savings."

145
00:24:00,000 --> 00:24:10,000
[Types: echo "📦 gp2 Volumes: $GP2_COUNT volumes, ${GP2_GB}GB" >> ~/finops-waste-summary.txt]
[Types: echo "   → Migrate to gp3: save \$${GP2_SAVINGS}/month" >> ~/finops-waste-summary.txt]
▶ Pronounced as: "Now appending gp2 findings to the waste summary."

146
00:24:10,000 --> 00:24:20,000
[Types: EIP_COUNT=$(aws ec2 describe-addresses --query 'length(Addresses[?!AssociationId])' --output text 2>/dev/null || echo 0)]
[Types: EIP_WASTE=$(echo "scale=2; ${EIP_COUNT:-0} * 3.65" | bc)]
▶ Pronounced as: "Now calculating unattached EIP count and monthly waste."

147
00:24:20,000 --> 00:24:30,000
[Types: echo "🌐 Unattached EIPs: $EIP_COUNT" >> ~/finops-waste-summary.txt]
[Types: echo "   → Release: save \$${EIP_WASTE}/month" >> ~/finops-waste-summary.txt]
▶ Pronounced as: "Now appending EIP findings to the waste summary."

148
00:24:30,000 --> 00:24:40,000
[Types: STOPPED_COUNT=$(aws ec2 describe-instances --filters Name=instance-state-name,Values=stopped --query 'length(Reservations[].Instances[])' --output text 2>/dev/null || echo 0)]
[Types: STOPPED_WASTE=$(echo "scale=2; ${STOPPED_COUNT:-0} * 8" | bc)]
▶ Pronounced as: "Now calculating stopped instance count and estimated monthly waste."

149
00:24:40,000 --> 00:24:50,000
[Types: echo "⏹  Stopped Instances: $STOPPED_COUNT" >> ~/finops-waste-summary.txt]
[Types: echo "   → Terminate unused: save ~\$${STOPPED_WASTE}/month" >> ~/finops-waste-summary.txt]
▶ Pronounced as: "Now appending stopped instance findings."

150
00:24:50,000 --> 00:25:00,000
[Types: UNATTACHED_GB=$(aws ec2 describe-volumes --filters Name=status,Values=available --query 'sum(Volumes[].Size)' --output text 2>/dev/null || echo 0)]
[Types: UNATTACHED_WASTE=$(echo "scale=2; ${UNATTACHED_GB:-0} * 0.08" | bc)]
[Types: echo "💾 Unattached EBS Volumes: ${UNATTACHED_GB}GB" >> ~/finops-waste-summary.txt]
[Types: echo "   → Delete after snapshot: save \$${UNATTACHED_WASTE}/month" >> ~/finops-waste-summary.txt]
▶ Pronounced as: "Now calculating unattached EBS volume storage and waste."
```

---

**SEGMENT 6: Audit Steps 5–8 — Volumes, Snapshots, Idle Load Balancers & Anomaly Detection**
*Timestamp: 25:00 – 30:00*

```
151
00:25:00,000 --> 00:25:10,000
[Types: NAT_COST=$(aws ce get-cost-and-usage --time-period Start=$START,End=$END --granularity MONTHLY --metrics BlendedCost --filter '{"Dimensions":{"Key":"SERVICE","Values":["Amazon EC2 - NAT Gateway"]}}' --query 'ResultsByTime[0].Total.BlendedCost.Amount' --output text 2>/dev/null || echo 0)]
[Types: NAT_SAVINGS=$(echo "scale=2; ${NAT_COST:-0} * 0.6" | bc)]
▶ Pronounced as: "Now calculating NAT Gateway cost and estimated 60 percent savings from VPC endpoints."

152
00:25:10,000 --> 00:25:20,000
[Types: echo "🌉 NAT Gateway Cost: \$${NAT_COST}/month" >> ~/finops-waste-summary.txt]
[Types: echo "   → VPC Endpoints: save ~\$${NAT_SAVINGS}/month" >> ~/finops-waste-summary.txt]
▶ Pronounced as: "Now appending NAT Gateway findings."

153
00:25:20,000 --> 00:25:30,000
[Types: OLD_SNAP_GB=$(aws ec2 describe-snapshots --owner-ids $ACCOUNT_ID --query "Snapshots[?StartTime<='$(date -d '90 days ago' +%Y-%m-%dT%H:%M:%S)'].VolumeSize" --output text 2>/dev/null | tr '\t' '\n' | awk '{sum+=$1} END {print sum}')]
[Types: SNAP_WASTE=$(echo "scale=2; ${OLD_SNAP_GB:-0} * 0.05" | bc)]
▶ Pronounced as: "Now calculating old snapshot storage and monthly waste."

154
00:25:30,000 --> 00:25:40,000
[Types: echo "📸 Old Snapshots (>90 days): ${OLD_SNAP_GB}GB" >> ~/finops-waste-summary.txt]
[Types: echo "   → Delete unused: save \$${SNAP_WASTE}/month" >> ~/finops-waste-summary.txt]
▶ Pronounced as: "Now appending old snapshot findings."

155
00:25:40,000 --> 00:25:50,000
[Types: IDLE_LB_COUNT=$(aws elbv2 describe-load-balancers --query 'LoadBalancers[].LoadBalancerArn' --output text 2>/dev/null | tr '\t' '\n' | while read lb_arn; do healthy=$(aws elbv2 describe-target-groups --load-balancer-arn $lb_arn --query 'TargetGroups[].TargetGroupArn' --output text 2>/dev/null | tr '\t' '\n' | while read tg_arn; do aws elbv2 describe-target-health --target-group-arn $tg_arn --query 'length(TargetHealthDescriptions[?TargetHealth.State==`healthy`])' --output text 2>/dev/null; done | awk '{sum+=$1} END {print sum+0}'); if [ "$healthy" = "0" ]; then echo "1"; fi; done | wc -l)]
[Types: LB_WASTE=$(echo "scale=2; $IDLE_LB_COUNT * 16" | bc)]
▶ Pronounced as: "Now counting idle load balancers and calculating monthly waste."

156
00:25:50,000 --> 00:26:00,000
[Types: echo "⚖️  Idle Load Balancers: $IDLE_LB_COUNT" >> ~/finops-waste-summary.txt]
[Types: echo "   → Remove: save ~\$${LB_WASTE}/month" >> ~/finops-waste-summary.txt]
▶ Pronounced as: "Now appending idle load balancer findings."

157
00:26:00,000 --> 00:26:10,000
[Types: echo "" >> ~/finops-waste-summary.txt]
[Types: TOTAL_WASTE=$(echo "scale=2; $GP2_SAVINGS + $EIP_WASTE + $STOPPED_WASTE + $UNATTACHED_WASTE + $NAT_SAVINGS + $SNAP_WASTE + $LB_WASTE" | bc)]
▶ Pronounced as: "Now calculating total identified waste by summing all categories."

158
00:26:10,000 --> 00:26:20,000
[Types: echo "---------------------------------------------" >> ~/finops-waste-summary.txt]
[Types: echo "TOTAL IDENTIFIED WASTE:              \$${TOTAL_WASTE}/month" >> ~/finops-waste-summary.txt]
[Types: echo "ANNUAL WASTE:                        \$$(echo "scale=2; $TOTAL_WASTE * 12" | bc)/year" >> ~/finops-waste-summary.txt]
[Types: echo "=============================================" >> ~/finops-waste-summary.txt]
▶ Pronounced as: "Now appending total waste and annual waste to the summary."

159
00:26:20,000 --> 00:26:30,000
[Types: cat ~/finops-waste-summary.txt]
Now, look at that output. This is your total identified waste.

160
00:26:30,000 --> 00:26:40,000
Some of you will see hundreds of dollars. Some of you will see thousands. A few of you will see tens of thousands.

161
00:26:40,000 --> 00:26:50,000
Whatever the number, it is real. It is money you are currently spending. And we are going to stop spending it.

162
00:26:50,000 --> 00:27:00,000
Now let's append the waste audit results to your baseline document.

163
00:27:00,000 --> 00:27:10,000
[Types: echo "" >> ~/finops-baseline.txt]
[Types: echo "=== WASTE AUDIT RESULTS ===" >> ~/finops-baseline.txt]
[Types: echo "gp2 volumes: $GP2_COUNT ($GP2_GB GB) → save \$${GP2_SAVINGS}/month" >> ~/finops-baseline.txt]
[Types: echo "Unattached EIPs: $EIP_COUNT → save \$${EIP_WASTE}/month" >> ~/finops-baseline.txt]
[Types: echo "Stopped instances: $STOPPED_COUNT → save ~\$${STOPPED_WASTE}/month" >> ~/finops-baseline.txt]
[Types: echo "Unattached EBS: ${UNATTACHED_GB}GB → save \$${UNATTACHED_WASTE}/month" >> ~/finops-baseline.txt]
[Types: echo "NAT Gateway: \$${NAT_COST}/month → save ~\$${NAT_SAVINGS}/month" >> ~/finops-baseline.txt]
[Types: echo "Old Snapshots: ${OLD_SNAP_GB}GB → save \$${SNAP_WASTE}/month" >> ~/finops-baseline.txt]
[Types: echo "Idle Load Balancers: $IDLE_LB_COUNT → save ~\$${LB_WASTE}/month" >> ~/finops-baseline.txt]
[Types: echo "TOTAL MONTHLY OPPORTUNITY: \$${TOTAL_WASTE}" >> ~/finops-baseline.txt]
▶ Pronounced as: "Now appending all waste audit results to the baseline document."

164
00:27:10,000 --> 00:27:20,000
Now, look at that output. Your baseline document now contains the complete waste audit results.

165
00:27:20,000 --> 00:27:30,000
Now let me recap what you built in Series 2. The entire cloud cost audit.

166
00:27:30,000 --> 00:27:40,000
You verified your environment. You ran spend by service queries. You identified daily cost trends.

167
00:27:40,000 --> 00:27:50,000
You found regional spend. You set up cost anomaly detection. You found gp2 volumes and migrated them.

168
00:27:50,000 --> 00:28:00,000
You found unattached Elastic IPs and released them. You found stopped instances and terminated them.

169
00:28:00,000 --> 00:28:10,000
You found unattached EBS volumes and deleted them. You found old snapshots and removed them.

170
00:28:10,000 --> 00:28:20,000
You found idle load balancers and removed them. You created VPC endpoints to eliminate NAT Gateway costs.

171
00:28:20,000 --> 00:28:30,000
And you created a complete waste summary document. This is the foundation of your FinOps practice.

172
00:28:30,000 --> 00:28:40,000
Let me give you the hard-won lessons from real audits. These are the patterns I see repeatedly.

173
00:28:40,000 --> 00:28:50,000
Lesson one: the eighty-twenty of cloud waste. Eighty percent of waste lives in three places: overprovisioned compute, NAT Gateway, and storage.

174
00:28:50,000 --> 00:29:00,000
Lesson two: never trust the default region. Developers switch regions during testing and forget.

175
00:29:00,000 --> 00:29:10,000
Lesson three: stopped is not the same as terminated. EBS, Elastic IPs, and data transfer still apply.

176
00:29:10,000 --> 00:29:20,000
Lesson four: gp2 is legacy — always migrate. There is not a single workload where gp2 is preferable to gp3.

177
00:29:20,000 --> 00:29:30,000
Lesson five: anomaly detection saves more than it costs to set up. Fifteen minutes has saved hundreds of thousands.

178
00:29:30,000 --> 00:29:40,000
Now let's review the prerequisites before Series 3.

179
00:29:40,000 --> 00:29:50,000
First: gp2 to gp3 migration submitted. Check with aws ec2 describe-volumes-modifications.

180
00:29:50,000 --> 00:30:00,000
Second: unattached EIPs released. Check with aws ec2 describe-addresses --query 'Addresses[?!AssociationId]'.
```

---

**SEGMENT 7: Complete Waste Summary & Baseline Update**
*Timestamp: 30:00 – 35:00*

```
181
00:30:00,000 --> 00:30:10,000
Third: VPC endpoints created for S3 and DynamoDB.

182
00:30:10,000 --> 00:30:20,000
Fourth: ~/finops-baseline.txt updated with waste audit findings.

183
00:30:20,000 --> 00:30:30,000
Fifth: anomaly monitor and subscription created.

184
00:30:30,000 --> 00:30:40,000
If all five are verified, you are ready for Series 3. If not, go back and fix them.

185
00:30:40,000 --> 00:30:50,000
In Series 3, you stop working at the AWS account level and go inside the Kubernetes cluster.

186
00:30:50,000 --> 00:31:00,000
You deploy Kubecost on EKS. For the first time you will see: cost per namespace, efficiency scores, rightsizing recommendations.

187
00:31:00,000 --> 00:31:10,000
AWS Cost Explorer shows you EC2. Kubecost shows you the pod that is wasting it. That is the difference.

188
00:31:10,000 --> 00:31:20,000
But for now, review your waste summary. Look at the total identified waste in your account.

189
00:31:20,000 --> 00:31:30,000
You have a number. You have a plan. In Series 3, you will find even more waste — inside the cluster.

190
00:31:30,000 --> 00:31:40,000
The savings compound. The commands work. The savings are real. You just have to do the work.

191
00:31:40,000 --> 00:31:50,000
Before you leave Series 2, I want to give you one more thing.

192
00:31:50,000 --> 00:32:00,000
I want to give you a mental framework that will help you think about waste differently.

193
00:32:00,000 --> 00:32:10,000
Waste is not a failure. Waste is information. Every dollar of waste tells you something about your system.

194
00:32:10,000 --> 00:32:20,000
A gp2 volume tells you that your Terraform modules are out of date. A stopped instance tells you that someone did not finish their work.

195
00:32:20,000 --> 00:32:30,000
A NAT Gateway charge tells you that your VPC architecture has a design flaw. Every waste finding is a clue.

196
00:32:30,000 --> 00:32:40,000
The engineers who find waste and fix it are valuable. The engineers who find waste and build systems to prevent it are invaluable.

197
00:32:40,000 --> 00:32:50,000
You are now in the second category. You are not just fixing waste. You are building a system that prevents it.

198
00:32:50,000 --> 00:33:00,000
Series 2 is complete. The audit is done. The waste is eliminated. The foundation is stronger.

199
00:33:00,000 --> 00:33:10,000
In Series 3, we go inside the cluster. We find the waste that Cost Explorer cannot see.

200
00:33:10,000 --> 00:33:20,000
See you in Series 3.
```

---

**SEGMENT 8: Hard-Won Lessons & Series 3 Preview**
*Timestamp: 35:00 – 40:00*

```
201
00:35:00,000 --> 00:35:10,000
Welcome to Segment 8. This is the hard-won lessons segment.

202
00:35:10,000 --> 00:35:20,000
I have run more than fifty of these audits. I have seen the same patterns over and over.

203
00:35:20,000 --> 00:35:30,000
The first lesson: the second and third items in the Cost Explorer list are almost always the biggest opportunity.

204
00:35:30,000 --> 00:35:40,000
Everyone focuses on the top item. Almost nobody looks at items two through five. That is where the hidden money lives.

205
00:35:40,000 --> 00:35:50,000
The startup I have been referencing? Their top item was EC2 — obvious, expected. Their second item was NAT Gateway.

206
00:35:50,000 --> 00:36:00,000
Two thousand one hundred dollars a month. They had been ignoring it for eighteen months because it was not the biggest number.

207
00:36:00,000 --> 00:36:10,000
The second lesson: always check CloudTrail before releasing an EIP. I released an EIP once that a payment processor had whitelisted.

208
00:36:10,000 --> 00:36:20,000
Payments failed for two hours. Check CloudTrail. Ask the owner. Then release.

209
00:36:20,000 --> 00:36:30,000
The third lesson: stopped instances are a morale indicator as much as a cost indicator.

210
00:36:30,000 --> 00:36:40,000
Every stopped instance is a project someone started and did not finish. Treat them as a conversation starter.

211
00:36:40,000 --> 00:36:50,000
The fourth lesson: cost anomaly detection at fifty dollars catches things that five hundred dollars misses for three months.

212
00:36:50,000 --> 00:37:00,000
Every time I have seen a large surprise on a bill, looking back through the anomaly history shows it was detectable at fifty dollars per day.

213
00:37:00,000 --> 00:37:10,000
The fifth lesson: the day after running an audit is the most important day. Every finding you identify today will start rebuilding in six months.

214
00:37:10,000 --> 00:37:20,000
If you do not automate the prevention. The Config rules, the lifecycle policies, the Terraform enforcement — those are what make the savings permanent.

215
00:37:20,000 --> 00:37:30,000
Now let's preview Series 3. Kubernetes cost visibility with Kubecost.

216
00:37:30,000 --> 00:37:40,000
AWS Cost Explorer told you that EC2 cost twenty-two thousand dollars this month. Kubecost will tell you that the financial-rag namespace spent fourteen thousand two hundred of that.

217
00:37:40,000 --> 00:37:50,000
And that the llm-ingest deployment is the top contributor. And that it is running at forty-eight percent efficiency.

218
00:37:50,000 --> 00:38:00,000
And that CPU requests can be reduced by sixty percent without affecting latency. That level of specificity is what makes the next level of optimization possible.

219
00:38:00,000 --> 00:38:10,000
In Series 3, you deploy Kubecost. You see cost by namespace. You understand efficiency scores.

220
00:38:10,000 --> 00:38:20,000
You find rightsizing opportunities. You apply them safely. You measure the savings.

221
00:38:20,000 --> 00:38:30,000
This is where the real cluster-level optimization begins. The foundation is laid. Now we build on it.

222
00:38:30,000 --> 00:38:40,000
Series 2 is complete. The audit is done. The waste is eliminated. The foundation is stronger.

223
00:38:40,000 --> 00:38:50,000
See you in Series 3.
```

---

**SEGMENT 9: Deep Dive — Understanding EC2 Overprovisioning**
*Timestamp: 40:00 – 45:00*

```
224
00:40:00,000 --> 00:40:10,000
Welcome to Segment 9. We are going to deep dive into EC2 overprovisioning.

225
00:40:10,000 --> 00:40:20,000
This was the biggest single line item in the startup's waste. Eight thousand dollars a month.

226
00:40:20,000 --> 00:40:30,000
Overprovisioning is when you choose an instance type that is larger than your workload actually needs.

227
00:40:30,000 --> 00:40:40,000
Engineers do this for a reason. They want headroom. They do not want performance issues during spikes.

228
00:40:40,000 --> 00:40:50,000
But they never revisit the decision. The instance type that was chosen during the initial deployment stays forever.

229
00:40:50,000 --> 00:41:00,000
Even when the workload grows in a different direction. Even when the usage patterns change.

230
00:41:00,000 --> 00:41:10,000
The result is that you are paying for instance capacity you are not using. This is the most common form of waste.

231
00:41:10,000 --> 00:41:20,000
How do you identify overprovisioning? You look at CPU utilization over a thirty-day period.

232
00:41:20,000 --> 00:41:30,000
If your average CPU utilization is below forty percent, you are overprovisioned. Below thirty percent, severely overprovisioned.

233
00:41:30,000 --> 00:41:40,000
[Types: aws cloudwatch get-metric-statistics --namespace AWS/EC2 --metric-name CPUUtilization --dimensions Name=InstanceId,Value=i-1234567890abcdef0 --start-time $START --end-time $END --period 86400 --statistics Average --query 'Datapoints[].Average' --output table]
▶ Pronounced as: "Now AWS CloudWatch get-metric-statistics. We're pulling average CPU utilization for a specific instance over 30 days."

234
00:41:40,000 --> 00:41:50,000
This query shows you the average CPU utilization for a specific instance over the last thirty days.

235
00:41:50,000 --> 00:42:00,000
You can also look at memory utilization with CloudWatch agent metrics.

236
00:42:00,000 --> 00:42:10,000
The fix is rightsizing. Choose a smaller instance type that still meets your peak requirements.

237
00:42:10,000 --> 00:42:20,000
[Types: aws ec2 describe-instance-types --instance-types t3.medium --query 'InstanceTypes[0].VCpuInfo.DefaultVCpus' --output text]
▶ Pronounced as: "Now AWS E-C-two describe-instance-types to check vCPU count of a smaller instance."

238
00:42:20,000 --> 00:42:30,000
This shows you the specifications of a smaller instance type. Compare it to your current usage.

239
00:42:30,000 --> 00:42:40,000
In Series 3, Kubecost does this automatically at the Kubernetes level. It tells you exactly what each pod needs.

240
00:42:40,000 --> 00:42:50,000
And in Series 4, Karpenter continuously rightsizes the node fleet based on actual pod requests.

241
00:42:50,000 --> 00:43:00,000
But understanding EC2 overprovisioning at the account level gives you the context for what Kubecost and Karpenter are doing.

242
00:43:00,000 --> 00:43:10,000
Now let's look at a real example. A t3.large has two vCPUs and eight gigabytes of memory.

243
00:43:10,000 --> 00:43:20,000
If your workload is consistently using less than one vCPU and two gigabytes, you are overprovisioned.

244
00:43:20,000 --> 00:43:30,000
A t3.medium has one vCPU and four gigabytes of memory. It costs half as much.

245
00:43:30,000 --> 00:43:40,000
If your workload fits on a t3.medium, you are saving fifty percent on that instance.

246
00:43:40,000 --> 00:43:50,000
Multiply that across fifty instances and you are saving thousands of dollars a month.

247
00:43:50,000 --> 00:44:00,000
This is why rightsizing is one of the highest-leverage activities in FinOps.

248
00:44:00,000 --> 00:44:10,000
But remember: rightsizing is not one-time. It is continuous. Workloads change. Instance types change.

249
00:44:10,000 --> 00:44:20,000
This is why Karpenter and Kubecost work together. Kubecost tells you what each pod needs.

250
00:44:20,000 --> 00:44:30,000
Karpenter continuously adjusts the node fleet to match those needs. It is continuous rightsizing at the cluster level.

251
00:44:30,000 --> 00:44:40,000
In the next segment, we deep dive into S3 storage classes and cost optimization.

252
00:44:40,000 --> 00:44:50,000
See you in Segment 10.
```

---

**SEGMENT 10: Deep Dive — S3 Storage Classes & Cost Optimization**
*Timestamp: 45:00 – 50:00*

```
253
00:45:00,000 --> 00:45:10,000
Welcome to Segment 10. We are going to deep dive into S3 storage classes.

254
00:45:10,000 --> 00:45:20,000
S3 has multiple storage classes. Each has different costs and different performance characteristics.

255
00:45:20,000 --> 00:45:30,000
The most common mistake is storing all data in Standard tier when it belongs in a colder tier.

256
00:45:30,000 --> 00:45:40,000
S3 Standard is zero point zero two three dollars per GB per month. Fast retrieval. Low latency.

257
00:45:40,000 --> 00:45:50,000
S3 Standard-IA is zero point zero one two five dollars per GB per month. Infrequent access. Retrieval fee.

258
00:45:50,000 --> 00:46:00,000
S3 Glacier Instant Retrieval is zero point zero zero four dollars per GB per month. Archive access. Milliseconds retrieval.

259
00:46:00,000 --> 00:46:10,000
S3 Glacier Flexible Retrieval is zero point zero zero three six dollars per GB per month. Archive access. Minutes retrieval.

260
00:46:10,000 --> 00:46:20,000
S3 Glacier Deep Archive is zero point zero zero zero nine nine dollars per GB per month. Archive access. Hours retrieval.

261
00:46:20,000 --> 00:46:30,000
The difference between Standard and Deep Archive is more than twenty-three times. Twenty-three times cheaper.

262
00:46:30,000 --> 00:46:40,000
But you pay for retrieval. Deep Archive retrieval takes twelve to forty-eight hours and costs zero point zero two dollars per GB.

263
00:46:40,000 --> 00:46:50,000
So you need to understand your access patterns. Data that is accessed monthly should be in Standard-IA.

264
00:46:50,000 --> 00:47:00,000
Data that is accessed quarterly should be in Glacier Instant Retrieval. Data that is never accessed should be in Deep Archive.

265
00:47:00,000 --> 00:47:10,000
Lifecycle policies automate this transition. You define the rules. S3 moves the data automatically.

266
00:47:10,000 --> 00:47:20,000
[Types: aws s3api put-bucket-lifecycle-configuration --bucket your-bucket --lifecycle-configuration '{"Rules":[{"ID":"transition-to-ia","Status":"Enabled","Prefix":"","Transitions":[{"Days":30,"StorageClass":"STANDARD_IA"},{"Days":90,"StorageClass":"GLACIER_INSTANT_RETRIEVAL"},{"Days":365,"StorageClass":"DEEP_ARCHIVE"}]}]}']
▶ Pronounced as: "Now AWS S3-API put-bucket-lifecycle-configuration. We're defining transitions to IA at 30 days, Glacier at 90 days, and Deep Archive at 365 days."

267
00:47:20,000 --> 00:47:30,000
This lifecycle policy moves data from Standard to Standard-IA at thirty days. To Glacier at ninety days. To Deep Archive at three hundred and sixty-five days.

268
00:47:30,000 --> 00:47:40,000
This is how you automate S3 cost optimization. You do it once and it runs forever.

269
00:47:40,000 --> 00:47:50,000
The startup in our story had fifteen terabytes of data in Standard tier. They should have been paying zero point zero zero one dollars per GB. They were paying zero point zero two three dollars per GB.

27000:47:50,000 --> 00:48:00,000
The difference is nine hundred dollars a month. A simple lifecycle policy fixed it.

271
00:48:00,000 --> 00:48:10,000
In Series 6, we cover S3 lifecycle policies in full detail. We apply them to all buckets.

272
00:48:10,000 --> 00:48:20,000
But understand the concept now. Data ages. Its value decreases. Its storage cost should decrease too.

273
00:48:20,000 --> 00:48:30,000
Now let's look at another common mistake: not cleaning up old versions.

274
00:48:30,000 --> 00:48:40,000
If you have versioning enabled, old versions accumulate. Each version consumes storage. Each version costs money.

275
00:48:40,000 --> 00:48:50,000
[Types: aws s3api put-bucket-lifecycle-configuration --bucket your-bucket --lifecycle-configuration '{"Rules":[{"ID":"delete-old-versions","Status":"Enabled","Prefix":"","NoncurrentVersionExpiration":{"NoncurrentDays":30}}]}']
▶ Pronounced as: "Now a lifecycle rule to delete non-current versions after 30 days."

276
00:48:50,000 --> 00:49:00,000
This deletes old versions after thirty days. It keeps your storage costs under control.

277
00:49:00,000 --> 00:49:10,000
In the next segment, we deep dive into EBS volume types.

278
00:49:10,000 --> 00:49:20,000
See you in Segment 11.
```

---

**SEGMENT 11: Deep Dive — EBS Volume Types & When to Use What**
*Timestamp: 50:00 – 55:00*

```
279
00:50:00,000 --> 00:50:10,000
Welcome to Segment 11. We are going to deep dive into EBS volume types.

280
00:50:10,000 --> 00:50:20,000
EBS has multiple volume types. Each has different performance and different cost.

281
00:50:20,000 --> 00:50:30,000
gp2 is the older generation. Up to one hundred and sixty IOPS per GB. Up to sixteen thousand IOPS per volume.

282
00:50:30,000 --> 00:50:40,000
gp3 is the newer generation. Three thousand IOPS baseline. Up to sixteen thousand IOPS. Fifty percent cheaper per GB.

283
00:50:40,000 --> 00:50:50,000
gp3 also has better consistency. gp2 has bursting IOPS that degrade under sustained load.

284
00:50:50,000 --> 00:51:00,000
The migration from gp2 to gp3 is one command. Zero downtime. We covered it in detail in Segment 3.

285
00:51:00,000 --> 00:51:10,000
But there are also io1 and io2 volumes. These are provisioned-IOPS volumes for high-performance workloads.

286
00:51:10,000 --> 00:51:20,000
io1 and io2 are used for databases, high-transaction applications, and latency-sensitive workloads.

287
00:51:20,000 --> 00:51:30,000
Do not migrate io1 or io2 to gp3 without validating the workload. gp3 has different performance characteristics.

288
00:51:30,000 --> 00:51:40,000
For most workloads, gp3 is sufficient. For critical databases, io2 with the right IOPS is the correct choice.

289
00:51:40,000 --> 00:51:50,000
The key is to right-size your IOPS. Do not overprovision IOPS you do not need.

290
00:51:50,000 --> 00:52:00,000
[Types: aws ec2 describe-volumes --volume-ids vol-1234567890abcdef0 --query 'Volumes[].Iops' --output text]
▶ Pronounced as: "Now AWS E-C-two describe-volumes to check the IOPS of a specific volume."

291
00:52:00,000 --> 00:52:10,000
This shows you the IOPS of a specific volume. Compare it to your actual usage.

292
00:52:10,000 --> 00:52:20,000
[Types: aws cloudwatch get-metric-statistics --namespace AWS/EBS --metric-name VolumeReadOps --dimensions Name=VolumeId,Value=vol-1234567890abcdef0 --start-time $START --end-time $END --period 86400 --statistics Sum --query 'Datapoints[].Sum' --output table]
▶ Pronounced as: "Now CloudWatch get-metric-statistics for VolumeReadOps to see actual usage."

293
00:52:20,000 --> 00:52:30,000
This shows you the read operations on a volume. If your IOPS are consistently below what you provisioned, you are overpaying.

294
00:52:30,000 --> 00:52:40,000
The gp2 to gp3 migration is the highest-return action in this course. Twenty percent savings. Zero downtime. One command.

295
00:52:40,000 --> 00:52:50,000
I have not found a single workload where gp2 is preferable to gp3. Not one.

296
00:52:50,000 --> 00:53:00,000
If you have gp2 volumes, migrate them. Today. The command is ready. The savings are guaranteed.

297
00:53:00,000 --> 00:53:10,000
Now let's look at volume encryption. All EBS volumes should be encrypted.

298
00:53:10,000 --> 00:53:20,000
[Types: aws ec2 describe-volumes --query 'Volumes[?Encrypted==`false`].[VolumeId,Size,VolumeType]' --output table]
▶ Pronounced as: "Now AWS E-C-two describe-volumes filtering for unencrypted volumes."

299
00:53:20,000 --> 00:53:30,000
This shows you all unencrypted volumes. Encrypting existing volumes requires a migration.

300
00:53:30,000 --> 00:53:40,000
But new volumes should always be encrypted. Enable the default encryption setting in your account.

301
00:53:40,000 --> 00:53:50,000
[Types: aws ec2 enable-ebs-encryption-by-default]
▶ Pronounced as: "Now enabling EBS encryption by default for all new volumes."

302
00:53:50,000 --> 00:54:00,000
This ensures all new volumes are encrypted. It costs nothing. It improves security.

303
00:54:00,000 --> 00:54:10,000
In the next segment, we look at how to set up daily cost monitoring.

304
00:54:10,000 --> 00:54:20,000
See you in Segment 12.
```

---

**SEGMENT 12: Cost Anomaly Detection — Advanced Configuration**
*Timestamp: 55:00 – 60:00*

```
305
00:55:00,000 --> 00:55:10,000
Welcome to Segment 12. We are going to look at advanced cost anomaly detection.

306
00:55:10,000 --> 00:55:20,000
You set up basic anomaly detection in Segment 1. Now we go deeper.

307
00:55:20,000 --> 00:55:30,000
AWS Cost Anomaly Detection can monitor specific dimensions. Service, linked account, region, or custom tags.

308
00:55:30,000 --> 00:55:40,000
[Types: aws ce create-anomaly-monitor --anomaly-monitor '{"MonitorName":"financial-rag-anomaly","MonitorType":"DIMENSIONAL","MonitorDimension":"TAG","MonitorSpecification":{"TagKey":"Team","TagValues":["financial-rag"]}}']
▶ Pronounced as: "Now creating an anomaly monitor specifically for the financial-rag team tag."

309
00:55:40,000 --> 00:55:50,000
This creates an anomaly monitor specifically for the financial-rag team. You get alerts when their spend spikes.

310
00:55:50,000 --> 00:56:00,000
You can also monitor by linked account. This is useful for multi-account organizations.

311
00:56:00,000 --> 00:56:10,000
[Types: aws ce create-anomaly-monitor --anomaly-monitor '{"MonitorName":"linked-account-anomaly","MonitorType":"DIMENSIONAL","MonitorDimension":"LINKED_ACCOUNT"}']
▶ Pronounced as: "Now creating an anomaly monitor for linked accounts."

312
00:56:10,000 --> 00:56:20,000
The threshold should be a percentage of your baseline spend. Not a fixed dollar amount.

313
00:56:20,000 --> 00:56:30,000
For a ten-thousand-dollar account, a ten percent anomaly is one thousand dollars. For a one-thousand-dollar account, ten percent is one hundred dollars.

314
00:56:30,000 --> 00:56:40,000
[Types: aws ce update-anomaly-monitor --monitor-arn $MONITOR_ARN --monitor-name "finops-monitor" --monitor-specification '{"ThresholdExpression":{"Dimension":{"Key":"SERVICE","Values":["EC2"]}}}']
▶ Pronounced as: "Now updating the anomaly monitor to add a threshold expression for EC2 service."

315
00:56:40,000 --> 00:56:50,000
You can also create subscriptions that send alerts to SNS, Slack, or Lambda.

316
00:56:50,000 --> 00:57:00,000
[Types: aws ce create-anomaly-subscription --anomaly-subscription '{"SubscriptionName":"Slack-alerts","MonitorArnList":["$MONITOR_ARN"],"Subscribers":[{"Type":"SNS","Address":"arn:aws:sns:us-east-1:123456789012:anomaly-alerts"}],"Threshold":50,"Frequency":"DAILY"}']
▶ Pronounced as: "Now creating an anomaly subscription that sends to SNS for Slack integration."

317
00:57:00,000 --> 00:57:10,000
The SNS topic can then be integrated with Slack using a Lambda function.

318
00:57:10,000 --> 00:57:20,000
This is how you build a proactive monitoring system. Anomalies get caught in hours, not weeks.

319
00:57:20,000 --> 00:57:30,000
The cost of setting up anomaly detection is minimal. The cost of not having it is the cost of surprise bills.

320
00:57:30,000 --> 00:57:40,000
I have seen a client catch a five-thousand-dollar anomaly on the second day. They fixed it immediately. The alternative was a forty-five-thousand-dollar surprise at month end.

321
00:57:40,000 --> 00:57:50,000
Now let's look at how to analyze anomaly history.

322
00:57:50,000 --> 00:58:00,000
[Types: aws ce get-anomalies --date-interval Start=$(date -d '30 days ago' +%Y-%m-%d),End=$END --query 'Anomalies[?Impact.TotalImpact > `100`].[AnomalyId,RootCauses[0].Service,Impact.TotalImpact]' --output table]
▶ Pronounced as: "Now AWS C-E get-anomalies for the last 30 days, filtering for impact over 100 dollars."

323
00:58:00,000 --> 00:58:10,000
This shows you all anomalies over the last thirty days with impact greater than one hundred dollars.

324
00:58:10,000 --> 00:58:20,000
Review this monthly. Look for patterns. If you see the same anomaly recurring, you have a systemic problem.

325
00:58:20,000 --> 00:58:30,000
In the next segment, we look at how to automate the waste audit with scripts.

326
00:58:30,000 --> 00:58:40,000
See you in Segment 13.
```

---

**SEGMENT 13: How to Automate the Waste Audit with Scripts**
*Timestamp: 60:00 – 65:00*

```
327
01:00:00,000 --> 01:00:10,000
Welcome to Segment 13. We are going to look at automating the waste audit.

328
01:00:10,000 --> 01:00:20,000
You ran the waste audit manually in this series. But you should automate it.

329
01:00:20,000 --> 01:00:30,000
A weekly automated audit catches waste before it compounds. It is your early warning system.

330
01:00:30,000 --> 01:00:40,000
The complete waste summary script we ran in Segment 6 can be turned into a scheduled job.

331
01:00:40,000 --> 01:00:50,000
[Types: cat > /usr/local/bin/finops-waste-audit.sh << 'EOF'
#!/bin/bash
export ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export REGION=us-east-1
export START=$(date -d '30 days ago' +%Y-%m-%d)
export END=$(date +%Y-%m-%d)

echo "===== FINOPS WASTE AUDIT — $(date) ====="
# gp2 volumes
GP2_GB=$(aws ec2 describe-volumes --filters Name=volume-type,Values=gp2 --query 'sum(Volumes[].Size)' --output text 2>/dev/null || echo 0)
echo "gp2 volumes: ${GP2_GB}GB"
# EIPs
EIP_COUNT=$(aws ec2 describe-addresses --query 'length(Addresses[?!AssociationId])' --output text 2>/dev/null || echo 0)
echo "Unattached EIPs: $EIP_COUNT"
# Add more checks as needed
EOF]
▶ Pronounced as: "Now creating a reusable audit script. We're writing the script to /usr/local/bin/finops-waste-audit.sh."

332
01:00:50,000 --> 01:01:00,000
Make it executable and schedule it weekly.

333
01:01:00,000 --> 01:01:10,000
[Types: chmod +x /usr/local/bin/finops-waste-audit.sh]
[Types: echo "0 9 * * 1 /usr/local/bin/finops-waste-audit.sh >> /var/log/finops-audit.log" | crontab -]
▶ Pronounced as: "Now making the script executable and scheduling it weekly with cron."

334
01:01:10,000 --> 01:01:20,000
This runs the audit every Monday at 9 AM. The output goes to a log file for review.

335
01:01:20,000 --> 01:01:30,000
You can also send the output to Slack or email. This gives you a weekly cost health report.

336
01:01:30,000 --> 01:01:40,000
The key is to automate the discovery. Do not rely on memory. Do not rely on manual checks.

337
01:01:40,000 --> 01:01:50,000
The audit script should check: gp2 volumes, unattached EIPs, stopped instances, unattached EBS volumes, old snapshots, NAT Gateway cost.

338
01:01:50,000 --> 01:02:00,000
[Types: aws ec2 describe-volumes --filters Name=volume-type,Values=gp2 --query 'length(Volumes)' --output text]
▶ Pronounced as: "AWS E-C-two describe-volumes to count gp2 volumes."

339
01:02:00,000 --> 01:02:10,000
This command returns the count of gp2 volumes. A number greater than zero means you have work to do.

340
01:02:10,000 --> 01:02:20,000
[Types: aws ec2 describe-addresses --query 'length(Addresses[?!AssociationId])' --output text]
▶ Pronounced as: "AWS E-C-two describe-addresses to count unattached EIPs."

341
01:02:20,000 --> 01:02:30,000
This returns the count of unattached EIPs. A number greater than zero means waste.

342
01:02:30,000 --> 01:02:40,000
You can also automate the remediation. For example, a Lambda function that detects and releases unattached EIPs.

343
01:02:40,000 --> 01:02:50,000
But be careful with automated remediation. You do not want to accidentally release an EIP that is being used.

344
01:02:50,000 --> 01:03:00,000
Start with automated detection. Then decide if automated remediation is right for your environment.

345
01:03:00,000 --> 01:03:10,000
The most important automation is the Config rule we created in Series 1. It prevents untagged resources from being created.

346
01:03:10,000 --> 01:03:20,000
In the next segment, we look at understanding data transfer costs.

347
01:03:20,000 --> 01:03:30,000
See you in Segment 14.
```

---

**SEGMENT 14: Understanding Data Transfer Costs**
*Timestamp: 65:00 – 70:00*

```
348
01:05:00,000 --> 01:05:10,000
Welcome to Segment 14. We are going to look at data transfer costs.

349
01:05:10,000 --> 01:05:20,000
Data transfer is one of the most misunderstood costs on the AWS bill. It is also one of the most expensive.

350
01:05:20,000 --> 01:05:30,000
Data transfer charges apply when data moves. Between regions. From your VPC to the internet. Through NAT Gateway.

351
01:05:30,000 --> 01:05:40,000
The rates vary by service and by region. Data transfer within the same region and same AZ is free.

352
01:05:40,000 --> 01:05:50,000
Data transfer between different AZs in the same region costs zero point zero one dollars per GB. Data transfer between different regions costs more.

353
01:05:50,000 --> 01:06:00,000
Data transfer from EC2 to the internet costs zero point zero nine dollars per GB. Through NAT Gateway, it costs more.

354
01:06:00,000 --> 01:06:10,000
The key principle: keep data transfers to a minimum. Use the same region. Use the same AZ.

355
01:06:10,000 --> 01:06:20,000
[Types: aws ce get-cost-and-usage --time-period Start=$START,End=$END --granularity MONTHLY --metrics BlendedCost --filter '{"Dimensions":{"Key":"USAGE_TYPE","Values":["DataTransfer-Out-Bytes"]}}' --query 'ResultsByTime[0].Total.BlendedCost.Amount' --output text]
▶ Pronounced as: "Now AWS C-E get-cost-and-usage filtering for DataTransfer-Out-Bytes usage type."

356
01:06:20,000 --> 01:06:30,000
This shows you your data transfer out cost. If this is a significant portion of your bill, investigate.

357
01:06:30,000 --> 01:06:40,000
Why are you transferring data out? Is it necessary? Can you optimize it?

358
01:06:40,000 --> 01:06:50,000
One common cause of high data transfer is CDN or content delivery. Another is data replication across regions.

359
01:06:50,000 --> 01:07:00,000
Another cause is misconfigured VPC routing. Traffic that should stay inside the VPC is going out and coming back in.

360
01:07:00,000 --> 01:07:10,000
This is why VPC endpoints are so important. They keep traffic inside the VPC. They eliminate NAT Gateway charges.

361
01:07:10,000 --> 01:07:20,000
We covered VPC endpoints in Segment 5. They are one of the highest-return actions you can take.

362
01:07:20,000 --> 01:07:30,000
Another common cause of data transfer costs is cross-AZ traffic. If your pods are in different AZs, they are paying for data transfer.

363
01:07:30,000 --> 01:07:40,000
Use topology-aware routing. Use pod affinity. Keep your pods in the same AZ when possible.

364
01:07:40,000 --> 01:07:50,000
In Series 3, Kubecost shows you network cost attribution. It tells you how much cross-AZ traffic each namespace is generating.

365
01:07:50,000 --> 01:08:00,000
This is the kind of visibility that enables optimization. You cannot fix what you cannot see.

366
01:08:00,000 --> 01:08:10,000
In the next segment, we look at the hidden cost of load balancers.

367
01:08:10,000 --> 01:08:20,000
See you in Segment 15.
```

---

**SEGMENT 15: The Hidden Cost of Load Balancers**
*Timestamp: 70:00 – 75:00*

```
368
01:10:00,000 --> 01:10:10,000
Welcome to Segment 15. We are going to look at the hidden cost of load balancers.

369
01:10:10,000 --> 01:10:20,000
Load balancers are essential for modern applications. They route traffic to your pods. They provide high availability.

370
01:10:20,000 --> 01:10:30,000
But they also cost money. And many organizations run load balancers they do not need.

371
01:10:30,000 --> 01:10:40,000
An Application Load Balancer costs zero point zero two two five dollars per hour just to exist. That is sixteen dollars a month.

372
01:10:40,000 --> 01:10:50,000
Plus data transfer charges. Plus Lambda integration charges. The total cost can be much higher.

373
01:10:50,000 --> 01:11:00,000
Idle load balancers are the worst. They are running. They are billing. They are serving no traffic.

374
01:11:00,000 --> 01:11:10,000
[Types: aws elbv2 describe-load-balancers --query 'LoadBalancers[?Type==`application`].{Name:LoadBalancerName,State:State.Code,Type:Type}' --output table]
▶ Pronounced as: "Now AWS ELBv2 describe-load-balancers showing only application type with name, state, and type."

375
01:11:10,000 --> 01:11:20,000
This shows you all Application Load Balancers. Look for the ones with State.Code 'active' but no traffic.

376
01:11:20,000 --> 01:11:30,000
[Types: aws elbv2 describe-target-groups --load-balancer-arn arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/your-lb/1234567890 --query 'TargetGroups[].TargetGroupArn' --output text | while read tg_arn; do aws elbv2 describe-target-health --target-group-arn $tg_arn --query 'length(TargetHealthDescriptions[?TargetHealth.State==`healthy`])' --output text; done]
▶ Pronounced as: "Now checking target health for a specific load balancer."

377
01:11:30,000 --> 01:11:40,000
This shows you the health status of the targets behind your load balancer. Zero healthy targets means the load balancer is idle.

378
01:11:40,000 --> 01:11:50,000
You can also look at request count in CloudWatch. If a load balancer has zero requests for a week, it is idle.

379
01:11:50,000 --> 01:12:00,000
[Types: aws cloudwatch get-metric-statistics --namespace AWS/ApplicationELB --metric-name RequestCount --dimensions Name=LoadBalancer,Value=app/your-lb/1234567890 --start-time $(date -d '7 days ago' -u +%Y-%m-%dT%H:%M:%SZ) --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) --period 86400 --statistics Sum --query 'Datapoints[].Sum' --output table]
▶ Pronounced as: "Now CloudWatch get-metric-statistics for RequestCount over 7 days."

380
01:12:00,000 --> 01:12:10,000
The fix is simple. Delete idle load balancers. The command is in Segment 5.

381
01:12:10,000 --> 01:12:20,000
But be careful. Some load balancers are used for health checks only. Some are used for internal traffic.

382
01:12:20,000 --> 01:12:30,000
Check the owner before deleting. Use the tag Owner to find the responsible person.

383
01:12:30,000 --> 01:12:40,000
In Series 9, we build an IDP that tracks all resources. The catalog will show you which load balancers are in use.

384
01:12:40,000 --> 01:12:50,000
Until then, manual review is the way to go. Run the queries. Identify the idle ones. Delete them.

385
01:12:50,000 --> 01:13:00,000
In the next segment, we look at CloudWatch logs and storage costs.

386
01:13:00,000 --> 01:13:10,000
See you in Segment 16.
```

---

**SEGMENT 16: Deep Dive — CloudWatch Logs & Storage Costs**
*Timestamp: 75:00 – 80:00*

```
387
01:15:00,000 --> 01:15:10,000
Welcome to Segment 16. We are going to look at CloudWatch logs and storage costs.

388
01:15:10,000 --> 01:15:20,000
CloudWatch logs are essential for debugging and monitoring. But they can be expensive.

389
01:15:20,000 --> 01:15:30,000
CloudWatch charges for data ingestion. And data storage. And data archival. And data retrieval.

390
01:15:30,000 --> 01:15:40,000
The standard retention period is indefinite. Logs accumulate forever. And you pay for every byte stored.

391
01:15:40,000 --> 01:15:50,000
[Types: aws logs describe-log-groups --query 'logGroups[].{Name:logGroupName,Retention:retentionInDays,StoredBytes:storedBytes}' --output table]
▶ Pronounced as: "Now AWS Logs describe-log-groups showing name, retention, and stored bytes."

392
01:15:50,000 --> 01:16:00,000
This shows you all your log groups. Look for groups with retention set to never expire.

393
01:16:00,000 --> 01:16:10,000
[Types: aws logs put-retention-policy --log-group-name /aws/lambda/your-function --retention-in-days 30]
▶ Pronounced as: "Now setting a 30-day retention policy for a specific log group."

394
01:16:10,000 --> 01:16:20,000
This sets the retention period to thirty days. Logs older than thirty days are automatically deleted.

395
01:16:20,000 --> 01:16:30,000
The default indefinite retention is a cost trap. It is the easiest cost to cut.

396
01:16:30,000 --> 01:16:40,000
Set retention policies for every log group. Thirty days for application logs. Seven days for debug logs. Ninety days for audit logs.

397
01:16:40,000 --> 01:16:50,000
[Types: for group in $(aws logs describe-log-groups --query 'logGroups[].logGroupName' --output text); do if [ -z "$(aws logs get-retention-policy --log-group-name $group 2>/dev/null)" ]; then echo "No retention policy for $group"; fi; done]
▶ Pronounced as: "Now looping through all log groups to find those without retention policies."

398
01:16:50,000 --> 01:17:00,000
This shows you all log groups without a retention policy. Those are the ones you need to set.

399
01:17:00,000 --> 01:17:10,000
You can also archive logs to S3 for long-term storage. It is cheaper than CloudWatch.

400
01:17:10,000 --> 01:17:20,000
[Types: aws logs create-export-task --task-name "export-logs" --log-group-name /aws/lambda/your-function --from 1640995200000 --to 1640998800000 --destination your-bucket --destination-prefix logs/]
▶ Pronounced as: "Now creating an export task to move logs from CloudWatch to S3."

401
01:17:20,000 --> 01:17:30,000
This exports logs from CloudWatch to S3. You can then set lifecycle policies on the S3 bucket.

402
01:17:30,000 --> 01:17:40,000
In Series 6, we cover S3 lifecycle policies in detail. You will apply them to all buckets.

403
01:17:40,000 --> 01:17:50,000
But start with CloudWatch retention policies today. It takes five minutes and saves money.

404
01:17:50,000 --> 01:18:00,000
In the next segment, we look at how to find orphaned resources.

405
01:18:00,000 --> 01:18:10,000
See you in Segment 17.
```

---

**SEGMENT 17: How to Find Orphaned Resources**
*Timestamp: 80:00 – 85:00*

```
406
01:20:00,000 --> 01:20:10,000
Welcome to Segment 17. We are going to look at finding orphaned resources.

407
01:20:10,000 --> 01:20:20,000
Orphaned resources are resources that are no longer needed but are still billing. They are the most common hidden cost.

408
01:20:20,000 --> 01:20:30,000
Unattached EBS volumes. Unattached Elastic IPs. Stopped instances. Old snapshots. Idle load balancers.

409
01:20:30,000 --> 01:20:40,000
All of these are orphaned resources. They were created for a purpose that no longer exists.

410
01:20:40,000 --> 01:20:50,000
[Types: aws ec2 describe-volumes --filters Name=status,Values=available --query 'Volumes[].[VolumeId,Size,CreateTime]' --output table]
▶ Pronounced as: "Now AWS E-C-two describe-volumes filtering for available (unattached) volumes."

411
01:20:50,000 --> 01:21:00,000
This finds unattached EBS volumes. Look at the CreateTime. If it is older than thirty days, it is an orphan.

412
01:21:00,000 --> 01:21:10,000
[Types: aws ec2 describe-snapshots --owner-ids $ACCOUNT_ID --query 'Snapshots[?StartTime<='$(date -d '180 days ago' +%Y-%m-%dT%H:%M:%S)'].[SnapshotId,StartTime,VolumeSize]' --output table]
▶ Pronounced as: "Now AWS E-C-two describe-snapshots filtering for snapshots older than 180 days."

413
01:21:10,000 --> 01:21:20,000
This finds snapshots older than one hundred and eighty days. Most are orphans.

414
01:21:20,000 --> 01:21:30,000
[Types: aws ec2 describe-addresses --query 'Addresses[?!AssociationId].[PublicIp,AllocationId,Domain]' --output table]
▶ Pronounced as: "Now AWS E-C-two describe-addresses for unattached EIPs."

415
01:21:30,000 --> 01:21:40,000
This finds unattached Elastic IPs. Each one is three dollars sixty-five a month.

416
01:21:40,000 --> 01:21:50,000
[Types: aws rds describe-db-instances --query 'DBInstances[?DBInstanceStatus==`stopped`].[DBInstanceIdentifier,DBInstanceClass,DBInstanceStatus]' --output table]
▶ Pronounced as: "Now AWS RDS describe-db-instances filtering for stopped instances."

417
01:21:50,000 --> 01:22:00,000
This finds stopped RDS instances. They still bill for storage.

418
01:22:00,000 --> 01:22:10,000
The key to finding orphans is automation. Run these queries weekly. Send the results to a dashboard.

419
01:22:10,000 --> 01:22:20,000
If you see the same resources week after week, they are orphans. They have no owner. They are pure waste.

420
01:22:20,000 --> 01:22:30,000
The cleanup is simple. Snapshot if needed. Then delete. The commands are in earlier segments.

421
01:22:30,000 --> 01:22:40,000
Orphaned resources are a sign of a broken process. Resources are created. They are never cleaned up.

422
01:22:40,000 --> 01:22:50,000
The solution is automation. Use lifecycle policies for snapshots. Use auto-scaling groups for EC2. Use Config rules for tags.

423
01:22:50,000 --> 01:23:00,000
In Series 7, we build an IDP that makes cleanup automatic. Resources are created with expiration dates.

424
01:23:00,000 --> 01:23:10,000
But until then, manual review is the way to go. Run the queries. Delete the orphans.

425
01:23:10,000 --> 01:23:20,000
In the next segment, we look at cost allocation tags — advanced strategies.

426
01:23:20,000 --> 01:23:30,000
See you in Segment 18.
```

---

**SEGMENT 18: Cost Allocation Tags — Advanced Strategies**
*Timestamp: 85:00 – 90:00*

```
427
01:25:00,000 --> 01:25:10,000
Welcome to Segment 18. We are going to look at advanced tag strategies.

428
01:25:10,000 --> 01:25:20,000
Tags are the foundation of cost allocation. But simple tagging is not enough. You need a strategy.

429
01:25:20,000 --> 01:25:30,000
The six required tags we defined in Series 1 are the minimum. But you can add more.

430
01:25:30,000 --> 01:25:40,000
Some examples: Environment with values prod, staging, dev, test. Application with values rag, risk, platform.

431
01:25:40,000 --> 01:25:50,000
Region with values us-east-1, us-west-2. CostCenter with values engineering, data-science.

432
01:25:50,000 --> 01:26:00,000
The key is consistency. Every resource gets the same tags. Every team uses the same values.

433
01:26:00,000 --> 01:26:10,000
[Types: aws resourcegroupstaggingapi get-resources --tag-filters '[{"Key":"Environment","Values":["prod"]}]' --query 'ResourceTagMappingList[].ResourceARN' --output table]
▶ Pronounced as: "Now AWS ResourceGroupsTaggingAPI get-resources filtered by Environment=prod."

434
01:26:10,000 --> 01:26:20,000
This finds all resources with Environment=prod. You can use this to audit your tagging.

435
01:26:20,000 --> 01:26:30,000
[Types: aws resourcegroupstaggingapi get-resources --tag-filters '[{"Key":"Environment","Values":["prod","staging","dev","test"]}]' --query 'ResourceTagMappingList[].ResourceARN' --output table]
▶ Pronounced as: "Now getting all resources with any allowed Environment value."

436
01:26:30,000 --> 01:26:40,000
This finds all resources with any of the allowed Environment values. Resources without these values are untagged.

437
01:26:40,000 --> 01:26:50,000
Another advanced strategy is tag inheritance. Some resources inherit tags from their parent.

438
01:26:50,000 --> 01:27:00,000
For example, EBS volumes inherit tags from the EC2 instance they are attached to. S3 objects inherit tags from the bucket.

439
01:27:00,000 --> 01:27:10,000
But not all resources inherit tags. Check the documentation for each resource type.

440
01:27:10,000 --> 01:27:20,000
Tag policies in AWS Organizations enforce tagging at the organizational level.

441
01:27:20,000 --> 01:27:30,000
[Types: aws organizations list-policies --filter TAG_POLICY --query 'Policies[].{Name:Name,Content:Content}' --output table]
▶ Pronounced as: "Now AWS Organizations list-policies for tag policies."

442
01:27:30,000 --> 01:27:40,000
This shows you the tag policies in your organization. They can enforce required tags on all accounts.

443
01:27:40,000 --> 01:27:50,000
The most advanced strategy is automated tagging. Use Lambda to tag resources at creation time.

444
01:27:50,000 --> 01:28:00,000
[Types: aws lambda list-functions --query 'Functions[?FunctionName.contains(@, `tag`)].FunctionName' --output table]
▶ Pronounced as: "Now AWS Lambda list-functions to find functions with 'tag' in the name."

445
01:28:00,000 --> 01:28:10,000
This finds Lambda functions that might be used for automated tagging.

446
01:28:10,000 --> 01:28:20,000
In Series 7, we build an IDP that tags all resources automatically. The platform handles it for you.

447
01:28:20,000 --> 01:28:30,000
Until then, use the Config rule to flag untagged resources. Use bulk tagging scripts to fix them.

448
01:28:30,000 --> 01:28:40,000
In the next segment, we look at how to set up daily cost monitoring.

449
01:28:40,000 --> 01:28:50,000
See you in Segment 19.
```

---

**SEGMENT 19: How to Set Up Daily Cost Monitoring**
*Timestamp: 90:00 – 95:00*

```
450
01:30:00,000 --> 01:30:10,000
Welcome to Segment 19. We are going to look at daily cost monitoring.

451
01:30:10,000 --> 01:30:20,000
Monthly Cost Explorer is not enough. You need daily visibility to catch problems early.

452
01:30:20,000 --> 01:30:30,000
[Types: aws ce get-cost-and-usage --time-period Start=$(date -d '1 day ago' +%Y-%m-%d),End=$END --granularity DAILY --metrics BlendedCost --query 'ResultsByTime[0].Total.BlendedCost.Amount' --output text]
▶ Pronounced as: "Now AWS C-E get-cost-and-usage for yesterday's total cost."

453
01:30:30,000 --> 01:30:40,000
This shows you yesterday's cost. Compare it to the same day last week. Look for increases.

454
01:30:40,000 --> 01:30:50,000
[Types: aws ce get-cost-and-usage --time-period Start=$(date -d '7 days ago' +%Y-%m-%d),End=$END --granularity DAILY --metrics BlendedCost --query 'ResultsByTime[].[TimePeriod.Start,Total.BlendedCost.Amount]' --output table]
▶ Pronounced as: "Now AWS C-E get-cost-and-usage for the last 7 days."

455
01:30:50,000 --> 01:31:00,000
This shows you the last seven days. Look for patterns. Look for anomalies.

456
01:31:00,000 --> 01:31:10,000
You can also look at daily cost by service.

457
01:31:10,000 --> 01:31:20,000
[Types: aws ce get-cost-and-usage --time-period Start=$(date -d '1 day ago' +%Y-%m-%d),End=$END --granularity DAILY --metrics BlendedCost --group-by Type=DIMENSION,Key=SERVICE --query 'ResultsByTime[0].Groups[?Metrics.BlendedCost.Amount > `1`].[Keys[0],Metrics.BlendedCost.Amount]' --output table]
▶ Pronounced as: "Now AWS C-E get-cost-and-usage for yesterday's cost by service."

458
01:31:20,000 --> 01:31:30,000
This shows you yesterday's cost by service. If a service spiked, investigate it.

459
01:31:30,000 --> 01:31:40,000
The best way to monitor daily cost is automation. Use a Lambda function to send daily cost reports.

460
01:31:40,000 --> 01:31:50,000
[Types: aws lambda create-function --function-name daily-cost-report --runtime python3.9 --handler lambda_function.lambda_handler --role arn:aws:iam::123456789012:role/lambda-execution-role --zip-file fileb://lambda.zip]
▶ Pronounced as: "Now AWS Lambda create-function for a daily cost report Lambda."

461
01:31:50,000 --> 01:32:00,000
The Lambda function runs daily and sends a report to Slack or email.

462
01:32:00,000 --> 01:32:10,000
[Types: aws events put-rule --name daily-cost-report --schedule-expression 'cron(0 9 * * ? *)']
▶ Pronounced as: "Now AWS Events put-rule to schedule the Lambda daily at 9 AM."

463
01:32:10,000 --> 01:32:20,000
This schedules the Lambda to run every day at 9 AM.

464
01:32:20,000 --> 01:32:30,000
The daily cost report should show: total cost, cost by service, cost by team, cost by region.

465
01:32:30,000 --> 01:32:40,000
It should highlight any anomalies. A ten percent increase in a single day is an anomaly.

466
01:32:40,000 --> 01:32:50,000
Daily monitoring is the difference between catching problems in hours and catching them in weeks.

467
01:32:50,000 --> 01:33:00,000
In Series 10, we integrate daily cost monitoring into the IDP dashboard.

468
01:33:00,000 --> 01:33:10,000
But you can set it up now. It takes an hour and saves you from surprises.

469
01:33:10,000 --> 01:33:20,000
In the next segment, we look at the complete audit checklist.

470
01:33:20,000 --> 01:33:30,000
See you in Segment 20.
```

---

**SEGMENT 20: The Complete Audit Checklist**
*Timestamp: 95:00 – 100:00*

```
471
01:35:00,000 --> 01:35:10,000
Welcome to Segment 20. This is the complete audit checklist.

472
01:35:10,000 --> 01:35:20,000
After running through all twelve audit steps, you should be able to check every item on this list.

473
01:35:20,000 --> 01:35:30,000
Checklist item one: Environment variables verified. ACCOUNT_ID, REGION, START, END all set.

474
01:35:30,000 --> 01:35:40,000
Checklist item two: Cost Explorer access confirmed. The baseline query returns a number.

475
01:35:40,000 --> 01:35:50,000
Checklist item three: Top services identified. You know which services are driving your spend.

476
01:35:50,000 --> 01:36:00,000
Checklist item four: Daily trends reviewed. You know if there are any spikes or patterns.

477
01:36:00,000 --> 01:36:10,000
Checklist item five: Regional spend reviewed. You know if there are resources in the wrong region.

478
01:36:10,000 --> 01:36:20,000
Checklist item six: Anomaly detection configured. The monitor and subscription are set up.

479
01:36:20,000 --> 01:36:30,000
Checklist item seven: gp2 volumes migrated. No gp2 volumes remain.

480
01:36:30,000 --> 01:36:40,000
Checklist item eight: Unattached EIPs released. No unattached EIPs remain.

481
01:36:40,000 --> 01:36:50,000
Checklist item nine: Stopped instances terminated. No stopped instances remain.

482
01:36:50,000 --> 01:37:00,000
Checklist item ten: Unattached EBS volumes deleted. No unattached EBS volumes remain.

483
01:37:00,000 --> 01:37:10,000
Checklist item eleven: Old snapshots deleted. No snapshots older than ninety days remain.

484
01:37:10,000 --> 01:37:20,000
Checklist item twelve: VPC endpoints created for S3 and DynamoDB.

485
01:37:20,000 --> 01:37:30,000
Checklist item thirteen: Idle load balancers removed. No idle load balancers remain.

486
01:37:30,000 --> 01:37:40,000
Checklist item fourteen: Baseline document updated with waste audit results.

487
01:37:40,000 --> 01:37:50,000
Checklist item fifteen: Anomaly detection configured and tested.

488
01:37:50,000 --> 01:38:00,000
If you can check all fifteen items, your audit is complete. You have eliminated all the waste you found.

489
01:38:00,000 --> 01:38:10,000
But remember: the audit is not a one-time event. You need to run it again in three months.

490
01:38:10,000 --> 01:38:20,000
Cloud waste always returns. New resources are created. Old resources are forgotten. New engineers join the team.

491
01:38:20,000 --> 01:38:30,000
The Config rules and automation prevent some waste. But you still need to run the audit.

492
01:38:30,000 --> 01:38:40,000
Quarterly audit is the minimum. Monthly audit is better. Weekly audit is best.

493
01:38:40,000 --> 01:38:50,000
In the next segment, we do a workshop — running your full audit.

494
01:38:50,000 --> 01:39:00,000
See you in Segment 21.
```

---

**SEGMENT 21: Workshop — Running Your Full Audit**
*Timestamp: 100:00 – 105:00*

```
495
01:40:00,000 --> 01:40:10,000
Welcome to Segment 21. This is the audit workshop.

496
01:40:10,000 --> 01:40:20,000
We are going to run the full audit from start to finish. Follow along with me.

497
01:40:20,000 --> 01:40:30,000
Step 1: Set your environment variables.

498
01:40:30,000 --> 01:40:40,000
[Types: export ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)]
[Types: export REGION=us-east-1]
[Types: export START=$(date -d '30 days ago' +%Y-%m-%d)]
[Types: export END=$(date +%Y-%m-%d)]
[Types: echo "Account: $ACCOUNT_ID | Start: $START | End: $END"]
▶ Pronounced as: "Now setting environment variables and verifying them."

499
01:40:40,000 --> 01:40:50,000
Step 2: Confirm Cost Explorer access.

500
01:40:50,000 --> 01:41:00,000
[Types: aws ce get-cost-and-usage --time-period Start=$START,End=$END --granularity MONTHLY --metrics BlendedCost --query 'ResultsByTime[0].Total.BlendedCost.Amount' --output text]
▶ Pronounced as: "Now AWS C-E get-cost-and-usage to confirm access."

501
01:41:00,000 --> 01:41:10,000
Step 3: Run the spend by service query.

502
01:41:10,000 --> 01:41:20,000
[Types: aws ce get-cost-and-usage --time-period Start=$START,End=$END --granularity MONTHLY --metrics BlendedCost --group-by Type=DIMENSION,Key=SERVICE --query 'ResultsByTime[0].Groups[?Metrics.BlendedCost.Amount > `10`].[Keys[0],Metrics.BlendedCost.Amount]' --output table]
▶ Pronounced as: "Now AWS C-E get-cost-and-usage grouped by SERVICE."

503
01:41:20,000 --> 01:41:30,000
Step 4: Run the daily trends query.

504
01:41:30,000 --> 01:41:40,000
[Types: aws ce get-cost-and-usage --time-period Start=$START,End=$END --granularity DAILY --metrics BlendedCost --query 'ResultsByTime[].[TimePeriod.Start,Total.BlendedCost.Amount]' --output table]
▶ Pronounced as: "Now AWS C-E get-cost-and-usage with DAILY granularity."

505
01:41:40,000 --> 01:41:50,000
Step 5: Run the cost by region query.

506
01:41:50,000 --> 01:42:00,000
[Types: aws ce get-cost-and-usage --time-period Start=$START,End=$END --granularity MONTHLY --metrics BlendedCost --group-by Type=DIMENSION,Key=REGION --query 'ResultsByTime[0].Groups[].[Keys[0],Metrics.BlendedCost.Amount]' --output table]
▶ Pronounced as: "Now AWS C-E get-cost-and-usage grouped by REGION."

507
01:42:00,000 --> 01:42:10,000
Step 6: Find gp2 volumes.

508
01:42:10,000 --> 01:42:20,000
[Types: aws ec2 describe-volumes --filters Name=volume-type,Values=gp2 --query 'Volumes[].[VolumeId,Size]' --output table]
▶ Pronounced as: "Now AWS E-C-two describe-volumes filtered by gp2."

509
01:42:20,000 --> 01:42:30,000
Step 7: Find unattached Elastic IPs.

510
01:42:30,000 --> 01:42:40,000
[Types: aws ec2 describe-addresses --query 'Addresses[?!AssociationId].AllocationId' --output table]
▶ Pronounced as: "Now AWS E-C-two describe-addresses for unattached EIPs."

511
01:42:40,000 --> 01:42:50,000
Step 8: Find stopped instances.

512
01:42:50,000 --> 01:43:00,000
[Types: aws ec2 describe-instances --filters Name=instance-state-name,Values=stopped --query 'Reservations[].Instances[].InstanceId' --output table]
▶ Pronounced as: "Now AWS E-C-two describe-instances filtered by stopped state."

513
01:43:00,000 --> 01:43:10,000
Step 9: Find unattached EBS volumes.

514
01:43:10,000 --> 01:43:20,000
[Types: aws ec2 describe-volumes --filters Name=status,Values=available --query 'Volumes[].VolumeId' --output table]
▶ Pronounced as: "Now AWS E-C-two describe-volumes filtered by available status."

515
01:43:20,000 --> 01:43:30,000
Step 10: Run the complete waste summary.

516
01:43:30,000 --> 01:43:40,000
[Types: bash ~/finops-waste-summary.sh]
▶ Pronounced as: "Now running the waste summary script."

517
01:43:40,000 --> 01:43:50,000
Step 11: Review the results. Identify the waste. Apply the fixes.

518
01:43:50,000 --> 01:44:00,000
This is your complete audit. Run it quarterly. Track your progress. Share the results.

519
01:44:00,000 --> 01:44:10,000
In the next segment, we analyze your audit results.

520
01:44:10,000 --> 01:44:20,000
See you in Segment 22.
```

---

**SEGMENT 22: Analyzing Your Audit Results — What's Normal vs What's Waste**
*Timestamp: 105:00 – 110:00*

```
521
01:45:00,000 --> 01:45:10,000
Welcome to Segment 22. We are going to analyze your audit results.

522
01:45:10,000 --> 01:45:20,000
You have the data. You have the numbers. Now you need to understand what they mean.

523
01:45:20,000 --> 01:45:30,000
What is normal? What is waste? What is a problem? What is just noise?

524
01:45:30,000 --> 01:45:40,000
Normal EC2 utilization is thirty to fifty percent of capacity. Above fifty percent is good. Below thirty percent is overprovisioned.

525
01:45:40,000 --> 01:45:50,000
Normal EBS utilization is fifty to eighty percent of provisioned IOPS. Above eighty percent is fine. Below twenty percent is overprovisioned.

526
01:45:50,000 --> 01:46:00,000
Normal S3 Standard tier storage should be less than twenty percent of total S3 storage. The rest should be in lower tiers.

527
01:46:00,000 --> 01:46:10,000
Normal NAT Gateway cost should be less than five percent of total data transfer cost. If it is higher, VPC endpoints will help.

528
01:46:10,000 --> 01:46:20,000
Normal tag compliance is ninety-five percent. Anything less than ninety-five percent is a problem.

529
01:46:20,000 --> 01:46:30,000
Normal anomaly frequency is less than one per week. More than one per week means you have unstable workloads.

530
01:46:30,000 --> 01:46:40,000
If your numbers are outside these ranges, you have a problem. The problem is usually waste.

531
01:46:40,000 --> 01:46:50,000
For example, if your EC2 utilization is twenty percent, you are overprovisioned. Rightsize the instances.

532
01:46:50,000 --> 01:47:00,000
If your S3 Standard tier is eighty percent of total S3 storage, you need lifecycle policies.

533
01:47:00,000 --> 01:47:10,000
If your NAT Gateway cost is ten percent of data transfer, you need VPC endpoints.

534
01:47:10,000 --> 01:47:20,000
The key is to compare your numbers to these benchmarks. If you are significantly above the normal range, you have waste.

535
01:47:20,000 --> 01:47:30,000
If you are within the normal range, you are doing well. But you can still optimize.

536
01:47:30,000 --> 01:47:40,000
Optimization is not just about fixing problems. It is about continuous improvement.

537
01:47:40,000 --> 01:47:50,000
In the next segment, we do a Q&A for Series 2.

538
01:47:50,000 --> 01:48:00,000
See you in Segment 23.
```

---

**SEGMENT 23: Series 2 Q&A — Common Questions Answered**
*Timestamp: 110:00 – 115:00*

```
539
01:50:00,000 --> 01:50:10,000
Welcome to Segment 23. This is the Q&A for Series 2.

540
01:50:10,000 --> 01:50:20,000
Question 1: "The gp2 migration command failed. What went wrong?"

541
01:50:20,000 --> 01:50:30,000
Check that you have the correct permissions. You need ec2:ModifyVolume. Check that the volume is not attached to a running instance.

542
01:50:30,000 --> 01:50:40,000
Check that the volume is not in use. If the volume is part of a RAID array, you may need to stop the instance first.

543
01:50:40,000 --> 01:50:50,000
Question 2: "I released an EIP and broke a service. What happened?"

544
01:50:50,000 --> 01:51:00,000
Some EIPs are used for IP whitelisting by third parties. Always check CloudTrail before releasing. Always ask the owner.

545
01:51:00,000 --> 01:51:10,000
Question 3: "I created VPC endpoints but my NAT Gateway cost did not drop."

546
01:51:10,000 --> 01:51:20,000
Check that your route tables are correctly configured. The endpoints need to be in the route tables of your subnets.

547
01:51:20,000 --> 01:51:30,000
Check that your traffic is actually going through the endpoints. Some workloads still use NAT Gateway by default.

548
01:51:30,000 --> 01:51:40,000
Question 4: "How long does it take for gp2 to gp3 migration to complete?"

549
01:51:40,000 --> 01:51:50,000
It depends on the size of the volume. Small volumes take minutes. Large volumes can take hours.

550
01:51:50,000 --> 01:52:00,000
The volume remains available during the migration. No downtime.

551
01:52:00,000 --> 01:52:10,000
Question 5: "I found stopped instances but I do not know who owns them."

552
01:52:10,000 --> 01:52:20,000
Check the Owner tag. If there is no Owner tag, check CloudTrail for the last person who stopped the instance.

553
01:52:20,000 --> 01:52:30,000
If you still cannot find the owner, wait seven days. If no one claims the instance, terminate it.

554
01:52:30,000 --> 01:52:40,000
Question 6: "What if my organization uses multiple AWS accounts?"

555
01:52:40,000 --> 01:52:50,000
The audit needs to be run in each account. But the principles are the same. Tags, Cost Explorer, anomaly detection.

556
01:52:50,000 --> 01:53:00,000
In Series 10, we build a multi-account view in the IDP. But for now, run the audit in each account.

557
01:53:00,000 --> 01:53:10,000
Question 7: "How often should I run the cloud cost audit?"

558
01:53:10,000 --> 01:53:20,000
Quarterly is the minimum. Monthly is better. Weekly is best for large organizations.

559
01:53:20,000 --> 01:53:30,000
The key is to automate it. Use the scripts we created in this series.

560
01:53:30,000 --> 01:53:40,000
Question 8: "What is the single most important thing I learned in Series 2?"

561
01:53:40,000 --> 01:53:50,000
Visibility. Before you can fix waste, you need to find it. And finding it requires the right tools and the right commands.

562
01:53:50,000 --> 01:54:00,000
The tools and commands you learned in Series 2 are the foundation of FinOps.

563
01:54:00,000 --> 01:54:10,000
In the next segment, we do a knowledge check and look ahead to Series 3.

564
01:54:10,000 --> 01:54:20,000
See you in Segment 24.
```

---

**SEGMENT 24: Series 2 Knowledge Check & Next Steps**
*Timestamp: 115:00 – 120:00*

```
565
01:55:00,000 --> 01:55:10,000
Welcome to Segment 24. This is the knowledge check for Series 2.

566
01:55:10,000 --> 01:55:20,000
Let's test your understanding of Series 2. Answer these questions in your own words.

567
01:55:20,000 --> 01:55:30,000
Question 1: What command finds gp2 volumes? Write it down.

568
01:55:30,000 --> 01:55:40,000
Question 2: What command finds unattached Elastic IPs? Write it down.

569
01:55:40,000 --> 01:55:50,000
Question 3: What command creates a VPC endpoint for S3? Write it down.

570
01:55:50,000 --> 01:56:00,000
Question 4: What command creates a cost anomaly monitor? Write it down.

571
01:56:00,000 --> 01:56:10,000
Question 5: What is the difference between BlendedCost and UnblendedCost?

572
01:56:10,000 --> 01:56:20,000
Question 6: Why does NAT Gateway cost so much and how do you fix it?

573
01:56:20,000 --> 01:56:30,000
Question 7: What is the eighty-twenty rule of cloud waste?

574
01:56:30,000 --> 01:56:40,000
Question 8: How often should you run the cloud cost audit?

575
01:56:40,000 --> 01:56:50,000
Pause the video. Write down your answers. Then compare them to what you learned.

576
01:56:50,000 --> 01:57:00,000
If you got all eight correct, you understand Series 2. If you missed any, review the relevant segment.

577
01:57:00,000 --> 01:57:10,000
Now let's look ahead to Series 3.

578
01:57:10,000 --> 01:57:20,000
In Series 3, you deploy Kubecost on EKS. You see cost by namespace. You understand efficiency scores.

579
01:57:20,000 --> 01:57:30,000
You find rightsizing opportunities. You apply them safely. You measure the savings.

580
01:57:30,000 --> 01:57:40,000
AWS Cost Explorer shows you EC2. Kubecost shows you the pod that is wasting it. That is the difference.

581
01:57:40,000 --> 01:57:50,000
Series 2 was about the account level. Series 3 is about the cluster level.

582
01:57:50,000 --> 01:58:00,000
Before you start Series 3, verify these five things.

583
01:58:00,000 --> 01:58:10,000
One: gp2 to gp3 migration submitted. Check with aws ec2 describe-volumes-modifications.

584
01:58:10,000 --> 01:58:20,000
Two: unattached EIPs released. Check with aws ec2 describe-addresses --query 'Addresses[?!AssociationId]'.

585
01:58:20,000 --> 01:58:30,000
Three: VPC endpoints created for S3 and DynamoDB.

586
01:58:30,000 --> 01:58:40,000
Four: ~/finops-baseline.txt updated with waste audit findings.

587
01:58:40,000 --> 01:58:50,000
Five: anomaly monitor and subscription created.

588
01:58:50,000 --> 01:59:00,000
If all five are verified, you are ready for Series 3.

589
01:59:00,000 --> 01:59:10,000
Series 2 is complete. The audit is done. The waste is eliminated. The foundation is stronger.

590
01:59:10,000 --> 01:59:20,000
You have moved from guessing to knowing. From hoping to planning. From reactive to proactive.

591
01:59:20,000 --> 01:59:30,000
That is the difference between a junior engineer and a senior engineer. And you just made that leap.

592
01:59:30,000 --> 01:59:40,000
The commands work. The savings are real. You just have to do the work.

593
01:59:40,000 --> 01:59:50,000
See you in Series 3.
```