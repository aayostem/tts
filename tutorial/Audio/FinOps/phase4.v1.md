# SERIES 4: Karpenter — Continuous Cost-Aware Autoscaling

## Complete 24-Segment SRT — 2 Hours

---

### SEGMENT 1: Why the Cluster Autoscaler Is Costing You Money
**Timestamp:** 00:00 – 05:00

```
1
00:00:00,000 --> 00:00:10,000
Welcome to Series 4. In Series 2, you found twelve thousand dollars of waste at the account level.

2
00:00:10,000 --> 00:00:20,000
In Series 3, you found another four thousand seven hundred dollars inside the cluster. You have already saved more than seventeen thousand dollars a month.

3
00:00:20,000 --> 00:00:30,000
That is over two hundred thousand dollars a year. But you did it manually. You ran commands. You applied fixes.

4
00:00:30,000 --> 00:00:40,000
What happens when the cluster scales? What happens at three in the morning when traffic spikes? Manual optimization does not work at three in the morning.

5
00:00:40,000 --> 00:00:50,000
That is where Series 4 comes in. Karpenter makes your cluster continuously self-optimizing. It replaces the Cluster Autoscaler entirely.

6
00:00:50,000 --> 00:01:00,000
Let me show you why the Cluster Autoscaler is costing you money. First, it is slow. It adds nodes only after pods fail to schedule.

7
00:01:00,000 --> 00:01:10,000
That process takes four to eight minutes. During those minutes, your users wait or your jobs queue. In a production environment, four minutes is an eternity.

8
00:01:10,000 --> 00:01:20,000
Second, it is rigid. You define one instance type per node group — t3.large. That is it. If t4g.large ARM instances are twenty percent cheaper right now, you cannot use them.

9
00:01:20,000 --> 00:01:30,000
If Spot prices dropped for m6i.xlarge this morning, you cannot benefit. The Cluster Autoscaler has no concept of price optimization. It just launches whatever you configured months ago.

10
00:01:30,000 --> 00:01:40,000
Third, it is slow to remove nodes. The Cluster Autoscaler waits for a node to be underutilised for ten to twenty minutes before removing it.

11
00:01:40,000 --> 00:01:50,000
During that window, you are paying for idle compute. On a busy cluster with frequent scaling events, this idle time compounds into hundreds of dollars per month.

12
00:01:50,000 --> 00:02:00,000
Karpenter solves all three. It was built at AWS specifically because the Cluster Autoscaler could not meet the cost and performance requirements of large-scale Kubernetes.

13
00:02:00,000 --> 00:02:10,000
Karpenter watches the Kubernetes scheduler directly. The moment a pod cannot schedule, Karpenter already knows — in milliseconds. It launches a node in seconds, not minutes.

14
00:02:10,000 --> 00:02:20,000
You give Karpenter a list of instance families. It queries EC2 Spot and On-Demand prices in real time. It picks the cheapest instance type that fits your pods.

15
00:02:20,000 --> 00:02:30,000
Right now, not when you configured the cluster. Karpenter does not wait for underutilisation thresholds. It continuously evaluates whether pods can be packed more tightly.

16
00:02:30,000 --> 00:02:40,000
When they can, it drains a node, moves the pods, and terminates the instance. Karpenter manages the Spot and On-Demand split as a first-class feature.

17
00:02:40,000 --> 00:02:50,000
You define capacity types. Karpenter handles the interruption signals, cordon and drain sequences, and fallback to On-Demand automatically.

18
00:02:50,000 --> 00:03:00,000
Here are the numbers from that startup. After Series 2 and 3, their bill was thirty-four thousand eight hundred dollars a month.

19
00:03:00,000 --> 00:03:10,000
Their compute situation before Karpenter: fifteen t3.large On-Demand nodes. Cluster Autoscaler managing scale-out. Nodes sitting at thirty-five to forty-five percent utilisation most of the time.

20
00:03:10,000 --> 00:03:20,000
Monthly compute cost: four thousand three hundred and twenty dollars. After deploying Karpenter with consolidation and Spot: five to eight nodes — mix of t4g.large Spot and m6i.large On-Demand.

21
00:03:20,000 --> 00:03:30,000
Continuous consolidation removing idle nodes within thirty seconds. Average cluster utilisation: seventy-two percent. Monthly compute cost: one thousand eight hundred and ninety dollars.

22
00:03:30,000 --> 00:03:40,000
Compute savings: two thousand four hundred and thirty dollars a month. Twenty-nine thousand one hundred and sixty dollars a year. From one afternoon of work.

23
00:03:40,000 --> 00:03:50,000
Combined with Series 2 and 3: bill went from forty-seven thousand to twenty thousand dollars. That is the story you will replicate.

24
00:03:50,000 --> 00:04:00,000
Now let me show you how to deploy Karpenter on your own cluster. Before we start, verify your environment.

25
00:04:00,000 --> 00:04:10,000
[Types: kubectl get nodes]
▶ Pronounced as: "Kubectl, get, nodes"

26
00:04:10,000 --> 00:04:20,000
You should see three or more nodes with status Ready. Karpenter requires Kubernetes 1.24 or higher.

27
00:04:20,000 --> 00:04:30,000
[Types: kubectl version --short | grep Server]
▶ Pronounced as: "Kubectl, version, dash, dash, short, pipe, grep, Server"

28
00:04:30,000 --> 00:04:40,000
You should see Server Version v1.24 or higher. If you are on an older version, upgrade your cluster before proceeding.

29
00:04:40,000 --> 00:04:50,000
[Types: echo "Account: $ACCOUNT_ID  Region: $REGION"]
▶ Pronounced as: "Echo, Account, colon, dollar, ACCOUNT, underscore, ID, Region, colon, dollar, REGION"

30
00:04:50,000 --> 00:05:00,000
Now, look at that output. You should see your account ID and region. This confirms your AWS CLI is configured correctly.
```

---

### SEGMENT 2: Removing Cluster Autoscaler & Setting Up IAM
**Timestamp:** 05:00 – 10:00

```
31
00:05:00,000 --> 00:05:10,000
Now let's remove the Cluster Autoscaler. You cannot run Karpenter and the Cluster Autoscaler simultaneously — they will fight over nodes.

32
00:05:10,000 --> 00:05:20,000
[Types: kubectl get deployment cluster-autoscaler -n kube-system 2>/dev/null && echo "Cluster Autoscaler found — must remove before installing Karpenter" || echo "No Cluster Autoscaler found — safe to proceed"]
▶ Pronounced as: "Kubectl, get, deployment, cluster, dash, autoscaler, dash, n, kube, dash, system..."

33
00:05:20,000 --> 00:05:30,000
If you see "Cluster Autoscaler found", you must remove it. If you see "No Cluster Autoscaler found", you are safe to proceed.

34
00:05:30,000 --> 00:05:40,000
[Types: kubectl delete deployment cluster-autoscaler -n kube-system]
▶ Pronounced as: "Kubectl, delete, deployment, cluster, dash, autoscaler, dash, n, kube, dash, system"

35
00:05:40,000 --> 00:05:50,000
[Types: kubectl delete clusterrolebinding cluster-autoscaler]
▶ Pronounced as: "Kubectl, delete, clusterrolebinding, cluster, dash, autoscaler"

36
00:05:50,000 --> 00:06:00,000
[Types: kubectl delete clusterrole cluster-autoscaler]
▶ Pronounced as: "Kubectl, delete, clusterrole, cluster, dash, autoscaler"

37
00:06:00,000 --> 00:06:10,000
[Types: kubectl delete serviceaccount cluster-autoscaler -n kube-system]
▶ Pronounced as: "Kubectl, delete, serviceaccount, cluster, dash, autoscaler, dash, n, kube, dash, system"

38
00:06:10,000 --> 00:06:20,000
Now let's verify the Cluster Autoscaler is removed.

39
00:06:20,000 --> 00:06:30,000
[Types: kubectl get deployment cluster-autoscaler -n kube-system 2>/dev/null || echo "Cluster Autoscaler removed successfully"]
▶ Pronounced as: "Kubectl, get, deployment, cluster, dash, autoscaler..."

40
00:06:30,000 --> 00:06:40,000
Now, look at that output. You should see "Cluster Autoscaler removed successfully". Do not skip this step.

41
00:06:40,000 --> 00:06:50,000
I have seen this cost a client eight thousand dollars in a single weekend from a node thrashing loop. Running both autoscalers simultaneously causes a race condition.

42
00:06:50,000 --> 00:07:00,000
They continuously fight to add and remove the same nodes. Now let's set up the IAM role for Karpenter. Karpenter runs inside your cluster but needs AWS permissions.

43
00:07:00,000 --> 00:07:10,000
[Types: OIDC_ISSUER=$(aws eks describe-cluster --name $CLUSTER_NAME --query "cluster.identity.oidc.issuer" --output text)]
▶ Pronounced as: "O-I-D-C, underscore, ISSUER, equals..."

44
00:07:10,000 --> 00:07:20,000
[Types: OIDC_ID=$(echo $OIDC_ISSUER | sed 's|https://oidc.eks.us-east-1.amazonaws.com/id/||')]
▶ Pronounced as: "O-I-D-C, underscore, ID, equals, echo, dollar, OIDC, underscore, ISSUER..."

45
00:07:20,000 --> 00:07:30,000
[Types: echo "OIDC Issuer: $OIDC_ISSUER"]
[Types: echo "OIDC ID: $OIDC_ID"]

46
00:07:30,000 --> 00:07:40,000
Now, look at that output. We are discovering your cluster's OIDC issuer. This is needed for IAM Roles for Service Accounts.

47
00:07:40,000 --> 00:07:50,000
Now let's create the IAM policy. This policy defines what EC2 actions Karpenter is allowed to perform.

48
00:07:50,000 --> 00:08:00,000
[Types: cat > karpenter-controller-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowScopedEC2InstanceActions",
      "Effect": "Allow",
      "Action": [
        "ec2:RunInstances",
        "ec2:CreateFleet"
      ],
      "Resource": [
        "arn:aws:ec2:$REGION::image/*",
        "arn:aws:ec2:$REGION::snapshot/*",
        "arn:aws:ec2:$REGION:*:spot-instances-request/*",
        "arn:aws:ec2:$REGION:*:security-group/*",
        "arn:aws:ec2:$REGION:*:subnet/*",
        "arn:aws:ec2:$REGION:*:launch-template/*",
        "arn:aws:ec2:$REGION:*:volume/*",
        "arn:aws:ec2:$REGION:*:network-interface/*",
        "arn:aws:ec2:$REGION:*:instance/*"
      ]
    },
    {
      "Sid": "AllowScopedEC2InstanceActionsWithTags",
      "Effect": "Allow",
      "Action": [
        "ec2:RunInstances",
        "ec2:CreateFleet",
        "ec2:CreateLaunchTemplate"
      ],
      "Resource": [
        "arn:aws:ec2:$REGION:*:fleet/*",
        "arn:aws:ec2:$REGION:*:launch-template/*",
        "arn:aws:ec2:$REGION:*:volume/*",
        "arn:aws:ec2:$REGION:*:network-interface/*",
        "arn:aws:ec2:$REGION:*:instance/*",
        "arn:aws:ec2:$REGION:*:spot-instances-request/*"
      ],
      "Condition": {
        "StringEquals": {
          "aws:RequestTag/kubernetes.io/cluster/$CLUSTER_NAME": "owned"
        },
        "StringLike": {
          "aws:RequestTag/karpenter.sh/provisioner-name": "*"
        }
      }
    },
    {
      "Sid": "AllowScopedResourceCreationTagging",
      "Effect": "Allow",
      "Action": "ec2:CreateTags",
      "Resource": [
        "arn:aws:ec2:$REGION:*:fleet/*",
        "arn:aws:ec2:$REGION:*:instance/*",
        "arn:aws:ec2:$REGION:*:volume/*",
        "arn:aws:ec2:$REGION:*:network-interface/*",
        "arn:aws:ec2:$REGION:*:launch-template/*",
        "arn:aws:ec2:$REGION:*:spot-instances-request/*"
      ]
    },
    {
      "Sid": "AllowScopedDeletion",
      "Effect": "Allow",
      "Action": [
        "ec2:TerminateInstances",
        "ec2:DeleteLaunchTemplate"
      ],
      "Resource": "arn:aws:ec2:$REGION:*:instance/*",
      "Condition": {
        "StringLike": {
          "aws:ResourceTag/karpenter.sh/provisioner-name": "*"
        },
        "StringEquals": {
          "aws:ResourceTag/kubernetes.io/cluster/$CLUSTER_NAME": "owned"
        }
      }
    },
    {
      "Sid": "AllowRegionalReadActions",
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeAvailabilityZones",
        "ec2:DescribeImages",
        "ec2:DescribeInstances",
        "ec2:DescribeInstanceTypeOfferings",
        "ec2:DescribeInstanceTypes",
        "ec2:DescribeLaunchTemplates",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSpotPriceHistory",
        "ec2:DescribeSubnets"
      ],
      "Resource": "*"
    },
    {
      "Sid": "AllowSSMReadActions",
      "Effect": "Allow",
      "Action": "ssm:GetParameter",
      "Resource": "arn:aws:ssm:$REGION::parameter/aws/service/*"
    },
    {
      "Sid": "AllowPricingReadActions",
      "Effect": "Allow",
      "Action": "pricing:GetProducts",
      "Resource": "*"
    },
    {
      "Sid": "AllowInterruptionQueueActions",
      "Effect": "Allow",
      "Action": [
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes",
        "sqs:GetQueueUrl",
        "sqs:ReceiveMessage"
      ],
      "Resource": "arn:aws:sqs:$REGION:$ACCOUNT_ID:$CLUSTER_NAME"
    },
    {
      "Sid": "AllowPassingInstanceRole",
      "Effect": "Allow",
      "Action": "iam:PassRole",
      "Resource": "arn:aws:iam::$ACCOUNT_ID:role/KarpenterNodeRole-$CLUSTER_NAME"
    },
    {
      "Sid": "AllowScopedInstanceProfileActions",
      "Effect": "Allow",
      "Action": [
        "iam:AddRoleToInstanceProfile",
        "iam:CreateInstanceProfile",
        "iam:DeleteInstanceProfile",
        "iam:GetInstanceProfile",
        "iam:RemoveRoleFromInstanceProfile",
        "iam:TagInstanceProfile"
      ],
      "Resource": "*"
    },
    {
      "Sid": "AllowAPIServerEndpointDiscovery",
      "Effect": "Allow",
      "Action": "eks:DescribeCluster",
      "Resource": "arn:aws:eks:$REGION:$ACCOUNT_ID:cluster/$CLUSTER_NAME"
    }
  ]
}
EOF]
▶ Pronounced as: "Cat, greater-than, karpenter-controller-policy, dot, json, space, less-than, less-than, EOF..."

49
00:08:00,000 --> 00:08:10,000
This is a comprehensive least-privilege policy. It allows Karpenter to launch and terminate instances, but only for this specific cluster.

50
00:08:10,000 --> 00:08:20,000
[Types: POLICY_ARN=$(aws iam create-policy --policy-name "KarpenterControllerPolicy-$CLUSTER_NAME" --policy-document file://karpenter-controller-policy.json --query 'Policy.Arn' --output text)]
▶ Pronounced as: "POLICY, underscore, ARN, equals..."

51
00:08:20,000 --> 00:08:30,000
[Types: echo "Policy ARN: $POLICY_ARN"]

52
00:08:30,000 --> 00:08:40,000
Now, look at that output. We have created the IAM policy and captured its ARN.

53
00:08:40,000 --> 00:08:50,000
Now let's create the IAM role with IRSA trust policy. This allows the Karpenter service account to assume this role.

54
00:08:50,000 --> 00:09:00,000
[Types: cat > karpenter-trust-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::$ACCOUNT_ID:oidc-provider/oidc.eks.$REGION.amazonaws.com/id/$OIDC_ID"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "oidc.eks.$REGION.amazonaws.com/id/$OIDC_ID:sub": "system:serviceaccount:karpenter:karpenter",
          "oidc.eks.$REGION.amazonaws.com/id/$OIDC_ID:aud": "sts.amazonaws.com"
        }
      }
    }
  ]
}
EOF]
▶ Pronounced as: "Cat, greater-than, karpenter-trust-policy, dot, json..."

55
00:09:00,000 --> 00:09:10,000
[Types: KARPENTER_ROLE_ARN=$(aws iam create-role --role-name "KarpenterControllerRole-$CLUSTER_NAME" --assume-role-policy-document file://karpenter-trust-policy.json --query 'Role.Arn' --output text)]
▶ Pronounced as: "KARPENTER, underscore, ROLE, underscore, ARN, equals..."

56
00:09:10,000 --> 00:09:20,000
[Types: aws iam attach-role-policy --role-name "KarpenterControllerRole-$CLUSTER_NAME" --policy-arn $POLICY_ARN]
▶ Pronounced as: "AWS, I-A-M, attach, role, policy..."

57
00:09:20,000 --> 00:09:30,000
[Types: echo "Karpenter IAM Role: $KARPENTER_ROLE_ARN"]

58
00:09:30,000 --> 00:09:40,000
Now, look at that output. We have created the IAM role and attached the policy.

59
00:09:40,000 --> 00:09:50,000
Now let's create the node IAM role. This is the role that the EC2 instances will assume.

60
00:09:50,000 --> 00:10:00,000
[Types: cat > node-trust-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF]
```

---

### SEGMENT 3: SQS Queue, Subnet Tags, & Installing Karpenter
**Timestamp:** 10:00 – 15:00

```
61
00:10:00,000 --> 00:10:10,000
[Types: aws iam create-role --role-name "KarpenterNodeRole-$CLUSTER_NAME" --assume-role-policy-document file://node-trust-policy.json]
▶ Pronounced as: "AWS, I-A-M, create, role..."

62
00:10:10,000 --> 00:10:20,000
Now let's attach the required managed policies for EKS nodes.

63
00:10:20,000 --> 00:10:30,000
[Types: for policy in AmazonEKSWorkerNodePolicy AmazonEKS_CNI_Policy AmazonEC2ContainerRegistryReadOnly AmazonSSMManagedInstanceCore; do aws iam attach-role-policy --role-name "KarpenterNodeRole-$CLUSTER_NAME" --policy-arn "arn:aws:iam::aws:policy/$policy"; echo "Attached: $policy"; done]
▶ Pronounced as: "For, policy, in... do... AWS, I-A-M, attach, role, policy..."

64
00:10:30,000 --> 00:10:40,000
Now, look at that output. You should see four policies attached. These are the standard EKS node policies.

65
00:10:40,000 --> 00:10:50,000
[Types: aws iam create-instance-profile --instance-profile-name "KarpenterNodeInstanceProfile-$CLUSTER_NAME"]
▶ Pronounced as: "AWS, I-A-M, create, instance, profile..."

66
00:10:50,000 --> 00:11:00,000
[Types: aws iam add-role-to-instance-profile --instance-profile-name "KarpenterNodeInstanceProfile-$CLUSTER_NAME" --role-name "KarpenterNodeRole-$CLUSTER_NAME"]
▶ Pronounced as: "AWS, I-A-M, add, role, to, instance, profile..."

67
00:11:00,000 --> 00:11:10,000
[Types: echo "Node instance profile created"]

68
00:11:10,000 --> 00:11:20,000
Now, look at that output. The node instance profile is created. This is what Karpenter uses to launch nodes.

69
00:11:20,000 --> 00:11:30,000
Now let's create the SQS queue for Spot interruption handling. Karpenter needs this to receive Spot interruption notifications from AWS.

70
00:11:30,000 --> 00:11:40,000
[Types: QUEUE_URL=$(aws sqs create-queue --queue-name $CLUSTER_NAME --attributes '{"MessageRetentionPeriod": "300"}' --query 'QueueUrl' --output text)]
▶ Pronounced as: "QUEUE, underscore, URL, equals..."

71
00:11:40,000 --> 00:11:50,000
[Types: QUEUE_ARN=$(aws sqs get-queue-attributes --queue-url $QUEUE_URL --attribute-names QueueArn --query 'Attributes.QueueArn' --output text)]
▶ Pronounced as: "QUEUE, underscore, ARN, equals..."

72
00:11:50,000 --> 00:12:00,000
[Types: echo "Queue URL: $QUEUE_URL"]
[Types: echo "Queue ARN: $QUEUE_ARN"]

73
00:12:00,000 --> 00:12:10,000
Now, look at that output. We have created the SQS queue and captured its ARN.

74
00:12:10,000 --> 00:12:20,000
[Types: aws sqs set-queue-attributes --queue-url $QUEUE_URL --attributes "{\"Policy\":\"{\\\"Version\\\":\\\"2012-10-17\\\",\\\"Statement\\\":[{\\\"Effect\\\":\\\"Allow\\\",\\\"Principal\\\":{\\\"Service\\\":[\\\"events.amazonaws.com\\\",\\\"sqs.amazonaws.com\\\"]},\\\"Action\\\":\\\"sqs:SendMessage\\\",\\\"Resource\\\":\\\"$QUEUE_ARN\\\"}]}\"}"]
▶ Pronounced as: "AWS, S-Q-S, set, queue, attributes..."

75
00:12:20,000 --> 00:12:30,000
Now let's create the EventBridge rules for Spot interruption and instance events.

76
00:12:30,000 --> 00:12:40,000
[Types: for rule_name in "KarpenterInterruptionQueueRule-SpotInterruption" "KarpenterInterruptionQueueRule-ScheduledChange" "KarpenterInterruptionQueueRule-StateChange"; do case $rule_name in *SpotInterruption*) pattern='{"source":["aws.ec2"],"detail-type":["EC2 Spot Instance Interruption Warning"]}' ;; *ScheduledChange*) pattern='{"source":["aws.health"],"detail-type":["AWS Health Event"]}' ;; *StateChange*) pattern='{"source":["aws.ec2"],"detail-type":["EC2 Instance State-change Notification"]}' ;; esac; RULE_ARN=$(aws events put-rule --name $rule_name --event-pattern "$pattern" --query 'RuleArn' --output text); aws events put-targets --rule $rule_name --targets "Id=1,Arn=$QUEUE_ARN"; echo "Created EventBridge rule: $rule_name"; done]
▶ Pronounced as: "For, rule, underscore, name, in..."

77
00:12:40,000 --> 00:12:50,000
Now, look at that output. You should see three EventBridge rules created. These route Spot interruption warnings to the SQS queue.

78
00:12:50,000 --> 00:13:00,000
Why three hundred second message retention? Spot interruption warnings give you two minutes. By the time Karpenter drains the node and the message is processed, five minutes is plenty.

79
00:13:00,000 --> 00:13:10,000
Now let's tag subnets and security groups. Karpenter discovers subnets and security groups by tag. Without this, it cannot launch nodes.

80
00:13:10,000 --> 00:13:20,000
[Types: VPC_ID=$(aws ec2 describe-vpcs --filters "Name=isDefault,Values=false" --query 'Vpcs[0].VpcId' --output text)]
▶ Pronounced as: "V-P-C, underscore, ID, equals..."

81
00:13:20,000 --> 00:13:30,000
[Types: echo "VPC: $VPC_ID"]

82
00:13:30,000 --> 00:13:40,000
Now, look at that output. We have discovered your VPC ID.

83
00:13:40,000 --> 00:13:50,000
[Types: aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --query 'Subnets[].SubnetId' --output text | tr '\t' '\n' | while read subnet_id; do aws ec2 create-tags --resources $subnet_id --tags "Key=karpenter.sh/discovery,Value=$CLUSTER_NAME"; echo "Tagged subnet: $subnet_id"; done]
▶ Pronounced as: "AWS, E-C-two, describe, subnets..."

84
00:13:50,000 --> 00:14:00,000
Now, look at that output. All private subnets are tagged. Karpenter can now discover them.

85
00:14:00,000 --> 00:14:10,000
[Types: NODE_SG=$(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$VPC_ID" "Name=tag:aws:eks:cluster-name,Values=$CLUSTER_NAME" --query 'SecurityGroups[0].GroupId' --output text)]
▶ Pronounced as: "NODE, underscore, S-G, equals..."

86
00:14:10,000 --> 00:14:20,000
[Types: aws ec2 create-tags --resources $NODE_SG --tags "Key=karpenter.sh/discovery,Value=$CLUSTER_NAME"]
▶ Pronounced as: "AWS, E-C-two, create, tags..."

87
00:14:20,000 --> 00:14:30,000
[Types: echo "Tagged security group: $NODE_SG"]

88
00:14:30,000 --> 00:14:40,000
Now, look at that output. The security group is tagged. Karpenter can now discover it.

89
00:14:40,000 --> 00:14:50,000
Now let's install Karpenter via Helm.

90
00:14:50,000 --> 00:15:00,000
[Types: export KARPENTER_VERSION="v0.37.0"]
[Types: helm repo add karpenter https://charts.karpenter.sh]
[Types: helm repo update]
[Types: helm install karpenter oci://public.ecr.aws/karpenter/karpenter --version "${KARPENTER_VERSION}" --namespace karpenter --create-namespace --set "settings.clusterName=$CLUSTER_NAME" --set "settings.interruptionQueue=$CLUSTER_NAME" --set "serviceAccount.annotations.eks\.amazonaws\.com/role-arn=$KARPENTER_ROLE_ARN" --set controller.resources.requests.cpu=1 --set controller.resources.requests.memory=1Gi --wait]
```

---

### SEGMENT 4: EC2NodeClass & NodePool Configuration
**Timestamp:** 15:00 – 20:00

```
91
00:15:00,000 --> 00:15:10,000
[Types: kubectl get pods -n karpenter]
▶ Pronounced as: "Kubectl, get, pods, dash, n, karpenter"

92
00:15:10,000 --> 00:15:20,000
Now, look at that output. You should see the Karpenter controller pod running. This confirms Karpenter is installed.

93
00:15:20,000 --> 00:15:30,000
Now let's create the EC2NodeClass. This tells Karpenter how to configure the EC2 instances it launches — AMI, subnets, security groups, instance profile.

94
00:15:30,000 --> 00:15:40,000
[Types: cat << EOF | kubectl apply -f -
apiVersion: karpenter.k8s.aws/v1beta1
kind: EC2NodeClass
metadata:
  name: default
spec:
  amiFamily: AL2023
  role: "KarpenterNodeRole-${CLUSTER_NAME}"
  subnetSelectorTerms:
    - tags:
        karpenter.sh/discovery: "${CLUSTER_NAME}"
  securityGroupSelectorTerms:
    - tags:
        karpenter.sh/discovery: "${CLUSTER_NAME}"
  tags:
    Name: "karpenter-node-${CLUSTER_NAME}"
    Environment: production
    ManagedBy: karpenter
    Team: platform
    CostCenter: engineering
    Owner: platform@yourcompany.com
  blockDeviceMappings:
    - deviceName: /dev/xvda
      ebs:
        volumeSize: 100Gi
        volumeType: gp3
        iops: 3000
        throughput: 125
        encrypted: true
        deleteOnTermination: true
  detailedMonitoring: true
EOF]
▶ Pronounced as: "Cat, less-than, less-than, EOF, pipe, kubectl, apply, dash, f, dash"

95
00:15:40,000 --> 00:15:50,000
Let me explain the EC2NodeClass. AMI Family is AL2023 — Amazon Linux 2023. This is the latest Amazon Linux with better security posture than AL2.

96
00:15:50,000 --> 00:16:00,000
Role is the node IAM role we created. Subnet selector and security group selector use the tags we applied earlier. This is how Karpenter discovers your VPC resources.

97
00:16:00,000 --> 00:16:10,000
Tags apply to every node Karpenter launches. Name, Environment, ManagedBy, Team, CostCenter, Owner — all six required tags.

98
00:16:10,000 --> 00:16:20,000
Block device mappings use gp3 with encryption enabled. Always use encrypted volumes for financial services workloads. There is no performance impact for gp3 with encryption.

99
00:16:20,000 --> 00:16:30,000
Now let's create the Application NodePool. This is where you define what instances Karpenter can provision.

100
00:16:30,000 --> 00:16:40,000
[Types: cat << EOF | kubectl apply -f -
apiVersion: karpenter.sh/v1beta1
kind: NodePool
metadata:
  name: application
spec:
  template:
    metadata:
      labels:
        role: application
    spec:
      nodeClassRef:
        apiVersion: karpenter.k8s.aws/v1beta1
        kind: EC2NodeClass
        name: default
      requirements:
        - key: kubernetes.io/arch
          operator: In
          values: ["amd64", "arm64"]
        - key: kubernetes.io/os
          operator: In
          values: ["linux"]
        - key: karpenter.k8s.aws/instance-family
          operator: In
          values: ["m5", "m5a", "m6i", "m6a", "m7i", "m7g", "c5", "c5a", "c6i", "c6a", "c7i", "c7g", "r5", "r5a", "r6i", "r6a", "r7g"]
        - key: karpenter.k8s.aws/instance-size
          operator: In
          values: ["large", "xlarge", "2xlarge", "4xlarge"]
        - key: karpenter.sh/capacity-type
          operator: In
          values: ["on-demand", "spot"]
      taints:
        - key: dedicated
          value: application
          effect: NoSchedule
  limits:
    cpu: "200"
    memory: 800Gi
  disruption:
    consolidationPolicy: WhenUnderutilized
    consolidateAfter: 30s
    expireAfter: 720h
  weight: 100
EOF]
▶ Pronounced as: "Cat, less-than, less-than, EOF, pipe, kubectl, apply, dash, f, dash"

101
00:16:40,000 --> 00:16:50,000
This NodePool includes both amd64 and arm64 architectures. Graviton ARM64 instances save approximately twenty percent compared to x86. The instance families include m5, m6i, m6g, m7g and many more.

102
00:16:50,000 --> 00:17:00,000
Capacity type includes both on-demand and spot. Karpenter will prefer Spot when available. The taint ensures only workloads with the matching toleration schedule here.

103
00:17:00,000 --> 00:17:10,000
Limits prevent runaway scaling. CPU limit is 200 cores. Memory limit is 800 GiB. Disruption policy consolidates when underutilised, with a thirty-second consolidation window.

104
00:17:10,000 --> 00:17:20,000
ExpireAfter is 720 hours — thirty days. This ensures nodes are replaced monthly with the latest AMI. Weight 100 makes this the preferred NodePool.

105
00:17:20,000 --> 00:17:30,000
Now let's create the Ingestion NodePool for batch workloads. This is Spot only.

106
00:17:30,000 --> 00:17:40,000
[Types: cat << EOF | kubectl apply -f -
apiVersion: karpenter.sh/v1beta1
kind: NodePool
metadata:
  name: ingestion
spec:
  template:
    metadata:
      labels:
        role: ingestion
    spec:
      nodeClassRef:
        apiVersion: karpenter.k8s.aws/v1beta1
        kind: EC2NodeClass
        name: default
      requirements:
        - key: karpenter.k8s.aws/instance-family
          operator: In
          values: ["c5", "c5a", "c6i", "c6a", "c6g", "c7i", "c7g"]
        - key: karpenter.k8s.aws/instance-size
          operator: In
          values: ["large", "xlarge", "2xlarge"]
        - key: karpenter.sh/capacity-type
          operator: In
          values: ["spot"]
      taints:
        - key: dedicated
          value: ingestion
          effect: NoSchedule
  limits:
    cpu: "64"
    memory: 256Gi
  disruption:
    consolidationPolicy: WhenEmpty
    consolidateAfter: 5m
    expireAfter: 168h
EOF]
▶ Pronounced as: "Cat, less-than, less-than, EOF, pipe, kubectl, apply, dash, f, dash"

107
00:17:40,000 --> 00:17:50,000
This NodePool uses compute-optimised instance families for ingestion workloads. Capacity type is spot only. Consolidation policy is WhenEmpty — only consolidate when completely empty.

108
00:17:50,000 --> 00:18:00,000
This prevents interrupting in-flight ingestion jobs. ExpireAfter is 168 hours — seven days, because batch workloads are shorter-lived.

109
00:18:00,000 --> 00:18:10,000
Now let's create the GPU NodePool for riskoracle ML workloads.

110
00:18:10,000 --> 00:18:20,000
[Types: cat << EOF | kubectl apply -f -
apiVersion: karpenter.sh/v1beta1
kind: NodePool
metadata:
  name: gpu-ml
spec:
  template:
    metadata:
      labels:
        role: gpu-ml
    spec:
      nodeClassRef:
        apiVersion: karpenter.k8s.aws/v1beta1
        kind: EC2NodeClass
        name: default
      requirements:
        - key: karpenter.k8s.aws/instance-family
          operator: In
          values: ["g4dn", "g5", "p3", "p4d"]
        - key: karpenter.k8s.aws/instance-size
          operator: In
          values: ["xlarge", "2xlarge", "4xlarge", "8xlarge"]
        - key: karpenter.sh/capacity-type
          operator: In
          values: ["spot", "on-demand"]
      taints:
        - key: nvidia.com/gpu
          value: "true"
          effect: NoSchedule
  limits:
    cpu: "128"
    memory: 512Gi
  disruption:
    consolidationPolicy: WhenEmpty
    consolidateAfter: 2m
    expireAfter: 24h
  weight: 10
EOF]
▶ Pronounced as: "Cat, less-than, less-than, EOF, pipe, kubectl, apply, dash, f, dash"

111
00:18:20,000 --> 00:18:30,000
This NodePool uses GPU instance families. Capacity type includes both spot and on-demand. Spot is preferred for training jobs with checkpointing.

112
00:18:30,000 --> 00:18:40,000
Consolidation policy is WhenEmpty — only consolidate when empty. This prevents interrupting active training jobs. Weight is 10 — lower than application NodePool.

113
00:18:40,000 --> 00:18:50,000
Now let's verify all NodePools and the EC2NodeClass are created.

114
00:18:50,000 --> 00:19:00,000
[Types: kubectl get nodepool]
[Types: kubectl get ec2nodeclass]

115
00:19:00,000 --> 00:19:10,000
Now, look at that output. You should see three NodePools — application, ingestion, and gpu-ml. And one EC2NodeClass named default.

116
00:19:10,000 --> 00:19:20,000
Now let's add tolerations to your workloads so they schedule on the correct NodePools.

117
00:19:20,000 --> 00:19:30,000
[Types: kubectl patch deployment financial-rag-agent-api -n financial-rag --type='json' -p='[{"op":"add","path":"/spec/template/spec/tolerations","value":[{"key":"dedicated","operator":"Equal","value":"application","effect":"NoSchedule"}]},{"op":"add","path":"/spec/template/spec/nodeSelector","value":{"role":"application"}}]']
▶ Pronounced as: "Kubectl, patch, deployment, financial-rag-agent-api..."

118
00:19:30,000 --> 00:19:40,000
[Types: kubectl patch deployment llm-ingest -n financial-rag --type='json' -p='[{"op":"add","path":"/spec/template/spec/tolerations","value":[{"key":"dedicated","operator":"Equal","value":"ingestion","effect":"NoSchedule"},{"key":"karpenter.sh/capacity-type","operator":"Equal","value":"spot","effect":"NoSchedule"}]},{"op":"add","path":"/spec/template/spec/nodeSelector","value":{"role":"ingestion"}}]']
▶ Pronounced as: "Kubectl, patch, deployment, llm-ingest..."

119
00:19:40,000 --> 00:19:50,000
[Types: kubectl patch deployment risk-model-trainer -n riskoracle --type='json' -p='[{"op":"add","path":"/spec/template/spec/tolerations","value":[{"key":"nvidia.com/gpu","operator":"Equal","value":"true","effect":"NoSchedule"}]},{"op":"add","path":"/spec/template/spec/nodeSelector","value":{"role":"gpu-ml"}}]']
▶ Pronounced as: "Kubectl, patch, deployment, risk-model-trainer..."

120
00:19:50,000 --> 00:20:00,000
Now, look at that output. Your workloads now have tolerations to schedule on the correct NodePools. This ensures application workloads go to application nodes, ingestion workloads go to Spot nodes, and GPU workloads go to GPU nodes.
```

---

### SEGMENT 5: Spot-Only NodePool, GPU NodePool & Testing Karpenter
**Timestamp:** 20:00 – 25:00

```
121
00:20:00,000 --> 00:20:10,000
Now let's test Karpenter in action. First, test scale-out speed.

122
00:20:10,000 --> 00:20:20,000
[Types: kubectl create deployment burst-test --image=nginx --replicas=20 --namespace=default]
▶ Pronounced as: "Kubectl, create, deployment, burst, dash, test..."

123
00:20:20,000 --> 00:20:30,000
[Types: time kubectl wait --for=condition=available deployment/burst-test --timeout=120s]
▶ Pronounced as: "Time, kubectl, wait..."

124
00:20:30,000 --> 00:20:40,000
Now, look at that output. You should see new nodes appear within thirty to sixty seconds. This is Karpenter. Compared to the four to eight minutes the Cluster Autoscaler needed.

125
00:20:40,000 --> 00:20:50,000
[Types: kubectl get nodes -w &]
▶ Pronounced as: "Kubectl, get, nodes, dash, w, ampersand"

126
00:20:50,000 --> 00:21:00,000
Watch nodes appear in real time. You should see new nodes with the karpenter.sh/capacity-type label. This tells you whether the node is Spot or On-Demand.

127
00:21:00,000 --> 00:21:10,000
[Types: kubectl delete deployment burst-test]
▶ Pronounced as: "Kubectl, delete, deployment, burst, dash, test"

128
00:21:10,000 --> 00:21:20,000
Now let's watch consolidation in action. Scale down to create underutilised nodes.

129
00:21:20,000 --> 00:21:30,000
[Types: kubectl scale deployment financial-rag-agent-api --replicas=1 -n financial-rag]
▶ Pronounced as: "Kubectl, scale, deployment, financial-rag-agent-api..."

130
00:21:30,000 --> 00:21:40,000
[Types: kubectl get nodes -w &]
▶ Pronounced as: "Kubectl, get, nodes, dash, w, ampersand"

131
00:21:40,000 --> 00:21:50,000
[Types: kubectl logs -n karpenter -l app.kubernetes.io/name=karpenter --follow --tail=30 | grep -iE "consolidat|disrupt|terminat"]
▶ Pronounced as: "Kubectl, logs, dash, n, karpenter..."

132
00:21:50,000 --> 00:22:00,000
Now, look at that output. You should see consolidation events in the logs. This is Karpenter at work.

133
00:22:00,000 --> 00:22:10,000
Expected log output during consolidation:
{"level":"INFO","message":"disrupting node(s) for consolidation reason=underutilized"}
{"level":"INFO","message":"cordon triggered","node":"ip-10-0-1-45.ec2.internal"}
{"level":"INFO","message":"taint added","taint":"karpenter.sh/disruption"}
{"level":"INFO","message":"node deleted","node":"ip-10-0-1-45.ec2.internal"}

134
00:22:10,000 --> 00:22:20,000
This is the consolidation process in action. Karpenter cordons the node, adds a taint, drains the pods, and terminates the instance. All within thirty seconds.

135
00:22:20,000 --> 00:22:30,000
Now let's verify Spot node selection. Karpenter should be using Spot instances for low-traffic workloads.

136
00:22:30,000 --> 00:22:40,000
[Types: kubectl get nodes -o custom-columns='NAME:.metadata.name,INSTANCE:.metadata.labels.node\.kubernetes\.io/instance-type,CAPACITY:.metadata.labels.karpenter\.sh/capacity-type,ARCH:.metadata.labels.kubernetes\.io/arch']
▶ Pronounced as: "Kubectl, get, nodes, dash, o, custom, dash, columns..."

137
00:22:40,000 --> 00:22:50,000
Now, look at that output. You should see a mix of capacity types. Some nodes will show "spot", others "on-demand". The arch column should show both "amd64" and "arm64" for Graviton nodes.

138
00:22:50,000 --> 00:23:00,000
Graviton nodes are ARM64 and save approximately twenty percent compared to x86 equivalents. Karpenter is automatically selecting them when available.

139
00:23:00,000 --> 00:23:10,000
Now let's analyze Spot prices in real time. This is what Karpenter uses to make its pricing decisions.

140
00:23:10,000 --> 00:23:20,000
[Types: for instance_type in m6i.large m6i.xlarge m7g.large m7g.xlarge c6i.large c6i.xlarge; do spot_price=$(aws ec2 describe-spot-price-history --instance-types $instance_type --product-descriptions "Linux/UNIX" --start-time $(date -u +"%Y-%m-%dT%H:%M:%SZ") --query 'SpotPriceHistory[0].SpotPrice' --output text 2>/dev/null || echo "N/A"); od_price=$(aws pricing get-products --service-code AmazonEC2 --filters "Type=TERM_MATCH,Field=instanceType,Value=$instance_type" "Type=TERM_MATCH,Field=operatingSystem,Value=Linux" "Type=TERM_MATCH,Field=tenancy,Value=Shared" "Type=TERM_MATCH,Field=location,Value=US East (N. Virginia)" "Type=TERM_MATCH,Field=preInstalledSw,Value=NA" "Type=TERM_MATCH,Field=capacitystatus,Value=Used" --query 'PriceList[0]' --output text 2>/dev/null | python3 -c "import sys,json; d=json.load(sys.stdin); terms=d.get('terms',{}).get('OnDemand',{}); p=list(list(list(terms.values())[0].get('priceDimensions',{}).values())[0].get('pricePerUnit',{}).values())[0]; print(p)" 2>/dev/null || echo "N/A"); if [ "$spot_price" != "N/A" ] && [ "$od_price" != "N/A" ]; then savings=$(echo "scale=0; (1 - $spot_price / $od_price) * 100" | bc 2>/dev/null || echo "?"); echo "$instance_type | OD: \$$od_price/hr | Spot: \$$spot_price/hr | Savings: ${savings}%"; else echo "$instance_type | OD: $od_price/hr | Spot: $spot_price/hr"; fi; done]
▶ Pronounced as: "For, instance, underscore, type, in... do..."

141
00:23:20,000 --> 00:23:30,000
Now, look at that output. You should see a comparison of On-Demand and Spot prices for each instance type. This is the data Karpenter uses to make its decisions.

142
00:23:30,000 --> 00:23:40,000
You will notice that Spot prices are typically sixty to eighty percent cheaper than On-Demand. This is why Karpenter's Spot-native design saves so much money.

143
00:23:40,000 --> 00:23:50,000
Now let's set up PodDisruptionBudgets. This is critical for production safety.

144
00:23:50,000 --> 00:24:00,000
[Types: cat << EOF | kubectl apply -f -
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: financial-rag-api-pdb
  namespace: financial-rag
spec:
  maxUnavailable: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: financial-rag-agent
      app.kubernetes.io/component: api
---
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: financial-rag-agent-pdb
  namespace: financial-rag
spec:
  minAvailable: 2
  selector:
    matchLabels:
      app.kubernetes.io/name: financial-rag-agent
      app.kubernetes.io/component: agent
EOF]
▶ Pronounced as: "Cat, less-than, less-than, EOF, pipe, kubectl, apply, dash, f, dash"

145
00:24:00,000 --> 00:24:10,000
This creates two PodDisruptionBudgets. The API PDB says never take down more than one replica at a time. The Agent PDB says maintain at least two replicas during disruption.

146
00:24:10,000 --> 00:24:20,000
[Types: kubectl get pdb --all-namespaces]
▶ Pronounced as: "Kubectl, get, pdb, dash, dash, all, dash, namespaces"

147
00:24:20,000 --> 00:24:30,000
Now, look at that output. You should see your PDBs with ALLOWED DISRUPTIONS. This confirms Karpenter will respect them.

148
00:24:30,000 --> 00:24:40,000
A critical note about PDBs: setting minAvailable 100% or maxUnavailable 0 blocks all disruption — including Karpenter consolidation and node upgrades.

149
00:24:40,000 --> 00:24:50,000
Set maxUnavailable 1 instead, and ensure you have replicas greater than or equal to two.

150
00:24:50,000 --> 00:25:00,000
Now let's update the baseline document with all our Series 4 findings.
```

---

### SEGMENT 6: Disruption Budgets, Baseline Update & Series 5 Preview
**Timestamp:** 25:00 – 30:00

```
151
00:25:00,000 --> 00:25:10,000
[Types: echo "" >> ~/finops-baseline.txt]
[Types: echo "=== SERIES 4: KARPENTER DEPLOYMENT ===" >> ~/finops-baseline.txt]
[Types: echo "Date: $(date)" >> ~/finops-baseline.txt]
[Types: echo "" >> ~/finops-baseline.txt]

152
00:25:10,000 --> 00:25:20,000
[Types: echo "--- NODE COUNT ---" >> ~/finops-baseline.txt]
[Types: kubectl get nodes --no-headers | wc -l >> ~/finops-baseline.txt]

153
00:25:20,000 --> 00:25:30,000
[Types: echo "--- INSTANCE TYPE DISTRIBUTION ---" >> ~/finops-baseline.txt]
[Types: kubectl get nodes -o json | jq -r '.items[] | .metadata.labels["node.kubernetes.io/instance-type"]' | sort | uniq -c | sort -rn >> ~/finops-baseline.txt]

154
00:25:30,000 --> 00:25:40,000
[Types: echo "--- SPOT VS ON-DEMAND SPLIT ---" >> ~/finops-baseline.txt]
[Types: kubectl get nodes -o json | jq -r '.items[] | .metadata.labels["karpenter.sh/capacity-type"]' | sort | uniq -c >> ~/finops-baseline.txt]

155
00:25:40,000 --> 00:25:50,000
[Types: echo "--- CONSOLIDATION EVENTS (LAST 24H) ---" >> ~/finops-baseline.txt]
[Types: kubectl logs -n karpenter -l app.kubernetes.io/name=karpenter --since=24h 2>/dev/null | grep -c "consolidat" >> ~/finops-baseline.txt]

156
00:25:50,000 --> 00:26:00,000
[Types: echo "--- NODEPOOLS ---" >> ~/finops-baseline.txt]
[Types: kubectl get nodepool -o custom-columns='NAME:.metadata.name,READY:.status.conditions[-1].type' >> ~/finops-baseline.txt]

157
00:26:00,000 --> 00:26:10,000
[Types: cat ~/finops-baseline.txt]

158
00:26:10,000 --> 00:26:20,000
Now let me recap everything you built in Series 4. The entire Karpenter deployment.

159
00:26:20,000 --> 00:26:30,000
You removed the Cluster Autoscaler. You created IAM roles with IRSA. You created the SQS interruption queue. You tagged subnets and security groups.

160
00:26:30,000 --> 00:26:40,000
You installed Karpenter via Helm. You created EC2NodeClass with gp3 and encryption. You created three NodePools — application, ingestion, and GPU.

161
00:26:40,000 --> 00:26:50,000
You added tolerations to your workloads. You tested scale-out speed. You watched consolidation in action. You verified Spot node selection.

162
00:26:50,000 --> 00:27:00,000
You analyzed Spot prices. You created PodDisruptionBudgets. And you updated the baseline document.

163
00:27:00,000 --> 00:27:10,000
Now let me give you the hard-won lessons from running Karpenter in production.

164
00:27:10,000 --> 00:27:20,000
Lesson one: the node group size floor will ruin your consolidation. If your EKS managed node group has minSize three, you will always have three nodes even when Karpenter wants to consolidate to one.

165
00:27:20,000 --> 00:27:30,000
Set minSize zero on your existing node groups after deploying Karpenter. Many teams miss this and wonder why consolidation is not working.

166
00:27:30,000 --> 00:27:40,000
[Types: aws eks update-nodegroup-config --cluster-name $CLUSTER_NAME --nodegroup-name your-existing-node-group --scaling-config minSize=0,maxSize=1,desiredSize=0]
▶ Pronounced as: "AWS, E-K-S, update, nodegroup, config..."

167
00:27:40,000 --> 00:27:50,000
Lesson two: consolidation breaks stateful workloads if you do not set PDBs. Karpenter will drain a node with a StatefulSet pod on it.

168
00:27:50,000 --> 00:28:00,000
If you have only one replica of PostgreSQL or Redis running on that node, it will go down during consolidation. Always set minAvailable one PDBs for all stateful workloads.

169
00:28:00,000 --> 00:28:10,000
Lesson three: the expireAfter setting is your security patch policy. Nodes running ancient AMIs are a security risk. Setting expireAfter seven hundred and twenty hours ensures every node is replaced monthly.

170
00:28:10,000 --> 00:28:20,000
This is automatic. You do not need a maintenance window. Karpenter handles the cordon, drain, launch, delete sequence.

171
00:28:20,000 --> 00:28:30,000
Lesson four: Graviton ARM instances save twenty percent — but test your containers first. Graviton nodes are arm64. If your container images were built only for amd64, they will not run on Graviton nodes.

172
00:28:30,000 --> 00:28:40,000
[Types: docker buildx build --platform linux/amd64,linux/arm64 -t your-ecr-repo/your-image:latest --push .]
▶ Pronounced as: "Docker, buildx, build, dash, dash, platform, linux, slash, amd64, comma, linux, slash, arm64..."

173
00:28:40,000 --> 00:28:50,000
Build multi-arch images. After confirming they work, add arm64 to your NodePool requirement and immediately start saving twenty percent.

174
00:28:50,000 --> 00:29:00,000
Lesson five: the weight field is your traffic management dial. When you have multiple NodePools, Karpenter uses the weight field to preference one over another.

175
00:29:00,000 --> 00:29:10,000
Set production NodePools to weight one hundred and burst or overflow NodePools to weight ten. This ensures normal workloads use your optimized pool, and only burst overflow spills into the secondary pool.

176
00:29:10,000 --> 00:29:20,000
Lesson six: never set CPU limits without understanding the throttling math. With Karpenter consolidating nodes aggressively, pods end up on fewer, denser nodes. CPU contention increases.

177
00:29:20,000 --> 00:29:30,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/metrics' | grep throttled | sort -t= -k2 -rn | head -10]
▶ Pronounced as: "Kubectl, exec, dash, n, kubecost, deploy, slash, kubecost, dash, cost, dash, analyzer..."

178
00:29:30,000 --> 00:29:40,000
Audit your CPU throttling rates after Karpenter consolidation. This is the silent performance killer.

179
00:29:40,000 --> 00:29:50,000
Now let's review the prerequisites before Series 5. You need these verified before moving on.

180
00:29:50,000 --> 00:30:00,000
First: Karpenter running. Check with kubectl get pods -n karpenter. All pods should be Running.
```

---

### SEGMENT 7: Understanding the Karpenter Architecture
**Timestamp:** 30:00 – 35:00

```
181
00:30:00,000 --> 00:30:10,000
Welcome to Segment 7. We are going to understand the Karpenter architecture.

182
00:30:10,000 --> 00:30:20,000
Karpenter is built on the Kubernetes controller pattern. It watches the Kubernetes API server for changes.

183
00:30:20,000 --> 00:30:30,000
When a pod is created that cannot schedule, Karpenter detects it immediately. It then evaluates the NodePools to find the best instance type.

184
00:30:30,000 --> 00:30:40,000
The architecture has four key components. The controller is the main logic engine. The EC2NodeClass defines AWS configuration. The NodePool defines instance selection policies.

185
00:30:40,000 --> 00:30:50,000
The interruption queue handles Spot termination signals. The controller watches the queue and responds to interruptions.

186
00:30:50,000 --> 00:31:00,000
The controller uses a reconciliation loop. It runs continuously. It checks the state of the cluster against the desired state.

187
00:31:00,000 --> 00:31:10,000
If the cluster has fewer nodes than needed, it launches new ones. If it has more nodes than needed, it removes them.

188
00:31:10,000 --> 00:31:20,000
This is the same pattern as other Kubernetes controllers. But Karpenter is optimized for speed and cost.

189
00:31:20,000 --> 00:31:30,000
The speed comes from direct integration with the scheduler. Karpenter does not wait for pods to be pending. It knows about them immediately.

190
00:31:30,000 --> 00:31:40,000
The cost optimization comes from real-time price analysis. Karpenter queries EC2 Spot and On-Demand prices before launching every node.

191
00:31:40,000 --> 00:31:50,000
This is how it chooses the cheapest instance type that fits your pods. Every time, not just when you configured the cluster.

192
00:31:50,000 --> 00:32:00,000
The consolidation controller is a separate component. It runs continuously and evaluates whether pods can be packed more tightly.

193
00:32:00,000 --> 00:32:10,000
When it finds an opportunity, it cordons the node. This marks the node as unschedulable. No new pods will be placed on it.

194
00:32:10,000 --> 00:32:20,000
Then it drains the node. This gracefully terminates the pods. The pods are rescheduled on other nodes.

195
00:32:20,000 --> 00:32:30,000
Finally, it terminates the instance. This is the consolidation cycle. It happens continuously.

196
00:32:30,000 --> 00:32:40,000
The disruption budget we created earlier prevents this from affecting critical workloads. Karpenter respects the disruption budgets.

197
00:32:40,000 --> 00:32:50,000
Now you understand the architecture. The controller, the NodePools, the interruption queue, and the consolidation cycle.

198
00:32:50,000 --> 00:33:00,000
This is why Karpenter is more efficient than the Cluster Autoscaler. It is continuous, not periodic. It is cost-aware, not fixed.

199
00:33:00,000 --> 00:33:10,000
In the next segment, we do a deep dive comparison between Karpenter and the Cluster Autoscaler.

200
00:33:10,000 --> 00:33:20,000
See you in Segment 8.
```

---

### SEGMENT 8: Deep Dive — Karpenter vs Cluster Autoscaler
**Timestamp:** 35:00 – 40:00

```
201
00:35:00,000 --> 00:35:10,000
Welcome to Segment 8. We are going to compare Karpenter and the Cluster Autoscaler.

202
00:35:10,000 --> 00:35:20,000
The Cluster Autoscaler is a vertical scaling tool. It adds nodes when pods fail to schedule. It removes nodes when they are underutilised.

203
00:35:20,000 --> 00:35:30,000
Karpenter is a horizontal scaling tool. It provisions new nodes and removes unused nodes. But it also optimizes instance selection.

204
00:35:30,000 --> 00:35:40,000
The Cluster Autoscaler uses node groups. You define one or more node groups. Each node group has a fixed instance type.

205
00:35:40,000 --> 00:35:50,000
Karpenter uses NodePools. Each NodePool has a set of instance families, sizes, and capacity types. Karpenter selects the best fit.

206
00:35:50,000 --> 00:36:00,000
The Cluster Autoscaler takes four to eight minutes to launch a node. Karpenter takes thirty to sixty seconds.

207
00:36:00,000 --> 00:36:10,000
The Cluster Autoscaler removes nodes after ten to twenty minutes of underutilisation. Karpenter removes nodes within thirty seconds of consolidation opportunity.

208
00:36:10,000 --> 00:36:20,000
The Cluster Autoscaler does not consider Spot prices. It only uses the instance types you configured. Karpenter queries Spot prices in real time.

209
00:36:20,000 --> 00:36:30,000
The Cluster Autoscaler does not handle Spot interruptions. You need separate tooling. Karpenter handles Spot interruptions natively.

210
00:36:30,000 --> 00:36:40,000
The Cluster Autoscaler does not support multiple architectures. You need separate node groups for amd64 and arm64. Karpenter supports both in a single NodePool.

211
00:36:40,000 --> 00:36:50,000
The Cluster Autoscaler has been the standard for years. But Karpenter is the future. It is built by AWS for AWS.

212
00:36:50,000 --> 00:37:00,000
The migration from Cluster Autoscaler to Karpenter is straightforward. You remove the Cluster Autoscaler. You install Karpenter. You define NodePools.

213
00:37:00,000 --> 00:37:10,000
You do not need to change your workload manifests. Karpenter works with standard Kubernetes pods.

214
00:37:10,000 --> 00:37:20,000
The cost savings from Karpenter come from three sources. Faster consolidation reduces idle time. Spot selection reduces compute cost. Graviton selection reduces cost by twenty percent.

215
00:37:20,000 --> 00:37:30,000
In the startup we have been following, the compute cost dropped from four thousand three hundred and twenty dollars to one thousand eight hundred and ninety dollars.

216
00:37:30,000 --> 00:37:40,000
That is a fifty-six percent reduction. Two thousand four hundred and thirty dollars a month. Twenty-nine thousand one hundred and sixty dollars a year.

217
00:37:40,000 --> 00:37:50,000
This is why Karpenter is a critical component of the FinOps toolkit. It is not just a scaling tool. It is a cost optimization tool.

218
00:37:50,000 --> 00:38:00,000
In the next segment, we look at advanced NodePool configuration.

219
00:38:00,000 --> 00:38:10,000
See you in Segment 9.
```

---

### SEGMENT 9: Advanced NodePool Configuration
**Timestamp:** 40:00 – 45:00

```
220
00:40:00,000 --> 00:40:10,000
Welcome to Segment 9. We are going to look at advanced NodePool configuration.

221
00:40:10,000 --> 00:40:20,000
You have seen the basic NodePools. Now let's look at advanced options that give you more control.

222
00:40:20,000 --> 00:40:30,000
The first is topology spread constraints. This controls how pods are spread across availability zones.

223
00:40:30,000 --> 00:40:40,000
[Types: kubectl patch nodepool application --type='merge' -p='{"spec":{"template":{"spec":{"topologySpreadConstraints":[{"maxSkew":1,"topologyKey":"topology.kubernetes.io/zone","whenUnsatisfiable":"DoNotSchedule","labelSelector":{"matchLabels":{"role":"application"}}}]}}}}']
▶ Pronounced as: "Kubectl, patch, nodepool, application..."

224
00:40:40,000 --> 00:40:50,000
This ensures pods are evenly spread across availability zones. It improves availability and reduces cross-AZ data transfer costs.

225
00:40:50,000 --> 00:41:00,000
The second is pod anti-affinity. This prevents pods from scheduling on the same node. It is useful for high-availability services.

226
00:41:00,000 --> 00:41:10,000
[Types: kubectl patch deployment financial-rag-agent-api -n financial-rag --type='json' -p='[{"op":"add","path":"/spec/template/spec/affinity","value":{"podAntiAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":[{"labelSelector":{"matchExpressions":[{"key":"app.kubernetes.io/name","operator":"In","values":["financial-rag-agent"]}]},"topologyKey":"kubernetes.io/hostname"}]}}}]']
▶ Pronounced as: "Kubectl, patch, deployment..."

227
00:41:10,000 --> 00:41:20,000
This ensures two replicas of the same service never land on the same node. It improves availability during node failures.

228
00:41:20,000 --> 00:41:30,000
The third is node affinity. This allows you to prefer or require specific node attributes.

229
00:41:30,000 --> 00:41:40,000
[Types: kubectl patch deployment risk-model-trainer -n riskoracle --type='json' -p='[{"op":"add","path":"/spec/template/spec/affinity","value":{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"weight":80,"preference":{"matchExpressions":[{"key":"node.kubernetes.io/instance-type","operator":"In","values":["g4dn.xlarge","g4dn.2xlarge"]}]}}]}}}]']
▶ Pronounced as: "Kubectl, patch, deployment..."

230
00:41:40,000 --> 00:41:50,000
This prefers g4dn instance types for ML training. It will fall back to other GPU types if g4dn is not available.

231
00:41:50,000 --> 00:42:00,000
The fourth is taints and tolerations. We already covered these. But advanced patterns include using multiple taints for different workloads.

232
00:42:00,000 --> 00:42:10,000
[Types: cat << EOF | kubectl apply -f -
apiVersion: karpenter.sh/v1beta1
kind: NodePool
metadata:
  name: high-memory
spec:
  template:
    spec:
      taints:
        - key: workload
          value: memory-intensive
          effect: NoSchedule
      requirements:
        - key: karpenter.k8s.aws/instance-family
          operator: In
          values: ["r5", "r6i", "r6g", "r7g"]
        - key: karpenter.k8s.aws/instance-size
          operator: In
          values: ["2xlarge", "4xlarge", "8xlarge"]
  weight: 50
EOF]
▶ Pronounced as: "Cat, less-than, less-than, EOF, pipe, kubectl, apply, dash, f, dash"

233
00:42:10,000 --> 00:42:20,000
This NodePool is for memory-intensive workloads. It uses R-family instances with high memory.

234
00:42:20,000 --> 00:42:30,000
The fifth is the consolidation policy. WhenUnderutilized is the default. WhenEmpty is for batch workloads. WhenUnderutilizedWithTaints is for advanced use cases.

235
00:42:30,000 --> 00:42:40,000
[Types: kubectl patch nodepool ingestion --type='merge' -p='{"spec":{"disruption":{"consolidateAfter":"10m"}}}']
▶ Pronounced as: "Kubectl, patch, nodepool, ingestion..."

236
00:42:40,000 --> 00:42:50,000
This increases the consolidation delay for ingestion workloads. It gives batch jobs more time to complete.

237
00:42:50,000 --> 00:43:00,000
The sixth is the expireAfter setting. We set this to 720 hours for application workloads. This is thirty days.

238
00:43:00,000 --> 00:43:10,000
For GPU workloads, we set it to 168 hours. Seven days. This ensures GPU nodes are refreshed weekly.

239
00:43:10,000 --> 00:43:20,000
[Types: kubectl patch nodepool gpu-ml --type='merge' -p='{"spec":{"disruption":{"expireAfter":"168h"}}}']
▶ Pronounced as: "Kubectl, patch, nodepool, gpu-ml..."

240
00:43:20,000 --> 00:43:30,000
Now you have advanced NodePool configuration. Use these to fine-tune Karpenter for your specific workloads.

241
00:43:30,000 --> 00:43:40,000
In the next segment, we look at understanding consolidation in depth.

242
00:43:40,000 --> 00:43:50,000
See you in Segment 10.
```

---

### SEGMENT 10: Understanding Consolidation in Depth
**Timestamp:** 45:00 – 50:00

```
243
00:45:00,000 --> 00:45:10,000
Welcome to Segment 10. We are going to understand consolidation in depth.

244
00:45:10,000 --> 00:45:20,000
Consolidation is Karpenter's most powerful feature. It is what makes the cluster continuously right-sized.

245
00:45:20,000 --> 00:45:30,000
The consolidation controller runs every thirty seconds. It evaluates the entire cluster.

246
00:45:30,000 --> 00:45:40,000
It asks: can I pack the pods more tightly? If yes, it consolidates the nodes.

247
00:45:40,000 --> 00:45:50,000
Consolidation happens in three steps. The first is cordon. The node is marked as unschedulable. No new pods can schedule on it.

248
00:45:50,000 --> 00:46:00,000
The second is drain. The pods on the node are gracefully terminated. Kubernetes ensures they are rescheduled on other nodes.

249
00:46:00,000 --> 00:46:10,000
The third is termination. The EC2 instance is terminated. You stop paying for it immediately.

250
00:46:10,000 --> 00:46:20,000
The consolidation controller uses a scoring algorithm. It calculates the cost of keeping a node versus the cost of moving pods.

251
00:46:20,000 --> 00:46:30,000
If the cost of keeping is higher than the cost of moving, it consolidates. This is how Karpenter makes economic decisions.

252
00:46:30,000 --> 00:46:40,000
The consolidation window is configurable. We set it to thirty seconds. This is aggressive.

253
00:46:40,000 --> 00:46:50,000
Some workloads need a longer consolidation window. Batch jobs need time to complete. We set the ingestion NodePool to five minutes.

254
00:46:50,000 --> 00:47:00,000
[Types: kubectl get events --all-namespaces --field-selector reason=Consolidation --sort-by='.metadata.creationTimestamp' | tail -10]
▶ Pronounced as: "Kubectl, get, events..."

255
00:47:00,000 --> 00:47:10,000
This shows you consolidation events in your cluster. You can see when nodes were removed.

256
00:47:10,000 --> 00:47:20,000
[Types: kubectl logs -n karpenter -l app.kubernetes.io/name=karpenter --since=1h | grep -i consolidate | wc -l]
▶ Pronounced as: "Kubectl, logs, dash, n, karpenter..."

257
00:47:20,000 --> 00:47:30,000
This counts consolidation events in the last hour. A high number means Karpenter is actively optimizing your cluster.

258
00:47:30,000 --> 00:47:40,000
Consolidation can be disruptive if not configured correctly. This is why we create PodDisruptionBudgets.

259
00:47:40,000 --> 00:47:50,000
PDBs tell Karpenter how many pods it can disrupt at once. Karpenter respects these limits.

260
00:47:50,000 --> 00:48:00,000
The consolidation controller is what makes Karpenter continuous. It is not a one-time optimization. It runs forever.

261
00:48:00,000 --> 00:48:10,000
This is why Karpenter is superior to manual rightsizing. Manual rightsizing is a point in time. Karpenter is continuous.

262
00:48:10,000 --> 00:48:20,000
In the next segment, we look at optimizing instance selection for cost.

263
00:48:20,000 --> 00:48:30,000
See you in Segment 11.
```

---

### SEGMENT 11: Optimizing Instance Selection for Cost
**Timestamp:** 50:00 – 55:00

```
264
00:50:00,000 --> 00:50:10,000
Welcome to Segment 11. We are going to optimize instance selection for cost.

265
00:50:10,000 --> 00:50:20,000
Karpenter selects instances based on your NodePool requirements. But you can guide it to make better cost decisions.

266
00:50:20,000 --> 00:50:30,000
The first optimization is instance family selection. Include families that are cost-effective for your workload.

267
00:50:30,000 --> 00:50:40,000
For general purpose workloads, m5, m6i, and m6g are the most cost-effective. m7g is even better but may not be available in all regions.

268
00:50:40,000 --> 00:50:50,000
For compute-intensive workloads, c5, c6i, and c6g are the best. For memory-intensive, r5, r6i, and r6g.

269
00:50:50,000 --> 00:51:00,000
The second optimization is architecture selection. Include arm64. Graviton instances are twenty percent cheaper than x86.

270
00:51:00,000 --> 00:51:10,000
[Types: kubectl patch nodepool application --type='merge' -p='{"spec":{"template":{"spec":{"requirements":[{"key":"kubernetes.io/arch","operator":"In","values":["amd64","arm64"]}]}}}}']
▶ Pronounced as: "Kubectl, patch, nodepool, application..."

271
00:51:10,000 --> 00:51:20,000
This enables Graviton instances. But you must build multi-arch containers. Otherwise your pods will not run on Graviton.

272
00:51:20,000 --> 00:51:30,000
The third optimization is Spot preference. Spot instances are sixty to eighty percent cheaper than On-Demand.

273
00:51:30,000 --> 00:51:40,000
[Types: kubectl patch nodepool application --type='merge' -p='{"spec":{"template":{"spec":{"requirements":[{"key":"karpenter.sh/capacity-type","operator":"In","values":["spot","on-demand"]}]}}}}']
▶ Pronounced as: "Kubectl, patch, nodepool, application..."

274
00:51:40,000 --> 00:51:50,000
Karpenter will prefer Spot because it is cheaper. But it will fall back to On-Demand if Spot is unavailable.

275
00:51:50,000 --> 00:52:00,000
The fourth optimization is instance size. Exclude very small instances. They are not cost-effective for production workloads.

276
00:52:00,000 --> 00:52:10,000
[Types: kubectl patch nodepool application --type='merge' -p='{"spec":{"template":{"spec":{"requirements":[{"key":"karpenter.k8s.aws/instance-size","operator":"NotIn","values":["nano","micro","small","medium"]}]}}}}']
▶ Pronounced as: "Kubectl, patch, nodepool, application..."

277
00:52:10,000 --> 00:52:20,000
This prevents Karpenter from launching tiny instances. They are inefficient for production workloads.

278
00:52:20,000 --> 00:52:30,000
The fifth optimization is to prefer newer instance generations. m7g is better than m6g. m6g is better than m5.

279
00:52:30,000 --> 00:52:40,000
Karpenter does not have a built-in preference for newer generations. But you can order them in the instance family list.

280
00:52:40,000 --> 00:52:50,000
[Types: kubectl patch nodepool application --type='merge' -p='{"spec":{"template":{"spec":{"requirements":[{"key":"karpenter.k8s.aws/instance-family","operator":"In","values":["m7g","m6g","m6i","m5"]}]}}}}']
▶ Pronounced as: "Kubectl, patch, nodepool, application..."

281
00:52:50,000 --> 00:53:00,000
This prefers m7g over m6g. Both are better than m5. This saves cost because newer generations are more efficient.

282
00:53:00,000 --> 00:53:10,000
The sixth optimization is to use the weight field. You can prefer some NodePools over others.

283
00:53:10,000 --> 00:53:20,000
[Types: kubectl patch nodepool application --type='merge' -p='{"spec":{"weight":100}}']
[Types: kubectl patch nodepool ingestion --type='merge' -p='{"spec":{"weight":50}}']

284
00:53:20,000 --> 00:53:30,000
This makes the application NodePool preferred. Karpenter will use it first. It will use ingestion only when necessary.

285
00:53:30,000 --> 00:53:40,000
Now you have optimized instance selection. Karpenter will make the best cost decisions for your workloads.

286
00:53:40,000 --> 00:53:50,000
In the next segment, we do a deep dive into Spot instance handling.

287
00:53:50,000 --> 00:54:00,000
See you in Segment 12.
```

---

### SEGMENT 12: Deep Dive — Spot Instance Handling
**Timestamp:** 55:00 – 60:00

```
288
00:55:00,000 --> 00:55:10,000
Welcome to Segment 12. We are going to do a deep dive into Spot instance handling.

289
00:55:10,000 --> 00:55:20,000
Spot instances are the primary cost saving mechanism in Karpenter. But they require careful handling.

290
00:55:20,000 --> 00:55:30,000
When AWS needs capacity back, it sends a Spot interruption notice. This happens two minutes before termination.

291
00:55:30,000 --> 00:55:40,000
Karpenter receives this notice through the SQS queue. It then drains the node gracefully.

292
00:55:40,000 --> 00:55:50,000
The drain process is the same as consolidation. Cordon, drain, terminate. But it is triggered by an interruption.

293
00:55:50,000 --> 00:56:00,000
Karpenter respects disruption budgets during Spot interruptions. It will not drain a node if it would violate the PDB.

294
00:56:00,000 --> 00:56:10,000
This is why PDBs are critical for Spot workloads. They protect your services from being disrupted.

295
00:56:10,000 --> 00:56:20,000
Karpenter also handles Spot interruptions at the cluster level. It does not require separate tooling.

296
00:56:20,000 --> 00:56:30,000
The EventBridge rule we created sends all Spot interruption events to the SQS queue. Karpenter reads from this queue.

297
00:56:30,000 --> 00:56:40,000
[Types: aws sqs receive-message --queue-url $QUEUE_URL --max-number-of-messages 5]
▶ Pronounced as: "AWS, S-Q-S, receive, message..."

298
00:56:40,000 --> 00:56:50,000
This shows you the messages currently in the queue. You can see if there are any pending interruptions.

299
00:56:50,000 --> 00:57:00,000
If you want to test Spot interruption handling, you can simulate an interruption.

300
00:57:00,000 --> 00:57:10,000
[Types: aws ec2 modify-instance-placement --instance-id i-xxxxxxxxx --affinity default --tenancy default --host-id null]
▶ Pronounced as: "AWS, E-C-two, modify, instance, placement..."

301
00:57:10,000 --> 00:57:20,000
This is not a real interruption. But it triggers the same EventBridge rules. It is useful for testing.

302
00:57:20,000 --> 00:57:30,000
For production, you do not need to test interruptions. They will happen naturally.

303
00:57:30,000 --> 00:57:40,000
You should monitor interruption rates. If you see high interruption rates, your Spot instance selection may be suboptimal.

304
00:57:40,000 --> 00:57:50,000
[Types: kubectl logs -n karpenter -l app.kubernetes.io/name=karpenter --since=7d | grep -c "interruption" || echo "0"]
▶ Pronounced as: "Kubectl, logs, dash, n, karpenter..."

305
00:57:50,000 --> 00:58:00,000
This counts interruptions in the last seven days. A low number means Karpenter is handling interruptions well.

306
00:58:00,000 --> 00:58:10,000
High interruption rates may mean you are using volatile instance families. Consider adding more instance families.

307
00:58:10,000 --> 00:58:20,000
Karpenter's Spot handling is production-ready. It has been tested at scale by AWS and many large enterprises.

308
00:58:20,000 --> 00:58:30,000
In the next segment, we look at NodePool taints and tolerations in more depth.

309
00:58:30,000 --> 00:58:40,000
See you in Segment 13.
```

---

### SEGMENT 13: NodePool Taints & Tolerations — Advanced Patterns
**Timestamp:** 60:00 – 65:00

```
310
01:00:00,000 --> 01:00:10,000
Welcome to Segment 13. We are going to look at advanced patterns for NodePool taints and tolerations.

311
01:00:10,000 --> 01:00:20,000
Taints are applied to nodes. Tolerations are applied to pods. They control which pods can schedule on which nodes.

312
01:00:20,000 --> 01:00:30,000
The basic pattern is: add a taint to the NodePool. Add a matching toleration to the workload. This ensures workloads go to the right NodePool.

313
01:00:30,000 --> 01:00:40,000
But there are advanced patterns. You can use taints to isolate different types of workloads.

314
01:00:40,000 --> 01:00:50,000
[Types: cat << EOF | kubectl apply -f -
apiVersion: karpenter.sh/v1beta1
kind: NodePool
metadata:
  name: production
spec:
  template:
    spec:
      taints:
        - key: environment
          value: production
          effect: NoSchedule
  weight: 100
EOF]
▶ Pronounced as: "Cat, less-than, less-than, EOF, pipe, kubectl, apply, dash, f, dash"

315
01:00:50,000 --> 01:01:00,000
This isolates production workloads from other environments. Only pods with the production toleration can schedule on these nodes.

316
01:01:00,000 --> 01:01:10,000
You can also use taints to isolate GPU workloads. We already did this with the gpu-ml NodePool.

317
01:01:10,000 --> 01:01:20,000
[Types: cat << EOF | kubectl apply -f -
apiVersion: karpenter.sh/v1beta1
kind: NodePool
metadata:
  name: gpu-training
spec:
  template:
    spec:
      taints:
        - key: nvidia.com/gpu
          value: "true"
          effect: NoSchedule
  weight: 10
EOF]
▶ Pronounced as: "Cat, less-than, less-than, EOF, pipe, kubectl, apply, dash, f, dash"

318
01:01:20,000 --> 01:01:30,000
This ensures only GPU workloads schedule on GPU nodes. Other workloads are blocked by the taint.

319
01:01:30,000 --> 01:01:40,000
You can also use taints with NoExecute effect. This evicts existing pods from the node.

320
01:01:40,000 --> 01:01:50,000
[Types: cat << EOF | kubectl apply -f -
apiVersion: karpenter.sh/v1beta1
kind: NodePool
metadata:
  name: maintenance
spec:
  template:
    spec:
      taints:
        - key: maintenance
          value: "true"
          effect: NoExecute
  weight: 1
EOF]
▶ Pronounced as: "Cat, less-than, less-than, EOF, pipe, kubectl, apply, dash, f, dash"

321
01:01:50,000 --> 01:02:00,000
This NodePool is for maintenance nodes. Pods without the toleration will be evicted when they are scheduled.

322
01:02:00,000 --> 01:02:10,000
Tolerations can be applied to deployments or pods directly. You can also apply them to Helm charts.

323
01:02:10,000 --> 01:02:20,000
[Types: kubectl patch deployment my-app -n my-namespace --type='json' -p='[{"op":"add","path":"/spec/template/spec/tolerations","value":[{"key":"environment","operator":"Equal","value":"production","effect":"NoSchedule"}]}]']
▶ Pronounced as: "Kubectl, patch, deployment..."

324
01:02:20,000 --> 01:02:30,000
This adds the production toleration to an existing deployment. It will now schedule on production nodes.

325
01:02:30,000 --> 01:02:40,000
Taints and tolerations are a powerful control. They allow you to segment your cluster by workload type.

326
01:02:40,000 --> 01:02:50,000
This improves both cost and security. You can isolate different teams or different environments.

327
01:02:50,000 --> 01:03:00,000
In the next segment, we look at understanding NodeExpiry and NodeRotation.

328
01:03:00,000 --> 01:03:10,000
See you in Segment 14.
```

---

### SEGMENT 14: Understanding NodeExpiry & NodeRotation
**Timestamp:** 65:00 – 70:00

```
329
01:05:00,000 --> 01:05:10,000
Welcome to Segment 14. We are going to understand NodeExpiry and NodeRotation.

330
01:05:10,000 --> 01:05:20,000
NodeExpiry is the expireAfter setting in the NodePool. It tells Karpenter when to replace a node.

331
01:05:20,000 --> 01:05:30,000
We set expireAfter to 720 hours for application workloads. This is thirty days.

332
01:05:30,000 --> 01:05:40,000
Why thirty days? Because security patches are released monthly. New AMIs are available monthly.

333
01:05:40,000 --> 01:05:50,000
Expiring nodes every thirty days ensures your nodes run the latest AMI. This improves security.

334
01:05:50,000 --> 01:06:00,000
NodeRotation is the process of replacing expired nodes. Karpenter does this automatically.

335
01:06:00,000 --> 01:06:10,000
When a node reaches its expiry time, Karpenter cordons it. It then drains the pods. Finally, it terminates the instance.

336
01:06:10,000 --> 01:06:20,000
A new node is launched with the latest AMI. The pods are rescheduled on the new node.

337
01:06:20,000 --> 01:06:30,000
This is the same process as consolidation. But it is triggered by time, not by utilisation.

338
01:06:30,000 --> 01:06:40,000
NodeRotation is essential for production security. Without it, you have nodes running old, potentially vulnerable AMIs.

339
01:06:40,000 --> 01:06:50,000
You can adjust the expireAfter setting based on your security requirements. Seven days for high-security environments.

340
01:06:50,000 --> 01:07:00,000
[Types: kubectl patch nodepool application --type='merge' -p='{"spec":{"disruption":{"expireAfter":"168h"}}}']
▶ Pronounced as: "Kubectl, patch, nodepool, application..."

341
01:07:00,000 --> 01:07:10,000
This sets expiry to seven days. Nodes will be replaced weekly. This is more secure but increases churn.

342
01:07:10,000 --> 01:07:20,000
NodeRotation and consolidation work together. They are both part of Karpenter's disruption budget.

343
01:07:20,000 --> 01:07:30,000
The disruption budget controls how many nodes can be disrupted at once. This prevents too many nodes being replaced simultaneously.

344
01:07:30,000 --> 01:07:40,000
[Types: kubectl get disruptionbudgets -A]
▶ Pronounced as: "Kubectl, get, disruptionbudgets, dash, A"

345
01:07:40,000 --> 01:07:50,000
This shows you the disruption budgets in your cluster. They are automatically created by Karpenter.

346
01:07:50,000 --> 01:08:00,000
NodeRotation is a key feature of Karpenter. It automates security maintenance. It reduces manual work.

347
01:08:00,000 --> 01:08:10,000
In the next segment, we look at monitoring Karpenter with CloudWatch.

348
01:08:10,000 --> 01:08:20,000
See you in Segment 15.
```

---

### SEGMENT 15: Monitoring Karpenter with CloudWatch
**Timestamp:** 70:00 – 75:00

```
349
01:10:00,000 --> 01:10:10,000
Welcome to Segment 15. We are going to monitor Karpenter with CloudWatch.

350
01:10:10,000 --> 01:10:20,000
Karpenter publishes metrics to CloudWatch. These metrics help you monitor cluster health and cost.

351
01:10:20,000 --> 01:10:30,000
The key metrics are: nodes_provisioned, nodes_terminated, consolidation_events, and spot_interruptions.

352
01:10:30,000 --> 01:10:40,000
[Types: aws cloudwatch get-metric-statistics --namespace AWS/Karpenter --metric-name nodes_provisioned --start-time $(date -d '1 hour ago' -u +%Y-%m-%dT%H:%M:%SZ) --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) --period 300 --statistics Sum --output table]
▶ Pronounced as: "AWS, CloudWatch, get, metric, statistics..."

353
01:10:40,000 --> 01:10:50,000
This shows you how many nodes Karpenter has provisioned in the last hour.

354
01:10:50,000 --> 01:11:00,000
[Types: aws cloudwatch get-metric-statistics --namespace AWS/Karpenter --metric-name consolidation_events --start-time $(date -d '1 hour ago' -u +%Y-%m-%dT%H:%M:%SZ) --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) --period 300 --statistics Sum --output table]
▶ Pronounced as: "AWS, CloudWatch, get, metric, statistics..."

355
01:11:00,000 --> 01:11:10,000
This shows you consolidation events. A high number means Karpenter is actively optimizing your cluster.

356
01:11:10,000 --> 01:11:20,000
You can create CloudWatch dashboards to visualize Karpenter metrics. This helps you monitor cluster health.

357
01:11:20,000 --> 01:11:30,000
[Types: aws cloudwatch put-dashboard --dashboard-name Karpenter --dashboard-body '{"widgets":[{"type":"metric","properties":{"metrics":[["AWS/Karpenter","nodes_provisioned"],["AWS/Karpenter","nodes_terminated"]],"period":300,"stat":"Sum","region":"us-east-1","title":"Karpenter Metrics"}}]}']
▶ Pronounced as: "AWS, CloudWatch, put, dashboard..."

358
01:11:30,000 --> 01:11:40,000
This creates a CloudWatch dashboard for Karpenter. You can view it in the CloudWatch console.

359
01:11:40,000 --> 01:11:50,000
You should also set up alarms for critical metrics.

360
01:11:50,000 --> 01:12:00,000
[Types: aws cloudwatch put-metric-alarm --alarm-name Karpenter-NodeCount --alarm-description "Alert if Karpenter provisions too many nodes" --metric-name nodes_provisioned --namespace AWS/Karpenter --statistic Sum --period 300 --evaluation-periods 1 --threshold 10 --comparison-operator GreaterThanThreshold --alarm-actions arn:aws:sns:us-east-1:123456789012:alerts]
▶ Pronounced as: "AWS, CloudWatch, put, metric, alarm..."

361
01:12:00,000 --> 01:12:10,000
This alerts you if Karpenter provisions more than ten nodes in five minutes. This could indicate a scaling issue.

362
01:12:10,000 --> 01:12:20,000
Monitoring Karpenter is essential for production. You need to know when it is scaling and why.

363
01:12:20,000 --> 01:12:30,000
In the next segment, we look at troubleshooting common Karpenter issues.

364
01:12:30,000 --> 01:12:40,000
See you in Segment 16.
```

---

### SEGMENT 16: Troubleshooting Karpenter Issues
**Timestamp:** 75:00 – 80:00

```
365
01:15:00,000 --> 01:15:10,000
Welcome to Segment 16. We are going to troubleshoot common Karpenter issues.

366
01:15:10,000 --> 01:15:20,000
Issue 1: "Karpenter is not provisioning any nodes." Check the Karpenter pod logs.

367
01:15:20,000 --> 01:15:30,000
[Types: kubectl logs -n karpenter -l app.kubernetes.io/name=karpenter --tail=50]
▶ Pronounced as: "Kubectl, logs, dash, n, karpenter..."

368
01:15:30,000 --> 01:15:40,000
Common cause: IAM role missing permissions. Check the IAM role policies.

369
01:15:40,000 --> 01:15:50,000
[Types: aws iam list-attached-role-policies --role-name KarpenterControllerRole-$CLUSTER_NAME]
▶ Pronounced as: "AWS, I-A-M, list, attached, role, policies..."

370
01:15:50,000 --> 01:16:00,000
Ensure the policy has ec2:RunInstances and ec2:TerminateInstances permissions.

371
01:16:00,000 --> 01:16:10,000
Issue 2: "Karpenter is provisioning nodes but pods are not scheduling." Check the NodePool requirements.

372
01:16:10,000 --> 01:16:20,000
[Types: kubectl describe nodepool application]
▶ Pronounced as: "Kubectl, describe, nodepool, application"

373
01:16:20,000 --> 01:16:30,000
Ensure the NodePool has the correct instance families. Ensure the taints match the tolerations.

374
01:16:30,000 --> 01:16:40,000
Issue 3: "Karpenter is not consolidating nodes." Check the consolidation policy.

375
01:16:40,000 --> 01:16:50,000
[Types: kubectl get nodepool -o yaml | grep -A10 disruption]
▶ Pronounced as: "Kubectl, get, nodepool..."

376
01:16:50,000 --> 01:17:00,000
Ensure consolidationPolicy is WhenUnderutilized. If it is WhenEmpty, it will only consolidate empty nodes.

377
01:17:00,000 --> 01:17:10,000
Issue 4: "Karpenter is terminating nodes with running pods." Check your PodDisruptionBudgets.

378
01:17:10,000 --> 01:17:20,000
[Types: kubectl get pdb --all-namespaces]
▶ Pronounced as: "Kubectl, get, pdb..."

379
01:17:20,000 --> 01:17:30,000
Ensure PDBs are correctly configured. If they are too restrictive, Karpenter cannot drain nodes.

380
01:17:30,000 --> 01:17:40,000
Issue 5: "Karpenter is not using Spot instances." Check the NodePool capacity types.

381
01:17:40,000 --> 01:17:50,000
[Types: kubectl get nodepool -o yaml | grep -A5 capacity-type]
▶ Pronounced as: "Kubectl, get, nodepool..."

382
01:17:50,000 --> 01:18:00,000
Ensure capacity-type includes "spot". If it only includes "on-demand", Spot will not be used.

383
01:18:00,000 --> 01:18:10,000
Issue 6: "Karpenter is launching nodes but they are failing to join the cluster." Check the node bootstrap configuration.

384
01:18:10,000 --> 01:18:20,000
[Types: kubectl get nodes --show-labels]
▶ Pronounced as: "Kubectl, get, nodes..."

385
01:18:20,000 --> 01:18:30,000
Ensure the EC2NodeClass has the correct subnet and security group tags. Ensure the node IAM role has the required policies.

386
01:18:30,000 --> 01:18:40,000
Common issues are usually IAM or networking. Check the logs for specific error messages.

387
01:18:40,000 --> 01:18:50,000
In the next segment, we do a workshop on configuring Karpenter for your workload.

388
01:18:50,000 --> 01:19:00,000
See you in Segment 17.
```

---

### SEGMENT 17: Workshop — Configuring Karpenter for Your Workload
**Timestamp:** 80:00 – 85:00

```
389
01:20:00,000 --> 01:20:10,000
Welcome to Segment 17. This is the Karpenter workshop.

390
01:20:10,000 --> 01:20:20,000
We are going to configure Karpenter for a real workload. You will apply what you have learned.

391
01:20:20,000 --> 01:20:30,000
Step 1: Identify your workload characteristics. What type of workload is it? CPU-intensive? Memory-intensive? GPU?

392
01:20:30,000 --> 01:20:40,000
Step 2: Choose the instance families. For CPU-intensive, use c5, c6i, c6g. For memory-intensive, use r5, r6i, r6g. For GPU, use g4dn, g5.

393
01:20:40,000 --> 01:20:50,000
Step 3: Choose the capacity types. For production, use both spot and on-demand. For batch, use spot only.

394
01:20:50,000 --> 01:21:00,000
Step 4: Choose the consolidation policy. For production, use WhenUnderutilized. For batch, use WhenEmpty.

395
01:21:00,000 --> 01:21:10,000
Step 5: Choose the expiry time. For production, use 720 hours. For batch, use 168 hours.

396
01:21:10,000 --> 01:21:20,000
Step 6: Create the NodePool. Use the templates from this course.

397
01:21:20,000 --> 01:21:30,000
[Types: cat << EOF | kubectl apply -f -
apiVersion: karpenter.sh/v1beta1
kind: NodePool
metadata:
  name: my-workload
spec:
  template:
    metadata:
      labels:
        workload: my-workload
    spec:
      nodeClassRef:
        name: default
      requirements:
        - key: karpenter.k8s.aws/instance-family
          operator: In
          values: ["m5", "m6i", "m6g"]
        - key: karpenter.sh/capacity-type
          operator: In
          values: ["spot", "on-demand"]
  disruption:
    consolidationPolicy: WhenUnderutilized
    expireAfter: 720h
EOF]
▶ Pronounced as: "Cat, less-than, less-than, EOF, pipe, kubectl, apply, dash, f, dash"

398
01:21:30,000 --> 01:21:40,000
Step 7: Add tolerations to your workload.

399
01:21:40,000 --> 01:21:50,000
[Types: kubectl patch deployment my-app -n my-namespace --type='json' -p='[{"op":"add","path":"/spec/template/spec/tolerations","value":[{"key":"workload","operator":"Equal","value":"my-workload","effect":"NoSchedule"}]},{"op":"add","path":"/spec/template/spec/nodeSelector","value":{"workload":"my-workload"}}]']
▶ Pronounced as: "Kubectl, patch, deployment..."

400
01:21:50,000 --> 01:22:00,000
Step 8: Test the configuration. Scale up the deployment and watch Karpenter launch nodes.

401
01:22:00,000 --> 01:22:10,000
[Types: kubectl scale deployment my-app -n my-namespace --replicas=10]
▶ Pronounced as: "Kubectl, scale, deployment..."

402
01:22:10,000 --> 01:22:20,000
[Types: kubectl get nodes -w]
▶ Pronounced as: "Kubectl, get, nodes, dash, w"

403
01:22:20,000 --> 01:22:30,000
Step 9: Verify the nodes are using the correct instance families. Check the node labels.

404
01:22:30,000 --> 01:22:40,000
[Types: kubectl get nodes -o custom-columns='NAME:.metadata.name,INSTANCE:.metadata.labels.node\.kubernetes\.io/instance-type,CAPACITY:.metadata.labels.karpenter\.sh/capacity-type']
▶ Pronounced as: "Kubectl, get, nodes, dash, o, custom, dash, columns..."

405
01:22:40,000 --> 01:22:50,000
Step 10: Monitor the cost impact. Compare the cost before and after Karpenter.

406
01:22:50,000 --> 01:23:00,000
This is the complete workflow for configuring Karpenter. You can adapt it for any workload.

407
01:23:00,000 --> 01:23:10,000
In the next segment, we look at understanding Pod Topology Spread Constraints.

408
01:23:10,000 --> 01:23:20,000
See you in Segment 18.
```

---

### SEGMENT 18: Understanding Pod Topology Spread Constraints
**Timestamp:** 85:00 – 90:00

```
409
01:25:00,000 --> 01:25:10,000
Welcome to Segment 18. We are going to understand Pod Topology Spread Constraints.

410
01:25:10,000 --> 01:25:20,000
Topology spread constraints control how pods are distributed across the cluster. They improve availability.

411
01:25:20,000 --> 01:25:30,000
The most common topology is availability zones. You want pods spread across AZs.

412
01:25:30,000 --> 01:25:40,000
[Types: cat << EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      topologySpreadConstraints:
        - maxSkew: 1
          topologyKey: topology.kubernetes.io/zone
          whenUnsatisfiable: DoNotSchedule
          labelSelector:
            matchLabels:
              app: my-app
      containers:
        - name: my-app
          image: nginx
EOF]
▶ Pronounced as: "Cat, less-than, less-than, EOF, pipe, kubectl, apply, dash, f, dash"

413
01:25:40,000 --> 01:25:50,000
This ensures three replicas are spread across three AZs. One in each AZ.

414
01:25:50,000 --> 01:26:00,000
The maxSkew controls how uneven the distribution can be. A maxSkew of 1 means each AZ can have at most one more pod than another.

415
01:26:00,000 --> 01:26:10,000
The whenUnsatisfiable setting controls what happens if the constraint cannot be met. DoNotSchedule means the pod will not be scheduled.

416
01:26:10,000 --> 01:26:20,000
This is the most important topology for cost. Cross-AZ data transfer costs money. Keeping pods in the same AZ reduces these costs.

417
01:26:20,000 --> 01:26:30,000
You can also use hostname topology. This spreads pods across different nodes.

418
01:26:30,000 --> 01:26:40,000
[Types: cat << EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      topologySpreadConstraints:
        - maxSkew: 1
          topologyKey: kubernetes.io/hostname
          whenUnsatisfiable: ScheduleAnyway
          labelSelector:
            matchLabels:
              app: my-app
      containers:
        - name: my-app
          image: nginx
EOF]
▶ Pronounced as: "Cat, less-than, less-than, EOF, pipe, kubectl, apply, dash, f, dash"

419
01:26:40,000 --> 01:26:50,000
This ensures pods are spread across different nodes. This improves availability during node failures.

420
01:26:50,000 --> 01:27:00,000
Topology spread constraints are part of Kubernetes. They work with Karpenter because Karpenter respects them.

421
01:27:00,000 --> 01:27:10,000
When Karpenter launches nodes, it considers the topology spread constraints. It launches nodes in the right AZs.

422
01:27:10,000 --> 01:27:20,000
This is how you combine Karpenter with availability requirements. You get cost optimization and availability.

423
01:27:20,000 --> 01:27:30,000
In the next segment, we look at Karpenter pricing optimization.

424
01:27:30,000 --> 01:27:40,000
See you in Segment 19.
```

---

### SEGMENT 19: Deep Dive — Karpenter Pricing Optimization
**Timestamp:** 90:00 – 95:00

```
425
01:30:00,000 --> 01:30:10,000
Welcome to Segment 19. We are going to look at Karpenter pricing optimization.

426
01:30:10,000 --> 01:30:20,000
Karpenter is not just a scaling tool. It is a pricing optimization tool. It actively chooses the cheapest instance types.

427
01:30:20,000 --> 01:30:30,000
Karpenter queries the AWS Pricing API before every launch. It gets the current Spot and On-Demand prices.

428
01:30:30,000 --> 01:30:40,000
It then selects the cheapest instance type that meets the pod requirements. This is real-time optimization.

429
01:30:40,000 --> 01:30:50,000
The optimization considers four factors. The first is instance family. The second is architecture. The third is capacity type. The fourth is size.

430
01:30:50,000 --> 01:31:00,000
Karpenter weights these factors based on cost. Spot is always cheaper than On-Demand. Arm64 is cheaper than amd64.

431
01:31:00,000 --> 01:31:10,000
Karpenter also considers availability. If Spot is not available for a particular instance type, it falls back to On-Demand.

432
01:31:10,000 --> 01:31:20,000
The pricing optimization is continuous. Karpenter re-evaluates pricing every time it launches a node.

433
01:31:20,000 --> 01:31:30,000
This is why Karpenter saves money over time. It adapts to changing prices.

434
01:31:30,000 --> 01:31:40,000
You can see the price differences yourself. Run the Spot price analysis script we covered earlier.

435
01:31:40,000 --> 01:31:50,000
[Types: for family in m6i m7g c6i c7g; do for size in large xlarge; do price=$(aws ec2 describe-spot-price-history --instance-types ${family}.${size} --start-time $(date -u +"%Y-%m-%dT%H:%M:%SZ") --query 'SpotPriceHistory[0].SpotPrice' --output text 2>/dev/null); echo "$family.$size: \$$price/hr"; done; done]
▶ Pronounced as: "For, family, in... do..."

436
01:31:50,000 --> 01:32:00,000
This shows you current Spot prices. You can see how much cheaper Graviton instances are.

437
01:32:00,000 --> 01:32:10,000
Karpenter uses the same API. It makes the same decision. It picks the cheapest instance type.

438
01:32:10,000 --> 01:32:20,000
Karpenter also considers the cost of consolidation. It evaluates whether keeping a node is cheaper than moving its pods.

439
01:32:20,000 --> 01:32:30,000
This is why Karpenter is a FinOps tool. It is not just about scaling. It is about cost optimization.

440
01:32:30,000 --> 01:32:40,000
In the next segment, we look at integrating Karpenter with Kubecost.

441
01:32:40,000 --> 01:32:50,000
See you in Segment 20.
```

---

### SEGMENT 20: Integrating Karpenter with Kubecost
**Timestamp:** 95:00 – 100:00

```
442
01:35:00,000 --> 01:35:10,000
Welcome to Segment 20. We are going to integrate Karpenter with Kubecost.

443
01:35:10,000 --> 01:35:20,000
Kubecost provides cost visibility. Karpenter provides cost optimization. Together, they form a complete FinOps system.

444
01:35:20,000 --> 01:35:30,000
Kubecost shows you which namespaces are expensive. Karpenter optimizes the compute for those namespaces.

445
01:35:30,000 --> 01:35:40,000
The integration is automatic. Kubecost sees the nodes Karpenter launches. It attributes the cost correctly.

446
01:35:40,000 --> 01:35:50,000
Kubecost also sees the instance types Karpenter selects. It shows you the Spot vs On-Demand split.

447
01:35:50,000 --> 01:36:00,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/allocation?window=7d&aggregate=cluster&expanded=true' | jq '.data[0].nodes[] | {node: .name, instanceType: .instanceType, capacityType: .capacityType}']
▶ Pronounced as: "Kubectl, exec, dash, n, kubecost..."

448
01:36:00,000 --> 01:36:10,000
This shows you the instance types and capacity types of all nodes. You can see Karpenter's selections.

449
01:36:10,000 --> 01:36:20,000
You can also see the cost savings from Karpenter in Kubecost. Compare the cost before and after Karpenter.

450
01:36:20,000 --> 01:36:30,000
[Types: kubectl exec -n kubecost deploy/kubecost-cost-analyzer -- curl -s 'http://localhost:9090/model/savings' | jq '.savings.karpenterSavings']
▶ Pronounced as: "Kubectl, exec, dash, n, kubecost..."

451
01:36:30,000 --> 01:36:40,000
This shows you the savings attributed to Karpenter. This is the dollar amount Karpenter has saved you.

452
01:36:40,000 --> 01:36:50,000
The Kubecost dashboard also shows Karpenter metrics. Node count, instance types, capacity split.

453
01:36:50,000 --> 01:37:00,000
This integration is what makes FinOps continuous. Kubecost shows you the problem. Karpenter fixes it.

454
01:37:00,000 --> 01:37:10,000
You can also set up alerts based on Karpenter metrics. If Karpenter is not using Spot, you get an alert.

455
01:37:10,000 --> 01:37:20,000
[Types: aws cloudwatch put-metric-alarm --alarm-name Karpenter-Spot-Usage --alarm-description "Alert if Spot usage drops below 50%" --metric-name spot_usage --namespace AWS/Karpenter --statistic Average --period 3600 --evaluation-periods 3 --threshold 50 --comparison-operator LessThanThreshold --alarm-actions arn:aws:sns:us-east-1:123456789012:alerts]
▶ Pronounced as: "AWS, CloudWatch, put, metric, alarm..."

456
01:37:20,000 --> 01:37:30,000
This alerts you if Spot usage drops below 50%. This could indicate a problem with the NodePool configuration.

457
01:37:30,000 --> 01:37:40,000
In the next segment, we look at disruption budgets in advanced configuration.

458
01:37:40,000 --> 01:37:50,000
See you in Segment 21.
```

---

### SEGMENT 21: Disruption Budgets — Advanced Configuration
**Timestamp:** 100:00 – 105:00

```
459
01:40:00,000 --> 01:40:10,000
Welcome to Segment 21. We are going to look at disruption budgets in advanced configuration.

460
01:40:10,000 --> 01:40:20,000
Disruption budgets control how Karpenter handles disruptions. They protect your workloads.

461
01:40:20,000 --> 01:40:30,000
There are two types of disruptions. Consolidation and NodeExpiry. Both are controlled by the disruption budget.

462
01:40:30,000 --> 01:40:40,000
The basic disruption budget uses minAvailable and maxUnavailable. This is the same as Kubernetes PDBs.

463
01:40:40,000 --> 01:40:50,000
But Karpenter also has advanced disruption budgets. You can control the rate of disruptions.

464
01:40:50,000 --> 01:41:00,000
[Types: cat << EOF | kubectl apply -f -
apiVersion: karpenter.sh/v1beta1
kind: DisruptionBudget
metadata:
  name: controlled-consolidation
spec:
  schedules:
    - name: weekday
      cron: "0 8 * * 1-5"
      maxNodes: 1
    - name: weekend
      cron: "0 8 * * 6-7"
      maxNodes: 5
EOF]
▶ Pronounced as: "Cat, less-than, less-than, EOF, pipe, kubectl, apply, dash, f, dash"

465
01:41:00,000 --> 01:41:10,000
This controls disruption during weekdays and weekends. During weekdays, only one node can be disrupted at a time. During weekends, five nodes can be disrupted.

466
01:41:10,000 --> 01:41:20,000
This is useful for production environments. You want less disruption during business hours.

467
01:41:20,000 --> 01:41:30,000
You can also control disruption by namespace. Some namespaces are more critical than others.

468
01:41:30,000 --> 01:41:40,000
[Types: cat << EOF | kubectl apply -f -
apiVersion: karpenter.sh/v1beta1
kind: DisruptionBudget
metadata:
  name: critical-namespace
spec:
  selector:
    matchLabels:
      namespace: financial-rag
  maxNodes: 0
EOF]
▶ Pronounced as: "Cat, less-than, less-than, EOF, pipe, kubectl, apply, dash, f, dash"

469
01:41:40,000 --> 01:41:50,000
This prevents any disruptions in the financial-rag namespace. No consolidation. No NodeExpiry.

470
01:41:50,000 --> 01:42:00,000
This is useful for critical production workloads. You want zero disruption risk.

471
01:42:00,000 --> 01:42:10,000
You can also set a disruption budget for NodeExpiry separately. This gives you fine-grained control.

472
01:42:10,000 --> 01:42:20,000
[Types: cat << EOF | kubectl apply -f -
apiVersion: karpenter.sh/v1beta1
kind: DisruptionBudget
metadata:
  name: expiry-control
spec:
  disruptionTypes:
    - expire
  maxNodes: 1
EOF]
▶ Pronounced as: "Cat, less-than, less-than, EOF, pipe, kubectl, apply, dash, f, dash"

473
01:42:20,000 --> 01:42:30,000
This controls only NodeExpiry disruptions. Consolidation can still happen normally.

474
01:42:30,000 --> 01:42:40,000
Disruption budgets are a powerful tool. They give you control over Karpenter's behavior.

475
01:42:40,000 --> 01:42:50,000
In the next segment, we look at Karpenter best practices for production.

476
01:42:50,000 --> 01:43:00,000
See you in Segment 22.
```

---

### SEGMENT 22: Karpenter Best Practices for Production
**Timestamp:** 105:00 – 110:00

```
477
01:45:00,000 --> 01:45:10,000
Welcome to Segment 22. We are going to cover Karpenter best practices for production.

478
01:45:10,000 --> 01:45:20,000
Best practice 1: Always set minSize to 0 on existing node groups. Otherwise, they block consolidation.

479
01:45:20,000 --> 01:45:30,000
[Types: aws eks update-nodegroup-config --cluster-name $CLUSTER_NAME --nodegroup-name your-node-group --scaling-config minSize=0,maxSize=1,desiredSize=0]
▶ Pronounced as: "AWS, E-K-S, update, nodegroup, config..."

480
01:45:30,000 --> 01:45:40,000
Best practice 2: Use PDBs for all stateful workloads. This prevents data loss during consolidation.

481
01:45:40,000 --> 01:45:50,000
[Types: kubectl apply -f pdb-statefulset.yaml]
▶ Pronounced as: "Kubectl, apply, dash, f, pdb-statefulset, dot, yaml"

482
01:45:50,000 --> 01:46:00,000
Best practice 3: Set expireAfter to 720 hours or less. This ensures regular security patching.

483
01:46:00,000 --> 01:46:10,000
[Types: kubectl patch nodepool application --type='merge' -p='{"spec":{"disruption":{"expireAfter":"720h"}}}']
▶ Pronounced as: "Kubectl, patch, nodepool, application..."

484
01:46:10,000 --> 01:46:20,000
Best practice 4: Include multiple instance families. This gives Karpenter more pricing options.

485
01:46:20,000 --> 01:46:30,000
[Types: kubectl patch nodepool application --type='merge' -p='{"spec":{"template":{"spec":{"requirements":[{"key":"karpenter.k8s.aws/instance-family","operator":"In","values":["m5","m6i","m6g","m7g","c5","c6i","c6g"]}]}}}}']
▶ Pronounced as: "Kubectl, patch, nodepool, application..."

486
01:46:30,000 --> 01:46:40,000
Best practice 5: Include arm64 architectures. Graviton instances are 20% cheaper.

487
01:46:40,000 --> 01:46:50,000
[Types: kubectl patch nodepool application --type='merge' -p='{"spec":{"template":{"spec":{"requirements":[{"key":"kubernetes.io/arch","operator":"In","values":["amd64","arm64"]}]}}}}']
▶ Pronounced as: "Kubectl, patch, nodepool, application..."

488
01:46:50,000 --> 01:47:00,000
Best practice 6: Use Spot for non-critical workloads. This saves 60-80% of compute cost.

489
01:47:00,000 --> 01:47:10,000
[Types: kubectl patch nodepool ingestion --type='merge' -p='{"spec":{"template":{"spec":{"requirements":[{"key":"karpenter.sh/capacity-type","operator":"In","values":["spot"]}]}}}}']
▶ Pronounced as: "Kubectl, patch, nodepool, ingestion..."

490
01:47:10,000 --> 01:47:20,000
Best practice 7: Monitor Karpenter metrics. Set up CloudWatch dashboards and alarms.

491
01:47:20,000 --> 01:47:30,000
Best practice 8: Test Karpenter changes in a staging environment first. This catches configuration issues.

492
01:47:30,000 --> 01:47:40,000
Best practice 9: Document your NodePool configurations. This helps new team members understand the setup.

493
01:47:40,000 --> 01:47:50,000
Best practice 10: Review Karpenter performance monthly. Adjust NodePool configurations as needed.

494
01:47:50,000 --> 01:48:00,000
These best practices are based on running Karpenter in production environments. They will help you avoid common pitfalls.

495
01:48:00,000 --> 01:48:10,000
In the next segment, we do a Q&A for Series 4.

496
01:48:10,000 --> 01:48:20,000
See you in Segment 23.
```

---

### SEGMENT 23: Series 4 Q&A — Common Questions Answered
**Timestamp:** 110:00 – 115:00

```
497
01:50:00,000 --> 01:50:10,000
Welcome to Segment 23. This is the Q&A for Series 4.

498
01:50:10,000 --> 01:50:20,000
Question 1: "What happens if I remove the Cluster Autoscaler and Karpenter is not installed yet?"

499
01:50:20,000 --> 01:50:30,000
Your cluster will not autoscale. It will run with the existing nodes. Pods that cannot schedule will stay pending.

500
01:50:30,000 --> 01:50:40,000
This is why you should install Karpenter immediately after removing the Cluster Autoscaler. Minimize the downtime.

501
01:50:40,000 --> 01:50:50,000
Question 2: "Can I run Karpenter and Cluster Autoscaler at the same time?"

502
01:50:50,000 --> 01:51:00,000
No. They will fight over nodes. This causes a node thrashing loop. It can cost thousands of dollars.

503
01:51:00,000 --> 01:51:10,000
Always remove the Cluster Autoscaler before installing Karpenter. This is non-negotiable.

504
01:51:10,000 --> 01:51:20,000
Question 3: "What if Karpenter is not provisioning Spot instances?"

505
01:51:20,000 --> 01:51:30,000
Check the NodePool configuration. Ensure capacity-type includes "spot". Check the Spot availability in your region.

506
01:51:30,000 --> 01:51:40,000
[Types: kubectl get nodepool -o yaml | grep -A5 capacity-type]
▶ Pronounced as: "Kubectl, get, nodepool..."

507
01:51:40,000 --> 01:51:50,000
Question 4: "How do I test Karpenter consolidation?"

508
01:51:50,000 --> 01:52:00,000
Scale down a deployment and watch the logs. Karpenter will consolidate within thirty seconds.

509
01:52:00,000 --> 01:52:10,000
[Types: kubectl scale deployment my-app --replicas=1; kubectl logs -n karpenter -l app.kubernetes.io/name=karpenter --tail=20]
▶ Pronounced as: "Kubectl, scale, deployment..."

510
01:52:10,000 --> 01:52:20,000
Question 5: "What if Karpenter is terminating nodes too aggressively?"

511
01:52:20,000 --> 01:52:30,000
Adjust the consolidation window. Increase consolidateAfter to a higher value. This gives pods more time to drain.

512
01:52:30,000 --> 01:52:40,000
[Types: kubectl patch nodepool application --type='merge' -p='{"spec":{"disruption":{"consolidateAfter":"5m"}}}']
▶ Pronounced as: "Kubectl, patch, nodepool, application..."

513
01:52:40,000 --> 01:52:50,000
Question 6: "Can I use Karpenter without Spot instances?"

514
01:52:50,000 --> 01:53:00,000
Yes. Set the capacity-type to on-demand only. Remove spot from the NodePool requirements.

515
01:53:00,000 --> 01:53:10,000
Question 7: "Does Karpenter work with Windows nodes?"

516
01:53:10,000 --> 01:53:20,000
Yes. Karpenter supports Windows nodes. You need to configure the NodeClass for Windows AMIs.

517
01:53:20,000 --> 01:53:30,000
Question 8: "What is the difference between NodePools and NodeGroups?"

518
01:53:30,000 --> 01:53:40,000
NodeGroups are a fixed set of nodes with a specific instance type. NodePools are a dynamic set of nodes with flexible instance types.

519
01:53:40,000 --> 01:53:50,000
NodePools are the Karpenter abstraction. They provide more flexibility and cost optimization.

520
01:53:50,000 --> 01:54:00,000
Question 9: "How do I troubleshoot Karpenter issues?"

521
01:54:00,000 --> 01:54:10,000
Start with the Karpenter logs. They contain detailed information about what Karpenter is doing.

522
01:54:10,000 --> 01:54:20,000
[Types: kubectl logs -n karpenter -l app.kubernetes.io/name=karpenter --tail=100]
▶ Pronounced as: "Kubectl, logs, dash, n, karpenter..."

523
01:54:20,000 --> 01:54:30,000
Question 10: "What if I have multiple clusters? Do I install Karpenter in each?"

524
01:54:30,000 --> 01:54:40,000
Yes. Karpenter runs in each cluster. It manages the nodes for that specific cluster.

525
01:54:40,000 --> 01:54:50,000
This is the Q&A for Series 4. If you have more questions, check the companion repository.

526
01:54:50,000 --> 01:55:00,000
In the next segment, we do a knowledge check and look ahead to Series 5.
```

---

### SEGMENT 24: Series 4 Knowledge Check & Next Steps
**Timestamp:** 115:00 – 120:00

```
527
01:55:00,000 --> 01:55:10,000
Welcome to Segment 24. This is the knowledge check for Series 4.

528
01:55:10,000 --> 01:55:20,000
Let's test your understanding. Answer these questions in your own words.

529
01:55:20,000 --> 01:55:30,000
Question 1: What are the three problems with the Cluster Autoscaler that Karpenter solves?

530
01:55:30,000 --> 01:55:40,000
Question 2: What is the purpose of the EC2NodeClass?

531
01:55:40,000 --> 01:55:50,000
Question 3: What is the difference between a NodeGroup and a NodePool?

532
01:55:50,000 --> 01:56:00,000
Question 4: What does consolidationPolicy: WhenUnderutilized do?

533
01:56:00,000 --> 01:56:10,000
Question 5: Why is expireAfter set to 720 hours?

534
01:56:10,000 --> 01:56:20,000
Question 6: What are the three NodePools we created and what are they for?

535
01:56:20,000 --> 01:56:30,000
Question 7: Why do we add taints to NodePools?

536
01:56:30,000 --> 01:56:40,000
Question 8: What is the purpose of the SQS queue in Karpenter?

537
01:56:40,000 --> 01:56:50,000
Pause the video. Write down your answers. Then compare them to what you learned.

538
01:56:50,000 --> 01:57:00,000
If you got all eight correct, you understand Series 4. If you missed any, review the relevant segment.

539
01:57:00,000 --> 01:57:10,000
Now let's look ahead to Series 5.

540
01:57:10,000 --> 01:57:20,000
In Series 5, we engineer for Spot instances. Karpenter puts Spot instances on the table. Series 5 teaches you how to engineer for them.

541
01:57:20,000 --> 01:57:30,000
You will implement checkpointing for ML training jobs. You will build SIGTERM signal handlers. You will set up Pod Disruption Budgets for Spot.

542
01:57:30,000 --> 01:57:40,000
You will diversify across multiple AZs. You will use the IMDS metadata watcher. You will analyse Spot price history.

543
01:57:40,000 --> 01:57:50,000
The goal: run eighty percent of your ML workloads on Spot at seventy percent off — with zero job failures.

544
01:57:50,000 --> 01:58:00,000
That is not theoretical. We do it on riskoracle. You will do it too.

545
01:58:00,000 --> 01:58:10,000
Before you start Series 5, verify these four things.

546
01:58:10,000 --> 01:58:20,000
One: Karpenter running. Check with kubectl get pods -n karpenter.

547
01:58:20,000 --> 01:58:30,000
Two: at least one consolidation event visible in logs. Check with kubectl logs -n karpenter | grep consolidat.

548
01:58:30,000 --> 01:58:40,000
Three: Spot nodes being selected. Check with kubectl get nodes -l karpenter.sh/capacity-type=spot.

549
01:58:40,000 --> 01:58:50,000
Four: PDBs applied to all stateful workloads. Check with kubectl get pdb --all-namespaces.

550
01:58:50,000 --> 01:59:00,000
If all four are verified, you are ready for Series 5.

551
01:59:00,000 --> 01:59:10,000
Series 4 is complete. You have deployed Karpenter. You have continuous cost-aware autoscaling.

552
01:59:10,000 --> 01:59:20,000
Your cluster is now self-optimizing. Nodes are consolidated automatically. Spot instances are used where possible.

553
01:59:20,000 --> 01:59:30,000
This is the difference between manual and continuous optimization.

554
01:59:30,000 --> 01:59:40,000
The commands work. The savings are real. You just have to do the work.

555
01:59:40,000 --> 01:59:50,000
See you in Series 5.
```