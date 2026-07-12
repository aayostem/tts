1
00:00:00,000 --> 00:00:06,000
Welcome to Phase 10 of the Financial RAG Agent series. This is where we become security engineers.

2
00:00:06,000 --> 00:00:12,000
In Phase 9, we built guardrails around our network. We controlled who can talk to whom. We encrypted all traffic. We enforced zero-trust networking.

3
00:00:12,000 --> 00:00:18,000
But networks can be breached. Containers can be compromised. What happens when an attacker gets inside your pod? What do you do when all your network policies have failed?

4
00:00:18,000 --> 00:00:24,000
That is what Phase 10 is about. Runtime security. Threat detection. Falco.

5
00:00:24,000 --> 00:00:30,000
Let me ask you a question. If someone breaks into your pod right now, how would you know? How would you detect it? How long would it take you to find out?

6
00:00:30,000 --> 00:00:36,000
Most organizations don't know they've been breached for weeks. Sometimes months. The average time to detect a breach is over 200 days.

7
00:00:36,000 --> 00:00:42,000
Runtime security closes that gap. It detects breaches in seconds, not months. It alerts you immediately when something suspicious happens.

8
00:00:42,000 --> 00:00:48,000
Before we install anything, let me show you the threat model. I want you to understand exactly what we are protecting against.

9
00:00:48,000 --> 00:00:54,000
Our application runs LLM inference. It reads sensitive financial data from SEC filings. It holds database credentials in Vault-injected files.

10
00:00:54,000 --> 00:01:00,000
Scenario number one: Prompt injection. An attacker sends a malicious prompt that causes the LLM to execute arbitrary code. This is a known vulnerability.

11
00:01:00,000 --> 00:01:06,000
Scenario number two: Once they have code execution, they spawn a shell. They run /bin/bash inside your pod.

12
00:01:06,000 --> 00:01:12,000
Scenario number three: They read /vault/secrets/database.env. They steal your database credentials. They now have access to your PostgreSQL database.

13
00:01:12,000 --> 00:01:18,000
Scenario number four: They connect to a command-and-control server. They exfiltrate data. They steal financial filings, user queries, analysis results.

14
00:01:18,000 --> 00:01:24,000
Scenario number five: They run crypto mining software. They use your CPU to mine Bitcoin. Your cloud bill skyrockets.

15
00:01:24,000 --> 00:01:30,000
Each of these attacks leaves a trace. Every time a program does something, it makes a system call. System calls are the interface between user space and kernel space.

16
00:01:30,000 --> 00:01:36,000
User space is where your application runs. Python. FastAPI. Uvicorn. This is where your code executes.

17
00:01:36,000 --> 00:01:42,000
Kernel space is the operating system core. It controls hardware. It manages processes. It handles network. It has complete control over the system.

18
00:01:42,000 --> 00:01:48,000
When your application needs to do something privileged, it makes a system call. Open a file. Connect to a network. Spawn a process. Read from disk.

19
00:01:48,000 --> 00:01:54,000
The kernel executes it. Then it returns the result. Every system call goes through the kernel.

20
00:01:54,000 --> 00:02:00,000
Falco sits in the kernel. It watches every system call. It sees everything. Even if the attacker has full control of the Python process, Falco still sees the underlying open syscall when they read /vault/secrets.

21
00:02:00,000 --> 00:02:06,000
Traditional security tools work in user space. They monitor logs. They monitor application behavior. But if the attacker controls the application, they control the logs.

22
00:02:06,000 --> 00:02:12,000
Falco works in kernel space. The attacker cannot control the kernel. They cannot hide system calls. They cannot delete the Falco process without killing the entire node.

23
00:02:12,000 --> 00:02:18,000
Now let's install Falco. We'll use the Helm chart. Open your editor and create `falco/config/falco-helm-values.yaml`.

24
00:02:18,000 --> 00:02:24,000
We'll start with the driver configuration. This tells Falco how to attach to the kernel.
[Types: driver: enabled: true kind: ebpf]

25
00:02:24,000 --> 00:02:30,000
We use the eBPF driver. This does not require a kernel module. It works on EKS managed nodes. It also works on any Linux kernel version 5.8 or later.

26
00:02:30,000 --> 00:02:36,000
Now the Falco configuration. This is the main configuration section.
[Types: falco:]

27
00:02:36,000 --> 00:02:42,000
[Types: rules_file: - /etc/falco/falco_rules.yaml - /etc/falco/falco_rules.local.yaml - /etc/falco/rules.d/financial_rag_rules.yaml]

28
00:02:42,000 --> 00:02:48,000
Falco loads rules from multiple files. The built-in rules are first. Our custom rules are last. We mount our rules via a ConfigMap.

29
00:02:48,000 --> 00:02:54,000
[Types: json_output: true]

30
00:02:54,000 --> 00:03:00,000
json_output enables structured logging. This is important for log aggregation. In production, we send logs to CloudWatch or Elasticsearch.

31
00:03:00,000 --> 00:03:06,000
[Types: json_include_output_property: true]

32
00:03:06,000 --> 00:03:12,000
This includes the output property in the JSON. This is useful for parsing alerts.

33
00:03:12,000 --> 00:03:18,000
[Types: log_level: info]

34
00:03:18,000 --> 00:03:24,000
log_level: info means we log informational messages. This is the default setting.

35
00:03:24,000 --> 00:03:30,000
[Types: priority: warning]

36
00:03:30,000 --> 00:03:36,000
priority: warning means only alerts at WARNING or higher are emitted. This reduces noise. We don't care about INFO level events in production.

37
00:03:36,000 --> 00:03:42,000
Now the gRPC configuration. This is how Falco communicates with Falcosidekick.
[Types: grpc: enabled: true bind_address: "unix:///var/run/falco/falco.sock"]

38
00:03:42,000 --> 00:03:48,000
gRPC is used to send events to Falcosidekick. Falcosidekick listens on this socket. It routes events to Slack, PagerDuty, and CloudWatch.

39
00:03:48,000 --> 00:03:54,000
[Types: grpc_output: enabled: true]

40
00:03:54,000 --> 00:04:00,000
grpc_output enables sending events over gRPC. Without this, Falco would only log to stdout.

41
00:04:00,000 --> 00:04:06,000
Now let's add the extra volumes. These mount our custom rules.
[Types: extraVolumes: - name: financial-rag-rules configMap: name: falco-financial-rag-rules]

42
00:04:06,000 --> 00:04:12,000
This mounts the ConfigMap containing our custom rules. The ConfigMap is named falco-financial-rag-rules.

43
00:04:12,000 --> 00:04:18,000
[Types: extraVolumeMounts: - mountPath: /etc/falco/rules.d name: financial-rag-rules]

44
00:04:18,000 --> 00:04:24,000
This mounts the rules directory inside the Falco container. Falco reads all rules from this directory.

45
00:04:24,000 --> 00:04:30,000
Now let's add the resources. Falco needs CPU and memory to run.
[Types: resources: requests: cpu: 100m memory: 512Mi limits: cpu: 1000m memory: 1024Mi]

46
00:04:30,000 --> 00:04:36,000
Falco is lightweight. 100 millicpu and 512 MB of memory is enough for most workloads.

47
00:04:36,000 --> 00:04:42,000
Now let's add the tolerations. This ensures Falco runs on all nodes.
[Types: tolerations: - operator: Exists effect: NoSchedule - operator: Exists effect: NoExecute]

48
00:04:42,000 --> 00:04:48,000
Falco must run on every node. These tolerations allow it to schedule on nodes with taints.

49
00:04:48,000 --> 00:04:54,000
[Types: serviceMonitor: enabled: true labels: release: kube-prometheus-stack]

50
00:04:54,000 --> 00:05:00,000
The ServiceMonitor enables Prometheus scraping. The label must match the Prometheus Operator's label selector.

51
00:05:00,000 --> 00:05:06,000
Now let's install Falco.

52
00:05:06,000 --> 00:05:12,000
First, add the Falco Helm repository.
[Types: helm repo add falcosecurity https://falcosecurity.github.io/charts]
[Types: helm repo update]

53
00:05:12,000 --> 00:05:18,000
Now install Falco with our values.
[Types: helm upgrade --install falco falcosecurity/falco --namespace kube-system -f falco/config/falco-helm-values.yaml]

54
00:05:18,000 --> 00:05:24,000
Wait for Falco to start.
[Types: kubectl get pods -n kube-system -l app.kubernetes.io/name=falco]

55
00:05:24,000 --> 00:05:30,000
You should see one Falco pod on every node.

56
00:05:30,000 --> 00:05:36,000
Now let's verify the eBPF driver is loaded.
[Types: kubectl exec -n kube-system $(kubectl get pods -n kube-system -l app.kubernetes.io/name=falco -o name | head -1) -- ls -la /sys/fs/bpf/]

57
00:05:36,000 --> 00:05:42,000
You should see a falco directory in the BPF filesystem. This confirms the eBPF program is loaded.

58
00:05:42,000 --> 00:05:48,000
Now let's check the Falco logs.
[Types: kubectl logs -n kube-system $(kubectl get pods -n kube-system -l app.kubernetes.io/name=falco -o name | head -1) --tail=50]

59
00:05:48,000 --> 00:05:54,000
You should see Falco startup messages. It reports the loaded rules. It reports the eBPF driver status.

60
00:05:54,000 --> 00:06:00,000
Now let's test Falco is working. Create a test pod and spawn a shell.
[Types: kubectl run test-shell --image=alpine --namespace=financial-rag --labels="app.kubernetes.io/component=api" --restart=Never -- sleep 600]

61
00:06:00,000 --> 00:06:06,000
[Types: kubectl exec -n financial-rag test-shell -- /bin/sh -c "echo test"]

62
00:06:06,000 --> 00:06:12,000
Now check Falco logs for the alert.
[Types: kubectl logs -n kube-system $(kubectl get pods -n kube-system -l app.kubernetes.io/name=falco -o name | head -1) | grep "Shell Spawned"]

63
00:06:12,000 --> 00:06:18,000
You should see an alert. It contains the user, the command, the pod name. Everything we need to investigate.

64
00:06:18,000 --> 00:06:24,000
Clean up the test pod.
[Types: kubectl delete pod test-shell -n financial-rag]

65
00:06:24,000 --> 00:06:30,000
Now let me recap what we've built in Part 1.

66
00:06:30,000 --> 00:06:36,000
We understood the threat model. Prompt injection, shell spawning, credential theft, data exfiltration, and crypto mining.

67
00:06:36,000 --> 00:06:42,000
We learned about user space versus kernel space. Falco operates in the kernel. It sees everything. The attacker cannot hide from Falco.

68
00:06:42,000 --> 00:06:48,000
We installed Falco as a DaemonSet. We used the eBPF driver. It runs on every node. It watches every system call.

69
00:06:48,000 --> 00:06:54,000
We verified the installation. Falco is running. The eBPF driver is loaded. The rules are loaded.

70
00:06:54,000 --> 00:07:00,000
We tested Falco. We created a test pod and spawned a shell. Falco detected the shell and alerted.

71
00:07:00,000 --> 00:07:06,000
In Part 2, we write the custom rules. Eight rules that cover our threat model.

72
00:07:06,000 --> 00:07:12,000
Thank you for watching. I'll see you in Part 2.

73
00:07:12,000 --> 00:07:16,000
[End of Part 1]

1
00:00:00,000 --> 00:00:06,000
Welcome back to Phase 10. In Part 2, we write the custom Falco rules that detect attacks in real-time.

2
00:00:06,000 --> 00:00:12,000
We have Falco installed. We have the eBPF driver running. But Falco is useless without good rules. The default rules are generic. They detect common attacks. But they don't understand our application.

3
00:00:12,000 --> 00:00:18,000
We need custom rules. Rules that understand the Financial RAG Agent. Rules that know what normal behavior looks like. Rules that detect abnormal behavior.

4
00:00:18,000 --> 00:00:24,000
Open your editor and create `falco/rules/financial_rag_rules.yaml`.

5
00:00:24,000 --> 00:00:30,000
We'll start with the macros. Macros are reusable conditions. They make our rules readable and maintainable.
[Types: - macro: financial_rag_namespace condition: k8s.ns.name = "financial-rag"]

6
00:00:30,000 --> 00:00:36,000
This macro matches any event in the financial-rag namespace. We use this in every rule. It scopes detection to our application only.

7
00:00:36,000 --> 00:00:42,000
Now let's define the API container macro.
[Types: - macro: api_container condition: financial_rag_namespace and k8s.pod.label.app.kubernetes.io/component = "api"]

8
00:00:42,000 --> 00:00:48,000
The API runs FastAPI. It handles user requests. It is a high-value target. Attackers want to compromise the API.

9
00:00:48,000 --> 00:00:54,000
Now let's define the agent container macro.
[Types: - macro: agent_container condition: financial_rag_namespace and k8s.pod.label.app.kubernetes.io/component = "agent"]

10
00:00:54,000 --> 00:01:00,000
The agent runs LLM inference. It handles sensitive data. It is also a high-value target. Attackers want to compromise the agent.

11
00:01:00,000 --> 00:01:06,000
Now let's define the ingestion container macro.
[Types: - macro: ingestion_container condition: financial_rag_namespace and k8s.pod.label.app.kubernetes.io/component = "ingestion"]

12
00:01:06,000 --> 00:01:12,000
The ingestion runs as CronJobs. It has lower privilege. It is less likely to be targeted.

13
00:01:12,000 --> 00:01:18,000
Now let's define the vault agent container macro.
[Types: - macro: vault_agent_container condition: container.name = "vault-agent"]

14
00:01:18,000 --> 00:01:24,000
The Vault Agent sidecar is allowed to do things other containers cannot. We need to exclude it from our rules.

15
00:01:24,000 --> 00:01:30,000
Now let's define the istio proxy container macro.
[Types: - macro: istio_proxy_container condition: container.name = "istio-proxy"]

16
00:01:30,000 --> 00:01:36,000
The Istio sidecar is also allowed to do things other containers cannot. We need to exclude it.

17
00:01:36,000 --> 00:01:42,000
Now let's define the allowed containers macro.
[Types: - macro: allowed_containers condition: vault_agent_container or istio_proxy_container]

18
00:01:42,000 --> 00:01:48,000
This combines Vault Agent and Istio Proxy. We use it to exclude legitimate containers from rules.

19
00:01:48,000 --> 00:01:54,000
Now let's write Rule 1. Shell Spawned in Financial RAG Pod. This is our highest priority rule.
[Types: - rule: Shell Spawned in Financial RAG Pod desc: A shell was spawned inside a financial-rag pod. This should never happen in production.]

20
00:01:54,000 --> 00:02:00,000
If a shell spawns in production, someone needs to investigate immediately. This could be a breach in progress.

21
00:02:00,000 --> 00:02:06,000
Now let's define the condition.
[Types: condition: spawned_process and financial_rag_namespace and shell_procs and not vault_agent_container and not istio_proxy_container]

22
00:02:06,000 --> 00:02:12,000
spawned_process means a new process was created. financial_rag_namespace uses our macro. shell_procs is a built-in macro that matches bash, sh, zsh, dash, fish.

23
00:02:12,000 --> 00:02:18,000
The not clauses prevent false positives. Vault Agent sometimes spawns subprocesses. Istio Proxy sometimes spawns subprocesses. We ignore those.

24
00:02:18,000 --> 00:02:24,000
Now let's define the output.
[Types: output: Shell spawned in financial-rag pod (user=%user.name user_uid=%user.uid command=%proc.cmdline pod=%k8s.pod.name container=%container.name namespace=%k8s.ns.name image=%container.image.repository:%container.image.tag)]

25
00:02:24,000 --> 00:02:30,000
The output includes everything a responder needs. The user who ran the command. The exact command. The pod name. The container name. The image. Complete forensic data.

26
00:02:30,000 --> 00:02:36,000
Now let's set the priority.
[Types: priority: CRITICAL tags: [financial-rag, shell, post-exploit, T1059]]

27
00:02:36,000 --> 00:02:42,000
CRITICAL means wake someone up. T1059 is the MITRE ATT&CK technique for command and script interpreter.

28
00:02:42,000 --> 00:02:48,000
Now let's write Rule 2. Unexpected Outbound Connection from Agent Pod.
[Types: - rule: Unexpected Outbound Connection from Agent Pod desc: Agent pod established a connection to an unexpected destination.]

29
00:02:48,000 --> 00:02:54,000
The agent should only talk to pgvector on port 5432. Redis on port 6379. External HTTPS on port 443. Istio sidecars on ports 15001 and 15006.

30
00:02:54,000 --> 00:03:00,000
[Types: condition: outbound and agent_container and not fd.sport in (5432, 6379, 443, 15001, 15006) and not fd.sip = "127.0.0.1"]

31
00:03:00,000 --> 00:03:06,000
If the agent connects to any other port, this rule fires. Even if Cilium blocks it, Falco still alerts. Defense in depth.

32
00:03:06,000 --> 00:03:12,000
[Types: output: Unexpected outbound connection from agent pod (command=%proc.cmdline connection=%fd.name pod=%k8s.pod.name namespace=%k8s.ns.name) priority: HIGH tags: [financial-rag, network, lateral-movement, T1071]]

33
00:03:12,000 --> 00:03:18,000
This catches lateral movement attempts. If an attacker compromises the agent, they might try to connect to other services. Falco catches it.

34
00:03:18,000 --> 00:03:24,000
Now let's write Rule 3. Write Outside Allowed Paths in Financial RAG.
[Types: - rule: Write Outside Allowed Paths in Financial RAG desc: A container wrote to a path outside the allowed writable paths.]

35
00:03:24,000 --> 00:03:30,000
All our containers have readOnlyRootFilesystem: true. They can only write to /tmp, /vault/secrets, /var/run, and /dev/null.

36
00:03:30,000 --> 00:03:36,000
[Types: condition: open_write and financial_rag_namespace and not fd.name startswith "/tmp/" and not fd.name startswith "/vault/secrets/" and not fd.name startswith "/var/run/" and not fd.name startswith "/proc/" and not fd.name = "/dev/null" and not vault_agent_container and not istio_proxy_container]

37
00:03:36,000 --> 00:03:42,000
If a container writes to any other path, this rule fires. This detects container escape attempts. An attacker trying to write to the host filesystem.

38
00:03:42,000 --> 00:03:48,000
[Types: output: Write outside allowed paths (user=%user.name file=%fd.name command=%proc.cmdline pod=%k8s.pod.name container=%container.name) priority: HIGH tags: [financial-rag, filesystem, T1565]]

39
00:03:48,000 --> 00:03:54,000
Now let's write Rule 4. Vault Secret Read by Unexpected Process.
[Types: - rule: Vault Secret Read by Unexpected Process desc: A process other than the application binary read a Vault secret file.]

40
00:03:54,000 --> 00:04:00,000
Vault Agent writes secrets to /vault/secrets/. The application reads them. That is normal behavior. The application is Python. It uses uvicorn or gunicorn to run.

41
00:04:00,000 --> 00:04:06,000
[Types: condition: open_read and financial_rag_namespace and fd.name startswith "/vault/secrets/" and not proc.name in (python3, python, uvicorn, gunicorn, vault) and not vault_agent_container]

42
00:04:06,000 --> 00:04:12,000
If any other process reads from /vault/secrets/, this rule fires. This detects credential theft. An attacker reading your database password from disk.

43
00:04:12,000 --> 00:04:18,000
[Types: output: Unexpected process reading Vault secret (process=%proc.name file=%fd.name pod=%k8s.pod.name container=%container.name) priority: CRITICAL tags: [financial-rag, vault, credential-access, T1552]]

44
00:04:18,000 --> 00:04:24,000
CRITICAL priority. The attacker has accessed your secrets. They may have your database credentials. Immediate action required.

45
00:04:24,000 --> 00:04:30,000
Now let's write Rule 5. Privilege Escalation in Financial RAG Pod.
[Types: - rule: Privilege Escalation in Financial RAG Pod desc: setuid or setgid binary executed in financial-rag namespace.]

46
00:04:30,000 --> 00:04:36,000
setuid and setgid binaries run with elevated privileges. An attacker might try to exploit them to gain root access.

47
00:04:36,000 --> 00:04:42,000
[Types: condition: financial_rag_namespace and evt.type = execve and (proc.is_suid_binary = true or proc.is_sgid_binary = true) and not proc.name in (sudo, ping)]

48
00:04:42,000 --> 00:04:48,000
sudo and ping are common setuid binaries. We exclude them because they are legitimate. Everything else is suspicious.

49
00:04:48,000 --> 00:04:54,000
[Types: output: Privilege escalation attempt (command=%proc.cmdline pod=%k8s.pod.name container=%container.name user=%user.name) priority: CRITICAL tags: [financial-rag, privilege-escalation, T1548]]

50
00:04:54,000 --> 00:05:00,000
Now let's write Rule 6. Crypto Mining Process in Financial RAG.
[Types: - rule: Crypto Mining Process in Financial RAG desc: Known crypto mining process names detected in financial-rag namespace.]

51
00:05:00,000 --> 00:05:06,000
Crypto miners are resource-intensive. They consume CPU and memory. They degrade performance. They increase cloud bills.

52
00:05:06,000 --> 00:05:12,000
[Types: condition: financial_rag_namespace and spawned_process and proc.name in (xmrig, minerd, cpuminer, ethminer, nbminer, phoenix, t-rex, gminer, lolminer, wildrig)]

53
00:05:12,000 --> 00:05:18,000
This detects known crypto mining software by process name. If an attacker installs a miner, Falco catches it immediately.

54
00:05:18,000 --> 00:05:24,000
[Types: output: Crypto mining process detected (process=%proc.name pod=%k8s.pod.name container=%container.name args=%proc.args) priority: CRITICAL tags: [financial-rag, crypto-mining, T1496]]

55
00:05:24,000 --> 00:05:30,000
Now let's write Rule 7. kubectl exec in Financial RAG Namespace.
[Types: - rule: kubectl exec in Financial RAG Namespace desc: kubectl exec was used to attach to a financial-rag pod.]

56
00:05:30,000 --> 00:05:36,000
This rule uses the Kubernetes audit log. It detects when someone runs kubectl exec to enter a pod.

57
00:05:36,000 --> 00:05:42,000
[Types: condition: ka.verb = "create" and ka.target.resource = "pods/exec" and ka.target.namespace = "financial-rag"]

58
00:05:42,000 --> 00:05:48,000
The priority is WARNING, not CRITICAL. kubectl exec is permitted via approved runbook with MFA. This rule creates an audit trail.

59
00:05:48,000 --> 00:05:54,000
[Types: output: kubectl exec into financial-rag pod (user=%ka.user.name pod=%ka.target.name namespace=%ka.target.namespace command=%ka.uri.param[command]) priority: WARNING tags: [financial-rag, exec, audit, CC6.1]]

60
00:05:54,000 --> 00:06:00,000
CC6.1 is the SOC2 control for privileged access. This rule provides evidence for SOC2 audits.

61
00:06:00,000 --> 00:06:06,000
Now let's write Rule 8. Read Process Environment in Financial RAG.
[Types: - rule: Read Process Environment in Financial RAG desc: A process read another process's environment variables via /proc.]

62
00:06:06,000 --> 00:06:12,000
Processes store environment variables in /proc/*/environ. This includes secrets. API keys. Database passwords.

63
00:06:12,000 --> 00:06:18,000
[Types: condition: open_read and financial_rag_namespace and fd.name glob "/proc/*/environ" and not proc.name in (ps, top, htop)]

64
00:06:18,000 --> 00:06:24,000
ps, top, and htop are legitimate tools. They sometimes read /proc. We exclude them.

65
00:06:24,000 --> 00:06:30,000
[Types: output: Process environment read (possible credential harvest) (command=%proc.cmdline file=%fd.name pod=%k8s.pod.name) priority: HIGH tags: [financial-rag, credential-access, T1082]]

66
00:06:30,000 --> 00:06:36,000
Now let's save the file and deploy the rules.

67
00:06:36,000 --> 00:06:42,000
[Types: kubectl create configmap falco-financial-rag-rules --namespace kube-system --from-file=financial_rag_rules.yaml=falco/rules/financial_rag_rules.yaml]

68
00:06:42,000 --> 00:06:48,000
This creates a ConfigMap with our custom rules. Falco will load this ConfigMap.

69
00:06:48,000 --> 00:06:54,000
Now let's verify the rules are loaded.
[Types: kubectl exec -n kube-system $(kubectl get pods -n kube-system -l app.kubernetes.io/name=falco -o name | head -1) -- falco -l 2>/dev/null | grep "financial-rag"]

70
00:06:54,000 --> 00:07:00,000
You should see all eight rules. Shell Spawned. Unexpected Outbound Connection. Vault Secret Read. All of them.

71
00:07:00,000 --> 00:07:06,000
Now let's recap what we've built in Part 2.

72
00:07:06,000 --> 00:07:12,000
We defined eight custom rules covering the financial RAG threat model. Shell spawning. Unexpected outbound connections. Filesystem writes outside allowed paths. Vault secret reads by unexpected processes.

73
00:07:12,000 --> 00:07:18,000
Privilege escalation. Crypto mining. kubectl exec audit. Process environment reads.

74
00:07:18,000 --> 00:07:24,000
We learned the anatomy of a Falco rule. Name. Description. Condition. Output. Priority. Tags.

75
00:07:24,000 --> 00:07:30,000
We deployed rules via ConfigMap. Falco is now monitoring for these specific threats.

76
00:07:30,000 --> 00:07:36,000
In Part 3, we integrate Falco with Prometheus and Falcosidekick. We create alerts for critical events.

77
00:07:36,000 --> 00:07:42,000
Thank you for watching. I'll see you in Part 3.

78
00:07:42,000 --> 00:07:46,000
[End of Part 2]

1
00:00:00,000 --> 00:00:06,000
Welcome back to Phase 10. In Part 3, we build the Falcosidekick and alerting pipeline.

2
00:00:06,000 --> 00:00:12,000
We have Falco installed. We have eight custom rules detecting threats. But detection is not enough. We need to route alerts to the right people.

3
00:00:12,000 --> 00:00:18,000
Think of it this way. Falco is the security camera. It sees everything. But a camera is useless if no one watches the footage.

4
00:00:18,000 --> 00:00:24,000
Falcosidekick is the security guard. It watches the footage and alerts the right people when something happens. It routes alerts to Slack, PagerDuty, and CloudWatch.

5
00:00:24,000 --> 00:00:30,000
Open your editor and create `falco/sidekick/falcosidekick-values.yaml`.

6
00:00:30,000 --> 00:00:36,000
We'll start with the replica count. This ensures high availability.
[Types: replicaCount: 2]

7
00:00:36,000 --> 00:00:42,000
Two replicas means we have redundancy. If one pod fails, the other continues routing alerts.

8
00:00:42,000 --> 00:00:48,000
Now the image configuration.
[Types: image: repository: falcosecurity/falcosidekick tag: "2.28.0"]

9
00:00:48,000 --> 00:00:54,000
We use the official Falcosidekick image. Version 2.28.0 is stable and well-tested.

10
00:00:54,000 --> 00:01:00,000
Now the config section. This is where we define where alerts go.
[Types: config:]

11
00:01:00,000 --> 00:01:06,000
First, Slack configuration. This is where most alerts will go.
[Types: slack: webhookurl: ""]

12
00:01:06,000 --> 00:01:12,000
The webhookurl is set via environment variable. We'll pass it at install time.

13
00:01:12,000 --> 00:01:18,000
[Types: channel: "#security-alerts"]

14
00:01:18,000 --> 00:01:24,000
The channel is #security-alerts. This is where the security team monitors.

15
00:01:24,000 --> 00:01:30,000
[Types: iconemoji: ":rotating_light:"]

16
00:01:30,000 --> 00:01:36,000
The iconemoji adds a rotating light emoji. This makes alerts stand out.

17
00:01:36,000 --> 00:01:42,000
[Types: username: "Falco | financial-rag"]

18
00:01:42,000 --> 00:01:48,000
The username identifies the source of the alert. The team knows it's from Falco.

19
00:01:48,000 --> 00:01:54,000
[Types: outputformat: "all"]

20
00:01:54,000 --> 00:02:00,000
outputformat: all includes all fields in the alert. This gives full context.

21
00:02:00,000 --> 00:02:06,000
[Types: minimumpriority: "warning"]

22
00:02:06,000 --> 00:02:12,000
We only send warnings and above to Slack. This reduces noise from lower priority events.

23
00:02:12,000 --> 00:02:18,000
[Types: messageformat: | *{{ .Rule }}* | Priority: {{ .Priority }} | Pod: {{ .OutputFields.k8s_pod_name }}]

24
00:02:18,000 --> 00:02:24,000
The message format is custom. It shows the rule name, priority, and pod name.
This is enough to start investigating.

25
00:02:24,000 --> 00:02:30,000
Now PagerDuty configuration. This is for critical alerts that need immediate attention.
[Types: pagerduty: routingkey: ""]

26
00:02:30,000 --> 00:02:36,000
The routing key is set via environment variable. We'll pass it at install time.

27
00:02:36,000 --> 00:02:42,000
[Types: minimumpriority: "critical"]

28
00:02:42,000 --> 00:02:48,000
Only critical alerts go to PagerDuty. We don't want to wake someone up for warnings.

29
00:02:48,000 --> 00:02:54,000
[Types: region: "us"]

30
00:02:54,000 --> 00:03:00,000
The region is us. This matches our AWS region.

31
00:03:00,000 --> 00:03:06,000
Now CloudWatch configuration. This is for audit and compliance.
[Types: aws: cloudwatchlogs: loggroup: "/aws/falco/financial-rag"]

32
00:03:06,000 --> 00:03:12,000
All events go to CloudWatch. This is our audit trail. SOC2 auditors can review these logs.

33
00:03:12,000 --> 00:03:18,000
[Types: logstream: ""]

34
00:03:18,000 --> 00:03:24,000
The logstream is auto-generated per instance. This keeps logs organized.

35
00:03:24,000 --> 00:03:30,000
[Types: minimumpriority: "warning"]

36
00:03:30,000 --> 00:03:36,000
Warnings and above go to CloudWatch. This captures all important events.

37
00:03:36,000 --> 00:03:42,000
[Types: region: "us-east-1"]

38
00:03:42,000 --> 00:03:48,000
The region is us-east-1. This is where our CloudWatch logs are stored.

39
00:03:48,000 --> 00:03:54,000
Now the Prometheus configuration. This exposes metrics for Prometheus to scrape.
[Types: prometheus: extralabels: ""]

40
00:03:54,000 --> 00:04:00,000
No extra labels. We use the default labels from Falco.

41
00:04:00,000 --> 00:04:06,000
Now the resources section. This defines CPU and memory limits.
[Types: resources: requests: cpu: 50m memory: 64Mi]

42
00:04:06,000 --> 00:04:12,000
Falcosidekick is lightweight. 50 millicpu and 64 megabytes of memory is enough.

43
00:04:12,000 --> 00:04:18,000
[Types: limits: cpu: 200m memory: 256Mi]

44
00:04:18,000 --> 00:04:24,000
Limits are higher to handle burst traffic. 200 millicpu and 256 megabytes.

45
00:04:24,000 --> 00:04:30,000
Now the ServiceMonitor. This tells Prometheus to scrape Falcosidekick metrics.
[Types: serviceMonitor: enabled: true]

46
00:04:30,000 --> 00:04:36,000
The ServiceMonitor is enabled. Prometheus will scrape metrics.

47
00:04:36,000 --> 00:04:42,000
[Types: labels: release: kube-prometheus-stack]

48
00:04:42,000 --> 00:04:48,000
The release label must match the Prometheus Operator's label selector.

49
00:04:48,000 --> 00:04:54,000
Now the affinity. This ensures high availability.
[Types: affinity: podAntiAffinity: requiredDuringSchedulingIgnoredDuringExecution: - labelSelector: matchLabels: app.kubernetes.io/name: falcosidekick topologyKey: kubernetes.io/hostname]

50
00:04:54,000 --> 00:05:00,000
podAntiAffinity ensures the two replicas run on different nodes. If one node fails, the other replica is still running.

51
00:05:00,000 --> 00:05:06,000
Now let's create the Prometheus alerts. Open `observability/prometheus-rules/financial-rag-alerts.yaml`.

52
00:05:06,000 --> 00:05:12,000
[Types: apiVersion: monitoring.coreos.com/v1 kind: PrometheusRule]

53
00:05:12,000 --> 00:05:18,000
PrometheusRule is a CRD for defining alerting rules. It's managed by the Prometheus Operator.

54
00:05:18,000 --> 00:05:24,000
[Types: metadata: name: financial-rag-alerts namespace: monitoring]

55
00:05:24,000 --> 00:05:30,000
The PrometheusRule lives in the monitoring namespace. This is where Prometheus Operator watches for rules.

56
00:05:30,000 --> 00:05:36,000
[Types: labels: release: kube-prometheus-stack app: financial-rag-agent]

57
00:05:36,000 --> 00:05:42,000
The release label must match the Prometheus Operator's label selector.

58
00:05:42,000 --> 00:05:48,000
Now the spec. This defines the alerting rules.
[Types: spec: groups: - name: financial-rag.api interval: 30s]

59
00:05:48,000 --> 00:05:54,000
The api group contains alerts for the API service. It runs every 30 seconds.

60
00:05:54,000 --> 00:06:00,000
[Types: rules: - alert: APIHighErrorRate]

61
00:06:00,000 --> 00:06:06,000
This alert triggers when the API error rate is high.

62
00:06:06,000 --> 00:06:12,000
[Types: expr: | ( sum(rate(http_requests_total{namespace="financial-rag",component="api",status=~"5.."}[5m])) / sum(rate(http_requests_total{namespace="financial-rag",component="api"}[5m])) ) > 0.05]

63
00:06:12,000 --> 00:06:18,000
The expression calculates the error rate. It divides 5xx responses by total responses.
If the rate exceeds 5%, the alert fires.

64
00:06:18,000 --> 00:06:24,000
[Types: for: 2m]

65
00:06:24,000 --> 00:06:30,000
The alert must be true for 2 minutes before firing. This prevents false positives.

66
00:06:30,000 --> 00:06:36,000
[Types: labels: severity: critical team: platform project: financial-rag]

67
00:06:36,000 --> 00:06:42,000
The labels define who to page. Critical severity pages the platform team.

68
00:06:42,000 --> 00:06:48,000
[Types: annotations: summary: "API error rate above 5%" description: "financial-rag API error rate is {{ $value | humanizePercentage }} over the last 5 minutes. SLO breach imminent."]

69
00:06:48,000 --> 00:06:54,000
The annotations provide context. The summary is short. The description explains the impact.

70
00:06:54,000 --> 00:07:00,000
Now let's add the Falco critical event alert.
[Types: - name: financial-rag.security interval: 30s]

71
00:07:00,000 --> 00:07:06,000
The security group contains alerts for security events.

72
00:07:06,000 --> 00:07:12,000
[Types: rules: - alert: FalcoCriticalEventDetected]

73
00:07:12,000 --> 00:07:18,000
This alert triggers when Falco detects a critical event.

74
00:07:18,000 --> 00:07:24,000
[Types: expr: | sum(rate(falco_events_total{namespace="financial-rag",priority="Critical"}[5m])) > 0]

75
00:07:24,000 --> 00:07:30,000
The expression checks if any critical events occurred in the last 5 minutes.

76
00:07:30,000 --> 00:07:36,000
[Types: for: 0m]

77
00:07:36,000 --> 00:07:42,000
for: 0m means the alert fires immediately. Security events need immediate attention.

78
00:07:42,000 --> 00:07:48,000
[Types: labels: severity: critical team: security]

79
00:07:48,000 --> 00:07:54,000
Critical severity pages the security team.

80
00:07:54,000 --> 00:08:00,000
[Types: annotations: summary: "Falco CRITICAL security event in financial-rag" description: "Falco detected a critical security event. Immediate investigation required."]

81
00:08:00,000 --> 00:08:06,000
The annotations tell the security team what happened and what to do.

82
00:08:06,000 --> 00:08:12,000
Now let's add the Cilium drop rate alert.
[Types: - alert: CiliumDropRateHigh]

83
00:08:12,000 --> 00:08:18,000
This alert triggers when Cilium drops many packets. This could indicate a network attack.

84
00:08:18,000 --> 00:08:24,000
[Types: expr: | sum(rate(hubble_drop_total{namespace="financial-rag"}[5m])) > 10]

85
00:08:24,000 --> 00:08:30,000
If more than 10 packets are dropped per second, the alert fires.

86
00:08:30,000 --> 00:08:36,000
[Types: for: 2m]

87
00:08:36,000 --> 00:08:42,000
The alert must be true for 2 minutes before firing.

88
00:08:42,000 --> 00:08:48,000
[Types: labels: severity: warning team: security]

89
00:08:48,000 --> 00:08:54,000
Warning severity notifies the security team.

90
00:08:54,000 --> 00:09:00,000
[Types: annotations: summary: "High Cilium drop rate in financial-rag namespace" description: "{{ $value }} drops/sec in financial-rag. May indicate lateral movement attempt or policy misconfiguration."]

91
00:09:00,000 --> 00:09:06,000
The annotations suggest what might be causing the drops.

92
00:09:06,000 --> 00:09:12,000
Now let's apply these resources.

93
00:09:12,000 --> 00:09:18,000
[Types: kubectl apply -f falco/sidekick/falcosidekick-values.yaml -n kube-system]

94
00:09:18,000 --> 00:09:24,000
This applies the Falcosidekick configuration. The Helm chart will pick it up.

95
00:09:24,000 --> 00:09:30,000
[Types: kubectl apply -f observability/prometheus-rules/financial-rag-alerts.yaml]

96
00:09:30,000 --> 00:09:36,000
This applies the PrometheusRule. Prometheus Operator will pick it up.

97
00:09:36,000 --> 00:09:42,000
Now let's verify Falcosidekick is running.
[Types: kubectl get pods -n kube-system -l app.kubernetes.io/name=falcosidekick]

98
00:09:42,000 --> 00:09:48,000
You should see two pods. Both should be running.

99
00:09:48,000 --> 00:09:54,000
Now let's verify the PrometheusRule.
[Types: kubectl get prometheusrules -n monitoring]

100
00:09:54,000 --> 00:10:00,000
You should see financial-rag-alerts. The rules are loaded.

101
00:10:00,000 --> 00:10:06,000
Now let's test the alerts. Trigger a Falco critical event.

102
00:10:06,000 --> 00:10:12,000
[Types: kubectl run test-shell --image=alpine --namespace=financial-rag --labels="app.kubernetes.io/component=api" --restart=Never -- sleep 600]

103
00:10:12,000 --> 00:10:18,000
This creates a test pod in the financial-rag namespace.

104
00:10:18,000 --> 00:10:24,000
[Types: kubectl exec -n financial-rag test-shell -- /bin/sh -c "echo test"]

105
00:10:24,000 --> 00:10:30,000
This spawns a shell in the pod. Falco should detect it and fire the Shell Spawned rule.

106
00:10:30,000 --> 00:10:36,000
Check Slack. You should see a message from Falco. "Shell spawned in financial-rag pod".

107
00:10:36,000 --> 00:10:42,000
Check PagerDuty. You should see an incident created. The incident title is "Falco critical event".

108
00:10:42,000 --> 00:10:48,000
Check Prometheus alerts. FalcoCriticalEventDetected should be firing.

109
00:10:48,000 --> 00:10:54,000
[Types: kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090]

110
00:10:54,000 --> 00:11:00,000
Open http://localhost:9090/alerts. You should see FalcoCriticalEventDetected.

111
00:11:00,000 --> 00:11:06,000
Now let's clean up the test pod.
[Types: kubectl delete pod test-shell -n financial-rag]

112
00:11:06,000 --> 00:11:12,000
This removes the test pod.

113
00:11:12,000 --> 00:11:18,000
Now let me recap what we've built in Part 3.

114
00:11:18,000 --> 00:11:24,000
We configured Falcosidekick. It routes alerts to Slack, PagerDuty, and CloudWatch.

115
00:11:24,000 --> 00:11:30,000
We created Prometheus alerts. They trigger on high error rates, critical Falco events, and high Cilium drop rates.

116
00:11:30,000 --> 00:11:36,000
We tested the alert pipeline. The critical Falco event triggered Slack, PagerDuty, and Prometheus alerts.

117
00:11:36,000 --> 00:11:42,000
This is the complete alerting pipeline. Detection, routing, and alerting.

118
00:11:42,000 --> 00:11:48,000
In Part 4, we'll build the Falco rules ConfigMap and deploy the Falco daemon.

119
00:11:48,000 --> 00:11:54,000
Thank you for watching. I'll see you in Part 4.

120
00:11:54,000 --> 00:11:58,000
[End of Part 3]

1
00:00:00,000 --> 00:00:06,000
Welcome back to Phase 10. In Part 4, we configure Falcosidekick to route alerts to the right places.

2
00:00:06,000 --> 00:00:12,000
Falco detects threats. But detection without action is useless. You need to know when a threat is detected. You need alerts to reach the right people.

3
00:00:12,000 --> 00:00:18,000
Think of Falcosidekick as the dispatch center. When Falco detects a threat, it sends an alert to Falcosidekick. Falcosidekick routes that alert to the right destination.

4
00:00:18,000 --> 00:00:24,000
Slack for team visibility. PagerDuty for critical alerts. CloudWatch for audit trail. Each destination serves a different purpose.

5
00:00:24,000 --> 00:00:30,000
Open your editor and create `falco/sidekick/falcosidekick-values.yaml`.

6
00:00:30,000 --> 00:00:36,000
We'll start with the replica count. High availability is critical for security alerts.
[Types: replicaCount: 2]

7
00:00:36,000 --> 00:00:42,000
Two replicas means if one fails, the other continues routing alerts. No single point of failure.

8
00:00:42,000 --> 00:00:48,000
Now the image configuration.
[Types: image: repository: falcosecurity/falcosidekick tag: "2.28.0"]

9
00:00:48,000 --> 00:00:54,000
We use the official Falcosidekick image. Version 2.28.0 is stable and well-tested.

10
00:00:54,000 --> 00:01:00,000
Now the config section. This is where we define where alerts go.
[Types: config:]

11
00:01:00,000 --> 00:01:06,000
First, Slack configuration. Slack is for team visibility.
[Types: slack: webhookurl: ""]

12
00:01:06,000 --> 00:01:12,000
The webhookurl is set via `--set falcosidekick.config.slack.webhookurl=$SLACK_WEBHOOK`.
We don't hardcode it here. It comes from a secret.

13
00:01:12,000 --> 00:01:18,000
[Types: channel: "#security-alerts"]

14
00:01:18,000 --> 00:01:24,000
The channel is #security-alerts. This is where the security team monitors alerts.

15
00:01:24,000 --> 00:01:30,000
[Types: iconemoji: ":rotating_light:"]

16
00:01:30,000 --> 00:01:36,000
The emoji makes the alert stand out in Slack. You immediately know it's a security alert.

17
00:01:36,000 --> 00:01:42,000
[Types: username: "Falco | financial-rag"]

18
00:01:42,000 --> 00:01:48,000
The username identifies the source. You know it's Falco from the financial-rag namespace.

19
00:01:48,000 --> 00:01:54,000
[Types: outputformat: "all"]

20
00:01:54,000 --> 00:02:00,000
outputformat: "all" includes all available fields. This gives the security team
complete context.

21
00:02:00,000 --> 00:02:06,000
[Types: minimumpriority: "warning"]

22
00:02:06,000 --> 00:02:12,000
Only alerts at WARNING or higher are sent to Slack. This reduces noise.
INFO level events are logged but not alerted.

23
00:02:12,000 --> 00:02:18,000
[Types: messageformat: '*{{ .Rule }}* | Priority: {{ .Priority }} | Pod: {{ .OutputFields.k8s_pod_name }}']

24
00:02:18,000 --> 00:02:24,000
This is the message format that appears in Slack. It's concise and actionable.
The rule name, priority, and pod name. Everything you need to investigate.

25
00:02:24,000 --> 00:02:30,000
Now PagerDuty configuration. PagerDuty is for critical alerts that need immediate action.
[Types: pagerduty: routingkey: ""]

26
00:02:30,000 --> 00:02:36,000
The routingkey is set via `--set falcosidekick.config.pagerduty.routingkey=$PAGERDUTY_PROD_KEY`.
It comes from a secret.

27
00:02:36,000 --> 00:02:42,000
[Types: minimumpriority: "critical"]

28
00:02:42,000 --> 00:02:48,000
Only CRITICAL alerts go to PagerDuty. These are the alerts that wake someone up.
Shell spawning. Vault secret theft. Privilege escalation. Crypto mining.

29
00:02:48,000 --> 00:02:54,000
[Types: region: "us"]

30
00:02:54,000 --> 00:03:00,000
The PagerDuty region. US is the default. This configures the API endpoint.

31
00:03:00,000 --> 00:03:06,000
Now CloudWatch configuration. CloudWatch is for audit and compliance.
[Types: aws: cloudwatchlogs: loggroup: "/aws/falco/financial-rag"]

32
00:03:06,000 --> 00:03:12,000
The log group is /aws/falco/financial-rag. All alerts are stored here for audit.

33
00:03:12,000 --> 00:03:18,000
[Types: logstream: ""]

34
00:03:18,000 --> 00:03:24,000
The logstream is auto-generated per instance. This prevents conflicts between replicas.

35
00:03:24,000 --> 00:03:30,000
[Types: minimumpriority: "warning"]

36
00:03:30,000 --> 00:03:36,000
All WARNING and above alerts go to CloudWatch. This creates a complete audit trail.

37
00:03:36,000 --> 00:03:42,000
[Types: region: "us-east-1"]

38
00:03:42,000 --> 00:03:48,000
The AWS region. us-east-1 is where our logs are stored.

39
00:03:48,000 --> 00:03:54,000
Now resources. Falcosidekick is lightweight.
[Types: resources: requests: cpu: 50m memory: 64Mi limits: cpu: 200m memory: 256Mi]

40
00:03:54,000 --> 00:04:00,000
50 millicpu and 64 megabytes of memory. This is very small. Falcosidekick just routes alerts.
It doesn't do heavy processing.

41
00:04:00,000 --> 00:04:06,000
Now ServiceMonitor for Prometheus.
[Types: serviceMonitor: enabled: true labels: release: kube-prometheus-stack]

42
00:04:06,000 --> 00:04:12,000
The ServiceMonitor tells Prometheus to scrape Falcosidekick metrics.
The label matches the Prometheus Operator selector.

43
00:04:12,000 --> 00:04:18,000
Now affinity for high availability.
[Types: affinity: podAntiAffinity: requiredDuringSchedulingIgnoredDuringExecution: - labelSelector: matchLabels: app.kubernetes.io/name: falcosidekick topologyKey: kubernetes.io/hostname]

44
00:04:18,000 --> 00:04:24,000
podAntiAffinity ensures replicas are scheduled on different nodes.
If one node fails, the other replica is still running.

45
00:04:24,000 --> 00:04:30,000
Now let's install Falcosidekick with these values.

46
00:04:30,000 --> 00:04:36,000
[Types: helm upgrade --install falco falcosecurity/falco --namespace kube-system -f falco/config/falco-helm-values.yaml -f falco/sidekick/falcosidekick-values.yaml --set falcosidekick.config.slack.webhookurl="${SLACK_SECURITY_WEBHOOK}" --set falcosidekick.config.pagerduty.routingkey="${PAGERDUTY_PROD_KEY}"]

47
00:04:36,000 --> 00:04:42,000
This installs Falco with the Falcosidekick configuration. The webhook URL and routing key are passed as environment variables.

48
00:04:42,000 --> 00:04:48,000
Now let's verify Falcosidekick is running.
[Types: kubectl get pods -n kube-system -l app.kubernetes.io/name=falcosidekick]

49
00:04:48,000 --> 00:04:54,000
You should see two replicas. Both should be Running. This confirms HA is working.

50
00:04:54,000 --> 00:05:00,000
Now let's test the alert routing. Trigger a shell spawn.

51
00:05:00,000 --> 00:05:06,000
[Types: kubectl run test-shell --image=alpine --namespace=financial-rag --labels="app.kubernetes.io/component=api" --restart=Never -- sleep 600 kubectl exec -n financial-rag test-shell -- /bin/sh -c "echo test"]

52
00:05:06,000 --> 00:05:12,000
This triggers Rule 1. Shell Spawned in Financial RAG Pod. The alert should be routed.

53
00:05:12,000 --> 00:05:18,000
Check Slack. You should see a message. "*Shell Spawned in Financial RAG Pod* | Priority: CRITICAL | Pod: test-shell"

54
00:05:18,000 --> 00:05:24,000
The alert is in the #security-alerts channel. The security team can see it immediately.

55
00:05:24,000 --> 00:05:30,000
Check PagerDuty. You should see an incident. "Falco critical event: Shell Spawned in Financial RAG Pod"

56
00:05:30,000 --> 00:05:36,000
The on-call engineer gets a push notification. They can start investigating.

57
00:05:36,000 --> 00:05:42,000
Check CloudWatch. You should see the alert in the log group.
[Types: aws logs describe-log-groups --log-group-name-prefix /aws/falco]

58
00:05:42,000 --> 00:05:48,000
The log group exists. The alert is stored for audit.

59
00:05:48,000 --> 00:05:54,000
Now let me explain the importance of minimumpriority. This is the most important
configuration setting.

60
00:05:54,000 --> 00:06:00,000
If you set minimumpriority to "info", you get every alert. Your Slack channel
will be flooded. You'll ignore the alerts. This is alert fatigue.

61
00:06:00,000 --> 00:06:06,000
If you set minimumpriority to "critical", you only get the most important alerts.
But you might miss issues that are WARNING level.

62
00:06:06,000 --> 00:06:12,000
Our configuration balances these. Slack gets WARNING and above. This gives the team
visibility. PagerDuty gets only CRITICAL. This pages people only for emergencies.

63
00:06:12,000 --> 00:06:18,000
CloudWatch gets WARNING and above. This creates a complete audit trail.
Every alert is stored. Nothing is lost.

64
00:06:18,000 --> 00:06:24,000
Now let me show you the full Falcosidekick values file. This is what you should have.

65
00:06:24,000 --> 00:06:30,000
replicaCount: 2
image:
  repository: falcosecurity/falcosidekick
  tag: "2.28.0"
config:
  slack:
    webhookurl: ""
    channel: "#security-alerts"
    iconemoji: ":rotating_light:"
    username: "Falco | financial-rag"
    outputformat: "all"
    minimumpriority: "warning"
    messageformat: '*{{ .Rule }}* | Priority: {{ .Priority }} | Pod: {{ .OutputFields.k8s_pod_name }}'
  pagerduty:
    routingkey: ""
    minimumpriority: "critical"
    region: "us"
  aws:
    cloudwatchlogs:
      loggroup: "/aws/falco/financial-rag"
      logstream: ""
      minimumpriority: "warning"
      region: "us-east-1"
resources:
  requests:
    cpu: 50m
    memory: 64Mi
  limits:
    cpu: 200m
    memory: 256Mi
serviceMonitor:
  enabled: true
  labels:
    release: kube-prometheus-stack
affinity:
  podAntiAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchLabels:
            app.kubernetes.io/name: falcosidekick
        topologyKey: kubernetes.io/hostname

66
00:06:30,000 --> 00:06:36,000
This is the complete file. You should have this in your editor.

67
00:06:36,000 --> 00:06:42,000
Now let me give you a tip. The Slack webhook URL should be stored in a Kubernetes secret.
Never hardcode it in the values file. Use the --set flag to pass it from a secret.

68
00:06:42,000 --> 00:06:48,000
The same applies to the PagerDuty routing key. These are sensitive credentials.
They should be injected at deploy time.

69
00:06:48,000 --> 00:06:54,000
In CI/CD, you can use GitHub secrets. In manual deployment, you can use environment variables.
The command we used shows this pattern.

70
00:06:54,000 --> 00:07:00,000
Now let me recap what we've built in Part 4.

71
00:07:00,000 --> 00:07:06,000
We configured Falcosidekick with three destinations. Slack for team visibility.
PagerDuty for critical alerts. CloudWatch for audit trail.

72
00:07:06,000 --> 00:07:12,000
We set minimumpriority for each destination. Slack gets WARNING and above.
PagerDuty gets only CRITICAL. CloudWatch gets WARNING and above.

73
00:07:12,000 --> 00:07:18,000
We enabled high availability with two replicas and podAntiAffinity.
We tested the alert routing. The alerts reached Slack, PagerDuty, and CloudWatch.

74
00:07:18,000 --> 00:07:24,000
In Part 5, we'll configure the Prometheus alerts. This will trigger PagerDuty
based on Prometheus metrics.

75
00:07:24,000 --> 00:07:30,000
Thank you for watching. I'll see you in Part 5.

76
00:07:30,000 --> 00:07:34,000
[End of Part 4]

1
00:00:00,000 --> 00:00:06,000
Welcome back to Phase 10. In Part 5, we build the Prometheus alerts for security monitoring.

2
00:00:06,000 --> 00:00:12,000
We have Falco detecting security events. We have Falcosidekick routing alerts.
Now we need Prometheus alerts that fire when security events occur.

3
00:00:12,000 --> 00:00:18,000
Think of it this way. Falco is the security camera. Falcosidekick is the security guard
who watches the camera. Prometheus alerts are the alarm system that notifies you
when something happens.

4
00:00:18,000 --> 00:00:24,000
Open your editor and create `observability/prometheus-rules/financial-rag-alerts.yaml`.

5
00:00:24,000 --> 00:00:30,000
We'll start with the apiVersion. monitoring.coreos.com/v1 is the stable version.
[Types: apiVersion: monitoring.coreos.com/v1]

6
00:00:30,000 --> 00:00:36,000
Now the kind.
[Types: kind: PrometheusRule]

7
00:00:36,000 --> 00:00:42,000
PrometheusRule defines alerting rules. It's a custom resource that the Prometheus
Operator watches for.

8
00:00:42,000 --> 00:00:48,000
Now the metadata.
[Types: metadata: name: financial-rag-alerts namespace: monitoring]

9
00:00:48,000 --> 00:00:54,000
The PrometheusRule lives in the monitoring namespace. This is where Prometheus
Operator looks for rules.

10
00:00:54,000 --> 00:01:00,000
[Types: labels: release: kube-prometheus-stack app: financial-rag-agent]

11
00:01:00,000 --> 00:01:06,000
The release label is critical. It must match the Prometheus Operator's label selector.
app: financial-rag-agent helps identify our rules.

12
00:01:06,000 --> 00:01:12,000
Now the spec. This defines the alert groups.
[Types: spec: groups:]

13
00:01:12,000 --> 00:01:18,000
Each group is a collection of rules. Groups are evaluated independently.

14
00:01:18,000 --> 00:01:24,000
Now let's define the API availability group.
[Types: - name: financial-rag.api interval: 30s rules:]

15
00:01:24,000 --> 00:01:30,000
The API group has a 30-second evaluation interval. Rules are checked every 30 seconds.

16
00:01:30,000 --> 00:01:36,000
Now let's define the high error rate alert.
[Types: - alert: APIHighErrorRate expr: ( sum(rate(http_requests_total{namespace="financial-rag",component="api",status=~"5.."}[5m])) / sum(rate(http_requests_total{namespace="financial-rag",component="api"}[5m])) ) > 0.05 for: 2m]

17
00:01:36,000 --> 00:01:42,000
This alert fires when the error rate exceeds 5% for 2 minutes.
The expr calculates the ratio of 5xx responses to total responses over 5 minutes.

18
00:01:42,000 --> 00:01:48,000
[Types: labels: severity: critical team: platform project: financial-rag]

19
00:01:48,000 --> 00:01:54,000
The labels define who to notify. severity: critical means this is a critical alert.
team: platform means the platform team is responsible.

20
00:01:54,000 --> 00:02:00,000
[Types: annotations: summary: "API error rate above 5%" description: "financial-rag API error rate is {{ $value | humanizePercentage }} over the last 5 minutes. SLO breach imminent." runbook: "https://github.com/aayostem/financial-rag-agent/docs/runbooks/api-errors.md"]

21
00:02:00,000 --> 00:02:06,000
The annotations provide context. summary is a short description. description provides
details with the actual value. runbook links to documentation.

22
00:02:06,000 --> 00:02:12,000
Now let's define the high latency alert.
[Types: - alert: APIHighLatency expr: histogram_quantile(0.99, sum by (le) (rate(http_request_duration_seconds_bucket{namespace="financial-rag",component="api",path=~"/query.*"}[5m])) ) > 120 for: 5m]

23
00:02:12,000 --> 00:02:18,000
This alert fires when P99 latency exceeds 120 seconds for 5 minutes.
The expr calculates the 99th percentile of query latency.

24
00:02:18,000 --> 00:02:24,000
[Types: labels: severity: warning team: platform]

25
00:02:24,000 --> 00:02:30,000
This is a warning, not critical. High latency is bad but not as urgent as errors.

26
00:02:30,000 --> 00:02:36,000
[Types: annotations: summary: "API P99 query latency above 120s" description: "P99 query latency is {{ $value }}s. Expected < 120s (LLM pipeline SLO)."]

27
00:02:36,000 --> 00:02:42,000
The description explains what the value is and what the expected value should be.

28
00:02:42,000 --> 00:02:48,000
Now let's define the API pod crash-looping alert.
[Types: - alert: APIPodCrashLooping expr: rate(kube_pod_container_status_restarts_total{namespace="financial-rag",container="api"}[15m]) * 60 * 15 > 3 for: 5m]

29
00:02:48,000 --> 00:02:54,000
This alert fires when the API pod restarts more than 3 times in 15 minutes.
The expr calculates the restart rate and multiplies by the window length.

30
00:02:54,000 --> 00:03:00,000
[Types: labels: severity: critical]

31
00:03:00,000 --> 00:03:06,000
Pod crash-looping is critical. The API is down and cannot recover.

32
00:03:06,000 --> 00:03:12,000
[Types: annotations: summary: "API pod crash-looping" description: "Pod {{ $labels.pod }} has restarted {{ $value }} times in 15 minutes."]

33
00:03:12,000 --> 00:03:18,000
The description includes the pod name and the restart count.

34
00:03:18,000 --> 00:03:24,000
Now let's define the HPA at max replicas alert.
[Types: - alert: APIHPAMaxReplicas expr: kube_horizontalpodautoscaler_status_current_replicas{namespace="financial-rag",horizontalpodautoscaler="financial-rag-agent-api"} >= kube_horizontalpodautoscaler_spec_max_replicas{namespace="financial-rag",horizontalpodautoscaler="financial-rag-agent-api"} for: 10m]

35
00:03:24,000 --> 00:03:30,000
This alert fires when the HPA is at max replicas for 10 minutes.
This indicates that the application is at its scaling limit.

36
00:03:30,000 --> 00:03:36,000
[Types: labels: severity: warning]

37
00:03:36,000 --> 00:03:42,000
This is a warning. The application is working but cannot scale further.

38
00:03:42,000 --> 00:03:48,000
[Types: annotations: summary: "API HPA at maximum replicas" description: "API HPA has been at maxReplicas for 10 minutes — scale limit may be causing latency."]

39
00:03:48,000 --> 00:03:54,000
Now let's define the LLM token usage alert.
[Types: - name: financial-rag.llm interval: 60s rules: - alert: LLMHighTokenUsage expr: avg(financial_rag_llm_tokens_input_per_query) > 4500 for: 10m]

40
00:03:54,000 --> 00:04:00,000
This alert fires when average input tokens exceed 4500 for 10 minutes.
High token usage means longer processing time and higher costs.

41
00:04:00,000 --> 00:04:06,000
[Types: labels: severity: warning team: finops]

42
00:04:06,000 --> 00:04:12,000
This is a FinOps alert. The finance team should be aware of rising costs.

43
00:04:12,000 --> 00:04:18,000
[Types: annotations: summary: "LLM average context window above 4,500 tokens" description: "Average input tokens per query: {{ $value }}. Retrieval pipeline may be over-fetching. Check RRF top-k setting."]

44
00:04:18,000 --> 00:04:24,000
Now let's define the LLM provider errors alert.
[Types: - alert: LLMProviderErrors expr: sum(rate(financial_rag_llm_api_errors_total[5m])) > 0.1 for: 2m]

45
00:04:24,000 --> 00:04:30,000
This alert fires when LLM API errors exceed 0.1 per second for 2 minutes.
This could indicate an API key issue or provider outage.

46
00:04:30,000 --> 00:04:36,000
[Types: labels: severity: critical]

47
00:04:36,000 --> 00:04:42,000
LLM provider errors are critical. Without the LLM, the application cannot function.

48
00:04:42,000 --> 00:04:48,000
[Types: annotations: summary: "LLM API errors detected" description: "LLM API error rate: {{ $value }} errors/sec. Check API key validity and provider status."]

49
00:04:48,000 --> 00:04:54,000
Now let's define the semantic cache hit rate alert.
[Types: - alert: SemanticCacheHitRateLow expr: ( sum(rate(financial_rag_cache_hits_total[30m])) / sum(rate(financial_rag_cache_requests_total[30m])) ) < 0.75 for: 30m]

50
00:04:54,000 --> 00:05:00,000
This alert fires when the cache hit rate drops below 75% for 30 minutes.
A low hit rate means more LLM calls and higher costs.

51
00:05:00,000 --> 00:05:06,000
[Types: labels: severity: warning team: finops]

52
00:05:06,000 --> 00:05:12,000
This is another FinOps alert. Cache efficiency is important for cost control.

53
00:05:12,000 --> 00:05:18,000
[Types: annotations: summary: "Semantic cache hit rate below 75%" description: "Cache hit rate: {{ $value | humanizePercentage }}. LLM costs rising — review cache TTL and similarity threshold."]

54
00:05:18,000 --> 00:05:24,000
Now let's define the security alerts group.
[Types: - name: financial-rag.security interval: 30s rules: - alert: FalcoCriticalEventDetected expr: sum(rate(falco_events_total{namespace="financial-rag",priority="Critical"}[5m])) > 0 for: 0m]

55
00:05:24,000 --> 00:05:30,000
This alert fires immediately when a critical Falco event is detected.
for: 0m means there's no delay. Security events need immediate attention.

56
00:05:30,000 --> 00:05:36,000
[Types: labels: severity: critical team: security]

57
00:05:36,000 --> 00:05:42,000
Security team is notified immediately. This is a critical severity alert.

58
00:05:42,000 --> 00:05:48,000
[Types: annotations: summary: "Falco CRITICAL security event in financial-rag" description: "Falco detected a critical security event. Immediate investigation required." runbook: "https://github.com/aayostem/financial-rag-agent/docs/runbooks/security-incident.md"]

59
00:05:48,000 --> 00:05:54,000
The runbook link provides the response procedure. The security team knows exactly
what to do.

60
00:05:54,000 --> 00:06:00,000
Now let's define the Cilium drop rate alert.
[Types: - alert: CiliumDropRateHigh expr: sum(rate(hubble_drop_total{namespace="financial-rag"}[5m])) > 10 for: 2m]

61
00:06:00,000 --> 00:06:06,000
This alert fires when Cilium drops more than 10 packets per second for 2 minutes.
High drop rates could indicate a network policy violation or attack.

62
00:06:06,000 --> 00:06:12,000
[Types: labels: severity: warning team: security]

63
00:06:12,000 --> 00:06:18,000
[Types: annotations: summary: "High Cilium drop rate in financial-rag namespace" description: "{{ $value }} drops/sec in financial-rag. May indicate lateral movement attempt or policy misconfiguration."]

64
00:06:18,000 --> 00:06:24,000
Now let's define the Vault token renewal failure alert.
[Types: - alert: VaultTokenRenewalFailure expr: sum(rate(financial_rag_vault_token_renewal_errors_total[5m])) > 0 for: 1m]

65
00:06:24,000 --> 00:06:30,000
This alert fires when Vault token renewal fails. Pods cannot get new secrets.
They will eventually lose access to the database.

66
00:06:30,000 --> 00:06:36,000
[Types: labels: severity: critical team: security]

67
00:06:36,000 --> 00:06:42,000
[Types: annotations: summary: "Vault token renewal failing" description: "Pods cannot renew Vault tokens — secrets will expire causing application failures."]

68
00:06:42,000 --> 00:06:48,000
Now let's apply the PrometheusRule.
[Types: kubectl apply -f observability/prometheus-rules/financial-rag-alerts.yaml]

69
00:06:48,000 --> 00:06:54,000
Wait a few minutes for Prometheus to load the new rules.
[Types: kubectl get prometheusrules -n monitoring]

70
00:06:54,000 --> 00:07:00,000
You should see financial-rag-alerts in the list. This confirms the rule was created.

71
00:07:00,000 --> 00:07:06,000
Now let's verify the alerts in Prometheus.
[Types: kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090]

72
00:07:06,000 --> 00:07:12,000
Open http://localhost:9090/alerts. You should see all the alerts we defined.
They should be inactive (green) if everything is healthy.

73
00:07:12,000 --> 00:07:18,000
Now let me test the Falco alert. Trigger a shell spawn in a test pod.

74
00:07:18,000 --> 00:07:24,000
[Types: kubectl run test-shell --image=alpine --namespace=financial-rag --labels="app.kubernetes.io/component=api" --restart=Never -- sleep 600]

75
00:07:24,000 --> 00:07:30,000
[Types: kubectl exec -n financial-rag test-shell -- /bin/sh -c "echo test"]

76
00:07:30,000 --> 00:07:36,000
Wait 30 seconds for Falco to detect the event. Then check Prometheus alerts.

77
00:07:36,000 --> 00:07:42,000
You should see FalcoCriticalEventDetected firing (red). This confirms the alert works.

78
00:07:42,000 --> 00:07:48,000
[Types: kubectl delete pod test-shell -n financial-rag]

79
00:07:48,000 --> 00:07:54,000
Clean up the test pod. The alert will resolve automatically.

80
00:07:54,000 --> 00:08:00,000
Now let me recap what we've built in Part 5.

81
00:08:00,000 --> 00:08:06,000
We built the API alerts. High error rate, high latency, crash-looping, and HPA at max replicas.

82
00:08:06,000 --> 00:08:12,000
We built the LLM alerts. High token usage, provider errors, and cache hit rate.

83
00:08:12,000 --> 00:08:18,000
We built the security alerts. Falco critical events, Cilium drop rate, and Vault token failures.

84
00:08:18,000 --> 00:08:24,000
Each alert has labels for severity and team. Each alert has annotations for context
and a runbook link.

85
00:08:24,000 --> 00:08:30,000
These alerts integrate with Alertmanager. They route to Slack for warnings and
PagerDuty for critical alerts.

86
00:08:30,000 --> 00:08:36,000
In Part 6, we'll configure the Gitleaks standalone workflow. This catches secrets
in CI before they reach production.

87
00:08:36,000 --> 00:08:42,000
Thank you for watching. I'll see you in Part 6.

88
00:08:42,000 --> 00:08:46,000
[End of Part 5]

1
00:00:00,000 --> 00:00:06,000
Welcome back to Phase 10. In Part 6, we build the Gitleaks standalone workflow.

2
00:00:06,000 --> 00:00:12,000
We already have Gitleaks in our pre-commit hooks. But pre-commit hooks can be bypassed.
Developers can use --no-verify. The standalone workflow provides an additional layer of protection.

3
00:00:12,000 --> 00:00:18,000
Think of it this way. The pre-commit hook is like a security guard at the door.
The standalone workflow is like a security camera that records everything.
Even if someone bypasses the guard, the camera catches them.

4
00:00:18,000 --> 00:00:24,000
Open your editor and create `.github/workflows/gitleaks.yml`.

5
00:00:24,000 --> 00:00:30,000
We'll start with the name. This appears in the GitHub Actions UI.
[Types: name: "Gitleaks Secret Detection"]

6
00:00:30,000 --> 00:00:36,000
Now the on section. This defines when the workflow runs.
[Types: on:]

7
00:00:36,000 --> 00:00:42,000
We run on push to main and develop branches.
[Types: push: branches: [main, develop]]

8
00:00:42,000 --> 00:00:48,000
We run on pull requests targeting main.
[Types: pull_request: branches: [main]]

9
00:00:48,000 --> 00:00:54,000
We run on a weekly schedule. This catches secrets in old commits.
[Types: schedule: - cron: "0 3 * * 1"]

10
00:00:54,000 --> 00:01:00,000
The cron expression runs at 3 AM every Monday. This is when we scan the full history.

11
00:01:00,000 --> 00:01:06,000
We also allow manual triggering. This is useful for debugging.
[Types: workflow_dispatch: inputs: scan-depth: description: "Git log depth to scan (0 = full history)" default: "0"]

12
00:01:06,000 --> 00:01:12,000
The scan-depth input lets us control how much history to scan. 0 means full history.

13
00:01:12,000 --> 00:01:18,000
Now the permissions section. This defines what the workflow can access.
[Types: permissions: contents: read security-events: write pull-requests: write]

14
00:01:18,000 --> 00:01:24,000
contents: read allows checking out the code. security-events: write allows uploading SARIF reports.
pull-requests: write allows posting comments on PRs.

15
00:01:24,000 --> 00:01:30,000
Now the jobs section.
[Types: jobs: gitleaks: name: "🔐 Gitleaks Secret Scan" runs-on: ubuntu-latest]

16
00:01:30,000 --> 00:01:36,000
The job runs on the latest Ubuntu runner. This is fast and reliable.

17
00:01:36,000 --> 00:01:42,000
Now the steps.
[Types: steps: - name: Checkout (full history for scheduled runs) uses: actions/checkout@v4 with: fetch-depth: ${{ github.event_name == 'schedule' && 0 || 50 }}]

18
00:01:42,000 --> 00:01:48,000
For scheduled runs, we check out the full history. This catches secrets in old commits.
For PRs and pushes, we check out the last 50 commits. This is faster.

19
00:01:48,000 --> 00:01:54,000
Now the Gitleaks step for PRs and pushes.
[Types: - name: Run Gitleaks — PR/push mode if: github.event_name != 'schedule' uses: gitleaks/gitleaks-action@v2 env: GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }} GITLEAKS_LICENSE: ${{ secrets.GITLEAKS_LICENSE }} with: args: > --config=.gitleaks.toml --verbose --redact --report-format=sarif --report-path=gitleaks-results.sarif --log-level=info]

20
00:01:54,000 --> 00:02:00,000
The if condition ensures this only runs on PRs and pushes, not scheduled runs.
We use the gitleaks-action from the marketplace. It handles the installation and execution.

21
00:02:00,000 --> 00:02:06,000
The args are important. --config points to our configuration file.
--verbose gives detailed output. --redact hides secrets from logs.
--report-format=sarif creates a SARIF report for GitHub Security.

22
00:02:06,000 --> 00:02:12,000
Now the Gitleaks step for scheduled runs.
[Types: - name: Run Gitleaks — full history mode (scheduled) if: github.event_name == 'schedule' uses: gitleaks/gitleaks-action@v2 env: GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }} with: args: > --config=.gitleaks.toml --verbose --redact --report-format=sarif --report-path=gitleaks-results.sarif --log-opts="--all --full-history" --log-level=info]

23
00:02:12,000 --> 00:02:18,000
The scheduled run scans the full history. --log-opts="--all --full-history" tells
Gitleaks to scan every commit.

24
00:02:18,000 --> 00:02:24,000
Now the SARIF upload step.
[Types: - name: Upload SARIF to GitHub Security tab uses: github/codeql-action/upload-sarif@v3 if: always() with: sarif_file: gitleaks-results.sarif category: gitleaks]

25
00:02:24,000 --> 00:02:30,000
The if: always() ensures this runs even if Gitleaks finds secrets.
The findings appear in the Security tab of your repository.

26
00:02:30,000 --> 00:02:36,000
Now the PR comment step. This posts a comment on the PR when secrets are found.
[Types: - name: Post PR comment on secret detection uses: actions/github-script@v7 if: failure() && github.event_name == 'pull_request' with: script: | github.rest.issues.createComment({ issue_number: context.issue.number, owner: context.repo.owner, repo: context.repo.repo, body: `## 🚨 Secret Detected — PR Blocked

Gitleaks has detected a potential secret in this PR.

**Immediate actions required:**
1. **Rotate the exposed credential NOW** — assume it is compromised
2. Check \`git log --all\` to identify when it was introduced
3. Remove the secret from the commit history (git-filter-repo or BFG)
4. Review the Gitleaks findings in the [Security tab](${context.serverUrl}/${context.repo.owner}/${context.repo.repo}/security/code-scanning)

**Do not:**
- Simply delete the file and recommit
- Add the file to .gitignore
- Use --no-verify to bypass the check

This PR cannot be merged until all findings are resolved.` })]

27
00:02:36,000 --> 00:02:42,000
This comment tells the developer exactly what to do. It's clear and actionable.
It also tells them what NOT to do. This prevents common mistakes.

28
00:02:42,000 --> 00:02:48,000
Now the Slack alert step. This notifies the security team.
[Types: - name: Alert security channel on secret detection if: failure() env: SLACK_WEBHOOK: ${{ secrets.SLACK_SECURITY_WEBHOOK }} run: | curl -s -X POST $SLACK_WEBHOOK -H 'Content-type: application/json' -d '{ "text": "🚨 *SECRET DETECTED* in financial-rag-agent", "attachments": [{ "color": "#ff0000", "fields": [ {"title": "Repository", "value": "${{ github.repository }}", "short": true}, {"title": "Branch", "value": "${{ github.ref_name }}", "short": true}, {"title": "Commit", "value": "${{ github.sha }}", "short": true}, {"title": "Actor", "value": "${{ github.actor }}", "short": true}, {"title": "Action required", "value": "Rotate the exposed credential immediately", "short": false} ] }] }']

29
00:02:48,000 --> 00:02:54,000
The Slack alert includes the repository, branch, commit, and actor.
The security team knows exactly who introduced the secret and when.

30
00:02:54,000 --> 00:03:00,000
Now let's test the workflow. Push a commit that contains a test secret.

31
00:03:00,000 --> 00:03:06,000
[Types: echo "AWS_SECRET_KEY=AKIAIMNOJVGFDXXXE4OA" >> test_secret.txt git add test_secret.txt git commit -m "test: secret detection" git push origin develop]

32
00:03:06,000 --> 00:03:12,000
The workflow should fail. You should see a comment on the PR. You should see a Slack alert.

33
00:03:12,000 --> 00:03:18,000
Now let's remove the secret.
[Types: git rm test_secret.txt git commit -m "fix: remove test secret" git push origin develop]

34
00:03:18,000 --> 00:03:24,000
The workflow should pass. The PR should be mergable.

35
00:03:24,000 --> 00:03:30,000
Now let me explain the Gitleaks configuration. Open `.gitleaks.toml`.

36
00:03:30,000 --> 00:03:36,000
[Types: [extend] useDefault = true]

37
00:03:36,000 --> 00:03:42,000
This uses the default Gitleaks rules. It detects common secrets like AWS keys,
GitHub tokens, and passwords.

38
00:03:42,000 --> 00:03:48,000
[Types: [allowlist] description = "Global allow list" paths = [ '''gitleaks\.toml''', '''\.env\.example''', '''.*\.lock''', '''.*\.mod''' ]]

39
00:03:48,000 --> 00:03:54,000
The allowlist ignores certain files. gitleaks.toml is the config file.
.env.example contains placeholders, not real secrets. *.lock are lock files.
*.mod are Go module files.

40
00:03:54,000 --> 00:04:00,000
[Types: regexes = [ '''219-09-9999''', '''078-05-1120''' ]]

41
00:04:00,000 --> 00:04:06,000
These are false positives. Gitleaks sometimes flags test data. We ignore common test values.

42
00:04:06,000 --> 00:04:12,000
Now let me explain the workflow_dispatch. This is for manual runs.

43
00:04:12,000 --> 00:04:18,000
In the GitHub Actions UI, click "Run workflow". Select the branch.
Click "Run workflow". This triggers the workflow manually.

44
00:04:18,000 --> 00:04:24,000
This is useful for testing. You can run the workflow without pushing code.
You can test changes to the workflow itself.

45
00:04:24,000 --> 00:04:30,000
Now let me recap what we've built in Part 6.

46
00:04:30,000 --> 00:04:36,000
We built the Gitleaks standalone workflow. It runs on every PR, push to main,
and weekly.

47
00:04:36,000 --> 00:04:42,000
The workflow produces a SARIF report. The report is uploaded to GitHub Security.

48
00:04:42,000 --> 00:04:48,000
If a secret is detected, the workflow comments on the PR. It notifies the
security team via Slack.

49
00:04:48,000 --> 00:04:54,000
The pre-commit hook catches secrets locally. The standalone workflow catches
secrets in CI. This is defense in depth.

50
00:04:54,000 --> 00:05:00,000
In Part 7, we'll test the Falco installation. We'll verify all eight rules
fire correctly.

51
00:05:00,000 --> 00:05:06,000
Thank you for watching. I'll see you in Part 7.

52
00:05:06,000 --> 00:05:10,000
[End of Part 6]

1
00:00:00,000 --> 00:00:06,000
Welcome back to Phase 10. In Part 7, we build the Gitleaks standalone workflow.

2
00:00:06,000 --> 00:00:12,000
We already have Gitleaks in our pre-commit hooks. But pre-commit hooks can be bypassed.
Developers can use git commit --no-verify. The standalone workflow is the backup.

3
00:00:12,000 --> 00:00:18,000
Think of it this way. Pre-commit hooks are like a security guard at the door.
The standalone workflow is like a security camera that records everything.
You need both.

4
00:00:18,000 --> 00:00:24,000
Open your editor and create `.github/workflows/gitleaks.yml`.

5
00:00:24,000 --> 00:00:30,000
We'll start with the name. This appears in the GitHub Actions UI.
[Types: name: "Gitleaks Secret Detection"]

6
00:00:30,000 --> 00:00:36,000
Now the on section. This defines when the workflow runs.
[Types: on: push: branches: [main, develop] pull_request: branches: [main] schedule: # Scan full history weekly — catches secrets in old commits - cron: "0 3 * * 1" workflow_dispatch: inputs: scan-depth: description: "Git log depth to scan (0 = full history)" default: "0"]

7
00:00:36,000 --> 00:00:42,000
The workflow runs on push to main and develop. It runs on pull requests to main.
It runs on a weekly schedule to scan the full history.
And it can be manually triggered with a scan-depth input.

8
00:00:42,000 --> 00:00:48,000
The weekly scan is important. It catches secrets that were committed before
Gitleaks was installed. It catches secrets that were missed.

9
00:00:48,000 --> 00:00:54,000
Now the permissions. This grants the workflow the permissions it needs.
[Types: permissions: contents: read security-events: write pull-requests: write]

10
00:00:54,000 --> 00:01:00,000
contents: read allows checking out the code. security-events: write allows uploading
SARIF reports to the Security tab. pull-requests: write allows commenting on PRs.

11
00:01:00,000 --> 00:01:06,000
Now the jobs section.
[Types: jobs: gitleaks: name: "🔐 Gitleaks Secret Scan" runs-on: ubuntu-latest]

12
00:01:06,000 --> 00:01:12,000
The job runs on the latest Ubuntu runner. It's fast and reliable.

13
00:01:12,000 --> 00:01:18,000
Now the steps. The first step is checking out the code.
[Types: steps: - name: Checkout (full history for scheduled runs) uses: actions/checkout@v4 with: fetch-depth: ${{ github.event_name == 'schedule' && 0 || 50 }}]

14
00:01:18,000 --> 00:01:24,000
For scheduled runs, we check out the full history. This allows scanning every commit.
For other runs, we check out the last 50 commits. This is faster.

15
00:01:24,000 --> 00:01:30,000
Now the Gitleaks step for PRs and pushes.
[Types: - name: Run Gitleaks — PR/push mode if: github.event_name != 'schedule' uses: gitleaks/gitleaks-action@v2 env: GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }} GITLEAKS_LICENSE: ${{ secrets.GITLEAKS_LICENSE }} with: args: > --config=.gitleaks.toml --verbose --redact --report-format=sarif --report-path=gitleaks-results.sarif --log-level=info]

16
00:01:30,000 --> 00:01:36,000
This runs Gitleaks on PRs and pushes. It uses the configuration file.
It produces a SARIF report for the GitHub Security tab.

17
00:01:36,000 --> 00:01:42,000
The GITLEAKS_LICENSE is required for organizations. For personal accounts,
it's not needed. The env section includes it conditionally.

18
00:01:42,000 --> 00:01:48,000
Now the Gitleaks step for scheduled runs.
[Types: - name: Run Gitleaks — full history mode (scheduled) if: github.event_name == 'schedule' uses: gitleaks/gitleaks-action@v2 env: GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }} with: args: > --config=.gitleaks.toml --verbose --redact --report-format=sarif --report-path=gitleaks-results.sarif --log-opts="--all --full-history" --log-level=info]

19
00:01:48,000 --> 00:01:54,000
This runs Gitleaks on the full history. It scans every commit in the repository.
The --log-opts="--all --full-history" tells git to scan everything.

20
00:01:54,000 --> 00:02:00,000
Now the SARIF upload step.
[Types: - name: Upload SARIF to GitHub Security tab uses: github/codeql-action/upload-sarif@v3 if: always() with: sarif_file: gitleaks-results.sarif category: gitleaks]

21
00:02:00,000 --> 00:02:06,000
The if: always() ensures this runs even if Gitleaks finds secrets.
The findings are uploaded to the GitHub Security tab. This provides a history
of secret detections.

22
00:02:06,000 --> 00:02:12,000
Now the PR comment step. This posts a comment on the PR.
[Types: - name: Post PR comment on secret detection uses: actions/github-script@v7 if: failure() && github.event_name == 'pull_request' with: script: | github.rest.issues.createComment({ issue_number: context.issue.number, owner: context.repo.owner, repo: context.repo.repo, body: `## 🚨 Secret Detected — PR Blocked

Gitleaks has detected a potential secret in this PR.

**Immediate actions required:**
1. **Rotate the exposed credential NOW** — assume it is compromised
2. Check \`git log --all\` to identify when it was introduced
3. Remove the secret from the commit history (git-filter-repo or BFG)
4. Review the Gitleaks findings in the [Security tab](${context.serverUrl}/${context.repo.owner}/${context.repo.repo}/security/code-scanning)

**Do not:**
- Simply delete the file and recommit
- Add the file to .gitignore
- Use --no-verify to bypass the check

This PR cannot be merged until all findings are resolved.` })]
```

23
00:02:12,000 --> 00:02:18,000
The PR comment tells the developer exactly what to do. It explains why the PR is blocked
and how to fix it. This saves time and prevents frustration.

24
00:02:18,000 --> 00:02:24,000
Now the Slack alert step. This sends a notification to the security channel.
[Types: - name: Alert security channel on secret detection if: failure() env: SLACK_WEBHOOK: ${{ secrets.SLACK_SECURITY_WEBHOOK }} run: | curl -s -X POST $SLACK_WEBHOOK -H 'Content-type: application/json' -d '{ "text": "🚨 *SECRET DETECTED* in financial-rag-agent", "attachments": [{ "color": "#ff0000", "fields": [ {"title": "Repository", "value": "${{ github.repository }}", "short": true}, {"title": "Branch", "value": "${{ github.ref_name }}", "short": true}, {"title": "Commit", "value": "${{ github.sha }}", "short": true}, {"title": "Actor", "value": "${{ github.actor }}", "short": true}, {"title": "Action required", "value": "Rotate the exposed credential immediately", "short": false} ] }] }']

25
00:02:24,000 --> 00:02:30,000
The Slack alert is sent to the security channel. It includes the repository,
branch, commit, and actor. The message is clear and actionable.

26
00:02:30,000 --> 00:02:36,000
Now let's test the workflow. Push a commit that contains a test secret.

27
00:02:36,000 --> 00:02:42,000
[Types: echo "AWS_SECRET_KEY=AKIAIMNOJVGFDXXXE4OA" >> test_secret.txt git add test_secret.txt git commit -m "test: secret detection" git push origin develop]

28
00:02:42,000 --> 00:02:48,000
Go to GitHub Actions. You should see the workflow running. It will fail at the
Gitleaks step.

29
00:02:48,000 --> 00:02:54,000
If this is a PR, you'll see a comment from the workflow. It explains what
the secret is and how to fix it.

30
00:02:54,000 --> 00:03:00,000
You'll also see a Slack alert in the security channel. The security team is notified
immediately.

31
00:03:00,000 --> 00:03:06,000
Now let's fix the secret. Remove the test file and rewrite history.

32
00:03:06,000 --> 00:03:12,000
[Types: git rm test_secret.txt git commit -m "fix: remove test secret" git push origin develop]

33
00:03:12,000 --> 00:03:18,000
But wait. The secret is still in the commit history. We need to remove it completely.

34
00:03:18,000 --> 00:03:24,000
[Types: git filter-repo --invert-paths --path test_secret.txt git push origin develop --force]

35
00:03:24,000 --> 00:03:30,000
git filter-repo rewrites the entire history. It removes the file completely.
The force push updates the remote branch.

36
00:03:30,000 --> 00:03:36,000
This is why the PR comment says "Do not simply delete the file and recommit."
The secret remains in the history. You must rewrite history.

37
00:03:36,000 --> 00:03:42,000
Now let me explain the configuration file. Open `.gitleaks.toml`.

38
00:03:42,000 --> 00:03:48,000
[Types: [extend] useDefault = true]

39
00:03:48,000 --> 00:03:54,000
This uses the default Gitleaks rules. It detects common secrets like AWS keys,
GitHub tokens, and passwords.

40
00:03:54,000 --> 00:04:00,000
[Types: [allowlist] description = "Global allow list" paths = [ '''gitleaks\.toml''', '''\.env\.example''', '''.*\.lock''', '''.*\.mod''' ] regexes = [ '''219-09-9999''', '''078-05-1120''' ]]

41
00:04:00,000 --> 00:04:06,000
The allowlist ignores certain files and patterns. This reduces false positives.
Test data and example files are ignored.

42
00:04:06,000 --> 00:04:12,000
Now let me recap what we've built in Part 7.

43
00:04:12,000 --> 00:04:18,000
We built the Gitleaks standalone workflow. It runs on PRs, pushes, and weekly schedules.

44
00:04:18,000 --> 00:04:24,000
We configured the workflow to upload SARIF reports to the GitHub Security tab.
This provides a history of secret detections.

45
00:04:24,000 --> 00:04:30,000
We configured PR comments. When a secret is detected, the PR gets a comment explaining
how to fix it.

46
00:04:30,000 --> 00:04:36,000
We configured Slack alerts. When a secret is detected, the security team is notified
immediately.

47
00:04:36,000 --> 00:04:42,000
We tested the workflow. We pushed a test secret. The workflow failed. The PR got a comment.
The security team got a Slack alert.

48
00:04:42,000 --> 00:04:48,000
We fixed the secret. We used git filter-repo to rewrite history and remove the file.

49
00:04:48,000 --> 00:04:54,000
This is the complete security pipeline. Pre-commit hooks catch secrets locally.
Standalone workflow catches secrets in CI. Slack alerts notify the security team.

50
00:04:54,000 --> 00:05:00,000
In Part 8, we'll install Falco and test all the rules. This is where we see
runtime security in action.

51
00:05:00,000 --> 00:05:06,000
Thank you for watching. I'll see you in Part 8.

52
00:05:06,000 --> 00:05:10,000
[End of Part 7]

1
00:00:00,000 --> 00:00:06,000
Welcome back to Phase 10. In Part 8, we verify the entire runtime security stack.

2
00:00:06,000 --> 00:00:12,000
We have built Falco with eight custom rules. We have Falcosidekick routing alerts
to Slack, PagerDuty, and CloudWatch. We have Prometheus alerts for critical events.

3
00:00:12,000 --> 00:00:18,000
Now we need to verify everything works together. This is the security verification.
We test each rule, each alert, and each destination.

4
00:00:18,000 --> 00:00:24,000
Think of this as a fire drill. You don't wait until a real fire to test the alarm.
You test it regularly so you know it works when you need it.

5
00:00:24,000 --> 00:00:30,000
Open your terminal. We'll start by verifying Falco is running.

6
00:00:30,000 --> 00:00:36,000
[Types: kubectl get pods -n kube-system -l app.kubernetes.io/name=falco]

7
00:00:36,000 --> 00:00:42,000
You should see one Falco pod on every node. Each pod is the Falco daemon.
The status should be Running.

8
00:00:42,000 --> 00:00:48,000
[Types: kubectl get pods -n kube-system -l app.kubernetes.io/name=falcosidekick]

9
00:00:48,000 --> 00:00:54,000
You should see two Falcosidekick pods. Both should be Running.
Two replicas provide high availability.

10
00:00:54,000 --> 00:01:00,000
Now let's verify Falco has loaded our custom rules.

11
00:01:00,000 --> 00:01:06,000
[Types: kubectl exec -n kube-system $(kubectl get pods -n kube-system -l app.kubernetes.io/name=falco -o name | head -1) -- falco -l 2>/dev/null | grep "financial-rag"]

12
00:01:06,000 --> 00:01:12,000
You should see our eight rules. Shell Spawned. Unexpected Outbound Connection.
Vault Secret Read. Privilege Escalation. Crypto Mining. kubectl exec. Process Environment Read.
Write Outside Allowed Paths.

13
00:01:12,000 --> 00:01:18,000
If you don't see these rules, the ConfigMap wasn't mounted correctly.
Check the Falco pod logs.

14
00:01:18,000 --> 00:01:24,000
[Types: kubectl logs -n kube-system $(kubectl get pods -n kube-system -l app.kubernetes.io/name=falco -o name | head -1) | grep "rules.d"]

15
00:01:24,000 --> 00:01:30,000
You should see a line like "Loading rules from /etc/falco/rules.d/financial_rag_rules.yaml".
This confirms our rules are loaded.

16
00:01:30,000 --> 00:01:36,000
Now let's test Rule 1. Shell Spawned in Financial RAG Pod.

17
00:01:36,000 --> 00:01:42,000
[Types: kubectl run test-shell --image=alpine --namespace=financial-rag --labels="app.kubernetes.io/component=api" --restart=Never -- sleep 600]

18
00:01:42,000 --> 00:01:48,000
This creates a test pod running Alpine Linux. It has the API component label.
Falco sees it as an API pod.

19
00:01:48,000 --> 00:01:54,000
[Types: kubectl exec -n financial-rag test-shell -- /bin/sh -c "echo test"]

20
00:01:54,000 --> 00:02:00,000
This triggers the shell spawn rule. Let's check Falco logs.

21
00:02:00,000 --> 00:02:06,000
[Types: kubectl logs -n kube-system $(kubectl get pods -n kube-system -l app.kubernetes.io/name=falco -o name | head -1) | grep "Shell Spawned"]

22
00:02:06,000 --> 00:02:12,000
You should see an alert. It contains the user, the command, the pod name.
Everything we need to investigate.

23
00:02:12,000 --> 00:02:18,000
Now check Slack. You should see a message from Falco. "Shell spawned in financial-rag pod".
Priority: CRITICAL. Pod: test-shell.

24
00:02:18,000 --> 00:02:24,000
Check PagerDuty. You should see an incident created. The incident title is
"Falco critical event: Shell Spawned in Financial RAG Pod".

25
00:02:24,000 --> 00:02:30,000
[Types: kubectl delete pod test-shell -n financial-rag]

26
00:02:30,000 --> 00:02:36,000
Clean up the test pod. Rule 1 is verified.

27
00:02:36,000 --> 00:02:42,000
Now let's test Rule 4. Vault Secret Read by Unexpected Process.

28
00:02:42,000 --> 00:02:48,000
[Types: kubectl run test-vault-read --image=alpine --namespace=financial-rag --labels="app.kubernetes.io/component=api" --restart=Never -- sleep 600]

29
00:02:48,000 --> 00:02:54,000
[Types: kubectl exec -n financial-rag test-vault-read -- cat /vault/secrets/database.env 2>/dev/null || true]

30
00:02:54,000 --> 00:03:00,000
This reads from the /vault/secrets/ path. Even though the file doesn't exist,
the open syscall still happens. Falco sees it.

31
00:03:00,000 --> 00:03:06,000
[Types: kubectl logs -n kube-system $(kubectl get pods -n kube-system -l app.kubernetes.io/name=falco -o name | head -1) | grep "Vault Secret Read"]

32
00:03:06,000 --> 00:03:12,000
You should see the alert. It shows the process that tried to read the secret.
It shows the pod name. It shows everything.

33
00:03:12,000 --> 00:03:18,000
[Types: kubectl delete pod test-vault-read -n financial-rag]

34
00:03:18,000 --> 00:03:24,000
Rule 4 is verified.

35
00:03:24,000 --> 00:03:30,000
Now let's test Rule 2. Unexpected Outbound Connection from Agent Pod.

36
00:03:30,000 --> 00:03:36,000
[Types: kubectl run test-outbound --image=alpine --namespace=financial-rag --labels="app.kubernetes.io/component=agent" --restart=Never -- sleep 600]

37
00:03:36,000 --> 00:03:42,000
[Types: kubectl exec -n financial-rag test-outbound -- wget -q --timeout=3 http://example.com:8080 || true]

38
00:03:42,000 --> 00:03:48,000
This connects to port 8080. The agent should only connect to ports 5432, 6379, 443,
and Istio ports. 8080 is unexpected.

39
00:03:48,000 --> 00:03:54,000
[Types: kubectl logs -n kube-system $(kubectl get pods -n kube-system -l app.kubernetes.io/name=falco -o name | head -1) | grep "Unexpected Outbound"]

40
00:03:54,000 --> 00:04:00,000
You should see the alert. The agent tried to connect to an unexpected port.
Falco caught it.

41
00:04:00,000 --> 00:04:06,000
[Types: kubectl delete pod test-outbound -n financial-rag]

42
00:04:06,000 --> 00:04:12,000
Rule 2 is verified.

43
00:04:12,000 --> 00:04:18,000
Now let's test Rule 7. kubectl exec in Financial RAG Namespace.

44
00:04:18,000 --> 00:04:24,000
[Types: kubectl run test-exec --image=alpine --namespace=financial-rag --labels="app.kubernetes.io/component=api" --restart=Never -- sleep 600]

45
00:04:24,000 --> 00:04:30,000
[Types: kubectl exec -n financial-rag test-exec -- echo "test"]

46
00:04:30,000 --> 00:04:36,000
[Types: kubectl logs -n kube-system $(kubectl get pods -n kube-system -l app.kubernetes.io/name=falco -o name | head -1) | grep "kubectl exec"]

47
00:04:36,000 --> 00:04:42,000
You should see the alert. It shows who ran the command, which pod, and what command.
This is an audit event.

48
00:04:42,000 --> 00:04:48,000
[Types: kubectl delete pod test-exec -n financial-rag]

49
00:04:48,000 --> 00:04:54,000
Rule 7 is verified.

50
00:04:54,000 --> 00:05:00,000
Now let's verify the Prometheus alerts. Check the alerts in Prometheus.

51
00:05:00,000 --> 00:05:06,000
[Types: kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090]

52
00:05:06,000 --> 00:05:12,000
Open http://localhost:9090/alerts. You should see FalcoCriticalEventDetected.
It may be inactive if no critical events are happening.

53
00:05:12,000 --> 00:05:18,000
Now trigger a critical event again to see the alert fire.

54
00:05:18,000 --> 00:05:24,000
[Types: kubectl run test-shell2 --image=alpine --namespace=financial-rag --labels="app.kubernetes.io/component=api" --restart=Never -- sleep 600]

55
00:05:24,000 --> 00:05:30,000
[Types: kubectl exec -n financial-rag test-shell2 -- /bin/sh -c "echo test"]

56
00:05:30,000 --> 00:05:36,000
Wait 30 seconds. Then check Prometheus alerts.

57
00:05:36,000 --> 00:05:42,000
FalcoCriticalEventDetected should be firing (red). This confirms the alert works.

58
00:05:42,000 --> 00:05:48,000
[Types: kubectl delete pod test-shell2 -n financial-rag]

59
00:05:48,000 --> 00:05:54,000
Now let's check the metrics in Grafana.

60
00:05:54,000 --> 00:06:00,000
[Types: kubectl port-forward -n observability svc/grafana 3000:3000]

61
00:06:00,000 --> 00:06:06,000
Open http://localhost:3000. Login with admin/admin. Go to Explore.
Select the Prometheus data source.

62
00:06:06,000 --> 00:06:12,000
Query `falco_events_total{namespace="financial-rag"}`.
You will see the total number of Falco events. Filter by priority to see
critical events only.

63
00:06:12,000 --> 00:06:18,000
Query `falco_events_total{namespace="financial-rag",priority="Critical"}`.
You should see counts from our test runs.

64
00:06:18,000 --> 00:06:24,000
Now let's check the CloudWatch logs.

65
00:06:24,000 --> 00:06:30,000
[Types: aws logs describe-log-groups --log-group-name-prefix /aws/falco]

66
00:06:30,000 --> 00:06:36,000
You should see the log group /aws/falco/financial-rag. This confirms CloudWatch
logging is working.

67
00:06:36,000 --> 00:06:42,000
[Types: aws logs get-log-events --log-group-name /aws/falco/financial-rag --log-stream-name $(aws logs describe-log-streams --log-group-name /aws/falco/financial-rag --order-by LastEventTime --descending --limit 1 --query 'logStreams[0].logStreamName' --output text) --limit 10]

68
00:06:42,000 --> 00:06:48,000
You should see the shell spawn event in CloudWatch logs. The complete audit trail.

69
00:06:48,000 --> 00:06:54,000
Now let's test the hot reload of Falco rules. Edit the rules file and add a test rule.

70
00:06:54,000 --> 00:07:00,000
[Types: echo "- rule: Test Rule desc: Test rule for hot reload condition: evt.type in (execve) priority: INFO" >> falco/rules/financial_rag_rules.yaml]

71
00:07:00,000 --> 00:07:06,000
Update the ConfigMap.

72
00:07:06,000 --> 00:07:12,000
[Types: kubectl create configmap falco-financial-rag-rules --namespace kube-system --from-file=financial_rag_rules.yaml=falco/rules/financial_rag_rules.yaml --dry-run=client -o yaml | kubectl apply -f -]

73
00:07:12,000 --> 00:07:18,000
Send SIGHUP to Falco.

74
00:07:18,000 --> 00:07:24,000
[Types: kubectl exec -n kube-system $(kubectl get pods -n kube-system -l app.kubernetes.io/name=falco -o name | head -1) -- kill -1 1]

75
00:07:24,000 --> 00:07:30,000
Check that the new rule is loaded.

76
00:07:30,000 --> 00:07:36,000
[Types: kubectl exec -n kube-system $(kubectl get pods -n kube-system -l app.kubernetes.io/name=falco -o name | head -1) -- falco -l 2>/dev/null | grep "Test Rule"]

77
00:07:36,000 --> 00:07:42,000
You should see the test rule. Hot reload works.

78
00:07:42,000 --> 00:07:48,000
Now let's clean up the test rule.

79
00:07:48,000 --> 00:07:54,000
[Types: sed -i '/Test Rule/d' falco/rules/financial_rag_rules.yaml]
[Types: kubectl create configmap falco-financial-rag-rules --namespace kube-system --from-file=financial_rag_rules.yaml=falco/rules/financial_rag_rules.yaml --dry-run=client -o yaml | kubectl apply -f -]
[Types: kubectl exec -n kube-system $(kubectl get pods -n kube-system -l app.kubernetes.io/name=falco -o name | head -1) -- kill -1 1]

80
00:07:54,000 --> 00:08:00,000
Now let me recap what we've verified in Part 8.

81
00:08:00,000 --> 00:08:06,000
We verified Falco is running with our custom rules. All eight rules are loaded.

82
00:08:06,000 --> 00:08:12,000
We tested each rule. Shell Spawned. Unexpected Outbound. Vault Secret Read.
kubectl exec. All rules fired correctly.

83
00:08:12,000 --> 00:08:18,000
We verified Falcosidekick routes alerts. Slack messages are sent. PagerDuty incidents
are created. CloudWatch logs are stored.

84
00:08:18,000 --> 00:08:24,000
We verified Prometheus alerts. FalcoCriticalEventDetected fires on critical events.
Metrics are available in Grafana.

85
00:08:24,000 --> 00:08:30,000
We verified hot reload. Falco rules can be updated without restarting pods.

86
00:08:30,000 --> 00:08:36,000
This is a complete runtime security stack. It detects threats, routes alerts,
and provides audit trails. Everything works together.

87
00:08:36,000 --> 00:08:42,000
Phase 10 is now complete. You have a production-grade security stack.

88
00:08:42,000 --> 00:08:48,000
Thank you for watching. I'll see you in Phase 11.

89
00:08:48,000 --> 00:08:52,000
[End of Part 8]