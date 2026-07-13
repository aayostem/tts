Here is your complete Series 6 SRT with all Type: lines and their corresponding Pronounced at: lines edited to type-along, precedential style. All headers, timestamps, numbering, narrative, and command blocks remain exactly as you provided.

---

Series 6: Storage & Database Cost Controls
Complete 24-Segment SRT — 2 Hours

---

SEGMENT 1: The Costs That Never Go Down
Timestamp: 00:00 – 05:00

```
1
00:00:00,000 --> 00:00:10,000
Welcome to Series 6. This is where we tackle the costs that never go down on their own.

2
00:00:10,000 --> 00:00:20,000
Compute is elastic. You scale it down, Karpenter consolidates it, Spot instances cut it 70%. When your traffic drops at 3 AM, your compute bill drops too.

3
00:00:20,000 --> 00:00:30,000
Storage and databases do not work that way. Every byte you write to S3 stays there and charges you until you explicitly delete it or move it to a cheaper tier.

4
00:00:30,000 --> 00:00:40,000
Every RDS instance runs 24 hours a day, 7 days a week, whether your developers are actively using it or not. Every untagged Docker image sitting in ECR costs you $0.10 per GB per month for as long as it exists.

5
00:00:40,000 --> 00:00:50,000
These costs compound silently. A startup that adds one new service per month, each generating 50 gigabytes of logs, adds $1.15 a month to their S3 bill.

6
00:00:50,000 --> 00:01:00,000
After 24 months it is 1.2 terabytes of logs — $27.60 a month — for data nobody has looked at in 18 months. That is the nature of storage costs: they never decrease unless you make them decrease.

7
00:01:00,000 --> 00:01:10,000
Here is what Series 6 does to the storage and database line in our startup's bill.

8
00:01:10,000 --> 00:01:20,000
S3 at $345 a month for 15 terabytes all in Standard — we bring it to $68 a month with lifecycle policies.

9
00:01:20,000 --> 00:01:30,000
ECR at $102 a month for 2,000 container images — we bring it to $10 a month with image cleanup.

10
00:01:30,000 --> 00:01:40,000
RDS production On-Demand at $210 a month — we bring it to $126 a month with Reserved Instances.

11
00:01:40,000 --> 00:01:50,000
RDS dev databases running 24/7 at $180 a month total — we bring them to $72 a month with stop/start schedules.

12
00:01:50,000 --> 00:02:00,000
ElastiCache On-Demand at $87 a month — we bring it to $52 a month with Reserved Nodes.

13
00:02:00,000 --> 00:02:10,000
Total Series 6 saving: $596 a month. $7,152 a year. From automation you set up once.

14
00:02:10,000 --> 00:02:20,000
Environment verification:

15
00:02:20,000 --> 00:02:30,000
[Types: export ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)]
[Types: export REGION=us-east-1]
[Types: export START=$(date -d '30 days ago' +%Y-%m-%d)]
[Types: export END=$(date +%Y-%m-%d)]
▶ Pronounced as: "Now setting our environment variables with ACCOUNT_ID, REGION, START, and END."

16
00:02:30,000 --> 00:02:40,000
[Types: aws ce get-cost-and-usage --time-period Start=$START,End=$END --granularity MONTHLY --metrics BlendedCost --filter '{"Dimensions":{"Key":"SERVICE","Values":["Amazon Simple Storage Service","Amazon Relational Database Service","Amazon ElastiCache","Amazon EC2 Container Registry (ECR)"]}}' --query 'ResultsByTime[0].Total.BlendedCost.Amount' --output text]
▶ Pronounced as: "Now querying Cost Explorer for our combined storage and database services baseline."

17
00:02:40,000 --> 00:02:50,000
Write that number down. Every dollar we save in Series 6 comes from this baseline.

18
00:02:50,000 --> 00:03:00,000
Now let me explain why storage and database costs are different from compute costs.

19
00:03:00,000 --> 00:03:10,000
When you scale down compute, you stop paying immediately. The EC2 instance terminates, the billing stops.

20
00:03:10,000 --> 00:03:20,000
When you delete a file from S3, you stop paying for that file. But until you delete it, you pay every single month. There is no automatic tiering. There is no automatic cleanup.

21
00:03:20,000 --> 00:03:30,000
This is the fundamental difference. Storage costs are persistent. They accumulate. They never go down unless you explicitly make them go down.

22
00:03:30,000 --> 00:03:40,000
Database costs are also persistent. An RDS instance runs 24/7 regardless of whether anyone is using it. A dev database that is used 8 hours a day still bills for 24 hours.

23
00:03:40,000 --> 00:03:50,000
This is why automation is so important. You cannot manually manage storage and database costs at scale. You need policies that run automatically.

24
00:03:50,000 --> 00:04:00,000
The lifecycle policies we apply in this series are set-and-forget. You write them once. They run forever. Every new object that is uploaded follows the same tiering path.

25
00:04:00,000 --> 00:04:10,000
The stop/start schedules we apply to dev databases are also set-and-forget. You configure the schedule once. It runs every day. Every dev database with the right tag follows the same schedule.

26
00:04:10,000 --> 00:04:20,000
The Reserved Instances we purchase are also set-and-forget. You buy them once. They apply discounts for the entire term. No ongoing management required.

27
00:04:20,000 --> 00:04:30,000
This is what makes Series 6 different from the earlier series. In Series 2 through 5, you were fixing existing waste. In Series 6, you are preventing future waste permanently.

28
00:04:30,000 --> 00:04:40,000
Let's start with S3 — the most silently compounding cost in most AWS accounts.

29
00:04:40,000 --> 00:04:50,000
I have seen accounts where S3 storage cost was 30% of the total bill. Most of that data was old. Most of it was in Standard tier. Most of it could have been moved to cheaper tiers years ago.

30
00:04:50,000 --> 00:05:00,000
The reason it stayed in Standard tier is simple: nobody looked. Storage costs are invisible until they compound. And by the time you notice, the cost is significant.

31
00:05:00,000 --> 00:05:10,000
In the next segment, we find the expensive buckets and understand what we are dealing with.

32
00:05:10,000 --> 00:05:20,000
See you in Segment 2.
```

---

SEGMENT 2: S3 Analysis — Finding the Expensive Buckets
Timestamp: 05:00 – 10:00

```
33
00:05:00,000 --> 00:05:10,000
Before applying any lifecycle policy, you need to understand what you have. How much data. In which storage class. With or without existing policies.

34
00:05:10,000 --> 00:05:20,000
These three questions determine your savings potential. If you have 10 terabytes of data in Standard, your savings potential is high. If you have 10 terabytes in Deep Archive, your savings potential is zero.

35
00:05:20,000 --> 00:05:30,000
If you already have lifecycle policies on all your buckets, you are done. But most accounts have at least a few buckets without policies.

36
00:05:30,000 --> 00:05:40,000
Let's find your most expensive buckets by data size and estimated cost.

37
00:05:40,000 --> 00:05:50,000
[Types: aws s3api list-buckets --query 'Buckets[].Name' --output text | tr '\t' '\n' | while read bucket; do size=$(aws s3api list-objects-v2 --bucket $bucket --query 'sum(Contents[].Size)' --output text 2>/dev/null || echo 0); size_gb=$(echo "scale=2; ${size:-0} / 1073741824" | bc); cost=$(echo "scale=4; $size_gb * 0.023" | bc); echo "$bucket | ${size_gb}GB | \$${cost}/month"; done | sort -t'|' -k3 -rn | head -20]
▶ Pronounced as: "Now listing all buckets, calculating their size in GB, and showing estimated monthly cost at Standard tier rates."

38
00:05:50,000 --> 00:06:00,000
Now, look at that output. You should see your most expensive buckets at the top. The ones with the largest data sizes and the highest estimated costs.

39
00:06:00,000 --> 00:06:10,000
These are your immediate targets. Start with the most expensive buckets and work your way down.

40
00:06:10,000 --> 00:06:20,000
Now check the storage class distribution in your most expensive bucket.

41
00:06:20,000 --> 00:06:30,000
[Types: TARGET_BUCKET="your-most-expensive-bucket"; aws s3api list-objects-v2 --bucket $TARGET_BUCKET --query 'Contents[].StorageClass' --output text | tr '\t' '\n' | sort | uniq -c | awk '{ class=$2; count=$1; if (class=="STANDARD") cost=0.023; if (class=="STANDARD_IA") cost=0.0125; if (class=="GLACIER_IR") cost=0.004; if (class=="GLACIER") cost=0.0036; if (class=="DEEP_ARCHIVE") cost=0.00099; printf "%-25s objects: %8d  rate: $%.4f/GB\n", class, count, cost }']
▶ Pronounced as: "Now checking the storage class distribution of the target bucket."

42
00:06:30,000 --> 00:06:40,000
Now, look at that output. This shows you what percentage of your data is in each storage class.

43
00:06:40,000 --> 00:06:50,000
If most of your data is in STANDARD, that is your opportunity. STANDARD costs $0.023 per GB per month. DEEP_ARCHIVE costs $0.00099 per GB per month. The difference is 23x.

44
00:06:50,000 --> 00:07:00,000
Not 23%. 23x. A file that costs $0.023 in Standard costs $0.00099 in Deep Archive. That is the magnitude of the saving.

45
00:07:00,000 --> 00:07:10,000
Now find all buckets with no lifecycle policy. These are your immediate targets.

46
00:07:10,000 --> 00:07:20,000
[Types: aws s3api list-buckets --query 'Buckets[].Name' --output text | tr '\t' '\n' | while read bucket; do lc=$(aws s3api get-bucket-lifecycle-configuration --bucket $bucket 2>/dev/null | jq '.Rules | length' || echo 0); if [ "$lc" = "0" ] || [ -z "$lc" ]; then size=$(aws s3 ls --summarize --recursive s3://$bucket 2>/dev/null | grep "Total Size" | awk '{print $3}'); size_gb=$(echo "scale=1; ${size:-0} / 1073741824" | bc); echo "NO LIFECYCLE: $bucket  (${size_gb}GB unmanaged)"; fi; done]
▶ Pronounced as: "Now finding all buckets with no lifecycle policy."

47
00:07:20,000 --> 00:07:30,000
Now, look at that output. These are the buckets that are fully unmanaged. All their data is sitting in Standard tier. All of it is costing you $0.023 per GB per month.

48
00:07:30,000 --> 00:07:40,000
What you are looking for: buckets with terabytes of data and no lifecycle policy. That is 100% of their data sitting in Standard at $0.023 per GB per month.

49
00:07:40,000 --> 00:07:50,000
Let me give you a real example. A financial services client had a bucket with 15 terabytes of old SEC filings. No lifecycle policy. All in Standard. $345 a month.

50
00:07:50,000 --> 00:08:00,000
We applied a lifecycle policy that moved data to Standard-IA after 30 days, Glacier after 90 days, and Deep Archive after 365 days. The monthly cost dropped to $68.

51
00:08:00,000 --> 00:08:10,000
$277 a month saved. $3,324 a year. From a single lifecycle policy on a single bucket.

52
00:08:10,000 --> 00:08:20,000
Now you know where your S3 waste is. In the next segment, we apply the lifecycle policies.

53
00:08:20,000 --> 00:08:30,000
See you in Segment 3.
```

---

SEGMENT 3: S3 Lifecycle Policies — The financial-rag Policy
Timestamp: 10:00 – 15:00

```
54
00:10:00,000 --> 00:10:10,000
The lifecycle policy is the most important file you will create in Series 6.

55
00:10:10,000 --> 00:10:20,000
Every byte written to this bucket from today forward will automatically migrate through the tiers on the schedule you define. You set it once. It runs forever.

56
00:10:20,000 --> 00:10:30,000
One important caveat before we write the policy: Standard-IA has a 30-day minimum storage charge per object. If you store a 1-kilobyte log file for one day and delete it, you pay for 30 days.

57
00:10:30,000 --> 00:10:40,000
Never use IA for objects smaller than 128 kilobytes. The filter below handles this automatically.

58
00:10:40,000 --> 00:10:50,000
Create the financial-rag lifecycle policy:

59
00:10:50,000 --> 00:11:00,000
[Types: cat > financial-rag-lifecycle.json << 'EOF'
{
  "Rules": [
    {
      "ID": "transition-logs",
      "Status": "Enabled",
      "Filter": {"And": {"Prefix": "logs/","ObjectSizeGreaterThan": 131072}},
      "Transitions": [
        {"Days": 30,  "StorageClass": "STANDARD_IA"},
        {"Days": 90,  "StorageClass": "GLACIER_INSTANT_RETRIEVAL"},
        {"Days": 365, "StorageClass": "DEEP_ARCHIVE"}
      ],
      "Expiration": {"Days": 730}
    },
    {
      "ID": "transition-model-checkpoints",
      "Status": "Enabled",
      "Filter": {"Prefix": "checkpoints/"},
      "Transitions": [
        {"Days": 7,  "StorageClass": "STANDARD_IA"},
        {"Days": 90, "StorageClass": "GLACIER_INSTANT_RETRIEVAL"}
      ],
      "Expiration": {"Days": 180}
    },
    {
      "ID": "transition-sec-filings",
      "Status": "Enabled",
      "Filter": {"Prefix": "filings/"},
      "Transitions": [
        {"Days": 90,  "StorageClass": "STANDARD_IA"},
        {"Days": 365, "StorageClass": "GLACIER_INSTANT_RETRIEVAL"}
      ]
    },
    {
      "ID": "abort-incomplete-multipart",
      "Status": "Enabled",
      "Filter": {"Prefix": ""},
      "AbortIncompleteMultipartUpload": {"DaysAfterInitiation": 7}
    }
  ]
}
EOF]
▶ Pronounced as: "Now creating the lifecycle policy JSON file with cat and heredoc."

60
00:11:00,000 --> 00:11:10,000
Now let me walk you through each rule.

61
00:11:10,000 --> 00:11:20,000
The first rule is for logs. Logs are typically accessed frequently for the first 30 days, then rarely. After 30 days, they move to Standard-IA. After 90 days, they move to Glacier Instant Retrieval. After 365 days, they move to Deep Archive. After 730 days, they are deleted.

62
00:11:20,000 --> 00:11:30,000
The second rule is for model checkpoints. Checkpoints are accessed frequently during training, then rarely. After 7 days, they move to Standard-IA. After 90 days, they move to Glacier Instant Retrieval. After 180 days, they are deleted.

63
00:11:30,000 --> 00:11:40,000
The third rule is for SEC filings. Filings are accessed occasionally for compliance purposes. After 90 days, they move to Standard-IA. After 365 days, they move to Glacier Instant Retrieval. They are never deleted.

64
00:11:40,000 --> 00:11:50,000
The fourth rule is the abort-incomplete-multipart rule. This is the one people always forget. Incomplete multipart uploads accumulate silently. $0.023 per GB per month for parts of uploads that will never be completed.

65
00:11:50,000 --> 00:12:00,000
The 7-day abort rule cleans these up automatically. I have seen this rule alone save $300 a month in accounts with high-volume upload workloads.

66
00:12:00,000 --> 00:12:10,000
Now apply this policy to the financial-rag-documents bucket:

67
00:12:10,000 --> 00:12:20,000
[Types: aws s3api put-bucket-lifecycle-configuration --bucket financial-rag-documents --lifecycle-configuration file://financial-rag-lifecycle.json]
[Types: echo "Lifecycle policy applied to financial-rag-documents"]
▶ Pronounced as: "Now applying the lifecycle policy to the financial-rag-documents bucket."

68
00:12:20,000 --> 00:12:30,000
Now verify it was applied:

69
00:12:30,000 --> 00:12:40,000
[Types: aws s3api get-bucket-lifecycle-configuration --bucket financial-rag-documents --query 'Rules[*].{ID:ID,Status:Status}' --output table]
▶ Pronounced as: "Now verifying the lifecycle policy was applied with get-bucket-lifecycle-configuration."

70
00:12:40,000 --> 00:12:50,000
Now, look at that output. You should see the four rules with Status Enabled.

71
00:12:50,000 --> 00:13:00,000
This policy is now active. Every new object uploaded to this bucket will follow this tiering path. Existing objects will be evaluated and tiered according to their age.

72
00:13:00,000 --> 00:13:10,000
The lifecycle policy runs once a day. It may take up to 24 hours for the first evaluation to complete. After that, tiering happens automatically.

73
00:13:10,000 --> 00:13:20,000
Now let me explain the thinking behind the tiering schedule.

74
00:13:20,000 --> 00:13:30,000
The first 30 days are Standard. This is when the data is most likely to be accessed. After 30 days, access drops off significantly. Standard-IA is half the cost of Standard.

75
00:13:30,000 --> 00:13:40,000
After 90 days, access drops off further. Glacier Instant Retrieval is 17% of the cost of Standard. You can retrieve data in milliseconds.

76
00:13:40,000 --> 00:13:50,000
After 365 days, access is rare. Deep Archive is 4% of the cost of Standard. You can retrieve data in 12 hours.

77
00:13:50,000 --> 00:14:00,000
This is the tiering strategy that maximizes savings while preserving access. The older the data, the lower the cost.

78
00:14:00,000 --> 00:14:10,000
In the next segment, we bulk-apply a standard lifecycle to every bucket that does not have one.

79
00:14:10,000 --> 00:14:20,000
See you in Segment 4.
```

---

SEGMENT 4: Bulk S3 Lifecycle & ECR Image Cleanup
Timestamp: 15:00 – 20:00

```
80
00:15:00,000 --> 00:15:10,000
Now we bulk-apply a standard lifecycle to all unprotected buckets.

81
00:15:10,000 --> 00:15:20,000
This is the force multiplier. Instead of applying policies to each bucket individually, you apply them to all buckets that do not have a policy.

82
00:15:20,000 --> 00:15:30,000
[Types: cat > bulk-apply-lifecycle.sh << 'EOF'
#!/usr/bin/env bash
STANDARD_LIFECYCLE='{
  "Rules": [{
    "ID": "standard-cost-lifecycle",
    "Status": "Enabled",
    "Filter": {"ObjectSizeGreaterThan": 131072},
    "Transitions": [
      {"Days": 30,  "StorageClass": "STANDARD_IA"},
      {"Days": 90,  "StorageClass": "GLACIER_INSTANT_RETRIEVAL"},
      {"Days": 365, "StorageClass": "DEEP_ARCHIVE"}
    ],
    "Expiration": {"Days": 730},
    "AbortIncompleteMultipartUpload": {"DaysAfterInitiation": 7}
  }]
}'

aws s3api list-buckets --query 'Buckets[].Name' --output text | \
  tr '\t' '\n' | while read bucket; do
    existing=$(aws s3api get-bucket-lifecycle-configuration \
      --bucket $bucket 2>/dev/null | jq '.Rules | length' || echo 0)
    if [ "$existing" = "0" ]; then
      aws s3api put-bucket-lifecycle-configuration \
        --bucket $bucket \
        --lifecycle-configuration "$STANDARD_LIFECYCLE"
      echo "Applied lifecycle: $bucket"
    else
      echo "Skipped (existing policy): $bucket"
    fi
  done
EOF]
▶ Pronounced as: "Now creating the bulk lifecycle application script."

83
00:15:30,000 --> 00:15:40,000
[Types: chmod +x bulk-apply-lifecycle.sh]
[Types: ./bulk-apply-lifecycle.sh]
▶ Pronounced as: "Now making the script executable and running it."

84
00:15:40,000 --> 00:15:50,000
Now, look at that output. Every bucket without a lifecycle policy now has one. Every new object uploaded to those buckets will be tiered automatically.

85
00:15:50,000 --> 00:16:00,000
This is the power of bulk automation. In one command, you fixed every unmanaged bucket in your account.

86
00:16:00,000 --> 00:16:10,000
Now let's move to ECR — Elastic Container Registry. This is the storage cost that most engineering teams never think about.

87
00:16:10,000 --> 00:16:20,000
ECR stores your container images. A mature CI/CD pipeline building and pushing on every commit generates hundreds of images per repository per month.

88
00:16:20,000 --> 00:16:30,000
At $0.10 per GB, a repository with 200 images averaging 1GB each costs $20 a month to store — for images that nobody will ever pull again.

89
00:16:30,000 --> 00:16:40,000
Audit your ECR repositories:

90
00:16:40,000 --> 00:16:50,000
[Types: aws ecr describe-repositories --query 'repositories[].[repositoryName]' --output text | tr '\t' '\n' | while read repo; do count=$(aws ecr list-images --repository-name $repo --query 'length(imageIds)' --output text); size=$(aws ecr describe-images --repository-name $repo --query 'sum(imageDetails[].imageSizeInBytes)' --output text 2>/dev/null || echo 0); size_gb=$(echo "scale=2; ${size:-0} / 1073741824" | bc); cost=$(echo "scale=4; $size_gb * 0.10" | bc); echo "$repo | images: $count | size: ${size_gb}GB | cost: \$${cost}/month"; done]
▶ Pronounced as: "Now auditing all ECR repositories with image count, size, and estimated cost."

91
00:16:50,000 --> 00:17:00,000
Now, look at that output. Some repositories will have hundreds of images. Many will have images older than a year that will never be used again.

92
00:17:00,000 --> 00:17:10,000
Apply lifecycle policy to all ECR repositories — keep 20 most recent images, delete untagged after 14 days:

93
00:17:10,000 --> 00:17:20,000
[Types: cat > ecr-lifecycle-policy.json << 'EOF'
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Delete untagged images after 14 days",
      "selection": {
        "tagStatus": "untagged",
        "countType": "sinceImagePushed",
        "countUnit": "days",
        "countNumber": 14
      },
      "action": {"type": "expire"}
    },
    {
      "rulePriority": 2,
      "description": "Keep only 20 most recent tagged images",
      "selection": {
        "tagStatus": "tagged",
        "tagPrefixList": ["v", "release", "main", "prod"],
        "countType": "imageCountMoreThan",
        "countNumber": 20
      },
      "action": {"type": "expire"}
    }
  ]
}
EOF]
▶ Pronounced as: "Now creating the ECR lifecycle policy JSON file."

94
00:17:20,000 --> 00:17:30,000
[Types: aws ecr describe-repositories --query 'repositories[].repositoryName' --output text | tr '\t' '\n' | while read repo; do aws ecr put-lifecycle-policy --repository-name $repo --lifecycle-policy-text file://ecr-lifecycle-policy.json; echo "ECR lifecycle applied: $repo"; done]
▶ Pronounced as: "Now applying the lifecycle policy to all ECR repositories."

95
00:17:30,000 --> 00:17:40,000
Now, look at that output. Every repository now has a lifecycle policy. Untagged images will be deleted after 14 days. Only the 20 most recent tagged images will be kept.

96
00:17:40,000 --> 00:17:50,000
The impact of this policy is significant. In the startup's account, ECR cost dropped from $102 a month to $10 a month. $92 a month saved.

97
00:17:50,000 --> 00:18:00,000
The untagged images rule is the most important. CI/CD pipelines often leave untagged images behind. These images are never used. They just sit there costing money.

98
00:18:00,000 --> 00:18:10,000
The tagged images rule keeps the most recent tagged images. If you have a tag prefix like "v" or "release", it keeps only the 20 most recent of those tags.

99
00:18:10,000 --> 00:18:20,000
This prevents the repository from accumulating hundreds of images. It keeps the repository clean and the cost low.

100
00:18:20,000 --> 00:18:30,000
S3 and ECR are automated. Now the most impactful database optimization: stop/start schedules for dev and staging RDS.

101
00:18:30,000 --> 00:18:40,000
In the next segment, we build the Lambda scheduler that stops dev databases at night and starts them in the morning.

102
00:18:40,000 --> 00:18:50,000
See you in Segment 5.
```

---

SEGMENT 5: RDS Stop/Start Schedules & Reserved Instances
Timestamp: 20:00 – 25:00

```
103
00:20:00,000 --> 00:20:10,000
Dev and staging RDS instances run 24 hours a day, 7 days a week. Developers use them for 50 hours a week — maybe 60. They run idle for the other 108 hours.

104
00:20:10,000 --> 00:20:20,000
If your dev database costs $60 a month On-Demand running all the time, it costs $18 a month running only during business hours. Same database. 70% cheaper.

105
00:20:20,000 --> 00:20:30,000
The Lambda scheduler watches for a tag — Schedule=dev-hours — and stops tagged instances at 20:00 UTC and starts them at 07:00 UTC on weekdays.

106
00:20:30,000 --> 00:20:40,000
Zero downtime impact. Developers start work and the database is already running. They never notice the database was stopped overnight.

107
00:20:40,000 --> 00:20:50,000
Create the Lambda function:

108
00:20:50,000 --> 00:21:00,000
[Types: cat > /tmp/rds_scheduler.py << 'EOF'
import boto3

def lambda_handler(event, context):
    rds    = boto3.client('rds')
    action = event.get('action', 'stop')

    instances = rds.describe_db_instances()['DBInstances']
    targets   = [
        db for db in instances
        if any(t['Key'] == 'Schedule' and t['Value'] == 'dev-hours'
               for t in db.get('TagList', []))
    ]

    results = []
    for db in targets:
        iid    = db['DBInstanceIdentifier']
        status = db['DBInstanceStatus']
        try:
            if action == 'stop' and status == 'available':
                rds.stop_db_instance(DBInstanceIdentifier=iid)
                results.append(f"Stopped: {iid}")
            elif action == 'start' and status == 'stopped':
                rds.start_db_instance(DBInstanceIdentifier=iid)
                results.append(f"Started: {iid}")
            else:
                results.append(f"Skipped {iid} (status: {status})")
        except Exception as e:
            results.append(f"Error {iid}: {e}")

    return {"action": action, "results": results}
EOF]
▶ Pronounced as: "Now creating the RDS scheduler Lambda function in Python."

109
00:21:00,000 --> 00:21:10,000
[Types: zip /tmp/rds_scheduler.zip /tmp/rds_scheduler.py]
▶ Pronounced as: "Now zipping the Lambda function."

110
00:21:10,000 --> 00:21:20,000
[Types: aws lambda create-function --function-name rds-scheduler --runtime python3.11 --handler rds_scheduler.lambda_handler --zip-file fileb:///tmp/rds_scheduler.zip --role arn:aws:iam::${ACCOUNT_ID}:role/LambdaRDSSchedulerRole]
▶ Pronounced as: "Now creating the Lambda function with AWS Lambda create-function."

111
00:21:20,000 --> 00:21:30,000
Now create the EventBridge rules that trigger the Lambda at the right times:

112
00:21:30,000 --> 00:21:40,000
[Types: aws events put-rule --name "rds-stop-dev" --schedule-expression "cron(0 20 ? * MON-FRI *)" --state ENABLED]
[Types: aws events put-rule --name "rds-start-dev" --schedule-expression "cron(0 7 ? * MON-FRI *)" --state ENABLED]
▶ Pronounced as: "Now creating EventBridge rules for stopping at 8 PM and starting at 7 AM on weekdays."

113
00:21:40,000 --> 00:21:50,000
Now add targets to the rules:

114
00:21:50,000 --> 00:22:00,000
[Types: aws events put-targets --rule rds-stop-dev --targets "Id=1,Arn=arn:aws:lambda:${REGION}:${ACCOUNT_ID}:function:rds-scheduler,Input='{\"action\":\"stop\"}'"]
[Types: aws events put-targets --rule rds-start-dev --targets "Id=1,Arn=arn:aws:lambda:${REGION}:${ACCOUNT_ID}:function:rds-scheduler,Input='{\"action\":\"start\"}'"]
▶ Pronounced as: "Now adding targets to the EventBridge rules with the stop and start actions."

115
00:22:00,000 --> 00:22:10,000
Now tag your dev databases to opt in:

116
00:22:10,000 --> 00:22:20,000
[Types: for db_id in financial-rag-dev riskoracle-dev riskoracle-staging; do aws rds add-tags-to-resource --resource-name $(aws rds describe-db-instances --db-instance-identifier $db_id --query 'DBInstances[0].DBInstanceArn' --output text) --tags Key=Schedule,Value=dev-hours; echo "Scheduled: $db_id"; done]
▶ Pronounced as: "Now tagging dev databases with Schedule=dev-hours to opt in to the scheduler."

117
00:22:20,000 --> 00:22:30,000
Now, look at that output. Each dev database now has the Schedule=dev-hours tag. The Lambda will stop them at 8 PM and start them at 7 AM.

118
00:22:30,000 --> 00:22:40,000
The savings are significant. Three dev databases at $60 each per month is $180 a month. With stop/start, they cost $72 a month. $108 a month saved.

119
00:22:40,000 --> 00:22:50,000
Now let's look at production databases. Production databases run 24/7. You cannot stop them. But you can buy Reserved Instances.

120
00:22:50,000 --> 00:23:00,000
Reserved Instances deliver 40 to 60% savings for a 1-year commitment. Check Cost Explorer's recommendation:

121
00:23:00,000 --> 00:23:10,000
[Types: aws ce get-reservation-purchase-recommendation --service "Amazon RDS" --lookback-period-in-days SIXTY_DAYS --term-in-years ONE_YEAR --payment-option NO_UPFRONT --query 'Recommendations[0].RecommendationDetails[0].[InstanceDetails,EstimatedMonthlySavingsAmount]' --output table]
▶ Pronounced as: "Now getting RDS Reserved Instance purchase recommendations from Cost Explorer."

122
00:23:10,000 --> 00:23:20,000
Now, look at that output. Cost Explorer recommends which instance types to reserve and how many. The estimated savings are shown.

123
00:23:20,000 --> 00:23:30,000
For the startup's production RDS, the recommendation was a db.r6g.large Reserved Instance. On-Demand cost was $210 a month. Reserved Instance cost was $126 a month. $84 a month saved.

124
00:23:30,000 --> 00:23:40,000
Purchase the Reserved Instance:

125
00:23:40,000 --> 00:23:50,000
[Types: OFFERING_ID=$(aws rds describe-reserved-db-instances-offerings --db-instance-class db.r6g.large --product-description postgresql --duration 31536000 --offering-type "No Upfront" --query 'ReservedDBInstancesOfferings[0].ReservedDBInstancesOfferingId' --output text)]
[Types: aws rds purchase-reserved-db-instances-offering --reserved-db-instances-offering-id $OFFERING_ID --reserved-db-instance-id "financial-rag-ri-$(date +%Y%m)" --db-instance-count 1]
▶ Pronounced as: "Now finding the offering ID and purchasing the Reserved Instance."

126
00:23:50,000 --> 00:24:00,000
Now update the baseline document:

127
00:24:00,000 --> 00:24:10,000
[Types: echo "=== SERIES 6: STORAGE & DATABASE RESULTS ===" >> ~/finops-baseline.txt]
[Types: echo "S3 lifecycle policies applied. Projected saving: \$277/month" >> ~/finops-baseline.txt]
[Types: echo "ECR cleanup policies applied. Projected saving: \$92/month" >> ~/finops-baseline.txt]
[Types: echo "RDS dev stop/start schedule enabled. Saving: \$108/month" >> ~/finops-baseline.txt]
[Types: echo "RDS RI purchase pending. Projected saving: \$84/month" >> ~/finops-baseline.txt]
[Types: echo "Total Series 6 saving: \$596/month | \$7,152/year" >> ~/finops-baseline.txt]
[Types: echo "Running bill total: ~\$19,404/month → series 7-10 locks this in permanently" >> ~/finops-baseline.txt]
[Types: echo "" >> ~/finops-baseline.txt]
▶ Pronounced as: "Now appending Series 6 results to the baseline document."

128
00:24:10,000 --> 00:24:20,000
Now let me recap what you built in Series 6.

129
00:24:20,000 --> 00:24:30,000
S3 lifecycle policies on all buckets — both custom policies for specific buckets and standard policies for all unprotected buckets. ECR cleanup policies on all repositories.

130
00:24:30,000 --> 00:24:40,000
RDS stop/start scheduler for dev databases — Lambda function with EventBridge triggers. RDS Reserved Instance for production — purchased and applied.

131
00:24:40,000 --> 00:24:50,000
Total savings: $596 a month. $7,152 a year. All from automation that you set up once.

132
00:24:50,000 --> 00:25:00,000
This is the end of the infrastructure optimization track. Series 7 through 10 build the platform that prevents all this waste from ever returning.

133
00:25:00,000 --> 00:25:10,000
The savings you have achieved are now permanent — as long as you have a platform to enforce them.

134
00:25:10,000 --> 00:25:20,000
See you in Series 7.
```

---

SEGMENT 6: Deep Dive — Understanding S3 Storage Classes
Timestamp: 25:00 – 30:00

```
135
00:25:00,000 --> 00:25:10,000
Welcome to Segment 6. We are going to understand S3 storage classes in detail.

136
00:25:10,000 --> 00:25:20,000
S3 has eight storage classes. Each is designed for a different access pattern. Choosing the right one can save you 90% of your storage costs.

137
00:25:20,000 --> 00:25:30,000
The first is S3 Standard. This is the default. It is for frequently accessed data. It costs $0.023 per GB per month. It has millisecond retrieval. No minimum duration.

138
00:25:30,000 --> 00:25:40,000
The second is S3 Standard-IA. IA stands for Infrequent Access. It is for data accessed less than once a month. It costs $0.0125 per GB per month. Half the cost of Standard. It has a 30-day minimum duration.

139
00:25:40,000 --> 00:25:50,000
The third is S3 One Zone-IA. This is the same as Standard-IA but stored in a single AZ. It costs $0.01 per GB per month. Cheaper but less durable. Use it for replicable data.

140
00:25:50,000 --> 00:26:00,000
The fourth is S3 Glacier Instant Retrieval. This is for archived data that needs millisecond retrieval. It costs $0.004 per GB per month. 17% of Standard. Minimum duration 90 days.

141
00:26:00,000 --> 00:26:10,000
The fifth is S3 Glacier Flexible Retrieval. This is for archived data that can wait minutes to hours. It costs $0.0036 per GB per month. 15% of Standard. Minimum duration 90 days.

142
00:26:10,000 --> 00:26:20,000
The sixth is S3 Glacier Deep Archive. This is for long-term retention. Retrieval takes 12 to 48 hours. It costs $0.00099 per GB per month. 4% of Standard. Minimum duration 180 days.

143
00:26:20,000 --> 00:26:30,000
The seventh is S3 Intelligent-Tiering. This automatically moves data between tiers based on access patterns. It costs $0.0025 per 1,000 objects for monitoring. Use it for unpredictable access patterns.

144
00:26:30,000 --> 00:26:40,000
The eighth is S3 Express One Zone. This is for high-performance workloads. It costs $0.16 per GB per month. Much more expensive. Only use it for latency-sensitive workloads.

145
00:26:40,000 --> 00:26:50,000
The key to cost optimization is matching storage class to access pattern. Most data is accessed frequently only in the first 30 days. After that, it should move to cheaper tiers.

146
00:26:50,000 --> 00:27:00,000
This is exactly what lifecycle policies do. They automate the movement of data between storage classes based on age.

147
00:27:00,000 --> 00:27:10,000
Let me give you a concrete example. A file that is 1 GB in size costs $0.023 per month in Standard. After 30 days, it moves to Standard-IA and costs $0.0125 per month.

148
00:27:10,000 --> 00:27:20,000
After 90 days, it moves to Glacier Instant Retrieval and costs $0.004 per month. After 365 days, it moves to Deep Archive and costs $0.00099 per month.

149
00:27:20,000 --> 00:27:30,000
Over 2 years, the total cost is: 30 days at $0.023 = $0.69. 60 days at $0.0125 = $0.75. 275 days at $0.004 = $1.10. 365 days at $0.00099 = $0.36. Total: $2.90.

150
00:27:30,000 --> 00:27:40,000
If it stayed in Standard for 2 years: $0.023 x 24 = $0.552 per month. Total: $13.25. The difference is 4.5x.

151
00:27:40,000 --> 00:27:50,000
This is the power of lifecycle policies. They automatically move data to the cheapest storage class that meets your access requirements.

152
00:27:50,000 --> 00:28:00,000
Now you understand S3 storage classes. You know which class to use for each access pattern. You know why lifecycle policies are so powerful.

153
00:28:00,000 --> 00:28:10,000
In the next segment, we look at lifecycle policy design patterns.

154
00:28:10,000 --> 00:28:20,000
See you in Segment 7.
```

---

SEGMENT 7: Deep Dive — S3 Lifecycle Policy Design Patterns
Timestamp: 30:00 – 35:00

```
155
00:30:00,000 --> 00:30:10,000
Welcome to Segment 7. We are going to look at lifecycle policy design patterns.

156
00:30:10,000 --> 00:30:20,000
There are three common lifecycle policy patterns. The one you choose depends on your data's access pattern.

157
00:30:20,000 --> 00:30:30,000
Pattern 1 is the standard tiering pattern. This is for data with gradually decreasing access. It moves from Standard to Standard-IA to Glacier to Deep Archive.

158
00:30:30,000 --> 00:30:40,000
This is the pattern we used for the financial-rag logs. It is the most common pattern. It balances cost and access speed.

159
00:30:40,000 --> 00:30:50,000
Pattern 2 is the rapid transition pattern. This is for data that is accessed very rarely. It moves quickly to the cheapest tiers.

160
00:30:50,000 --> 00:31:00,000
For example, backups. Backups are accessed only during disaster recovery. They can be moved to Deep Archive immediately. The transition days would be 0 or very low.

161
00:31:00,000 --> 00:31:10,000
Pattern 3 is the expiration pattern. This is for data that has a fixed retention period. After that period, it is deleted.

162
00:31:10,000 --> 00:31:20,000
For example, logs. Logs older than 12 months are rarely needed. They can be deleted after 365 days. This is what we did with the financial-rag logs.

163
00:31:20,000 --> 00:31:30,000
Here are some design principles for lifecycle policies.

164
00:31:30,000 --> 00:31:40,000
Principle 1: Use object size filters. Never transition objects smaller than 128 KB to IA tiers. The 30-day minimum charge makes it uneconomical.

165
00:31:40,000 --> 00:31:50,000
Principle 2: Use prefix filters. Apply different policies to different prefixes in the same bucket. This is what we did with logs, checkpoints, and filings.

166
00:31:50,000 --> 00:32:00,000
Principle 3: Use abort-incomplete-multipart-upload. This cleans up failed uploads. It is a hidden cost that people forget about.

167
00:32:00,000 --> 00:32:10,000
Principle 4: Test your policies on a sample bucket first. Do not apply a new policy to a bucket with petabytes of data without testing.

168
00:32:10,000 --> 00:32:20,000
Principle 5: Monitor the effect of your policies. Check the S3 metrics to see how much data is transitioning. Adjust your policies based on actual access patterns.

169
00:32:20,000 --> 00:32:30,000
Now let's look at some example policies.

170
00:32:30,000 --> 00:32:40,000
Example 1: Standard tiering for logs. This is the policy we used. It transitions to Standard-IA after 30 days, Glacier after 90 days, Deep Archive after 365 days, and deletes after 730 days.

171
00:32:40,000 --> 00:32:50,000
Example 2: Rapid transition for backups. This transitions to Glacier after 7 days and Deep Archive after 30 days. It never deletes.

172
00:32:50,000 --> 00:33:00,000
Example 3: Expiration for temporary data. This deletes data after 30 days. No transitions. No storage. Just deletion.

173
00:33:00,000 --> 00:33:10,000
Example 4: Intelligent-Tiering for unpredictable access. This automatically moves data between Standard and Glacier based on access patterns.

174
00:33:10,000 --> 00:33:20,000
Now you understand lifecycle policy design patterns. You know which pattern to use for your data.

175
00:33:20,000 --> 00:33:30,000
In the next segment, we look at S3 Intelligent-Tiering — when to use it.

176
00:33:30,000 --> 00:33:40,000
See you in Segment 8.
```

---

SEGMENT 8: S3 Intelligent-Tiering — When to Use It
Timestamp: 35:00 – 40:00

```
177
00:35:00,000 --> 00:35:10,000
Welcome to Segment 8. We are going to look at S3 Intelligent-Tiering.

178
00:35:10,000 --> 00:35:20,000
Intelligent-Tiering is a storage class that automatically moves data between Standard and Glacier based on access patterns.

179
00:35:20,000 --> 00:35:30,000
It is the only storage class that does this automatically. You do not need to define lifecycle policies. S3 does it for you.

180
00:35:30,000 --> 00:35:40,000
When should you use Intelligent-Tiering? When you have unpredictable access patterns. When you do not know when data will be accessed.

181
00:35:40,000 --> 00:35:50,000
For example, data science experiment outputs. You do not know which experiments will be accessed again. Intelligent-Tiering handles this automatically.

182
00:35:50,000 --> 00:36:00,000
Another example: customer uploads. You do not know which files customers will access again. Intelligent-Tiering optimizes the cost automatically.

183
00:36:00,000 --> 00:36:10,000
Intelligent-Tiering has a monitoring cost. It is $0.0025 per 1,000 objects per month. This is the cost of automatic tiering.

184
00:36:10,000 --> 00:36:20,000
If you have 1 million objects, the monitoring cost is $2.50 a month. This is usually worth it if it saves you more than $2.50 in storage costs.

185
00:36:20,000 --> 00:36:30,000
Intelligent-Tiering has three tiers: Frequent Access, Infrequent Access, and Archive Access. The archive tier is equivalent to Glacier.

186
00:36:30,000 --> 00:36:40,000
Objects are automatically moved to Infrequent Access if they are not accessed for 30 days. They are moved to Archive Access if they are not accessed for 90 days.

187
00:36:40,000 --> 00:36:50,000
The retrieval time for Archive Access is milliseconds to minutes. This is faster than Glacier Flexible Retrieval.

188
00:36:50,000 --> 00:37:00,000
To enable Intelligent-Tiering, use the put-bucket-intelligent-tiering-configuration command:

189
00:37:00,000 --> 00:37:10,000
[Types: aws s3api put-bucket-intelligent-tiering-configuration --bucket your-bucket-name --id config1 --intelligent-tiering-configuration '{"Status":"Enabled","Tierings":[{"Days":30,"AccessTier":"ARCHIVE_ACCESS"}]}']
▶ Pronounced as: "Now enabling Intelligent-Tiering on a bucket with Archive Access after 30 days."

190
00:37:10,000 --> 00:37:20,000
This enables Intelligent-Tiering with Archive Access after 30 days. You can also use Deep Archive Access after 180 days.

191
00:37:20,000 --> 00:37:30,000
Intelligent-Tiering is best for buckets with unpredictable access patterns. It is not necessary for buckets with predictable patterns.

192
00:37:30,000 --> 00:37:40,000
For the financial-rag buckets, we used lifecycle policies. The access patterns were predictable. Logs are accessed frequently for 30 days. Checkpoints are accessed during training.

193
00:37:40,000 --> 00:37:50,000
If your access patterns are unpredictable, use Intelligent-Tiering. It will save you money without requiring manual configuration.

194
00:37:50,000 --> 00:38:00,000
Now you understand S3 Intelligent-Tiering. You know when to use it.

195
00:38:00,000 --> 00:38:10,000
In the next segment, we look at ECR lifecycle policy rules in detail.

196
00:38:10,000 --> 00:38:20,000
See you in Segment 9.
```

---

SEGMENT 9: Deep Dive — ECR Lifecycle Policy Rules
Timestamp: 40:00 – 45:00

```
197
00:40:00,000 --> 00:40:10,000
Welcome to Segment 9. We are going to look at ECR lifecycle policy rules in detail.

198
00:40:10,000 --> 00:40:20,000
ECR lifecycle policies define which images to keep and which to delete. They are the only way to keep your ECR costs under control.

199
00:40:20,000 --> 00:40:30,000
There are three types of rules. The first is the untagged images rule. This deletes images that do not have any tags.

200
00:40:30,000 --> 00:40:40,000
Untagged images are usually left over from CI/CD builds. They are never used. They just sit there costing money. Delete them after 14 days.

201
00:40:40,000 --> 00:40:50,000
```json
{
  "rulePriority": 1,
  "description": "Delete untagged images after 14 days",
  "selection": {
    "tagStatus": "untagged",
    "countType": "sinceImagePushed",
    "countUnit": "days",
    "countNumber": 14
  },
  "action": {"type": "expire"}
}
```

202
00:40:50,000 --> 00:41:00,000
The second is the image count rule. This keeps a maximum number of images per repository. It keeps the most recent images.

203
00:41:00,000 --> 00:41:10,000

```json
{
  "rulePriority": 2,
  "description": "Keep only 20 most recent images",
  "selection": {
    "tagStatus": "any",
    "countType": "imageCountMoreThan",
    "countNumber": 20
  },
  "action": {"type": "expire"}
}
```

204
00:41:10,000 --> 00:41:20,000
The third is the tag prefix rule. This keeps a maximum number of images for each tag prefix. It keeps the most recent images for each prefix.

205
00:41:20,000 --> 00:41:30,000

```json
{
  "rulePriority": 3,
  "description": "Keep 5 most recent images per prefix",
  "selection": {
    "tagStatus": "tagged",
    "tagPrefixList": ["v", "release", "prod"],
    "countType": "imageCountMoreThan",
    "countNumber": 5
  },
  "action": {"type": "expire"}
}
```

206
00:41:30,000 --> 00:41:40,000
The tag prefix rule is useful for images with version tags. It keeps the most recent versions of each major version.

207
00:41:40,000 --> 00:41:50,000
The rule priority determines the order of evaluation. Lower numbers are evaluated first. The first matching rule is applied.

208
00:41:50,000 --> 00:42:00,000
In the policy we used, untagged images are evaluated first (priority 1). Then tag prefix rules (priority 2). Then the general image count (priority 3).

209
00:42:00,000 --> 00:42:10,000
This means untagged images are deleted first. Then images with old version tags are deleted. Then the oldest images are deleted.

210
00:42:10,000 --> 00:42:20,000
The count type can be "sinceImagePushed" or "imageCountMoreThan". "sinceImagePushed" uses time. "imageCountMoreThan" uses count.

211
00:42:20,000 --> 00:42:30,000
"sinceImagePushed" is good for untagged images. Delete images older than 14 days. "imageCountMoreThan" is good for tagged images. Keep only 20 most recent.

212
00:42:30,000 --> 00:42:40,000
Now let's look at a complete ECR lifecycle policy:

213
00:42:40,000 --> 00:42:50,000

```json
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Delete untagged images after 14 days",
      "selection": {
        "tagStatus": "untagged",
        "countType": "sinceImagePushed",
        "countUnit": "days",
        "countNumber": 14
      },
      "action": {"type": "expire"}
    },
    {
      "rulePriority": 2,
      "description": "Keep last 5 images per version prefix",
      "selection": {
        "tagStatus": "tagged",
        "tagPrefixList": ["v", "release", "prod"],
        "countType": "imageCountMoreThan",
        "countNumber": 5
      },
      "action": {"type": "expire"}
    },
    {
      "rulePriority": 3,
      "description": "Keep last 20 images total",
      "selection": {
        "tagStatus": "any",
        "countType": "imageCountMoreThan",
        "countNumber": 20
      },
      "action": {"type": "expire"}
    }
  ]
}
```

214
00:42:50,000 --> 00:43:00,000
This policy keeps ECR costs low. Untagged images are deleted after 14 days. Only 5 images per version prefix are kept. Only 20 images total are kept.

215
00:43:00,000 --> 00:43:10,000
Apply this policy to all your repositories. It will save you 80% of your ECR costs. In the startup's account, it saved $92 a month.

216
00:43:10,000 --> 00:43:20,000
Now you understand ECR lifecycle policy rules. You know how to keep your ECR costs under control.

217
00:43:20,000 --> 00:43:30,000
In the next segment, we look at ECR repository scanning and security.

218
00:43:30,000 --> 00:43:40,000
See you in Segment 10.

```

---

**SEGMENT 10: ECR Repository Scanning & Security**
*Timestamp: 45:00 – 50:00*

```

219
00:45:00,000 --> 00:45:10,000
Welcome to Segment 10. We are going to look at ECR repository scanning and security.

220
00:45:10,000 --> 00:45:20,000
ECR has built-in image scanning. It scans images for vulnerabilities. It is enabled at the repository level.

221
00:45:20,000 --> 00:45:30,000
There are two scanning options: basic scanning and enhanced scanning. Basic scanning is free. Enhanced scanning costs $0.01 per image scan.

222
00:45:30,000 --> 00:45:40,000
Basic scanning uses the Common Vulnerabilities and Exposures database. It scans on image push. It does not scan old images again.

223
00:45:40,000 --> 00:45:50,000
Enhanced scanning uses Amazon Inspector. It scans on image push and continuously. It finds more vulnerabilities.

224
00:45:50,000 --> 00:46:00,000
Enable scanning on all repositories:

225
00:46:00,000 --> 00:46:10,000
[Types: aws ecr put-image-scanning-configuration --repository-name your-repository --image-scanning-configuration scanOnPush=true]
▶ Pronounced as: "Now enabling image scanning on a repository."

226
00:46:10,000 --> 00:46:20,000
Check scan results:

227
00:46:20,000 --> 00:46:30,000
[Types: aws ecr describe-image-scan-findings --repository-name your-repository --image-id imageTag=latest]
▶ Pronounced as: "Now checking scan findings for the latest image."

228
00:46:30,000 --> 00:46:40,000
This shows you the vulnerabilities found in the image. You can use this to improve your security posture.

229
00:46:40,000 --> 00:46:50,000
Another important security practice is limiting repository access. Use IAM policies to restrict who can push and pull images.

230
00:46:50,000 --> 00:47:00,000

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {"AWS": "arn:aws:iam::123456789012:role/CI"},
      "Action": ["ecr:GetAuthorizationToken", "ecr:BatchCheckLayerAvailability", "ecr:PutImage"],
      "Resource": "*"
    }
  ]
}
```

231
00:47:00,000 --> 00:47:10,000
This allows only the CI role to push images. No other user can push. This prevents accidental pushes from developers.

232
00:47:10,000 --> 00:47:20,000
Also limit who can pull images. Only the cluster nodes should be able to pull images. Use the same IAM policy approach.

233
00:47:20,000 --> 00:47:30,000
Now let's look at image immutability. This prevents images from being overwritten. It is useful for security and reproducibility.

234
00:47:30,000 --> 00:47:40,000
[Types: aws ecr put-image-tag-mutability --repository-name your-repository --image-tag-mutability IMMUTABLE]
▶ Pronounced as: "Now enabling image immutability on a repository."

235
00:47:40,000 --> 00:47:50,000
With immutability enabled, you cannot push an image with a tag that already exists. This prevents accidental overwrites.

236
00:47:50,000 --> 00:48:00,000
Now let's look at ECR repository encryption. Encryption is enabled by default. But you can choose between AWS managed and customer managed keys.

237
00:48:00,000 --> 00:48:10,000
[Types: aws ecr put-encryption-configuration --repository-name your-repository --encryption-configuration encryptionType=KMS,kmsKey=arn:aws:kms:us-east-1:123456789012:key/your-key-id]
▶ Pronounced as: "Now setting customer-managed KMS encryption on a repository."

238
00:48:10,000 --> 00:48:20,000
Customer managed keys give you more control. You can rotate them and control access. But they cost $1 per month per key.

239
00:48:20,000 --> 00:48:30,000
Now you understand ECR repository scanning and security. You know how to keep your ECR images secure.

240
00:48:30,000 --> 00:48:40,000
In the next segment, we look at RDS instance types and pricing.

241
00:48:40,000 --> 00:48:50,000
See you in Segment 11.

```

---

**SEGMENT 11: Deep Dive — RDS Instance Types & Pricing**
*Timestamp: 50:00 – 55:00*

```

242
00:50:00,000 --> 00:50:10,000
Welcome to Segment 11. We are going to look at RDS instance types and pricing.

243
00:50:10,000 --> 00:50:20,000
RDS instance types are the same as EC2 instance types. They come in different families and sizes. Each has a different price.

244
00:50:20,000 --> 00:50:30,000
The instance family determines the CPU and memory architecture. The size determines the amount of CPU and memory.

245
00:50:30,000 --> 00:50:40,000
The most common families are: db.t4g (burstable, Graviton), db.t3 (burstable, Intel), db.m6g (general purpose, Graviton), db.m6i (general purpose, Intel), db.r6g (memory optimized, Graviton).

246
00:50:40,000 --> 00:50:50,000
Graviton instances are ARM-based. They are 20% cheaper than Intel instances. They are recommended for most workloads.

247
00:50:50,000 --> 00:51:00,000
The t families are burstable. They have a baseline CPU and can burst above it. They are good for low utilisation workloads. They are cheaper than the m families.

248
00:51:00,000 --> 00:51:10,000
The m families are general purpose. They have consistent CPU performance. They are good for most workloads. They are more expensive than t families.

249
00:51:10,000 --> 00:51:20,000
The r families are memory optimized. They have more memory per CPU. They are good for in-memory databases like Redis. They are more expensive than m families.

250
00:51:20,000 --> 00:51:30,000
Here is a comparison of some common instance types in us-east-1:

251
00:51:30,000 --> 00:51:40,000
db.t4g.micro: $0.016 per hour, $11.68 per month. 2 vCPU, 1 GB RAM. Good for small dev databases.

252
00:51:40,000 --> 00:51:50,000
db.t4g.small: $0.032 per hour, $23.36 per month. 2 vCPU, 2 GB RAM. Good for dev and staging.

253
00:51:50,000 --> 00:52:00,000
db.m6g.large: $0.144 per hour, $105.12 per month. 2 vCPU, 8 GB RAM. Good for production workloads.

254
00:52:00,000 --> 00:52:10,000
db.r6g.large: $0.192 per hour, $140.16 per month. 2 vCPU, 16 GB RAM. Good for memory-intensive production workloads.

255
00:52:10,000 --> 00:52:20,000
The cost difference between instance types can be significant. Choose the right instance type for your workload.

256
00:52:20,000 --> 00:52:30,000
For dev databases, use t4g.micro or t4g.small. For staging, use t4g.small or t4g.medium. For production, use m6g.large or r6g.large.

257
00:52:30,000 --> 00:52:40,000
Now let's look at how to choose the right instance type.

258
00:52:40,000 --> 00:52:50,000
First, look at your current utilisation. Check the RDS Performance Insights dashboard. It shows CPU, memory, and I/O usage.

259
00:52:50,000 --> 00:53:00,000
If your CPU utilisation is below 20%, you are overprovisioned. Move to a smaller instance type.

260
00:53:00,000 --> 00:53:10,000
If your CPU utilisation is above 80%, you are underprovisioned. Move to a larger instance type.

261
00:53:10,000 --> 00:53:20,000
If your memory utilisation is above 90%, you are underprovisioned. Move to a larger instance type or switch to the r family.

262
00:53:20,000 --> 00:53:30,000
Now let's look at how to change the instance type.

263
00:53:30,000 --> 00:53:40,000
[Types: aws rds modify-db-instance --db-instance-identifier your-database --db-instance-class db.m6g.large --apply-immediately]
▶ Pronounced as: "Now modifying an RDS instance to change its instance type immediately."

264
00:53:40,000 --> 00:53:50,000
This changes the instance type immediately. There is downtime during the change. Plan for a maintenance window.

265
00:53:50,000 --> 00:54:00,000
You can also schedule the change during the next maintenance window:

266
00:54:00,000 --> 00:54:10,000
[Types: aws rds modify-db-instance --db-instance-identifier your-database --db-instance-class db.m6g.large --no-apply-immediately]
▶ Pronounced as: "Now scheduling the instance type change during the next maintenance window."

267
00:54:10,000 --> 00:54:20,000
Now you understand RDS instance types and pricing. You know how to choose the right instance type.

268
00:54:20,000 --> 00:54:30,000
In the next segment, we look at RDS Performance Insights and cost optimization.

269
00:54:30,000 --> 00:54:40,000
See you in Segment 12.

```

---

**SEGMENT 12: RDS Performance Insights & Cost Optimization**
*Timestamp: 55:00 – 60:00*

```

270
00:55:00,000 --> 00:55:10,000
Welcome to Segment 12. We are going to look at RDS Performance Insights and cost optimization.

271
00:55:10,000 --> 00:55:20,000
Performance Insights is a free feature of RDS. It shows you the top SQL queries, top users, and top wait events.

272
00:55:20,000 --> 00:55:30,000
It helps you identify performance issues that affect cost. Slow queries use more CPU and memory. More CPU and memory require larger instances.

273
00:55:30,000 --> 00:55:40,000
Enable Performance Insights when you create or modify a database:

274
00:55:40,000 --> 00:55:50,000
[Types: aws rds modify-db-instance --db-instance-identifier your-database --enable-performance-insights --performance-insights-retention-period 7]
▶ Pronounced as: "Now enabling Performance Insights on an RDS instance."

275
00:55:50,000 --> 00:56:00,000
Performance Insights retains data for 7 days by default. You can extend it to 2 years with a paid subscription.

276
00:56:00,000 --> 00:56:10,000
Now let's look at the top SQL queries. This shows you which queries are consuming the most resources.

277
00:56:10,000 --> 00:56:20,000
[Types: aws rds get-performance-insights-query --db-instance-identifier your-database --group-by "db.sql" --metric "db.load.average" --start-time $(date -d '1 hour ago' -u +%Y-%m-%dT%H:%M:%SZ) --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ)]
▶ Pronounced as: "Now getting top SQL queries from Performance Insights."

278
00:56:20,000 --> 00:56:30,000
This shows you the top SQL queries by load. If you see a query that is consuming a lot of resources, you need to optimize it.

279
00:56:30,000 --> 00:56:40,000
Query optimization can reduce CPU and memory usage. This allows you to use a smaller instance type.

280
00:56:40,000 --> 00:56:50,000
Now let's look at the top wait events. This shows you what the database is waiting for.

281
00:56:50,000 --> 00:57:00,000
[Types: aws rds get-performance-insights-query --db-instance-identifier your-database --group-by "db.wait_event" --metric "db.load.average" --start-time $(date -d '1 hour ago' -u +%Y-%m-%dT%H:%M:%SZ) --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ)]
▶ Pronounced as: "Now getting top wait events from Performance Insights."

282
00:57:00,000 --> 00:57:10,000
Common wait events are: wait/io/table/sql/handler, wait/io/redo, wait/io/log, and wait/lock/metadata.

283
00:57:10,000 --> 00:57:20,000
If you see wait/io/table/sql/handler, the database is waiting on table I/O. This means you need to optimize your queries or add indexes.

284
00:57:20,000 --> 00:57:30,000
If you see wait/io/redo, the database is waiting on redo log I/O. This means you need to increase your storage IOPS.

285
00:57:30,000 --> 00:57:40,000
Now let's look at storage configuration. RDS supports three storage types: gp2, gp3, and io1.

286
00:57:40,000 --> 00:57:50,000
gp2 is the legacy storage type. It has 3 IOPS per GB. It is deprecated. We migrated from gp2 in Series 2.

287
00:57:50,000 --> 00:58:00,000
gp3 is the current storage type. It has 3000 IOPS by default. It is cheaper than gp2. We migrated to gp3 in Series 2.

288
00:58:00,000 --> 00:58:10,000
io1 is provisioned IOPS. It is expensive. Only use it for workloads that need high IOPS.

289
00:58:10,000 --> 00:58:20,000
You can change the storage type of a database:

290
00:58:20,000 --> 00:58:30,000
[Types: aws rds modify-db-instance --db-instance-identifier your-database --storage-type gp3 --iops 3000 --apply-immediately]
▶ Pronounced as: "Now changing the storage type to gp3."

291
00:58:30,000 --> 00:58:40,000
Now you understand RDS Performance Insights and cost optimization. You know how to identify and fix performance issues.

292
00:58:40,000 --> 00:58:50,000
In the next segment, we look at RDS automated backups and snapshot management.

293
00:58:50,000 --> 00:59:00,000
See you in Segment 13.

```

---

**SEGMENT 13: RDS Automated Backups & Snapshot Management**
*Timestamp: 60:00 – 65:00*

```

294
01:00:00,000 --> 01:00:10,000
Welcome to Segment 13. We are going to look at RDS automated backups and snapshot management.

295
01:00:10,000 --> 01:00:20,000
RDS automated backups are enabled by default. They run daily. They retain data for 7 days by default.

296
01:00:20,000 --> 01:00:30,000
Automated backups are stored in S3. You pay for the storage. It costs the same as gp3 storage — $0.08 per GB per month.

297
01:00:30,000 --> 01:00:40,000
The backup storage cost can be significant. A 500 GB database has 500 GB of backup storage. That is $40 a month.

298
01:00:40,000 --> 01:00:50,000
You can reduce backup storage by reducing the retention period. 7 days is usually enough. 35 days is the maximum.

299
01:00:50,000 --> 01:01:00,000
[Types: aws rds modify-db-instance --db-instance-identifier your-database --backup-retention-period 7 --apply-immediately]
▶ Pronounced as: "Now setting backup retention to 7 days."

300
01:01:00,000 --> 01:01:10,000
You can also create manual snapshots. Manual snapshots are kept until you delete them. They cost the same as automated backups.

301
01:01:10,000 --> 01:01:20,000
Manual snapshots are useful for long-term retention. You can keep them for years. They are stored in S3.

302
01:01:20,000 --> 01:01:30,000
Create a manual snapshot:

303
01:01:30,000 --> 01:01:40,000
[Types: aws rds create-db-snapshot --db-instance-identifier your-database --db-snapshot-identifier your-database-snapshot-$(date +%Y%m%d)]
▶ Pronounced as: "Now creating a manual snapshot."

304
01:01:40,000 --> 01:01:50,000
List your manual snapshots:

305
01:01:50,000 --> 01:02:00,000
[Types: aws rds describe-db-snapshots --snapshot-type manual --query 'DBSnapshots[*].[DBSnapshotIdentifier,SnapshotCreateTime,AllocatedStorage]' --output table]
▶ Pronounced as: "Now listing manual snapshots."

306
01:02:00,000 --> 01:02:10,000
Delete old manual snapshots to save cost:

307
01:02:10,000 --> 01:02:20,000
[Types: aws rds delete-db-snapshot --db-snapshot-identifier your-old-snapshot]
▶ Pronounced as: "Now deleting an old manual snapshot."

308
01:02:20,000 --> 01:02:30,000
Now let's look at the backup window. The backup window is the time when automated backups run.

309
01:02:30,000 --> 01:02:40,000
Choose a backup window during low traffic hours. This minimizes performance impact.

310
01:02:40,000 --> 01:02:50,000
[Types: aws rds modify-db-instance --db-instance-identifier your-database --preferred-backup-window "03:00-04:00" --apply-immediately]
▶ Pronounced as: "Now setting the backup window to 3-4 AM."

311
01:02:50,000 --> 01:03:00,000
Now let's look at point-in-time recovery. RDS can restore a database to any point in time within the retention period.

312
01:03:00,000 --> 01:03:10,000
[Types: aws rds restore-db-instance-to-point-in-time --source-db-instance-identifier your-database --target-db-instance-identifier your-database-restored --restore-time 2024-01-15T12:00:00Z]
▶ Pronounced as: "Now performing point-in-time recovery."

313
01:03:10,000 --> 01:03:20,000
Point-in-time recovery is useful for disaster recovery. It is one of the main reasons to keep automated backups.

314
01:03:20,000 --> 01:03:30,000
Now you understand RDS automated backups and snapshot management. You know how to manage backup costs.

315
01:03:30,000 --> 01:03:40,000
In the next segment, we look at RDS Reserved Instance purchase options.

316
01:03:40,000 --> 01:03:50,000
See you in Segment 14.

```

---

**SEGMENT 14: Deep Dive — RDS Reserved Instance Purchase Options**
*Timestamp: 65:00 – 70:00*

```

317
01:05:00,000 --> 01:05:10,000
Welcome to Segment 14. We are going to look at RDS Reserved Instance purchase options.

318
01:05:10,000 --> 01:05:20,000
RDS Reserved Instances are a way to get a discount on your RDS compute costs. You commit to a specific instance type for 1 or 3 years.

319
01:05:20,000 --> 01:05:30,000
The discount is significant — 40% for 1 year and 60% for 3 years. This is the biggest cost optimization you can make for RDS.

320
01:05:30,000 --> 01:05:40,000
There are three payment options: No Upfront, Partial Upfront, and All Upfront.

321
01:05:40,000 --> 01:05:50,000
No Upfront means you pay nothing upfront. You pay a discounted hourly rate. This is the most flexible option.

322
01:05:50,000 --> 01:06:00,000
Partial Upfront means you pay some money upfront. You pay a lower hourly rate. This is cheaper than No Upfront over the term.

323
01:06:00,000 --> 01:06:10,000
All Upfront means you pay all the money upfront. You pay a zero hourly rate. This is the cheapest option over the term.

324
01:06:10,000 --> 01:06:20,000
Here is a comparison for a db.m6g.large in us-east-1:

325
01:06:20,000 --> 01:06:30,000
On-Demand: $0.144 per hour, $105.12 per month. No commitment.

326
01:06:30,000 --> 01:06:40,000
1-year No Upfront: $0.086 per hour, $62.78 per month. 40% discount.

327
01:06:40,000 --> 01:06:50,000
1-year Partial Upfront: $0.077 per hour, $56.21 per month. 46% discount. $200 upfront.

328
01:06:50,000 --> 01:07:00,000
1-year All Upfront: $0.000 per hour, $0.00 per month. 100% discount. $767 upfront. Total: $767 for 12 months = $63.91 per month.

329
01:07:00,000 --> 01:07:10,000
3-year No Upfront: $0.057 per hour, $41.61 per month. 60% discount.

330
01:07:10,000 --> 01:07:20,000
The best option depends on your cash flow and your commitment horizon.

331
01:07:20,000 --> 01:07:30,000
If you have the cash, All Upfront is the cheapest. If you want flexibility, No Upfront is the best.

332
01:07:30,000 --> 01:07:40,000
Now let's look at how to purchase a Reserved Instance.

333
01:07:40,000 --> 01:07:50,000
First, find the offering ID:

334
01:07:50,000 --> 01:08:00,000
[Types: OFFERING_ID=$(aws rds describe-reserved-db-instances-offerings --db-instance-class db.m6g.large --product-description postgresql --duration 31536000 --offering-type "No Upfront" --query 'ReservedDBInstancesOfferings[0].ReservedDBInstancesOfferingId' --output text)]
▶ Pronounced as: "Now finding the Reserved Instance offering ID."

335
01:08:00,000 --> 01:08:10,000
Then purchase it:

336
01:08:10,000 --> 01:08:20,000
[Types: aws rds purchase-reserved-db-instances-offering --reserved-db-instances-offering-id $OFFERING_ID --reserved-db-instance-id "your-ri-$(date +%Y%m)" --db-instance-count 1]
▶ Pronounced as: "Now purchasing the Reserved Instance."

337
01:08:20,000 --> 01:08:30,000
The Reserved Instance is applied automatically. You do not need to do anything else.

338
01:08:30,000 --> 01:08:40,000
One important thing: Reserved Instances are region-specific. They apply only to the region where you buy them.

339
01:08:40,000 --> 01:08:50,000
They are also instance-type-specific. They apply only to the instance type you buy. If you change the instance type, the Reserved Instance does not apply.

340
01:08:50,000 --> 01:09:00,000
This is why you should only buy Reserved Instances for stable workloads. If you are not sure, wait.

341
01:09:00,000 --> 01:09:10,000
Now you understand RDS Reserved Instance purchase options. You know how to save 40-60% on RDS compute costs.

342
01:09:10,000 --> 01:09:20,000
In the next segment, we look at ElastiCache Reserved Nodes.

343
01:09:20,000 --> 01:09:30,000
See you in Segment 15.

```

---

**SEGMENT 15: ElastiCache Reserved Nodes — Cost Optimization**
*Timestamp: 70:00 – 75:00*

```

344
01:10:00,000 --> 01:10:10,000
Welcome to Segment 15. We are going to look at ElastiCache Reserved Nodes.

345
01:10:10,000 --> 01:10:20,000
ElastiCache is the managed Redis and Memcached service from AWS. It is used for caching and session storage.

346
01:10:20,000 --> 01:10:30,000
ElastiCache nodes run 24/7. They cost money all the time. Reserved Nodes can save you 30-40% on your ElastiCache costs.

347
01:10:30,000 --> 01:10:40,000
Reserved Nodes work the same way as RDS Reserved Instances. You commit to a specific node type for 1 or 3 years.

348
01:10:40,000 --> 01:10:50,000
The discount is significant — 30% for 1 year and 45% for 3 years.

349
01:10:50,000 --> 01:11:00,000
There are three payment options: No Upfront, Partial Upfront, and All Upfront. The same as RDS.

350
01:11:00,000 --> 01:11:10,000
Here is a comparison for a cache.r6g.large node in us-east-1:

351
01:11:10,000 --> 01:11:20,000
On-Demand: $0.115 per hour, $83.95 per month. No commitment.

352
01:11:20,000 --> 01:11:30,000
1-year No Upfront: $0.080 per hour, $58.40 per month. 30% discount.

353
01:11:30,000 --> 01:11:40,000
3-year No Upfront: $0.063 per hour, $45.99 per month. 45% discount.

354
01:11:40,000 --> 01:11:50,000
Now let's look at how to purchase a Reserved Node.

355
01:11:50,000 --> 01:12:00,000
First, find the offering ID:

356
01:12:00,000 --> 01:12:10,000
[Types: OFFERING_ID=$(aws elasticache describe-reserved-cache-nodes-offerings --cache-node-type cache.r6g.large --product-description redis --duration 31536000 --offering-type "No Upfront" --query 'ReservedCacheNodesOfferings[0].ReservedCacheNodesOfferingId' --output text)]
▶ Pronounced as: "Now finding the ElastiCache Reserved Node offering ID."

357
01:12:10,000 --> 01:12:20,000
Then purchase it:

358
01:12:20,000 --> 01:12:30,000
[Types: aws elasticache purchase-reserved-cache-nodes-offering --reserved-cache-nodes-offering-id $OFFERING_ID --reserved-cache-node-id "your-ri-$(date +%Y%m)" --cache-node-count 1]
▶ Pronounced as: "Now purchasing the Reserved Node."

359
01:12:30,000 --> 01:12:40,000
The Reserved Node is applied automatically. You do not need to do anything else.

360
01:12:40,000 --> 01:12:50,000
Now let's look at ElastiCache node types. The same principles apply as RDS. Choose the right node type for your workload.

361
01:12:50,000 --> 01:13:00,000
cache.t4g.micro: 2 vCPU, 0.5 GB RAM. $0.016 per hour. For small dev caches.

362
01:13:00,000 --> 01:13:10,000
cache.m6g.large: 2 vCPU, 8 GB RAM. $0.092 per hour. For production caches.

363
01:13:10,000 --> 01:13:20,000
cache.r6g.large: 2 vCPU, 16 GB RAM. $0.115 per hour. For memory-intensive caches.

364
01:13:20,000 --> 01:13:30,000
Choose the node type based on your memory requirements and CPU needs.

365
01:13:30,000 --> 01:13:40,000
Now let's look at how to monitor ElastiCache costs.

366
01:13:40,000 --> 01:13:50,000
[Types: aws ce get-cost-and-usage --time-period Start=$START,End=$END --granularity MONTHLY --metrics BlendedCost --filter '{"Dimensions":{"Key":"SERVICE","Values":["Amazon ElastiCache"]}}' --query 'ResultsByTime[0].Total.BlendedCost.Amount' --output text]
▶ Pronounced as: "Now querying Cost Explorer for ElastiCache costs."

367
01:13:50,000 --> 01:14:00,000
This shows your total ElastiCache cost. You can use this to track your savings from Reserved Nodes.

368
01:14:00,000 --> 01:14:10,000
Now you understand ElastiCache Reserved Nodes. You know how to save 30-45% on your ElastiCache costs.

369
01:14:10,000 --> 01:14:20,000
In the next segment, we look at Terraform enforcement for S3 lifecycle policies.

370
01:14:20,000 --> 01:14:30,000
See you in Segment 16.

```

---

**SEGMENT 16: Deep Dive — ElastiCache Node Types & Pricing**
*Timestamp: 75:00 – 80:00*

```

371
01:15:00,000 --> 01:15:10,000
Welcome to Segment 16. We are going to look at ElastiCache node types and pricing in detail.

372
01:15:10,000 --> 01:15:20,000
ElastiCache has two engines: Redis and Memcached. Redis is more popular. It supports data persistence and complex data structures.

373
01:15:20,000 --> 01:15:30,000
Memcached is simpler. It supports key-value caching only. It is faster than Redis for basic caching.

374
01:15:30,000 --> 01:15:40,000
The node types are the same for both engines. The pricing is the same.

375
01:15:40,000 --> 01:15:50,000
The t4g family is burstable. It is good for low utilisation workloads. It is the cheapest.

376
01:15:50,000 --> 01:16:00,000
The m6g family is general purpose. It is good for most workloads. It is more expensive than t4g.

377
01:16:00,000 --> 01:16:10,000
The r6g family is memory optimized. It has more memory per CPU. It is good for in-memory caching. It is the most expensive.

378
01:16:10,000 --> 01:16:20,000
Here is a detailed pricing comparison for us-east-1:

379
01:16:20,000 --> 01:16:30,000
cache.t4g.micro: $0.016/hr, 2 vCPU, 0.5 GB RAM. Good for dev.

380
01:16:30,000 --> 01:16:40,000
cache.t4g.small: $0.032/hr, 2 vCPU, 1.5 GB RAM. Good for small dev.

381
01:16:40,000 --> 01:16:50,000
cache.t4g.medium: $0.064/hr, 2 vCPU, 3 GB RAM. Good for staging.

382
01:16:50,000 --> 01:17:00,000
cache.m6g.large: $0.092/hr, 2 vCPU, 8 GB RAM. Good for small production.

383
01:17:00,000 --> 01:17:10,000
cache.m6g.xlarge: $0.184/hr, 4 vCPU, 16 GB RAM. Good for medium production.

384
01:17:10,000 --> 01:17:20,000
cache.r6g.large: $0.115/hr, 2 vCPU, 16 GB RAM. Good for memory-intensive.

385
01:17:20,000 --> 01:17:30,000
cache.r6g.xlarge: $0.230/hr, 4 vCPU, 32 GB RAM. Good for large memory workloads.

386
01:17:30,000 --> 01:17:40,000
Now let's look at how to choose the right node type.

387
01:17:40,000 --> 01:17:50,000
First, estimate your memory requirement. The rule of thumb is 50% of your data fits in Redis. So if your data is 10 GB, you need 5 GB of Redis memory.

388
01:17:50,000 --> 01:18:00,000
Add overhead for Redis. The overhead is 20-30% of the total memory. So 5 GB of data requires 6-6.5 GB of Redis memory.

389
01:18:00,000 --> 01:18:10,000
Choose a node type with enough memory. cache.r6g.large has 16 GB. That is enough for 10 GB of data.

390
01:18:10,000 --> 01:18:20,000
Second, estimate your CPU requirement. Redis is single-threaded. It uses one CPU core. The other cores are for OS and overhead.

391
01:18:20,000 --> 01:18:30,000
If you have high throughput, you need a larger node type. cache.m6g.large has 2 vCPU. That is enough for most workloads.

392
01:18:30,000 --> 01:18:40,000
Third, consider using Redis Cluster. Redis Cluster distributes data across multiple nodes. It can handle larger data sets and higher throughput.

393
01:18:40,000 --> 01:18:50,000
Redis Cluster is more expensive. It requires at least 6 nodes. It is worth it for large workloads.

394
01:18:50,000 --> 01:19:00,000
Now you understand ElastiCache node types and pricing. You know how to choose the right node type.

395
01:19:00,000 --> 01:19:10,000
In the next segment, we look at Terraform enforcement for S3 lifecycle policies.

396
01:19:10,000 --> 01:19:20,000
See you in Segment 17.

```

---

**SEGMENT 17: Terraform Enforcement — S3 Lifecycle Policies**
*Timestamp: 80:00 – 85:00*

```

397
01:20:00,000 --> 01:20:10,000
Welcome to Segment 17. We are going to look at Terraform enforcement for S3 lifecycle policies.

398
01:20:10,000 --> 01:20:20,000
Everything you have done manually in this series must be encoded in Terraform. Otherwise, it will drift back.

399
01:20:20,000 --> 01:20:30,000
Terraform is the only way to enforce storage policies at scale. It ensures every new bucket has a lifecycle policy.

400
01:20:30,000 --> 01:20:40,000
Create a Terraform module for S3 buckets:

401
01:20:40,000 --> 01:20:50,000

```hcl
# modules/s3-bucket/main.tf
resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  tags   = var.tags
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    id     = "standard-lifecycle"
    status = "Enabled"

    filter {
      and {
        prefix                   = var.prefix
        object_size_greater_than = 131072
      }
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER_INSTANT_RETRIEVAL"
    }

    transition {
      days          = 365
      storage_class = "DEEP_ARCHIVE"
    }

    expiration {
      days = var.expiration_days
    }
  }

  rule {
    id     = "abort-incomplete-multipart"
    status = "Enabled"

    filter {
      prefix = ""
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}
```

402
01:20:50,000 --> 01:21:00,000
This module creates an S3 bucket with a lifecycle policy. Every bucket created with this module has the policy.

403
01:21:00,000 --> 01:21:10,000
Use the module in your environment:

404
01:21:10,000 --> 01:21:20,000

```hcl
module "financial_rag_documents" {
  source = "./modules/s3-bucket"

  bucket_name = "financial-rag-documents"
  prefix      = "logs/"
  tags = {
    Team    = "financial-rag"
    Service = "document-storage"
  }
}
```

405
01:21:20,000 --> 01:21:30,000
Now every new bucket has a lifecycle policy. The policy is applied when the bucket is created. No manual intervention required.

406
01:21:30,000 --> 01:21:40,000
You can also use Terraform to audit existing buckets. Use the data source to check for lifecycle policies.

407
01:21:40,000 --> 01:21:50,000

```hcl
data "aws_s3_bucket" "all" {
  for_each = local.bucket_names
  bucket   = each.value
}

data "aws_s3_bucket_lifecycle_configuration" "all" {
  for_each = data.aws_s3_bucket.all
  bucket   = each.value.id
}
```

408
01:21:50,000 --> 01:22:00,000
This checks if each bucket has a lifecycle policy. If it does not, you can flag it as non-compliant.

409
01:22:00,000 --> 01:22:10,000
Now you understand Terraform enforcement for S3 lifecycle policies. You know how to prevent drift.

410
01:22:10,000 --> 01:22:20,000
In the next segment, we look at Terraform enforcement for ECR lifecycle policies.

411
01:22:20,000 --> 01:22:30,000
See you in Segment 18.

```

---

**SEGMENT 18: Terraform Enforcement — ECR Lifecycle Policies**
*Timestamp: 85:00 – 90:00*

```

412
01:25:00,000 --> 01:25:10,000
Welcome to Segment 18. We are going to look at Terraform enforcement for ECR lifecycle policies.

413
01:25:10,000 --> 01:25:20,000
ECR lifecycle policies must also be enforced by Terraform. Otherwise, repositories will accumulate old images.

414
01:25:20,000 --> 01:25:30,000
Create a Terraform module for ECR repositories:

415
01:25:30,000 --> 01:25:40,000

```hcl
# modules/ecr-repository/main.tf
resource "aws_ecr_repository" "this" {
  name = var.repository_name
}

resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Delete untagged images after 14 days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 14
        }
        action = { type = "expire" }
      },
      {
        rulePriority = 2
        description  = "Keep last 20 images total"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 20
        }
        action = { type = "expire" }
      }
    ]
  })
}
```

416
01:25:40,000 --> 01:25:50,000
This module creates an ECR repository with a lifecycle policy. Every repository created with this module has the policy.

417
01:25:50,000 --> 01:26:00,000
Use the module in your environment:

418
01:26:00,000 --> 01:26:10,000

```hcl
module "financial_rag_api" {
  source = "./modules/ecr-repository"

  repository_name = "financial-rag-api"
  tags = {
    Team    = "financial-rag"
    Service = "rag-api"
  }
}
```

419
01:26:10,000 --> 01:26:20,000
Now every new repository has a lifecycle policy. The policy is applied when the repository is created. No manual intervention required.

420
01:26:20,000 --> 01:26:30,000
You can also use Terraform to audit existing repositories. Use the data source to check for lifecycle policies.

421
01:26:30,000 --> 01:26:40,000

```hcl
data "aws_ecr_repository" "all" {
  for_each = local.repository_names
  name     = each.value
}

data "aws_ecr_lifecycle_policy" "all" {
  for_each   = data.aws_ecr_repository.all
  repository = each.value.name
}
```

422
01:26:40,000 --> 01:26:50,000
This checks if each repository has a lifecycle policy. If it does not, you can flag it as non-compliant.

423
01:26:50,000 --> 01:27:00,000
Now you understand Terraform enforcement for ECR lifecycle policies. You know how to prevent drift.

424
01:27:00,000 --> 01:27:10,000
In the next segment, we look at Terraform enforcement for RDS configuration.

425
01:27:10,000 --> 01:27:20,000
See you in Segment 19.

```

---

**SEGMENT 19: Terraform Enforcement — RDS Configuration**
*Timestamp: 90:00 – 95:00*

```

426
01:30:00,000 --> 01:30:10,000
Welcome to Segment 19. We are going to look at Terraform enforcement for RDS configuration.

427
01:30:10,000 --> 01:30:20,000
RDS configuration must also be enforced by Terraform. Otherwise, databases will be created without proper tags and configurations.

428
01:30:20,000 --> 01:30:30,000
Create a Terraform module for RDS instances:

429
01:30:30,000 --> 01:30:40,000

```hcl
# modules/rds-instance/main.tf
resource "aws_db_instance" "this" {
  identifier        = var.identifier
  instance_class    = var.instance_class
  engine            = "postgres"
  engine_version    = var.engine_version
  allocated_storage = var.allocated_storage
  storage_type      = var.storage_type  # must be gp3

  backup_retention_period = var.is_production ? 30 : 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:00-sun:05:00"

  performance_insights_enabled          = true
  performance_insights_retention_period = var.is_production ? 7 : 0

  deletion_protection = var.is_production

  tags = merge(var.tags, {
    Schedule = var.is_production ? "always-on" : "dev-hours"
  })
}
```

430
01:30:40,000 --> 01:30:50,000
This module creates an RDS instance with proper configuration. Production databases have deletion protection and longer backup retention.

431
01:30:50,000 --> 01:31:00,000
Dev databases have the Schedule=dev-hours tag. This enables the stop/start scheduler.

432
01:31:00,000 --> 01:31:10,000
Use the module in your environment:

433
01:31:10,000 --> 01:31:20,000

```hcl
module "financial_rag_db" {
  source = "./modules/rds-instance"

  identifier     = "financial-rag-prod"
  instance_class = "db.r6g.large"
  engine_version = "15"
  allocated_storage = 100
  storage_type   = "gp3"

  is_production = true
  tags = {
    Team    = "financial-rag"
    Service = "rag-database"
  }
}
```

434
01:31:20,000 --> 01:31:30,000
Now every new database has the correct configuration. The configuration is applied when the database is created. No manual intervention required.

435
01:31:30,000 --> 01:31:40,000
You can also use Terraform to audit existing databases. Use the data source to check for configuration.

436
01:31:40,000 --> 01:31:50,000

```hcl
data "aws_db_instance" "all" {
  for_each = local.db_identifiers
  db_instance_identifier = each.value
}
```

437
01:31:50,000 --> 01:32:00,000
This checks if each database has the correct configuration. If it does not, you can flag it as non-compliant.

438
01:32:00,000 --> 01:32:10,000
Now you understand Terraform enforcement for RDS configuration. You know how to prevent drift.

439
01:32:10,000 --> 01:32:20,000
In the next segment, we look at OPA policies for storage and database compliance.

440
01:32:20,000 --> 01:32:30,000
See you in Segment 20.

```

---

**SEGMENT 20: OPA Policies for Storage & Database Compliance**
*Timestamp: 95:00 – 100:00*

```

441
01:35:00,000 --> 01:35:10,000
Welcome to Segment 20. We are going to look at OPA policies for storage and database compliance.

442
01:35:10,000 --> 01:35:20,000
OPA — Open Policy Agent — is a policy engine that validates Terraform plans. It prevents non-compliant infrastructure from being deployed.

443
01:35:20,000 --> 01:35:30,000
We used OPA earlier in the course for tagging. We now extend it to storage and database configurations.

444
01:35:30,000 --> 01:35:40,000
Create an OPA policy for S3 buckets:

445
01:35:40,000 --> 01:35:50,000

```rego
# policies/storage.rego
package financial_rag.storage

deny[msg] {
  resource := input.resources[_]
  resource.type == "aws_s3_bucket"
  not has_lifecycle_policy(resource.name)
  msg = sprintf("S3 bucket '%s' has no lifecycle policy", [resource.name])
}

has_lifecycle_policy(bucket_name) {
  resource := input.resources[_]
  resource.type == "aws_s3_bucket_lifecycle_configuration"
  resource.values.bucket == bucket_name
}
```

446
01:35:50,000 --> 01:36:00,000
This policy denies any S3 bucket that does not have a lifecycle policy. The Terraform plan will fail if this condition is met.

447
01:36:00,000 --> 01:36:10,000
Create an OPA policy for ECR repositories:

448
01:36:10,000 --> 01:36:20,000

```rego
# policies/ecr.rego
package financial_rag.ecr

deny[msg] {
  resource := input.resources[_]
  resource.type == "aws_ecr_repository"
  not has_lifecycle_policy(resource.name)
  msg = sprintf("ECR repository '%s' has no lifecycle policy", [resource.name])
}

has_lifecycle_policy(repo_name) {
  resource := input.resources[_]
  resource.type == "aws_ecr_lifecycle_policy"
  resource.values.repository == repo_name
}
```

449
01:36:20,000 --> 01:36:30,000
This policy denies any ECR repository that does not have a lifecycle policy.

450
01:36:30,000 --> 01:36:40,000
Create an OPA policy for RDS instances:

451
01:36:40,000 --> 01:36:50,000

```rego
# policies/rds.rego
package financial_rag.rds

deny[msg] {
  resource := input.resources[_]
  resource.type == "aws_db_instance"
  resource.values.storage_type == "gp2"
  msg = sprintf("RDS instance '%s' uses gp2 storage (must use gp3)", [resource.name])
}

warn[msg] {
  resource := input.resources[_]
  resource.type == "aws_db_instance"
  not resource.values.tags.Schedule
  not contains(resource.name, "prod")
  msg = sprintf("RDS instance '%s' has no Schedule tag", [resource.name])
}
```

452
01:36:50,000 --> 01:37:00,000
This policy denies any RDS instance that uses gp2 storage. It warns if a non-production database does not have the Schedule tag.

453
01:37:00,000 --> 01:37:10,000
Run OPA with your Terraform plan:

454
01:37:10,000 --> 01:37:20,000

```bash
terraform plan -out=tfplan
terraform show -json tfplan > tfplan.json
conftest test tfplan.json --policy policies/
```

455
01:37:20,000 --> 01:37:30,000
This validates your Terraform plan against the OPA policies. If any violations are found, the deployment is blocked.

456
01:37:30,000 --> 01:37:40,000
Now you understand OPA policies for storage and database compliance. You know how to prevent non-compliant infrastructure.

457
01:37:40,000 --> 01:37:50,000
In the next segment, we do a workshop on auditing your storage costs.

458
01:37:50,000 --> 01:38:00,000
See you in Segment 21.

```

---

**SEGMENT 21: Workshop — Auditing Your Storage Costs**
*Timestamp: 100:00 – 105:00*

```

459
01:40:00,000 --> 01:40:10,000
Welcome to Segment 21. This is the storage cost audit workshop.

460
01:40:10,000 --> 01:40:20,000
Run all the audit commands together. This gives you a complete picture of your storage costs.

461
01:40:20,000 --> 01:40:30,000
First, find your most expensive buckets:

462
01:40:30,000 --> 01:40:40,000

```bash
aws s3api list-buckets --query 'Buckets[].Name' --output text | \
  tr '\t' '\n' | while read bucket; do
    size=$(aws s3api list-objects-v2 --bucket $bucket \
      --query 'sum(Contents[].Size)' --output text 2>/dev/null || echo 0)
    size_gb=$(echo "scale=2; ${size:-0} / 1073741824" | bc)
    cost=$(echo "scale=4; $size_gb * 0.023" | bc)
    echo "$bucket | ${size_gb}GB | \$${cost}/month"
done | sort -t'|' -k3 -rn | head -20
```

463
01:40:40,000 --> 01:40:50,000
Second, check which buckets have lifecycle policies:

464
01:40:50,000 --> 01:41:00,000

```bash
aws s3api list-buckets --query 'Buckets[].Name' --output text | \
  tr '\t' '\n' | while read bucket; do
    lc=$(aws s3api get-bucket-lifecycle-configuration --bucket $bucket \
      2>/dev/null | jq '.Rules | length' || echo 0)
    if [ "$lc" = "0" ]; then
      size=$(aws s3 ls --summarize --recursive s3://$bucket 2>/dev/null | \
        grep "Total Size" | awk '{print $3}')
      size_gb=$(echo "scale=1; ${size:-0} / 1073741824" | bc)
      echo "NO LIFECYCLE: $bucket (${size_gb}GB)"
    fi
done
```

465
01:41:00,000 --> 01:41:10,000
Third, check ECR repository sizes:

466
01:41:10,000 --> 01:41:20,000

```bash
aws ecr describe-repositories --query 'repositories[].[repositoryName]' \
  --output text | tr '\t' '\n' | while read repo; do
    count=$(aws ecr list-images --repository-name $repo \
      --query 'length(imageIds)' --output text)
    size=$(aws ecr describe-images --repository-name $repo \
      --query 'sum(imageDetails[].imageSizeInBytes)' --output text 2>/dev/null || echo 0)
    size_gb=$(echo "scale=2; ${size:-0} / 1073741824" | bc)
    cost=$(echo "scale=4; $size_gb * 0.10" | bc)
    echo "$repo | images: $count | ${size_gb}GB | \$${cost}/month"
done
```

467
01:41:20,000 --> 01:41:30,000
Fourth, check RDS database costs:

468
01:41:30,000 --> 01:41:40,000

```bash
aws rds describe-db-instances --query 'DBInstances[].[DBInstanceIdentifier,DBInstanceClass,Engine,AllocatedStorage,DBInstanceStatus]' --output table
```

469
01:41:40,000 --> 01:41:50,000
Fifth, check ElastiCache costs:

470
01:41:50,000 --> 01:42:00,000

```bash
aws elasticache describe-cache-clusters --query 'CacheClusters[].[CacheClusterId,Engine,CacheNodeType,NumCacheNodes,CacheClusterStatus]' --output table
```

471
01:42:00,000 --> 01:42:10,000
Now compile the results. Write down the total storage cost. This is your Series 6 baseline.

472
01:42:10,000 --> 01:42:20,000
Compare this to the Series 6 savings we projected: $596 a month. That is the target.

473
01:42:20,000 --> 01:42:30,000
Now you have a complete picture of your storage costs. You know exactly where to focus.

474
01:42:30,000 --> 01:42:40,000
In the next segment, we do a workshop on database cost optimization.

475
01:42:40,000 --> 01:42:50,000
See you in Segment 22.

```

---

**SEGMENT 22: Workshop — Database Cost Optimization Review**
*Timestamp: 105:00 – 110:00*

```

476
01:45:00,000 --> 01:45:10,000
Welcome to Segment 22. This is the database cost optimization workshop.

477
01:45:10,000 --> 01:45:20,000
Run all the database cost optimization commands together. This gives you a complete picture of your database costs.

478
01:45:20,000 --> 01:45:30,000
First, review RDS instance types:

479
01:45:30,000 --> 01:45:40,000

```bash
aws rds describe-db-instances --query 'DBInstances[].[DBInstanceIdentifier,DBInstanceClass,Engine,AllocatedStorage]' --output table
```

480
01:45:40,000 --> 01:45:50,000
Second, check RDS utilization:

481
01:45:50,000 --> 01:46:00,000

```bash
aws rds describe-db-instances --query 'DBInstances[].DBInstanceArn' \
  --output text | tr '\t' '\n' | while read arn; do
    cpu=$(aws cloudwatch get-metric-statistics --namespace AWS/RDS \
      --metric-name CPUUtilization --dimensions Name=DBInstanceIdentifier,Value=$arn \
      --start-time $(date -d '1 hour ago' -u +%Y-%m-%dT%H:%M:%SZ) \
      --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) --period 3600 --statistics Average \
      --query 'Datapoints[0].Average' --output text 2>/dev/null)
    echo "$arn: CPU $cpu%"
done
```

482
01:46:00,000 --> 01:46:10,000
Third, check RDS storage utilization:

483
01:46:10,000 --> 01:46:20,000

```bash
aws rds describe-db-instances --query 'DBInstances[].[DBInstanceIdentifier,AllocatedStorage,StorageType]' --output table
```

484
01:46:20,000 --> 01:46:30,000
Fourth, check RDS backup retention:

485
01:46:30,000 --> 01:46:40,000

```bash
aws rds describe-db-instances --query 'DBInstances[].[DBInstanceIdentifier,BackupRetentionPeriod]' --output table
```

486
01:46:40,000 --> 01:46:50,000
Fifth, check RDS tags for dev-hour scheduling:

487
01:46:50,000 --> 01:47:00,000

```bash
aws rds describe-db-instances --query 'DBInstances[].[DBInstanceIdentifier,Tags]' --output table
```

488
01:47:00,000 --> 01:47:10,000
Now identify optimization opportunities:

489
01:47:10,000 --> 01:47:20,000

1. Instances with CPU below 20% can be downsized.
2. Instances without dev-hour tags can be scheduled.
3. Production instances can have Reserved Instances.
4. gp2 storage can be migrated to gp3.
5. Databases with long backup retention can be reduced.

490
01:47:20,000 --> 01:47:30,000
Calculate the potential savings:

491
01:47:30,000 --> 01:47:40,000

```bash
echo "=== DATABASE OPTIMIZATION SUMMARY ==="
echo "Instances with CPU below 20%: [count]"
echo "Instances without dev-hour tags: [count]"
echo "Instances using gp2: [count]"
echo "Potential monthly savings: $[amount]"
```

492
01:47:40,000 --> 01:47:50,000
Now you have a complete picture of your database costs. You know exactly where to focus.

493
01:47:50,000 --> 01:48:00,000
In the next segment, we do the Q&A for Series 6.

494
01:48:00,000 --> 01:48:10,000
See you in Segment 23.

```

---

**SEGMENT 23: Series 6 Q&A — Common Questions Answered**
*Timestamp: 110:00 – 115:00*

```

495
01:50:00,000 --> 01:50:10,000
Welcome to Segment 23. This is the Q&A for Series 6.

496
01:50:10,000 --> 01:50:20,000
Question 1: "Do S3 lifecycle policies apply to existing objects?"

497
01:50:20,000 --> 01:50:30,000
Yes. When you apply a lifecycle policy to a bucket, S3 evaluates all existing objects. They are transitioned based on their current age.

498
01:50:30,000 --> 01:50:40,000
It may take up to 24 hours for the first evaluation. After that, transitions happen automatically.

499
01:50:40,000 --> 01:50:50,000
Question 2: "What happens if I need to retrieve data from Deep Archive?"

500
01:50:50,000 --> 01:51:00,000
Deep Archive retrieval takes 12 to 48 hours. You need to initiate a restore request first. The data is then available for 30 days.

501
01:51:00,000 --> 01:51:10,000

```bash
aws s3api restore-object --bucket your-bucket --key your-key --restore-request Days=30
```

502
01:51:10,000 --> 01:51:20,000
Question 3: "Can I use Intelligent-Tiering with lifecycle policies?"

503
01:51:20,000 --> 01:51:30,000
Yes, but they serve different purposes. Intelligent-Tiering moves data between Standard and Glacier based on access. Lifecycle policies move data based on age.

504
01:51:30,000 --> 01:51:40,000
Question 4: "How do I verify the RDS stop/start scheduler is working?"

505
01:51:40,000 --> 01:51:50,000
Check the Lambda logs in CloudWatch. You can also check the RDS instance status after the scheduled times.

506
01:51:50,000 --> 01:52:00,000

```bash
aws rds describe-db-instances --query 'DBInstances[*].[DBInstanceIdentifier,DBInstanceStatus]' --output table
```

507
01:52:00,000 --> 01:52:10,000
Question 5: "What if my dev database is used 24/7?"

508
01:52:10,000 --> 01:52:20,000
Then do not apply the dev-hours tag. The scheduler only affects instances with the tag.

509
01:52:20,000 --> 01:52:30,000
Question 6: "Do Reserved Instances apply to any region?"

510
01:52:30,000 --> 01:52:40,000
No. Reserved Instances are region-specific. They apply only to the region where you buy them.

511
01:52:40,000 --> 01:52:50,000
Question 7: "Can I change the instance type of a Reserved Instance?"

512
01:52:50,000 --> 01:53:00,000
No. Reserved Instances are instance-type-specific. If you change the instance type, the Reserved Instance does not apply.

513
01:53:00,000 --> 01:53:10,000
Question 8: "What is the difference between automated backups and manual snapshots?"

514
01:53:10,000 --> 01:53:20,000
Automated backups run daily. They are automatically deleted after the retention period. Manual snapshots are kept until you delete them.

515
01:53:20,000 --> 01:53:30,000
Automated backups support point-in-time recovery. Manual snapshots do not.

516
01:53:30,000 --> 01:53:40,000
Question 9: "How do I set up Terraform enforcement for these policies?"

517
01:53:40,000 --> 01:53:50,000
Use Terraform modules for all resources. The modules include the lifecycle policies. Use OPA policies to validate the Terraform plans.

518
01:53:50,000 --> 01:54:00,000
Now you have the answers to the most common questions about storage and database cost controls.

519
01:54:00,000 --> 01:54:10,000
In the next segment, we do the knowledge check and look ahead to Series 7.

520
01:54:10,000 --> 01:54:20,000
See you in Segment 24.

```

---

**SEGMENT 24: Series 6 Knowledge Check & Next Steps**
*Timestamp: 115:00 – 120:00*

```

521
01:55:00,000 --> 01:55:10,000
Welcome to Segment 24. This is the knowledge check for Series 6.

522
01:55:10,000 --> 01:55:20,000
Let's test your understanding of Series 6. Answer these questions in your own words.

523
01:55:20,000 --> 01:55:30,000
Question 1: What are the three S3 storage classes and when should you use each?

524
01:55:30,000 --> 01:55:40,000
Question 2: How do S3 lifecycle policies reduce costs?

525
01:55:40,000 --> 01:55:50,000
Question 3: What is the abort-incomplete-multipart rule and why is it important?

526
01:55:50,000 --> 01:56:00,000
Question 4: How does the ECR lifecycle policy keep costs under control?

527
01:56:00,000 --> 01:56:10,000
Question 5: How does the RDS stop/start scheduler work?

528
01:56:10,000 --> 01:56:20,000
Question 6: What is the savings from RDS Reserved Instances?

529
01:56:20,000 --> 01:56:30,000
Question 7: What is the difference between automated backups and manual snapshots?

530
01:56:30,000 --> 01:56:40,000
Question 8: How does Terraform enforcement prevent storage cost drift?

531
01:56:40,000 --> 01:56:50,000
Pause the video. Write down your answers. Then compare them to what you learned.

532
01:56:50,000 --> 01:57:00,000
If you got all eight correct, you understand Series 6. If you missed any, review the relevant segment.

533
01:57:00,000 --> 01:57:10,000
Now let's recap what you built in Series 6.

534
01:57:10,000 --> 01:57:20,000
S3 lifecycle policies on all buckets — both custom and standard. ECR cleanup policies on all repositories. RDS stop/start scheduler for dev databases. RDS Reserved Instance for production. ElastiCache Reserved Nodes. Terraform enforcement for all policies.

535
01:57:20,000 --> 01:57:30,000
Total savings: $596 a month. $7,152 a year. All from automation that you set up once.

536
01:57:30,000 --> 01:57:40,000
Now let's look ahead to Series 7.

537
01:57:40,000 --> 01:57:50,000
Series 7 is the IDP — Internal Developer Platform. The cost optimizations you have made in Series 2 through 6 are all manual. They require ongoing enforcement.

538
01:57:50,000 --> 01:58:00,000
Series 7 through 10 build a platform that encodes all these optimizations into the development workflow. New services are automatically cost-optimized. No manual enforcement required.

539
01:58:00,000 --> 01:58:10,000
Before you start Series 7, verify these four things:

540
01:58:10,000 --> 01:58:20,000
One: S3 lifecycle policies applied. Check with aws s3api get-bucket-lifecycle-configuration.

541
01:58:20,000 --> 01:58:30,000
Two: ECR lifecycle policies applied. Check with aws ecr get-lifecycle-policy.

542
01:58:30,000 --> 01:58:40,000
Three: RDS stop/start scheduler deployed. Check the Lambda function and EventBridge rules.

543
01:58:40,000 --> 01:58:50,000
Four: Baseline document updated with Series 6 savings.

544
01:58:50,000 --> 01:59:00,000
Series 6 is complete. The storage and database costs are now on autopilot.

545
01:59:00,000 --> 01:59:10,000
The running total: Series 2 through 5 saved $11,694 a month. Series 6 adds $596 a month. Total: $12,290 a month. $147,480 a year.

546
01:59:10,000 --> 01:59:20,000
The startup bill has gone from $47,000 to approximately $19,404 a month. That is a $27,596 reduction.

547
01:59:20,000 --> 01:59:30,000
The commands work. The savings are real. You just have to do the work.

548
01:59:30,000 --> 01:59:40,000
Now we move to the platform track. Series 7 begins now.

549
01:59:40,000 --> 01:59:50,000
See you in Series 7.

```