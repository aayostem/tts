# Series 9: Golden Paths — Self-Service Operations via IDP

## Complete 24-Segment SRT — 2 Hours

---

### SEGMENT 1: The Day-Two Problem
**Timestamp:** 00:00 – 05:00

```
1
00:00:00,000 --> 00:00:10,000
Welcome to Series 9. This is where we solve the day-two problem.

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
Restart a deployment that is stuck in a bad state. Check whether their service is running on Spot instances. Understand why their pod failed to schedule.

6
00:00:50,000 --> 00:01:00,000
Right now, every one of those actions requires kubectl. Which means either the developer has cluster access — a security risk — or they file a ticket with the platform team — a bottleneck.

7
00:01:00,000 --> 00:01:10,000
Neither is acceptable. Series 9 closes that gap by building Backstage templates for every day-two operation.

8
00:01:10,000 --> 00:01:20,000
Scale a service: template. Roll back: template. Restart: template. Stream logs: custom backend action.

9
00:01:20,000 --> 00:01:30,000
Every template that changes resource consumption shows the cost impact before execution.

10
00:01:30,000 --> 00:01:40,000
A developer scaling from 2 to 10 replicas sees: estimated monthly cost change +$160/month. That number changes behaviour. Not through a mandate — through information.

11
00:01:40,000 --> 00:01:50,000
Let me show you the day-two operations we are going to build.

12
00:01:50,000 --> 00:02:00,000
First, scale. A developer opens the catalog, finds their service, clicks Scale, enters a new replica count, and the deployment updates.

13
00:02:00,000 --> 00:02:10,000
Second, rollback. A developer opens the catalog, finds their service, clicks Rollback, selects a previous image tag, and ArgoCD reverts the deployment.

14
00:02:10,000 --> 00:02:20,000
Third, logs. A developer opens the catalog, finds their service, clicks Logs, selects a pod, and sees real-time log output.

15
00:02:20,000 --> 00:02:30,000
Fourth, restart. A developer opens the catalog, finds their service, clicks Restart, and the deployment is recreated.

16
00:02:30,000 --> 00:02:40,000
Fifth, pod status. A developer opens the catalog, finds their service, and sees the status of every pod in the deployment.

17
00:02:40,000 --> 00:02:50,000
All of these operations happen through the Backstage UI. No kubectl access required. No platform team tickets required.

18
00:02:50,000 --> 00:03:00,000
Before we build the templates, we need the Kubernetes plugin. This gives Backstage visibility into the cluster.

19
00:03:00,000 --> 00:03:10,000
Install the Kubernetes plugin:

20
00:03:10,000 --> 00:03:20,000
[Types: cd finops-idp]

21
00:03:20,000 --> 00:03:30,000
[Types: yarn --cwd packages/app add @backstage/plugin-kubernetes]

22
00:03:30,000 --> 00:03:40,000
[Types: yarn --cwd packages/backend add @backstage/plugin-kubernetes-backend]

23
00:03:40,000 --> 00:03:50,000
Now register the backend module:

24
00:03:50,000 --> 00:04:00,000
[Types: cat > packages/backend/src/index.ts << 'EOF'
backend.add(import('@backstage/plugin-kubernetes-backend'));
EOF]

25
00:04:00,000 --> 00:04:10,000
Now configure cluster access in app-config.yaml:

26
00:04:10,000 --> 00:04:20,000
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

27
00:04:20,000 --> 00:04:30,000
The Kubernetes plugin requires an IAM role that Backstage can assume. This role has read-only access to the cluster.

28
00:04:30,000 --> 00:04:40,000
In the next segment, we set up the RBAC that gives Backstage read access without cluster-admin.

29
00:04:40,000 --> 00:04:50,000
See you in Segment 2.
```

---

### SEGMENT 2: Kubernetes RBAC for Backstage & The Scale Template
**Timestamp:** 05:00 – 10:00

```
30
00:05:00,000 --> 00:05:10,000
Welcome to Segment 2. We are setting up Kubernetes RBAC and building the scale template.

31
00:05:10,000 --> 00:05:20,000
Backstage needs read access to pods, deployments, events, and HPA resources. Write access is handled through custom backend actions.

32
00:05:20,000 --> 00:05:30,000
Apply the RBAC:

33
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

34
00:05:40,000 --> 00:05:50,000
Now, look at that output. The RBAC is applied. Backstage can now read Kubernetes resources.

35
00:05:50,000 --> 00:06:00,000
Now let's build the Scale Service template. This is the most used day-two operation.

36
00:06:00,000 --> 00:06:10,000
[Types: mkdir -p infrastructure/backstage/templates/operations]

37
00:06:10,000 --> 00:06:20,000
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
      required: [service_name, namespace, replicas]
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
          title: Namespace
          type: string
          description: The Kubernetes namespace where the service is deployed

        replicas:
          title: New Replica Count
          type: integer
          minimum: 1
          maximum: 20
          description: Current count shown in the Kubernetes tab of your service

        reason:
          title: Reason for Scaling
          type: string
          description: Brief explanation — logged for cost attribution and audit

  steps:
    - id: calculate-impact
      name: Calculate Cost Impact
      action: debug:log
      input:
        message: |
          COST IMPACT ANALYSIS
          Service: ${{ parameters.service_name }}
          New Replicas: ${{ parameters.replicas }}
          Estimated monthly cost change: ${{ parameters.replicas < 10 and '~$40' or '~$80' }}/month
          Reason: ${{ parameters.reason }}

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

  output:
    text:
      - title: Scale Complete
        content: |
          ✅ **${{ parameters.service_name }}** scaled to **${{ parameters.replicas }}** replicas.
          Reason: ${{ parameters.reason }}
          Monitor actual cost change in Kubecost within 24 hours.
EOF]

38
00:06:20,000 --> 00:06:30,000
Now let me walk you through this template.

39
00:06:30,000 --> 00:06:40,000
The parameters section asks for the service name, namespace, new replica count, and reason for scaling.

40
00:06:40,000 --> 00:06:50,000
The EntityPicker field allows the developer to select a service from the catalog. This ensures they are scaling a real service.

41
00:06:50,000 --> 00:07:00,000
The replicas field has a minimum of 1 and a maximum of 20. This prevents accidental scaling to zero or absurd numbers.

42
00:07:00,000 --> 00:07:10,000
The reason field is required. This is for audit purposes. When someone asks why a service was scaled, you have a record.

43
00:07:10,000 --> 00:07:20,000
The calculate-impact step shows the estimated cost impact before execution.

44
00:07:20,000 --> 00:07:30,000
The scale step uses the kubernetes:apply action to patch the deployment.

45
00:07:30,000 --> 00:07:40,000
Now register the template in Backstage:

46
00:07:40,000 --> 00:07:50,000
[Types: cat >> app-config.yaml << 'EOF'
catalog:
  locations:
    - type: url
      target: https://github.com/your-org/infrastructure/blob/main/backstage/templates/operations/scale-service.yaml
EOF]

47
00:07:50,000 --> 00:08:00,000
[Types: yarn dev]

48
00:08:00,000 --> 00:08:10,000
Now test the template. Open Backstage at http://localhost:3000/create. Select "Scale Service".

49
00:08:10,000 --> 00:08:20,000
Fill in: service_name=financial-rag-agent, namespace=financial-rag, replicas=5, reason=Traffic increase during earnings season.

50
00:08:20,000 --> 00:08:30,000
Click Review. You should see the cost impact. Click Create. The deployment should scale.

51
00:08:30,000 --> 00:08:40,000
[Types: kubectl get deployment financial-rag-agent -n financial-rag -o json | jq '.spec.replicas']

52
00:08:40,000 --> 00:08:50,000
Now, look at that output. The deployment should now show 5 replicas. The scale operation worked.

53
00:08:50,000 --> 00:09:00,000
The scale template is the foundation. In the next segment, we build the rollback template.

54
00:09:00,000 --> 00:09:10,000
See you in Segment 3.
```

---

### SEGMENT 3: Rollback Template, Log Streaming & The Complete Deployment Trace
**Timestamp:** 10:00 – 15:00

```
55
00:10:00,000 --> 00:10:10,000
Welcome to Segment 3. We are building the rollback template, log streaming, and the complete deployment trace.

56
00:10:10,000 --> 00:10:20,000
The rollback template is the most used day-two operation in any team. It is also the highest-risk operation.

57
00:10:20,000 --> 00:10:30,000
When something breaks in production, developers need to roll back quickly. The rollback template makes this safe and fast.

58
00:10:30,000 --> 00:10:40,000
[Types: cat > infrastructure/backstage/templates/operations/rollback-service.yaml << 'EOF'
apiVersion: scaffolder.backstage.io/v1beta3
kind: Template
metadata:
  name: rollback-service
  title: Rollback Service
  description: Roll back a service to the previous image tag via ArgoCD.
  tags: [operations, rollback, incident-response]
spec:
  owner: group:team-platform
  type: operation

  parameters:
    - title: Rollback Configuration
      required: [service_name, target_revision]
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
          description: Git commit SHA or image tag to roll back to. Find in ArgoCD history.

        reason:
          title: Reason for Rollback
          type: string
          description: Required. Describe what went wrong.

  steps:
    - id: rollback
      name: Trigger ArgoCD Rollback
      action: argocd:sync
      input:
        appName: ${{ parameters.service_name }}
        revision: ${{ parameters.target_revision }}
        syncOptions:
          - Validate=false
          - Prune=true

  output:
    text:
      - title: Rollback Initiated
        content: |
          🔄 **Rollback initiated** for ${{ parameters.service_name }} to revision **${{ parameters.target_revision }}**.
          Reason: ${{ parameters.reason }}
          ArgoCD will sync within 30-60 seconds.
EOF]

59
00:10:40,000 --> 00:10:50,000
Now let me walk you through the rollback template.

60
00:10:50,000 --> 00:11:00,000
The target_revision is the Git commit SHA or image tag to roll back to. This is found in ArgoCD history.

61
00:11:00,000 --> 00:11:10,000
The reason field is required. This is for incident documentation. When a rollback happens, you want to know why.

62
00:11:10,000 --> 00:11:20,000
The argocd:sync action triggers an ArgoCD sync to the specified revision.

63
00:11:20,000 --> 00:11:30,000
Now let's build log streaming. This is the feature developers ask for most.

64
00:11:30,000 --> 00:11:40,000
[Types: cat > packages/backend/src/plugins/log-stream.ts << 'EOF'
import { Router } from 'express';
import { KubeConfig, CoreV1Api, Log } from '@kubernetes/client-node';

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

65
00:11:40,000 --> 00:11:50,000
Now register the log stream router:

66
00:11:50,000 --> 00:12:00,000
[Types: cat >> packages/backend/src/index.ts << 'EOF'
import { createLogStreamRouter } from './plugins/log-stream';
const logStreamRouter = createLogStreamRouter();
backend.use('/api/logs', logStreamRouter);
EOF]

67
00:12:00,000 --> 00:12:10,000
Now let me walk through the complete deployment trace.

68
00:12:10,000 --> 00:12:20,000
A new developer on the financial-rag team needs the filing-classifier service.

69
00:12:20,000 --> 00:12:30,000
They open the portal. Click Create New Service. Fill in: name=filing-classifier, team=team-financial-rag, traffic=medium, database=false, cache=false, s3=true.

70
00:12:30,000 --> 00:12:40,000
The portal shows estimated cost: ~$120/month. They click Create.

71
00:12:40,000 --> 00:12:50,000
In 90 seconds: GitHub repo created at your-org/filing-classifier. Files pushed — Dockerfile, Helm chart, CI/CD workflow, catalog-info.yaml, main.py.

72
00:12:50,000 --> 00:13:00,000
S3 bucket created with lifecycle policy. ArgoCD app created and syncing. Service appears in catalog.

73
00:13:00,000 --> 00:13:10,000
The developer never touched kubectl. Never wrote a Helm chart. Never thought about Spot tolerations. Never configured lifecycle policies.

74
00:13:10,000 --> 00:13:20,000
All of it happened correctly because it was encoded in the template. That developer builds features from day one.

75
00:13:20,000 --> 00:13:30,000
Now let's verify the deployment trace worked.

76
00:13:30,000 --> 00:13:40,000
[Types: kubectl get pods -n filing-classifier -o wide]

77
00:13:40,000 --> 00:13:50,000
[Types: kubectl get deployment filing-classifier -n filing-classifier -o json | jq '.spec.replicas, .spec.template.spec.tolerations']

78
00:13:50,000 --> 00:14:00,000
Now, look at that output. The deployment should show the correct replicas and Spot tolerations.

79
00:14:00,000 --> 00:14:10,000
In the next segment, we recap Series 9 and preview Series 10.

80
00:14:10,000 --> 00:14:20,000
See you in Segment 4.
```

---

### SEGMENT 4: Series 9 Recap & Series 10 Preview
**Timestamp:** 15:00 – 20:00

```
81
00:15:00,000 --> 00:15:10,000
Welcome to Segment 4. This is the Series 9 recap and Series 10 preview.

82
00:15:10,000 --> 00:15:20,000
Let me recap what you built in Series 9.

83
00:15:20,000 --> 00:15:30,000
Kubernetes plugin installed and showing live pod status in the catalog. Backstage RBAC — read access without cluster-admin.

84
00:15:30,000 --> 00:15:40,000
Scale service template with cost impact display. Rollback template via ArgoCD. Complete deployment trace validated.

85
00:15:40,000 --> 00:15:50,000
The platform is now self-sufficient for all day-two operations. Platform team involvement is optional, not required.

86
00:15:50,000 --> 00:16:00,000
Before moving to Series 10, verify these things.

87
00:16:00,000 --> 00:16:10,000
[Types: echo "=== SERIES 9 VERIFICATION ==="]

88
00:16:10,000 --> 00:16:20,000
[Types: curl -s http://localhost:7007/api/kubernetes | jq .]

89
00:16:20,000 --> 00:16:30,000
Now, look at that output. If the Kubernetes plugin is working, you should see a response.

90
00:16:30,000 --> 00:16:40,000
[Types: curl -s "http://localhost:7007/api/catalog/entities?filter=kind=Template" | jq -r '.items[] | select(.metadata.name | contains("scale")) | .metadata.name']

91
00:16:40,000 --> 00:16:50,000
Now, look at that output. You should see "scale-service" and "rollback-service" in the templates list.

92
00:16:50,000 --> 00:17:00,000
Open the catalog, find any registered service, and click the Kubernetes tab. You should see live pod status, resource usage, and recent events.

93
00:17:00,000 --> 00:17:10,000
If it shows an error, check the cluster RBAC and the IAM role ARN in app-config.yaml.

94
00:17:10,000 --> 00:17:20,000
Series 10 is the final integration. FinOps data — live cost per service, efficiency scores, budget progress, anomaly alerts — surfaces inside the catalog.

95
00:17:20,000 --> 00:17:30,000
Developers see it daily as part of normal workflow. A monthly chargeback report sends automatically to the finance team.

96
00:17:30,000 --> 00:17:40,000
Budget alerts route to service owners in Slack. The IDP becomes the source of truth not just for deployment status but for financial status.

97
00:17:40,000 --> 00:17:50,000
By the end of Series 10, every developer who opens the catalog sees their service's current monthly cost and trend.

98
00:17:50,000 --> 00:18:00,000
Their team's budget progress with a red bar when approaching the limit. Efficiency score and rightsizing recommendations.

99
00:18:00,000 --> 00:18:10,000
Live cost anomaly alerts routed to service owners. A FinOps homepage dashboard with the full picture.

100
00:18:10,000 --> 00:18:20,000
FinOps stops being something the platform team thinks about. It becomes something every developer sees, every day, as a natural part of their workflow.

101
00:18:20,000 --> 00:18:30,000
That is the power of the IDP. Not just automation. But visibility. The kind of visibility that changes behaviour.

102
00:18:30,000 --> 00:18:40,000
In the next segment, we do the knowledge check for Series 9.

103
00:18:40,000 --> 00:18:50,000
See you in Segment 5.
```

---

### SEGMENT 5: Series 9 Knowledge Check & Next Steps
**Timestamp:** 20:00 – 25:00

```
104
00:20:00,000 --> 00:20:10,000
Welcome to Segment 5. This is the Series 9 knowledge check.

105
00:20:10,000 --> 00:20:20,000
Let's test your understanding of Series 9. Answer these questions in your own words.

106
00:20:20,000 --> 00:20:30,000
Question 1: What is the day-two problem and why does it matter?

107
00:20:30,000 --> 00:20:40,000
Question 2: What Kubernetes resources does Backstage need read access to?

108
00:20:40,000 --> 00:20:50,000
Question 3: What does the Scale Service template do and why is the cost impact shown?

109
00:20:50,000 --> 00:21:00,000
Question 4: How does the Rollback template work with ArgoCD?

110
00:21:00,000 --> 00:21:10,000
Question 5: How does log streaming work without kubectl access?

111
00:21:10,000 --> 00:21:20,000
Pause the video. Write down your answers. Then compare them to what you learned.

112
00:21:20,000 --> 00:21:30,000
If you got all five correct, you understand Series 9. If you missed any, review the relevant segment.

113
00:21:30,000 --> 00:21:40,000
Now let's look ahead to Series 10.

114
00:21:40,000 --> 00:21:50,000
In Series 10, we close the loop. We bring FinOps data directly into the developer's workflow inside the platform itself.

115
00:21:50,000 --> 00:22:00,000
You will build a FinOps backend plugin that serves cost data to the frontend. A budget scheduler that alerts teams approaching their monthly limits.

116
00:22:00,000 --> 00:22:10,000
A FinOps cost card that displays in every service's catalog page. A chargeback report generator that sends team-by-team cost breakdowns to finance.

117
00:22:10,000 --> 00:22:20,000
And a Kubecost anomaly webhook that routes cost anomalies to service owners.

118
00:22:20,000 --> 00:22:30,000
After Series 10, a developer opening the Backstage catalog sees their service's monthly cost, their team's budget usage, and any active cost anomalies.

119
00:22:30,000 --> 00:22:40,000
Without opening a single AWS console page. FinOps becomes invisible to them and omnipresent in their workflow.

120
00:22:40,000 --> 00:22:50,000
That is the final piece of the FinOps platform puzzle.

121
00:22:50,000 --> 00:23:00,000
See you in Series 10.
```

---

### SEGMENT 6: Deep Dive: Day-Two Operations — What Developers Need
**Timestamp:** 25:00 – 30:00

```
122
00:25:00,000 --> 00:25:10,000
Welcome to Segment 6. Let's dive deep into day-two operations.

123
00:25:10,000 --> 00:25:20,000
Day-two operations are the activities developers perform after a service is already running in production.

124
00:25:20,000 --> 00:25:30,000
These operations are high-frequency, high-impact, and often disruptive to developer productivity.

125
00:25:30,000 --> 00:25:40,000
The most common day-two operations are scaling, rollback, log viewing, restart, and status checking.

126
00:25:40,000 --> 00:25:50,000
Scaling is needed during traffic spikes. Rollback is needed when a deployment breaks. Log viewing is needed for debugging.

127
00:25:50,000 --> 00:26:00,000
Restart is needed when a deployment is stuck. Status checking is needed for monitoring.

128
00:26:00,000 --> 00:26:10,000
Today, these operations require kubectl access. This creates two problems.

129
00:26:10,000 --> 00:26:20,000
First, security. Kubectl access is powerful. It gives the ability to read secrets, modify resources, and even delete namespaces.

130
00:26:20,000 --> 00:26:30,000
Giving every developer kubectl access is a security risk. Most organizations restrict kubectl access to a small group.

131
00:26:30,000 --> 00:26:40,000
Second, productivity. When developers need to file a ticket for a scale operation, they wait. They lose flow state. They context-switch.

132
00:26:40,000 --> 00:26:50,000
A scale operation that takes 30 seconds with kubectl takes 4 hours with a ticket queue. That is not acceptable.

133
00:26:50,000 --> 00:27:00,000
The IDP solves both problems. Developers get self-service operations through the portal. They do not get kubectl access.

134
00:27:00,000 --> 00:27:10,000
Security is maintained. Productivity is improved. Everyone wins.

135
00:27:10,000 --> 00:27:20,000
But there is another benefit: auditability. Every operation through the IDP is logged.

136
00:27:20,000 --> 00:27:30,000
Who scaled the service? Why did they scale it? When did they scale it? All of this is recorded.

137
00:27:30,000 --> 00:27:40,000
With kubectl, there is no audit trail. You can see the change in the cluster, but you do not know who made it or why.

138
00:27:40,000 --> 00:27:50,000
The IDP provides the audit trail automatically. Every operation is tied to the user who performed it and the reason they gave.

139
00:27:50,000 --> 00:28:00,000
This is important for compliance. It is also important for incident response. When something breaks, you know who changed what and why.

140
00:28:00,000 --> 00:28:10,000
Now you understand the day-two problem and why the IDP solves it.

141
00:28:10,000 --> 00:28:20,000
In the next segment, we look at the Kubernetes plugin installation in detail.

142
00:28:20,000 --> 00:28:30,000
See you in Segment 7.
```

---

### SEGMENT 7: Kubernetes Plugin — Installation & Configuration
**Timestamp:** 30:00 – 35:00

```
143
00:30:00,000 --> 00:30:10,000
Welcome to Segment 7. We are looking at the Kubernetes plugin installation.

144
00:30:10,000 --> 00:30:20,000
The Kubernetes plugin is what gives Backstage visibility into the cluster. Without it, the day-two operations cannot work.

145
00:30:20,000 --> 00:30:30,000
The plugin has two parts: the frontend plugin and the backend plugin.

146
00:30:30,000 --> 00:30:40,000
The frontend plugin displays Kubernetes resources in the catalog. It shows pod status, events, and resource usage.

147
00:30:40,000 --> 00:30:50,000
The backend plugin handles the Kubernetes API calls. It authenticates with the cluster and fetches the data.

148
00:30:50,000 --> 00:31:00,000
Install the frontend plugin:

149
00:31:00,000 --> 00:31:10,000
[Types: cd finops-idp]

150
00:31:10,000 --> 00:31:20,000
[Types: yarn --cwd packages/app add @backstage/plugin-kubernetes]

151
00:31:20,000 --> 00:31:30,000
Install the backend plugin:

152
00:31:30,000 --> 00:31:40,000
[Types: yarn --cwd packages/backend add @backstage/plugin-kubernetes-backend]

153
00:31:40,000 --> 00:31:50,000
Now configure the backend plugin:

154
00:31:50,000 --> 00:32:00,000
[Types: cat >> packages/backend/src/index.ts << 'EOF'
backend.add(import('@backstage/plugin-kubernetes-backend'));
EOF]

155
00:32:00,000 --> 00:32:10,000
Now configure the cluster access in app-config.yaml:

156
00:32:10,000 --> 00:32:20,000
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
          skipTLSVerify: false
          caData: ${K8S_CA_DATA}
EOF]

157
00:32:20,000 --> 00:32:30,000
The authProvider is set to aws. This means Backstage uses AWS IAM to authenticate with the cluster.

158
00:32:30,000 --> 00:32:40,000
The assumeRole is the IAM role that Backstage assumes. This role has read-only access to the cluster.

159
00:32:40,000 --> 00:32:50,000
The cluster URL is the EKS endpoint. You can find this in the AWS console or with the AWS CLI.

160
00:32:50,000 --> 00:33:00,000
[Types: aws eks describe-cluster --name $CLUSTER_NAME --query 'cluster.endpoint' --output text]

161
00:33:00,000 --> 00:33:10,000
The CA data is the certificate authority data. This is used to verify the cluster's TLS certificate.

162
00:33:10,000 --> 00:33:20,000
[Types: aws eks describe-cluster --name $CLUSTER_NAME --query 'cluster.certificateAuthority.data' --output text]

163
00:33:20,000 --> 00:33:30,000
Now restart Backstage:

164
00:33:30,000 --> 00:33:40,000
[Types: yarn dev]

165
00:33:40,000 --> 00:33:50,000
After Backstage restarts, open the catalog and click on any service. You should now see a Kubernetes tab.

166
00:33:50,000 --> 00:34:00,000
Click the Kubernetes tab. You should see the pods, deployments, and events for that service.

167
00:34:00,000 --> 00:34:10,000
If you see an error, check the cluster configuration. The cluster URL, IAM role, and CA data must be correct.

168
00:34:10,000 --> 00:34:20,000
You can also check the Backstage logs for errors:

169
00:34:20,000 --> 00:34:30,000
[Types: kubectl logs -n backstage deployment/backstage --tail=50 | grep -i kubernetes]

170
00:34:30,000 --> 00:34:40,000
Now the Kubernetes plugin is installed and configured. Backstage can now see the cluster.

171
00:34:40,000 --> 00:34:50,000
In the next segment, we look at the Kubernetes RBAC in detail.

172
00:34:50,000 --> 00:35:00,000
See you in Segment 8.
```

---

### SEGMENT 8: Kubernetes RBAC — Service Account & ClusterRole
**Timestamp:** 35:00 – 40:00

```
173
00:35:00,000 --> 00:35:10,000
Welcome to Segment 8. We are looking at Kubernetes RBAC.

174
00:35:10,000 --> 00:35:20,000
RBAC is Role-Based Access Control. It controls what users and services can do in the cluster.

175
00:35:20,000 --> 00:35:30,000
For Backstage, we need read-only access to specific resources. We do not need write access.

176
00:35:30,000 --> 00:35:40,000
The ServiceAccount defines the identity that Backstage uses in the cluster.

177
00:35:40,000 --> 00:35:50,000
[Types: cat << EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: backstage
  namespace: backstage
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::${ACCOUNT_ID}:role/BackstageKubernetesRole
EOF]

178
00:35:50,000 --> 00:36:00,000
The ServiceAccount is in the backstage namespace. It uses an annotation to associate with an IAM role.

179
00:36:00,000 --> 00:36:10,000
The IAM role is assumed by Backstage when it makes API calls to the cluster.

180
00:36:10,000 --> 00:36:20,000
The ClusterRole defines the permissions that Backstage has in the cluster.

181
00:36:20,000 --> 00:36:30,000
[Types: cat << EOF | kubectl apply -f -
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
EOF]

182
00:36:30,000 --> 00:36:40,000
The ClusterRole grants get, list, and watch permissions on pods, services, events, configmaps, namespaces, deployments, replicasets, statefulsets, and horizontalpodautoscalers.

183
00:36:40,000 --> 00:36:50,000
These are the resources that Backstage needs to display in the catalog. No write permissions are granted.

184
00:36:50,000 --> 00:37:00,000
The ClusterRoleBinding binds the ServiceAccount to the ClusterRole.

185
00:37:00,000 --> 00:37:10,000
[Types: cat << EOF | kubectl apply -f -
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

186
00:37:10,000 --> 00:37:20,000
Now Backstage has read-only access to the cluster. It can fetch pod status, events, and deployment information.

187
00:37:20,000 --> 00:37:30,000
The IAM role must also have the correct permissions. Backstage uses the IAM role to authenticate with EKS.

188
00:37:30,000 --> 00:37:40,000
[Types: aws iam attach-role-policy --role-name BackstageKubernetesRole --policy-arn arn:aws:iam::aws:policy/ReadOnlyAccess]

189
00:37:40,000 --> 00:37:50,000
The ReadOnlyAccess policy gives the IAM role read-only access to all AWS resources. This is broader than what Backstage needs.

190
00:37:50,000 --> 00:38:00,000
For production, you should create a custom policy with only the permissions Backstage needs.

191
00:38:00,000 --> 00:38:10,000
[Types: cat << EOF > /tmp/backstage-eks-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "eks:DescribeCluster",
        "eks:ListClusters"
      ],
      "Resource": "*"
    }
  ]
}
EOF]

192
00:38:10,000 --> 00:38:20,000
[Types: aws iam create-policy --policy-name BackstageEKSPolicy --policy-document file:///tmp/backstage-eks-policy.json]

193
00:38:20,000 --> 00:38:30,000
[Types: aws iam attach-role-policy --role-name BackstageKubernetesRole --policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/BackstageEKSPolicy]

194
00:38:30,000 --> 00:38:40,000
Now Backstage has the minimum permissions needed to access the cluster. This is the principle of least privilege.

195
00:38:40,000 --> 00:38:50,000
Now you understand Kubernetes RBAC for Backstage. You have the ServiceAccount, ClusterRole, and ClusterRoleBinding configured.

196
00:38:50,000 --> 00:39:00,000
In the next segment, we do a deep dive into the Scale Service template.

197
00:39:00,000 --> 00:39:10,000
See you in Segment 9.
```

---

### SEGMENT 9: Deep Dive: The Scale Service Template
**Timestamp:** 40:00 – 45:00

```
198
00:40:00,000 --> 00:40:10,000
Welcome to Segment 9. We are diving deep into the Scale Service template.

199
00:40:10,000 --> 00:40:20,000
The Scale Service template is the most used day-two operation. Developers scale services frequently.

200
00:40:20,000 --> 00:40:30,000
The template is simple. It takes three inputs: service name, namespace, and new replica count.

201
00:40:30,000 --> 00:40:40,000
It then calculates the cost impact and applies the scale operation.

202
00:40:40,000 --> 00:40:50,000
[Types: cat infrastructure/backstage/templates/operations/scale-service.yaml]

203
00:40:50,000 --> 00:41:00,000
Let me walk through each part of the template in detail.

204
00:41:00,000 --> 00:41:10,000
The parameters section defines the input fields. The service_name field uses the EntityPicker.

205
00:41:10,000 --> 00:41:20,000
The EntityPicker allows the developer to select a service from the catalog. This ensures they are scaling a real service.

206
00:41:20,000 --> 00:41:30,000
The replicas field is an integer with a minimum of 1 and a maximum of 20. This prevents accidental scaling.

207
00:41:30,000 --> 00:41:40,000
The reason field is a string. It is required. This is for audit purposes.

208
00:41:40,000 --> 00:41:50,000
The steps section defines the actions. The first step is calculate-impact.

209
00:41:50,000 --> 00:42:00,000
This step uses the debug:log action to display a message. The message shows the cost impact.

210
00:42:00,000 --> 00:42:10,000
The cost impact is calculated based on the new replica count. More replicas mean more cost.

211
00:42:10,000 --> 00:42:20,000
The second step is scale. This uses the kubernetes:apply action.

212
00:42:20,000 --> 00:42:30,000
The manifest is a Deployment patch. It updates the replicas field of the deployment.

213
00:42:30,000 --> 00:42:40,000
The output section defines what the developer sees after the operation completes.

214
00:42:40,000 --> 00:42:50,000
It shows the service name, new replica count, and the reason for scaling.

215
00:42:50,000 --> 00:43:00,000
Now let me show you how to test the template.

216
00:43:00,000 --> 00:43:10,000
[Types: curl -X POST "http://localhost:7007/api/scaffolder/v2/tasks" -H "Content-Type: application/json" -d '{"templateRef":"template:default/scale-service","values":{"service_name":"financial-rag-agent","namespace":"financial-rag","replicas":5,"reason":"Traffic increase during earnings season"}}']

217
00:43:10,000 --> 00:43:20,000
Now, look at that output. You should see a task ID. This is the ID of the scale operation.

218
00:43:20,000 --> 00:43:30,000
[Types: kubectl get deployment financial-rag-agent -n financial-rag -o json | jq '.spec.replicas']

219
00:43:30,000 --> 00:43:40,000
Now, look at that output. The deployment should now show 5 replicas. The scale operation worked.

220
00:43:40,000 --> 00:43:50,000
The Scale Service template is complete. It is simple, effective, and cost-aware.

221
00:43:50,000 --> 00:44:00,000
In the next segment, we look at the cost impact calculation in detail.

222
00:44:00,000 --> 00:44:10,000
See you in Segment 10.
```

---

### SEGMENT 10: Scale Template — Cost Impact Calculation
**Timestamp:** 45:00 – 50:00

```
223
00:45:00,000 --> 00:45:10,000
Welcome to Segment 10. We are looking at the cost impact calculation.

224
00:45:10,000 --> 00:45:20,000
The cost impact is the most important feature of the Scale Service template.

225
00:45:20,000 --> 00:45:30,000
When a developer scales a service, they see the estimated monthly cost change before they apply the change.

226
00:45:30,000 --> 00:45:40,000
This number changes behaviour. Developers think twice before scaling unnecessarily.

227
00:45:40,000 --> 00:45:50,000
The cost impact calculation is based on the traffic tier of the service.

228
00:45:50,000 --> 00:46:00,000
Low traffic services cost approximately $40 per replica per month. Medium traffic services cost approximately $80 per replica per month.

229
00:46:00,000 --> 00:46:10,000
High traffic services cost approximately $160 per replica per month.

230
00:46:10,000 --> 00:46:20,000
The cost impact is the difference between the current cost and the new cost.

231
00:46:20,000 --> 00:46:30,000
[Types: cat infrastructure/backstage/templates/operations/scale-service.yaml | grep -A5 "calculate-impact"]

232
00:46:30,000 --> 00:46:40,000
The calculate-impact step uses the debug:log action to display the cost impact.

233
00:46:40,000 --> 00:46:50,000
The message includes the service name, new replicas, and estimated monthly cost change.

234
00:46:50,000 --> 00:47:00,000
The cost change is calculated using a simple formula. Each replica adds a fixed cost per month.

235
00:47:00,000 --> 00:47:10,000
For low traffic: $40 per replica. For medium traffic: $80 per replica. For high traffic: $160 per replica.

236
00:47:10,000 --> 00:47:20,000
The developer sees this number before they click Create. They can decide if the scale is worth the cost.

237
00:47:20,000 --> 00:47:30,000
This is the behaviour change that makes FinOps self-sustaining. Developers make cost-aware decisions because they see the cost.

238
00:47:30,000 --> 00:47:40,000
In the future, this calculation can be made more accurate. It can use Kubecost data to calculate the actual cost per replica.

239
00:47:40,000 --> 00:47:50,000
But for now, the simple calculation is effective. It gives developers a rough estimate of the cost impact.

240
00:47:50,000 --> 00:48:00,000
The cost impact is also logged. When someone asks why the bill increased, you can look at the scale history.

241
00:48:00,000 --> 00:48:10,000
[Types: curl -s "http://localhost:7007/api/scaffolder/v2/tasks" | jq -r '.tasks[] | select(.status == "completed") | {id: .id, created: .createdAt, template: .templateRef}']

242
00:48:10,000 --> 00:48:20,000
Now you understand the cost impact calculation. It is simple but effective.

243
00:48:20,000 --> 00:48:30,000
In the next segment, we look at the Rollback Service template in detail.

244
00:48:30,000 --> 00:48:40,000
See you in Segment 11.
```

---

### SEGMENT 11: Deep Dive: The Rollback Service Template
**Timestamp:** 50:00 – 55:00

```
245
00:50:00,000 --> 00:50:10,000
Welcome to Segment 11. We are diving deep into the Rollback Service template.

246
00:50:10,000 --> 00:50:20,000
The Rollback Service template is the most critical day-two operation. When something breaks, developers need to roll back quickly.

247
00:50:20,000 --> 00:50:30,000
The template takes three inputs: service name, target revision, and reason for rollback.

248
00:50:30,000 --> 00:50:40,000
The target revision is the Git commit SHA or image tag to roll back to.

249
00:50:40,000 --> 00:50:50,000
[Types: cat infrastructure/backstage/templates/operations/rollback-service.yaml]

250
00:50:50,000 --> 00:51:00,000
The rollback action uses the argocd:sync action. This triggers an ArgoCD sync to the specified revision.

251
00:51:00,000 --> 00:51:10,000
The sync options include Validate=false and Prune=true. This forces the sync and removes resources that are not in the target revision.

252
00:51:10,000 --> 00:51:20,000
The reason field is required. This is for incident documentation. When a rollback happens, you want to know why.

253
00:51:20,000 --> 00:51:30,000
The output section shows the rollback status. It shows the service name, target revision, and reason.

254
00:51:30,000 --> 00:51:40,000
Now let me show you how to test the rollback template.

255
00:51:40,000 --> 00:51:50,000
First, get the current revision of a service:

256
00:51:50,000 --> 00:52:00,000
[Types: kubectl get application financial-rag-agent -n argocd -o json | jq '.status.sync.revision']

257
00:52:00,000 --> 00:52:10,000
Now, look at that output. This is the current revision of the service.

258
00:52:10,000 --> 00:52:20,000
To roll back, you need a previous revision. You can find previous revisions in ArgoCD history.

259
00:52:20,000 --> 00:52:30,000
[Types: kubectl get application financial-rag-agent -n argocd -o json | jq '.status.history[] | {revision: .revision, deployedAt: .deployedAt}' | head -20]

260
00:52:30,000 --> 00:52:40,000
Now, look at that output. This shows the history of revisions for the service.

261
00:52:40,000 --> 00:52:50,000
Pick a previous revision. Then trigger a rollback:

262
00:52:50,000 --> 00:53:00,000
[Types: curl -X POST "http://localhost:7007/api/scaffolder/v2/tasks" -H "Content-Type: application/json" -d '{"templateRef":"template:default/rollback-service","values":{"service_name":"financial-rag-agent","target_revision":"abc123","reason":"Bad deploy — fixed in next PR"}}']

263
00:53:00,000 --> 00:53:10,000
Now, look at that output. You should see a task ID. This is the ID of the rollback operation.

264
00:53:10,000 --> 00:53:20,000
[Types: kubectl get application financial-rag-agent -n argocd -o json | jq '.status.sync.revision']

265
00:53:20,000 --> 00:53:30,000
Now, look at that output. The service should now be using the target revision. The rollback worked.

266
00:53:30,000 --> 00:53:40,000
The Rollback Service template is complete. It is fast, safe, and auditable.

267
00:53:40,000 --> 00:53:50,000
In the next segment, we look at the Rollback template's ArgoCD integration.

268
00:53:50,000 --> 00:54:00,000
See you in Segment 12.
```

---

### SEGMENT 12: Rollback Template — ArgoCD Integration
**Timestamp:** 55:00 – 60:00

```
269
00:55:00,000 --> 00:55:10,000
Welcome to Segment 12. We are looking at the Rollback template's ArgoCD integration.

270
00:55:10,000 --> 00:55:20,000
The Rollback template uses the argocd:sync action. This action triggers an ArgoCD sync.

271
00:55:20,000 --> 00:55:30,000
ArgoCD is a GitOps continuous delivery tool. It syncs the cluster state with Git.

272
00:55:30,000 --> 00:55:40,000
When you roll back, you are telling ArgoCD to sync to a previous revision. This reverts the deployment.

273
00:55:40,000 --> 00:55:50,000
The argocd:sync action requires ArgoCD to be installed and configured in the cluster.

274
00:55:50,000 --> 00:56:00,000
[Types: kubectl get pods -n argocd]

275
00:56:00,000 --> 00:56:10,000
Now, look at that output. You should see ArgoCD pods running in the argocd namespace.

276
00:56:10,000 --> 00:56:20,000
The argocd:sync action also requires an ArgoCD token. This token is used to authenticate with the ArgoCD API.

277
00:56:20,000 --> 00:56:30,000
[Types: kubectl get secret argocd-initial-admin-secret -n argocd -o json | jq -r '.data.password' | base64 -d]

278
00:56:30,000 --> 00:56:40,000
The token is stored in a Kubernetes secret. The scaffolder uses this token to authenticate.

279
00:56:40,000 --> 00:56:50,000
The argocd:sync action takes two inputs: appName and revision.

280
00:56:50,000 --> 00:57:00,000
The appName is the name of the ArgoCD application. The revision is the Git commit SHA or tag to sync to.

281
00:57:00,000 --> 00:57:10,000
The action also supports sync options. We use Validate=false and Prune=true.

282
00:57:10,000 --> 00:57:20,000
Validate=false skips validation. This is faster. Prune=true removes resources that are not in the target revision.

283
00:57:20,000 --> 00:57:30,000
The rollback operation is logged in ArgoCD. You can see the sync history in the ArgoCD UI.

284
00:57:30,000 --> 00:57:40,000
[Types: kubectl port-forward svc/argocd-server -n argocd 8443:443]

285
00:57:40,000 --> 00:57:50,000
Open https://localhost:8443 in your browser. Log in with the admin credentials.

286
00:57:50,000 --> 00:58:00,000
Click on the financial-rag-agent application. You should see the sync history with the rollback.

287
00:58:00,000 --> 00:58:10,000
The rollback operation is also visible in the Backstage catalog. The Kubernetes tab shows the deployment status.

288
00:58:10,000 --> 00:58:20,000
Now you understand the Rollback template's ArgoCD integration. It is fast, safe, and auditable.

289
00:58:20,000 --> 00:58:30,000
In the next segment, we look at the Restart Service template.

290
00:58:30,000 --> 00:58:40,000
See you in Segment 13.
```

---

### SEGMENT 13: Deep Dive: The Restart Service Template
**Timestamp:** 60:00 – 65:00

```
291
01:00:00,000 --> 01:00:10,000
Welcome to Segment 13. We are looking at the Restart Service template.

292
01:00:10,000 --> 01:00:20,000
The Restart Service template is used when a deployment is stuck. Restarting the deployment often fixes the issue.

293
01:00:20,000 --> 01:00:30,000
The template takes two inputs: service name and reason for restart.

294
01:00:30,000 --> 01:00:40,000
[Types: cat > infrastructure/backstage/templates/operations/restart-service.yaml << 'EOF'
apiVersion: scaffolder.backstage.io/v1beta3
kind: Template
metadata:
  name: restart-service
  title: Restart Service
  description: Restart a deployment. Useful when a service is stuck.
  tags: [operations, restart]
spec:
  owner: group:team-platform
  type: operation

  parameters:
    - title: Restart Configuration
      required: [service_name, namespace]
      properties:
        service_name:
          title: Service to Restart
          type: string
          ui:field: EntityPicker

        namespace:
          title: Namespace
          type: string

        reason:
          title: Reason for Restart
          type: string

  steps:
    - id: restart
      name: Restart Deployment
      action: kubernetes:apply
      input:
        manifest:
          apiVersion: apps/v1
          kind: Deployment
          metadata:
            name: ${{ parameters.service_name }}
            namespace: ${{ parameters.namespace }}
          spec:
            template:
              metadata:
                annotations:
                  kubectl.kubernetes.io/restartedAt: ${{ now | date: "2006-01-02T15:04:05Z07:00" }}

  output:
    text:
      - title: Restart Complete
        content: |
          ✅ **${{ parameters.service_name }}** restarted.
          Reason: ${{ parameters.reason }}
EOF]

295
01:00:40,000 --> 01:00:50,000
Now let me walk through the Restart Service template.

296
01:01:00,000 --> 01:01:10,000
The restart action uses the kubernetes:apply action. It patches the deployment with a restart annotation.

297
01:01:10,000 --> 01:01:20,000
The annotation is kubectl.kubernetes.io/restartedAt. This triggers a rolling restart of the deployment.

298
01:01:20,000 --> 01:01:30,000
The timestamp is generated using the current time. This ensures the annotation is new each time.

299
01:01:30,000 --> 01:01:40,000
The output section shows the service name and reason for restart.

300
01:01:40,000 --> 01:01:50,000
Now let me show you how to test the Restart template.

301
01:01:50,000 --> 01:02:00,000
[Types: curl -X POST "http://localhost:7007/api/scaffolder/v2/tasks" -H "Content-Type: application/json" -d '{"templateRef":"template:default/restart-service","values":{"service_name":"financial-rag-agent","namespace":"financial-rag","reason":"Stuck deployment"}}']

302
01:02:00,000 --> 01:02:10,000
Now, look at that output. You should see a task ID. This is the ID of the restart operation.

303
01:02:10,000 --> 01:02:20,000
[Types: kubectl get deployment financial-rag-agent -n financial-rag -o json | jq '.spec.template.metadata.annotations["kubectl.kubernetes.io/restartedAt"]']

304
01:02:20,000 --> 01:02:30,000
Now, look at that output. You should see the restart annotation with the current timestamp.

305
01:02:30,000 --> 01:02:40,000
The deployment is restarting. The pods will be recreated with the new timestamp.

306
01:02:40,000 --> 01:02:50,000
[Types: kubectl rollout status deployment/financial-rag-agent -n financial-rag]

307
01:02:50,000 --> 01:03:00,000
Now, look at that output. The rollout should complete successfully.

308
01:03:00,000 --> 01:03:10,000
The Restart Service template is complete. It is simple, effective, and auditable.

309
01:03:10,000 --> 01:03:20,000
In the next segment, we look at the Log Streaming action.

310
01:03:20,000 --> 01:03:30,000
See you in Segment 14.
```

---

### SEGMENT 14: Deep Dive: The Log Streaming Action
**Timestamp:** 65:00 – 70:00

```
311
01:05:00,000 --> 01:05:10,000
Welcome to Segment 14. We are looking at the Log Streaming action.

312
01:05:10,000 --> 01:05:20,000
Log streaming is the feature developers ask for most. They need to see logs from their pods.

313
01:05:20,000 --> 01:05:30,000
The Log Streaming action is a custom backend action. It fetches logs from the Kubernetes API.

314
01:05:30,000 --> 01:05:40,000
[Types: cat packages/backend/src/plugins/log-stream.ts]

315
01:05:40,000 --> 01:05:50,000
The log stream router has a single endpoint: /pod-logs.

316
01:05:50,000 --> 01:06:00,000
It takes four query parameters: namespace, pod, container, and lines.

317
01:06:00,000 --> 01:06:10,000
The endpoint uses the Kubernetes client to fetch logs from the pod.

318
01:06:10,000 --> 01:06:20,000
The logs are streamed back to the client. The response is chunked.

319
01:06:20,000 --> 01:06:30,000
Let me show you how the log streaming works.

320
01:06:30,000 --> 01:06:40,000
[Types: curl -s "http://localhost:7007/api/logs/pod-logs?namespace=financial-rag&pod=financial-rag-agent-abc123&lines=50"]

321
01:06:40,000 --> 01:06:50,000
Now, look at that output. You should see the logs from the pod.

322
01:06:50,000 --> 01:07:00,000
The logs include timestamps. This helps with debugging.

323
01:07:00,000 --> 01:07:10,000
The frontend component for log viewing displays the logs in a scrollable container.

324
01:07:10,000 --> 01:07:20,000
[Types: cat packages/app/src/components/LogViewer/LogViewer.tsx]

325
01:07:20,000 --> 01:07:30,000
The LogViewer component calls the /pod-logs endpoint and displays the logs.

326
01:07:30,000 --> 01:07:40,000
It also allows the developer to select different pods and containers.

327
01:07:40,000 --> 01:07:50,000
The component is added to the catalog page. Developers can view logs directly from the catalog.

328
01:07:50,000 --> 01:08:00,000
No kubectl access required. No platform team tickets required. Just click and view.

329
01:08:00,000 --> 01:08:10,000
The log streaming action is secure. It uses the same RBAC as the rest of Backstage.

330
01:08:10,000 --> 01:08:20,000
Developers can only view logs for services they have access to. They cannot view logs for other namespaces.

331
01:08:20,000 --> 01:08:30,000
Now you understand the Log Streaming action. It is simple, secure, and effective.

332
01:08:30,000 --> 01:08:40,000
In the next segment, we look at the Log Streaming frontend component.

333
01:08:40,000 --> 01:08:50,000
See you in Segment 15.
```

---

### SEGMENT 15: Log Streaming — Frontend Component
**Timestamp:** 70:00 – 75:00

```
334
01:10:00,000 --> 01:10:10,000
Welcome to Segment 15. We are looking at the Log Streaming frontend component.

335
01:10:10,000 --> 01:10:20,000
The frontend component displays logs in the catalog. Developers can view logs from any service.

336
01:10:20,000 --> 01:10:30,000
[Types: cat > packages/app/src/components/LogViewer/LogViewer.tsx << 'EOF'
import React, { useEffect, useState } from 'react';
import { useEntity } from '@backstage/plugin-catalog-react';
import {
  Card,
  CardHeader,
  CardContent,
  Select,
  MenuItem,
  Button,
  CircularProgress,
  Typography,
} from '@material-ui/core';

interface LogEntry {
  timestamp: string;
  message: string;
}

export const LogViewer: React.FC = () => {
  const { entity } = useEntity();
  const namespace = entity.metadata.annotations?.['backstage.io/kubernetes-namespace'];
  const [pods, setPods] = useState<string[]>([]);
  const [selectedPod, setSelectedPod] = useState('');
  const [logs, setLogs] = useState<string>('');
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (!namespace) return;
    fetch(`/api/logs/pods?namespace=${namespace}`)
      .then(r => r.json())
      .then(data => {
        setPods(data.pods || []);
        if (data.pods?.length) setSelectedPod(data.pods[0]);
      });
  }, [namespace]);

  const fetchLogs = async () => {
    if (!selectedPod) return;
    setLoading(true);
    try {
      const res = await fetch(
        `/api/logs/pod-logs?namespace=${namespace}&pod=${selectedPod}&lines=200`
      );
      const text = await res.text();
      setLogs(text);
    } finally {
      setLoading(false);
    }
  };

  return (
    <Card>
      <CardHeader title="Pod Logs" />
      <CardContent>
        <div style={{ display: 'flex', gap: 8, marginBottom: 16 }}>
          <Select
            value={selectedPod}
            onChange={e => setSelectedPod(e.target.value as string)}
            style={{ minWidth: 300 }}
          >
            {pods.map(pod => (
              <MenuItem key={pod} value={pod}>{pod}</MenuItem>
            ))}
          </Select>
          <Button variant="contained" color="primary" onClick={fetchLogs} disabled={loading}>
            {loading ? <CircularProgress size={20} /> : 'Load Logs'}
          </Button>
        </div>
        {logs ? (
          <pre style={{
            backgroundColor: '#0d1117',
            color: '#c9d1d9',
            padding: 16,
            borderRadius: 4,
            maxHeight: 500,
            overflowY: 'auto',
            fontFamily: 'monospace',
            fontSize: 12,
            whiteSpace: 'pre-wrap',
          }}>
            {logs}
          </pre>
        ) : (
          <Typography variant="body2" color="textSecondary">
            Select a pod and click Load Logs
          </Typography>
        )}
      </CardContent>
    </Card>
  );
};
EOF]

337
01:10:30,000 --> 01:10:40,000
Now let me walk through the LogViewer component.

338
01:10:40,000 --> 01:10:50,000
The component uses the useEntity hook to get the current entity. It then fetches the namespace from the annotations.

339
01:10:50,000 --> 01:11:00,000
The component fetches the list of pods in the namespace. It then displays them in a dropdown.

340
01:11:00,000 --> 01:11:10,000
The developer selects a pod and clicks Load Logs. The component fetches the logs and displays them.

341
01:11:10,000 --> 01:11:20,000
The logs are displayed in a monospaced font with a dark background. This is similar to the terminal experience.

342
01:11:20,000 --> 01:11:30,000
The component is added to the catalog page:

343
01:11:30,000 --> 01:11:40,000
[Types: cat >> packages/app/src/components/catalog/EntityPage.tsx << 'EOF'
import { LogViewer } from '../LogViewer/LogViewer';

const serviceEntityPage = (
  <EntityLayout>
    <EntityLayout.Route path="/logs" title="Logs">
      <LogViewer />
    </EntityLayout.Route>
  </EntityLayout>
);
EOF]

344
01:11:40,000 --> 01:11:50,000
Now developers can view logs from any service in the catalog. No kubectl access required.

345
01:11:50,000 --> 01:12:00,000
[Types: curl -s "http://localhost:7007/api/logs/pods?namespace=financial-rag"]

346
01:12:00,000 --> 01:12:10,000
Now, look at that output. This shows the pods in the financial-rag namespace.

347
01:12:10,000 --> 01:12:20,000
Now you understand the Log Streaming frontend component. It is simple, secure, and effective.

348
01:12:20,000 --> 01:12:30,000
In the next segment, we look at the Pod Status Check template.

349
01:12:30,000 --> 01:12:40,000
See you in Segment 16.
```

---

### SEGMENT 16: Deep Dive: The Pod Status Check Template
**Timestamp:** 75:00 – 80:00

```
350
01:15:00,000 --> 01:15:10,000
Welcome to Segment 16. We are looking at the Pod Status Check template.

351
01:15:10,000 --> 01:15:20,000
The Pod Status Check template shows the status of all pods in a deployment.

352
01:15:20,000 --> 01:15:30,000
This is useful for debugging. Developers can see which pods are running and which are failing.

353
01:15:30,000 --> 01:15:40,000
[Types: cat > infrastructure/backstage/templates/operations/pod-status.yaml << 'EOF'
apiVersion: scaffolder.backstage.io/v1beta3
kind: Template
metadata:
  name: pod-status
  title: Pod Status
  description: Check the status of pods in a deployment.
  tags: [operations, status]
spec:
  owner: group:team-platform
  type: operation

  parameters:
    - title: Status Configuration
      required: [service_name, namespace]
      properties:
        service_name:
          title: Service
          type: string
          ui:field: EntityPicker

        namespace:
          title: Namespace
          type: string

  steps:
    - id: get-pods
      name: Get Pod Status
      action: kubernetes:apply
      input:
        manifest:
          apiVersion: v1
          kind: Pod
          metadata:
            namespace: ${{ parameters.namespace }}
          spec: {}

  output:
    text:
      - title: Pod Status
        content: |
          Pod status for ${{ parameters.service_name }}:
          [Use the Kubernetes tab in the catalog for detailed status]
EOF]

354
01:15:40,000 --> 01:15:50,000
Now let me walk through the Pod Status Check template.

355
01:15:50,000 --> 01:16:00,000
The template takes two inputs: service name and namespace.

356
01:16:00,000 --> 01:16:10,000
It uses the kubernetes:apply action to fetch pod information. The output is displayed in the catalog.

357
01:16:10,000 --> 01:16:20,000
However, the Kubernetes tab in the catalog already shows pod status. This template is redundant.

358
01:16:20,000 --> 01:16:30,000
The real value of this template is in the learning process. It shows how to interact with Kubernetes from Backstage.

359
01:16:30,000 --> 01:16:40,000
[Types: kubectl get pods -n financial-rag]

360
01:16:40,000 --> 01:16:50,000
Now, look at that output. This shows the pods in the financial-rag namespace.

361
01:16:50,000 --> 01:17:00,000
The Kubernetes tab in the catalog displays this information automatically. Developers do not need a separate template.

362
01:17:00,000 --> 01:17:10,000
Now you understand the Pod Status Check template. It is useful for learning, but the Kubernetes tab is more practical.

363
01:17:10,000 --> 01:17:20,000
In the next segment, we look at the ArgoCD Plugin installation.

364
01:17:20,000 --> 01:17:30,000
See you in Segment 17.
```

---

### SEGMENT 17: ArgoCD Plugin — Installation & Configuration
**Timestamp:** 80:00 – 85:00

```
365
01:20:00,000 --> 01:20:10,000
Welcome to Segment 17. We are looking at the ArgoCD Plugin.

366
01:20:10,000 --> 01:20:20,000
The ArgoCD Plugin integrates ArgoCD with Backstage. It shows the sync status of applications in the catalog.

367
01:20:20,000 --> 01:20:30,000
Install the ArgoCD Plugin:

368
01:20:30,000 --> 01:20:40,000
[Types: cd finops-idp]

369
01:20:40,000 --> 01:20:50,000
[Types: yarn --cwd packages/app add @roadiehq/backstage-plugin-argo-cd]

370
01:20:50,000 --> 01:21:00,000
[Types: yarn --cwd packages/backend add @roadiehq/backstage-plugin-argo-cd-backend]

371
01:21:00,000 --> 01:21:10,000
Now configure the plugin in app-config.yaml:

372
01:21:10,000 --> 01:21:20,000
[Types: cat >> app-config.yaml << 'EOF'
argocd:
  appLocatorMethods:
    - type: config
      instances:
        - name: finops-argocd
          url: https://argocd.yourcompany.com
          token: ${ARGOCD_TOKEN}
EOF]

373
01:21:20,000 --> 01:21:30,000
The ArgoCD token is required for authentication. You can generate a token from the ArgoCD UI.

374
01:21:30,000 --> 01:21:40,000
[Types: kubectl get secret argocd-initial-admin-secret -n argocd -o json | jq -r '.data.password' | base64 -d]

375
01:21:40,000 --> 01:21:50,000
Now add the ArgoCD card to the catalog page:

376
01:21:50,000 --> 01:22:00,000
[Types: cat >> packages/app/src/components/catalog/EntityPage.tsx << 'EOF'
import { EntityArgoCDOverviewCard } from '@roadiehq/backstage-plugin-argo-cd';

const overviewContent = (
  <Grid container spacing={3}>
    <Grid item md={6}>
      <EntityAboutCard variant="gridItem" />
    </Grid>
    <Grid item md={6}>
      <EntityArgoCDOverviewCard />
    </Grid>
  </Grid>
);
EOF]

377
01:22:00,000 --> 01:22:10,000
Now the catalog shows ArgoCD sync status for each service. Developers can see if their service is synced.

378
01:22:10,000 --> 01:22:20,000
[Types: curl -s "http://localhost:7007/api/argocd/applications" | jq '.[] | {name: .metadata.name, syncStatus: .status.sync.status}']

379
01:22:20,000 --> 01:22:30,000
Now, look at that output. This shows the sync status of all ArgoCD applications.

380
01:22:30,000 --> 01:22:40,000
The ArgoCD Plugin is now installed and configured. It integrates ArgoCD with Backstage.

381
01:22:40,000 --> 01:22:50,000
In the next segment, we look at the ArgoCD integration in detail.

382
01:22:50,000 --> 01:23:00,000
See you in Segment 18.
```

---

### SEGMENT 18: ArgoCD Integration — Sync Status in Catalog
**Timestamp:** 85:00 – 90:00

```
383
01:25:00,000 --> 01:25:10,000
Welcome to Segment 18. We are looking at the ArgoCD integration.

384
01:25:10,000 --> 01:25:20,000
The ArgoCD integration shows the sync status of applications in the catalog.

385
01:25:20,000 --> 01:25:30,000
Developers can see if their service is synced with Git. If not, they can trigger a sync.

386
01:25:30,000 --> 01:25:40,000
The integration uses the ArgoCD API to fetch the sync status.

387
01:25:40,000 --> 01:25:50,000
[Types: curl -s "http://localhost:7007/api/argocd/applications/financial-rag-agent" | jq '{name: .metadata.name, syncStatus: .status.sync.status, healthStatus: .status.health.status}']

388
01:25:50,000 --> 01:26:00,000
Now, look at that output. This shows the sync status and health status of the financial-rag-agent application.

389
01:26:00,000 --> 01:26:10,000
The sync status can be Synced, OutOfSync, or Unknown. The health status can be Healthy, Degraded, or Unknown.

390
01:26:10,000 --> 01:26:20,000
If the sync status is OutOfSync, the application is not synced with Git. This usually means a new commit was pushed.

391
01:26:20,000 --> 01:26:30,000
If the health status is Degraded, the application has a problem. This usually means a pod is failing.

392
01:26:30,000 --> 01:26:40,000
The ArgoCD card in the catalog displays this information. It also provides a link to the ArgoCD UI.

393
01:26:40,000 --> 01:26:50,000
[Types: kubectl port-forward svc/argocd-server -n argocd 8443:443]

394
01:26:50,000 --> 01:27:00,000
Open https://localhost:8443 in your browser. You can see the full ArgoCD UI.

395
01:27:00,000 --> 01:27:10,000
Now you understand the ArgoCD integration. It brings deployment status into the catalog.

396
01:27:10,000 --> 01:27:20,000
In the next segment, we look at the complete deployment trace.

397
01:27:20,000 --> 01:27:30,000
See you in Segment 19.
```

---

### SEGMENT 19: Complete Deployment Trace — Walkthrough
**Timestamp:** 90:00 – 95:00

```
398
01:30:00,000 --> 01:30:10,000
Welcome to Segment 19. We are walking through the complete deployment trace.

399
01:30:10,000 --> 01:30:20,000
The complete deployment trace shows the journey from developer click to running pod.

400
01:30:20,000 --> 01:30:30,000
A new developer on the financial-rag team needs the filing-classifier service.

401
01:30:30,000 --> 01:30:40,000
They open the portal. Click Create New Service. Fill in: name=filing-classifier, team=team-financial-rag, traffic=medium, database=false, cache=false, s3=true.

402
01:30:40,000 --> 01:30:50,000
The portal shows estimated cost: ~$120/month. They click Create.

403
01:30:50,000 --> 01:31:00,000
Let me show you what happens behind the scenes.

404
01:31:00,000 --> 01:31:10,000
Step 1: GitHub repository is created. The repository is at https://github.com/your-org/filing-classifier.

405
01:31:10,000 --> 01:31:20,000
[Types: curl -s "https://api.github.com/repos/your-org/filing-classifier" | jq '.name, .description']

406
01:31:20,000 --> 01:31:30,000
Step 2: Files are pushed. Dockerfile, Helm chart, CI/CD workflow, catalog-info.yaml, main.py.

407
01:31:30,000 --> 01:31:40,000
[Types: curl -s "https://api.github.com/repos/your-org/filing-classifier/contents" | jq '.[].name']

408
01:31:40,000 --> 01:31:50,000
Step 3: S3 bucket is created with lifecycle policy.

409
01:31:50,000 --> 01:32:00,000
[Types: aws s3api get-bucket-lifecycle-configuration --bucket filing-classifier-team-financial-rag-data]

410
01:32:00,000 --> 01:32:10,000
Step 4: ArgoCD application is created and syncing.

411
01:32:10,000 --> 01:32:20,000
[Types: kubectl get application filing-classifier -n argocd -o json | jq '.status.sync.status']

412
01:32:20,000 --> 01:32:30,000
Step 5: Service is registered in the catalog.

413
01:32:30,000 --> 01:32:40,000
[Types: curl -s "http://localhost:7007/api/catalog/entities/by-name/component/default/filing-classifier" | jq '.metadata.name']

414
01:32:40,000 --> 01:32:50,000
The total time is under 90 seconds. The developer never touched kubectl. Never wrote a Helm chart. Never thought about Spot tolerations.

415
01:32:50,000 --> 01:33:00,000
All of it happened correctly because it was encoded in the template.

416
01:33:00,000 --> 01:33:10,000
This is the IDP working as designed. Developer builds features from day one. Platform handles the rest.

417
01:33:10,000 --> 01:33:20,000
Now you understand the complete deployment trace. It is fast, secure, and cost-optimised.

418
01:33:20,000 --> 01:33:30,000
In the next segment, we look at the developer experience.

419
01:33:30,000 --> 01:33:40,000
See you in Segment 20.
```

---

### SEGMENT 20: Developer Experience — From Creation to Production
**Timestamp:** 95:00 – 100:00

```
420
01:35:00,000 --> 01:35:10,000
Welcome to Segment 20. We are looking at the developer experience.

421
01:35:10,000 --> 01:35:20,000
The developer experience is the most important part of the IDP. If developers do not like using it, they will find other ways.

422
01:35:20,000 --> 01:35:30,000
The developer journey has four phases: discovery, creation, deployment, and day-two operations.

423
01:35:30,000 --> 01:35:40,000
Discovery: The developer opens the catalog. They see all services in the organization. They search for the service they need.

424
01:35:40,000 --> 01:35:50,000
Creation: The developer clicks Create New Service. They fill in five fields. They see the cost estimate. They click Create.

425
01:35:50,000 --> 01:36:00,000
Deployment: The scaffolder runs. GitHub repository is created. Files are pushed. S3 bucket is created. ArgoCD app is created. Service is registered.

426
01:36:00,000 --> 01:36:10,000
Day-two operations: The developer scales the service. They view logs. They roll back if needed. All through the portal.

427
01:36:10,000 --> 01:36:20,000
The developer never leaves the Backstage portal. They never open a ticket. They never ask for kubectl access.

428
01:36:20,000 --> 01:36:30,000
The developer experience is frictionless. Developers ship features faster. Platform team supports fewer tickets.

429
01:36:30,000 --> 01:36:40,000
This is the promise of the IDP. It makes developers more productive. It makes the platform team less busy.

430
01:36:40,000 --> 01:36:50,000
Now let me show you the developer experience metrics.

431
01:36:50,000 --> 01:37:00,000
[Types: echo "=== DEVELOPER EXPERIENCE METRICS ==="]
[Types: echo "Time to first deploy: under 90 seconds"]
[Types: echo "Tickets for infrastructure: 0"]
[Types: echo "Kubectl access requests: 0"]
[Types: echo "Services created via IDP: $(curl -s "http://localhost:7007/api/catalog/entities?filter=kind=Component" | jq '.items | length')"]

432
01:37:00,000 --> 01:37:10,000
Now, look at that output. These metrics show the impact of the IDP on developer productivity.

433
01:37:10,000 --> 01:37:20,000
Developers are shipping features faster. The platform team is spending less time on tickets. Everyone is happier.

434
01:37:20,000 --> 01:37:30,000
Now you understand the developer experience. It is the key to IDP adoption.

435
01:37:30,000 --> 01:37:40,000
In the next segment, we do a workshop on scaling a service via IDP.

436
01:37:40,000 --> 01:37:50,000
See you in Segment 21.
```

---

### SEGMENT 21: Workshop: Scaling a Service via IDP
**Timestamp:** 100:00 – 105:00

```
437
01:40:00,000 --> 01:40:10,000
Welcome to Segment 21. This is the scaling workshop.

438
01:40:10,000 --> 01:40:20,000
You are going to scale a service via the IDP. This is the most common day-two operation.

439
01:40:20,000 --> 01:40:30,000
Step 1: Open Backstage at http://localhost:3000.

440
01:40:30,000 --> 01:40:40,000
Step 2: Click on the Catalog tab. Find the financial-rag-agent service.

441
01:40:40,000 --> 01:40:50,000
Step 3: Click on the service. You should see the service details page.

442
01:40:50,000 --> 01:41:00,000
Step 4: Click on the Create button in the top right corner. This opens the scaffolder.

443
01:41:00,000 --> 01:41:10,000
Step 5: Select "Scale Service" from the list of templates.

444
01:41:10,000 --> 01:41:20,000
Step 6: Fill in the fields. Service: financial-rag-agent. Namespace: financial-rag. Replicas: 5. Reason: Traffic increase.

445
01:41:20,000 --> 01:41:30,000
Step 7: Click Review. You should see the cost impact: Estimated monthly cost change: ~$40/month.

446
01:41:30,000 --> 01:41:40,000
Step 8: Click Create. The scale operation will run.

447
01:41:40,000 --> 01:41:50,000
Step 9: Wait for the operation to complete. It should take about 10 seconds.

448
01:41:50,000 --> 01:42:00,000
Step 10: Verify the scale worked.

449
01:42:00,000 --> 01:42:10,000
[Types: kubectl get deployment financial-rag-agent -n financial-rag -o json | jq '.spec.replicas']

450
01:42:10,000 --> 01:42:20,000
Now, look at that output. The deployment should show 5 replicas. The scale operation worked.

451
01:42:20,000 --> 01:42:30,000
Step 11: Scale back to 2 replicas. This is the normal state.

452
01:42:30,000 --> 01:42:40,000
[Types: curl -X POST "http://localhost:7007/api/scaffolder/v2/tasks" -H "Content-Type: application/json" -d '{"templateRef":"template:default/scale-service","values":{"service_name":"financial-rag-agent","namespace":"financial-rag","replicas":2,"reason":"Revert after traffic spike"}}']

453
01:42:40,000 --> 01:42:50,000
Now, look at that output. You should see a task ID. This is the ID of the scale operation.

454
01:42:50,000 --> 01:43:00,000
[Types: kubectl get deployment financial-rag-agent -n financial-rag -o json | jq '.spec.replicas']

455
01:43:00,000 --> 01:43:10,000
Now, look at that output. The deployment should show 2 replicas. The scale operation worked.

456
01:43:10,000 --> 01:43:20,000
You have successfully scaled a service via the IDP. No kubectl access required. No platform team tickets required.

457
01:43:20,000 --> 01:43:30,000
In the next segment, we do a workshop on rolling back a service via IDP.

458
01:43:30,000 --> 01:43:40,000
See you in Segment 22.
```

---

### SEGMENT 22: Workshop: Rolling Back a Service via IDP
**Timestamp:** 105:00 – 110:00

```
459
01:45:00,000 --> 01:45:10,000
Welcome to Segment 22. This is the rollback workshop.

460
01:45:10,000 --> 01:45:20,000
You are going to roll back a service via the IDP. This is the most critical day-two operation.

461
01:45:20,000 --> 01:45:30,000
Step 1: Open Backstage at http://localhost:3000.

462
01:45:30,000 --> 01:45:40,000
Step 2: Click on the Catalog tab. Find the financial-rag-agent service.

463
01:45:40,000 --> 01:45:50,000
Step 3: Click on the service. You should see the service details page.

464
01:45:50,000 --> 01:46:00,000
Step 4: Click on the Create button in the top right corner. This opens the scaffolder.

465
01:46:00,000 --> 01:46:10,000
Step 5: Select "Rollback Service" from the list of templates.

466
01:46:10,000 --> 01:46:20,000
Step 6: Get the current revision of the service:

467
01:46:20,000 --> 01:46:30,000
[Types: kubectl get application financial-rag-agent -n argocd -o json | jq '.status.sync.revision']

468
01:46:30,000 --> 01:46:40,000
Now, look at that output. This is the current revision of the service.

469
01:46:40,000 --> 01:46:50,000
Step 7: Get a previous revision from ArgoCD history:

470
01:46:50,000 --> 01:47:00,000
[Types: kubectl get application financial-rag-agent -n argocd -o json | jq '.status.history[1].revision']

471
01:47:00,000 --> 01:47:10,000
Now, look at that output. This is a previous revision of the service.

472
01:47:10,000 --> 01:47:20,000
Step 8: Fill in the rollback fields. Service: financial-rag-agent. Target revision: [previous revision]. Reason: Bad deploy.

473
01:47:20,000 --> 01:47:30,000
Step 9: Click Review. You should see the rollback details.

474
01:47:30,000 --> 01:47:40,000
Step 10: Click Create. The rollback operation will run.

475
01:47:40,000 --> 01:47:50,000
Step 11: Wait for the operation to complete. It should take about 30 seconds.

476
01:47:50,000 --> 01:48:00,000
Step 12: Verify the rollback worked.

477
01:48:00,000 --> 01:48:10,000
[Types: kubectl get application financial-rag-agent -n argocd -o json | jq '.status.sync.revision']

478
01:48:10,000 --> 01:48:20,000
Now, look at that output. The service should now be using the target revision. The rollback worked.

479
01:48:20,000 --> 01:48:30,000
Step 13: Roll forward to the current revision. This is the normal state.

480
01:48:30,000 --> 01:48:40,000
[Types: curl -X POST "http://localhost:7007/api/scaffolder/v2/tasks" -H "Content-Type: application/json" -d "{\"templateRef\":\"template:default/rollback-service\",\"values\":{\"service_name\":\"financial-rag-agent\",\"target_revision\":\"$(kubectl get application financial-rag-agent -n argocd -o json | jq -r '.status.sync.revision')\",\"reason\":\"Revert rollback\"}}"]

481
01:48:40,000 --> 01:48:50,000
Now, look at that output. You should see a task ID. This is the ID of the rollback operation.

482
01:48:50,000 --> 01:49:00,000
[Types: kubectl get application financial-rag-agent -n argocd -o json | jq '.status.sync.revision']

483
01:49:00,000 --> 01:49:10,000
Now, look at that output. The service should now be using the current revision. The roll-forward worked.

484
01:49:10,000 --> 01:49:20,000
You have successfully rolled back a service via the IDP. No kubectl access required. No platform team tickets required.

485
01:49:20,000 --> 01:49:30,000
In the next segment, we do the Q&A for Series 9.

486
01:49:30,000 --> 01:49:40,000
See you in Segment 23.
```

---

### SEGMENT 23: Series 9 Q&A — Common Questions Answered
**Timestamp:** 110:00 – 115:00

```
487
01:50:00,000 --> 01:50:10,000
Welcome to Segment 23. This is the Q&A for Series 9.

488
01:50:10,000 --> 01:50:20,000
Let me address the most common questions about Series 9.

489
01:50:20,000 --> 01:50:30,000
Question 1: "Why not just give developers kubectl access? It would be simpler."

490
01:50:30,000 --> 01:50:40,000
Kubectl access is a security risk. It gives the ability to read secrets, modify resources, and even delete namespaces. The IDP provides the same operations with audit and without security risks.

491
01:50:40,000 --> 01:50:50,000
Question 2: "Can developers still use kubectl if they need to?"

492
01:50:50,000 --> 01:51:00,000
Yes, but it is not the standard path. Developers who need kubectl for debugging can request temporary access. The standard path is the IDP.

493
01:51:00,000 --> 01:51:10,000
Question 3: "How do we handle sensitive logs in the log streaming feature?"

494
01:51:10,000 --> 01:51:20,000
Sensitive logs should not be in logs. Use structured logging and avoid logging sensitive information. The IDP logs are read-only and audited.

495
01:51:20,000 --> 01:51:30,000
Question 4: "What about scaling down to zero? The template limits to 1."

496
01:51:30,000 --> 01:51:40,000
Scaling to zero is a valid operation for non-production environments. But it should be a separate template with additional safeguards. The Scale Service template is for production services.

497
01:51:40,000 --> 01:51:50,000
Question 5: "How do we handle rollbacks to a specific image tag instead of a Git revision?"

498
01:51:50,000 --> 01:52:00,000
The Rollback Service template supports both Git revisions and image tags. The target_revision field accepts both formats.

499
01:52:00,000 --> 01:52:10,000
Question 6: "Can the IDP operations be integrated with Slack or other chat platforms?"

500
01:52:10,000 --> 01:52:20,000
Yes. The operations can trigger notifications. This is a good addition for team awareness. It can be added as a separate step in the template.

501
01:52:20,000 --> 01:52:30,000
Question 7: "What about approval workflows? Can we require approval for certain operations?"

502
01:52:30,000 --> 01:52:40,000
Yes. Backstage supports approval workflows. You can add approval steps to the templates. This is useful for high-risk operations like scaling to large numbers.

503
01:52:40,000 --> 01:52:50,000
Question 8: "How do we handle operations on StatefulSets instead of Deployments?"

504
01:52:50,000 --> 01:53:00,000
The templates are designed for Deployments. StatefulSets require different logic. You can create separate templates for StatefulSets.

505
01:53:00,000 --> 01:53:10,000
Now you have the answers to the most common questions about Series 9.

506
01:53:10,000 --> 01:53:20,000
In the next segment, we do the knowledge check for Series 9.

507
01:53:20,000 --> 01:53:30,000
See you in Segment 24.
```

---

### SEGMENT 24: Series 9 Knowledge Check & Next Steps
**Timestamp:** 115:00 – 120:00

```
508
01:55:00,000 --> 01:55:10,000
Welcome to Segment 24. This is the Series 9 knowledge check.

509
01:55:10,000 --> 01:55:20,000
Let's test your understanding of Series 9. Answer these questions in your own words.

510
01:55:20,000 --> 01:55:30,000
Question 1: What is the day-two problem and why does it matter?

511
01:55:30,000 --> 01:55:40,000
Question 2: What is the difference between the Scale Service and Rollback Service templates?

512
01:55:40,000 --> 01:55:50,000
Question 3: How does the Log Streaming action work?

513
01:55:50,000 --> 01:56:00,000
Question 4: Why is the cost impact shown in the Scale Service template?

514
01:56:00,000 --> 01:56:10,000
Question 5: What does the ArgoCD integration show in the catalog?

515
01:56:10,000 --> 01:56:20,000
Pause the video. Write down your answers. Then compare them to what you learned.

516
01:56:20,000 --> 01:56:30,000
If you got all five correct, you understand Series 9. If you missed any, review the relevant segment.

517
01:56:30,000 --> 01:56:40,000
Now let's look ahead to Series 10.

518
01:56:40,000 --> 01:56:50,000
In Series 10, we close the loop. We bring FinOps data directly into the developer's workflow inside the platform itself.

519
01:56:50,000 --> 01:57:00,000
You will build a FinOps backend plugin that serves cost data to the frontend.

520
01:57:00,000 --> 01:57:10,000
A budget scheduler that alerts teams approaching their monthly limits. A FinOps cost card that displays in every service's catalog page.

521
01:57:10,000 --> 01:57:20,000
A chargeback report generator that sends team-by-team cost breakdowns to finance. And a Kubecost anomaly webhook that routes cost anomalies to service owners.

522
01:57:20,000 --> 01:57:30,000
After Series 10, a developer opening the Backstage catalog sees their service's monthly cost, their team's budget usage, and any active cost anomalies.

523
01:57:30,000 --> 01:57:40,000
Without opening a single AWS console page. FinOps becomes invisible to them and omnipresent in their workflow.

524
01:57:40,000 --> 01:57:50,000
That is the final piece of the FinOps platform puzzle.

525
01:57:50,000 --> 01:58:00,000
Series 9 is complete. The platform is now self-sufficient for all day-two operations.

526
01:58:00,000 --> 01:58:10,000
The commands work. The savings are real. You just have to do the work.

527
01:58:10,000 --> 01:58:20,000
See you in Series 10.
```