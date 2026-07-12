# Phase 10, Part 1: Falco Threat Model & Installation — Complete SRT Script

## Runtime Security: The Foundation (00:00:00 - 00:40:00)

```srt
1
00:00:00,000 --> 00:00:08,000
Welcome back to the Financial RAG Agent series. This is Phase 10. And this is where everything changes.

2
00:00:08,000 --> 00:00:16,000
In Phase 9, we built guardrails around our network. We controlled who can talk to whom. We encrypted all traffic. We enforced zero-trust networking with Cilium and Istio.

3
00:00:16,000 --> 00:00:24,000
But here's the thing about networks. They can be breached. Containers can be compromised. What happens when an attacker gets inside your pod? What do you do when all your network policies have failed and someone is already inside your container?

4
00:00:24,000 --> 00:00:32,000
That is what Phase 10 is all about. Runtime security. Threat detection. Falco.

5
00:00:32,000 --> 00:00:40,000
Before we write any code, let me ask you a question. If someone breaks into your pod right now, how would you know? How would you detect it? How long would it take you to find out?

6
00:00:40,000 --> 00:00:48,000
Most organizations don't know they've been breached for weeks. Months. Sometimes years. The average time to detect a breach is over 200 days. That's almost seven months.

7
00:00:48,000 --> 00:00:56,000
During those seven months, attackers are reading your data. They're stealing your secrets. They're using your compute for crypto mining. They're moving laterally through your infrastructure. They're doing all of this right under your nose.

8
00:00:56,000 --> 00:01:04,000
Runtime security closes that gap. It detects breaches in seconds, not months. It alerts you immediately when something suspicious happens. That's what we're building in this phase. That's what makes this system truly production-grade.

9
00:01:04,000 --> 00:01:12,000
Let me start by showing you the threat model. I want you to understand exactly what we are protecting against. This is the most important part of the entire phase. If you don't understand the threat model, you don't understand why we're building any of this.

10
00:01:12,000 --> 00:01:20,000
Open your mind to the attack scenarios. Our Financial RAG Agent runs LLM inference. It reads sensitive financial data from SEC filings. It holds database credentials in Vault-injected files. It's a high-value target.

11
00:01:20,000 --> 00:01:28,000
Scenario number one. Prompt injection. An attacker sends a malicious prompt that causes the LLM to execute arbitrary code. This is a known vulnerability in LLM applications. It's been demonstrated in research papers. It's been exploited in the wild. This is the most common attack vector for AI applications.

12
00:01:28,000 --> 00:01:36,000
Scenario number two. Once they have code execution, they spawn a shell. They run /bin/bash inside your pod. They now have an interactive terminal. They can execute any command. They're inside your application.

13
00:01:36,000 --> 00:01:44,000
Scenario number three. They read /vault/secrets/database.env. They steal your database credentials. They now have access to your PostgreSQL database. They can read all your financial filings. They can modify your data. They can delete everything. Your financial data is now in the hands of an attacker.

14
00:01:44,000 --> 00:01:52,000
Scenario number four. They connect to a command-and-control server. They exfiltrate data. They steal financial filings, user queries, analysis results. They sell this data on the dark web. Your users' data is compromised.

15
00:01:52,000 --> 00:02:00,000
Scenario number five. They run crypto mining software. They use your CPU to mine Bitcoin. Your application becomes slow. Your cloud bill skyrockets. You're paying for the attacker's mining operation. This is called cryptojacking.

16
00:02:00,000 --> 00:02:08,000
These are the five attack scenarios. Prompt injection, shell spawning, credential theft, data exfiltration, and crypto mining. Each one of these attacks leaves a trace. And that trace is what Falco detects.

17
00:02:08,000 --> 00:02:16,000
Every time a program does something, it makes a system call. System calls are the interface between user space and kernel space. Let me explain this distinction. It's critical to understanding how Falco works. This is not optional knowledge. This is foundational.

18
00:02:16,000 --> 00:02:24,000
User space is where your application runs. Python. FastAPI. Uvicorn. This is where your code executes. It's where the attacker's code executes when they compromise your pod. User space is the application layer.

19
00:02:24,000 --> 00:02:32,000
Kernel space is the operating system core. It controls hardware. It manages processes. It handles network. It has complete control over the system. The kernel is the gatekeeper. Everything goes through the kernel.

20
00:02:32,000 --> 00:02:40,000
When your application needs to do something privileged, it makes a system call. Open a file. Connect to a network. Spawn a process. Read from disk. The kernel executes it. Then it returns the result. Every single operation goes through the kernel.

21
00:02:40,000 --> 00:02:48,000
Every system call goes through the kernel. There is no way to avoid this. Even if the attacker has full control of the Python process, the kernel still sees every system call. The attacker cannot bypass the kernel. This is the fundamental truth of operating system security.

22
00:02:48,000 --> 00:02:56,000
Falco sits in the kernel. It watches every system call. It sees everything. Even if the attacker has full control of the Python process, Falco still sees the underlying open syscall when they read /vault/secrets. They cannot hide from Falco. Falco is below their control.

23
00:02:56,000 --> 00:03:04,000
Let me contrast this with traditional security tools. Traditional security tools work in user space. They monitor logs. They monitor application behavior. But if the attacker controls the application, they control the logs. They can delete them. They can modify them. They can turn them off. Traditional tools are vulnerable.

24
00:03:04,000 --> 00:03:12,000
Falco works in kernel space. The attacker cannot control the kernel. They cannot hide system calls. They cannot delete the Falco process without killing the entire node. This is why Falco is so powerful. It's operating below the attacker's control. It's the surveillance system that cannot be turned off.

25
00:03:12,000 --> 00:03:20,000
Let me show you the architecture. Falco runs as a DaemonSet. One pod on every node. Each Falco pod attaches to the kernel's eBPF subsystem.

26
00:03:20,000 --> 00:03:28,000
eBPF stands for extended Berkeley Packet Filter. It allows us to run sandboxed programs in the kernel. eBPF is revolutionary. It's like giving the Linux kernel a programmable brain. Before eBPF, writing kernel code was dangerous. A bug could crash the entire system.

27
00:03:28,000 --> 00:03:36,000
With eBPF, the programs are verified. The kernel checks they are safe before loading them. They cannot crash the system. They cannot access memory they shouldn't. eBPF programs are safe and secure. This is what makes Falco production-ready.

28
00:03:36,000 --> 00:03:44,000
Falco loads an eBPF program. This program watches every system call. It filters them based on our rules. When a rule matches, it generates an event. This event contains all the details of what happened.

29
00:03:44,000 --> 00:03:52,000
Events are sent to Falcosidekick. Falcosidekick is a lightweight router. It sends events to Slack, PagerDuty, CloudWatch, and Prometheus. This is the complete detection pipeline. Kernel, Falco, Falcosidekick, Alert. Every step is critical.

30
00:03:52,000 --> 00:04:00,000
Let me explain the difference between Falco and Cilium. They both use eBPF. But they serve different purposes. Cilium enforces network policies. It blocks traffic. It is proactive. It prevents attacks by stopping them at the network layer. Cilium is the bouncer.

31
00:04:00,000 --> 00:04:08,000
Falco detects threats. It is reactive. It alerts you when an attack happens. It helps you investigate and respond. Falco is the security camera. They complement each other. Cilium blocks the attack. Falco detects the attempt. Together, they provide complete coverage.

32
00:04:08,000 --> 00:04:16,000
Now let's install Falco. We'll use the Helm chart. This is the standard way to install Falco in Kubernetes. Open your terminal and let's get started. I'll walk you through every command.

33
00:04:16,000 --> 00:04:24,000
First, add the Falco Helm repository. This tells Helm where to find the Falco chart.

34
00:04:24,000 --> 00:04:32,000
`helm repo add falcosecurity https://falcosecurity.github.io/charts`
`helm repo update`

35
00:04:32,000 --> 00:04:40,000
Now create the namespace. Falco runs in kube-system. It must access the host's eBPF subsystem. This requires privileged access. We're giving Falco this access because it needs it to do its job.

36
00:04:40,000 --> 00:04:48,000
`kubectl create namespace kube-system --dry-run=client -o yaml | kubectl apply -f -`

37
00:04:48,000 --> 00:04:56,000
Now let's look at the Falco Helm values. Open `falco/config/falco-helm-values.yaml` in your editor. This file configures the Falco daemon. Let me walk through the key settings. These settings are critical to getting Falco working correctly.

38
00:04:56,000 --> 00:05:04,000
```
driver:
  enabled: true
  kind: ebpf
```

39
00:05:04,000 --> 00:05:12,000
We use the eBPF driver. This does not require a kernel module. It works on EKS managed nodes. It also works on any Linux kernel version 5.8 or later. If you're running on an older kernel, you would use the kernel module. But we're on EKS, so we use eBPF. It's more secure and easier to manage.

40
00:05:12,000 --> 00:05:20,000
```
falco:
  rules_file:
    - /etc/falco/falco_rules.yaml
    - /etc/falco/falco_rules.local.yaml
    - /etc/falco/rules.d/financial_rag_rules.yaml
```

41
00:05:20,000 --> 00:05:28,000
Falco loads rules from multiple files. The built-in rules are first. Our custom rules are last. We mount our rules via a ConfigMap. The order matters. Later rules override earlier rules. Our custom rules take precedence over the default rules. This allows us to customize behavior.

42
00:05:28,000 --> 00:05:36,000
```
json_output: true
json_include_output_property: true
log_level: info
priority: warning
```

43
00:05:36,000 --> 00:05:44,000
json_output enables structured logging. This is important for log aggregation. In production, we send logs to CloudWatch or Elasticsearch. JSON is easy to parse. `priority: warning` means only alerts at WARNING or higher are emitted. This reduces noise. We don't care about INFO level events in production. We only care about things that could be attacks.

44
00:05:44,000 --> 00:05:52,000
```
grpc:
  enabled: true
  bind_address: "unix:///var/run/falco/falco.sock"

grpc_output:
  enabled: true
```

45
00:05:52,000 --> 00:06:00,000
gRPC is used to send events to Falcosidekick. Falcosidekick listens on this socket. It routes events to Slack, PagerDuty, and CloudWatch. Without gRPC, Falco would only log to stdout. We want to send alerts to external destinations. So we enable gRPC output. This is how the alerts leave the pod.

46
00:06:00,000 --> 00:06:08,000
Now let's install Falco.

47
00:06:08,000 --> 00:06:16,000
`helm upgrade --install falco falcosecurity/falco --namespace kube-system -f falco/config/falco-helm-values.yaml`

48
00:06:16,000 --> 00:06:24,000
Wait for the Falco pods to start. This takes a moment because they need to load the eBPF driver. The driver is loaded into the kernel on startup. This is the most critical part of the installation.

49
00:06:24,000 --> 00:06:32,000
`kubectl get pods -n kube-system -l app.kubernetes.io/name=falco`

50
00:06:32,000 --> 00:06:40,000
You should see one Falco pod on every node. Each pod is the Falco daemon. It runs in the host's network namespace. It has privileged access to the kernel. This is normal and necessary.

51
00:06:40,000 --> 00:06:48,000
Now let's verify the eBPF driver is loaded. This confirms Falco is attached to the kernel. If the driver isn't loaded, Falco can't see system calls. This is the most common installation failure.

52
00:06:48,000 --> 00:06:56,000
`kubectl exec -n kube-system $(kubectl get pods -n kube-system -l app.kubernetes.io/name=falco -o name | head -1) -- ls -la /sys/fs/bpf/`

53
00:06:56,000 --> 00:07:04,000
You should see a falco directory in the BPF filesystem. This confirms the eBPF program is loaded. If you don't see this directory, the eBPF driver failed to load. Check the Falco logs for errors.

54
00:07:04,000 --> 00:07:12,000
Now let's check Falco's internal status.

55
00:07:12,000 --> 00:07:20,000
`kubectl exec -n kube-system $(kubectl get pods -n kube-system -l app.kubernetes.io/name=falco -o name | head -1) -- falco -l 2>/dev/null | grep -i version`

56
00:07:20,000 --> 00:07:28,000
This shows the Falco version and the loaded rules. You should see the built-in rules loaded. This confirms Falco is running correctly.

57
00:07:28,000 --> 00:07:36,000
Now let me show you the Falco logs. This is where we see alerts and system messages. This is how we monitor Falco.

58
00:07:36,000 --> 00:07:44,000
`kubectl logs -n kube-system $(kubectl get pods -n kube-system -l app.kubernetes.io/name=falco -o name | head -1) --tail=50`

59
00:07:44,000 --> 00:07:52,000
You should see Falco startup messages. It reports the loaded rules. It reports the eBPF driver status. It reports the gRPC server status. Everything should look green. No errors.

60
00:07:52,000 --> 00:08:00,000
Now let's test Falco is working. We will create a test pod and spawn a shell. This should trigger a Falco alert. This is the moment of truth.

61
00:08:00,000 --> 00:08:08,000
`kubectl run test-shell --image=alpine --namespace=financial-rag --labels="app.kubernetes.io/component=api" --restart=Never -- sleep 600`

62
00:08:08,000 --> 00:08:16,000
This creates a pod running Alpine Linux. It has the API component label. Falco sees it as an API pod. It applies all our rules to it. This pod is our test subject.

63
00:08:16,000 --> 00:08:24,000
Now exec into the pod and spawn a shell.

64
00:08:24,000 --> 00:08:32,000
`kubectl exec -n financial-rag test-shell -- /bin/sh -c "echo test"`

65
00:08:32,000 --> 00:08:40,000
This triggers the shell spawn rule. Let's check Falco logs.

66
00:08:40,000 --> 00:08:48,000
`kubectl logs -n kube-system $(kubectl get pods -n kube-system -l app.kubernetes.io/name=falco -o name | head -1) | grep "Shell Spawned"`

67
00:08:48,000 --> 00:08:56,000
You should see an alert. It contains the user, the command, the pod name. Everything we need to investigate. This is the security camera in action. It saw the shell spawn. It alerted immediately. This is working.

68
00:08:56,000 --> 00:09:04,000
Without Falco, this would be invisible. You would never know someone ran a shell in your pod. With Falco, you have a complete audit trail. Every suspicious action is logged. This is the power of runtime security.

69
00:09:04,000 --> 00:09:12,000
Clean up the test pod.

70
00:09:12,000 --> 00:09:20,000
`kubectl delete pod test-shell -n financial-rag`

71
00:09:20,000 --> 00:09:28,000
Now let me explain why this matters. This is not just a security tool. This is a compliance tool. SOC2 requires runtime monitoring. PCI DSS requires intrusion detection. GDPR requires breach notification. Falco provides all of these.

72
00:09:28,000 --> 00:09:36,000
Falco is your security camera. It is your audit trail. It is your early warning system. When an auditor asks "How do you know if you've been breached?", you point to Falco. When a security incident happens, Falco tells you immediately. This is how you protect your users.

73
00:09:36,000 --> 00:09:44,000
Now let me show you the full file tree for Phase 10. I want you to see everything we are going to build.

74
00:09:44,000 --> 00:09:52,000
`falco/config/falco.yaml`. Falco daemon configuration. `falco/config/falco-helm-values.yaml`. Helm values for Falco.

75
00:09:52,000 --> 00:10:00,000
`falco/rules/financial_rag_rules.yaml`. Eight custom rules. We will write these in Part 2. These are the heart of the detection system.

76
00:10:00,000 --> 00:10:08,000
`falco/sidekick/falcosidekick-values.yaml`. Falcosidekick configuration. We will configure this in Part 3. This is how alerts get routed.

77
00:10:08,000 --> 00:10:16,000
`observability/prometheus-rules/financial-rag-alerts.yaml`. PrometheusRule for Falco alerts. We will apply this in Part 3. This is how we get paged.

78
00:10:16,000 --> 00:10:24,000
These are all the files we need. The runtime security stack is complete. Everything is in place. Now we just need to build it.

79
00:10:24,000 --> 00:10:32,000
Now let's recap what we have built in Part 1.

80
00:10:32,000 --> 00:10:40,000
We understood the threat model. Prompt injection, shell spawning, credential theft, data exfiltration, and crypto mining. These are the attacks we're defending against. This is the threat landscape.

81
00:10:40,000 --> 00:10:48,000
We learned about user space versus kernel space. Falco operates in the kernel. It sees everything. The attacker cannot hide from Falco. This is the fundamental advantage of runtime security. This is why Falco is so powerful.

82
00:10:48,000 --> 00:10:56,000
We installed Falco as a DaemonSet. We used the eBPF driver. It runs on every node. It watches every system call. This is the surveillance system. This is the security camera.

83
00:10:56,000 --> 00:11:04,000
We verified the installation. Falco is running. The eBPF driver is loaded. The rules are loaded. Everything is working. This is a successful deployment.

84
00:11:04,000 --> 00:11:12,000
We tested Falco. We created a test pod and spawned a shell. Falco detected the shell and alerted. The security camera works. The detection system is live.

85
00:11:12,000 --> 00:11:20,000
This is the foundation of runtime security. In Part 2, we write the custom rules. Eight rules that cover our threat model. Each rule detects a specific type of attack. This is where Falco becomes truly powerful.

86
00:11:20,000 --> 00:11:28,000
In Part 3, we integrate Falco with Slack, PagerDuty, and CloudWatch. We build the complete alerting pipeline. We make sure the right people are notified when an attack happens. This is where we close the loop.

87
00:11:28,000 --> 00:11:36,000
This is where we become security engineers. This is where we build systems that detect and respond to threats. This is where we protect our users' data. This is what production-grade security looks like.

88
00:11:36,000 --> 00:11:44,000
I'll see you in Part 2.

89
00:11:44,000 --> 00:11:48,000
[End of Part 1]
```
# Phase 10, Part 2: Custom Falco Rules & Threat Detection — Complete 40-Minute SRT Script

## Part 2: Custom Falco Rules & Threat Detection (00:40:00 - 01:20:00)

```srt
1
00:40:00,000 --> 00:40:08,000
Welcome back to Phase 10. This is Part 2. And this is where we write the actual Falco rules that detect attacks in real-time. This is the heart of runtime security.

2
00:40:08,000 --> 00:40:16,000
In Part 1, we installed Falco. We got the eBPF driver running. We verified the installation works. But here's the thing about Falco. It's like a security camera. You can have the most expensive security camera system in the world. But if you don't tell it what to look for, it's useless.

3
00:40:16,000 --> 00:40:24,000
Falco has default rules. They're good. They detect common attacks. But they don't understand our application. They don't know what normal behavior looks like for the Financial RAG Agent. They don't know what's suspicious and what's not.

4
00:40:24,000 --> 00:40:32,000
That's why we need custom rules. Rules that understand our application. Rules that know what normal behavior looks like. Rules that detect abnormal behavior. That's what we're building in this part.

5
00:40:32,000 --> 00:40:40,000
Let me show you exactly what we're going to build. We're going to write eight custom rules. Eight rules that cover our entire threat model. Let me walk through the threat model again. I want you to understand exactly what we are defending against before we write any rules.

6
00:40:40,000 --> 00:40:48,000
Attack scenario number one. Prompt injection. An attacker sends a malicious prompt that causes the LLM to execute arbitrary code. This is a known vulnerability in LLM applications. It's been demonstrated in research papers. It's been exploited in the wild. Once they have code execution, they spawn a shell.

7
00:40:48,000 --> 00:40:56,000
Attack scenario number two. They read /vault/secrets/database.env. They steal your database credentials. They now have access to your PostgreSQL database. They can read all your financial filings. They can modify your data. They can delete everything.

8
00:40:56,000 --> 00:41:04,000
Attack scenario number three. A compromised agent pod connects to an attacker's C2 server. This is how attackers exfiltrate data and maintain persistence. They send your financial data to their server.

9
00:41:04,000 --> 00:41:12,000
Attack scenario number four. An attacker uses kubectl exec to enter a pod. This is how attackers move laterally through your infrastructure. They go from one pod to another.

10
00:41:12,000 --> 00:41:20,000
Attack scenario number five. Cryptojacking. An attacker runs mining software on your pods. This degrades performance and increases cloud costs. You're paying for the attacker's mining operation.

11
00:41:20,000 --> 00:41:28,000
Attack scenario number six. A container escape attempt. Writing to the read-only filesystem. This is how attackers break out of containers and get access to the host.

12
00:41:28,000 --> 00:41:36,000
Attack scenario number seven. Privilege escalation via setuid binary. This is how attackers gain root access. Once they have root, they control everything.

13
00:41:36,000 --> 00:41:44,000
Attack scenario number eight. Credential harvesting via /proc/*/environ. This is how attackers steal environment variables containing secrets. They read your API keys. Your database passwords. Your encryption keys.

14
00:41:44,000 --> 00:41:52,000
These are the eight attack scenarios. Each one corresponds to a Falco rule. Falco detects these at the syscall layer. Below the application. Below the container runtime. Even if the attacker has full control of the Python process, Falco sees the underlying open, connect, and execve syscalls.

15
00:41:52,000 --> 00:42:00,000
Let me show you the anatomy of a Falco rule. Every rule has five required fields. Understanding this structure is critical to writing effective rules.

16
00:42:00,000 --> 00:42:08,000
The first field is the rule name. This appears in the alert. It should be descriptive. It should tell the responder what happened. For example, "Shell Spawned in Financial RAG Pod". That's clear. That's actionable. When someone gets that alert, they immediately know what happened.

17
00:42:08,000 --> 00:42:16,000
The second field is the description. This explains why the rule exists. It helps responders understand the threat context. For example, "A shell was spawned inside a financial-rag pod. This should never happen in production." That tells the responder why this matters. It gives them context.

18
00:42:16,000 --> 00:42:24,000
The third field is the condition. This is the heart of the rule. It is a boolean expression using Falco fields. These fields map to system call data. For example, `spawned_process and financial_rag_namespace and shell_procs`. This matches any shell process spawned in our namespace.

19
00:42:24,000 --> 00:42:32,000
The fourth field is the output. This is the alert message. It uses template variables like `%user.name` and `%proc.cmdline`. It defines what information is included in the alert. For example, "Shell spawned in financial-rag pod (user=%user.name command=%proc.cmdline pod=%k8s.pod.name)". This gives the responder everything they need to investigate.

20
00:42:32,000 --> 00:42:40,000
The fifth field is the priority. This tells us how urgent the alert is. CRITICAL means wake someone up. WARNING means log it for auditing. HIGH means investigate soon. This determines who gets paged and how urgently.

21
00:42:40,000 --> 00:42:48,000
The sixth field is the tags. These are metadata. We use MITRE ATT&CK tags for classification. T1059 is command and script interpreter. T1552 is credential theft. This helps with threat intelligence and compliance reporting. It also helps categorize alerts.

22
00:42:48,000 --> 00:42:56,000
Open `falco/rules/financial_rag_rules.yaml` in your editor. This is where we will write all our custom rules. Let me walk through every rule in detail. I'm going to explain each one thoroughly.

23
00:42:56,000 --> 00:43:04,000
Before I explain the rules, let me define the macros. Macros are reusable conditions. They make our rules readable and maintainable. We define them once and reuse them everywhere. This is a programming best practice applied to security rules.

24
00:43:04,000 --> 00:43:12,000
The first macro is `financial_rag_namespace`. This matches any event in the financial-rag namespace. We use this in every rule. It scopes detection to our application only. We don't care about events in other namespaces. This reduces noise and false positives.

25
00:43:12,000 --> 00:43:20,000
macro: financial_rag_namespace
condition: k8s.ns.name = "financial-rag"

26
00:43:20,000 --> 00:43:28,000
The second macro is `api_container`. This matches API pods. The API runs FastAPI. It handles user requests. It is a high-value target. Attackers want to compromise the API because it has the most access. It talks to the database. It talks to the agent. It handles user input.

27
00:43:28,000 --> 00:43:36,000
macro: api_container
condition: financial_rag_namespace and k8s.pod.label.app.kubernetes.io/component = "api"

28
00:43:36,000 --> 00:43:44,000
The third macro is `agent_container`. This matches agent pods. The agent runs LLM inference. It handles sensitive data. It is also a high-value target. Attackers want to compromise the agent because it has access to the LLM and the database. It also has the most compute resources.

29
00:43:44,000 --> 00:43:52,000
macro: agent_container
condition: financial_rag_namespace and k8s.pod.label.app.kubernetes.io/component = "agent"

30
00:43:52,000 --> 00:44:00,000
The fourth macro is `ingestion_container`. This matches ingestion pods. They run as CronJobs. They have lower privilege. They are less likely targets, but still need protection. They handle SEC filing downloads.

31
00:44:00,000 --> 00:44:08,000
macro: ingestion_container
condition: financial_rag_namespace and k8s.pod.label.app.kubernetes.io/component = "ingestion"

32
00:44:08,000 --> 00:44:16,000
The fifth macro is `vault_agent_container`. This matches the Vault sidecar container. It is allowed to do things other containers cannot. It reads secrets. It writes to /vault/secrets. We need to exclude it from our rules. Otherwise, we'd get false positives.

33
00:44:16,000 --> 00:44:24,000
macro: vault_agent_container
condition: container.name = "vault-agent"

34
00:44:24,000 --> 00:44:32,000
The sixth macro is `istio_proxy_container`. This matches the Istio sidecar. It is also allowed to do things other containers cannot. It handles traffic. It proxies requests. We need to exclude it from our rules. Otherwise, we'd get false positives.

35
00:44:32,000 --> 00:44:40,000
macro: istio_proxy_container
condition: container.name = "istio-proxy"

36
00:44:40,000 --> 00:44:48,000
The seventh macro is `allowed_containers`. This combines Vault Agent and Istio Proxy. We use it to exclude legitimate containers from rules. This simplifies our rule conditions. We don't have to repeat the not clauses everywhere.

37
00:44:48,000 --> 00:44:56,000
macro: allowed_containers
condition: vault_agent_container or istio_proxy_container

38
00:44:56,000 --> 00:45:04,000
Now let's look at Rule 1. Shell Spawned in Financial RAG Pod. This is our highest priority rule. It detects the most common attack vector. If an attacker gets code execution, the first thing they do is spawn a shell.

39
00:45:04,000 --> 00:45:12,000
rule: Shell Spawned in Financial RAG Pod
desc: A shell was spawned inside a financial-rag pod. This should never happen in production.

40
00:45:12,000 --> 00:45:20,000
condition: >
  spawned_process and
  financial_rag_namespace and
  shell_procs and
  not vault_agent_container and
  not istio_proxy_container

41
00:45:20,000 --> 00:45:28,000
Let me break this down. `spawned_process` means a new process was created. `financial_rag_namespace` uses our macro. `shell_procs` is a built-in Falco macro that matches bash, sh, zsh, dash, fish. The `not` clauses prevent false positives. Vault Agent sometimes spawns subprocesses. Istio Proxy sometimes spawns subprocesses. We ignore those.

42
00:45:28,000 --> 00:45:36,000
output: >
  Shell spawned in financial-rag pod
  (user=%user.name user_uid=%user.uid
   command=%proc.cmdline
   pod=%k8s.pod.name
   container=%container.name
   namespace=%k8s.ns.name
   image=%container.image.repository:%container.image.tag)

43
00:45:36,000 --> 00:45:44,000
The output includes everything a responder needs. The user who ran the command. The exact command. The pod name. The container name. The image. This is complete forensic data. You can immediately see what happened and where. You can reconstruct the entire attack.

44
00:45:44,000 --> 00:45:52,000
priority: CRITICAL. This is a critical alert. If a shell spawns in production, someone needs to investigate immediately. This could be a breach in progress. The on-call engineer gets paged.

45
00:45:52,000 --> 00:46:00,000
tags: [financial-rag, shell, post-exploit, T1059]. T1059 is the MITRE ATT&CK technique for command and script interpreter. This helps with threat intelligence and compliance reporting.

46
00:46:00,000 --> 00:46:08,000
Now let's look at Rule 2. Unexpected Outbound Connection from Agent Pod. This detects lateral movement attempts.

47
00:46:08,000 --> 00:46:16,000
rule: Unexpected Outbound Connection from Agent Pod
desc: Agent pod established a connection to an unexpected destination.

48
00:46:16,000 --> 00:46:24,000
condition: >
  outbound and
  agent_container and
  not fd.sport in (5432, 6379, 443, 15001, 15006) and
  not fd.sip = "127.0.0.1"

49
00:46:24,000 --> 00:46:32,000
The agent should only talk to pgvector on port 5432. Redis on port 6379. External HTTPS on port 443. Istio sidecars on ports 15001 and 15006. If the agent connects to any other port, this rule fires. Even if Cilium blocks it, Falco still alerts. This is defense in depth.

50
00:46:32,000 --> 00:46:40,000
This rule catches lateral movement attempts. If an attacker compromises the agent, they might try to connect to other services. Maybe they try to reach the API. Maybe they try to reach the database directly. Falco catches it. The attacker can't hide.

51
00:46:40,000 --> 00:46:48,000
output: >
  Unexpected outbound connection from agent pod
  (command=%proc.cmdline
   connection=%fd.name
   pod=%k8s.pod.name
   namespace=%k8s.ns.name)

52
00:46:48,000 --> 00:46:56,000
The output includes the command, the connection details, and the pod name. This helps responders understand what the attacker was trying to do. Was it a connection to a known C2 server? Was it a connection to an internal service? This helps prioritize the response.

53
00:46:56,000 --> 00:47:04,000
priority: HIGH. This is a high priority alert. It could indicate lateral movement. It needs investigation. Not as critical as a shell spawn, but still serious.

54
00:47:04,000 --> 00:47:12,000
tags: [financial-rag, network, lateral-movement, T1071]. T1071 is application layer protocol.

55
00:47:12,000 --> 00:47:20,000
Now let's look at Rule 3. Write Outside Allowed Paths in Financial RAG. This detects container escape attempts.

56
00:47:20,000 --> 00:47:28,000
rule: Write Outside Allowed Paths in Financial RAG
desc: A container wrote to a path outside the allowed writable paths.

57
00:47:28,000 --> 00:47:36,000
condition: >
  open_write and
  financial_rag_namespace and
  not fd.name startswith "/tmp/" and
  not fd.name startswith "/vault/secrets/" and
  not fd.name startswith "/var/run/" and
  not fd.name startswith "/proc/" and
  not fd.name = "/dev/null" and
  not vault_agent_container and
  not istio_proxy_container

58
00:47:36,000 --> 00:47:44,000
All our containers have `readOnlyRootFilesystem: true`. They can only write to `/tmp`, `/vault/secrets`, `/var/run`, and `/dev/null`. Everything else is read-only. If a container writes to any other path, this rule fires. This detects container escape attempts. An attacker trying to write to the host filesystem.

59
00:47:44,000 --> 00:47:52,000
output: >
  Write outside allowed paths
  (user=%user.name
   file=%fd.name
   command=%proc.cmdline
   pod=%k8s.pod.name
   container=%container.name)

60
00:47:52,000 --> 00:48:00,000
This tells the responder which file was written, which process did it, and which pod it happened in. This is critical forensic data. It helps determine if the attacker was trying to escape the container.

61
00:48:00,000 --> 00:48:08,000
priority: HIGH. This is a high priority alert. It could indicate a container escape attempt. Immediate investigation required. This is one of the most serious security events.

62
00:48:08,000 --> 00:48:16,000
tags: [financial-rag, filesystem, T1565]. T1565 is data manipulation.

63
00:48:16,000 --> 00:48:24,000
Now let's look at Rule 4. Vault Secret Read by Unexpected Process. This detects credential theft.

64
00:48:24,000 --> 00:48:32,000
rule: Vault Secret Read by Unexpected Process
desc: A process other than the application binary read a Vault secret file.

65
00:48:32,000 --> 00:48:40,000
condition: >
  open_read and
  financial_rag_namespace and
  fd.name startswith "/vault/secrets/" and
  not proc.name in (python3, python, uvicorn, gunicorn, vault) and
  not vault_agent_container

66
00:48:40,000 --> 00:48:48,000
Vault Agent writes secrets to `/vault/secrets/`. The application reads them. That is normal behavior. The application is Python. It uses uvicorn or gunicorn to run. If any other process reads from `/vault/secrets/`, this rule fires. This detects credential theft. An attacker reading your database password from disk.

67
00:48:48,000 --> 00:48:56,000
output: >
  Unexpected process reading Vault secret
  (process=%proc.name
   file=%fd.name
   pod=%k8s.pod.name
   container=%container.name)

68
00:48:56,000 --> 00:49:04,000
This tells the responder which process read the secret, which file was read, and which pod it happened in. This is the most critical alert. The attacker has accessed your secrets. They may have your database credentials. Immediate action required.

69
00:49:04,000 --> 00:49:12,000
priority: CRITICAL. This is a critical alert. The attacker has accessed your secrets. They may have your database credentials. Immediate action required. The on-call engineer gets paged.

70
00:49:12,000 --> 00:49:20,000
tags: [financial-rag, vault, credential-access, T1552]. T1552 is credential theft.

71
00:49:20,000 --> 00:49:28,000
Now let's look at Rule 5. Privilege Escalation in Financial RAG Pod. This detects root access attempts.

72
00:49:28,000 --> 00:49:36,000
rule: Privilege Escalation in Financial RAG Pod
desc: setuid or setgid binary executed in financial-rag namespace.

73
00:49:36,000 --> 00:49:44,000
condition: >
  financial_rag_namespace and
  evt.type = execve and
  (proc.is_suid_binary = true or proc.is_sgid_binary = true) and
  not proc.name in (sudo, ping)

74
00:49:44,000 --> 00:49:52,000
setuid and setgid binaries run with elevated privileges. An attacker might try to exploit them to gain root access. This rule detects that attempt. `sudo` and `ping` are common setuid binaries. We exclude them because they are legitimate. Everything else is suspicious.

75
00:49:52,000 --> 00:50:00,000
output: >
  Privilege escalation attempt
  (command=%proc.cmdline
   pod=%k8s.pod.name
   container=%container.name
   user=%user.name)

76
00:50:00,000 --> 00:50:08,000
priority: CRITICAL. This is a critical alert. The attacker is trying to gain root access. Immediate action required. This is one of the most serious security events.

77
00:50:08,000 --> 00:50:16,000
tags: [financial-rag, privilege-escalation, T1548]. T1548 is abuse elevation control mechanism.

78
00:50:16,000 --> 00:50:24,000
Now let's look at Rule 6. Crypto Mining Process in Financial RAG. This detects resource hijacking.

79
00:50:24,000 --> 00:50:32,000
rule: Crypto Mining Process in Financial RAG
desc: Known crypto mining process names detected in financial-rag namespace.

80
00:50:32,000 --> 00:50:40,000
condition: >
  financial_rag_namespace and
  spawned_process and
  proc.name in (xmrig, minerd, cpuminer, ethminer, nbminer,
                phoenix, t-rex, gminer, lolminer, wildrig)

81
00:50:40,000 --> 00:50:48,000
Crypto miners are resource-intensive. They consume CPU and memory. They will degrade your application performance. They will increase your cloud bill. This rule detects known crypto mining software by process name. If an attacker installs a miner, Falco catches it immediately.

82
00:50:48,000 --> 00:50:56,000
output: >
  Crypto mining process detected
  (process=%proc.name
   pod=%k8s.pod.name
   container=%container.name
   args=%proc.args)

83
00:50:56,000 --> 00:51:04,000
priority: CRITICAL. This is a critical alert. The attacker is using your compute to mine crypto. This costs you money. Immediate action required. You need to kill the pod and investigate.

84
00:51:04,000 --> 00:51:12,000
tags: [financial-rag, crypto-mining, T1496]. T1496 is resource hijacking.

85
00:51:12,000 --> 00:51:20,000
Now let's look at Rule 7. kubectl exec in Financial RAG Namespace. This creates an audit trail for privileged access.

86
00:51:20,000 --> 00:51:28,000
rule: kubectl exec in Financial RAG Namespace
desc: kubectl exec was used to attach to a financial-rag pod.

87
00:51:28,000 --> 00:51:36,000
condition: >
  ka.verb = "create" and
  ka.target.resource = "pods/exec" and
  ka.target.namespace = "financial-rag"

88
00:51:36,000 --> 00:51:44,000
This rule uses the Kubernetes audit log. It detects when someone runs kubectl exec to enter a pod. The priority is WARNING, not CRITICAL. kubectl exec is permitted via approved runbook with MFA. This rule creates an audit trail. Every exec session is logged with the user, pod, and command.

89
00:51:44,000 --> 00:51:52,000
output: >
  kubectl exec into financial-rag pod
  (user=%ka.user.name
   pod=%ka.target.name
   namespace=%ka.target.namespace
   command=%ka.uri.param[command])

90
00:51:52,000 --> 00:52:00,000
priority: WARNING. This is an audit event. It is important for compliance but not critical. It's logged for SOC2 audit. It helps with incident response if something goes wrong.

91
00:52:00,000 --> 00:52:08,000
tags: [financial-rag, exec, audit, CC6.1]. CC6.1 is the SOC2 control for privileged access.

92
00:52:08,000 --> 00:52:16,000
Now let's look at Rule 8. Read Process Environment in Financial RAG. This detects credential harvesting.

93
00:52:16,000 --> 00:52:24,000
rule: Read Process Environment in Financial RAG
desc: A process read another process's environment variables via /proc.

94
00:52:24,000 --> 00:52:32,000
condition: >
  open_read and
  financial_rag_namespace and
  fd.name glob "/proc/*/environ" and
  not proc.name in (ps, top, htop)

95
00:52:32,000 --> 00:52:40,000
Processes store environment variables in `/proc/*/environ`. This includes secrets. API keys. Database passwords. If an attacker reads this file, they can harvest credentials. This rule detects that. `ps`, `top`, and `htop` are legitimate tools. They sometimes read `/proc`. We exclude them.

96
00:52:40,000 --> 00:52:48,000
output: >
  Process environment read (possible credential harvest)
  (command=%proc.cmdline
   file=%fd.name
   pod=%k8s.pod.name)

97
00:52:48,000 --> 00:52:56,000
priority: HIGH. This is a high priority alert. The attacker is harvesting credentials. They may have accessed your secrets. Investigation required.

98
00:52:56,000 --> 00:53:04,000
tags: [financial-rag, credential-access, T1082]. T1082 is system information discovery.

99
00:53:04,000 --> 00:53:12,000
These eight rules form our detection capability. They cover the entire threat model. Let me recap them all so you can see the complete picture.

100
00:53:12,000 --> 00:53:20,000
Rule 1: Shell Spawned. Detects post-exploit shell access. This is the most common attack. Rule 2: Unexpected Outbound Connection. Detects lateral movement.

101
00:53:20,000 --> 00:53:28,000
Rule 3: Write Outside Allowed Paths. Detects container escape attempts. Rule 4: Vault Secret Read. Detects credential theft.

102
00:53:28,000 --> 00:53:36,000
Rule 5: Privilege Escalation. Detects root access attempts. Rule 6: Crypto Mining. Detects resource hijacking.

103
00:53:36,000 --> 00:53:44,000
Rule 7: kubectl exec. Audit trail for privileged access. Rule 8: Process Environment Read. Detects credential harvesting.

104
00:53:44,000 --> 00:53:52,000
Now let me show you how to deploy these rules. We create a ConfigMap from the rules file. This is how we get our custom rules into Falco.

105
00:53:52,000 --> 00:54:00,000
kubectl create configmap falco-financial-rag-rules \
  --namespace kube-system \
  --from-file=financial_rag_rules.yaml=falco/rules/financial_rag_rules.yaml

106
00:54:00,000 --> 00:54:08,000
This creates a ConfigMap named `falco-financial-rag-rules`. It contains our eight custom rules. The ConfigMap is stored in etcd. It's available to all Falco pods.

107
00:54:08,000 --> 00:54:16,000
Now we need to mount this ConfigMap into the Falco pods. We do this by upgrading the Helm release. This is how we tell Falco where to find our rules.

108
00:54:16,000 --> 00:54:24,000
helm upgrade --install falco falcosecurity/falco \
  --namespace kube-system \
  -f falco/config/falco-helm-values.yaml \
  --set extraVolumes[0].name=financial-rag-rules \
  --set extraVolumes[0].configMap.name=falco-financial-rag-rules \
  --set extraVolumeMounts[0].mountPath=/etc/falco/rules.d \
  --set extraVolumeMounts[0].name=financial-rag-rules

109
00:54:24,000 --> 00:54:32,000
This mounts the ConfigMap at `/etc/falco/rules.d`. Falco loads all rules from this directory. Any rule file in this directory is loaded automatically.

110
00:54:32,000 --> 00:54:40,000
Now let's verify the rules are loaded. We need to check that Falco actually sees our rules.

111
00:54:40,000 --> 00:54:48,000
kubectl exec -n kube-system \
  $(kubectl get pods -n kube-system -l app.kubernetes.io/name=falco -o name | head -1) \
  -- falco -l 2>/dev/null | grep "financial-rag"

112
00:54:48,000 --> 00:54:56,000
This lists all loaded rules. You should see our eight rules. Shell Spawned. Unexpected Outbound Connection. Vault Secret Read. All of them. If you don't see them, something went wrong with the mount.

113
00:54:56,000 --> 00:55:04,000
Now let's test the rules. We will deliberately trigger an alert. This is how we verify our rules work.

114
00:55:04,000 --> 00:55:12,000
First, create a test pod in the financial-rag namespace. This pod will be our target.

115
00:55:12,000 --> 00:55:20,000
kubectl run test-shell --image=alpine --namespace=financial-rag \
  --labels="app.kubernetes.io/component=api" \
  --restart=Never -- sleep 600

116
00:55:20,000 --> 00:55:28,000
This creates a pod running Alpine Linux. It has the API component label. Falco sees it as an API pod. It applies all our rules to it.

117
00:55:28,000 --> 00:55:36,000
Now exec into the pod and spawn a shell. This should trigger Rule 1.

118
00:55:36,000 --> 00:55:44,000
kubectl exec -n financial-rag test-shell -- /bin/sh -c "echo test"

119
00:55:44,000 --> 00:55:52,000
This triggers Rule 1. Shell Spawned in Financial RAG Pod. Let's check Falco logs.

120
00:55:52,000 --> 00:56:00,000
kubectl logs -n kube-system \
  $(kubectl get pods -n kube-system -l app.kubernetes.io/name=falco -o name | head -1) \
  | grep "Shell Spawned"

121
00:56:00,000 --> 00:56:08,000
You should see an alert. It contains the user, the command, the pod name. Everything we need to investigate. The security camera works. Let me show you what the alert looks like.

122
00:56:08,000 --> 00:56:16,000
The alert says "Shell spawned in financial-rag pod". It shows the user was root. It shows the command was `/bin/sh -c echo test`. It shows the pod was test-shell. It shows the container was test-shell. This is complete forensic data.

123
00:56:16,000 --> 00:56:24,000
Now let's test Rule 4. Vault Secret Read. We don't have Vault secrets in this test pod, but we can simulate the pattern.

124
00:56:24,000 --> 00:56:32,000
kubectl exec -n financial-rag test-shell -- \
  cat /vault/secrets/database.env 2>/dev/null || true

125
00:56:32,000 --> 00:56:40,000
This reads from the `/vault/secrets/` path. Even though the file doesn't exist, the open syscall still happens. Falco sees it.

126
00:56:40,000 --> 00:56:48,000
kubectl logs -n kube-system \
  $(kubectl get pods -n kube-system -l app.kubernetes.io/name=falco -o name | head -1) \
  | grep "Vault Secret Read"

127
00:56:48,000 --> 00:56:56,000
You should see the alert. It shows the process that tried to read the secret. It shows the pod name. It shows everything. The alert says "Unexpected process reading Vault secret". It shows the process was cat. It shows the file was /vault/secrets/database.env.

128
00:56:56,000 --> 00:57:04,000
Now let's test Rule 2. Unexpected Outbound Connection. The agent should only connect to specific ports.

129
00:57:04,000 --> 00:57:12,000
kubectl exec -n financial-rag test-shell -- \
  wget -q --timeout=3 http://example.com:8080 || true

130
00:57:12,000 --> 00:57:20,000
This connects to port 8080. The agent should only connect to ports 5432, 6379, 443, and Istio ports. 8080 is unexpected.

131
00:57:20,000 --> 00:57:28,000
kubectl logs -n kube-system \
  $(kubectl get pods -n kube-system -l app.kubernetes.io/name=falco -o name | head -1) \
  | grep "Unexpected Outbound"

132
00:57:28,000 --> 00:57:36,000
You should see the alert. The agent tried to connect to an unexpected port. Falco caught it. The alert says "Unexpected outbound connection from agent pod". It shows the command was wget. It shows the connection was to port 8080.

133
00:57:36,000 --> 00:57:44,000
Now let's clean up the test pod.

134
00:57:44,000 --> 00:57:52,000
kubectl delete pod test-shell -n financial-rag

135
00:57:52,000 --> 00:58:00,000
Now let me show you how to update rules without restarting Falco. This is called hot reload. It's a powerful feature.

136
00:58:00,000 --> 00:58:08,000
First, edit the rules file. Add a new rule or modify an existing one. Let's say you want to add a new rule. You edit the file in your editor.

137
00:58:08,000 --> 00:58:16,000
Then update the ConfigMap. This updates the rules in etcd.

138
00:58:16,000 --> 00:58:24,000
kubectl create configmap falco-financial-rag-rules \
  --namespace kube-system \
  --from-file=financial_rag_rules.yaml=falco/rules/financial_rag_rules.yaml \
  --dry-run=client -o yaml | kubectl apply -f -

139
00:58:24,000 --> 00:58:32,000
Then send SIGHUP to Falco. This tells it to reload rules without restarting. SIGHUP is the signal for "reload configuration".

140
00:58:32,000 --> 00:58:40,000
kubectl exec -n kube-system \
  $(kubectl get pods -n kube-system -l app.kubernetes.io/name=falco -o name | head -1) \
  -- kill -1 1

141
00:58:40,000 --> 00:58:48,000
This is powerful. You can update rules in real-time. No pod restart. No downtime. No disruption to threat detection. You can iterate on rules quickly.

142
00:58:48,000 --> 00:58:56,000
Now let's recap what we have built in Part 2.

143
00:58:56,000 --> 00:59:04,000
We defined eight custom rules covering the financial RAG threat model. Shell spawning. Unexpected outbound connections. Filesystem writes outside allowed paths. Vault secret reads by unexpected processes.

144
00:59:04,000 --> 00:59:12,000
Privilege escalation. Crypto mining. kubectl exec audit. Process environment reads. Every attack scenario is covered.

145
00:59:12,000 --> 00:59:20,000
We learned the anatomy of a Falco rule. Name. Description. Condition. Output. Priority. Tags. We understand how to write effective rules.

146
00:59:20,000 --> 00:59:28,000
We learned about macros. Reusable conditions that make rules readable and maintainable. We use them to scope rules to our namespace and exclude legitimate containers.

147
00:59:28,000 --> 00:59:36,000
We tested each rule. We saw Falco fire on shell spawning. Vault secret reads. Outbound connections. The detection works.

148
00:59:36,000 --> 00:59:44,000
We deployed rules via ConfigMap. We learned how to hot-reload rules without restarting Falco. We can iterate quickly.

149
00:59:44,000 --> 00:59:52,000
This is runtime security. This is detecting attacks that bypass all other defenses. This is protecting our users' data.

150
00:59:52,000 --> 01:00:00,000
In Part 3, we integrate Falco with Prometheus and Falcosidekick. We create alerts for critical events. We build dashboards to visualize security events. We build the complete alerting pipeline.

151
01:00:00,000 --> 01:00:08,000
Let me give you a preview of what's coming. In Part 3, we'll configure Falcosidekick to send alerts to Slack, PagerDuty, and CloudWatch. We'll set up Prometheus alerts for critical events. We'll build a complete alerting pipeline.

152
01:00:08,000 --> 01:00:16,000
When a shell spawns, Slack gets a message. When a Vault secret is read, PagerDuty pages the on-call engineer. Every event is logged to CloudWatch for SOC2 audit. This is a complete security response system.

153
01:00:16,000 --> 01:00:24,000
But for now, you have the rules. You have the detection. You know what to look for. This is the foundation of runtime security.

154
01:00:24,000 --> 01:00:32,000
I'll see you in Part 3.

155
01:00:32,000 --> 01:00:36,000
[End of Part 2]
```
# Phase 10: Runtime Security & Threat Detection — Part 3 (01:20:00 - 02:00:00)

## Falcosidekick, Prometheus & Alerting Pipeline — Complete SRT Script

```srt
1
01:20:00,000 --> 01:20:08,000
Welcome back to Phase 10. This is Part 3. This is the final part of our runtime security stack. And this is where things get really exciting.

2
01:20:08,000 --> 01:20:16,000
We have Falco installed. We have eight custom rules detecting threats. We have the eBPF driver running on every node. We have the security camera watching everything. But detection is not enough.

3
01:20:16,000 --> 01:20:24,000
You need to know when an alert fires. You need to get notified. You need to have an audit trail. You need to build dashboards. You need to alert on critical threats. That's what we're building in this part.

4
01:20:24,000 --> 01:20:32,000
Let me show you the architecture. Falco detects an event. It sends the alert to Falcosidekick. Falcosidekick routes it to Slack, PagerDuty, and CloudWatch. Prometheus scrapes Falco metrics. PrometheusRule fires alerts based on those metrics.

5
01:20:32,000 --> 01:20:40,000
The complete alerting pipeline. Let me break this down piece by piece. First, Falco detects a shell spawning. It sends an alert to Falcosidekick. Falcosidekick routes to Slack. Slack shows a message in #security-alerts.

6
01:20:40,000 --> 01:20:48,000
Simultaneously, Falcosidekick routes to PagerDuty. PagerDuty pages the on-call engineer. Simultaneously, Falcosidekick routes to CloudWatch. The event is stored in /aws/falco/financial-rag for SOC2 audit.

7
01:20:48,000 --> 01:20:56,000
At the same time, Prometheus scrapes Falco metrics. The FalcoCriticalEventDetected alert fires. The security team is notified via Slack. The on-call engineer gets a PagerDuty alert. The CloudWatch log is stored for SOC2 audit. This is the complete pipeline.

8
01:20:56,000 --> 01:21:04,000
Everything happens in seconds. From the moment the shell spawns to the moment the on-call engineer gets paged. That's runtime security. That's what we're building today.

9
01:21:04,000 --> 01:21:12,000
First, let's understand the Falcosidekick configuration. Open `falco/sidekick/falcosidekick-values.yaml` in your editor. This file configures where Falco alerts are sent.

10
01:21:12,000 --> 01:21:20,000
We have three destinations configured. Slack for warnings and above. PagerDuty for critical only. CloudWatch for all events. Each destination serves a different purpose.

11
01:21:20,000 --> 01:21:28,000
Let me walk through the Slack configuration. This is the most important destination because this is where most people will first see the alerts.

12
01:21:28,000 --> 01:21:36,000
config:
  slack:
    webhookurl: ""              # set via --set config.slack.webhookurl=$SLACK_WEBHOOK
    channel: "#security-alerts"
    iconemoji: ":rotating_light:"
    username: "Falco | financial-rag"
    outputformat: "all"
    minimumpriority: "warning"
    messageformat: |
      *{{ .Rule }}* | Priority: {{ .Priority }} | Pod: {{ .OutputFields.k8s_pod_name }}

13
01:21:36,000 --> 01:21:44,000
`slack.webhookurl` is the Slack webhook URL. You get this from Slack's incoming webhooks feature. `slack.channel` is "#security-alerts". `slack.username` is "Falco | financial-rag". `slack.minimumpriority` is "warning".

14
01:21:44,000 --> 01:21:52,000
We use a custom message format. `*{{ .Rule }}* | Priority: {{ .Priority }} | Pod: {{ .OutputFields.k8s_pod_name }}`. This creates a readable Slack message. The message includes the rule name, the priority, and the pod name.

15
01:21:52,000 --> 01:22:00,000
This is enough information for the security team to start investigating. They know what happened. They know how urgent it is. They know where it happened. They can start their investigation immediately.

16
01:22:00,000 --> 01:22:08,000
Now the PagerDuty configuration. This is for the most critical alerts. The ones that wake someone up.

17
01:22:08,000 --> 01:22:16,000
pagerduty:
  routingkey: ""              # set via secret
  minimumpriority: "critical"
  region: "us"

18
01:22:16,000 --> 01:22:24,000
`pagerduty.routingkey` is the PagerDuty routing key. You get this from your PagerDuty service integration. `pagerduty.minimumpriority` is "critical". Only critical alerts wake someone up.

19
01:22:24,000 --> 01:22:32,000
Why only critical? Because PagerDuty sends push notifications. It pages people. It wakes them up at 3 AM. We don't want to page someone for a warning. We only page for critical events that require immediate action.

20
01:22:32,000 --> 01:22:40,000
What counts as critical? Shell spawning. Vault secret theft. Privilege escalation. Crypto mining. These are the critical events. These are the ones that wake someone up.

21
01:22:40,000 --> 01:22:48,000
Now the CloudWatch configuration. This is for audit and compliance. Every event goes to CloudWatch.

22
01:22:48,000 --> 01:22:56,000
aws:
  cloudwatchlogs:
    loggroup: "/aws/falco/financial-rag"
    logstream: ""             # auto-generated per instance
    minimumpriority: "warning"
    region: "us-east-1"

23
01:22:56,000 --> 01:23:04,000
`aws.cloudwatchlogs.loggroup` is "/aws/falco/financial-rag". `aws.cloudwatchlogs.minimumpriority` is "warning". Every warning and above event is stored in CloudWatch.

24
01:23:04,000 --> 01:23:12,000
CloudWatch is for SOC2 audit. If we ever need to investigate a security incident, we can query CloudWatch logs. The audit trail is complete. Every security event is stored. Nothing is lost.

25
01:23:12,000 --> 01:23:20,000
Now let's look at the resources configuration. Falcosidekick needs resources to run. We give it what it needs.

26
01:23:20,000 --> 01:23:28,000
resources:
  requests:
    cpu: 50m
    memory: 64Mi
  limits:
    cpu: 200m
    memory: 256Mi

27
01:23:28,000 --> 01:23:36,000
50 millicpu and 64 megabytes of memory. That's very small. Falcosidekick is lightweight. It just routes alerts. It doesn't do heavy processing. It uses very little resources.

28
01:23:36,000 --> 01:23:44,000
Now let's look at the high availability configuration. We want Falcosidekick to be available even if a node fails.

29
01:23:44,000 --> 01:23:52,000
affinity:
  podAntiAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchLabels:
            app.kubernetes.io/name: falcosidekick
        topologyKey: kubernetes.io/hostname

30
01:23:52,000 --> 01:24:00,000
We configured two replicas with pod anti-affinity. This ensures alert delivery even if one node fails. Each replica runs on a different node. If one node goes down, the other node is still running. High availability for security alerts is critical.

31
01:24:00,000 --> 01:24:08,000
Now let's install Falcosidekick. We already installed it with Falco, but let me show you the command.

32
01:24:08,000 --> 01:24:16,000
helm upgrade --install falco falcosecurity/falco \
  --namespace kube-system \
  -f falco/config/falco-helm-values.yaml \
  -f falco/sidekick/falcosidekick-values.yaml

33
01:24:16,000 --> 01:24:24,000
We set the Slack webhook and PagerDuty key at install time. You pass them as environment variables to Helm.

34
01:24:24,000 --> 01:24:32,000
helm upgrade --install falco falcosecurity/falco \
  --namespace kube-system \
  -f falco/config/falco-helm-values.yaml \
  -f falco/sidekick/falcosidekick-values.yaml \
  --set falcosidekick.config.slack.webhookurl="${SLACK_SECURITY_WEBHOOK}" \
  --set falcosidekick.config.pagerduty.routingkey="${PAGERDUTY_PROD_KEY}"

35
01:24:32,000 --> 01:24:40,000
Let me show you how to get these values. For Slack, you create an incoming webhook in your Slack workspace. Go to Slack. Go to Apps. Go to Incoming Webhooks. Create a new webhook. Choose the #security-alerts channel. Copy the webhook URL.

36
01:24:40,000 --> 01:24:48,000
For PagerDuty, you create a service integration. Go to PagerDuty. Go to Services. Click Add Integration. Choose Events API v2. Copy the routing key. That's it.

37
01:24:48,000 --> 01:24:56,000
Now let's verify Falcosidekick is running.

38
01:24:56,000 --> 01:25:04,000
kubectl get pods -n kube-system -l app.kubernetes.io/name=falcosidekick

39
01:25:04,000 --> 01:25:12,000
You should see two replicas. Both are running. Each on a different node. High availability is working.

40
01:25:12,000 --> 01:25:20,000
Now let's test Falcosidekick. Trigger a shell spawn. This will send an alert through the entire pipeline.

41
01:25:20,000 --> 01:25:28,000
kubectl run test-shell --image=alpine --namespace=financial-rag \
  --labels="app.kubernetes.io/component=api" \
  --restart=Never -- sleep 600

42
01:25:28,000 --> 01:25:36,000
kubectl exec -n financial-rag test-shell -- /bin/sh -c "echo test"

43
01:25:36,000 --> 01:25:44,000
Check Slack. You should see a message from Falco. "Shell spawned in financial-rag pod | Priority: CRITICAL | Pod: test-shell". The message is formatted and readable.

44
01:25:44,000 --> 01:25:52,000
Check PagerDuty. You should see an incident created for the critical alert. The incident title is "Falco critical event: Shell Spawned in Financial RAG Pod". The on-call engineer gets a push notification.

45
01:25:52,000 --> 01:26:00,000
Check CloudWatch. `aws logs describe-log-groups --log-group-name-prefix /aws/falco`. You should see the log group exists. The event is stored for audit. Let's look at the logs.

46
01:26:00,000 --> 01:26:08,000
aws logs get-log-events \
  --log-group-name /aws/falco/financial-rag \
  --log-stream-name $(aws logs describe-log-streams \
    --log-group-name /aws/falco/financial-rag \
    --order-by LastEventTime \
    --descending \
    --limit 1 \
    --query 'logStreams[0].logStreamName' \
    --output text) \
  --limit 10

47
01:26:08,000 --> 01:26:16,000
You should see the shell spawn event in CloudWatch logs. The complete audit trail. The event is stored forever. SOC2 auditors can review it.

48
01:26:16,000 --> 01:26:24,000
Now let's set up Prometheus integration. Falco exposes metrics at /metrics. The Helm values enable this with `serviceMonitor.enabled: true`.

49
01:26:24,000 --> 01:26:32,000
Open `falco/config/falco-helm-values.yaml`. Look for `serviceMonitor`. `serviceMonitor.enabled: true`. `serviceMonitor.labels.release: kube-prometheus-stack`.

50
01:26:32,000 --> 01:26:40,000
The label `release: kube-prometheus-stack` is critical. The Prometheus operator only picks up ServiceMonitors that match its label selector. If this label is wrong, the ServiceMonitor is ignored. We learned this lesson in Phase 5.

51
01:26:40,000 --> 01:26:48,000
Let me explain how this works. The Prometheus operator watches for ServiceMonitors. It looks for ServiceMonitors with the label `release: kube-prometheus-stack`. When it finds one, it adds the target to Prometheus.

52
01:26:48,000 --> 01:26:56,000
If the label doesn't match, the ServiceMonitor is ignored. No metrics are scraped. No alerts fire. So this label is critical. Make sure it matches your Prometheus operator's label selector.

53
01:26:56,000 --> 01:27:04,000
Now let's apply the Prometheus alerts. Open `observability/prometheus-rules/financial-rag-alerts.yaml` in your editor. This defines alerting rules for Falco events. We have four security alerts in this file.

54
01:27:04,000 --> 01:27:12,000
Let me walk through the Falco alert. This is the most important security alert.

55
01:27:12,000 --> 01:27:20,000
- alert: FalcoCriticalEventDetected
  expr: |
    sum(rate(falco_events_total{namespace="financial-rag",priority="Critical"}[5m])) > 0
  for: 0m
  labels:
    severity: critical
    team: security
  annotations:
    summary: "Falco CRITICAL security event in financial-rag"
    description: "Falco detected a critical security event. Immediate investigation required."

56
01:27:20,000 --> 01:27:28,000
`for: 0m` means the alert fires immediately. No waiting period. Security events at critical priority require immediate response, not a 5-minute wait to confirm the alert. This is a security alert, not a performance alert.

57
01:27:28,000 --> 01:27:36,000
The labels tell us who to page. `severity: critical`. `team: security`. The annotations tell us what to do. `summary: "Falco CRITICAL security event in financial-rag"`. `description: "Falco detected a critical security event. Immediate investigation required."`

58
01:27:36,000 --> 01:27:44,000
Now let's look at the Cilium alert. This detects high drop rates in the network.

59
01:27:44,000 --> 01:27:52,000
- alert: CiliumDropRateHigh
  expr: |
    sum(rate(hubble_drop_total{namespace="financial-rag"}[5m])) > 10
  for: 2m
  labels:
    severity: warning
    team: security
  annotations:
    summary: "High Cilium drop rate in financial-rag namespace"
    description: "{{ $value }} drops/sec in financial-rag. May indicate lateral movement attempt or policy misconfiguration."

60
01:27:52,000 --> 01:28:00,000
If Cilium drops more than 10 packets per second for 2 minutes, this alert fires. This could indicate a network policy violation. An attacker trying to connect to a blocked port. Cilium is blocking it, but we want to know about it.

61
01:28:00,000 --> 01:28:08,000
Now let's look at the Vault alert. This detects token renewal failures.

62
01:28:08,000 --> 01:28:16,000
- alert: VaultTokenRenewalFailure
  expr: |
    sum(rate(financial_rag_vault_token_renewal_errors_total[5m])) > 0
  for: 1m
  labels:
    severity: critical
    team: security
  annotations:
    summary: "Vault token renewal failing"
    description: "Pods cannot renew Vault tokens — secrets will expire causing application failures."

63
01:28:16,000 --> 01:28:24,000
If Vault token renewal fails, this alert fires. This means pods cannot get new secrets. They will eventually lose access to the database. This is a critical operational failure. The application will break.

64
01:28:24,000 --> 01:28:32,000
Now let's look at the API alert. This detects high error rates on the API.

65
01:28:32,000 --> 01:28:40,000
- alert: APIHighErrorRate
  expr: |
    (
      sum(rate(http_requests_total{namespace="financial-rag",component="api",status=~"5.."}[5m]))
      /
      sum(rate(http_requests_total{namespace="financial-rag",component="api"}[5m]))
    ) > 0.05
  for: 2m
  labels:
    severity: critical
    team: platform
  annotations:
    summary: "API error rate above 5%"
    description: "financial-rag API error rate is {{ $value | humanizePercentage }} over the last 5 minutes. SLO breach imminent."

66
01:28:40,000 --> 01:28:48,000
If the API error rate exceeds 5% for 2 minutes, this alert fires. This could indicate a security attack. An attacker sending malformed requests to cause errors. Or it could indicate a legitimate outage. Either way, we want to know.

67
01:28:48,000 --> 01:28:56,000
Now let's apply the PrometheusRule.

68
01:28:56,000 --> 01:29:04,000
kubectl apply -f observability/prometheus-rules/financial-rag-alerts.yaml

69
01:29:04,000 --> 01:29:12,000
Wait a few minutes for Prometheus to scrape the new rules. Then check the alerts in Prometheus.

70
01:29:12,000 --> 01:29:20,000
kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090

71
01:29:20,000 --> 01:29:28,000
Open http://localhost:9090/alerts. You should see FalcoCriticalEventDetected in the list. It will be inactive until a critical event occurs.

72
01:29:28,000 --> 01:29:36,000
Now let's test the full pipeline. Trigger a critical event. We'll do this step by step so you can see every part of the pipeline working.

73
01:29:36,000 --> 01:29:44,000
Step 1: Create a test pod in the financial-rag namespace.

74
01:29:44,000 --> 01:29:52,000
kubectl run test-shell --image=alpine --namespace=financial-rag \
  --labels="app.kubernetes.io/component=api" \
  --restart=Never -- sleep 600

75
01:29:52,000 --> 01:30:00,000
Step 2: Spawn a shell in the pod. This triggers Rule 1.

76
01:30:00,000 --> 01:30:08,000
kubectl exec -n financial-rag test-shell -- /bin/sh -c "echo test"

77
01:30:08,000 --> 01:30:16,000
Step 3: Check Slack. You should see a message from Falco. The message is formatted and readable. "Shell spawned in financial-rag pod | Priority: CRITICAL | Pod: test-shell".

78
01:30:16,000 --> 01:30:24,000
Step 4: Check PagerDuty. You should see an incident created. The incident title is "Falco critical event: Shell Spawned in Financial RAG Pod". The on-call engineer gets a push notification.

79
01:30:24,000 --> 01:30:32,000
Step 5: Check Prometheus alerts. FalcoCriticalEventDetected should be firing. The alert is active. The severity is critical. The team is security.

80
01:30:32,000 --> 01:30:40,000
The full pipeline works. Falco detects the shell spawn. It sends the alert to Falcosidekick. Falcosidekick routes to Slack, PagerDuty, and CloudWatch. Prometheus scrapes Falco metrics. The FalcoCriticalEventDetected alert fires. The security team is notified via Slack. The on-call engineer gets a PagerDuty alert. The CloudWatch log is stored for SOC2 audit.

81
01:30:40,000 --> 01:30:48,000
Clean up the test pod.

82
01:30:48,000 --> 01:30:56,000
kubectl delete pod test-shell -n financial-rag

83
01:30:56,000 --> 01:31:04,000
Now let me show you how to view Falco metrics in Grafana. We already have Grafana running from Phase 5.

84
01:31:04,000 --> 01:31:12,000
kubectl port-forward -n monitoring svc/grafana 3000:3000

85
01:31:12,000 --> 01:31:20,000
Open http://localhost:3000. Login with admin/admin. Go to Explore. Select the Prometheus data source.

86
01:31:20,000 --> 01:31:28,000
Query `falco_events_total{namespace="financial-rag"}`. You will see the total number of Falco events. Filter by priority to see critical events only. You can build a dashboard showing Falco events over time. This is useful for security monitoring and SOC2 compliance.

87
01:31:28,000 --> 01:31:36,000
Let me show you a sample dashboard query. `sum(rate(falco_events_total{namespace="financial-rag"}[5m])) by (priority)`. This shows the rate of Falco events by priority. You can see how many critical events are happening.

88
01:31:36,000 --> 01:31:44,000
Another useful query. `histogram_quantile(0.95, sum(rate(falco_event_latency_seconds_bucket[5m])) by (le))`. This shows the latency of Falco processing. You can see how fast Falco is detecting events.

89
01:31:44,000 --> 01:31:52,000
These dashboards are essential for security monitoring. They show you what's happening in your cluster. They show you if attacks are happening. They show you if Falco is working properly.

90
01:31:52,000 --> 01:32:00,000
Now let me show you the complete file tree for Phase 10. This is everything we built.

91
01:32:00,000 --> 01:32:08,000
falco/config/falco.yaml. Falco daemon configuration. falco/config/falco-helm-values.yaml. Helm values for Falco.

92
01:32:08,000 --> 01:32:16,000
falco/rules/financial_rag_rules.yaml. Eight custom rules. falco/sidekick/falcosidekick-values.yaml. Falcosidekick configuration.

93
01:32:16,000 --> 01:32:24,000
observability/prometheus-rules/financial-rag-alerts.yaml. PrometheusRule for Falco alerts.

94
01:32:24,000 --> 01:32:32,000
These are all the files we need. The runtime security stack is complete. Everything works together. Cilium, Istio, Falco, Prometheus, Grafana. All working together.

95
01:32:32,000 --> 01:32:40,000
Now let's recap the entire Phase 10.

96
01:32:40,000 --> 01:32:48,000
Part 1: Falco Threat Model & Installation. We installed Falco with the eBPF driver. We verified the installation. We understood the threat model. We saw Falco detect a shell spawn.

97
01:32:48,000 --> 01:32:56,000
Part 2: Custom Rules. We wrote eight custom rules. Shell spawning. Unexpected outbound connections. Filesystem writes. Vault secret reads. Privilege escalation. Crypto mining. kubectl exec audit. Process environment reads. Every attack scenario is covered.

98
01:32:56,000 --> 01:33:04,000
Part 3: Falcosidekick & Prometheus Integration. We configured Falcosidekick to route alerts to Slack, PagerDuty, and CloudWatch. We applied Prometheus alerts for critical events. We tested the full pipeline. The alerts go to the right people.

99
01:33:04,000 --> 01:33:12,000
This is a complete runtime security stack. It detects threats in real-time. It routes alerts to the right people. It stores audit logs for compliance. This is production-grade security.

100
01:33:12,000 --> 01:33:20,000
This is the final piece of the security puzzle. Cilium secures the network. Istio secures service-to-service communication. ArgoCD ensures configuration consistency. Falco detects runtime threats. This is defense in depth.

101
01:33:20,000 --> 01:33:28,000
Multiple layers of security. No single point of failure. Each layer protects against different types of attacks. If one layer fails, the others are still there. This is how you build secure systems.

102
01:33:28,000 --> 01:33:36,000
Let me show you the complete stack one more time. Layer 1: Network. Cilium enforces L3, L4, and L7 policies at the kernel level. Zero-trust networking. Layer 2: Service Mesh. Istio provides mTLS and identity-based authorization. Every hop is encrypted.

103
01:33:36,000 --> 01:33:44,000
Layer 3: GitOps. ArgoCD ensures configuration consistency. Git is the source of truth. Layer 4: Runtime Security. Falco detects threats at the syscall level. Real-time threat detection. Layer 5: Observability. Prometheus and Grafana provide visibility. Alerts route to Slack and PagerDuty.

104
01:33:44,000 --> 01:33:52,000
This is the complete security stack. No single layer is perfect. Together, they provide defense in depth. This is how you protect your applications in production. This is how you protect your users' data.

105
01:33:52,000 --> 01:34:00,000
Thank you for following along with Phase 10. This completes the runtime security stack. You now have a complete production-grade Financial RAG Agent.

106
01:34:00,000 --> 01:34:08,000
From the first line of Python to the last line of Kubernetes YAML. From the development environment to the production cluster. From the application code to the security stack. Everything is complete.

107
01:34:08,000 --> 01:34:16,000
This is a full-stack AI application. It is secure. It is scalable. It is maintainable. It is production-ready. You built this.

108
01:34:16,000 --> 01:34:24,000
Let me know when you are ready for the next phase. We still have more to build. The observability stack awaits. But for now, take a moment to appreciate what you've built. This is a significant achievement.

109
01:34:24,000 --> 01:34:32,000
I'll see you in Phase 11.

110
01:34:32,000 --> 01:34:36,000
[End of Phase 10]
```
