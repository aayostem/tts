# Series 7: IDP Fundamentals — What Is an Internal Developer Platform

## Complete 24-Segment SRT — 2 Hours

---

### SEGMENT 1: Why Every FinOps Win Eventually Reverses
**Timestamp:** 00:00 – 05:00

```
1
00:00:00,000 --> 00:00:10,000
Welcome to Series 7. This is where we shift from fixing infrastructure to building a platform.

2
00:00:10,000 --> 00:00:20,000
You have saved $27,596 a month. Let that land for a moment. From $47,000 to $19,404. Real savings. Real commands. Real infrastructure.

3
00:00:20,000 --> 00:00:30,000
Your AWS bill is less than half of what it was. But there is a problem. A problem that kills 90% of FinOps initiatives.

4
00:00:30,000 --> 00:00:40,000
Three months later, the bill is back at $35,000. Not because the optimizations stopped working. Not because AWS raised prices.

5
00:00:40,000 --> 00:00:50,000
Because the company kept growing. New engineers joined. New services got deployed. New databases were created. New S3 buckets were provisioned.

6
00:00:50,000 --> 00:01:00,000
Nobody told the new hires about the lifecycle policies. Nobody enforced the tagging strategy. Nobody reminded anyone to use Spot instances.

7
00:01:00,000 --> 00:01:10,000
Nobody checked whether the new RDS database was tagged Schedule=dev-hours. The waste came back — silently, gradually, and entirely predictably.

8
00:01:10,000 --> 00:01:20,000
I have seen this happen at startup after startup. It is not a failure of intention. Every engineer at that company wanted to be cost-conscious.

9
00:01:20,000 --> 00:01:30,000
They just did not have the infrastructure to make the right thing the automatic thing. The startup in our story did not experience this reversal.

10
00:01:30,000 --> 00:01:40,000
After implementing the IDP in Series 7 through 10, their bill stayed at $19,404 for 18 months. They grew from 40 to 80 engineers.

11
00:01:40,000 --> 00:01:50,000
They added 30 new services. Their bill did not move significantly. Because every new service was cost-optimized by default.

12
00:01:50,000 --> 00:02:00,000
The IDP was the difference. An Internal Developer Platform is a system that makes the right thing the easy thing.

13
00:02:00,000 --> 00:02:10,000
And makes the wrong thing require deliberate effort. In the FinOps context, the right thing means: every new S3 bucket has a lifecycle policy.

14
00:02:10,000 --> 00:02:20,000
Every new RDS instance is tagged for scheduling. Every new Kubernetes workload has appropriate resource requests. Every new service uses Spot where appropriate.

15
00:02:20,000 --> 00:02:30,000
Before an IDP, those things depend on what individual engineers know. After an IDP, they happen automatically for every service ever created.

16
00:02:30,000 --> 00:02:40,000
This is what we are building in Series 7 through 10. A platform that encodes every FinOps lesson from Series 2 through 6 into the default path.

17
00:02:40,000 --> 00:02:50,000
The platform makes cost optimization invisible to the developer. They do not think about Spot tolerations. They do not think about lifecycle policies.

18
00:02:50,000 --> 00:03:00,000
They just deploy their service. And the platform ensures it is cost-optimized. This is the shift from manual to automatic.

19
00:03:00,000 --> 00:03:10,000
Before we start building, we need to understand the organizational model that makes platforms successful.

20
00:03:10,000 --> 00:03:20,000
I have seen platform teams fail in three ways. Know these failure modes before we start building.

21
00:03:20,000 --> 00:03:30,000
Failure Mode 1 is the Gatekeeper Platform. The platform team controls all infrastructure. Developers file tickets. The platform team reviews, approves, implements.

22
00:03:30,000 --> 00:03:40,000
Nothing happens without them. Result: developers wait days or weeks. They start going around the platform. Shadow infrastructure proliferates.

23
00:03:40,000 --> 00:03:50,000
The platform becomes irrelevant. The signal: your developers describe the platform team as a bottleneck or the no team.

24
00:03:50,000 --> 00:04:00,000
Failure Mode 2 is the Invisible Platform. No platform team exists. Every team builds their own tooling.

25
00:04:00,000 --> 00:04:10,000
Ten teams, ten different CI/CD systems, ten different tagging strategies, ten different cost profiles. The signal: how do I deploy here is a question that takes a week to answer.

26
00:04:10,000 --> 00:04:20,000
Failure Mode 3 is the Shiny Platform. The platform team builds a beautiful developer portal with great UX. But the golden paths inside it are poorly designed.

27
00:04:20,000 --> 00:04:30,000
Resource requests too high. No Spot tolerations. No lifecycle policies. The platform makes it easy to do expensive things.

28
00:04:30,000 --> 00:04:40,000
The signal: platform adoption is high but the AWS bill is still out of control. The platform in this course avoids all three.

29
00:04:40,000 --> 00:04:50,000
It is self-service — no gatekeeper. It is universal — no invisible shadow infrastructure. It is cost-encoded — the golden paths are built on everything you learned in Series 2 through 6.

30
00:04:50,000 --> 00:05:00,000
The organizational model that works is Team Topologies. Four team types. Stream-aligned teams, platform teams, enabling teams, and complicated-subsystem teams.

31
00:05:00,000 --> 00:05:10,000
Stream-aligned teams are your product teams. They build features for users. They ship code. They serve customers.

32
00:05:10,000 --> 00:05:20,000
Platform teams build and maintain the IDP. They treat developers as customers. They have a roadmap, user research, and adoption metrics.

33
00:05:20,000 --> 00:05:30,000
Enabling teams are temporarily embedded to help teams adopt new practices. They run workshops, write documentation, answer questions. They transfer knowledge.

34
00:05:30,000 --> 00:05:40,000
Complicated-subsystem teams own particularly complex components. The GPU training infrastructure for riskoracle is an example.

35
00:05:40,000 --> 00:05:50,000
The key principle: platform teams reduce cognitive load for stream-aligned teams. The stream-aligned teams should spend nearly all their time on product work.

36
00:05:50,000 --> 00:06:00,000
Not on infrastructure decisions. Every infrastructure decision the platform makes automatic is cognitive load returned to product work.

37
00:06:00,000 --> 00:06:10,000
In the next segment, we look at the core concept that makes the IDP work for FinOps: the golden path.

38
00:06:10,000 --> 00:06:20,000
See you in Segment 2.
```

---

### SEGMENT 2: Three Failure Modes & Team Topologies
**Timestamp:** 05:00 – 10:00

```
39
00:05:00,000 --> 00:05:10,000
Let me expand on the three failure modes and Team Topologies.

40
00:05:10,000 --> 00:05:20,000
The Gatekeeper Platform is the most common failure mode. The platform team becomes a bottleneck. Every infrastructure request goes through them.

41
00:05:20,000 --> 00:05:30,000
Developers wait days for an S3 bucket. They wait weeks for a database. They start finding ways around the platform.

42
00:05:30,000 --> 00:05:40,000
They create their own resources in the console. Those resources are untagged. They have no lifecycle policies. They are invisible to cost management.

43
00:05:40,000 --> 00:05:50,000
Shadow infrastructure proliferates. The platform becomes irrelevant. The team that was supposed to enable developers becomes the reason they cannot ship.

44
00:05:50,000 --> 00:06:00,000
The Invisible Platform is the second most common. No platform team exists. Every team builds their own tooling.

45
00:06:00,000 --> 00:06:10,000
The financial-rag team uses Terraform. The riskoracle team uses CDK. The platform team uses CloudFormation. None of them share tooling.

46
00:06:10,000 --> 00:06:20,000
None of them have consistent tagging. None of them have consistent cost controls. The bill is a mess. Nobody knows who owns what.

47
00:06:20,000 --> 00:06:30,000
The Shiny Platform is the most frustrating failure mode. The platform team builds a beautiful portal. It has great UX. Developers love it.

48
00:06:30,000 --> 00:06:40,000
But the golden paths inside it are poorly designed. Resource requests are too high. No Spot tolerations. No lifecycle policies.

49
00:06:40,000 --> 00:06:50,000
The platform makes it easy to do expensive things. Platform adoption is high but the AWS bill is still out of control.

50
00:06:50,000 --> 00:07:00,000
This is where many IDP projects fail. They focus on the developer experience but forget the cost controls. The bill does not improve.

51
00:07:00,000 --> 00:07:10,000
The platform in this course avoids all three. It is self-service — no gatekeeper. It is universal — one set of golden paths for everyone.

52
00:07:10,000 --> 00:07:20,000
It is cost-encoded — every golden path has Spot tolerations, right-sized resource requests, and lifecycle policies built in.

53
00:07:20,000 --> 00:07:30,000
Now let me explain Team Topologies in more detail. This is the organizational model that makes platform engineering work.

54
00:07:30,000 --> 00:07:40,000
Stream-aligned teams are aligned to a stream of work — a product area, a user journey, a business capability. The financial-rag team and the riskoracle team are stream-aligned teams.

55
00:07:40,000 --> 00:07:50,000
They should spend the vast majority of their time on product work. Not on infrastructure decisions. Not on security reviews. Not on cost optimization.

56
00:07:50,000 --> 00:08:00,000
The platform exists to remove that cognitive load. Platform teams treat stream-aligned teams as their customers. They build products, not just tools.

57
00:08:00,000 --> 00:08:10,000
They have a roadmap, user research, and adoption metrics. The platform team in this course owns the developer portal, the golden path templates, the FinOps tooling, and the cost controls.

58
00:08:10,000 --> 00:08:20,000
Enabling teams are temporarily embedded with stream-aligned teams to help them adopt new practices. They run workshops, write documentation, answer questions.

59
00:08:20,000 --> 00:08:30,000
They do not own systems — they transfer knowledge. In the context of this course, an enabling team would help the financial-rag team migrate their existing workloads to the golden path templates.

60
00:08:30,000 --> 00:08:40,000
Complicated-subsystem teams own particularly complex parts of the system that require deep expertise. For riskoracle, the ML training infrastructure is owned by a complicated-subsystem team.

61
00:08:40,000 --> 00:08:50,000
They provide it as a service to other teams. The key principle: platform teams reduce cognitive load for stream-aligned teams.

62
00:08:50,000 --> 00:09:00,000
The stream-aligned teams should spend nearly all their time on product work — not on infrastructure decisions. Every infrastructure decision the platform makes automatic is cognitive load returned to product work.

63
00:09:00,000 --> 00:09:10,000
This is the organizational model that makes platform engineering successful. It is not just about the technology. It is about how teams interact.

64
00:09:10,000 --> 00:09:20,000
Now let me give you an example of how these teams interact in practice.

65
00:09:20,000 --> 00:09:30,000
A stream-aligned team needs a new service. They open the developer portal. They fill in five fields. The platform creates everything automatically.

66
00:09:30,000 --> 00:09:40,000
The platform team built the portal and the templates. The enabling team helped them learn how to use it. The complicated-subsystem team provides the GPU infrastructure if needed.

67
00:09:40,000 --> 00:09:50,000
The stream-aligned team never thinks about infrastructure. They just build product. That is the goal.

68
00:09:50,000 --> 00:10:00,000
In the next segment, we look at the core concept that makes the IDP work for FinOps: the golden path.

69
00:10:00,000 --> 00:10:10,000
See you in Segment 3.
```

---

### SEGMENT 3: Golden Paths, Backstage Architecture & Installation
**Timestamp:** 10:00 – 15:00

```
70
00:10:00,000 --> 00:10:10,000
The core concept that makes the IDP work for FinOps is the golden path.

71
00:10:10,000 --> 00:10:20,000
A golden path is the well-maintained, well-documented, well-supported way of doing something on your platform. The paved road.

72
00:10:20,000 --> 00:10:30,000
Developers can go off-road — but if they do, they are on their own. The platform team only supports the golden path.

73
00:10:30,000 --> 00:10:40,000
For deploying a new microservice, the golden path in this course includes: a GitHub repository created automatically.

74
00:10:40,000 --> 00:10:50,000
A multi-arch Dockerfile supporting both amd64 and arm64 for Graviton Spot. A Helm chart with resource requests sized to traffic tier.

75
00:10:50,000 --> 00:11:00,000
Spot tolerations pre-configured for low and medium traffic. An S3 bucket with lifecycle policy already applied.

76
00:11:00,000 --> 00:11:10,000
ArgoCD deployment wired and ready. Kubecost cost attribution tags applied. And an estimated monthly cost displayed before the developer clicks confirm.

77
00:11:10,000 --> 00:11:20,000
That last feature is the most underrated thing we build in this course. When a developer sees $120 per month next to their Helm chart configuration before they deploy, their instinct is to understand what drives that number.

78
00:11:20,000 --> 00:11:30,000
They ask why. They compare it to other services. They start internalising unit economics. FinOps stops being a platform concern. It becomes a developer concern. That shift is everything.

79
00:11:30,000 --> 00:11:40,000
Now let's install Backstage. Backstage is the open-source developer portal from Spotify. It is the foundation of our IDP.

80
00:11:40,000 --> 00:11:50,000
Prerequisites check:

81
00:11:50,000 --> 00:12:00,000
[Types: node --version]
▶ Pronounced as: "Node, dash, dash, version"

82
00:12:00,000 --> 00:12:10,000
You should see v18 or higher. Backstage requires Node.js 18 or 20.

83
00:12:10,000 --> 00:12:20,000
[Types: yarn --version]
▶ Pronounced as: "Yarn, dash, dash, version"

84
00:12:20,000 --> 00:12:30,000
You should see 1.22 or higher. Yarn is the package manager for Backstage.

85
00:12:30,000 --> 00:12:40,000
Now create the Backstage app:

86
00:12:40,000 --> 00:12:50,000
[Types: npx @backstage/create-app@latest]
▶ Pronounced as: "N-P-X, at, backstage, slash, create, app, at, latest"

87
00:12:50,000 --> 00:13:00,000
When prompted: enter finops-idp as the app name. Select PostgreSQL as the database. The CLI will scaffold the entire application.

88
00:13:00,000 --> 00:13:10,000
[Types: cd finops-idp]

89
00:13:10,000 --> 00:13:20,000
[Types: yarn dev]
▶ Pronounced as: "Yarn, dev"

90
00:13:20,000 --> 00:13:30,000
Backstage starts on port 3000 for the frontend and 7007 for the backend.

91
00:13:30,000 --> 00:13:40,000
Open localhost:3000 in your browser. You will see the Backstage home page. The catalog will be empty. The scaffolder will have no templates.

92
00:13:40,000 --> 00:13:50,000
We fill both in the next segments. Let me explain the Backstage architecture.

93
00:13:50,000 --> 00:14:00,000
Backstage has a frontend and a backend. The frontend is built with React. The backend is built with Node.js.

94
00:14:00,000 --> 00:14:10,000
Plugins extend both the frontend and backend. The catalog plugin provides the service inventory. The scaffolder plugin provides the golden path templates.

95
00:14:10,000 --> 00:14:20,000
The Kubernetes plugin shows live pod status. The ArgoCD plugin shows deployment status. The FinOps plugin we build in Series 10 shows cost data.

96
00:14:20,000 --> 00:14:30,000
Backstage is highly extensible. You can build your own plugins for anything. The FinOps plugin we build in Series 10 is a custom plugin.

97
00:14:30,000 --> 00:14:40,000
The configuration file is app-config.yaml. This file controls everything — GitHub integration, Kubernetes access, catalog discovery, and plugin configuration.

98
00:14:40,000 --> 00:14:50,000
We will modify this file throughout Series 7 through 10. Each modification adds a new capability to the platform.

99
00:14:50,000 --> 00:15:00,000
Now that Backstage is running, we need to register our existing services in the catalog.

100
00:15:00,000 --> 00:15:10,000
In the next segment, we create the catalog-info.yaml files that define our services.

101
00:15:10,000 --> 00:15:20,000
See you in Segment 4.
```

---

### SEGMENT 4: The Software Catalog — Registering Services
**Timestamp:** 15:00 – 20:00

```
102
00:15:00,000 --> 00:15:10,000
The catalog is the inventory of everything your platform manages. Every service. Every API. Every database. Every team.

103
00:15:10,000 --> 00:15:20,000
Without a comprehensive catalog, the developer portal is just a pretty page that nobody uses. With one, it becomes the single source of truth.

104
00:15:20,000 --> 00:15:30,000
Any engineer can open the catalog and learn everything they need to know about any service in ten seconds.

105
00:15:30,000 --> 00:15:40,000
Create the catalog entity for financial-rag-agent. Commit this file to the root of the repository:

106
00:15:40,000 --> 00:15:50,000
[Types: cat > catalog-info.yaml << 'EOF'
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: financial-rag-agent
  title: Financial RAG Agent
  description: "Production RAG system for SEC filing analysis. Answers financial questions with citations."
  annotations:
    github.com/project-slug: your-org/financial-rag-agent
    backstage.io/kubernetes-namespace: financial-rag
    backstage.io/kubernetes-label-selector: app=financial-rag-agent
    argocd/app-name: financial-rag-agent
    finops.io/team: team-financial-rag
    finops.io/monthly-budget: "15000"
    finops.io/cost-tier: production
  tags:
    - python
    - rag
    - llm
    - production
    - finops-optimized
  links:
    - url: https://grafana.internal/d/rag-dashboard
      title: Grafana Dashboard
    - url: https://kubecost.internal/namespaces/financial-rag
      title: Kubecost Cost Dashboard
spec:
  type: service
  lifecycle: production
  owner: group:team-financial-rag
  system: financial-intelligence
  dependsOn:
    - resource:financial-rag-postgres
    - resource:financial-rag-redis
  providesApis:
    - financial-rag-api
EOF]

103
00:15:50,000 --> 00:16:00,000
Now let me walk you through each field.

104
00:16:00,000 --> 00:16:10,000
The kind is Component. This is the most common entity type. It represents a deployable service.

105
00:16:10,000 --> 00:16:20,000
The metadata section contains the name, title, and description. These appear in the catalog UI.

106
00:16:20,000 --> 00:16:30,000
The annotations section contains integrations. github.com/project-slug links to GitHub. backstage.io/kubernetes-namespace tells the Kubernetes plugin where to look.

107
00:16:30,000 --> 00:16:40,000
argocd/app-name tells the ArgoCD plugin which application to show. finops.io/team and finops.io/monthly-budget are used by the Series 10 cost plugin.

108
00:16:40,000 --> 00:16:50,000
The tags section is for filtering and categorization. The links section provides quick access to dashboards and tools.

109
00:16:50,000 --> 00:17:00,000
The spec section defines the type, lifecycle, owner, and dependencies. owner points to a team entity. dependsOn lists resources this service depends on.

110
00:17:00,000 --> 00:17:10,000
Now configure GitHub catalog discovery in app-config.yaml so Backstage automatically finds catalog-info.yaml files across your organisation:

111
00:17:10,000 --> 00:17:20,000
[Types: cat >> app-config.yaml << 'EOF'
catalog:
  providers:
    github:
      your-org:
        organization: your-github-org
        catalogPath: /catalog-info.yaml
        filters:
          branch: main
        schedule:
          frequency: {minutes: 30}
          timeout: {minutes: 3}
EOF]

112
00:17:20,000 --> 00:17:30,000
With this config, Backstage crawls every repository in your GitHub org every 30 minutes. It automatically registers any service with a catalog-info.yaml.

113
00:17:30,000 --> 00:17:40,000
New services appear in the catalog within 30 minutes of pushing the file. No manual registration required.

114
00:17:40,000 --> 00:17:50,000
Now create the catalog entity for riskoracle:

115
00:17:50,000 --> 00:18:00,000
[Types: cat > riskoracle-catalog-info.yaml << 'EOF'
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: riskoracle
  title: RiskOracle
  description: "MLOps risk calculation engine for financial portfolio risk modeling."
  annotations:
    github.com/project-slug: your-org/riskoracle
    backstage.io/kubernetes-namespace: riskoracle
    argocd/app-name: riskoracle
    finops.io/team: team-riskoracle
    finops.io/monthly-budget: "8000"
    finops.io/cost-tier: production
  tags:
    - python
    - mlops
    - pytorch
    - gpu
    - production
    - finops-optimized
spec:
  type: service
  lifecycle: production
  owner: group:team-riskoracle
  system: financial-intelligence
  dependsOn:
    - resource:riskoracle-postgres
    - resource:riskoracle-redis
    - resource:riskoracle-gpu-nodegroup
  providesApis:
    - riskoracle-api
EOF]

116
00:18:00,000 --> 00:18:10,000
Now create the team entities:

117
00:18:10,000 --> 00:18:20,000
[Types: cat > team-financial-rag.yaml << 'EOF'
apiVersion: backstage.io/v1alpha1
kind: Group
metadata:
  name: team-financial-rag
  title: Financial RAG Team
  description: Owns the financial-rag-agent RAG system and related ingestion services
spec:
  type: team
  parent: engineering
  children: []
  members:
    - engineer-1
    - engineer-2
    - engineer-3
EOF]

118
00:18:20,000 --> 00:18:30,000
[Types: cat > team-riskoracle.yaml << 'EOF'
apiVersion: backstage.io/v1alpha1
kind: Group
metadata:
  name: team-riskoracle
  title: RiskOracle Team
  description: Owns the riskoracle MLOps risk calculation engine
spec:
  type: team
  parent: engineering
  children: []
  members:
    - engineer-4
    - engineer-5
    - engineer-6
EOF]

119
00:18:30,000 --> 00:18:40,000
Now commit all these files to their respective repositories. The GitHub catalog discovery will pick them up within 30 minutes.

120
00:18:40,000 --> 00:18:50,000
[Types: git add catalog-info.yaml && git commit -m "Add Backstage catalog definition" && git push]

121
00:18:50,000 --> 00:19:00,000
After the catalog discovery runs, open Backstage at localhost:3000 and click Catalog. You should see financial-rag-agent and riskoracle.

122
00:19:00,000 --> 00:19:10,000
Click on financial-rag-agent. You should see the overview page with the description, tags, links, and ownership information.

123
00:19:10,000 --> 00:19:20,000
This is the foundation. Every service in your organization should be registered here. The catalog is the source of truth for what exists, who owns it, and how to contact them.

124
00:19:20,000 --> 00:19:30,000
In the next segment, we recap Series 7 and preview Series 8.

125
00:19:30,000 --> 00:19:40,000
See you in Segment 5.
```

---

### SEGMENT 5: Series 7 Recap & Series 8 Preview
**Timestamp:** 20:00 – 25:00

```
126
00:20:00,000 --> 00:20:10,000
Now let me recap what you built in Series 7.

127
00:20:10,000 --> 00:20:20,000
You understood why FinOps wins reverse without a platform. You learned the three failure modes of platform teams. You learned Team Topologies.

128
00:20:20,000 --> 00:20:30,000
You installed Backstage and ran it locally. You configured GitHub catalog discovery. You registered financial-rag-agent and riskoracle in the catalog.

129
00:20:30,000 --> 00:20:40,000
You created team entities. You verified the catalog shows your services. The foundation for the developer portal is in place.

130
00:20:40,000 --> 00:20:50,000
Before moving to Series 8, verify these things.

131
00:20:50,000 --> 00:21:00,000
First: run yarn dev in the finops-idp directory and confirm both the frontend and backend start without errors.

132
00:21:00,000 --> 00:21:10,000
Second: open localhost:3000 and confirm you see the catalog with your registered services.

133
00:21:10,000 --> 00:21:20,000
Third: open a service page and confirm the overview shows the description, tags, and ownership information.

134
00:21:20,000 --> 00:21:30,000
If you have deployed Backstage to the cluster, run kubectl get pods -n backstage and confirm all pods show Running.

135
00:21:30,000 --> 00:21:40,000
Series 8 is where the catalog becomes a machine. A developer opens the portal, clicks Create New Service, fills in five fields.

136
00:21:40,000 --> 00:21:50,000
And gets: a GitHub repository with production-ready structure. A multi-arch Dockerfile. A Helm chart with Spot tolerations and cost-appropriate resource requests.

137
00:21:50,000 --> 00:22:00,000
An ArgoCD app wired to the cluster. An S3 bucket with lifecycle policy. And a cost estimate. All in under 90 seconds.

138
00:22:00,000 --> 00:22:10,000
The scaffolder is the golden path made real. Every new service created through it is cost-optimized by default.

139
00:22:10,000 --> 00:22:20,000
The developer never thinks about Spot tolerations. Never thinks about lifecycle policies. Never thinks about resource requests. The platform handles it all.

140
00:22:20,000 --> 00:22:30,000
This is the shift from manual to automatic. From hoping engineers do the right thing to making the right thing the default.

141
00:22:30,000 --> 00:22:40,000
Now let me preview the golden path template we build in Series 8.

142
00:22:40,000 --> 00:22:50,000
The template has three sections: parameters — the form fields developers fill in. Steps — the actions that execute when they click create. Output — the links they receive when it is done.

143
00:22:50,000 --> 00:23:00,000
The parameters section has five fields: service name, team, description, traffic tier, and infrastructure choices. Five fields is the maximum for adoption.

144
00:23:00,000 --> 00:23:10,000
If a developer has to make more than five decisions to create a service, they will find a shortcut. And the shortcut will bypass your cost controls.

145
00:23:10,000 --> 00:23:20,000
The traffic tier field is the most important. Low, medium, or high. That one field determines resource requests, Spot tolerations, and the cost estimate.

146
00:23:20,000 --> 00:23:30,000
The developer never thinks about CPU requests or memory limits. They think about traffic. The template handles the rest.

147
00:23:30,000 --> 00:23:40,000
The steps section creates the GitHub repository, pushes the skeleton files, creates the S3 bucket, wires ArgoCD, and registers the service in the catalog.

148
00:23:40,000 --> 00:23:50,000
The output section provides links to the repository, ArgoCD, and the catalog entry.

149
00:23:50,000 --> 00:24:00,000
The skeleton files are the actual code and configuration that gets generated. The Helm values skeleton is where all the FinOps intelligence lives.

150
00:24:00,000 --> 00:24:10,000
Resource requests right-sized based on traffic tier. Spot tolerations for low and medium traffic. HPA for services that need it. Cost attribution labels always applied.

151
00:24:10,000 --> 00:24:20,000
This single file encodes every FinOps lesson from Series 2 through 6. No developer decision required. No platform team review needed. Just automatic cost optimization.

152
00:24:20,000 --> 00:24:30,000
The number that matters: from this point forward, every new service created through this portal costs on average 35% less than services created manually.

153
00:24:30,000 --> 00:24:40,000
That is the compounding effect. As the team grows, the platform enforces the optimization automatically. Without any ongoing attention from the platform team.

154
00:24:40,000 --> 00:24:50,000
Series 8 is the scaffolder. See you there.
```

---

### SEGMENT 6: Deep Dive — The Platform Engineering Maturity Model
**Timestamp:** 25:00 – 30:00

```
155
00:25:00,000 --> 00:25:10,000
Welcome to Segment 6. Let's dive into the platform engineering maturity model.

156
00:25:10,000 --> 00:25:20,000
Understanding where you are today helps you plan where you are going. There are four stages of platform maturity.

157
00:25:20,000 --> 00:25:30,000
Stage 1 is Reactive. The platform team responds to tickets. Engineers file requests for new infrastructure. The platform team provisions it.

158
00:25:30,000 --> 00:25:40,000
Cost optimization happens when someone notices the bill is high. There is no proactive monitoring. No enforcement. No golden paths.

159
00:25:40,000 --> 00:25:50,000
Symptoms: We will look at costs next quarter. I will create that database for you, should be ready in three days. I do not know which team owns this EC2 instance.

160
00:25:50,000 --> 00:26:00,000
Stage 2 is Automated. The platform team has automated the repetitive work. Engineers can self-service basic infrastructure.

161
00:26:00,000 --> 00:26:10,000
There are lifecycle policies on S3 and ECR. Some tagging is enforced. The bill is lower but still unpredictable.

162
00:26:10,000 --> 00:26:20,000
Symptoms: We have Kubecost but nobody looks at it. We have lifecycle policies but half our buckets were created before we added them. We have budget alerts but they go to an email nobody reads.

163
00:26:20,000 --> 00:26:30,000
Stage 3 is Product-Driven. The platform team treats engineers as customers. They have a golden path that encodes FinOps by default.

164
00:26:30,000 --> 00:26:40,000
They measure adoption. They have a developer portal. Budget alerts go to Slack. Every new service is cost-optimized automatically.

165
00:26:40,000 --> 00:26:50,000
Symptoms: Our bill hasn't changed in six months even though we doubled the team. New engineers ship their first service on day three without asking anyone. I can tell you exactly which team spends what, down to the service.

166
00:26:50,000 --> 00:27:00,000
Stage 4 is Engineering Economics. The platform team produces unit economics data that drives product decisions.

167
00:27:00,000 --> 00:27:10,000
Should we add this feature? is answered partly by what does it cost per user? Cost per query, cost per API call, cost per ML prediction. All visible in real time.

168
00:27:10,000 --> 00:27:20,000
Most teams never reach Stage 4. The goal of this course is to take you from Stage 1 to Stage 3. Stage 4 is a natural evolution once Stage 3 is stable.

169
00:27:20,000 --> 00:27:30,000
The platform team charter is the document that defines your mission. Write this down and share it with your engineering leadership before building anything.

170
00:27:30,000 --> 00:27:40,000
Mission: Enable every engineer to ship production-grade, cost-optimized infrastructure in under five minutes without platform team involvement.

171
00:27:40,000 --> 00:27:50,000
What We Own: The developer portal. The golden path templates. The FinOps tooling. The shared infrastructure. The cost controls.

172
00:27:50,000 --> 00:28:00,000
What We Do Not Own: Application code. Product decisions. Individual team's infrastructure after golden path creation.

173
00:28:00,000 --> 00:28:10,000
How We Measure Success: Golden path coverage — percentage of services created via scaffolder, target above 80%. Time to first deploy — new engineer, first service, target under one day.

174
00:28:10,000 --> 00:28:20,000
Budget alert response time — time from alert to action, target under 48 hours. Platform NPS — developer satisfaction score, target above 40. Bill stability — month-over-month variance, target under 10% without deliberate change.

175
00:28:20,000 --> 00:28:30,000
What We Are Not: A ticket queue for infrastructure requests. A review board for every deployment. The only team that can touch cloud resources.

176
00:28:30,000 --> 00:28:40,000
Sharing this charter accomplishes two things. It sets expectations — no more file a ticket and wait three days. And it gets buy-in before the platform team starts building.

177
00:28:40,000 --> 00:28:50,000
You cannot enforce golden paths without leadership backing. The charter is how you get that backing.

178
00:28:50,000 --> 00:29:00,000
Now you understand the platform maturity model. You know where you are and where you are going.

179
00:29:00,000 --> 00:29:10,000
In the next segment, we dive deeper into stream-aligned teams versus platform teams.

180
00:29:10,000 --> 00:29:20,000
See you in Segment 7.
```

---

### SEGMENT 7: Deep Dive — Stream-Aligned Teams vs Platform Teams
**Timestamp:** 30:00 – 35:00

```
181
00:30:00,000 --> 00:30:10,000
Let's dive deeper into stream-aligned teams versus platform teams.

182
00:30:10,000 --> 00:30:20,000
Stream-aligned teams are aligned to a stream of work. A product area, a user journey, a business capability. They build features, ship code, serve customers.

183
00:30:20,000 --> 00:30:30,000
The financial-rag team and the riskoracle team are stream-aligned teams. They own the product. They own the customer experience.

184
00:30:30,000 --> 00:30:40,000
Stream-aligned teams should spend the vast majority of their time on product work. Not on infrastructure decisions. Not on security reviews. Not on cost optimization.

185
00:30:40,000 --> 00:30:50,000
The platform exists to remove that cognitive load. Every time the platform team makes a decision automatic, the stream-aligned team gets that time back.

186
00:30:50,000 --> 00:31:00,000
Platform teams build and maintain the Internal Developer Platform. Their job is to reduce cognitive load for stream-aligned teams.

187
00:31:00,000 --> 00:31:10,000
They treat stream-aligned teams as their customers. They build products, not just tools. They have a roadmap, user research, and adoption metrics. Not just a ticket queue.

188
00:31:10,000 --> 00:31:20,000
The platform team in this course owns the developer portal. The golden path templates. The FinOps tooling. The cost controls.

189
00:31:20,000 --> 00:31:30,000
They do not own application code. They do not own product decisions. They own the platform.

190
00:31:30,000 --> 00:31:40,000
The relationship between stream-aligned teams and platform teams is critical. It is a product-customer relationship. Not a management relationship.

191
00:31:40,000 --> 00:31:50,000
The platform team does not tell stream-aligned teams what to do. They provide capabilities. The stream-aligned teams choose which capabilities to use.

192
00:31:50,000 --> 00:32:00,000
This is the difference between a platform and a gatekeeper. A gatekeeper controls. A platform enables.

193
00:32:00,000 --> 00:32:10,000
The golden path is the primary capability. It is the well-supported way of doing things. Stream-aligned teams can use it or not.

194
00:32:10,000 --> 00:32:20,000
But if they use it, everything works. If they do not, they are on their own. The platform team only supports the golden path.

195
00:32:20,000 --> 00:32:30,000
This creates alignment without control. Stream-aligned teams have freedom. But the freedom comes with responsibility. If they go off the golden path, they own the consequences.

196
00:32:30,000 --> 00:32:40,000
In practice, most teams choose the golden path. It is easier. It is faster. It works. The off-path path requires more work.

197
00:32:40,000 --> 00:32:50,000
This is the key to making FinOps work at scale. The golden path is the cost-optimized path. Most teams choose it because it is easier.

198
00:32:50,000 --> 00:33:00,000
They do not choose it because they care about cost. They choose it because it works. The cost optimization is a side effect.

199
00:33:00,000 --> 00:33:10,000
Now you understand the relationship between stream-aligned teams and platform teams. It is a product-customer relationship.

200
00:33:10,000 --> 00:33:20,000
In the next segment, we look at enabling teams and complicated-subsystem teams.

201
00:33:20,000 --> 00:33:30,000
See you in Segment 8.
```

---

### SEGMENT 8: Enabling Teams & Complicated-Subsystem Teams
**Timestamp:** 35:00 – 40:00

```
202
00:35:00,000 --> 00:35:10,000
Let's look at enabling teams and complicated-subsystem teams.

203
00:35:10,000 --> 00:35:20,000
Enabling teams are temporarily embedded with stream-aligned teams to help them adopt new practices. They run workshops, write documentation, answer questions.

204
00:35:20,000 --> 00:35:30,000
They do not own systems. They transfer knowledge. They are temporary by design. Once the team is up to speed, the enabling team moves on.

205
00:35:30,000 --> 00:35:40,000
In the context of this course, an enabling team would help the financial-rag team migrate their existing workloads to the golden path templates after the IDP is built.

206
00:35:40,000 --> 00:35:50,000
They would run a workshop on how to use the scaffolder. They would answer questions. They would unblock the team.

207
00:35:50,000 --> 00:36:00,000
After a few weeks, the financial-rag team can use the platform independently. The enabling team moves to the next team.

208
00:36:00,000 --> 00:36:10,000
Complicated-subsystem teams own particularly complex parts of the system that require deep expertise. For riskoracle, the ML training infrastructure is owned by a complicated-subsystem team.

209
00:36:10,000 --> 00:36:20,000
They provide it as a service to other teams. The Spot engineering, checkpointing, and GPU node pools are their responsibility.

210
00:36:20,000 --> 00:36:30,000
They are not a platform team. They do not build general-purpose tools. They build specialized capabilities that are used by specific teams.

211
00:36:30,000 --> 00:36:40,000
The key difference between platform teams and complicated-subsystem teams is scope. Platform teams build general-purpose capabilities. Complicated-subsystem teams build specialized capabilities.

212
00:36:40,000 --> 00:36:50,000
Platform teams serve the entire organization. Complicated-subsystem teams serve specific use cases.

213
00:36:50,000 --> 00:37:00,000
Now let me give you the complete interaction model:

214
00:37:00,000 --> 00:37:10,000
Stream-aligned teams consume golden paths from the platform team. They also consume specialized services from complicated-subsystem teams when needed.

215
00:37:10,000 --> 00:37:20,000
The platform team builds the developer portal and the golden path templates. They also build the FinOps dashboards and cost controls.

216
00:37:20,000 --> 00:37:30,000
Enabling teams embed with stream-aligned teams to transfer knowledge of platform capabilities. They help teams migrate to the golden path.

217
00:37:30,000 --> 00:37:40,000
Complicated-subsystem teams provide specialized services like the ML training platform. They are consumed by stream-aligned teams that need those capabilities.

218
00:37:40,000 --> 00:37:50,000
This model works because it aligns responsibility with expertise. Each team does what they are best at.

219
00:37:50,000 --> 00:38:00,000
Stream-aligned teams build product. Platform teams build the platform. Enabling teams transfer knowledge. Complicated-subsystem teams build specialized capabilities.

220
00:38:00,000 --> 00:38:10,000
Now let me give you a concrete example of how this works in practice.

221
00:38:10,000 --> 00:38:20,000
The financial-rag team needs a new service. They open the developer portal built by the platform team. They fill in the fields.

222
00:38:20,000 --> 00:38:30,000
The platform team's golden path template creates everything automatically. The enabling team helped them learn how to use the portal.

223
00:38:30,000 --> 00:38:40,000
If they need GPU training infrastructure, they consume it from the complicated-subsystem team that owns the ML training platform.

224
00:38:40,000 --> 00:38:50,000
This is the complete picture. Every team has a role. Every team knows what they own. The platform works.

225
00:38:50,000 --> 00:39:00,000
In the next segment, we dive deep into golden paths.

226
00:39:00,000 --> 00:39:10,000
See you in Segment 9.
```

---

### SEGMENT 9: Deep Dive — Golden Paths — Definition & Design Principles
**Timestamp:** 40:00 – 45:00

```
227
00:40:00,000 --> 00:40:10,000
Let's dive deep into golden paths. This is the core concept that makes the IDP work.

228
00:40:10,000 --> 00:40:20,000
A golden path is the well-maintained, well-documented, well-supported way of doing something on your platform. It is the paved road.

229
00:40:20,000 --> 00:40:30,000
Developers can go off-road. But if they do, they are on their own. The platform team only supports the golden path.

230
00:40:30,000 --> 00:40:40,000
The name comes from the idea that this is the path the platform team promises to keep working, keep secure, keep cost-optimized, and keep documented.

231
00:40:40,000 --> 00:40:50,000
The golden path has several design principles. Let me walk you through each one.

232
00:40:50,000 --> 00:41:00,000
Principle 1: Minimal decisions. The developer should make as few decisions as possible. Every decision is cognitive load. Remove unnecessary decisions.

233
00:41:00,000 --> 00:41:10,000
For deploying a service, the golden path should require five or fewer decisions. Service name. Team. Description. Traffic tier. Infrastructure choices.

234
00:41:10,000 --> 00:41:20,000
Everything else is automated. Resource requests, Spot tolerations, lifecycle policies, cost attribution. All automatic.

235
00:41:20,000 --> 00:41:30,000
Principle 2: Cost visible. The golden path should show the estimated cost before the developer commits. This changes behaviour.

236
00:41:30,000 --> 00:41:40,000
When a developer sees $120 a month next to their service name, they think about whether they need that traffic tier. They compare to other services. They internalize unit economics.

237
00:41:40,000 --> 00:41:50,000
Principle 3: Cost-optimized by default. The golden path should use cost-optimized defaults. Spot tolerations for low and medium traffic. gp3 for storage. Lifecycle policies for S3.

238
00:41:50,000 --> 00:42:00,000
The developer should not have to think about these things. The platform handles them. The default is the cost-optimized default.

239
00:42:00,000 --> 00:42:10,000
Principle 4: Self-service. The golden path should be accessible without human intervention. No tickets. No approval processes.

240
00:42:10,000 --> 00:42:20,000
The developer opens the portal, fills in the fields, and the service is created. The platform team is not involved. The developer does not wait.

241
00:42:20,000 --> 00:42:30,000
Principle 5: Universal. The golden path should work for everyone. The same path for all teams. This creates consistency. Consistency enables automation.

242
00:42:30,000 --> 00:42:40,000
If every team uses the same golden path, the platform team can optimize it once and everyone benefits. If each team has their own path, optimization is fragmented.

243
00:42:40,000 --> 00:42:50,000
Principle 6: Incremental. The golden path should support gradual adoption. Teams can migrate existing services incrementally.

244
00:42:50,000 --> 00:43:00,000
You do not need to migrate everything at once. Start with new services. Then migrate existing services when they need updates.

245
00:43:00,000 --> 00:43:10,000
Principle 7: Well-documented. The golden path should have clear documentation. How to use it. What it does. What the trade-offs are.

246
00:43:10,000 --> 00:43:20,000
The documentation should be in the developer portal. Accessible right where the developer is working.

247
00:43:20,000 --> 00:43:30,000
Principle 8: Well-supported. The platform team should actively support the golden path. They should fix bugs. They should respond to issues.

248
00:43:30,000 --> 00:43:40,000
If developers have problems with the golden path, the platform team should prioritize fixing them. The golden path is the product.

249
00:43:40,000 --> 00:43:50,000
Now let me give you a concrete example of what the golden path looks like for the financial-rag-agent.

250
00:43:50,000 --> 00:44:00,000
For deploying a new microservice, the golden path includes: GitHub repository created automatically. Multi-arch Dockerfile supporting amd64 and arm64.

251
00:44:00,000 --> 00:44:10,000
Helm chart with resource requests sized to traffic tier. Spot tolerations for low and medium traffic. S3 bucket with lifecycle policy. ArgoCD deployment wired. Kubecost cost attribution tags.

252
00:44:10,000 --> 00:44:20,000
Estimated monthly cost displayed before the developer clicks confirm. All of this happens automatically. The developer does not make any of these decisions.

253
00:44:20,000 --> 00:44:30,000
They just answer: what is your service name? Which team? Which traffic tier? Do you need a database? Do you need a cache?

254
00:44:30,000 --> 00:44:40,000
Five questions. That is the golden path. Everything else is automatic. This is how you scale FinOps. By making it invisible.

255
00:44:40,000 --> 00:44:50,000
In the next segment, we look at what falls inside the golden path versus what falls outside.

256
00:44:50,000 --> 00:45:00,000
See you in Segment 10.
```

---

### SEGMENT 10: Golden Paths — What Falls Inside vs Outside
**Timestamp:** 45:00 – 50:00

```
257
00:45:00,000 --> 00:45:10,000
What falls inside the golden path versus what falls outside. This is an important distinction.

258
00:45:10,000 --> 00:45:20,000
The golden path covers the common cases. The things that most teams need most of the time. The things that can be standardized.

259
00:45:20,000 --> 00:45:30,000
Inside the golden path: standard microservices. APIs. Batch jobs. Simple databases. Standard S3 buckets.

260
00:45:30,000 --> 00:45:40,000
These are the building blocks of most applications. They can be templated. They can be automated. They should be on the golden path.

261
00:45:40,000 --> 00:45:50,000
Outside the golden path: specialized workloads. GPU training. Streaming data pipelines. Legacy systems. Custom databases. Unique architectures.

262
00:45:50,000 --> 00:46:00,000
These are the things that do not fit the template. They require special handling. They are outside the golden path.

263
00:46:00,000 --> 00:46:10,000
The platform team does not support workloads outside the golden path. But they do not prevent them. Developers can go off-road.

264
00:46:10,000 --> 00:46:20,000
They just have to understand the consequences. The platform team will not fix their problems. The cost controls will not apply automatically.

265
00:46:20,000 --> 00:46:30,000
The rule is simple: if you go outside the golden path, you own it yourself. You are responsible for the cost. You are responsible for the security. You are responsible for the documentation.

266
00:46:30,000 --> 00:46:40,000
This is not restriction. It is clarity. The platform does not prevent innovation. It prevents accidental deviation from best practices.

267
00:46:40,000 --> 00:46:50,000
If you need to go off-road, you can. But you have to justify it. You have to document it. You have to own it.

268
00:46:50,000 --> 00:47:00,000
The off-road process is simple. Create an Architecture Decision Record. Explain why the golden path does not work for your use case. Get it approved by the platform team lead.

269
00:47:00,000 --> 00:47:10,000
Then build your off-road solution. The platform team will not build it for you. But they will not block it either.

270
00:47:10,000 --> 00:47:20,000
This is the balance between standardization and flexibility. The golden path covers 80% of use cases. The other 20% go off-road.

271
00:47:20,000 --> 00:47:30,000
The 80% is where the cost savings live. The 20% is where the innovation happens. Both are important.

272
00:47:30,000 --> 00:47:40,000
Now let me give you an example of what falls outside the golden path at the startup.

273
00:47:40,000 --> 00:47:50,000
The riskoracle GPU training infrastructure is outside the golden path. It requires specialized hardware. It requires custom scheduling. It requires Spot engineering.

274
00:47:50,000 --> 00:48:00,000
The platform team does not build this. The complicated-subsystem team builds it. They provide it as a service to the riskoracle team.

275
00:48:00,000 --> 00:48:10,000
The golden path covers the standard microservices. The financial-rag API service. The ingestion pipeline. The web frontend.

276
00:48:10,000 --> 00:48:20,000
Everything that does not require specialized hardware or specialized scheduling is on the golden path. Everything else is off-road.

277
00:48:20,000 --> 00:48:30,000
This is a practical approach. The platform team focuses on what they can standardize. The rest is handled by specialized teams.

278
00:48:30,000 --> 00:48:40,000
The key is to keep the golden path broad enough to cover most use cases. And keep the off-road process simple enough that it is not a blocker.

279
00:48:40,000 --> 00:48:50,000
In the next segment, we look at the Backstage architecture in detail.

280
00:48:50,000 --> 00:49:00,000
See you in Segment 11.
```

---

### SEGMENT 11: Backstage Architecture — Frontend, Backend & Plugins
**Timestamp:** 50:00 – 55:00

```
281
00:50:00,000 --> 00:50:10,000
Let's look at the Backstage architecture in detail.

282
00:50:10,000 --> 00:50:20,000
Backstage has a frontend and a backend. The frontend is built with React. The backend is built with Node.js.

283
00:50:20,000 --> 00:50:30,000
The frontend serves the user interface. The catalog pages. The scaffolder forms. The Kubernetes tab. The FinOps cost card.

284
00:50:30,000 --> 00:50:40,000
The frontend communicates with the backend via REST API. The backend handles the heavy lifting. Database queries. GitHub API calls. Kubernetes API calls.

285
00:50:40,000 --> 00:50:50,000
Plugins extend both the frontend and backend. A plugin is a package that adds functionality. The catalog plugin. The scaffolder plugin. The Kubernetes plugin.

286
00:50:50,000 --> 00:51:00,000
Each plugin has a frontend component and a backend component. The frontend component renders the UI. The backend component handles the API.

287
00:51:00,000 --> 00:51:10,000
The plugin architecture is what makes Backstage extensible. You can build your own plugins for anything. The FinOps plugin we build in Series 10 is a custom plugin.

288
00:51:10,000 --> 00:51:20,000
The core Backstage application has a few built-in plugins. The catalog plugin provides the service inventory. The scaffolder plugin provides the golden path templates.

289
00:51:20,000 --> 00:51:30,000
The TechDocs plugin provides documentation. The search plugin provides search. The user settings plugin provides user preferences.

290
00:51:30,000 --> 00:51:40,000
Everything else is an optional plugin. You add the plugins you need. You do not install plugins you do not need.

291
00:51:40,000 --> 00:51:50,000
The configuration file is app-config.yaml. This file controls everything. GitHub integration. Kubernetes access. Catalog discovery. Plugin configuration.

292
00:51:50,000 --> 00:52:00,000
The configuration file is the source of truth for the Backstage instance. Every plugin has its own configuration section.

293
00:52:00,000 --> 00:52:10,000
The database is PostgreSQL. Backstage uses it to store catalog data. The catalog entities. The scaffolder templates. The user preferences.

294
00:52:10,000 --> 00:52:20,000
The database is critical. If the database is lost, the catalog is lost. Back up the database regularly.

295
00:52:20,000 --> 00:52:30,000
The authentication is configurable. Backstage supports GitHub OAuth, Okta, Google, and many others. We use GitHub OAuth in this course.

296
00:52:30,000 --> 00:52:40,000
The authentication flow: The user logs in with GitHub. Backstage validates the token. The user is authenticated. The user can then interact with the catalog and scaffolder.

297
00:52:40,000 --> 00:52:50,000
The authorization is also configurable. Backstage supports RBAC and policies. We configure basic RBAC in this course.

298
00:52:50,000 --> 00:53:00,000
The deployment architecture: Backstage can be deployed as a container. It runs on Kubernetes. It runs on EKS. It runs on any Kubernetes cluster.

299
00:53:00,000 --> 00:53:10,000
The deployment includes the frontend, backend, and database. The frontend and backend are separate containers. The database is a separate service.

300
00:53:10,000 --> 00:53:20,000
The frontend container serves the React app. The backend container serves the API. The database container stores the data.

301
00:53:20,000 --> 00:53:30,000
In production, you use managed services. RDS for PostgreSQL. EKS for the containers. ALB for the ingress.

302
00:53:30,000 --> 00:53:40,000
The Backstage deployment is well-tested. Many organizations run it in production. It is stable and scalable.

303
00:53:40,000 --> 00:53:50,000
Now you understand the Backstage architecture. Frontend, backend, plugins, configuration, database, authentication, and deployment.

304
00:53:50,000 --> 00:54:00,000
In the next segment, we walk through the Backstage installation in detail.

305
00:54:00,000 --> 00:54:10,000
See you in Segment 12.
```

---

### SEGMENT 12: Backstage Installation — Detailed Walkthrough
**Timestamp:** 55:00 – 60:00

```
306
00:55:00,000 --> 00:55:10,000
Let's walk through the Backstage installation in detail.

307
00:55:10,000 --> 00:55:20,000
Prerequisites: Node.js 18 or higher. Yarn 1.22 or higher. PostgreSQL 12 or higher.

308
00:55:20,000 --> 00:55:30,000
[Types: node --version]
▶ Pronounced as: "Node, dash, dash, version"

309
00:55:30,000 --> 00:55:40,000
[Types: yarn --version]
▶ Pronounced as: "Yarn, dash, dash, version"

310
00:55:40,000 --> 00:55:50,000
[Types: psql --version]
▶ Pronounced as: "Psql, dash, dash, version"

311
00:55:50,000 --> 00:56:00,000
Create the Backstage app:

312
00:56:00,000 --> 00:56:10,000
[Types: npx @backstage/create-app@latest]
▶ Pronounced as: "N-P-X, at, backstage, slash, create, app, at, latest"

313
00:56:10,000 --> 00:56:20,000
When prompted: enter finops-idp as the app name. Select PostgreSQL as the database.

314
00:56:20,000 --> 00:56:30,000
The CLI will scaffold the entire application. This takes a few minutes. The scaffold includes the frontend, backend, and configuration.

315
00:56:30,000 --> 00:56:40,000
[Types: cd finops-idp]

316
00:56:40,000 --> 00:56:50,000
[Types: yarn install]
▶ Pronounced as: "Yarn, install"

317
00:56:50,000 --> 00:57:00,000
This installs all dependencies. This also takes a few minutes.

318
00:57:00,000 --> 00:57:10,000
Now configure the environment variables. Backstage uses environment variables for sensitive configuration.

319
00:57:10,000 --> 00:57:20,000
[Types: cp .env.example .env]

320
00:57:20,000 --> 00:57:30,000
Edit the .env file. Set the database connection string. Set the GitHub token. Set the OAuth client ID and secret.

321
00:57:30,000 --> 00:57:40,000
The database connection string format is postgresql://user:password@host:port/database.

322
00:57:40,000 --> 00:57:50,000
The GitHub token needs repo access. It is used to read catalog files and create repositories.

323
00:57:50,000 --> 00:58:00,000
Now start Backstage in development mode:

324
00:58:00,000 --> 00:58:10,000
[Types: yarn dev]
▶ Pronounced as: "Yarn, dev"

325
00:58:10,000 --> 00:58:20,000
Backstage starts on port 3000 for the frontend and 7007 for the backend.

326
00:58:20,000 --> 00:58:30,000
Open localhost:3000 in your browser. You should see the Backstage home page.

327
00:58:30,000 --> 00:58:40,000
The first login will redirect to GitHub. Authorize the application. You will be redirected back to Backstage.

328
00:58:40,000 --> 00:58:50,000
The home page shows the catalog, scaffolder, and TechDocs. The catalog will be empty. The scaffolder will have no templates.

329
00:58:50,000 --> 00:59:00,000
If you see errors, check the logs. Common errors: database connection issues, GitHub token issues, OAuth configuration issues.

330
00:59:00,000 --> 00:59:10,000
The logs are in the terminal where you ran yarn dev. They show the backend logs. They show API errors and database errors.

331
00:59:10,000 --> 00:59:20,000
[Types: yarn dev --check]
▶ Pronounced as: "Yarn, dev, dash, dash, check"

332
00:59:20,000 --> 00:59:30,000
This runs a check of the configuration. It validates the database connection and GitHub token.

333
00:59:30,000 --> 00:59:40,000
If the check passes, Backstage is configured correctly. If it fails, fix the errors before proceeding.

334
00:59:40,000 --> 00:59:50,000
Now you have a running Backstage instance. The catalog is ready. The scaffolder is ready. The TechDocs are ready.

335
00:59:50,000 --> 01:00:00,000
In the next segment, we look at the app-config.yaml file in detail.

336
01:00:00,000 --> 01:00:10,000
See you in Segment 13.
```

---

### SEGMENT 13: Backstage Configuration — app-config.yaml Deep Dive
**Timestamp:** 60:00 – 65:00

```
337
01:00:00,000 --> 01:00:10,000
Let's look at the app-config.yaml file in detail.

338
01:00:10,000 --> 01:00:20,000
This file controls everything about your Backstage instance. It is the source of truth for configuration.

339
01:00:20,000 --> 01:00:30,000
The app section configures the frontend. The baseUrl is the URL where the frontend is served. The title is the browser title.

340
01:00:30,000 --> 01:00:40,000
[Types: cat app-config.yaml | head -20]

341
01:00:40,000 --> 01:00:50,000
The backend section configures the backend. The baseUrl is the URL where the backend API is served. The listen port is the port the backend listens on.

342
01:00:50,000 --> 01:01:00,000
The database section configures the database. The client is PostgreSQL. The connection string is from environment variables.

343
01:01:00,000 --> 01:01:10,000
[Types: cat app-config.yaml | grep -A5 "database:"]

344
01:01:10,000 --> 01:01:20,000
The integrations section configures external integrations. GitHub, GitLab, and others.

345
01:01:20,000 --> 01:01:30,000
[Types: cat app-config.yaml | grep -A10 "integrations:"]

346
01:01:30,000 --> 01:01:40,000
The auth section configures authentication. The providers section configures the authentication providers.

347
01:01:40,000 --> 01:01:50,000
[Types: cat app-config.yaml | grep -A15 "auth:"]

348
01:01:50,000 --> 01:02:00,000
The catalog section configures the catalog. The import section configures how catalog files are imported. The rules section configures what entity types are allowed.

349
01:02:00,000 --> 01:02:10,000
[Types: cat app-config.yaml | grep -A20 "catalog:"]

350
01:02:10,000 --> 01:02:20,000
The locations section configures where catalog files are discovered. We add the GitHub discovery here.

351
01:02:20,000 --> 01:02:30,000
The scaffolder section configures the scaffolder. The gitAuthor section configures the author of the commits.

352
01:02:30,000 --> 01:02:40,000
[Types: cat app-config.yaml | grep -A5 "scaffolder:"]

353
01:02:40,000 --> 01:02:50,000
The kubernetes section configures the Kubernetes plugin. The cluster locator methods define how clusters are discovered.

354
01:02:50,000 --> 01:03:00,000
[Types: cat app-config.yaml | grep -A10 "kubernetes:"]

355
01:03:00,000 --> 01:03:10,000
The proxy section configures the proxy. The proxy forwards requests to external services.

356
01:03:10,000 --> 01:03:20,000
The plugin configuration sections are plugin-specific. Each plugin has its own configuration section.

357
01:03:20,000 --> 01:03:30,000
The app-config.yaml file is the single source of truth. Changes to configuration are made here. Do not hardcode configuration in code.

358
01:03:30,000 --> 01:03:40,000
Now let me show you the key configuration changes we make in this course.

359
01:03:40,000 --> 01:03:50,000
We add GitHub catalog discovery. We add Kubernetes cluster access. We add ArgoCD integration. We add the FinOps plugin.

360
01:03:50,000 --> 01:04:00,000
Each change is a small addition to the app-config.yaml file. Each addition adds a new capability to the platform.

361
01:04:00,000 --> 01:04:10,000
The app-config.yaml file is read at startup. Changes require a restart of the Backstage process.

362
01:04:10,000 --> 01:04:20,000
[Types: yarn dev --config app-config.yaml]
▶ Pronounced as: "Yarn, dev, dash, dash, config, app, dash, config, dot, yaml"

363
01:04:20,000 --> 01:04:30,000
This starts Backstage with the specified configuration file. Useful if you have multiple environments.

364
01:04:30,000 --> 01:04:40,000
Now you understand the app-config.yaml file. Every configuration change we make in this course is documented.

365
01:04:40,000 --> 01:04:50,000
In the next segment, we look at catalog entity types in detail.

366
01:04:50,000 --> 01:05:00,000
See you in Segment 14.
```

---

### SEGMENT 14: Deep Dive — Catalog Entity Types — Component, API, Resource
**Timestamp:** 65:00 – 70:00

```
367
01:05:00,000 --> 01:05:10,000
Let's look at catalog entity types in detail.

368
01:05:10,000 --> 01:05:20,000
The catalog is the source of truth for everything in your platform. Every service, API, database, team, and user is represented as an entity.

369
01:05:20,000 --> 01:05:30,000
The most common entity type is Component. A Component represents a deployable service, library, or website.

370
01:05:30,000 --> 01:05:40,000
The financial-rag-agent and riskoracle are Components. They are deployable services. They have a lifecycle, an owner, and dependencies.

371
01:05:40,000 --> 01:05:50,000
The API entity type represents an API spec. OpenAPI, gRPC, or GraphQL. It documents the API endpoints, parameters, and responses.

372
01:05:50,000 --> 01:06:00,000
The Resource entity type represents an infrastructure component. A database, a cache, a load balancer, a VPC.

373
01:06:00,000 --> 01:06:10,000
[Types: cat > financial-rag-postgres.yaml << 'EOF'
apiVersion: backstage.io/v1alpha1
kind: Resource
metadata:
  name: financial-rag-postgres
  title: Financial RAG PostgreSQL
  description: "RDS PostgreSQL 15 with pgvector extension for embeddings"
  annotations:
    finops.io/monthly-cost: "126"
    finops.io/reserved-instance-expiry: "2025-03-15"
spec:
  type: database
  lifecycle: production
  owner: group:team-financial-rag
  system: financial-intelligence
EOF]

374
01:06:10,000 --> 01:06:20,000
The API entity type represents an API specification:

375
01:06:20,000 --> 01:06:30,000
[Types: cat > financial-rag-api.yaml << 'EOF'
apiVersion: backstage.io/v1alpha1
kind: API
metadata:
  name: financial-rag-api
  title: Financial RAG Query API
  description: "REST API for querying SEC filings via RAG pipeline"
spec:
  type: openapi
  lifecycle: production
  owner: group:team-financial-rag
  system: financial-intelligence
  definition: |
    openapi: "3.0.0"
    info:
      title: Financial RAG Query API
      version: "1.0.0"
    paths:
      /query:
        post:
          summary: Query SEC filings using RAG
          requestBody:
            content:
              application/json:
                schema:
                  type: object
                  properties:
                    question:
                      type: string
                    ticker:
                      type: string
          responses:
            "200":
              description: RAG answer with source citations
EOF]

376
01:06:30,000 --> 01:06:40,000
Each entity type has a specific purpose. Component for services. API for API specs. Resource for infrastructure.

377
01:06:40,000 --> 01:06:50,000
The relations between entities are defined in the spec section. dependsOn lists dependencies. providesApis lists APIs provided.

378
01:06:50,000 --> 01:07:00,000
The financial-rag-agent Component dependsOn the financial-rag-postgres Resource. It providesApis the financial-rag-api API.

379
01:07:00,000 --> 01:07:10,000
These relations are displayed in the catalog UI. They show the dependency graph. They show what depends on what.

380
01:07:10,000 --> 01:07:20,000
The dependency graph is useful for impact analysis. If PostgreSQL is down, which services are affected? The catalog tells you.

381
01:07:20,000 --> 01:07:30,000
Now you understand the Component, API, and Resource entity types. They represent the technical assets of your platform.

382
01:07:30,000 --> 01:07:40,000
In the next segment, we look at the System, Domain, Group, and User entity types.

383
01:07:40,000 --> 01:07:50,000
See you in Segment 15.
```

---

### SEGMENT 15: Deep Dive — Catalog Entity Types — System, Domain, Group, User
**Timestamp:** 70:00 – 75:00

```
384
01:10:00,000 --> 01:10:10,000
Let's look at the System, Domain, Group, and User entity types.

385
01:10:10,000 --> 01:10:20,000
The System entity type represents a collection of components. A system is a logical grouping of services that work together.

386
01:10:20,000 --> 01:10:30,000
The financial-intelligence system includes the financial-rag-agent and riskoracle components. They work together to provide financial intelligence capabilities.

387
01:10:30,000 --> 01:10:40,000
[Types: cat > financial-intelligence-system.yaml << 'EOF'
apiVersion: backstage.io/v1alpha1
kind: System
metadata:
  name: financial-intelligence
  title: Financial Intelligence System
  description: "AI-powered financial document analysis and risk calculation"
spec:
  owner: group:team-financial-rag
  domain: fintech
EOF]

388
01:10:40,000 --> 01:10:50,000
The Domain entity type represents a business domain. A domain is a high-level grouping of systems.

389
01:10:50,000 --> 01:11:00,000
The fintech domain includes all systems related to financial technology. The financial-intelligence system is part of the fintech domain.

390
01:11:00,000 --> 01:11:10,000
[Types: cat > fintech-domain.yaml << 'EOF'
apiVersion: backstage.io/v1alpha1
kind: Domain
metadata:
  name: fintech
  title: FinTech Domain
  description: "All financial technology products and services"
spec:
  owner: group:engineering-leadership
EOF]

391
01:11:10,000 --> 01:11:20,000
The Group entity type represents a team. A group is a collection of users who work together.

392
01:11:20,000 --> 01:11:30,000
[Types: cat > team-platform.yaml << 'EOF'
apiVersion: backstage.io/v1alpha1
kind: Group
metadata:
  name: team-platform
  title: Platform Team
  description: "Owns the Internal Developer Platform and shared infrastructure"
spec:
  type: team
  parent: engineering
  children: []
  members:
    - platform-engineer-1
    - platform-engineer-2
EOF]

393
01:11:30,000 --> 01:11:40,000
The User entity type represents an engineer. A user is a member of a group.

394
01:11:40,000 --> 01:11:50,000
[Types: cat > user-aayo.yaml << 'EOF'
apiVersion: backstage.io/v1alpha1
kind: User
metadata:
  name: aayo
  title: Aayostem
spec:
  profile:
    displayName: Aayostem
    email: aayo@yourcompany.com
    picture: https://avatars.githubusercontent.com/u/12345
  memberOf:
    - group:team-financial-rag
    - group:team-platform
EOF]

395
01:11:50,000 --> 01:12:00,000
The hierarchy is Domain → System → Component. Domain contains Systems. Systems contain Components.

396
01:12:00,000 --> 01:12:10,000
The hierarchy for teams is Group → User. Groups contain Users. Users are members of Groups.

397
01:12:10,000 --> 01:12:20,000
The catalog uses these hierarchies for organization. The catalog UI shows the hierarchy. It shows which services are in which system. It shows which users are in which group.

398
01:12:20,000 --> 01:12:30,000
The ownership model is critical. Every entity has an owner. The owner is a group or a user.

399
01:12:30,000 --> 01:12:40,000
The owner is responsible for the entity. They are the point of contact. They are the decision maker for changes.

400
01:12:40,000 --> 01:12:50,000
The catalog uses ownership for notifications. If a service is failing, the owner is notified. If a cost alert is triggered, the owner is notified.

401
01:12:50,000 --> 01:13:00,000
Now you understand the System, Domain, Group, and User entity types. They represent the organizational and business structure.

402
01:13:00,000 --> 01:13:10,000
In the next segment, we write the catalog-info.yaml for the financial-rag-agent.

403
01:13:10,000 --> 01:13:20,000
See you in Segment 16.
```

---

### SEGMENT 16: Writing catalog-info.yaml for financial-rag-agent
**Timestamp:** 75:00 – 80:00

```
404
01:15:00,000 --> 01:15:10,000
Let's write the catalog-info.yaml for the financial-rag-agent.

405
01:15:10,000 --> 01:15:20,000
This file defines the financial-rag-agent as a Component in the catalog. It includes all the metadata, annotations, and spec.

406
01:15:20,000 --> 01:15:30,000
[Types: cat > catalog-info.yaml << 'EOF'
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: financial-rag-agent
  title: Financial RAG Agent
  description: |
    Production RAG system for financial document queries.
    Ingests SEC EDGAR 10-K and 10-Q filings, stores embeddings in pgvector,
    and answers natural language questions using LLM function calling.
  annotations:
    github.com/project-slug: aayostem/financial-rag-agent
    argocd/app-name: financial-rag-agent-prod
    backstage.io/kubernetes-namespace: financial-rag
    backstage.io/kubernetes-label-selector: app=financial-rag-agent
    kubecost.com/namespace: financial-rag
    finops.io/team: team-financial-rag
    finops.io/monthly-budget: "15000"
    finops.io/alert-thresholds: "75,90,100"
    prometheus.io/rule: financial_rag:api_error_rate:rate1h
    pagerduty.com/service-id: P123456
  tags:
    - python
    - fastapi
    - rag
    - llm
    - pgvector
    - production
    - finops-optimized
  links:
    - url: https://github.com/aayostem/financial-rag-agent
      title: GitHub Repository
      icon: github
    - url: https://argocd.yourcompany.com/applications/financial-rag-agent-prod
      title: ArgoCD Application
      icon: dashboard
    - url: https://grafana.yourcompany.com/d/financial-rag
      title: Grafana Dashboard
      icon: dashboard
    - url: https://yourcompany.slack.com/archives/C12345
      title: Slack Channel (#financial-rag)
      icon: chat
spec:
  type: service
  lifecycle: production
  owner: group:team-financial-rag
  system: financial-intelligence
  dependsOn:
    - resource:default/financial-rag-postgres
    - resource:default/financial-rag-redis
    - component:default/llm-ingest
  providesApis:
    - financial-rag-query-api
EOF]

407
01:15:30,000 --> 01:15:40,000
Now let me walk through each section.

408
01:15:40,000 --> 01:15:50,000
The metadata section contains the name, title, and description. The description is multi-line. It explains what the service does.

409
01:15:50,000 --> 01:16:00,000
The annotations section contains all the integrations. github.com/project-slug links to GitHub. argocd/app-name links to ArgoCD. backstage.io/kubernetes-namespace links to Kubernetes.

410
01:16:00,000 --> 01:16:10,000
kubecost.com/namespace links to Kubecost. finops.io/team and finops.io/monthly-budget are used by the FinOps plugin. prometheus.io/rule links to Prometheus alerts. pagerduty.com/service-id links to PagerDuty.

411
01:16:10,000 --> 01:16:20,000
The tags section is for filtering and categorization. The links section provides quick access to dashboards and tools.

412
01:16:20,000 --> 01:16:30,000
The spec section defines the type, lifecycle, owner, system, dependencies, and APIs.

413
01:16:30,000 --> 01:16:40,000
The owner is group:team-financial-rag. The system is financial-intelligence. The dependsOn lists the PostgreSQL and Redis resources. The providesApis lists the query API.

414
01:16:40,000 --> 01:16:50,000
This file is committed to the root of the financial-rag-agent repository. The GitHub catalog discovery picks it up.

415
01:16:50,000 --> 01:17:00,000
Now let me show you the FinOps annotations in detail.

416
01:17:00,000 --> 01:17:10,000
finops.io/team is the team that owns the service. This is used for cost attribution. Kubecost uses this to show cost by team.

417
01:17:10,000 --> 01:17:20,000
finops.io/monthly-budget is the monthly budget for the service. This is used for budget alerts. When the service exceeds 75%, 90%, or 100% of the budget, an alert is sent.

418
01:17:20,000 --> 01:17:30,000
finops.io/alert-thresholds is the list of alert thresholds. The default is 75%, 90%, and 100%.

419
01:17:30,000 --> 01:17:40,000
These annotations are used by the Series 10 FinOps plugin. The plugin displays the cost, budget, and alerts in the catalog.

420
01:17:40,000 --> 01:17:50,000
Now let's commit this file:

421
01:17:50,000 --> 01:18:00,000
[Types: git add catalog-info.yaml]
[Types: git commit -m "Add Backstage catalog definition for financial-rag-agent"]
[Types: git push]

422
01:18:00,000 --> 01:18:10,000
After the GitHub catalog discovery runs, the financial-rag-agent appears in the Backstage catalog.

423
01:18:10,000 --> 01:18:20,000
Now you have a complete catalog definition for the financial-rag-agent. Every service should have a similar definition.

424
01:18:20,000 --> 01:18:30,000
In the next segment, we write the catalog-info.yaml for the riskoracle.

425
01:18:30,000 --> 01:18:40,000
See you in Segment 17.
```

---

### SEGMENT 17: Writing catalog-info.yaml for riskoracle
**Timestamp:** 80:00 – 85:00

```
426
01:20:00,000 --> 01:20:10,000
Let's write the catalog-info.yaml for the riskoracle.

427
01:20:10,000 --> 01:20:20,000
The riskoracle is a different kind of service. It is an MLOps risk calculation engine. It runs GPU batch workloads.

428
01:20:20,000 --> 01:20:30,000
The catalog definition reflects its specific characteristics.

429
01:20:30,000 --> 01:20:40,000
[Types: cat > catalog-info.yaml << 'EOF'
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: riskoracle
  title: RiskOracle
  description: |
    MLOps risk calculation engine for financial portfolio risk modeling.
    Runs GPU-accelerated batch workloads for risk calculation and stress testing.
  annotations:
    github.com/project-slug: aayostem/riskoracle
    argocd/app-name: riskoracle-prod
    backstage.io/kubernetes-namespace: riskoracle
    backstage.io/kubernetes-label-selector: app=riskoracle
    kubecost.com/namespace: riskoracle
    finops.io/team: team-riskoracle
    finops.io/monthly-budget: "8000"
    finops.io/alert-thresholds: "75,90,100"
    finops.io/spot-eligible: "true"
    prometheus.io/rule: riskoracle:job_failure_rate:rate1h
  tags:
    - python
    - mlops
    - pytorch
    - gpu
    - batch
    - production
    - finops-optimized
    - spot-enabled
  links:
    - url: https://github.com/aayostem/riskoracle
      title: GitHub Repository
      icon: github
    - url: https://argocd.yourcompany.com/applications/riskoracle-prod
      title: ArgoCD Application
      icon: dashboard
    - url: https://grafana.yourcompany.com/d/riskoracle
      title: Grafana Dashboard
      icon: dashboard
spec:
  type: service
  lifecycle: production
  owner: group:team-riskoracle
  system: financial-intelligence
  dependsOn:
    - resource:default/riskoracle-postgres
    - resource:default/riskoracle-redis
    - resource:default/riskoracle-gpu-nodegroup
  providesApis:
    - riskoracle-api
EOF]

430
01:20:40,000 --> 01:20:50,000
Now let me highlight the differences from the financial-rag-agent.

431
01:20:50,000 --> 01:21:00,000
The tags include mlops, pytorch, gpu, batch, and spot-enabled. These reflect the nature of the workload.

432
01:21:00,000 --> 01:21:10,000
The finops.io/spot-eligible annotation is true. This indicates that the service can run on Spot instances.

433
01:21:10,000 --> 01:21:20,000
The dependsOn includes the gpu-nodegroup resource. This is a specialized resource that only the riskoracle uses.

434
01:21:20,000 --> 01:21:30,000
Now create the resource definitions for the dependencies:

435
01:21:30,000 --> 01:21:40,000
[Types: cat > riskoracle-postgres.yaml << 'EOF'
apiVersion: backstage.io/v1alpha1
kind: Resource
metadata:
  name: riskoracle-postgres
  title: RiskOracle PostgreSQL
  description: "RDS PostgreSQL 15 for risk calculation results storage"
  annotations:
    finops.io/monthly-cost: "84"
    finops.io/reserved-instance-expiry: "2025-06-15"
spec:
  type: database
  lifecycle: production
  owner: group:team-riskoracle
  system: financial-intelligence
EOF]

436
01:21:40,000 --> 01:21:50,000
[Types: cat > riskoracle-redis.yaml << 'EOF'
apiVersion: backstage.io/v1alpha1
kind: Resource
metadata:
  name: riskoracle-redis
  title: RiskOracle Redis
  description: "ElastiCache Redis for caching risk calculation results"
  annotations:
    finops.io/monthly-cost: "52"
spec:
  type: cache
  lifecycle: production
  owner: group:team-riskoracle
  system: financial-intelligence
EOF]

437
01:21:50,000 --> 01:22:00,000
[Types: cat > riskoracle-gpu-nodegroup.yaml << 'EOF'
apiVersion: backstage.io/v1alpha1
kind: Resource
metadata:
  name: riskoracle-gpu-nodegroup
  title: RiskOracle GPU Node Group
  description: "Karpenter-managed GPU node group for training workloads"
  annotations:
    finops.io/monthly-cost: "288"
    finops.io/spot-enabled: "true"
spec:
  type: compute
  lifecycle: production
  owner: group:team-riskoracle
  system: financial-intelligence
EOF]

438
01:22:00,000 --> 01:22:10,000
Now commit all these files to their respective repositories.

439
01:22:10,000 --> 01:22:20,000
[Types: git add catalog-info.yaml riskoracle-postgres.yaml riskoracle-redis.yaml riskoracle-gpu-nodegroup.yaml]
[Types: git commit -m "Add Backstage catalog definitions for riskoracle and dependencies"]
[Types: git push]

440
01:22:20,000 --> 01:22:30,000
After the GitHub catalog discovery runs, the riskoracle appears in the Backstage catalog along with its dependencies.

441
01:22:30,000 --> 01:22:40,000
The catalog now shows the complete picture. The financial-rag-agent and riskoracle. Their dependencies. Their ownership. Their cost budgets.

442
01:22:40,000 --> 01:22:50,000
This is the foundation for the developer portal. Every service in your organization should have a catalog definition.

443
01:22:50,000 --> 01:23:00,000
In the next segment, we look at GitHub catalog discovery configuration.

444
01:23:00,000 --> 01:23:10,000
See you in Segment 18.
```

---

### SEGMENT 18: GitHub Catalog Discovery Configuration
**Timestamp:** 85:00 – 90:00

```
445
01:25:00,000 --> 01:25:10,000
Let's look at GitHub catalog discovery configuration.

446
01:25:10,000 --> 01:25:20,000
GitHub catalog discovery automatically finds catalog-info.yaml files across your GitHub organisation. This is how services appear in Backstage without manual registration.

447
01:25:20,000 --> 01:25:30,000
The configuration is in app-config.yaml. Let's look at it in detail.

448
01:25:30,000 --> 01:25:40,000
[Types: cat >> app-config.yaml << 'EOF'
catalog:
  providers:
    github:
      your-org:
        organization: your-github-org
        catalogPath: /catalog-info.yaml
        filters:
          branch: main
        schedule:
          frequency: {minutes: 30}
          timeout: {minutes: 3}
EOF]

449
01:25:40,000 --> 01:25:50,000
The organization is your GitHub organisation name. The catalogPath is the path to the catalog file. The default is /catalog-info.yaml.

450
01:25:50,000 --> 01:26:00,000
The filters section filters which repositories are scanned. The branch is the branch to scan. Only repositories with the main branch are scanned.

451
01:26:00,000 --> 01:26:10,000
The schedule section configures the scan frequency. The frequency is 30 minutes. The timeout is 3 minutes.

452
01:26:10,000 --> 01:26:20,000
You can also filter by repository. Add a repositories list to scan only specific repositories.

453
01:26:20,000 --> 01:26:30,000
[Types: cat >> app-config.yaml << 'EOF'
        repositories:
          - financial-rag-agent
          - riskoracle
          - infrastructure
EOF]

454
01:26:30,000 --> 01:26:40,000
This scans only the specified repositories. Useful for large organisations with many repositories.

455
01:26:40,000 --> 01:26:50,000
You can also scan all repositories in the organisation by omitting the repositories list.

456
01:26:50,000 --> 01:27:00,000
The GitHub token needs repo access. It is used to read the catalog files. It is also used to create repositories via the scaffolder.

457
01:27:00,000 --> 01:27:10,000
The token is configured in app-config.yaml in the integrations section.

458
01:27:10,000 --> 01:27:20,000
[Types: cat app-config.yaml | grep -A5 "integrations:"]

459
01:27:20,000 --> 01:27:30,000
The token is set as an environment variable. It is not hardcoded in the file.

460
01:27:30,000 --> 01:27:40,000
Now restart Backstage to pick up the new configuration:

461
01:27:40,000 --> 01:27:50,000
[Types: yarn dev]
▶ Pronounced as: "Yarn, dev"

462
01:27:50,000 --> 01:28:00,000
After the restart, the catalog discovery runs. It scans the repositories and registers any catalog entities it finds.

463
01:28:00,000 --> 01:28:10,000
You can check the logs to see the discovery process:

464
01:28:10,000 --> 01:28:20,000
[Types: cat ~/finops-idp/backstage.log | grep "catalog" | grep "github"]

465
01:28:20,000 --> 01:28:30,000
The logs show which repositories were scanned and which entities were registered.

466
01:28:30,000 --> 01:28:40,000
Now you have GitHub catalog discovery configured. Every repository with a catalog-info.yaml will automatically appear in Backstage.

467
01:28:40,000 --> 01:28:50,000
In the next segment, we look at Backstage authentication with GitHub OAuth.

468
01:28:50,000 --> 01:29:00,000
See you in Segment 19.
```

---

### SEGMENT 19: Backstage Authentication — GitHub OAuth Setup
**Timestamp:** 90:00 – 95:00

```
469
01:30:00,000 --> 01:30:10,000
Let's set up Backstage authentication with GitHub OAuth.

470
01:30:10,000 --> 01:30:20,000
Authentication is required for Backstage to identify users. It is also required for the scaffolder to create repositories.

471
01:30:20,000 --> 01:30:30,000
First, create a GitHub OAuth application. Go to GitHub Settings → Developer settings → OAuth Apps → New OAuth App.

472
01:30:30,000 --> 01:30:40,000
Set the Application name to Backstage. Set the Homepage URL to http://localhost:3000. Set the Authorization callback URL to http://localhost:7007/api/auth/github/handler/frame.

473
01:30:40,000 --> 01:30:50,000
The callback URL is important. It must match exactly. The Backstage backend handles the OAuth callback.

474
01:30:50,000 --> 01:31:00,000
After creating the OAuth app, note the Client ID and Client Secret. These are used in the Backstage configuration.

475
01:31:00,000 --> 01:31:10,000
Now configure Backstage to use GitHub OAuth:

476
01:31:10,000 --> 01:31:20,000
[Types: cat >> app-config.yaml << 'EOF'
auth:
  providers:
    github:
      development:
        clientId: ${GITHUB_CLIENT_ID}
        clientSecret: ${GITHUB_CLIENT_SECRET}
EOF]

477
01:31:20,000 --> 01:31:30,000
Set the environment variables:

478
01:31:30,000 --> 01:31:40,000
[Types: export GITHUB_CLIENT_ID=your-client-id]
[Types: export GITHUB_CLIENT_SECRET=your-client-secret]

479
01:31:40,000 --> 01:31:50,000
Now restart Backstage:

480
01:31:50,000 --> 01:32:00,000
[Types: yarn dev]
▶ Pronounced as: "Yarn, dev"

481
01:32:00,000 --> 01:32:10,000
Open localhost:3000. You should see a Sign In button. Click it. You will be redirected to GitHub.

482
01:32:10,000 --> 01:32:20,000
Authorize the application. You will be redirected back to Backstage. You should be signed in.

483
01:32:20,000 --> 01:32:30,000
The user information is stored in the Backstage database. The user's email and name are available to the backend.

484
01:32:30,000 --> 01:32:40,000
The scaffolder uses the user's GitHub token to create repositories. The user must have permission to create repositories in the organisation.

485
01:32:40,000 --> 01:32:50,000
The user's membership in groups is determined by the catalog. If a user is listed in a group's members list, they are a member of that group.

486
01:32:50,000 --> 01:33:00,000
Now you have GitHub OAuth authentication configured. Users can sign in with their GitHub accounts.

487
01:33:00,000 --> 01:33:10,000
In the next segment, we look at Backstage authorization and RBAC configuration.

488
01:33:10,000 --> 01:33:20,000
See you in Segment 20.
```

---

### SEGMENT 20: Backstage Authorization — RBAC Configuration
**Timestamp:** 95:00 – 100:00

```
489
01:35:00,000 --> 01:35:10,000
Let's look at Backstage authorization and RBAC configuration.

490
01:35:10,000 --> 01:35:20,000
RBAC controls who can do what in Backstage. Who can view the catalog. Who can create services. Who can modify entities.

491
01:35:20,000 --> 01:35:30,000
The default RBAC is permissive. Anyone can view anything. Anyone can create anything. This is suitable for small teams.

492
01:35:30,000 --> 01:35:40,000
For larger teams, you need more restrictive RBAC. You need to limit who can create services. You need to limit who can modify catalog entities.

493
01:35:40,000 --> 01:35:50,000
Backstage uses the permission framework for RBAC. The permission framework is extensible. You can define custom permissions.

494
01:35:50,000 --> 01:36:00,000
The basic permission policies are: catalog-read, catalog-write, scaffolder-create, scaffolder-update.

495
01:36:00,000 --> 01:36:10,000
The policies are defined in the backend. They are evaluated when a user makes a request.

496
01:36:10,000 --> 01:36:20,000
[Types: cat > permissions.yaml << 'EOF'
apiVersion: backstage.io/v1beta1
kind: PermissionPolicy
metadata:
  name: default-policy
spec:
  policies:
    - name: catalog-read
      actions: [read]
      resources: [catalog-entity]
      effect: ALLOW
      conditions:
        - allOf:
          - subject.group: engineering
    - name: catalog-write
      actions: [create, update, delete]
      resources: [catalog-entity]
      effect: ALLOW
      conditions:
        - allOf:
          - subject.group: platform-engineers
          - subject.group: team-leads
    - name: scaffolder-create
      actions: [create]
      resources: [scaffolder-template]
      effect: ALLOW
      conditions:
        - allOf:
          - subject.group: engineering
EOF]

497
01:36:20,000 --> 01:36:30,000
This policy allows all engineers to read the catalog. It allows platform engineers and team leads to write the catalog. It allows all engineers to create services with the scaffolder.

498
01:36:30,000 --> 01:36:40,000
Apply the policy:

499
01:36:40,000 --> 01:36:50,000
[Types: kubectl apply -f permissions.yaml -n backstage]

500
01:36:50,000 --> 01:37:00,000
Now only authorized users can perform actions. Unauthorized users are denied.

501
01:37:00,000 --> 01:37:10,000
The permission framework also supports conditions. Conditions can be based on the user's group, the entity type, or the action.

502
01:37:10,000 --> 01:37:20,000
For example, you can allow only the owner of a service to update it. You can allow only platform engineers to create new catalog entities.

503
01:37:20,000 --> 01:37:30,000
The permission framework is powerful. It allows fine-grained access control. It is essential for larger organisations.

504
01:37:30,000 --> 01:37:40,000
Now you have RBAC configured. Users have appropriate permissions. The platform is secure.

505
01:37:40,000 --> 01:37:50,000
In the next segment, we do a workshop on registering your existing services.

506
01:37:50,000 --> 01:38:00,000
See you in Segment 21.
```

---

### SEGMENT 21: Workshop — Registering Your Existing Services
**Timestamp:** 100:00 – 105:00

```
507
01:40:00,000 --> 01:40:10,000
Let's do a workshop on registering your existing services.

508
01:40:10,000 --> 01:40:20,000
You have registered the financial-rag-agent and riskoracle. Now you need to register all your other services.

509
01:40:20,000 --> 01:40:30,000
The process is the same for every service. Create a catalog-info.yaml file. Add it to the root of the repository.

510
01:40:30,000 --> 01:40:40,000
Step 1: Identify the service. What is the name? What does it do? Who owns it? What are its dependencies?

511
01:40:40,000 --> 01:40:50,000
Step 2: Create the catalog-info.yaml file. Use the financial-rag-agent file as a template.

512
01:40:50,000 --> 01:41:00,000
[Types: cp financial-rag-agent/catalog-info.yaml your-service/catalog-info.yaml]

513
01:41:00,000 --> 01:41:10,000
Step 3: Update the file. Change the name, title, description, and annotations.

514
01:41:10,000 --> 01:41:20,000
Step 4: Add the file to the repository. Commit and push.

515
01:41:20,000 --> 01:41:30,000
[Types: git add catalog-info.yaml]
[Types: git commit -m "Add Backstage catalog definition for your-service"]
[Types: git push]

516
01:41:30,000 --> 01:41:40,000
Step 5: Wait for the catalog discovery. It runs every 30 minutes. Or trigger it manually.

517
01:41:40,000 --> 01:41:50,000
[Types: curl -X POST http://localhost:7007/api/catalog/locations -H "Content-Type: application/json" -d '{"type":"url","target":"https://github.com/your-org/your-service/blob/main/catalog-info.yaml"}']

518
01:41:50,000 --> 01:42:00,000
This manually registers the location. The catalog discovery will then pick up the entity.

519
01:42:00,000 --> 01:42:10,000
Step 6: Verify the entity appears in the catalog. Open localhost:3000 and search for your service.

520
01:42:10,000 --> 01:42:20,000
If the entity does not appear, check the logs. The logs show any errors in parsing the catalog file.

521
01:42:20,000 --> 01:42:30,000
[Types: cat ~/finops-idp/backstage.log | grep "catalog" | grep "error"]

522
01:42:30,000 --> 01:42:40,000
Common errors: invalid YAML, missing required fields, invalid annotation values.

523
01:42:40,000 --> 01:42:50,000
Step 7: Repeat for all your services. Every service should have a catalog definition.

524
01:42:50,000 --> 01:43:00,000
The catalog is the source of truth. It should include all production services. It should include all staging services. It should include all development services.

525
01:43:00,000 --> 01:43:10,000
Now let's practice. Register the llm-ingest service. This is the ingestion pipeline for the financial-rag-agent.

526
01:43:10,000 --> 01:43:20,000
[Types: cat > llm-ingest-catalog-info.yaml << 'EOF'
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: llm-ingest
  title: LLM Ingest
  description: "Ingestion pipeline for SEC EDGAR filings and financial documents"
  annotations:
    github.com/project-slug: your-org/llm-ingest
    backstage.io/kubernetes-namespace: llm-ingest
    finops.io/team: team-financial-rag
    finops.io/monthly-budget: "2000"
  tags:
    - python
    - ingestion
    - rag
    - production
spec:
  type: service
  lifecycle: production
  owner: group:team-financial-rag
  system: financial-intelligence
  dependsOn:
    - resource:financial-rag-postgres
    - resource:financial-rag-s3
EOF]

527
01:43:20,000 --> 01:43:30,000
Now commit this file to the llm-ingest repository. The catalog will pick it up.

528
01:43:30,000 --> 01:43:40,000
Now you have registered all your services. The catalog is complete. It is the source of truth for everything.

529
01:43:40,000 --> 01:43:50,000
In the next segment, we do the platform maturity assessment.

530
01:43:50,000 --> 01:44:00,000
See you in Segment 22.
```

---

### SEGMENT 22: Platform Maturity Assessment — Score Your Organization
**Timestamp:** 105:00 – 110:00

```
531
01:45:00,000 --> 01:45:10,000
Let's do the platform maturity assessment. This is a self-assessment for your organisation.

532
01:45:10,000 --> 01:45:20,000
Answer each question honestly. Score 0 for not started. Score 1 for partial. Score 2 for complete.

533
01:45:20,000 --> 01:45:30,000
Developer Self-Service:
- Developers can deploy a new service without filing a ticket. Score: ___
- Developers can provision a database without waiting for ops. Score: ___
- Developers can create a new S3 bucket with correct config automatically. Score: ___

534
01:45:30,000 --> 01:45:40,000
Golden Paths:
- We have documented the right way to deploy a service. Score: ___
- Our golden path includes resource requests, Spot tolerations, lifecycle policies. Score: ___
- Developers use the golden path for over 80% of new services. Score: ___

535
01:45:40,000 --> 01:45:50,000
Cost Visibility:
- Every team can see their monthly AWS cost without asking someone. Score: ___
- Budget alerts are configured and tested. Score: ___
- Cost per service is visible in the developer portal. Score: ___

536
01:45:50,000 --> 01:46:00,000
Catalog:
- All production services are registered in a catalog. Score: ___
- Every service has a documented owner. Score: ___
- Dependencies between services are tracked. Score: ___

537
01:46:00,000 --> 01:46:10,000
Enforcement:
- New resources without required tags are blocked at CI. Score: ___
- New S3 buckets without lifecycle policies fail to deploy. Score: ___
- New ECR repos without lifecycle policies fail to deploy. Score: ___

538
01:46:10,000 --> 01:46:20,000
Now add up your scores. Total possible is 20. Most teams starting this course score 2 to 6. The goal is 18 or higher.

539
01:46:20,000 --> 01:46:30,000
Record your score. This is your baseline. Reassess after completing Series 7 through 10.

540
01:46:30,000 --> 01:46:40,000
[Types: echo "=== PLATFORM MATURITY ASSESSMENT ===" >> ~/finops-baseline.txt]
[Types: echo "Date: $(date)" >> ~/finops-baseline.txt]
[Types: echo "Score: [your score] / 20" >> ~/finops-baseline.txt]
[Types: echo "Target: 18+ after Series 10" >> ~/finops-baseline.txt]

541
01:46:40,000 --> 01:46:50,000
Now let's interpret the scores. Score 0 to 6: Reactive. You are at Stage 1. You respond to tickets and firefight costs.

542
01:46:50,000 --> 01:47:00,000
Score 7 to 12: Automated. You are at Stage 2. You have some automation but it is inconsistent. Costs are lower but still unpredictable.

543
01:47:00,000 --> 01:47:10,000
Score 13 to 18: Product-Driven. You are at Stage 3. You have a golden path. You have a developer portal. Costs are stable.

544
01:47:10,000 --> 01:47:20,000
Score 19 to 20: Engineering Economics. You are at Stage 4. You produce unit economics data. You drive product decisions with cost data.

545
01:47:20,000 --> 01:47:30,000
The goal of this course is to take you from Stage 1 or 2 to Stage 3. Stage 4 is a natural evolution once Stage 3 is stable.

546
01:47:30,000 --> 01:47:40,000
Now you know your maturity score. This is your baseline. Reassess after completing the course. You should see significant improvement.

547
01:47:40,000 --> 01:47:50,000
In the next segment, we do the Q&A for Series 7.

548
01:47:50,000 --> 01:48:00,000
See you in Segment 23.
```

---

### SEGMENT 23: Series 7 Q&A — Common Questions Answered
**Timestamp:** 110:00 – 115:00

```
549
01:50:00,000 --> 01:50:10,000
Welcome to the Series 7 Q&A. Common questions answered.

550
01:50:10,000 --> 01:50:20,000
Question 1: "Do I need to deploy Backstage to production immediately?"

551
01:50:20,000 --> 01:50:30,000
No. Start with a development instance. Get comfortable with the interface. Understand the architecture. Then deploy to production.

552
01:50:30,000 --> 01:50:40,000
The development instance is fine for learning. The production instance needs high availability, backups, and monitoring.

553
01:50:40,000 --> 01:50:50,000
Question 2: "What if I don't have a GitHub organisation? Can I still use Backstage?"

554
01:50:50,000 --> 01:51:00,000
Yes. Backstage supports GitLab, Bitbucket, and other SCM providers. The configuration is similar.

555
01:51:00,000 --> 01:51:10,000
You can also use local file discovery. Place catalog-info.yaml files in a local directory. The catalog discovery will pick them up.

556
01:51:10,000 --> 01:51:20,000
Question 3: "How many services can the catalog handle?"

557
01:51:20,000 --> 01:51:30,000
The catalog can handle thousands of services. It is used by Spotify with thousands of services. Performance is good.

558
01:51:30,000 --> 01:51:40,000
The database is the bottleneck. Use a managed PostgreSQL service with sufficient resources. RDS with 8 GB of RAM is sufficient for most organisations.

559
01:51:40,000 --> 01:51:50,000
Question 4: "What if I already have a service registry? Do I need to migrate?"

560
01:51:50,000 --> 01:52:00,000
You can integrate your existing registry with Backstage. Use the catalog provider API. Write a plugin that reads from your existing registry.

561
01:52:00,000 --> 01:52:10,000
This is a common pattern. Many organisations have existing service registries. They integrate them with Backstage.

562
01:52:10,000 --> 01:52:20,000
Question 5: "Is Backstage free?"

563
01:52:20,000 --> 01:52:30,000
Backstage is open source and free. There is no licensing cost. You pay for the infrastructure. EKS, RDS, and ALB.

564
01:52:30,000 --> 01:52:40,000
The infrastructure cost is moderate. A production Backstage instance costs approximately $100 to $300 a month.

565
01:52:40,000 --> 01:52:50,000
Question 6: "What is the learning curve for Backstage?"

566
01:52:50,000 --> 01:53:00,000
The learning curve is moderate. React and TypeScript are the main languages. The documentation is good. The community is active.

567
01:53:00,000 --> 01:53:10,000
The platform team needs to understand the architecture. The stream-aligned teams need to understand the catalog and scaffolder.

568
01:53:10,000 --> 01:53:20,000
Question 7: "Can I use Backstage with EKS?"

569
01:53:20,000 --> 01:53:30,000
Yes. Backstage runs well on EKS. Use the Helm chart. The chart includes the frontend, backend, and database.

570
01:53:30,000 --> 01:53:40,000
The Helm chart is maintained by the Backstage community. It is well-tested and production-ready.

571
01:53:40,000 --> 01:53:50,000
Question 8: "What if my team is small — one or two platform engineers?"

572
01:53:50,000 --> 01:54:00,000
Small teams can still benefit from Backstage. The investment is moderate. The benefits are significant.

573
01:54:00,000 --> 01:54:10,000
Consider using Port as an alternative. Port is a managed IDP. It requires less setup time. It is suitable for small teams.

574
01:54:10,000 --> 01:54:20,000
Question 9: "How long does it take to implement the golden path?"

575
01:54:20,000 --> 01:54:30,000
The golden path template takes approximately one week to build. The scaffold is the hardest part. The operations templates are simpler.

576
01:54:30,000 --> 01:54:40,000
Testing and refinement add another week. The full implementation takes two to four weeks for a typical organisation.

577
01:54:40,000 --> 01:54:50,000
Question 10: "What if I have security concerns about Backstage?"

578
01:54:50,000 --> 01:55:00,000
Backstage is used by many large organisations. It has a strong security model. Authentication, authorization, and encryption are built in.

579
01:55:00,000 --> 01:55:10,000
Follow the security best practices. Use HTTPS. Use strong authentication. Limit permissions.

580
01:55:10,000 --> 01:55:20,000
Now you have the answers to the most common questions about Backstage and IDPs.

581
01:55:20,000 --> 01:55:30,000
In the next segment, we do the knowledge check and look ahead to Series 8.

582
01:55:30,000 --> 01:55:40,000
See you in Segment 24.
```

---

### SEGMENT 24: Series 7 Knowledge Check & Next Steps
**Timestamp:** 115:00 – 120:00

```
583
01:55:00,000 --> 01:55:10,000
Welcome to the Series 7 knowledge check.

584
01:55:10,000 --> 01:55:20,000
Let's test your understanding of Series 7. Answer these questions in your own words.

585
01:55:20,000 --> 01:55:30,000
Question 1: Why do FinOps wins reverse without a platform?

586
01:55:30,000 --> 01:55:40,000
Question 2: What are the three failure modes of platform teams?

587
01:55:40,000 --> 01:55:50,000
Question 3: What are the four team types in Team Topologies?

588
01:55:50,000 --> 01:56:00,000
Question 4: What is a golden path?

589
01:56:00,000 --> 01:56:10,000
Question 5: What are the five fields in the golden path template?

590
01:56:10,000 --> 01:56:20,000
Question 6: What is the purpose of the Backstage catalog?

591
01:56:20,000 --> 01:56:30,000
Question 7: What are the annotations used for FinOps integration?

592
01:56:30,000 --> 01:56:40,000
Question 8: What is the purpose of GitHub catalog discovery?

593
01:56:40,000 --> 01:56:50,000
Pause the video. Write down your answers. Then compare them to what you learned.

594
01:56:50,000 --> 01:57:00,000
If you got all eight correct, you understand Series 7. If you missed any, review the relevant segment.

595
01:57:00,000 --> 01:57:10,000
Now let's look ahead to Series 8.

596
01:57:10,000 --> 01:57:20,000
Series 8 is the scaffolder. The golden path template. You will build a template that creates a new service in 90 seconds.

597
01:57:20,000 --> 01:57:30,000
The template will include: GitHub repository creation, multi-arch Dockerfile, Helm chart with Spot tolerations, S3 bucket with lifecycle policy, ArgoCD deployment, and catalog registration.

598
01:57:30,000 --> 01:57:40,000
The template will also include a cost estimate. The developer will see the estimated monthly cost before they click confirm.

599
01:57:40,000 --> 01:57:50,000
This is the shift from manual to automatic. From hoping engineers do the right thing to making the right thing the default.

600
01:57:50,000 --> 01:58:00,000
Before starting Series 8, verify these things.

601
01:58:00,000 --> 01:58:10,000
First: Backstage is running. Run yarn dev in the finops-idp directory.

602
01:58:10,000 --> 01:58:20,000
Second: The catalog has your registered services. Open localhost:3000 and check.

603
01:58:20,000 --> 01:58:30,000
Third: GitHub OAuth is configured. Sign in with GitHub and confirm it works.

604
01:58:30,000 --> 01:58:40,000
Fourth: GitHub catalog discovery is configured. The catalog should discover new services automatically.

605
01:58:40,000 --> 01:58:50,000
If all four are verified, you are ready for Series 8.

606
01:58:50,000 --> 01:59:00,000
Series 7 is complete. The platform foundation is built.

607
01:59:00,000 --> 01:59:10,000
You have understood why FinOps wins reverse. You have learned the failure modes. You have installed Backstage. You have registered services in the catalog.

608
01:59:10,000 --> 01:59:20,000
You have configured GitHub catalog discovery. You have set up GitHub OAuth. You have performed the platform maturity assessment.

609
01:59:20,000 --> 01:59:30,000
The foundation is laid. In Series 8, we build the golden path. The scaffolder. The machine that creates cost-optimized services automatically.

610
01:59:30,000 --> 01:59:40,000
The commands work. The savings are real. You just have to do the work.

611
01:59:40,000 --> 01:59:50,000
See you in Series 8.
```