# Series 1: FinOps Fundamentals — Unit Economics & Tagging Strategy

## Complete 24-Segment SRT — 2 Hours

---

### SEGMENT 1: Course Introduction & What This Course Is
**Timestamp:** 00:00 – 05:00

```
1
00:00:00,000 --> 00:00:10,000
I want to start with a number that will make you uncomfortable.

2
00:00:10,000 --> 00:00:20,000
Forty-seven thousand dollars. That was the AWS bill of a forty-person startup, every single month.

3
00:00:20,000 --> 00:00:30,000
They thought it was normal. They said, "We're doing real work. We're processing SEC filings. We're running RAG queries. Real work costs real money."

4
00:00:30,000 --> 00:00:40,000
And then I ran an audit. One day. And I found twelve thousand, five hundred and forty-four dollars in monthly waste.

5
00:00:40,000 --> 00:00:50,000
Every single dollar of it was recoverable. Every single dollar of it was the result of not knowing — not of bad engineering, not of reckless spending.

6
00:00:50,000 --> 00:01:00,000
Just not knowing what was happening inside their cloud account. They had never looked. They had never asked the questions we are about to ask together.

7
00:01:00,000 --> 00:01:10,000
By the time we finished all the optimizations you will see in this course, their bill was nineteen thousand, four hundred and four dollars.

8
00:01:10,000 --> 00:01:20,000
From forty-seven thousand to nineteen thousand, four hundred and four. That is twenty-seven thousand, five hundred and ninety-six dollars a month in savings.

9
00:01:20,000 --> 00:01:30,000
That is three hundred and thirty-one thousand, one hundred and fifty-two dollars a year. On a ten-million-dollar raise, that is three point three percent of their funding runway — returned every single year.

10
00:01:30,000 --> 00:01:40,000
Not from cutting features. Not from reducing headcount. Just from knowing what to look at and what to do about it.

11
00:01:40,000 --> 00:01:50,000
This course teaches you how to do that. Not in theory. On real infrastructure. On two real production stacks.

12
00:01:50,000 --> 00:02:00,000
The first is the financial-rag-agent. A production RAG system that answers questions about SEC filings and earnings reports. Large language models, vector databases, GPU instances for embedding generation, high data transfer.

13
00:02:00,000 --> 00:02:10,000
This is the kind of AI workload every startup is building right now. And it is expensive. Understanding how to optimize the cost of a RAG system is one of the highest-value skills in engineering today.

14
00:02:10,000 --> 00:02:20,000
The second stack is riskoracle. An MLOps risk calculation engine that runs GPU batch workloads for financial portfolio risk modeling. Resource-intensive, variable in load, and does not need to run twenty-four hours a day.

15
00:02:20,000 --> 00:02:30,000
Both stacks are on GitHub. You clone them. You deploy them. You break them and optimize them and watch real numbers move in your AWS console.

16
00:02:30,000 --> 00:02:40,000
By the end of eleven series, you will have reduced a real cloud bill by thirty to sixty percent. You will have built an Internal Developer Platform that makes cost optimization automatic for every engineer on your team.

17
00:02:40,000 --> 00:02:50,000
And you will have the unit economics vocabulary to walk into a CTO's office and say — here is exactly what each user action costs us, here is what I changed, and here is the dollar impact.

18
00:02:50,000 --> 00:03:00,000
That conversation — not "the cloud is too expensive" but data, a plan, and a number — is what this course makes possible.

19
00:03:00,000 --> 00:03:10,000
I want to show you something right now. I want you to look at your own AWS bill. Not the total. Look at the line items. How many of them can you actually explain? How many of them do you know are necessary?

20
00:03:10,000 --> 00:03:20,000
Most engineers cannot explain half their bill. And the ones that cannot explain it are paying for things they do not need. That is not a criticism. That is just what happens when you are moving fast.

21
00:03:20,000 --> 00:03:30,000
The same thing happened at that startup. They were moving fast. They were building features. They were shipping code. And nobody was looking at the bill as a system to be optimized.

22
00:03:30,000 --> 00:03:40,000
We are going to change that. By the end of Series 1, you will know exactly what your starting position is. You will have a baseline document that shows your total spend, your top services by cost, your cost by region, and your unit economics placeholder.

23
00:03:40,000 --> 00:03:50,000
That document is your foundation. Every series we add to it. Every series we measure progress against it. By the end of the course, it is your proof of work.

24
00:03:50,000 --> 00:04:00,000
This is the most important file you will create in this entire course. Not because it is code. Because it is evidence. It is the difference between saying "I saved money" and being able to prove it.

25
00:04:00,000 --> 00:04:10,000
Here is what we cover in Series 1. FinOps fundamentals and the three phases. Environment setup. Unit economics. The six required tags. Your first Cost Explorer queries. And your baseline document.

26
00:04:10,000 --> 00:04:20,000
That is the Inform phase of FinOps. You cannot optimize what you cannot see. You cannot fix what you cannot measure. Series 1 is about making the invisible visible.

27
00:04:20,000 --> 00:04:30,000
Before we go any further, I want to say something directly to you. If you are watching this course, you are already ahead of most engineers. Most engineers never look at the bill at all. They just pay it and move on.

28
00:04:30,000 --> 00:04:40,000
By the time we are done, you will not just understand the bill. You will be able to predict it. You will be able to optimize it. You will be able to explain every single line item to your CTO. That is real job security.

29
00:04:40,000 --> 00:04:50,000
The commands we run in this course are not theory. They are the exact same commands I use when I walk into a new client engagement. The exact same commands that found twelve thousand, five hundred and forty-four dollars of waste in one day.

30
00:04:50,000 --> 00:05:00,000
You are not learning concepts. You are inheriting a process. A process that has been refined across more than fifty audits. A process that has saved companies millions of dollars. A process that you are about to apply to your own account.
```

---

### SEGMENT 2: What Is FinOps & The Three Phases
**Timestamp:** 05:00 – 10:00

```
31
00:05:00,000 --> 00:05:10,000
Let me show you the process. First — what is FinOps, and why does it exist?

32
00:05:10,000 --> 00:05:20,000
FinOps is a cloud financial management discipline created by the FinOps Foundation. The companies that practice it — Uber, Spotify, Airbnb, Netflix — do not guess at their cloud costs.

33
00:05:20,000 --> 00:05:30,000
They have dedicated FinOps practitioners, frameworks, and tooling. And they treat cloud cost not as a finance problem but as an engineering problem. Because it is.

34
00:05:30,000 --> 00:05:40,000
FinOps runs on three phases. Inform, Optimize, Operate. And they form a loop — not a checklist.

35
00:05:40,000 --> 00:05:50,000
Phase 1 is Inform. You cannot optimize what you cannot see. You cannot fix what you cannot measure. Inform is entirely about visibility.

36
00:05:50,000 --> 00:06:00,000
Tagging your resources so you know who owns what. Setting up Cost Explorer so you can query your spend. Deploying Kubecost so you can see cost per namespace, per pod, per team.

37
00:06:00,000 --> 00:06:10,000
Knowing — specifically, not approximately — which team spent what on which service in which region at which time of day. Without Inform, everything you do in Optimize is guesswork.

38
00:06:10,000 --> 00:06:20,000
Phase 2 is Optimize. Once you can see the waste, you eliminate it. Rightsizing EC2 instances that are twice as large as they need to be.

39
00:06:20,000 --> 00:06:30,000
Migrating gp2 volumes to gp3 for an instant twenty percent saving with zero downtime. Buying Savings Plans for stable baseline workloads. Running Karpenter to continuously consolidate your EKS nodes.

40
00:06:30,000 --> 00:06:40,000
Phase 3 is Operate. And this is where most courses stop — right before the most important phase. Cloud waste always comes back. Always.

41
00:06:40,000 --> 00:06:50,000
Engineers create new services. New resources spin up without tags. Lifecycle policies get forgotten. A new hire does not know about Spot tolerations. Phase 3 is making sure the waste never comes back.

42
00:06:50,000 --> 00:07:00,000
Budget alerts. Config rules that flag untagged resources automatically. Terraform guardrails that prevent non-compliant infrastructure from being created. An IDP with cost controls baked into every golden path.

43
00:07:00,000 --> 00:07:10,000
Most courses only teach Phase 2. That is why most optimization projects fail. Without Phase 1, you do not know what to optimize. Without Phase 3, the waste creeps back in six months.

44
00:07:10,000 --> 00:07:20,000
This course teaches all three phases, on real EKS workloads, with real tools. You are not learning concepts. You are learning a system.

45
00:07:20,000 --> 00:07:30,000
Now let's meet the two production stacks you will work with throughout this course.

46
00:07:30,000 --> 00:07:40,000
You are not going to learn FinOps on a toy app. You are going to learn it on two real production stacks that represent the kinds of systems engineering teams are actually building in 2026.

47
00:07:40,000 --> 00:07:50,000
The first is the financial-rag-agent. A Retrieval Augmented Generation system that answers questions about financial documents — SEC filings, earnings reports, investor updates.

48
00:07:50,000 --> 00:08:00,000
A user asks a question. The system retrieves relevant financial documents from a vector database. It passes those documents and the question to a large language model. The model generates a grounded answer with citations.

49
00:08:00,000 --> 00:08:10,000
This is the kind of AI workload every startup is building right now. And it is expensive — large language models, vector databases, GPU instances for embedding generation, high data transfer between components.

50
00:08:10,000 --> 00:08:20,000
Understanding how to optimize the cost of a RAG system is one of the highest-value skills in engineering right now. RAG systems are expensive enough that their unit economics can determine whether an AI product is profitable.

51
00:08:20,000 --> 00:08:30,000
We will get the cost per RAG query from zero point zero one six dollars to zero point zero zero nine dollars. That is a forty-two percent reduction.

52
00:08:30,000 --> 00:08:40,000
On a system doing five hundred thousand queries a month, that is three thousand five hundred dollars a month in recovered margin. That is forty-two thousand dollars a year.

53
00:08:40,000 --> 00:08:50,000
The second stack is riskoracle. This is an MLOps risk calculation engine. It processes batch jobs. It runs GPU workloads for risk modeling on financial portfolios.

54
00:08:50,000 --> 00:09:00,000
It is resource-intensive, variable in load, and does not need to run twenty-four hours a day — which makes it perfect for the Spot instance engineering we cover in Series 5.

55
00:09:00,000 --> 00:09:10,000
With the right Spot configuration, riskoracle's training workloads will drop from one thousand one hundred and fifty-two dollars a month to two hundred and eighty-eight dollars. That is seventy-five percent cheaper, with no lost training runs.

56
00:09:10,000 --> 00:09:20,000
Both stacks are on GitHub. The links are in the course materials. Clone them before Series 2. You will need them deployed and running by the time we hit Kubecost in Series 3.

57
00:09:20,000 --> 00:09:30,000
Pull them now. Have a look. We will be inside both of them for the next ten series.

58
00:09:30,000 --> 00:09:40,000
Before we look at cost, we need to make sure your environment is set up correctly. That is what the next five minutes is about.

59
00:09:40,000 --> 00:09:50,000
Every series in this course starts with environment verification. This is not optional. Wrong environment variables mean wrong data, and wrong data means wrong decisions.

60
00:09:50,000 --> 00:10:00,000
You will see this pattern in every series — verify before you touch anything. Production engineers do not guess. They verify.
```

---

### SEGMENT 3: The Two Production Stacks
**Timestamp:** 10:00 – 15:00

```
61
00:10:00,000 --> 00:10:10,000
Step 1. Verify the AWS CLI is installed and your credentials are working.

62
00:10:10,000 --> 00:10:20,000
Type this with me. I will call out the flags as I type.

63
00:10:20,000 --> 00:10:30,000
[Types: aws sts get-caller-identity]
▶ Pronounced as: "AWS, S-T-S, get, caller, identity"

64
00:10:30,000 --> 00:10:40,000
You should see a JSON response with your UserId, your Account ID, and your ARN. Write down your Account ID. You will need it throughout this course.

65
00:10:40,000 --> 00:10:50,000
Now, look at that output. That Account ID is your unique AWS identifier. Every command we run will reference it.

66
00:10:50,000 --> 00:11:00,000
If you see "Unable to locate credentials" — run aws configure and enter your Access Key ID and Secret Access Key.

67
00:11:00,000 --> 00:11:10,000
If you see "Access denied" — attach the AWSBillingReadOnlyAccess and AmazonEC2ReadOnlyAccess policies to your IAM user. You need billing read to query Cost Explorer. You need EC2 read to find resources.

68
00:11:10,000 --> 00:11:20,000
Let me show you something that will make you an expert. Run this command: aws ec2 describe-instances.

69
00:11:20,000 --> 00:11:30,000
If you haven't attached the right policy, you will see an AccessDenied error. Take that error code. Go to the AWS IAM documentation. See how it maps to the policy you are about to apply.

70
00:11:30,000 --> 00:11:40,000
That connection — between the error message and the fix — is what makes you an expert, not just someone who follows commands. When you understand why something failed, you can fix anything.

71
00:11:40,000 --> 00:11:50,000
Now, go to the IAM console. Search for AWSBillingReadOnlyAccess. Attach it to your user. Wait sixty seconds for propagation. Then run the command again. You will see the error disappear.

72
00:11:50,000 --> 00:12:00,000
Step 2. Export your environment variables. These four variables are the foundation for every command we run.

73
00:12:00,000 --> 00:12:10,000
[Types: export ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)]
▶ Pronounced as: "Export, ACCOUNT, underscore, ID, equals, sub-shell, AWS, S-T-S, get, caller, identity, dash, dash, query, Account, dash, dash, output, text"

74
00:12:10,000 --> 00:12:20,000
We are capturing your Account ID into a variable. Think of this as your clipboard for the entire course — we are going to reference this variable hundreds of times, and this prevents the typos that plague manual entry.

75
00:12:20,000 --> 00:12:30,000
[Types: export REGION=us-east-1]
▶ Pronounced as: "Export, REGION, equals, U-S, dash, east, dash, one"

76
00:12:30,000 --> 00:12:40,000
[Types: export START=$(date -d '30 days ago' +%Y-%m-%d)]
▶ Pronounced as: "Export, START, equals, date, dash, D, thirty, days, ago, plus, Y, dash, M, dash, D"

77
00:12:40,000 --> 00:12:50,000
[Types: export END=$(date +%Y-%m-%d)]
▶ Pronounced as: "Export, END, equals, date, plus, Y, dash, M, dash, D"

78
00:12:50,000 --> 00:13:00,000
macOS users: replace date -d '30 days ago' with date -v-30d. Linux users: the command above is correct. This is a common mistake — many engineers copy commands without reading the platform-specific instructions.

79
00:13:00,000 --> 00:13:10,000
Now, look at that output — or rather, verify these are set correctly. Echo account ID. Echo region. Echo start. Echo end.

80
00:13:10,000 --> 00:13:20,000
[Types: echo $ACCOUNT_ID]
[Types: echo $REGION]
[Types: echo $START]
[Types: echo $END]

81
00:13:20,000 --> 00:13:30,000
You should see your twelve-digit account ID, us-east-1, a date thirty days ago, and today's date. If any of these are blank, the export failed. Run each export line individually and check for typos.

82
00:13:30,000 --> 00:13:40,000
Step 3. Add these exports to your shell profile so they persist across sessions.

83
00:13:40,000 --> 00:13:50,000
[Types: echo 'export ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)' >> ~/.bashrc]
[Types: echo 'export REGION=us-east-1' >> ~/.bashrc]
[Types: source ~/.bashrc]

84
00:13:50,000 --> 00:14:00,000
Do not skip this. If you close the terminal and these variables are gone, every command in this course breaks silently with wrong or empty data.

85
00:14:00,000 --> 00:14:10,000
In production, we don't "hope" the variables are set; we "validate" they are set. This is the mindset of a senior engineer. Verification is not optional — it is mandatory.

86
00:14:10,000 --> 00:14:20,000
Environment is verified. Now let's confirm Cost Explorer access and pull your first real number.

87
00:14:20,000 --> 00:14:30,000
This is the most important command in Series 1. Everything that follows is measured against the number it returns.

88
00:14:30,000 --> 00:14:40,000
[Types: aws ce get-cost-and-usage --time-period Start=$START,End=$END --granularity MONTHLY --metrics BlendedCost --query 'ResultsByTime[0].Total.BlendedCost.Amount' --output text]
▶ Pronounced as: "AWS, C-E, get, cost, and, usage, dash, dash, time, period, Start, equals, dollar, START, comma, End, equals, dollar, END, dash, dash, granularity, MONTHLY, dash, dash, metrics, BlendedCost, dash, dash, query, quote, ResultsByTime, open-bracket, zero, close-bracket, dot, Total, dot, BlendedCost, dot, Amount, quote, dash, dash, output, text"

89
00:14:40,000 --> 00:14:50,000
Run it. Write down the number you get. This is your baseline. This is the number you are going to reduce over the next ten series.

90
00:14:50,000 --> 00:15:00,000
A few things to understand about this number. It uses BlendedCost — not UnblendedCost. BlendedCost is what you actually pay after Savings Plans, Reserved Instances, and volume discounts are applied.
```

---

### SEGMENT 4: Environment Setup — AWS CLI & Credentials
**Timestamp:** 15:00 – 20:00

```
91
00:15:00,000 --> 00:15:10,000
UnblendedCost is the list price. Always use BlendedCost for real decision-making. The difference can be twenty to forty percent on accounts with any committed spend.

92
00:15:10,000 --> 00:15:20,000
If you see zero — your Cost Explorer was just enabled and it needs up to twenty-four hours to populate historical data. Run the verify command again tomorrow.

93
00:15:20,000 --> 00:15:30,000
If you see "Access denied" — your IAM user needs the AWSBillingReadOnlyAccess policy. Go to IAM, find your user, attach that policy, and re-run.

94
00:15:30,000 --> 00:15:40,000
If you see a number — any number — you have Cost Explorer access and you are ready to proceed.

95
00:15:40,000 --> 00:15:50,000
Now let's pull the breakdown by service. This tells you where the money is going.

96
00:15:50,000 --> 00:16:00,000
[Types: aws ce get-cost-and-usage --time-period Start=$START,End=$END --granularity MONTHLY --metrics BlendedCost --group-by Type=DIMENSION,Key=SERVICE --query 'ResultsByTime[0].Groups[?Metrics.BlendedCost.Amount > `10`].[Keys[0],Metrics.BlendedCost.Amount]' --output table]
▶ Pronounced as: "AWS, C-E, get, cost, and, usage, dash, dash, time, period, Start, equals, dollar, START, comma, End, equals, dollar, END, dash, dash, granularity, MONTHLY, dash, dash, metrics, BlendedCost, dash, dash, group-by, Type, equals, DIMENSION, comma, Key, equals, SERVICE..."

97
00:16:00,000 --> 00:16:10,000
Look at this output carefully. EC2 should be your biggest line item — that is normal for EKS workloads.

98
00:16:10,000 --> 00:16:20,000
If NAT Gateway is in your top five, that is a flag — we fix it in Series 2 with VPC Endpoints. If RDS is top three, check for dev databases running twenty-four-seven — we fix that in Series 6.

99
00:16:20,000 --> 00:16:30,000
If you see spend in regions you do not recognize — someone left resources in the wrong region. We find and clean those up in Series 2 as well.

100
00:16:30,000 --> 00:16:40,000
Save this output. It is the first entry in your baseline document. We will append to it throughout the series.

101
00:16:40,000 --> 00:16:50,000
Now — the concept that separates senior engineers from the rest. Unit economics.

102
00:16:50,000 --> 00:17:00,000
Your AWS bill is a number. It might be eight thousand four hundred or forty-seven thousand or one hundred and eighty thousand. That number, on its own, tells you almost nothing.

103
00:17:00,000 --> 00:17:10,000
It does not tell you if you are efficient. It does not tell you if a new feature made things better or worse. It does not give you anything you can act on.

104
00:17:10,000 --> 00:17:20,000
Unit economics gives you something you can act on. The question is: what does one unit of your business cost?

105
00:17:20,000 --> 00:17:30,000
For a RAG application, one unit is one RAG query — one question answered. For an API service, one unit is one API call. For a batch processing system, one unit is one job execution.

106
00:17:30,000 --> 00:17:40,000
Find your unit. Everything follows from that. The formula is simple.

107
00:17:40,000 --> 00:17:50,000
Cost per unit equals total monthly infrastructure cost divided by the number of units processed that month.

108
00:17:50,000 --> 00:18:00,000
For the financial-rag-agent client I mentioned at the start: eight thousand four hundred dollars per month divided by five hundred thousand RAG queries equals zero point zero one six eight dollars per query.

109
00:18:00,000 --> 00:18:10,000
One point six eight cents per question answered. Now you have something.

110
00:18:10,000 --> 00:18:20,000
If you charge ten cents per query, your margin is eighty-three percent. If you charge two cents, your margin is sixteen percent — and one infrastructure accident puts you underwater.

111
00:18:20,000 --> 00:18:30,000
That number changes every decision you make about what to optimize first.

112
00:18:30,000 --> 00:18:40,000
Here is how to calculate it for your workload. First, get your total monthly cost. We already have that from the Cost Explorer query.

113
00:18:40,000 --> 00:18:50,000
Second, get your query count from CloudWatch. If you don't have CloudWatch metrics yet — we set those up in Series 8. Understand the concept now. Apply the number later.

114
00:18:50,000 --> 00:19:00,000
Every decision in this course should be evaluated against your unit cost. Every rightsizing, every Karpenter consolidation, every Spot instance migration.

115
00:19:00,000 --> 00:19:10,000
The question is always: how does this change my cost per unit? After all optimizations in this course: zero point zero one six eight becomes zero point zero zero nine eight.

116
00:19:10,000 --> 00:19:20,000
A forty-two percent reduction. On five hundred thousand queries a month, that is three thousand five hundred dollars recovered every single month.

117
00:19:20,000 --> 00:19:30,000
Without tags, you cannot do unit economics. You cannot attribute cost. You cannot do FinOps. The next segment is about the six tags that make everything possible.

118
00:19:30,000 --> 00:19:40,000
Without tags, Cost Explorer can tell you that EC2 cost twenty-two thousand dollars this month. It cannot tell you which team spent it. It cannot tell you which service drove the spike on the fourteenth.

119
00:19:40,000 --> 00:19:50,000
It cannot tell you who to call when a number doubles unexpectedly. Tags solve all of this. Six tags. Every resource. No exceptions.

120
00:19:50,000 --> 00:20:00,000
The first is Environment. Values: production, staging, development, test. This separates your production spend from test spend — so you know whether the spike was in prod or someone's dev environment.
```

---

### SEGMENT 5: First Cost Explorer Query & Your Baseline Number
**Timestamp:** 20:00 – 25:00

```
121
00:20:00,000 --> 00:20:10,000
This is the most common tag that teams apply inconsistently. If you have one resource tagged staging and another tagged Staging with a capital S, Cost Explorer sees two different values.

122
00:20:10,000 --> 00:20:20,000
Standardize the casing. Use lowercase. Enforce it with Config rules. This one standardization saves hours of confusion in cost analysis.

123
00:20:20,000 --> 00:20:30,000
The second is Team. Values: financial-rag, riskoracle, platform. This is your chargeback dimension. Which team spent what.

124
00:20:30,000 --> 00:20:40,000
When you have ten teams, this tag is what makes the monthly cost review conversation specific rather than collective. Specific accountability produces action. Collective accountability produces nothing.

125
00:20:40,000 --> 00:20:50,000
The third is Service. Values: llm-ingest, risk-calc, api-gateway. Granular attribution per microservice.

126
00:20:50,000 --> 00:21:00,000
When your financial-rag namespace costs twenty-two thousand dollars, Service tells you that fourteen thousand of that is the llm-ingest deployment — not the retrieval service, not the API layer.

127
00:21:00,000 --> 00:21:10,000
That specificity is what turns a twenty-two-thousand-dollar problem into a fourteen-thousand-dollar problem with a known root cause.

128
00:21:10,000 --> 00:21:20,000
The fourth is ManagedBy. Values: terraform, kubecost, manual. This tells you how a resource was created and how to modify it.

129
00:21:20,000 --> 00:21:30,000
If it says terraform — find the .tf file and change it there, not in the console. If it says manual — that is a flag for technical debt. Manual resources are the ones that get forgotten and accumulate cost.

130
00:21:30,000 --> 00:21:40,000
The fifth is CostCenter. Values: engineering, data-science, product. This is your finance reporting dimension. It rolls up to your accounting system.

131
00:21:40,000 --> 00:21:50,000
Your CFO cares about CostCenter. Your CTO cares about Team. Both use the same tags. That alignment is rare and powerful. It bridges the gap between engineering and finance.

132
00:21:50,000 --> 00:22:00,000
The sixth is Owner. Values: an email address. One person. The person who is responsible for this resource and who you ping when it needs to be reviewed or cleaned up.

133
00:22:00,000 --> 00:22:10,000
Six tags. Every resource. Always. The moment you allow one untagged resource, you lose the ability to trust your data.

134
00:22:10,000 --> 00:22:20,000
I have seen startups tag ninety-nine percent of their resources, feel great — and then discover the untagged one percent accounts for twenty percent of their spend.

135
00:22:20,000 --> 00:22:30,000
One untagged EC2 instance with a GPU. Eight hundred dollars a month. Completely invisible. One untagged S3 bucket with fifteen terabytes of old data. Nine hundred dollars a month. Completely invisible.

136
00:22:30,000 --> 00:22:40,000
One untagged RDS database running twenty-four-seven. Four hundred dollars a month. Completely invisible. That is why every resource gets every tag. No exceptions. No shortcuts.

137
00:22:40,000 --> 00:22:50,000
Now let's apply these tags. First — activate them for cost allocation, then find everything that is currently untagged.

138
00:22:50,000 --> 00:23:00,000
Before Cost Explorer can filter by tag, you need to activate the tags for cost allocation. One-time setup. Takes thirty seconds.

139
00:23:00,000 --> 00:23:10,000
[Types: for tag in Environment Team Service ManagedBy CostCenter Owner; do aws ce update-cost-allocation-tags-status --cost-allocation-tags-status TagKey=$tag,Status=Active; echo "Activated: $tag"; done]
▶ Pronounced as: "For, tag, in, Environment, Team, Service, ManagedBy, CostCenter, Owner, semicolon, do, AWS, C-E, update, cost, allocation, tags, status..."

140
00:23:10,000 --> 00:23:20,000
Good. Now let's find everything that is currently untagged. Start with EC2.

141
00:23:20,000 --> 00:23:30,000
[Types: aws ec2 describe-instances --query 'Reservations[].Instances[?!Tags || length(Tags)==`0`].{ID:InstanceId,Type:InstanceType,State:State.Name}' --output table]
▶ Pronounced as: "AWS, E-C-two, describe, instances, dash, dash, query..."

142
00:23:30,000 --> 00:23:40,000
If this returns more than three rows, your cost allocation is broken. Every row here is a dollar amount you cannot attribute. Each row is a gap in your visibility.

143
00:23:40,000 --> 00:23:50,000
Now S3 buckets — these require a different approach because S3 uses a separate tagging API.

144
00:23:50,000 --> 00:24:00,000
[Types: aws s3api list-buckets --query 'Buckets[].Name' --output text | tr '\t' '\n' | while read b; do tags=$(aws s3api get-bucket-tagging --bucket $b 2>/dev/null | jq '.TagSet | length'); if [[ $tags == '0' || -z $tags ]]; then echo "UNTAGGED S3 BUCKET: $b"; fi; done]
▶ Pronounced as: "AWS, S-three, API, list, buckets..."

145
00:24:00,000 --> 00:24:10,000
S3 buckets are often the most overlooked. They accumulate data silently and cost grows without anyone noticing. Tags on S3 buckets are how you know who to ask when the storage bill doubles.

146
00:24:10,000 --> 00:24:20,000
Now EBS volumes — often the most forgotten:

147
00:24:20,000 --> 00:24:30,000
[Types: aws ec2 describe-volumes --query 'Volumes[?!Tags || length(Tags)==`0`].{ID:VolumeId,Size:Size,Type:VolumeType}' --output table]
▶ Pronounced as: "AWS, E-C-two, describe, volumes..."

148
00:24:30,000 --> 00:24:40,000
EBS volumes are forgotten because they are attached to instances that may have been terminated. The volume remains, billing you every month, with no owner.

149
00:24:40,000 --> 00:24:50,000
And RDS instances:

150
00:24:50,000 --> 00:25:00,000
[Types: aws rds describe-db-instances --query 'DBInstances[?!TagList || length(TagList)==`0`].{ID:DBInstanceIdentifier,Class:DBInstanceClass,Engine:Engine}' --output table]
▶ Pronounced as: "AWS, R-D-S, describe, DB, instances..."
```

---

### SEGMENT 6: Unit Economics — The Formula That Changes Everything
**Timestamp:** 25:00 – 30:00

```
151
00:25:00,000 --> 00:25:10,000
Run all four. Write down the total number of untagged resources. That count is the depth of your attribution gap. We are going to close it entirely in the next segment.

152
00:25:10,000 --> 00:25:20,000
Tagging resources one by one in the AWS console is how you waste a week. We do it with scripts. Tag everything at once, then refine later.

153
00:25:20,000 --> 00:25:30,000
A word before we run these: the bulk scripts apply placeholder values — Team=unknown, Service=unknown. That is intentional. We are establishing the tag structure first.

154
00:25:30,000 --> 00:25:40,000
You will go back after and update specific resources with their real team and service values. Unknown is not useful for attribution — but it is better than no tag.

155
00:25:40,000 --> 00:25:50,000
It tells you that a resource has been tagged and needs to be refined, rather than looking identical to resources you simply missed.

156
00:25:50,000 --> 00:26:00,000
Bulk tag EC2 instances:

157
00:26:00,000 --> 00:26:10,000
[Types: aws ec2 describe-instances --query 'Reservations[].Instances[].InstanceId' --output text | tr '\t' '\n' | while read id; do aws ec2 create-tags --resources $id --tags Key=Environment,Value=production Key=Team,Value=unknown Key=Service,Value=unknown Key=ManagedBy,Value=finops Key=CostCenter,Value=engineering Key=Owner,Value=finops@yourcompany.com; echo "Tagged EC2: $id"; done]
▶ Pronounced as: "AWS, E-C-two, describe, instances... pipe, while, read..."

158
00:26:10,000 --> 00:26:20,000
This script finds every EC2 instance in your account and applies all six tags. The placeholder values are a starting point. You will refine them later.

159
00:26:20,000 --> 00:26:30,000
Bulk tag EBS volumes:

160
00:26:30,000 --> 00:26:40,000
[Types: aws ec2 describe-volumes --query 'Volumes[].VolumeId' --output text | tr '\t' '\n' | while read id; do aws ec2 create-tags --resources $id --tags Key=Environment,Value=production Key=Team,Value=unknown Key=Service,Value=unknown Key=ManagedBy,Value=finops Key=CostCenter,Value=engineering Key=Owner,Value=finops@yourcompany.com; echo "Tagged EBS: $id"; done]
▶ Pronounced as: "AWS, E-C-two, describe, volumes... pipe, while, read..."

161
00:26:40,000 --> 00:26:50,000
RDS uses a different command because it requires an ARN rather than a resource ID:

162
00:26:50,000 --> 00:27:00,000
[Types: aws rds describe-db-instances --query 'DBInstances[].DBInstanceArn' --output text | tr '\t' '\n' | while read arn; do aws rds add-tags-to-resource --resource-name $arn --tags Key=Environment,Value=production Key=Team,Value=unknown Key=Service,Value=unknown Key=ManagedBy,Value=finops Key=CostCenter,Value=engineering Key=Owner,Value=finops@yourcompany.com; echo "Tagged RDS: $arn"; done]
▶ Pronounced as: "AWS, R-D-S, describe, DB, instances... pipe, while, read..."

163
00:27:00,000 --> 00:27:10,000
Run all three. Watch the output. Every confirmation line is one fewer unattributed resource. Each line is a step toward full visibility.

164
00:27:10,000 --> 00:27:20,000
Tags applied. Now we automate enforcement so new resources can never be created without them.

165
00:27:20,000 --> 00:27:30,000
The bulk tagging scripts fixed the past. This Config rule fixes the future. Without enforcement, the next engineer who provisions an EC2 instance will do it without tags, and we are back to square one.

166
00:27:30,000 --> 00:27:40,000
AWS Config has a built-in rule called REQUIRED_TAGS. When applied, it continuously evaluates every resource in your account against a list of required tag keys.

167
00:27:40,000 --> 00:27:50,000
Any resource missing one of the required tags is flagged as NON_COMPLIANT. You can then build notifications, remediation actions, or just use it as a weekly compliance report.

168
00:27:50,000 --> 00:28:00,000
[Types: aws configservice put-config-rule --config-rule '{"Name":"finops-required-tags","Description":"Enforces six required tags on all resources","Source":{"Owner":"AWS","SourceIdentifier":"REQUIRED_TAGS"},"InputParameters":"{\"tag1Key\":\"Environment\",\"tag2Key\":\"Team\",\"tag3Key\":\"Service\",\"tag4Key\":\"ManagedBy\",\"tag5Key\":\"CostCenter\",\"tag6Key\":\"Owner\"}","Scope":{"ComplianceResourceTypes":["AWS::EC2::Instance","AWS::EC2::Volume","AWS::RDS::DBInstance","AWS::S3::Bucket","AWS::ElasticLoadBalancingV2::LoadBalancer"]}}']
▶ Pronounced as: "AWS, ConfigService, put, config, rule..."

169
00:28:00,000 --> 00:28:10,000
This Config rule is your insurance policy. It does not prevent resources from being created — but it flags them immediately. You can build a remediation pipeline that automatically applies default tags or notifies the owner.

170
00:28:10,000 --> 00:28:20,000
Check compliance after the rule evaluates. It takes a few minutes to run the first evaluation.

171
00:28:20,000 --> 00:28:30,000
[Types: aws configservice get-compliance-summary-by-config-rule --config-rule-names finops-required-tags]
▶ Pronounced as: "AWS, ConfigService, get, compliance, summary, by, config, rule..."

172
00:28:30,000 --> 00:28:40,000
What you want to see: COMPLIANT count going up, NON_COMPLIANT count going to zero. What you almost certainly see today: a lot of NON_COMPLIANT.

173
00:28:40,000 --> 00:28:50,000
That is your to-do list for the week. Each NON_COMPLIANT resource is an attribution gap. Each one is a dollar you cannot track.

174
00:28:50,000 --> 00:29:00,000
In Series 7, when we build the IDP, new services created through the platform will automatically have all six tags applied. The Config rule will flag anything that goes around the platform.

175
00:29:00,000 --> 00:29:10,000
At that point, NON_COMPLIANT becomes a signal for shadow infrastructure — something created outside the approved path, which is a security concern as much as a cost concern.

176
00:29:10,000 --> 00:29:20,000
Set up a weekly email report from Config notifications. Fifteen minutes a week reviewing this report is worth more than a full day of retrospective cost analysis.

177
00:29:20,000 --> 00:29:30,000
Now let's look at cost by region — and find anything hiding in regions you do not know about.

178
00:29:30,000 --> 00:29:40,000
Cost by region is the query that finds the things you forgot about. When an engineer spins up a test instance in the wrong region — us-west-2 instead of us-east-1 — it does not appear in your normal monitoring.

179
00:29:40,000 --> 00:29:50,000
It runs. It bills. Nobody notices until the audit. Pull your cost by region:

180
00:29:50,000 --> 00:30:00,000
[Types: aws ce get-cost-and-usage --time-period Start=$START,End=$END --granularity MONTHLY --metrics BlendedCost --group-by Type=DIMENSION,Key=REGION --query 'ResultsByTime[0].Groups[].[Keys[0],Metrics.BlendedCost.Amount]' --output table]
▶ Pronounced as: "AWS, C-E, get, cost, and, usage... group-by, Type, equals, DIMENSION, comma, Key, equals, REGION"
```

---

### SEGMENT 7: The Six Required Tags — Why Tagging Is Non-Negotiable
**Timestamp:** 30:00 – 35:00

```
181
00:30:00,000 --> 00:30:10,000
If every dollar is in us-east-1 — good. If you see spend in regions you do not use, run this scan immediately:

182
00:30:10,000 --> 00:30:20,000
[Types: for region in us-west-1 us-west-2 eu-west-1 eu-central-1 ap-southeast-1 ap-northeast-1; do count=$(aws ec2 describe-instances --region $region --query 'length(Reservations[].Instances[])' --output text 2>/dev/null || echo 0); if [ "$count" -gt "0" ]; then echo "⚠️  $count instance(s) found in $region"; aws ec2 describe-instances --region $region --query 'Reservations[].Instances[].[InstanceId,InstanceType,State.Name,Tags[?Key==`Name`].Value|[0]]' --output table; fi; done]
▶ Pronounced as: "For, region, in, us-west-one, us-west-two..."

183
00:30:20,000 --> 00:30:30,000
For each stray resource: identify it, find the owner, decide — migrate, snapshot and delete, or tag and track. Never ignore a stray resource.

184
00:30:30,000 --> 00:30:40,000
A zero point zero two dollar per hour test instance in the wrong region is fourteen dollars forty a month for nothing. Multiply that by the number of engineers who have ever had console access and the number climbs fast.

185
00:30:40,000 --> 00:30:50,000
Add this scan to your monthly FinOps review. It takes thirty seconds and catches a category of waste that almost nothing else surfaces.

186
00:30:50,000 --> 00:31:00,000
Based on real audits across fifty-plus startups, here is what the waste looks like by category. These are averages. Your numbers will differ.

187
00:31:00,000 --> 00:31:10,000
But the pattern is consistent enough that I can tell you, before running a single command, that your biggest opportunities are almost certainly in EC2 overprovisioning, gp2 volumes, and NAT Gateway traffic — in that order.

188
00:31:10,000 --> 00:31:20,000
Overprovisioned EC2 — twenty-five to forty percent of compute cost. Engineers provision instances at their peak estimate and never revisit them. Kubecost in Series 3 surfaces this exactly. Karpenter in Series 4 fixes it continuously.

189
00:31:20,000 --> 00:31:30,000
gp2 versus gp3 volumes — twenty percent of EBS cost. One command. Zero downtime. We do this in Series 2. This is the highest-return action per minute of engineering work in this entire course.

190
00:31:30,000 --> 00:31:40,000
Unattached Elastic IPs — three dollars sixty-five per IP per month, every month, for doing absolutely nothing. We find and release them in Series 2.

191
00:31:40,000 --> 00:31:50,000
NAT Gateway traffic — thirty to fifty percent of data transfer cost. S3 and DynamoDB traffic going through NAT when it should go through VPC Endpoints. Zero-cost fix. Series 2.

192
00:31:50,000 --> 00:32:00,000
RDS overprovisioning — twenty to thirty percent of database cost. Dev databases running twenty-four hours a day, seven days a week. Stop-start schedules in Series 6.

193
00:32:00,000 --> 00:32:10,000
S3 without lifecycle policies — forty to sixty percent of S3 cost on data older than ninety days. Automated lifecycle rules in Series 6.

194
00:32:10,000 --> 00:32:20,000
Total typical savings: thirty to sixty percent of total cloud spend. Not after a year of work. After this course. On infrastructure you already have, without building anything new.

195
00:32:20,000 --> 00:32:30,000
Write down your top three services from the Cost Explorer query we ran earlier. Those three services are where you will focus in Series 2. The biggest opportunities are almost always in that list.

196
00:32:30,000 --> 00:32:40,000
Before we end Series 1, we create the baseline document. This is the file you will update after every series and present to your CTO when the course is complete.

197
00:32:40,000 --> 00:32:50,000
The baseline document is your evidence file. It is how you prove that what you did in this course produced real results.

198
00:32:50,000 --> 00:33:00,000
Without it, you have a lower bill but no story. With it, you have a CTO-ready report that shows exactly what was spent, when, what changed, and what the delta was.

199
00:33:00,000 --> 00:33:10,000
Create it now. We already started it in Part 1. Now we complete it.

200
00:33:10,000 --> 00:33:20,000
[Types: touch ~/finops-baseline.txt]
"We create or touch the baseline document. This will be our source of truth throughout the course."

201
00:33:20,000 --> 00:33:30,000
[Types: echo "=== FINOPS BASELINE REPORT ===" >> ~/finops-baseline.txt]
[Types: echo "Date: $(date)" >> ~/finops-baseline.txt]
[Types: echo "Account: $ACCOUNT_ID" >> ~/finops-baseline.txt]
[Types: echo "" >> ~/finops-baseline.txt]

202
00:33:30,000 --> 00:33:40,000
[Types: echo "=== TOTAL MONTHLY SPEND ===" >> ~/finops-baseline.txt]
[Types: aws ce get-cost-and-usage --time-period Start=$START,End=$END --granularity MONTHLY --metrics BlendedCost --query 'ResultsByTime[0].Total.BlendedCost.Amount' --output text >> ~/finops-baseline.txt]
[Types: echo "" >> ~/finops-baseline.txt]

203
00:33:40,000 --> 00:33:50,000
[Types: echo "=== TOP 10 SERVICES BY COST ===" >> ~/finops-baseline.txt]
[Types: aws ce get-cost-and-usage --time-period Start=$START,End=$END --granularity MONTHLY --metrics BlendedCost --group-by Type=DIMENSION,Key=SERVICE --query 'ResultsByTime[0].Groups[?Metrics.BlendedCost.Amount > `10`].[Keys[0],Metrics.BlendedCost.Amount]' --output table >> ~/finops-baseline.txt]
[Types: echo "" >> ~/finops-baseline.txt]

204
00:33:50,000 --> 00:34:00,000
[Types: echo "=== COST BY REGION ===" >> ~/finops-baseline.txt]
[Types: aws ce get-cost-and-usage --time-period Start=$START,End=$END --granularity MONTHLY --metrics BlendedCost --group-by Type=DIMENSION,Key=REGION --query 'ResultsByTime[0].Groups[].[Keys[0],Metrics.BlendedCost.Amount]' --output table >> ~/finops-baseline.txt]
[Types: echo "" >> ~/finops-baseline.txt]

205
00:34:00,000 --> 00:34:10,000
[Types: echo "=== TAGGING STATUS ===" >> ~/finops-baseline.txt]
[Types: echo "Six required tags activated: Environment, Team, Service, ManagedBy, CostCenter, Owner" >> ~/finops-baseline.txt]
[Types: echo "AWS Config rule 'finops-required-tags' created and enforcing tagging" >> ~/finops-baseline.txt]
[Types: echo "" >> ~/finops-baseline.txt]

206
00:34:10,000 --> 00:34:20,000
[Types: echo "=== UNIT ECONOMICS ===" >> ~/finops-baseline.txt]
[Types: echo "Cost per RAG query: TBD (Series 8 — requires CloudWatch metrics)" >> ~/finops-baseline.txt]
[Types: echo "Cost per API call: TBD (Series 8)" >> ~/finops-baseline.txt]
[Types: echo "" >> ~/finops-baseline.txt]

207
00:34:20,000 --> 00:34:30,000
[Types: echo "=== NOTES FOR SERIES 2 ===" >> ~/finops-baseline.txt]
[Types: echo "Run the complete cloud cost audit to find hidden waste" >> ~/finops-baseline.txt]
[Types: echo "Focus on: gp2 volumes, unattached EIPs, stopped instances, NAT Gateway, S3 lifecycle" >> ~/finops-baseline.txt]

208
00:34:30,000 --> 00:34:40,000
[Types: cat ~/finops-baseline.txt]
Now, look at that output. You should see all sections with real data from your account. This is your complete baseline document.

209
00:34:40,000 --> 00:34:50,000
[Types: echo "=== SERIES 1 COMPLETE ===" >> ~/finops-baseline.txt]
[Types: echo "Date completed: $(date)" >> ~/finops-baseline.txt]

210
00:34:50,000 --> 00:35:00,000
This file will have new sections appended after every series. By Series 11, it will show the complete journey — from your starting bill to your optimized bill, series by series, with the dollar delta at each step.
```

---

### SEGMENT 8: Activating Tags & Finding Untagged Resources
**Timestamp:** 35:00 – 40:00

```
211
00:35:00,000 --> 00:35:10,000
That document is the proof of work for everything we are about to build. It is the difference between saying "I saved money" and being able to prove it.

212
00:35:10,000 --> 00:35:20,000
Now let me recap what you built in Series 1.

213
00:35:20,000 --> 00:35:30,000
AWS environment verified and environment variables set. Cost Explorer baseline pulled — you have your starting number. Six required tags defined and activated for cost allocation.

214
00:35:30,000 --> 00:35:40,000
Untagged resources found across EC2, EBS, S3, and RDS. Bulk tagging scripts applied to close the attribution gap. Config rule deployed to enforce tags on every new resource going forward.

215
00:35:40,000 --> 00:35:50,000
Top services and regions identified. Baseline document created and saved. That is the Inform phase foundation.

216
00:35:50,000 --> 00:36:00,000
Without it, everything in Series 2 through 10 is guesswork. With it, every optimization is measurable.

217
00:36:00,000 --> 00:36:10,000
Before starting Series 2, verify these four things. Run aws sts get-caller-identity and confirm it returns your account ID.

218
00:36:10,000 --> 00:36:20,000
Run echo $START and confirm it shows a date thirty days ago. Run cat ~/finops-baseline.txt and confirm it has your total monthly spend. Run the Cost Explorer service query and confirm you see real data.

219
00:36:20,000 --> 00:36:30,000
Series 2 is the cloud cost audit. We stop talking about waste and start finding it — with real commands, real numbers, and real dollar amounts from your own account.

220
00:36:30,000 --> 00:36:40,000
In Series 2 you will find and fix: gp2 volumes that cost twenty percent more than gp3 — zero downtime migration, one command.

221
00:36:40,000 --> 00:36:50,000
Unattached Elastic IPs charging you three dollars sixty-five each per month for doing nothing. Stopped instances still paying for their EBS volumes.

222
00:36:50,000 --> 00:37:00,000
NAT Gateway traffic that should be free via VPC Endpoints. Cost anomaly detection that runs forever and catches spikes before they become invoices.

223
00:37:00,000 --> 00:37:10,000
By the end of Series 2, you will have a list of actual dollar amounts of waste — not estimated, not projected — from your own account, and every fix applied.

224
00:37:10,000 --> 00:37:20,000
You are not just learning about FinOps. You are doing FinOps. On your own account. With real money. And you are going to see the results on your next bill.

225
00:37:20,000 --> 00:37:30,000
That is the difference between this course and every other FinOps course you have ever taken. Every other course teaches concepts. This course teaches a process. And that process produces a result.

226
00:37:30,000 --> 00:37:40,000
The commands work. The savings are real. You just have to do the work.

227
00:37:40,000 --> 00:37:50,000
But before you leave Series 1, I want to give you one more thing.

228
00:37:50,000 --> 00:38:00,000
I want to give you a mental framework that will help you think about cost optimization in every decision you make going forward. It is called the Cost-Aware Engineering Mindset.

229
00:38:00,000 --> 00:38:10,000
Cost-Aware Engineering is not about being cheap. It is not about choosing the lowest-cost option every time. It is about knowing the cost of your choices so you can make informed trade-offs.

230
00:38:10,000 --> 00:38:20,000
When you choose a larger instance type, do you know what it costs you? When you choose a more expensive region, do you know the impact? When you leave a test environment running over the weekend, do you know what you are burning?

231
00:38:20,000 --> 00:38:30,000
The baseline document you just created is the first step. It is your cost-awareness anchor. Every time you make a change, you measure it against that baseline. Every time you deploy a new service, you estimate its cost. Every time you choose an architecture, you evaluate its unit economics.

232
00:38:30,000 --> 00:38:40,000
This is how senior engineers think. They do not avoid cost — they understand it. They do not fear cost — they manage it. They do not ignore cost — they optimize it.

233
00:38:40,000 --> 00:38:50,000
You are now on that path. The commands you ran today are not just commands — they are the foundation of a new way of engineering.

234
00:38:50,000 --> 00:39:00,000
Series 1 is complete. The foundation is laid. In Series 2, we start finding the waste. And in Series 3 through 11, we build a platform that makes cost optimization automatic.

235
00:39:00,000 --> 00:39:10,000
But remember: every journey starts with a single step. You just took that step. The baseline number you wrote down is your starting line. The document you created is your evidence. The tags you applied are your visibility.

236
00:39:10,000 --> 00:39:20,000
Now you are ready for what comes next. Series 2 begins now.
```

---

### SEGMENT 9: Bulk Tagging Scripts — Tag Everything At Once
**Timestamp:** 40:00 – 45:00

```
237
00:40:00,000 --> 00:40:10,000
Welcome to Segment 9. We are going to tag everything at once.

238
00:40:10,000 --> 00:40:20,000
In the previous segment, you found all the untagged resources. You saw the gap in your visibility. Now you close that gap.

239
00:40:20,000 --> 00:40:30,000
Tagging resources one by one in the AWS console is how you waste a week. We do it with scripts. Tag everything at once, then refine later.

240
00:40:30,000 --> 00:40:40,000
A word before we run these: the bulk scripts apply placeholder values — Team=unknown, Service=unknown. That is intentional. We are establishing the tag structure first.

241
00:40:40,000 --> 00:40:50,000
You will go back after and update specific resources with their real team and service values. Unknown is not useful for attribution — but it is better than no tag.

242
00:40:50,000 --> 00:41:00,000
It tells you that a resource has been tagged and needs to be refined, rather than looking identical to resources you simply missed.

243
00:41:00,000 --> 00:41:10,000
Let's run the bulk tagging scripts now.

244
00:41:10,000 --> 00:41:20,000
Bulk tag EC2 instances:

245
00:41:20,000 --> 00:41:30,000
[Types: aws ec2 describe-instances --query 'Reservations[].Instances[].InstanceId' --output text | tr '\t' '\n' | while read id; do aws ec2 create-tags --resources $id --tags Key=Environment,Value=production Key=Team,Value=unknown Key=Service,Value=unknown Key=ManagedBy,Value=finops Key=CostCenter,Value=engineering Key=Owner,Value=finops@yourcompany.com; echo "Tagged EC2: $id"; done]
▶ Pronounced as: "AWS, E-C-two, describe, instances... pipe, while, read..."

246
00:41:30,000 --> 00:41:40,000
This script finds every EC2 instance in your account and applies all six tags. The placeholder values are a starting point. You will refine them later.

247
00:41:40,000 --> 00:41:50,000
Bulk tag EBS volumes:

248
00:41:50,000 --> 00:42:00,000
[Types: aws ec2 describe-volumes --query 'Volumes[].VolumeId' --output text | tr '\t' '\n' | while read id; do aws ec2 create-tags --resources $id --tags Key=Environment,Value=production Key=Team,Value=unknown Key=Service,Value=unknown Key=ManagedBy,Value=finops Key=CostCenter,Value=engineering Key=Owner,Value=finops@yourcompany.com; echo "Tagged EBS: $id"; done]
▶ Pronounced as: "AWS, E-C-two, describe, volumes... pipe, while, read..."

249
00:42:00,000 --> 00:42:10,000
RDS uses a different command because it requires an ARN rather than a resource ID:

250
00:42:10,000 --> 00:42:20,000
[Types: aws rds describe-db-instances --query 'DBInstances[].DBInstanceArn' --output text | tr '\t' '\n' | while read arn; do aws rds add-tags-to-resource --resource-name $arn --tags Key=Environment,Value=production Key=Team,Value=unknown Key=Service,Value=unknown Key=ManagedBy,Value=finops Key=CostCenter,Value=engineering Key=Owner,Value=finops@yourcompany.com; echo "Tagged RDS: $arn"; done]
▶ Pronounced as: "AWS, R-D-S, describe, DB, instances... pipe, while, read..."

251
00:42:20,000 --> 00:42:30,000
Run all three. Watch the output. Every confirmation line is one fewer unattributed resource. Each line is a step toward full visibility.

252
00:42:30,000 --> 00:42:40,000
After the scripts finish, you will have no more untagged EC2 instances. No more untagged EBS volumes. No more untagged RDS instances. S3 buckets are covered as well.

253
00:42:40,000 --> 00:42:50,000
Is every resource now perfectly attributed? No. The placeholder values are still there. But now every resource has a tag structure that can be refined.

254
00:42:50,000 --> 00:43:00,000
The difference between no tag and a placeholder tag is massive. No tag means the resource is invisible. A placeholder tag means you know it exists and you know it needs attention.

255
00:43:00,000 --> 00:43:10,000
Now that the scripts have run, let's verify the work. Run the untagged resource queries again and confirm they return zero rows.

256
00:43:10,000 --> 00:43:20,000
[Types: aws ec2 describe-instances --query 'Reservations[].Instances[?!Tags || length(Tags)==`0`].InstanceId' --output text]
[Types: aws ec2 describe-volumes --query 'Volumes[?!Tags || length(Tags)==`0`].VolumeId' --output text]
[Types: aws rds describe-db-instances --query 'DBInstances[?!TagList || length(TagList)==`0`].DBInstanceIdentifier' --output text]

257
00:43:20,000 --> 00:43:30,000
If any of these return rows, investigate why those resources were not tagged. It could be a permission issue, a resource type not covered, or a resource created after the script ran.

258
00:43:30,000 --> 00:43:40,000
You now have a fully tagged environment. Every resource is attributed. This is the foundation of cost visibility.

259
00:43:40,000 --> 00:43:50,000
And here is the key: you only have to do this once. The Config rule will prevent future untagged resources. The bulk tagging was a one-time cleanup.

260
00:43:50,000 --> 00:44:00,000
From now on, every new resource will have tags from the moment it is created. Your visibility will never degrade again.

261
00:44:00,000 --> 00:44:10,000
That is the power of automation. You fixed the past and the future at the same time.

262
00:44:10,000 --> 00:44:20,000
Now you can confidently query Cost Explorer by tag. You can see cost by team. You can see cost by service. You can see cost by environment.

263
00:44:20,000 --> 00:44:30,000
This is what the Inform phase looks like when it is complete. Complete visibility. Complete attribution. Complete control.

264
00:44:30,000 --> 00:44:40,000
In the next segment, we automate enforcement so this state never degrades.

265
00:44:40,000 --> 00:44:50,000
See you in Segment 10.
```

---

### SEGMENT 10: AWS Config Rule — Tag Enforcement Automation
**Timestamp:** 45:00 – 50:00

```
266
00:45:00,000 --> 00:45:10,000
The bulk tagging scripts fixed the past. This Config rule fixes the future.

267
00:45:10,000 --> 00:45:20,000
Without enforcement, the next engineer who provisions an EC2 instance will do it without tags, and we are back to square one.

268
00:45:20,000 --> 00:45:30,000
AWS Config has a built-in rule called REQUIRED_TAGS. When applied, it continuously evaluates every resource in your account against a list of required tag keys.

269
00:45:30,000 --> 00:45:40,000
Any resource missing one of the required tags is flagged as NON_COMPLIANT. You can then build notifications, remediation actions, or just use it as a weekly compliance report.

270
00:45:40,000 --> 00:45:50,000
[Types: aws configservice put-config-rule --config-rule '{"Name":"finops-required-tags","Description":"Enforces six required tags on all resources","Source":{"Owner":"AWS","SourceIdentifier":"REQUIRED_TAGS"},"InputParameters":"{\"tag1Key\":\"Environment\",\"tag2Key\":\"Team\",\"tag3Key\":\"Service\",\"tag4Key\":\"ManagedBy\",\"tag5Key\":\"CostCenter\",\"tag6Key\":\"Owner\"}","Scope":{"ComplianceResourceTypes":["AWS::EC2::Instance","AWS::EC2::Volume","AWS::RDS::DBInstance","AWS::S3::Bucket","AWS::ElasticLoadBalancingV2::LoadBalancer"]}}']
▶ Pronounced as: "AWS, ConfigService, put, config, rule..."

271
00:45:50,000 --> 00:46:00,000
This Config rule is your insurance policy. It does not prevent resources from being created — but it flags them immediately.

272
00:46:00,000 --> 00:46:10,000
You can build a remediation pipeline that automatically applies default tags or notifies the owner. You can set up an SNS topic that sends a Slack message to the team when a non-compliant resource is detected.

273
00:46:10,000 --> 00:46:20,000
Check compliance after the rule evaluates. It takes a few minutes to run the first evaluation.

274
00:46:20,000 --> 00:46:30,000
[Types: aws configservice get-compliance-summary-by-config-rule --config-rule-names finops-required-tags]
▶ Pronounced as: "AWS, ConfigService, get, compliance, summary, by, config, rule..."

275
00:46:30,000 --> 00:46:40,000
What you want to see: COMPLIANT count going up, NON_COMPLIANT count going to zero. What you almost certainly see today: a lot of NON_COMPLIANT.

276
00:46:40,000 --> 00:46:50,000
That is your to-do list for the week. Each NON_COMPLIANT resource is an attribution gap. Each one is a dollar you cannot track.

277
00:46:50,000 --> 00:47:00,000
But here is the important thing: you now know about them. You can fix them. And going forward, they will be flagged immediately.

278
00:47:00,000 --> 00:47:10,000
In Series 7, when we build the IDP, new services created through the platform will automatically have all six tags applied. The Config rule will flag anything that goes around the platform.

279
00:47:10,000 --> 00:47:20,000
At that point, NON_COMPLIANT becomes a signal for shadow infrastructure — something created outside the approved path, which is a security concern as much as a cost concern.

280
00:47:20,000 --> 00:47:30,000
Set up a weekly email report from Config notifications. Fifteen minutes a week reviewing this report is worth more than a full day of retrospective cost analysis.

281
00:47:30,000 --> 00:47:40,000
[Types: aws configservice get-compliance-details-by-config-rule --config-rule-name finops-required-tags --compliance-types NON_COMPLIANT --output table]
▶ Pronounced as: "AWS, ConfigService, get, compliance, details, by, config, rule..."

282
00:47:40,000 --> 00:47:50,000
This command shows you every non-compliant resource. You can run it weekly and review the list. Each resource on this list is a gap you can close.

283
00:47:50,000 --> 00:48:00,000
You now have a complete enforcement mechanism. The past is fixed. The future is protected. The present is monitored.

284
00:48:00,000 --> 00:48:10,000
This is what production-grade tagging looks like. It is not just about applying tags. It is about ensuring they stay applied.

285
00:48:10,000 --> 00:48:20,000
In the next segment, we look at cost by region and find anything hiding in regions you do not know about.

286
00:48:20,000 --> 00:48:30,000
See you in Segment 11.
```

---

### SEGMENT 11: Cost by Region & Finding Stray Resources
**Timestamp:** 50:00 – 55:00

```
287
00:50:00,000 --> 00:50:10,000
Now let's look at cost by region — and find anything hiding in regions you do not know about.

288
00:50:10,000 --> 00:50:20,000
Cost by region is the query that finds the things you forgot about. When an engineer spins up a test instance in the wrong region — us-west-2 instead of us-east-1 — it does not appear in your normal monitoring.

289
00:50:20,000 --> 00:50:30,000
It runs. It bills. Nobody notices until the audit. Pull your cost by region:

290
00:50:30,000 --> 00:50:40,000
[Types: aws ce get-cost-and-usage --time-period Start=$START,End=$END --granularity MONTHLY --metrics BlendedCost --group-by Type=DIMENSION,Key=REGION --query 'ResultsByTime[0].Groups[].[Keys[0],Metrics.BlendedCost.Amount]' --output table]
▶ Pronounced as: "AWS, C-E, get, cost, and, usage... group-by, Type, equals, DIMENSION, comma, Key, equals, REGION"

291
00:50:40,000 --> 00:50:50,000
If every dollar is in us-east-1 — good. If you see spend in regions you do not use, run this scan immediately:

292
00:50:50,000 --> 00:51:00,000
[Types: for region in us-west-1 us-west-2 eu-west-1 eu-central-1 ap-southeast-1 ap-northeast-1; do count=$(aws ec2 describe-instances --region $region --query 'length(Reservations[].Instances[])' --output text 2>/dev/null || echo 0); if [ "$count" -gt "0" ]; then echo "⚠️  $count instance(s) found in $region"; aws ec2 describe-instances --region $region --query 'Reservations[].Instances[].[InstanceId,InstanceType,State.Name,Tags[?Key==`Name`].Value|[0]]' --output table; fi; done]
▶ Pronounced as: "For, region, in, us-west-one, us-west-two..."

293
00:51:00,000 --> 00:51:10,000
For each stray resource: identify it, find the owner, decide — migrate, snapshot and delete, or tag and track. Never ignore a stray resource.

294
00:51:10,000 --> 00:51:20,000
A zero point zero two dollar per hour test instance in the wrong region is fourteen dollars forty a month for nothing. Multiply that by the number of engineers who have ever had console access and the number climbs fast.

295
00:51:20,000 --> 00:51:30,000
Add this scan to your monthly FinOps review. It takes thirty seconds and catches a category of waste that almost nothing else surfaces.

296
00:51:30,000 --> 00:51:40,000
Based on real audits across fifty-plus startups, here is what the waste looks like by category. These are averages. Your numbers will differ.

297
00:51:40,000 --> 00:51:50,000
But the pattern is consistent enough that I can tell you, before running a single command, that your biggest opportunities are almost certainly in EC2 overprovisioning, gp2 volumes, and NAT Gateway traffic — in that order.

298
00:51:50,000 --> 00:52:00,000
Overprovisioned EC2 — twenty-five to forty percent of compute cost. Engineers provision instances at their peak estimate and never revisit them. Kubecost in Series 3 surfaces this exactly. Karpenter in Series 4 fixes it continuously.

299
00:52:00,000 --> 00:52:10,000
gp2 versus gp3 volumes — twenty percent of EBS cost. One command. Zero downtime. We do this in Series 2. This is the highest-return action per minute of engineering work in this entire course.

300
00:52:10,000 --> 00:52:20,000
Unattached Elastic IPs — three dollars sixty-five per IP per month, every month, for doing absolutely nothing. We find and release them in Series 2.

301
00:52:20,000 --> 00:52:30,000
NAT Gateway traffic — thirty to fifty percent of data transfer cost. S3 and DynamoDB traffic going through NAT when it should go through VPC Endpoints. Zero-cost fix. Series 2.

302
00:52:30,000 --> 00:52:40,000
RDS overprovisioning — twenty to thirty percent of database cost. Dev databases running twenty-four hours a day, seven days a week. Stop-start schedules in Series 6.

303
00:52:40,000 --> 00:52:50,000
S3 without lifecycle policies — forty to sixty percent of S3 cost on data older than ninety days. Automated lifecycle rules in Series 6.

304
00:52:50,000 --> 00:53:00,000
Total typical savings: thirty to sixty percent of total cloud spend. Not after a year of work. After this course. On infrastructure you already have, without building anything new.

305
00:53:00,000 --> 00:53:10,000
Write down your top three services from the Cost Explorer query we ran earlier. Those three services are where you will focus in Series 2. The biggest opportunities are almost always in that list.

306
00:53:10,000 --> 00:53:20,000
Before we end Series 1, we create the baseline document. This is the file you will update after every series and present to your CTO when the course is complete.

307
00:53:20,000 --> 00:53:30,000
The baseline document is your evidence file. It is how you prove that what you did in this course produced real results.

308
00:53:30,000 --> 00:53:40,000
Without it, you have a lower bill but no story. With it, you have a CTO-ready report that shows exactly what was spent, when, what changed, and what the delta was.

309
00:53:40,000 --> 00:53:50,000
Create it now. We already started it in Part 1. Now we complete it.

310
00:53:50,000 --> 00:54:00,000
[Types: touch ~/finops-baseline.txt]
"We create or touch the baseline document. This will be our source of truth throughout the course."

311
00:54:00,000 --> 00:54:10,000
[Types: echo "=== FINOPS BASELINE REPORT ===" >> ~/finops-baseline.txt]
[Types: echo "Date: $(date)" >> ~/finops-baseline.txt]
[Types: echo "Account: $ACCOUNT_ID" >> ~/finops-baseline.txt]
[Types: echo "" >> ~/finops-baseline.txt]

312
00:54:10,000 --> 00:54:20,000
[Types: echo "=== TOTAL MONTHLY SPEND ===" >> ~/finops-baseline.txt]
[Types: aws ce get-cost-and-usage --time-period Start=$START,End=$END --granularity MONTHLY --metrics BlendedCost --query 'ResultsByTime[0].Total.BlendedCost.Amount' --output text >> ~/finops-baseline.txt]
[Types: echo "" >> ~/finops-baseline.txt]

313
00:54:20,000 --> 00:54:30,000
[Types: echo "=== TOP 10 SERVICES BY COST ===" >> ~/finops-baseline.txt]
[Types: aws ce get-cost-and-usage --time-period Start=$START,End=$END --granularity MONTHLY --metrics BlendedCost --group-by Type=DIMENSION,Key=SERVICE --query 'ResultsByTime[0].Groups[?Metrics.BlendedCost.Amount > `10`].[Keys[0],Metrics.BlendedCost.Amount]' --output table >> ~/finops-baseline.txt]
[Types: echo "" >> ~/finops-baseline.txt]

314
00:54:30,000 --> 00:54:40,000
[Types: echo "=== COST BY REGION ===" >> ~/finops-baseline.txt]
[Types: aws ce get-cost-and-usage --time-period Start=$START,End=$END --granularity MONTHLY --metrics BlendedCost --group-by Type=DIMENSION,Key=REGION --query 'ResultsByTime[0].Groups[].[Keys[0],Metrics.BlendedCost.Amount]' --output table >> ~/finops-baseline.txt]
[Types: echo "" >> ~/finops-baseline.txt]

315
00:54:40,000 --> 00:54:50,000
[Types: echo "=== TAGGING STATUS ===" >> ~/finops-baseline.txt]
[Types: echo "Six required tags activated: Environment, Team, Service, ManagedBy, CostCenter, Owner" >> ~/finops-baseline.txt]
[Types: echo "AWS Config rule 'finops-required-tags' created and enforcing tagging" >> ~/finops-baseline.txt]
[Types: echo "" >> ~/finops-baseline.txt]

316
00:54:50,000 --> 00:55:00,000
[Types: echo "=== UNIT ECONOMICS ===" >> ~/finops-baseline.txt]
[Types: echo "Cost per RAG query: TBD (Series 8 — requires CloudWatch metrics)" >> ~/finops-baseline.txt]
[Types: echo "Cost per API call: TBD (Series 8)" >> ~/finops-baseline.txt]
[Types: echo "" >> ~/finops-baseline.txt]
```

---

### SEGMENT 12: The 30–60% Savings Reality
**Timestamp:** 55:00 – 60:00

```
317
00:55:00,000 --> 00:55:10,000
[Types: echo "=== NOTES FOR SERIES 2 ===" >> ~/finops-baseline.txt]
[Types: echo "Run the complete cloud cost audit to find hidden waste" >> ~/finops-baseline.txt]
[Types: echo "Focus on: gp2 volumes, unattached EIPs, stopped instances, NAT Gateway, S3 lifecycle" >> ~/finops-baseline.txt]

318
00:55:10,000 --> 00:55:20,000
[Types: cat ~/finops-baseline.txt]
Now, look at that output. You should see all sections with real data from your account. This is your complete baseline document.

319
00:55:20,000 --> 00:55:30,000
[Types: echo "=== SERIES 1 COMPLETE ===" >> ~/finops-baseline.txt]
[Types: echo "Date completed: $(date)" >> ~/finops-baseline.txt]

320
00:55:30,000 --> 00:55:40,000
This file will have new sections appended after every series. By Series 11, it will show the complete journey — from your starting bill to your optimized bill, series by series, with the dollar delta at each step.

321
00:55:40,000 --> 00:55:50,000
That document is the proof of work for everything we are about to build. It is the difference between saying "I saved money" and being able to prove it.

322
00:55:50,000 --> 00:56:00,000
Now let me recap what you built in Series 1.

323
00:56:00,000 --> 00:56:10,000
AWS environment verified and environment variables set. Cost Explorer baseline pulled — you have your starting number. Six required tags defined and activated for cost allocation.

324
00:56:10,000 --> 00:56:20,000
Untagged resources found across EC2, EBS, S3, and RDS. Bulk tagging scripts applied to close the attribution gap. Config rule deployed to enforce tags on every new resource going forward.

325
00:56:20,000 --> 00:56:30,000
Top services and regions identified. Baseline document created and saved. That is the Inform phase foundation.

326
00:56:30,000 --> 00:56:40,000
Without it, everything in Series 2 through 10 is guesswork. With it, every optimization is measurable.

327
00:56:40,000 --> 00:56:50,000
Before starting Series 2, verify these four things. Run aws sts get-caller-identity and confirm it returns your account ID.

328
00:56:50,000 --> 00:57:00,000
Run echo $START and confirm it shows a date thirty days ago. Run cat ~/finops-baseline.txt and confirm it has your total monthly spend. Run the Cost Explorer service query and confirm you see real data.

329
00:57:00,000 --> 00:57:10,000
Series 2 is the cloud cost audit. We stop talking about waste and start finding it — with real commands, real numbers, and real dollar amounts from your own account.

330
00:57:10,000 --> 00:57:20,000
In Series 2 you will find and fix: gp2 volumes that cost twenty percent more than gp3 — zero downtime migration, one command.

331
00:57:20,000 --> 00:57:30,000
Unattached Elastic IPs charging you three dollars sixty-five each per month for doing nothing. Stopped instances still paying for their EBS volumes.

332
00:57:30,000 --> 00:57:40,000
NAT Gateway traffic that should be free via VPC Endpoints. Cost anomaly detection that runs forever and catches spikes before they become invoices.

333
00:57:40,000 --> 00:57:50,000
By the end of Series 2, you will have a list of actual dollar amounts of waste — not estimated, not projected — from your own account, and every fix applied.

334
00:57:50,000 --> 00:58:00,000
You are not just learning about FinOps. You are doing FinOps. On your own account. With real money. And you are going to see the results on your next bill.

335
00:58:00,000 --> 00:58:10,000
That is the difference between this course and every other FinOps course you have ever taken. Every other course teaches concepts. This course teaches a process. And that process produces a result.

336
00:58:10,000 --> 00:58:20,000
The commands work. The savings are real. You just have to do the work.

337
00:58:20,000 --> 00:58:30,000
But before you leave Series 1, I want to give you one more thing.

338
00:58:30,000 --> 00:58:40,000
I want to give you a mental framework that will help you think about cost optimization in every decision you make going forward. It is called the Cost-Aware Engineering Mindset.

339
00:58:40,000 --> 00:58:50,000
Cost-Aware Engineering is not about being cheap. It is not about choosing the lowest-cost option every time. It is about knowing the cost of your choices so you can make informed trade-offs.

340
00:58:50,000 --> 00:59:00,000
When you choose a larger instance type, do you know what it costs you? When you choose a more expensive region, do you know the impact? When you leave a test environment running over the weekend, do you know what you are burning?

341
00:59:00,000 --> 00:59:10,000
The baseline document you just created is the first step. It is your cost-awareness anchor. Every time you make a change, you measure it against that baseline. Every time you deploy a new service, you estimate its cost. Every time you choose an architecture, you evaluate its unit economics.

342
00:59:10,000 --> 00:59:20,000
This is how senior engineers think. They do not avoid cost — they understand it. They do not fear cost — they manage it. They do not ignore cost — they optimize it.

343
00:59:20,000 --> 00:59:30,000
You are now on that path. The commands you ran today are not just commands — they are the foundation of a new way of engineering.

344
00:59:30,000 --> 00:59:40,000
Series 1 is complete. The foundation is laid. In Series 2, we start finding the waste. And in Series 3 through 11, we build a platform that makes cost optimization automatic.

345
00:59:40,000 --> 00:59:50,000
But remember: every journey starts with a single step. You just took that step. The baseline number you wrote down is your starting line. The document you created is your evidence. The tags you applied are your visibility.

346
00:59:50,000 --> 01:00:00,000
Now you are ready for what comes next. Series 2 begins now.
```

---

### SEGMENT 13: Creating the Baseline Document
**Timestamp:** 60:00 – 65:00

```
347
01:00:00,000 --> 01:00:10,000
Welcome to Segment 13. This is where we bring everything together.

348
01:00:10,000 --> 01:00:20,000
You have run the commands. You have the data. Now you create the baseline document that will track your entire journey.

349
01:00:20,000 --> 01:00:30,000
This is the most important file you will create in this entire course. Not because it is code. Because it is evidence.

350
01:00:30,000 --> 01:00:40,000
The baseline document is your proof. It is the difference between saying "I saved money" and being able to prove it.

351
01:00:40,000 --> 01:00:50,000
Every series we add to it. Every series we measure progress against it. By the end of the course, it is your CTO-ready report.

352
01:00:50,000 --> 01:01:00,000
Let's build it now. We already started it in earlier segments. Now we complete it.

353
01:01:00,000 --> 01:01:10,000
[Types: touch ~/finops-baseline.txt]
"We create or touch the baseline document. This will be our source of truth throughout the course."

354
01:01:10,000 --> 01:01:20,000
[Types: echo "=== FINOPS BASELINE REPORT ===" >> ~/finops-baseline.txt]
[Types: echo "Date: $(date)" >> ~/finops-baseline.txt]
[Types: echo "Account: $ACCOUNT_ID" >> ~/finops-baseline.txt]
[Types: echo "" >> ~/finops-baseline.txt]

355
01:01:20,000 --> 01:01:30,000
[Types: echo "=== TOTAL MONTHLY SPEND ===" >> ~/finops-baseline.txt]
[Types: aws ce get-cost-and-usage --time-period Start=$START,End=$END --granularity MONTHLY --metrics BlendedCost --query 'ResultsByTime[0].Total.BlendedCost.Amount' --output text >> ~/finops-baseline.txt]
[Types: echo "" >> ~/finops-baseline.txt]

356
01:01:30,000 --> 01:01:40,000
[Types: echo "=== TOP 10 SERVICES BY COST ===" >> ~/finops-baseline.txt]
[Types: aws ce get-cost-and-usage --time-period Start=$START,End=$END --granularity MONTHLY --metrics BlendedCost --group-by Type=DIMENSION,Key=SERVICE --query 'ResultsByTime[0].Groups[?Metrics.BlendedCost.Amount > `10`].[Keys[0],Metrics.BlendedCost.Amount]' --output table >> ~/finops-baseline.txt]
[Types: echo "" >> ~/finops-baseline.txt]

357
01:01:40,000 --> 01:01:50,000
[Types: echo "=== COST BY REGION ===" >> ~/finops-baseline.txt]
[Types: aws ce get-cost-and-usage --time-period Start=$START,End=$END --granularity MONTHLY --metrics BlendedCost --group-by Type=DIMENSION,Key=REGION --query 'ResultsByTime[0].Groups[].[Keys[0],Metrics.BlendedCost.Amount]' --output table >> ~/finops-baseline.txt]
[Types: echo "" >> ~/finops-baseline.txt]

358
01:01:50,000 --> 01:02:00,000
[Types: echo "=== TAGGING STATUS ===" >> ~/finops-baseline.txt]
[Types: echo "Six required tags activated: Environment, Team, Service, ManagedBy, CostCenter, Owner" >> ~/finops-baseline.txt]
[Types: echo "AWS Config rule 'finops-required-tags' created and enforcing tagging" >> ~/finops-baseline.txt]
[Types: echo "" >> ~/finops-baseline.txt]

359
01:02:00,000 --> 01:02:10,000
[Types: echo "=== UNIT ECONOMICS ===" >> ~/finops-baseline.txt]
[Types: echo "Cost per RAG query: TBD (Series 8 — requires CloudWatch metrics)" >> ~/finops-baseline.txt]
[Types: echo "Cost per API call: TBD (Series 8)" >> ~/finops-baseline.txt]
[Types: echo "" >> ~/finops-baseline.txt]

360
01:02:10,000 --> 01:02:20,000
[Types: echo "=== NOTES FOR SERIES 2 ===" >> ~/finops-baseline.txt]
[Types: echo "Run the complete cloud cost audit to find hidden waste" >> ~/finops-baseline.txt]
[Types: echo "Focus on: gp2 volumes, unattached EIPs, stopped instances, NAT Gateway, S3 lifecycle" >> ~/finops-baseline.txt]

361
01:02:20,000 --> 01:02:30,000
[Types: cat ~/finops-baseline.txt]
Now, look at that output. You should see all sections with real data from your account. This is your complete baseline document.

362
01:02:30,000 --> 01:02:40,000
[Types: echo "=== SERIES 1 COMPLETE ===" >> ~/finops-baseline.txt]
[Types: echo "Date completed: $(date)" >> ~/finops-baseline.txt]

363
01:02:40,000 --> 01:02:50,000
This file will have new sections appended after every series. By Series 11, it will show the complete journey.

364
01:02:50,000 --> 01:03:00,000
From your starting bill to your optimized bill, series by series, with the dollar delta at each step.

365
01:03:00,000 --> 01:03:10,000
That document is your professional deliverable. It is the evidence of everything you built.

366
01:03:10,000 --> 01:03:20,000
Treat it like a professional deliverable. Keep it clean. Keep it updated. Share it with your manager at the end of each series.

367
01:03:20,000 --> 01:03:30,000
This is how you build a career in FinOps. Not by knowing commands. By producing results and being able to prove them.

368
01:03:30,000 --> 01:03:40,000
In the next segment, we recap Series 1 and look ahead to Series 2.

369
01:03:40,000 --> 01:03:50,000
See you in Segment 14.
```

---

### SEGMENT 14: Series 1 Recap & Series 2 Preview
**Timestamp:** 65:00 – 70:00

```
370
01:05:00,000 --> 01:05:10,000
Now let me recap what you built in Series 1.

371
01:05:10,000 --> 01:05:20,000
AWS environment verified and environment variables set. Cost Explorer baseline pulled — you have your starting number.

372
01:05:20,000 --> 01:05:30,000
Six required tags defined and activated for cost allocation. Untagged resources found across EC2, EBS, S3, and RDS.

373
01:05:30,000 --> 01:05:40,000
Bulk tagging scripts applied to close the attribution gap. Config rule deployed to enforce tags on every new resource going forward.

374
01:05:40,000 --> 01:05:50,000
Top services and regions identified. Baseline document created and saved. That is the Inform phase foundation.

375
01:05:50,000 --> 01:06:00,000
Without it, everything in Series 2 through 10 is guesswork. With it, every optimization is measurable.

376
01:06:00,000 --> 01:06:10,000
Before starting Series 2, verify these four things.

377
01:06:10,000 --> 01:06:20,000
First: run aws sts get-caller-identity and confirm it returns your account ID.

378
01:06:20,000 --> 01:06:30,000
Second: run echo $START and confirm it shows a date thirty days ago.

379
01:06:30,000 --> 01:06:40,000
Third: run cat ~/finops-baseline.txt and confirm it has your total monthly spend.

380
01:06:40,000 --> 01:06:50,000
Fourth: run the Cost Explorer service query and confirm you see real data.

381
01:06:50,000 --> 01:07:00,000
If all four are verified, you are ready for Series 2.

382
01:07:00,000 --> 01:07:10,000
Series 2 is the cloud cost audit. We stop talking about waste and start finding it.

383
01:07:10,000 --> 01:07:20,000
With real commands, real numbers, and real dollar amounts from your own account.

384
01:07:20,000 --> 01:07:30,000
In Series 2 you will find and fix: gp2 volumes that cost twenty percent more than gp3 — zero downtime migration, one command.

385
01:07:30,000 --> 01:07:40,000
Unattached Elastic IPs charging you three dollars sixty-five each per month for doing nothing.

386
01:07:40,000 --> 01:07:50,000
Stopped instances still paying for their EBS volumes. NAT Gateway traffic that should be free via VPC Endpoints.

387
01:07:50,000 --> 01:08:00,000
Cost anomaly detection that runs forever and catches spikes before they become invoices.

388
01:08:00,000 --> 01:08:10,000
By the end of Series 2, you will have a list of actual dollar amounts of waste — not estimated, not projected — from your own account.

389
01:08:10,000 --> 01:08:20,000
And every fix applied. The savings will show on your next bill.

390
01:08:20,000 --> 01:08:30,000
This is the difference between this course and every other FinOps course you have taken.

391
01:08:30,000 --> 01:08:40,000
Every other course teaches concepts. This course teaches a process. And that process produces a result.

392
01:08:40,000 --> 01:08:50,000
The commands work. The savings are real. You just have to do the work.

393
01:08:50,000 --> 01:09:00,000
See you in Series 2.
```

---

### SEGMENT 15: Deep Dive — Understanding Your Cost Explorer Data
**Timestamp:** 70:00 – 75:00

```
394
01:10:00,000 --> 01:10:10,000
Welcome to Segment 15. We are going to look deeper at Cost Explorer data.

395
01:10:10,000 --> 01:10:20,000
You ran the basic queries. You saw the totals. But there is much more you can learn from this data.

396
01:10:20,000 --> 01:10:30,000
Cost Explorer is not just a reporting tool. It is an investigation tool. It tells you where to look.

397
01:10:30,000 --> 01:10:40,000
The first thing to understand is the difference between cost types. BlendedCost is what you actually pay. UnblendedCost is the list price.

398
01:10:40,000 --> 01:10:50,000
If you have Savings Plans or Reserved Instances, your BlendedCost is lower than UnblendedCost. The difference is your savings.

399
01:10:50,000 --> 01:11:00,000
Always use BlendedCost for decision-making. UnblendedCost shows you what you would pay if you had no commitments.

400
01:11:00,000 --> 01:11:10,000
The next dimension is usage type. Cost Explorer can show you cost by usage type — DataTransfer, EC2:RunningHours, EBS:VolumeUsage.

401
01:11:10,000 --> 01:11:20,000
This is where you find the specifics. DataTransfer is often a surprise cost. People forget that data moving between regions costs money.

402
01:11:20,000 --> 01:11:30,000
EC2:RunningHours is your compute cost. EBS:VolumeUsage is your storage cost. Each of these has optimization opportunities.

403
01:11:30,000 --> 01:11:40,000
You can also group by usage type and service together. This tells you which service is driving which cost.

404
01:11:40,000 --> 01:11:50,000
For example, you might see NAT Gateway cost under EC2:DataTransfer. That tells you the data transfer is going through NAT.

405
01:11:50,000 --> 01:12:00,000
This is why we fix NAT Gateway in Series 2. The data tells you it is a problem. The command fixes it.

406
01:12:00,000 --> 01:12:10,000
Another powerful feature is filtering. You can filter Cost Explorer by region, by tag, by instance type.

407
01:12:10,000 --> 01:12:20,000
This lets you answer questions like: "What is my cost in us-east-1 for EC2 instances tagged Team=financial-rag?"

408
01:12:20,000 --> 01:12:30,000
[Types: aws ce get-cost-and-usage --time-period Start=$START,End=$END --granularity MONTHLY --metrics BlendedCost --filter '{"Dimensions":{"Key":"REGION","Values":["us-east-1"]},"Tags":{"Key":"Team","Values":["financial-rag"]}}' --group-by Type=DIMENSION,Key=SERVICE --output table]
▶ Pronounced as: "AWS, C-E, get, cost, and, usage, dash, dash, time, period..."

409
01:12:30,000 --> 01:12:40,000
This query gives you the cost of a specific team in a specific region. This is the level of granularity you need for chargeback.

410
01:12:40,000 --> 01:12:50,000
You can also look at monthly trends over a longer period. Compare month over month to see growth.

411
01:12:50,000 --> 01:13:00,000
[Types: aws ce get-cost-and-usage --time-period Start=$(date -d '12 months ago' +%Y-%m-%d),End=$END --granularity MONTHLY --metrics BlendedCost --query 'ResultsByTime[].[TimePeriod.Start,Total.BlendedCost.Amount]' --output table]
▶ Pronounced as: "AWS, C-E, get, cost, and, usage, dash, dash, time, period..."

412
01:13:00,000 --> 01:13:10,000
This shows your cost trend over the last year. Is it growing? Is it stable? Is there a spike in a specific month?

413
01:13:10,000 --> 01:13:20,000
Cost Explorer is your primary investigation tool. Learn it. Use it. It will tell you where to optimize.

414
01:13:20,000 --> 01:13:30,000
In the next segment, we look at common mistakes in tagging and how to avoid them.

415
01:13:30,000 --> 01:13:40,000
See you in Segment 16.
```

---

### SEGMENT 16: Common Mistakes in Tagging & How to Avoid Them
**Timestamp:** 75:00 – 80:00

```
416
01:15:00,000 --> 01:15:10,000
Welcome to Segment 16. We are going to look at common tagging mistakes.

417
01:15:10,000 --> 01:15:20,000
Tagging seems simple. Apply key-value pairs to resources. But there are common mistakes that break cost allocation.

418
01:15:20,000 --> 01:15:30,000
Mistake number one: inconsistent casing. Environment=production vs environment=Production. Cost Explorer sees these as two different tags.

419
01:15:30,000 --> 01:15:40,000
The fix is simple. Standardize on lowercase for all tag keys and values. Enforce it with Config rules.

420
01:15:40,000 --> 01:15:50,000
Mistake number two: using spaces or special characters. Team=financial-rag is fine. Team=financial rag is not.

421
01:15:50,000 --> 01:16:00,000
Spaces break querying. You have to quote them. Avoid spaces. Use hyphens or underscores.

422
01:16:00,000 --> 01:16:10,000
Mistake number three: activating tags after resources are created. Tags do not apply retroactively to billing data.

423
01:16:10,000 --> 01:16:20,000
Activate tags early. Even if you have not applied them to all resources yet. Future data will be tagged correctly.

424
01:16:20,000 --> 01:16:30,000
Mistake number four: not applying tags to all resource types. You tag EC2 instances but not EBS volumes.

425
01:16:30,000 --> 01:16:40,000
EBS volumes are separate resources. They need their own tags. The bulk tagging script we ran covers volumes too.

426
01:16:40,000 --> 01:16:50,000
Mistake number five: not having a tag strategy document. You need a written document that defines all tags and their values.

427
01:16:50,000 --> 01:17:00,000
This is important because new engineers join. They need to know what tags to apply. The document is their guide.

428
01:17:00,000 --> 01:17:10,000
Mistake number six: not reviewing tags regularly. Tags drift over time. Teams change. Services change.

429
01:17:10,000 --> 01:17:20,000
Review your tags quarterly. Update values that have changed. Remove tags that are no longer needed.

430
01:17:20,000 --> 01:17:30,000
Mistake number seven: using tags for things other than cost allocation. Tags are also used for security and operations.

431
01:17:30,000 --> 01:17:40,000
Keep your cost allocation tags separate from operational tags. Do not mix them. It gets confusing.

432
01:17:40,000 --> 01:17:50,000
Mistake number eight: forgetting about resources created outside the normal workflow.

433
01:17:50,000 --> 01:18:00,000
Some teams create resources in the console. Those resources may not get tags. This is why the Config rule is important.

434
01:18:00,000 --> 01:18:10,000
It flags resources created outside the normal workflow. You can then remediate them.

435
01:18:10,000 --> 01:18:20,000
Now you know the common mistakes. Avoid them. Your tagging will be clean and reliable.

436
01:18:20,000 --> 01:18:30,000
In the next segment, we clarify the difference between cost allocation tags and resource tags.

437
01:18:30,000 --> 01:18:40,000
See you in Segment 17.
```

---

### SEGMENT 17: Cost Allocation Tags vs Resource Tags — What's the Difference?
**Timestamp:** 80:00 – 85:00

```
438
01:20:00,000 --> 01:20:10,000
Welcome to Segment 17. We are going to clarify a common confusion.

439
01:20:10,000 --> 01:20:20,000
There is a difference between cost allocation tags and resource tags. Many engineers use these terms interchangeably. They are not the same.

440
01:20:20,000 --> 01:20:30,000
Resource tags are the actual key-value pairs you attach to your AWS resources. Things like Environment=production or Team=financial-rag.

441
01:20:30,000 --> 01:20:40,000
These tags exist on the resource itself. You can see them in the AWS console, in the CLI, and in CloudFormation.

442
01:20:40,000 --> 01:20:50,000
Cost allocation tags are a subset of resource tags that you have explicitly activated for cost reporting.

443
01:20:50,000 --> 01:21:00,000
When you activate a tag for cost allocation, AWS starts including that tag in your billing data. Cost Explorer can then filter and group by that tag.

444
01:21:00,000 --> 01:21:10,000
Here is the critical difference: A resource tag exists on the resource regardless of whether it is activated for cost allocation.

445
01:21:10,000 --> 01:21:20,000
But a cost allocation tag only appears in your billing data if it has been activated. This is a common source of confusion.

446
01:21:20,000 --> 01:21:30,000
You can have a resource with all six tags applied — Environment, Team, Service, ManagedBy, CostCenter, Owner.

447
01:21:30,000 --> 01:21:40,000
But if you have not activated those tags for cost allocation, Cost Explorer cannot group by them. Your tags exist, but your billing data does not include them.

448
01:21:40,000 --> 01:21:50,000
Activating a tag for cost allocation is a one-time, account-level operation. You do it once, and from that point forward, any resource with that tag will have its cost attributed correctly.

449
01:21:50,000 --> 01:22:00,000
We already ran this activation earlier. But let me show you what it looks like again.

450
01:22:00,000 --> 01:22:10,000
[Types: aws ce update-cost-allocation-tags-status --cost-allocation-tags-status TagKey=Environment,Status=Active]
▶ Pronounced as: "AWS, C-E, update, cost, allocation, tags, status..."

451
01:22:10,000 --> 01:22:20,000
You need to run this for each of the six tags. We did this as a loop in an earlier segment.

452
01:22:20,000 --> 01:22:30,000
Once activated, it takes a few hours for the changes to propagate fully through the billing pipeline.

453
01:22:30,000 --> 01:22:40,000
Another important distinction: the billing data is historical. If you activate a tag today, it does not apply retroactively to past months.

454
01:22:40,000 --> 01:22:50,000
This means you need to activate tags early. Do not wait until you need the data. Activate them now.

455
01:22:50,000 --> 01:23:00,000
To check which tags are currently activated for cost allocation, run this command:

456
01:23:00,000 --> 01:23:10,000
[Types: aws ce list-cost-allocation-tags --status Active --output table]
▶ Pronounced as: "AWS, C-E, list, cost, allocation, tags..."

457
01:23:10,000 --> 01:23:20,000
This shows you all tags that are currently active for cost allocation. If you do not see your six tags in this list, they are not active.

458
01:23:20,000 --> 01:23:30,000
In practice, your workflow should be: define your tag strategy, apply resource tags to all resources, activate those tags for cost allocation.

459
01:23:30,000 --> 01:23:40,000
Then verify that your Cost Explorer data reflects the tags correctly. This is the sequence we followed in this series.

460
01:23:40,000 --> 01:23:50,000
When we build the IDP in Series 7, this distinction becomes even more important. The IDP will automatically apply resource tags.

461
01:23:50,000 --> 01:24:00,000
But the platform team still needs to activate new tags for cost allocation if they are introduced.

462
01:24:00,000 --> 01:24:10,000
To avoid this becoming a manual process, include tag activation in your account setup automation.

463
01:24:10,000 --> 01:24:20,000
One more nuance: cost allocation tags have a limit of fifty active tags per account. This is a hard limit from AWS.

464
01:24:20,000 --> 01:24:30,000
If you need more than fifty tags for cost allocation, you need to consolidate your tagging strategy.

465
01:24:30,000 --> 01:24:40,000
For most organizations, six to ten tags is sufficient. The other tags can remain as resource tags without being activated.

466
01:24:40,000 --> 01:24:50,000
Now you know the difference. Resource tags are the data you attach. Cost allocation tags are the data you make visible.

467
01:24:50,000 --> 01:25:00,000
In the next segment, we look at how to read AWS billing reports like a pro.

468
01:25:00,000 --> 01:25:10,000
See you in Segment 18.
```

---

### SEGMENT 18: How to Read AWS Billing Reports Like a Pro
**Timestamp:** 85:00 – 90:00

```
469
01:25:00,000 --> 01:25:10,000
Welcome to Segment 18. We are going to look at AWS billing reports.

470
01:25:10,000 --> 01:25:20,000
Cost Explorer is great for analysis. But the raw billing reports contain everything. You need to know how to read them.

471
01:25:20,000 --> 01:25:30,000
AWS billing reports are delivered to S3 as CSV files. They contain every single line item from your bill.

472
01:25:30,000 --> 01:25:40,000
The first thing to understand is the structure. Each row is a line item. Each column is a dimension.

473
01:25:40,000 --> 01:25:50,000
The key columns are: UsageType, ResourceId, LineItemDescription, Cost. These tell you what you are paying for.

474
01:25:50,000 --> 01:26:00,000
UsageType tells you the type of usage — EC2:RunningHours, EBS:VolumeUsage, DataTransfer:Out.

475
01:26:00,000 --> 01:26:10,000
ResourceId tells you the specific resource — i-1234567890abcdef0, vol-1234567890abcdef0.

476
01:26:10,000 --> 01:26:20,000
LineItemDescription gives you more detail about the usage. Cost is the actual amount.

477
01:26:20,000 --> 01:26:30,000
The billing report also includes tags. If you have activated tags for cost allocation, they appear in the report.

478
01:26:30,000 --> 01:26:40,000
This is how you can group cost by team, by service, by environment. The tags are in the report.

479
01:26:40,000 --> 01:26:50,000
You can analyze the billing report in any tool — Excel, Python, or a BI tool like Tableau.

480
01:26:50,000 --> 01:27:00,000
One of the most powerful things to do is pivot the data. Group by UsageType to see your biggest cost drivers.

481
01:27:00,000 --> 01:27:10,000
Group by ResourceId to see which resources are most expensive. Group by Tag to see cost by team.

482
01:27:10,000 --> 01:27:20,000
The billing report also shows you discounts. If you have Savings Plans or Reserved Instances, the discount appears as a negative cost.

483
01:27:20,000 --> 01:27:30,000
This is how you verify your savings are being applied correctly. Look for negative line items.

484
01:27:30,000 --> 01:27:40,000
The billing report is also where you find anomalies. A line item that was not there last month is an anomaly.

485
01:27:40,000 --> 01:27:50,000
If you see a new UsageType or a large increase in a specific ResourceId, investigate it.

486
01:27:50,000 --> 01:28:00,000
This is how you catch problems early. The monthly report is your early warning system.

487
01:28:00,000 --> 01:28:10,000
Set up daily billing reports to S3. That way you can look at the data daily, not just monthly.

488
01:28:10,000 --> 01:28:20,000
[Types: aws s3 ls s3://your-billing-bucket/]
▶ Pronounced as: "AWS, S-three, L-S, S-three, colon, slash, slash, your, billing, bucket..."

489
01:28:20,000 --> 01:28:30,000
You can also use Athena to query the billing data directly in S3. This is faster than downloading CSV files.

490
01:28:30,000 --> 01:28:40,000
[Types: SELECT line_item_usage_type, SUM(line_item_blended_cost) FROM billing_data WHERE line_item_usage_start_date >= '2024-01-01' GROUP BY line_item_usage_type ORDER BY SUM(line_item_blended_cost) DESC]
▶ Pronounced as: "SELECT, line, item, usage, type, SUM, line, item, blended, cost..."

491
01:28:40,000 --> 01:28:50,000
This query gives you the same data as Cost Explorer but with more flexibility. You can join with other data sources.

492
01:28:50,000 --> 01:29:00,000
You can also build dashboards on top of the billing data. Tableau, Power BI, or Grafana can connect to Athena.

493
01:29:00,000 --> 01:29:10,000
This is what FinOps teams do. They have automated dashboards that show cost trends, anomalies, and chargeback.

494
01:29:10,000 --> 01:29:20,000
In this course, we focus on Cost Explorer because it is the quickest way to get started.

495
01:29:20,000 --> 01:29:30,000
But the billing report is the source of truth. It contains everything. Learn to read it.

496
01:29:30,000 --> 01:29:40,000
In the next segment, we set up budget alerts and notifications.

497
01:29:40,000 --> 01:29:50,000
See you in Segment 19.
```

---

### SEGMENT 19: Setting Up Budget Alerts & Notifications
**Timestamp:** 90:00 – 95:00

```
498
01:30:00,000 --> 01:30:10,000
Welcome to Segment 19. We are going to set up budget alerts.

499
01:30:10,000 --> 01:30:20,000
Cost Explorer tells you what happened. Budget alerts tell you what is about to happen.

500
01:30:20,000 --> 01:30:30,000
Setting up budget alerts is the Operate phase of FinOps. It is how you prevent waste before it happens.

501
01:30:30,000 --> 01:30:40,000
AWS Budgets is the native service for this. You set a budget. AWS notifies you when you approach it.

502
01:30:40,000 --> 01:30:50,000
[Types: aws budgets create-budget --account-id $ACCOUNT_ID --budget '{"BudgetLimit":{"Amount":"500","Unit":"USD"},"BudgetName":"Monthly-Spend","BudgetType":"COST","TimeUnit":"MONTHLY","TimePeriod":{"Start":"2024-01-01T00:00:00Z","End":"2087-06-15T00:00:00Z"}}' --notifications-with-subscribers '[{"Notification":{"NotificationType":"ACTUAL","ComparisonOperator":"GREATER_THAN","Threshold":80,"ThresholdType":"PERCENTAGE"},"Subscribers":[{"SubscriptionType":"EMAIL","Address":"your-email@company.com"}]}]']
▶ Pronounced as: "AWS, budgets, create, budget..."

503
01:30:50,000 --> 01:31:00,000
This creates a monthly budget of five hundred dollars with an alert at eighty percent.

504
01:31:00,000 --> 01:31:10,000
You can set multiple thresholds. Fifty percent is good for early warning. Eighty percent is good for action. One hundred percent is good for escalation.

505
01:31:10,000 --> 01:31:20,000
[Types: aws budgets create-budget --account-id $ACCOUNT_ID --budget '{"BudgetLimit":{"Amount":"500","Unit":"USD"},"BudgetName":"Monthly-Spend-50","BudgetType":"COST","TimeUnit":"MONTHLY","TimePeriod":{"Start":"2024-01-01T00:00:00Z","End":"2087-06-15T00:00:00Z"}}' --notifications-with-subscribers '[{"Notification":{"NotificationType":"ACTUAL","ComparisonOperator":"GREATER_THAN","Threshold":50,"ThresholdType":"PERCENTAGE"},"Subscribers":[{"SubscriptionType":"EMAIL","Address":"your-email@company.com"}]}]']
▶ Pronounced as: "AWS, budgets, create, budget..."

506
01:31:20,000 --> 01:31:30,000
You can also set budgets by tag. This is how you track cost by team.

507
01:31:30,000 --> 01:31:40,000
[Types: aws budgets create-budget --account-id $ACCOUNT_ID --budget '{"BudgetLimit":{"Amount":"1000","Unit":"USD"},"BudgetName":"Team-FinancialRag","BudgetType":"COST","TimeUnit":"MONTHLY","CostFilters":{"TagKeyValue":["Team$financial-rag"]},"TimePeriod":{"Start":"2024-01-01T00:00:00Z","End":"2087-06-15T00:00:00Z"}}' --notifications-with-subscribers '[{"Notification":{"NotificationType":"ACTUAL","ComparisonOperator":"GREATER_THAN","Threshold":80,"ThresholdType":"PERCENTAGE"},"Subscribers":[{"SubscriptionType":"EMAIL","Address":"financial-rag@company.com"}]}]']
▶ Pronounced as: "AWS, budgets, create, budget..."

508
01:31:40,000 --> 01:31:50,000
This creates a budget for the financial-rag team. The team gets notified when they approach their budget.

509
01:31:50,000 --> 01:32:00,000
The alert destinations can be email, SNS, or Lambda. Email is the simplest. SNS allows you to send to Slack.

510
01:32:00,000 --> 01:32:10,000
[Types: aws sns create-topic --name budget-alerts]
[Types: aws sns subscribe --topic-arn arn:aws:sns:us-east-1:123456789012:budget-alerts --protocol email --notification-endpoint your-email@company.com]
▶ Pronounced as: "AWS, S-N-S, create, topic..."

511
01:32:10,000 --> 01:32:20,000
Then you can use the SNS topic as the subscriber for your budget alerts. This scales better than email.

512
01:32:20,000 --> 01:32:30,000
You can also use Lambda to take automated actions when a budget is exceeded.

513
01:32:30,000 --> 01:32:40,000
For example, you can automatically stop a dev environment if its budget is exceeded.

514
01:32:40,000 --> 01:32:50,000
[Types: aws budgets create-budget --account-id $ACCOUNT_ID --budget '{"BudgetLimit":{"Amount":"100","Unit":"USD"},"BudgetName":"Dev-Environment","BudgetType":"COST","TimeUnit":"MONTHLY","TimePeriod":{"Start":"2024-01-01T00:00:00Z","End":"2087-06-15T00:00:00Z"}}' --notifications-with-subscribers '[{"Notification":{"NotificationType":"ACTUAL","ComparisonOperator":"GREATER_THAN","Threshold":100,"ThresholdType":"PERCENTAGE"},"Subscribers":[{"SubscriptionType":"EMAIL","Address":"your-email@company.com"}]}]']
▶ Pronounced as: "AWS, budgets, create, budget..."

515
01:32:50,000 --> 01:33:00,000
But be careful with automated actions. You do not want to accidentally stop production. Use them only for non-production environments.

516
01:33:00,000 --> 01:33:10,000
The key to budget alerts is to set them early. Do not wait until you have a large bill. Set them now.

517
01:33:10,000 --> 01:33:20,000
Review your budgets monthly. Adjust them as your spend grows. They should be living documents.

518
01:33:20,000 --> 01:33:30,000
In Series 10, we integrate these budget alerts into the IDP. The alerts go to Slack and are visible in the catalog.

519
01:33:30,000 --> 01:33:40,000
But you can set them up now. It takes five minutes and saves you from surprises.

520
01:33:40,000 --> 01:33:50,000
In the next segment, we look at Savings Plans vs Reserved Instances.

521
01:33:50,000 --> 01:34:00,000
See you in Segment 20.
```

---

### SEGMENT 20: Understanding Savings Plans vs Reserved Instances
**Timestamp:** 95:00 – 100:00

```
522
01:35:00,000 --> 01:35:10,000
Welcome to Segment 20. We are going to look at Savings Plans and Reserved Instances.

523
01:35:10,000 --> 01:35:20,000
These are two ways to commit to spend and get discounts. They are similar but different.

524
01:35:20,000 --> 01:35:30,000
Reserved Instances are specific to an instance type and region. You commit to a specific resource.

525
01:35:30,000 --> 01:35:40,000
For example, you commit to a t3.large instance in us-east-1. You get a discount on that specific instance.

526
01:35:40,000 --> 01:35:50,000
The discount is significant — forty to sixty percent. But it is rigid. You cannot change the instance type.

527
01:35:50,000 --> 01:36:00,000
Savings Plans are more flexible. You commit to a dollar amount of spend. The discount applies across many services.

528
01:36:00,000 --> 01:36:10,000
For example, you commit to ten dollars an hour of EC2 spend. Any EC2 usage gets the discount. Any region. Any instance type.

529
01:36:10,000 --> 01:36:20,000
Savings Plans also cover Fargate and Lambda. Reserved Instances do not.

530
01:36:20,000 --> 01:36:30,000
Savings Plans are generally better for dynamic workloads. Reserved Instances are better for static, predictable workloads.

531
01:36:30,000 --> 01:36:40,000
Here is a comparison table for the same workload:

532
01:36:40,000 --> 01:36:50,000
Option 1: On-Demand — pay full price. Zero commitment. Maximum flexibility.

533
01:36:50,000 --> 01:37:00,000
Option 2: One-Year No Upfront Reserved Instance — forty percent discount. Specific instance type.

534
01:37:00,000 --> 01:37:10,000
Option 3: One-Year No Upfront Savings Plan — forty percent discount. Flexible across services.

535
01:37:10,000 --> 01:37:20,000
Option 4: Three-Year All Upfront Savings Plan — sixty percent discount. Highest savings, highest commitment.

536
01:37:20,000 --> 01:37:30,000
You can view Savings Plan recommendations in Cost Explorer:

537
01:37:30,000 --> 01:37:40,000
[Types: aws ce get-savings-plans-purchase-recommendation --savings-plans-type COMPUTE_SP --term-in-years ONE_YEAR --payment-option NO_UPFRONT --lookback-period-in-days THIRTY_DAYS --output table]
▶ Pronounced as: "AWS, C-E, get, savings, plans, purchase, recommendation..."

538
01:37:40,000 --> 01:37:50,000
This gives you a recommendation based on your historical usage. It tells you how much to commit.

539
01:37:50,000 --> 01:38:00,000
You can also view Reserved Instance recommendations:

540
01:38:00,000 --> 01:38:10,000
[Types: aws ce get-reservation-purchase-recommendation --service AmazonEC2 --term-in-years ONE_YEAR --payment-option NO_UPFRONT --lookback-period-in-days THIRTY_DAYS --output table]
▶ Pronounced as: "AWS, C-E, get, reservation, purchase, recommendation..."

541
01:38:10,000 --> 01:38:20,000
The recommendation tells you which instance types to reserve and how many.

542
01:38:20,000 --> 01:38:30,000
The key principle: start with no commitment. Observe your usage for thirty days. Then buy commitments based on the data.

543
01:38:30,000 --> 01:38:40,000
Do not buy commitments before you understand your usage. That is how you waste money on unused reservations.

544
01:38:40,000 --> 01:38:50,000
Also, review your commitments quarterly. Cancel or exchange ones that are no longer needed.

545
01:38:50,000 --> 01:39:00,000
The worst thing you can do is buy a three-year commitment and then move to a different region.

546
01:39:00,000 --> 01:39:10,000
In this course, we cover Reserved Instances in detail in Series 6. That is when you buy them.

547
01:39:10,000 --> 01:39:20,000
But understand the concept now. Savings Plans and Reserved Instances are how you reduce your baseline cost.

548
01:39:20,000 --> 01:39:30,000
In the next segment, we do a live unit economics workshop.

549
01:39:30,000 --> 01:39:40,000
See you in Segment 21.
```

---

### SEGMENT 21: The Unit Economics Workshop — Live Calculation Exercise
**Timestamp:** 100:00 – 105:00

```
550
01:40:00,000 --> 01:40:10,000
Welcome to Segment 21. This is the unit economics workshop.

551
01:40:10,000 --> 01:40:20,000
We are going to do the math together. I want you to calculate your own unit economics.

552
01:40:20,000 --> 01:40:30,000
Take your last AWS bill. Find the total monthly cost. You have that in your baseline document.

553
01:40:30,000 --> 01:40:40,000
Now define your business unit. What is one unit of your business? A user login? An API call? A RAG query? A file upload?

554
01:40:40,000 --> 01:40:50,000
If you do not have a unit, define one now. Write it down. This is the most important step.

555
01:40:50,000 --> 01:41:00,000
Now get the count of those units for the same month. Look at your application metrics. CloudWatch, Datadog, or your own logs.

556
01:41:00,000 --> 01:41:10,000
If you do not have metrics yet, estimate. Use your business data. How many customers? How many active users?

557
01:41:10,000 --> 01:41:20,000
Now divide. Total cost divided by total units. That is your cost per unit.

558
01:41:20,000 --> 01:41:30,000
For example: eight thousand four hundred dollars divided by five hundred thousand queries equals zero point zero one six eight dollars per query.

559
01:41:30,000 --> 01:41:40,000
Write that number down. That is your unit cost. This is the number that changes everything.

560
01:41:40,000 --> 01:41:50,000
Now compare it to your revenue per unit. If you charge ten cents per unit, your margin is eighty-three percent.

561
01:41:50,000 --> 01:42:00,000
If you charge two cents, your margin is sixteen percent. One infrastructure accident puts you underwater.

562
01:42:00,000 --> 01:42:10,000
This is the conversation you have with your CTO. "Our cost per unit is X. I can reduce it to Y by doing Z."

563
01:42:10,000 --> 01:42:20,000
Your CTO understands unit economics. This is how you get buy-in for your optimization work.

564
01:42:20,000 --> 01:42:30,000
Now write your unit cost in your baseline document. It is a placeholder now. We will update it in Series 8.

565
01:42:30,000 --> 01:42:40,000
[Types: echo "Cost per unit: TBD (Series 8)" >> ~/finops-baseline.txt]
▶ Pronounced as: "Echo, Cost per unit, colon, T-B-D, space, Series, eight..."

566
01:42:40,000 --> 01:42:50,000
Every decision you make in this course should be evaluated against your unit cost.

567
01:42:50,000 --> 01:43:00,000
Every rightsizing, every Karpenter consolidation, every Spot instance migration. The question is always: how does this change my cost per unit?

568
01:43:00,000 --> 01:43:10,000
After all optimizations in this course: zero point zero one six eight becomes zero point zero zero nine eight.

569
01:43:10,000 --> 01:43:20,000
A forty-two percent reduction. On five hundred thousand queries a month, that is three thousand five hundred dollars recovered every single month.

570
01:43:20,000 --> 01:43:30,000
Now you know how to calculate your own unit economics. Apply it to your workload.

571
01:43:30,000 --> 01:43:40,000
In the next segment, we look at how to present your baseline to leadership.

572
01:43:40,000 --> 01:43:50,000
See you in Segment 22.
```

---

### SEGMENT 22: How to Present Your Baseline to Leadership
**Timestamp:** 105:00 – 110:00

```
573
01:45:00,000 --> 01:45:10,000
Welcome to Segment 22. We are going to talk about presenting your baseline.

574
01:45:10,000 --> 01:45:20,000
You have the data. You have the baseline document. Now you need to share it with leadership.

575
01:45:20,000 --> 01:45:30,000
The baseline document is your evidence. But you need to present it in a way that leadership understands.

576
01:45:30,000 --> 01:45:40,000
Most engineers present data as tables. Leadership wants a story. Turn your data into a story.

577
01:45:40,000 --> 01:45:50,000
Here is the structure for your presentation: Start with the problem. "Our cloud spend is $X and growing."

578
01:45:50,000 --> 01:46:00,000
Then show the data. "Here is where the money is going. Here are the top services. Here is cost by team."

579
01:46:00,000 --> 01:46:10,000
Then show the opportunity. "We identified $Y in waste. Here is the breakdown."

580
01:46:10,000 --> 01:46:20,000
Then show the plan. "Here is what we will fix. Here is the expected savings. Here is the timeline."

581
01:46:20,000 --> 01:46:30,000
Finally, show the ask. "We need support for this work. We need time. We need resources."

582
01:46:30,000 --> 01:46:40,000
This structure works. It is clear. It is professional. It gets results.

583
01:46:40,000 --> 01:46:50,000
Here is an example of a slide you could create from your baseline document:

584
01:46:50,000 --> 01:47:00,000
Slide 1: Problem — "Our AWS bill is $47,000/month and growing 15% month over month."

585
01:47:00,000 --> 01:47:10,000
Slide 2: Data — "Top services: EC2 ($22,000), NAT Gateway ($6,000), RDS ($3,500)."

586
01:47:10,000 --> 01:47:20,000
Slide 3: Opportunity — "$12,544/month in identified waste: EC2 overprovisioning, gp2 volumes, NAT Gateway traffic."

587
01:47:20,000 --> 01:47:30,000Slide 4: Plan — "Reduce EC2 cost by 35% with Karpenter. Eliminate NAT Gateway traffic with VPC Endpoints. Migrate gp2 to gp3."

588
01:47:30,000 --> 01:47:40,000
Slide 5: Ask — "We need 2 hours per week over the next 3 months to implement these optimizations."

589
01:47:40,000 --> 01:47:50,000
This is a professional presentation. It is concise. It is data-driven. It is actionable.

590
01:47:50,000 --> 01:48:00,000
You can create this presentation in less than an hour using your baseline document.

591
01:48:00,000 --> 01:48:10,000
The baseline document is your raw data. The presentation is your story. Both are important.

592
01:48:10,000 --> 01:48:20,000
Share the presentation with your manager first. Get their feedback. Then present it to leadership.

593
01:48:20,000 --> 01:48:30,000
The key is to be prepared. Know your data. Know your plan. Be confident.

594
01:48:30,000 --> 01:48:40,000
When you walk into that meeting, you are not just asking for something. You are presenting a solution.

595
01:48:40,000 --> 01:48:50,000
This is how you become a leader in your organization. You solve problems. You bring data. You get results.

596
01:48:50,000 --> 01:49:00,000
In the next segment, we do a Q&A for Series 1.

597
01:49:00,000 --> 01:49:10,000
See you in Segment 23.
```

---

### SEGMENT 23: Series 1 Q&A — Common Questions Answered
**Timestamp:** 110:00 – 115:00

```
598
01:50:00,000 --> 01:50:10,000
Welcome to Segment 23. This is the final Q&A for Series 1.

599
01:50:10,000 --> 01:50:20,000
Question 1: "I ran the Cost Explorer query and got zero. What does that mean?"

600
01:50:20,000 --> 01:50:30,000
If you see zero, your Cost Explorer was just enabled and it needs up to twenty-four hours to populate historical data.

601
01:50:30,000 --> 01:50:40,000
If you still see zero after twenty-four hours, check that you have the AWSBillingReadOnlyAccess policy attached.

602
01:50:40,000 --> 01:50:50,000
Question 2: "I tagged all my resources, but Cost Explorer still shows untagged cost."

603
01:50:50,000 --> 01:51:00,000
You have not activated the tags for cost allocation. Resource tags exist on the resource. Cost allocation tags are what Cost Explorer uses for reporting.

604
01:51:00,000 --> 01:51:10,000
Run: aws ce list-cost-allocation-tags --status Active. If your tags are not in the list, activate them.

605
01:51:10,000 --> 01:51:20,000
Question 3: "My AWS bill is small — less than $100 a month. Is this still relevant?"

606
01:51:20,000 --> 01:51:30,000
Yes. The principles scale. A $100 bill that grows 20% per month becomes $1,000 in 12 months.

607
01:51:30,000 --> 01:51:40,000
Learning now, when your bill is small, is the smartest time. The worst time to learn is when your bill is already high.

608
01:51:40,000 --> 01:51:50,000
Question 4: "What if I do not have all the AWS permissions?"

609
01:51:50,000 --> 01:52:00,000
You need at least AWSBillingReadOnlyAccess and AmazonEC2ReadOnlyAccess. Without these, you cannot run most commands.

610
01:52:00,000 --> 01:52:10,000
If you cannot get these permissions, follow along conceptually. But the real learning happens when you run the commands yourself.

611
01:52:10,000 --> 01:52:20,000
Question 5: "How long until I see the cost impact of my tagging work?"

612
01:52:20,000 --> 01:52:30,000
Tag activation takes up to twenty-four hours to propagate. You will see the tags in Cost Explorer the next billing cycle.

613
01:52:30,000 --> 01:52:40,000
Question 6: "What if I have resources in multiple regions?"

614
01:52:40,000 --> 01:52:50,000
Tagging and Config rules are global. Once you activate tags for cost allocation, they apply to all regions.

615
01:52:50,000 --> 01:53:00,000
The multi-region scan script is the only region-specific part. You need to run that scan to find stray resources.

616
01:53:00,000 --> 01:53:10,000
Question 7: "Is there a way to automate tagging of new resources?"

617
01:53:10,000 --> 01:53:20,000
Yes. Use Infrastructure as Code like Terraform. Define the tags in your modules. Or use AWS Organizations tag policies.

618
01:53:20,000 --> 01:53:30,000
Or use the Config rule we already created. It flags non-compliant resources so you can remediate them.

619
01:53:30,000 --> 01:53:40,000
Question 8: "What is the difference between Cost Explorer and AWS Budgets?"

620
01:53:40,000 --> 01:53:50,000
Cost Explorer is analytical. It tells you what happened. AWS Budgets is proactive. It tells you what is about to happen.

621
01:53:50,000 --> 01:54:00,000
Both are essential. Cost Explorer tells you where you have waste. Budgets tells you when you are about to have waste.

622
01:54:00,000 --> 01:54:10,000
Question 9: "What if my resources were created before I started tagging?"

623
01:54:10,000 --> 01:54:20,000
This is why we ran the bulk tagging scripts. They find all existing resources and apply the six required tags.

624
01:54:20,000 --> 01:54:30,000
Question 10: "I have resources not covered by the Config rule. How do I enforce tags on them?"

625
01:54:30,000 --> 01:54:40,000
The REQUIRED_TAGS rule supports many resource types. Extend the scope to include additional resource types.

626
01:54:40,000 --> 01:54:50,000
Question 11: "How do I share the baseline document with my team?"

627
01:54:50,000 --> 01:55:00,000
Share it directly or convert it to a presentation format. In Series 11, we create a final CTO-ready report.

628
01:55:00,000 --> 01:55:10,000
Question 12: "What if I accidentally delete a resource while cleaning up waste?"

629
01:55:10,000 --> 01:55:20,000
This is why we always snapshot before deleting. You can restore from the snapshot.

630
01:55:20,000 --> 01:55:30,000
Questions are not a sign of confusion. They are a sign of engagement. Keep asking them.

631
01:55:30,000 --> 01:55:40,000
In the next segment, we do a knowledge check and look ahead to Series 2.

632
01:55:40,000 --> 01:55:50,000
See you in Segment 24.
```

---

### SEGMENT 24: Series 1 Knowledge Check & Next Steps
**Timestamp:** 115:00 – 120:00

```
633
01:55:00,000 --> 01:55:10,000
Welcome to Segment 24. This is the knowledge check.

634
01:55:10,000 --> 01:55:20,000
Let's test your understanding of Series 1. Answer these questions in your own words.

635
01:55:20,000 --> 01:55:30,000
Question 1: What are the three phases of FinOps? Write them down. Explain each in one sentence.

636
01:55:30,000 --> 01:55:40,000
Question 2: What is the formula for unit economics? Write it down.

637
01:55:40,000 --> 01:55:50,000
Question 3: What are the six required tags? List them.

638
01:55:50,000 --> 01:56:00,000
Question 4: What command activates a tag for cost allocation?

639
01:56:00,000 --> 01:56:10,000
Question 5: What command finds untagged EC2 instances?

640
01:56:10,000 --> 01:56:20,000
Question 6: What AWS Config rule enforces required tags?

641
01:56:20,000 --> 01:56:30,000
Question 7: Why does Cost Explorer show untagged cost even when resources have tags?

642
01:56:30,000 --> 01:56:40,000
Question 8: What is the difference between BlendedCost and UnblendedCost?

643
01:56:40,000 --> 01:56:50,000
Pause the video. Write down your answers. Then compare them to what you learned.

644
01:56:50,000 --> 01:57:00,000
If you got all eight correct, you understand Series 1. If you missed any, review the relevant segment.

645
01:57:00,000 --> 01:57:10,000
Now let's look ahead to Series 2.

646
01:57:10,000 --> 01:57:20,000
In Series 2, we stop talking about waste and start finding it. We run the complete cloud cost audit.

647
01:57:20,000 --> 01:57:30,000
We find gp2 volumes and migrate them to gp3. We find unattached Elastic IPs and release them.

648
01:57:30,000 --> 01:57:40,000
We find stopped instances and terminate them. We create VPC endpoints to eliminate NAT Gateway costs.

649
01:57:40,000 --> 01:57:50,000
We set up cost anomaly detection. We run the complete waste summary script.

650
01:57:50,000 --> 01:58:00,000
By the end of Series 2, you will have a list of actual dollar amounts of waste from your own account.

651
01:58:00,000 --> 01:58:10,000
Not estimated. Not projected. Real numbers. From your account. And a plan to eliminate every dollar.

652
01:58:10,000 --> 01:58:20,000
Before you start Series 2, verify these four things:

653
01:58:20,000 --> 01:58:30,000
One: aws sts get-caller-identity returns your account ID.

654
01:58:30,000 --> 01:58:40,000
Two: echo $START shows a date thirty days ago.

655
01:58:40,000 --> 01:58:50,000
Three: cat ~/finops-baseline.txt shows your total monthly spend.

656
01:58:50,000 --> 01:59:00,000
Four: the Cost Explorer service query returns real data.

657
01:59:00,000 --> 01:59:10,000
If all four are verified, you are ready for Series 2.

658
01:59:10,000 --> 01:59:20,000
Series 1 is complete. The foundation is laid. The baseline is set. The visibility is established.

659
01:59:20,000 --> 01:59:30,000
You have moved from guessing to knowing. From hoping to planning. From reactive to proactive.

660
01:59:30,000 --> 01:59:40,000
That is the difference between a junior engineer and a senior engineer. And you just made that leap.

661
01:59:40,000 --> 01:59:50,000
The commands work. The savings are real. You just have to do the work.

662
01:59:50,000 --> 02:00:00,000
See you in Series 2.
```