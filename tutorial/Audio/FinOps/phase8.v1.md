Here is your complete Series 8 SRT with all Type: lines and their corresponding Pronounced at: lines edited to type-along, precedential style. All headers, timestamps, numbering, narrative, and command blocks remain exactly as you provided.

---

Series 8: Backstage Scaffolder — The Golden Path Template
Complete 24-Segment SRT — 2 Hours

---

SEGMENT 1: What You're Building & The Scaffolder Architecture
Timestamp: 00:00 – 05:00

```
1
00:00:00,000 --> 00:00:10,000
Welcome to Series 8. This is where the catalog becomes a deployment machine.

2
00:00:10,000 --> 00:00:20,000
In Series 7, you built the foundation. Backstage is running. Your services are registered. The catalog is populated.

3
00:00:20,000 --> 00:00:30,000
Now we turn that foundation into a self-service deployment platform. A developer opens the portal, fills in five fields, and gets a complete service.

4
00:00:30,000 --> 00:00:40,000
Let me show you what you are building before we build it.

5
00:00:40,000 --> 00:00:50,000
Today, when a developer needs a new service, they clone a repo, modify a Dockerfile, copy a Helm chart, spend an afternoon figuring out ArgoCD, open three tickets, and wait two days.

6
00:00:50,000 --> 00:01:00,000
By the end of this series, they open the portal, fill in five fields, click Create, and in 90 seconds they have everything.

7
00:01:00,000 --> 00:01:10,000
A GitHub repository with production-ready code structure. A multi-arch Dockerfile — amd64 and arm64 — so the service can run on Graviton Spot instances from day one.

8
00:01:10,000 --> 00:01:20,000
A Helm chart with resource requests sized to their expected traffic tier — not a guess, a calibrated starting point based on what similar services actually use.

9
00:01:20,000 --> 00:01:30,000
Spot tolerations pre-applied for low and medium traffic services. An S3 bucket with lifecycle policy already configured. An ArgoCD application wired to the cluster.

10
00:01:30,000 --> 00:01:40,000
The service registered in the catalog. And — most importantly — an estimated monthly cost displayed before they click confirm.

11
00:01:40,000 --> 00:01:50,000
That last item is the behaviour change that makes FinOps self-sustaining. When a developer sees $120 a month before deploying, they understand what infrastructure costs.

12
00:01:50,000 --> 00:02:00,000
They start asking why. They start comparing. They start making better decisions — not because they were told to, but because the information is right there.

13
00:02:00,000 --> 00:02:10,000
The Scaffolder architecture has three layers. The developer portal UI — a form where developers fill in service name, team, expected traffic, database, and cache.

14
00:02:10,000 --> 00:02:20,000
The Scaffolder engine — executes steps defined in template YAML in sequence. Each step calls an action — create GitHub repo, push files, create ArgoCD app, register catalog entity.

15
00:02:20,000 --> 00:02:30,000
The integrations — GitHub API, Kubernetes API, Catalog API. All the actions are pre-built. You just configure them.

16
00:02:30,000 --> 00:02:40,000
Before we write the template, install the required plugins. These add the actions that the template uses.

17
00:02:40,000 --> 00:02:50,000
[Types: cd finops-idp]
▶ Pronounced as: "Now changing into the finops-idp directory."

18
00:02:50,000 --> 00:03:00,000
[Types: yarn --cwd packages/backend add @backstage/plugin-scaffolder-backend-module-github]
▶ Pronounced as: "Now installing the GitHub scaffolder module."

19
00:03:00,000 --> 00:03:10,000
[Types: yarn --cwd packages/backend add @backstage/plugin-scaffolder-backend-module-kubernetes]
▶ Pronounced as: "Now installing the Kubernetes scaffolder module."

20
00:03:10,000 --> 00:03:20,000
[Types: yarn --cwd packages/backend add @backstage/plugin-scaffolder-backend-module-aws]
▶ Pronounced as: "Now installing the AWS scaffolder module."

21
00:03:20,000 --> 00:03:30,000
[Types: yarn --cwd packages/app add @roadiehq/backstage-plugin-argo-cd]
▶ Pronounced as: "Now installing the ArgoCD frontend plugin."

22
00:03:30,000 --> 00:03:40,000
[Types: yarn --cwd packages/backend add @roadiehq/backstage-plugin-argo-cd-backend]
▶ Pronounced as: "Now installing the ArgoCD backend plugin."

23
00:03:40,000 --> 00:03:50,000
Now, look at that output. The plugins are installed. The actions are registered. The template can now use them.

24
00:03:50,000 --> 00:04:00,000
Let me explain what each plugin does.

25
00:04:00,000 --> 00:04:10,000
The GitHub module provides the publish:github action. This creates a GitHub repository and pushes files to it.

26
00:04:10,000 --> 00:04:20,000
The Kubernetes module provides the kubernetes:apply action. This applies Kubernetes manifests to the cluster.

27
00:04:20,000 --> 00:04:30,000
The AWS module provides the aws:s3:create action. This creates S3 buckets with lifecycle policies.

28
00:04:30,000 --> 00:04:40,000
The ArgoCD plugin provides the argocd:create-resources action. This creates ArgoCD applications.

29
00:04:40,000 --> 00:04:50,000
Together, these actions do everything we need. Create a repo. Push files. Create an S3 bucket. Create an ArgoCD app. Register in the catalog.

30
00:04:50,000 --> 00:05:00,000
In the next segment, we write the template — the most important file we create in this entire course.

31
00:05:00,000 --> 00:05:10,000
See you in Segment 2.
```

---

SEGMENT 2: The Golden Path Template — Parameters Section
Timestamp: 05:00 – 10:00

```
32
00:05:00,000 --> 00:05:10,000
The template YAML has three sections: parameters, steps, and output.

33
00:05:10,000 --> 00:05:20,000
Parameters are the form fields developers fill in. Steps are the actions that execute when they click create. Output is the links they receive when it is done.

34
00:05:20,000 --> 00:05:30,000
The parameters section is the user experience. Keep it minimal. Five questions is the maximum for adoption.

35
00:05:30,000 --> 00:05:40,000
If a developer has to make more than five decisions to create a service, they will find a shortcut — and the shortcut will bypass your cost controls.

36
00:05:40,000 --> 00:05:50,000
[Types: mkdir -p infrastructure/backstage/templates/microservice]
▶ Pronounced as: "Now creating the template directory structure."

37
00:05:50,000 --> 00:06:00,000
[Types: cat > infrastructure/backstage/templates/microservice/template.yaml << 'EOF'
apiVersion: scaffolder.backstage.io/v1beta3
kind: Template
metadata:
  name: microservice-finops
  title: Microservice (FinOps Optimized)
  description: >
    Creates a production-ready microservice with FinOps best practices built in.
    Includes: Spot tolerations, resource requests by traffic tier, S3 lifecycle
    policy, ArgoCD deployment, and pre-deploy cost estimate.
  tags: [python, fastapi, production, finops, recommended]
spec:
  owner: group:team-platform
  type: service

  parameters:
    - title: Service Information
      required: [name, team, description]
      properties:
        name:
          title: Service Name
          type: string
          description: Lowercase, hyphens only. Becomes your GitHub repo, namespace, and ArgoCD app name.
          pattern: '^[a-z][a-z0-9-]{2,39}$'
          ui:autofocus: true

        team:
          title: Owning Team
          type: string
          ui:field: OwnerPicker
          ui:options:
            catalogFilter:
              kind: Group

        description:
          title: Service Description
          type: string
          ui:widget: textarea

    - title: Infrastructure Configuration
      required: [traffic_tier]
      properties:
        traffic_tier:
          title: Expected Traffic Tier
          type: string
          enum: [low, medium, high]
          enumNames:
            - "Low (< 100 req/s) — Spot eligible, ~$60/month"
            - "Medium (100-1000 req/s) — Spot eligible, ~$120/month"
            - "High (> 1000 req/s) — On-Demand required, ~$280/month"
          default: low

        needs_database:
          title: Does this service need a PostgreSQL database?
          type: boolean
          default: false

        needs_cache:
          title: Does this service need Redis cache?
          type: boolean
          default: false

        needs_s3:
          title: Does this service need an S3 bucket?
          type: boolean
          default: false
EOF]
▶ Pronounced as: "Now creating the template.yaml file with the parameters section."

38
00:06:00,000 --> 00:06:10,000
The traffic tier enum is the key FinOps design decision. The developer picks their expected load.

39
00:06:10,000 --> 00:06:20,000
The template uses that choice to set resource requests, enable or disable Spot tolerations, and show the cost estimate.

40
00:06:20,000 --> 00:06:30,000
One field drives three cost-critical decisions automatically. The developer never thinks about Spot tolerations, CPU requests, or lifecycle policies.

41
00:06:30,000 --> 00:06:40,000
They think about traffic. The template does the rest.

42
00:06:40,000 --> 00:06:50,000
The name field has a pattern — '^[a-z][a-z0-9-]{2,39}$'. This enforces lowercase, hyphens only, and a minimum of three characters.

43
00:06:50,000 --> 00:07:00,000
This prevents invalid names that would break Kubernetes naming conventions. The developer cannot create a service with an invalid name.

44
00:07:00,000 --> 00:07:10,000
The team field uses the OwnerPicker UI widget. This pulls from the catalog groups. The developer selects their team from a dropdown.

45
00:07:10,000 --> 00:07:20,000
The description field is a text area. This is where the developer describes what the service does.

46
00:07:20,000 --> 00:07:30,000
The infrastructure configuration section has three booleans. Does the service need a database? A cache? An S3 bucket?

47
00:07:30,000 --> 00:07:40,000
Each boolean triggers additional infrastructure creation. If needs_s3 is true, the template creates an S3 bucket with lifecycle policy.

48
00:07:40,000 --> 00:07:50,000
Now let's look at how the cost estimate is displayed. The enumNames for traffic_tier include the estimated cost.

49
00:07:50,000 --> 00:08:00,000
"Low (< 100 req/s) — Spot eligible, ~$60/month". The developer sees the cost before they even select the tier.

50
00:08:00,000 --> 00:08:10,000
This is the cost visibility we want. The developer sees the cost estimate before they make any decisions.

51
00:08:10,000 --> 00:08:20,000
Later, in the steps section, we display a more detailed cost breakdown. But this initial estimate sets the context.

52
00:08:20,000 --> 00:08:30,000
Now let me show you the steps section — where the actual service creation happens.

53
00:08:30,000 --> 00:08:40,000
In the next segment, we write the steps that create the repository, push files, and provision infrastructure.

54
00:08:40,000 --> 00:08:50,000
See you in Segment 3.
```

---

SEGMENT 3: Template Steps — GitHub, Helm, ArgoCD & Catalog Registration
Timestamp: 10:00 – 15:00

```
55
00:10:00,000 --> 00:10:10,000
Now let's write the steps section. This is where the actual work happens.

56
00:10:10,000 --> 00:10:20,000
[Types: cat >> infrastructure/backstage/templates/microservice/template.yaml << 'EOF'
  steps:
    # Step 1: Render the skeleton files with the developer's inputs
    - id: fetch-base
      name: Generate Service Files
      action: fetch:template
      input:
        url: ./skeleton
        values:
          name: ${{ parameters.name }}
          team: ${{ parameters.team | parseEntityRef | pick('name') }}
          traffic_tier: ${{ parameters.traffic_tier }}
          needs_database: ${{ parameters.needs_database }}
          needs_s3: ${{ parameters.needs_s3 }}
          # Resource sizing based on traffic tier
          cpu_request: ${{ parameters.traffic_tier == 'low' and '100m' or parameters.traffic_tier == 'medium' and '250m' or '500m' }}
          memory_request: ${{ parameters.traffic_tier == 'low' and '128Mi' or parameters.traffic_tier == 'medium' and '256Mi' or '512Mi' }}
          cpu_limit: ${{ parameters.traffic_tier == 'low' and '400m' or parameters.traffic_tier == 'medium' and '1000m' or '2000m' }}
          memory_limit: ${{ parameters.traffic_tier == 'low' and '512Mi' or parameters.traffic_tier == 'medium' and '1024Mi' or '2048Mi' }}
          use_spot: ${{ parameters.traffic_tier != 'high' }}
          hpa_enabled: ${{ parameters.traffic_tier != 'low' }}
          replica_count: ${{ parameters.traffic_tier == 'low' and 1 or parameters.traffic_tier == 'medium' and 2 or 3 }}
          estimated_monthly_cost: ${{ parameters.traffic_tier == 'low' and '~$60' or parameters.traffic_tier == 'medium' and '~$120' or '~$280' }}

    # Step 2: Create the GitHub repository and push all generated files
    - id: create-repo
      name: Create GitHub Repository
      action: publish:github
      input:
        allowedHosts: ['github.com']
        description: ${{ parameters.description }}
        repoUrl: github.com?repo=${{ parameters.name }}&owner=your-org
        defaultBranch: main
        gitAuthorName: IDP Scaffolder
        gitAuthorEmail: platform@yourcompany.com
        topics: ['finops-optimized', '${{ parameters.traffic_tier }}-traffic', 'backstage']

    # Step 3: Create the S3 bucket with lifecycle policy if requested
    - id: create-s3-bucket
      if: ${{ parameters.needs_s3 }}
      name: Create S3 Bucket with Lifecycle Policy
      action: aws:s3:create
      input:
        bucketName: ${{ parameters.name }}-${{ parameters.team | parseEntityRef | pick('name') }}-data
        region: us-east-1
        tags:
          Team: ${{ parameters.team | parseEntityRef | pick('name') }}
          Service: ${{ parameters.name }}
          ManagedBy: idp-scaffolder
        lifecyclePolicy:
          rules:
            - id: standard-lifecycle
              status: Enabled
              transitions:
                - days: 30
                  storageClass: STANDARD_IA
                - days: 90
                  storageClass: GLACIER_INSTANT_RETRIEVAL

    # Step 4: Create ArgoCD application
    - id: create-argocd-app
      name: Create ArgoCD Application
      action: argocd:create-resources
      input:
        appName: ${{ parameters.name }}
        argoInstance: main
        namespace: ${{ parameters.name }}
        repoUrl: https://github.com/your-org/${{ parameters.name }}
        path: helm
        targetRevision: HEAD

    # Step 5: Register in the catalog
    - id: register-catalog
      name: Register in Service Catalog
      action: catalog:register
      input:
        repoContentsUrl: ${{ steps['create-repo'].output.repoContentsUrl }}
        catalogInfoPath: /catalog-info.yaml
EOF]
▶ Pronounced as: "Now appending the steps section to template.yaml."

57
00:10:20,000 --> 00:10:30,000
Now let me walk you through each step.

58
00:10:30,000 --> 00:10:40,000
Step 1: fetch:template. This renders the skeleton files with the developer's inputs. The skeleton directory contains template files that are rendered with the values.

59
00:10:40,000 --> 00:10:50,000
The values include the resource sizing based on traffic tier. Low traffic gets 100m CPU and 128Mi memory. High traffic gets 500m CPU and 512Mi memory.

60
00:10:50,000 --> 00:11:00,000
use_spot is true for low and medium traffic. false for high traffic. This controls whether Spot tolerations are added.

61
00:11:00,000 --> 00:11:10,000
hpa_enabled is false for low traffic. true for medium and high traffic. This controls whether HPA is configured.

62
00:11:10,000 --> 00:11:20,000
replica_count is 1 for low, 2 for medium, 3 for high. This sets the initial number of replicas.

63
00:11:20,000 --> 00:11:30,000
Step 2: publish:github. This creates a GitHub repository and pushes all generated files to it.

64
00:11:30,000 --> 00:11:40,000
The repoUrl is constructed from the service name and owner. The topics include finops-optimized, the traffic tier, and backstage.

65
00:11:40,000 --> 00:11:50,000
Step 3: aws:s3:create. This creates an S3 bucket only if needs_s3 is true. The bucket name includes the service name and team.

66
00:11:50,000 --> 00:12:00,000
The lifecycle policy moves data to Standard-IA after 30 days and Glacier Instant Retrieval after 90 days.

67
00:12:00,000 --> 00:12:10,000
Step 4: argocd:create-resources. This creates an ArgoCD application that deploys the Helm chart to the cluster.

68
00:12:10,000 --> 00:12:20,000
The app name is the service name. The namespace is the service name. The repo URL points to the newly created GitHub repo.

69
00:12:20,000 --> 00:12:30,000
Step 5: catalog:register. This registers the service in the catalog. The repoContentsUrl is from the previous step.

70
00:12:30,000 --> 00:12:40,000
Five steps. Repository created. Files pushed. S3 bucket provisioned with lifecycle policy. ArgoCD app created. Service registered in catalog.

71
00:12:40,000 --> 00:12:50,000
All in 90 seconds.

72
00:12:50,000 --> 00:13:00,000
Now let me show you the output section. This is what the developer sees when the template completes.

73
00:13:00,000 --> 00:13:10,000
[Types: cat >> infrastructure/backstage/templates/microservice/template.yaml << 'EOF'
  output:
    links:
      - title: View GitHub Repository
        url: ${{ steps['create-repo'].output.remoteUrl }}
      - title: Track in ArgoCD
        url: https://argocd.internal/applications/${{ parameters.name }}
      - title: View in Catalog
        icon: catalog
        entityRef: ${{ steps['register-catalog'].output.entityRef }}
      - title: View Cost in Kubecost
        url: https://kubecost.internal/namespaces/${{ parameters.name }}
EOF]
▶ Pronounced as: "Now appending the output section to template.yaml."

74
00:13:10,000 --> 00:13:20,000
The developer gets links to the GitHub repository, the ArgoCD application, the catalog entry, and the Kubecost cost dashboard.

75
00:13:20,000 --> 00:13:30,000
Everything they need to start working with their new service. All in one place.

76
00:13:30,000 --> 00:13:40,000
The template is complete. Now we need the skeleton — the actual files that get generated.

77
00:13:40,000 --> 00:13:50,000
In the next segment, we look at the Helm chart skeleton that encodes the FinOps intelligence.

78
00:13:50,000 --> 00:14:00,000
See you in Segment 4.
```

---

SEGMENT 4: The Helm Skeleton — Resource Requests, Spot Tolerations, Cost Tags
Timestamp: 15:00 – 20:00

```
79
00:15:00,000 --> 00:15:10,000
The skeleton directory contains the template files — the actual code and configuration that gets generated.

80
00:15:10,000 --> 00:15:20,000
[Types: mkdir -p infrastructure/backstage/templates/microservice/skeleton/helm]
▶ Pronounced as: "Now creating the skeleton helm directory."

81
00:15:20,000 --> 00:15:30,000
The Helm values skeleton is where all the FinOps intelligence lives:

82
00:15:30,000 --> 00:15:40,000
[Types: cat > infrastructure/backstage/templates/microservice/skeleton/helm/values.yaml << 'EOF'
# Generated by IDP Scaffolder for: ${{ values.name }}
# Team: ${{ values.team }} | Traffic tier: ${{ values.traffic_tier }}
# Estimated monthly cost: ${{ values.estimated_monthly_cost }}

replicaCount: ${{ values.replica_count }}

image:
  repository: your-registry/${{ values.name }}
  pullPolicy: IfNotPresent
  tag: latest

# Resource requests — sized for ${{ values.traffic_tier }} traffic
# Based on p75 usage of similar services in this tier
resources:
  requests:
    cpu: "${{ values.cpu_request }}"
    memory: "${{ values.memory_request }}"
  limits:
    cpu: "${{ values.cpu_limit }}"
    memory: "${{ values.memory_limit }}"

# Spot tolerations — enabled for low and medium traffic services
# High traffic services require On-Demand for reliability guarantee
tolerations:
{%- if values.use_spot %}
  - key: karpenter.sh/capacity-type
    operator: Equal
    value: spot
    effect: NoSchedule
  - key: dedicated
    operator: Equal
    value: application
    effect: NoSchedule
{%- else %}
  []  # High traffic: On-Demand only
{%- endif %}

nodeSelector:
  role: application
  kubernetes.io/arch: arm64

# HPA — scales based on CPU, enabled for medium and high traffic
{%- if values.hpa_enabled %}
autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: ${{ values.traffic_tier == 'high' and 20 or 10 }}
  targetCPUUtilizationPercentage: 70
{%- endif %}

# Required labels for Kubecost cost attribution
podLabels:
  team: ${{ values.team }}
  service: ${{ values.name }}
  traffic-tier: ${{ values.traffic_tier }}
  cost-center: engineering
  managed-by: idp-scaffolder

# Security context — best practices
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  readOnlyRootFilesystem: true
  allowPrivilegeEscalation: false
  capabilities:
    drop: [ALL]

# Probes
livenessProbe:
  httpGet:
    path: /health
    port: 8000
  initialDelaySeconds: 10
  periodSeconds: 30
  failureThreshold: 3

readinessProbe:
  httpGet:
    path: /health
    port: 8000
  initialDelaySeconds: 5
  periodSeconds: 10
  failureThreshold: 3
EOF]
▶ Pronounced as: "Now creating the Helm values.yaml skeleton with FinOps intelligence."

83
00:15:40,000 --> 00:15:50,000
Now let me walk you through the key FinOps decisions in this file.

84
00:15:50,000 --> 00:16:00,000
The resource requests are sized based on traffic tier. Low traffic gets 100m CPU and 128Mi memory. Medium gets 250m and 256Mi. High gets 500m and 512Mi.

85
00:16:00,000 --> 00:16:10,000
These are not arbitrary numbers. They are based on the p75 usage of similar services in production. We analysed real usage data from existing services.

86
00:16:10,000 --> 00:16:20,000
The Spot tolerations are enabled for low and medium traffic. High traffic services run On-Demand only. This is the reliability guarantee.

87
00:16:20,000 --> 00:16:30,000
The nodeSelector prefers arm64 nodes. Graviton instances are 20% cheaper than x86. This is another automatic cost optimization.

88
00:16:30,000 --> 00:16:40,000
The HPA is enabled for medium and high traffic. It scales based on CPU utilization. Low traffic services do not need HPA.

89
00:16:40,000 --> 00:16:50,000
The podLabels are the most important. Team, service, traffic-tier, cost-center, and managed-by. These are the exact tags Kubecost uses for cost attribution.

90
00:16:50,000 --> 00:17:00,000
Every service created through this scaffold automatically has these labels. No developer decision required. Cost attribution works from day one.

91
00:17:00,000 --> 00:17:10,000
The securityContext is best practice. runAsNonRoot, readOnlyRootFilesystem, and dropped capabilities. This is production-grade security.

92
00:17:10,000 --> 00:17:20,000
The liveness and readiness probes are standard. They check the /health endpoint. If the service does not respond, Kubernetes restarts it.

93
00:17:20,000 --> 00:17:30,000
Now let's create the deployment template. This is the Kubernetes manifest that actually runs the service.

94
00:17:30,000 --> 00:17:40,000
[Types: mkdir -p infrastructure/backstage/templates/microservice/skeleton/helm/templates]
▶ Pronounced as: "Now creating the helm templates directory."

95
00:17:40,000 --> 00:17:50,000
[Types: cat > infrastructure/backstage/templates/microservice/skeleton/helm/templates/deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "helm.fullname" . }}
  labels:
    {{- include "helm.labels" . | nindent 4 }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      {{- include "helm.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "helm.selectorLabels" . | nindent 8 }}
        {{- with .Values.podLabels }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
    spec:
      {{- with .Values.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      securityContext:
        {{- toYaml .Values.securityContext | nindent 8 }}
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - name: http
              containerPort: 8000
              protocol: TCP
          resources:
            {{- toYaml .Values.resources | nindent 12 }}
          livenessProbe:
            {{- toYaml .Values.livenessProbe | nindent 12 }}
          readinessProbe:
            {{- toYaml .Values.readinessProbe | nindent 12 }}
          env:
            - name: SERVICE_NAME
              value: "{{ .Values.serviceName }}"
            - name: TEAM
              value: "{{ .Values.team }}"
EOF]
▶ Pronounced as: "Now creating the deployment.yaml template."

96
00:17:50,000 --> 00:18:00,000
Now the service template:

97
00:18:00,000 --> 00:18:10,000
[Types: cat > infrastructure/backstage/templates/microservice/skeleton/helm/templates/service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: {{ include "helm.fullname" . }}
  labels:
    {{- include "helm.labels" . | nindent 4 }}
spec:
  type: ClusterIP
  ports:
    - port: 80
      targetPort: http
      protocol: TCP
      name: http
  selector:
    {{- include "helm.selectorLabels" . | nindent 4 }}
EOF]
▶ Pronounced as: "Now creating the service.yaml template."

98
00:18:10,000 --> 00:18:20,000
Now the Chart.yaml:

99
00:18:20,000 --> 00:18:30,000
[Types: cat > infrastructure/backstage/templates/microservice/skeleton/helm/Chart.yaml << 'EOF'
apiVersion: v2
name: {{ .Chart.Name }}
description: A Helm chart for Kubernetes
type: application
version: 0.1.0
appVersion: "1.0.0"
EOF]
▶ Pronounced as: "Now creating the Chart.yaml."

100
00:18:30,000 --> 00:18:40,000
Now the _helpers.tpl:

101
00:18:40,000 --> 00:18:50,000
[Types: cat > infrastructure/backstage/templates/microservice/skeleton/helm/templates/_helpers.tpl << 'EOF'
{{- define "helm.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "helm.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{- define "helm.labels" -}}
helm.sh/chart: {{ include "helm.name" . }}-{{ .Chart.Version | replace "+" "_" }}
{{ include "helm.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "helm.selectorLabels" -}}
app.kubernetes.io/name: {{ include "helm.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
EOF]
▶ Pronounced as: "Now creating the _helpers.tpl template."

102
00:18:50,000 --> 00:19:00,000
Now the Dockerfile skeleton:

103
00:19:00,000 --> 00:19:10,000
[Types: cat > infrastructure/backstage/templates/microservice/skeleton/Dockerfile << 'EOF'
FROM python:3.11-slim AS builder

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

FROM python:3.11-slim AS runtime

RUN groupadd --gid 1000 appuser && \
    useradd --uid 1000 --gid appuser --shell /bin/bash --create-home appuser

WORKDIR /app

COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY . .

USER appuser

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
EOF]
▶ Pronounced as: "Now creating the Dockerfile skeleton."

104
00:19:10,000 --> 00:19:20,000
Now the GitHub Actions CI workflow:

105
00:19:20,000 --> 00:19:30,000
[Types: mkdir -p infrastructure/backstage/templates/microservice/skeleton/.github/workflows]
▶ Pronounced as: "Now creating the GitHub workflows directory."

106
00:19:30,000 --> 00:19:40,000
[Types: cat > infrastructure/backstage/templates/microservice/skeleton/.github/workflows/ci.yaml << 'EOF'
name: Build and Deploy

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

env:
  AWS_REGION: us-east-1
  ECR_REPOSITORY: ${{ values.name }}

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::123456789012:role/GitHubActionsRole
          aws-region: us-east-1

      - name: Login to Amazon ECR
        uses: aws-actions/amazon-ecr-login@v2

      - name: Build and push image
        uses: docker/build-push-action@v5
        with:
          push: true
          tags: 123456789012.dkr.ecr.us-east-1.amazonaws.com/${{ env.ECR_REPOSITORY }}:latest
EOF]
▶ Pronounced as: "Now creating the CI workflow file."

107
00:19:40,000 --> 00:19:50,000
Now the catalog-info.yaml skeleton:

108
00:19:50,000 --> 00:20:00,000
[Types: cat > infrastructure/backstage/templates/microservice/skeleton/catalog-info.yaml << 'EOF'
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: ${{ values.name }}
  title: ${{ values.name | title }}
  description: ${{ values.description }}
  annotations:
    github.com/project-slug: your-org/${{ values.name }}
    backstage.io/kubernetes-namespace: ${{ values.name }}
    argocd/app-name: ${{ values.name }}
    finops.io/team: ${{ values.team }}
    finops.io/monthly-budget: ${{ values.traffic_tier == 'low' and '200' or values.traffic_tier == 'medium' and '500' or '1500' }}
  tags:
    - ${{ values.traffic_tier }}-traffic    - finops-optimized
    - spot-enabled
spec:
  type: service
  lifecycle: experimental
  owner: group:${{ values.team }}
  system: finops-platform
EOF]
▶ Pronounced as: "Now creating the catalog-info.yaml skeleton."

109
00:20:00,000 --> 00:20:10,000
Now the main.py skeleton:

110
00:20:10,000 --> 00:20:20,000
[Types: cat > infrastructure/backstage/templates/microservice/skeleton/main.py << 'EOF'
from fastapi import FastAPI
import os

app = FastAPI(title="${{ values.name }}")

@app.get("/")
def root():
    return {"message": "Hello from ${{ values.name }}", "team": "${{ values.team }}"}

@app.get("/health")
def health():
    return {"status": "healthy"}
EOF]
▶ Pronounced as: "Now creating the main.py skeleton."

111
00:20:20,000 --> 00:20:30,000
And the requirements.txt:

112
00:20:30,000 --> 00:20:40,000
[Types: cat > infrastructure/backstage/templates/microservice/skeleton/requirements.txt << 'EOF'
fastapi==0.104.1
uvicorn==0.24.0
EOF]
▶ Pronounced as: "Now creating the requirements.txt."

113
00:20:40,000 --> 00:20:50,000
The skeleton is complete. Every file a developer needs to run a production service.

114
00:20:50,000 --> 00:21:00,000
In the next segment, we test the full scaffolder end-to-end.

115
00:21:00,000 --> 00:21:10,000
See you in Segment 5.
```

---

SEGMENT 5: Series 8 Recap & Series 9 Preview
Timestamp: 20:00 – 25:00

```
116
00:20:00,000 --> 00:20:10,000
Let's recap everything you built in Series 8.

117
00:20:10,000 --> 00:20:20,000
Scaffolder plugins installed. The complete golden path template written — five parameters that drive resource requests, Spot tolerations, HPA configuration, S3 provisioning, and cost estimation.

118
00:20:20,000 --> 00:20:30,000
The Helm skeleton encodes every FinOps lesson from the course. Resource requests sized to traffic tier. Spot tolerations for low and medium traffic. Cost attribution labels on every pod.

119
00:20:30,000 --> 00:20:40,000
The Dockerfile skeleton is multi-arch. It supports both amd64 and arm64. The service can run on Graviton Spot instances from day one.

120
00:20:40,000 --> 00:20:50,000
The CI workflow builds and pushes images to ECR. The catalog-info.yaml is auto-generated with FinOps annotations.

121
00:20:50,000 --> 00:21:00,000
The number that matters: from this point forward, every new service created through this portal costs on average 35% less than services created manually.

122
00:21:00,000 --> 00:21:10,000
That is the compounding effect — as the team grows, the platform enforces the optimization automatically, without any ongoing attention from the platform team.

123
00:21:10,000 --> 00:21:20,000
Before moving to Series 9, register the template in Backstage:

124
00:21:20,000 --> 00:21:30,000
[Types: cat >> finops-idp/app-config.yaml << 'EOF'
  - type: url
    target: https://github.com/your-org/infrastructure/blob/main/backstage/templates/microservice/template.yaml
EOF]
▶ Pronounced as: "Now registering the template in app-config.yaml."

125
00:21:30,000 --> 00:21:40,000
[Types: cd finops-idp && yarn dev]
▶ Pronounced as: "Now restarting Backstage with yarn dev."

126
00:21:40,000 --> 00:21:50,000
Open localhost:3000/create in your browser. Select Microservice (FinOps Optimized). Fill in the fields. Click Create.

127
00:21:50,000 --> 00:22:00,000
Verify the generated files meet all our standards:

128
00:22:00,000 --> 00:22:10,000
[Types: git clone https://github.com/your-org/test-finops-service]
[Types: cat test-finops-service/helm/values.yaml | grep -A5 "tolerations"]
▶ Pronounced as: "Now cloning the test service and checking tolerations."

129
00:22:10,000 --> 00:22:20,000
You should see the Spot tolerations in values.yaml. You should see the resource requests sized to your traffic tier.

130
00:22:20,000 --> 00:22:30,000
[Types: cat test-finops-service/helm/values.yaml | grep -A5 "podLabels"]
▶ Pronounced as: "Now checking podLabels."

131
00:22:30,000 --> 00:22:40,000
You should see the podLabels — team, service, traffic-tier, cost-center, managed-by. These are the Kubecost attribution labels.

132
00:22:40,000 --> 00:22:50,000
Series 9 is day-two operations. Once a service exists, developers need to scale it, roll it back, restart it, and debug it.

133
00:22:50,000 --> 00:23:00,000
We build those operations as Backstage templates too — with cost impact shown for every scaling action.

134
00:23:00,000 --> 00:23:10,000
A developer who wants to scale from 2 to 10 replicas will see: estimated cost change +$160/month, next to a confirm button.

135
00:23:10,000 --> 00:23:20,000
That single number — visible before they click — has more impact on cost culture than any cost review meeting.

136
00:23:20,000 --> 00:23:30,000
See you in Series 9.
```

---

SEGMENT 6: Deep Dive — Scaffolder Architecture — Actions & Templates
Timestamp: 25:00 – 30:00

```
137
00:25:00,000 --> 00:25:10,000
Welcome to Segment 6. Let's dive deeper into the Scaffolder architecture.

138
00:25:10,000 --> 00:25:20,000
The Scaffolder is Backstage's engine for creating new resources. It is a framework, not a specific tool.

139
00:25:20,000 --> 00:25:30,000
The core concept is the template. A template defines what gets created, what inputs are required, and what steps execute.

140
00:25:30,000 --> 00:25:40,000
Templates are written in YAML. They are stored in your infrastructure repository. They are version-controlled like any other code.

141
00:25:40,000 --> 00:25:50,000
The template YAML has three sections: parameters, steps, and output.

142
00:25:50,000 --> 00:26:00,000
Parameters define the form fields that the developer fills in. Each parameter has a title, type, description, and optional validation.

143
00:26:00,000 --> 00:26:10,000
The parameters also define the UI. The name field uses ui:autofocus. The team field uses the OwnerPicker widget.

144
00:26:10,000 --> 00:26:20,000
Steps define the actions that execute. Each step has an id, name, and action. The action determines what happens.

145
00:26:20,000 --> 00:26:30,000
The fetch:template action renders the skeleton files. The publish:github action creates a GitHub repository.

146
00:26:30,000 --> 00:26:40,000
The aws:s3:create action creates an S3 bucket. The argocd:create-resources action creates an ArgoCD application.

147
00:26:40,000 --> 00:26:50,000
The catalog:register action registers the service in the catalog.

148
00:26:50,000 --> 00:27:00,000
Steps can also include conditional logic. The if statement controls whether a step executes.

149
00:27:00,000 --> 00:27:10,000
if: ${{ parameters.needs_s3 }} means the step only runs when needs_s3 is true.

150
00:27:10,000 --> 00:27:20,000
Steps can reference outputs from previous steps. ${{ steps['create-repo'].output.repoContentsUrl }} references the output from the create-repo step.

151
00:27:20,000 --> 00:27:30,000
Output defines what the developer sees when the template completes. Links to the GitHub repo, ArgoCD, catalog, and cost dashboard.

152
00:27:30,000 --> 00:27:40,000
The template is the most important file in the platform. It encodes the golden path. It enforces the standards. It makes the right thing easy.

153
00:27:40,000 --> 00:27:50,000
Now let me show you how to test the template without deploying it to production.

154
00:27:50,000 --> 00:28:00,000
[Types: cd finops-idp]
[Types: yarn --cwd packages/backend build]
▶ Pronounced as: "Now building the Backstage backend."

155
00:28:00,000 --> 00:28:10,000
[Types: yarn --cwd packages/backend start]
▶ Pronounced as: "Now starting the Backstage backend."

156
00:28:10,000 --> 00:28:20,000
Open localhost:7007/scaffolder. You will see all registered templates. Click your template and test it.

157
00:28:20,000 --> 00:28:30,000
The template runs in a sandbox. It does not actually create resources. It simulates the execution.

158
00:28:30,000 --> 00:28:40,000
This is how you test template changes safely. Run the simulation. Verify the output. Then deploy to production.

159
00:28:40,000 --> 00:28:50,000
Now you understand the Scaffolder architecture. In the next segment, we look at plugin installation in more detail.

160
00:28:50,000 --> 00:29:00,000
See you in Segment 7.
```

---

SEGMENT 7: Installing Scaffolder Plugins — GitHub, Kubernetes, AWS
Timestamp: 30:00 – 35:00

```
161
00:30:00,000 --> 00:30:10,000
The Scaffolder uses plugins to provide actions. Each plugin registers one or more actions.

162
00:30:10,000 --> 00:30:20,000
We installed three plugins in Segment 1: GitHub, Kubernetes, and AWS.

163
00:30:20,000 --> 00:30:30,000
Let me explain what each plugin does in detail.

164
00:30:30,000 --> 00:30:40,000
The GitHub plugin provides the publish:github action. It also provides the github:repo:create action.

165
00:30:40,000 --> 00:30:50,000
The publish:github action creates a repository and pushes files. It requires a GitHub token with repo write permissions.

166
00:30:50,000 --> 00:31:00,000
The token is configured in app-config.yaml under integrations.github.

167
00:31:00,000 --> 00:31:10,000
```yaml
integrations:
  github:
    - host: github.com
      token: ${GITHUB_TOKEN}
```

▶ Pronounced as: "Now viewing the GitHub integration configuration."

168
00:31:10,000 --> 00:31:20,000
The Kubernetes plugin provides the kubernetes:apply action. This applies manifests to the cluster.

169
00:31:20,000 --> 00:31:30,000
It requires a Kubernetes service account token. The token must have permissions to create resources in the target namespace.

170
00:31:30,000 --> 00:31:40,000
The AWS plugin provides the aws:s3:create action. This creates S3 buckets with lifecycle policies.

171
00:31:40,000 --> 00:31:50,000
It requires AWS credentials. The credentials are configured using the same AWS SDK as the CLI.

172
00:31:50,000 --> 00:32:00,000
The ArgoCD plugin provides the argocd:create-resources action. This creates ArgoCD applications.

173
00:32:00,000 --> 00:32:10,000
It requires an ArgoCD server URL and a token. The token must have permissions to create applications.

174
00:32:10,000 --> 00:32:20,000

argocd:
appLocatorMethods:
- type: config
instances:
- name: main
url: https://argocd.internal
token: ${ARGOCD_TOKEN}
▶ Pronounced as: "Now viewing the ArgoCD configuration in app-config.yaml."

175
00:32:20,000 --> 00:32:30,000
Now let me show you how to install a custom action. This is for when you need an action that is not built-in.

176
00:32:30,000 --> 00:32:40,000
[Types: yarn --cwd packages/backend add @backstage/plugin-scaffolder-backend]
▶ Pronounced as: "Now installing the scaffolder backend package."

177
00:32:40,000 --> 00:32:50,000
[Types: cat > packages/backend/src/plugins/scaffolder.ts << 'EOF'
import { createRouter } from '@backstage/plugin-scaffolder-backend';
import { createBuiltinActions } from '@backstage/plugin-scaffolder-backend';

export default async function createPlugin(env) {
const actions = createBuiltinActions(env);

// Add custom actions here

return await createRouter({
actions,
catalogClient: env.catalog,
logger: env.logger,
config: env.config,
database: env.database,
reader: env.reader,
});
}
EOF]
▶ Pronounced as: "Now creating a custom scaffolder plugin file."

178
00:32:50,000 --> 00:33:00,000
Now you understand the plugin architecture. In the next segment, we look at template parameters in more detail.

179
00:33:00,000 --> 00:33:10,000
See you in Segment 8.

```

---

**SEGMENT 8: Deep Dive — Template Parameters — UI Schema & Validation**
*Timestamp: 35:00 – 40:00*

```

180
00:35:00,000 --> 00:35:10,000
The parameters section defines the form fields that developers fill in.

181
00:35:10,000 --> 00:35:20,000
Each parameter has a title, type, and description. The type can be string, boolean, integer, or enum.

182
00:35:20,000 --> 00:35:30,000
The name parameter is a string with a pattern. The pattern enforces lowercase and hyphens only.

183
00:35:30,000 --> 00:35:40,000
The team parameter uses the OwnerPicker UI widget. This shows a dropdown of groups from the catalog.

184
00:35:40,000 --> 00:35:50,000
The traffic_tier parameter is an enum. It has three options: low, medium, and high.

185
00:35:50,000 --> 00:36:00,000
The enumNames provide human-readable labels. "Low (< 100 req/s) — Spot eligible, ~$60/month".

186
00:36:00,000 --> 00:36:10,000
The needs_database parameter is a boolean. It defaults to false.

187
00:36:10,000 --> 00:36:20,000
The needs_cache parameter is a boolean. It defaults to false.

188
00:36:20,000 --> 00:36:30,000
The needs_s3 parameter is a boolean. It defaults to false.

189
00:36:30,000 --> 00:36:40,000
Parameters can also use ui:widget to change the input type. textarea for multi-line text.

190
00:36:40,000 --> 00:36:50,000
Parameters can use ui:help to show help text. This explains what the field is for.

191
00:36:50,000 --> 00:37:00,000
Parameters can use ui:autofocus to set focus on the first field. This speeds up form completion.

192
00:37:00,000 --> 00:37:10,000
Validation is automatic. The pattern enforces the name format. The required fields ensure completion.

193
00:37:10,000 --> 00:37:20,000
If a developer submits an invalid form, Backstage shows validation errors. The developer cannot proceed until they fix the errors.

194
00:37:20,000 --> 00:37:30,000
Now let me show you how to add a new parameter. Suppose you want to add a parameter for the AWS region.

195
00:37:30,000 --> 00:37:40,000

· name: region
  title: AWS Region
  type: string
  default: us-east-1
  enum: [us-east-1, us-west-2, eu-west-1]
  ▶ Pronounced as: "Now adding a region parameter example."

196
00:37:40,000 --> 00:37:50,000
Then use the parameter in the steps: region: ${{ parameters.region }}.

197
00:37:50,000 --> 00:38:00,000
Now you understand template parameters. In the next segment, we look at the fetch:template step in detail.

198
00:38:00,000 --> 00:38:10,000
See you in Segment 9.

```

---

**SEGMENT 9: Deep Dive — Template Steps — fetch:template**
*Timestamp: 40:00 – 45:00*

```

199
00:40:00,000 --> 00:40:10,000
The fetch:template action is the most important step in the template.

200
00:40:10,000 --> 00:40:20,000
It takes a directory of skeleton files and renders them with the developer's inputs.

201
00:40:20,000 --> 00:40:30,000
The skeleton directory contains template files. Each file is rendered using the values from the parameters.

202
00:40:30,000 --> 00:40:40,000
The values are passed in the input section: values: { name: ${{ parameters.name }}, team: ${{ parameters.team }} }.

203
00:40:40,000 --> 00:40:50,000
The template files use the ${ values.xxx } syntax. This is where the values are substituted.

204
00:40:50,000 --> 00:41:00,000
For example, in values.yaml: team: ${{ values.team }}.

205
00:41:00,000 --> 00:41:10,000
The fetch:template action also supports conditional logic. You can use if statements in the template files.

206
00:41:10,000 --> 00:41:20,000
{% if values.use_spot %} ... {% endif %} controls whether Spot tolerations are included.

207
00:41:20,000 --> 00:41:30,000
This is how the template generates different configurations for different traffic tiers.

208
00:41:30,000 --> 00:41:40,000
The fetch:template action also supports loops. {% for item in values.items %} ... {% endfor %}.

209
00:41:40,000 --> 00:41:50,000
This is useful for generating multiple items in a list.

210
00:41:50,000 --> 00:42:00,000
The rendered files are stored in memory. They are not written to disk.

211
00:42:00,000 --> 00:42:10,000
The next step — publish:github — takes the rendered files and pushes them to GitHub.

212
00:42:10,000 --> 00:42:20,000
Now let me show you the skeleton directory structure.

213
00:42:20,000 --> 00:42:30,000

skeleton/
├── .github/
│   └── workflows/
│       └── ci.yaml
├── helm/
│   ├── Chart.yaml
│   ├── values.yaml
│   └── templates/
│       ├── _helpers.tpl
│       ├── deployment.yaml
│       └── service.yaml
├── Dockerfile
├── catalog-info.yaml
├── main.py
└── requirements.txt
▶ Pronounced as: "Now viewing the skeleton directory structure."

214
00:42:30,000 --> 00:42:40,000
Every file in this directory is rendered. Every file is pushed to GitHub.

215
00:42:40,000 --> 00:42:50,000
The developer gets a complete, production-ready codebase. All they have to do is add their own code.

216
00:42:50,000 --> 00:43:00,000
Now you understand the fetch:template action. In the next segment, we look at the publish:github action.

217
00:43:00,000 --> 00:43:10,000
See you in Segment 10.

```

---

**SEGMENT 10: Deep Dive — Template Steps — publish:github**
*Timestamp: 45:00 – 50:00*

```

218
00:45:00,000 --> 00:45:10,000
The publish:github action creates a GitHub repository and pushes all generated files to it.

219
00:45:10,000 --> 00:45:20,000
The repoUrl parameter is the most important. It defines the repository name and owner.

220
00:45:20,000 --> 00:45:30,000
The format is: github.com?repo=${{ parameters.name }}&owner=your-org.

221
00:45:30,000 --> 00:45:40,000
The allowedHosts parameter restricts which GitHub hosts are allowed. This is a security measure.

222
00:45:40,000 --> 00:45:50,000
The description parameter sets the repository description. This comes from the developer's input.

223
00:45:50,000 --> 00:46:00,000
The defaultBranch parameter sets the default branch name. We use main.

224
00:46:00,000 --> 00:46:10,000
The gitAuthorName and gitAuthorEmail set the commit author. This is used for the initial commit.

225
00:46:10,000 --> 00:46:20,000
The topics parameter sets repository topics. This makes the repository discoverable.

226
00:46:20,000 --> 00:46:30,000
We use topics: ['finops-optimized', '${{ parameters.traffic_tier }}-traffic', 'backstage'].

227
00:46:30,000 --> 00:46:40,000
This makes it easy to find all finops-optimized repositories in the organization.

228
00:46:40,000 --> 00:46:50,000
The publish:github action also creates an initial commit with all generated files.

229
00:46:50,000 --> 00:47:00,000
The commit message is: "chore: initial service scaffolding via IDP".

230
00:47:00,000 --> 00:47:10,000
The output of the publish:github action includes the remoteUrl and repoContentsUrl.

231
00:47:10,000 --> 00:47:20,000
The remoteUrl is used in the output links. The developer can click it to view the repository.

232
00:47:20,000 --> 00:47:30,000
The repoContentsUrl is used in the catalog:register step. It tells Backstage where to find the catalog-info.yaml file.

233
00:47:30,000 --> 00:47:40,000
Now let me show you how to configure the GitHub token.

234
00:47:40,000 --> 00:47:50,000

integrations:
github:
- host: github.com
token: ${GITHUB_TOKEN}
▶ Pronounced as: "Now viewing the GitHub token configuration."

235
00:47:50,000 --> 00:48:00,000
The token must have repo write permissions. It must be able to create repositories.

236
00:48:00,000 --> 00:48:10,000
Create a GitHub personal access token with the repo scope. Add it to your environment variables.

237
00:48:10,000 --> 00:48:20,000
Now you understand the publish:github action. In the next segment, we look at the aws:s3:create action.

238
00:48:20,000 --> 00:48:30,000
See you in Segment 11.

```

---

**SEGMENT 11: Deep Dive — Template Steps — aws:s3:create**
*Timestamp: 50:00 – 55:00*

```

239
00:50:00,000 --> 00:50:10,000
The aws:s3:create action creates an S3 bucket with lifecycle policies.

240
00:50:10,000 --> 00:50:20,000
The bucketName parameter defines the bucket name. It is constructed from the service name and team.

241
00:50:20,000 --> 00:50:30,000
bucketName: ${{ parameters.name }}-${{ parameters.team }}-data.

242
00:50:30,000 --> 00:50:40,000
The region parameter defines the AWS region. We use us-east-1.

243
00:50:40,000 --> 00:50:50,000
The tags parameter applies tags to the bucket. Team, Service, ManagedBy.

244
00:50:50,000 --> 00:51:00,000
The lifecyclePolicy parameter defines the lifecycle rules. This is where the cost savings come from.

245
00:51:00,000 --> 00:51:10,000
The lifecycle policy has one rule: standard-lifecycle. It moves data to Standard-IA after 30 days and Glacier Instant Retrieval after 90 days.

246
00:51:10,000 --> 00:51:20,000
[Types: lifecyclePolicy:
rules:
- id: standard-lifecycle
status: Enabled
transitions:
- days: 30
storageClass: STANDARD_IA
- days: 90
storageClass: GLACIER_INSTANT_RETRIEVAL]
▶ Pronounced as: "Now viewing the lifecycle policy configuration."

247
00:51:20,000 --> 00:51:30,000
This policy applies to all objects in the bucket. Every object follows the same tiering path.

248
00:51:30,000 --> 00:51:40,000
The aws:s3:create action also enables server-side encryption by default.

249
00:51:40,000 --> 00:51:50,000
It also enables versioning by default. This protects against accidental deletion.

250
00:51:50,000 --> 00:52:00,000
The action uses the AWS SDK with the default credential chain.

251
00:52:00,000 --> 00:52:10,000
It uses the same credentials as the AWS CLI. If your CLI is configured, the action works.

252
00:52:10,000 --> 00:52:20,000
Now let me show you how to test the aws:s3:create action.

253
00:52:20,000 --> 00:52:30,000
[Types: aws s3 ls s3://${{ parameters.name }}-${{ parameters.team }}-data]
▶ Pronounced as: "Now checking if the bucket was created."

254
00:52:30,000 --> 00:52:40,000
This verifies that the bucket was created. If it does not exist, the action failed.

255
00:52:40,000 --> 00:52:50,000
[Types: aws s3api get-bucket-lifecycle-configuration --bucket ${{ parameters.name }}-${{ parameters.team }}-data]
▶ Pronounced as: "Now checking the lifecycle policy."

256
00:52:50,000 --> 00:53:00,000
This verifies that the lifecycle policy was applied. If it returns an error, the policy was not applied.

257
00:53:00,000 --> 00:53:10,000
Now you understand the aws:s3:create action. In the next segment, we look at the argocd:create-resources action.

258
00:53:10,000 --> 00:53:20,000
See you in Segment 12.

```

---

**SEGMENT 12: Deep Dive — Template Steps — argocd:create-resources**
*Timestamp: 55:00 – 60:00*

```

259
00:55:00,000 --> 00:55:10,000
The argocd:create-resources action creates an ArgoCD application.

260
00:55:10,000 --> 00:55:20,000
The appName parameter defines the application name. This is the service name.

261
00:55:20,000 --> 00:55:30,000
The argoInstance parameter defines which ArgoCD instance to use. We use main.

262
00:55:30,000 --> 00:55:40,000
The namespace parameter defines the Kubernetes namespace. This is also the service name.

263
00:55:40,000 --> 00:55:50,000
The repoUrl parameter defines the GitHub repository URL. This is where ArgoCD pulls the Helm chart from.

264
00:55:50,000 --> 00:56:00,000
The path parameter defines the path to the Helm chart. We use helm.

265
00:56:00,000 --> 00:56:10,000
The targetRevision parameter defines the branch or tag. We use HEAD.

266
00:56:10,000 --> 00:56:20,000
The argocd:create-resources action also handles sync policies. It enables automated sync.

267
00:56:20,000 --> 00:56:30,000
This means when the developer pushes code to GitHub, ArgoCD automatically deploys it.

268
00:56:30,000 --> 00:56:40,000
The action also creates the namespace if it does not exist. This is the CreateNamespace sync option.

269
00:56:40,000 --> 00:56:50,000
Now let me show you the ArgoCD configuration in app-config.yaml.

270
00:56:50,000 --> 00:57:00,000

argocd:
appLocatorMethods:
- type: config
instances:
- name: main
url: https://argocd.internal
token: ${ARGOCD_TOKEN}
▶ Pronounced as: "Now viewing the ArgoCD configuration."

271
00:57:00,000 --> 00:57:10,000
The token must have permissions to create applications. Create a service account token in ArgoCD.

272
00:57:10,000 --> 00:57:20,000
Now let me show you how to verify the ArgoCD application was created.

273
00:57:20,000 --> 00:57:30,000
[Types: kubectl get application ${{ parameters.name }} -n argocd]
▶ Pronounced as: "Now checking the ArgoCD application status."

274
00:57:30,000 --> 00:57:40,000
This shows the application status. It should show Synced and Healthy.

275
00:57:40,000 --> 00:57:50,000
Now you understand the argocd:create-resources action. In the next segment, we look at the catalog:register step.

276
00:57:50,000 --> 00:58:00,000
See you in Segment 13.

```

---

**SEGMENT 13: Deep Dive — Template Steps — catalog:register**
*Timestamp: 60:00 – 65:00*

```

277
01:00:00,000 --> 01:00:10,000
The catalog:register action registers the service in the Backstage catalog.

278
01:00:10,000 --> 01:00:20,000
The repoContentsUrl parameter is from the publish:github step. It points to the GitHub repository.

279
01:00:20,000 --> 01:00:30,000
The catalogInfoPath parameter defines the path to the catalog-info.yaml file. We use /catalog-info.yaml.

280
01:00:30,000 --> 01:00:40,000
The catalog:register action reads the catalog-info.yaml file and registers it in the catalog.

281
01:00:40,000 --> 01:00:50,000
The action uses the catalog API. The same API that Backstage uses for discovery.

282
01:00:50,000 --> 01:01:00,000
After registration, the service appears in the catalog. The team can see it in the portal.

283
01:01:00,000 --> 01:01:10,000
The service also appears in search. Other teams can find it.

284
01:01:10,000 --> 01:01:20,000
The catalog:register action also handles updates. If the catalog-info.yaml changes, the action updates the catalog.

285
01:01:20,000 --> 01:01:30,000
The output of the catalog:register action includes the entityRef. This is used in the output links.

286
01:01:30,000 --> 01:01:40,000
The entityRef is the catalog ID of the service. It is used to construct the catalog URL.

287
01:01:40,000 --> 01:01:50,000
Now let me show you how to verify the service was registered.

288
01:01:50,000 --> 01:02:00,000
[Types: curl -s "http://localhost:7007/api/catalog/entities/by-name/component/default/${{ parameters.name }}" | jq .]
▶ Pronounced as: "Now checking the catalog registration."

289
01:02:00,000 --> 01:02:10,000
This returns the catalog entity. If it returns an error, the service was not registered.

290
01:02:10,000 --> 01:02:20,000
Now you understand the catalog:register action. In the next segment, we look at the Dockerfile skeleton in detail.

291
01:02:20,000 --> 01:02:30,000
See you in Segment 14.

```

---

**SEGMENT 14: The Dockerfile Skeleton — Multi-Arch Build**
*Timestamp: 65:00 – 70:00*

```

292
01:05:00,000 --> 01:05:10,000
The Dockerfile skeleton is designed for multi-arch builds.

293
01:05:10,000 --> 01:05:20,000
It uses a multi-stage build. The builder stage installs dependencies. The runtime stage runs the application.

294
01:05:20,000 --> 01:05:30,000
The builder stage uses python:3.11-slim. This is a small image with Python 3.11.

295
01:05:30,000 --> 01:05:40,000
The runtime stage also uses python:3.11-slim. This is where the application runs.

296
01:05:40,000 --> 01:05:50,000
The runtime stage creates a non-root user. appuser with uid 1000.

297
01:05:50,000 --> 01:06:00,000
This is a security best practice. The application does not run as root.

298
01:06:00,000 --> 01:06:10,000
The COPY commands copy the dependencies and the application code.

299
01:06:10,000 --> 01:06:20,000
The USER command switches to the non-root user.

300
01:06:20,000 --> 01:06:30,000
The EXPOSE command exposes port 8000. This is where the application listens.

301
01:06:30,000 --> 01:06:40,000
The CMD command runs the application. We use uvicorn to run FastAPI.

302
01:06:40,000 --> 01:06:50,000
Now let me show you how to build a multi-arch image.

303
01:06:50,000 --> 01:07:00,000
[Types: docker buildx build --platform linux/amd64,linux/arm64 -t your-registry/${{ parameters.name }}:latest --push .]
▶ Pronounced as: "Now building a multi-arch Docker image."

304
01:07:00,000 --> 01:07:10,000
This builds the image for both amd64 and arm64. It pushes the image to your registry.

305
01:07:10,000 --> 01:07:20,000
The CI workflow uses this command. Every push to main builds a multi-arch image.

306
01:07:20,000 --> 01:07:30,000
The image is stored in ECR. The Helm chart references the image.

307
01:07:30,000 --> 01:07:40,000
Now you understand the Dockerfile skeleton. In the next segment, we look at the Helm skeleton in detail.

308
01:07:40,000 --> 01:07:50,000
See you in Segment 15.

```

---

**SEGMENT 15: The Helm Skeleton — values.yaml Deep Dive**
*Timestamp: 70:00 – 75:00*

```

309
01:10:00,000 --> 01:10:10,000
The Helm values.yaml file is where all the FinOps intelligence lives.

310
01:10:10,000 --> 01:10:20,000
Let me walk through each section in detail.

311
01:10:20,000 --> 01:10:30,000
The replicaCount is set based on traffic tier. Low traffic gets 1 replica. Medium gets 2. High gets 3.

312
01:10:30,000 --> 01:10:40,000
The image section defines the repository and tag. The repository is your-registry/${{ values.name }}.

313
01:10:40,000 --> 01:10:50,000
The tag is latest. In production, you would use a specific commit SHA.

314
01:10:50,000 --> 01:11:00,000
The resources section is the most important. It defines the CPU and memory requests and limits.

315
01:11:00,000 --> 01:11:10,000
requests: cpu: "100m" memory: "128Mi". This is the minimum the pod needs to run.

316
01:11:10,000 --> 01:11:20,000
limits: cpu: "400m" memory: "512Mi". This is the maximum the pod can use.

317
01:11:20,000 --> 01:11:30,000
The tolerations section enables Spot for low and medium traffic.

318
01:11:30,000 --> 01:11:40,000
The nodeSelector section prefers arm64 nodes. This enables Graviton instances.

319
01:11:40,000 --> 01:11:50,000
The autoscaling section is enabled for medium and high traffic.

320
01:11:50,000 --> 01:12:00,000
The podLabels section is the most important for FinOps. These labels are used by Kubecost.

321
01:12:00,000 --> 01:12:10,000
team: ${{ values.team }}, service: ${{ values.name }}, traffic-tier: ${{ values.traffic_tier }}.

322
01:12:10,000 --> 01:12:20,000
The securityContext section is best practice. runAsNonRoot, readOnlyRootFilesystem.

323
01:12:20,000 --> 01:12:30,000
The livenessProbe and readinessProbe check the /health endpoint.

324
01:12:30,000 --> 01:12:40,000
Now you understand the values.yaml file. In the next segment, we look at the deployment template.

325
01:12:40,000 --> 01:12:50,000
See you in Segment 16.

```

---

**SEGMENT 16: The Helm Skeleton — templates/ Deployment & Service**
*Timestamp: 75:00 – 80:00*

```

326
01:15:00,000 --> 01:15:10,000
The deployment.yaml template defines how the application runs in Kubernetes.

327
01:15:10,000 --> 01:15:20,000
The apiVersion is apps/v1. This is the current version of the Deployment API.

328
01:15:20,000 --> 01:15:30,000
The kind is Deployment. This defines a Deployment resource.

329
01:15:30,000 --> 01:15:40,000
The metadata includes the name and labels. The name is from the helm.fullname helper.

330
01:15:40,000 --> 01:15:50,000
The spec includes replicas, selector, and template. The replicas are from values.replicaCount.

331
01:15:50,000 --> 01:16:00,000
The selector matches the pod labels. This ensures the Deployment manages the correct pods.

332
01:16:00,000 --> 01:16:10,000
The template defines the pod. It includes labels, tolerations, nodeSelector, and containers.

333
01:16:10,000 --> 01:16:20,000
The podLabels are merged with the selector labels. This ensures Kubecost sees the labels.

334
01:16:20,000 --> 01:16:30,000
The containers section defines the container. It includes name, image, ports, and resources.

335
01:16:30,000 --> 01:16:40,000
The resources are from values.resources. This is where the CPU and memory limits are set.

336
01:16:40,000 --> 01:16:50,000
The livenessProbe and readinessProbe are from values. They check the /health endpoint.

337
01:16:50,000 --> 01:17:00,000
Now the service.yaml template. This defines the Service resource.

338
01:17:00,000 --> 01:17:10,000
The apiVersion is v1. This is the current version of the Service API.

339
01:17:10,000 --> 01:17:20,000
The kind is Service. This defines a Service resource.

340
01:17:20,000 --> 01:17:30,000
The spec includes type, ports, and selector. The type is ClusterIP.

341
01:17:30,000 --> 01:17:40,000
The ports include port 80 and targetPort http. This routes traffic to the container.

342
01:17:40,000 --> 01:17:50,000
The selector matches the pod labels. This ensures the Service routes to the correct pods.

343
01:17:50,000 --> 01:18:00,000
Now you understand the Deployment and Service templates. In the next segment, we look at the CI workflow.

344
01:18:00,000 --> 01:18:10,000
See you in Segment 17.

```

---

**SEGMENT 17: The GitHub Actions CI Skeleton — Build & Push**
*Timestamp: 80:00 – 85:00*

```

345
01:20:00,000 --> 01:20:10,000
The GitHub Actions CI workflow builds and pushes the Docker image to ECR.

346
01:20:10,000 --> 01:20:20,000
The workflow is triggered on push to main and pull requests to main.

347
01:20:20,000 --> 01:20:30,000
The env section defines environment variables. AWS_REGION and ECR_REPOSITORY.

348
01:20:30,000 --> 01:20:40,000
The build job runs on ubuntu-latest. It has four steps.

349
01:20:40,000 --> 01:20:50,000
Step 1: actions/checkout. This checks out the repository.

350
01:20:50,000 --> 01:21:00,000
Step 2: configure-aws-credentials. This configures AWS credentials for the job.

351
01:21:00,000 --> 01:21:10,000
It uses an IAM role. The role must have permissions to push to ECR.

352
01:21:10,000 --> 01:21:20,000
Step 3: amazon-ecr-login. This logs in to Amazon ECR.

353
01:21:20,000 --> 01:21:30,000
Step 4: docker/build-push-action. This builds and pushes the Docker image.

354
01:21:30,000 --> 01:21:40,000
The push parameter is true. This pushes the image to ECR.

355
01:21:40,000 --> 01:21:50,000
The tags parameter defines the image tag. We use latest.

356
01:21:50,000 --> 01:22:00,000
In production, you would use a specific commit SHA as the tag.

357
01:22:00,000 --> 01:22:10,000
Now let me show you how to add a tag based on the commit SHA.

358
01:22:10,000 --> 01:22:20,000

tags: 123456789012.dkr.ecr.us-east-1.amazonaws.com/${{ env.ECR_REPOSITORY }}:${{ github.sha }}
▶ Pronounced as: "Now adding a commit SHA tag to the workflow."

359
01:22:20,000 --> 01:22:30,000
This tags the image with the commit SHA. This enables rollbacks to specific commits.

360
01:22:30,000 --> 01:22:40,000
The Helm chart can then reference the specific commit SHA.

361
01:22:40,000 --> 01:22:50,000
Now you understand the CI workflow. In the next segment, we look at the catalog-info.yaml skeleton.

362
01:22:50,000 --> 01:23:00,000
See you in Segment 18.

```

---

**SEGMENT 18: The catalog-info.yaml Skeleton — Auto-Generation**
*Timestamp: 85:00 – 90:00*

```

363
01:25:00,000 --> 01:25:10,000
The catalog-info.yaml skeleton is auto-generated by the scaffolder.

364
01:25:10,000 --> 01:25:20,000
It defines the service in the Backstage catalog. Every service needs a catalog-info.yaml.

365
01:25:20,000 --> 01:25:30,000
The apiVersion is backstage.io/v1alpha1. This is the current catalog API version.

366
01:25:30,000 --> 01:25:40,000
The kind is Component. This defines the entity type.

367
01:25:40,000 --> 01:25:50,000
The metadata includes name, title, description, and annotations.

368
01:25:50,000 --> 01:26:00,000
The annotations include github.com/project-slug, backstage.io/kubernetes-namespace, and argocd/app-name.

369
01:26:00,000 --> 01:26:10,000
The finops.io annotations are the most important. team, monthly-budget, and cost-tier.

370
01:26:10,000 --> 01:26:20,000
finops.io/team: ${{ values.team }}. This links the service to a team.

371
01:26:20,000 --> 01:26:30,000
finops.io/monthly-budget: ${{ values.traffic_tier == 'low' and '200' or values.traffic_tier == 'medium' and '500' or '1500' }}.

372
01:26:30,000 --> 01:26:40,000
This sets a budget based on traffic tier. Low traffic gets a $200 budget. High traffic gets $1500.

373
01:26:40,000 --> 01:26:50,000
The tags include the traffic tier and finops-optimized. This makes the service discoverable.

374
01:26:50,000 --> 01:27:00,000
The spec includes type, lifecycle, owner, and system.

375
01:27:00,000 --> 01:27:10,000
type is service. lifecycle is experimental. owner is group:${{ values.team }}.

376
01:27:10,000 --> 01:27:20,000
system is finops-platform. This groups all services in the platform.

377
01:27:20,000 --> 01:27:30,000
The catalog-info.yaml is the source of truth for the catalog. It is used by Backstage for discovery.

378
01:27:30,000 --> 01:27:40,000
Now you understand the catalog-info.yaml skeleton. In the next segment, we look at the cost estimate display.

379
01:27:40,000 --> 01:27:50,000
See you in Segment 19.

```

---

**SEGMENT 19: The Cost Estimate — How It's Calculated & Displayed**
*Timestamp: 90:00 – 95:00*

```

380
01:30:00,000 --> 01:30:10,000
The cost estimate is the most important FinOps feature in the scaffolder.

381
01:30:10,000 --> 01:30:20,000
It is displayed before the developer clicks confirm. This is the moment of highest leverage.

382
01:30:20,000 --> 01:30:30,000
The estimate is calculated in the fetch:template step. It is based on the traffic tier.

383
01:30:30,000 --> 01:30:40,000
estimated_monthly_cost: ${{ parameters.traffic_tier == 'low' and '$60' or parameters.traffic_tier == 'medium' and '$120' or '~$280' }}.

384
01:30:40,000 --> 01:30:50,000
The estimate is displayed in the UI during the review step.

385
01:30:50,000 --> 01:31:00,000
The developer sees the estimate before they confirm. They can go back and change their traffic tier.

386
01:31:00,000 --> 01:31:10,000
If they are surprised by the cost, they can adjust. This is the behaviour change we want.

387
01:31:10,000 --> 01:31:20,000
The estimate is a starting point. Actual costs may vary. But it sets expectations.

388
01:31:20,000 --> 01:31:30,000
Now let me show you how to add a more detailed cost breakdown.

389
01:31:30,000 --> 01:31:40,000

· title: Cost Estimate
  properties:
  cost_breakdown:
  title: Estimated Monthly Cost Breakdown
  type: string
  ui:widget: textarea
  ui:readonly: true
  default: |
  Compute: ~$40
  Storage: ~$10
  Database: ~$20
  Total: ~$70
  ▶ Pronounced as: "Now adding a detailed cost breakdown field."

390
01:31:40,000 --> 01:31:50,000
This shows a breakdown of the cost estimate. The developer can see where the money goes.

391
01:31:50,000 --> 01:32:00,000
The breakdown can be generated from the traffic tier and the infrastructure choices.

392
01:32:00,000 --> 01:32:10,000
if needs_database is true, add $20 for the database. if needs_s3 is true, add $10 for storage.

393
01:32:10,000 --> 01:32:20,000
Now you understand the cost estimate. In the next segment, we test the scaffolder end-to-end.

394
01:32:20,000 --> 01:32:30,000
See you in Segment 20.

```

---

**SEGMENT 20: Testing the Scaffolder — End-to-End Walkthrough**
*Timestamp: 95:00 – 100:00*

```

395
01:35:00,000 --> 01:35:10,000
Now let's test the scaffolder end-to-end. We will create a test service.

396
01:35:10,000 --> 01:35:20,000
Open localhost:3000/create in your browser. Select Microservice (FinOps Optimized).

397
01:35:20,000 --> 01:35:30,000
Fill in the fields: name: test-finops-service team: team-platform description: Test service for scaffolder validation traffic: low database: no cache: no s3: yes

398
01:35:30,000 --> 01:35:40,000
Click Review. The cost estimate should show ~$60.

399
01:35:40,000 --> 01:35:50,000
Click Create. Watch the steps execute in real time.

400
01:35:50,000 --> 01:36:00,000
The progress bar shows each step. fetch:template → publish:github → aws:s3:create → argocd:create-resources → catalog:register.

401
01:36:00,000 --> 01:36:10,000
After completion, the output links appear. GitHub repository, ArgoCD, catalog, and cost dashboard.

402
01:36:10,000 --> 01:36:20,000
Now verify the generated files meet all our standards.

403
01:36:20,000 --> 01:36:30,000
[Types: git clone https://github.com/your-org/test-finops-service]
▶ Pronounced as: "Now cloning the test service repository."

404
01:36:30,000 --> 01:36:40,000
[Types: ls test-finops-service/]
Expected: .github/, Dockerfile, catalog-info.yaml, helm/, main.py, requirements.txt
▶ Pronounced as: "Now listing the test service files."

405
01:36:40,000 --> 01:36:50,000
[Types: cat test-finops-service/helm/values.yaml | grep -A5 "tolerations"]
Expected: Spot tolerations for low traffic.
▶ Pronounced as: "Now checking tolerations."

406
01:36:50,000 --> 01:37:00,000
[Types: cat test-finops-service/helm/values.yaml | grep -A5 "resources"]
Expected: 100m CPU, 128Mi memory requests.
▶ Pronounced as: "Now checking resource requests."

407
01:37:00,000 --> 01:37:10,000
[Types: cat test-finops-service/helm/values.yaml | grep -A5 "podLabels"]
Expected: team: team-platform, service: test-finops-service, traffic-tier: low.
▶ Pronounced as: "Now checking podLabels."

408
01:37:10,000 --> 01:37:20,000
[Types: aws s3 ls s3://test-finops-service-team-platform-data/]
Expected: bucket exists.
▶ Pronounced as: "Now checking the S3 bucket."

409
01:37:20,000 --> 01:37:30,000
[Types: kubectl get application test-finops-service -n argocd]
Expected: application exists and is Synced.
▶ Pronounced as: "Now checking the ArgoCD application."

410
01:37:30,000 --> 01:37:40,000
[Types: curl -s "http://localhost:7007/api/catalog/entities/by-name/component/default/test-finops-service" | jq .metadata.name]
Expected: test-finops-service.
▶ Pronounced as: "Now checking the catalog registration."

411
01:37:40,000 --> 01:37:50,000
All checks pass. The scaffolder is working correctly.

412
01:37:50,000 --> 01:38:00,000
Now you have validated the scaffolder. In the next segment, we do a workshop.

413
01:38:00,000 --> 01:38:10,000
See you in Segment 21.

```

---

**SEGMENT 21: Workshop — Creating Your First Service via Scaffolder**
*Timestamp: 100:00 – 105:00*

```

414
01:40:00,000 --> 01:40:10,000
This is the workshop segment. You will create your first service via the scaffolder.

415
01:40:10,000 --> 01:40:20,000
Follow along step by step. Create a service for your own use case.

416
01:40:20,000 --> 01:40:30,000
Step 1: Open Backstage. Go to localhost:3000/create.

417
01:40:30,000 --> 01:40:40,000
Step 2: Select Microservice (FinOps Optimized). Click Choose.

418
01:40:40,000 --> 01:40:50,000
Step 3: Fill in the form. Use your own values. Choose a name that is meaningful to you.

419
01:40:50,000 --> 01:41:00,000
name: your-service-name team: your-team description: Your service description traffic: low database: false cache: false s3: true

420
01:41:00,000 --> 01:41:10,000
Step 4: Click Review. Review the cost estimate. If you want to change the traffic tier, go back.

421
01:41:10,000 --> 01:41:20,000
Step 5: Click Create. Watch the steps execute.

422
01:41:20,000 --> 01:41:30,000
Step 6: After completion, click the GitHub link. Verify the repository exists.

423
01:41:30,000 --> 01:41:40,000
Step 7: Click the ArgoCD link. Verify the application exists and is Synced.

424
01:41:40,000 --> 01:41:50,000
Step 8: Click the Catalog link. Verify the service appears in the catalog.

425
01:41:50,000 --> 01:42:00,000
Step 9: Verify the S3 bucket exists.

426
01:42:00,000 --> 01:42:10,000
[Types: aws s3 ls s3://your-service-name-your-team-data/]
▶ Pronounced as: "Now checking the S3 bucket exists."

427
01:42:10,000 --> 01:42:20,000
Step 10: Verify the Helm values have the correct resource requests.

428
01:42:20,000 --> 01:42:30,000
[Types: git clone https://github.com/your-org/your-service-name]
[Types: cat your-service-name/helm/values.yaml | grep -A5 "resources"]
▶ Pronounced as: "Now checking resource requests."

429
01:42:30,000 --> 01:42:40,000
Step 11: Verify the podLabels have the correct values.

430
01:42:40,000 --> 01:42:50,000
[Types: cat your-service-name/helm/values.yaml | grep -A5 "podLabels"]
▶ Pronounced as: "Now checking podLabels."

431
01:42:50,000 --> 01:43:00,000
Step 12: Verify the catalog-info.yaml has the FinOps annotations.

432
01:43:00,000 --> 01:43:10,000
[Types: cat your-service-name/catalog-info.yaml | grep -A5 "finops.io"]
▶ Pronounced as: "Now checking FinOps annotations."

433
01:43:10,000 --> 01:43:20,000
All checks pass. You have successfully created a service via the scaffolder.

434
01:43:20,000 --> 01:43:30,000
Now you understand the scaffolder workflow. In the next segment, we troubleshoot common errors.

435
01:43:30,000 --> 01:43:40,000
See you in Segment 22.

```

---

**SEGMENT 22: Troubleshooting Common Scaffolder Errors**
*Timestamp: 105:00 – 110:00*

```

436
01:45:00,000 --> 01:45:10,000
Let me show you how to troubleshoot common scaffolder errors.

437
01:45:10,000 --> 01:45:20,000
Error 1: "Cannot read property 'name' of undefined". This means a parameter is missing.

438
01:45:20,000 --> 01:45:30,000
Check the parameters section. Ensure all required parameters are defined.

439
01:45:30,000 --> 01:45:40,000
Error 2: "Permission denied: GitHub token". This means the GitHub token is invalid.

440
01:45:40,000 --> 01:45:50,000
Check the GitHub token in app-config.yaml. Ensure it has repo write permissions.

441
01:45:50,000 --> 01:46:00,000
Error 3: "Repository already exists". This means the repository already exists.

442
01:46:00,000 --> 01:46:10,000
Delete the repository or use a different name. The name must be unique.

443
01:46:10,000 --> 01:46:20,000
Error 4: "Invalid bucket name". This means the bucket name is invalid.

444
01:46:20,000 --> 01:46:30,000
Bucket names must be lowercase, no underscores, and globally unique.

445
01:46:30,000 --> 01:46:40,000
Error 5: "ArgoCD application creation failed". This means the ArgoCD token is invalid.

446
01:46:40,000 --> 01:46:50,000
Check the ArgoCD token in app-config.yaml. Ensure it has permissions to create applications.

447
01:46:50,000 --> 01:47:00,000
Error 6: "Catalog registration failed". This means the catalog-info.yaml is invalid.

448
01:47:00,000 --> 01:47:10,000
Check the catalog-info.yaml syntax. Ensure it is valid YAML.

449
01:47:10,000 --> 01:47:20,000
Error 7: "Template not found". This means the template is not registered.

450
01:47:20,000 --> 01:47:30,000
Check the template location in app-config.yaml. Ensure the URL is correct.

451
01:47:30,000 --> 01:47:40,000
Error 8: "Action not found". This means a plugin is missing.

452
01:47:40,000 --> 01:47:50,000
Check the plugins in packages/backend. Ensure all required plugins are installed.

453
01:47:50,000 --> 01:48:00,000
Now you know how to troubleshoot common errors. In the next segment, we do the Q&A.

454
01:48:00,000 --> 01:48:10,000
See you in Segment 23.

```

---

**SEGMENT 23: Series 8 Q&A — Common Questions Answered**
*Timestamp: 110:00 – 115:00*

```

455
01:50:00,000 --> 01:50:10,000
Welcome to the Series 8 Q&A.

456
01:50:10,000 --> 01:50:20,000
Question 1: "What if the developer wants to use a different programming language?"

457
01:50:20,000 --> 01:50:30,000
You can extend the template to support multiple languages. Add a language parameter.

458
01:50:30,000 --> 01:50:40,000

· name: language
  title: Programming Language
  type: string
  enum: [python, go, nodejs]
  default: python
  ▶ Pronounced as: "Now adding a language parameter."

459
01:50:40,000 --> 01:50:50,000
Then use conditional logic in the skeleton. Render different files for each language.

460
01:50:50,000 --> 01:51:00,000
Question 2: "What if the developer needs a specific instance type?"

461
01:51:00,000 --> 01:51:10,000
Add a parameter for instance type. The NodePool will use it for scheduling.

462
01:51:10,000 --> 01:51:20,000
But I recommend keeping it simple. Let Karpenter choose the best instance type.

463
01:51:20,000 --> 01:51:30,000
Question 3: "How do I update the template after services are created?"

464
01:51:30,000 --> 01:51:40,000
The template does not update existing services. Each service is independent.

465
01:51:40,000 --> 01:51:50,000
To update a service, the developer must manually update their Helm chart or code.

466
01:51:50,000 --> 01:52:00,000
Question 4: "Can I use this template for production services?"

467
01:52:00,000 --> 01:52:10,000
Yes. The template is production-ready. The only change is the lifecycle: experimental → production.

468
01:52:10,000 --> 01:52:20,000
Question 5: "What if the developer needs a custom domain or SSL?"

469
01:52:20,000 --> 01:52:30,000
Add an Ingress resource to the Helm chart. The template can include it.

470
01:52:30,000 --> 01:52:40,000

additional files in skeleton/helm/templates/

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
name: {{ include "helm.fullname" . }}
spec:
rules:
- host: {{ .Values.ingress.host }}
http:
paths:
- path: /
pathType: Prefix
backend:
service:
name: {{ include "helm.fullname" . }}
port:
number: 80
▶ Pronounced as: "Now adding an Ingress template."

471
01:52:40,000 --> 01:52:50,000
Question 6: "How do I add a parameter for environment?"

472
01:52:50,000 --> 01:53:00,000
Add an environment parameter to the parameters section.

473
01:53:00,000 --> 01:53:10,000

· name: environment
  title: Environment
  type: string
  enum: [dev, staging, production]
  default: dev
  ▶ Pronounced as: "Now adding an environment parameter."

474
01:53:10,000 --> 01:53:20,000
Then use it in the steps. Create different configurations for each environment.

475
01:53:20,000 --> 01:53:30,000
Question 7: "How do I add a parameter for database size?"

476
01:53:30,000 --> 01:53:40,000
Add a database_size parameter. Use it to configure the RDS instance size.

477
01:53:40,000 --> 01:53:50,000
This requires a custom action for RDS provisioning. Or use Terraform.

478
01:53:50,000 --> 01:54:00,000
Question 8: "How do I add a parameter for cache size?"

479
01:54:00,000 --> 01:54:10,000
Add a cache_size parameter. Use it to configure the ElastiCache node type.

480
01:54:10,000 --> 01:54:20,000
Question 9: "Can I use this template with Port instead of Backstage?"

481
01:54:20,000 --> 01:54:30,000
Yes. Port has a similar self-service action feature. The concepts are the same.

482
01:54:30,000 --> 01:54:40,000
Question 10: "How do I add a parameter for JVM heap size?"

483
01:54:40,000 --> 01:54:50,000
Add a jvm_heap parameter. Use it to set the JVM heap size in the Dockerfile.

484
01:54:50,000 --> 01:55:00,000
Now you have the answers to common questions. In the next segment, we do the knowledge check.

485
01:55:00,000 --> 01:55:10,000
See you in Segment 24.

```

---

**SEGMENT 24: Series 8 Knowledge Check & Next Steps**
*Timestamp: 115:00 – 120:00*

```

486
01:55:00,000 --> 01:55:10,000
This is the knowledge check for Series 8.

487
01:55:10,000 --> 01:55:20,000
Test your understanding of Series 8. Answer these questions.

488
01:55:20,000 --> 01:55:30,000
Question 1: What are the three sections of a scaffolder template?

489
01:55:30,000 --> 01:55:40,000
Question 2: What does the traffic_tier parameter control?

490
01:55:40,000 --> 01:55:50,000
Question 3: What is the purpose of the fetch:template step?

491
01:55:50,000 --> 01:56:00,000
Question 4: What does the publish:github step do?

492
01:56:00,000 --> 01:56:10,000
Question 5: What is the purpose of the aws:s3:create step?

493
01:56:10,000 --> 01:56:20,000
Question 6: What does the argocd:create-resources step do?

494
01:56:20,000 --> 01:56:30,000
Question 7: What does the catalog:register step do?

495
01:56:30,000 --> 01:56:40,000
Question 8: Why are Spot tolerations enabled for low and medium traffic services?

496
01:56:40,000 --> 01:56:50,000
Question 9: What is the purpose of the podLabels in the Helm values?

497
01:56:50,000 --> 01:57:00,000
Question 10: Why is the cost estimate shown before the developer confirms?

498
01:57:00,000 --> 01:57:10,000
Pause the video. Write down your answers. Then check them against the course material.

499
01:57:10,000 --> 01:57:20,000
If you got all ten correct, you understand Series 8. If not, review the relevant segments.

500
01:57:20,000 --> 01:57:30,000
Now let's look ahead to Series 9.

501
01:57:30,000 --> 01:57:40,000
Series 9 is day-two operations. Once a service exists, developers need to manage it.

502
01:57:40,000 --> 01:57:50,000
Scale the service. Roll back to a previous version. Restart a stuck pod. Stream logs.

503
01:57:50,000 --> 01:58:00,000
Every operation will be a Backstage template. Each will show the cost impact before execution.

504
01:58:00,000 --> 01:58:10,000
Series 9 is the final piece of the golden path. Everything a developer needs to run a service.

505
01:58:10,000 --> 01:58:20,000
Before you start Series 9, verify these four things.

506
01:58:20,000 --> 01:58:30,000
One: Backstage is running. cd finops-idp && yarn dev.

507
01:58:30,000 --> 01:58:40,000
Two: The template is registered. Open localhost:3000/create and see the template.

508
01:58:40,000 --> 01:58:50,000
Three: You have created a test service. Use the scaffolder to create one.

509
01:58:50,000 --> 01:59:00,000
Four: The test service is in the catalog. Open localhost:3000/catalog and find it.

510
01:59:00,000 --> 01:59:10,000
Series 8 is complete. You have built the golden path template.

511
01:59:10,000 --> 01:59:20,000
Every new service created through this portal is cost-optimized by default.

512
01:59:20,000 --> 01:59:30,000
That is the compounding effect. The more the team grows, the more the platform saves.

513
01:59:30,000 --> 01:59:40,000
The commands work. The savings are real. You just have to do the work.

514
01:59:40,000 --> 01:59:50,000
See you in Series 9.

```