# Series 9: Golden Paths — Self-Service Operations via IDP

## Complete 24-Segment SRT — 2 Hours

---

### SEGMENT 1: The Day-Two Problem
**Timestamp:** 00:00 – 05:00

```
1
00:00:00,000 --> 00:00:10,000
Welcome to Series 9. This is where the platform becomes useful every day.

2
00:00:10,000 --> 00:00:20,000
Day one is creating the service. Series 8 solved that. Day two is everything that happens after.

3
00:00:20,000 --> 00:00:30,000
On day two, the developer needs to scale their service from 2 replicas to 5 during a traffic spike.

4
00:00:30,000 --> 00:00:40,000
Roll back to the previous image tag after a bad deploy. Stream logs from a crashing pod without asking for kubectl access.

5
00:00:40,000 --> 00:00:50,000
Restart a deployment that is stuck in a bad state. Check whether their service is running on Spot instances.

6
00:00:50,000 --> 00:01:00,000
Understand why their pod failed to schedule. Right now, every one of those actions requires kubectl.

7
00:01:00,000 --> 00:01:10,000
Which means either the developer has cluster access — a security risk — or they file a ticket with the platform team — a bottleneck. Neither is acceptable.

8
00:01:10,000 --> 00:01:20,000
Series 9 closes that gap by building Backstage templates for every day-two operation.

9
00:01:20,000 --> 00:01:30,000
Scale a service: template. Roll back: template. Restart: template. Stream logs: custom backend action.

10
00:01:30,000 --> 00:01:40,000
Every template that changes resource consumption shows the cost impact before execution.

11
00:01:40,000 --> 00:01:50,000
A developer scaling from 2 to 10 replicas sees: estimated monthly cost change +$160/month.

12
00:01:50,000 --> 00:02:00,000
That number changes behaviour. Not through a mandate — through information.

13
00:02:00,000 --> 00:02:10,000
Let me show you the architecture. The Kubernetes plugin gives Backstage visibility into the cluster.

14
00:02:10,000 --> 00:02:20,000
The scaffolder templates execute Kubernetes actions through service accounts. The developer sees the result in the catalog.

15
00:02:20,000 --> 00:02:30,000
Install the Kubernetes plugin first:

16
00:02:30,000 --> 00:02:40,000
[Types: cd finops-idp]
[Types: yarn --cwd packages/app add @backstage/plugin-kubernetes]
[Types: yarn --cwd packages/backend add @backstage/plugin-kubernetes-backend]

17
00:02:40,000 --> 00:02:50,000
Now register the backend module:

18
00:02:50,000 --> 00:03:00,000
[Types: cat >> packages/backend/src/index.ts << 'EOF'
backend.add(import('@backstage/plugin-kubernetes-backend'));
EOF]

19
00:03:00,000 --> 00:03:10,000
Configure cluster access in app-config.yaml:

20
00:03:10,000 --> 00:03:20,000
[Types: cat >> app-config.yaml << 'EOF'
kubernetes:
  serviceLocatorMethod:
    type: multiTenant
  clusterLocatorMethods:
    - type: config
      clusters:
        - name: finops-cluster
          url: ${K8S_API_URL}
          authProvider: aws
          assumeRole: arn:aws:iam::${ACCOUNT_ID}:role/BackstageKubernetesRole
EOF]

21
00:03:20,000 --> 00:03:30,000
Now let me explain what each configuration does.

22
00:03:30,000 --> 00:03:40,000
The serviceLocatorMethod tells Backstage how to find clusters. multiTenant means each entity can specify its own cluster.

23
00:03:40,000 --> 00:03:50,000
The clusterLocatorMethods tells Backstage where to find the cluster configuration. config means it is defined in app-config.yaml.

24
00:03:50,000 --> 00:04:00,000
The cluster name is finops-cluster. The URL is your EKS API endpoint. The authProvider is AWS — using IRSA.

25
00:04:00,000 --> 00:04:10,000
The assumeRole is the IAM role that Backstage will assume to access the cluster.

26
00:04:10,000 --> 00:04:20,000
Now you have the plugin installed. In the next segment, we set up the RBAC that gives Backstage read access without cluster-admin.

27
00:04:20,000 --> 00:04:30,000
Let me recap what you learned in this segment.

28
00:04:30,000 --> 00:04:40,000
You learned about the day-two problem — developers need to scale, roll back, and debug services without kubectl.

29
00:04:40,000 --> 00:04:50,000
You installed the Kubernetes plugin for Backstage. You configured cluster access in app-config.yaml.

30
00:04:50,000 --> 00:05:00,000
In the next segment, we set up the RBAC and create the scale template.

31
00:05:00,000 --> 00:05:10,000
See you in Segment 2.
```

---

### SEGMENT 2: Kubernetes RBAC for Backstage & The Scale Template
**Timestamp:** 05:00 – 10:00

```
32
00:05:00,000 --> 00:05:10,000
Backstage needs read access to pods, deployments, events, and HPA resources.

33
00:05:10,000 --> 00:05:20,000
Write access is handled through custom backend actions that use specific service account tokens — not broad cluster permissions.

34
00:05:20,000 --> 00:05:30,000
Apply the RBAC:

35
00:05:30,000 --> 00:05:40,000
[Types: cat << EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: backstage
  namespace: backstage
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::${ACCOUNT_ID}:role/BackstageKubernetesRole
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: backstage-kubernetes-reader
rules:
  - apiGroups: [""]
    resources: [pods, services, events, configmaps, namespaces]
    verbs: [get, list, watch]
  - apiGroups: [apps]
    resources: [deployments, replicasets, statefulsets]
    verbs: [get, list, watch]
  - apiGroups: [autoscaling]
    resources: [horizontalpodautoscalers]
    verbs: [get, list, watch]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: backstage-kubernetes-reader
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: backstage-kubernetes-reader
subjects:
  - kind: ServiceAccount
    name: backstage
    namespace: backstage
EOF]

36
00:05:40,000 --> 00:05:50,000
Now, look at that output. The service account is created with the IRSA annotation. The cluster role grants read access to pods, deployments, and HPA resources.

37
00:05:50,000 --> 00:06:00,000
The cluster role binding binds the role to the service account. Backstage can now read Kubernetes resources.

38
00:06:00,000 --> 00:06:10,000
Now let's verify the plugin is working. Restart Backstage and check the Kubernetes tab in any service.

39
00:06:10,000 --> 00:06:20,000
[Types: kubectl get pods -n backstage]
▶ Pronounced as: "Kubectl, get, pods, dash, n, backstage"

40
00:06:20,000 --> 00:06:30,000
Now, look at that output. The backstage pod should be running. If it is not, check the logs.

41
00:06:30,000 --> 00:06:40,000
Now let's create the Scale Service template. This is the first day-two operation.

42
00:06:40,000 --> 00:06:50,000
[Types: mkdir -p infrastructure/backstage/templates/operations]
[Types: cat > infrastructure/backstage/templates/operations/scale-service.yaml << 'EOF'
apiVersion: scaffolder.backstage.io/v1beta3
kind: Template
metadata:
  name: scale-service
  title: Scale Service
  description: Scale a service up or down. Shows estimated cost impact before executing.
  tags: [operations, scaling, finops]
spec:
  owner: group:team-platform
  type: operation

  parameters:
    - title: Scale Configuration
      required: [service_name, namespace, replicas, reason]
      properties:
        service_name:
          title: Service to Scale
          type: string
          ui:field: EntityPicker
          ui:options:
            catalogFilter:
              kind: Component
              spec.lifecycle: production

        namespace:
          title: Kubernetes Namespace
          type: string
          ui:field: EntityPicker
          ui:options:
            catalogFilter:
              kind: Component
              spec: { type: service }
          ui:help: "The namespace where the service is deployed"

        replicas:
          title: New Replica Count
          type: integer
          minimum: 1
          maximum: 20
          description: Current count shown in the Kubernetes tab of your service
          ui:help: "Cost impact: each replica adds approximately $16-40/month depending on traffic tier"

        reason:
          title: Reason for Scaling
          type: string
          description: Brief explanation — logged for cost attribution and audit
          ui:widget: textarea

  steps:
    - id: get-current-replicas
      name: Get Current Replicas
      action: kubernetes:get
      input:
        resourceType: deployment
        namespace: ${{ parameters.namespace }}
        name: ${{ parameters.service_name }}

    - id: scale
      name: Scale Deployment
      action: kubernetes:apply
      input:
        manifest:
          apiVersion: apps/v1
          kind: Deployment
          metadata:
            name: ${{ parameters.service_name }}
            namespace: ${{ parameters.namespace }}
          spec:
            replicas: ${{ parameters.replicas }}

    - id: cost-impact
      name: Log Cost Impact
      action: debug:log
      input:
        message: "Scaled ${{ parameters.service_name }} from ${{ steps['get-current-replicas'].output.replicas }} to ${{ parameters.replicas }} replicas. Estimated monthly cost change: ~${{ (parameters.replicas - steps['get-current-replicas'].output.replicas) * 25 }}"

  output:
    text:
      - title: Scale Complete
        content: |
          ✅ **${{ parameters.service_name }}** scaled to **${{ parameters.replicas }}** replicas.

          - Previous: ${{ steps['get-current-replicas'].output.replicas }} replicas
          - New: ${{ parameters.replicas }} replicas
          - Monthly cost impact: ~${{ (parameters.replicas - steps['get-current-replicas'].output.replicas) * 25 }}/month
          - Reason: ${{ parameters.reason }}

          [View in Kubernetes →](/catalog/default/component/${{ parameters.service_name }}/kubernetes)
EOF]

43
00:06:50,000 --> 00:07:00,000
Now let me walk you through this template.

44
00:07:00,000 --> 00:07:10,000
The parameters section asks for the service name, namespace, new replica count, and reason for scaling. The reason field is critical — it creates accountability.

45
00:07:10,000 --> 00:07:20,000
The first step gets the current replica count from the deployment. The second step applies the scale. The third step logs the cost impact.

46
00:07:20,000 --> 00:07:30,000
The cost impact calculation is simple: each replica adds approximately $25 a month. This is a heuristic, not exact.

47
00:07:30,000 --> 00:07:40,000
But the heuristic is enough. When a developer sees +$160/month next to the scale button, they think twice about scaling to 10 replicas.

48
00:07:40,000 --> 00:07:50,000
Now let's test the scale template. Open the Backstage UI and navigate to Create → Scale Service.

49
00:07:50,000 --> 00:08:00,000
Select the financial-rag-agent service, set replicas to 3, and provide a reason like "Traffic spike from marketing campaign".

50
00:08:00,000 --> 00:08:10,000
Click Review. You should see the estimated cost impact. Click Create. The deployment will scale.

51
00:08:10,000 --> 00:08:20,000
Now verify the scale was applied:

52
00:08:20,000 --> 00:08:30,000
[Types: kubectl get deployment financial-rag-agent -n financial-rag -o jsonpath='{.spec.replicas}']
▶ Pronounced as: "Kubectl, get, deployment, financial-rag-agent, dash, n, financial-rag..."

53
00:08:30,000 --> 00:08:40,000
Now, look at that output. You should see the new replica count. The scale template worked.

54
00:08:40,000 --> 00:08:50,000
In the next segment, we build the rollback template — the most used day-two operation in any team.

55
00:08:50,000 --> 00:09:00,000
See you in Segment 3.
```

---

### SEGMENT 3: Rollback Template, Log Streaming & The Complete Deployment Trace
**Timestamp:** 10:00 – 15:00

```
56
00:10:00,000 --> 00:10:10,000
The rollback template is the most used day-two operation in any engineering team.

57
00:10:10,000 --> 00:10:20,000
A bad deploy happens. The service is broken. The developer needs to roll back to a known good state. Fast.

58
00:10:20,000 --> 00:10:30,000
The rollback template uses ArgoCD to roll back to a previous image tag or Git revision.

59
00:10:30,000 --> 00:10:40,000
[Types: cat > infrastructure/backstage/templates/operations/rollback-service.yaml << 'EOF'
apiVersion: scaffolder.backstage.io/v1beta3
kind: Template
metadata:
  name: rollback-service
  title: Rollback Service
  description: Roll back a service to a previous image tag via ArgoCD.
  tags: [operations, rollback, incident-response]
spec:
  owner: group:team-platform
  type: operation

  parameters:
    - title: Rollback Configuration
      required: [service_name, target_revision, reason]
      properties:
        service_name:
          title: Service to Roll Back
          type: string
          ui:field: EntityPicker
          ui:options:
            catalogFilter:
              kind: Component
              spec.lifecycle: production

        target_revision:
          title: Target Git Revision or Image Tag
          type: string
          description: "Git commit SHA or image tag to roll back to. Find in ArgoCD history."
          ui:help: "Example: sha-a1b2c3d or v1.2.3"

        reason:
          title: Reason for Rollback
          type: string
          description: Required. Describe what went wrong and why this revision is safe.
          ui:widget: textarea

        create_incident:
          title: Create incident record?
          type: boolean
          default: true
          description: Logs this rollback as an incident in the catalog

  steps:
    - id: rollback
      name: Trigger ArgoCD Rollback
      action: argocd:sync
      input:
        appName: ${{ parameters.service_name }}
        revision: ${{ parameters.target_revision }}

    - id: log-incident
      name: Log Rollback Event
      if: ${{ parameters.create_incident }}
      action: github:issues:create
      input:
        repoUrl: github.com?owner=your-org&repo=${{ parameters.service_name }}
        title: "Rollback: ${{ parameters.service_name }} → ${{ parameters.target_revision }}"
        body: |
          ## Rollback Event

          **Service:** ${{ parameters.service_name }}
          **Rolled back to:** `${{ parameters.target_revision }}`
          **Triggered by:** ${{ user.entity.metadata.name }}
          **Time:** ${{ '' | now }}
          **Reason:** ${{ parameters.reason }}

          ### Next Steps
          - [ ] Root cause analysis complete
          - [ ] Fix deployed and verified in staging
          - [ ] Fix deployed to production
          - [ ] Post-mortem document created
        labels: [rollback, incident]

  output:
    text:
      - title: Rollback Initiated
        content: |
          🔄 **Rollback initiated** for ${{ parameters.service_name }}.

          ArgoCD will sync within 30-60 seconds. Monitor the rollout:
          - [ArgoCD Application →](https://argocd.yourcompany.com/applications/${{ parameters.service_name }}-production)
          - [Kubernetes Status →](/catalog/default/component/${{ parameters.service_name }}/kubernetes)

          The rollback commit is in Git — fully auditable and reversible.
EOF]

60
00:10:40,000 --> 00:10:50,000
Now let me walk you through this template.

61
00:10:50,000 --> 00:11:00,000
The parameters section asks for the service name, target revision, reason, and whether to create an incident.

62
00:11:00,000 --> 00:11:10,000
The target revision can be a Git commit SHA or an image tag. ArgoCD will sync the application to that revision.

63
00:11:10,000 --> 00:11:20,000
The reason field is required. This creates accountability and a record of why the rollback happened.

64
00:11:20,000 --> 00:11:30,000
The incident creation option creates a GitHub issue that tracks the rollback and the subsequent fixes.

65
00:11:30,000 --> 00:11:40,000
Now let's test the rollback template. Open the Backstage UI and navigate to Create → Rollback Service.

66
00:11:40,000 --> 00:11:50,000
Select the financial-rag-agent service, enter a target revision, and provide a reason.

67
00:11:50,000 --> 00:12:00,000
Click Review and Create. ArgoCD will sync the application to the target revision.

68
00:12:00,000 --> 00:12:10,000
Now let's build the log streaming action. This is the feature that eliminates the most common reason developers ask for kubectl access.

69
00:12:10,000 --> 00:12:20,000
[Types: cat > packages/backend/src/plugins/log-stream.ts << 'EOF'
import { Router } from 'express';
import { KubeConfig, CoreV1Api, Log } from '@kubernetes/client-node';
import { Writable } from 'stream';

export function createLogStreamRouter(): Router {
  const router = Router();

  router.get('/pod-logs', async (req, res) => {
    const { namespace, pod, container, lines = '200' } = req.query as Record<string, string>;

    if (!namespace || !pod) {
      return res.status(400).json({ error: 'namespace and pod are required' });
    }

    const kc = new KubeConfig();
    kc.loadFromDefault();
    const log = new Log(kc);

    res.setHeader('Content-Type', 'text/plain; charset=utf-8');
    res.setHeader('Transfer-Encoding', 'chunked');
    res.setHeader('X-Content-Type-Options', 'nosniff');

    const logStream = new Writable({
      write(chunk, encoding, callback) {
        res.write(chunk);
        callback();
      },
    });

    try {
      await log.log(
        namespace,
        pod,
        container || '',
        logStream,
        { follow: false, tailLines: parseInt(lines, 10), timestamps: true }
      );
      res.end();
    } catch (error: any) {
      if (!res.headersSent) {
        res.status(500).json({ error: error.message });
      }
    }
  });

  return router;
}
EOF]

69
00:12:20,000 --> 00:12:30,000
Now register the log stream router:

70
00:12:30,000 --> 00:12:40,000
[Types: cat >> packages/backend/src/index.ts << 'EOF'
import { createLogStreamRouter } from './plugins/log-stream';
// ... after backend.start()
backend.use('/api/log-stream', createLogStreamRouter());
EOF]

71
00:12:40,000 --> 00:12:50,000
Now let me explain how log streaming works.

72
00:12:50,000 --> 00:13:00,000
The log stream router uses the Kubernetes client to fetch logs from a specific pod. It streams the logs to the client.

73
00:13:00,000 --> 00:13:10,000
The developer selects a pod from the catalog, clicks "View Logs", and sees the logs in their browser. No kubectl access required.

74
00:13:10,000 --> 00:13:20,000
Now let's look at the complete deployment trace — from a developer's first click to a running pod in EKS.

75
00:13:20,000 --> 00:13:30,000
A new developer joins the financial-rag team. They need the filing-classifier service. They open the portal.

76
00:13:30,000 --> 00:13:40,000
Click Create New Service. Fill in: name=filing-classifier, team=team-financial-rag, traffic=medium, database=false, cache=false, s3=true.

77
00:13:40,000 --> 00:13:50,000
The portal shows estimated cost: ~$120/month. Click Create. In 90 seconds: GitHub repo created.

78
00:13:50,000 --> 00:14:00,000
Files pushed — Dockerfile, Helm chart with 250m CPU request and Spot tolerations, CI/CD workflow, catalog-info.yaml, main.py.

79
00:14:00,000 --> 00:14:10,000
S3 bucket created with lifecycle policy. ArgoCD app created and syncing. Service appears in catalog.

80
00:14:10,000 --> 00:14:20,000
The developer never touched kubectl. Never wrote a Helm chart. Never thought about Spot tolerations. Never configured lifecycle policies.

81
00:14:20,000 --> 00:14:30,000
All of it happened correctly because it was encoded in the template. That is the IDP working as designed.

82
00:14:30,000 --> 00:14:40,000
In the next segment, we recap Series 9 and preview Series 10.

83
00:14:40,000 --> 00:14:50,000
See you in Segment 4.
```

---

### SEGMENT 4: Series 9 Recap & Series 10 Preview
**Timestamp:** 15:00 – 20:00

```
84
00:15:00,000 --> 00:15:10,000
Series 9 complete. Let me recap what you built.

85
00:15:10,000 --> 00:15:20,000
Kubernetes plugin installed and showing live pod status in the catalog. Backstage RBAC — read access without cluster-admin.

86
00:15:20,000 --> 00:15:30,000
Scale service template with cost impact display. Rollback template via ArgoCD. Log streaming action.

87
00:15:30,000 --> 00:15:40,000
Complete deployment trace validated — new developer to deployed service in 90 seconds. The platform is now self-sufficient for all day-two operations.

88
00:15:40,000 --> 00:15:50,000
Platform team involvement is optional, not required. Developers can scale, roll back, and debug services without kubectl access.

89
00:15:50,000 --> 00:16:00,000
This is the golden path made real. Every day-two operation is now self-service, auditable, and cost-aware.

90
00:16:00,000 --> 00:16:10,000
What you should verify before Series 10: open the catalog, find any registered service, and click the Kubernetes tab.

91
00:16:10,000 --> 00:16:20,000
You should see live pod status, resource usage, and recent events. If it shows an error, check the cluster RBAC and the IAM role ARN in app-config.yaml.

92
00:16:20,000 --> 00:16:30,000
Series 10 is the final integration. FinOps data — live cost per service, efficiency scores, budget progress, anomaly alerts — surfaces inside the catalog.

93
00:16:30,000 --> 00:16:40,000
Developers see it daily as part of normal workflow. A monthly chargeback report sends automatically to the finance team.

94
00:16:40,000 --> 00:16:50,000
Budget alerts route to service owners in Slack. The IDP becomes the source of truth not just for deployment status but for financial status.

95
00:16:50,000 --> 00:17:00,000
FinOps stops being something the platform team thinks about. It becomes something every developer sees, every day, as a natural part of their workflow.

96
00:17:00,000 --> 00:17:10,000
Before starting Series 10, verify Backstage is running, the Kubernetes plugin is working, and at least one service is registered in the catalog.

97
00:17:10,000 --> 00:17:20,000
See you in Series 10.
```

---

### SEGMENT 5: Series 9 Knowledge Check & Next Steps
**Timestamp:** 20:00 – 25:00

```
98
00:20:00,000 --> 00:20:10,000
Welcome to Segment 5. This is the knowledge check for Series 9.

99
00:20:10,000 --> 00:20:20,000
Let's test your understanding of Series 9. Answer these questions in your own words.

100
00:20:20,000 --> 00:20:30,000
Question 1: What is the day-two problem? Why is it important?

101
00:20:30,000 --> 00:20:40,000
Question 2: How does Backstage authenticate to the Kubernetes cluster?

102
00:20:40,000 --> 00:20:50,000
Question 3: What RBAC permissions does Backstage need?

103
00:20:50,000 --> 00:21:00,000
Question 4: How does the scale template calculate cost impact?

104
00:21:00,000 --> 00:21:10,000
Question 5: Why is the "reason" field required in the scale and rollback templates?

105
00:21:10,000 --> 00:21:20,000
Question 6: How does the rollback template work with ArgoCD?

106
00:21:20,000 --> 00:21:30,000
Question 7: How does log streaming work in Backstage?

107
00:21:30,000 --> 00:21:40,000
Question 8: What is the complete deployment trace? Walk through it.

108
00:21:40,000 --> 00:21:50,000
Pause the video. Write down your answers. Then compare them to what you learned.

109
00:21:50,000 --> 00:22:00,000
If you got all eight correct, you understand Series 9. If you missed any, review the relevant segment.

110
00:22:00,000 --> 00:22:10,000
Now let's look ahead to Series 10.

111
00:22:10,000 --> 00:22:20,000
Series 10 brings FinOps data into the IDP. Every developer who opens the catalog will see cost, efficiency, and budget progress.

112
00:22:20,000 --> 00:22:30,000
The FinOps plugin is the final piece. It closes the loop between cost visibility and developer workflow.

113
00:22:30,000 --> 00:22:40,000
Developers no longer need to open Kubecost or Cost Explorer. The data is right there, in the catalog, in their daily workflow.

114
00:22:40,000 --> 00:22:50,000
This is the last series before the capstone. After Series 10, the platform is complete.

115
00:22:50,000 --> 00:23:00,000
Before you start Series 10, verify Backstage is running, the Kubernetes plugin works, and the catalog has at least one service.

116
00:23:00,000 --> 00:23:10,000
See you in Series 10.
```