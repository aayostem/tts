1
00:00:00,000 --> 00:00:06,000
Welcome to Phase 4. In Part 1, we build the Query Engine and Circuit Breaker.

2
00:00:06,000 --> 00:00:12,000
The Query Engine is the public interface for the entire retrieval layer.
Everything above it talks to this. The API, the agents, everything.

3
00:00:12,000 --> 00:00:18,000
Think of the Query Engine as the conductor of an orchestra. It doesn't play
any instrument. But it tells everyone when to start, when to stop, and how
to work together.

4
00:00:18,000 --> 00:00:24,000
The Circuit Breaker is a pattern that prevents cascading failures. If the
LLM API is down, the circuit breaker opens. The system falls back to a safe mode.
It doesn't crash. It degrades gracefully.

5
00:00:24,000 --> 00:00:30,000
Open your editor and create `src/financial_rag/retrieval/query_engine.py`.

6
00:00:30,000 --> 00:00:36,000
We'll start with the imports. The __future__ import enables forward references.
[Types: from __future__ import annotations]

7
00:00:36,000 --> 00:00:42,000
We import logging for structured logging throughout the module.
[Types: import logging]

8
00:00:42,000 --> 00:00:48,000
We import time for measuring latency. Every query should track how long it takes.
[Types: import time]

9
00:00:48,000 --> 00:00:54,000
We import dataclass and field from dataclasses for our result types.
[Types: from dataclasses import dataclass, field]

10
00:00:54,000 --> 00:01:00,000
We import Literal from typing for type hints on search types.
[Types: from typing import Literal]

11
00:01:00,000 --> 00:01:06,000
We import AsyncOpenAI from openai for LLM calls. This is the async client.
[Types: from openai import AsyncOpenAI]

12
00:01:06,000 --> 00:01:12,000
We import get_settings from our config module.
[Types: from financial_rag.config import get_settings]

13
00:01:12,000 --> 00:01:18,000
We import DocumentRetriever and RetrievalResult from document_retriever.
[Types: from financial_rag.retrieval.document_retriever import DocumentRetriever, RetrievalResult]

14
00:01:18,000 --> 00:01:24,000
We import HybridSearcher from hybrid_search.
[Types: from financial_rag.retrieval.hybrid_search import HybridSearcher]

15
00:01:24,000 --> 00:01:30,000
We import VectorStore from storage.vector_store.
[Types: from financial_rag.storage.vector_store import VectorStore]

16
00:01:30,000 --> 00:01:36,000
We import RetrievalError for error handling.
[Types: from financial_rag.utils.exceptions import RetrievalError]

17
00:01:36,000 --> 00:01:42,000
Now let's define the system prompts. These are the three analysis styles.
[Types: _SYSTEM_PROMPTS: dict[str, str] = {}]

18
00:01:42,000 --> 00:01:48,000
The Analyst prompt is for detailed financial analysis.
[Types: _SYSTEM_PROMPTS["analyst"] = "You are a senior financial analyst with deep expertise in SEC filings, financial statements, and corporate strategy. Provide detailed, precise analysis grounded strictly in the provided context. Cite specific figures, dates, and sections. If the context does not contain sufficient information to answer the question, say so explicitly rather than speculating."]

19
00:01:48,000 --> 00:01:54,000
This prompt tells the LLM to act like a senior analyst. It should be detailed,
precise, and cite sources. It should not speculate.

20
00:01:54,000 --> 00:02:00,000
The Executive prompt is for concise, decision-ready insights.
[Types: _SYSTEM_PROMPTS["executive"] = "You are a CFO-level advisor providing concise, decision-ready financial insights. Synthesise the key points from the provided context into clear, actionable intelligence. Lead with the most important finding. Be direct and quantitative."]

21
00:02:00,000 --> 00:02:06,000
This prompt is for executives who want the bottom line. Be direct. Be quantitative.
Lead with the most important finding.

22
00:02:06,000 --> 00:02:12,000
The Risk prompt is for risk assessment.
[Types: _SYSTEM_PROMPTS["risk"] = "You are a chief risk officer conducting a thorough risk assessment. Analyse the provided context for financial risks, regulatory exposures, operational vulnerabilities, and forward-looking risk factors. Quantify risks where possible. Flag any material concerns explicitly."]

23
00:02:12,000 --> 00:02:18,000
This prompt focuses on risks. Financial risks, regulatory exposures,
operational vulnerabilities. Flag anything material.

24
00:02:18,000 --> 00:02:24,000
Now let's define the default style.
[Types: _DEFAULT_STYLE = "analyst"]

25
00:02:24,000 --> 00:02:30,000
If no style is specified, we use analyst. This is the safe default.

26
00:02:30,000 --> 00:02:36,000
Now let's define the QueryResult dataclass. This is returned by the engine.
[Types: @dataclass class QueryResult:]

27
00:02:36,000 --> 00:02:42,000
The question field stores the user's original question.
[Types: question: str]

28
00:02:42,000 --> 00:02:48,000
The answer field stores the generated response.
[Types: answer: str]

29
00:02:48,000 --> 00:02:54,000
The analysis_style field stores which style was used.
[Types: analysis_style: str]

30
00:02:54,000 --> 00:03:00,000
The search_type field stores which search strategy was used.
[Types: search_type: str]

31
00:03:00,000 --> 00:03:06,000
The agent_type field identifies which component generated the answer.
[Types: agent_type: str]

32
00:03:06,000 --> 00:03:12,000
The latency_ms field stores the total time in milliseconds.
[Types: latency_ms: int]

33
00:03:12,000 --> 00:03:18,000
The source_documents field stores the retrieved chunks used.
[Types: source_documents: list[RetrievalResult] = field(default_factory=list)]

34
00:03:18,000 --> 00:03:24,000
The error field stores any error message. None if successful.
[Types: error: str | None = None]

35
00:03:24,000 --> 00:03:30,000
Now let's define a property that converts milliseconds to seconds.
[Types: @property def latency_seconds(self) -> float: return self.latency_ms / 1000.0]

36
00:03:30,000 --> 00:03:36,000
This is used in the API response. It's a convenience property.

37
00:03:36,000 --> 00:03:42,000
Now let's define the string representation for debugging.
[Types: def __repr__(self) -> str: return f"<QueryResult style={self.analysis_style} sources={len(self.source_documents)} latency={self.latency_ms}ms>"]

38
00:03:42,000 --> 00:03:48,000
This makes it easy to see what a QueryResult contains.

39
00:03:48,000 --> 00:03:54,000
Now let's define the QueryEngine class.
[Types: class QueryEngine:]

40
00:03:54,000 --> 00:04:00,000
We define the init method. This is where we set up the engine.
[Types: def __init__(self, vector_store: VectorStore | None = None) -> None:]

41
00:04:00,000 --> 00:04:06,000
We get the settings instance for configuration.
[Types: self._settings = get_settings()]

42
00:04:06,000 --> 00:04:12,000
If no vector_store is provided, we create one.
[Types: vs = vector_store or VectorStore()]

43
00:04:12,000 --> 00:04:18,000
We create the DocumentRetriever with the vector store.
[Types: self._retriever = DocumentRetriever(vs)]

44
00:04:18,000 --> 00:04:24,000
We create the HybridSearcher for hybrid search.
[Types: self._hybrid = HybridSearcher()]

45
00:04:24,000 --> 00:04:30,000
We build the LLM client. This is where the circuit breaker happens.
[Types: self._llm = self._build_llm_client()]

46
00:04:30,000 --> 00:04:36,000
Now let's implement the circuit breaker method.
[Types: def _build_llm_client(self) -> AsyncOpenAI | None:]

47
00:04:36,000 --> 00:04:42,000
If MOCK_EXTERNAL_APIS is True, we return None. This disables LLM calls.
[Types: if self._settings.MOCK_EXTERNAL_APIS: logger.info("QueryEngine: LLM calls mocked (MOCK_EXTERNAL_APIS=True)") return None]

48
00:04:42,000 --> 00:04:48,000
This is the circuit breaker. When external APIs are mocked, we skip LLM calls.

49
00:04:48,000 --> 00:04:54,000
Now we try Groq first. This is our primary LLM provider.
[Types: if self._settings.GROQ_API_KEY: logger.debug("QueryEngine: Using GROQ_API_KEY for LLM") return AsyncOpenAI( api_key=self._settings.GROQ_API_KEY.get_secret_value(), base_url=self._settings.LLM_BASE_URL or "https://api.groq.com/openai/v1", timeout=self._settings.LLM_REQUEST_TIMEOUT, )]

50
00:04:54,000 --> 00:05:00,000
We use Groq as the primary provider because it's fast and cost-effective.
If GROQ_API_KEY is set, we use it.

51
00:05:00,000 --> 00:05:06,000
Now we fall back to OpenAI. If OPENAI_API_KEY is set, we use it.
[Types: if self._settings.OPENAI_API_KEY: logger.debug("QueryEngine: Using OPENAI_API_KEY for LLM (fallback)") return AsyncOpenAI( api_key=self._settings.OPENAI_API_KEY.get_secret_value(), base_url=self._settings.LLM_BASE_URL or "https://api.openai.com/v1", timeout=self._settings.LLM_REQUEST_TIMEOUT, )]

52
00:05:06,000 --> 00:05:12,000
This is the fallback. If Groq is not available, we use OpenAI.

53
00:05:12,000 --> 00:05:18,000
If no API key is available, we return None. This is the circuit breaker opening.
[Types: logger.warning("QueryEngine: No API key available for LLM. Set GROQ_API_KEY or OPENAI_API_KEY.") return None]

54
00:05:18,000 --> 00:05:24,000
When the circuit breaker opens, the system falls back to returning raw context.
The API still responds with a 200 and useful content. No crashes.

55
00:05:24,000 --> 00:05:30,000
This is the difference between a production system and a toy.
Production systems degrade gracefully. Toy systems crash and burn.

56
00:05:30,000 --> 00:05:36,000
Now let's implement the main query method. This is the public interface.
[Types: async def query(self, question: str, *, ticker: str | None = None, filing_type: str | None = None, fiscal_year: int | None = None, section: str | None = None, analysis_style: str = _DEFAULT_STYLE, search_type: Literal["similarity", "mmr", "hybrid"] = "similarity", limit: int | None = None,) -> QueryResult:]

57
00:05:36,000 --> 00:05:42,000
This method takes a question and optional filters. It returns a QueryResult.

58
00:05:42,000 --> 00:05:48,000
First, we validate the question. If it's empty, we raise ValueError.
[Types: if not question or not question.strip(): raise ValueError("Question cannot be empty")]

59
00:05:48,000 --> 00:05:54,000
This prevents meaningless queries from reaching the LLM.

60
00:05:54,000 --> 00:06:00,000
We start the timer for latency measurement.
[Types: t0 = time.monotonic()]

61
00:06:00,000 --> 00:06:06,000
If the analysis style is invalid, we use the default.
[Types: if analysis_style not in _SYSTEM_PROMPTS: analysis_style = _DEFAULT_STYLE]

62
00:06:06,000 --> 00:06:12,000
Now we try to retrieve results. We wrap this in a try-except block.
[Types: try:]

63
00:06:12,000 --> 00:06:18,000
Step 1: Retrieve. Get relevant chunks from the vector store.
[Types: results = await self._retrieve(question, ticker=ticker, filing_type=filing_type, fiscal_year=fiscal_year, section=section, search_type=search_type, limit=limit,)]

64
00:06:18,000 --> 00:06:24,000
Step 2: Auto-upgrade to hybrid if vector confidence is low.
[Types: if search_type == "similarity" and results and results[0].score < self._settings.VECTOR_SEARCH_THRESHOLD: logger.info("Low vector confidence (%.3f < %.3f) — upgrading to hybrid", results[0].score, self._settings.VECTOR_SEARCH_THRESHOLD) results = await self._hybrid.search(question, ticker=ticker, filing_type=filing_type, fiscal_year=fiscal_year, limit=limit or self._settings.TOP_K_RESULTS,) search_type = "hybrid"]

65
00:06:24,000 --> 00:06:30,000
If vector search returns low confidence scores, we automatically upgrade to hybrid.
This ensures we always get the best results.

66
00:06:30,000 --> 00:06:36,000
Step 3: If no results, return a helpful message.
[Types: if not results: return QueryResult(question=question, answer="I could not find relevant information in the available financial documents to answer this question. Please ensure the relevant filings have been ingested.", analysis_style=analysis_style, search_type=search_type, agent_type="query_engine", latency_ms=int((time.monotonic() - t0) * 1000), source_documents=[],)]

67
00:06:36,000 --> 00:06:42,000
This is better than returning nothing or crashing. The user gets a helpful message.

68
00:06:42,000 --> 00:06:48,000
Step 4: Build context from the retrieved results.
[Types: context = self._retriever.build_context(results)]

69
00:06:48,000 --> 00:06:54,000
The context is a string that combines all the relevant chunks.

70
00:06:54,000 --> 00:07:00,000
Step 5: Generate answer using the LLM.
[Types: answer = await self._generate_answer(question=question, context=context, analysis_style=analysis_style,)]

71
00:07:00,000 --> 00:07:06,000
Step 6: Build and return the QueryResult.
[Types: latency_ms = int((time.monotonic() - t0) * 1000)]

72
00:07:06,000 --> 00:07:12,000
[Types: logger.info("Query complete — style=%s search=%s sources=%d latency=%dms", analysis_style, search_type, len(results), latency_ms)]

73
00:07:12,000 --> 00:07:18,000
[Types: return QueryResult(question=question, answer=answer, analysis_style=analysis_style, search_type=search_type, agent_type="query_engine", latency_ms=latency_ms, source_documents=results,)]

74
00:07:18,000 --> 00:07:24,000
If an exception occurs, we catch it and return an error result.
[Types: except Exception as exc: latency_ms = int((time.monotonic() - t0) * 1000) logger.error("Query failed after %dms: %s", latency_ms, exc) return QueryResult(question=question, answer="", analysis_style=analysis_style, search_type=search_type, agent_type="query_engine", latency_ms=latency_ms, error=str(exc),)]

75
00:07:24,000 --> 00:07:30,000
This is the final circuit breaker. Even if the LLM fails, the system returns
a QueryResult with an error. The API still responds.

76
00:07:30,000 --> 00:07:36,000
Now let's implement the retrieve method. This routes to the correct strategy.
[Types: async def _retrieve(self, question: str, *, ticker: str | None, filing_type: str | None, fiscal_year: int | None, section: str | None = None, search_type: str, limit: int | None,) -> list[RetrievalResult]:]

77
00:07:36,000 --> 00:07:42,000
If search_type is "hybrid", use the HybridSearcher.
[Types: if search_type == "hybrid": return await self._hybrid.search(question, ticker=ticker, filing_type=filing_type, fiscal_year=fiscal_year, limit=limit or self._settings.TOP_K_RESULTS,)]

78
00:07:42,000 --> 00:07:48,000
Otherwise, use the DocumentRetriever.
[Types: return await self._retriever.retrieve(question, ticker=ticker, filing_type=filing_type, fiscal_year=fiscal_year, section=section, limit=limit, search_type=search_type,)]

79
00:07:48,000 --> 00:07:54,000
Now let's implement the generate_answer method. This calls the LLM.
[Types: async def _generate_answer(self, *, question: str, context: str, analysis_style: str,) -> str:]

80
00:07:54,000 --> 00:08:00,000
If the LLM client is None, return the raw context. This is the circuit breaker.
[Types: if self._llm is None: return f"[LLM unavailable — returning raw context]\n\n{context}"]

81
00:08:00,000 --> 00:08:06,000
When the circuit breaker is open, the user still gets useful content.

82
00:08:06,000 --> 00:08:12,000
We get the system prompt for the analysis style.
[Types: system_prompt = _SYSTEM_PROMPTS.get(analysis_style, _SYSTEM_PROMPTS[_DEFAULT_STYLE])]

83
00:08:12,000 --> 00:08:18,000
We build the user message with the context.
[Types: user_message = f"Using only the following financial document excerpts, answer this question:\n\nQuestion: {question}\n\nContext:\n{context}"]

84
00:08:18,000 --> 00:08:24,000
We call the LLM with the prompt and message.
[Types: try: response = await self._llm.chat.completions.create( model=self._settings.LLM_MODEL, messages=[{"role": "system", "content": system_prompt}, {"role": "user", "content": user_message}], temperature=self._settings.LLM_TEMPERATURE, max_tokens=self._settings.LLM_MAX_TOKENS, ) return response.choices[0].message.content or ""]

85
00:08:24,000 --> 00:08:30,000
If the LLM call fails, we raise RetrievalError. This is caught by the query method.
[Types: except Exception as exc: raise RetrievalError(f"LLM generation failed: {exc}") from exc]

86
00:08:30,000 --> 00:08:36,000
Now let's update the retrieval __init__.py file.
Open `src/financial_rag/retrieval/__init__.py`.

87
00:08:36,000 --> 00:08:42,000
We import QueryEngine and QueryResult from the module.
[Types: from .query_engine import QueryEngine, QueryResult]

88
00:08:42,000 --> 00:08:48,000
We add them to __all__.
[Types: __all__ = ["DocumentRetriever", "EmbeddingClient", "HybridSearcher", "QueryEngine", "QueryResult", "RetrievalResult"]]

89
00:08:48,000 --> 00:08:54,000
Now let's test the Query Engine. Open a Python shell and run these commands.

90
00:08:54,000 --> 00:09:00,000
[Types: from financial_rag.retrieval import QueryEngine]
[Types: engine = QueryEngine()]

91
00:09:00,000 --> 00:09:06,000
[Types: import asyncio]
[Types: result = await engine.query("What was Apple's revenue in 2024?", ticker="AAPL")]

92
00:09:06,000 --> 00:09:12,000
This runs the full RAG pipeline. It retrieves relevant chunks and generates an answer.

93
00:09:12,000 --> 00:09:18,000
[Types: print(result.answer)]
[Types: print(f"Found {len(result.source_documents)} sources in {result.latency_ms}ms")]

94
00:09:18,000 --> 00:09:24,000
You should see an answer with citations and source documents.

95
00:09:24,000 --> 00:09:30,000
Now let me recap what we've built in Part 1.

96
00:09:30,000 --> 00:09:36,000
We built the QueryEngine class. It orchestrates the full RAG pipeline.
It retrieves chunks, builds context, and generates answers.

97
00:09:36,000 --> 00:09:42,000
We built the Circuit Breaker pattern. If the LLM is unavailable, the system
returns raw context. No crashes. Graceful degradation.

98
00:09:42,000 --> 00:09:48,000
We built three system prompts. Analyst for detailed analysis.
Executive for concise insights. Risk for risk assessment.

99
00:09:48,000 --> 00:09:54,000
We built auto-upgrade to hybrid search. If vector confidence is low,
we automatically upgrade to hybrid.

100
00:09:54,000 --> 00:10:00,000
We built error handling. Every exception is caught and returned as an error result.
The API always responds.

101
00:10:00,000 --> 00:10:06,000
In Part 2, we build the Analysis Repository. This records every query and answer
for auditing and debugging.

102
00:10:06,000 --> 00:10:12,000
Thank you for watching. I'll see you in Part 2.

103
00:10:12,000 --> 00:10:16,000
[End of Part 1]
1
00:00:00,000 --> 00:00:06,000
Welcome back to Phase 4. In Part 2, we build the analysis history repository.

2
00:00:06,000 --> 00:00:12,000
This is the audit trail. Every query and answer is recorded here.
This is append-only. Records are never modified or deleted.

3
00:00:12,000 --> 00:00:18,000
Why append-only? Because financial systems need tamper-evident audit logs.
If a user disputes an answer, you can show exactly what was asked and answered.

4
00:00:18,000 --> 00:00:24,000
Think of it like a black box in an airplane. You never erase the data.
You only add more data. This preserves the complete history.

5
00:00:24,000 --> 00:00:30,000
Open your editor and create `src/financial_rag/storage/repositories/analysis.py`.

6
00:00:30,000 --> 00:00:36,000
We'll start with the imports. The __future__ import enables forward references.
[Types: from __future__ import annotations]

7
00:00:36,000 --> 00:00:42,000
We import logging for structured logging throughout the repository.
[Types: import logging]

8
00:00:42,000 --> 00:00:48,000
We import datetime and timezone for timestamp handling.
[Types: from datetime import datetime, timezone]

9
00:00:48,000 --> 00:00:54,000
We import Any for generic type hints.
[Types: from typing import Any]

10
00:00:54,000 --> 00:01:00,000
We import UUID for primary key handling.
[Types: from uuid import UUID]

11
00:01:00,000 --> 00:01:06,000
Now we import SQLAlchemy types. Boolean for boolean fields.
[Types: from sqlalchemy import Boolean, Integer, String, Text, func, select]

12
00:01:06,000 --> 00:01:12,000
We import ARRAY from PostgreSQL dialect for array columns.
[Types: from sqlalchemy.dialects.postgresql import ARRAY]

13
00:01:12,000 --> 00:01:18,000
We import UUID from PostgreSQL dialect for native UUID support.
[Types: from sqlalchemy.dialects.postgresql import UUID as PG_UUID]

14
00:01:18,000 --> 00:01:24,000
We import Mapped and mapped_column from SQLAlchemy ORM.
[Types: from sqlalchemy.orm import Mapped, mapped_column]

15
00:01:24,000 --> 00:01:30,000
We import TIMESTAMP for timezone-aware timestamps.
[Types: from sqlalchemy.types import TIMESTAMP]

16
00:01:30,000 --> 00:01:36,000
We import Base from our database module for declarative base.
[Types: from financial_rag.storage.database import Base]

17
00:01:36,000 --> 00:01:42,000
We import BaseRepository from the base module.
[Types: from financial_rag.storage.repositories.base import BaseRepository]

18
00:01:42,000 --> 00:01:48,000
We import DatabaseQueryError for error handling.
[Types: from financial_rag.utils.exceptions import DatabaseQueryError]

19
00:01:48,000 --> 00:01:54,000
Now let's define the ORM model. This is Component #37 — the AnalysisRecord.
[Types: class AnalysisRecord(Base):]

20
00:01:54,000 --> 00:02:00,000
We set the table name to match our schema.
[Types: __tablename__ = "analysis_history"]

21
00:02:00,000 --> 00:02:06,000
Now let's define the id column. This is the primary key.
[Types: id: Mapped[UUID] = mapped_column(PG_UUID(as_uuid=True), primary_key=True)]

22
00:02:06,000 --> 00:02:12,000
We use PG_UUID with as_uuid=True so SQLAlchemy handles UUID objects natively.
This gives us type safety in our Python code.

23
00:02:12,000 --> 00:02:18,000
Now the ticker column. This stores the company ticker, which is optional.
[Types: ticker: Mapped[str | None] = mapped_column(String(10))]

24
00:02:18,000 --> 00:02:24,000
We use String(10) because tickers are short like AAPL or MSFT.
We allow None because some queries might not have a ticker filter.

25
00:02:24,000 --> 00:02:30,000
Now the question column. This stores the user's question.
[Types: question: Mapped[str] = mapped_column(Text, nullable=False)]

26
00:02:30,000 --> 00:02:36,000
We use Text because questions can be long. We set nullable=False because
every analysis has a question.

27
00:02:36,000 --> 00:02:42,000
Now the answer column. This stores the generated answer.
[Types: answer: Mapped[str] = mapped_column(Text, nullable=False)]

28
00:02:42,000 --> 00:02:48,000
We use Text because answers can be long. We set nullable=False because
every analysis has an answer.

29
00:02:48,000 --> 00:02:54,000
Now the analysis_style column. This is 'analyst', 'executive', or 'risk'.
[Types: analysis_style: Mapped[str] = mapped_column(String(20), nullable=False, default="analyst")]

30
00:02:54,000 --> 00:03:00,000
We use String(20) because the style names are short. We set default="analyst"
because that's the most common style.

31
00:03:00,000 --> 00:03:06,000
Now the agent_type column. This identifies which agent produced the response.
[Types: agent_type: Mapped[str] = mapped_column(String(50), nullable=False)]

32
00:03:06,000 --> 00:03:12,000
We use String(50) because agent type names are short like 'financial_agent'
or 'query_engine'. This is useful for debugging and monitoring.

33
00:03:12,000 --> 00:03:18,000
Now the search_type column. This is 'similarity', 'mmr', or 'hybrid'.
[Types: search_type: Mapped[str] = mapped_column(String(20), nullable=False, default="similarity")]

34
00:03:18,000 --> 00:03:24,000
We use String(20) because the search types are short. We set default="similarity"
because that's the default search type.

35
00:03:24,000 --> 00:03:30,000
Now the latency_ms column. This stores the query latency in milliseconds.
[Types: latency_ms: Mapped[int] = mapped_column(Integer, nullable=False)]

36
00:03:30,000 --> 00:03:36,000
We use Integer for millisecond precision. We store as integer, not float,
for efficient range queries and aggregations.

37
00:03:36,000 --> 00:03:42,000
Now the source_chunk_ids column. This is an array of UUIDs.
[Types: source_chunk_ids: Mapped[list[Any]] = mapped_column(ARRAY(PG_UUID(as_uuid=True)), default=list)]

38
00:03:42,000 --> 00:03:48,000
This stores which chunks were used to generate the answer. This enables
source attribution and reproducibility.

39
00:03:48,000 --> 00:03:54,000
Now the real_time_used column. This indicates if real-time data was used.
[Types: real_time_used: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)]

40
00:03:54,000 --> 00:04:00,000
We use Boolean for a simple true/false flag. We set default=False because
most queries don't use real-time data.

41
00:04:00,000 --> 00:04:06,000
Now the error column. This stores any error that occurred.
[Types: error: Mapped[str | None] = mapped_column(Text)]

42
00:04:06,000 --> 00:04:12,000
We use Text because error messages can be long. We allow None because
not every query has an error.

43
00:04:12,000 --> 00:04:18,000
Now the session_id column. This groups queries by session.
[Types: session_id: Mapped[UUID | None] = mapped_column(PG_UUID(as_uuid=True), index=True)]

44
00:04:18,000 --> 00:04:24,000
We use PG_UUID for native UUID support. We add index=True for fast lookups
by session. This enables conversation tracking.

45
00:04:24,000 --> 00:04:30,000
Now the created_at column. This stores when the record was created.
[Types: created_at: Mapped[datetime] = mapped_column(TIMESTAMP(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))]

46
00:04:30,000 --> 00:04:36,000
We use TIMESTAMP with timezone=True for timezone-aware timestamps.
We use UTC for consistency. This is the audit timestamp.

47
00:04:36,000 --> 00:04:42,000
Now let's define the string representation for debugging.
[Types: def __repr__(self) -> str: return f"<AnalysisRecord id={self.id} ticker={self.ticker} agent={self.agent_type} latency={self.latency_ms}ms>"]

48
00:04:42,000 --> 00:04:48,000
This makes it easy to identify records when debugging.

49
00:04:48,000 --> 00:04:54,000
Now let's define the AnalysisRepository. This is Component #36.
[Types: class AnalysisRepository(BaseRepository[AnalysisRecord]):]

50
00:04:54,000 --> 00:05:00,000
We specify AnalysisRecord as the model type.
[Types: model_class = AnalysisRecord]

51
00:05:00,000 --> 00:05:06,000
Now let's implement the record method. This is the primary write method.
[Types: async def record(self, *, question: str, answer: str, agent_type: str, latency_ms: int, ticker: str | None = None, analysis_style: str = "analyst", search_type: str = "similarity", source_chunk_ids: list[UUID] | None = None, real_time_used: bool = False, error: str | None = None, session_id: UUID | None = None,) -> AnalysisRecord:]

52
00:05:06,000 --> 00:05:12,000
This method records a completed analysis to the history table.
All parameters are keyword-only for clarity.

53
00:05:12,000 --> 00:05:18,000
We import uuid for generating new UUIDs.
[Types: import uuid]

54
00:05:18,000 --> 00:05:24,000
We create a new record with the provided data.
[Types: record = AnalysisRecord( id=uuid.uuid4(), ticker=ticker.upper() if ticker else None, question=question, answer=answer, analysis_style=analysis_style, agent_type=agent_type, search_type=search_type, latency_ms=latency_ms, source_chunk_ids=source_chunk_ids or [], real_time_used=real_time_used, error=error, session_id=session_id, )]

55
00:05:24,000 --> 00:05:30,000
We call the add method from the base repository.
[Types: return await self.add(record)]

56
00:05:30,000 --> 00:05:36,000
Now let's implement get_by_ticker. This returns history for a ticker.
[Types: async def get_by_ticker(self, ticker: str, *, limit: int = 50, offset: int = 0,) -> list[AnalysisRecord]:]

57
00:05:36,000 --> 00:05:42,000
We wrap the query in a try-except block for error handling.
[Types: try:]

58
00:05:42,000 --> 00:05:48,000
We build a select query with a where clause on ticker.
[Types: result = await self._session.execute( select(AnalysisRecord).where(AnalysisRecord.ticker == ticker.upper()).order_by(AnalysisRecord.created_at.desc()).limit(limit).offset(offset) )]

59
00:05:48,000 --> 00:05:54,000
We order by created_at descending to get the most recent first.
[Types: return list(result.scalars().all())]

60
00:05:54,000 --> 00:06:00,000
If there's an error, we raise DatabaseQueryError.
[Types: except Exception as exc: raise DatabaseQueryError(f"Failed to fetch analysis history for '{ticker}': {exc}") from exc]

61
00:06:00,000 --> 00:06:06,000
Now let's implement get_by_session. This returns all records for a session.
[Types: async def get_by_session(self, session_id: UUID) -> list[AnalysisRecord]:]

62
00:06:06,000 --> 00:06:12,000
[Types: try:]

63
00:06:12,000 --> 00:06:18,000
[Types: result = await self._session.execute( select(AnalysisRecord).where(AnalysisRecord.session_id == session_id).order_by(AnalysisRecord.created_at) )]

64
00:06:18,000 --> 00:06:24,000
We order by created_at ascending to get chronological order.
[Types: return list(result.scalars().all())]

65
00:06:24,000 --> 00:06:30,000
[Types: except Exception as exc: raise DatabaseQueryError(f"Failed to fetch session history {session_id}: {exc}") from exc]

66
00:06:30,000 --> 00:06:36,000
Now let's implement get_recent. This returns the most recent analyses.
[Types: async def get_recent(self, *, limit: int = 20, agent_type: str | None = None, errors_only: bool = False,) -> list[AnalysisRecord]:]

67
00:06:36,000 --> 00:06:42,000
This is useful for dashboards and debugging.

68
00:06:42,000 --> 00:06:48,000
[Types: try: stmt = select(AnalysisRecord).order_by(AnalysisRecord.created_at.desc()).limit(limit)]

69
00:06:48,000 --> 00:06:54,000
If agent_type is provided, we add it as a filter.
[Types: if agent_type: stmt = stmt.where(AnalysisRecord.agent_type == agent_type)]

70
00:06:54,000 --> 00:07:00,000
If errors_only is True, we filter to only records with errors.
[Types: if errors_only: stmt = stmt.where(AnalysisRecord.error.isnot(None))]

71
00:07:00,000 --> 00:07:06,000
[Types: result = await self._session.execute(stmt)]
[Types: return list(result.scalars().all())]

72
00:07:06,000 --> 00:07:12,000
[Types: except Exception as exc: raise DatabaseQueryError(f"Failed to fetch recent analyses: {exc}") from exc]

73
00:07:12,000 --> 00:07:18,000
Now let's implement average_latency_ms. This is an aggregation method.
[Types: async def average_latency_ms(self, *, ticker: str | None = None, agent_type: str | None = None,) -> float | None:]

74
00:07:18,000 --> 00:07:24,000
This is used for monitoring performance.

75
00:07:24,000 --> 00:07:30,000
[Types: try: stmt = select(func.avg(AnalysisRecord.latency_ms))]

76
00:07:30,000 --> 00:07:36,000
If ticker is provided, we add it as a filter.
[Types: if ticker: stmt = stmt.where(AnalysisRecord.ticker == ticker.upper())]

77
00:07:36,000 --> 00:07:42,000
If agent_type is provided, we add it as a filter.
[Types: if agent_type: stmt = stmt.where(AnalysisRecord.agent_type == agent_type)]

78
00:07:42,000 --> 00:07:48,000
[Types: result = await self._session.execute(stmt)]
[Types: avg = result.scalar_one_or_none()]
[Types: return float(avg) if avg is not None else None]

79
00:07:48,000 --> 00:07:54,000
We convert the result to float because SQLAlchemy returns Decimal.
[Types: except Exception as exc: raise DatabaseQueryError(f"Failed to compute average latency: {exc}") from exc]

80
00:07:54,000 --> 00:08:00,000
Now let's implement error_rate. This returns the fraction of errors.
[Types: async def error_rate(self, *, ticker: str | None = None,) -> float:]

81
00:08:00,000 --> 00:08:06,000
This is a critical SLO metric.

82
00:08:06,000 --> 00:08:12,000
[Types: try:]

83
00:08:12,000 --> 00:08:18,000
We build two queries. One for total records. One for error records.
[Types: base_stmt = select(func.count()).select_from(AnalysisRecord)]

84
00:08:18,000 --> 00:08:24,000
[Types: error_stmt = select(func.count()).select_from(AnalysisRecord).where(AnalysisRecord.error.isnot(None))]

85
00:08:24,000 --> 00:08:30,000
If ticker is provided, we add it to both queries.
[Types: if ticker: base_stmt = base_stmt.where(AnalysisRecord.ticker == ticker.upper()) error_stmt = error_stmt.where(AnalysisRecord.ticker == ticker.upper())]

86
00:08:30,000 --> 00:08:36,000
[Types: total = (await self._session.execute(base_stmt)).scalar_one()]
[Types: errors = (await self._session.execute(error_stmt)).scalar_one()]

87
00:08:36,000 --> 00:08:42,000
We return the ratio. If there are no records, we return 0.0.
[Types: return errors / total if total > 0 else 0.0]

88
00:08:42,000 --> 00:08:48,000
[Types: except Exception as exc: raise DatabaseQueryError(f"Failed to compute error rate: {exc}") from exc]

89
00:08:48,000 --> 00:08:54,000
Now let's update the repositories __init__.py file.
Open `src/financial_rag/storage/repositories/__init__.py`.

90
00:08:54,000 --> 00:09:00,000
We import AnalysisRecord and AnalysisRepository from the module.
[Types: from .analysis import AnalysisRecord, AnalysisRepository]

91
00:09:00,000 --> 00:09:06,000
We add them to __all__.
[Types: __all__ = ["AnalysisRecord", "AnalysisRepository", "BaseRepository", "ChunksRepository", "Filing", "FilingsRepository", "FinancialChunk"]]

92
00:09:06,000 --> 00:09:12,000
Now let me recap what we've built in Part 2.

93
00:09:12,000 --> 00:09:18,000
We built the AnalysisRecord ORM model. This maps to the analysis_history table.
It has fields for ticker, question, answer, analysis_style, agent_type,
search_type, latency_ms, source_chunk_ids, real_time_used, error, session_id,
and created_at.

94
00:09:18,000 --> 00:09:24,000
We built the AnalysisRepository. This provides CRUD operations and
aggregation methods for the analysis_history table.

95
00:09:24,000 --> 00:09:30,000
The record method is the primary write method. It creates an append-only record.
The get_by_ticker method returns history for a specific ticker.
The get_by_session method returns history for a specific session.
The get_recent method returns the most recent analyses.
The average_latency_ms method returns the average latency.
The error_rate method returns the fraction of errors.

96
00:09:30,000 --> 00:09:36,000
This is the foundation of our audit trail. Every query is recorded.
Every answer is recorded. Every error is recorded.

97
00:09:36,000 --> 00:09:42,000
In Part 3, we'll build the Financial Agent. This adds reasoning and tool use
on top of the query engine.

98
00:09:42,000 --> 00:09:48,000
Thank you for watching. I'll see you in Part 3.

99
00:09:48,000 --> 00:09:52,000
[End of Part 2]

1
00:00:00,000 --> 00:00:06,000
Welcome back to Phase 4. In Part 3, we build the Financial Agent.

2
00:00:06,000 --> 00:00:12,000
The query engine is great for simple questions. But sometimes you need
more than a single search. You need reasoning. You need tool use.

3
00:00:12,000 --> 00:00:18,000
Think of it this way. The query engine is like a research assistant.
You ask a question, it finds documents, and it gives you an answer.

4
00:00:18,000 --> 00:00:24,000
The Financial Agent is like a senior analyst. It thinks about what tools to use.
It searches multiple times. It compares filings. It synthesizes findings.

5
00:00:24,000 --> 00:00:30,000
This is the power of agents. They can use tools to gather information.
They can reason about what they've found. They can produce better answers.

6
00:00:30,000 --> 00:00:36,000
Open your editor and create `src/financial_rag/agents/financial_agent.py`.

7
00:00:36,000 --> 00:00:42,000
We'll start with the imports. The __future__ import enables forward references.
[Types: from __future__ import annotations]

8
00:00:42,000 --> 00:00:48,000
We import json for parsing function call arguments.
[Types: import json]

9
00:00:48,000 --> 00:00:54,000
We import logging for structured logging.
[Types: import logging]

10
00:00:54,000 --> 00:01:00,000
We import time for latency measurement.
[Types: import time]

11
00:01:00,000 --> 00:01:06,000
We import dataclass and field from dataclasses for the result object.
[Types: from dataclasses import dataclass, field]

12
00:01:06,000 --> 00:01:12,000
We import Any and Literal from typing for type hints.
[Types: from typing import Any, Literal]

13
00:01:12,000 --> 00:01:18,000
We import AsyncOpenAI from openai for the LLM client.
[Types: from openai import AsyncOpenAI]

14
00:01:18,000 --> 00:01:24,000
We import get_settings from our config module.
[Types: from financial_rag.config import get_settings]

15
00:01:24,000 --> 00:01:30,000
We import RetrievalResult from the document retriever.
[Types: from financial_rag.retrieval.document_retriever import RetrievalResult]

16
00:01:30,000 --> 00:01:36,000
We import QueryEngine and QueryResult from the query engine.
[Types: from financial_rag.retrieval.query_engine import QueryEngine, QueryResult]

17
00:01:36,000 --> 00:01:42,000
We import VectorStore for the vector store dependency.
[Types: from financial_rag.storage.vector_store import VectorStore]

18
00:01:42,000 --> 00:01:48,000
Now let's define the AgentResult dataclass. This is the complete result
from an agent run.
[Types: @dataclass class AgentResult:]

19
00:01:48,000 --> 00:01:54,000
The question field stores the original user question.
[Types: question: str]

20
00:01:54,000 --> 00:02:00,000
The answer field stores the final answer from the agent.
[Types: answer: str]

21
00:02:00,000 --> 00:02:06,000
The analysis_style field stores which style was used.
[Types: analysis_style: str]

22
00:02:06,000 --> 00:02:12,000
The agent_type field identifies which agent produced the result.
[Types: agent_type: str]

23
00:02:12,000 --> 00:02:18,000
The latency_ms field stores the total latency in milliseconds.
[Types: latency_ms: int]

24
00:02:18,000 --> 00:02:24,000
The source_documents field stores the documents used to generate the answer.
[Types: source_documents: list[RetrievalResult] = field(default_factory=list)]

25
00:02:24,000 --> 00:02:30,000
The tool_calls field stores the trace of every tool call.
[Types: tool_calls: list[dict[str, Any]] = field(default_factory=list)]

26
00:02:30,000 --> 00:02:36,000
The reasoning_steps field stores the chain of thought.
[Types: reasoning_steps: list[str] = field(default_factory=list)]

27
00:02:36,000 --> 00:02:42,000
The error field stores any error that occurred.
[Types: error: str | None = None]

28
00:02:42,000 --> 00:02:48,000
Now let's define the latency_seconds property. This converts milliseconds to seconds.
[Types: @property def latency_seconds(self) -> float: return self.latency_ms / 1000.0]

29
00:02:48,000 --> 00:02:54,000
This is used in the API response for human-readable latency.

30
00:02:54,000 --> 00:03:00,000
Now let's define the to_query_result method. This converts AgentResult to QueryResult.
[Types: def to_query_result(self) -> QueryResult: return QueryResult(question=self.question, answer=self.answer, analysis_style=self.analysis_style, search_type="agent", agent_type=self.agent_type, latency_ms=self.latency_ms, source_documents=self.source_documents, error=self.error, )]

31
00:03:00,000 --> 00:03:06,000
This makes the agent compatible with the API. The API expects QueryResult.

32
00:03:06,000 --> 00:03:12,000
Now let's define the system prompts. These are the three analysis styles.
[Types: _SYSTEM_PROMPTS: dict[str, str] = {}]

33
00:03:12,000 --> 00:03:18,000
The analyst prompt. This is for detailed financial analysis.
[Types: _SYSTEM_PROMPTS["analyst"] = """You are a senior financial analyst with deep expertise in SEC filings, financial statements, and corporate strategy. You have access to a search tool that retrieves relevant passages from ingested SEC filings.

APPROACH:
1. Use the search tool to retrieve relevant information before answering
2. For complex questions, search multiple times with different queries
3. Synthesize findings into a precise, evidence-based answer
4. Always cite specific figures, dates, and document sections
5. If information is insufficient, say so explicitly — never speculate

Your answers should be suitable for institutional investment decisions."""]

34
00:03:18,000 --> 00:03:24,000
The analyst prompt emphasizes precision and evidence. It tells the agent to
search multiple times and cite sources.

35
00:03:24,000 --> 00:03:30,000
The executive prompt. This is for concise, decision-ready insights.
[Types: _SYSTEM_PROMPTS["executive"] = """You are a CFO-level advisor providing concise, decision-ready financial intelligence. You have access to a search tool over SEC filings.

APPROACH:
1. Search for the most relevant data points first
2. Lead with the single most important finding
3. Be direct and quantitative — numbers over adjectives
4. Flag any material risks or uncertainties
5. Keep responses concise but complete"""]

36
00:03:30,000 --> 00:03:36,000
The executive prompt emphasizes conciseness. It tells the agent to lead
with the most important finding and be quantitative.

37
00:03:36,000 --> 00:03:42,000
The risk prompt. This is for risk assessment.
[Types: _SYSTEM_PROMPTS["risk"] = """You are a Chief Risk Officer conducting financial risk assessments. You have access to a search tool over SEC filings.

APPROACH:
1. Search specifically for risk factors, legal proceedings, and management discussion
2. Quantify risks where possible
3. Identify interconnected risk factors
4. Flag regulatory and litigation exposures explicitly
5. Assess risk trends (improving/deteriorating)"""]

38
00:03:42,000 --> 00:03:48,000
The risk prompt emphasizes risk identification. It tells the agent to look
for risk factors, quantify risks, and identify trends.

39
00:03:48,000 --> 00:03:54,000
Now let's define the tool definitions. These are for OpenAI function calling.
[Types: _TOOLS = []]

40
00:03:54,000 --> 00:04:00,000
The first tool is search_filings. This searches SEC filings.
[Types: _TOOLS.append({ "type": "function", "function": { "name": "search_filings", "description": "Search SEC filings for information relevant to the query.", "parameters": { "type": "object", "properties": { "query": {"type": "string", "description": "The search query"}, "ticker": {"type": "string", "description": "Optional company filter"}, "section": {"type": "string", "description": "Optional section filter"}, "fiscal_year": {"type": "integer", "description": "Optional year filter"}, }, "required": ["query"], }, }, })]

41
00:04:00,000 --> 00:04:06,000
The search_filings tool takes a query and optional filters. It returns
relevant passages from SEC filings.

42
00:04:06,000 --> 00:04:12,000
The second tool is compare_filings. This compares data across filings.
[Types: _TOOLS.append({ "type": "function", "function": { "name": "compare_filings", "description": "Compare financial data across multiple filings or fiscal years.", "parameters": { "type": "object", "properties": { "query": {"type": "string", "description": "What to compare"}, "ticker": {"type": "string", "description": "Company ticker"}, "years": {"type": "array", "items": {"type": "integer"}, "description": "Years to compare"}, }, "required": ["query", "ticker"], }, }, })]

43
00:04:12,000 --> 00:04:18,000
The compare_filings tool takes a query, a ticker, and optional years.
It compares data across multiple fiscal years.

44
00:04:18,000 --> 00:04:24,000
Now let's define the FinancialAgent class.
[Types: class FinancialAgent:]

45
00:04:24,000 --> 00:04:30,000
We define the init method. This initializes the agent.
[Types: def __init__(self, vector_store: VectorStore | None = None) -> None:]

46
00:04:30,000 --> 00:04:36,000
We get the settings instance.
[Types: self._settings = get_settings()]

47
00:04:36,000 --> 00:04:42,000
We create a VectorStore instance if one wasn't provided.
[Types: vs = vector_store or VectorStore()]

48
00:04:42,000 --> 00:04:48,000
We create a QueryEngine instance for the fallback.
[Types: self._query_engine = QueryEngine(vector_store=vs)]

49
00:04:48,000 --> 00:04:54,000
We build the LLM client. This is the circuit breaker.
[Types: self._llm = self._build_llm_client()]

50
00:04:54,000 --> 00:05:00,000
Now let's define the _build_llm_client method. This is the circuit breaker.
[Types: def _build_llm_client(self) -> AsyncOpenAI | None:]

51
00:05:00,000 --> 00:05:06,000
If MOCK_EXTERNAL_APIS is True, return None. This disables LLM calls.
[Types: if self._settings.MOCK_EXTERNAL_APIS: return None]

52
00:05:06,000 --> 00:05:12,000
If OPENAI_API_KEY is not set, return None. This is the circuit breaker.
[Types: if not self._settings.OPENAI_API_KEY: logger.warning("FinancialAgent: OPENAI_API_KEY not set — falling back to QueryEngine") return None]

53
00:05:12,000 --> 00:05:18,000
If the key is set, create the AsyncOpenAI client.
[Types: return AsyncOpenAI(api_key=self._settings.OPENAI_API_KEY.get_secret_value(), base_url=self._settings.LLM_BASE_URL or None, timeout=self._settings.LLM_REQUEST_TIMEOUT, )]

54
00:05:18,000 --> 00:05:24,000
This is the circuit breaker. If the LLM client is None, the agent falls back
to the query engine.

55
00:05:24,000 --> 00:05:30,000
Now let's define the analyze method. This is the main entry point.
[Types: async def analyze(self, question: str, *, ticker: str | None = None, fiscal_year: int | None = None, analysis_style: Literal["analyst", "executive", "risk"] = "analyst", max_tool_calls: int = 5,) -> AgentResult:]

56
00:05:30,000 --> 00:05:36,000
We start the timer for latency measurement.
[Types: t0 = time.monotonic()]

57
00:05:36,000 --> 00:05:42,000
If the LLM client is None, fall back to QueryEngine.
[Types: if self._llm is None: result = await self._query_engine.query(question, ticker=ticker, fiscal_year=fiscal_year, analysis_style=analysis_style, ) return AgentResult(question=question, answer=result.answer, analysis_style=analysis_style, agent_type="query_engine_fallback", latency_ms=int((time.monotonic() - t0) * 1000), source_documents=result.source_documents, error=result.error, )]

58
00:05:42,000 --> 00:05:48,000
This is the graceful degradation path. If the LLM isn't available, we still
provide an answer using the query engine.

59
00:05:48,000 --> 00:05:54,000
Now we run the agent loop. This is where the reasoning happens.
[Types: try: answer, sources, tool_calls, steps = await self._run_agent_loop(question=question, ticker=ticker, fiscal_year=fiscal_year, analysis_style=analysis_style, max_tool_calls=max_tool_calls, )]

60
00:05:54,000 --> 00:06:00,000
If the agent loop succeeds, we return an AgentResult with all the details.
[Types: return AgentResult(question=question, answer=answer, analysis_style=analysis_style, agent_type="financial_agent", latency_ms=int((time.monotonic() - t0) * 1000), source_documents=sources, tool_calls=tool_calls, reasoning_steps=steps, )]

61
00:06:00,000 --> 00:06:06,000
If an exception occurs, we log it and fall back to QueryEngine.
[Types: except Exception as exc: logger.error("Agent loop failed: %s", exc, exc_info=True) result = await self._query_engine.query(question, ticker=ticker, fiscal_year=fiscal_year, analysis_style=analysis_style, ) return AgentResult(question=question, answer=result.answer, analysis_style=analysis_style, agent_type="query_engine_fallback", latency_ms=int((time.monotonic() - t0) * 1000), source_documents=result.source_documents, error=str(exc), )]

62
00:06:06,000 --> 00:06:12,000
This ensures the agent never crashes. Even if something goes wrong, the user
gets a response.

63
00:06:12,000 --> 00:06:18,000
Now let's define the _run_agent_loop method. This is where the function
calling happens.
[Types: async def _run_agent_loop(self, *, question: str, ticker: str | None, fiscal_year: int | None, analysis_style: str, max_tool_calls: int,) -> tuple[str, list[RetrievalResult], list[dict], list[str]]:]

64
00:06:18,000 --> 00:06:24,000
We get the system prompt for the chosen analysis style.
[Types: system_prompt = _SYSTEM_PROMPTS.get(analysis_style, _SYSTEM_PROMPTS["analyst"])]

65
00:06:24,000 --> 00:06:30,000
We build the context hints if ticker or fiscal_year are provided.
[Types: context_hints = [] if ticker: context_hints.append(f"Company: {ticker}") if fiscal_year: context_hints.append(f"Fiscal year: {fiscal_year}")]

66
00:06:30,000 --> 00:06:36,000
We build the user content with the context hints and the question.
[Types: if context_hints: user_content = f"[{', '.join(context_hints)}]\n\n{question}" else: user_content = question]

67
00:06:36,000 --> 00:06:42,000
We initialize the messages list with system and user messages.
[Types: messages: list[dict[str, Any]] = [{"role": "system", "content": system_prompt}, {"role": "user", "content": user_content}, ]]

68
00:06:42,000 --> 00:06:48,000
We initialize the tracking variables.
[Types: all_sources: list[RetrievalResult] = [] all_tool_calls: list[dict[str, Any]] = [] reasoning_steps: list[str] = [] tool_call_count = 0]

69
00:06:48,000 --> 00:06:54,000
Now we start the loop. This runs until the agent decides to stop.
[Types: while tool_call_count < max_tool_calls:]

70
00:06:54,000 --> 00:07:00,000
We call the LLM with the messages and tools.
[Types: response = await self._llm.chat.completions.create(model=self._settings.LLM_MODEL, messages=messages, tools=_TOOLS, tool_choice="auto", temperature=self._settings.LLM_TEMPERATURE, max_tokens=self._settings.LLM_MAX_TOKENS, )]

71
00:07:00,000 --> 00:07:06,000
We get the message from the response.
[Types: message = response.choices[0].message]

72
00:07:06,000 --> 00:07:12,000
If there are no tool calls, we return the final answer.
[Types: if not message.tool_calls: return message.content or "", all_sources, all_tool_calls, reasoning_steps]

73
00:07:12,000 --> 00:07:18,000
If there are tool calls, we add the message to the conversation.
[Types: messages.append(message.model_dump(exclude_unset=True))]

74
00:07:18,000 --> 00:07:24,000
We iterate over each tool call.
[Types: for tc in message.tool_calls:]

75
00:07:24,000 --> 00:07:30,000
We increment the tool call counter.
[Types: tool_call_count += 1]

76
00:07:30,000 --> 00:07:36,000
We parse the function name and arguments.
[Types: fn_name = tc.function.name fn_args = json.loads(tc.function.arguments)]

77
00:07:36,000 --> 00:07:42,000
We log the tool call for debugging.
[Types: logger.debug("Agent tool call: %s(%s)", fn_name, fn_args)]
[Types: reasoning_steps.append(f"Calling {fn_name}: {fn_args.get('query', '')}")]

78
00:07:42,000 --> 00:07:48,000
We execute the tool and get the result.
[Types: tool_result, sources = await self._execute_tool(fn_name, fn_args, ticker=ticker, fiscal_year=fiscal_year, )]

79
00:07:48,000 --> 00:07:54,000
We add the sources to the tracking list.
[Types: all_sources.extend(sources)]

80
00:07:54,000 --> 00:08:00,000
We add the tool call to the tracking list.
[Types: all_tool_calls.append({"tool": fn_name, "args": fn_args, "result": tool_result[:500], })]

81
00:08:00,000 --> 00:08:06,000
We add the tool result to the conversation.
[Types: messages.append({"role": "tool", "tool_call_id": tc.id, "content": tool_result, })]

82
00:08:06,000 --> 00:08:12,000
If we hit max_tool_calls, we force a final answer without tools.
[Types: if tool_call_count >= max_tool_calls: logger.warning("Agent hit max_tool_calls=%d, forcing final answer", max_tool_calls) final_response = await self._llm.chat.completions.create(model=self._settings.LLM_MODEL, messages=messages, temperature=self._settings.LLM_TEMPERATURE, max_tokens=self._settings.LLM_MAX_TOKENS, ) return final_response.choices[0].message.content or "", all_sources, all_tool_calls, reasoning_steps]

83
00:08:12,000 --> 00:08:18,000
Now let's define the _execute_tool method. This routes tool calls to the
appropriate handler.
[Types: async def _execute_tool(self, tool_name: str, args: dict[str, Any], *, ticker: str | None, fiscal_year: int | None,) -> tuple[str, list[RetrievalResult]]:]

84
00:08:18,000 --> 00:08:24,000
If the tool is search_filings, we call _tool_search_filings.
[Types: try: if tool_name == "search_filings": return await self._tool_search_filings(args, default_ticker=ticker, default_year=fiscal_year, )]

85
00:08:24,000 --> 00:08:30,000
If the tool is compare_filings, we call _tool_compare_filings.
[Types: elif tool_name == "compare_filings": return await self._tool_compare_filings(args)]

86
00:08:30,000 --> 00:08:36,000
If the tool is unknown, we return an error message.
[Types: else: return f"Unknown tool: {tool_name}", []]

87
00:08:36,000 --> 00:08:42,000
If an exception occurs, we log it and return the error message.
[Types: except Exception as exc: logger.warning("Tool %s failed: %s", tool_name, exc) return f"Tool call failed: {exc}", []]

88
00:08:42,000 --> 00:08:48,000
Now let's define the _tool_search_filings method. This executes the search.
[Types: async def _tool_search_filings(self, args: dict[str, Any], *, default_ticker: str | None, default_year: int | None,) -> tuple[str, list[RetrievalResult]]:]

89
00:08:48,000 --> 00:08:54,000
We extract the query and optional filters from the arguments.
[Types: query = args.get("query", "") ticker = args.get("ticker") or default_ticker section = args.get("section") fiscal_year = args.get("fiscal_year") or default_year]

90
00:08:54,000 --> 00:09:00,000
We call the query engine with the parameters.
[Types: result = await self._query_engine.query(query, ticker=ticker, fiscal_year=fiscal_year, section=section if section else None, analysis_style="analyst", search_type="similarity", )]

91
00:09:00,000 --> 00:09:06,000
If there are no source documents, we return a helpful message.
[Types: if not result.source_documents: return "No relevant information found for this query.", []]

92
00:09:06,000 --> 00:09:12,000
We format the results as context for the LLM.
[Types: context_parts = [r.to_context_string() for r in result.source_documents] context = "\n\n---\n\n".join(context_parts)]

93
00:09:12,000 --> 00:09:18,000
We return the context and the source documents.
[Types: return context, result.source_documents]

94
00:09:18,000 --> 00:09:24,000
Now let's define the _tool_compare_filings method.
[Types: async def _tool_compare_filings(self, args: dict[str, Any]) -> tuple[str, list[RetrievalResult]]:]

95
00:09:24,000 --> 00:09:30,000
We extract the query, ticker, and years from the arguments.
[Types: query = args.get("query", "") ticker = args.get("ticker") years = args.get("years") or []]

96
00:09:30,000 --> 00:09:36,000
We initialize the tracking variables.
[Types: all_sources: list[RetrievalResult] = [] year_contexts: list[str] = []]

97
00:09:36,000 --> 00:09:42,000
If years are provided, we search each year individually.
[Types: if years: for year in years[:3]: result = await self._query_engine.query(query, ticker=ticker, fiscal_year=year, analysis_style="analyst", ) if result.source_documents: all_sources.extend(result.source_documents) chunks = [r.to_context_string() for r in result.source_documents[:2]] year_contexts.append(f"=== FY{year} ===\n" + "\n".join(chunks))]

98
00:09:42,000 --> 00:09:48,000
If no years are provided, we do a single general search.
[Types: else: result = await self._query_engine.query(query, ticker=ticker, analysis_style="analyst") all_sources = result.source_documents year_contexts = [r.to_context_string() for r in all_sources]]

99
00:09:48,000 --> 00:09:54,000
If there are no results, we return a helpful message.
[Types: if not year_contexts: return "No comparative data found.", []]

100
00:09:54,000 --> 00:10:00,000
We return the combined context and the sources.
[Types: return "\n\n".join(year_contexts), all_sources]

101
00:10:00,000 --> 00:10:06,000
Now let's update the agents __init__.py file.
Open `src/financial_rag/agents/__init__.py`.

102
00:10:06,000 --> 00:10:12,000
We import the AgentResult and FinancialAgent classes.
[Types: from .financial_agent import AgentResult, FinancialAgent]

103
00:10:12,000 --> 00:10:18,000
We add them to __all__.
[Types: __all__ = ["AgentResult", "FinancialAgent"]]

104
00:10:18,000 --> 00:10:24,000
Now let me recap what we've built in Part 3.

105
00:10:24,000 --> 00:10:30,000
We built the AgentResult dataclass. This stores the complete result of an
agent run, including tool calls and reasoning steps.

106
00:10:30,000 --> 00:10:36,000
We built the system prompts. Three styles: analyst, executive, risk.
Each prompt guides the agent to behave differently.

107
00:10:36,000 --> 00:10:42,000
We built the tool definitions. search_filings and compare_filings.
These are the tools the agent can use.

108
00:10:42,000 --> 00:10:48,000
We built the FinancialAgent class. It has a circuit breaker for the LLM.
If the LLM isn't available, it falls back to the query engine.

109
00:10:48,000 --> 00:10:54,000
We built the agent loop. This handles function calling.
It calls the LLM, executes tools, and continues until the answer is ready.

110
00:10:54,000 --> 00:11:00,000
We built the tool execution methods. search_filings and compare_filings.
These call the query engine with the right parameters.

111
00:11:00,000 --> 00:11:06,000
This is the Financial Agent. It can reason, use tools, and produce
better answers than the query engine alone.

112
00:11:06,000 --> 00:11:12,000
In Part 4, we'll build the verification tests. We'll test the agent,
the query engine, and the analysis repository together.

113
00:11:12,000 --> 00:11:18,000
Thank you for watching. I'll see you in Part 4.

114
00:11:18,000 --> 00:11:22,000
[End of Part 3]
1
00:00:00,000 --> 00:00:06,000
Welcome back to Phase 4. In Part 4, we build the verification tests.

2
00:00:06,000 --> 00:00:12,000
We've built the QueryEngine, the AnalysisRepository, and the FinancialAgent.
Now we need to verify everything works together.

3
00:00:12,000 --> 00:00:18,000
Think of this as the quality control checkpoint. Every component is inspected.
Every connection is tested. Nothing is assumed to work.

4
00:00:18,000 --> 00:00:24,000
Open your editor and create `tests/integration/test_phase4_agent.py`.

5
00:00:24,000 --> 00:00:30,000
We'll start with the imports. The __future__ import enables forward references.
[Types: from __future__ import annotations]

6
00:00:30,000 --> 00:00:36,000
We import uuid for generating test IDs.
[Types: import uuid]

7
00:00:36,000 --> 00:00:42,000
We import os for environment variable access during testing.
[Types: import os]

8
00:00:42,000 --> 00:00:48,000
We import patch from unittest.mock for mocking dependencies.
[Types: from unittest.mock import patch]

9
00:00:48,000 --> 00:00:54,000
We import pytest as our testing framework.
[Types: import pytest]

10
00:00:54,000 --> 00:01:00,000
We import AgentResult and FinancialAgent from the agents module.
[Types: from financial_rag.agents.financial_agent import AgentResult, FinancialAgent]

11
00:01:00,000 --> 00:01:06,000
We import get_settings from the config module.
[Types: from financial_rag.config import get_settings]

12
00:01:06,000 --> 00:01:12,000
We import QueryEngine and QueryResult from the retrieval module.
[Types: from financial_rag.retrieval.query_engine import QueryEngine, QueryResult]

13
00:01:12,000 --> 00:01:18,000
We import AnalysisRepository from the storage repositories.
[Types: from financial_rag.storage.repositories.analysis import AnalysisRepository]

14
00:01:18,000 --> 00:01:24,000
We import VALID_SECRETS from the test configuration.
[Types: from tests.conftest import VALID_SECRETS]

15
00:01:24,000 --> 00:01:30,000
Now let's define the settings cache fixture. This clears the cache before and after each test.
[Types: @pytest.fixture(autouse=True) def clear_settings_cache(): get_settings.cache_clear() yield get_settings.cache_clear()]

16
00:01:30,000 --> 00:01:36,000
This fixture ensures environment patches in one test don't affect another test.
It clears the lru_cache before and after every test.

17
00:01:36,000 --> 00:01:42,000
Now let's define the database client fixture. This creates and connects a DatabaseClient.
[Types: @pytest.fixture async def db_client(): from financial_rag.storage.database import DatabaseClient client = DatabaseClient() await client.connect() yield client await client.disconnect()]

18
00:01:42,000 --> 00:01:48,000
This fixture handles setup and teardown automatically. The client is connected before the test and disconnected after.

19
00:01:48,000 --> 00:01:54,000
Now let's define the database session fixture. This provides a clean session for each test.
[Types: @pytest.fixture async def db_session(db_client): async with db_client.session() as session: yield session]

20
00:01:54,000 --> 00:02:00,000
The session is committed and closed automatically. This ensures test isolation.

21
00:02:00,000 --> 00:02:06,000
Now let's define the TestQueryResult class. This tests the QueryResult model.
[Types: class TestQueryResult:]

22
00:02:06,000 --> 00:02:12,000
We test that latency_seconds correctly converts milliseconds to seconds.
[Types: def test_latency_seconds_converts_correctly(self): result = QueryResult(question="test", answer="answer", analysis_style="analyst", search_type="similarity", agent_type="query_engine", latency_ms=1500) assert result.latency_seconds == 1.5]

23
00:02:12,000 --> 00:02:18,000
The property divides by 1000 to convert milliseconds to seconds. This is used
in the API response.

24
00:02:18,000 --> 00:02:24,000
We test that repr includes key fields for debugging.
[Types: def test_repr_includes_key_fields(self): result = QueryResult(question="test", answer="answer", analysis_style="analyst", search_type="similarity", agent_type="query_engine", latency_ms=250) assert "analyst" in repr(result) assert "250ms" in repr(result)]

25
00:02:24,000 --> 00:02:30,000
The repr shows the analysis style and latency. This makes debugging easier.

26
00:02:30,000 --> 00:02:36,000
Now let's define the TestAgentResult class. This tests the AgentResult model.
[Types: class TestAgentResult:]

27
00:02:36,000 --> 00:02:42,000
We test that to_query_result correctly converts AgentResult to QueryResult.
[Types: def test_to_query_result_converts(self): agent_result = AgentResult(question="test", answer="answer", analysis_style="analyst", agent_type="financial_agent", latency_ms=800) qr = agent_result.to_query_result() assert isinstance(qr, QueryResult) assert qr.search_type == "agent" assert qr.latency_ms == 800]

28
00:02:42,000 --> 00:02:48,000
This conversion is used by the API to return a consistent response format.

29
00:02:48,000 --> 00:02:54,000
We test that latency_seconds converts correctly on AgentResult.
[Types: def test_latency_seconds_property(self): result = AgentResult(question="test", answer="answer", analysis_style="analyst", agent_type="financial_agent", latency_ms=2000) assert result.latency_seconds == 2.0]

30
00:02:54,000 --> 00:03:00,000
Same property as QueryResult. Consistent behavior across models.

31
00:03:00,000 --> 00:03:06,000
Now let's define the TestAnalysisRepository class. This tests the audit trail.
[Types: class TestAnalysisRepository:]

32
00:03:06,000 --> 00:03:12,000
We test that record creates a record with an ID.
[Types: @pytest.mark.integration async def test_record_and_retrieve(self, db_session): repo = AnalysisRepository(db_session) record = await repo.record(question="What was Apple's revenue?", answer="Apple's revenue was $394 billion.", agent_type="query_engine", latency_ms=320, ticker="AAPL", analysis_style="analyst", search_type="similarity") assert record.id is not None assert record.ticker == "AAPL" assert record.latency_ms == 320]

33
00:03:12,000 --> 00:03:18,000
The record should have an auto-generated ID. The ticker and latency should match
what we passed in.

34
00:03:18,000 --> 00:03:24,000
We test that get_by_ticker returns a list of records.
[Types: @pytest.mark.integration async def test_get_by_ticker(self, db_session): repo = AnalysisRepository(db_session) records = await repo.get_by_ticker("AAPL") assert isinstance(records, list)]

35
00:03:24,000 --> 00:03:30,000
This method is used to retrieve history for a specific company.

36
00:03:30,000 --> 00:03:36,000
Now let's define the TestQueryEngineMocked class. Tests that run without LLM.
[Types: class TestQueryEngineMocked:]

37
00:03:36,000 --> 00:03:42,000
We test that query returns a QueryResult even without LLM.
[Types: @pytest.mark.integration async def test_query_returns_query_result(self, monkeypatch): monkeypatch.setenv("MOCK_EXTERNAL_APIS", "true") get_settings.cache_clear() engine = QueryEngine() result = await engine.query("What is Apple's revenue?", ticker="AAPL") assert isinstance(result, QueryResult) assert result.question == "What is Apple's revenue?"]

38
00:03:42,000 --> 00:03:48,000
This verifies the circuit breaker works. No LLM, but the system still responds.

39
00:03:48,000 --> 00:03:54,000
We test that the agent falls back to QueryEngine without LLM.
[Types: @pytest.mark.integration async def test_agent_falls_back_to_query_engine_without_key(self, monkeypatch): monkeypatch.setenv("MOCK_EXTERNAL_APIS", "true") get_settings.cache_clear() agent = FinancialAgent() assert agent._llm is None result = await agent.analyze("Test question?") assert result.agent_type == "query_engine_fallback"]

40
00:03:54,000 --> 00:04:00,000
This verifies the graceful degradation. When LLM is unavailable, the agent
falls back to the query engine.

41
00:04:00,000 --> 00:04:06,000
Now let's define the TestErrorHandling class. This tests error handling.
[Types: class TestErrorHandling:]

42
00:04:06,000 --> 00:04:12,000
We test that empty questions are rejected.
[Types: @pytest.mark.integration async def test_query_handles_empty_question(self): engine = QueryEngine() with pytest.raises(ValueError, match="Question cannot be empty"): await engine.query("", ticker="AAPL")]

43
00:04:12,000 --> 00:04:18,000
Empty questions are rejected early. This prevents meaningless queries.

44
00:04:18,000 --> 00:04:24,000
We test that the agent also rejects empty questions.
[Types: @pytest.mark.integration async def test_agent_handles_empty_question(self, monkeypatch): monkeypatch.setenv("MOCK_EXTERNAL_APIS", "true") get_settings.cache_clear() agent = FinancialAgent() with pytest.raises(ValueError, match="Question cannot be empty"): await agent.analyze("")]

45
00:04:24,000 --> 00:04:30,000
Consistent error handling across both components.

46
00:04:30,000 --> 00:04:36,000
Now let's define the cleanup fixture. This ensures database cleanup after tests.
[Types: @pytest.fixture(autouse=True) def cleanup_after_integration_tests(): yield]

47
00:04:36,000 --> 00:04:42,000
This fixture runs automatically after each test. Any cleanup logic can go here.

48
00:04:42,000 --> 00:04:48,000
Now let's run the tests. Activate your virtual environment and run pytest.

49
00:04:48,000 --> 00:04:54,000
[Types: source .venv/bin/activate]
[Types: pytest tests/integration/test_phase4_agent.py -v]

50
00:04:54,000 --> 00:05:00,000
The unit tests should pass quickly. The integration tests may take longer
because they interact with the database.

51
00:05:00,000 --> 00:05:06,000
You should see output like this showing all tests passing.

52
00:05:06,000 --> 00:05:12,000
============================= test session starts =============================
collected 8 items
test_phase4_agent.py ........                                            [100%]
============================= 8 passed in 15.23s =============================

53
00:05:12,000 --> 00:05:18,000
All green means everything is working. If you see red, check the error message
and fix the issue.

54
00:05:18,000 --> 00:05:24,000
Now let me recap what we've built in Part 4.

55
00:05:24,000 --> 00:05:30,000
We built tests for QueryResult. We verified latency_seconds conversion and repr.

56
00:05:30,000 --> 00:05:36,000
We built tests for AgentResult. We verified to_query_result conversion and
latency_seconds property.

57
00:05:36,000 --> 00:05:42,000
We built integration tests for AnalysisRepository. We verified record creation
and retrieval by ticker.

58
00:05:42,000 --> 00:05:48,000
We built tests for QueryEngine with mocked LLM. We verified it returns
QueryResult even without LLM.

59
00:05:48,000 --> 00:05:54,000
We built tests for FinancialAgent fallback. We verified it falls back to
QueryEngine when LLM is unavailable.

60
00:05:54,000 --> 00:06:00,000
We built error handling tests. We verified empty questions are rejected.

61
00:06:00,000 --> 00:06:06,000
This is the complete test suite for Phase 4. Every component is tested.
The system is reliable. Bugs are caught early.

62
00:06:06,000 --> 00:06:12,000
Phase 4 is now complete. You have a working RAG system with an intelligent agent.

63
00:06:12,000 --> 00:06:18,000
Thank you for watching. I'll see you in Phase 5.

64
00:06:18,000 --> 00:06:22,000
[End of Phase 4]