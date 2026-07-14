Here is your complete Series 10 SRT with all Type: lines and their corresponding Pronounced at: lines edited to type-along, precedential style. All headers, timestamps, numbering, narrative, and command blocks remain exactly as you provided.

---

Series 10: FinOps Integration into the IDP
Complete 24-Segment SRT — 2 Hours

---

SEGMENT 1: Closing the Loop
Timestamp: 00:00 – 05:00

```
1
00:00:00,000 --> 00:00:10,000
Welcome to Series 10. This is where we close the loop.

2
00:00:10,000 --> 00:00:20,000
You have spent nine series building two things in parallel.

3
00:00:20,000 --> 00:00:30,000
The first track: Series 2 through 6 found, eliminated, and automated cost controls at the infrastructure level. You cut the bill from $47,000 to $19,404.

4
00:00:30,000 --> 00:00:40,000
The second track: Series 7 through 9 built a platform that encodes those controls into every new service automatically. New services are cost-optimised by default.

5
00:00:40,000 --> 00:00:50,000
But there is still a gap. The controls are applied. The costs are tracked in Kubecost. But none of this is visible to the people who create the spend.

6
00:00:50,000 --> 00:01:00,000
The developers using the platform every day. They open the catalog and see deployment status, logs, CI/CD history. They do not see cost.

7
00:01:00,000 --> 00:01:10,000
They do not see budget usage. They do not see that their service is running at 48% efficiency. They only find out when the bill arrives.

8
00:01:10,000 --> 00:01:20,000
Series 10 changes that. By the end, every developer who opens the catalog sees their service's current monthly cost and trend.

9
00:01:20,000 --> 00:01:30,000
Their team's budget progress with a red bar when approaching the limit. Efficiency score and rightsizing recommendations.

10
00:01:30,000 --> 00:01:40,000
Live cost anomaly alerts routed to service owners. A FinOps homepage dashboard with the full picture.

11
00:01:40,000 --> 00:01:50,000
FinOps stops being something the platform team thinks about. It becomes something every developer sees, every day, as a natural part of their workflow.

12
00:01:50,000 --> 00:02:00,000
This is the final piece of the puzzle. Cost visibility inside the developer portal.

13
00:02:00,000 --> 00:02:10,000
Let me show you the architecture we are building. Kubecost provides the cost data. The FinOps backend plugin queries Kubecost and serves it through a REST API.

14
00:02:10,000 --> 00:02:20,000
The frontend components display the data in the catalog. A budget scheduler checks daily for overspend. A chargeback report runs monthly for finance.

15
00:02:20,000 --> 00:02:30,000
And an anomaly webhook receives alerts from Kubecost and routes them to service owners.

16
00:02:30,000 --> 00:02:40,000
Everything is visible in the developer portal. No separate dashboards. No separate tools. Everything in one place.

17
00:02:40,000 --> 00:02:50,000
Create the FinOps backend plugin:

18
00:02:50,000 --> 00:03:00,000
[Types: cd finops-idp]
[Types: npx @backstage/cli new --select backend-plugin --option id=finops]
▶ Pronounced as: "Now creating the FinOps backend plugin with the Backstage CLI."

19
00:03:00,000 --> 00:03:10,000
[Types: yarn --cwd plugins/finops-backend add node-fetch @backstage/catalog-client @slack/web-api aws-sdk]
▶ Pronounced as: "Now installing dependencies for the FinOps backend plugin."

20
00:03:10,000 --> 00:03:20,000
Now let me explain what each of these dependencies does.

21
00:03:20,000 --> 00:03:30,000
node-fetch is for making HTTP requests to Kubecost. The catalog client is for querying the Backstage catalog to find services and their metadata.

22
00:03:30,000 --> 00:03:40,000
The Slack web API is for sending budget alerts to team channels. AWS SDK is for accessing Cost Explorer and other AWS services if needed.

23
00:03:40,000 --> 00:03:50,000
Now let's look at the plugin structure. The backend plugin has three main files.

24
00:03:50,000 --> 00:04:00,000
router.ts contains the REST API endpoints. scheduler.ts contains the budget check that runs daily. chargeback.ts contains the monthly report generator.

25
00:04:00,000 --> 00:04:10,000
We will build each of these in the next segments.

26
00:04:10,000 --> 00:04:20,000
Before we write any code, verify that Kubecost is running and accessible:

27
00:04:20,000 --> 00:04:30,000
[Types: kubectl get pods -n kubecost]
[Types: kubectl port-forward -n kubecost svc/kubecost-cost-analyzer 9090:9090 &]
▶ Pronounced as: "Now verifying Kubecost is running and port-forwarding for access."

28
00:04:30,000 --> 00:04:40,000
[Types: curl -s http://localhost:9090/health | jq .]
▶ Pronounced as: "Now checking Kubecost health endpoint."

29
00:04:40,000 --> 00:04:50,000
Now, look at that output. If you see a health check response, Kubecost is running and the API is accessible.

30
00:04:50,000 --> 00:05:00,000
Now let's build the router that serves cost data to the frontend.

31
00:05:00,000 --> 00:05:10,000
See you in Segment 2.
```

---

SEGMENT 2: FinOps Backend Plugin — Cost API & Budget Scheduler
Timestamp: 05:00 – 10:00

```
32
00:05:00,000 --> 00:05:10,000
The backend plugin serves two functions. A REST API that the frontend queries for cost data per namespace.

33
00:05:10,000 --> 00:05:20,000
And a daily scheduler that checks budget usage and sends Slack alerts when teams approach their limits.

34
00:05:20,000 --> 00:05:30,000
Let's build the cost API router first.

35
00:05:30,000 --> 00:05:40,000
[Types: cat > plugins/finops-backend/src/router.ts << 'EOF'
import { Router } from 'express';
import fetch from 'node-fetch';
import { Config } from '@backstage/config';
import { Logger } from 'winston';

export async function createRouter({
  config,
  logger,
}: {
  config: Config;
  logger: Logger;
}): Promise<Router> {
  const router = Router();
  const kubecostUrl = config.getString('kubecost.baseUrl');

  router.get('/cost', async (req, res) => {
    const namespace = req.query.namespace as string;
    if (!namespace) {
      return res.status(400).json({ error: 'namespace required' });
    }

    try {
      const [currentRes, prevRes, rightsizeRes] = await Promise.all([
        fetch(`${kubecostUrl}/allocation?window=30d&aggregate=namespace&filter=namespace:"${namespace}"`),
        fetch(`${kubecostUrl}/allocation?window=month&aggregate=namespace&filter=namespace:"${namespace}"`),
        fetch(`${kubecostUrl}/savings/requestSizing?window=7d&filter=namespace:"${namespace}"`),
      ]);

      const [current, previous, rightsize] = await Promise.all([
        currentRes.json() as any,
        prevRes.json() as any,
        rightsizeRes.json() as any,
      ]);

      const curr = current?.data?.[0]?.[namespace] ?? {};
      const prev = previous?.data?.[0]?.[namespace] ?? {};

      const currentMonth = curr.totalCost ?? 0;
      const previousMonth = prev.totalCost ?? 0;
      const trend = previousMonth > 0
        ? ((currentMonth - previousMonth) / previousMonth) * 100
        : 0;

      // EOM forecast via linear extrapolation
      const now = new Date();
      const daysInMonth = new Date(now.getFullYear(), now.getMonth() + 1, 0).getDate();
      const forecast = (currentMonth / now.getDate()) * daysInMonth;

      const rightsizingSavings = (rightsize?.recommendations ?? [])
        .reduce((sum: number, r: any) => sum + (r.monthlySavings ?? 0), 0);

      res.json({
        namespace,
        currentMonth: Math.round(currentMonth * 100) / 100,
        previousMonth: Math.round(previousMonth * 100) / 100,
        trend: Math.round(trend * 10) / 10,
        forecast: Math.round(forecast * 100) / 100,
        efficiency: curr.efficiency ?? 0,
        cpuCost: curr.cpuCost ?? 0,
        ramCost: curr.ramCost ?? 0,
        storageCost: curr.storageCost ?? 0,
        networkCost: curr.networkCost ?? 0,
        idleCost: curr.idleCost ?? 0,
        rightsizingSavings: Math.round(rightsizingSavings * 100) / 100,
      });
    } catch (error: any) {
      logger.error(`Cost fetch failed for ${namespace}: ${error.message}`);
      res.status(500).json({ error: 'Failed to fetch cost data' });
    }
  });

  return router;
}
EOF]
▶ Pronounced as: "Now creating the router.ts file with the cost API endpoint."

36
00:05:40,000 --> 00:05:50,000
Let me walk you through this router. The /cost endpoint takes a namespace parameter and returns cost data for that namespace.

37
00:05:50,000 --> 00:06:00,000
It makes three parallel requests to Kubecost. The first gets the last 30 days of cost data. The second gets the previous month for trend comparison.

38
00:06:00,000 --> 00:06:10,000
The third gets rightsizing recommendations for the namespace. This is how we calculate potential savings.

39
00:06:10,000 --> 00:06:20,000
The response includes current month cost, previous month cost, trend percentage, end-of-month forecast, efficiency, and rightsizing savings.

40
00:06:20,000 --> 00:06:30,000
Now let's build the budget scheduler. This runs daily at 9 AM and alerts teams approaching their monthly budget.

41
00:06:30,000 --> 00:06:40,000
[Types: cat > plugins/finops-backend/src/scheduler.ts << 'EOF'
import { Config } from '@backstage/config';
import { Logger } from 'winston';
import { CatalogClient } from '@backstage/catalog-client';
import fetch from 'node-fetch';
import { WebClient } from '@slack/web-api';

export async function runBudgetCheck({
  config,
  logger,
  catalog,
}: {
  config: Config;
  logger: Logger;
  catalog: CatalogClient;
}): Promise<void> {
  logger.info('Running budget check');

  const kubecostUrl = config.getString('kubecost.baseUrl');
  const slackToken = config.getString('slack.token');
  const slack = new WebClient(slackToken);

  const { items: components } = await catalog.getEntities({
    filter: { kind: 'Component' },
  });

  let alertCount = 0;

  for (const component of components) {
    const namespace = component.metadata.annotations?.['kubecost.com/namespace']
      ?? component.metadata.annotations?.['backstage.io/kubernetes-namespace'];
    const budgetStr = component.metadata.annotations?.['finops/monthly-budget'];
    const team = component.metadata.annotations?.['finops/team'];
    const name = component.metadata.name;

    if (!namespace || !budgetStr || !team) continue;

    const budget = parseFloat(budgetStr);
    if (budget <= 0) continue;

    try {
      const resp = await fetch(
        `${kubecostUrl}/allocation?window=month&aggregate=namespace&filter=namespace:"${namespace}"`
      );
      const data = await resp.json() as any;
      const currentSpend = data?.data?.[0]?.[namespace]?.totalCost ?? 0;

      const usagePct = (currentSpend / budget) * 100;

      if (usagePct >= 90) {
        alertCount++;
        const daysLeft = new Date(
          new Date().getFullYear(),
          new Date().getMonth() + 1, 0
        ).getDate() - new Date().getDate();

        const message = {
          blocks: [
            {
              type: 'header',
              text: {
                type: 'plain_text',
                text: `💰 Budget Alert — ${name}`,
              },
            },
            {
              type: 'section',
              text: {
                type: 'mrkdwn',
                text: `*${usagePct.toFixed(0)}%* of monthly budget used\n` +
                      `Current: $${currentSpend.toFixed(0)} / $${budget}\n` +
                      `Days left: ${daysLeft} days`,
              },
            },
            {
              type: 'actions',
              elements: [
                {
                  type: 'button',
                  text: { type: 'plain_text', text: 'View in Portal' },
                  url: `https://backstage.internal/catalog/default/component/${name}/finops`,
                  style: 'primary',
                },
              ],
            },
          ],
        };

        await slack.chat.postMessage({
          channel: `#${team}-alerts`,
          text: `Budget alert for ${name}`,
          blocks: message.blocks,
        });

        logger.info(`Budget alert sent for ${name}: ${usagePct.toFixed(0)}%`);
      }
    } catch (err: any) {
      logger.warn(`Budget check failed for ${name}: ${err.message}`);
    }
  }

  logger.info(`Budget check complete. ${alertCount} alerts sent.`);
}
EOF]
▶ Pronounced as: "Now creating the scheduler.ts file with the budget check logic."

42
00:06:40,000 --> 00:06:50,000
The scheduler queries the catalog for all components. For each component, it checks if it has the required annotations.

43
00:06:50,000 --> 00:07:00,000
If the component has a namespace, a budget, and a team, it queries Kubecost for the current month's spend.

44
00:07:00,000 --> 00:07:10,000
If the usage percentage is 90% or higher, it sends a Slack alert to the team's channel.

45
00:07:10,000 --> 00:07:20,000
Now register the scheduler in the plugin:

46
00:07:20,000 --> 00:07:30,000
[Types: cat > plugins/finops-backend/src/plugin.ts << 'EOF'
import { createBackendPlugin } from '@backstage/backend-plugin-api';
import { createRouter } from './router';
import { runBudgetCheck } from './scheduler';

export const finopsPlugin = createBackendPlugin({
  pluginId: 'finops',
  register(env) {
    env.registerInit({
      deps: {
        logger: env.logger,
        config: env.config,
        catalog: env.catalog,
        scheduler: env.scheduler,
        http: env.http,
      },
      async init({ logger, config, catalog, scheduler, http }) {
        const router = await createRouter({ config, logger });
        http.use(router);

        await scheduler.scheduleTask({
          id: 'finops-budget-check',
          frequency: { cron: '0 9 * * *' },
          timeout: { minutes: 5 },
          fn: async () => {
            await runBudgetCheck({ config, logger, catalog });
          },
        });

        logger.info('FinOps plugin initialized');
      },
    });
  },
});
EOF]
▶ Pronounced as: "Now creating the plugin.ts file to register the FinOps plugin."

47
00:07:30,000 --> 00:07:40,000
Now register the plugin in the backend:

48
00:07:40,000 --> 00:07:50,000
[Types: cat >> packages/backend/src/index.ts << 'EOF'
backend.add(import('@internal/plugin-finops-backend'));
EOF]
▶ Pronounced as: "Now registering the FinOps backend plugin in the backend index."

49
00:07:50,000 --> 00:08:00,000
Now add the kubecost configuration to app-config.yaml:

50
00:08:00,000 --> 00:08:10,000
[Types: cat >> app-config.yaml << 'EOF'
kubecost:
  baseUrl: http://kubecost-cost-analyzer.kubecost:9090

slack:
  token: ${SLACK_TOKEN}
EOF]
▶ Pronounced as: "Now adding Kubecost and Slack configuration to app-config.yaml."

51
00:08:10,000 --> 00:08:20,000
Test the cost API endpoint:

52
00:08:20,000 --> 00:08:30,000
[Types: curl -s "http://localhost:7007/api/finops/cost?namespace=financial-rag" | jq .]
▶ Pronounced as: "Now testing the cost API endpoint."

53
00:08:30,000 --> 00:08:40,000
Now, look at that output. You should see a JSON response with current month cost, trend, forecast, efficiency, and rightsizing savings.

54
00:08:40,000 --> 00:08:50,000
If you see an error, check that Kubecost is running and the baseUrl is correct. Also verify the namespace exists.

55
00:08:50,000 --> 00:09:00,000
Now let's test the budget scheduler manually:

56
00:09:00,000 --> 00:09:10,000
[Types: curl -X POST "http://localhost:7007/api/finops/run-budget-check"]
▶ Pronounced as: "Now manually triggering the budget scheduler."

57
00:09:10,000 --> 00:09:20,000
Now, look at the logs. You should see budget check messages for each component with budget annotations.

58
00:09:20,000 --> 00:09:30,000
The backend is now serving cost data and running budget checks. In the next segment, we build the frontend component that displays this data in the catalog.

59
00:09:30,000 --> 00:09:40,000
See you in Segment 3.
```

---

SEGMENT 3: FinOps Frontend Component & Homepage Dashboard
Timestamp: 10:00 – 15:00

```
60
00:10:00,000 --> 00:10:10,000
Now we build the frontend component that displays cost data in the catalog.

61
00:10:10,000 --> 00:10:20,000
This is the card that appears in every service's catalog page. It shows current cost, trend, efficiency, and budget progress.

62
00:10:20,000 --> 00:10:30,000
Create the FinOps plugin frontend:

63
00:10:30,000 --> 00:10:40,000
[Types: cd finops-idp]
[Types: npx @backstage/cli new --select frontend-plugin --option id=finops]
▶ Pronounced as: "Now creating the FinOps frontend plugin with the Backstage CLI."

64
00:10:40,000 --> 00:10:50,000
[Types: yarn --cwd plugins/finops add @backstage/core-components @backstage/core-plugin-api @backstage/plugin-catalog-react]
▶ Pronounced as: "Now installing frontend dependencies."

65
00:10:50,000 --> 00:11:00,000
Now create the FinOpsCostCard component:

66
00:11:00,000 --> 00:11:10,000
[Types: cat > plugins/finops/src/components/FinOpsCostCard/FinOpsCostCard.tsx << 'EOF'
import React, { useEffect, useState } from 'react';
import { InfoCard, Progress, WarningPanel } from '@backstage/core-components';
import { useEntity } from '@backstage/plugin-catalog-react';
import { Box, Typography, LinearProgress, Chip } from '@material-ui/core';

interface CostData {
  namespace: string;
  currentMonth: number;
  previousMonth: number;
  trend: number;
  forecast: number;
  efficiency: number;
  cpuCost: number;
  ramCost: number;
  storageCost: number;
  networkCost: number;
  idleCost: number;
  rightsizingSavings: number;
}

export const FinOpsCostCard = () => {
  const { entity } = useEntity();
  const namespace = entity.metadata.annotations?.['kubecost.com/namespace']
    ?? entity.metadata.annotations?.['backstage.io/kubernetes-namespace'];
  const budgetStr = entity.metadata.annotations?.['finops/monthly-budget'];

  const [cost, setCost] = useState<CostData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    if (!namespace) {
      setLoading(false);
      return;
    }

    fetch(`/api/finops/cost?namespace=${namespace}`)
      .then(r => {
        if (!r.ok) throw new Error(`HTTP ${r.status}`);
        return r.json();
      })
      .then(data => {
        setCost(data);
        setLoading(false);
      })
      .catch(err => {
        setError(err.message);
        setLoading(false);
      });
  }, [namespace]);

  if (loading) return <Progress />;
  if (error) return <WarningPanel title="Cost data unavailable" message={error} />;
  if (!cost) return null;

  const budget = budgetStr ? parseFloat(budgetStr) : 0;
  const budgetPct = budget > 0 ? (cost.currentMonth / budget) * 100 : 0;
  const trendIcon = cost.trend > 5 ? '📈' : cost.trend < -5 ? '📉' : '➡️';
  const efficiencyColor = cost.efficiency >= 0.7 ? 'primary' : cost.efficiency >= 0.5 ? 'secondary' : 'error';

  return (
    <InfoCard title="💰 Cost Overview" subheader="Last 30 days via Kubecost">
      <Box p={2}>
        <Box display="flex" justifyContent="space-between" alignItems="center">
          <Box>
            <Typography variant="h3">${cost.currentMonth.toFixed(0)}</Typography>
            <Typography variant="caption" color="textSecondary">
              This month {trendIcon} {Math.abs(cost.trend).toFixed(1)}% vs last month
            </Typography>
          </Box>
          <Box textAlign="right">
            <Typography variant="h6">
              {(cost.efficiency * 100).toFixed(0)}%
            </Typography>
            <Typography variant="caption" color="textSecondary">
              Efficiency
            </Typography>
          </Box>
        </Box>

        {budget > 0 && (
          <Box mt={2}>
            <Box display="flex" justifyContent="space-between">
              <Typography variant="body2">
                Budget: ${cost.currentMonth.toFixed(0)} / ${budget}
              </Typography>
              <Typography variant="body2" color={budgetPct >= 90 ? 'error' : budgetPct >= 75 ? 'warning' : 'textSecondary'}>
                {budgetPct.toFixed(0)}%
              </Typography>
            </Box>
            <LinearProgress
              variant="determinate"
              value={Math.min(budgetPct, 100)}
              style={{
                height: 8,
                borderRadius: 4,
                backgroundColor: '#e0e0e0',
              }}
              color={budgetPct >= 90 ? 'secondary' : 'primary'}
            />
          </Box>
        )}

        {cost.rightsizingSavings > 0 && (
          <Box mt={2}>
            <Chip
              size="small"
              label={`💡 Rightsizing opportunity: $${cost.rightsizingSavings.toFixed(0)}/month`}
              style={{ backgroundColor: '#e8f5e9', color: '#2e7d32' }}
            />
          </Box>
        )}

        <Box mt={2} display="flex" flexWrap="wrap" gap={1}>
          <Typography variant="caption" color="textSecondary">
            Forecast: ${cost.forecast.toFixed(0)}
          </Typography>
          <Typography variant="caption" color="textSecondary">
            •
          </Typography>
          <Typography variant="caption" color="textSecondary">
            Idle: ${cost.idleCost.toFixed(0)}
          </Typography>
        </Box>
      </Box>
    </InfoCard>
  );
};
EOF]
▶ Pronounced as: "Now creating the FinOpsCostCard component."

67
00:11:10,000 --> 00:11:20,000
Now export the component from the plugin:

68
00:11:20,000 --> 00:11:30,000
[Types: cat > plugins/finops/src/index.ts << 'EOF'
export { finopsPlugin, FinopsPage } from './plugin';
export { FinOpsCostCard } from './components/FinOpsCostCard/FinOpsCostCard';
EOF]
▶ Pronounced as: "Now exporting the FinOpsCostCard component."

69
00:11:30,000 --> 00:11:40,000
Now add the card to the catalog entity page:

70
00:11:40,000 --> 00:11:50,000
[Types: cat >> packages/app/src/components/catalog/EntityPage.tsx << 'EOF'
import { FinOpsCostCard } from '@internal/plugin-finops';

// In the service entity page
const serviceEntityPage = (
  <EntityLayout>
    <EntityLayout.Route path="/" title="Overview">
      <Grid container spacing={3}>
        <Grid item md={6}>
          <EntityAboutCard variant="gridItem" />
        </Grid>
        <Grid item md={6}>
          <FinOpsCostCard />
        </Grid>
        <Grid item md={12}>
          <EntityLinksCard />
        </Grid>
      </Grid>
    </EntityLayout.Route>
    {/* Additional routes */}
  </EntityLayout>
);
EOF]
▶ Pronounced as: "Now adding the FinOpsCostCard to the catalog entity page."

71
00:11:50,000 --> 00:12:00,000
Now let's test the component. Start Backstage:

72
00:12:00,000 --> 00:12:10,000
[Types: yarn dev]
▶ Pronounced as: "Now starting Backstage with yarn dev."

73
00:12:10,000 --> 00:12:20,000
Open http://localhost:3000. Navigate to the financial-rag-agent service in the catalog. You should see the FinOps cost card on the overview page.

74
00:12:20,000 --> 00:12:30,000
Now, look at that output. The card shows current month cost, trend, efficiency, budget progress, and rightsizing opportunities.

75
00:12:30,000 --> 00:12:40,000
If you see "Cost data unavailable", check that the namespace annotation is correct and that the FinOps backend plugin is running.

76
00:12:40,000 --> 00:12:50,000
Now let's build the FinOps homepage dashboard. This shows a company-wide view of cost.

77
00:12:50,000 --> 00:13:00,000
[Types: cat > plugins/finops/src/components/FinopsDashboard/FinopsDashboard.tsx << 'EOF'
import React, { useEffect, useState } from 'react';
import { InfoCard, Progress, WarningPanel } from '@backstage/core-components';
import { Box, Grid, Typography, LinearProgress, Table, TableBody, TableCell, TableContainer, TableHead, TableRow } from '@material-ui/core';

interface DashboardData {
  totalSpend: number;
  teamCount: number;
  teams: Array<{
    team: string;
    totalCost: number;
    budget: number;
    percentOfBudget: number | null;
    services: number;
  }>;
  topServices: Array<{
    namespace: string;
    totalCost: number;
  }>;
}

export const FinopsDashboard = () => {
  const [data, setData] = useState<DashboardData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    fetch('/api/finops/dashboard')
      .then(r => {
        if (!r.ok) throw new Error(`HTTP ${r.status}`);
        return r.json();
      })
      .then(setData)
      .catch(err => {
        setError(err.message);
      })
      .finally(() => setLoading(false));
  }, []);

  if (loading) return <Progress />;
  if (error) return <WarningPanel title="Dashboard unavailable" message={error} />;
  if (!data) return null;

  return (
    <Box>
      <Typography variant="h4" gutterBottom>
        FinOps Dashboard
      </Typography>
      <Typography variant="subtitle2" color="textSecondary" gutterBottom>
        Company-wide cost overview
      </Typography>

      <Grid container spacing={3}>
        <Grid item xs={12} md={4}>
          <InfoCard title="Total Monthly Spend">
            <Typography variant="h3">${data.totalSpend.toFixed(0)}</Typography>
            <Typography variant="caption" color="textSecondary">
              Across {data.teamCount} teams
            </Typography>
          </InfoCard>
        </Grid>

        <Grid item xs={12} md={8}>
          <InfoCard title="Team Budget Status">
            <TableContainer>
              <Table size="small">
                <TableHead>
                  <TableRow>
                    <TableCell>Team</TableCell>
                    <TableCell align="right">Spend</TableCell>
                    <TableCell align="right">Budget</TableCell>
                    <TableCell align="center">Usage</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {data.teams.map(team => (
                    <TableRow key={team.team}>
                      <TableCell>{team.team}</TableCell>
                      <TableCell align="right">${team.totalCost.toFixed(0)}</TableCell>
                      <TableCell align="right">
                        {team.budget > 0 ? `$${team.budget}` : '—'}
                      </TableCell>
                      <TableCell align="center">
                        {team.percentOfBudget !== null && team.budget > 0 ? (
                          <Box display="flex" alignItems="center" gap={1}>
                            <LinearProgress
                              variant="determinate"
                              value={Math.min(team.percentOfBudget, 100)}
                              style={{
                                flex: 1,
                                height: 6,
                                borderRadius: 3,
                              }}
                              color={team.percentOfBudget >= 90 ? 'secondary' : 'primary'}
                            />
                            <Typography variant="caption">
                              {team.percentOfBudget.toFixed(0)}%
                            </Typography>
                          </Box>
                        ) : (
                          <Typography variant="caption" color="textSecondary">
                            No budget set
                          </Typography>
                        )}
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </TableContainer>
          </InfoCard>
        </Grid>
      </Grid>
    </Box>
  );
};
EOF]
▶ Pronounced as: "Now creating the FinopsDashboard component."

78
00:13:00,000 --> 00:13:10,000
Now add the dashboard to the plugin exports:

79
00:13:10,000 --> 00:13:20,000
[Types: cat >> plugins/finops/src/index.ts << 'EOF'
export { FinopsDashboard } from './components/FinopsDashboard/FinopsDashboard';
EOF]
▶ Pronounced as: "Now exporting the FinopsDashboard component."

80
00:13:20,000 --> 00:13:30,000
Now add a FinOps tab to the homepage:

81
00:13:30,000 --> 00:13:40,000
[Types: cat >> packages/app/src/App.tsx << 'EOF'
import { FinopsDashboard } from '@internal/plugin-finops';

// In the routes
<Route path="/finops" element={<FinopsDashboard />} />
EOF]
▶ Pronounced as: "Now adding the FinOps dashboard route."

82
00:13:40,000 --> 00:13:50,000
Now, look at the homepage dashboard. You should see total company spend, team budget status, and top services.

83
00:13:50,000 --> 00:14:00,000
Every developer who opens the portal sees cost data immediately. No need to navigate to separate tools.

84
00:14:00,000 --> 00:14:10,000
In the next segment, we add the chargeback report and Kubecost anomaly webhook.

85
00:14:10,000 --> 00:14:20,000
See you in Segment 4.
```

---

SEGMENT 4: Chargeback Report & Kubecost Anomaly Webhook
Timestamp: 15:00 – 20:00

```
86
00:15:00,000 --> 00:15:10,000
The chargeback report runs on the first of every month and sends a team-by-team cost breakdown to finance.

87
00:15:10,000 --> 00:15:20,000
This closes the accountability loop: developers see cost in the catalog, managers see cost in Slack alerts, and finance sees cost in the monthly report.

88
00:15:20,000 --> 00:15:30,000
Add the chargeback endpoint to the router:

89
00:15:30,000 --> 00:15:40,000
[Types: cat >> plugins/finops-backend/src/router.ts << 'EOF'
  router.get('/chargeback', async (req, res) => {
    const format = req.query.format as string || 'json';
    const month = req.query.month as string || 'current';

    try {
      const window = month === 'current' ? '30d' : `month`;
      const resp = await fetch(
        `${kubecostUrl}/allocation?window=${window}&aggregate=namespace&accumulate=true`
      );
      const data = await resp.json() as any;
      const namespaces = data?.data?.[0] ?? {};

      // Get all components from catalog
      const { items: components } = await catalog.getEntities({
        filter: { kind: 'Component' },
      });

      // Build team report
      const teamReport: Record<string, {
        team: string;
        totalCost: number;
        services: Array<{ name: string; cost: number }>;
      }> = {};

      for (const component of components) {
        const team = component.metadata.annotations?.['finops/team'] ?? 'unknown';
        const namespace = component.metadata.annotations?.['kubecost.com/namespace']
          ?? component.metadata.name;
        const cost = namespaces[namespace]?.totalCost ?? 0;

        if (!teamReport[team]) {
          teamReport[team] = {
            team,
            totalCost: 0,
            services: [],
          };
        }

        teamReport[team].totalCost += cost;
        teamReport[team].services.push({
          name: component.metadata.name,
          cost,
        });
      }

      if (format === 'csv') {
        let csv = 'Team,Service,Monthly Cost ($)\n';
        let total = 0;
        for (const [team, data] of Object.entries(teamReport) as any) {
          for (const service of data.services) {
            csv += `${team},${service.name},${service.cost.toFixed(2)}\n`;
          }
          total += data.totalCost;
        }
        csv += `\nTOTAL,,,,${total.toFixed(2)}\n`;
        res.setHeader('Content-Type', 'text/csv');
        res.setHeader('Content-Disposition', `attachment; filename=chargeback-${month}.csv`);
        return res.send(csv);
      }

      res.json({
        month,
        teams: Object.values(teamReport),
        total: Object.values(teamReport).reduce((sum, t: any) => sum + t.totalCost, 0),
      });
    } catch (error: any) {
      res.status(500).json({ error: 'Failed to generate chargeback' });
    }
  });
EOF]
▶ Pronounced as: "Now adding the chargeback endpoint to the router."

90
00:15:40,000 --> 00:15:50,000
Now add the anomaly webhook endpoint. This receives alerts from Kubecost and routes them to service owners.

91
00:15:50,000 --> 00:16:00,000
[Types: cat >> plugins/finops-backend/src/router.ts << 'EOF'
  router.post('/webhooks/kubecost', async (req, res) => {
    const payload = req.body;
    const namespace = payload.namespace || payload.rootCauses?.[0]?.service || 'unknown';
    const costIncrease = payload.costIncrease || payload.impact || 0;

    if (costIncrease < 50) {
      return res.json({ status: 'ignored', reason: 'below threshold' });
    }

    // Find service in catalog by namespace
    const { items: components } = await catalog.getEntities({
      filter: { kind: 'Component' },
    });

    const service = components.find(c =>
      c.metadata.annotations?.['kubecost.com/namespace'] === namespace ||
      c.metadata.name === namespace
    );

    if (!service) {
      return res.json({ status: 'ignored', reason: 'service not found' });
    }

    const team = service.metadata.annotations?.['finops/team'] ?? 'unknown';
    const name = service.metadata.name;

    // Send Slack alert
    const slackToken = config.getString('slack.token');
    const slack = new WebClient(slackToken);

    await slack.chat.postMessage({
      channel: `#${team}-alerts`,
      text: `🚨 Cost Anomaly Detected — ${name}`,
      blocks: [
        {
          type: 'header',
          text: {
            type: 'plain_text',
            text: `🚨 Cost Anomaly — ${name}`,
          },
        },
        {
          type: 'section',
          fields: [
            { type: 'mrkdwn', text: `*Namespace:*\n${namespace}` },
            { type: 'mrkdwn', text: `*Increase:*\n$${costIncrease.toFixed(0)}` },
            { type: 'mrkdwn', text: `*Team:*\n${team}` },
            { type: 'mrkdwn', text: `*Service:*\n${name}` },
          ],
        },
        {
          type: 'actions',
          elements: [
            {
              type: 'button',
              text: { type: 'plain_text', text: 'View in Portal' },
              url: `https://backstage.internal/catalog/default/component/${name}/finops`,
              style: 'primary',
            },
          ],
        },
      ],
    });

    res.json({ status: 'alert_sent', service: name, team });
  });
EOF]
▶ Pronounced as: "Now adding the anomaly webhook endpoint to the router."

92
00:16:00,000 --> 00:16:10,000
Now configure Kubecost to send anomaly alerts to Backstage:

93
00:16:10,000 --> 00:16:20,000
[Types: kubectl patch configmap kubecost-cost-analyzer -n kubecost --type merge -p '{
  "data": {
    "alertConfigs": "{\"alerts\":[{\"type\":\"anomaly\",\"window\":\"1d\",\"threshold\":0.20,\"slackWebhookUrl\":\"https://backstage.internal/api/finops/webhooks/kubecost\",\"ownerContact\":[\"platform-team@yourcompany.com\"]}]}"
  }
}']
▶ Pronounced as: "Now configuring Kubecost to send anomaly alerts to the Backstage webhook."

94
00:16:20,000 --> 00:16:30,000
Test the webhook manually:

95
00:16:30,000 --> 00:16:40,000
[Types: curl -X POST http://localhost:7007/api/finops/webhooks/kubecost -H "Content-Type: application/json" -d '{"namespace":"financial-rag","costIncrease":340,"impact":340}']
▶ Pronounced as: "Now testing the anomaly webhook manually."

96
00:16:40,000 --> 00:16:50,000
Now, look at that output. You should see an alert response. If Slack is configured, the alert will be sent to the team channel.

97
00:16:50,000 --> 00:17:00,000
Now update the baseline document:

98
00:17:00,000 --> 00:17:10,000
[Types: echo "=== SERIES 10: IDP FINOPS INTEGRATION ===" >> ~/finops-baseline.txt]
[Types: echo "Date: $(date)" >> ~/finops-baseline.txt]
[Types: echo "" >> ~/finops-baseline.txt]
[Types: echo "FinOps cost card: live in catalog for all services" >> ~/finops-baseline.txt]
[Types: echo "Budget alerts: routing to team Slack channels daily" >> ~/finops-baseline.txt]
[Types: echo "Chargeback report: auto-generating on the 1st of each month" >> ~/finops-baseline.txt]
[Types: echo "Kubecost anomaly webhook: pointing at Backstage FinOps plugin" >> ~/finops-baseline.txt]
[Types: echo "Result: FinOps visible to every developer as part of daily workflow" >> ~/finops-baseline.txt]
[Types: echo "" >> ~/finops-baseline.txt]
▶ Pronounced as: "Now updating the baseline document with Series 10 results."

99
00:17:10,000 --> 00:17:20,000
Now let me recap what you built in Series 10.

100
00:17:20,000 --> 00:17:30,000
You built the FinOps backend plugin with cost API, budget scheduler, chargeback endpoint, and anomaly webhook.

101
00:17:30,000 --> 00:17:40,000
You built the FinOps frontend component showing cost in the catalog. You built the FinOps homepage dashboard showing company-wide cost.

102
00:17:40,000 --> 00:17:50,000
You configured Kubecost to send anomaly alerts to Backstage. The budget scheduler runs daily and alerts teams approaching their budget.

103
00:17:50,000 --> 00:18:00,000
The chargeback report runs monthly for finance. Cost is now visible to every developer in their daily workflow.

104
00:18:00,000 --> 00:18:10,000
FinOps stops being something the platform team thinks about. It becomes something every developer sees, every day.

105
00:18:10,000 --> 00:18:20,000
In the next segment, we recap Series 10 and preview Series 11.

106
00:18:20,000 --> 00:18:30,000
See you in Segment 5.
```

---

SEGMENT 5: Series 10 Recap & Series 11 Preview
Timestamp: 20:00 – 25:00

```
107
00:20:00,000 --> 00:20:10,000
Stand back and look at what this course has built.

108
00:20:10,000 --> 00:20:20,000
Series 1 established visibility. Series 2 eliminated $12,544 a month in waste. Series 3 brought namespace-level cost intelligence.

109
00:20:20,000 --> 00:20:30,000
Series 4 automated node right-sizing continuously with Karpenter. Series 5 cut GPU training costs by 75% with Spot engineering.

110
00:20:30,000 --> 00:20:40,000
Series 6 automated storage and database cost controls. Series 7 built the IDP foundation. Series 8 encoded all FinOps knowledge into the golden path template.

111
00:20:40,000 --> 00:20:50,000
Series 9 gave developers self-service operations. Series 10 made cost visible to every developer in their daily workflow.

112
00:20:50,000 --> 00:21:00,000
The total: $47,000 a month to $19,404 a month. $330,000 a year in savings.

113
00:21:00,000 --> 00:21:10,000
On infrastructure that now self-optimises — new services launch with cost controls already in place, anomalies alert automatically, budgets report to finance monthly.

114
00:21:10,000 --> 00:21:20,000
And developers see the financial impact of their infrastructure decisions before they make them.

115
00:21:20,000 --> 00:21:30,000
Series 11 is the capstone. We validate every component we built. We run the final baseline update. We produce the CTO-ready report.

116
00:21:30,000 --> 00:21:40,000
And we deploy the monitoring infrastructure that keeps everything running correctly after the course ends.

117
00:21:40,000 --> 00:21:50,000
Before Series 11, run these verification checks:

118
00:21:50,000 --> 00:22:00,000
[Types: cat ~/finops-baseline.txt | grep -c "SERIES" | xargs echo "Series completed in baseline:"]
▶ Pronounced as: "Now checking how many series are recorded in the baseline document."

119
00:22:00,000 --> 00:22:10,000
[Types: kubectl get pods -n kubecost | grep -c Running | xargs echo "Kubecost pods running:"]
▶ Pronounced as: "Now checking Kubecost pod status."

120
00:22:10,000 --> 00:22:20,000
[Types: curl -s http://localhost:7007/api/finops/cost?namespace=financial-rag | jq -r '.currentMonth' 2>/dev/null | xargs echo "Current month cost from FinOps API: $" || echo "FinOps API not responding"]
▶ Pronounced as: "Now checking the FinOps API is responding."

121
00:22:20,000 --> 00:22:30,000
Verify the FinOps card appears in at least one catalog entity. Navigate to any service in Backstage and look for the Cost Overview card.

122
00:22:30,000 --> 00:22:40,000
If any of these are missing, the corresponding series needs to be completed before Series 11 makes sense.

123
00:22:40,000 --> 00:22:50,000
Series 10 is complete. The IDP is now the single source of truth for both deployment status and financial status.

124
00:22:50,000 --> 00:23:00,000
Every developer who opens the portal sees cost. Every team receives budget alerts. Finance receives monthly chargeback reports.

125
00:23:00,000 --> 00:23:10,000
The loop is closed. FinOps is now part of the daily workflow, not a separate activity.

126
00:23:10,000 --> 00:23:20,000
In Series 11, we validate everything and produce the final CTO report.

127
00:23:20,000 --> 00:23:30,000
See you in Series 11.
```

---

SEGMENT 6: Deep Dive: FinOps Plugin Architecture
Timestamp: 25:00 – 30:00

```
128
00:25:00,000 --> 00:25:10,000
Welcome to Segment 6. Let's dive deep into the FinOps plugin architecture.

129
00:25:10,000 --> 00:25:20,000
The FinOps plugin is a Backstage backend plugin that integrates cost data from Kubecost into the developer portal.

130
00:25:20,000 --> 00:25:30,000
The architecture has three main layers. The data layer is Kubecost, which provides the cost data through its REST API.

131
00:25:30,000 --> 00:25:40,000
The service layer is the Backstage backend plugin. It queries Kubecost, processes the data, and serves it through its own REST API.

132
00:25:40,000 --> 00:25:50,000
The presentation layer is the Backstage frontend plugin. It displays the cost data in the catalog and on the homepage dashboard.

133
00:25:50,000 --> 00:26:00,000
The data flow is simple. The frontend makes requests to the backend API. The backend makes requests to Kubecost.

134
00:26:00,000 --> 00:26:10,000
The backend also has a scheduler that runs daily, independent of frontend requests. It checks budgets and sends alerts.

135
00:26:10,000 --> 00:26:20,000
This separation of concerns is important. The frontend is stateless. The backend handles all data processing and external integrations.

136
00:26:20,000 --> 00:26:30,000
The plugin uses the Backstage catalog to discover services and their annotations. This is how it finds the namespace and budget for each service.

137
00:26:30,000 --> 00:26:40,000
The catalog annotations are the configuration. finops/monthly-budget sets the budget. finops/team sets the team for alerts.

138
00:26:40,000 --> 00:26:50,000
kubecost.com/namespace tells the plugin which namespace to query. This is how the cost data is linked to the service.

139
00:26:50,000 --> 00:27:00,000
The plugin also integrates with Slack for alerts. The Slack token is configured in app-config.yaml.

140
00:27:00,000 --> 00:27:10,000
The anomaly webhook receives alerts from Kubecost and routes them to the appropriate team channel.

141
00:27:10,000 --> 00:27:20,000
This architecture is modular. Each component can be replaced or extended independently.

142
00:27:20,000 --> 00:27:30,000
If you want to use a different cost data source, you only need to change the backend data layer. The frontend stays the same.

143
00:27:30,000 --> 00:27:40,000
If you want to use a different alerting destination, you only need to change the scheduler. The cost API stays the same.

144
00:27:40,000 --> 00:27:50,000
Now you understand the FinOps plugin architecture. It is a clean, modular integration that brings cost data into the developer portal.

145
00:27:50,000 --> 00:28:00,000
In the next segment, we look at installing and setting up the FinOps backend plugin in detail.

146
00:28:00,000 --> 00:28:10,000
See you in Segment 7.
```

---

SEGMENT 7: FinOps Backend Plugin — Installation & Setup
Timestamp: 30:00 – 35:00

```
147
00:30:00,000 --> 00:30:10,000
Let's walk through the FinOps backend plugin installation step by step.

148
00:30:10,000 --> 00:30:20,000
First, create the plugin using the Backstage CLI.

149
00:30:20,000 --> 00:30:30,000
[Types: cd finops-idp]
[Types: npx @backstage/cli new --select backend-plugin --option id=finops]
▶ Pronounced as: "Now creating the FinOps backend plugin with the Backstage CLI."

150
00:30:30,000 --> 00:30:40,000
This creates a new plugin in the packages/backend directory with the name finops-backend.

151
00:30:40,000 --> 00:30:50,000
The plugin structure includes src/ for source code, package.json for dependencies, and tsconfig.json for TypeScript configuration.

152
00:30:50,000 --> 00:31:00,000
Now install the dependencies:

153
00:31:00,000 --> 00:31:10,000
[Types: yarn --cwd plugins/finops-backend add node-fetch @backstage/catalog-client @slack/web-api aws-sdk]
▶ Pronounced as: "Now installing dependencies for the FinOps backend plugin."

154
00:31:10,000 --> 00:31:20,000
node-fetch is for HTTP requests. The catalog client is for querying the Backstage catalog. The Slack web API is for sending alerts.

155
00:31:20,000 --> 00:31:30,000
AWS SDK is for accessing Cost Explorer and other AWS services if needed.

156
00:31:30,000 --> 00:31:40,000
Now create the router.ts file. This is where the REST API endpoints are defined.

157
00:31:40,000 --> 00:31:50,000
The router exports a function called createRouter that takes config and logger as parameters and returns an Express router.

158
00:31:50,000 --> 00:32:00,000
The router has endpoints for cost, rightsizing, dashboard, chargeback, and the anomaly webhook.

159
00:32:00,000 --> 00:32:10,000
Each endpoint uses the kubecostUrl from the config to make requests to Kubecost.

160
00:32:10,000 --> 00:32:20,000
Now create the scheduler.ts file. This contains the budget check logic that runs daily.

161
00:32:20,000 --> 00:32:30,000
The scheduler queries the catalog for all components, checks their budget annotations, and sends alerts when budgets are exceeded.

162
00:32:30,000 --> 00:32:40,000
Now create the plugin.ts file. This registers the plugin with Backstage and schedules the budget check.

163
00:32:40,000 --> 00:32:50,000
The plugin uses the Backstage scheduler service to run the budget check daily at 9 AM.

164
00:32:50,000 --> 00:33:00,000
Now register the plugin in the backend index.ts file:

165
00:33:00,000 --> 00:33:10,000
[Types: cat >> packages/backend/src/index.ts << 'EOF'
backend.add(import('@internal/plugin-finops-backend'));
EOF]
▶ Pronounced as: "Now registering the FinOps backend plugin in the backend index."

166
00:33:10,000 --> 00:33:20,000
Now add the configuration to app-config.yaml:

167
00:33:20,000 --> 00:33:30,000
[Types: cat >> app-config.yaml << 'EOF'
kubecost:
  baseUrl: http://kubecost-cost-analyzer.kubecost:9090

slack:
  token: ${SLACK_TOKEN}
EOF]
▶ Pronounced as: "Now adding Kubecost and Slack configuration to app-config.yaml."

168
00:33:30,000 --> 00:33:40,000
The kubecost baseUrl is the internal service URL within the cluster. If you are running Backstage outside the cluster, use the port-forward address.

169
00:33:40,000 --> 00:33:50,000
The Slack token is an environment variable. Set it in your .env file:

170
00:33:50,000 --> 00:34:00,000
[Types: echo "SLACK_TOKEN=xoxb-your-token" >> .env]
▶ Pronounced as: "Now adding the Slack token to the .env file."

171
00:34:00,000 --> 00:34:10,000
Now rebuild Backstage:

172
00:34:10,000 --> 00:34:20,000
[Types: yarn build]
▶ Pronounced as: "Now building Backstage."

173
00:34:20,000 --> 00:34:30,000
And start Backstage:

174
00:34:30,000 --> 00:34:40,000
[Types: yarn dev]
▶ Pronounced as: "Now starting Backstage."

175
00:34:40,000 --> 00:34:50,000
Test the cost API endpoint:

176
00:34:50,000 --> 00:35:00,000
[Types: curl -s "http://localhost:7007/api/finops/cost?namespace=financial-rag" | jq .]
▶ Pronounced as: "Now testing the cost API endpoint."

177
00:35:00,000 --> 00:35:10,000
Now, look at that output. You should see cost data for the financial-rag namespace.

178
00:35:10,000 --> 00:35:20,000
If you see an error, check the logs. Common issues include incorrect kubecostUrl, network connectivity, or missing namespace.

179
00:35:20,000 --> 00:35:30,000
Now you have the FinOps backend plugin installed and configured. In the next segment, we look at the cost API endpoint in detail.

180
00:35:30,000 --> 00:35:40,000
See you in Segment 8.
```

---

SEGMENT 8: Deep Dive: Cost API — /cost Endpoint
Timestamp: 35:00 – 40:00

```
181
00:35:00,000 --> 00:35:10,000
The /cost endpoint is the primary data source for the FinOps frontend component.

182
00:35:10,000 --> 00:35:20,000
It takes a namespace parameter and returns comprehensive cost data for that namespace.

183
00:35:20,000 --> 00:35:30,000
Let's look at the endpoint implementation in detail.

184
00:35:30,000 --> 00:35:40,000
[Types: router.get('/cost', async (req, res) => {
  const namespace = req.query.namespace as string;
  if (!namespace) {
    return res.status(400).json({ error: 'namespace required' });
  }

  try {
    const [currentRes, prevRes, rightsizeRes] = await Promise.all([
      fetch(`${kubecostUrl}/allocation?window=30d&aggregate=namespace&filter=namespace:"${namespace}"`),
      fetch(`${kubecostUrl}/allocation?window=month&aggregate=namespace&filter=namespace:"${namespace}"`),
      fetch(`${kubecostUrl}/savings/requestSizing?window=7d&filter=namespace:"${namespace}"`),
    ]);

    const [current, previous, rightsize] = await Promise.all([
      currentRes.json() as any,
      prevRes.json() as any,
      rightsizeRes.json() as any,
    ]);

    const curr = current?.data?.[0]?.[namespace] ?? {};
    const prev = previous?.data?.[0]?.[namespace] ?? {};

    const currentMonth = curr.totalCost ?? 0;
    const previousMonth = prev.totalCost ?? 0;

    const trend = previousMonth > 0
      ? ((currentMonth - previousMonth) / previousMonth) * 100
      : 0;

    const now = new Date();
    const daysInMonth = new Date(now.getFullYear(), now.getMonth() + 1, 0).getDate();
    const forecast = (currentMonth / now.getDate()) * daysInMonth;

    const rightsizingSavings = (rightsize?.recommendations ?? [])
      .reduce((sum: number, r: any) => sum + (r.monthlySavings ?? 0), 0);

    res.json({
      namespace,
      currentMonth: Math.round(currentMonth * 100) / 100,
      previousMonth: Math.round(previousMonth * 100) / 100,
      trend: Math.round(trend * 10) / 10,
      forecast: Math.round(forecast * 100) / 100,
      efficiency: curr.efficiency ?? 0,
      cpuCost: curr.cpuCost ?? 0,
      ramCost: curr.ramCost ?? 0,
      storageCost: curr.storageCost ?? 0,
      networkCost: curr.networkCost ?? 0,
      idleCost: curr.idleCost ?? 0,
      rightsizingSavings: Math.round(rightsizingSavings * 100) / 100,
    });
  } catch (error: any) {
    logger.error(`Cost fetch failed for ${namespace}: ${error.message}`);
    res.status(500).json({ error: 'Failed to fetch cost data' });
  }
});]
▶ Pronounced as: "Now viewing the /cost endpoint implementation."

185
00:35:40,000 --> 00:35:50,000
Let me break down what this endpoint does.

186
00:35:50,000 --> 00:36:00,000
First, it validates the namespace parameter. If it is missing, it returns a 400 error.

187
00:36:00,000 --> 00:36:10,000
Then it makes three parallel requests to Kubecost using Promise.all. This is more efficient than sequential requests.

188
00:36:10,000 --> 00:36:20,000
The first request gets the last 30 days of cost data. The second gets the previous month's data for trend calculation.

189
00:36:20,000 --> 00:36:30,000
The third gets rightsizing recommendations. This tells us how much could be saved by right-sizing the workload.

190
00:36:30,000 --> 00:36:40,000
The Kubecost API response is complex. We extract the relevant data using the namespace as a key.

191
00:36:40,000 --> 00:36:50,000
The current month cost is extracted from the 30-day window. The previous month cost is extracted from the month window.

192
00:36:50,000 --> 00:37:00,000
The trend is calculated as the percentage change from the previous month.

193
00:37:00,000 --> 00:37:10,000
The forecast is calculated by linear extrapolation: currentMonthCost divided by days elapsed times total days in the month.

194
00:37:10,000 --> 00:37:20,000
This is a simple forecast that works well for stable workloads. It assumes the current spend rate will continue.

195
00:37:20,000 --> 00:37:30,000
The efficiency is extracted from the current month data. This is the percentage of requested resources that are actually used.

196
00:37:30,000 --> 00:37:40,000
The cost breakdown by category is also extracted: CPU cost, RAM cost, storage cost, network cost, and idle cost.

197
00:37:40,000 --> 00:37:50,000
The rightsizing savings is calculated by summing the monthly savings of all rightsizing recommendations.

198
00:37:50,000 --> 00:38:00,000
All values are rounded to two decimal places to avoid floating point issues.

199
00:38:00,000 --> 00:38:10,000
The endpoint returns a JSON object with all this data. The frontend component displays it in the cost card.

200
00:38:10,000 --> 00:38:20,000
Now you understand the /cost endpoint. It is a simple but powerful API that provides all the cost data needed for the frontend.

201
00:38:20,000 --> 00:38:30,000
In the next segment, we look at the rightsizing endpoint.

202
00:38:30,000 --> 00:38:40,000
See you in Segment 9.
```

---

SEGMENT 9: Deep Dive: Cost API — /rightsizing Endpoint
Timestamp: 40:00 – 45:00

```
203
00:40:00,000 --> 00:40:10,000
The /rightsizing endpoint provides detailed rightsizing recommendations for a namespace.

204
00:40:10,000 --> 00:40:20,000
It takes a namespace parameter and returns specific recommendations for each deployment.

205
00:40:20,000 --> 00:40:30,000
Let's look at the endpoint implementation.

206
00:40:30,000 --> 00:40:40,000
[Types: router.get('/rightsizing', async (req, res) => {
  const namespace = req.query.namespace as string;
  if (!namespace) {
    return res.status(400).json({ error: 'namespace required' });
  }

  try {
    const resp = await fetch(
      `${kubecostUrl}/savings/requestSizing?window=7d&filter=namespace:"${namespace}"`
    );
    const data = await resp.json() as any;

    const recommendations = (data?.recommendations ?? [])
      .map((r: any) => ({
        namespace: r.namespace,
        deployment: r.deployment,
        container: r.containerName,
        currentCPU: r.currentCPUReq,
        recommendedCPU: r.recommendedCPUReq,
        currentRAM: r.currentRAMReq,
        recommendedRAM: r.recommendedRAMReq,
        monthlySavings: r.monthlySavings,
      }))
      .filter((r: any) => r.monthlySavings > 0)
      .sort((a: any, b: any) => b.monthlySavings - a.monthlySavings);

    res.json({
      namespace,
      recommendations,
      totalMonthlySavings: recommendations
        .reduce((sum: number, r: any) => sum + r.monthlySavings, 0),
    });
  } catch (error: any) {
    res.status(500).json({ error: 'Failed to fetch rightsizing data' });
  }
});]
▶ Pronounced as: "Now viewing the /rightsizing endpoint implementation."

207
00:40:40,000 --> 00:40:50,000
The endpoint makes a request to the Kubecost rightsizing API for the specified namespace.

208
00:40:50,000 --> 00:41:00,000
The response is processed to extract the container name, current and recommended resources, and monthly savings.

209
00:41:00,000 --> 00:41:10,000
Only recommendations with positive monthly savings are returned. They are sorted by savings amount, highest first.

210
00:41:10,000 --> 00:41:20,000
The response includes the total monthly savings across all recommendations.

211
00:41:20,000 --> 00:41:30,000
This endpoint is used by the FinOps frontend to display rightsizing opportunities to developers.

212
00:41:30,000 --> 00:41:40,000
A typical response looks like this:

213
00:41:40,000 --> 00:41:50,000
{
  "namespace": "financial-rag",
  "recommendations": [
    {
      "deployment": "llm-ingest",
      "container": "llm-ingest",
      "currentCPU": "2000m",
      "recommendedCPU": "500m",
      "currentRAM": "4Gi",
      "recommendedRAM": "1.2Gi",
      "monthlySavings": 47.20
    }
  ],
  "totalMonthlySavings": 47.20
}

214
00:41:50,000 --> 00:42:00,000
The developer sees that the llm-ingest deployment can save $47.20 a month by reducing CPU from 2000m to 500m and RAM from 4Gi to 1.2Gi.

215
00:42:00,000 --> 00:42:10,000
This is actionable information. The developer can apply the recommendation and see the savings on the next bill.

216
00:42:10,000 --> 00:42:20,000
The endpoint also includes the total monthly savings. This is useful for reporting and prioritization.

217
00:42:20,000 --> 00:42:30,000
Now you understand the /rightsizing endpoint. It provides specific, actionable recommendations for cost optimization.

218
00:42:30,000 --> 00:42:40,000
In the next segment, we look at the /dashboard endpoint.

219
00:42:40,000 --> 00:42:50,000
See you in Segment 10.
```

---

SEGMENT 10: Deep Dive: Cost API — /dashboard Endpoint
Timestamp: 45:00 – 50:00

```
220
00:45:00,000 --> 00:45:10,000
The /dashboard endpoint provides a company-wide view of cost.

221
00:45:10,000 --> 00:45:20,000
It aggregates cost data across all namespaces and teams. It is used by the FinOps homepage dashboard.

222
00:45:20,000 --> 00:45:30,000
Let's look at the endpoint implementation.

223
00:45:30,000 --> 00:45:40,000
[Types: router.get('/dashboard', async (req, res) => {
  try {
    // Get all components from catalog
    const { items: components } = await catalog.getEntities({
      filter: { kind: 'Component' },
    });

    // Get cluster-wide allocation from Kubecost
    const resp = await fetch(
      `${kubecostUrl}/allocation?window=30d&aggregate=namespace&accumulate=true`
    );
    const data = await resp.json() as any;
    const namespaces = data?.data?.[0] ?? {};

    // Build team report
    const teamReport: Record<string, {
      team: string;
      totalCost: number;
      budget: number;
      services: number;
    }> = {};

    for (const component of components) {
      const team = component.metadata.annotations?.['finops/team'] ?? 'unknown';
      const namespace = component.metadata.annotations?.['kubecost.com/namespace']
        ?? component.metadata.name;
      const budget = parseFloat(component.metadata.annotations?.['finops/monthly-budget'] ?? '0');
      const cost = namespaces[namespace]?.totalCost ?? 0;

      if (!teamReport[team]) {
        teamReport[team] = { team, totalCost: 0, budget: 0, services: 0 };
      }

      teamReport[team].totalCost += cost;
      teamReport[team].budget += budget;
      teamReport[team].services += 1;
    }

    // Top services by cost
    const topServices = Object.entries(namespaces)
      .map(([ns, data]: [string, any]) => ({
        namespace: ns,
        totalCost: data.totalCost ?? 0,
      }))
      .sort((a, b) => b.totalCost - a.totalCost)
      .slice(0, 10);

    const totalSpend = Object.values(teamReport).reduce(
      (sum, t: any) => sum + t.totalCost, 0
    );

    res.json({
      totalSpend: Math.round(totalSpend * 100) / 100,
      teamCount: Object.keys(teamReport).length,
      teams: Object.values(teamReport).map((t: any) => ({
        ...t,
        percentOfBudget: t.budget > 0 ? (t.totalCost / t.budget) * 100 : null,
      })),
      topServices,
    });
  } catch (error: any) {
    res.status(500).json({ error: 'Failed to generate dashboard' });
  }
});]
▶ Pronounced as: "Now viewing the /dashboard endpoint implementation."

224
00:45:40,000 --> 00:45:50,000
The endpoint first queries the catalog for all components. This provides the team and budget metadata.

225
00:45:50,000 --> 00:46:00,000
Then it queries Kubecost for the 30-day cost data aggregated by namespace. This provides the cost data.

226
00:46:00,000 --> 00:46:10,000
The endpoint then builds a team report by aggregating cost and budget data by team.

227
00:46:10,000 --> 00:46:20,000
For each component, it looks up the team annotation, the namespace annotation, and the budget annotation.

228
00:46:20,000 --> 00:46:30,000
It then finds the cost for that namespace in the Kubecost data and adds it to the team's total.

229
00:46:30,000 --> 00:46:40,000
The endpoint also calculates the top 10 services by cost. This is useful for identifying the most expensive services.

230
00:46:40,000 --> 00:46:50,000
The response includes total spend across all teams, the number of teams, a detailed team report, and the top services.

231
00:46:50,000 --> 00:47:00,000
The team report includes the team name, total cost, total budget, percentage of budget used, and number of services.

232
00:47:00,000 --> 00:47:10,000
A typical response looks like this:

233
00:47:10,000 --> 00:47:20,000
{
  "totalSpend": 19404.00,
  "teamCount": 3,
  "teams": [
    {
      "team": "financial-rag",
      "totalCost": 14200.00,
      "budget": 15000.00,
      "percentOfBudget": 94.67,
      "services": 5
    }
  ],
  "topServices": [
    { "namespace": "financial-rag", "totalCost": 14200.00 }
  ]
}

234
00:47:20,000 --> 00:47:30,000
This endpoint provides the data for the FinOps homepage dashboard. It gives a company-wide view of cost and budget health.

235
00:47:30,000 --> 00:47:40,000
Now you understand the /dashboard endpoint. It aggregates cost data across the entire organization.

236
00:47:40,000 --> 00:47:50,000
In the next segment, we look at the chargeback endpoint.

237
00:47:50,000 --> 00:48:00,000
See you in Segment 11.
```

---

SEGMENT 11: Deep Dive: Cost API — /chargeback Endpoint
Timestamp: 50:00 – 55:00

```
238
00:50:00,000 --> 00:50:10,000
The /chargeback endpoint generates a team-by-team cost breakdown for finance.

239
00:50:10,000 --> 00:50:20,000
It supports both JSON and CSV formats. The CSV format is used for importing into finance systems.

240
00:50:20,000 --> 00:50:30,000
Let's look at the endpoint implementation.

241
00:50:30,000 --> 00:50:40,000
[Types: router.get('/chargeback', async (req, res) => {
  const format = req.query.format as string || 'json';
  const month = req.query.month as string || 'current';

  try {
    const window = month === 'current' ? '30d' : `month`;
    const resp = await fetch(
      `${kubecostUrl}/allocation?window=${window}&aggregate=namespace&accumulate=true`
    );
    const data = await resp.json() as any;
    const namespaces = data?.data?.[0] ?? {};

    const { items: components } = await catalog.getEntities({
      filter: { kind: 'Component' },
    });

    const teamReport: Record<string, {
      team: string;
      totalCost: number;
      services: Array<{ name: string; cost: number }>;
    }> = {};

    for (const component of components) {
      const team = component.metadata.annotations?.['finops/team'] ?? 'unknown';
      const namespace = component.metadata.annotations?.['kubecost.com/namespace']
        ?? component.metadata.name;
      const cost = namespaces[namespace]?.totalCost ?? 0;

      if (!teamReport[team]) {
        teamReport[team] = {
          team,
          totalCost: 0,
          services: [],
        };
      }

      teamReport[team].totalCost += cost;
      teamReport[team].services.push({
        name: component.metadata.name,
        cost,
      });
    }

    if (format === 'csv') {
      let csv = 'Team,Service,Monthly Cost ($)\n';
      let total = 0;
      for (const [team, data] of Object.entries(teamReport) as any) {
        for (const service of data.services) {
          csv += `${team},${service.name},${service.cost.toFixed(2)}\n`;
        }
        total += data.totalCost;
      }
      csv += `\nTOTAL,,,,${total.toFixed(2)}\n`;
      res.setHeader('Content-Type', 'text/csv');
      res.setHeader('Content-Disposition', `attachment; filename=chargeback-${month}.csv`);
      return res.send(csv);
    }

    res.json({
      month,
      teams: Object.values(teamReport),
      total: Object.values(teamReport).reduce((sum, t: any) => sum + t.totalCost, 0),
    });
  } catch (error: any) {
    res.status(500).json({ error: 'Failed to generate chargeback' });
  }
});]
▶ Pronounced as: "Now viewing the /chargeback endpoint implementation."

242
00:50:40,000 --> 00:50:50,000
The endpoint queries Kubecost for the specified month or the current 30-day period.

243
00:50:50,000 --> 00:51:00,000
It then queries the catalog for all components to get the team annotations.

244
00:51:00,000 --> 00:51:10,000
It builds a report by aggregating cost data by team and by service within each team.

245
00:51:10,000 --> 00:51:20,000
The report includes the team name, total cost, and a list of services with their individual costs.

246
00:51:20,000 --> 00:51:30,000
The JSON format is used for integration with other systems. The CSV format is used for finance.

247
00:51:30,000 --> 00:51:40,000
A typical CSV output looks like this:

248
00:51:40,000 --> 00:51:50,000
Team,Service,Monthly Cost ($)
financial-rag,financial-rag-api,5200.00
financial-rag,llm-ingest,8900.00
riskoracle,risk-calc,6000.00
...

249
00:51:50,000 --> 00:52:00,000
This is exactly what finance needs. It is clean, simple, and accurate.

250
00:52:00,000 --> 00:52:10,000
The chargeback report is generated on the first of every month. It is sent to finance automatically.

251
00:52:10,000 --> 00:52:20,000
This closes the accountability loop. Finance sees the cost per team. Teams see their cost in the catalog.

252
00:52:20,000 --> 00:52:30,000
Now you understand the /chargeback endpoint. It provides a clean, finance-ready cost breakdown by team.

253
00:52:30,000 --> 00:52:40,000
In the next segment, we look at the budget scheduler in detail.

254
00:52:40,000 --> 00:52:50,000
See you in Segment 12.
```

---

SEGMENT 12: Deep Dive: Budget Scheduler — How It Works
Timestamp: 55:00 – 60:00

```
255
00:55:00,000 --> 00:55:10,000
The budget scheduler is the proactive component of the FinOps plugin.

256
00:55:10,000 --> 00:55:20,000
It runs daily at 9 AM and checks each service's spend against its budget.

257
00:55:20,000 --> 00:55:30,000
If a service is approaching or exceeding its budget, it sends a Slack alert to the team.

258
00:55:30,000 --> 00:55:40,000
Let's look at the scheduler implementation.

259
00:55:40,000 --> 00:55:50,000
[Types: export async function runBudgetCheck({
  config,
  logger,
  catalog,
}: {
  config: Config;
  logger: Logger;
  catalog: CatalogClient;
}): Promise<void> {
  logger.info('Running budget check');

  const kubecostUrl = config.getString('kubecost.baseUrl');
  const slackToken = config.getString('slack.token');
  const slack = new WebClient(slackToken);

  const { items: components } = await catalog.getEntities({
    filter: { kind: 'Component' },
  });

  let alertCount = 0;

  for (const component of components) {
    const namespace = component.metadata.annotations?.['kubecost.com/namespace']
      ?? component.metadata.annotations?.['backstage.io/kubernetes-namespace'];
    const budgetStr = component.metadata.annotations?.['finops/monthly-budget'];
    const team = component.metadata.annotations?.['finops/team'];
    const name = component.metadata.name;

    if (!namespace || !budgetStr || !team) continue;

    const budget = parseFloat(budgetStr);
    if (budget <= 0) continue;

    try {
      const resp = await fetch(
        `${kubecostUrl}/allocation?window=month&aggregate=namespace&filter=namespace:"${namespace}"`
      );
      const data = await resp.json() as any;
      const currentSpend = data?.data?.[0]?.[namespace]?.totalCost ?? 0;

      const usagePct = (currentSpend / budget) * 100;

      if (usagePct >= 90) {
        alertCount++;
        const daysLeft = new Date(
          new Date().getFullYear(),
          new Date().getMonth() + 1, 0
        ).getDate() - new Date().getDate();

        await slack.chat.postMessage({
          channel: `#${team}-alerts`,
          text: `Budget alert for ${name}`,
          blocks: [
            {
              type: 'header',
              text: {
                type: 'plain_text',
                text: `💰 Budget Alert — ${name}`,
              },
            },
            {
              type: 'section',
              text: {
                type: 'mrkdwn',
                text: `*${usagePct.toFixed(0)}%* of monthly budget used\n` +
                      `Current: $${currentSpend.toFixed(0)} / $${budget}\n` +
                      `Days left: ${daysLeft} days`,
              },
            },
            {
              type: 'actions',
              elements: [
                {
                  type: 'button',
                  text: { type: 'plain_text', text: 'View in Portal' },
                  url: `https://backstage.internal/catalog/default/component/${name}/finops`,
                  style: 'primary',
                },
              ],
            },
          ],
        });

        logger.info(`Budget alert sent for ${name}: ${usagePct.toFixed(0)}%`);
      }
    } catch (err: any) {
      logger.warn(`Budget check failed for ${name}: ${err.message}`);
    }
  }

  logger.info(`Budget check complete. ${alertCount} alerts sent.`);
}]
▶ Pronounced as: "Now viewing the budget scheduler implementation."

260
00:55:50,000 --> 00:56:00,000
The scheduler first queries the catalog for all components. This provides the namespace, budget, and team for each service.

261
00:56:00,000 --> 00:56:10,000
For each component, it checks if it has the required annotations. If not, it skips the service.

262
00:56:10,000 --> 00:56:20,000
If the service has the required annotations, it queries Kubecost for the month-to-date spend.

263
00:56:20,000 --> 00:56:30,000
It calculates the usage percentage by dividing the current spend by the budget.

264
00:56:30,000 --> 00:56:40,000
If the usage percentage is 90% or higher, it sends a Slack alert to the team's channel.

265
00:56:40,000 --> 00:56:50,000
The alert includes the service name, usage percentage, current spend, budget, and days left in the month.

266
00:56:50,000 --> 00:57:00,000
It also includes a button to view the service in the Backstage portal.

267
00:57:00,000 --> 00:57:10,000
The scheduler runs daily at 9 AM. This gives teams early warning before they exceed their budget.

268
00:57:10,000 --> 00:57:20,000
If a team exceeds their budget, they receive multiple alerts. The first alert is at 90%, the second at 100%.

269
00:57:20,000 --> 00:57:30,000
This gives them time to investigate and take action before the month ends.

270
00:57:30,000 --> 00:57:40,000
The scheduler is configurable. The threshold can be changed from 90% to any value.

271
00:57:40,000 --> 00:57:50,000
Now you understand the budget scheduler. It is a simple but effective mechanism for proactive cost management.

272
00:57:50,000 --> 00:58:00,000
In the next segment, we look at the Slack integration in detail.

273
00:58:00,000 --> 00:58:10,000
See you in Segment 13.
```

---

SEGMENT 13: Budget Scheduler — Slack Integration
Timestamp: 60:00 – 65:00

```
274
01:00:00,000 --> 01:00:10,000
The Slack integration is how budget alerts reach the teams.

275
01:00:10,000 --> 01:00:20,000
The scheduler uses the Slack Web API to send messages to team channels.

276
01:00:20,000 --> 01:00:30,000
Let's look at the Slack integration in detail.

277
01:00:30,000 --> 01:00:40,000
[Types: const slack = new WebClient(slackToken);]
▶ Pronounced as: "Now initializing the Slack WebClient."

278
01:00:40,000 --> 01:00:50,000
The Slack token is configured in app-config.yaml. It is an environment variable for security.

279
01:00:50,000 --> 01:01:00,000
[Types: slack:
  token: ${SLACK_TOKEN}]
▶ Pronounced as: "Now viewing the Slack token configuration."

280
01:01:00,000 --> 01:01:10,000
The token is a Bot User OAuth Token. It starts with xoxb- and has permissions to send messages.

281
01:01:10,000 --> 01:01:20,000
The scheduler uses the chat.postMessage method to send messages to channels.

282
01:01:20,000 --> 01:01:30,000
[Types: await slack.chat.postMessage({
  channel: `#${team}-alerts`,
  text: `Budget alert for ${name}`,
  blocks: [
    {
      type: 'header',
      text: {
        type: 'plain_text',
        text: `💰 Budget Alert — ${name}`,
      },
    },
    {
      type: 'section',
      text: {
        type: 'mrkdwn',
        text: `*${usagePct.toFixed(0)}%* of monthly budget used\n` +
              `Current: $${currentSpend.toFixed(0)} / $${budget}\n` +
              `Days left: ${daysLeft} days`,
      },
    },
    {
      type: 'actions',
      elements: [
        {
          type: 'button',
          text: { type: 'plain_text', text: 'View in Portal' },
          url: `https://backstage.internal/catalog/default/component/${name}/finops`,
          style: 'primary',
        },
      ],
    },
  ],
});]
▶ Pronounced as: "Now viewing the Slack message format."

283
01:01:30,000 --> 01:01:40,000
The message uses Slack's Block Kit to create a rich, structured message.

284
01:01:40,000 --> 01:01:50,000
The header provides a visual summary. The section provides the detailed information.

285
01:01:50,000 --> 01:02:00,000
The actions section includes a button that links directly to the service in Backstage.

286
01:02:00,000 --> 01:02:10,000
The channel is named after the team. For example, #financial-rag-alerts or #riskoracle-alerts.

287
01:02:10,000 --> 01:02:20,000
The team name comes from the finops/team annotation in the catalog.

288
01:02:20,000 --> 01:02:30,000
This means each team must have a corresponding Slack channel.

289
01:02:30,000 --> 01:02:40,000
The channel name is predictable: #${team}-alerts. This makes it easy to configure.

290
01:02:40,000 --> 01:02:50,000
If a team does not have a channel, the alert fails. The scheduler logs the error and continues.

291
01:02:50,000 --> 01:03:00,000
The Slack integration is simple but effective. It ensures that cost alerts reach the right people.

292
01:03:00,000 --> 01:03:10,000
Now you understand the Slack integration. It is a critical part of the budget alert system.

293
01:03:10,000 --> 01:03:20,000
In the next segment, we look at the FinOps frontend cost card component.

294
01:03:20,000 --> 01:03:30,000
See you in Segment 14.
```

---

SEGMENT 14: Deep Dive: FinOps Frontend — CostCard Component
Timestamp: 65:00 – 70:00

```
295
01:05:00,000 --> 01:05:10,000
The FinOpsCostCard is the frontend component that displays cost data in the catalog.

296
01:05:10,000 --> 01:05:20,000
It appears on every service's overview page. It shows current cost, trend, efficiency, and budget progress.

297
01:05:20,000 --> 01:05:30,000
Let's look at the component implementation.

298
01:05:30,000 --> 01:05:40,000
[Types: export const FinOpsCostCard = () => {
  const { entity } = useEntity();
  const namespace = entity.metadata.annotations?.['kubecost.com/namespace']
    ?? entity.metadata.annotations?.['backstage.io/kubernetes-namespace'];
  const budgetStr = entity.metadata.annotations?.['finops/monthly-budget'];

  const [cost, setCost] = useState<CostData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    if (!namespace) {
      setLoading(false);
      return;
    }

    fetch(`/api/finops/cost?namespace=${namespace}`)
      .then(r => {
        if (!r.ok) throw new Error(`HTTP ${r.status}`);
        return r.json();
      })
      .then(data => {
        setCost(data);
        setLoading(false);
      })
      .catch(err => {
        setError(err.message);
        setLoading(false);
      });
  }, [namespace]);

  if (loading) return <Progress />;
  if (error) return <WarningPanel title="Cost data unavailable" message={error} />;
  if (!cost) return null;

  const budget = budgetStr ? parseFloat(budgetStr) : 0;
  const budgetPct = budget > 0 ? (cost.currentMonth / budget) * 100 : 0;
  const trendIcon = cost.trend > 5 ? '📈' : cost.trend < -5 ? '📉' : '➡️';
  const efficiencyColor = cost.efficiency >= 0.7 ? 'primary' : cost.efficiency >= 0.5 ? 'secondary' : 'error';

  return (
    <InfoCard title="💰 Cost Overview" subheader="Last 30 days via Kubecost">
      <Box p={2}>
        <Box display="flex" justifyContent="space-between" alignItems="center">
          <Box>
            <Typography variant="h3">${cost.currentMonth.toFixed(0)}</Typography>
            <Typography variant="caption" color="textSecondary">
              This month {trendIcon} {Math.abs(cost.trend).toFixed(1)}% vs last month
            </Typography>
          </Box>
          <Box textAlign="right">
            <Typography variant="h6">
              {(cost.efficiency * 100).toFixed(0)}%
            </Typography>
            <Typography variant="caption" color="textSecondary">
              Efficiency
            </Typography>
          </Box>
        </Box>

        {budget > 0 && (
          <Box mt={2}>
            <Box display="flex" justifyContent="space-between">
              <Typography variant="body2">
                Budget: ${cost.currentMonth.toFixed(0)} / ${budget}
              </Typography>
              <Typography variant="body2" color={budgetPct >= 90 ? 'error' : budgetPct >= 75 ? 'warning' : 'textSecondary'}>
                {budgetPct.toFixed(0)}%
              </Typography>
            </Box>
            <LinearProgress
              variant="determinate"
              value={Math.min(budgetPct, 100)}
              style={{
                height: 8,
                borderRadius: 4,
                backgroundColor: '#e0e0e0',
              }}
              color={budgetPct >= 90 ? 'secondary' : 'primary'}
            />
          </Box>
        )}

        {cost.rightsizingSavings > 0 && (
          <Box mt={2}>
            <Chip
              size="small"
              label={`💡 Rightsizing opportunity: $${cost.rightsizingSavings.toFixed(0)}/month`}
              style={{ backgroundColor: '#e8f5e9', color: '#2e7d32' }}
            />
          </Box>
        )}

        <Box mt={2} display="flex" flexWrap="wrap" gap={1}>
          <Typography variant="caption" color="textSecondary">
            Forecast: ${cost.forecast.toFixed(0)}
          </Typography>
          <Typography variant="caption" color="textSecondary">
            •
          </Typography>
          <Typography variant="caption" color="textSecondary">
            Idle: ${cost.idleCost.toFixed(0)}
          </Typography>
        </Box>
      </Box>
    </InfoCard>
  );
};]
▶ Pronounced as: "Now viewing the FinOpsCostCard component implementation."

299
01:05:40,000 --> 01:05:50,000
The component first uses the useEntity hook to get the current entity from the catalog.

300
01:05:50,000 --> 01:06:00,000
It extracts the namespace and budget from the entity annotations.

301
01:06:00,000 --> 01:06:10,000
If the namespace is missing, it displays nothing. This is the case for services that are not cost-tracked.

302
01:06:10,000 --> 01:06:20,000
It makes a fetch request to the /cost endpoint with the namespace as a parameter.

303
01:06:20,000 --> 01:06:30,000
While loading, it displays a progress indicator. If there is an error, it displays a warning panel.

304
01:06:30,000 --> 01:06:40,000
Once the data is loaded, it displays the cost card.

305
01:06:40,000 --> 01:06:50,000
The card shows the current month cost, the trend compared to last month, and the efficiency score.

306
01:06:50,000 --> 01:07:00,000
If a budget is set, it displays a budget progress bar with the current spend and budget.

307
01:07:00,000 --> 01:07:10,000
If there are rightsizing savings, it displays a chip with the savings amount.

308
01:07:10,000 --> 01:07:20,000
The card also shows the forecast and the idle cost.

309
01:07:20,000 --> 01:07:30,000
The component is compact and information-rich. It fits in the catalog overview page without taking too much space.

310
01:07:30,000 --> 01:07:40,000
Now you understand the FinOpsCostCard component. It is the primary way developers see cost in the catalog.

311
01:07:40,000 --> 01:07:50,000
In the next segment, we look at the FinOps homepage dashboard component.

312
01:07:50,000 --> 01:08:00,000
See you in Segment 15.
```

---

SEGMENT 15: Deep Dive: FinOps Frontend — Dashboard Component
Timestamp: 70:00 – 75:00

```
313
01:10:00,000 --> 01:10:10,000
The FinopsDashboard is the homepage dashboard component.

314
01:10:10,000 --> 01:10:20,000
It provides a company-wide view of cost. It is accessible from the Backstage homepage.

315
01:10:20,000 --> 01:10:30,000
Let's look at the component implementation.

316
01:10:30,000 --> 01:10:40,000
[Types: export const FinopsDashboard = () => {
  const [data, setData] = useState<DashboardData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    fetch('/api/finops/dashboard')
      .then(r => {
        if (!r.ok) throw new Error(`HTTP ${r.status}`);
        return r.json();
      })
      .then(setData)
      .catch(err => {
        setError(err.message);
      })
      .finally(() => setLoading(false));
  }, []);

  if (loading) return <Progress />;
  if (error) return <WarningPanel title="Dashboard unavailable" message={error} />;
  if (!data) return null;

  return (
    <Box>
      <Typography variant="h4" gutterBottom>
        FinOps Dashboard
      </Typography>
      <Typography variant="subtitle2" color="textSecondary" gutterBottom>
        Company-wide cost overview
      </Typography>

      <Grid container spacing={3}>
        <Grid item xs={12} md={4}>
          <InfoCard title="Total Monthly Spend">
            <Typography variant="h3">${data.totalSpend.toFixed(0)}</Typography>
            <Typography variant="caption" color="textSecondary">
              Across {data.teamCount} teams
            </Typography>
          </InfoCard>
        </Grid>

        <Grid item xs={12} md={8}>
          <InfoCard title="Team Budget Status">
            <TableContainer>
              <Table size="small">
                <TableHead>
                  <TableRow>
                    <TableCell>Team</TableCell>
                    <TableCell align="right">Spend</TableCell>
                    <TableCell align="right">Budget</TableCell>
                    <TableCell align="center">Usage</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {data.teams.map(team => (
                    <TableRow key={team.team}>
                      <TableCell>{team.team}</TableCell>
                      <TableCell align="right">${team.totalCost.toFixed(0)}</TableCell>
                      <TableCell align="right">
                        {team.budget > 0 ? `$${team.budget}` : '—'}
                      </TableCell>
                      <TableCell align="center">
                        {team.percentOfBudget !== null && team.budget > 0 ? (
                          <Box display="flex" alignItems="center" gap={1}>
                            <LinearProgress
                              variant="determinate"
                              value={Math.min(team.percentOfBudget, 100)}
                              style={{
                                flex: 1,
                                height: 6,
                                borderRadius: 3,
                              }}
                              color={team.percentOfBudget >= 90 ? 'secondary' : 'primary'}
                            />
                            <Typography variant="caption">
                              {team.percentOfBudget.toFixed(0)}%
                            </Typography>
                          </Box>
                        ) : (
                          <Typography variant="caption" color="textSecondary">
                            No budget set
                          </Typography>
                        )}
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </TableContainer>
          </InfoCard>
        </Grid>
      </Grid>
    </Box>
  );
};]
▶ Pronounced as: "Now viewing the FinopsDashboard component implementation."

317
01:10:40,000 --> 01:10:50,000
The component makes a fetch request to the /dashboard endpoint.

318
01:10:50,000 --> 01:11:00,000
While loading, it displays a progress indicator. If there is an error, it displays a warning panel.

319
01:11:00,000 --> 01:11:10,000
Once the data is loaded, it displays the dashboard.

320
01:11:10,000 --> 01:11:20,000
The dashboard has two main sections. The top shows the total monthly spend across all teams.

321
01:11:20,000 --> 01:11:30,000
The bottom shows a table with the budget status for each team.

322
01:11:30,000 --> 01:11:40,000
The table includes the team name, current spend, budget, and usage percentage.

323
01:11:40,000 --> 01:11:50,000
The usage percentage is displayed as a progress bar. It is color-coded: green for low usage, orange for medium, red for high.

324
01:11:50,000 --> 01:12:00,000
The dashboard is a high-level overview. It is useful for engineering leadership and platform teams.

325
01:12:00,000 --> 01:12:10,000
Now you understand the FinopsDashboard component. It is the company-wide view of cost.

326
01:12:10,000 --> 01:12:20,000
In the next segment, we look at the chargeback report component.

327
01:12:20,000 --> 01:12:30,000
See you in Segment 16.
```

---

SEGMENT 16: Deep Dive: FinOps Frontend — Chargeback Report Component
Timestamp: 75:00 – 80:00

```
328
01:15:00,000 --> 01:15:10,000
The chargeback report component is a frontend view of the chargeback data.

329
01:15:10,000 --> 01:15:20,000
It allows users to view the chargeback report in the browser and download it as CSV.

330
01:15:20,000 --> 01:15:30,000
Let's look at the component implementation.

331
01:15:30,000 --> 01:15:40,000
[Types: export const ChargebackReport = () => {
  const [data, setData] = useState<ChargebackData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [month, setMonth] = useState('current');

  useEffect(() => {
    fetch(`/api/finops/chargeback?format=json&month=${month}`)
      .then(r => {
        if (!r.ok) throw new Error(`HTTP ${r.status}`);
        return r.json();
      })
      .then(setData)
      .catch(err => {
        setError(err.message);
      })
      .finally(() => setLoading(false));
  }, [month]);

  const downloadCSV = () => {
    window.location.href = `/api/finops/chargeback?format=csv&month=${month}`;
  };

  if (loading) return <Progress />;
  if (error) return <WarningPanel title="Chargeback unavailable" message={error} />;
  if (!data) return null;

  return (
    <Box>
      <Box display="flex" justifyContent="space-between" alignItems="center">
        <Typography variant="h4">Chargeback Report</Typography>
        <Box>
          <Select value={month} onChange={e => setMonth(e.target.value)}>
            <MenuItem value="current">Current Month</MenuItem>
            <MenuItem value="last">Last Month</MenuItem>
          </Select>
          <Button onClick={downloadCSV} variant="contained" color="primary">
            Download CSV
          </Button>
        </Box>
      </Box>

      <InfoCard title={`Chargeback — ${data.month}`}>
        <TableContainer>
          <Table>
            <TableHead>
              <TableRow>
                <TableCell>Team</TableCell>
                <TableCell>Service</TableCell>
                <TableCell align="right">Monthly Cost</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {data.teams.map(team => (
                team.services.map(service => (
                  <TableRow key={`${team.team}-${service.name}`}>
                    <TableCell>{team.team}</TableCell>
                    <TableCell>{service.name}</TableCell>
                    <TableCell align="right">${service.cost.toFixed(2)}</TableCell>
                  </TableRow>
                ))
              ))}
              <TableRow>
                <TableCell colSpan={2} align="right">
                  <strong>Total</strong>
                </TableCell>
                <TableCell align="right">
                  <strong>${data.total.toFixed(2)}</strong>
                </TableCell>
              </TableRow>
            </TableBody>
          </Table>
        </TableContainer>
      </InfoCard>
    </Box>
  );
};]
▶ Pronounced as: "Now viewing the ChargebackReport component implementation."

332
01:15:40,000 --> 01:15:50,000
The component provides a dropdown to select the month and a button to download the CSV.

333
01:15:50,000 --> 01:16:00,000
It fetches the chargeback data in JSON format and displays it in a table.

334
01:16:00,000 --> 01:16:10,000
The table includes the team, service, and monthly cost for each service.

335
01:16:10,000 --> 01:16:20,000
The total row at the bottom shows the total cost across all teams and services.

336
01:16:20,000 --> 01:16:30,000
The CSV download uses the same endpoint with the format parameter set to CSV.

337
01:16:30,000 --> 01:16:40,000
This component is used by finance teams to review and export chargeback data.

338
01:16:40,000 --> 01:16:50,000
Now you understand the chargeback report component. It provides a finance-ready view of cost data.

339
01:16:50,000 --> 01:17:00,000
In the next segment, we look at the homepage dashboard in more detail.

340
01:17:00,000 --> 01:17:10,000
See you in Segment 17.
```

---

SEGMENT 17: Homepage Dashboard — Company-Wide Cost View
Timestamp: 80:00 – 85:00

```
341
01:20:00,000 --> 01:20:10,000
The homepage dashboard is the primary entry point for FinOps data in the portal.

342
01:20:10,000 --> 01:20:20,000
It is accessible from the Backstage homepage and provides a company-wide view of cost.

343
01:20:20,000 --> 01:20:30,000
Let's look at how the dashboard is integrated into the Backstage homepage.

344
01:20:30,000 --> 01:20:40,000
[Types: // In packages/app/src/App.tsx
import { FinopsDashboard } from '@internal/plugin-finops';

// In the routes
<Route path="/finops" element={<FinopsDashboard />} />]
▶ Pronounced as: "Now viewing the FinOps dashboard route configuration."

345
01:20:40,000 --> 01:20:50,000
The dashboard is accessible at the /finops route. It is linked from the sidebar.

346
01:20:50,000 --> 01:21:00,000
[Types: // In packages/app/src/components/Root/Root.tsx
import DashboardIcon from '@material-ui/icons/Dashboard';
import AttachMoneyIcon from '@material-ui/icons/AttachMoney';

// In the sidebar items
<SidebarItem icon={AttachMoneyIcon} to="/finops" text="FinOps" />]
▶ Pronounced as: "Now viewing the sidebar integration."

347
01:21:00,000 --> 01:21:10,000
The sidebar item links to the FinOps dashboard. It is visible to all users.

348
01:21:10,000 --> 01:21:20,000
The dashboard is also available as a homepage widget. It can be added to the Backstage homepage.

349
01:21:20,000 --> 01:21:30,000
[Types: // In packages/app/src/components/home/HomePage.tsx
import { FinopsDashboard } from '@internal/plugin-finops';

// In the homepage components
<Grid item xs={12}>
  <FinopsDashboard />
</Grid>]
▶ Pronounced as: "Now viewing the homepage widget configuration."

350
01:21:30,000 --> 01:21:40,000
The homepage dashboard provides a high-level overview of cost across the organization.

351
01:21:40,000 --> 01:21:50,000
It shows the total monthly spend, the number of teams, and the budget status for each team.

352
01:21:50,000 --> 01:22:00,000
The dashboard is refreshed every time the page loads. It always shows the latest data.

353
01:22:00,000 --> 01:22:10,000
The dashboard is a powerful tool for engineering leadership. It provides a quick view of cost health.

354
01:22:10,000 --> 01:22:20,000
It also creates visibility. When everyone sees the cost data, it becomes a shared concern.

355
01:22:20,000 --> 01:22:30,000
Now you understand the homepage dashboard. It is the company-wide view of cost.

356
01:22:30,000 --> 01:22:40,000
In the next segment, we look at the chargeback report generation.

357
01:22:40,000 --> 01:22:50,000
See you in Segment 18.
```

---

SEGMENT 18: Chargeback Report — CSV Generation
Timestamp: 85:00 – 90:00

```
358
01:25:00,000 --> 01:25:10,000
The chargeback report is generated as a CSV file for finance teams.

359
01:25:10,000 --> 01:25:20,000
The CSV format is widely supported by finance tools and spreadsheets.

360
01:25:20,000 --> 01:25:30,000
Let's look at the CSV generation implementation.

361
01:25:30,000 --> 01:25:40,000
[Types: if (format === 'csv') {
  let csv = 'Team,Service,Monthly Cost ($)\n';
  let total = 0;
  for (const [team, data] of Object.entries(teamReport) as any) {
    for (const service of data.services) {
      csv += `${team},${service.name},${service.cost.toFixed(2)}\n`;
    }
    total += data.totalCost;
  }
  csv += `\nTOTAL,,,,${total.toFixed(2)}\n`;
  res.setHeader('Content-Type', 'text/csv');
  res.setHeader('Content-Disposition', `attachment; filename=chargeback-${month}.csv`);
  return res.send(csv);
}]
▶ Pronounced as: "Now viewing the CSV generation implementation."

362
01:25:40,000 --> 01:25:50,000
The CSV generation is simple. It iterates over the team report and writes each service as a row.

363
01:25:50,000 --> 01:26:00,000
The CSV has three columns: Team, Service, and Monthly Cost.

364
01:26:00,000 --> 01:26:10,000
The total row at the bottom shows the total cost across all teams and services.

365
01:26:10,000 --> 01:26:20,000
The CSV is downloaded as an attachment. The filename includes the month.

366
01:26:20,000 --> 01:26:30,000
A typical CSV file looks like this:

367
01:26:30,000 --> 01:26:40,000
Team,Service,Monthly Cost ($)
financial-rag,financial-rag-api,5200.00
financial-rag,llm-ingest,8900.00
riskoracle,risk-calc,6000.00
platform,karpenter,1200.00

TOTAL,,,,21300.00

368
01:26:40,000 --> 01:26:50,000
The CSV is ready for import into finance tools. No additional formatting is needed.

369
01:26:50,000 --> 01:27:00,000
The chargeback report is generated on the first of every month. It is sent to finance automatically.

370
01:27:00,000 --> 01:27:10,000
The automation ensures that finance always has the latest data without manual effort.

371
01:27:10,000 --> 01:27:20,000
Now you understand the CSV generation. It is a simple but critical feature for finance integration.

372
01:27:20,000 --> 01:27:30,000
In the next segment, we look at the Kubecost anomaly webhook configuration.

373
01:27:30,000 --> 01:27:40,000
See you in Segment 19.
```

---

SEGMENT 19: Kubecost Anomaly Webhook — Configuration
Timestamp: 90:00 – 95:00

```
374
01:30:00,000 --> 01:30:10,000
The Kubecost anomaly webhook is how cost anomalies are detected and routed to service owners.

375
01:30:10,000 --> 01:30:20,000
Kubecost detects anomalies in cost data and sends alerts to configured webhooks.

376
01:30:20,000 --> 01:30:30,000
The FinOps plugin provides a webhook endpoint that receives these alerts.

377
01:30:30,000 --> 01:30:40,000
Let's look at the webhook configuration.

378
01:30:40,000 --> 01:30:50,000
[Types: kubectl patch configmap kubecost-cost-analyzer -n kubecost --type merge -p '{
  "data": {
    "alertConfigs": "{\"alerts\":[{\"type\":\"anomaly\",\"window\":\"1d\",\"threshold\":0.20,\"slackWebhookUrl\":\"https://backstage.internal/api/finops/webhooks/kubecost\",\"ownerContact\":[\"platform-team@yourcompany.com\"]}]}"
  }
}']
▶ Pronounced as: "Now configuring Kubecost anomaly alerts to send to Backstage."

379
01:30:50,000 --> 01:31:00,000
The alert configuration defines the type of alert, the window, the threshold, and the webhook URL.

380
01:31:00,000 --> 01:31:10,000
The type is anomaly. This means Kubecost will send alerts for cost anomalies.

381
01:31:10,000 --> 01:31:20,000
The window is 1 day. Kubecost will look at daily cost data for anomalies.

382
01:31:20,000 --> 01:31:30,000
The threshold is 0.20. Kubecost will only send an alert if the anomaly is at least 20% above normal.

383
01:31:30,000 --> 01:31:40,000
The slackWebhookUrl is the endpoint in the FinOps plugin.

384
01:31:40,000 --> 01:31:50,000
The webhook receives the alert, extracts the namespace and cost increase, and sends a Slack alert.

385
01:31:50,000 --> 01:32:00,000
Let's look at the webhook endpoint implementation.

386
01:32:00,000 --> 01:32:10,000
[Types: router.post('/webhooks/kubecost', async (req, res) => {
  const payload = req.body;
  const namespace = payload.namespace || payload.rootCauses?.[0]?.service || 'unknown';
  const costIncrease = payload.costIncrease || payload.impact || 0;

  if (costIncrease < 50) {
    return res.json({ status: 'ignored', reason: 'below threshold' });
  }

  const { items: components } = await catalog.getEntities({
    filter: { kind: 'Component' },
  });

  const service = components.find(c =>
    c.metadata.annotations?.['kubecost.com/namespace'] === namespace ||
    c.metadata.name === namespace
  );

  if (!service) {
    return res.json({ status: 'ignored', reason: 'service not found' });
  }

  const team = service.metadata.annotations?.['finops/team'] ?? 'unknown';
  const name = service.metadata.name;

  const slackToken = config.getString('slack.token');
  const slack = new WebClient(slackToken);

  await slack.chat.postMessage({
    channel: `#${team}-alerts`,
    text: `🚨 Cost Anomaly Detected — ${name}`,
    blocks: [
      {
        type: 'header',
        text: {
          type: 'plain_text',
          text: `🚨 Cost Anomaly — ${name}`,
        },
      },
      {
        type: 'section',
        fields: [
          { type: 'mrkdwn', text: `*Namespace:*\n${namespace}` },
          { type: 'mrkdwn', text: `*Increase:*\n$${costIncrease.toFixed(0)}` },
          { type: 'mrkdwn', text: `*Team:*\n${team}` },
          { type: 'mrkdwn', text: `*Service:*\n${name}` },
        ],
      },
      {
        type: 'actions',
        elements: [
          {
            type: 'button',
            text: { type: 'plain_text', text: 'View in Portal' },
            url: `https://backstage.internal/catalog/default/component/${name}/finops`,
            style: 'primary',
          },
        ],
      },
    ],
  });

  res.json({ status: 'alert_sent', service: name, team });
});]
▶ Pronounced as: "Now viewing the webhook endpoint implementation."

387
01:32:10,000 --> 01:32:20,000
The webhook endpoint first extracts the namespace and cost increase from the payload.

388
01:32:20,000 --> 01:32:30,000
If the cost increase is less than $50, it ignores the alert. This prevents noise.

389
01:32:30,000 --> 01:32:40,000
It then finds the service in the catalog by namespace. If the service is not found, it ignores the alert.

390
01:32:40,000 --> 01:32:50,000
It extracts the team from the service annotations and sends a Slack alert to the team channel.

391
01:32:50,000 --> 01:33:00,000
The alert includes the namespace, cost increase, team, and service name.

392
01:33:00,000 --> 01:33:10,000
It also includes a button to view the service in the Backstage portal.

393
01:33:10,000 --> 01:33:20,000
Now you understand the Kubecost anomaly webhook configuration. It is a powerful tool for proactive cost management.

394
01:33:20,000 --> 01:33:30,000
In the next segment, we look at the anomaly webhook routing in more detail.

395
01:33:30,000 --> 01:33:40,000
See you in Segment 20.
```

---

SEGMENT 20: Anomaly Webhook — Routing to Service Owners
Timestamp: 95:00 – 100:00

```
396
01:35:00,000 --> 01:35:10,000
The anomaly webhook routes cost anomalies to the appropriate service owners.

397
01:35:10,000 --> 01:35:20,000
This ensures that the right people are notified when cost spikes occur.

398
01:35:20,000 --> 01:35:30,000
Let's look at the routing logic in detail.

399
01:35:30,000 --> 01:35:40,000
[Types: const { items: components } = await catalog.getEntities({
  filter: { kind: 'Component' },
});

const service = components.find(c =>
  c.metadata.annotations?.['kubecost.com/namespace'] === namespace ||
  c.metadata.name === namespace
);

if (!service) {
  return res.json({ status: 'ignored', reason: 'service not found' });
}

const team = service.metadata.annotations?.['finops/team'] ?? 'unknown';
const name = service.metadata.name;
const owner = service.spec?.owner ?? 'unknown';]
▶ Pronounced as: "Now viewing the routing logic."

400
01:35:40,000 --> 01:35:50,000
The routing logic uses the catalog to find the service by namespace.

401
01:35:50,000 --> 01:36:00,000
If the service is found, it extracts the team and owner from the service metadata.

402
01:36:00,000 --> 01:36:10,000
The team is used to route the alert to the correct Slack channel.

403
01:36:10,000 --> 01:36:20,000
The owner is used for email escalation if Slack is unavailable.

404
01:36:20,000 --> 01:36:30,000
[Types: const slackChannel = `#${team}-alerts`;]
▶ Pronounced as: "Now viewing the Slack channel derivation."

405
01:36:30,000 --> 01:36:40,000
The Slack channel is predictable: #${team}-alerts. This makes it easy to configure.

406
01:36:40,000 --> 01:36:50,000
If the team is unknown, the alert is sent to a default channel.

407
01:36:50,000 --> 01:37:00,000
[Types: const defaultChannel = '#platform-alerts';]
▶ Pronounced as: "Now viewing the default channel configuration."

408
01:37:00,000 --> 01:37:10,000
The default channel ensures that anomalies are never missed, even if the team is unknown.

409
01:37:10,000 --> 01:37:20,000
The routing logic also includes an escalation path.

410
01:37:20,000 --> 01:37:30,000
[Types: if (costIncrease > 500) {
  // Send email escalation to owner
  const email = service.spec?.owner?.replace('user:', '') + '@company.com';
  await sendEmail(email, `Cost anomaly detected for ${name}`, message);
}]
▶ Pronounced as: "Now viewing the email escalation logic."

411
01:37:30,000 --> 01:37:40,000
If the cost increase is greater than $500, an email is sent to the service owner.

412
01:37:40,000 --> 01:37:50,000
This ensures that large anomalies are escalated immediately.

413
01:37:50,000 --> 01:38:00,000
Now you understand the anomaly webhook routing. It ensures that alerts reach the right people.

414
01:38:00,000 --> 01:38:10,000
In the next segment, we do a workshop on viewing cost in the catalog.

415
01:38:10,000 --> 01:38:20,000
See you in Segment 21.
```

---

SEGMENT 21: Workshop: Viewing Cost in the Catalog
Timestamp: 100:00 – 105:00

```
416
01:40:00,000 --> 01:40:10,000
This is the first workshop for Series 10. We will view cost data in the catalog.

417
01:40:10,000 --> 01:40:20,000
Open Backstage and navigate to the financial-rag-agent service.

418
01:40:20,000 --> 01:40:30,000
On the overview page, you will see the FinOps cost card.

419
01:40:30,000 --> 01:40:40,000
[Types: open http://localhost:3000/catalog/default/component/financial-rag-agent]
▶ Pronounced as: "Now opening the financial-rag-agent service in the catalog."

420
01:40:40,000 --> 01:40:50,000
Now, look at the cost card. It shows the current month cost, trend, efficiency, and budget progress.

421
01:40:50,000 --> 01:41:00,000
If the cost card is not visible, check the annotations in catalog-info.yaml.

422
01:41:00,000 --> 01:41:10,000
[Types: cat catalog-info.yaml | grep -E "kubecost.com/namespace|finops/"]
▶ Pronounced as: "Now checking the annotations in catalog-info.yaml."

423
01:41:10,000 --> 01:41:20,000
The annotations should include kubecost.com/namespace and finops/monthly-budget.

424
01:41:20,000 --> 01:41:30,000
If these are missing, add them to catalog-info.yaml and push the change.

425
01:41:30,000 --> 01:41:40,000
Now navigate to the riskoracle service and view its cost card.

426
01:41:40,000 --> 01:41:50,000
Compare the cost and efficiency between the two services. Which one is more efficient?

427
01:41:50,000 --> 01:42:00,000
Now navigate to the FinOps dashboard at /finops.

428
01:42:00,000 --> 01:42:10,000
[Types: open http://localhost:3000/finops]
▶ Pronounced as: "Now opening the FinOps dashboard."

429
01:42:10,000 --> 01:42:20,000
Look at the total monthly spend and the team budget status.

430
01:42:20,000 --> 01:42:30,000
Which team is closest to exceeding its budget?

431
01:42:30,000 --> 01:42:40,000
Now generate a chargeback report for the current month.

432
01:42:40,000 --> 01:42:50,000
[Types: open http://localhost:3000/finops/chargeback]
▶ Pronounced as: "Now opening the chargeback report."

433
01:42:50,000 --> 01:43:00,000
Look at the breakdown by team and service. Which service is the most expensive?

434
01:43:00,000 --> 01:43:10,000
Download the CSV and open it in a spreadsheet.

435
01:43:10,000 --> 01:43:20,000
[Types: curl http://localhost:7007/api/finops/chargeback?format=csv -o chargeback.csv]
▶ Pronounced as: "Now downloading the chargeback report as CSV."

436
01:43:20,000 --> 01:43:30,000
Now you have viewed cost data in the catalog, dashboard, and chargeback report.

437
01:43:30,000 --> 01:43:40,000
In the next segment, we generate a chargeback report for finance.

438
01:43:40,000 --> 01:43:50,000
See you in Segment 22.
```

---

SEGMENT 22: Workshop: Generating a Chargeback Report
Timestamp: 105:00 – 110:00

```
439
01:45:00,000 --> 01:45:10,000
This is the second workshop. We will generate a chargeback report for finance.

440
01:45:10,000 --> 01:45:20,000
The chargeback report is a CSV file that can be imported into finance tools.

441
01:45:20,000 --> 01:45:30,000
Generate the report using the API endpoint.

442
01:45:30,000 --> 01:45:40,000
[Types: curl http://localhost:7007/api/finops/chargeback?format=csv -o chargeback-$(date +%Y-%m).csv]
▶ Pronounced as: "Now generating the chargeback report as CSV."

443
01:45:40,000 --> 01:45:50,000
Now open the CSV file in a spreadsheet.

444
01:45:50,000 --> 01:46:00,000
[Types: open chargeback-$(date +%Y-%m).csv]
▶ Pronounced as: "Now opening the CSV file."

445
01:46:00,000 --> 01:46:10,000
Review the data. Check that the team and service names are correct.

446
01:46:10,000 --> 01:46:20,000
If any team is missing, add the finops/team annotation to the service's catalog-info.yaml.

447
01:46:20,000 --> 01:46:30,000
If any service is missing, add kubecost.com/namespace annotation.

448
01:46:30,000 --> 01:46:40,000
Now generate a report for the previous month.

449
01:46:40,000 --> 01:46:50,000
[Types: curl http://localhost:7007/api/finops/chargeback?format=csv&month=last -o chargeback-last-month.csv]
▶ Pronounced as: "Now generating the previous month's chargeback report."

450
01:46:50,000 --> 01:47:00,000
Compare the current month and last month reports.

451
01:47:00,000 --> 01:47:10,000
Which teams increased their spend? Which teams decreased?

452
01:47:10,000 --> 01:47:20,000
Now automate the report generation using a cron job.

453
01:47:20,000 --> 01:47:30,000
[Types: crontab -e
# Add this line to run on the 1st of every month
0 0 1 * * curl http://localhost:7007/api/finops/chargeback?format=csv -o /finance/chargeback-$(date +\%Y-\%m).csv]
▶ Pronounced as: "Now adding a cron job to generate the chargeback report monthly."

454
01:47:30,000 --> 01:47:40,000
The report will be automatically generated and saved to the finance directory.

455
01:47:40,000 --> 01:47:50,000
Now you have generated a chargeback report for finance.

456
01:47:50,000 --> 01:48:00,000
In the next segment, we do the Q&A for Series 10.

457
01:48:00,000 --> 01:48:10,000
See you in Segment 23.
```

---

SEGMENT 23: Series 10 Q&A — Common Questions Answered
Timestamp: 110:00 – 115:00

```
458
01:50:00,000 --> 01:50:10,000
Welcome to the Series 10 Q&A. Let me answer the most common questions.

459
01:50:10,000 --> 01:50:20,000
Question 1: "I don't see the FinOps cost card in my catalog. What's wrong?"

460
01:50:20,000 --> 01:50:30,000
Check the annotations in catalog-info.yaml. The kubecost.com/namespace annotation must be set.

461
01:50:30,000 --> 01:50:40,000
Also verify that the FinOps backend plugin is running and the /cost endpoint is accessible.

462
01:50:40,000 --> 01:50:50,000
[Types: curl http://localhost:7007/api/finops/cost?namespace=financial-rag]
▶ Pronounced as: "Now testing the cost API endpoint."

463
01:50:50,000 --> 01:51:00,000
If the endpoint returns an error, check the kubecost baseUrl in app-config.yaml.

464
01:51:00,000 --> 01:51:10,000
Question 2: "Budget alerts are not being sent to Slack. How do I fix this?"

465
01:51:10,000 --> 01:51:20,000
Check the Slack token in app-config.yaml. It must be a valid Bot User OAuth Token.

466
01:51:20,000 --> 01:51:30,000
Verify that the team channel exists. The scheduler sends to #${team}-alerts.

467
01:51:30,000 --> 01:51:40,000
Check the logs for errors. The scheduler logs every attempt.

468
01:51:40,000 --> 01:51:50,000
[Types: kubectl logs -n backstage deployment/backstage-backend | grep "budget" | tail -20]
▶ Pronounced as: "Now checking the Backstage logs for budget scheduler errors."

469
01:51:50,000 --> 01:52:00,000
Question 3: "The cost data in the dashboard seems wrong. How do I verify it?"

470
01:52:00,000 --> 01:52:10,000
Query Kubecost directly to verify the data.

471
01:52:10,000 --> 01:52:20,000
[Types: curl http://localhost:9090/model/allocation?window=30d&aggregate=namespace]
▶ Pronounced as: "Now querying Kubecost directly."

472
01:52:20,000 --> 01:52:30,000
Compare the Kubecost output with the FinOps API output.

473
01:52:30,000 --> 01:52:40,000
If they match, the data is correct. If not, check the API implementation.

474
01:52:40,000 --> 01:52:50,000
Question 4: "How do I add a budget annotation to a service?"

475
01:52:50,000 --> 01:53:00,000
Add the finops/monthly-budget annotation to catalog-info.yaml.

476
01:53:00,000 --> 01:53:10,000
[Types: annotations:
  finops/monthly-budget: "15000"]
▶ Pronounced as: "Now viewing the budget annotation format."

477
01:53:10,000 --> 01:53:20,000
Commit and push the change. The scheduler will pick it up on the next run.

478
01:53:20,000 --> 01:53:30,000
Question 5: "Can I use a different alert destination instead of Slack?"

479
01:53:30,000 --> 01:53:40,000
Yes. The scheduler uses the Slack Web API, but you can replace it with any alerting system.

480
01:53:40,000 --> 01:53:50,000
Modify the scheduler to call your preferred alerting system. The architecture is modular.

481
01:53:50,000 --> 01:54:00,000
Question 6: "How often does the budget scheduler run?"

482
01:54:00,000 --> 01:54:10,000
The scheduler runs daily at 9 AM. This is configurable in the scheduler configuration.

483
01:54:10,000 --> 01:54:20,000
[Types: frequency: { cron: '0 9 * * *' }]
▶ Pronounced as: "Now viewing the scheduler frequency configuration."

484
01:54:20,000 --> 01:54:30,000
Change the cron expression to change the schedule.

485
01:54:30,000 --> 01:54:40,000
Question 7: "What is the cost increase threshold for anomaly alerts?"

486
01:54:40,000 --> 01:54:50,000
The threshold is $50. An anomaly is only alerted if the cost increase is at least $50.

487
01:54:50,000 --> 01:55:00,000
This prevents noise from small fluctuations.

488
01:55:00,000 --> 01:55:10,000
Question 8: "Can I see cost data for services that don't have the namespace annotation?"

489
01:55:10,000 --> 01:55:20,000
No. The namespace annotation is required. It tells the plugin which namespace to query.

490
01:55:20,000 --> 01:55:30,000
Add the annotation to enable cost tracking for a service.

491
01:55:30,000 --> 01:55:40,000
Now you have the answers to the most common questions about Series 10.

492
01:55:40,000 --> 01:55:50,000
In the next segment, we do the knowledge check and look ahead to Series 11.

493
01:55:50,000 --> 01:56:00,000
See you in Segment 24.
```

---

SEGMENT 24: Series 10 Knowledge Check & Next Steps
Timestamp: 115:00 – 120:00

```
494
01:55:00,000 --> 01:55:10,000
This is the knowledge check for Series 10.

495
01:55:10,000 --> 01:55:20,000
Let's test your understanding of the FinOps integration.

496
01:55:20,000 --> 01:55:30,000
Question 1: What annotation tells the FinOps plugin which namespace to query for cost data?

497
01:55:30,000 --> 01:55:40,000
Question 2: What annotation sets the monthly budget for a service?

498
01:55:40,000 --> 01:55:50,000
Question 3: Which endpoint does the FinOps cost card call to get cost data?

499
01:55:50,000 --> 01:56:00,000
Question 4: What does the budget scheduler do and when does it run?

500
01:56:00,000 --> 01:56:10,000
Question 5: How does the anomaly webhook route alerts to the correct team?

501
01:56:10,000 --> 01:56:20,000
Question 6: What format does the chargeback report support for finance integration?

502
01:56:20,000 --> 01:56:30,000
Question 7: What is the threshold for sending an anomaly alert?

503
01:56:30,000 --> 01:56:40,000
Question 8: How do you enable cost tracking for a service in the catalog?

504
01:56:40,000 --> 01:56:50,000
Pause the video. Write down your answers. Then compare them to what you learned.

505
01:56:50,000 --> 01:57:00,000
If you got all eight correct, you understand Series 10. If you missed any, review the relevant segment.

506
01:57:00,000 --> 01:57:10,000
Now let's look ahead to Series 11.

507
01:57:10,000 --> 01:57:20,000
Series 11 is the capstone. We validate every component we built.

508
01:57:20,000 --> 01:57:30,000
We run the final baseline update. We produce the CTO-ready report.

509
01:57:30,000 --> 01:57:40,000
And we deploy the monitoring infrastructure that keeps everything running correctly.

510
01:57:40,000 --> 01:57:50,000
Before Series 11, verify these four things.

511
01:57:50,000 --> 01:58:00,000
First: Verify the FinOps cost card appears in at least one catalog entity.

512
01:58:00,000 --> 01:58:10,000
Second: Verify the FinOps dashboard loads at /finops.

513
01:58:10,000 --> 01:58:20,000
Third: Verify the chargeback report generates correctly.

514
01:58:20,000 --> 01:58:30,000
[Types: curl http://localhost:7007/api/finops/chargeback?format=csv | head -10]
▶ Pronounced as: "Now verifying the chargeback report generation."

515
01:58:30,000 --> 01:58:40,000
Fourth: Verify the budget scheduler is running by checking the logs.

516
01:58:40,000 --> 01:58:50,000
[Types: kubectl logs -n backstage deployment/backstage-backend | grep "Budget check" | tail -5]
▶ Pronounced as: "Now checking the budget scheduler logs."

517
01:58:50,000 --> 01:59:00,000
If all four are verified, you are ready for Series 11.

518
01:59:00,000 --> 01:59:10,000
Series 10 is complete. FinOps is now visible to every developer in the portal.

519
01:59:10,000 --> 01:59:20,000
Every developer who opens the catalog sees cost. Every team receives budget alerts.

520
01:59:20,000 --> 01:59:30,000
Finance receives monthly chargeback reports. Anomalies are routed to service owners.

521
01:59:30,000 --> 01:59:40,000
The loop is closed. FinOps is part of the daily workflow.

522
01:59:40,000 --> 01:59:50,000
The commands work. The savings are real. You just have to do the work.

523
01:59:50,000 --> 02:00:00,000
See you in Series 11.
```