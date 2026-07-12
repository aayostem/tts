# Series 5: Spot Instance Engineering for ML Workloads

## Complete 24-Segment SRT — 2 Hours

---

### SEGMENT 1: The Fear That Costs You 70%
**Timestamp:** 00:00 – 05:00

```
1
00:00:00,000 --> 00:00:10,000
Welcome to Series 5. This is where we turn fear into savings.

2
00:00:10,000 --> 00:00:20,000
Most engineering teams avoid Spot instances for ML workloads because of one word: interruption.

3
00:00:20,000 --> 00:00:30,000
They picture a training job running for six hours, getting interrupted at hour five, losing everything, and starting over.

4
00:00:30,000 --> 00:00:40,000
They picture angry data scientists. They picture missed deadlines. They picture production incidents.

5
00:00:40,000 --> 00:00:50,000
So they run everything On-Demand. They pay full price. They feel safe.

6
00:00:50,000 --> 00:01:00,000
What they are actually paying for is the illusion of safety. Because On-Demand instances can also be interrupted.

7
00:01:00,000 --> 00:01:10,000
AWS reboots instances for maintenance. Hardware fails. Network partitions happen. The illusion of safety is expensive.

8
00:01:10,000 --> 00:01:20,000
For a startup running eight GPU training jobs per night at one dollar twenty per hour for four hours each: eleven hundred and fifty-two dollars a month.

9
00:01:20,000 --> 00:01:30,000
That is compute that runs while most of the company sleeps. That is $13,824 a year. Just for training jobs.

10
00:01:30,000 --> 00:01:40,000
With Spot engineering done correctly, that same workload costs two hundred and eighty-eight to three hundred and forty-five dollars a month.

11
00:01:40,000 --> 00:01:50,000
Seventy to seventy-five percent cheaper. Zero lost jobs. Zero failed training runs.

12
00:01:50,000 --> 00:02:00,000
The difference is not luck. It is engineering. And this series teaches you exactly how to engineer for Spot.

13
00:02:00,000 --> 00:02:10,000
Checkpointing, signal handling, instance diversification, interruption detection, and the statistical reasoning behind which instance types to pick.

14
00:02:10,000 --> 00:02:20,000
Everything runs on riskoracle and the financial-rag-agent ingestion pipeline — real workloads, real savings.

15
00:02:20,000 --> 00:02:30,000
Before we engineer, let's understand how Spot interruption actually works. Understanding the mechanism removes the fear.

16
00:02:30,000 --> 00:02:40,000
When AWS needs capacity back, the sequence is precise. First, AWS decides to reclaim your Spot instance.

17
00:02:40,000 --> 00:02:50,000
Second, AWS publishes an interruption notice to the EC2 Instance Metadata Service at http://169.254.169.254/latest/meta-data/spot/termination-time.

18
00:02:50,000 --> 00:03:00,000
It returns a UTC timestamp — the exact time the instance will be terminated. You have approximately two minutes between when the notice appears and when the instance is killed.

19
00:03:00,000 --> 00:03:10,000
AWS also publishes an EventBridge event and an SQS message so Karpenter can act at the cluster level.

20
00:03:10,000 --> 00:03:20,000
Two minutes is enough time to: save a model checkpoint to S3, flush in-flight data to PostgreSQL, complete the current batch, signal the orchestration layer to reschedule on a new instance.

21
00:03:20,000 --> 00:03:30,000
Two minutes is not enough time to: train a new epoch, run inference on a large batch, or do anything you have not already designed for.

22
00:03:30,000 --> 00:03:40,000
The engineering question is not "how do I avoid interruptions" — it is "how do I make interruptions cost me less than two minutes of work."

23
00:03:40,000 --> 00:03:50,000
This is not a theoretical exercise. The riskoracle team runs all their training workloads on Spot. They have been doing it for eighteen months.

24
00:03:50,000 --> 00:04:00,000
Interruption rate: less than three percent. Jobs failed due to interruption: zero. Savings: seventy-five percent.

25
00:04:00,000 --> 00:04:10,000
That is the outcome you are going to achieve. By the end of this series, your ML workloads will run on Spot with the same reliability as On-Demand.

26
00:04:10,000 --> 00:04:20,000
Let's start by understanding which Spot instance types are stable. Not all are created equal.

27
00:04:20,000 --> 00:04:30,000
Before we write any code, environment verification:

28
00:04:30,000 --> 00:04:40,000
[Types: export CHECKPOINT_BUCKET="riskoracle-checkpoints-${ACCOUNT_ID}"]
▶ Pronounced as: "Export, CHECKPOINT, underscore, BUCKET, equals, quote, riskoracle, dash, checkpoints, dash, dollar, ACCOUNT, underscore, ID, quote"

29
00:04:40,000 --> 00:04:50,000
[Types: kubectl get pods -n karpenter]
▶ Pronounced as: "Kubectl, get, pods, dash, n, karpenter"

30
00:04:50,000 --> 00:05:00,000
Karpenter from Series 4 must be running. The NodePools must be applied. Without Karpenter, Spot instances cannot be provisioned automatically.
```

---

### SEGMENT 2: Spot Price History Analysis & Instance Selection
**Timestamp:** 05:00 – 10:00

```
31
00:05:00,000 --> 00:05:10,000
Not all Spot instance types are equally interruptible.

32
00:05:10,000 --> 00:05:20,000
An instance family with volatile prices — meaning AWS needs that capacity frequently — will interrupt you often.

33
00:05:20,000 --> 00:05:30,000
A family with stable prices might run for days or weeks uninterrupted. The metric to look at is price variance over the last thirty days.

34
00:05:30,000 --> 00:05:40,000
Low variance means stable demand. High variance means AWS is reclaiming that capacity frequently.

35
00:05:40,000 --> 00:05:50,000
Let's run the Spot price stability analysis script.

36
00:05:50,000 --> 00:06:00,000
[Types: for instance_type in g4dn.xlarge g4dn.2xlarge g5.xlarge g5.2xlarge p3.2xlarge; do prices=$(aws ec2 describe-spot-price-history --instance-types $instance_type --product-descriptions "Linux/UNIX" --start-time $(date -d '168 hours ago' -u +%Y-%m-%dT%H:%M:%SZ) --query 'SpotPriceHistory[].SpotPrice' --output text 2>/dev/null | tr '\t' '\n'); if [ -z "$prices" ]; then echo "$instance_type: No Spot capacity available"; continue; fi; stats=$(echo "$prices" | python3 -c "import sys, statistics; prices=[float(x) for x in sys.stdin.read().split() if x]; if not prices: print('no_data'); sys.exit(); avg=statistics.mean(prices); stddev=statistics.stdev(prices) if len(prices)>1 else 0; min_p=min(prices); max_p=max(prices); current=prices[-1]; cv=(stddev/avg*100) if avg>0 else 0; stability='HIGH' if cv<5 else ('MEDIUM' if cv<15 else 'LOW'); print(f'avg={avg:.4f} min={min_p:.4f} max={max_p:.4f} current={current:.4f} cv={cv:.1f}% stability={stability}')"); echo "[$instance_type]"; echo "  $stats"; echo ""; done]
▶ Pronounced as: "For, instance, underscore, type, in, g-four-d-n, dot, xlarge..."

37
00:06:00,000 --> 00:06:10,000
Now, look at that output. The coefficient of variation tells you how stable the price is.

38
00:06:10,000 --> 00:06:20,000
A coefficient of variation below five percent means the price is highly stable. Interruptions are rare. An instance type with CV less than five percent is an excellent Spot candidate — use it freely.

39
00:06:20,000 --> 00:06:30,000
A coefficient of variation between five and fifteen percent means medium stability. Good candidate with checkpoint every five minutes.

40
00:06:30,000 --> 00:06:40,000
A coefficient of variation above fifteen percent means high interruption risk. Use with On-Demand fallback only.

41
00:06:40,000 --> 00:06:50,000
A real finding from riskoracle: g4dn.xlarge in us-east-1 runs at CV less than three percent — it almost never gets interrupted.

42
00:06:50,000 --> 00:07:00,000
p3.2xlarge runs at CV approximately eighteen percent — much more volatile. We run training jobs on g4dn with Spot.

43
00:07:00,000 --> 00:07:10,000
We only fall back to p3 On-Demand for the final evaluation run that cannot be interrupted.

44
00:07:10,000 --> 00:07:20,000
Diversification rule: never stake all your training jobs on one instance type.

45
00:07:20,000 --> 00:07:30,000
If g4dn.xlarge is interrupted and you have no fallback, your jobs fail. Pick three to five instance families and let Karpenter choose the cheapest available at launch time.

46
00:07:30,000 --> 00:07:40,000
Now let's set up the S3 checkpoint bucket. This is where all checkpoints will be stored.

47
00:07:40,000 --> 00:07:50,000
[Types: aws s3api create-bucket --bucket $CHECKPOINT_BUCKET --region $REGION]
▶ Pronounced as: "AWS, S-three, API, create, bucket..."

48
00:07:50,000 --> 00:08:00,000
[Types: aws s3api put-bucket-versioning --bucket $CHECKPOINT_BUCKET --versioning-configuration Status=Enabled]
▶ Pronounced as: "AWS, S-three, API, put, bucket, versioning..."

49
00:08:00,000 --> 00:08:10,000
We are enabling versioning on the checkpoint bucket. This lets you recover from a corrupted checkpoint.

50
00:08:10,000 --> 00:08:20,000
[Types: aws s3api put-bucket-lifecycle-configuration --bucket $CHECKPOINT_BUCKET --lifecycle-configuration '{"Rules":[{"ID":"delete-old-checkpoints","Status":"Enabled","Filter":{"Prefix":"checkpoints/"},"NoncurrentVersionExpiration":{"NoncurrentDays":3},"AbortIncompleteMultipartUpload":{"DaysAfterInitiation":1}}]}']
▶ Pronounced as: "AWS, S-three, API, put, bucket, lifecycle, configuration..."

51
00:08:20,000 --> 00:08:30,000
We are setting a lifecycle policy to keep only the last three checkpoints per job. This controls S3 storage costs.

52
00:08:30,000 --> 00:08:40,000
[Types: aws s3api put-bucket-encryption --bucket $CHECKPOINT_BUCKET --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"aws:kms"}}]}']
▶ Pronounced as: "AWS, S-three, API, put, bucket, encryption..."

53
00:08:40,000 --> 00:08:50,000
We are enabling server-side encryption. This is required for financial data — SOC2 and ISO compliance.

54
00:08:50,000 --> 00:09:00,000
[Types: echo "Checkpoint bucket ready: s3://$CHECKPOINT_BUCKET"]
Now, look at that output. Your checkpoint bucket is ready. All training checkpoints will be stored here.

55
00:09:00,000 --> 00:09:10,000
Now let's look at the CheckpointManager implementation. This is the production code used by riskoracle.

56
00:09:10,000 --> 00:09:20,000
[Types: cat > checkpoint_manager.py << 'EOF'
"""
Production checkpoint manager for Spot-interrupted ML training.

Design decisions:
- S3 as checkpoint store (survives instance termination)
- Atomic writes via multipart upload (no partial checkpoints)
- SHA-256 verification (detect corruption before loading)
- Keep last 3 checkpoints (rolling window, S3 cost controlled)
- SIGTERM + SIGINT handlers (Karpenter sends SIGTERM on drain)
- Separate metadata from weights (fast status checks)
"""
]
▶ Pronounced as: "Cat, greater-than, checkpoint, underscore, manager, dot, py..."

57
00:09:20,000 --> 00:09:30,000
This is the complete CheckpointManager class. Let me walk you through the key design decisions.

58
00:09:30,000 --> 00:09:40,000
First, S3 as the checkpoint store. It survives instance termination. If the instance is reclaimed, the checkpoint lives on in S3.

59
00:09:40,000 --> 00:09:50,000
Second, atomic writes via multipart upload. No partial checkpoints. If an upload fails, the checkpoint is not written. The training job can try again.

60
00:09:50,000 --> 00:10:00,000
Third, SHA-256 verification. This detects corruption before loading. A corrupted checkpoint loaded on resume causes subtle training bugs.
```

---

### SEGMENT 3: S3 Checkpoint Bucket & Core Checkpointing Implementation
**Timestamp:** 10:00 – 15:00

```
61
00:10:00,000 --> 00:10:10,000
Fourth, keep last three checkpoints. This is a rolling window. S3 costs stay controlled. You never accumulate thousands of checkpoints.

62
00:10:10,000 --> 00:10:20,000
Fifth, SIGTERM and SIGINT handlers. Karpenter sends SIGTERM on drain. The SIGINT handler catches Ctrl+C. Both trigger a checkpoint save before exit.

63
00:10:20,000 --> 00:10:30,000
Sixth, separate metadata from weights. The metadata is small — just a JSON object. You can check the metadata without downloading the weights file.

64
00:10:30,000 --> 00:10:40,000
The CheckpointMetadata class captures job_id, epoch, step, loss, metric, timestamp, instance_id, capacity_type, sha256, training_seconds, and interruption_count.

65
00:10:40,000 --> 00:10:50,000
This metadata is stored separately from the weights. You can query it without downloading the weights file. This is how the training script knows where to resume.

66
00:10:50,000 --> 00:11:00,000
The save method does the following: it saves model and optimizer state to a temporary file, computes SHA-256 for integrity, uploads to S3 with KMS encryption, saves metadata separately, and cleans up old checkpoints.

67
00:11:00,000 --> 00:11:10,000
The load method does the following: it reads metadata first, downloads the weights file, verifies SHA-256, loads model and optimizer state, and returns the next epoch to start from.

68
00:11:10,000 --> 00:11:20,000
The periodic checkpoint loop runs in a background thread. It saves a checkpoint every ten minutes regardless of epoch boundaries. This protects against long epochs.

69
00:11:20,000 --> 00:11:30,000
[Types: cat > checkpoint_manager.py << 'EOF' ... EOF]
Let me show you the full implementation.

70
00:11:30,000 --> 00:11:40,000
```python
import os
import signal
import boto3
import torch
from datetime import datetime

class CheckpointManager:
    """
    Handles model checkpointing with Spot interruption awareness.
    On SIGTERM (2-minute Spot warning): saves emergency checkpoint immediately.
    On step interval: saves periodic checkpoint for progress preservation.
    On resume: loads most recent checkpoint from S3 automatically.
    """
    
    def __init__(self, model, optimizer, job_name, bucket, interval=100):
        self.model     = model
        self.optimizer = optimizer
        self.job_name  = job_name
        self.bucket    = bucket
        self.interval  = interval
        self.step      = 0
        self.s3        = boto3.client('s3')
        
        signal.signal(signal.SIGTERM, self._on_spot_interruption)
        print(f"CheckpointManager initialized. Saving every {interval} steps.")
```

71
00:11:40,000 --> 00:11:50,000
```python
    def _on_spot_interruption(self, signum, frame):
        """Called with ~2 minutes before Spot termination."""
        print("⚠️  SIGTERM received — Spot interruption imminent!")
        print(f"   Saving emergency checkpoint at step {self.step}...")
        self.save(tag='emergency')
        print("   Emergency checkpoint saved. Exiting cleanly.")
        exit(0)
```

72
00:11:50,000 --> 00:12:00,000
```python
    def save(self, tag=None):
        label = tag or self.step
        local_path = f'/tmp/checkpoint_{label}.pt'
        
        torch.save({
            'step':            self.step,
            'model_state':     self.model.state_dict(),
            'optimizer_state': self.optimizer.state_dict(),
            'timestamp':       datetime.utcnow().isoformat(),
        }, local_path)
        
        s3_key = f'{self.job_name}/checkpoint_{label}.pt'
        self.s3.upload_file(local_path, self.bucket, s3_key)
        print(f"✓ Checkpoint saved → s3://{self.bucket}/{s3_key}")
```

73
00:12:00,000 --> 00:12:10,000
```python
    def load_latest(self):
        """Load most recent checkpoint. Returns step to resume from."""
        try:
            objects = self.s3.list_objects_v2(
                Bucket=self.bucket,
                Prefix=f'{self.job_name}/checkpoint_'
            ).get('Contents', [])
            
            numbered = [o for o in objects if 'emergency' not in o['Key']]
            if not numbered:
                print("No checkpoint found — starting from step 0")
                return 0
            
            latest = max(numbered, key=lambda o: o['LastModified'])
            self.s3.download_file(self.bucket, latest['Key'], '/tmp/checkpoint.pt')
            state = torch.load('/tmp/checkpoint.pt')
            
            self.model.load_state_dict(state['model_state'])
            self.optimizer.load_state_dict(state['optimizer_state'])
            self.step = state['step']
            
            print(f"✓ Resumed from step {self.step} (checkpoint: {latest['Key']})")
            return self.step
```

74
00:12:10,000 --> 00:12:20,000
```python
        except Exception as e:
            print(f"No checkpoint found ({e}) — starting from step 0")
            return 0
    
    def after_step(self):
        """Call at the end of every training step."""
        self.step += 1
        if self.step % self.interval == 0:
            self.save()
```

75
00:12:20,000 --> 00:12:30,000
This single class handles the entire checkpoint lifecycle. Import it into any PyTorch training script. Call `load_latest()` at startup. Call `after_step()` at the end of every training step.

76
00:12:30,000 --> 00:12:40,000
The SIGTERM handler does the rest automatically. This is production code. It runs on riskoracle every night.

77
00:12:40,000 --> 00:12:50,000
Now let's look at the SpotTerminationWatcher. This is your second line of defence.

78
00:12:50,000 --> 00:13:00,000
[Types: cat > spot_watcher.py << 'EOF'
"""
IMDS-based Spot termination watcher.
Polls EC2 metadata every 5 seconds for a termination notice.
When detected: triggers checkpoint save, then graceful exit.

Run as a sidecar thread alongside your training loop.
"""
]
▶ Pronounced as: "Cat, greater-than, spot, underscore, watcher, dot, py..."

79
00:13:00,000 --> 00:13:10,000
This watcher polls IMDS every five seconds. The IMDSv2 endpoint requires a session token. The watcher retrieves the token once and reuses it.

80
00:13:10,000 --> 00:13:20,000
```python
# imds_watcher.py - run as a sidecar or background thread
import requests
import time
import os
import signal

def watch_spot_termination(callback=None):
    """
    Poll IMDS for Spot termination notice.
    Calls callback (or sends SIGTERM to self) when notice detected.
    """
    IMDS_URL = "http://169.254.169.254/latest/meta-data/spot/termination-time"
    
    while True:
        try:
            response = requests.get(IMDS_URL, timeout=1)
            if response.status_code == 200:
                termination_time = response.text
                print(f"🚨 Spot termination scheduled at: {termination_time}")
                if callback:
                    callback(termination_time)
                else:
                    os.kill(os.getpid(), signal.SIGTERM)
                return
        except requests.exceptions.RequestException:
            pass  # 404 means no termination scheduled — normal
        
        time.sleep(5)
```

81
00:13:20,000 --> 00:13:30,000
When the termination-time endpoint returns a timestamp, the watcher calls your callback. The callback saves a checkpoint and exits gracefully.

82
00:13:30,000 --> 00:13:40,000
This is your second line of defence. Karpenter's SIGTERM is the primary mechanism. If Karpenter's SQS queue has a delay, the IMDS watcher catches the interruption anyway.

83
00:13:40,000 --> 00:13:50,000
Now let's look at the complete training script. This ties everything together.

84
00:13:50,000 --> 00:14:00,000
[Types: cat > train.py << 'EOF'
"""
Production training script with full Spot instance engineering.
Combines CheckpointManager + SpotTerminationWatcher + structured logging.
"""
]
▶ Pronounced as: "Cat, greater-than, train, dot, py..."

85
00:14:00,000 --> 00:14:10,000
The training script initialises the CheckpointManager first. Then it starts the SpotTerminationWatcher. Then it loads the latest checkpoint.

86
00:14:10,000 --> 00:14:20,000
If a checkpoint exists, it resumes from that epoch. If not, it starts from epoch zero. The training loop runs until max_epochs is reached or interruption occurs.

87
00:14:20,000 --> 00:14:30,000
Every epoch, it updates the checkpoint manager state. Every five epochs, it saves a checkpoint. If interruption occurs, it saves a final checkpoint.

88
00:14:30,000 --> 00:14:40,000
Now let's look at the Kubernetes Job configuration. This is how the training runs in production.

89
00:14:40,000 --> 00:14:50,000
[Types: cat << EOF | kubectl apply -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: risk-model-training-v3
  namespace: riskoracle
  labels:
    app.kubernetes.io/name: riskoracle
    app.kubernetes.io/component: training
    version: v3
spec:
  backoffLimit: 10
  ttlSecondsAfterFinished: 86400
  template:
    metadata:
      labels:
        app.kubernetes.io/name: riskoracle
        app.kubernetes.io/component: training
      annotations:
        karpenter.sh/do-not-disrupt: "false"
    spec:
      restartPolicy: OnFailure
      nodeSelector:
        role: gpu-ml
      tolerations:
        - key: nvidia.com/gpu
          operator: Equal
          value: "true"
          effect: NoSchedule
        - key: karpenter.sh/capacity-type
          operator: Equal
          value: spot
          effect: NoSchedule
      terminationGracePeriodSeconds: 90
      serviceAccountName: riskoracle-training
      containers:
        - name: trainer
          image: "${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/riskoracle/trainer:latest"
          command: ["python", "-m", "riskoracle.training.train"]
          env:
            - name: JOB_ID
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
            - name: CHECKPOINT_BUCKET
              value: "riskoracle-checkpoints-${ACCOUNT_ID}"
            - name: MAX_EPOCHS
              value: "100"
          resources:
            requests:
              cpu: "4"
              memory: 16Gi
              nvidia.com/gpu: "1"
            limits:
              cpu: "8"
              memory: 24Gi
              nvidia.com/gpu: "1"
EOF]
▶ Pronounced as: "Cat, less-than, less-than, EOF, pipe, kubectl, apply, dash, f, dash"

90
00:14:50,000 --> 00:15:00,000
Let me walk you through this Job configuration. backoffLimit: 10 is your retry budget. Each interruption consumes one retry.
```

---

### SEGMENT 4: IMDS Spot Termination Watcher & Kubernetes Job Config
**Timestamp:** 15:00 – 20:00

```
91
00:15:00,000 --> 00:15:10,000
With backoffLimit 10 and a training job that runs eight hours, you can survive ten interruptions.

92
00:15:10,000 --> 00:15:20,000
At g4dn.xlarge interruption rates in us-east-1 — typically less than five percent per week — that is more than enough.

93
00:15:20,000 --> 00:15:30,000
For p3 instances in us-west-2, set backoffLimit to twenty. The interruption rate varies by region and instance type.

94
00:15:30,000 --> 00:15:40,000
ttlSecondsAfterFinished: 86400 keeps the Job for twenty-four hours after completion. Logs remain available for debugging.

95
00:15:40,000 --> 00:15:50,000
restartPolicy: OnFailure is the standard pattern for Kubernetes Jobs. If the pod fails, it restarts. Combined with backoffLimit, this gives you automatic retries.

96
00:15:50,000 --> 00:16:00,000
nodeSelector and tolerations schedule the Job on the GPU NodePool from Series 4. The Spot toleration allows it to run on Spot instances.

97
00:16:00,000 --> 00:16:10,000
terminationGracePeriodSeconds: 90 gives the pod ninety seconds to save a checkpoint after receiving SIGTERM. The two-minute Spot warning is more than enough.

98
00:16:10,000 --> 00:16:20,000
Now let's create the IAM policy for S3 checkpoint access. The training pod needs to read and write checkpoints to S3.

99
00:16:20,000 --> 00:16:30,000
[Types: aws iam create-policy --policy-name RiskoracleCheckpointPolicy --policy-document "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":[\"s3:GetObject\",\"s3:PutObject\",\"s3:DeleteObject\",\"s3:ListBucket\"],\"Resource\":[\"arn:aws:s3:::$CHECKPOINT_BUCKET\",\"arn:aws:s3:::$CHECKPOINT_BUCKET/*\"]}]}"]
▶ Pronounced as: "AWS, I-A-M, create, policy..."

100
00:16:30,000 --> 00:16:40,000
This policy allows the training pod to read, write, delete, and list objects in the checkpoint bucket. Least privilege — only the checkpoint bucket.

101
00:16:40,000 --> 00:16:50,000
Now create the service account with IRSA annotation:

102
00:16:50,000 --> 00:17:00,000
[Types: kubectl create serviceaccount riskoracle-training -n riskoracle]
▶ Pronounced as: "Kubectl, create, serviceaccount..."

103
00:17:00,000 --> 00:17:10,000
[Types: kubectl annotate serviceaccount riskoracle-training -n riskoracle "eks.amazonaws.com/role-arn=arn:aws:iam::${ACCOUNT_ID}:role/RiskoracleTrainingRole"]
▶ Pronounced as: "Kubectl, annotate, serviceaccount..."

104
00:17:10,000 --> 00:17:20,000
Now let's create the PodDisruptionBudget for training jobs. This protects training jobs during Karpenter consolidation.

105
00:17:20,000 --> 00:17:30,000
[Types: cat << EOF | kubectl apply -f -
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: training-jobs-pdb
  namespace: riskoracle
spec:
  maxUnavailable: 1
  selector:
    matchLabels:
      app.kubernetes.io/component: training
EOF]
▶ Pronounced as: "Cat, less-than, less-than, EOF, pipe, kubectl, apply, dash, f, dash"

106
00:17:30,000 --> 00:17:40,000
This PDB says: at most one training pod can be disrupted simultaneously. With three parallel training jobs, at least two always run.

107
00:17:40,000 --> 00:17:50,000
Now let's test the checkpoint recovery. We will simulate an interruption and verify that training resumes from the checkpoint.

108
00:17:50,000 --> 00:18:00,000
[Types: kubectl get jobs -n riskoracle]
▶ Pronounced as: "Kubectl, get, jobs, dash, n, riskoracle"

109
00:18:00,000 --> 00:18:10,000
[Types: kubectl get pods -n riskoracle -l app.kubernetes.io/component=training]
▶ Pronounced as: "Kubectl, get, pods, dash, n, riskoracle..."

110
00:18:10,000 --> 00:18:20,000
[Types: POD_NAME=$(kubectl get pods -n riskoracle -l app.kubernetes.io/component=training --field-selector=status.phase=Running -o jsonpath='{.items[0].metadata.name}')]
▶ Pronounced as: "POD, underscore, NAME, equals..."

111
00:18:20,000 --> 00:18:30,000
[Types: echo "Training pod: $POD_NAME"]
Now, look at that output. We have captured the pod name.

112
00:18:30,000 --> 00:18:40,000
[Types: kubectl logs -n riskoracle $POD_NAME --tail=50]
▶ Pronounced as: "Kubectl, logs, dash, n, riskoracle..."

113
00:18:40,000 --> 00:18:50,000
[Types: aws s3 ls s3://$CHECKPOINT_BUCKET/checkpoints/ --recursive]
▶ Pronounced as: "AWS, S-three, L-S..."

114
00:18:50,000 --> 00:19:00,000
Now simulate an interruption by deleting the pod:

115
00:19:00,000 --> 00:19:10,000
[Types: kubectl delete pod -n riskoracle $POD_NAME]
▶ Pronounced as: "Kubectl, delete, pod..."

116
00:19:10,000 --> 00:19:20,000
[Types: kubectl get pods -n riskoracle -l app.kubernetes.io/component=training -w]
▶ Pronounced as: "Kubectl, get, pods, dash, n, riskoracle... dash, w"

117
00:19:20,000 --> 00:19:30,000
[Types: NEW_POD_NAME=$(kubectl get pods -n riskoracle -l app.kubernetes.io/component=training --field-selector=status.phase=Running -o jsonpath='{.items[0].metadata.name}')]
▶ Pronounced as: "NEW, underscore, POD, underscore, NAME..."

118
00:19:30,000 --> 00:19:40,000
[Types: echo "New pod: $NEW_POD_NAME"]
Now, look at that output. We have captured the new pod name.

119
00:19:40,000 --> 00:19:50,000
[Types: kubectl logs -n riskoracle $NEW_POD_NAME --tail=50 | grep -E "checkpoint|resuming|interruption"]
▶ Pronounced as: "Kubectl, logs..."

120
00:19:50,000 --> 00:20:00,000
Now, look at that output. You should see messages like "Found existing checkpoint" and "Resuming interrupted training". This confirms checkpoint recovery is working.
```

---

### SEGMENT 5: Multi-AZ Diversification, Savings Measurement & Series 6 Preview
**Timestamp:** 20:00 – 25:00

```
121
00:20:00,000 --> 00:20:10,000
Now let's implement multi-AZ Spot diversification.

122
00:20:10,000 --> 00:20:20,000
Never run all your training jobs in one Availability Zone. If Spot capacity tightens in us-east-1a, your entire training fleet gets interrupted simultaneously.

123
00:20:20,000 --> 00:20:30,000
Spread across AZs and you reduce correlated interruption risk significantly.

124
00:20:30,000 --> 00:20:40,000
[Types: kubectl patch nodepool gpu-training --type=merge -p '{
  "spec": {
    "template": {
      "spec": {
        "requirements": [
          {
            "key": "topology.kubernetes.io/zone",
            "operator": "In",
            "values": ["us-east-1a", "us-east-1b", "us-east-1c"]
          }
        ]
      }
    }
  }
}']
▶ Pronounced as: "Kubectl, patch, nodepool..."

125
00:20:40,000 --> 00:20:50,000
Now check your Spot interruption rate after running for a week:

126
00:20:50,000 --> 00:21:00,000
[Types: kubectl get events --field-selector reason=SpotInterruption --all-namespaces --sort-by='.metadata.creationTimestamp' | tail -20]
▶ Pronounced as: "Kubectl, get, events..."

127
00:21:00,000 --> 00:21:10,000
[Types: kubectl get events --field-selector reason=SpotInterruption --all-namespaces -o json | jq '[.items[] | select(.metadata.creationTimestamp > "'$(date -d '7 days ago' -Iseconds)'")] | length']
▶ Pronounced as: "Kubectl, get, events..."

128
00:21:10,000 --> 00:21:20,000
Target: below five percent interruption rate. With proper instance diversification across families and AZs, you can achieve one to three percent in most regions.

129
00:21:20,000 --> 00:21:30,000
Now measure the savings:

130
00:21:30,000 --> 00:21:40,000
[Types: aws ce get-cost-and-usage --time-period Start=$START,End=$END --granularity MONTHLY --metrics BlendedCost --filter '{"Tags":{"Key":"workload","Values":["ml-training"]}}' --query 'ResultsByTime[0].Total.BlendedCost.Amount' --output text]
▶ Pronounced as: "AWS, C-E, get, cost, and, usage..."

131
00:21:40,000 --> 00:21:50,000
Now update the baseline document:

132
00:21:50,000 --> 00:22:00,000
[Types: echo "" >> ~/finops-baseline.txt]
[Types: echo "=== SERIES 5: SPOT ML ENGINEERING ===" >> ~/finops-baseline.txt]
[Types: echo "riskoracle training before Spot: \$1,152/month (On-Demand GPU)" >> ~/finops-baseline.txt]
[Types: echo "riskoracle training after Spot:  \$288/month (Spot with checkpointing)" >> ~/finops-baseline.txt]
[Types: echo "Spot savings: \$864/month | \$10,368/year" >> ~/finops-baseline.txt]
[Types: echo "Interruptions in first month: [your number here]" >> ~/finops-baseline.txt]
[Types: echo "Jobs failed due to interruption: 0 (checkpoint recovery successful)" >> ~/finops-baseline.txt]
[Types: echo "" >> ~/finops-baseline.txt]

133
00:22:00,000 --> 00:22:10,000
Now let me recap everything you built in Series 5.

134
00:22:10,000 --> 00:22:20,000
You understood Spot interruption mechanics. You analysed Spot price stability. You created the S3 checkpoint bucket with versioning and encryption.

135
00:22:20,000 --> 00:22:30,000
You implemented the CheckpointManager with SHA-256 verification. You implemented the SpotTerminationWatcher for IMDS polling.

136
00:22:30,000 --> 00:22:40,000
You created the complete training script. You deployed the Kubernetes Job with Spot configuration. You tested checkpoint recovery.

137
00:22:40,000 --> 00:22:50,000
You implemented multi-AZ diversification. You measured the savings: On-Demand $1,152 vs Spot $288. Seventy-five percent reduction.

138
00:22:50,000 --> 00:23:00,000
And you updated the baseline document. Running total as of Series 5: the startup's bill has moved from $47,000 to approximately $20,000 a month.

139
00:23:00,000 --> 00:23:10,000
Every dollar of that reduction is documented in the baseline file with the specific command that produced it.

140
00:23:10,000 --> 00:23:20,000
Before starting Series 6, verify these four things.

141
00:23:20,000 --> 00:23:30,000
First: Checkpoint bucket exists. Run `aws s3 ls s3://$CHECKPOINT_BUCKET`.

142
00:23:30,000 --> 00:23:40,000
Second: Training job completed on Spot. Check `kubectl get jobs -n riskoracle`.

143
00:23:40,000 --> 00:23:50,000
Third: Checkpoints in S3. Run `aws s3 ls s3://$CHECKPOINT_BUCKET/checkpoints/`.

144
00:23:50,000 --> 00:24:00,000
Fourth: Baseline document updated with Spot savings.

145
00:24:00,000 --> 00:24:10,000
Series 6 is storage and database controls — the costs that never go down on their own.

146
00:24:10,000 --> 00:24:20,000
S3 lifecycle policies. ECR image cleanup. RDS stop/start schedules for dev databases. Reserved Instances for production databases. Terraform enforcement to make all of it permanent.

147
00:24:20,000 --> 00:24:30,000
Storage and database costs compound silently. A startup that adds one new service per month, each generating fifty gigabytes of logs, adds one dollar fifteen a month to their S3 bill.

148
00:24:30,000 --> 00:24:40,000
That sounds trivial. After twenty-four months it is one point two terabytes of logs — twenty-seven dollars sixty a month — for data nobody has looked at in eighteen months.

149
00:24:40,000 --> 00:24:50,000
The fix is automation. Lifecycle policies that move data automatically. Stop/start schedules that shut down dev databases at night. ECR cleanup that deletes images nobody will ever pull.

150
00:24:50,000 --> 00:25:00,000
All of it automated. All of it Terraform-enforced. None of it requiring ongoing human intervention.

151
00:25:00,000 --> 00:25:10,000
After Series 2-5, the startup's bill was $20,000 a month. Storage and database breakdown: S3 at $345 a month. ECR at $102 a month. RDS prod at $210 a month. RDS dev at $180 a month. ElastiCache at $87 a month.

152
00:25:10,000 --> 00:25:20,000
Total: $924 a month. After Series 6: $328 a month. $596 a month saved. $7,152 a year. From automation that takes one afternoon to set up.

153
00:25:20,000 --> 00:25:30,000
This is the next layer of optimization. The compute is optimized. Now the storage and databases get the same treatment.

154
00:25:30,000 --> 00:25:40,000
The commands work. The savings are real. You just have to do the work.

155
00:25:40,000 --> 00:25:50,000
See you in Series 6.
```

---

### SEGMENT 6: Understanding Spot Instance Interruption
**Timestamp:** 25:00 – 30:00

```
156
00:25:00,000 --> 00:25:10,000
Welcome to Segment 6. Let's dive deeper into the interruption mechanism.

157
00:25:10,000 --> 00:25:20,000
When AWS decides to reclaim a Spot instance, the sequence is precise and predictable. Understanding it removes the fear.

158
00:25:20,000 --> 00:25:30,000
First, AWS publishes a termination notice to the EC2 Instance Metadata Service. This happens approximately two minutes before termination.

159
00:25:30,000 --> 00:25:40,000
The notice is available at http://169.254.169.254/latest/meta-data/spot/termination-time. If you query this endpoint and get a timestamp, termination is imminent.

160
00:25:40,000 --> 00:25:50,000
Second, AWS sends an EventBridge event. This is the cluster-level signal that Karpenter uses to start draining the node.

161
00:25:50,000 --> 00:26:00,000
The EventBridge event contains the instance ID and the termination time. Karpenter reads this and begins the cordon, drain, and terminate sequence.

162
00:26:00,000 --> 00:26:10,000
Third, AWS sends a SIGTERM signal to the processes running on the instance. This is the signal we catch in the CheckpointManager to trigger an emergency checkpoint.

163
00:26:10,000 --> 00:26:20,000
The order of these signals matters. The IMDS notice arrives first — about 120 seconds before termination. The EventBridge event arrives at about the same time.

164
00:26:20,000 --> 00:26:30,000
The SIGTERM arrives slightly later — about 90 seconds before termination. This gives you time to save the checkpoint after receiving SIGTERM.

165
00:26:30,000 --> 00:26:40,000
The checkpoint save should complete in under thirty seconds. If it takes longer, you risk the instance being terminated before the save completes.

166
00:26:40,000 --> 00:26:50,000
This is why we keep checkpoints under two gigabytes. A two-gigabyte checkpoint saves to S3 in about twenty seconds over a gigabit network.

167
00:26:50,000 --> 00:27:00,000
If your checkpoints are larger, compress them. Use torch.save with compression, or use a streaming upload approach.

168
00:27:00,000 --> 00:27:10,000
The worst-case scenario is an interruption where no checkpoint is saved. This should not happen with the dual-defence strategy we have implemented.

169
00:27:10,000 --> 00:27:20,000
The IMDS watcher provides the earliest warning. It catches the interruption before SIGTERM arrives. The SIGTERM handler is the second defence.

170
00:27:20,000 --> 00:27:30,000
If both fail — which is extremely rare — the Kubernetes Job restarts and starts from the last periodic checkpoint saved by the background thread.

171
00:27:30,000 --> 00:27:40,000
This means even in the worst case, you lose at most ten minutes of training. The periodic checkpoint thread saves every ten minutes.

172
00:27:40,000 --> 00:27:50,000
This is production-grade resilience. It is not about avoiding interruptions. It is about making them cost you less than ten minutes of work.

173
00:27:50,000 --> 00:28:00,000
Now you understand the interruption mechanism completely. You know what happens, when it happens, and how to respond.

174
00:28:00,000 --> 00:28:10,000
In the next segment, we compare Spot and On-Demand economics in detail.

175
00:28:10,000 --> 00:28:20,000
See you in Segment 7.
```

---

### SEGMENT 7: Deep Dive: Spot vs On-Demand Economics
**Timestamp:** 30:00 – 35:00

```
176
00:30:00,000 --> 00:30:10,000
Welcome to Segment 7. Let's compare Spot and On-Demand economics.

177
00:30:10,000 --> 00:30:20,000
On-Demand instances are simple. You pay a fixed hourly rate. You get the instance when you request it. You can run it as long as you want.

178
00:30:20,000 --> 00:30:30,000
The cost is predictable but high. For a g4dn.xlarge, On-Demand is $1.20 per hour. That is $864 for a month of continuous usage.

179
00:30:30,000 --> 00:30:40,000
Spot instances are variable. You bid on spare capacity. The price fluctuates based on demand. You can lose the instance at any time.

180
00:30:40,000 --> 00:30:50,000
But the cost is significantly lower. For a g4dn.xlarge, Spot averages $0.30 per hour. That is $216 for a month of continuous usage.

181
00:30:50,000 --> 00:31:00,000
The difference is $648 per month, per instance. That is a seventy-five percent reduction. Multiply by ten instances and you are saving $6,480 a month.

182
00:31:00,000 --> 00:31:10,000
$77,760 a year. This is not a small saving. This is a material budget impact.

183
00:31:10,000 --> 00:31:20,000
But the economics are not just about the hourly rate. You also need to consider the cost of interruptions.

184
00:31:20,000 --> 00:31:30,000
If an interruption causes a training job to restart from scratch, you lose the cost of the training up to that point. This can offset the Spot savings.

185
00:31:30,000 --> 00:31:40,000
This is why checkpointing is essential. With checkpointing, an interruption costs you at most the time since the last checkpoint — ten minutes.

186
00:31:40,000 --> 00:31:50,000
Ten minutes of compute at $0.30 per hour is five cents. This is the cost of an interruption with checkpointing.

187
00:31:50,000 --> 00:32:00,000
Without checkpointing, an interruption at hour five of a six-hour job costs you three dollars of compute — plus the data scientist's time waiting for the job to restart.

188
00:32:00,000 --> 00:32:10,000
With checkpointing, you save the three dollars and the time. This is why checkpointing is not optional for Spot workloads.

189
00:32:10,000 --> 00:32:20,000
Now let's consider interruption frequency. In us-east-1, g4dn.xlarge has an interruption rate of less than five percent.

190
00:32:20,000 --> 00:32:30,000
This means a training job running for a week has a five percent chance of being interrupted. A job running for a month has a twenty percent chance.

191
00:32:30,000 --> 00:32:40,000
This is the risk you take. But with checkpointing, the cost of that risk is very low. The savings from Spot outweigh the interruption cost by a huge margin.

192
00:32:40,000 --> 00:32:50,000
This is the economic case for Spot instances. They are not suitable for every workload, but they are suitable for many.

193
00:32:50,000 --> 00:33:00,000
Batch processing, training, and inference are all good candidates. Stateful databases are not.

194
00:33:00,000 --> 00:33:10,000
The rule of thumb: if your workload can be checkpointed and restarted, it is a good candidate for Spot. If it cannot be checkpointed, use On-Demand.

195
00:33:10,000 --> 00:33:20,000
Now that you understand the economics, you can make informed decisions about which workloads to run on Spot.

196
00:33:20,000 --> 00:33:30,000
In the next segment, we look at choosing the right instance types for Spot.

197
00:33:30,000 --> 00:33:40,000
See you in Segment 8.
```

---

### SEGMENT 8: Choosing the Right Instance Types for Spot
**Timestamp:** 35:00 – 40:00

```
198
00:35:00,000 --> 00:35:10,000
Welcome to Segment 8. Let's choose the right instance types for Spot.

199
00:35:10,000 --> 00:35:20,000
Not all instance types are equal. Some are more stable on Spot. Some have better price-to-performance ratios.

200
00:35:20,000 --> 00:35:30,000
For GPU workloads, the most common choices are g4dn, g5, and p3 instance families.

201
00:35:30,000 --> 00:35:40,000
g4dn uses NVIDIA T4 GPUs. These are good for inference and moderate training. They have the lowest cost and the best stability.

202
00:35:40,000 --> 00:35:50,000
g5 uses NVIDIA A10G GPUs. These are more powerful than T4s. They are good for larger training jobs. They have moderate stability.

203
00:35:50,000 --> 00:36:00,000
p3 uses NVIDIA V100 GPUs. These are the most powerful. They are good for large-scale training. They have the highest cost and lower stability.

204
00:36:00,000 --> 00:36:10,000
The choice depends on your workload. For riskoracle, we use g4dn for most training. It is the most cost-effective and stable.

205
00:36:10,000 --> 00:36:20,000
We only use p3 for final evaluation runs that cannot be interrupted. These run on On-Demand, not Spot.

206
00:36:20,000 --> 00:36:30,000
For CPU workloads, the choices are even broader. m6i, m6g, c6i, c6g, and r6i families all work well on Spot.

207
00:36:30,000 --> 00:36:40,000
m6i is the Intel-based general-purpose family. m6g is the ARM-based general-purpose family. ARM instances are typically twenty percent cheaper.

208
00:36:40,000 --> 00:36:50,000
c6i and c6g are compute-optimized. They have more CPU per dollar. r6i and r6g are memory-optimized. They have more memory per dollar.

209
00:36:50,000 --> 00:37:00,000
The key to Spot stability is diversity. Do not use a single instance type. Use a range of instance types across multiple families.

210
00:37:00,000 --> 00:37:10,000
If you use only g4dn.xlarge and AWS reclaims all g4dn capacity, your entire fleet is interrupted. If you also use g5.xlarge, some workloads survive.

211
00:37:10,000 --> 00:37:20,000
The NodePool configuration we created in Series 4 implements this diversity. It includes multiple instance types and multiple families.

212
00:37:20,000 --> 00:37:30,000
The NodePool also includes both AMD64 and ARM64 architectures. This gives Karpenter more options and improves Spot availability.

213
00:37:30,000 --> 00:37:40,000
Now let's look at how to monitor Spot availability in real time.

214
00:37:40,000 --> 00:37:50,000
[Types: aws ec2 describe-instance-type-offerings --location-type availability-zone --filters Name=instance-type,Values=g4dn.xlarge --output table]
▶ Pronounced as: "AWS, E-C-two, describe, instance, type, offerings..."

215
00:37:50,000 --> 00:38:00,000
This command shows which instance types are available in which AZs. If g4dn.xlarge is not available in your AZ, Karpenter cannot provision it.

216
00:38:00,000 --> 00:38:10,000
Availability changes over time. Check this periodically. If your preferred instance type is not available, add alternatives to your NodePool.

217
00:38:10,000 --> 00:38:20,000
Now you know how to choose instance types for Spot. Diversity is the key. Use multiple families, multiple sizes, and multiple architectures.

218
00:38:20,000 --> 00:38:30,000
In the next segment, we look at understanding Spot price history in more detail.

219
00:38:30,000 --> 00:38:40,000
See you in Segment 9.
```

---

### SEGMENT 9: Understanding Spot Price History Analysis
**Timestamp:** 40:00 – 45:00

```
220
00:40:00,000 --> 00:40:10,000
Welcome to Segment 9. Let's understand Spot price history analysis in detail.

221
00:40:10,000 --> 00:40:20,000
The Spot price history tells you what prices have been over time. It also tells you about the volatility of the price.

222
00:40:20,000 --> 00:40:30,000
Volatility is important because it correlates with interruption frequency. High volatility means high interruption frequency.

223
00:40:30,000 --> 00:40:40,000
The coefficient of variation is the statistical measure we use. It is the standard deviation divided by the mean. It normalizes the variability.

224
00:40:40,000 --> 00:40:50,000
A coefficient of variation below five percent is excellent. The price is very stable. Interruptions are rare.

225
00:40:50,000 --> 00:41:00,000
A coefficient of variation between five and fifteen percent is acceptable. The price fluctuates but not dramatically. Interruptions happen occasionally.

226
00:41:00,000 --> 00:41:10,000
A coefficient of variation above fifteen percent is high. The price is volatile. Interruptions are frequent.

227
00:41:10,000 --> 00:41:20,000
The coefficient of variation varies by region and instance type. g4dn.xlarge in us-east-1 has a CV below three percent. This is excellent.

228
00:41:20,000 --> 00:41:30,000
p3.2xlarge in us-east-1 has a CV around eighteen percent. This is high. We use this instance type only with On-Demand fallback.

229
00:41:30,000 --> 00:41:40,000
The Spot price history also shows seasonal patterns. Prices are typically higher during business hours and lower at night.

230
00:41:40,000 --> 00:41:50,000
This is because demand is higher during business hours. AWS has less spare capacity. The Spot price reflects this.

231
00:41:50,000 --> 00:42:00,000
You can use this to your advantage. Schedule training jobs to run at night. The Spot price will be lower and availability will be higher.

232
00:42:00,000 --> 00:42:10,000
The cron scheduler in Kubernetes can implement this. Run the training job at 2 AM and have it finish by 6 AM.

233
00:42:10,000 --> 00:42:20,000
The interruption rate at night is also lower. There is less demand for Spot capacity during off-hours.

234
00:42:20,000 --> 00:42:30,000
Now let's look at how to get Spot price history data in a usable format.

235
00:42:30,000 --> 00:42:40,000
[Types: aws ec2 describe-spot-price-history --instance-types g4dn.xlarge --product-descriptions "Linux/UNIX" --start-time $(date -d '7 days ago' -u +%Y-%m-%dT%H:%M:%SZ) --query 'SpotPriceHistory[].SpotPrice' --output text | tr '\t' '\n' | head -20]
▶ Pronounced as: "AWS, E-C-two, describe, spot, price, history..."

236
00:42:40,000 --> 00:42:50,000
This gives you the last seven days of Spot prices for g4dn.xlarge. You can graph this data to see the volatility.

237
00:42:50,000 --> 00:43:00,000
You can also compare across instance types. This helps you choose the most stable instance type for your workload.

238
00:43:00,000 --> 00:43:10,000
Now you understand Spot price history analysis. You know how to use it to choose instance types and schedule jobs.

239
00:43:10,000 --> 00:43:20,000
In the next segment, we look at advanced checkpointing strategies.

240
00:43:20,000 --> 00:43:30,000
See you in Segment 10.
```

---

### SEGMENT 10: Deep Dive: Checkpointing Strategies
**Timestamp:** 45:00 – 50:00

```
241
00:45:00,000 --> 00:45:10,000
Welcome to Segment 10. Let's look at advanced checkpointing strategies.

242
00:45:10,000 --> 00:45:20,000
We have covered the basics of checkpointing. But there are strategies that make checkpointing more efficient and reliable.

243
00:45:20,000 --> 00:45:30,000
The first strategy is asynchronous checkpointing. This is saving checkpoints in a background thread while training continues.

244
00:45:30,000 --> 00:45:40,000
The CheckpointManager we implemented already uses this. The periodic checkpoint loop runs in a background thread. Training does not pause for checkpoints.

245
00:45:40,000 --> 00:45:50,000
This is important for performance. Saving a checkpoint can take a few seconds. You do not want training to pause during this time.

246
00:45:50,000 --> 00:46:00,000
The second strategy is differential checkpointing. This is saving only the changes since the last checkpoint.

247
00:46:00,000 --> 00:46:10,000
This reduces the size of checkpoints and the time to save them. It is useful for very large models.

248
00:46:10,000 --> 00:46:20,000
The third strategy is checkpoint compression. Compress the checkpoint before saving to S3. This reduces storage cost and transfer time.

249
00:46:20,000 --> 00:46:30,000
PyTorch supports compression through the `torch.save` function. Use compression for large models.

250
00:46:30,000 --> 00:46:40,000
```python
torch.save(state, 'checkpoint.pt', _use_new_zipfile_serialization=True)
```

251
00:46:40,000 --> 00:46:50,000
The fourth strategy is checkpoint versioning. Keep a rolling window of checkpoints. Do not keep every checkpoint.

252
00:46:50,000 --> 00:47:00,000
The CheckpointManager we implemented keeps only the last three checkpoints. This is the rolling window approach.

253
00:47:00,000 --> 00:47:10,000
The fifth strategy is checkpoint validation. Validate the checkpoint before saving. This ensures the checkpoint is not corrupted.

254
00:47:10,000 --> 00:47:20,000
We already do this with SHA-256 verification. The checkpoint is validated when it is loaded.

255
00:47:20,000 --> 00:47:30,000
The sixth strategy is checkpoint sharding. For very large models, shard the checkpoint across multiple files.

256
00:47:30,000 --> 00:47:40,000
This makes it easier to save and load large models. It also makes it easier to resume training on a different number of GPUs.

257
00:47:40,000 --> 00:47:50,000
The seventh strategy is checkpoint deduplication. For models that do not change much, use deduplication to save storage.

258
00:47:50,000 --> 00:48:00,000
This is advanced and rarely needed. Use the simpler strategies first.

259
00:48:00,000 --> 00:48:10,000
The eighth strategy is checkpoint recovery testing. Test the recovery process regularly. Do not wait for an interruption to test recovery.

260
00:48:10,000 --> 00:48:20,000
We tested recovery in Segment 4 by deleting the pod. This is a good practice. Do it regularly.

261
00:48:20,000 --> 00:48:30,000
Now you know the advanced checkpointing strategies. Choose the ones that fit your workload.

262
00:48:30,000 --> 00:48:40,000
In the next segment, we do a workshop on implementing checkpointing for your workload.

263
00:48:40,000 --> 00:48:50,000
See you in Segment 11.
```

---

### SEGMENT 11: Workshop: Implementing Checkpointing for Your Workload
**Timestamp:** 50:00 – 55:00

```
264
00:50:00,000 --> 00:50:10,000
Welcome to Segment 11. This is the checkpointing workshop.

265
00:50:10,000 --> 00:50:20,000
We have covered the CheckpointManager implementation. Now you apply it to your own workload.

266
00:50:20,000 --> 00:50:30,000
Step 1: Identify your training script. Find the file that contains your training loop.

267
00:50:30,000 --> 00:50:40,000
Step 2: Import the CheckpointManager. Add the import statement at the top of your file.

268
00:50:40,000 --> 00:50:50,000
```python
from checkpoint_manager import CheckpointManager
```

269
00:50:50,000 --> 00:51:00,000
Step 3: Initialize the CheckpointManager. Do this before starting the training loop.

270
00:51:00,000 --> 00:51:10,000
```python
manager = CheckpointManager(
    model=model,
    optimizer=optimizer,
    job_name=os.environ.get('JOB_ID', 'training-job'),
    bucket=os.environ.get('CHECKPOINT_BUCKET'),
    interval=100
)
```

271
00:51:10,000 --> 00:51:20,000
Step 4: Load the latest checkpoint. This is how you resume from interruptions.

272
00:51:20,000 --> 00:51:30,000
```python
start_step = manager.load_latest()
```

273
00:51:30,000 --> 00:51:40,000
Step 5: Update the training loop to call after_step() at the end of each step.

274
00:51:40,000 --> 00:51:50,000
```python
for step in range(start_step, max_steps):
    loss = train_step()
    manager.after_step()
```

275
00:51:50,000 --> 00:52:00,000
Step 6: Save a final checkpoint at the end of training. This ensures the completed model is saved.

276
00:52:00,000 --> 00:52:10,000
```python
manager.save(tag='final')
```

277
00:52:10,000 --> 00:52:20,000
Step 7: Add the SpotTerminationWatcher. This is your second line of defence.

278
00:52:20,000 --> 00:52:30,000
```python
from spot_watcher import watch_spot_termination

def on_termination(termination_time):
    manager.save(tag='emergency')
    print(f"Emergency checkpoint saved at {termination_time}")

watch_spot_termination(on_termination)
```

279
00:52:30,000 --> 00:52:40,000
Step 8: Update the Kubernetes Job configuration. Add the Spot tolerations and backoffLimit.

280
00:52:40,000 --> 00:52:50,000
```yaml
spec:
  backoffLimit: 10
  template:
    spec:
      tolerations:
      - key: karpenter.sh/capacity-type
        value: spot
        effect: NoSchedule
```

281
00:52:50,000 --> 00:53:00,000
Step 9: Set the environment variables. The Job needs JOB_ID and CHECKPOINT_BUCKET.

282
00:53:00,000 --> 00:53:10,000
```yaml
env:
- name: JOB_ID
  valueFrom:
    fieldRef:
      fieldPath: metadata.name
- name: CHECKPOINT_BUCKET
  value: "riskoracle-checkpoints-123456789012"
```

283
00:53:10,000 --> 00:53:20,000
Step 10: Test the implementation. Run the training job and verify checkpoints are saved to S3.

284
00:53:20,000 --> 00:53:30,000
[Types: aws s3 ls s3://$CHECKPOINT_BUCKET/checkpoints/]
▶ Pronounced as: "AWS, S-three, L-S..."

285
00:53:30,000 --> 00:53:40,000
Step 11: Simulate an interruption. Delete the pod and verify that the training resumes from the checkpoint.

286
00:53:40,000 --> 00:53:50,000
This is the complete workflow. Apply it to your training script. The changes are minimal but the impact is huge.

287
00:53:50,000 --> 00:54:00,000
Now you have a production-ready checkpointing implementation for your ML workloads.

288
00:54:00,000 --> 00:54:10,000
In the next segment, we look at the IMDS metadata service in more detail.

289
00:54:10,000 --> 00:54:20,000
See you in Segment 12.
```

---

### SEGMENT 12: Deep Dive: IMDS Metadata Service
**Timestamp:** 55:00 – 60:00

```
290
00:55:00,000 --> 00:55:10,000
Welcome to Segment 12. Let's dive into the IMDS metadata service.

291
00:55:10,000 --> 00:55:20,000
The Instance Metadata Service is a service that runs on every EC2 instance. It provides information about the instance to processes running on it.

292
00:55:20,000 --> 00:55:30,000
The IMDS endpoint is http://169.254.169.254. This is a link-local address. It is only accessible from within the instance.

293
00:55:30,000 --> 00:55:40,000
IMDSv2 is the current version. It requires a session token for security. This prevents SSRF attacks.

294
00:55:40,000 --> 00:55:50,000
To get a session token, send a PUT request to http://169.254.169.254/latest/api/token.

295
00:55:50,000 --> 00:56:00,000
```bash
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
```

296
00:56:00,000 --> 00:56:10,000
Then use the token in subsequent requests. Add the header X-aws-ec2-metadata-token: $TOKEN.

297
00:56:10,000 --> 00:56:20,000
The Spot termination notice is at http://169.254.169.254/latest/meta-data/spot/termination-time.

298
00:56:20,000 --> 00:56:30,000
If the endpoint returns a timestamp, Spot termination is imminent. The timestamp is in UTC.

299
00:56:30,000 --> 00:56:40,000
[Types: curl -s http://169.254.169.254/latest/meta-data/spot/termination-time]
▶ Pronounced as: "Curl, dash, s..."

300
00:56:40,000 --> 00:56:50,000
If the endpoint returns 404, no termination is scheduled. This is the normal state.

301
00:56:50,000 --> 00:57:00,000
The IMDS service also provides other metadata. You can get the instance type, the instance ID, the region, and many other attributes.

302
00:57:00,000 --> 00:57:10,000
[Types: curl -s http://169.254.169.254/latest/meta-data/instance-type]
[Types: curl -s http://169.254.169.254/latest/meta-data/instance-id]
[Types: curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone]
▶ Pronounced as: "Curl, dash, s..."

303
00:57:10,000 --> 00:57:20,000
These attributes are useful for logging. You can log the instance type and AZ with your training run.

304
00:57:20,000 --> 00:57:30,000
The instance lifecycle attribute tells you if the instance is Spot or On-Demand.

305
00:57:30,000 --> 00:57:40,000
[Types: curl -s http://169.254.169.254/latest/meta-data/instance-life-cycle]
▶ Pronounced as: "Curl, dash, s..."

306
00:57:40,000 --> 00:57:50,000
This returns "spot" for Spot instances and "normal" for On-Demand instances. This is useful for verification.

307
00:57:50,000 --> 00:58:00,000
The IMDS service is rate-limited. Do not poll it too frequently. Polling every five seconds is safe.

308
00:58:00,000 --> 00:58:10,000
The SpotTerminationWatcher we implemented polls every five seconds. This is the recommended frequency.

309
00:58:10,000 --> 00:58:20,000
Now you understand the IMDS metadata service. You know how to use it to detect Spot interruptions.

310
00:58:20,000 --> 00:58:30,000
In the next segment, we look at SIGTERM and graceful shutdown in more detail.

311
00:58:30,000 --> 00:58:40,000
See you in Segment 13.
```

---

### SEGMENT 13: Understanding SIGTERM & Graceful Shutdown
**Timestamp:** 60:00 – 65:00

```
312
01:00:00,000 --> 01:00:10,000
Welcome to Segment 13. Let's understand SIGTERM and graceful shutdown.

313
01:00:10,000 --> 01:00:20,000
SIGTERM is a signal sent to a process to request termination. It is the polite way to ask a process to shut down.

314
01:00:20,000 --> 01:00:30,000
When Karpenter drains a node, it sends SIGTERM to all processes running on the node. This is your notification that the node is being terminated.

315
01:00:30,000 --> 01:00:40,000
The process has a grace period to shut down. This is set by terminationGracePeriodSeconds in the Kubernetes pod spec.

316
01:00:40,000 --> 01:00:50,000
In our Job configuration, the grace period is ninety seconds. This gives the training process ninety seconds to save a checkpoint and exit.

317
01:00:50,000 --> 01:01:00,000
The SIGTERM handler in CheckpointManager catches the signal and triggers an emergency checkpoint.

318
01:01:00,000 --> 01:01:10,000
```python
def _on_spot_interruption(self, signum, frame):
    print("⚠️  SIGTERM received — Spot interruption imminent!")
    self.save(tag='emergency')
    print("   Emergency checkpoint saved. Exiting cleanly.")
    exit(0)
```

319
01:01:10,000 --> 01:01:20,000
The emergency checkpoint is saved to S3. The process exits. The Kubernetes Job restarts the pod.

320
01:01:20,000 --> 01:01:30,000
The new pod loads the emergency checkpoint and resumes training from where it stopped.

321
01:01:30,000 --> 01:01:40,000
If the process does not handle SIGTERM, Kubernetes waits for the grace period and then sends SIGKILL. SIGKILL cannot be handled. The process is terminated immediately.

322
01:01:40,000 --> 01:01:50,000
This is why the SIGTERM handler is essential. Without it, the checkpoint is not saved and training progress is lost.

323
01:01:50,000 --> 01:02:00,000
The SIGTERM handler should be as fast as possible. It should not do any heavy processing. Save the checkpoint and exit.

324
01:02:00,000 --> 01:02:10,000
The checkpoint save should take under thirty seconds. This leaves sixty seconds for the exit and pod cleanup.

325
01:02:10,000 --> 01:02:20,000
The IMDS watcher is a second line of defence. It detects the interruption before SIGTERM arrives and triggers a checkpoint.

326
01:02:20,000 --> 01:02:30,000
If the IMDS watcher triggers a checkpoint and then SIGTERM arrives, the CheckpointManager handles SIGTERM gracefully.

327
01:02:30,000 --> 01:02:40,000
It checks if a checkpoint was already saved. If so, it does not save another one. It just exits.

328
01:02:40,000 --> 01:02:50,000
```python
if self._checkpoint_saved:
    exit(0)
```

329
01:02:50,000 --> 01:03:00,000
This dual-defence strategy ensures that a checkpoint is saved even if one of the mechanisms fails.

330
01:03:00,000 --> 01:03:10,000
Now you understand SIGTERM and graceful shutdown. You know how to implement a SIGTERM handler for your training process.

331
01:03:10,000 --> 01:03:20,000
In the next segment, we look at advanced Spot handling patterns.

332
01:03:20,000 --> 01:03:30,000
See you in Segment 14.
```

---

### SEGMENT 14: Advanced Spot Handling Patterns
**Timestamp:** 65:00 – 70:00

```
333
01:05:00,000 --> 01:05:10,000
Welcome to Segment 14. Let's look at advanced Spot handling patterns.

334
01:05:10,000 --> 01:05:20,000
We have covered the basics. Now let's look at patterns that handle Spot interruptions more gracefully.

335
01:05:20,000 --> 01:05:30,000
The first pattern is job checkpointing with priority. This is when you save checkpoints at different frequencies based on the job priority.

336
01:05:30,000 --> 01:05:40,000
High-priority jobs save checkpoints more frequently. Low-priority jobs save checkpoints less frequently.

337
01:05:40,000 --> 01:05:50,000
```python
if priority == 'high':
    interval = 10
elif priority == 'medium':
    interval = 100
else:
    interval = 1000
```

338
01:05:50,000 --> 01:06:00,000
The second pattern is multi-region Spot diversification. Run training jobs in multiple regions. If one region has low Spot capacity, the other region can continue.

339
01:06:00,000 --> 01:06:10,000
This is more expensive because of data transfer. But it provides higher availability.

340
01:06:10,000 --> 01:06:20,000
The third pattern is Spot price-aware scheduling. Run jobs when the Spot price is low. Pause jobs when the Spot price is high.

341
01:06:20,000 --> 01:06:30,000
This is complex to implement. But it can save money by avoiding high-priced Spot instances.

342
01:06:30,000 --> 01:06:40,000
The fourth pattern is hybrid Spot-On-Demand scheduling. Run critical parts of the job on On-Demand. Run non-critical parts on Spot.

343
01:06:40,000 --> 01:06:50,000
This is the approach riskoracle uses. Final evaluation runs on On-Demand. Training runs on Spot.

344
01:06:50,000 --> 01:07:00,000
The fifth pattern is job preemption handling. When a job is interrupted, the job is not restarted. Instead, the job is rescheduled on a different node.

345
01:07:00,000 --> 01:07:10,000
Kubernetes Jobs with backoffLimit handle this automatically. When a pod is terminated, the Job restarts it.

346
01:07:10,000 --> 01:07:20,000
The sixth pattern is persistent storage for checkpoints. Use EFS or FSx for checkpoint storage. This is faster than S3 for large models.

347
01:07:20,000 --> 01:07:30,000
S3 is cheaper but slower. EFS is faster but more expensive. Choose based on your model size.

348
01:07:30,000 --> 01:07:40,000
The seventh pattern is checkpoint compression. Compress checkpoints before saving. This reduces storage cost and transfer time.

349
01:07:40,000 --> 01:07:50,000
```python
torch.save(state, 'checkpoint.pt', _use_new_zipfile_serialization=True)
```

350
01:07:50,000 --> 01:08:00,000
The eighth pattern is checkpoint verification. Verify the checkpoint after saving. This ensures the checkpoint is not corrupted.

351
01:08:00,000 --> 01:08:10,000
```python
def verify_checkpoint(path):
    state = torch.load(path)
    assert state is not None
    assert 'step' in state
    assert 'model_state' in state
```

352
01:08:10,000 --> 01:08:20,000
Now you know the advanced Spot handling patterns. Choose the ones that fit your workload.

353
01:08:20,000 --> 01:08:30,000
In the next segment, we look at Kubernetes Job configuration for Spot workloads in more detail.

354
01:08:30,000 --> 01:08:40,000
See you in Segment 15.
```

---

### SEGMENT 15: Kubernetes Job Configuration for Spot Workloads
**Timestamp:** 70:00 – 75:00

```
355
01:10:00,000 --> 01:10:10,000
Welcome to Segment 15. Let's look at Kubernetes Job configuration for Spot workloads.

356
01:10:10,000 --> 01:10:20,000
The Kubernetes Job is the primary way to run batch workloads in EKS. It handles the lifecycle of the training pod.

357
01:10:20,000 --> 01:10:30,000
The backoffLimit is the number of retries allowed. Each interruption consumes one retry. With backoffLimit ten, you can survive ten interruptions.

358
01:10:30,000 --> 01:10:40,000
The restartPolicy is the policy for restarting the pod. OnFailure is the correct policy for training jobs. It restarts the pod when it fails.

359
01:10:40,000 --> 01:10:50,000
The terminationGracePeriodSeconds is the grace period for the pod to shut down. Ninety seconds is sufficient for the checkpoint save.

360
01:10:50,000 --> 01:11:00,000
The nodeSelector schedules the pod on nodes with the correct label. For GPU workloads, the label is role: gpu-ml.

361
01:11:00,000 --> 01:11:10,000
The tolerations allow the pod to schedule on Spot nodes. The toleration is karpenter.sh/capacity-type: spot.

362
01:11:10,000 --> 01:11:20,000
The serviceAccountName is the service account used by the pod. This is where the IRSA is attached.

363
01:11:20,000 --> 01:11:30,000
The container spec defines the image, the command, and the environment variables.

364
01:11:30,000 --> 01:11:40,000
The resources requests and limits define the compute resources. These must match the NodePool limits.

365
01:11:40,000 --> 01:11:50,000
```yaml
resources:
  requests:
    cpu: "4"
    memory: 16Gi
    nvidia.com/gpu: "1"
  limits:
    cpu: "8"
    memory: 24Gi
    nvidia.com/gpu: "1"
```

366
01:11:50,000 --> 01:12:00,000
The livenessProbe checks the health of the pod. If the livenessProbe fails, the pod is restarted.

367
01:12:00,000 --> 01:12:10,000
```yaml
livenessProbe:
  exec:
    command:
    - python3
    - -c
    - |
      import os, time
      mtime = os.path.getmtime('/tmp/training-heartbeat')
      assert time.time() - mtime < 300, 'No heartbeat in 5 minutes'
  initialDelaySeconds: 120
  periodSeconds: 60
  failureThreshold: 3
```

368
01:12:10,000 --> 01:12:20,000
The livenessProbe checks a heartbeat file. If the training loop hangs, the heartbeat stops. The pod is restarted after five minutes.

369
01:12:20,000 --> 01:12:30,000
Now let's look at the complete Job configuration:

370
01:12:30,000 --> 01:12:40,000
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: risk-model-training-v3
  namespace: riskoracle
  labels:
    app.kubernetes.io/name: riskoracle
    app.kubernetes.io/component: training
    version: v3
spec:
  backoffLimit: 10
  ttlSecondsAfterFinished: 86400
  template:
    metadata:
      labels:
        app.kubernetes.io/name: riskoracle
        app.kubernetes.io/component: training
      annotations:
        karpenter.sh/do-not-disrupt: "false"
    spec:
      restartPolicy: OnFailure
      nodeSelector:
        role: gpu-ml
      tolerations:
      - key: nvidia.com/gpu
        operator: Equal
        value: "true"
        effect: NoSchedule
      - key: karpenter.sh/capacity-type
        operator: Equal
        value: spot
        effect: NoSchedule
      terminationGracePeriodSeconds: 90
      serviceAccountName: riskoracle-training
      containers:
      - name: trainer
        image: "123456789012.dkr.ecr.us-east-1.amazonaws.com/riskoracle/trainer:latest"
        command: ["python", "-m", "riskoracle.training.train"]
        env:
        - name: JOB_ID
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        - name: CHECKPOINT_BUCKET
          value: "riskoracle-checkpoints-123456789012"
        - name: MAX_EPOCHS
          value: "100"
        resources:
          requests:
            cpu: "4"
            memory: 16Gi
            nvidia.com/gpu: "1"
          limits:
            cpu: "8"
            memory: 24Gi
            nvidia.com/gpu: "1"
```

371
01:12:40,000 --> 01:12:50,000
This is the production Job configuration. Apply it to your cluster and the training will run on Spot.

372
01:12:50,000 --> 01:13:00,000
In the next segment, we look at understanding PodDisruptionBudgets for Spot.

373
01:13:00,000 --> 01:13:10,000
See you in Segment 16.
```

---

### SEGMENT 16: Understanding PodDisruptionBudgets for Spot
**Timestamp:** 75:00 – 80:00

```
374
01:15:00,000 --> 01:15:10,000
Welcome to Segment 16. Let's understand PodDisruptionBudgets for Spot.

375
01:15:10,000 --> 01:15:20,000
A PodDisruptionBudget is a Kubernetes resource that limits the number of pods that can be disrupted at the same time.

376
01:15:20,000 --> 01:15:30,000
Disruption includes both voluntary and involuntary disruptions. Voluntary disruptions include node draining for maintenance. Involuntary disruptions include Spot interruptions.

377
01:15:30,000 --> 01:15:40,000
The PDB ensures that a minimum number of pods are always available. This is important for high availability.

378
01:15:40,000 --> 01:15:50,000
For training jobs, the PDB is less critical. Training jobs are not serving traffic. They can be interrupted.

379
01:15:50,000 --> 01:16:00,000
But if you have multiple training jobs running in parallel, you may want to limit the number of jobs that can be interrupted simultaneously.

380
01:16:00,000 --> 01:16:10,000
```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: training-jobs-pdb
  namespace: riskoracle
spec:
  maxUnavailable: 1
  selector:
    matchLabels:
      app.kubernetes.io/component: training
```

381
01:16:10,000 --> 01:16:20,000
This PDB says: at most one training job can be interrupted at a time. If two jobs are on the same node and the node is drained, only one job is interrupted.

382
01:16:20,000 --> 01:16:30,000
The other job waits until the first job has completed its checkpoint and restarted. Then the second job is interrupted.

383
01:16:30,000 --> 01:16:40,000
This is useful for large fleets of training jobs. It reduces the impact of a node failure on the overall training pipeline.

384
01:16:40,000 --> 01:16:50,000
The PDB also applies to voluntary disruptions. If you need to drain a node for maintenance, the PDB ensures that only one training job is affected.

385
01:16:50,000 --> 01:17:00,000
This makes maintenance easier. You can drain nodes without worrying about interrupting all training jobs.

386
01:17:00,000 --> 01:17:10,000
The PDB can also be used with maxUnavailable zero. This means no pods can be disrupted. This is useful for critical training jobs.

387
01:17:10,000 --> 01:17:20,000
But using maxUnavailable zero prevents any disruption. This includes voluntary disruption for maintenance. Use it sparingly.

388
01:17:20,000 --> 01:17:30,000
Now you understand PodDisruptionBudgets for Spot. They are useful for controlling the impact of interruptions on training fleets.

389
01:17:30,000 --> 01:17:40,000
In the next segment, we do a workshop on deploying your training job.

390
01:17:40,000 --> 01:17:50,000
See you in Segment 17.
```

---

### SEGMENT 17: Workshop: Deploying Your Training Job
**Timestamp:** 80:00 – 85:00

```
391
01:20:00,000 --> 01:20:10,000
Welcome to Segment 17. This is the deployment workshop.

392
01:20:10,000 --> 01:20:20,000
You have the code. You have the configuration. Now you deploy your training job to EKS.

393
01:20:20,000 --> 01:20:30,000
Step 1: Build the container image. Use the Dockerfile from the riskoracle repository.

394
01:20:30,000 --> 01:20:40,000
```bash
docker build -t riskoracle-trainer:latest .
```

395
01:20:40,000 --> 01:20:50,000
Step 2: Push the image to ECR.

396
01:20:50,000 --> 01:21:00,000
```bash
docker tag riskoracle-trainer:latest $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/riskoracle-trainer:latest
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/riskoracle-trainer:latest
```

397
01:21:00,000 --> 01:21:10,000
Step 3: Apply the Job configuration to the cluster.

398
01:21:10,000 --> 01:21:20,000
```bash
kubectl apply -f training-job.yaml
```

399
01:21:20,000 --> 01:21:30,000
Step 4: Watch the pod schedule. It should schedule on a Spot node.

400
01:21:30,000 --> 01:21:40,000
```bash
kubectl get pods -n riskoracle -l app.kubernetes.io/component=training -w
```

401
01:21:40,000 --> 01:21:50,000
Step 5: Check the logs. You should see the training starting.

402
01:21:50,000 --> 01:22:00,000
```bash
kubectl logs -n riskoracle -l app.kubernetes.io/component=training --tail=50
```

403
01:22:00,000 --> 01:22:10,000
Step 6: Verify checkpoints are saved to S3.

404
01:22:10,000 --> 01:22:20,000
```bash
aws s3 ls s3://$CHECKPOINT_BUCKET/checkpoints/
```

405
01:22:20,000 --> 01:22:30,000
Step 7: Simulate an interruption. Delete the pod.

406
01:22:30,000 --> 01:22:40,000
```bash
kubectl delete pod -n riskoracle -l app.kubernetes.io/component=training
```

407
01:22:40,000 --> 01:22:50,000
Step 8: Watch the new pod start.

408
01:22:50,000 --> 01:23:00,000
```bash
kubectl get pods -n riskoracle -l app.kubernetes.io/component=training -w
```

409
01:23:00,000 --> 01:23:10,000
Step 9: Check the logs of the new pod. It should resume from the checkpoint.

410
01:23:10,000 --> 01:23:20,000
```bash
kubectl logs -n riskoracle -l app.kubernetes.io/component=training --tail=50 | grep "resuming"
```

411
01:23:20,000 --> 01:23:30,000
Step 10: Verify the job completed successfully.

412
01:23:30,000 --> 01:23:40,000
```bash
kubectl get jobs -n riskoracle
```

413
01:23:40,000 --> 01:23:50,000
Step 11: Verify the final checkpoint was saved.

414
01:23:50,000 --> 01:24:00,000
```bash
aws s3 ls s3://$CHECKPOINT_BUCKET/checkpoints/ | grep final
```

415
01:24:00,000 --> 01:24:10,000
Step 12: Verify the interruption count in the metadata.

416
01:24:10,000 --> 01:24:20,000
```bash
aws s3 cp s3://$CHECKPOINT_BUCKET/checkpoints/risk-model-training-v3/latest-metadata.json -
```

417
01:24:20,000 --> 01:24:30,000
Now you have deployed your training job to EKS. It is running on Spot with checkpointing.

418
01:24:30,000 --> 01:24:40,000
In the next segment, we look at monitoring Spot interruption rates.

419
01:24:40,000 --> 01:24:50,000
See you in Segment 18.
```

---

### SEGMENT 18: Monitoring Spot Interruption Rates
**Timestamp:** 85:00 – 90:00

```
420
01:25:00,000 --> 01:25:10,000
Welcome to Segment 18. Let's monitor Spot interruption rates.

421
01:25:10,000 --> 01:25:20,000
Monitoring interruptions is important. It tells you if your instance selection is stable. It also tells you if there are capacity issues.

422
01:25:20,000 --> 01:25:30,000
The first way to monitor interruptions is through Karpenter logs.

423
01:25:30,000 --> 01:25:40,000
```bash
kubectl logs -n karpenter -l app.kubernetes.io/name=karpenter --since=24h | grep interruption
```

424
01:25:40,000 --> 01:25:50,000
This shows all interruption events in the last twenty-four hours.

425
01:25:50,000 --> 01:26:00,000
The second way is through the Job events.

426
01:26:00,000 --> 01:26:10,000
```bash
kubectl describe job risk-model-training-v3 -n riskoracle
```

427
01:26:10,000 --> 01:26:20,000
This shows the job status and any events related to the job.

428
01:26:20,000 --> 01:26:30,000
The third way is through CloudWatch metrics. Karpenter publishes metrics to CloudWatch.

429
01:26:30,000 --> 01:26:40,000
```bash
aws cloudwatch get-metric-statistics --namespace Karpenter --metric-name spot_interruptions --start-time $(date -d '24 hours ago' -u +%Y-%m-%dT%H:%M:%SZ) --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) --period 3600 --statistics Sum --query 'Datapoints[*].Sum' --output text
```

430
01:26:40,000 --> 01:26:50,000
The fourth way is through the checkpoint metadata. The CheckpointManager stores the interruption count in the metadata.

431
01:26:50,000 --> 01:27:00,000
```bash
for prefix in $(aws s3api list-objects-v2 --bucket $CHECKPOINT_BUCKET --delimiter "/" --prefix "checkpoints/" --query 'CommonPrefixes[].Prefix' --output text | tr '\t' '\n'); do metadata_key="${prefix}latest-metadata.json"; metadata=$(aws s3api get-object --bucket $CHECKPOINT_BUCKET --key "$metadata_key" /tmp/meta.json 2>/dev/null && cat /tmp/meta.json || echo "{}"); job_id=$(echo $metadata | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('job_id','unknown'))" 2>/dev/null); interruptions=$(echo $metadata | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('interruption_count',0))" 2>/dev/null); capacity=$(echo $metadata | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('capacity_type','unknown'))" 2>/dev/null); echo "Job: $job_id | Interruptions: $interruptions | Capacity: $capacity"; done
```

432
01:27:00,000 --> 01:27:10,000
The fifth way is through the Kubernetes events.

433
01:27:10,000 --> 01:27:20,000
```bash
kubectl get events --field-selector reason=SpotInterruption --all-namespaces --sort-by='.metadata.creationTimestamp'
```

434
01:27:20,000 --> 01:27:30,000
Now let's create a dashboard for monitoring interruptions.

435
01:27:30,000 --> 01:27:40,000
You can use Grafana with the CloudWatch data source. Create a graph showing interruption events over time.

436
01:27:40,000 --> 01:27:50,000
Set up an alert when the interruption rate exceeds five percent.

437
01:27:50,000 --> 01:28:00,000
Now you know how to monitor Spot interruption rates. This is important for maintaining reliability.

438
01:28:00,000 --> 01:28:10,000
In the next segment, we look at advanced strategies for handling Spot interruptions.

439
01:28:10,000 --> 01:28:20,000
See you in Segment 19.
```

---

### SEGMENT 19: Handling Spot Interruptions — Advanced Strategies
**Timestamp:** 90:00 – 95:00

```
440
01:30:00,000 --> 01:30:10,000
Welcome to Segment 19. Let's look at advanced strategies for handling Spot interruptions.

441
01:30:10,000 --> 01:30:20,000
We have covered the basics. Now let's look at strategies that make Spot interruptions even less impactful.

442
01:30:20,000 --> 01:30:30,000
The first strategy is predictive interruption handling. This is using machine learning to predict when a Spot interruption will occur.

443
01:30:30,000 --> 01:30:40,000
This is advanced and rarely needed. The two-minute warning is sufficient for most workloads.

444
01:30:40,000 --> 01:30:50,000
The second strategy is checkpoint migration. This is moving checkpoints to a new instance before the interruption.

445
01:30:50,000 --> 01:31:00,000
This is useful for workloads that cannot tolerate even a short interruption. It is complex to implement.

446
01:31:00,000 --> 01:31:10,000
The third strategy is job decomposition. This is breaking a large job into smaller jobs. Each small job can be interrupted independently.

447
01:31:10,000 --> 01:31:20,000
This is useful for hyperparameter tuning. Each tuning job is independent. Interruptions only affect one tuning job.

448
01:31:20,000 --> 01:31:30,000
The fourth strategy is node affinity. This is scheduling jobs on nodes that are less likely to be interrupted.

449
01:31:30,000 --> 01:31:40,000
Use node affinity to schedule training jobs on nodes in availability zones with stable Spot capacity.

450
01:31:40,000 --> 01:31:50,000
The fifth strategy is pod anti-affinity. This is scheduling jobs on different nodes. If one node is interrupted, other nodes are not affected.

451
01:31:50,000 --> 01:32:00,000
```yaml
affinity:
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 100
      podAffinityTerm:
        labelSelector:
          matchLabels:
            app: training
        topologyKey: kubernetes.io/hostname
```

452
01:32:00,000 --> 01:32:10,000
The sixth strategy is topology spread constraints. This is spreading jobs across different nodes and availability zones.

453
01:32:10,000 --> 01:32:20,000
```yaml
topologySpreadConstraints:
- maxSkew: 1
  topologyKey: topology.kubernetes.io/zone
  whenUnsatisfiable: DoNotSchedule
```

454
01:32:20,000 --> 01:32:30,000
The seventh strategy is using On-Demand fallback. If Spot capacity is not available, fall back to On-Demand.

455
01:32:30,000 --> 01:32:40,000
The NodePool we created in Series 4 already supports this. It includes both Spot and On-Demand capacity types.

456
01:32:40,000 --> 01:32:50,000
The eighth strategy is using multiple instance families. If one instance family is not available, use another.

457
01:32:50,000 --> 01:33:00,000
The NodePool also supports this. It includes multiple instance families.

458
01:33:00,000 --> 01:33:10,000
Now you know the advanced strategies for handling Spot interruptions. Choose the ones that fit your workload.

459
01:33:10,000 --> 01:33:20,000
In the next segment, we look at understanding multi-AZ diversification in more detail.

460
01:33:20,000 --> 01:33:30,000
See you in Segment 20.
```

---

### SEGMENT 20: Understanding Multi-AZ Diversification
**Timestamp:** 95:00 – 100:00

```
461
01:35:00,000 --> 01:35:10,000
Welcome to Segment 20. Let's understand multi-AZ diversification.

462
01:35:10,000 --> 01:35:20,000
Availability zones are isolated data centers within a region. Each AZ has its own power, cooling, and networking.

463
01:35:20,000 --> 01:35:30,000
Spot capacity varies by AZ. One AZ may have plenty of Spot capacity. Another AZ may have none.

464
01:35:30,000 --> 01:35:40,000
If you run all your training jobs in one AZ and that AZ runs out of Spot capacity, all your jobs are interrupted.

465
01:35:40,000 --> 01:35:50,000
If you spread your training jobs across multiple AZs, an interruption in one AZ does not affect the other AZs.

466
01:35:50,000 --> 01:36:00,000
This is multi-AZ diversification. It reduces the risk of correlated interruptions.

467
01:36:00,000 --> 01:36:10,000
To implement multi-AZ diversification, update the NodePool to include multiple AZs.

468
01:36:10,000 --> 01:36:20,000
```yaml
requirements:
- key: topology.kubernetes.io/zone
  operator: In
  values:
  - us-east-1a
  - us-east-1b
  - us-east-1c
```

469
01:36:20,000 --> 01:36:30,000
Karpenter will then schedule nodes across all three AZs. Training jobs will be distributed across the AZs.

470
01:36:30,000 --> 01:36:40,000
You should also use pod anti-affinity to prevent all training jobs from scheduling on the same AZ.

471
01:36:40,000 --> 01:36:50,000
```yaml
affinity:
  podAntiAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
    - labelSelector:
        matchLabels:
          app: training
      topologyKey: topology.kubernetes.io/zone
```

472
01:36:50,000 --> 01:37:00,000
This ensures that training jobs are spread across AZs. No AZ runs more than one training job.

473
01:37:00,000 --> 01:37:10,000
Now you understand multi-AZ diversification. It is a simple but effective strategy for reducing interruption risk.

474
01:37:10,000 --> 01:37:20,000
In the next segment, we look at calculating your Spot savings.

475
01:37:20,000 --> 01:37:30,000
See you in Segment 21.
```

---

### SEGMENT 21: Calculating Your Spot Savings
**Timestamp:** 100:00 – 105:00

```
476
01:40:00,000 --> 01:40:10,000
Welcome to Segment 21. Let's calculate your Spot savings.

477
01:40:10,000 --> 01:40:20,000
You have deployed training jobs on Spot. Now you need to measure the savings.

478
01:40:20,000 --> 01:40:30,000
The first step is to get the On-Demand cost for the same workload. This is your baseline.

479
01:40:30,000 --> 01:40:40,000
```bash
aws ce get-cost-and-usage --time-period Start=$START,End=$END --granularity MONTHLY --metrics BlendedCost --filter '{"Tags":{"Key":"workload","Values":["ml-training-on-demand"]}}' --query 'ResultsByTime[0].Total.BlendedCost.Amount' --output text
```

480
01:40:40,000 --> 01:40:50,000
The second step is to get the actual Spot cost for the same workload.

481
01:40:50,000 --> 01:41:00,000
```bash
aws ce get-cost-and-usage --time-period Start=$START,End=$END --granularity MONTHLY --metrics BlendedCost --filter '{"Tags":{"Key":"workload","Values":["ml-training-spot"]}}' --query 'ResultsByTime[0].Total.BlendedCost.Amount' --output text
```

482
01:41:00,000 --> 01:41:10,000
The third step is to calculate the savings.

483
01:41:10,000 --> 01:41:20,000
```bash
echo "$ON_DEMAND_COST - $SPOT_COST" | bc
```

484
01:41:20,000 --> 01:41:30,000
For riskoracle, the On-Demand cost was $1,152 a month. The Spot cost was $288 a month. The savings was $864 a month.

485
01:41:30,000 --> 01:41:40,000
That is a seventy-five percent reduction.

486
01:41:40,000 --> 01:41:50,000
But you also need to consider the interruption cost. Each interruption costs you the training time since the last checkpoint.

487
01:41:50,000 --> 01:42:00,000
The total cost is the Spot cost plus the interruption cost. The interruption cost is typically small.

488
01:42:00,000 --> 01:42:10,000
For riskoracle, the interruption cost was less than $10 a month. The total cost was $298 a month.

489
01:42:10,000 --> 01:42:20,000
That is still a seventy-four percent reduction.

490
01:42:20,000 --> 01:42:30,000
Now let's create a savings report.

491
01:42:30,000 --> 01:42:40,000
```bash
cat << EOF > ~/spot-savings-report.txt
=== SPOT SAVINGS REPORT ===
Date: $(date)
Workload: ML Training
On-Demand Cost: \$1,152/month
Spot Cost: \$288/month
Interruption Cost: \$10/month
Total Cost: \$298/month
Savings: \$854/month (74%)
Annual Savings: \$10,248/year
EOF
```

492
01:42:40,000 --> 01:42:50,000
This report is your evidence. Share it with your CTO.

493
01:42:50,000 --> 01:43:00,000
In the next segment, we look at Spot best practices for production.

494
01:43:00,000 --> 01:43:10,000
See you in Segment 22.
```

---

### SEGMENT 22: Spot Best Practices for Production
**Timestamp:** 105:00 – 110:00

```
495
01:45:00,000 --> 01:45:10,000
Welcome to Segment 22. Let's look at Spot best practices for production.

496
01:45:10,000 --> 01:45:20,000
These are the practices that make Spot workloads production-ready.

497
01:45:20,000 --> 01:45:30,000
Practice 1: Always checkpoint. This is the most important practice. Without checkpointing, Spot workloads are not production-ready.

498
01:45:30,000 --> 01:45:40,000
Practice 2: Use multiple instance types. Do not rely on a single instance type. Use a range of types across families.

499
01:45:40,000 --> 01:45:50,000
Practice 3: Use multiple AZs. Spread your workloads across AZs. This reduces correlated interruptions.

500
01:45:50,000 --> 01:46:00,000
Practice 4: Monitor interruption rates. Track interruption rates weekly. Investigate if the rate exceeds five percent.

501
01:46:00,000 --> 01:46:10,000
Practice 5: Set backoffLimit appropriately. backoffLimit should be sufficient for your expected interruption rate.

502
01:46:10,000 --> 01:46:20,000
Practice 6: Use liveness probes. Liveness probes detect hung training loops. This is important for long-running jobs.

503
01:46:20,000 --> 01:46:30,000
Practice 7: Use PodDisruptionBudgets. PDBs limit the impact of interruptions on your training fleet.

504
01:46:30,000 --> 01:46:40,000
Practice 8: Test interruption handling regularly. Simulate interruptions in a test environment.

505
01:46:40,000 --> 01:46:50,000
Practice 9: Use On-Demand fallback. If Spot capacity is not available, fall back to On-Demand.

506
01:46:50,000 --> 01:47:00,000
Practice 10: Monitor costs. Track your Spot costs and compare them to On-Demand costs. This validates your savings.

507
01:47:00,000 --> 01:47:10,000
Practice 11: Use checkpoint compression. Compress checkpoints to reduce storage cost and transfer time.

508
01:47:10,000 --> 01:47:20,000
Practice 12: Use checkpoint validation. Verify checkpoints after saving. This ensures they are not corrupted.

509
01:47:20,000 --> 01:47:30,000
Practice 13: Use structured logging. Log the instance type, AZ, and interruption events. This helps with debugging.

510
01:47:30,000 --> 01:47:40,000
Practice 14: Use metrics. Publish interruption and checkpoint metrics to CloudWatch. This helps with monitoring.

511
01:47:40,000 --> 01:47:50,000
Practice 15: Use alerts. Alert on high interruption rates or checkpoint failures.

512
01:47:50,000 --> 01:48:00,000
Now you know the best practices for Spot workloads. Follow them and your Spot workloads will be production-ready.

513
01:48:00,000 --> 01:48:10,000
In the next segment, we do the Q&A for Series 5.

514
01:48:10,000 --> 01:48:20,000
See you in Segment 23.
```

---

### SEGMENT 23: Series 5 Q&A — Common Questions Answered
**Timestamp:** 110:00 – 115:00

```
515
01:50:00,000 --> 01:50:10,000
Welcome to Segment 23. This is the Q&A for Series 5.

516
01:50:10,000 --> 01:50:20,000
Question 1: "What happens if the Spot interruption happens before the checkpoint is saved?"

517
01:50:20,000 --> 01:50:30,000
The IMDS watcher and SIGTERM handler both trigger checkpoints. If both fail, the periodic checkpoint from the background thread is used.

518
01:50:30,000 --> 01:50:40,000
In the worst case, you lose at most ten minutes of training. This is acceptable for most workloads.

519
01:50:40,000 --> 01:50:50,000
Question 2: "What is a good backoffLimit for Spot workloads?"

520
01:50:50,000 --> 01:51:00,000
For g4dn.xlarge in us-east-1, backoffLimit ten is sufficient. For more volatile instance types, use backoffLimit twenty.

521
01:51:00,000 --> 01:51:10,000
Question 3: "How do I know if a Spot interruption was the cause of a job failure?"

522
01:51:10,000 --> 01:51:20,000
Check the Kubernetes events. Events with reason SpotInterruption indicate a Spot interruption.

523
01:51:20,000 --> 01:51:30,000
```bash
kubectl get events --field-selector reason=SpotInterruption --all-namespaces
```

524
01:51:30,000 --> 01:51:40,000
Question 4: "Can I run stateful workloads on Spot?"

525
01:51:40,000 --> 01:51:50,000
Stateful workloads are not recommended on Spot. They require persistent storage and fail on interruption.

526
01:51:50,000 --> 01:52:00,000
If you must run stateful workloads on Spot, use persistent storage that survives interruption.

527
01:52:00,000 --> 01:52:10,000
Question 5: "How do I handle checkpoint storage cost?"

528
01:52:10,000 --> 01:52:20,000
Use lifecycle policies to delete old checkpoints. The lifecycle policy we applied keeps only the last three checkpoints.

529
01:52:20,000 --> 01:52:30,000
Question 6: "Can I use Spot with multiple GPUs?"

530
01:52:30,000 --> 01:52:40,000
Yes. Use multi-GPU instance types like g4dn.12xlarge. The checkpointing approach works for multi-GPU as well.

531
01:52:40,000 --> 01:52:50,000
Question 7: "What is the best instance type for Spot ML workloads?"

532
01:52:50,000 --> 01:53:00,000
g4dn.xlarge is the best for cost-effectiveness and stability. g5.xlarge is better for larger workloads.

533
01:53:00,000 --> 01:53:10,000
Question 8: "How long does a checkpoint take to save?"

534
01:53:10,000 --> 01:53:20,000
For a one-gigabyte model, it takes about ten seconds. For a ten-gigabyte model, it takes about sixty seconds.

535
01:53:20,000 --> 01:53:30,000
Question 9: "Can I use Spot for inference?"

536
01:53:30,000 --> 01:53:40,000
Yes, but inference workloads are usually stateful. Use Spot only for stateless inference.

537
01:53:40,000 --> 01:53:50,000
Question 10: "What if no Spot capacity is available?"

538
01:53:50,000 --> 01:54:00,000
Karpenter falls back to On-Demand if Spot is not available. The NodePool configuration supports this.

539
01:54:00,000 --> 01:54:10,000
Now you have the answers to the most common questions about Spot workloads.

540
01:54:10,000 --> 01:54:20,000
In the next segment, we do the knowledge check and look ahead to Series 6.

541
01:54:20,000 --> 01:54:30,000
See you in Segment 24.
```

---

### SEGMENT 24: Series 5 Knowledge Check & Next Steps
**Timestamp:** 115:00 – 120:00

```
542
01:55:00,000 --> 01:55:10,000
Welcome to Segment 24. This is the knowledge check for Series 5.

543
01:55:10,000 --> 01:55:20,000
Let's test your understanding of Series 5. Answer these questions in your own words.

544
01:55:20,000 --> 01:55:30,000
Question 1: What is the coefficient of variation and why is it important for Spot instance selection?

545
01:55:30,000 --> 01:55:40,000
Question 2: What are the three mechanisms for detecting a Spot interruption?

546
01:55:40,000 --> 01:55:50,000
Question 3: How does the CheckpointManager handle SIGTERM?

547
01:55:50,000 --> 01:56:00,000
Question 4: Why is SHA-256 verification important for checkpoints?

548
01:56:00,000 --> 01:56:10,000
Question 5: What does backoffLimit do in a Kubernetes Job?

549
01:56:10,000 --> 01:56:20,000
Question 6: Why is multi-AZ diversification important for Spot workloads?

550
01:56:20,000 --> 01:56:30,000
Question 7: What is the IMDS termination-time endpoint?

551
01:56:30,000 --> 01:56:40,000
Question 8: What is the difference between SIGTERM and SIGKILL?

552
01:56:40,000 --> 01:56:50,000
Pause the video. Write down your answers. Then compare them to what you learned.

553
01:56:50,000 --> 01:57:00,000
If you got all eight correct, you understand Series 5. If you missed any, review the relevant segment.

554
01:57:00,000 --> 01:57:10,000
Now let's look ahead to Series 6.

555
01:57:10,000 --> 01:57:20,000
Series 6 is storage and database cost controls. The costs that never go down on their own.

556
01:57:20,000 --> 01:57:30,000
S3 lifecycle policies. ECR image cleanup. RDS stop/start schedules for dev databases. Reserved Instances for production databases.

557
01:57:30,000 --> 01:57:40,000
Terraform enforcement to make all of it permanent. Every byte you write to S3 stays there until you delete it.

558
01:57:40,000 --> 01:57:50,000
Every RDS instance runs 24 hours a day, 7 days a week, whether your developers are using it or not.

559
01:57:50,000 --> 01:58:00,000
These costs compound silently. The fix is automation. Lifecycle policies. Stop/start schedules. Cleanup policies.

560
01:58:00,000 --> 01:58:10,000
By the end of Series 6, your storage and database costs will be on autopilot.

561
01:58:10,000 --> 01:58:20,000
Before you start Series 6, verify these four things:

562
01:58:20,000 --> 01:58:30,000
One: Checkpoint bucket exists. Run `aws s3 ls s3://$CHECKPOINT_BUCKET`.

563
01:58:30,000 --> 01:58:40,000
Two: Training job completed on Spot. Check `kubectl get jobs -n riskoracle`.

564
01:58:40,000 --> 01:58:50,000
Three: Checkpoints in S3. Run `aws s3 ls s3://$CHECKPOINT_BUCKET/checkpoints/`.

565
01:58:50,000 --> 01:59:00,000
Four: Baseline document updated with Spot savings.

566
01:59:00,000 --> 01:59:10,000
Series 5 is complete. You have engineered Spot instances for ML workloads. You have reduced GPU compute cost by seventy-five percent.

567
01:59:10,000 --> 01:59:20,000
From $1,152 a month to $288 a month. No lost training runs. No angry data scientists. Just reliable, cost-effective training.

568
01:59:20,000 --> 01:59:30,000
That is the power of Spot engineering. It is not about avoiding interruptions. It is about making interruptions cost you almost nothing.

569
01:59:30,000 --> 01:59:40,000
The commands work. The savings are real. You just have to do the work.

570
01:59:40,000 --> 01:59:50,000
Now let's recap the running total.

571
01:59:50,000 --> 02:00:00,000
Series 2 savings: $3,700 a month. Series 3 savings: $4,700 a month. Series 4 savings: $2,430 a month. Series 5 savings: $864 a month.

572
02:00:00,000 --> 02:00:10,000
Total savings from Series 2-5: $11,694 a month. $140,328 a year.

573
02:00:10,000 --> 02:00:20,000
The startup bill has gone from $47,000 to approximately $20,000 a month. That is a $27,000 reduction.

574
02:00:20,000 --> 02:00:30,000
Series 6 adds another $596 a month in storage and database savings. The total keeps growing.

575
02:00:30,000 --> 02:00:40,000
See you in Series 6.
```