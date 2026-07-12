1
00:00:00,000 --> 00:00:06,000
Welcome to Phase 5. In Part 1, we build the API foundation.

2
00:00:06,000 --> 00:00:12,000
This is where our application becomes accessible to the outside world.
We create the Pydantic models, dependency injection, and the FastAPI server.

3
00:00:12,000 --> 00:00:18,000
Think of this as building the front door to our application. Every request
comes through here. Every response goes out through here.

4
00:00:18,000 --> 00:00:24,000
Open your editor and create `src/financial_rag/api/models.py`.

5
00:00:24,000 --> 00:00:30,000
We'll start with the imports. The __future__ import enables forward references.
[Types: from __future__ import annotations]

6
00:00:30,000 --> 00:00:36,000
We import StrEnum from enum for string-based enumerations.
[Types: from enum import StrEnum]

7
00:00:36,000 --> 00:00:42,000
We import Any from typing for generic type hints.
[Types: from typing import Any]

8
00:00:42,000 --> 00:00:48,000
We import BaseModel and Field from Pydantic for data validation.
[Types: from pydantic import BaseModel, Field]

9
00:00:48,000 --> 00:00:54,000
Now let's define the AnalysisStyle enum. This controls the analysis style.
[Types: class AnalysisStyle(StrEnum):]

10
00:00:54,000 --> 00:01:00,000
We define three styles. Analyst for detailed analysis.
[Types: ANALYST = "analyst"]

11
00:01:00,000 --> 00:01:06,000
Executive for concise, decision-ready insights.
[Types: EXECUTIVE = "executive"]

12
00:01:06,000 --> 00:01:12,000
And Risk for risk-focused assessment.
[Types: RISK = "risk"]

13
00:01:12,000 --> 00:01:18,000
Now let's define the SearchType enum. This controls the search strategy.
[Types: class SearchType(StrEnum):]

14
00:01:18,000 --> 00:01:24,000
Similarity search uses pure vector similarity.
[Types: SIMILARITY = "similarity"]

15
00:01:24,000 --> 00:01:30,000
MMR search balances relevance and diversity.
[Types: MMR = "mmr"]

16
00:01:30,000 --> 00:01:36,000
Hybrid search combines vector and text search.
[Types: HYBRID = "hybrid"]

17
00:01:36,000 --> 00:01:42,000
Now let's define the QueryRequest model. This is the request for the query endpoint.
[Types: class QueryRequest(BaseModel):]

18
00:01:42,000 --> 00:01:48,000
The question is required. It must be a non-empty string.
[Types: question: str = Field(..., description="The financial question to analyse")]

19
00:01:48,000 --> 00:01:54,000
The ticker is optional. It filters results to a specific company.
[Types: ticker: str | None = Field(default=None, description="Optional company ticker filter")]

20
00:01:54,000 --> 00:02:00,000
The filing_type is optional. It filters results to a specific SEC form type.
[Types: filing_type: str | None = Field(default=None, description="Optional filing type filter")]

21
00:02:00,000 --> 00:02:06,000
The fiscal_year is optional. It filters results to a specific year.
[Types: fiscal_year: int | None = Field(default=None, description="Optional fiscal year filter")]

22
00:02:06,000 --> 00:02:12,000
The analysis_style defaults to analyst. It controls the response style.
[Types: analysis_style: AnalysisStyle = Field(default=AnalysisStyle.ANALYST)]

23
00:02:12,000 --> 00:02:18,000
The search_type defaults to similarity. It controls the search strategy.
[Types: search_type: SearchType = Field(default=SearchType.SIMILARITY)]

24
00:02:18,000 --> 00:02:24,000
The limit is optional. It controls how many source documents to return.
[Types: limit: int | None = Field(default=None, ge=1, le=20)]

25
00:02:24,000 --> 00:02:30,000
We use ge=1 and le=20 to validate the limit is between 1 and 20.

26
00:02:30,000 --> 00:02:36,000
Now let's define the DocumentResponse model. This represents a source chunk.
[Types: class DocumentResponse(BaseModel):]

27
00:02:36,000 --> 00:02:42,000
The chunk_id identifies the chunk in the database.
[Types: chunk_id: str]

28
00:02:42,000 --> 00:02:48,000
The content is the actual text of the chunk.
[Types: content: str]

29
00:02:48,000 --> 00:02:54,000
The ticker identifies the company.
[Types: ticker: str]

30
00:02:54,000 --> 00:03:00,000
The filing_type identifies the SEC form type.
[Types: filing_type: str]

31
00:03:00,000 --> 00:03:06,000
The fiscal_year is the year of the filing.
[Types: fiscal_year: int | None]

32
00:03:06,000 --> 00:03:12,000
The section identifies where in the filing the chunk came from.
[Types: section: str | None]

33
00:03:12,000 --> 00:03:18,000
The score is the similarity score from the search.
[Types: score: float]

34
00:03:18,000 --> 00:03:24,000
The metrics are extracted financial metrics like revenue and EPS.
[Types: metrics: dict[str, Any] = {}]

35
00:03:24,000 --> 00:03:30,000
Now let's define the QueryResponse model. This is the response for the query endpoint.
[Types: class QueryResponse(BaseModel):]

36
00:03:30,000 --> 00:03:36,000
The question echoes back the user's question.
[Types: question: str]

37
00:03:36,000 --> 00:03:42,000
The answer is the generated response from the agent.
[Types: answer: str]

38
00:03:42,000 --> 00:03:48,000
The analysis_style indicates which style was used.
[Types: analysis_style: str]

39
00:03:48,000 --> 00:03:54,000
The search_type indicates which search strategy was used.
[Types: search_type: str]

40
00:03:54,000 --> 00:04:00,000
The agent_type indicates which agent generated the response.
[Types: agent_type: str]

41
00:04:00,000 --> 00:04:06,000
The latency_seconds is the response time in seconds.
[Types: latency_seconds: float]

42
00:04:06,000 --> 00:04:12,000
The source_documents are the chunks used to generate the answer.
[Types: source_documents: list[DocumentResponse] = []]

43
00:04:12,000 --> 00:04:18,000
The error field contains an error message if something went wrong.
[Types: error: str | None = None]

44
00:04:18,000 --> 00:04:24,000
Now let's define the IngestionRequest model. This is the request for ingestion.
[Types: class IngestionRequest(BaseModel):]

45
00:04:24,000 --> 00:04:30,000
The ticker is required. It identifies which company to ingest.
[Types: ticker: str = Field(..., description="Stock ticker symbol")]

46
00:04:30,000 --> 00:04:36,000
The filing_type defaults to 10-K. This is the most common filing.
[Types: filing_type: str = Field(default="10-K", description="SEC form type")]

47
00:04:36,000 --> 00:04:42,000
The years defaults to 2. It controls how many years of filings to ingest.
[Types: years: int = Field(default=2, ge=1, le=5, description="Years of filings to ingest")]

48
00:04:42,000 --> 00:04:48,000
Now let's define the IngestionResponse model. This is the response for ingestion.
[Types: class IngestionResponse(BaseModel):]

49
00:04:48,000 --> 00:04:54,000
The ticker identifies which company was ingested.
[Types: ticker: str]

50
00:04:54,000 --> 00:05:00,000
The filing_type identifies which form type was ingested.
[Types: filing_type: str]

51
00:05:00,000 --> 00:05:06,000
The filings_found indicates how many filings were found.
[Types: filings_found: int]

52
00:05:06,000 --> 00:05:12,000
The chunks_stored indicates how many chunks were stored.
[Types: chunks_stored: int]

53
00:05:12,000 --> 00:05:18,000
The success flag indicates if the ingestion succeeded.
[Types: success: bool]

54
00:05:18,000 --> 00:05:24,000
The skipped_duplicates indicates how many filings were skipped.
[Types: skipped_duplicates: int = 0]

55
00:05:24,000 --> 00:05:30,000
The error field contains an error message if something went wrong.
[Types: error: str | None = None]

56
00:05:30,000 --> 00:05:36,000
Now let's define the ServiceStatus model. This is a status check for a service.
[Types: class ServiceStatus(BaseModel):]

57
00:05:36,000 --> 00:05:42,000
The healthy flag indicates if the service is healthy.
[Types: healthy: bool]

58
00:05:42,000 --> 00:05:48,000
The details field contains additional information about the service.
[Types: details: dict[str, Any] = {}]

59
00:05:48,000 --> 00:05:54,000
Now let's define the HealthResponse model. This is the response for health checks.
[Types: class HealthResponse(BaseModel):]

60
00:05:54,000 --> 00:06:00,000
The status is "healthy", "degraded", or "unhealthy".
[Types: status: str]

61
00:06:00,000 --> 00:06:06,000
The version is the application version.
[Types: version: str]

62
00:06:06,000 --> 00:06:12,000
The services field maps service name to status.
[Types: services: dict[str, ServiceStatus]]

63
00:06:12,000 --> 00:06:18,000
Now let's define the StatsResponse model. This is the response for statistics.
[Types: class StatsResponse(BaseModel):]

64
00:06:18,000 --> 00:06:24,000
The ticker identifies which company the stats are for.
[Types: ticker: str | None]

65
00:06:24,000 --> 00:06:30,000
The total_chunks is the total number of chunks in the vector store.
[Types: total_chunks: int]

66
00:06:30,000 --> 00:06:36,000
The total_filings is the total number of filings in the database.
[Types: total_filings: int]

67
00:06:36,000 --> 00:06:42,000
The provider identifies the embedding provider in use.
[Types: provider: str]

68
00:06:42,000 --> 00:06:48,000
The dimensions is the embedding dimension size.
[Types: dimensions: int]

69
00:06:48,000 --> 00:06:54,000
This completes the models. Now create `src/financial_rag/api/dependencies.py`.

70
00:06:54,000 --> 00:07:00,000
This is Component #41. It provides dependency injection for the API routes.

71
00:07:00,000 --> 00:07:06,000
We'll start with the imports. The __future__ import enables forward references.
[Types: from __future__ import annotations]

72
00:07:06,000 --> 00:07:12,000
We import logging for structured logging.
[Types: import logging]

73
00:07:12,000 --> 00:07:18,000
We import Annotated from typing for type hints with dependencies.
[Types: from typing import Annotated]

74
00:07:18,000 --> 00:07:24,000
We import Depends from FastAPI for dependency injection.
[Types: from fastapi import Depends]

75
00:07:24,000 --> 00:07:30,000
We import QueryEngine from the retrieval module.
[Types: from financial_rag.retrieval.query_engine import QueryEngine]

76
00:07:30,000 --> 00:07:36,000
We import CacheClient and get_cache_client from storage.cache.
[Types: from financial_rag.storage.cache import CacheClient, get_cache_client]

77
00:07:36,000 --> 00:07:42,000
We import DatabaseClient and get_db_client from storage.database.
[Types: from financial_rag.storage.database import DatabaseClient, get_db_client]

78
00:07:42,000 --> 00:07:48,000
We import VectorStore from storage.vector_store.
[Types: from financial_rag.storage.vector_store import VectorStore]

79
00:07:48,000 --> 00:07:54,000
Now let's define the module-level singletons.
[Types: _query_engine: QueryEngine | None = None]
[Types: _vector_store: VectorStore | None = None]

80
00:07:54,000 --> 00:08:00,000
These are instantiated once at startup and reused per request.

81
00:08:00,000 --> 00:08:06,000
Now let's define the get_vector_store function. This returns the singleton.
[Types: def get_vector_store() -> VectorStore: global _vector_store if _vector_store is None: _vector_store = VectorStore() return _vector_store]

82
00:08:06,000 --> 00:08:12,000
This creates the VectorStore instance once and reuses it for all requests.

83
00:08:12,000 --> 00:08:18,000
Now let's define the get_query_engine function. This returns the singleton.
[Types: def get_query_engine() -> QueryEngine: global _query_engine if _query_engine is None: vs = get_vector_store() _query_engine = QueryEngine(vector_store=vs) return _query_engine]

84
00:08:18,000 --> 00:08:24,000
This creates the QueryEngine instance once and reuses it for all requests.

85
00:08:24,000 --> 00:08:30,000
Now let's define the FastAPI dependency functions.
[Types: async def db_client() -> DatabaseClient: return await get_db_client()]

86
00:08:30,000 --> 00:08:36,000
This is used with Depends() in route handlers.

87
00:08:36,000 --> 00:08:42,000
[Types: async def cache_client() -> CacheClient: return await get_cache_client()]

88
00:08:42,000 --> 00:08:48,000
[Types: async def query_engine() -> QueryEngine: return get_query_engine()]

89
00:08:48,000 --> 00:08:54,000
[Types: async def vector_store() -> VectorStore: return get_vector_store()]

90
00:08:54,000 --> 00:09:00,000
Now let's define the Annotated types for cleaner route signatures.
[Types: DBClient = Annotated[DatabaseClient, Depends(db_client)]]

91
00:09:00,000 --> 00:09:06,000
[Types: CacheClient_ = Annotated[CacheClient, Depends(cache_client)]]

92
00:09:06,000 --> 00:09:12,000
[Types: Engine = Annotated[QueryEngine, Depends(query_engine)]]

93
00:09:12,000 --> 00:09:18,000
[Types: Store = Annotated[VectorStore, Depends(vector_store)]]

94
00:09:18,000 --> 00:09:24,000
Now let's define initialise_dependencies. This is called at application startup.
[Types: async def initialise_dependencies() -> None: db = await get_db_client() await db.connect() logger.info("Database client connected") await db.verify_pgvector() cache = await get_cache_client() await cache.connect() logger.info("Cache client connected") get_vector_store() get_query_engine() logger.info("QueryEngine and VectorStore initialised")]

95
00:09:24,000 --> 00:09:30,000
This connects to the database, verifies pgvector, connects to Redis,
and pre-warms the singletons.

96
00:09:30,000 --> 00:09:36,000
Now let's define shutdown_dependencies. This is called at application shutdown.
[Types: async def shutdown_dependencies() -> None: db = await get_db_client() await db.disconnect() logger.info("Database client disconnected") cache = await get_cache_client() await cache.disconnect() logger.info("Cache client disconnected")]

97
00:09:36,000 --> 00:09:42,000
This closes all connections gracefully.

98
00:09:42,000 --> 00:09:48,000
Now create `src/financial_rag/api/server.py`. This is Component #40.

99
00:09:48,000 --> 00:09:54,000
We'll start with the imports. The __future__ import enables forward references.
[Types: from __future__ import annotations]

100
00:09:54,000 --> 00:10:00,000
We import logging for structured logging.
[Types: import logging]

101
00:10:00,000 --> 00:10:06,000
We import asynccontextmanager from contextlib for the lifespan context manager.
[Types: from contextlib import asynccontextmanager]

102
00:10:06,000 --> 00:10:12,000
We import TYPE_CHECKING for conditional imports.
[Types: from typing import TYPE_CHECKING]

103
00:10:12,000 --> 00:10:18,000
We import uvicorn for running the server.
[Types: import uvicorn]

104
00:10:18,000 --> 00:10:24,000
We import FastAPI from FastAPI.
[Types: from fastapi import FastAPI]

105
00:10:24,000 --> 00:10:30,000
We import CORSMiddleware for cross-origin requests.
[Types: from fastapi.middleware.cors import CORSMiddleware]

106
00:10:30,000 --> 00:10:36,000
We import the dependencies.
[Types: from financial_rag.api.dependencies import initialise_dependencies, shutdown_dependencies]

107
00:10:36,000 --> 00:10:42,000
We import the router from routes.
[Types: from financial_rag.api.routes import router]

108
00:10:42,000 --> 00:10:48,000
We import get_settings from config.
[Types: from financial_rag.config import get_settings]

109
00:10:48,000 --> 00:10:54,000
Now let's define the lifespan context manager.
[Types: @asynccontextmanager async def lifespan(app: FastAPI):]

110
00:10:54,000 --> 00:11:00,000
This replaces the deprecated on_event decorators.

111
00:11:00,000 --> 00:11:06,000
Inside the lifespan, we get settings and log the startup message.
[Types: settings = get_settings() logger.info("Starting %s v%s [%s]", settings.APP_NAME, settings.APP_VERSION, settings.APP_ENV)]

112
00:11:06,000 --> 00:11:12,000
We call initialise_dependencies to connect to all services.
[Types: await initialise_dependencies()]

113
00:11:12,000 --> 00:11:18,000
We log that the application is ready.
[Types: logger.info("Application ready — listening on %s:%d", settings.API_HOST, settings.API_PORT)]

114
00:11:18,000 --> 00:11:24,000
The yield is where the application runs.
[Types: yield]

115
00:11:24,000 --> 00:11:30,000
After the application shuts down, we call shutdown_dependencies.
[Types: logger.info("Shutting down %s...", settings.APP_NAME) await shutdown_dependencies() logger.info("Shutdown complete")]

116
00:11:30,000 --> 00:11:36,000
Now let's define the create_app function. This is the application factory.
[Types: def create_app() -> FastAPI:]

117
00:11:36,000 --> 00:11:42,000
We get settings.
[Types: settings = get_settings()]

118
00:11:42,000 --> 00:11:48,000
We create the FastAPI app with the lifespan context manager.
[Types: app = FastAPI(title="Financial RAG Analyst API", description="Production-grade financial analysis using RAG over SEC filings.", version=settings.APP_VERSION, docs_url="/docs" if settings.DEBUG else None, redoc_url="/redoc" if settings.DEBUG else None, openapi_url="/openapi.json" if settings.DEBUG else None, lifespan=lifespan)]

119
00:11:48,000 --> 00:11:54,000
We disable docs in production. This prevents API surface enumeration.

120
00:11:54,000 --> 00:12:00,000
Now we add CORS middleware.
[Types: app.add_middleware(CORSMiddleware, allow_origins=settings.CORS_ORIGINS_LIST, allow_credentials=True, allow_methods=["GET", "POST"], allow_headers=["*"])]

121
00:12:00,000 --> 00:12:06,000
We add the router.
[Types: app.include_router(router)]

122
00:12:06,000 --> 00:12:12,000
We add the root endpoint.
[Types: @app.get("/", include_in_schema=False) async def root() -> dict[str, str]: return {"service": settings.APP_NAME, "version": settings.APP_VERSION, "docs": "/docs" if settings.DEBUG else "disabled"}]

123
00:12:12,000 --> 00:12:18,000
We return the app.
[Types: return app]

124
00:12:18,000 --> 00:12:24,000
Now we create the module-level app instance.
[Types: app = create_app()]

125
00:12:24,000 --> 00:12:30,000
This is what uvicorn imports.

126
00:12:30,000 --> 00:12:36,000
Now let's define the main function. This is the development entrypoint.
[Types: def main() -> None: settings = get_settings() uvicorn.run("financial_rag.api.server:app", host=settings.API_HOST, port=settings.API_PORT, reload=settings.DEBUG, log_level="debug" if settings.DEBUG else "info", access_log=True)]

127
00:12:36,000 --> 00:12:42,000
This runs the server with the configured host and port.

128
00:12:42,000 --> 00:12:48,000
Now let's test our work. Start the API server.

129
00:12:48,000 --> 00:12:54,000
[Types: uvicorn financial_rag.api.server:app --reload --port 8000]

130
00:12:54,000 --> 00:13:00,000
Expected output: "Starting financial-rag-agent v0.1.0 [development]"

131
00:13:00,000 --> 00:13:06,000
"Database client connected". "pgvector extension verified". "Cache client connected".

132
00:13:06,000 --> 00:13:12,000
"QueryEngine and VectorStore initialised". "Application ready — listening on 0.0.0.0:8000".

133
00:13:12,000 --> 00:13:18,000
Test the health endpoint.
[Types: curl http://localhost:8000/health]

134
00:13:18,000 --> 00:13:24,000
Expected response: {"status": "healthy", "version": "0.1.0", "services": {"database": {"healthy": true}, "cache": {"healthy": true}}}

135
00:13:24,000 --> 00:13:30,000
Now let me recap what we've built in Part 1.

136
00:13:30,000 --> 00:13:36,000
We built the Pydantic models. QueryRequest, QueryResponse, DocumentResponse,
IngestionRequest, IngestionResponse, ServiceStatus, HealthResponse, StatsResponse.

137
00:13:36,000 --> 00:13:42,000
We built the dependencies. Singleton getters for VectorStore and QueryEngine.
FastAPI dependency functions. Annotated types for clean route signatures.

138
00:13:42,000 --> 00:13:48,000
We built the lifespan context manager. This handles startup and shutdown.
Everything before yield runs at startup. Everything after runs at shutdown.

139
00:13:48,000 --> 00:13:54,000
We built the application factory. This creates and configures the FastAPI app.
Docs are disabled in production. CORS is configured. The router is added.

140
00:13:54,000 --> 00:14:00,000
We tested the server. The health endpoint returns a healthy response.

141
00:14:00,000 --> 00:14:06,000
In Part 2, we'll build the middleware. API key auth, rate limiting,
request logging, and exception handling.

142
00:14:06,000 --> 00:14:12,000
Thank you for watching. I'll see you in Part 2.

143
00:14:12,000 --> 00:14:16,000
[End of Part 1]

1
00:00:00,000 --> 00:00:06,000
Welcome back to Phase 5. In Part 2, we build the API routes. This is where we
define the actual endpoints that our users will call.

2
00:00:06,000 --> 00:00:12,000
We have four main endpoints in this phase. /health for checking service status.
/query for answering financial questions. /ingest/sec for ingesting filings.
And /stats for getting vector store statistics.

3
00:00:12,000 --> 00:00:18,000
Think of routes as the front door to your application. Every request comes through
these routes. They validate the input, call the business logic, and return the response.

4
00:00:18,000 --> 00:00:24,000
Open your editor and create `src/financial_rag/api/routes.py`.

5
00:00:24,000 --> 00:00:30,000
We'll start with the imports. The __future__ import enables forward references.
[Types: from __future__ import annotations]

6
00:00:30,000 --> 00:00:36,000
We import logging for structured logging throughout the routes.
[Types: import logging]

7
00:00:36,000 --> 00:00:42,000
We import BackgroundTasks from FastAPI for running tasks asynchronously.
[Types: from fastapi import APIRouter, BackgroundTasks, HTTPException, status]

8
00:00:42,000 --> 00:00:48,000
We import Response from FastAPI for the metrics endpoint.
[Types: from fastapi.responses import Response]

9
00:00:48,000 --> 00:00:54,000
We import the dependencies for database, cache, and query engine.
[Types: from financial_rag.api.dependencies import Engine, Store]

10
00:00:54,000 --> 00:01:00,000
We import the Pydantic models for request and response validation.
[Types: from financial_rag.api.models import DocumentResponse, HealthResponse, IngestionRequest, IngestionResponse, QueryRequest, QueryResponse, ServiceStatus, StatsResponse]

11
00:01:00,000 --> 00:01:06,000
We import the HTMLParser for parsing SEC filing HTML.
[Types: from financial_rag.ingestion.parsers.html_parser import HTMLParser]

12
00:01:06,000 --> 00:01:12,000
We import the TextParser for cleaning extracted text.
[Types: from financial_rag.ingestion.parsers.text_parser import TextParser]

13
00:01:12,000 --> 00:01:18,000
We import the SECIngestor for downloading filings from EDGAR.
[Types: from financial_rag.ingestion.sec_ingestor import SECIngestor]

14
00:01:18,000 --> 00:01:24,000
We import the TextProcessor for chunking text into manageable pieces.
[Types: from financial_rag.processing.text_processor import TextProcessor]

15
00:01:24,000 --> 00:01:30,000
We import get_cache_client for accessing the Redis cache.
[Types: from financial_rag.storage.cache import get_cache_client]

16
00:01:30,000 --> 00:01:36,000
We import get_db_client for accessing the PostgreSQL database.
[Types: from financial_rag.storage.database import get_db_client]

17
00:01:36,000 --> 00:01:42,000
We import VectorStore for vector search operations.
[Types: from financial_rag.storage.vector_store import VectorStore]

18
00:01:42,000 --> 00:01:48,000
We import DuplicateFilingError for handling duplicate filing errors.
[Types: from financial_rag.utils.exceptions import DuplicateFilingError]

19
00:01:48,000 --> 00:01:54,000
We import record_query from the monitoring metrics module.
[Types: from financial_rag.monitoring.metrics import record_query]

20
00:01:54,000 --> 00:02:00,000
We import get_metrics_output from the monitoring metrics module.
[Types: from financial_rag.monitoring.metrics import get_metrics_output]

21
00:02:00,000 --> 00:02:06,000
Now let's create the APIRouter instance. This is our route registry.
[Types: router = APIRouter()]

22
00:02:06,000 --> 00:02:12,000
The router is like a collection of endpoints. We'll register all our routes on it.

23
00:02:12,000 --> 00:02:18,000
Now let's define the health endpoint. This is a GET request at /health.
[Types: @router.get("/health", response_model=HealthResponse, summary="Health check", tags=["ops"])]

24
00:02:18,000 --> 00:02:24,000
We use the @router.get decorator to register this as a GET endpoint.
The response_model tells FastAPI to validate the response against HealthResponse.

25
00:02:24,000 --> 00:02:30,000
The summary and tags are for OpenAPI documentation. The ops tag groups
operational endpoints together.

26
00:02:30,000 --> 00:02:36,000
Now let's define the handler function.
[Types: async def health_check() -> HealthResponse:]

27
00:02:36,000 --> 00:02:42,000
We import get_settings inside the function to get the current settings.
[Types: from financial_rag.config import get_settings settings = get_settings()]

28
00:02:42,000 --> 00:02:48,000
We create a ServiceStatus for the database with healthy set to False initially.
[Types: db_status = ServiceStatus(healthy=False)]

29
00:02:48,000 --> 00:02:54,000
We create a ServiceStatus for the cache with healthy set to False initially.
[Types: cache_status = ServiceStatus(healthy=False)]

30
00:02:54,000 --> 00:03:00,000
We probe the database connection.
[Types: try: db = await get_db_client() db_info = await db.health_check() db_status = ServiceStatus(healthy=True, details=db_info)]

31
00:03:00,000 --> 00:03:06,000
If the database is reachable, we set healthy to True and include the details.
[Types: except Exception as exc: db_status = ServiceStatus(healthy=False, details={"error": str(exc)})]

32
00:03:06,000 --> 00:03:12,000
If the database connection fails, we capture the error in the details.

33
00:03:12,000 --> 00:03:18,000
We probe the cache connection.
[Types: try: cache = await get_cache_client() cache_info = await cache.health_check() cache_status = ServiceStatus(healthy=True, details=cache_info)]

34
00:03:18,000 --> 00:03:24,000
If the cache is reachable, we set healthy to True and include the details.
[Types: except Exception as exc: cache_status = ServiceStatus(healthy=False, details={"error": str(exc)})]

35
00:03:24,000 --> 00:03:30,000
If the cache connection fails, we capture the error in the details.

36
00:03:30,000 --> 00:03:36,000
We determine the overall status. If the database is down, the service is unhealthy.
[Types: if not db_status.healthy: overall = "unhealthy"]

37
00:03:36,000 --> 00:03:42,000
If the database is healthy but the cache is down, the service is degraded.
[Types: elif not cache_status.healthy: overall = "degraded"]

38
00:03:42,000 --> 00:03:48,000
If both are healthy, the service is healthy.
[Types: else: overall = "healthy"]

39
00:03:48,000 --> 00:03:54,000
We return the HealthResponse with the status, version, and service details.
[Types: return HealthResponse(status=overall, version=settings.APP_VERSION, services={"database": db_status, "cache": cache_status})]

40
00:03:54,000 --> 00:04:00,000
Now let's define the query endpoint. This is a POST request at /query.
[Types: @router.post("/query", response_model=QueryResponse, summary="Financial RAG query", tags=["query"])]

41
00:04:00,000 --> 00:04:06,000
The query endpoint handles financial questions. It takes a QueryRequest and
returns a QueryResponse.

42
00:04:06,000 --> 00:04:12,000
Now let's define the handler function.
[Types: async def query(request: QueryRequest, engine: Engine) -> QueryResponse:]

43
00:04:12,000 --> 00:04:18,000
We call the query engine with the request parameters.
[Types: result = await engine.query(request.question, ticker=request.ticker, filing_type=request.filing_type, fiscal_year=request.fiscal_year, analysis_style=request.analysis_style.value, search_type=request.search_type.value, limit=request.limit)]

44
00:04:18,000 --> 00:04:24,000
The engine handles the entire RAG pipeline. Retrieval, context assembly, and LLM generation.

45
00:04:24,000 --> 00:04:30,000
Now we record Prometheus metrics for monitoring.
[Types: try: import time as _time _t0 = _time.monotonic() record_query(analysis_style=request.analysis_style.value, search_type=request.search_type.value, agent_type=result.agent_type, latency_seconds=result.latency_seconds, success=result.error is None, error_type=type(result.error).__name__ if result.error else None) except Exception: pass]

46
00:04:30,000 --> 00:04:36,000
The record_query function tracks metrics like query count, latency, and error rate.
This data is used for monitoring dashboards and SLO tracking.

47
00:04:36,000 --> 00:04:42,000
Now we write to the analysis_history table for audit purposes.
[Types: try: from financial_rag.storage.repositories.analysis import AnalysisRepository db = await get_db_client() async with db.session() as session: repo = AnalysisRepository(session) await repo.record(question=request.question, answer=result.answer, agent_type=result.agent_type, latency_ms=result.latency_ms, ticker=request.ticker, analysis_style=result.analysis_style, search_type=result.search_type, source_chunk_ids=[r.chunk_id for r in result.source_documents], error=result.error) except Exception as exc: logger.warning("Failed to write analysis_history (non-fatal): %s", exc)]

48
00:04:42,000 --> 00:04:48,000
The analysis_history table is an audit trail. It records every query and response.
This is essential for debugging, compliance, and quality monitoring.

49
00:04:48,000 --> 00:04:54,000
If writing to the history fails, we log a warning but continue. This is non-fatal.
The query response is still returned to the user.

50
00:04:54,000 --> 00:05:00,000
We convert the source documents to DocumentResponse objects.
[Types: source_docs = [DocumentResponse(chunk_id=r.chunk_id, content=r.chunk_text, ticker=r.ticker, filing_type=r.filing_type, fiscal_year=r.fiscal_year, section=r.section, score=r.score, metrics=r.metrics) for r in result.source_documents]]

51
00:05:00,000 --> 00:05:06,000
Each document includes the chunk ID, content, ticker, filing type, year, section, score, and metrics.

52
00:05:06,000 --> 00:05:12,000
If there was an error and no answer, we raise an HTTP exception.
[Types: if result.error and not result.answer: raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=result.error)]

53
00:05:12,000 --> 00:05:18,000
This ensures the user gets a clear error message when the system fails.

54
00:05:18,000 --> 00:05:24,000
We return the QueryResponse with all the data.
[Types: return QueryResponse(question=result.question, answer=result.answer, analysis_style=result.analysis_style, search_type=result.search_type, agent_type=result.agent_type, latency_seconds=result.latency_seconds, source_documents=source_docs, error=result.error)]

55
00:05:24,000 --> 00:05:30,000
Now let's define the ingestion endpoint. This is a POST request at /ingest/sec.
[Types: @router.post("/ingest/sec", response_model=IngestionResponse, status_code=status.HTTP_202_ACCEPTED, summary="Ingest SEC filings", tags=["ingestion"])]

56
00:05:30,000 --> 00:05:36,000
The ingestion endpoint triggers the SEC filing ingestion pipeline.
It returns 202 Accepted because the ingestion runs in the background.

57
00:05:36,000 --> 00:05:42,000
Now let's define the handler function.
[Types: async def ingest_sec(request: IngestionRequest, background_tasks: BackgroundTasks, store: Store) -> IngestionResponse:]

58
00:05:42,000 --> 00:05:48,000
We add the ingestion task to the background tasks.
[Types: background_tasks.add_task(_ingest_background, ticker=request.ticker, filing_type=request.filing_type, years=request.years, store=store)]

59
00:05:48,000 --> 00:05:54,000
The background task runs asynchronously. The API returns immediately.
This prevents the API from timing out on long-running ingestion jobs.

60
00:05:54,000 --> 00:06:00,000
We return a response with success set to True.
[Types: return IngestionResponse(ticker=request.ticker.upper(), filing_type=request.filing_type, filings_found=0, chunks_stored=0, success=True, error=None)]

61
00:06:00,000 --> 00:06:06,000
The actual counts will be updated in the background task.

62
00:06:06,000 --> 00:06:12,000
Now let's define the background ingestion function. This is the actual ingestion pipeline.
[Types: async def _ingest_background(*, ticker: str, filing_type: str, years: int, store: VectorStore) -> None:]

63
00:06:12,000 --> 00:06:18,000
We get the settings instance.
[Types: from financial_rag.config import get_settings settings = get_settings()]

64
00:06:18,000 --> 00:06:24,000
We normalize the ticker to uppercase.
[Types: ticker = ticker.upper()]

65
00:06:24,000 --> 00:06:30,000
We create the parser instances.
[Types: html_parser = HTMLParser() text_parser = TextParser() processor = TextProcessor()]

66
00:06:30,000 --> 00:06:36,000
We log the start of the ingestion.
[Types: logger.info("Background ingestion started — ticker=%s type=%s years=%d", ticker, filing_type, years)]

67
00:06:36,000 --> 00:06:42,000
We initialize counters for tracking progress.
[Types: total_chunks = 0 total_filings = 0 skipped = 0]

68
00:06:42,000 --> 00:06:48,000
We create the SECIngestor in a context manager.
[Types: try: async with SECIngestor() as ingestor:]

69
00:06:48,000 --> 00:06:54,000
We list the filings for the ticker.
[Types: filings = await ingestor.list_filings(ticker, filing_type, years=years) total_filings = len(filings)]

70
00:06:54,000 --> 00:07:00,000
We create the raw data directory.
[Types: raw_dir = settings.RAW_DATA_DIR / ticker / filing_type raw_dir.mkdir(parents=True, exist_ok=True)]

71
00:07:00,000 --> 00:07:06,000
We iterate over each filing metadata.
[Types: for meta in filings:]

72
00:07:06,000 --> 00:07:12,000
We download the filing content.
[Types: try: raw_html, file_hash = await ingestor.download_filing(meta, raw_dir=raw_dir)]

73
00:07:12,000 --> 00:07:18,000
If download fails, we log the error and continue.
[Types: except Exception as exc: logger.error("Failed to download %s FY%s: %s", meta.filing_type, meta.fiscal_year, exc) continue]

74
00:07:18,000 --> 00:07:24,000
We parse the HTML into sections.
[Types: parsed = html_parser.parse(raw_html, ticker=ticker, filing_type=filing_type, fiscal_year=meta.fiscal_year)]

75
00:07:24,000 --> 00:07:30,000
We clean the text in each section.
[Types: for section in parsed.sections: section.text = text_parser.clean(section.text)]

76
00:07:30,000 --> 00:07:36,000
We generate a placeholder filing ID.
[Types: import uuid placeholder_filing_id = uuid.uuid4()]

77
00:07:36,000 --> 00:07:42,000
We chunk the parsed filing.
[Types: chunks = processor.process(parsed, meta, placeholder_filing_id)]

78
00:07:42,000 --> 00:07:48,000
We ingest the chunks into the vector store.
[Types: try: _, stored = await store.ingest(chunks, meta, file_hash) total_chunks += stored logger.info("Ingested %s FY%s — %d chunks", ticker, meta.fiscal_year, stored)]

79
00:07:48,000 --> 00:07:54,000
If the filing is a duplicate, we skip it and increment the skipped counter.
[Types: except DuplicateFilingError: skipped += 1 logger.info("Skipped duplicate — %s FY%s hash=%s", ticker, meta.fiscal_year, file_hash[:12])]

80
00:07:54,000 --> 00:08:00,000
We log the completion of the ingestion.
[Types: logger.info("Background ingestion complete — ticker=%s filings=%d chunks=%d skipped=%d", ticker, total_filings, total_chunks, skipped)]

81
00:08:00,000 --> 00:08:06,000
If the ingestion fails, we log the error.
[Types: except Exception as exc: logger.error("Background ingestion failed — ticker=%s error=%s", ticker, exc, exc_info=True)]

82
00:08:06,000 --> 00:08:12,000
Now let's define the stats endpoints. These are GET requests.
[Types: @router.get("/stats", response_model=StatsResponse, summary="Global vector store statistics", tags=["ops"])]

83
00:08:12,000 --> 00:08:18,000
The global stats endpoint returns aggregate statistics across all filings.
[Types: async def global_stats(store: Store) -> StatsResponse: stats = await store.stats() return StatsResponse(**stats)]

84
00:08:18,000 --> 00:08:24,000
We call store.stats() with no ticker to get global statistics.

85
00:08:24,000 --> 00:08:30,000
Now let's define the per-ticker stats endpoint.
[Types: @router.get("/stats/{ticker}", response_model=StatsResponse, summary="Per-ticker statistics", tags=["ops"])]

86
00:08:30,000 --> 00:08:36,000
[Types: async def ticker_stats(ticker: str, store: Store) -> StatsResponse: stats = await store.stats(ticker=ticker.upper()) return StatsResponse(**stats)]

87
00:08:36,000 --> 00:08:42,000
This endpoint returns statistics for a specific ticker.

88
00:08:42,000 --> 00:08:48,000
Now let's define the metrics endpoint. This is a GET request at /metrics.
[Types: @router.get("/metrics", include_in_schema=False, tags=["ops"])]

89
00:08:48,000 --> 00:08:54,000
The metrics endpoint returns Prometheus metrics for scraping.
[Types: async def metrics() -> Response: data, content_type = get_metrics_output() return Response(content=data, media_type=content_type)]

90
00:08:54,000 --> 00:09:00,000
We include_in_schema=False so this endpoint doesn't appear in the OpenAPI docs.

91
00:09:00,000 --> 00:09:06,000
Now let me recap what we've built in Part 2.

92
00:09:06,000 --> 00:09:12,000
We built the health endpoint. It checks database and cache connectivity and returns
the overall service status.

93
00:09:12,000 --> 00:09:18,000
We built the query endpoint. It handles financial questions through the RAG pipeline.
It records metrics and writes to the audit trail.

94
00:09:18,000 --> 00:09:24,000
We built the ingestion endpoint. It triggers SEC filing ingestion in the background.
It returns immediately with a 202 Accepted status.

95
00:09:24,000 --> 00:09:30,000
We built the background ingestion function. It downloads filings, parses them,
chunks them, and stores them in the vector store.

96
00:09:30,000 --> 00:09:36,000
We built the stats endpoints. They return global and per-ticker statistics.

97
00:09:36,000 --> 00:09:42,000
We built the metrics endpoint. It returns Prometheus metrics for monitoring.

98
00:09:42,000 --> 00:09:48,000
In Part 3, we'll build the middleware. This handles logging, rate limiting,
authentication, and error handling.

99
00:09:48,000 --> 00:09:54,000
Thank you for watching. I'll see you in Part 3.

100
00:09:54,000 --> 00:09:58,000
[End of Part 2]

1
00:00:00,000 --> 00:00:06,000
Welcome back to Phase 5. In Part 3, we build the API middleware.

2
00:00:06,000 --> 00:00:12,000
Middleware is code that runs before and after every request. It handles logging,
rate limiting, authentication, and error handling.

3
00:00:12,000 --> 00:00:18,000
Think of middleware like airport security. Every passenger goes through the
same checks. Metal detector. ID verification. Baggage scan.

4
00:00:18,000 --> 00:00:24,000
Open your editor and create `src/financial_rag/api/middleware.py`.

5
00:00:24,000 --> 00:00:30,000
We'll start with the imports. The __future__ import enables forward references.
[Types: from __future__ import annotations]

6
00:00:30,000 --> 00:00:36,000
We import logging for structured logging.
[Types: import logging]

7
00:00:36,000 --> 00:00:42,000
We import time for measuring request duration.
[Types: import time]

8
00:00:42,000 --> 00:00:48,000
We import uuid for generating request IDs.
[Types: import uuid]

9
00:00:48,000 --> 00:00:54,000
We import FastAPI and Request for type hints.
[Types: from fastapi import FastAPI, Request, status]

10
00:00:54,000 --> 00:01:00,000
We import JSONResponse for structured error responses.
[Types: from fastapi.responses import JSONResponse]

11
00:01:00,000 --> 00:01:06,000
We import Limiter and the rate limit exceeded handler from slowapi.
[Types: from slowapi import Limiter, _rate_limit_exceeded_handler]

12
00:01:06,000 --> 00:01:12,000
We import RateLimitExceeded for handling rate limit errors.
[Types: from slowapi.errors import RateLimitExceeded]

13
00:01:12,000 --> 00:01:18,000
We import get_remote_address for extracting client IP.
[Types: from slowapi.util import get_remote_address]

14
00:01:18,000 --> 00:01:24,000
We import BaseHTTPMiddleware and RequestResponseEndpoint from Starlette.
[Types: from starlette.middleware.base import BaseHTTPMiddleware, RequestResponseEndpoint]

15
00:01:24,000 --> 00:01:30,000
We import Response from Starlette.
[Types: from starlette.responses import Response]

16
00:01:30,000 --> 00:01:36,000
We import get_settings from the config module.
[Types: from financial_rag.config import get_settings]

17
00:01:36,000 --> 00:01:42,000
Now let's define the rate limiter. This is the global limiter instance.
[Types: limiter = Limiter(key_func=get_remote_address, default_limits=["100/minute"])]

18
00:01:42,000 --> 00:01:48,000
The key_func is get_remote_address. This identifies the client by IP address.
The default_limits is 100 requests per minute.

19
00:01:48,000 --> 00:01:54,000
Now let's define the configure_limiter function.
[Types: def configure_limiter(app: FastAPI) -> None:]

20
00:01:54,000 --> 00:02:00,000
We get the settings instance.
[Types: settings = get_settings()]

21
00:02:00,000 --> 00:02:06,000
We initialize storage_uri to None. This defaults to in-memory storage.
[Types: storage_uri: str | None = None]

22
00:02:06,000 --> 00:02:12,000
If we're in production and Redis is configured, we use Redis.
[Types: if settings.APP_ENV == "production" and settings.REDIS_URL.get_secret_value(): storage_uri = settings.REDIS_URL.get_secret_value() logger.info("Rate limiter: Redis backend at %s", settings.REDIS_HOST)]

23
00:02:12,000 --> 00:02:18,000
Redis provides distributed rate limiting across multiple pods. Without it,
each pod tracks limits independently.

24
00:02:18,000 --> 00:02:24,000
If not in production, we use in-memory storage.
[Types: else: logger.info("Rate limiter: in-memory backend (dev/test)")]

25
00:02:24,000 --> 00:02:30,000
We create a new Limiter instance with the storage URI.
[Types: global limiter limiter = Limiter(key_func=get_remote_address, default_limits=["100/minute"], storage_uri=storage_uri)]

26
00:02:30,000 --> 00:02:36,000
We store the limiter on the app state.
[Types: app.state.limiter = limiter]

27
00:02:36,000 --> 00:02:42,000
We add the rate limit exceeded handler.
[Types: app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)]

28
00:02:42,000 --> 00:02:48,000
Now let's define the RequestLoggingMiddleware.
[Types: class RequestLoggingMiddleware(BaseHTTPMiddleware):]

29
00:02:48,000 --> 00:02:54,000
The dispatch method is called for every request.
[Types: async def dispatch(self, request: Request, call_next: RequestResponseEndpoint) -> Response:]

30
00:02:54,000 --> 00:03:00,000
We generate a unique request ID.
[Types: request_id = str(uuid.uuid4())]

31
00:03:00,000 --> 00:03:06,000
We record the start time for latency measurement.
[Types: t0 = time.monotonic()]

32
00:03:06,000 --> 00:03:12,000
We store the request ID on the request state.
[Types: request.state.request_id = request_id]

33
00:03:12,000 --> 00:03:18,000
We log the start of the request.
[Types: logger.info("request_start", extra={"request_id": request_id, "method": request.method, "path": request.url.path, "client_ip": request.client.host if request.client else "unknown"})]

34
00:03:18,000 --> 00:03:24,000
We call the next middleware or route handler.
[Types: try: response = await call_next(request)]

35
00:03:24,000 --> 00:03:30,000
If an exception occurs, we log it and re-raise.
[Types: except Exception as exc: logger.error("request_error", extra={"request_id": request_id, "error": str(exc)}) raise]

36
00:03:30,000 --> 00:03:36,000
We calculate the processing time in milliseconds.
[Types: process_ms = int((time.monotonic() - t0) * 1000)]

37
00:03:36,000 --> 00:03:42,000
We add the request ID to the response headers.
[Types: response.headers["X-Request-ID"] = request_id]

38
00:03:42,000 --> 00:03:48,000
We add the processing time to the response headers.
[Types: response.headers["X-Process-Time"] = f"{process_ms}ms"]

39
00:03:48,000 --> 00:03:54,000
We log the completion of the request.
[Types: logger.info("request_complete", extra={"request_id": request_id, "status_code": response.status_code, "process_ms": process_ms})]

40
00:03:54,000 --> 00:04:00,000
We return the response.
[Types: return response]

41
00:04:00,000 --> 00:04:06,000
Now let's define the APIKeyMiddleware.
[Types: class APIKeyMiddleware(BaseHTTPMiddleware):]

42
00:04:06,000 --> 00:04:12,000
We define exempt paths that don't require an API key.
[Types: EXEMPT_PATHS = frozenset({"/health", "/docs", "/redoc", "/openapi.json", "/"})]

43
00:04:12,000 --> 00:04:18,000
These paths are always accessible. This is standard for health checks.

44
00:04:18,000 --> 00:04:24,000
The dispatch method is called for every request.
[Types: async def dispatch(self, request: Request, call_next: RequestResponseEndpoint) -> Response:]

45
00:04:24,000 --> 00:04:30,000
We get the settings instance.
[Types: settings = get_settings()]

46
00:04:30,000 --> 00:04:36,000
If API key auth is disabled, we skip authentication.
[Types: if not settings.API_KEY_ENABLED or request.url.path in self.EXEMPT_PATHS: return await call_next(request)]

47
00:04:36,000 --> 00:04:42,000
We extract the API key from the X-API-Key header.
[Types: api_key = request.headers.get("X-API-Key")]

48
00:04:42,000 --> 00:04:48,000
We get the expected key from settings.
[Types: expected = settings.API_KEY.get_secret_value() if settings.API_KEY else None]

49
00:04:48,000 --> 00:04:54,000
If there's no expected key, we skip authentication.
[Types: if not expected: return await call_next(request)]

50
00:04:54,000 --> 00:05:00,000
If the API key doesn't match, we return 401 Unauthorized.
[Types: if api_key != expected: return JSONResponse(status_code=status.HTTP_401_UNAUTHORIZED, content={"type": "about:blank", "title": "Unauthorized", "status": 401, "detail": "Invalid or missing API key. Pass X-API-Key header.", "instance": request.url.path})]

51
00:05:00,000 --> 00:05:06,000
If the key is valid, we proceed.
[Types: return await call_next(request)]

52
00:05:06,000 --> 00:05:12,000
Now let's define the exception handlers.
[Types: def register_exception_handlers(app: FastAPI) -> None:]

53
00:05:12,000 --> 00:05:18,000
We handle unhandled exceptions and return 500.
[Types: @app.exception_handler(Exception) async def unhandled_exception_handler(request: Request, exc: Exception) -> JSONResponse: request_id = getattr(request.state, "request_id", "unknown") logger.error("unhandled_exception", extra={"request_id": request_id, "error": str(exc)}, exc_info=True) return JSONResponse(status_code=500, content={"type": "about:blank", "title": "Internal Server Error", "status": 500, "detail": "An unexpected error occurred.", "instance": request.url.path, "request_id": request_id})]

54
00:05:18,000 --> 00:05:24,000
This handler catches any unhandled exception and returns a structured response.

55
00:05:24,000 --> 00:05:30,000
We handle ValueError exceptions and return 422.
[Types: @app.exception_handler(ValueError) async def value_error_handler(request: Request, exc: ValueError) -> JSONResponse: request_id = getattr(request.state, "request_id", "unknown") return JSONResponse(status_code=422, content={"type": "about:blank", "title": "Validation Error", "status": 422, "detail": str(exc), "instance": request.url.path, "request_id": request_id})]

56
00:05:30,000 --> 00:05:36,000
ValueError is raised for validation errors. This catches them and returns
a proper response.

57
00:05:36,000 --> 00:05:42,000
This is the complete middleware file. One file. All middleware. No duplicates.

58
00:05:42,000 --> 00:05:48,000
Now let me recap what we've built in Part 3.

59
00:05:48,000 --> 00:05:54,000
We built the rate limiter with Redis support. It limits requests to 100 per minute.

60
00:05:54,000 --> 00:06:00,000
We built the RequestLoggingMiddleware. It logs every request with a unique ID.

61
00:06:00,000 --> 00:06:06,000
We built the APIKeyMiddleware. It enforces API key authentication.

62
00:06:06,000 --> 00:06:12,000
We built exception handlers. They return structured RFC 7807 Problem Details.

63
00:06:12,000 --> 00:06:18,000
In Part 4, we'll build the metrics module and integrate everything into server.py.

64
00:06:18,000 --> 00:06:24,000
Thank you for watching. I'll see you in Part 4.

65
00:06:24,000 --> 00:06:28,000
[End of Part 3]
1
00:00:00,000 --> 00:00:06,000
Welcome back to Phase 5. In Part 4, we build the Prometheus metrics module.

2
00:00:06,000 --> 00:00:12,000
This is where we expose application metrics for monitoring. Prometheus scrapes
these metrics and Grafana visualizes them.

3
00:00:12,000 --> 00:00:18,000
Think of metrics like the dashboard of a car. Speed, temperature, fuel level.
You need to know what's happening while you're driving.

4
00:00:18,000 --> 00:00:24,000
Open your editor and create `src/financial_rag/monitoring/metrics.py`.

5
00:00:24,000 --> 00:00:30,000
We'll start with the imports. The __future__ import enables forward references.
[Types: from __future__ import annotations]

6
00:00:30,000 --> 00:00:36,000
We import Counter, Gauge, Histogram for metric types from prometheus_client.
[Types: from prometheus_client import CONTENT_TYPE_LATEST, Counter, Gauge, Histogram, generate_latest]

7
00:00:36,000 --> 00:00:42,000
CONTENT_TYPE_LATEST is the correct content type for Prometheus metrics.
generate_latest produces the metrics in the correct format.

8
00:00:42,000 --> 00:00:48,000
Now let's define our metrics. We'll start with query metrics.

9
00:00:48,000 --> 00:00:54,000
QUERY_TOTAL counts the total number of RAG queries.
[Types: QUERY_TOTAL = Counter("finrag_query_total", "Total number of RAG queries", ["analysis_style", "search_type", "agent_type", "status"])]

10
00:00:54,000 --> 00:01:00,000
This counter tracks queries by analysis style, search type, agent type, and status.
Status can be "success" or "error".

11
00:01:00,000 --> 00:01:06,000
QUERY_LATENCY measures query duration in seconds.
[Types: QUERY_LATENCY = Histogram("finrag_query_latency_seconds", "Query latency in seconds", ["analysis_style", "search_type"], buckets=[0.1, 0.25, 0.5, 1.0, 2.5, 5.0, 10.0, 30.0])]

12
00:01:06,000 --> 00:01:12,000
The buckets define the histogram bins. We measure from 100ms to 30 seconds.
This gives us detailed latency distribution.

13
00:01:12,000 --> 00:01:18,000
QUERY_ERRORS tracks the number of query errors by error type.
[Types: QUERY_ERRORS = Counter("finrag_query_errors_total", "Total number of query errors", ["error_type"])]

14
00:01:18,000 --> 00:01:24,000
This helps us understand what types of errors are occurring.

15
00:01:24,000 --> 00:01:30,000
CHUNKS_TOTAL shows the total number of chunks in the vector store.
[Types: CHUNKS_TOTAL = Gauge("finrag_chunks_total", "Total number of chunks in vector store", ["ticker"])]

16
00:01:30,000 --> 00:01:36,000
This gauge tracks the size of our vector store by ticker.

17
00:01:36,000 --> 00:01:42,000
FILINGS_TOTAL shows the total number of filings ingested.
[Types: FILINGS_TOTAL = Gauge("finrag_filings_total", "Total number of filings ingested", ["ticker", "filing_type"])]

18
00:01:42,000 --> 00:01:48,000
This tracks ingestion progress by ticker and filing type.

19
00:01:48,000 --> 00:01:54,000
INGESTION_TOTAL counts the number of ingestion jobs.
[Types: INGESTION_TOTAL = Counter("finrag_ingestion_total", "Total number of ingestion jobs", ["ticker", "filing_type", "status"])]

20
00:01:54,000 --> 00:02:00,000
Status can be "success" or "error". This tracks ingestion reliability.

21
00:02:00,000 --> 00:02:06,000
INGESTION_LATENCY measures ingestion job duration.
[Types: INGESTION_LATENCY = Histogram("finrag_ingestion_latency_seconds", "Ingestion job latency in seconds", ["ticker"], buckets=[1.0, 5.0, 10.0, 30.0, 60.0, 120.0, 300.0])]

22
00:02:06,000 --> 00:02:12,000
Ingestion can take several minutes. The buckets go up to 300 seconds (5 minutes).

23
00:02:12,000 --> 00:02:18,000
CACHE_HITS tracks the number of cache hits.
[Types: CACHE_HITS = Counter("finrag_cache_hits_total", "Total Redis cache hits")]

24
00:02:18,000 --> 00:02:24,000
CACHE_MISSES tracks the number of cache misses.
[Types: CACHE_MISSES = Counter("finrag_cache_misses_total", "Total Redis cache misses")]

25
00:02:24,000 --> 00:02:30,000
These help us understand cache effectiveness. A high miss rate means we need
to adjust our caching strategy.

26
00:02:30,000 --> 00:02:36,000
Now let's define the record_query function. This records query metrics.
[Types: def record_query(*, analysis_style: str, search_type: str, agent_type: str, latency_seconds: float, success: bool, error_type: str | None = None,) -> None:]

27
00:02:36,000 --> 00:02:42,000
We determine the status based on success.
[Types: status = "success" if success else "error"]

28
00:02:42,000 --> 00:02:48,000
We increment the QUERY_TOTAL counter with labels.
[Types: QUERY_TOTAL.labels(analysis_style=analysis_style, search_type=search_type, agent_type=agent_type, status=status).inc()]

29
00:02:48,000 --> 00:02:54,000
We observe the latency in the QUERY_LATENCY histogram.
[Types: QUERY_LATENCY.labels(analysis_style=analysis_style, search_type=search_type).observe(latency_seconds)]

30
00:02:54,000 --> 00:03:00,000
If there's an error, we increment the error counter.
[Types: if not success and error_type: QUERY_ERRORS.labels(error_type=error_type).inc()]

31
00:03:00,000 --> 00:03:06,000
Now let's define the record_ingestion function.
[Types: def record_ingestion(*, ticker: str, filing_type: str, latency_seconds: float, success: bool,) -> None:]

32
00:03:06,000 --> 00:03:12,000
We determine the status based on success.
[Types: status = "success" if success else "error"]

33
00:03:12,000 --> 00:03:18,000
We increment the INGESTION_TOTAL counter.
[Types: INGESTION_TOTAL.labels(ticker=ticker, filing_type=filing_type, status=status).inc()]

34
00:03:18,000 --> 00:03:24,000
We observe the latency in the INGESTION_LATENCY histogram.
[Types: INGESTION_LATENCY.labels(ticker=ticker).observe(latency_seconds)]

35
00:03:24,000 --> 00:03:30,000
Now let's define the update_store_stats function.
[Types: def update_store_stats(*, ticker: str, chunks: int, filings: int, filing_type: str = "all") -> None:]

36
00:03:30,000 --> 00:03:36,000
We update the CHUNKS_TOTAL gauge for the ticker.
[Types: CHUNKS_TOTAL.labels(ticker=ticker).set(chunks)]

37
00:03:36,000 --> 00:03:42,000
We update the FILINGS_TOTAL gauge for the ticker and filing type.
[Types: FILINGS_TOTAL.labels(ticker=ticker, filing_type=filing_type).set(filings)]

38
00:03:42,000 --> 00:03:48,000]
Now let's define the get_metrics_output function. This returns the metrics for the /metrics endpoint.
[Types: def get_metrics_output() -> tuple[bytes, str]: return generate_latest(), CONTENT_TYPE_LATEST]

39
00:03:48,000 --> 00:03:54,000
generate_latest() produces the Prometheus text format. CONTENT_TYPE_LATEST
is the correct content type for the response.

40
00:03:54,000 --> 00:04:00,000
Now let's update the monitoring __init__.py file.
Open `src/financial_rag/monitoring/__init__.py`.

41
00:04:00,000 --> 00:04:06,000
We import the functions from the metrics module.
[Types: from .metrics import get_metrics_output, record_ingestion, record_query, update_store_stats]

42
00:04:06,000 --> 00:04:12,000
We export them in __all__.
[Types: __all__ = ["get_metrics_output", "record_ingestion", "record_query", "update_store_stats"]]

43
00:04:12,000 --> 00:04:18,000
Now let's test the metrics. Start the server and access the /metrics endpoint.

44
00:04:18,000 --> 00:04:24,000
[Types: curl http://localhost:8000/metrics]

45
00:04:24,000 --> 00:04:30,000
You should see output starting with # HELP and # TYPE. These are the Prometheus
comments that describe the metrics.

46
00:04:30,000 --> 00:04:36,000
You should see finrag_query_total at the bottom with 0 counts. No queries
have been made yet.

47
00:04:36,000 --> 00:04:42,000
Now let's make a query and check the metrics again.

48
00:04:42,000 --> 00:04:48,000
[Types: curl -X POST http://localhost:8000/query -H "Content-Type: application/json" -d '{"question":"What is Apple's revenue?"}']

49
00:04:48,000 --> 00:04:54,000
Then check the metrics again.
[Types: curl http://localhost:8000/metrics | grep finrag_query]

50
00:04:54,000 --> 00:05:00,000
You should see finrag_query_total with count 1. The analysis_style, search_type,
and status labels should be populated.

51
00:05:00,000 --> 00:05:06,000
Now let me recap what we've built in Part 4.

52
00:05:06,000 --> 00:05:12,000
We built four counter metrics. QUERY_TOTAL for query count. QUERY_ERRORS for
error count. INGESTION_TOTAL for ingestion count. CACHE_HITS and CACHE_MISSES
for cache tracking.

53
00:05:12,000 --> 00:05:18,000
We built two histogram metrics. QUERY_LATENCY for query duration. INGESTION_LATENCY
for ingestion duration.

54
00:05:18,000 --> 00:05:24,000
We built two gauge metrics. CHUNKS_TOTAL for vector store size. FILINGS_TOTAL
for ingestion progress.

55
00:05:24,000 --> 00:05:30,000
We built the record_query function for recording query metrics. We built the
record_ingestion function for ingestion metrics.

56
00:05:30,000 --> 00:05:36,000
We built the update_store_stats function for updating the store metrics.
We built the get_metrics_output function for the /metrics endpoint.

57
00:05:36,000 --> 00:05:42,000
This is the complete metrics module. Every operation is instrumented.
Prometheus can scrape and visualize everything.

58
00:05:42,000 --> 00:05:48,000
Phase 5 is now complete. You have a production-ready API with metrics,
logging, rate limiting, and authentication.

59
00:05:48,000 --> 00:05:54,000
Thank you for watching. I'll see you in Phase 6.

60
00:05:54,000 --> 00:05:58,000
[End of Phase 5]
1
00:00:00,000 --> 00:00:06,000
Welcome back to Phase 5. In Part 6, we build the verification tests for the API.

2
00:00:06,000 --> 00:00:12,000
We've built the models, dependencies, server, routes, and middleware.
Now we need to verify everything works together.

3
00:00:12,000 --> 00:00:18,000
Think of this as the final quality check before deployment. Every endpoint is tested.
Every error case is verified. Nothing is left untested.

4
00:00:18,000 --> 00:00:24,000
Open your editor and create `tests/integration/test_phase5_api.py`.

5
00:00:24,000 --> 00:00:30,000
We'll start with the imports. The __future__ import enables forward references.
[Types: from __future__ import annotations]

6
00:00:30,000 --> 00:00:36,000
We import os for environment variable access during testing.
[Types: import os]

7
00:00:36,000 --> 00:00:42,000
We import AsyncMock and patch from unittest.mock for mocking dependencies.
[Types: from unittest.mock import AsyncMock, patch]

8
00:00:42,000 --> 00:00:48,000
We import pytest as our testing framework.
[Types: import pytest]

9
00:00:48,000 --> 00:00:54,000
We import ASGITransport and AsyncClient from httpx for testing FastAPI apps.
[Types: from httpx import ASGITransport, AsyncClient]

10
00:00:54,000 --> 00:01:00,000
We import get_settings from the config module.
[Types: from financial_rag.config import get_settings]

11
00:01:00,000 --> 00:01:06,000
Now let's define the valid test secrets. These are environment variables that
must be set for tests to run.
[Types: VALID_SECRETS = { "POSTGRES_PASSWORD": "test-pg-password-32-chars-minimum", "REDIS_PASSWORD": "test-redis-password-32-chars-min", "APP_ENV": "testing" }]

12
00:01:06,000 --> 00:01:12,000
These secrets are used to initialize the settings without reading from .env.

13
00:01:12,000 --> 00:01:18,000
Now let's define the testing environment fixture. This patches the environment
with our valid test secrets and clears the settings cache.
[Types: @pytest.fixture(autouse=True) def _testing_env(): with patch.dict(os.environ, VALID_SECRETS, clear=False): get_settings.cache_clear() yield get_settings.cache_clear()]

14
00:01:18,000 --> 00:01:24,000
This fixture runs automatically for every test. It ensures the environment is
correctly configured.

15
00:01:24,000 --> 00:01:30,000
Now let's define the mock database fixture.
[Types: @pytest.fixture def mock_db(): db = AsyncMock() db.connect = AsyncMock() db.disconnect = AsyncMock() db.verify_pgvector = AsyncMock() db.health_check = AsyncMock(return_value={"status": "healthy", "postgres_version": "16.0", "server_start_time": "2024-01-01", "pool_size": 2, "pool_checked_out": 0, "pool_overflow": -1}) return db]

16
00:01:30,000 --> 00:01:36,000
This mock database client returns a healthy status. It verifies that the health
endpoint works correctly.

17
00:01:36,000 --> 00:01:42,000
Now let's define the mock cache fixture.
[Types: @pytest.fixture def mock_cache(): cache = AsyncMock() cache.connect = AsyncMock() cache.disconnect = AsyncMock() cache.health_check = AsyncMock(return_value={"status": "healthy", "redis_version": "7.0", "used_memory_human": "1M", "pool_max_connections": 20}) return cache]

18
00:01:42,000 --> 00:01:48,000
This mock cache client returns a healthy status. It verifies that the health
endpoint correctly checks Redis.

19
00:01:48,000 --> 00:01:54,000
Now let's define the mock query engine fixture.
[Types: @pytest.fixture def mock_query_engine(): from financial_rag.retrieval.query_engine import QueryResult engine = AsyncMock() engine.query = AsyncMock(return_value=QueryResult(question="What is Apple's revenue?", answer="Apple reported $391 billion in revenue for FY2024.", analysis_style="analyst", search_type="similarity", agent_type="query_engine", latency_ms=500, source_documents=[])) return engine]

20
00:01:54,000 --> 00:02:00,000
This mock query engine returns a sample answer. It verifies that the query
endpoint returns the correct format.

21
00:02:00,000 --> 00:02:06,000
Now let's define the mock vector store fixture.
[Types: @pytest.fixture def mock_vector_store(): vs = AsyncMock() vs.stats = AsyncMock(return_value={"ticker": None, "total_chunks": 100, "total_filings": 5, "provider": "LocalEmbeddingProvider", "dimensions": 384}) return vs]

22
00:02:06,000 --> 00:02:12,000
This mock vector store returns sample statistics. It verifies that the stats
endpoint returns the correct format.

23
00:02:12,000 --> 00:02:18,000
Now let's define the test client fixture. This creates an AsyncClient with
all dependencies mocked.
[Types: @pytest.fixture async def test_client(mock_db, mock_cache, mock_query_engine, mock_vector_store): from financial_rag.api.server import create_app app = create_app() with ( patch("financial_rag.api.dependencies.initialise_dependencies", AsyncMock()), patch("financial_rag.api.dependencies.shutdown_dependencies", AsyncMock()), patch("financial_rag.api.dependencies.get_db_client", AsyncMock(return_value=mock_db)), patch("financial_rag.api.dependencies.get_cache_client", AsyncMock(return_value=mock_cache)), patch("financial_rag.api.dependencies.get_query_engine", return_value=mock_query_engine), patch("financial_rag.api.dependencies.get_vector_store", return_value=mock_vector_store), patch("financial_rag.api.routes.get_cache_client", AsyncMock(return_value=mock_cache)), patch("financial_rag.api.routes.get_db_client", AsyncMock(return_value=mock_db)), ): async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client: yield client]

24
00:02:18,000 --> 00:02:24,000
This fixture creates a complete test client. All external dependencies are mocked.
The application runs in-memory without a real database.

25
00:02:24,000 --> 00:02:30,000
Now let's define the TestRootEndpoint class. This tests the root endpoint.
[Types: class TestRootEndpoint:]

26
00:02:30,000 --> 00:02:36,000
We test that the root endpoint returns 200 OK.
[Types: @pytest.mark.asyncio async def test_root_returns_200(self, test_client): response = await test_client.get("/") assert response.status_code == 200]

27
00:02:36,000 --> 00:02:42,000
The root endpoint is the landing page. It should always return a 200.

28
00:02:42,000 --> 00:02:48,000
We test that the root endpoint returns the service name.
[Types: @pytest.mark.asyncio async def test_root_returns_service_name(self, test_client): response = await test_client.get("/") data = response.json() assert "service" in data assert "version" in data]

29
00:02:48,000 --> 00:02:54,000
The service name and version tell you what's running. This is useful for debugging.

30
00:02:54,000 --> 00:03:00,000
Now let's define the TestHealthEndpoint class. This tests the health endpoint.
[Types: class TestHealthEndpoint:]

31
00:03:00,000 --> 00:03:06,000
We test that the health endpoint returns 200 OK.
[Types: @pytest.mark.asyncio async def test_health_returns_200(self, test_client): response = await test_client.get("/health") assert response.status_code == 200]

32
00:03:06,000 --> 00:03:12,000
The health endpoint is used by Kubernetes for liveness and readiness probes.

33
00:03:12,000 --> 00:03:18,000
We test that the health response has a status field.
[Types: @pytest.mark.asyncio async def test_health_response_has_status(self, test_client): response = await test_client.get("/health") data = response.json() assert "status" in data assert data["status"] in ("healthy", "degraded", "unhealthy")]

34
00:03:18,000 --> 00:03:24,000
The status tells Kubernetes if the application is ready to serve traffic.

35
00:03:24,000 --> 00:03:30,000
We test that the health response has a version field.
[Types: @pytest.mark.asyncio async def test_health_response_has_version(self, test_client): response = await test_client.get("/health") data = response.json() assert "version" in data]

36
00:03:30,000 --> 00:03:36,000
The version helps you know which version of the application is running.

37
00:03:36,000 --> 00:03:42,000
We test that the health response has services.
[Types: @pytest.mark.asyncio async def test_health_response_has_services(self, test_client): response = await test_client.get("/health") data = response.json() assert "services" in data assert "database" in data["services"] assert "cache" in data["services"]]

38
00:03:42,000 --> 00:03:48,000
The services section shows the health of each backing service.

39
00:03:48,000 --> 00:03:54,000
We test that each service has a healthy field.
[Types: @pytest.mark.asyncio async def test_health_service_has_healthy_field(self, test_client): response = await test_client.get("/health") data = response.json() for service in data["services"].values(): assert "healthy" in service]

40
00:03:54,000 --> 00:04:00,000
This verifies that each service returns a health status.

41
00:04:00,000 --> 00:04:06,000
Now let's define the TestQueryEndpoint class. This tests the query endpoint.
[Types: class TestQueryEndpoint:]

42
00:04:06,000 --> 00:04:12,000
We test that the query endpoint returns 200 OK.
[Types: @pytest.mark.asyncio async def test_query_returns_200(self, test_client): response = await test_client.post("/query", json={"question": "What is Apple's revenue?", "ticker": "AAPL"}) assert response.status_code == 200]

43
00:04:12,000 --> 00:04:18,000
The query endpoint is the main endpoint. It should always return a 200.

44
00:04:18,000 --> 00:04:24,000
We test that the query response has an answer field.
[Types: @pytest.mark.asyncio async def test_query_response_has_answer(self, test_client): response = await test_client.post("/query", json={"question": "What is Apple's revenue?"}) data = response.json() assert "answer" in data assert isinstance(data["answer"], str)]

45
00:04:24,000 --> 00:04:30,000
The answer is the main result of the query. It should be a string.

46
00:04:30,000 --> 00:04:36,000
We test that the query response has source_documents.
[Types: @pytest.mark.asyncio async def test_query_response_has_source_documents(self, test_client): response = await test_client.post("/query", json={"question": "What is Apple's revenue?"}) data = response.json() assert "source_documents" in data assert isinstance(data["source_documents"], list)]

47
00:04:36,000 --> 00:04:42,000
The source_documents field lists the documents used to generate the answer.

48
00:04:42,000 --> 00:04:48,000
We test that the query response has latency_seconds.
[Types: @pytest.mark.asyncio async def test_query_response_has_latency(self, test_client): response = await test_client.post("/query", json={"question": "Revenue?"}) data = response.json() assert "latency_seconds" in data assert data["latency_seconds"] >= 0]

49
00:04:48,000 --> 00:04:54,000
The latency_seconds field tells you how long the query took.

50
00:04:54,000 --> 00:05:00,000
We test that missing question returns 422.
[Types: @pytest.mark.asyncio async def test_query_missing_question_returns_422(self, test_client): response = await test_client.post("/query", json={}) assert response.status_code == 422]

51
00:05:00,000 --> 00:05:06,000
Question is required. Without it, the API should return a validation error.

52
00:05:06,000 --> 00:05:12,000
We test that invalid analysis_style returns 422.
[Types: @pytest.mark.asyncio async def test_query_invalid_analysis_style_returns_422(self, test_client): response = await test_client.post("/query", json={"question": "Revenue?", "analysis_style": "invalid_style"}) assert response.status_code == 422]

53
00:05:12,000 --> 00:05:18,000
The analysis_style must be one of "analyst", "executive", or "risk".

54
00:05:18,000 --> 00:05:24,000
We test that all analysis styles are accepted.
[Types: @pytest.mark.asyncio async def test_query_all_analysis_styles_accepted(self, test_client): for style in ("analyst", "executive", "risk"): response = await test_client.post("/query", json={"question": "Revenue?", "analysis_style": style}) assert response.status_code == 200, f"Style {style} failed"]

55
00:05:24,000 --> 00:05:30,000
This verifies that all three styles are supported.

56
00:05:30,000 --> 00:05:36,000
We test that all search types are accepted.
[Types: @pytest.mark.asyncio async def test_query_all_search_types_accepted(self, test_client): for stype in ("similarity", "mmr", "hybrid"): response = await test_client.post("/query", json={"question": "Revenue?", "search_type": stype}) assert response.status_code == 200, f"Search type {stype} failed"]

57
00:05:36,000 --> 00:05:42,000
This verifies that all search types are supported.

58
00:05:42,000 --> 00:05:48,000
Now let's define the TestIngestEndpoint class. This tests the ingestion endpoint.
[Types: class TestIngestEndpoint:]

59
00:05:48,000 --> 00:05:54,000
We test that the ingest endpoint returns 202 Accepted.
[Types: @pytest.mark.asyncio async def test_ingest_returns_202(self, test_client): with patch("financial_rag.api.routes._ingest_background", AsyncMock()): response = await test_client.post("/ingest/sec", json={"ticker": "AAPL", "filing_type": "10-K", "years": 1}) assert response.status_code == 202]

60
00:05:54,000 --> 00:06:00,000
The ingest endpoint returns 202 because it runs as a background task.

61
00:06:00,000 --> 00:06:06,000
We test that the ingest response has the ticker.
[Types: @pytest.mark.asyncio async def test_ingest_response_has_ticker(self, test_client): with patch("financial_rag.api.routes._ingest_background", AsyncMock()): response = await test_client.post("/ingest/sec", json={"ticker": "MSFT", "filing_type": "10-K", "years": 1}) data = response.json() assert data["ticker"] == "MSFT"]

62
00:06:06,000 --> 00:06:12,000
The response echoes back the ticker for confirmation.

63
00:06:12,000 --> 00:06:18,000
We test that missing ticker returns 422.
[Types: @pytest.mark.asyncio async def test_ingest_missing_ticker_returns_422(self, test_client): response = await test_client.post("/ingest/sec", json={"filing_type": "10-K"}) assert response.status_code == 422]

64
00:06:18,000 --> 00:06:24,000
Ticker is required. Without it, the API should return a validation error.

65
00:06:24,000 --> 00:06:30,000
We test that years out of range returns 422.
[Types: @pytest.mark.asyncio async def test_ingest_years_out_of_range_returns_422(self, test_client): response = await test_client.post("/ingest/sec", json={"ticker": "AAPL", "years": 10}) assert response.status_code == 422]

66
00:06:30,000 --> 00:06:36,000
Years must be between 1 and 5. Anything else should return a validation error.

67
00:06:36,000 --> 00:06:42,000
Now let's define the TestStatsEndpoint class. This tests the stats endpoints.
[Types: class TestStatsEndpoint:]

68
00:06:42,000 --> 00:06:48,000
We test that the global stats endpoint returns 200 OK.
[Types: @pytest.mark.asyncio async def test_global_stats_returns_200(self, test_client): response = await test_client.get("/stats") assert response.status_code == 200]

69
00:06:48,000 --> 00:06:54,000
The stats endpoint provides monitoring information.

70
00:06:54,000 --> 00:07:00,000
We test that the global stats has required fields.
[Types: @pytest.mark.asyncio async def test_global_stats_has_required_fields(self, test_client): response = await test_client.get("/stats") data = response.json() assert "total_chunks" in data assert "total_filings" in data assert "provider" in data assert "dimensions" in data]

71
00:07:00,000 --> 00:07:06,000
These fields are used for monitoring and capacity planning.

72
00:07:06,000 --> 00:07:12,000
We test that the ticker stats endpoint returns 200 OK.
[Types: @pytest.mark.asyncio async def test_ticker_stats_returns_200(self, test_client): response = await test_client.get("/stats/AAPL") assert response.status_code == 200]

73
00:07:12,000 --> 00:07:18,000
The ticker stats endpoint returns statistics for a specific company.

74
00:07:18,000 --> 00:07:24,000
We test that the ticker stats has a ticker field.
[Types: @pytest.mark.asyncio async def test_ticker_stats_has_ticker_field(self, test_client): response = await test_client.get("/stats/AAPL") data = response.json() assert "ticker" in data]

75
00:07:24,000 --> 00:07:30,000
The ticker field identifies which company the stats are for.

76
00:07:30,000 --> 00:07:36,000
Now let's define the TestMetricsEndpoint class. This tests the metrics endpoint.
[Types: class TestMetricsEndpoint:]

77
00:07:36,000 --> 00:07:42,000
We test that the metrics endpoint returns Prometheus format.
[Types: @pytest.mark.asyncio async def test_metrics_returns_prometheus_format(self, test_client): response = await test_client.get("/metrics") assert response.status_code == 200 assert "finrag_query_total" in response.text assert "finrag_query_latency_seconds" in response.text]

78
00:07:42,000 --> 00:07:48,000
The metrics endpoint is scraped by Prometheus. It should return the correct format.

79
00:07:48,000 --> 00:07:54,000
Now let's define the TestAPIKeyMiddleware class. This tests authentication.
[Types: class TestAPIKeyMiddleware:]

80
00:07:54,000 --> 00:08:00,000
We test that the health endpoint is exempt from API key auth.
[Types: @pytest.mark.asyncio async def test_health_exempt_without_key(self, test_client): response = await test_client.get("/health") assert response.status_code != 401]

81
00:08:00,000 --> 00:08:06,000
The health endpoint must be accessible without authentication. Kubernetes needs
it for health checks.

82
00:08:06,000 --> 00:08:12,000
We test that the query endpoint is allowed without key when auth is disabled.
[Types: @pytest.mark.asyncio async def test_query_allowed_without_key_when_disabled(self, test_client): response = await test_client.post("/query", json={"question": "test"}) assert response.status_code != 401]

83
00:08:12,000 --> 00:08:18,000
When API key auth is disabled, all endpoints are accessible without a key.

84
00:08:18,000 --> 00:08:24,000
Now let's define the TestRequestIDs class. This tests request ID headers.
[Types: class TestRequestIDs:]

85
00:08:24,000 --> 00:08:30,000
We test that the response has a X-Request-ID header.
[Types: @pytest.mark.asyncio async def test_response_has_request_id_header(self, test_client): response = await test_client.get("/health") assert "X-Request-ID" in response.headers]

86
00:08:30,000 --> 00:08:36,000
The request ID header is used for tracing requests through the system.

87
00:08:36,000 --> 00:08:42,000
We test that the response has a X-Process-Time header.
[Types: @pytest.mark.asyncio async def test_response_has_process_time_header(self, test_client): response = await test_client.get("/health") assert "X-Process-Time" in response.headers]

88
00:08:42,000 --> 00:08:48,000
The process time header tells you how long the request took to process.

89
00:08:48,000 --> 00:08:54,000
Now let's run the tests. Activate your virtual environment and run pytest.

90
00:08:54,000 --> 00:09:00,000
[Types: source .venv/bin/activate]
[Types: pytest tests/integration/test_phase5_api.py -v]

91
00:09:00,000 --> 00:09:06,000
You should see output like this showing all tests passing.

92
00:09:06,000 --> 00:09:12,000
============================= test session starts =============================
collected 22 items
test_phase5_api.py ......................                                [100%]
============================= 22 passed in 8.45s =============================

93
00:09:12,000 --> 00:09:18,000
All green means everything is working. The API is ready for production.

94
00:09:18,000 --> 00:09:24,000
Now let me recap what we've built in Part 6.

95
00:09:24,000 --> 00:09:30,000
We built tests for the root endpoint. We verified it returns 200 and the
service name.

96
00:09:30,000 --> 00:09:36,000
We built tests for the health endpoint. We verified it returns status and
services information.

97
00:09:36,000 --> 00:09:42,000
We built tests for the query endpoint. We verified it returns answers,
source documents, and latency.

98
00:09:42,000 --> 00:09:48,000
We built tests for the ingest endpoint. We verified it returns 202 and handles
validation correctly.

99
00:09:48,000 --> 00:09:54,000
We built tests for the stats endpoints. We verified they return the expected fields.

100
00:09:54,000 --> 00:10:00,000
We built tests for the metrics endpoint. We verified it returns Prometheus format.

101
00:10:00,000 --> 00:10:06,000
We built tests for the API key middleware. We verified exempt paths work
without authentication.

102
00:10:06,000 --> 00:10:12,000
We built tests for request ID headers. We verified X-Request-ID and
X-Process-Time are present.

103
00:10:12,000 --> 00:10:18,000
This is the complete API test suite. Every endpoint is tested. Every error
case is covered. The API is reliable.

104
00:10:18,000 --> 00:10:24,000
Phase 5 is now complete. You have a complete FastAPI application with routes,
middleware, and tests.

105
00:10:24,000 --> 00:10:30,000
Thank you for watching. I'll see you in Phase 6.

106
00:10:30,000 --> 00:10:34,000
[End of Phase 5]