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
Welcome back to Phase 5. In Part 2, we build the API routes and middleware.

2
00:00:06,000 --> 00:00:12,000
The routes define our API endpoints. The middleware handles cross-cutting concerns
like logging, rate limiting, and authentication.

3
00:00:12,000 --> 00:00:18,000
Open your editor and create `src/financial_rag/api/routes.py`.

4
00:00:18,000 --> 00:00:24,000
We'll start with the imports. The __future__ import enables forward references.
[Types: from __future__ import annotations]

5
00:00:24,000 --> 00:00:30,000
We import logging for structured logging throughout the routes.
[Types: import logging]

6
00:00:30,000 --> 00:00:36,000
We import BackgroundTasks from fastapi for running background tasks.
[Types: from fastapi import APIRouter, BackgroundTasks, HTTPException, status]

7
00:00:36,000 --> 00:00:42,000
We import Response from fastapi for the metrics endpoint.
[Types: from fastapi.responses import Response]

8
00:00:42,000 --> 00:00:48,000
We import the dependencies we created in Part 1.
[Types: from financial_rag.api.dependencies import Engine, Store]

9
00:00:48,000 --> 00:00:54,000
We import all the request and response models.
[Types: from financial_rag.api.models import DocumentResponse, HealthResponse, IngestionRequest, IngestionResponse, QueryRequest, QueryResponse, ServiceStatus, StatsResponse]

10
00:00:54,000 --> 00:01:00,000
We import the HTMLParser and TextParser for parsing filings.
[Types: from financial_rag.ingestion.parsers.html_parser import HTMLParser]

11
00:01:00,000 --> 00:01:06,000
[Types: from financial_rag.ingestion.parsers.text_parser import TextParser]

12
00:01:06,000 --> 00:01:12,000
We import the SECIngestor for downloading filings.
[Types: from financial_rag.ingestion.sec_ingestor import SECIngestor]

13
00:01:12,000 --> 00:01:18,000
We import the TextProcessor for chunking.
[Types: from financial_rag.processing.text_processor import TextProcessor]

14
00:01:18,000 --> 00:01:24,000
We import get_cache_client and get_db_client for health checks.
[Types: from financial_rag.storage.cache import get_cache_client]

15
00:01:24,000 --> 00:01:30,000
[Types: from financial_rag.storage.database import get_db_client]

16
00:01:30,000 --> 00:01:36,000
We import VectorStore for ingestion and stats.
[Types: from financial_rag.storage.vector_store import VectorStore]

17
00:01:36,000 --> 00:01:42,000
We import DuplicateFilingError for handling duplicate filings.
[Types: from financial_rag.utils.exceptions import DuplicateFilingError]

18
00:01:42,000 --> 00:01:48,000
Now let's create the router instance.
[Types: router = APIRouter()]

19
00:01:48,000 --> 00:01:54,000
This is the main router for our API. We'll register all endpoints on it.

20
00:01:54,000 --> 00:02:00,000
Now let's define the health check endpoint.
[Types: @router.get("/health", response_model=HealthResponse, summary="Health check", tags=["ops"])]

21
00:02:00,000 --> 00:02:06,000
[Types: async def health_check() -> HealthResponse:]

22
00:02:06,000 --> 00:02:12,000
We import get_settings from the config module.
[Types: from financial_rag.config import get_settings]

23
00:02:12,000 --> 00:02:18,000
[Types: settings = get_settings()]

24
00:02:18,000 --> 00:02:24,000
We initialize the database status as unhealthy by default.
[Types: db_status = ServiceStatus(healthy=False)]

25
00:02:24,000 --> 00:02:30,000
We initialize the cache status as unhealthy by default.
[Types: cache_status = ServiceStatus(healthy=False)]

26
00:02:30,000 --> 00:02:36,000
Now let's check the database. We wrap this in a try-except block.
[Types: try: db = await get_db_client() db_info = await db.health_check() db_status = ServiceStatus(healthy=True, details=db_info)]

27
00:02:36,000 --> 00:02:42,000
If the database is reachable, we set healthy to True and include the details.

28
00:02:42,000 --> 00:02:48,000
If an error occurs, we capture the error in the details.
[Types: except Exception as exc: db_status = ServiceStatus(healthy=False, details={"error": str(exc)})]

29
00:02:48,000 --> 00:02:54,000
Now let's check the cache. Same pattern.
[Types: try: cache = await get_cache_client() cache_info = await cache.health_check() cache_status = ServiceStatus(healthy=True, details=cache_info)]

30
00:02:54,000 --> 00:03:00,000
[Types: except Exception as exc: cache_status = ServiceStatus(healthy=False, details={"error": str(exc)})]

31
00:03:00,000 --> 00:03:06,000
Now we determine the overall status based on the individual checks.
[Types: if not db_status.healthy: overall = "unhealthy" elif not cache_status.healthy: overall = "degraded" else: overall = "healthy"]

32
00:03:06,000 --> 00:03:12,000
If the database is down, the system is unhealthy. If only cache is down, it's degraded.
If both are healthy, the system is healthy.

33
00:03:12,000 --> 00:03:18,000
We return the HealthResponse.
[Types: return HealthResponse(status=overall, version=settings.APP_VERSION, services={"database": db_status, "cache": cache_status})]

34
00:03:18,000 --> 00:03:24,000
Now let's define the query endpoint. This is the main RAG endpoint.
[Types: @router.post("/query", response_model=QueryResponse, summary="Financial RAG query", tags=["query"])]

35
00:03:24,000 --> 00:03:30,000
[Types: async def query(request: QueryRequest, engine: Engine,) -> QueryResponse:]

36
00:03:30,000 --> 00:03:36,000
We call the query engine with the request parameters.
[Types: result = await engine.query(request.question, ticker=request.ticker, filing_type=request.filing_type, fiscal_year=request.fiscal_year, analysis_style=request.analysis_style.value, search_type=request.search_type.value, limit=request.limit)]

37
00:03:36,000 --> 00:03:42,000
Now we record Prometheus metrics. We wrap this in a try-except to prevent
metric recording from failing the request.
[Types: try: from financial_rag.monitoring.metrics import record_query import time as _time record_query(analysis_style=request.analysis_style.value, search_type=request.search_type.value, agent_type=result.agent_type, latency_seconds=_time.monotonic() - _t0, success=result.error is None, error_type=type(result.error).__name__ if result.error else None) except Exception: pass]

38
00:03:42,000 --> 00:03:48,000
We need to capture the start time before the query.
[Types: import time as _time]
[Types: _t0 = _time.monotonic()]

39
00:03:48,000 --> 00:03:54,000
Now we write to analysis_history. This is the audit trail.
[Types: try: from financial_rag.storage.repositories.analysis import AnalysisRepository from financial_rag.storage.database import get_db_client from uuid import UUID _db = await get_db_client() async with _db.session() as _session: _repo = AnalysisRepository(_session) await _repo.record(question=request.question, answer=result.answer, agent_type=result.agent_type, latency_ms=result.latency_ms, ticker=request.ticker, analysis_style=result.analysis_style, search_type=result.search_type, source_chunk_ids=[UUID(r.chunk_id) for r in result.source_documents], error=result.error) except Exception as _exc: logger.warning("Failed to write analysis_history (non-fatal): %s", _exc)]

40
00:03:54,000 --> 00:04:00,000
This is a fire-and-forget operation. If it fails, we log a warning but don't
fail the request.

41
00:04:00,000 --> 00:04:06,000
If the result has an error and no answer, we raise an HTTPException.
[Types: if result.error and not result.answer: raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=result.error)]

42
00:04:06,000 --> 00:04:12,000
We convert the source documents to the response format.
[Types: source_docs = [DocumentResponse(chunk_id=r.chunk_id, content=r.chunk_text, ticker=r.ticker, filing_type=r.filing_type, fiscal_year=r.fiscal_year, section=r.section, score=r.score, metrics=r.metrics) for r in result.source_documents]]

43
00:04:12,000 --> 00:04:18,000
We return the QueryResponse.
[Types: return QueryResponse(question=result.question, answer=result.answer, analysis_style=result.analysis_style, search_type=result.search_type, agent_type=result.agent_type, latency_seconds=result.latency_seconds, source_documents=source_docs, error=result.error)]

44
00:04:18,000 --> 00:04:24,000
Now let's define the ingestion endpoint. This triggers ingestion of SEC filings.
[Types: @router.post("/ingest/sec", response_model=IngestionResponse, status_code=status.HTTP_202_ACCEPTED, summary="Ingest SEC filings", tags=["ingestion"])]

45
00:04:24,000 --> 00:04:30,000
[Types: async def ingest_sec(request: IngestionRequest, background_tasks: BackgroundTasks, store: Store,) -> IngestionResponse:]

46
00:04:30,000 --> 00:04:36,000
We add the ingestion task to the background tasks.
[Types: background_tasks.add_task(_ingest_background, ticker=request.ticker, filing_type=request.filing_type, years=request.years, store=store)]

47
00:04:36,000 --> 00:04:42,000
We return an immediate response with a 202 Accepted status.
[Types: return IngestionResponse(ticker=request.ticker.upper(), filing_type=request.filing_type, filings_found=0, chunks_stored=0, success=True, error=None)]

48
00:04:42,000 --> 00:04:48,000
Now let's define the background ingestion function.
[Types: async def _ingest_background(*, ticker: str, filing_type: str, years: int, store: VectorStore) -> None:]

49
00:04:48,000 --> 00:04:54,000
We import get_settings for configuration.
[Types: from financial_rag.config import get_settings]

50
00:04:54,000 --> 00:05:00,000
[Types: settings = get_settings()]

51
00:05:00,000 --> 00:05:06,000
We normalize the ticker to uppercase.
[Types: ticker = ticker.upper()]

52
00:05:06,000 --> 00:05:12,000
We create the parser instances.
[Types: html_parser = HTMLParser()]
[Types: text_parser = TextParser()]
[Types: processor = TextProcessor()]

53
00:05:12,000 --> 00:05:18,000
We log the start of the background job.
[Types: logger.info("Background ingestion started — ticker=%s type=%s years=%d", ticker, filing_type, years)]

54
00:05:18,000 --> 00:05:24,000
We initialize counters for tracking progress.
[Types: total_chunks = 0]
[Types: total_filings = 0]
[Types: skipped = 0]

55
00:05:24,000 --> 00:05:30,000
We wrap the ingestion in a try-except block.
[Types: try:]

56
00:05:30,000 --> 00:05:36,000
We create the ingestor and list the filings.
[Types: async with SECIngestor() as ingestor: filings = await ingestor.list_filings(ticker, filing_type, years=years) total_filings = len(filings)]

57
00:05:36,000 --> 00:05:42,000
We create the raw data directory.
[Types: raw_dir = settings.RAW_DATA_DIR / ticker / filing_type]
[Types: raw_dir.mkdir(parents=True, exist_ok=True)]

58
00:05:42,000 --> 00:05:48,000
We loop through each filing.
[Types: for meta in filings:]

59
00:05:48,000 --> 00:05:54,000
We download the filing. If it fails, we log the error and continue.
[Types: try: raw_html, file_hash = await ingestor.download_filing(meta, raw_dir=raw_dir) except Exception as exc: logger.error("Failed to download %s FY%s: %s", meta.filing_type, meta.fiscal_year, exc) continue]

60
00:05:54,000 --> 00:06:00,000
We parse the HTML into sections.
[Types: parsed = html_parser.parse(raw_html, ticker=ticker, filing_type=filing_type, fiscal_year=meta.fiscal_year)]

61
00:06:00,000 --> 00:06:06,000
We clean the text in each section.
[Types: for section in parsed.sections: section.text = text_parser.clean(section.text)]

62
00:06:06,000 --> 00:06:12,000
We generate a placeholder filing ID.
[Types: import uuid]
[Types: placeholder_filing_id = uuid.uuid4()]

63
00:06:12,000 --> 00:06:18,000
We chunk the parsed content.
[Types: chunks = processor.process(parsed, meta, placeholder_filing_id)]

64
00:06:18,000 --> 00:06:24,000
We ingest the chunks into the vector store.
[Types: try: _, stored = await store.ingest(chunks, meta, file_hash) total_chunks += stored logger.info("Ingested %s FY%s — %d chunks", ticker, meta.fiscal_year, stored)]

65
00:06:24,000 --> 00:06:30,000
If the filing is a duplicate, we skip it.
[Types: except DuplicateFilingError: skipped += 1 logger.info("Skipped duplicate — %s FY%s hash=%s", ticker, meta.fiscal_year, file_hash[:12])]

66
00:06:30,000 --> 00:06:36,000
We log the completion of the background job.
[Types: logger.info("Background ingestion complete — ticker=%s filings=%d chunks=%d skipped=%d", ticker, total_filings, total_chunks, skipped)]

67
00:06:36,000 --> 00:06:42,000
If an error occurs, we log it.
[Types: except Exception as exc: logger.error("Background ingestion failed — ticker=%s error=%s", ticker, exc, exc_info=True)]

68
00:06:42,000 --> 00:06:48,000
Now let's define the stats endpoints.
[Types: @router.get("/stats", response_model=StatsResponse, summary="Global vector store statistics", tags=["ops"])]

69
00:06:48,000 --> 00:06:54,000
[Types: async def global_stats(store: Store) -> StatsResponse: stats = await store.stats() return StatsResponse(**stats)]

70
00:06:54,000 --> 00:07:00,000
[Types: @router.get("/stats/{ticker}", response_model=StatsResponse, summary="Per-ticker statistics", tags=["ops"])]

71
00:07:00,000 --> 00:07:06,000
[Types: async def ticker_stats(ticker: str, store: Store) -> StatsResponse: stats = await store.stats(ticker=ticker.upper()) return StatsResponse(**stats)]

72
00:07:06,000 --> 00:07:12,000
Now let's define the metrics endpoint for Prometheus.
[Types: @router.get("/metrics", include_in_schema=False, tags=["ops"])]

73
00:07:12,000 --> 00:07:18,000
[Types: async def metrics() -> Response: from fastapi.responses import Response as FastAPIResponse from financial_rag.monitoring.metrics import get_metrics_output data, content_type = get_metrics_output() return FastAPIResponse(content=data, media_type=content_type)]

74
00:07:18,000 --> 00:07:24,000
This completes the routes file. Now let's create the middleware file.

75
00:07:24,000 --> 00:07:30,000
Open `src/financial_rag/api/middleware.py`.

76
00:07:30,000 --> 00:07:36,000
We'll start with the imports.
[Types: from __future__ import annotations]

77
00:07:36,000 --> 00:07:42,000
[Types: import logging]
[Types: import time]
[Types: import uuid]

78
00:07:42,000 --> 00:07:48,000
[Types: from fastapi import FastAPI, Request, status]
[Types: from fastapi.responses import JSONResponse]

79
00:07:48,000 --> 00:07:54,000
[Types: from slowapi import Limiter, _rate_limit_exceeded_handler]
[Types: from slowapi.errors import RateLimitExceeded]
[Types: from slowapi.util import get_remote_address]

80
00:07:54,000 --> 00:08:00,000
[Types: from starlette.middleware.base import BaseHTTPMiddleware, RequestResponseEndpoint]
[Types: from starlette.responses import Response]

81
00:08:00,000 --> 00:08:06,000
[Types: from financial_rag.config import get_settings]

82
00:08:06,000 --> 00:08:12,000
Now let's create the rate limiter singleton.
[Types: limiter = Limiter(key_func=get_remote_address, default_limits=["100/minute"])]

83
00:08:12,000 --> 00:08:18,000
This limiter uses the client's IP address as the key. It allows 100 requests per minute.

84
00:08:18,000 --> 00:08:24,000
Now let's define the configure_limiter function.
[Types: def configure_limiter(app: FastAPI) -> None:]

85
00:08:24,000 --> 00:08:30,000
We get the settings.
[Types: settings = get_settings()]

86
00:08:30,000 --> 00:08:36,000
We set the storage URI to None by default.
[Types: storage_uri: str | None = None]

87
00:08:36,000 --> 00:08:42,000
In production, we use Redis for rate limiting storage.
[Types: if settings.APP_ENV == "production" and settings.REDIS_URL.get_secret_value(): storage_uri = settings.REDIS_URL.get_secret_value() logger.info("Rate limiter: Redis backend at %s", settings.REDIS_HOST)]

88
00:08:42,000 --> 00:08:48,000
In development, we use in-memory storage.
[Types: else: logger.info("Rate limiter: in-memory backend (dev/test)")]

89
00:08:48,000 --> 00:08:54,000
We reassign the global limiter with the storage URI.
[Types: global limiter]
[Types: limiter = Limiter(key_func=get_remote_address, default_limits=["100/minute"], storage_uri=storage_uri)]

90
00:08:54,000 --> 00:09:00,000
We attach the limiter to the app state.
[Types: app.state.limiter = limiter]

91
00:09:00,000 --> 00:09:06,000
We add the exception handler for rate limit exceeded.
[Types: app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)]

92
00:09:06,000 --> 00:09:12,000
Now let's define the request logging middleware.
[Types: class RequestLoggingMiddleware(BaseHTTPMiddleware):]

93
00:09:12,000 --> 00:09:18,000
This middleware logs every request with a unique ID.
[Types: async def dispatch(self, request: Request, call_next: RequestResponseEndpoint) -> Response:]

94
00:09:18,000 --> 00:09:24,000
We generate a unique request ID.
[Types: request_id = str(uuid.uuid4())]

95
00:09:24,000 --> 00:09:30,000
We capture the start time.
[Types: t0 = time.monotonic()]

96
00:09:30,000 --> 00:09:36,000
We store the request ID on the request state.
[Types: request.state.request_id = request_id]

97
00:09:36,000 --> 00:09:42,000
We log the start of the request.
[Types: logger.info("request_start", extra={"request_id": request_id, "method": request.method, "path": request.url.path, "client_ip": request.client.host if request.client else "unknown"})]

98
00:09:42,000 --> 00:09:48,000
We call the next middleware or route handler.
[Types: try: response = await call_next(request)]

99
00:09:48,000 --> 00:09:54,000
If an error occurs, we log it.
[Types: except Exception as exc: logger.error("request_error", extra={"request_id": request_id, "error": str(exc)}) raise]

100
00:09:54,000 --> 00:10:00,000
We calculate the processing time.
[Types: process_ms = int((time.monotonic() - t0) * 1000)]

101
00:10:00,000 --> 00:10:06,000
We add headers to the response.
[Types: response.headers["X-Request-ID"] = request_id]
[Types: response.headers["X-Process-Time"] = f"{process_ms}ms"]

102
00:10:06,000 --> 00:10:12,000
We log the completion of the request.
[Types: logger.info("request_complete", extra={"request_id": request_id, "status_code": response.status_code, "process_ms": process_ms})]

103
00:10:12,000 --> 00:10:18,000
We return the response.
[Types: return response]

104
00:10:18,000 --> 00:10:24,000
Now let's define the API key authentication middleware.
[Types: class APIKeyMiddleware(BaseHTTPMiddleware):]

105
00:10:24,000 --> 00:10:30,000
We define the paths that are exempt from API key checks.
[Types: EXEMPT_PATHS = frozenset({"/health", "/docs", "/redoc", "/openapi.json", "/"})]

106
00:10:30,000 --> 00:10:36,000
[Types: async def dispatch(self, request: Request, call_next: RequestResponseEndpoint) -> Response:]

107
00:10:36,000 --> 00:10:42,000
We get the settings.
[Types: settings = get_settings()]

108
00:10:42,000 --> 00:10:48,000
If API key is not enabled or the path is exempt, we skip authentication.
[Types: if not settings.API_KEY_ENABLED or request.url.path in self.EXEMPT_PATHS: return await call_next(request)]

109
00:10:48,000 --> 00:10:54,000
We get the API key from the header.
[Types: api_key = request.headers.get("X-API-Key")]

110
00:10:54,000 --> 00:11:00,000
We get the expected key from settings.
[Types: expected = settings.API_KEY.get_secret_value() if settings.API_KEY else None]

111
00:11:00,000 --> 00:11:06,000
If there's no expected key, we skip authentication.
[Types: if not expected: return await call_next(request)]

112
00:11:06,000 --> 00:11:12,000
If the key doesn't match, we return a 401 Unauthorized response.
[Types: if api_key != expected: return JSONResponse(status_code=status.HTTP_401_UNAUTHORIZED, content={"type": "about:blank", "title": "Unauthorized", "status": 401, "detail": "Invalid or missing API key. Pass X-API-Key header.", "instance": request.url.path})]

113
00:11:12,000 --> 00:11:18,000
If the key matches, we proceed to the next middleware or route handler.
[Types: return await call_next(request)]

114
00:11:18,000 --> 00:11:24,000
Now let's define the exception handlers.
[Types: def register_exception_handlers(app: FastAPI) -> None:]

115
00:11:24,000 --> 00:11:30,000
We handle all unhandled exceptions.
[Types: @app.exception_handler(Exception) async def unhandled_exception_handler(request: Request, exc: Exception) -> JSONResponse:]

116
00:11:30,000 --> 00:11:36,000
We get the request ID from the request state.
[Types: request_id = getattr(request.state, "request_id", "unknown")]

117
00:11:36,000 --> 00:11:42,000
We log the exception with full traceback.
[Types: logger.error("unhandled_exception", extra={"request_id": request_id, "error": str(exc)}, exc_info=True)]

118
00:11:42,000 --> 00:11:48,000
We return a JSON response following RFC 7807.
[Types: return JSONResponse(status_code=500, content={"type": "about:blank", "title": "Internal Server Error", "status": 500, "detail": "An unexpected error occurred.", "instance": request.url.path, "request_id": request_id})]

119
00:11:48,000 --> 00:11:54,000
We also handle ValueError specifically for validation errors.
[Types: @app.exception_handler(ValueError) async def value_error_handler(request: Request, exc: ValueError) -> JSONResponse: request_id = getattr(request.state, "request_id", "unknown") return JSONResponse(status_code=422, content={"type": "about:blank", "title": "Validation Error", "status": 422, "detail": str(exc), "instance": request.url.path, "request_id": request_id})]

120
00:11:54,000 --> 00:12:00,000
This completes the middleware file. Let's recap what we've built.

121
00:12:00,000 --> 00:12:06,000
We built the routes file. It has endpoints for health, query, ingestion, stats, and metrics.

122
00:12:06,000 --> 00:12:12,000
We built the health endpoint. It checks database and cache status. It returns
a structured response.

123
00:12:12,000 --> 00:12:18,000
We built the query endpoint. It calls the query engine and returns results.
It records metrics and writes to the audit trail.

124
00:12:18,000 --> 00:12:24,000
We built the ingestion endpoint. It runs as a background task. It downloads,
parses, chunks, and stores filings.

125
00:12:24,000 --> 00:12:30,000
We built the stats endpoints. They return vector store statistics.

126
00:12:30,000 --> 00:12:36,000
We built the middleware. Request logging, rate limiting, and API key authentication.

127
00:12:36,000 --> 00:12:42,000
Now let's test our work. Start the API server.

128
00:12:42,000 --> 00:12:48,000
[Types: uvicorn financial_rag.api.server:app --reload --port 8000]

129
00:12:48,000 --> 00:12:54,000
Test the health endpoint.
[Types: curl http://localhost:8000/health]

130
00:12:54,000 --> 00:13:00,000
You should see a response with status healthy.

131
00:13:00,000 --> 00:13:06,000
This completes Part 2. You now have a working API with routes and middleware.

132
00:13:06,000 --> 00:13:12,000
Thank you for watching. I'll see you in Part 3.

133
00:13:12,000 --> 00:13:16,000
[End of Part 2]
1
00:00:00,000 --> 00:00:06,000
Welcome back to Phase 5. In Part 3, we build the API middleware and rate limiting.

2
00:00:06,000 --> 00:00:12,000
Middleware is code that runs before and after every request. It's the gatekeeper.
It handles authentication, logging, rate limiting, and error handling.

3
00:00:12,000 --> 00:00:18,000
Think of middleware like airport security. Every passenger goes through the
same checks. Metal detector. ID verification. Baggage scan.

4
00:00:18,000 --> 00:00:24,000
Your API requests go through the same checks. Every request is logged.
Every request is rate limited. Every request is authenticated.

5
00:00:24,000 --> 00:00:30,000
Open your editor and create `src/financial_rag/api/middleware.py`.

6
00:00:30,000 --> 00:00:36,000
We'll start with the imports. The __future__ import enables forward references.
[Types: from __future__ import annotations]

7
00:00:36,000 --> 00:00:42,000
We import logging for structured logging throughout the middleware.
[Types: import logging]

8
00:00:42,000 --> 00:00:48,000
We import time for measuring request duration and creating timestamps.
[Types: import time]

9
00:00:48,000 --> 00:00:54,000
We import uuid for generating unique request IDs for tracing.
[Types: import uuid]

10
00:00:54,000 --> 00:01:00,000
We import FastAPI for the application type hints.
[Types: from fastapi import FastAPI, Request, status]

11
00:01:00,000 --> 00:01:06,000
We import JSONResponse for returning structured error responses.
[Types: from fastapi.responses import JSONResponse]

12
00:01:06,000 --> 00:01:12,000
We import the Limiter class from slowapi for rate limiting.
[Types: from slowapi import Limiter, _rate_limit_exceeded_handler]

13
00:01:12,000 --> 00:01:18,000
We import RateLimitExceeded for handling rate limit errors.
[Types: from slowapi.errors import RateLimitExceeded]

14
00:01:18,000 --> 00:01:24,000
We import get_remote_address for extracting the client IP address.
[Types: from slowapi.util import get_remote_address]

15
00:01:24,000 --> 00:01:30,000
We import BaseHTTPMiddleware and RequestResponseEndpoint from Starlette.
[Types: from starlette.middleware.base import BaseHTTPMiddleware, RequestResponseEndpoint]

16
00:01:30,000 --> 00:01:36,000
We import Response from Starlette for response type hints.
[Types: from starlette.responses import Response]

17
00:01:36,000 --> 00:01:42,000
We import get_settings from the config module for configuration access.
[Types: from financial_rag.config import get_settings]

18
00:01:42,000 --> 00:01:48,000
Now let's define the rate limiter singleton. This is the global rate limiter.
[Types: limiter = Limiter(key_func=get_remote_address, default_limits=["100/minute"])]

19
00:01:48,000 --> 00:01:54,000
The key_func is get_remote_address. This identifies the client by IP address.
The default_limits is 100 requests per minute per client.

20
00:01:54,000 --> 00:02:00,000
Now let's define the configure_limiter function. This attaches the rate limiter to the app.
[Types: def configure_limiter(app: FastAPI) -> None:]

21
00:02:00,000 --> 00:02:06,000
We get the settings instance. This gives us Redis configuration.
[Types: settings = get_settings()]

22
00:02:06,000 --> 00:02:12,000
We initialize the storage_uri to None. This defaults to in-memory storage.
[Types: storage_uri: str | None = None]

23
00:02:12,000 --> 00:02:18,000
If we're in production and Redis is configured, we use Redis for rate limiting.
[Types: if settings.APP_ENV == "production" and settings.REDIS_URL.get_secret_value(): storage_uri = settings.REDIS_URL.get_secret_value() logger.info("Rate limiter: Redis backend at %s", settings.REDIS_HOST)]

24
00:02:18,000 --> 00:02:24,000
Redis provides distributed rate limiting across multiple API pods.
Without Redis, each pod tracks limits independently.

25
00:02:24,000 --> 00:02:30,000
If we're not in production, we use in-memory storage.
[Types: else: logger.info("Rate limiter: in-memory backend (dev/test)")]

26
00:02:30,000 --> 00:02:36,000
We create a new Limiter instance with the storage URI.
[Types: global limiter limiter = Limiter(key_func=get_remote_address, default_limits=["100/minute"], storage_uri=storage_uri,)]

27
00:02:36,000 --> 00:02:42,000
We store the limiter on the app state for access in routes.
[Types: app.state.limiter = limiter]

28
00:02:42,000 --> 00:02:48,000
We add the rate limit exceeded exception handler.
[Types: app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)]

29
00:02:48,000 --> 00:02:54,000
This handler returns a 429 Too Many Requests response when a rate limit is exceeded.

30
00:02:54,000 --> 00:03:00,000
Now let's define the RequestLoggingMiddleware. This logs every request.
[Types: class RequestLoggingMiddleware(BaseHTTPMiddleware):]

31
00:03:00,000 --> 00:03:06,000
The dispatch method is called for every request.
[Types: async def dispatch(self, request: Request, call_next: RequestResponseEndpoint) -> Response:]

32
00:03:06,000 --> 00:03:12,000
We generate a unique request ID for tracing.
[Types: request_id = str(uuid.uuid4())]

33
00:03:12,000 --> 00:03:18,000
We record the start time for latency measurement.
[Types: t0 = time.monotonic()]

34
00:03:18,000 --> 00:03:24,000
We store the request ID on the request state for use in other middleware.
[Types: request.state.request_id = request_id]

35
00:03:24,000 --> 00:03:30,000
We log the start of the request with structured logging.
[Types: logger.info("request_start", extra={"request_id": request_id, "method": request.method, "path": request.url.path, "client_ip": request.client.host if request.client else "unknown",})]

36
00:03:30,000 --> 00:03:36,000
The extra dictionary adds structured fields to the log. This makes it searchable.

37
00:03:36,000 --> 00:03:42,000
We call the next middleware or the route handler.
[Types: try: response = await call_next(request)]

38
00:03:42,000 --> 00:03:48,000
If an exception occurs, we log it and re-raise.
[Types: except Exception as exc: logger.error("request_error", extra={"request_id": request_id, "error": str(exc)}) raise]

39
00:03:48,000 --> 00:03:54,000
We calculate the processing time in milliseconds.
[Types: process_ms = int((time.monotonic() - t0) * 1000)]

40
00:03:54,000 --> 00:04:00,000
We add the request ID to the response headers for client-side tracing.
[Types: response.headers["X-Request-ID"] = request_id]

41
00:04:00,000 --> 00:04:06,000
We add the processing time to the response headers.
[Types: response.headers["X-Process-Time"] = f"{process_ms}ms"]

42
00:04:06,000 --> 00:04:12,000
We log the completion of the request.
[Types: logger.info("request_complete", extra={"request_id": request_id, "status_code": response.status_code, "process_ms": process_ms,})]

43
00:04:12,000 --> 00:04:18,000
We return the response to the client.
[Types: return response]

44
00:04:18,000 --> 00:04:24,000
Now let's define the APIKeyMiddleware. This handles API key authentication.
[Types: class APIKeyMiddleware(BaseHTTPMiddleware):]

45
00:04:24,000 --> 00:04:30,000
We define exempt paths that don't require an API key.
[Types: EXEMPT_PATHS = frozenset({"/health", "/docs", "/redoc", "/openapi.json", "/"})]

46
00:04:30,000 --> 00:04:36,000
These paths are always accessible without authentication. This is standard
for health checks and documentation.

47
00:04:36,000 --> 00:04:42,000
The dispatch method is called for every request.
[Types: async def dispatch(self, request: Request, call_next: RequestResponseEndpoint) -> Response:]

48
00:04:42,000 --> 00:04:48,000
We get the settings instance to check if API key auth is enabled.
[Types: settings = get_settings()]

49
00:04:48,000 --> 00:04:54,000
If API key auth is disabled, we skip authentication.
[Types: if not settings.API_KEY_ENABLED or request.url.path in self.EXEMPT_PATHS: return await call_next(request)]

50
00:04:54,000 --> 00:05:00,000
We extract the API key from the X-API-Key header.
[Types: api_key = request.headers.get("X-API-Key")]

51
00:05:00,000 --> 00:05:06,000
We get the expected API key from settings.
[Types: expected = settings.API_KEY.get_secret_value() if settings.API_KEY else None]

52
00:05:06,000 --> 00:05:12,000
If there's no expected key, we skip authentication.
[Types: if not expected: return await call_next(request)]

53
00:05:12,000 --> 00:05:18,000
If the API key doesn't match, we return a 401 Unauthorized response.
[Types: if api_key != expected: return JSONResponse(status_code=status.HTTP_401_UNAUTHORIZED, content={"type": "about:blank", "title": "Unauthorized", "status": 401, "detail": "Invalid or missing API key. Pass X-API-Key header.", "instance": request.url.path,},)]

54
00:05:18,000 --> 00:05:24,000
The response format follows RFC 7807 Problem Details. This is a standard
format for API errors.

55
00:05:24,000 --> 00:05:30,000
If the key is valid, we proceed to the next middleware.
[Types: return await call_next(request)]

56
00:05:30,000 --> 00:05:36,000
Now let's define the exception handlers. These handle unhandled exceptions.
[Types: def register_exception_handlers(app: FastAPI) -> None:]

57
00:05:36,000 --> 00:05:42,000
We handle unhandled exceptions and return a 500 Internal Server Error.
[Types: @app.exception_handler(Exception) async def unhandled_exception_handler(request: Request, exc: Exception) -> JSONResponse: request_id = getattr(request.state, "request_id", "unknown") logger.error("unhandled_exception", extra={"request_id": request_id, "error": str(exc)}, exc_info=True) return JSONResponse(status_code=500, content={"type": "about:blank", "title": "Internal Server Error", "status": 500, "detail": "An unexpected error occurred.", "instance": request.url.path, "request_id": request_id,},)]

58
00:05:42,000 --> 00:05:48,000
This handler catches any unhandled exception and returns a structured response.
The error is logged with the request ID for debugging.

59
00:05:48,000 --> 00:05:54,000
We handle ValueError exceptions and return a 422 Unprocessable Entity.
[Types: @app.exception_handler(ValueError) async def value_error_handler(request: Request, exc: ValueError) -> JSONResponse: request_id = getattr(request.state, "request_id", "unknown") return JSONResponse(status_code=422, content={"type": "about:blank", "title": "Validation Error", "status": 422, "detail": str(exc), "instance": request.url.path, "request_id": request_id,},)]

60
00:05:54,000 --> 00:06:00,000
ValueError is raised for validation errors. This catches them and returns
a proper response.

61
00:06:00,000 --> 00:06:06,000
Now let's update the API __init__.py file to export the middleware.
Open `src/financial_rag/api/__init__.py`.

62
00:06:06,000 --> 00:06:12,000
We don't need to export anything from middleware. It's imported directly
in server.py.

63
00:06:12,000 --> 00:06:18,000
Now let's test the rate limiter. We'll use curl to make multiple requests.

64
00:06:18,000 --> 00:06:24,000
[Types: for i in {1..101}; do curl -s -o /dev/null -w "%{http_code}\n" http://localhost:8000/health; done | sort | uniq -c]

65
00:06:24,000 --> 00:06:30,000
This makes 101 requests to the health endpoint. You should see 100 requests
return 200 OK and 1 request return 429 Too Many Requests.

66
00:06:30,000 --> 00:06:36,000
Now let's test the API key middleware. Start the server and make a request
without a key.

67
00:06:36,000 --> 00:06:42,000
[Types: curl -i http://localhost:8000/query -X POST -H "Content-Type: application/json" -d '{"question":"test"}']

68
00:06:42,000 --> 00:06:48,000
You should get a 401 Unauthorized response. Then make a request with the key.

69
00:06:48,000 --> 00:06:54,000
[Types: curl -i http://localhost:8000/query -X POST -H "Content-Type: application/json" -H "X-API-Key: YOUR_API_KEY" -d '{"question":"test"}']

70
00:06:54,000 --> 00:07:00,000
This should succeed with a 200 OK response.

71
00:07:00,000 --> 00:07:06,000
Now let me recap what we've built in Part 3.

72
00:07:06,000 --> 00:07:12,000
We built the rate limiter with Redis support. It limits requests to 100 per
minute per client in production.

73
00:07:12,000 --> 00:07:18,000
We built the RequestLoggingMiddleware. It logs every request with a unique ID.
It adds X-Request-ID and X-Process-Time to responses.

74
00:07:18,000 --> 00:07:24,000
We built the APIKeyMiddleware. It enforces API key authentication for all
paths except health, docs, and root.

75
00:07:24,000 --> 00:07:30,000
We built exception handlers. They return structured RFC 7807 Problem Details
for unhandled exceptions.

76
00:07:30,000 --> 00:07:36,000
This is the complete middleware stack. Every request is logged, rate limited,
and authenticated. Every error is handled gracefully.

77
00:07:36,000 --> 00:07:42,000
In Part 4, we'll build the API routes. This is where we define the actual
endpoints for query, ingestion, and health.

78
00:07:42,000 --> 00:07:48,000
Thank you for watching. I'll see you in Part 4.

79
00:07:48,000 --> 00:07:52,000
[End of Part 3]

1
00:00:00,000 --> 00:00:06,000
Welcome back to Phase 5. In Part 4, we build the API middleware.

2
00:00:06,000 --> 00:00:12,000
Middleware is code that runs on every request before it reaches your route handlers.
Think of it as a security checkpoint at the entrance of a building.

3
00:00:12,000 --> 00:00:18,000
Every request must pass through the checkpoint. The checkpoint checks ID,
logs the visit, and enforces rules. Only then does the request proceed.

4
00:00:18,000 --> 00:00:24,000
Open your editor and create `src/financial_rag/api/middleware.py`.

5
00:00:24,000 --> 00:00:30,000
We'll start with the imports. The __future__ import enables forward references.
[Types: from __future__ import annotations]

6
00:00:30,000 --> 00:00:36,000
We import logging for structured logging throughout the middleware.
[Types: import logging]

7
00:00:36,000 --> 00:00:42,000
We import time for measuring request duration.
[Types: import time]

8
00:00:42,000 --> 00:00:48,000
We import uuid for generating unique request IDs.
[Types: import uuid]

9
00:00:48,000 --> 00:00:54,000
We import FastAPI for type hints and app configuration.
[Types: from fastapi import FastAPI, Request, status]

10
00:00:54,000 --> 00:01:00,000
We import JSONResponse for returning structured error responses.
[Types: from fastapi.responses import JSONResponse]

11
00:01:00,000 --> 00:01:06,000
We import Limiter and _rate_limit_exceeded_handler from slowapi for rate limiting.
[Types: from slowapi import Limiter, _rate_limit_exceeded_handler]

12
00:01:06,000 --> 00:01:12,000
We import RateLimitExceeded for handling rate limit errors.
[Types: from slowapi.errors import RateLimitExceeded]

13
00:01:12,000 --> 00:01:18,000
We import get_remote_address for identifying the client IP.
[Types: from slowapi.util import get_remote_address]

14
00:01:18,000 --> 00:01:24,000
We import BaseHTTPMiddleware and RequestResponseEndpoint from Starlette.
[Types: from starlette.middleware.base import BaseHTTPMiddleware, RequestResponseEndpoint]

15
00:01:24,000 --> 00:01:30,000
We import Response from Starlette for type hints.
[Types: from starlette.responses import Response]

16
00:01:30,000 --> 00:01:36,000
We import get_settings from the config module.
[Types: from financial_rag.config import get_settings]

17
00:01:36,000 --> 00:01:42,000
Now let's create the logger instance for this module.
[Types: logger = logging.getLogger(__name__)]

18
00:01:42,000 --> 00:01:48,000
This logger will be used for all logging in the middleware.

19
00:01:48,000 --> 00:01:54,000
Now let's define the rate limiter. This is a singleton that will be used
throughout the API.
[Types: limiter = Limiter(key_func=get_remote_address, default_limits=["100/minute"])]

20
00:01:54,000 --> 00:02:00,000
The rate limiter uses the client's remote IP address as the key.
Each IP is limited to 100 requests per minute by default.

21
00:02:00,000 --> 00:02:06,000
Now let's define the configure_limiter function. This attaches the rate limiter
to the FastAPI app.
[Types: def configure_limiter(app: FastAPI) -> None:]

22
00:02:06,000 --> 00:02:12,000
We get the settings instance for configuration.
[Types: settings = get_settings()]

23
00:02:12,000 --> 00:02:18,000
We set storage_uri to None by default. This means in-memory storage.
[Types: storage_uri: str | None = None]

24
00:02:18,000 --> 00:02:24,000
If we're in production and we have a Redis URL, we use Redis for rate limiting.
[Types: if settings.APP_ENV == "production" and settings.REDIS_URL.get_secret_value(): storage_uri = settings.REDIS_URL.get_secret_value() logger.info("Rate limiter: Redis backend at %s", settings.REDIS_HOST)]

25
00:02:24,000 --> 00:02:30,000
In production, we want distributed rate limiting across multiple instances.
Redis provides that. In development, in-memory is sufficient.

26
00:02:30,000 --> 00:02:36,000
We create a new Limiter instance with the storage URI.
[Types: global limiter limiter = Limiter( key_func=get_remote_address, default_limits=["100/minute"], storage_uri=storage_uri, )]

27
00:02:36,000 --> 00:02:42,000
We attach the limiter to the app state so routes can access it.
[Types: app.state.limiter = limiter]

28
00:02:42,000 --> 00:02:48,000
We add the exception handler for RateLimitExceeded.
[Types: app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)]

29
00:02:48,000 --> 00:02:54,000
This handler returns a 429 Too Many Requests response when the rate limit is exceeded.

30
00:02:54,000 --> 00:03:00,000
Now let's define the RequestLoggingMiddleware class. This logs every request.
[Types: class RequestLoggingMiddleware(BaseHTTPMiddleware):]

31
00:03:00,000 --> 00:03:06,000
We define the dispatch method. This is called for every request.
[Types: async def dispatch(self, request: Request, call_next: RequestResponseEndpoint) -> Response:]

32
00:03:06,000 --> 00:03:12,000
We generate a unique request ID for tracing.
[Types: request_id = str(uuid.uuid4())]

33
00:03:12,000 --> 00:03:18,000
We record the start time for latency measurement.
[Types: t0 = time.monotonic()]

34
00:03:18,000 --> 00:03:24,000
We store the request ID on the request state so routes can access it.
[Types: request.state.request_id = request_id]

35
00:03:24,000 --> 00:03:30,000
We log the start of the request with metadata.
[Types: logger.info("request_start", extra={"request_id": request_id, "method": request.method, "path": request.url.path, "client_ip": request.client.host if request.client else "unknown"})]

36
00:03:30,000 --> 00:03:36,000
The extra field adds structured data to the log entry. This makes it searchable
in log aggregators.

37
00:03:36,000 --> 00:03:42,000
We call the next middleware or route handler.
[Types: try: response = await call_next(request)]

38
00:03:42,000 --> 00:03:48,000
If an exception occurs, we log it with the request ID.
[Types: except Exception as exc: logger.error("request_error", extra={"request_id": request_id, "error": str(exc)}) raise]

39
00:03:48,000 --> 00:03:54,000
We calculate the processing time in milliseconds.
[Types: process_ms = int((time.monotonic() - t0) * 1000)]

40
00:03:54,000 --> 00:04:00,000
We add the request ID and processing time to the response headers.
[Types: response.headers["X-Request-ID"] = request_id]
[Types: response.headers["X-Process-Time"] = f"{process_ms}ms"]

41
00:04:00,000 --> 00:04:06,000
These headers help clients trace requests and measure performance.

42
00:04:06,000 --> 00:04:12,000
We log the completion of the request with metadata.
[Types: logger.info("request_complete", extra={"request_id": request_id, "status_code": response.status_code, "process_ms": process_ms})]

43
00:04:12,000 --> 00:04:18,000
We return the response to the client.
[Types: return response]

44
00:04:18,000 --> 00:04:24,000
Now let's define the APIKeyMiddleware class. This handles API key authentication.
[Types: class APIKeyMiddleware(BaseHTTPMiddleware):]

45
00:04:24,000 --> 00:04:30,000
We define the exempt paths that don't require API keys.
[Types: EXEMPT_PATHS = frozenset({"/health", "/docs", "/redoc", "/openapi.json", "/"})]

46
00:04:30,000 --> 00:04:36,000
Health checks, documentation, and the root endpoint are exempt.
These paths are used for monitoring and discovery.

47
00:04:36,000 --> 00:04:42,000
We define the dispatch method.
[Types: async def dispatch(self, request: Request, call_next: RequestResponseEndpoint) -> Response:]

48
00:04:42,000 --> 00:04:48,000
We get the settings instance.
[Types: settings = get_settings()]

49
00:04:48,000 --> 00:04:54,000
If API key authentication is disabled or the path is exempt, we skip auth.
[Types: if not settings.API_KEY_ENABLED or request.url.path in self.EXEMPT_PATHS: return await call_next(request)]

50
00:04:54,000 --> 00:05:00,000
This allows the API to be used without authentication in development or
for public endpoints.

51
00:05:00,000 --> 00:05:06,000
We get the API key from the X-API-Key header.
[Types: api_key = request.headers.get("X-API-Key")]

52
00:05:06,000 --> 00:05:12,000
We get the expected key from settings.
[Types: expected = settings.API_KEY.get_secret_value() if settings.API_KEY else None]

53
00:05:12,000 --> 00:05:18,000
If no key is expected, we skip auth.
[Types: if not expected: return await call_next(request)]

54
00:05:18,000 --> 00:05:24,000
If the provided key doesn't match, we return a 401 Unauthorized response.
[Types: if api_key != expected: return JSONResponse( status_code=status.HTTP_401_UNAUTHORIZED, content={"type": "about:blank", "title": "Unauthorized", "status": 401, "detail": "Invalid or missing API key. Pass X-API-Key header.", "instance": request.url.path}, )]

55
00:05:24,000 --> 00:05:30,000
We use the RFC 7807 problem details format for error responses.
This is a standard format for API errors.

56
00:05:30,000 --> 00:05:36,000
If the key is valid, we proceed to the next middleware or route handler.
[Types: return await call_next(request)]

57
00:05:36,000 --> 00:05:42,000
Now let's define the register_exception_handlers function. This adds global
exception handlers to the app.
[Types: def register_exception_handlers(app: FastAPI) -> None:]

58
00:05:42,000 --> 00:05:48,000
We define the handler for unhandled exceptions.
[Types: @app.exception_handler(Exception) async def unhandled_exception_handler(request: Request, exc: Exception) -> JSONResponse:]

59
00:05:48,000 --> 00:05:54,000
We get the request ID from the request state.
[Types: request_id = getattr(request.state, "request_id", "unknown")]

60
00:05:54,000 --> 00:06:00,000
We log the exception with full traceback.
[Types: logger.error("unhandled_exception", extra={"request_id": request_id, "error": str(exc)}, exc_info=True)]

61
00:06:00,000 --> 00:06:06,000
We return a 500 Internal Server Error response with problem details.
[Types: return JSONResponse( status_code=500, content={"type": "about:blank", "title": "Internal Server Error", "status": 500, "detail": "An unexpected error occurred.", "instance": request.url.path, "request_id": request_id}, )]

62
00:06:06,000 --> 00:06:12,000
The request_id is included so clients can reference it when reporting issues.

63
00:06:12,000 --> 00:06:18,000
We define the handler for ValueError exceptions.
[Types: @app.exception_handler(ValueError) async def value_error_handler(request: Request, exc: ValueError) -> JSONResponse:]

64
00:06:18,000 --> 00:06:24,000
We get the request ID.
[Types: request_id = getattr(request.state, "request_id", "unknown")]

65
00:06:24,000 --> 00:06:30,000
We return a 422 Unprocessable Entity response with the error detail.
[Types: return JSONResponse( status_code=422, content={"type": "about:blank", "title": "Validation Error", "status": 422, "detail": str(exc), "instance": request.url.path, "request_id": request_id}, )]

66
00:06:30,000 --> 00:06:36,000
ValueError is used for validation errors in our application.
This returns a structured error response.

67
00:06:36,000 --> 00:06:42,000
Now let's update the API __init__.py file to export the middleware.
Open `src/financial_rag/api/__init__.py`.

68
00:06:42,000 --> 00:06:48,000
We import the middleware components.
[Types: from .middleware import APIKeyMiddleware, RequestLoggingMiddleware, configure_limiter, limiter, register_exception_handlers]

69
00:06:48,000 --> 00:06:54,000
We add them to __all__.
[Types: __all__ = ["APIKeyMiddleware", "RequestLoggingMiddleware", "configure_limiter", "limiter", "register_exception_handlers"]]

70
00:06:54,000 --> 00:07:00,000
Now let's test the middleware. Run the FastAPI server.

71
00:07:00,000 --> 00:07:06,000
[Types: uvicorn financial_rag.api.server:app --reload --port 8000]

72
00:07:06,000 --> 00:07:12,000
Send a request with curl and check the response headers.
[Types: curl -v http://localhost:8000/health]

73
00:07:12,000 --> 00:07:18,000
You should see X-Request-ID and X-Process-Time headers in the response.

74
00:07:18,000 --> 00:07:24,000
Now test the rate limiter. Send 101 requests in quick succession.
[Types: for i in {1..101}; do curl -s http://localhost:8000/health; done]

75
00:07:24,000 --> 00:07:30,000
The 101st request should return a 429 Too Many Requests response.

76
00:07:30,000 --> 00:07:36,000
Now test the API key middleware. Enable API keys in your .env file.
[Types: API_KEY_ENABLED=true]
[Types: API_KEY=test-key-123]

77
00:07:36,000 --> 00:07:42,000
Restart the server and send a request without the API key.
[Types: curl http://localhost:8000/query -X POST -H "Content-Type: application/json" -d '{"question": "test"}']

78
00:07:42,000 --> 00:07:48,000
You should get a 401 Unauthorized response.

79
00:07:48,000 --> 00:07:54,000
Now send a request with the API key.
[Types: curl http://localhost:8000/query -X POST -H "Content-Type: application/json" -H "X-API-Key: test-key-123" -d '{"question": "test"}']

80
00:07:54,000 --> 00:08:00,000
The request should succeed.

81
00:08:00,000 --> 00:08:06,000
Now let me recap what we've built in Part 4.

82
00:08:06,000 --> 00:08:12,000
We built the rate limiter. It limits requests to 100 per minute per IP.
We use Redis in production for distributed rate limiting.

83
00:08:12,000 --> 00:08:18,000
We built the RequestLoggingMiddleware. It logs every request with a unique ID.
It adds X-Request-ID and X-Process-Time headers to every response.

84
00:08:18,000 --> 00:08:24,000
We built the APIKeyMiddleware. It authenticates requests using the X-API-Key header.
It exempts health checks and documentation endpoints.

85
00:08:24,000 --> 00:08:30,000
We built exception handlers. They return RFC 7807 problem details for errors.
This provides structured error responses to clients.

86
00:08:30,000 --> 00:08:36,000
This is the foundation of API security and observability. Every request is logged.
Every request is rate limited. Every request is authenticated.

87
00:08:36,000 --> 00:08:42,000
In Part 5, we'll build the API routes. This is where we define the actual
endpoints for querying, ingestion, and health checks.

88
00:08:42,000 --> 00:08:48,000
Thank you for watching. I'll see you in Part 5.

89
00:08:48,000 --> 00:08:52,000
[End of Part 4]
1
00:00:00,000 --> 00:00:06,000
Welcome back to Phase 5. In Part 5, we build the API routes.

2
00:00:06,000 --> 00:00:12,000
This is where our application comes to life. We've built the engine.
We've built the agent. We've built the storage layer. Now we connect
everything to the outside world.

3
00:00:12,000 --> 00:00:18,000
Think of routes as the front door of a building. All requests come through
this door. They're directed to the right room. The rooms are our application
logic. The door is our API.

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
We import time for measuring latency in the /stats endpoint.
[Types: import time]

8
00:00:42,000 --> 00:00:48,000
We import BackgroundTasks for handling background ingestion jobs.
[Types: from fastapi import BackgroundTasks]

9
00:00:48,000 --> 00:00:54,000
We import APIRouter for creating our route group.
[Types: from fastapi import APIRouter]

10
00:00:54,000 --> 00:01:00,000
We import HTTPException for error responses.
[Types: from fastapi import HTTPException, status]

11
00:01:00,000 --> 00:01:06,000
We import Response from fastapi for the metrics response.
[Types: from fastapi.responses import Response]

12
00:01:06,000 --> 00:01:12,000
We import our dependencies from the dependencies module.
[Types: from financial_rag.api.dependencies import Engine, Store]

13
00:01:12,000 --> 00:01:18,000
We import all of our Pydantic models from the models module.
[Types: from financial_rag.api.models import DocumentResponse, HealthResponse, IngestionRequest, IngestionResponse, QueryRequest, QueryResponse, ServiceStatus, StatsResponse]

14
00:01:18,000 --> 00:01:24,000
We import the HTMLParser and TextParser for parsing filings.
[Types: from financial_rag.ingestion.parsers.html_parser import HTMLParser]

15
00:01:24,000 --> 00:01:30,000
We import the TextParser for cleaning extracted text.
[Types: from financial_rag.ingestion.parsers.text_parser import TextParser]

16
00:01:30,000 --> 00:01:36,000
We import the SECIngestor for downloading filings from EDGAR.
[Types: from financial_rag.ingestion.sec_ingestor import SECIngestor]

17
00:01:36,000 --> 00:01:42,000
We import the TextProcessor for chunking documents.
[Types: from financial_rag.processing.text_processor import TextProcessor]

18
00:01:42,000 --> 00:01:48,000
We import get_cache_client for accessing the cache.
[Types: from financial_rag.storage.cache import get_cache_client]

19
00:01:48,000 --> 00:01:54,000
We import get_db_client for accessing the database.
[Types: from financial_rag.storage.database import get_db_client]

20
00:01:54,000 --> 00:02:00,000
We import VectorStore for accessing the vector store.
[Types: from financial_rag.storage.vector_store import VectorStore]

21
00:02:00,000 --> 00:02:06,000
We import DuplicateFilingError from our exceptions.
[Types: from financial_rag.utils.exceptions import DuplicateFilingError]

22
00:02:06,000 --> 00:02:12,000
We import get_settings for accessing configuration.
[Types: from financial_rag.config import get_settings]

23
00:02:12,000 --> 00:02:18,000
Now let's create the router instance. This is the APIRouter that
we'll register with the FastAPI app.
[Types: router = APIRouter()]

24
00:02:18,000 --> 00:02:24,000
We import the get_metrics_output function from the monitoring module.
[Types: from financial_rag.monitoring.metrics import get_metrics_output]

25
00:02:24,000 --> 00:02:30,000
Now let's build the health check endpoint. This is the simplest endpoint.
[Types: @router.get("/health", response_model=HealthResponse, summary="Health check", tags=["ops"])]

26
00:02:30,000 --> 00:02:36,000
We define the handler function with no dependencies needed.
[Types: async def health_check() -> HealthResponse:]

27
00:02:36,000 --> 00:02:42,000
We get the settings to access APP_VERSION.
[Types: settings = get_settings()]

28
00:02:42,000 --> 00:02:48,000
We initialize the service status objects.
[Types: db_status = ServiceStatus(healthy=False)]
[Types: cache_status = ServiceStatus(healthy=False)]

29
00:02:48,000 --> 00:02:54,000
Now we probe the database. This checks if PostgreSQL is reachable.
[Types: try: db = await get_db_client() db_info = await db.health_check() db_status = ServiceStatus(healthy=True, details=db_info)]

30
00:02:54,000 --> 00:03:00,000
If the database check fails, we capture the error.
[Types: except Exception as exc: db_status = ServiceStatus(healthy=False, details={"error": str(exc)})]

31
00:03:00,000 --> 00:03:06,000
Now we probe the cache. This checks if Redis is reachable.
[Types: try: cache = await get_cache_client() cache_info = await cache.health_check() cache_status = ServiceStatus(healthy=True, details=cache_info)]

32
00:03:06,000 --> 00:03:12,000
If the cache check fails, we capture the error.
[Types: except Exception as exc: cache_status = ServiceStatus(healthy=False, details={"error": str(exc)})]

33
00:03:12,000 --> 00:03:18,000
We determine the overall status. If the database is down, the system is unhealthy.
[Types: if not db_status.healthy: overall = "unhealthy"]

34
00:03:18,000 --> 00:03:24,000
If the database is healthy but the cache is down, the system is degraded.
[Types: elif not cache_status.healthy: overall = "degraded"]

35
00:03:24,000 --> 00:03:30,000
If both are healthy, the system is healthy.
[Types: else: overall = "healthy"]

36
00:03:30,000 --> 00:03:36,000
We return the HealthResponse with all the status information.
[Types: return HealthResponse(status=overall, version=settings.APP_VERSION, services={"database": db_status, "cache": cache_status})]

37
00:03:36,000 --> 00:03:42,000
Now let's build the query endpoint. This is the main RAG endpoint.
[Types: @router.post("/query", response_model=QueryResponse, summary="Financial RAG query", tags=["query"])]

38
00:03:42,000 --> 00:03:48,000
We inject the QueryEngine using the Engine dependency.
[Types: async def query(request: QueryRequest, engine: Engine) -> QueryResponse:]

39
00:03:48,000 --> 00:03:54,000
We call the query engine with the request parameters.
[Types: result = await engine.query(request.question, ticker=request.ticker, filing_type=request.filing_type, fiscal_year=request.fiscal_year, analysis_style=request.analysis_style.value, search_type=request.search_type.value, limit=request.limit)]

40
00:03:54,000 --> 00:04:00,000
Now we write the analysis to the database. This is non-fatal.
[Types: try: import time as _time from uuid import UUID from financial_rag.storage.repositories.analysis import AnalysisRepository _db = await get_db_client() async with _db.session() as _session: _repo = AnalysisRepository(_session) await _repo.record(question=request.question, answer=result.answer, agent_type=result.agent_type, latency_ms=result.latency_ms, ticker=request.ticker, analysis_style=result.analysis_style, search_type=result.search_type, source_chunk_ids=[UUID(r.chunk_id) for r in result.source_documents], error=result.error)]

41
00:04:00,000 --> 00:04:06,000
If writing to the database fails, we log the error and continue.
[Types: except Exception as _exc: logger.warning("Failed to write analysis_history (non-fatal): %s", _exc)]

42
00:04:06,000 --> 00:04:12,000
Now we record Prometheus metrics.
[Types: try: from financial_rag.monitoring.metrics import record_query record_query(analysis_style=request.analysis_style.value, search_type=request.search_type.value, agent_type=result.agent_type, latency_seconds=result.latency_seconds, success=result.error is None, error_type=type(result.error).__name__ if result.error else None)]

43
00:04:12,000 --> 00:04:18,000
If the query returns an error, we raise an HTTP exception.
[Types: except Exception: pass if result.error and not result.answer: raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=result.error)]

44
00:04:18,000 --> 00:04:24,000
We convert the source documents to the response format.
[Types: source_docs = [DocumentResponse(chunk_id=r.chunk_id, content=r.chunk_text, ticker=r.ticker, filing_type=r.filing_type, fiscal_year=r.fiscal_year, section=r.section, score=r.score, metrics=r.metrics) for r in result.source_documents]]

45
00:04:24,000 --> 00:04:30,000
We return the QueryResponse.
[Types: return QueryResponse(question=result.question, answer=result.answer, analysis_style=result.analysis_style, search_type=result.search_type, agent_type=result.agent_type, latency_seconds=result.latency_seconds, source_documents=source_docs, error=result.error)]

46
00:04:30,000 --> 00:04:36,000
Now let's build the ingestion endpoint. This triggers the background ingestion job.
[Types: @router.post("/ingest/sec", response_model=IngestionResponse, status_code=status.HTTP_202_ACCEPTED, summary="Ingest SEC filings", tags=["ingestion"])]

47
00:04:36,000 --> 00:04:42,000
We inject the VectorStore and the BackgroundTasks.
[Types: async def ingest_sec(request: IngestionRequest, background_tasks: BackgroundTasks, store: Store) -> IngestionResponse:]

48
00:04:42,000 --> 00:04:48,000
We add the ingestion task to the background.
[Types: background_tasks.add_task(_ingest_background, ticker=request.ticker, filing_type=request.filing_type, years=request.years, store=store)]

49
00:04:48,000 --> 00:04:54,000
We return immediately with a 202 Accepted response.
[Types: return IngestionResponse(ticker=request.ticker.upper(), filing_type=request.filing_type, filings_found=0, chunks_stored=0, success=True, error=None)]

50
00:04:54,000 --> 00:05:00,000
Now let's define the background ingestion function. This runs as a FastAPI
background task. It downloads filings, parses them, and stores them in the
vector store.

51
00:05:00,000 --> 00:05:06,000
[Types: async def _ingest_background(*, ticker: str, filing_type: str, years: int, store: VectorStore,) -> None:]

52
00:05:06,000 --> 00:05:12,000
We get the settings for the raw data directory.
[Types: settings = get_settings()]

53
00:05:12,000 --> 00:05:18,000
We normalize the ticker to uppercase.
[Types: ticker = ticker.upper()]

54
00:05:18,000 --> 00:05:24,000
We create instances of the parsers.
[Types: html_parser = HTMLParser()]
[Types: text_parser = TextParser()]
[Types: processor = TextProcessor()]

55
00:05:24,000 --> 00:05:30,000
We log the start of the background ingestion.
[Types: logger.info("Background ingestion started — ticker=%s type=%s years=%d", ticker, filing_type, years)]

56
00:05:30,000 --> 00:05:36,000
We initialize counters for the ingestion.
[Types: total_chunks = 0]
[Types: total_filings = 0]
[Types: skipped = 0]

57
00:05:36,000 --> 00:05:42,000
We wrap the ingestion in a try block to catch any errors.
[Types: try:]

58
00:05:42,000 --> 00:05:48,000
We create a SECIngestor instance and list the filings.
[Types: async with SECIngestor() as ingestor: filings = await ingestor.list_filings(ticker, filing_type, years=years) total_filings = len(filings)]

59
00:05:48,000 --> 00:05:54,000
We create the raw data directory for caching.
[Types: raw_dir = settings.RAW_DATA_DIR / ticker / filing_type]
[Types: raw_dir.mkdir(parents=True, exist_ok=True)]

60
00:05:54,000 --> 00:06:00,000
We loop through each filing.
[Types: for meta in filings:]

61
00:06:00,000 --> 00:06:06,000
We download the filing. If it fails, we log the error and continue.
[Types: try: raw_html, file_hash = await ingestor.download_filing(meta, raw_dir=raw_dir)]

62
00:06:06,000 --> 00:06:12,000
If the download fails, we log the error and continue to the next filing.
[Types: except Exception as exc: logger.error("Failed to download %s FY%s: %s", meta.filing_type, meta.fiscal_year, exc) continue]

63
00:06:12,000 --> 00:06:18,000
We parse the HTML content.
[Types: parsed = html_parser.parse(raw_html, ticker=ticker, filing_type=filing_type, fiscal_year=meta.fiscal_year)]

64
00:06:18,000 --> 00:06:24,000
We clean each section with the text parser.
[Types: for section in parsed.sections: section.text = text_parser.clean(section.text)]

65
00:06:24,000 --> 00:06:30,000
We create a placeholder filing ID. This will be replaced during ingestion.
[Types: import uuid placeholder_filing_id = uuid.uuid4()]

66
00:06:30,000 --> 00:06:36,000
We chunk the document.
[Types: chunks = processor.process(parsed, meta, placeholder_filing_id)]

67
00:06:36,000 --> 00:06:42,000
We ingest the chunks into the vector store. This handles deduplication.
[Types: try: _, stored = await store.ingest(chunks, meta, file_hash) total_chunks += stored]

68
00:06:42,000 --> 00:06:48,000
If the filing is a duplicate, we skip it.
[Types: except DuplicateFilingError: skipped += 1 logger.info("Skipped duplicate — %s FY%s hash=%s", ticker, meta.fiscal_year, file_hash[:12])]

69
00:06:48,000 --> 00:06:54,000
We log the completion of the background ingestion.
[Types: logger.info("Background ingestion complete — ticker=%s filings=%d chunks=%d skipped=%d", ticker, total_filings, total_chunks, skipped)]

70
00:06:54,000 --> 00:07:00,000
If an error occurs, we log it and exit.
[Types: except Exception as exc: logger.error("Background ingestion failed — ticker=%s error=%s", ticker, exc, exc_info=True)]

71
00:07:00,000 --> 00:07:06,000
Now let's build the stats endpoints. These return statistics about the vector store.

72
00:07:06,000 --> 00:07:12,000
We build the global stats endpoint.
[Types: @router.get("/stats", response_model=StatsResponse, summary="Global vector store statistics", tags=["ops"])]

73
00:07:12,000 --> 00:07:18,000
We inject the VectorStore using the Store dependency.
[Types: async def global_stats(store: Store) -> StatsResponse:]

74
00:07:18,000 --> 00:07:24,000
We get the stats from the vector store.
[Types: stats = await store.stats()]

75
00:07:24,000 --> 00:07:30,000
We return the stats.
[Types: return StatsResponse(**stats)]

76
00:07:30,000 --> 00:07:36,000
We build the per-ticker stats endpoint.
[Types: @router.get("/stats/{ticker}", response_model=StatsResponse, summary="Per-ticker statistics", tags=["ops"])]

77
00:07:36,000 --> 00:07:42,000
We inject the VectorStore using the Store dependency.
[Types: async def ticker_stats(ticker: str, store: Store) -> StatsResponse:]

78
00:07:42,000 --> 00:07:48,000
We get the stats for the specific ticker.
[Types: stats = await store.stats(ticker=ticker.upper())]

79
00:07:48,000 --> 00:07:54,000
We return the stats.
[Types: return StatsResponse(**stats)]

80
00:07:54,000 --> 00:08:00,000
Now let's build the metrics endpoint. This exposes Prometheus metrics.
[Types: @router.get("/metrics", include_in_schema=False, tags=["ops"])]

81
00:08:00,000 --> 00:08:06,000
We inject no dependencies.
[Types: async def metrics() -> Response:]

82
00:08:06,000 --> 00:08:12,000
We get the metrics from the monitoring module.
[Types: data, content_type = get_metrics_output()]

83
00:08:12,000 --> 00:08:18,000
We return the metrics as a Response.
[Types: return Response(content=data, media_type=content_type)]

84
00:08:18,000 --> 00:08:24,000
Now let's test the routes. Start the server and test the health endpoint.

85
00:08:24,000 --> 00:08:30,000
[Types: curl http://localhost:8000/health]

86
00:08:30,000 --> 00:08:36,000
You should see the health response. It should show both services as healthy.

87
00:08:36,000 --> 00:08:42,000
Now test the query endpoint.

88
00:08:42,000 --> 00:08:48,000
[Types: curl -X POST http://localhost:8000/query -H "Content-Type: application/json" -d '{"question": "What was Apple's revenue in 2024?", "ticker": "AAPL"}']

89
00:08:48,000 --> 00:08:54,000
You should see the query response. It should have the answer and source documents.

90
00:08:54,000 --> 00:09:00,000
Now test the ingestion endpoint.

91
00:09:00,000 --> 00:09:06,000
[Types: curl -X POST http://localhost:8000/ingest/sec -H "Content-Type: application/json" -d '{"ticker": "AAPL", "filing_type": "10-K", "years": 1}']

92
00:09:06,000 --> 00:09:12,000
You should get a 202 Accepted response. The ingestion will run in the background.

93
00:09:12,000 --> 00:09:18,000
Now test the stats endpoint.

94
00:09:18,000 --> 00:09:24,000
[Types: curl http://localhost:8000/stats]

95
00:09:24,000 --> 00:09:30,000
You should see the stats response. It shows the total chunks and filings.

96
00:09:30,000 --> 00:09:36,000
Now let me recap what we've built in Part 5.

97
00:09:36,000 --> 00:09:42,000
We built the health check endpoint. It checks both database and cache health.
It returns a structured HealthResponse.

98
00:09:42,000 --> 00:09:48,000
We built the query endpoint. It accepts a QueryRequest and returns a QueryResponse.
It writes to the analysis history and records Prometheus metrics.

99
00:09:48,000 --> 00:09:54,000
We built the ingestion endpoint. It accepts an IngestionRequest and returns
a 202 Accepted response. The ingestion runs as a background task.

100
00:09:54,000 --> 00:10:00,000
We built the stats endpoints. Global stats and per-ticker stats.
They return statistics about the vector store.

101
00:10:00,000 --> 00:10:06,000
We built the metrics endpoint. It exposes Prometheus metrics.
It's used by the monitoring stack.

102
00:10:06,000 --> 00:10:12,000
This is the complete API layer. All endpoints are built and ready for production.

103
00:10:12,000 --> 00:10:18,000
Thank you for watching. I'll see you in Phase 5, Part 6.

104
00:10:18,000 --> 00:10:22,000
[End of Part 5]
1
00:00:00,000 --> 00:00:06,000
Welcome back to Phase 5. In Part 6, we build the application server.

2
00:00:06,000 --> 00:00:12,000
This is where everything comes together. The API models, the dependencies,
the routes, the middleware. All of it is wired up in the server.

3
00:00:12,000 --> 00:00:18,000
Think of the server as the central hub. It receives requests. It routes them
to the right handler. It sends back responses. It manages the lifecycle of
the application.

4
00:00:18,000 --> 00:00:24,000
Open your editor and create `src/financial_rag/api/server.py`.

5
00:00:24,000 --> 00:00:30,000
We'll start with the imports. The __future__ import enables forward references.
[Types: from __future__ import annotations]

6
00:00:30,000 --> 00:00:36,000
We import logging for structured logging throughout the server.
[Types: import logging]

7
00:00:36,000 --> 00:00:42,000
We import asynccontextmanager from contextlib for the lifespan context manager.
[Types: from contextlib import asynccontextmanager]

8
00:00:42,000 --> 00:00:48,000
We import TYPE_CHECKING for conditional imports.
[Types: from typing import TYPE_CHECKING]

9
00:00:48,000 --> 00:00:54,000
We import uvicorn for running the ASGI server in development.
[Types: import uvicorn]

10
00:00:54,000 --> 00:01:00,000
We import FastAPI from fastapi for the application class.
[Types: from fastapi import FastAPI]

11
00:01:00,000 --> 00:01:06,000
We import CORSMiddleware for cross-origin resource sharing.
[Types: from fastapi.middleware.cors import CORSMiddleware]

12
00:01:06,000 --> 00:01:12,000
We import initialise_dependencies and shutdown_dependencies from dependencies.
[Types: from financial_rag.api.dependencies import initialise_dependencies, shutdown_dependencies]

13
00:01:12,000 --> 00:01:18,000
We import the router from routes.
[Types: from financial_rag.api.routes import router]

14
00:01:18,000 --> 00:01:24,000
We import get_settings from the config module.
[Types: from financial_rag.config import get_settings]

15
00:01:24,000 --> 00:01:30,000
Now let's define the lifespan context manager. This handles startup and shutdown.
[Types: @asynccontextmanager async def lifespan(app: FastAPI):]

16
00:01:30,000 --> 00:01:36,000
The lifespan context manager replaces the deprecated on_event decorators.
Everything before yield runs at startup. Everything after runs at shutdown.

17
00:01:36,000 --> 00:01:42,000
We get the settings instance.
[Types: settings = get_settings()]

18
00:01:42,000 --> 00:01:48,000
We log the startup message with the application name and version.
[Types: logger.info("Starting %s v%s [%s]", settings.APP_NAME, settings.APP_VERSION, settings.APP_ENV)]

19
00:01:48,000 --> 00:01:54,000
We call initialise_dependencies to connect to database and cache.
[Types: await initialise_dependencies()]

20
00:01:54,000 --> 00:02:00,000
We log that the application is ready.
[Types: logger.info("Application ready — listening on %s:%d", settings.API_HOST, settings.API_PORT)]

21
00:02:00,000 --> 00:02:06,000
We yield control to the application. This is where the server runs.
[Types: yield]

22
00:02:06,000 --> 00:02:12,000
After the application shuts down, we call shutdown_dependencies.
[Types: logger.info("Shutting down %s...", settings.APP_NAME)]
[Types: await shutdown_dependencies()]
[Types: logger.info("Shutdown complete")]

23
00:02:12,000 --> 00:02:18,000
Now let's define the create_app function. This is the application factory.
[Types: def create_app() -> FastAPI:]

24
00:02:18,000 --> 00:02:24,000
We get the settings instance.
[Types: settings = get_settings()]

25
00:02:24,000 --> 00:02:30,000
We create the FastAPI application with the lifespan context manager.
[Types: app = FastAPI(title="Financial RAG Analyst API", description="Production-grade financial analysis using RAG over SEC filings.", version=settings.APP_VERSION, docs_url="/docs" if settings.DEBUG else None, redoc_url="/redoc" if settings.DEBUG else None, openapi_url="/openapi.json" if settings.DEBUG else None, lifespan=lifespan)]

26
00:02:30,000 --> 00:02:36,000
The title appears in the OpenAPI documentation. The docs are disabled in production
to prevent API surface enumeration.

27
00:02:36,000 --> 00:02:42,000
Now we add CORS middleware. This allows frontend applications to call the API.
[Types: app.add_middleware(CORSMiddleware, allow_origins=settings.CORS_ORIGINS_LIST, allow_credentials=True, allow_methods=["GET", "POST"], allow_headers=["*"])]

28
00:02:42,000 --> 00:02:48,000
CORS stands for Cross-Origin Resource Sharing. It allows browsers from different
domains to call our API.

29
00:02:48,000 --> 00:02:54,000
Now we add the router. This includes all the API endpoints.
[Types: app.include_router(router)]

30
00:02:54,000 --> 00:03:00,000
The router includes the health endpoint, query endpoint, ingestion endpoint,
and stats endpoints.

31
00:03:00,000 --> 00:03:06,000
Now we add the root endpoint. This is a simple welcome message.
[Types: @app.get("/", include_in_schema=False) async def root() -> dict[str, str]: return {"service": settings.APP_NAME, "version": settings.APP_VERSION, "docs": "/docs" if settings.DEBUG else "disabled"}]

32
00:03:06,000 --> 00:03:12,000
The root endpoint tells users what the service is and where to find documentation.
Docs are disabled in production.

33
00:03:12,000 --> 00:03:18,000
We return the application.
[Types: return app]

34
00:03:18,000 --> 00:03:24,000
Now let's create the module-level app instance. This is what uvicorn imports.
[Types: app = create_app()]

35
00:03:24,000 --> 00:03:30,000
This is the entry point for the ASGI server. Uvicorn looks for this variable.

36
00:03:30,000 --> 00:03:36,000
Now let's define the main function. This is the development entrypoint.
[Types: def main() -> None:]

37
00:03:36,000 --> 00:03:42,000
We get the settings instance.
[Types: settings = get_settings()]

38
00:03:42,000 --> 00:03:48,000
We run uvicorn with the configured host, port, and reload settings.
[Types: uvicorn.run("financial_rag.api.server:app", host=settings.API_HOST, port=settings.API_PORT, reload=settings.DEBUG, log_level="debug" if settings.DEBUG else "info", access_log=True)]

39
00:03:48,000 --> 00:03:54,000
The reload flag enables auto-reload in development. This is disabled in production.

40
00:03:54,000 --> 00:04:00,000
Now let's test the server. Start the application.

41
00:04:00,000 --> 00:04:06,000
[Types: python -m financial_rag.api.server]

42
00:04:06,000 --> 00:04:12,000
You should see output like this showing the server starting.

43
00:04:12,000 --> 00:04:18,000
INFO: Starting financial-rag-agent v0.1.0 [development]
INFO: Database client connected
INFO: pgvector extension verified
INFO: Cache client connected
INFO: QueryEngine and VectorStore initialised
INFO: Application ready — listening on 0.0.0.0:8000

44
00:04:18,000 --> 00:04:24,000
Now test the health endpoint.

45
00:04:24,000 --> 00:04:30,000
[Types: curl http://localhost:8000/health]

46
00:04:30,000 --> 00:04:36,000
You should see the health response.

47
00:04:36,000 --> 00:04:42,000
{"status":"healthy","version":"0.1.0","services":{"database":{"healthy":true,"postgres_version":"17.0","pool_size":2},"cache":{"healthy":true,"redis_version":"7.0"}}}

48
00:04:42,000 --> 00:04:48,000
Test the query endpoint.

49
00:04:48,000 --> 00:04:54,000
[Types: curl -X POST http://localhost:8000/query -H "Content-Type: application/json" -d '{"question": "What was Apple's revenue?", "ticker": "AAPL"}']

50
00:04:54,000 --> 00:05:00,000
You should see a response with the answer and source documents.

51
00:05:00,000 --> 00:05:06,000
Now let me show you the complete file. This is what you should have in your editor.

52
00:05:06,000 --> 00:05:12,000
[Show complete server.py file]

53
00:05:12,000 --> 00:05:18,000
Let me explain the key decisions we made.

54
00:05:18,000 --> 00:05:24,000
First, we use a lifespan context manager. This is the modern way to handle
startup and shutdown in FastAPI. It's cleaner than the on_event decorators.

55
00:05:24,000 --> 00:05:30,000
Second, we disable docs in production. This prevents attackers from discovering
API endpoints. The docs are only available in development.

56
00:05:30,000 --> 00:05:36,000
Third, we use CORS middleware. This allows frontend applications to call the API.
The allowed origins are configured in settings.

57
00:05:36,000 --> 00:05:42,000
Fourth, we use the application factory pattern. This allows us to create multiple
applications for testing. It makes the code more testable.

58
00:05:42,000 --> 00:05:48,000
Fifth, we use the module-level app instance. This is what uvicorn imports.
It's a clean entry point for the ASGI server.

59
00:05:48,000 --> 00:05:54,000
Now let me give you a debugging tip. If the server fails to start, check
the error message. Common issues include port conflicts and missing
environment variables.

60
00:05:54,000 --> 00:06:00,000
If port 8000 is already in use, you can change the port in the .env file.
Set API_PORT=8001 to use a different port.

61
00:06:00,000 --> 00:06:06,000
If the database connection fails, check that PostgreSQL is running.
Run docker compose ps to check the status of services.

62
00:06:06,000 --> 00:06:12,000
If the Redis connection fails, check that Redis is running.
Same command: docker compose ps.

63
00:06:12,000 --> 00:06:18,000
Now let me recap what we've built in Part 6.

64
00:06:18,000 --> 00:06:24,000
We built the lifespan context manager. This handles startup and shutdown.
We connect to the database and cache at startup. We disconnect at shutdown.

65
00:06:24,000 --> 00:06:30,000
We built the application factory. This creates and configures the FastAPI app.
We add CORS middleware and the router. We add the root endpoint.

66
00:06:30,000 --> 00:06:36,000
We created the module-level app instance. This is what uvicorn imports.
It's the entry point for the ASGI server.

67
00:06:36,000 --> 00:06:42,000
We built the main function. This is the development entrypoint.
It runs uvicorn with the configured host, port, and reload settings.

68
00:06:42,000 --> 00:06:48,000
We tested the server. We started it, checked the health endpoint,
and ran a query.

69
00:06:48,000 --> 00:06:54,000
This is the complete application server. Every component is wired up.
The server is ready for production.

70
00:06:54,000 --> 00:07:00,000
Phase 5 is now complete. You have a working FastAPI server with all the
endpoints, dependencies, and middleware.

71
00:07:00,000 --> 00:07:06,000
Thank you for watching. I'll see you in Phase 6.

72
00:07:06,000 --> 00:07:10,000
[End of Phase 5]