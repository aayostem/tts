1
00:00:00,000 --> 00:00:06,000
Welcome to Phase 3. In Part 1, we set up Alembic for database migrations.

2
00:00:06,000 --> 00:00:12,000
We have a database schema defined in SQL. But we need a way to evolve that schema
over time. We need to add columns, change types, and create new tables.

3
00:00:12,000 --> 00:00:18,000
Alembic is the tool that manages these schema changes. It tracks which migrations
have been applied and applies new ones in order.

4
00:00:18,000 --> 00:00:24,000
Open your terminal and run the Alembic init command.
[Types: alembic init migrations]

5
00:00:24,000 --> 00:00:30,000
This creates the migrations directory and the alembic.ini configuration file.

6
00:00:30,000 --> 00:00:36,000
Now open `alembic.ini` in your editor. This is the main Alembic configuration file.

7
00:00:36,000 --> 00:00:42,000
Scroll down to the sqlalchemy.url line. This is the database connection string.
[Types: sqlalchemy.url = driver://user:pass@localhost/dbname]

8
00:00:42,000 --> 00:00:48,000
We need to replace this with our actual database URL. But we don't want to
hardcode credentials. We'll use our settings system.

9
00:00:48,000 --> 00:00:54,000
[Types: sqlalchemy.url = postgresql+psycopg2://finrag:${POSTGRES_PASSWORD}@localhost:5432/financial_rag]

10
00:00:54,000 --> 00:01:00,000
This is the sync version of the URL. Alembic uses psycopg2, not asyncpg.
The format is postgresql+psycopg2://user:password@host:port/database.

11
00:01:00,000 --> 00:01:06,000
But we have a better way. We can use our settings system to get the URL.
Open `migrations/env.py` in your editor.

12
00:01:06,000 --> 00:01:12,000
This is the Alembic environment file. It runs every time you run a migration.

13
00:01:12,000 --> 00:01:18,000
We need to import our settings system. Add these imports at the top.
[Types: import sys]
[Types: from pathlib import Path]

14
00:01:18,000 --> 00:01:24,000
We need to add the project root to the Python path so we can import our modules.
[Types: sys.path.insert(0, str(Path(__file__).parent.parent))]

15
00:01:24,000 --> 00:01:30,000
This allows Alembic to find our settings module when it runs.

16
00:01:30,000 --> 00:01:36,000
Now import the settings.
[Types: from financial_rag.config import get_settings]

17
00:01:36,000 --> 00:01:42,000
We need to get the sync database URL for Alembic.
[Types: settings = get_settings()]

18
00:01:42,000 --> 00:01:48,000
Now we configure Alembic to use our database URL from settings.
[Types: config.set_main_option("sqlalchemy.url", settings.DATABASE_URL_SYNC.get_secret_value())]

19
00:01:48,000 --> 00:01:54,000
This sets the sqlalchemy.url option in the Alembic config at runtime.
It uses the sync URL from our settings.

20
00:01:54,000 --> 00:02:00,000
Now scroll down to the target_metadata variable. This tells Alembic which
metadata to use for schema generation.
[Types: target_metadata = None]

21
00:02:00,000 --> 00:02:06,000
We need to import our Base metadata from the database module.
[Types: from financial_rag.storage.database import Base]

22
00:02:06,000 --> 00:02:12,000
And set target_metadata to Base.metadata.
[Types: target_metadata = Base.metadata]

23
00:02:12,000 --> 00:02:18,000
This tells Alembic to use our ORM models to generate schema migrations.

24
00:02:18,000 --> 00:02:24,000
Now let's create our first migration. This will create the initial schema.

25
00:02:24,000 --> 00:02:30,000
[Types: alembic revision -m "initial_migration"]

26
00:02:30,000 --> 00:02:36,000
This creates a new migration file in migrations/versions.
The file name is something like 001_initial_migration.py.

27
00:02:36,000 --> 00:02:42,000
Open that file in your editor. It looks like this.

28
00:02:42,000 --> 00:02:48,000
[Types: """initial_migration
Revision ID: 001
Revises:
Create Date: 2026-01-01 00:00:00.000000
"""]

29
00:02:48,000 --> 00:02:54,000
The file starts with a docstring describing the migration.

30
00:02:54,000 --> 00:03:00,000
Then it defines the revision ID. This is a unique identifier for this migration.
[Types: revision = "001"]

31
00:03:00,000 --> 00:03:06,000
down_revision is None because this is the first migration.
[Types: down_revision = None]

32
00:03:06,000 --> 00:03:12,000
branch_labels and depends_on are also None for the first migration.
[Types: branch_labels = None]
[Types: depends_on = None]

33
00:03:12,000 --> 00:03:18,000
Now the upgrade function. This is what runs when you apply the migration.
[Types: def upgrade() -> None:]

34
00:03:18,000 --> 00:03:24,000
We need to create our extensions. These are PostgreSQL extensions that our
application depends on.

35
00:03:24,000 --> 00:03:30,000
First, create the vector extension. This enables pgvector functionality.
[Types: op.execute("CREATE EXTENSION IF NOT EXISTS vector")]

36
00:03:30,000 --> 00:03:36,000
We use op.execute to run raw SQL. This is the simplest way to create extensions.

37
00:03:36,000 --> 00:03:42,000
Next, create the uuid-ossp extension. This enables UUID generation functions.
[Types: op.execute('CREATE EXTENSION IF NOT EXISTS "uuid-ossp"')]

38
00:03:42,000 --> 00:03:48,000
We need quotes around uuid-ossp because it contains a hyphen.
This is a PostgreSQL extension for generating UUIDs.

39
00:03:48,000 --> 00:03:54,000
Next, create the pg_trgm extension. This enables trigram similarity search.
[Types: op.execute("CREATE EXTENSION IF NOT EXISTS pg_trgm")]

40
00:03:54,000 --> 00:04:00,000
This is used for the hybrid search fallback when vector search has low confidence.

41
00:04:00,000 --> 00:04:06,000
Finally, create the btree_gin extension. This enables GIN indexes on JSONB.
[Types: op.execute("CREATE EXTENSION IF NOT EXISTS btree_gin")]

42
00:04:06,000 --> 00:04:12,000
This is used for efficient indexing of the metrics and entities JSONB columns.

43
00:04:12,000 --> 00:04:18,000
Now the downgrade function. This is what runs when you roll back a migration.
[Types: def downgrade() -> None:]

44
00:04:18,000 --> 00:04:24,000
We use pass because we don't want to drop extensions on downgrade.
[Types: pass]

45
00:04:24,000 --> 00:04:30,000
We could drop the extensions, but that would delete all data. It's safer to
just skip the downgrade for extensions.

46
00:04:30,000 --> 00:04:36,000
Now let's apply the migration. This creates the schema in the database.

47
00:04:36,000 --> 00:04:42,000
[Types: alembic upgrade head]

48
00:04:42,000 --> 00:04:48,000
This applies all pending migrations. Since this is the first migration,
it creates all the tables and extensions.

49
00:04:48,000 --> 00:04:54,000
Let me show you the complete migration file. You should have this in your editor.

50
00:04:54,000 --> 00:05:00,000
"""Initial schema baseline

Revision ID: 001
Revises:
Create Date: 2026-01-01 00:00:00.000000
"""

51
00:05:00,000 --> 00:05:06,000
from __future__ import annotations
from alembic import op

52
00:05:06,000 --> 00:05:12,000
revision = "001"
down_revision = None
branch_labels = None
depends_on = None

53
00:05:12,000 --> 00:05:18,000
def upgrade() -> None:
    op.execute("CREATE EXTENSION IF NOT EXISTS vector")
    op.execute('CREATE EXTENSION IF NOT EXISTS "uuid-ossp"')
    op.execute("CREATE EXTENSION IF NOT EXISTS pg_trgm")
    op.execute("CREATE EXTENSION IF NOT EXISTS btree_gin")

54
00:05:18,000 --> 00:05:24,000
def downgrade() -> None:
    pass

55
00:05:24,000 --> 00:05:30,000
Now let's verify the migration worked. Connect to the database and check.

56
00:05:30,000 --> 00:05:36,000
[Types: docker compose exec postgres psql -U finrag -d financial_rag -c "\dx"]

57
00:05:36,000 --> 00:05:42,000
You should see the vector, uuid-ossp, pg_trgm, and btree_gin extensions listed.

58
00:05:42,000 --> 00:05:48,000
Now check that the tables exist.
[Types: docker compose exec postgres psql -U finrag -d financial_rag -c "\dt"]

59
00:05:48,000 --> 00:05:54,000
You should see filings, financial_chunks, analysis_history, and schema_migrations.

60
00:05:54,000 --> 00:06:00,000
Now let me explain the Alembic workflow. This is how you'll manage schema changes.

61
00:06:00,000 --> 00:06:06,000
Step 1: Make changes to your ORM models. Add a column, change a type, create a new table.

62
00:06:06,000 --> 00:06:12,000
Step 2: Generate a migration.
[Types: alembic revision -m "description_of_change"]

63
00:06:12,000 --> 00:06:18,000
Step 3: Edit the migration file. Fill in the upgrade and downgrade functions.

64
00:06:18,000 --> 00:06:24,000
Step 4: Apply the migration.
[Types: alembic upgrade head]

65
00:06:24,000 --> 00:06:30,000
Step 5: Test the changes. Verify everything works as expected.

66
00:06:30,000 --> 00:06:36,000
Let me give you a practical example. Suppose you need to add a new column
to the filings table.

67
00:06:36,000 --> 00:06:42,000
You would add the column to the Filing ORM model.
[Types: new_column: Mapped[str | None] = mapped_column(String(50))]

68
00:06:42,000 --> 00:06:48,000
Then generate a migration.
[Types: alembic revision -m "add_new_column_to_filings"]

69
00:06:48,000 --> 00:06:54,000
In the migration file, you would write.
[Types: def upgrade() -> None: op.add_column("filings", sa.Column("new_column", sa.String(50), nullable=True))]

70
00:06:54,000 --> 00:07:00,000
And the downgrade.
[Types: def downgrade() -> None: op.drop_column("filings", "new_column")]

71
00:07:00,000 --> 00:07:06,000
Then apply the migration.
[Types: alembic upgrade head]

72
00:07:06,000 --> 00:07:12,000
This is the Alembic workflow. It's how you evolve your database schema safely.

73
00:07:12,000 --> 00:07:18,000
Now let me give you a debugging tip. If a migration fails, you need to fix it
and try again.

74
00:07:18,000 --> 00:07:24,000
If you can't fix it, you can rollback to a previous version.
[Types: alembic downgrade -1]

75
00:07:24,000 --> 00:07:30,000
This rolls back the last migration. Then you can fix the migration and try again.

76
00:07:30,000 --> 00:07:36,000
Never edit a migration that has already been applied in production.
Create a new migration instead.

77
00:07:36,000 --> 00:07:42,000
Now let me recap what we've built in Part 1.

78
00:07:42,000 --> 00:07:48,000
We initialized Alembic. We created the migrations directory and alembic.ini.

79
00:07:48,000 --> 00:07:54,000
We configured Alembic to use our settings system. We set the database URL
from settings and target_metadata from our Base.

80
00:07:54,000 --> 00:08:00,000
We created our first migration. It creates the vector, uuid-ossp, pg_trgm,
and btree_gin extensions.

81
00:08:00,000 --> 00:08:06,000
We applied the migration. We verified the extensions and tables exist.

82
00:08:06,000 --> 00:08:12,000
We learned the Alembic workflow. Make changes, generate migration, edit migration,
apply migration, test.

83
00:08:12,000 --> 00:08:18,000
In Part 2, we'll build the Text Processor. This will chunk documents into
token-bounded pieces for embedding.

84
00:08:18,000 --> 00:08:24,000
Thank you for watching. I'll see you in Part 2.

85
00:08:24,000 --> 00:08:28,000
[End of Part 1]
1
00:00:00,000 --> 00:00:06,000
Welcome back to Phase 3. In Part 2, we build the Text Processor.

2
00:00:06,000 --> 00:00:12,000
The Text Processor is the bridge between parsing and chunking. It takes the
cleaned text from our HTML parser and splits it into token-bounded chunks
ready for embedding and storage.

3
00:00:12,000 --> 00:00:18,000
This is a critical component. The quality of your chunks determines the quality
of your RAG system. Bad chunks mean bad retrieval. Bad retrieval means bad answers.

4
00:00:18,000 --> 00:00:24,000
Open your editor and create `src/financial_rag/processing/text_processor.py`.

5
00:00:24,000 --> 00:00:30,000
We'll start with the imports. The __future__ import enables forward references.
[Types: from __future__ import annotations]

6
00:00:30,000 --> 00:00:36,000
We import logging for structured logging throughout the processor.
[Types: import logging]

7
00:00:36,000 --> 00:00:42,000
We import uuid for generating chunk IDs.
[Types: import uuid]

8
00:00:42,000 --> 00:00:48,000
We import dataclass for the ChunkSpec data structure.
[Types: from dataclasses import dataclass, field]

9
00:00:48,000 --> 00:00:54,000
We import tiktoken for accurate token counting.
[Types: import tiktoken]

10
00:00:54,000 --> 00:01:00,000
We import get_settings from our config module.
[Types: from financial_rag.config import get_settings]

11
00:01:00,000 --> 00:01:06,000
We import FinancialChunk from the chunks repository.
[Types: from financial_rag.storage.repositories.chunks import FinancialChunk]

12
00:01:06,000 --> 00:01:12,000
And we import ChunkingError for handling chunking failures.
[Types: from financial_rag.utils.exceptions import ChunkingError]

13
00:01:12,000 --> 00:01:18,000
Now let's define the tiktoken encoding. We use cl100k_base which covers
GPT-4 and text-embedding-3-* models.
[Types: _ENCODING_NAME = "cl100k_base"]

14
00:01:18,000 --> 00:01:24,000
This encoding is shared across all our models, so we use it for all token counting.

15
00:01:24,000 --> 00:01:30,000
Now let's define the ChunkSpec dataclass. This specifies how a chunk should be created.
[Types: @dataclass class ChunkSpec: text: str section: str chunk_index: int token_count: int filing_id: uuid.UUID ticker: str filing_type: str fiscal_year: int | None metrics: dict[str, object] = field(default_factory=dict) entities: dict[str, object] = field(default_factory=dict) sentiment_score: float | None = None]

16
00:01:30,000 --> 00:01:36,000
ChunkSpec holds all the metadata for a chunk before it becomes a FinancialChunk.
It includes the text, the section name, the chunk index, the token count, the filing ID,
and the ticker and filing type information.

17
00:01:36,000 --> 00:01:42,000
Now let's define the TextProcessor class.
[Types: class TextProcessor:]

18
00:01:42,000 --> 00:01:48,000
We define the __init__ method. This initializes the processor with settings.
[Types: def __init__(self) -> None:]

19
00:01:48,000 --> 00:01:54,000
We get the settings instance.
[Types: self._settings = get_settings()]

20
00:01:54,000 --> 00:02:00,000
We initialize the tiktoken encoding.
[Types: try: self._encoding = tiktoken.get_encoding(_ENCODING_NAME) except Exception as exc: raise ChunkingError(f"Failed to load tiktoken encoding '{_ENCODING_NAME}': {exc}") from exc]

21
00:02:00,000 --> 00:02:06,000
If tiktoken fails to load, we raise ChunkingError. This prevents the application
from starting with a broken chunking configuration.

22
00:02:06,000 --> 00:02:12,000
We set the chunk size and overlap from settings.
[Types: self._chunk_size = self._settings.CHUNK_SIZE_TOKENS]
[Types: self._chunk_overlap = self._settings.CHUNK_OVERLAP_TOKENS]

23
00:02:12,000 --> 00:02:18,000
The chunk size is the target number of tokens per chunk. The overlap is the
number of tokens that overlap between consecutive chunks.

24
00:02:18,000 --> 00:02:24,000
We log the initialization.
[Types: logger.info("TextProcessor initialised — chunk_size=%d overlap=%d encoding=%s", self._chunk_size, self._chunk_overlap, _ENCODING_NAME)]

25
00:02:24,000 --> 00:02:30,000
Now let's implement the process method. This is the main public method.
[Types: def process(self, parsed: ParsedFiling, meta: FilingMetadata, filing_id: uuid.UUID) -> list[FinancialChunk]:]

26
00:02:30,000 --> 00:02:36,000
We check if there are sections to chunk.
[Types: if not parsed.sections: raise ChunkingError(f"ParsedFiling for {meta.ticker} {meta.filing_type} FY{meta.fiscal_year} has no sections to chunk.")]

27
00:02:36,000 --> 00:02:42,000
If there are no sections, we raise ChunkingError. This indicates the parsing
failed to extract any sections.

28
00:02:42,000 --> 00:02:48,000
We initialize the results list.
[Types: all_chunks: list[FinancialChunk] = []]

29
00:02:48,000 --> 00:02:54,000
We initialize the global chunk index.
[Types: global_index = 0]

30
00:02:54,000 --> 00:03:00,000
Now we iterate over each section in the parsed filing.
[Types: for section in parsed.sections:]

31
00:03:00,000 --> 00:03:06,000
We skip empty sections.
[Types: if not section.text or not section.text.strip(): continue]

32
00:03:06,000 --> 00:03:12,000
We chunk the section.
[Types: try: section_chunks = self._chunk_section(text=section.text, section_name=section.name, filing_id=filing_id, meta=meta, start_index=global_index) except Exception as exc: raise ChunkingError(f"Failed to chunk section '{section.name}' for {meta.ticker} {meta.filing_type}: {exc}") from exc]

33
00:03:12,000 --> 00:03:18,000
If chunking fails, we raise ChunkingError with context about which section failed.

34
00:03:18,000 --> 00:03:24,000
We add the section chunks to the results list.
[Types: all_chunks.extend(section_chunks)]

35
00:03:24,000 --> 00:03:30,000
We update the global chunk index.
[Types: global_index += len(section_chunks)]

36
00:03:30,000 --> 00:03:36,000
We log the completion.
[Types: logger.info("Processed %s %s FY%s — %d sections → %d chunks", meta.ticker, meta.filing_type, meta.fiscal_year, len(parsed.sections), len(all_chunks))]

37
00:03:36,000 --> 00:03:42,000
We return the chunks.
[Types: return all_chunks]

38
00:03:42,000 --> 00:03:48,000
Now let's implement the count_tokens method. This returns the exact token count
for a string.
[Types: def count_tokens(self, text: str) -> int: return len(self._encoding.encode(text))]

39
00:03:48,000 --> 00:03:54,000
We use tiktoken's encode method to convert the text to tokens and count them.
This is more accurate than using len(text) / 4.

40
00:03:54,000 --> 00:04:00,000
Now let's implement the estimate_cost method. This estimates the cost of embedding
a list of chunks.
[Types: def estimate_cost(self, chunks: list[FinancialChunk], *, cost_per_million_tokens: float = 0.13) -> dict[str, float]:]

41
00:04:00,000 --> 00:04:06,000
The default cost is 0.13 per million tokens for text-embedding-3-large.
This is OpenAI's pricing as of mid-2024.

42
00:04:06,000 --> 00:04:12,000
We calculate the total tokens.
[Types: total_tokens = sum(c.token_count or 0 for c in chunks)]

43
00:04:12,000 --> 00:04:18,000
We calculate the cost.
[Types: cost = (total_tokens / 1_000_000) * cost_per_million_tokens]

44
00:04:18,000 --> 00:04:24,000
We return the metrics.
[Types: return {"chunk_count": len(chunks), "total_tokens": total_tokens, "estimated_cost_usd": round(cost, 4)}]

45
00:04:24,000 --> 00:04:30,000
This is useful for monitoring and cost optimization.

46
00:04:30,000 --> 00:04:36,000
Now let's implement the _chunk_section method. This splits a section into chunks.
[Types: def _chunk_section(self, text: str, section_name: str, filing_id: uuid.UUID, meta: FilingMetadata, start_index: int) -> list[FinancialChunk]:]

47
00:04:36,000 --> 00:04:42,000
We encode the text to tokens.
[Types: tokens = self._encoding.encode(text)]

48
00:04:42,000 --> 00:04:48,000
If there are no tokens, we return an empty list.
[Types: if not tokens: return []]

49
00:04:48,000 --> 00:04:54,000
If the entire section fits in one chunk, we return a single chunk.
[Types: if len(tokens) <= self._chunk_size: return [self._build_chunk(text=text, token_count=len(tokens), section=section_name, chunk_index=start_index, filing_id=filing_id, meta=meta)]]

50
00:04:54,000 --> 00:05:00,000
This optimization avoids unnecessary splitting for short sections.

51
00:05:00,000 --> 00:05:06,000
We initialize the chunks list.
[Types: chunks: list[FinancialChunk] = []]

52
00:05:06,000 --> 00:05:12,000
We initialize the start position.
[Types: start = 0]

53
00:05:12,000 --> 00:05:18,000
We initialize the chunk index.
[Types: chunk_index = start_index]

54
00:05:18,000 --> 00:05:24,000
Now we loop through the tokens with a sliding window.
[Types: while start < len(tokens):]

55
00:05:24,000 --> 00:05:30,000
We calculate the end position.
[Types: end = min(start + self._chunk_size, len(tokens))]

56
00:05:30,000 --> 00:05:36,000
We extract the chunk tokens.
[Types: chunk_tokens = tokens[start:end]]

57
00:05:36,000 --> 00:05:42,000
We decode the tokens back to text.
[Types: chunk_text = self._encoding.decode(chunk_tokens)]

58
00:05:42,000 --> 00:05:48,000
This is the exact reversal of the encoding process. The text is exactly what
the tokens represent.

59
00:05:48,000 --> 00:05:54,000
We skip near-empty chunks at the end of the section.
[Types: if len(chunk_text.strip()) < 50: break]

60
00:05:54,000 --> 00:06:00,000
This prevents tiny chunks that don't contain meaningful content.

61
00:06:00,000 --> 00:06:06,000
We build the chunk and add it to the list.
[Types: chunks.append(self._build_chunk(text=chunk_text, token_count=len(chunk_tokens), section=section_name, chunk_index=chunk_index, filing_id=filing_id, meta=meta))]

62
00:06:06,000 --> 00:06:12,000
We increment the chunk index.
[Types: chunk_index += 1]

63
00:06:12,000 --> 00:06:18,000
We calculate the step size.
[Types: step = self._chunk_size - self._chunk_overlap]

64
00:06:18,000 --> 00:06:24,000
We advance the start position by the step size.
[Types: start += step]

65
00:06:24,000 --> 00:06:30,000
If step is 0 or negative, we break the loop to avoid infinite loops.
[Types: if step <= 0: logger.warning("chunk_overlap >= chunk_size — processing single chunk only") break]

66
00:06:30,000 --> 00:06:36,000
This safety check prevents infinite loops if overlap is greater than or equal
to chunk size.

67
00:06:36,000 --> 00:06:42,000
We return the chunks.
[Types: return chunks]

68
00:06:42,000 --> 00:06:48,000
Now let's implement the _build_chunk method. This creates a FinancialChunk
from a chunk specification.
[Types: def _build_chunk(self, *, text: str, token_count: int, section: str, chunk_index: int, filing_id: uuid.UUID, meta: FilingMetadata) -> FinancialChunk:]

69
00:06:48,000 --> 00:06:54,000
We import TextParser for extracting metrics.
[Types: from financial_rag.ingestion.parsers.text_parser import TextParser]

70
00:06:54,000 --> 00:07:00,000
We create a TextParser instance.
[Types: text_parser = TextParser()]

71
00:07:00,000 --> 00:07:06,000
We extract metrics from the chunk text.
[Types: metrics = text_parser.extract_metrics(text)]

72
00:07:06,000 --> 00:07:12,000
We create and return a FinancialChunk.
[Types: return FinancialChunk(id=uuid.uuid4(), filing_id=filing_id, ticker=meta.ticker, filing_type=meta.filing_type, fiscal_year=meta.fiscal_year, section=section, chunk_index=chunk_index, chunk_text=text, token_count=token_count, embedding=[], metrics=metrics, entities={}, sentiment_score=None, model_version=self._settings.EMBEDDING_MODEL)]

73
00:07:12,000 --> 00:07:18,000
The embedding field is intentionally left empty. It will be populated by the
embeddings module before storage.

74
00:07:18,000 --> 00:07:24,000
Now let's update the processing __init__.py file.
Open `src/financial_rag/processing/__init__.py`.

75
00:07:24,000 --> 00:07:30,000
We import the TextProcessor.
[Types: from .text_processor import TextProcessor]

76
00:07:30,000 --> 00:07:36,000
We export it.
[Types: __all__ = ["TextProcessor"]]

77
00:07:36,000 --> 00:07:42,000
Now let's test the TextProcessor. Open a Python shell.

78
00:07:42,000 --> 00:07:48,000
[Types: python]
[Types: from financial_rag.ingestion.parsers.html_parser import HTMLParser]
[Types: from financial_rag.processing import TextProcessor]

79
00:07:48,000 --> 00:07:54,000
[Types: html = "<html><body><p>Apple Inc. reported revenue of $394 billion.</p></body></html>"]
[Types: parser = HTMLParser()]
[Types: parsed = parser.parse(html, ticker="AAPL", filing_type="10-K", fiscal_year=2024)]

80
00:07:54,000 --> 00:08:00,000
[Types: processor = TextProcessor()]
[Types: from financial_rag.ingestion.sec_ingestor import FilingMetadata]
[Types: meta = FilingMetadata(ticker="AAPL", filing_type="10-K", fiscal_year=2024, fiscal_quarter=None, filed_at=None, accession_number="test", primary_document="test", source_url="test", cik="0000320193")]

81
00:08:00,000 --> 00:08:06,000
[Types: import uuid]
[Types: filing_id = uuid.uuid4()]
[Types: chunks = processor.process(parsed, meta, filing_id)]

82
00:08:06,000 --> 00:08:12,000
[Types: print(f"Created {len(chunks)} chunks")]
[Types: print(f"First chunk: {chunks[0].chunk_text[:100]}...")]

83
00:08:12,000 --> 00:08:18,000
You should see one chunk created. The text processor worked correctly.

84
00:08:18,000 --> 00:08:24,000
Now let me explain the chunking strategy. We use a sliding window approach
with overlap. This ensures that important information near chunk boundaries
is preserved.

85
00:08:24,000 --> 00:08:30,000
The overlap is 50 tokens by default. This means each chunk shares 50 tokens
with the previous and next chunks. This improves retrieval quality.

86
00:08:30,000 --> 00:08:36,000
The chunk size is 512 tokens by default. This is the optimal size for
text-embedding-3-small. It balances context and cost.

87
00:08:36,000 --> 00:08:42,000
Now let me recap what we've built in Part 2.

88
00:08:42,000 --> 00:08:48,000
We built the TextProcessor class. It has four main methods: process for the
full pipeline, count_tokens for exact token counting, estimate_cost for
cost estimation, and internal methods for chunking and building chunks.

89
00:08:48,000 --> 00:08:54,000
We use tiktoken for exact token counting. This is more accurate than
heuristic approximations.

90
00:08:54,000 --> 00:09:00,000
We use a sliding window chunking strategy with overlap. This preserves
context across chunk boundaries.

91
00:09:00,000 --> 00:09:06,000
In Part 3, we'll build the Embedding Client. This will embed our chunks
using OpenAI's text-embedding-3 model.

92
00:09:06,000 --> 00:09:12,000
Thank you for watching. I'll see you in Part 3.

93
00:09:12,000 --> 00:09:16,000
[End of Part 2]
1
00:00:00,000 --> 00:00:06,000
Welcome back to Phase 3. In Part 3, we build the embedding client.

2
00:00:06,000 --> 00:00:12,000
This is one of the most important components in our RAG system.
Embeddings are what make semantic search possible.

3
00:00:12,000 --> 00:00:18,000
Without embeddings, we can't find similar chunks of text.
Without embeddings, we can't do vector search.
Without embeddings, there is no RAG.

4
00:00:18,000 --> 00:00:24,000
Open your editor and create `src/financial_rag/retrieval/embeddings.py`.

5
00:00:24,000 --> 00:00:30,000
We'll start with the imports. The __future__ import enables forward references.
[Types: from __future__ import annotations]

6
00:00:30,000 --> 00:00:36,000
We import logging for structured logging throughout the client.
[Types: import logging]

7
00:00:36,000 --> 00:00:42,000
We import time for measuring embedding latency.
[Types: import time]

8
00:00:42,000 --> 00:00:48,000
We import the tenacity decorators for retry logic with exponential backoff.
[Types: from tenacity import retry, retry_if_exception_type, stop_after_attempt, wait_exponential]

9
00:00:48,000 --> 00:00:54,000
We import get_settings from our config module.
[Types: from financial_rag.config import get_settings]

10
00:00:54,000 --> 00:01:00,000
We import EmbeddingError from our exception hierarchy.
[Types: from financial_rag.utils.exceptions import EmbeddingError]

11
00:01:00,000 --> 00:01:06,000
Now let's define the OpenAI cost dictionary. This maps models to cost per million tokens.
[Types: _OPENAI_COSTS: dict[str, float] = { "text-embedding-3-large": 0.13, "text-embedding-3-small": 0.02, "text-embedding-ada-002": 0.10, }]

12
00:01:06,000 --> 00:01:12,000
As of mid-2024, text-embedding-3-large costs $0.13 per million tokens.
text-embedding-3-small costs $0.02 per million tokens.
text-embedding-ada-002 costs $0.10 per million tokens.

13
00:01:12,000 --> 00:01:18,000
We use these costs for estimating embedding expenses during ingestion.
This helps us track and optimize our LLM costs.

14
00:01:18,000 --> 00:01:24,000
Now let's define the abstract base class for embedding providers.
[Types: class EmbeddingProvider:]

15
00:01:24,000 --> 00:01:30,000
This defines the interface that all embedding providers must implement.
[Types: @property def dimensions(self) -> int: raise NotImplementedError]

16
00:01:30,000 --> 00:01:36,000
The dimensions property returns the vector dimensions for this provider.
OpenAI text-embedding-3-large has 3072 dimensions.
text-embedding-3-small has 1536 dimensions.
Our local model has 384 dimensions.

17
00:01:36,000 --> 00:01:42,000
We use NotImplementedError to ensure subclasses implement this property.

18
00:01:42,000 --> 00:01:48,000
Now the embed_batch method. This embeds a batch of texts synchronously.
[Types: def embed_batch(self, texts: list[str]) -> list[list[float]]: raise NotImplementedError]

19
00:01:48,000 --> 00:01:54,000
This is used during bulk ingestion. We embed chunks in batches.
The synchronous version is called from the async version using an executor.

20
00:01:54,000 --> 00:02:00,000
Now the async version. This embeds a batch of texts asynchronously.
[Types: async def embed_batch_async(self, texts: list[str]) -> list[list[float]]: raise NotImplementedError]

21
00:02:00,000 --> 00:02:06,000
This is used during real-time queries. We embed the query text.
The async version doesn't block the event loop.

22
00:02:06,000 --> 00:02:12,000
Now let's implement the OpenAI provider. This is the production provider.
[Types: class OpenAIEmbeddingProvider(EmbeddingProvider):]

23
00:02:12,000 --> 00:02:18,000
We start with the init method.
[Types: def __init__(self) -> None:]

24
00:02:18,000 --> 00:02:24,000
We need to import OpenAI and AsyncOpenAI from the openai package.
[Types: from openai import AsyncOpenAI, OpenAI]

25
00:02:24,000 --> 00:02:30,000
We get the settings instance.
[Types: settings = get_settings()]

26
00:02:30,000 --> 00:02:36,000
We check if the OpenAI API key is set. If not, raise an error.
[Types: if not settings.OPENAI_API_KEY: raise EmbeddingError( "OPENAI_API_KEY is required for OpenAI embedding provider." "Set it in .env or switch EMBEDDING_PROVIDER=local." )]

27
00:02:36,000 --> 00:02:42,000
We extract the API key from the SecretStr.
[Types: api_key = settings.OPENAI_API_KEY.get_secret_value()]

28
00:02:42,000 --> 00:02:48,000
We store the model name and dimensions from settings.
[Types: self._model = settings.EMBEDDING_MODEL]
[Types: self._dimensions = settings.EMBEDDING_DIMENSIONS]

29
00:02:48,000 --> 00:02:54,000
We create the synchronous OpenAI client.
[Types: self._client = OpenAI(api_key=api_key)]

30
00:02:54,000 --> 00:03:00,000
And the asynchronous OpenAI client.
[Types: self._async_client = AsyncOpenAI(api_key=api_key)]

31
00:03:00,000 --> 00:03:06,000
We log that the OpenAI provider is initialized.
[Types: logger.info( "OpenAI embedding provider initialised — model=%s dims=%d", self._model, self._dimensions, )]

32
00:03:06,000 --> 00:03:12,000
Now let's implement the dimensions property.
[Types: @property def dimensions(self) -> int: return self._dimensions]

33
00:03:12,000 --> 00:03:18,000
This returns the configured dimensions for the OpenAI provider.

34
00:03:18,000 --> 00:03:24,000
Now let's implement the synchronous embed_batch method with retry logic.
[Types: @retry( retry=retry_if_exception_type(EmbeddingError), stop=stop_after_attempt(3), wait=wait_exponential(multiplier=1, min=2, max=30), reraise=True, ) def embed_batch(self, texts: list[str]) -> list[list[float]]:]

35
00:03:24,000 --> 00:03:30,000
The @retry decorator handles transient failures. If EmbeddingError is raised,
it retries up to 3 times with exponential backoff.

36
00:03:30,000 --> 00:03:36,000
We check if texts is empty. If so, return an empty list.
[Types: if not texts: return []]

37
00:03:36,000 --> 00:03:42,000
We wrap the API call in a try-except block.
[Types: try:]

38
00:03:42,000 --> 00:03:48,000
We start the timer for latency tracking.
[Types: t0 = time.monotonic()]

39
00:03:48,000 --> 00:03:54,000
We call the OpenAI embeddings API.
[Types: response = self._client.embeddings.create( model=self._model, input=texts, dimensions=self._dimensions, )]

40
00:03:54,000 --> 00:04:00,000
We calculate the latency.
[Types: latency = time.monotonic() - t0]

41
00:04:00,000 --> 00:04:06,000
We extract the embeddings from the response.
[Types: embeddings = [item.embedding for item in response.data]]

42
00:04:06,000 --> 00:04:12,000
We get the token usage from the response.
[Types: tokens_used = response.usage.total_tokens]

43
00:04:12,000 --> 00:04:18,000
We estimate the cost using our cost dictionary.
[Types: cost = self._estimate_cost(tokens_used)]

44
00:04:18,000 --> 00:04:24,000
We log the batch details.
[Types: logger.info( "OpenAI embed_batch — texts=%d tokens=%d cost=$%.4f latency=%.2fs", len(texts), tokens_used, cost, latency, )]

45
00:04:24,000 --> 00:04:30,000
We validate the dimensions of the returned embeddings.
[Types: self._validate_dimensions(embeddings)]

46
00:04:30,000 --> 00:04:36,000
We return the embeddings.
[Types: return embeddings]

47
00:04:36,000 --> 00:04:42,000
If an exception occurs, we wrap it in EmbeddingError.
[Types: except Exception as exc: raise EmbeddingError( f"OpenAI embedding failed for batch of {len(texts)} texts: {exc}" ) from exc]

48
00:04:42,000 --> 00:04:48,000
Now let's implement the async version.
[Types: @retry( retry=retry_if_exception_type(EmbeddingError), stop=stop_after_attempt(3), wait=wait_exponential(multiplier=1, min=2, max=30), reraise=True, ) async def embed_batch_async(self, texts: list[str]) -> list[list[float]]:]

49
00:04:48,000 --> 00:04:54,000
This is almost identical to the synchronous version but uses the async client.
[Types: if not texts: return []]

50
00:04:54,000 --> 00:05:00,000
We wrap the API call in a try-except block.
[Types: try:]

51
00:05:00,000 --> 00:05:06,000
We start the timer.
[Types: t0 = time.monotonic()]

52
00:05:06,000 --> 00:05:12,000
We call the async OpenAI embeddings API.
[Types: response = await self._async_client.embeddings.create( model=self._model, input=texts, dimensions=self._dimensions, )]

53
00:05:12,000 --> 00:05:18,000
We calculate the latency.
[Types: latency = time.monotonic() - t0]

54
00:05:18,000 --> 00:05:24,000
We extract the embeddings.
[Types: embeddings = [item.embedding for item in response.data]]

55
00:05:24,000 --> 00:05:30,000
We get the token usage.
[Types: tokens_used = response.usage.total_tokens]

56
00:05:30,000 --> 00:05:36,000
We estimate the cost.
[Types: cost = self._estimate_cost(tokens_used)]

57
00:05:36,000 --> 00:05:42,000
We log the batch details.
[Types: logger.info( "OpenAI embed_batch_async — texts=%d tokens=%d cost=$%.4f latency=%.2fs", len(texts), tokens_used, cost, latency, )]

58
00:05:42,000 --> 00:05:48,000
We validate the dimensions.
[Types: self._validate_dimensions(embeddings)]

59
00:05:48,000 --> 00:05:54,000
We return the embeddings.
[Types: return embeddings]

60
00:05:54,000 --> 00:06:00,000
If an exception occurs, we wrap it in EmbeddingError.
[Types: except Exception as exc: raise EmbeddingError( f"OpenAI async embedding failed for batch of {len(texts)} texts: {exc}" ) from exc]

61
00:06:00,000 --> 00:06:06,000
Now let's implement the cost estimation method.
[Types: def _estimate_cost(self, tokens: int) -> float: rate = _OPENAI_COSTS.get(self._model, 0.13) return (tokens / 1_000_000) * rate]

62
00:06:06,000 --> 00:06:12,000
This uses the cost dictionary to calculate the cost of embedding.
If the model isn't in the dictionary, we use the default rate of $0.13.

63
00:06:12,000 --> 00:06:18,000
Now let's implement the dimension validation method.
[Types: def _validate_dimensions(self, embeddings: list[list[float]]) -> None: if not embeddings: return actual = len(embeddings[0]) if actual != self._dimensions: raise EmbeddingError( f"Dimension mismatch: expected {self._dimensions}, " f"got {actual} from OpenAI." )]

64
00:06:18,000 --> 00:06:24,000
This ensures the embeddings have the correct dimensions.
If there's a mismatch, we raise EmbeddingError with a clear message.

65
00:06:24,000 --> 00:06:30,000
Now let's implement the local embedding provider. This uses sentence-transformers.
[Types: class LocalEmbeddingProvider(EmbeddingProvider):]

66
00:06:30,000 --> 00:06:36,000
We start with the init method.
[Types: def __init__(self) -> None:]

67
00:06:36,000 --> 00:06:42,000
We try to import SentenceTransformer from sentence-transformers.
[Types: try: from sentence_transformers import SentenceTransformer except ImportError as e: raise ImportError( "sentence-transformers is required for local embeddings." "Install it with: pip install sentence-transformers" ) from e]

68
00:06:42,000 --> 00:06:48,000
If sentence-transformers isn't installed, we raise a clear error message.

69
00:06:48,000 --> 00:06:54,000
We get the settings instance.
[Types: settings = get_settings()]

70
00:06:54,000 --> 00:07:00,000
We store the model name and dimensions from settings.
[Types: self._model_name = settings.EMBEDDING_MODEL]
[Types: self._dimensions = settings.EMBEDDING_DIMENSIONS]

71
00:07:00,000 --> 00:07:06,000
We log that we're loading the local model.
[Types: logger.info( "Loading local embedding model '%s' (this may take a moment)...", self._model_name, )]

72
00:07:06,000 --> 00:07:12,000
We load the model using SentenceTransformer.
[Types: try: self._model = SentenceTransformer(self._model_name) except Exception as exc: raise EmbeddingError(f"Failed to load local model '{self._model_name}': {exc}") from exc]

73
00:07:12,000 --> 00:07:18,000
The model download may take a moment on first load.
Subsequent loads use the cached model.

74
00:07:18,000 --> 00:07:24,000
We log that the local provider is ready.
[Types: logger.info( "Local embedding provider ready — model=%s dims=%d", self._model_name, self._dimensions, )]

75
00:07:24,000 --> 00:07:30,000
Now let's implement the dimensions property.
[Types: @property def dimensions(self) -> int: return self._dimensions]

76
00:07:30,000 --> 00:07:36,000
This returns the configured dimensions for the local provider.

77
00:07:36,000 --> 00:07:42,000
Now let's implement the synchronous embed_batch method.
[Types: def embed_batch(self, texts: list[str]) -> list[list[float]]:]

78
00:07:42,000 --> 00:07:48,000
If texts is empty, return an empty list.
[Types: if not texts: return []]

79
00:07:48,000 --> 00:07:54,000
We wrap the embedding in a try-except block.
[Types: try:]

80
00:07:54,000 --> 00:08:00,000
We start the timer for latency tracking.
[Types: t0 = time.monotonic()]

81
00:08:00,000 --> 00:08:06,000
We call the SentenceTransformer encode method.
[Types: raw = self._model.encode( texts, convert_to_numpy=True, show_progress_bar=False, batch_size=32, )]

82
00:08:06,000 --> 00:08:12,000
convert_to_numpy=True returns numpy arrays.
show_progress_bar=False prevents progress output during tests.
batch_size=32 processes 32 texts at a time.

83
00:08:12,000 --> 00:08:18,000
We calculate the latency.
[Types: latency = time.monotonic() - t0]

84
00:08:18,000 --> 00:08:24,000
We convert the numpy arrays to Python lists.
[Types: embeddings = [vec.tolist() for vec in raw]]

85
00:08:24,000 --> 00:08:30,000
We log the batch details.
[Types: logger.info( "Local embed_batch — texts=%d latency=%.2fs", len(texts), latency, )]

86
00:08:30,000 --> 00:08:36,000
We return the embeddings.
[Types: return embeddings]

87
00:08:36,000 --> 00:08:42,000
If an exception occurs, we wrap it in EmbeddingError.
[Types: except Exception as exc: raise EmbeddingError( f"Local embedding failed for batch of {len(texts)} texts: {exc}" ) from exc]

88
00:08:42,000 --> 00:08:48,000
Now let's implement the async version of embed_batch.
[Types: async def embed_batch_async(self, texts: list[str]) -> list[list[float]]:]

89
00:08:48,000 --> 00:08:54,000
The local model is synchronous. We need to run it in a thread pool.
[Types: import asyncio]

90
00:08:54,000 --> 00:09:00,000
We get the event loop.
[Types: loop = asyncio.get_event_loop()]

91
00:09:00,000 --> 00:09:06,000
We run the synchronous method in a thread pool using run_in_executor.
[Types: return await loop.run_in_executor(None, self.embed_batch, texts)]

92
00:09:06,000 --> 00:09:12,000
This prevents the synchronous embedding from blocking the async event loop.

93
00:09:12,000 --> 00:09:18,000
Now let's implement the main EmbeddingClient class. This is the public interface.
[Types: class EmbeddingClient:]

94
00:09:18,000 --> 00:09:24,000
We start with the init method.
[Types: def __init__(self) -> None:]

95
00:09:24,000 --> 00:09:30,000
We get the settings instance.
[Types: self._settings = get_settings()]

96
00:09:30,000 --> 00:09:36,000
We build the provider based on settings.
[Types: self._provider = self._build_provider()]

97
00:09:36,000 --> 00:09:42,000
Now let's implement the build_provider method.
[Types: def _build_provider(self) -> EmbeddingProvider: settings = self._settings provider_name = settings.EMBEDDING_PROVIDER]

98
00:09:42,000 --> 00:09:48,000
If the provider is openai, check if the API key is available.
[Types: if provider_name == "openai": if not settings.OPENAI_API_KEY: if settings.APP_ENV in ("development", "testing"): logger.warning( "OPENAI_API_KEY not set — falling back to local embedding provider" ) return LocalEmbeddingProvider() else: raise EmbeddingError( "OPENAI_API_KEY is required in production. Set it in .env." ) return OpenAIEmbeddingProvider()]

99
00:09:48,000 --> 00:09:54,000
In development or testing, we fall back to the local provider if no API key is set.
In production, we raise an error.

100
00:09:54,000 --> 00:10:00,000
If the provider is not openai, we use the local provider.
[Types: return LocalEmbeddingProvider()]

101
00:10:00,000 --> 00:10:06,000
Now let's implement the dimensions property.
[Types: @property def dimensions(self) -> int: return self._provider.dimensions]

102
00:10:06,000 --> 00:10:12,000
This delegates to the underlying provider.

103
00:10:12,000 --> 00:10:18,000
Now let's implement the provider_name property.
[Types: @property def provider_name(self) -> str: return type(self._provider).__name__]

104
00:10:18,000 --> 00:10:24,000
This returns the name of the provider class for logging and metrics.

105
00:10:24,000 --> 00:10:30,000
Now let's implement the embed_texts method. This is the public embed method.
[Types: async def embed_texts(self, texts: list[str]) -> list[list[float]]:]

106
00:10:30,000 --> 00:10:36,000
If texts is empty, return an empty list.
[Types: if not texts: return []]

107
00:10:36,000 --> 00:10:42,000
We get the batch size from settings.
[Types: settings = self._settings]
[Types: batch_size = settings.EMBEDDING_BATCH_SIZE]

108
00:10:42,000 --> 00:10:48,000
We initialize an empty list for all embeddings.
[Types: all_embeddings: list[list[float]] = []]

109
00:10:48,000 --> 00:10:54,000
We process the texts in batches.
[Types: for i in range(0, len(texts), batch_size): batch = texts[i:i + batch_size] batch_num = i // batch_size + 1 total_batches = (len(texts) + batch_size - 1) // batch_size]

110
00:10:54,000 --> 00:11:00,000
We log the batch progress.
[Types: logger.debug( "Embedding batch %d/%d (%d texts)", batch_num, total_batches, len(batch), )]

111
00:11:00,000 --> 00:11:06,000
We embed the batch using the provider's async method.
[Types: embeddings = await self._provider.embed_batch_async(batch)]

112
00:11:06,000 --> 00:11:12,000
We extend the all_embeddings list with the batch embeddings.
[Types: all_embeddings.extend(embeddings)]

113
00:11:12,000 --> 00:11:18,000
We return all embeddings.
[Types: return all_embeddings]

114
00:11:18,000 --> 00:11:24,000
Now let's implement the embed_chunks method. This embeds FinancialChunk objects.
[Types: async def embed_chunks(self, chunks: list) -> list:]

115
00:11:24,000 --> 00:11:30,000
If chunks is empty, return an empty list.
[Types: if not chunks: return []]

116
00:11:30,000 --> 00:11:36,000
We extract the chunk texts.
[Types: texts = [c.chunk_text for c in chunks]]

117
00:11:36,000 --> 00:11:42,000
We embed the texts using embed_texts.
[Types: embeddings = await self.embed_texts(texts)]

118
00:11:42,000 --> 00:11:48,000
We check that the number of embeddings matches the number of chunks.
[Types: if len(embeddings) != len(chunks): raise EmbeddingError( f"Embedding count mismatch: got {len(embeddings)} " f"embeddings for {len(chunks)} chunks." )]

119
00:11:48,000 --> 00:11:54,000
We populate the embedding field on each chunk.
[Types: for chunk, embedding in zip(chunks, embeddings, strict=False): chunk.embedding = embedding]

120
00:11:54,000 --> 00:12:00,000
We log the completed embedding.
[Types: logger.info( "Populated embeddings for %d chunks via %s", len(chunks), self.provider_name, )]

121
00:12:00,000 --> 00:12:06,000
We return the chunks with embeddings populated.
[Types: return chunks]

122
00:12:06,000 --> 00:12:12,000
Now let's implement the embed_query method. This embeds a single query string.
[Types: async def embed_query(self, query: str) -> list[float]:]

123
00:12:12,000 --> 00:12:18,000
We call embed_texts with a single-item list and return the first result.
[Types: results = await self.embed_texts([query])]
[Types: return results[0]]

124
00:12:18,000 --> 00:12:24,000
This is a convenience method for embedding search queries.

125
00:12:24,000 --> 00:12:30,000
Now let's update the retrieval __init__.py file.
Open `src/financial_rag/retrieval/__init__.py`.

126
00:12:30,000 --> 00:12:36,000
We import EmbeddingClient from the embeddings module.
[Types: from .embeddings import EmbeddingClient]

127
00:12:36,000 --> 00:12:42,000
We add it to __all__.
[Types: __all__ = ["EmbeddingClient"]]

128
00:12:42,000 --> 00:12:48,000
Now let me show you the complete file. You should have this in your editor.

129
00:12:48,000 --> 00:12:54,000
[Show the complete embeddings.py file]

130
00:12:54,000 --> 00:13:00,000
Now let's test the embedding client. Open a Python shell.

131
00:13:00,000 --> 00:13:06,000
[Types: from financial_rag.retrieval import EmbeddingClient]
[Types: client = EmbeddingClient()]

132
00:13:06,000 --> 00:13:12,000
[Types: print(client.provider_name)]
[Types: print(client.dimensions)]

133
00:13:12,000 --> 00:13:18,000
If you have OPENAI_API_KEY set, you should see "OpenAIEmbeddingProvider" and 1536.
If not, you should see "LocalEmbeddingProvider" and 384.

134
00:13:18,000 --> 00:13:24,000
[Types: vector = await client.embed_query("What was Apple's revenue?")]
[Types: print(len(vector))]

135
00:13:24,000 --> 00:13:30,000
You should see a vector with 1536 or 384 dimensions.
This confirms the embedding client is working.

136
00:13:30,000 --> 00:13:36,000
Now let me give you a performance tip. The local model is slower than OpenAI.
For production, use OpenAI. For development and testing, use local.

137
00:13:36,000 --> 00:13:42,000
The local model loads once and caches the model in memory.
First load takes about 3 seconds. Subsequent loads are instant.

138
00:13:42,000 --> 00:13:48,000
Now let me give you a cost tip. OpenAI embedding costs about $0.13 per million tokens.
For a 100-chunk filing with 500 tokens per chunk, that's 50,000 tokens.
Cost per filing is about $0.0065. Very cheap.

139
00:13:48,000 --> 00:13:54,000
Now let me recap what we've built in Part 3.

140
00:13:54,000 --> 00:14:00,000
We built the EmbeddingProvider abstract base class. This defines the interface
for all embedding providers.

141
00:14:00,000 --> 00:14:06,000
We built the OpenAIEmbeddingProvider. This uses the OpenAI API with
retry logic, cost estimation, and dimension validation.

142
00:14:06,000 --> 00:14:12,000
We built the LocalEmbeddingProvider. This uses sentence-transformers
with the all-MiniLM-L6-v2 model for local embedding.

143
00:14:12,000 --> 00:14:18,000
We built the EmbeddingClient. This chooses the appropriate provider
based on settings and provides a unified interface.

144
00:14:18,000 --> 00:14:24,000
In Part 4, we'll build the Chunks Repository. This stores chunks and embeddings
in pgvector and provides similarity search.

145
00:14:24,000 --> 00:14:30,000
Thank you for watching. I'll see you in Part 4.

146
00:14:30,000 --> 00:14:34,000
[End of Part 3]
1
00:00:00,000 --> 00:00:06,000
Welcome back to Phase 3. In Part 4, we build the Chunks Repository.

2
00:00:06,000 --> 00:00:12,000
This is the most important data access layer in our entire application.
It handles vector similarity search. It retrieves chunks from pgvector.

3
00:00:12,000 --> 00:00:18,000
Without this repository, we can't do RAG. Without vector search, we can't
find relevant documents. This is the heart of the retrieval system.

4
00:00:18,000 --> 00:00:24,000
Open your editor and create `src/financial_rag/storage/repositories/chunks.py`.

5
00:00:24,000 --> 00:00:30,000
We'll start with the imports. The __future__ import enables forward references.
[Types: from __future__ import annotations]

6
00:00:30,000 --> 00:00:36,000
We import logging for structured logging throughout the repository.
[Types: import logging]

7
00:00:36,000 --> 00:00:42,000
We import UUID from the standard library for primary key handling.
[Types: from uuid import UUID]

8
00:00:42,000 --> 00:00:48,000
We import Vector from pgvector.sqlalchemy for the vector data type.
[Types: from pgvector.sqlalchemy import Vector]

9
00:00:48,000 --> 00:00:54,000
We import SQLAlchemy types. Float for floating point values.
[Types: from sqlalchemy import Float]

10
00:00:54,000 --> 00:01:00,000
Integer for integer values. SmallInteger for small integers.
[Types: from sqlalchemy import Integer, SmallInteger]

11
00:01:00,000 --> 00:01:06,000
String for string values. Text for long text values.
[Types: from sqlalchemy import String, Text]

12
00:01:06,000 --> 00:01:12,000
We import func for SQL functions like count and avg.
[Types: from sqlalchemy import func]

13
00:01:12,000 --> 00:01:18,000
We import select for building queries.
[Types: from sqlalchemy import select]

14
00:01:18,000 --> 00:01:24,000
We import text for raw SQL queries when needed.
[Types: from sqlalchemy import text]

15
00:01:24,000 --> 00:01:30,000
Now we import the PostgreSQL-specific types. JSONB for flexible JSON storage.
[Types: from sqlalchemy.dialects.postgresql import JSONB]

16
00:01:30,000 --> 00:01:36,000
We import UUID as PG_UUID for PostgreSQL UUID compatibility.
[Types: from sqlalchemy.dialects.postgresql import UUID as PG_UUID]

17
00:01:36,000 --> 00:01:42,000
Now we import the ORM mapping types. Mapped for type hints.
[Types: from sqlalchemy.orm import Mapped]

18
00:01:42,000 --> 00:01:48,000
And mapped_column for defining columns.
[Types: from sqlalchemy.orm import mapped_column]

19
00:01:48,000 --> 00:01:54,000
We import Base from our database module. This is the declarative base.
[Types: from financial_rag.storage.database import Base]

20
00:01:54,000 --> 00:02:00,000
We import BaseRepository from the base module.
[Types: from financial_rag.storage.repositories.base import BaseRepository]

21
00:02:00,000 --> 00:02:06,000
We import DatabaseQueryError for handling database errors.
[Types: from financial_rag.utils.exceptions import DatabaseQueryError]

22
00:02:06,000 --> 00:02:12,000
We import VectorSearchError for vector-specific errors.
[Types: from financial_rag.utils.exceptions import VectorSearchError]

23
00:02:12,000 --> 00:02:18,000
Now let's define the ORM model for financial chunks.
[Types: class FinancialChunk(Base):]

24
00:02:18,000 --> 00:02:24,000
We set the table name to match our schema.
[Types: __tablename__ = "financial_chunks"]

25
00:02:24,000 --> 00:02:30,000
Now let's define the id column. This is the primary key.
[Types: id: Mapped[UUID] = mapped_column(PG_UUID(as_uuid=True), primary_key=True)]

26
00:02:30,000 --> 00:02:36,000
We use PG_UUID to map PostgreSQL UUID to Python UUID. We use as_uuid=True
to automatically convert between the two types.

27
00:02:36,000 --> 00:02:42,000
Now the filing_id column. This links back to the filings table.
[Types: filing_id: Mapped[UUID] = mapped_column(PG_UUID(as_uuid=True), nullable=False, index=True)]

28
00:02:42,000 --> 00:02:48,000
We add index=True because we often query chunks by filing_id.
We set nullable=False because every chunk belongs to a filing.

29
00:02:48,000 --> 00:02:54,000
Now the ticker column. This is denormalized for faster queries.
[Types: ticker: Mapped[str] = mapped_column(String(10), nullable=False)]

30
00:02:54,000 --> 00:03:00,000
We denormalize ticker so we don't need to join with filings for every query.
This makes search much faster.

31
00:03:00,000 --> 00:03:06,000
Now the filing_type column. Also denormalized for speed.
[Types: filing_type: Mapped[str] = mapped_column(String(20), nullable=False)]

32
00:03:06,000 --> 00:03:12,000
We store the filing type directly on each chunk for faster filtering.

33
00:03:12,000 --> 00:03:18,000
Now the fiscal_year column. Denormalized for fast year filtering.
[Types: fiscal_year: Mapped[int | None] = mapped_column(SmallInteger)]

34
00:03:18,000 --> 00:03:24,000
We use SmallInteger because years fit in a small integer.
We allow None because some filings might not have a fiscal year.

35
00:03:24,000 --> 00:03:30,000
Now the section column. This identifies which section the chunk came from.
[Types: section: Mapped[str | None] = mapped_column(String(100))]

36
00:03:30,000 --> 00:03:36,000
We use String(100) because section names are short like "MD&A" or "Risk Factors".
We allow None because some chunks might not have a section.

37
00:03:36,000 --> 00:03:42,000
Now the chunk_index column. This tracks the order of chunks within a filing.
[Types: chunk_index: Mapped[int] = mapped_column(Integer, nullable=False)]

38
00:03:42,000 --> 00:03:48,000
We use Integer because indices can be large. We set nullable=False because
every chunk has an index.

39
00:03:48,000 --> 00:03:54,000
Now the chunk_text column. This stores the actual text of the chunk.
[Types: chunk_text: Mapped[str] = mapped_column(Text, nullable=False)]

40
00:03:54,000 --> 00:04:00,000
We use Text because chunks can be long. We set nullable=False because
every chunk has text.

41
00:04:00,000 --> 00:04:06,000
Now the token_count column. This stores the exact token count from tiktoken.
[Types: token_count: Mapped[int | None] = mapped_column(Integer)]

42
00:04:06,000 --> 00:04:12,000
We allow None because we might not always have the token count.
But in practice, we always calculate it.

43
00:04:12,000 --> 00:04:18,000
Now the embedding column. This stores the vector embedding of the chunk text.
[Types: embedding: Mapped[list[float]] = mapped_column(Vector(384), nullable=False)]

44
00:04:18,000 --> 00:04:24,000
We use Vector(384) for the pgvector type. This matches the all-MiniLM-L6-v2
model dimensions. In production with OpenAI, this would be 1536.

45
00:04:24,000 --> 00:04:30,000
Now the metrics column. This stores extracted financial metrics in JSON.
[Types: metrics: Mapped[dict[str, object]] = mapped_column(JSONB, default=dict, nullable=False)]

46
00:04:30,000 --> 00:04:36,000
We use JSONB for flexible schema. This allows us to store different metrics
for different chunks without changing the schema.

47
00:04:36,000 --> 00:04:42,000
Now the entities column. This stores extracted entities in JSON.
[Types: entities: Mapped[dict[str, object]] = mapped_column(JSONB, default=dict, nullable=False)]

48
00:04:42,000 --> 00:04:48,000
Entities include company names, people, dates, and amounts.
This will be populated by the NER pipeline in a future phase.

49
00:04:48,000 --> 00:04:54,000
Now the sentiment_score column. This stores a sentiment score between -1 and 1.
[Types: sentiment_score: Mapped[float | None] = mapped_column(Float)]

50
00:04:54,000 --> 00:05:00,000
We use Float for the score. We allow None because we might not always
calculate sentiment.

51
00:05:00,000 --> 00:05:06,000
Now the model_version column. This identifies which embedding model was used.
[Types: model_version: Mapped[str] = mapped_column(String(50), nullable=False, default="text-embedding-3-large")]

52
00:05:06,000 --> 00:05:12,000
We store the model version so we can track changes in embedding quality.
This is important when upgrading embedding models.

53
00:05:12,000 --> 00:05:18,000
Now let's define the string representation. This is for debugging.
[Types: def __repr__(self) -> str:]

54
00:05:18,000 --> 00:05:24,000
We return a string with the id, ticker, section, and chunk_index.
[Types: return f"<FinancialChunk id={self.id} ticker={self.ticker} section={self.section} idx={self.chunk_index}>"]

55
00:05:24,000 --> 00:05:30,000
This makes it easy to identify chunks when debugging.

56
00:05:30,000 --> 00:05:36,000
Now let's define the ChunksRepository class.
[Types: class ChunksRepository(BaseRepository[FinancialChunk]):]

57
00:05:36,000 --> 00:05:42,000
We specify FinancialChunk as the model type.
[Types: model_class = FinancialChunk]

58
00:05:42,000 --> 00:05:48,000
Now let's implement the similarity_search method.
This is the most important method in the entire repository.
[Types: async def similarity_search(self, query_embedding: list[float], *, ticker: str | None = None, filing_type: str | None = None, fiscal_year: int | None = None, section: str | None = None, limit: int = 5, ef_search: int = 100,) -> list[tuple[FinancialChunk, float]]:]

59
00:05:48,000 --> 00:05:54,000
We take a query embedding vector and optional filters.
We return a list of chunk, score tuples. The score is cosine similarity.

60
00:05:54,000 --> 00:06:00,000
We start with the try block.
[Types: try:]

61
00:06:00,000 --> 00:06:06,000
We set the HNSW ef_search parameter for this query.
[Types: await self._session.execute(text(f"SET LOCAL hnsw.ef_search = {int(ef_search)}"))]

62
00:06:06,000 --> 00:06:12,000
ef_search controls the HNSW recall/speed tradeoff. Higher values give
better recall but are slower. 100 is the production default.

63
00:06:12,000 --> 00:06:18,000
Now we build the similarity expression.
[Types: distance_col = FinancialChunk.embedding.cosine_distance(query_embedding)]

64
00:06:18,000 --> 00:06:24,000
The cosine_distance operator calculates cosine distance. Distance ranges
from 0 (identical) to 2 (opposite).

65
00:06:24,000 --> 00:06:30,000
We convert distance to similarity. Similarity = 1 - distance.
[Types: similarity_col = (1 - distance_col).label("similarity")]

66
00:06:30,000 --> 00:06:36,000
This gives us a score from 0 to 1, where 1 means identical.

67
00:06:36,000 --> 00:06:42,000
Now we build the base query.
[Types: stmt = select(FinancialChunk, similarity_col).order_by(distance_col).limit(limit)]

68
00:06:42,000 --> 00:06:48,000
We select the chunk and the similarity score. We order by distance ascending
(the most similar first). We limit to the specified number of results.

69
00:06:48,000 --> 00:06:54,000
Now we apply filters if provided.
[Types: if ticker: stmt = stmt.where(FinancialChunk.ticker == ticker.upper())]

70
00:06:54,000 --> 00:07:00,000
We filter by ticker. We uppercase the ticker for consistency.

71
00:07:00,000 --> 00:07:06,000
[Types: if filing_type: stmt = stmt.where(FinancialChunk.filing_type == filing_type)]
We filter by filing type like "10-K" or "10-Q".

72
00:07:06,000 --> 00:07:12,000
[Types: if fiscal_year: stmt = stmt.where(FinancialChunk.fiscal_year == fiscal_year)]
We filter by fiscal year.

73
00:07:12,000 --> 00:07:18,000
[Types: if section: stmt = stmt.where(FinancialChunk.section == section)]
We filter by section like "MD&A" or "Risk Factors".

74
00:07:18,000 --> 00:07:24,000
Now we execute the query.
[Types: result = await self._session.execute(stmt)]

75
00:07:24,000 --> 00:07:30,000
We extract the rows.
[Types: rows = result.all()]

76
00:07:30,000 --> 00:07:36,000
We return a list of chunk, score tuples.
[Types: return [(row[0], float(row[1])) for row in rows]]

77
00:07:36,000 --> 00:07:42,000
If there's an error, we raise VectorSearchError.
[Types: except Exception as exc:]
[Types: raise VectorSearchError(f"Vector similarity search failed: {exc}") from exc]

78
00:07:42,000 --> 00:07:48,000
Now let's implement the mmr_search method.
MMR stands for Maximal Marginal Relevance.
[Types: async def mmr_search(self, query_embedding: list[float], *, ticker: str | None = None, filing_type: str | None = None, fiscal_year: int | None = None, limit: int = 5, fetch_k: int = 20, lambda_mult: float = 0.5,) -> list[tuple[FinancialChunk, float]]:]

79
00:07:48,000 --> 00:07:54,000
MMR balances relevance and diversity. It prevents returning near-duplicate
chunks from the same paragraph. This gives better coverage of the document.

80
00:07:54,000 --> 00:08:00,000
Step 1: Fetch more candidates than we need.
[Types: candidates = await self.similarity_search(query_embedding, ticker=ticker, filing_type=filing_type, fiscal_year=fiscal_year, limit=fetch_k)]

81
00:08:00,000 --> 00:08:06,000
We fetch fetch_k candidates (20 by default) using similarity search.
This gives us a pool to select from.

82
00:08:06,000 --> 00:08:12,000
[Types: if not candidates: return []]
If there are no candidates, return an empty list.

83
00:08:12,000 --> 00:08:18,000
Step 2: Initialize the selection.
[Types: selected: list[tuple[FinancialChunk, float]] = []]
[Types: remaining = list(candidates)]

84
00:08:18,000 --> 00:08:24,000
We maintain a list of selected chunks and a list of remaining candidates.

85
00:08:24,000 --> 00:08:30,000
Step 3: Iteratively select the best chunk.
[Types: while remaining and len(selected) < limit:]

86
00:08:30,000 --> 00:08:36,000
We continue until we've selected limit chunks or no candidates remain.

87
00:08:36,000 --> 00:08:42,000
[Types: best_idx = 0]
[Types: best_score = float("-inf")]

88
00:08:42,000 --> 00:08:48,000
We track the best candidate index and its score.

89
00:08:48,000 --> 00:08:54,000
[Types: for i, (chunk, sim_score) in enumerate(remaining):]
We iterate through each remaining candidate.

90
00:08:54,000 --> 00:09:00,000
[Types: if not selected:]
[Types: mmr_score = sim_score]
If no chunks have been selected yet, use the similarity score.

91
00:09:00,000 --> 00:09:06,000
[Types: else:]
If chunks have been selected, calculate MMR score.

92
00:09:06,000 --> 00:09:12,000
[Types: max_redundancy = max(self._cosine_similarity(chunk.embedding, sel_chunk.embedding) for sel_chunk, _ in selected)]
We calculate the maximum similarity to any already-selected chunk.

93
00:09:12,000 --> 00:09:18,000
[Types: mmr_score = lambda_mult * sim_score - (1 - lambda_mult) * max_redundancy]
The MMR score balances relevance and diversity.

94
00:09:18,000 --> 00:09:24,000
[Types: if mmr_score > best_score:]
[Types: best_score = mmr_score]
[Types: best_idx = i]
If this candidate is better, update the best.

95
00:09:24,000 --> 00:09:30,000
[Types: selected.append(remaining.pop(best_idx))]
Add the best candidate to the selected list and remove it from remaining.

96
00:09:30,000 --> 00:09:36,000
[Types: return selected]
Return the selected chunks.

97
00:09:36,000 --> 00:09:42,000
Now let's implement the bulk_upsert method.
[Types: async def bulk_upsert(self, chunks: list[FinancialChunk]) -> int:]

98
00:09:42,000 --> 00:09:48,000
This inserts or updates chunks in bulk. It uses INSERT ... ON CONFLICT
for safe re-ingestion.

99
00:09:48,000 --> 00:09:54,000
[Types: if not chunks:]
[Types: return 0]
If no chunks are provided, return 0.

100
00:09:54,000 --> 00:10:00,000
We start with the try block.
[Types: try:]

101
00:10:00,000 --> 00:10:06,000
We import the PostgreSQL insert function.
[Types: from sqlalchemy.dialects.postgresql import insert as pg_insert]

102
00:10:06,000 --> 00:10:12,000
We build the insert statement with values from the chunks.
[Types: stmt = pg_insert(FinancialChunk).values([{ "id": c.id, "filing_id": c.filing_id, "ticker": c.ticker, "filing_type": c.filing_type, "fiscal_year": c.fiscal_year, "section": c.section, "chunk_index": c.chunk_index, "chunk_text": c.chunk_text, "token_count": c.token_count, "embedding": c.embedding, "metrics": c.metrics, "entities": c.entities, "sentiment_score": c.sentiment_score, "model_version": c.model_version, } for c in chunks])]

103
00:10:12,000 --> 00:10:18,000
We convert each chunk to a dictionary of values.

104
00:10:18,000 --> 00:10:24,000
We add the ON CONFLICT clause.
[Types: stmt = stmt.on_conflict_do_update(index_elements=["id"], set_={ "chunk_text": stmt.excluded.chunk_text, "embedding": stmt.excluded.embedding, "metrics": stmt.excluded.metrics, "entities": stmt.excluded.entities, "sentiment_score": stmt.excluded.sentiment_score, "model_version": stmt.excluded.model_version, })]

105
00:10:24,000 --> 00:10:30,000
If a chunk with the same ID already exists, update the non-ID fields.
This allows safe re-ingestion without creating duplicates.

106
00:10:30,000 --> 00:10:36,000
[Types: result = await self._session.execute(stmt)]
[Types: await self._session.flush()]
[Types: logger.info("Bulk upserted %d chunks", len(chunks))]
[Types: return result.rowcount]

107
00:10:36,000 --> 00:10:42,000
If there's an error, raise DatabaseQueryError.
[Types: except Exception as exc:]
[Types: raise DatabaseQueryError(f"Bulk upsert of {len(chunks)} chunks failed: {exc}") from exc]

108
00:10:42,000 --> 00:10:48,000
Now let's implement the cosine_similarity helper method.
This is used by MMR search for calculating redundancy.
[Types: @staticmethod def _cosine_similarity(a: list[float], b: list[float]) -> float:]

109
00:10:48,000 --> 00:10:54,000
[Types: dot = sum(x * y for x, y in zip(a, b, strict=False))]
We calculate the dot product of the two vectors.

110
00:10:54,000 --> 00:11:00,000
[Types: norm_a = sum(x * x for x in a) ** 0.5]
We calculate the norm of vector A.

111
00:11:00,000 --> 00:11:06,000
[Types: norm_b = sum(x * x for x in b) ** 0.5]
We calculate the norm of vector B.

112
00:11:06,000 --> 00:11:12,000
[Types: if norm_a == 0 or norm_b == 0: return 0.0]
If either vector is zero, return 0. This prevents division by zero.

113
00:11:12,000 --> 00:11:18,000
[Types: return float(dot / (norm_a * norm_b))]
Return the cosine similarity. This is a float between -1 and 1.

114
00:11:18,000 --> 00:11:24,000
Now let's implement the get_by_filing method.
This returns all chunks for a filing.
[Types: async def get_by_filing(self, filing_id: UUID, *, section: str | None = None,) -> list[FinancialChunk]:]

115
00:11:24,000 --> 00:11:30,000
[Types: try:]
[Types: stmt = select(FinancialChunk).where(FinancialChunk.filing_id == filing_id).order_by(FinancialChunk.chunk_index)]
[Types: if section: stmt = stmt.where(FinancialChunk.section == section)]
[Types: result = await self._session.execute(stmt)]
[Types: return list(result.scalars().all())]

116
00:11:30,000 --> 00:11:36,000
[Types: except Exception as exc:]
[Types: raise DatabaseQueryError(f"Failed to fetch chunks for filing {filing_id}: {exc}") from exc]

117
00:11:36,000 --> 00:11:42,000
Now let's implement the count_by_ticker method.
This returns the total number of chunks for a ticker.
[Types: async def count_by_ticker(self, ticker: str) -> int:]

118
00:11:42,000 --> 00:11:48,000
[Types: try:]
[Types: result = await self._session.execute(select(func.count()).select_from(FinancialChunk).where(FinancialChunk.ticker == ticker.upper()))]
[Types: return result.scalar_one()]

119
00:11:48,000 --> 00:11:54,000
[Types: except Exception as exc:]
[Types: raise DatabaseQueryError(f"Failed to count chunks for ticker '{ticker}': {exc}") from exc]

120
00:11:54,000 --> 00:12:00,000
Now let's update the repositories __init__.py file.
Open `src/financial_rag/storage/repositories/__init__.py`.

121
00:12:00,000 --> 00:12:06,000
[Types: from .chunks import ChunksRepository, FinancialChunk]
We import the new classes.

122
00:12:06,000 --> 00:12:12,000
[Types: __all__ = ["AnalysisRecord", "AnalysisRepository", "BaseRepository", "ChunksRepository", "Filing", "FilingsRepository", "FinancialChunk"]]
We add them to the exports.

123
00:12:12,000 --> 00:12:18,000
Now let me recap what we've built in Part 4.

124
00:12:18,000 --> 00:12:24,000
We built the FinancialChunk ORM model. This maps to the financial_chunks table.
It has fields for id, filing_id, ticker, filing_type, fiscal_year, section,
chunk_index, chunk_text, token_count, embedding, metrics, entities,
sentiment_score, and model_version.

125
00:12:24,000 --> 00:12:30,000
We built the ChunksRepository. This provides vector similarity search with
HNSW, MMR search for diversity, and bulk_upsert for safe re-ingestion.

126
00:12:30,000 --> 00:12:36,000
The similarity_search method uses the cosine_distance operator with
HNSW indexing for fast approximate nearest neighbor search.

127
00:12:36,000 --> 00:12:42,000
The mmr_search method balances relevance and diversity using the MMR algorithm.
It prevents returning near-duplicate chunks.

128
00:12:42,000 --> 00:12:48,000
The bulk_upsert method uses INSERT ... ON CONFLICT for safe re-ingestion.
It updates non-ID fields if a chunk with the same ID already exists.

129
00:12:48,000 --> 00:12:54,000
In Part 5, we'll build the Vector Store. This orchestrates the full
chunk → embed → store pipeline.

130
00:12:54,000 --> 00:13:00,000
Thank you for watching. I'll see you in Part 5.

131
00:13:00,000 --> 00:13:04,000
[End of Part 4]
1
00:00:00,000 --> 00:00:06,000
Welcome back to Phase 3. In Part 5, we build the Vector Store.

2
00:00:06,000 --> 00:00:12,000
This is where everything comes together. The vector store orchestrates the full
pipeline from chunks to embeddings to database storage.

3
00:00:12,000 --> 00:00:18,000
Think of the vector store as the manager of a warehouse. It receives items,
stores them in the right location, and retrieves them when needed.

4
00:00:18,000 --> 00:00:24,000
Open your editor and create `src/financial_rag/storage/vector_store.py`.

5
00:00:24,000 --> 00:00:30,000
We'll start with the imports. The __future__ import enables forward references.
[Types: from __future__ import annotations]

6
00:00:30,000 --> 00:00:36,000
We import logging for structured logging throughout the vector store.
[Types: import logging]

7
00:00:36,000 --> 00:00:42,000
We import typing imports for type hints.
[Types: from typing import TYPE_CHECKING]

8
00:00:42,000 --> 00:00:48,000
We import get_db_client from the database module for database access.
[Types: from financial_rag.storage.database import get_db_client]

9
00:00:48,000 --> 00:00:54,000
We import the EmbeddingClient for generating embeddings.
[Types: from financial_rag.retrieval.embeddings import EmbeddingClient]

10
00:00:54,000 --> 00:01:00,000
We import the repositories we need for database operations.
[Types: from financial_rag.storage.repositories.chunks import ChunksRepository]

11
00:01:00,000 --> 00:01:06,000
We import the Filing model and FilingsRepository for filing operations.
[Types: from financial_rag.storage.repositories.filings import Filing, FilingsRepository]

12
00:01:06,000 --> 00:01:12,000
We import DuplicateFilingError for handling duplicate filings during ingestion.
[Types: from financial_rag.utils.exceptions import DuplicateFilingError]

13
00:01:12,000 --> 00:01:18,000
Now let's check if TYPE_CHECKING is true so we can import types conditionally.
[Types: if TYPE_CHECKING:]

14
00:01:18,000 --> 00:01:24,000
We import uuid for UUID generation when TYPE_CHECKING is true.
[Types: import uuid]

15
00:01:24,000 --> 00:01:30,000
We import FilingMetadata from the sec_ingestor module for type hints.
[Types: from financial_rag.ingestion.sec_ingestor import FilingMetadata]

16
00:01:30,000 --> 00:01:36,000
We import FinancialChunk from the chunks repository for type hints.
[Types: from financial_rag.storage.repositories.chunks import FinancialChunk]

17
00:01:36,000 --> 00:01:42,000
Now let's set up the logger for the vector store.
[Types: logger = logging.getLogger(__name__)]

18
00:01:42,000 --> 00:01:48,000
This creates a logger that will show the module name in log messages.

19
00:01:48,000 --> 00:01:54,000
Now let's define the VectorStore class.
[Types: class VectorStore:]

20
00:01:54,000 --> 00:02:00,000
We define the init method. This initializes the vector store.
[Types: def __init__(self) -> None:]

21
00:02:00,000 --> 00:02:06,000
We create an instance of the EmbeddingClient.
[Types: self._embedding_client = EmbeddingClient()]

22
00:02:06,000 --> 00:02:12,000
We log the initialization with the provider name and dimensions.
[Types: logger.info("VectorStore initialised — provider=%s dims=%d", self._embedding_client.provider_name, self._embedding_client.dimensions)]

23
00:02:12,000 --> 00:02:18,000
This confirms the embedding client is ready to use.

24
00:02:18,000 --> 00:02:24,000
Now let's implement the ingest method. This is the full ingestion pipeline.
[Types: async def ingest(self, chunks: list[FinancialChunk], meta: FilingMetadata, file_hash: str,) -> tuple[uuid.UUID, int]:]

25
00:02:24,000 --> 00:02:30,000
The method takes a list of chunks, filing metadata, and a file hash.
It returns a tuple of filing_id and the number of chunks stored.

26
00:02:30,000 --> 00:02:36,000
We import DuplicateFilingError at the top of the method.
[Types: from financial_rag.utils.exceptions import DuplicateFilingError]

27
00:02:36,000 --> 00:02:42,000
We get the database client.
[Types: db = await get_db_client()]

28
00:02:42,000 --> 00:02:48,000
Now we check for duplicates using a session.
[Types: async with db.session() as session:]

29
00:02:48,000 --> 00:02:54,000
We create an instance of FilingsRepository.
[Types: filings_repo = FilingsRepository(session)]

30
00:02:54,000 --> 00:03:00,000
We check if the file_hash already exists in the database.
[Types: if await filings_repo.exists_by_hash(file_hash):]

31
00:03:00,000 --> 00:03:06,000
If the hash exists, we raise DuplicateFilingError.
[Types: raise DuplicateFilingError(ticker=meta.ticker, file_hash=file_hash)]

32
00:03:06,000 --> 00:03:12,000
This prevents duplicate filings from being ingested.

33
00:03:12,000 --> 00:03:18,000
We log the start of ingestion with the filing details.
[Types: logger.info("Ingesting %s %s FY%s — %d chunks", meta.ticker, meta.filing_type, meta.fiscal_year, len(chunks))]

34
00:03:18,000 --> 00:03:24,000
This helps track ingestion progress in the logs.

35
00:03:24,000 --> 00:03:30,000
Now we embed all the chunks using the embedding client.
[Types: chunks_with_embeddings = await self._embedding_client.embed_chunks(chunks)]

36
00:03:30,000 --> 00:03:36,000
This populates the embedding field on each chunk with the vector.

37
00:03:36,000 --> 00:03:42,000
Now we register the filing in the database.
[Types: import uuid as uuid_module]

38
00:03:42,000 --> 00:03:48,000
We generate a new UUID for the filing.
[Types: filing_id = uuid_module.uuid4()]

39
00:03:48,000 --> 00:03:54,000
We open a new database session.
[Types: async with db.session() as session:]

40
00:03:54,000 --> 00:04:00,000
We create an instance of FilingsRepository.
[Types: filings_repo = FilingsRepository(session)]

41
00:04:00,000 --> 00:04:06,000
We create a Filing ORM object with the metadata.
[Types: filing = Filing(id=filing_id, ticker=meta.ticker, filing_type=meta.filing_type, fiscal_year=meta.fiscal_year, fiscal_quarter=meta.fiscal_quarter, filed_at=meta.filed_at, source_url=meta.source_url, file_hash=file_hash, ingested_by="VectorStore", is_active=True,)]

42
00:04:06,000 --> 00:04:12,000
We add the filing to the database.
[Types: await filings_repo.add(filing)]

43
00:04:12,000 --> 00:04:18,000
Now we set the filing_id on all chunks.
[Types: for chunk in chunks_with_embeddings: chunk.filing_id = filing_id]

44
00:04:18,000 --> 00:04:24,000
This links the chunks to the filing in the database.

45
00:04:24,000 --> 00:04:30,000
We open a new session for storing chunks.
[Types: async with db.session() as session:]

46
00:04:30,000 --> 00:04:36,000
We create an instance of ChunksRepository.
[Types: chunks_repo = ChunksRepository(session)]

47
00:04:36,000 --> 00:04:42,000
We bulk upsert the chunks into the database.
[Types: stored = await chunks_repo.bulk_upsert(chunks_with_embeddings)]

48
00:04:42,000 --> 00:04:48,000
We log the completion of ingestion.
[Types: logger.info("Ingestion complete — %s %s FY%s: filing_id=%s chunks=%d", meta.ticker, meta.filing_type, meta.fiscal_year, str(filing_id)[:8], stored)]

49
00:04:48,000 --> 00:04:54,000
We return the filing_id and the number of chunks stored.
[Types: return filing_id, stored]

50
00:04:54,000 --> 00:05:00,000
Now let's implement the search method. This retrieves relevant chunks for a query.
[Types: async def search(self, query: str, *, ticker: str | None = None, filing_type: str | None = None, fiscal_year: int | None = None, section: str | None = None, limit: int = 5, search_type: str = "similarity", ef_search: int = 100,) -> list[tuple[FinancialChunk, float]]:]

51
00:05:00,000 --> 00:05:06,000
The method takes a query string and optional filters. It returns a list of
chunks with their similarity scores.

52
00:05:06,000 --> 00:05:12,000
We generate the query embedding using the embedding client.
[Types: query_embedding = await self._embedding_client.embed_query(query)]

53
00:05:12,000 --> 00:05:18,000
This converts the query string to a vector.

54
00:05:18,000 --> 00:05:24,000
We get the database client.
[Types: db = await get_db_client()]

55
00:05:24,000 --> 00:05:30,000
We open a database session.
[Types: async with db.session() as session:]

56
00:05:30,000 --> 00:05:36,000
We create an instance of ChunksRepository.
[Types: repo = ChunksRepository(session)]

57
00:05:36,000 --> 00:05:42,000
If search_type is "mmr", we use MMR search.
[Types: if search_type == "mmr": return await repo.mmr_search(query_embedding, ticker=ticker, filing_type=filing_type, fiscal_year=fiscal_year, limit=limit)]

58
00:05:42,000 --> 00:05:48,000
MMR balances relevance and diversity in the results.

59
00:05:48,000 --> 00:05:54,000
Otherwise, we use similarity search.
[Types: return await repo.similarity_search(query_embedding, ticker=ticker, filing_type=filing_type, fiscal_year=fiscal_year, section=section, limit=limit, ef_search=ef_search)]

60
00:05:54,000 --> 00:06:00,000
Similarity search returns the most relevant chunks.

61
00:06:00,000 --> 00:06:06,000
Now let's implement the stats method. This returns storage statistics.
[Types: async def stats(self, ticker: str | None = None) -> dict[str, object]:]

62
00:06:06,000 --> 00:06:12,000
We get the database client.
[Types: db = await get_db_client()]

63
00:06:12,000 --> 00:06:18,000
We open a database session.
[Types: async with db.session() as session:]

64
00:06:18,000 --> 00:06:24,000
We create instances of both repositories.
[Types: chunks_repo = ChunksRepository(session) filings_repo = FilingsRepository(session)]

65
00:06:24,000 --> 00:06:30,000
If ticker is provided, we get counts for that ticker.
[Types: if ticker: chunk_count = await chunks_repo.count_by_ticker(ticker) filing_count = len(await filings_repo.get_by_ticker(ticker))]

66
00:06:30,000 --> 00:06:36,000
Otherwise, we get global counts.
[Types: else: chunk_count = await chunks_repo.count() filing_count = await filings_repo.count()]

67
00:06:36,000 --> 00:06:42,000
We return a dictionary with the statistics.
[Types: return {"ticker": ticker or "all", "total_chunks": chunk_count, "total_filings": filing_count, "provider": self._embedding_client.provider_name, "dimensions": self._embedding_client.dimensions}]

68
00:06:42,000 --> 00:06:48,000
These stats are used for monitoring and observability.

69
00:06:48,000 --> 00:06:54,000
Now let's update the storage __init__.py file.
Open `src/financial_rag/storage/__init__.py`.

70
00:06:54,000 --> 00:07:00,000
We import VectorStore from the vector_store module.
[Types: from .vector_store import VectorStore]

71
00:07:00,000 --> 00:07:06,000
We add VectorStore to __all__.
[Types: __all__ = ["VectorStore", ...]]

72
00:07:06,000 --> 00:07:12,000
Now let me explain the complete flow of the vector store.

73
00:07:12,000 --> 00:07:18,000
First, you call ingest with chunks and filing metadata. The vector store
checks for duplicates, embeds the chunks, registers the filing, and stores the chunks.

74
00:07:18,000 --> 00:07:24,000
Then, you call search with a query. The vector store embeds the query,
searches the database, and returns the relevant chunks with scores.

75
00:07:24,000 --> 00:07:30,000
Finally, you call stats to get monitoring information.

76
00:07:30,000 --> 00:07:36,000
This is the complete vector store. It orchestrates the entire pipeline
from ingestion to retrieval.

77
00:07:36,000 --> 00:07:42,000
Let's test the vector store. We'll use an IPython session.

78
00:07:42,000 --> 00:07:48,000
[Types: from financial_rag.storage.vector_store import VectorStore]
[Types: from financial_rag.ingestion.sec_ingestor import SECIngestor]
[Types: from financial_rag.ingestion.parsers.html_parser import HTMLParser]
[Types: from financial_rag.processing.text_processor import TextProcessor]

79
00:07:48,000 --> 00:07:54,000
We import all the components we need for the full pipeline.

80
00:07:54,000 --> 00:08:00,000
[Types: async with SECIngestor() as ingestor:]
[Types: filings = await ingestor.list_filings("AAPL", "10-K", years=1)]
[Types: content, file_hash = await ingestor.download_filing(filings[0])]

81
00:08:00,000 --> 00:08:06,000
We download a filing from EDGAR.

82
00:08:06,000 --> 00:08:12,000
[Types: parser = HTMLParser()]
[Types: parsed = parser.parse(content, ticker="AAPL", filing_type="10-K", fiscal_year=filings[0].fiscal_year)]

83
00:08:12,000 --> 00:08:18,000
We parse the HTML into a ParsedFiling.

84
00:08:18,000 --> 00:08:24,000
[Types: processor = TextProcessor()]
[Types: filing_id = uuid.uuid4()]
[Types: chunks = processor.process(parsed, filings[0], filing_id)]

85
00:08:24,000 --> 00:08:30,000
We process the parsed filing into chunks.

86
00:08:30,000 --> 00:08:36,000
[Types: store = VectorStore()]
[Types: stored_id, count = await store.ingest(chunks, filings[0], file_hash)]

87
00:08:36,000 --> 00:08:42,000
We ingest the chunks into the vector store.

88
00:08:42,000 --> 00:08:48,000
[Types: results = await store.search("What was Apple's revenue in 2024?", ticker="AAPL", limit=3)]

89
00:08:48,000 --> 00:08:54,000
We search for relevant chunks.

90
00:08:54,000 --> 00:09:00,000
[Types: for chunk, score in results: print(f"Score: {score:.3f}") print(chunk.chunk_text[:200])]

91
00:09:00,000 --> 00:09:06,000
We print the scores and the first 200 characters of each chunk.

92
00:09:06,000 --> 00:09:12,000
Now let me recap what we've built in Part 5.

93
00:09:12,000 --> 00:09:18,000
We built the VectorStore class. It orchestrates the full pipeline from
chunks to embeddings to database storage.

94
00:09:18,000 --> 00:09:24,000
The ingest method checks for duplicates, embeds chunks, registers the filing,
and stores the chunks in the database.

95
00:09:24,000 --> 00:09:30,000
The search method embeds a query and retrieves relevant chunks using either
similarity or MMR search.

96
00:09:30,000 --> 00:09:36,000
The stats method returns monitoring information about the vector store.

97
00:09:36,000 --> 00:09:42,000
This is the heart of our RAG system. Everything else builds on this.

98
00:09:42,000 --> 00:09:48,000
In Part 6, we'll build the hybrid search. This combines vector search with
full-text search for better retrieval.

99
00:09:48,000 --> 00:09:54,000
Thank you for watching. I'll see you in Part 6.

100
00:09:54,000 --> 00:09:58,000
[End of Part 5]
1
00:00:00,000 --> 00:00:06,000
Welcome back to Phase 3. In Part 6, we build the hybrid search system.

2
00:00:06,000 --> 00:00:12,000
Vector search is powerful. But it's not perfect. Sometimes the semantic meaning
of a query doesn't match the exact keywords in the document.

3
00:00:12,000 --> 00:00:18,000
Think about it this way. Vector search finds similar meaning. Keyword search
finds exact matches. Sometimes you need both.

4
00:00:18,000 --> 00:00:24,000
When a user searches for "AAPL revenue 2024", vector search might find
documents about Apple's revenue. But keyword search finds documents that
contain "AAPL", "revenue", and "2024" in the same chunk.

5
00:00:24,000 --> 00:00:30,000
Hybrid search combines both. It gives you the best of both worlds. And it uses
a technique called Reciprocal Rank Fusion to combine the results.

6
00:00:30,000 --> 00:00:36,000
Open your editor and create `src/financial_rag/retrieval/hybrid_search.py`.

7
00:00:36,000 --> 00:00:42,000
We'll start with the imports. The __future__ import enables forward references.
[Types: from __future__ import annotations]

8
00:00:42,000 --> 00:00:48,000
We import logging for structured logging throughout the module.
[Types: import logging]

9
00:00:48,000 --> 00:00:54,000
We import TYPE_CHECKING for conditional imports in type hints.
[Types: from typing import TYPE_CHECKING]

10
00:00:54,000 --> 00:01:00,000
We import text from sqlalchemy for raw SQL execution.
[Types: from sqlalchemy import text]

11
00:01:00,000 --> 00:01:06,000
We import get_settings from our config module for configuration access.
[Types: from financial_rag.config import get_settings]

12
00:01:06,000 --> 00:01:12,000
We import RetrievalResult from document_retriever for the return type.
[Types: from financial_rag.retrieval.document_retriever import RetrievalResult]

13
00:01:12,000 --> 00:01:18,000
We import EmbeddingClient for embedding the query.
[Types: from financial_rag.retrieval.embeddings import EmbeddingClient]

14
00:01:18,000 --> 00:01:24,000
We import get_db_client for database access.
[Types: from financial_rag.storage.database import get_db_client]

15
00:01:24,000 --> 00:01:30,000
We import ChunksRepository and FinancialChunk from the chunks repository.
[Types: from financial_rag.storage.repositories.chunks import ChunksRepository, FinancialChunk]

16
00:01:30,000 --> 00:01:36,000
We import RetrievalError for error handling.
[Types: from financial_rag.utils.exceptions import RetrievalError]

17
00:01:36,000 --> 00:01:42,000
Now let's define the RRF constant. This is the standard RRF constant from the literature.
[Types: _RRF_K = 60]

18
00:01:42,000 --> 00:01:48,000
RRF stands for Reciprocal Rank Fusion. The constant 60 is recommended in the
original research paper. It prevents scores from being dominated by a single rank.

19
00:01:48,000 --> 00:01:54,000
Now let's define the HybridSearcher class.
[Types: class HybridSearcher:]

20
00:01:54,000 --> 00:02:00,000
We define the init method. This is where we initialize the searcher.
[Types: def __init__(self) -> None:]

21
00:02:00,000 --> 00:02:06,000
We get the settings instance for configuration values.
[Types: self._settings = get_settings()]

22
00:02:06,000 --> 00:02:12,000
We create an EmbeddingClient for embedding the query.
[Types: self._embedding_client = EmbeddingClient()]

23
00:02:12,000 --> 00:02:18,000
Now let's define the search method. This is the public interface.
[Types: async def search(self, question: str, *, ticker: str | None = None, filing_type: str | None = None, fiscal_year: int | None = None, limit: int | None = None, alpha: float | None = None,) -> list[RetrievalResult]:]

24
00:02:18,000 --> 00:02:24,000
This method takes a question and optional filters. It returns a list of results
sorted by relevance.

25
00:02:24,000 --> 00:02:30,000
The alpha parameter controls the balance between vector and text search.
Alpha = 1.0 means pure vector. Alpha = 0.0 means pure text.

26
00:02:30,000 --> 00:02:36,000
We set effective_limit from the limit parameter or the default from settings.
[Types: effective_limit = limit or self._settings.TOP_K_RESULTS]

27
00:02:36,000 --> 00:02:42,000
We set effective_alpha from the alpha parameter or the default from settings.
[Types: effective_alpha = alpha if alpha is not None else self._settings.HYBRID_SEARCH_ALPHA]

28
00:02:42,000 --> 00:02:48,000
We fetch more candidates than needed. Fusion narrows the list.
[Types: fetch_limit = effective_limit * 3]

29
00:02:48,000 --> 00:02:54,000
Now we run both searches concurrently. Vector search and text search.
[Types: vector_task = self._vector_search(question, ticker=ticker, filing_type=filing_type, fiscal_year=fiscal_year, limit=fetch_limit)]

30
00:02:54,000 --> 00:03:00,000
[Types: text_task = self._text_search(question, ticker=ticker, filing_type=filing_type, fiscal_year=fiscal_year, limit=fetch_limit)]

31
00:03:00,000 --> 00:03:06,000
We gather both tasks to run in parallel. This improves performance.
[Types: try: vector_results, text_results = await asyncio.gather(vector_task, text_task)]

32
00:03:06,000 --> 00:03:12,000
We need to import asyncio for concurrent execution.
[Types: import asyncio]

33
00:03:12,000 --> 00:03:18,000
If an error occurs, we raise RetrievalError with context.
[Types: except Exception as exc: raise RetrievalError(f"Hybrid search failed for '{question[:50]}': {exc}") from exc]

34
00:03:18,000 --> 00:03:24,000
Now we fuse the results using RRF.
[Types: fused = self._reciprocal_rank_fusion(vector_results=vector_results, text_results=text_results, alpha=effective_alpha, limit=effective_limit)]

35
00:03:24,000 --> 00:03:30,000
We log the results for debugging and monitoring.
[Types: logger.info("Hybrid search — vector=%d text=%d fused=%d alpha=%.2f", len(vector_results), len(text_results), len(fused), effective_alpha)]

36
00:03:30,000 --> 00:03:36,000
We return the fused results.
[Types: return fused]

37
00:03:36,000 --> 00:03:42,000
Now let's define the vector search method. This embeds the question and runs
similarity search on the vector index.
[Types: async def _vector_search(self, question: str, *, ticker: str | None, filing_type: str | None, fiscal_year: int | None, limit: int,) -> list[tuple[FinancialChunk, float]]:]

38
00:03:42,000 --> 00:03:48,000
First, we embed the question using the EmbeddingClient.
[Types: query_embedding = await self._embedding_client.embed_query(question)]

39
00:03:48,000 --> 00:03:54,000
We get the database client for the query.
[Types: db = await get_db_client()]

40
00:03:54,000 --> 00:04:00,000
We open a session and create a repository.
[Types: async with db.session() as session: repo = ChunksRepository(session)]

41
00:04:00,000 --> 00:04:06,000
We call similarity_search on the repository with the query embedding and filters.
[Types: return await repo.similarity_search(query_embedding, ticker=ticker, filing_type=filing_type, fiscal_year=fiscal_year, limit=limit)]

42
00:04:06,000 --> 00:04:12,000]
This returns a list of (chunk, score) tuples sorted by similarity.

43
00:04:12,000 --> 00:04:18,000
Now let's define the text search method. This uses PostgreSQL's trigram similarity.
[Types: async def _text_search(self, question: str, *, ticker: str | None, filing_type: str | None, fiscal_year: int | None, limit: int,) -> list[tuple[FinancialChunk, float]]:]

44
00:04:18,000 --> 00:04:24,000
We use PostgreSQL's trigram similarity for text search. This is supported by the
pg_trgm extension we created in Phase 1.

45
00:04:24,000 --> 00:04:30,000
We get the database client.
[Types: db = await get_db_client()]

46
00:04:30,000 --> 00:04:36,000
We open a session.
[Types: async with db.session() as session:]

47
00:04:36,000 --> 00:04:42,000
We build the filters list. This is a list of WHERE clauses.
[Types: filters = []]

48
00:04:42,000 --> 00:04:48,000
We create the parameters dictionary for the query.
[Types: params: dict[str, object] = {"query": question, "limit": limit}]

49
00:04:48,000 --> 00:04:54,000
If ticker is provided, we add it to filters and params.
[Types: if ticker: filters.append("ticker = :ticker") params["ticker"] = ticker.upper()]

50
00:04:54,000 --> 00:05:00,000
If filing_type is provided, we add it to filters and params.
[Types: if filing_type: filters.append("filing_type = :filing_type") params["filing_type"] = filing_type]

51
00:05:00,000 --> 00:05:06,000
If fiscal_year is provided, we add it to filters and params.
[Types: if fiscal_year: filters.append("fiscal_year = :fiscal_year") params["fiscal_year"] = fiscal_year]

52
00:05:06,000 --> 00:05:12,000
We build the WHERE clause from the filters.
[Types: where_clause = "WHERE " + " AND ".join(filters) if filters else ""]

53
00:05:12,000 --> 00:05:18,000
We build the SQL query. It selects the id and the similarity score.
[Types: sql = text(f""" SELECT id, similarity(chunk_text, :query) AS trgm_score FROM financial_chunks {where_clause} ORDER BY trgm_score DESC LIMIT :limit """)]

54
00:05:18,000 --> 00:05:24,000
The similarity function is provided by the pg_trgm extension. It compares
the query text to the chunk_text using trigram similarity.

55
00:05:24,000 --> 00:05:30,000
We execute the query with the parameters.
[Types: try: result = await session.execute(sql, params) rows = result.fetchall()]

56
00:05:30,000 --> 00:05:36,000
If an error occurs, we log a warning and return empty. This makes text search
fail gracefully.
[Types: except Exception as exc: logger.warning("Full-text search failed (non-fatal, falling back to vector-only): %s", exc) return []]

57
00:05:36,000 --> 00:05:42,000
If no rows are returned, we return an empty list.
[Types: if not rows: return []]

58
00:05:42,000 --> 00:05:48,000
We extract the chunk IDs and build a score map.
[Types: chunk_ids = [row[0] for row in rows] score_map = {row[0]: float(row[1]) for row in rows}]

59
00:05:48,000 --> 00:05:54,000
We import select from sqlalchemy to fetch the actual chunk objects.
[Types: from sqlalchemy import select]

60
00:05:54,000 --> 00:06:00,000
We fetch the chunks by ID.
[Types: chunks_result = await session.execute(select(FinancialChunk).where(FinancialChunk.id.in_(chunk_ids)))]

61
00:06:00,000 --> 00:06:06,000
We create a dictionary mapping ID to chunk.
[Types: chunks = {c.id: c for c in chunks_result.scalars().all()}]

62
00:06:06,000 --> 00:06:12,000
We return the chunks with their scores in the order of the query results.
[Types: return [(chunks[cid], score_map[cid]) for cid in chunk_ids if cid in chunks]]

63
00:06:12,000 --> 00:06:18,000
Now let's define the RRF fusion method. This combines two ranked lists.
[Types: def _reciprocal_rank_fusion(self, *, vector_results: list[tuple[FinancialChunk, float]], text_results: list[tuple[FinancialChunk, float]], alpha: float, limit: int,) -> list[RetrievalResult]:]

64
00:06:18,000 --> 00:06:24,000
The formula for RRF is: 1 / (k + rank). This gives higher scores to documents
that appear high in both lists.

65
00:06:24,000 --> 00:06:30,000
First, we build rank maps for both result lists. 1-indexed.
[Types: vector_ranks: dict[str, int] = {str(chunk.id): rank + 1 for rank, (chunk, _) in enumerate(vector_results)}]

66
00:06:30,000 --> 00:06:36,000
[Types: text_ranks: dict[str, int] = {str(chunk.id): rank + 1 for rank, (chunk, _) in enumerate(text_results)}]

67
00:06:36,000 --> 00:06:42,000
We get all unique chunk IDs from both lists.
[Types: all_ids: set[str] = set(vector_ranks) | set(text_ranks)]

68
00:06:42,000 --> 00:06:48,000
We build a lookup dictionary from ID to chunk.
[Types: chunk_lookup: dict[str, FinancialChunk] = {} for chunk, _ in vector_results: chunk_lookup[str(chunk.id)] = chunk for chunk, _ in text_results: chunk_lookup[str(chunk.id)] = chunk]

69
00:06:48,000 --> 00:06:54,000
Now we compute the fused RRF scores.
[Types: fused_scores: list[tuple[str, float]] = []]

70
00:06:54,000 --> 00:07:00,000
We iterate over all unique IDs.
[Types: for chunk_id in all_ids:]

71
00:07:00,000 --> 00:07:06,000
If the chunk appears in the vector results, we add its RRF score.
[Types: vector_rrf = 1.0 / (_RRF_K + vector_ranks[chunk_id]) if chunk_id in vector_ranks else 0.0]

72
00:07:06,000 --> 00:07:12,000
If the chunk appears in the text results, we add its RRF score.
[Types: text_rrf = 1.0 / (_RRF_K + text_ranks[chunk_id]) if chunk_id in text_ranks else 0.0]

73
00:07:12,000 --> 00:07:18,000
We combine them using the alpha weight.
[Types: fused_score = alpha * vector_rrf + (1 - alpha) * text_rrf]

74
00:07:18,000 --> 00:07:24,000
We append the ID and score to the list.
[Types: fused_scores.append((chunk_id, fused_score))]

75
00:07:24,000 --> 00:07:30,000
We sort descending by score and take the top limit.
[Types: fused_scores.sort(key=lambda x: x[1], reverse=True) top = fused_scores[:limit]]

76
00:07:30,000 --> 00:07:36,000
We convert the results to RetrievalResult objects.
[Types: return [RetrievalResult.from_chunk(chunk_lookup[cid], score) for cid, score in top if cid in chunk_lookup]]

77
00:07:36,000 --> 00:07:42,000
Now let's update the retrieval __init__.py file.
Open `src/financial_rag/retrieval/__init__.py`.

78
00:07:42,000 --> 00:07:48,000
We import HybridSearcher from the module.
[Types: from .hybrid_search import HybridSearcher]

79
00:07:48,000 --> 00:07:54,000
We add HybridSearcher to __all__.
[Types: __all__ = ["DocumentRetriever", "EmbeddingClient", "HybridSearcher", "QueryEngine", "QueryResult", "RetrievalResult"]]

80
00:07:54,000 --> 00:08:00,000
Now let's test the hybrid search. Open a Python shell and run these commands.

81
00:08:00,000 --> 00:08:06,000
[Types: from financial_rag.retrieval import HybridSearcher]
[Types: searcher = HybridSearcher()]

82
00:08:06,000 --> 00:08:12,000
[Types: import asyncio]
[Types: results = await searcher.search("AAPL revenue 2024", ticker="AAPL")]

83
00:08:12,000 --> 00:08:18,000
This runs a hybrid search for AAPL revenue in 2024. It should return a list
of results with both vector and text matches.

84
00:08:18,000 --> 00:08:24,000
You should see results from both vector search and text search combined by RRF.

85
00:08:24,000 --> 00:08:30,000
Now let me recap what we've built in Part 6.

86
00:08:30,000 --> 00:08:36,000
We built the HybridSearcher class. It combines vector similarity search with
PostgreSQL's trigram text search.

87
00:08:36,000 --> 00:08:42,000
We implemented Reciprocal Rank Fusion. This combines two ranked lists into a
single list using the formula 1 / (k + rank).

88
00:08:42,000 --> 00:08:48,000
We built the vector search method. It embeds the query and runs similarity search
on the vector index.

89
00:08:48,000 --> 00:08:54,000
We built the text search method. It uses PostgreSQL's trigram similarity to find
keyword matches.

90
00:08:54,000 --> 00:09:00,000
We built the RRF fusion method. It combines the two ranked lists using the alpha
parameter to control the balance.

91
00:09:00,000 --> 00:09:06,000
This is the foundation of hybrid search. It gives you the best of both worlds.
Vector search for semantic meaning. Text search for exact keywords.

92
00:09:06,000 --> 00:09:12,000
In Part 7, we'll build the Document Retriever. This adds Redis caching on top
of the search functionality.

93
00:09:12,000 --> 00:09:18,000
Thank you for watching. I'll see you in Part 7.

94
00:09:18,000 --> 00:09:22,000
[End of Part 6]
1
00:00:00,000 --> 00:00:06,000
Welcome back to Phase 3. In Part 7, we build the Document Retriever.

2
00:00:06,000 --> 00:00:12,000
The Document Retriever is the public interface for retrieval. It adds Redis caching
on top of the vector search and hybrid search we've built.

3
00:00:12,000 --> 00:00:18,000
Think about it this way. Vector search is fast. But it's still a database query.
If a user asks the same question twice, we shouldn't hit the database twice.

4
00:00:18,000 --> 00:00:24,000
The Document Retriever caches results in Redis. Repeated queries return instantly.
This dramatically improves performance for common questions.

5
00:00:24,000 --> 00:00:30,000
Open your editor and create `src/financial_rag/retrieval/document_retriever.py`.

6
00:00:30,000 --> 00:00:36,000
We'll start with the imports. The __future__ import enables forward references.
[Types: from __future__ import annotations]

7
00:00:36,000 --> 00:00:42,000
We import hashlib for creating cache keys from query parameters.
[Types: import hashlib]

8
00:00:42,000 --> 00:00:48,000
We import json for serializing query parameters into cache keys.
[Types: import json]

9
00:00:48,000 --> 00:00:54,000
We import logging for structured logging throughout the module.
[Types: import logging]

10
00:00:54,000 --> 00:01:00,000
We import dataclass and field for the RetrievalResult data class.
[Types: from dataclasses import dataclass, field]

11
00:01:00,000 --> 00:01:06,000
We import TYPE_CHECKING for conditional imports in type hints.
[Types: from typing import TYPE_CHECKING]

12
00:01:06,000 --> 00:01:12,000
We import get_settings from our config module for configuration access.
[Types: from financial_rag.config import get_settings]

13
00:01:12,000 --> 00:01:18,000
We import the cache helpers from the storage module.
[Types: from financial_rag.storage.cache import NS_QUERY, build_key, get_cache_client]

14
00:01:18,000 --> 00:01:24,000
We import VectorStore for the vector search.
[Types: from financial_rag.storage.vector_store import VectorStore]

15
00:01:24,000 --> 00:01:30,000
We import RetrievalError for error handling.
[Types: from financial_rag.utils.exceptions import RetrievalError]

16
00:01:30,000 --> 00:01:36,000
Now let's define the RetrievalResult dataclass. This represents a single retrieved chunk.
[Types: @dataclass class RetrievalResult:]

17
00:01:36,000 --> 00:01:42,000
We define the chunk_id field. This is the UUID of the chunk in the database.
[Types: chunk_id: str]

18
00:01:42,000 --> 00:01:48,000
We define the chunk_text field. This is the actual text of the chunk.
[Types: chunk_text: str]

19
00:01:48,000 --> 00:01:54,000
We define the ticker field. This is the company ticker symbol.
[Types: ticker: str]

20
00:01:54,000 --> 00:02:00,000
We define the filing_type field. This is the SEC form type.
[Types: filing_type: str]

21
00:02:00,000 --> 00:02:06,000
We define the fiscal_year field. This is the fiscal year of the filing.
[Types: fiscal_year: int | None]

22
00:02:06,000 --> 00:02:12,000
We define the section field. This is the section of the filing.
[Types: section: str | None]

23
00:02:12,000 --> 00:02:18,000
We define the score field. This is the similarity score from the search.
[Types: score: float]

24
00:02:18,000 --> 00:02:24,000
We define the metrics field. This is a dictionary of extracted financial metrics.
[Types: metrics: dict[str, object] = field(default_factory=dict)]

25
00:02:24,000 --> 00:02:30,000
Now let's define the to_context_string method. This formats the result for the LLM prompt.
[Types: def to_context_string(self) -> str:]

26
00:02:30,000 --> 00:02:36,000
We build a header with the source attribution.
[Types: header = f"[Source: {self.ticker} {self.filing_type} FY{self.fiscal_year} — {self.section or 'General'} (score={self.score:.3f})]"]

27
00:02:36,000 --> 00:02:42,000
We return the header followed by the chunk text.
[Types: return f"{header}\n{self.chunk_text}"]

28
00:02:42,000 --> 00:02:48,000
This format tells the LLM exactly where each piece of information came from.
It's essential for source attribution and grounding.

29
00:02:48,000 --> 00:02:54,000
Now let's define the from_chunk class method. This creates a RetrievalResult from a chunk.
[Types: @classmethod def from_chunk(cls, chunk: FinancialChunk, score: float) -> RetrievalResult:]

30
00:02:54,000 --> 00:03:00,000
We import FinancialChunk from the chunks repository.
[Types: from financial_rag.storage.repositories.chunks import FinancialChunk]

31
00:03:00,000 --> 00:03:06,000
We build the result from the chunk fields.
[Types: return cls(chunk_id=str(chunk.id), chunk_text=chunk.chunk_text, ticker=chunk.ticker, filing_type=chunk.filing_type, fiscal_year=chunk.fiscal_year, section=chunk.section, score=score, metrics=chunk.metrics or {})]

32
00:03:06,000 --> 00:03:12,000
Now let's define the DocumentRetriever class.
[Types: class DocumentRetriever:]

33
00:03:12,000 --> 00:03:18,000
We define the init method. This is where we initialize the retriever.
[Types: def __init__(self, vector_store: VectorStore | None = None) -> None:]

34
00:03:18,000 --> 00:03:24,000
We get the settings instance for configuration values.
[Types: self._settings = get_settings()]

35
00:03:24,000 --> 00:03:30,000
We set the vector store, either from the parameter or a new instance.
[Types: self._vector_store = vector_store or VectorStore()]

36
00:03:30,000 --> 00:03:36,000
Now let's define the retrieve method. This is the public interface.
[Types: async def retrieve(self, question: str, *, ticker: str | None = None, filing_type: str | None = None, fiscal_year: int | None = None, section: str | None = None, limit: int | None = None, search_type: str = "similarity", use_cache: bool = True, score_threshold: float | None = None,) -> list[RetrievalResult]:]

37
00:03:36,000 --> 00:03:42,000
This method retrieves the most relevant chunks for a question. It checks the cache
first, then falls back to vector search.

38
00:03:42,000 --> 00:03:48,000
We set effective_limit from the limit parameter or the default from settings.
[Types: effective_limit = limit or self._settings.TOP_K_RESULTS]

39
00:03:48,000 --> 00:03:54,000
We set effective_threshold from the score_threshold parameter or the default.
[Types: effective_threshold = score_threshold if score_threshold is not None else self._settings.VECTOR_SEARCH_THRESHOLD]

40
00:03:54,000 --> 00:04:00,000
Now we check the cache if use_cache is True and we're not in mock mode.
[Types: cache_key = None if use_cache and not self._settings.MOCK_EXTERNAL_APIS:]

41
00:04:00,000 --> 00:04:06,000
We build the cache key from the query parameters.
[Types: cache_key = self._build_cache_key(question, ticker, filing_type, fiscal_year, section, effective_limit, search_type)]

42
00:04:06,000 --> 00:04:12,000
We try to get cached results.
[Types: cached = await self._get_cached(cache_key) if cached is not None: logger.debug("Cache hit for query hash=%s", cache_key[-8:]) return cached]

43
00:04:12,000 --> 00:04:18,000
If the cache misses, we perform the vector search.
[Types: try: raw_results = await self._vector_store.search(question, ticker=ticker, filing_type=filing_type, fiscal_year=fiscal_year, section=section, limit=effective_limit, search_type=search_type)]

44
00:04:18,000 --> 00:04:24,000
If an error occurs, we raise RetrievalError with context.
[Types: except Exception as exc: raise RetrievalError(f"Vector search failed for question='{question[:50]}...': {exc}") from exc]

45
00:04:24,000 --> 00:04:30,000
We filter the results by the score threshold.
[Types: results = [RetrievalResult.from_chunk(chunk, score) for chunk, score in raw_results if score >= effective_threshold]]

46
00:04:30,000 --> 00:04:36,000
We log the number of results found.
[Types: logger.info("Retrieved %d/%d results above threshold=%.2f for '%s...'", len(results), len(raw_results), effective_threshold, question[:50])]

47
00:04:36,000 --> 00:04:42,000
We cache the results if caching is enabled and we have results.
[Types: if use_cache and cache_key and results: await self._set_cached(cache_key, results)]

48
00:04:42,000 --> 00:04:48,000
We return the results.
[Types: return results]

49
00:04:48,000 --> 00:04:54,000
Now let's define the build_context method. This assembles chunks into a context string.
[Types: def build_context(self, results: list[RetrievalResult], *, max_tokens: int | None = None,) -> str:]

50
00:04:54,000 --> 00:05:00,000
This method is used by the query engine to build the prompt context.
It respects the token budget.

51
00:05:00,000 --> 00:05:06,000
We import tiktoken for token counting.
[Types: import tiktoken]

52
00:05:06,000 --> 00:05:12,000
We set the token budget from the parameter or the default.
[Types: budget = max_tokens or self._settings.MAX_CONTEXT_TOKENS]

53
00:05:12,000 --> 00:05:18,000
We get the encoding for the tokenizer.
[Types: enc = tiktoken.get_encoding("cl100k_base")]

54
00:05:18,000 --> 00:05:24,000
We initialize the context parts list and token counter.
[Types: context_parts: list[str] = [] tokens_used = 0]

55
00:05:24,000 --> 00:05:30,000
We iterate over each result.
[Types: for result in results:]

56
00:05:30,000 --> 00:05:36,000
We get the context block by calling to_context_string.
[Types: block = result.to_context_string()]

57
00:05:36,000 --> 00:05:42,000
We count the tokens in the block.
[Types: block_tokens = len(enc.encode(block))]

58
00:05:42,000 --> 00:05:48,000
If adding this block would exceed the budget, we break.
[Types: if tokens_used + block_tokens > budget: logger.debug("Context budget reached at %d/%d tokens after %d chunks", tokens_used, budget, len(context_parts)) break]

59
00:05:48,000 --> 00:05:54,000
We add the block to the context parts and update the token count.
[Types: context_parts.append(block) tokens_used += block_tokens]

60
00:05:54,000 --> 00:06:00,000
We join the parts with separators and return the context.
[Types: return "\n\n---\n\n".join(context_parts)]

61
00:06:00,000 --> 00:06:06,000
Now let's define the cache helper methods. These handle Redis caching.

62
00:06:06,000 --> 00:06:12,000
We define _build_cache_key. This creates a deterministic cache key from query parameters.
[Types: def _build_cache_key(self, question: str, ticker: str | None, filing_type: str | None, fiscal_year: int | None, section: str | None, limit: int, search_type: str) -> str:]

63
00:06:12,000 --> 00:06:18,000
We create a payload dictionary with all the query parameters.
[Types: payload = json.dumps({"q": question, "t": ticker, "ft": filing_type, "fy": fiscal_year, "s": section, "l": limit, "st": search_type}, sort_keys=True)]

64
00:06:18,000 --> 00:06:24,000
We create a SHA-256 hash of the payload.
[Types: digest = hashlib.sha256(payload.encode()).hexdigest()]

65
00:06:24,000 --> 00:06:30,000
We build the cache key with the query namespace and the hash.
[Types: return build_key(NS_QUERY, digest)]

66
00:06:30,000 --> 00:06:36,000
Now we define _get_cached. This retrieves cached results from Redis.
[Types: async def _get_cached(self, cache_key: str) -> list[RetrievalResult] | None:]

67
00:06:36,000 --> 00:06:42,000
We try to get the client and retrieve the data.
[Types: try: client = await get_cache_client() data = await client.get(cache_key) if data is None: return None]

68
00:06:42,000 --> 00:06:48,000
We convert the data back to RetrievalResult objects.
[Types: return [RetrievalResult(**item) for item in data]]

69
00:06:48,000 --> 00:06:54,000
If an error occurs, we log a warning and return None. Cache failures are non-fatal.
[Types: except Exception as exc: logger.warning("Cache GET failed (non-fatal): %s", exc) return None]

70
00:06:54,000 --> 00:07:00,000
Now we define _set_cached. This stores results in Redis.
[Types: async def _set_cached(self, cache_key: str, results: list[RetrievalResult]) -> None:]

71
00:07:00,000 --> 00:07:06,000
We convert the results to serializable dictionaries.
[Types: try: client = await get_cache_client() serialisable = [{"chunk_id": r.chunk_id, "chunk_text": r.chunk_text, "ticker": r.ticker, "filing_type": r.filing_type, "fiscal_year": r.fiscal_year, "section": r.section, "score": r.score, "metrics": r.metrics} for r in results]]

72
00:07:06,000 --> 00:07:12,000
We store the data in Redis with the default TTL.
[Types: await client.set(cache_key, serialisable)]

73
00:07:12,000 --> 00:07:18,000
If an error occurs, we log a warning. Cache failures are non-fatal.
[Types: except Exception as exc: logger.warning("Cache SET failed (non-fatal): %s", exc)]

74
00:07:18,000 --> 00:07:24,000
Now let's update the retrieval __init__.py file.
Open `src/financial_rag/retrieval/__init__.py`.

75
00:07:24,000 --> 00:07:30,000
We import DocumentRetriever and RetrievalResult from the module.
[Types: from .document_retriever import DocumentRetriever, RetrievalResult]

76
00:07:30,000 --> 00:07:36,000
We add them to __all__.
[Types: __all__ = ["DocumentRetriever", "EmbeddingClient", "HybridSearcher", "QueryEngine", "QueryResult", "RetrievalResult"]]

77
00:07:36,000 --> 00:07:42,000
Now let's test the document retriever. Open a Python shell.

78
00:07:42,000 --> 00:07:48,000
[Types: from financial_rag.retrieval import DocumentRetriever]
[Types: retriever = DocumentRetriever()]

79
00:07:48,000 --> 00:07:54,000
[Types: import asyncio]
[Types: results = await retriever.retrieve("What is Apple's revenue?", ticker="AAPL")]

80
00:07:54,000 --> 00:08:00,000
This should return a list of RetrievalResult objects. Each result has the
chunk text, metadata, and similarity score.

81
00:08:00,000 --> 00:08:06,000
Now run the same query again. The second time should be faster because it's
cached in Redis.

82
00:08:06,000 --> 00:08:12,000
[Types: results = await retriever.retrieve("What is Apple's revenue?", ticker="AAPL")]

83
00:08:12,000 --> 00:08:18,000
You should see "Cache hit" in the logs. This confirms the caching is working.

84
00:08:18,000 --> 00:08:24,000
Now let's test building a context string.
[Types: context = retriever.build_context(results, max_tokens=2000)]

85
00:08:24,000 --> 00:08:30,000
[Types: print(context[:500])]

86
00:08:30,000 --> 00:08:36,000
You should see the formatted context with source headers and chunk text.
This is what the LLM receives as context.

87
00:08:36,000 --> 00:08:42,000
Now let me recap what we've built in Part 7.

88
00:08:42,000 --> 00:08:48,000
We built the RetrievalResult dataclass. This represents a single retrieved chunk
with all its metadata.

89
00:08:48,000 --> 00:08:54,000
We built the to_context_string method. This formats the result for the LLM prompt
with source attribution.

90
00:08:54,000 --> 00:09:00,000
We built the from_chunk class method. This creates a RetrievalResult from a
database chunk.

91
00:09:00,000 --> 00:09:06,000
We built the DocumentRetriever class. It adds Redis caching on top of vector search.
It checks the cache first, then falls back to search, then caches the results.

92
00:09:06,000 --> 00:09:12,000
We built the build_context method. This assembles chunks into a context string
while respecting the token budget.

93
00:09:12,000 --> 00:09:18,000
We built the cache helper methods. _build_cache_key creates deterministic keys.
_get_cached retrieves from Redis. _set_cached stores in Redis.

94
00:09:18,000 --> 00:09:24,000
This completes the retrieval layer. We have vector search, hybrid search, and
cached document retrieval. All working together.

95
00:09:24,000 --> 00:09:30,000
In Phase 4, we'll build the Query Engine. This orchestrates the full RAG pipeline.

96
00:09:30,000 --> 00:09:36,000
Thank you for watching. I'll see you in Phase 4.

97
00:09:36,000 --> 00:09:40,000
[End of Part 7]
1
00:00:00,000 --> 00:00:06,000
Welcome back to Phase 3. In Part 8, we build the processing tests.

2
00:00:06,000 --> 00:00:12,000
We've built the TextProcessor for chunking documents. We've built the EmbeddingClient for generating embeddings. We've built the ChunksRepository for storing chunks. We've built the VectorStore for orchestrating ingestion.

3
00:00:12,000 --> 00:00:18,000
Now we need to verify everything works together. This is where we catch bugs before they reach production.

4
00:00:18,000 --> 00:00:24,000
Open your editor and create `tests/integration/test_phase3_processing.py`.

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
We import uuid for generating unique identifiers in tests.
[Types: import uuid]

8
00:00:42,000 --> 00:00:48,000
We import pytest as our testing framework.
[Types: import pytest]

9
00:00:48,000 --> 00:00:54,000
We import patch from unittest.mock for mocking external dependencies.
[Types: from unittest.mock import patch]

10
00:00:54,000 --> 00:01:00,000
We import get_settings from our config module for test configuration.
[Types: from financial_rag.config import get_settings]

11
00:01:00,000 --> 00:01:06,000
We import ParsedSection from the HTML parser for building test fixtures.
[Types: from financial_rag.ingestion.parsers.html_parser import ParsedSection]

12
00:01:06,000 --> 00:01:12,000
We import FilingMetadata from the SEC ingestor for building test fixtures.
[Types: from financial_rag.ingestion.sec_ingestor import FilingMetadata]

13
00:01:12,000 --> 00:01:18,000
We import TextProcessor from the processing module for testing chunking.
[Types: from financial_rag.processing.text_processor import TextProcessor]

14
00:01:18,000 --> 00:01:24,000
We import ChunkingError from exceptions for error testing.
[Types: from financial_rag.utils.exceptions import ChunkingError]

15
00:01:24,000 --> 00:01:30,000
Now let's define the valid test secrets. These are environment variables that must be set for tests to run.
[Types: VALID_SECRETS = { "POSTGRES_PASSWORD": "test-pg-password-32-chars-minimum", "REDIS_PASSWORD": "test-redis-password-32-chars-min", "APP_ENV": "testing", }]

16
00:01:30,000 --> 00:01:36,000
We set POSTGRES_PASSWORD to a test value. In production, this would be a secure password. For testing, we use a placeholder.

17
00:01:36,000 --> 00:01:42,000
We do the same for REDIS_PASSWORD. We set APP_ENV to "testing" which enables testing mode in the application.

18
00:01:42,000 --> 00:01:48,000
Now let's define the settings cache fixture. This clears the cache before and after each test to prevent state bleeding.
[Types: @pytest.fixture(autouse=True) def clear_settings_cache(): get_settings.cache_clear() yield get_settings.cache_clear()]

19
00:01:48,000 --> 00:01:54,000
The fixture runs automatically for every test. It clears the cache before the test and again after the test completes.

20
00:01:54,000 --> 00:02:00,000
Now let's define the helper function for creating mock filing metadata. This is used across multiple tests.
[Types: def make_mock_filing_meta(ticker: str = "AAPL") -> FilingMetadata:]

21
00:02:00,000 --> 00:02:06,000
We import date from datetime for the filed_at field.
[Types: from datetime import date]

22
00:02:06,000 --> 00:02:12,000
We create a FilingMetadata object with realistic test data.
[Types: return FilingMetadata( ticker=ticker, filing_type="10-K", fiscal_year=2023, fiscal_quarter=None, filed_at=date(2023, 11, 3), accession_number="0000320193-23-000106", primary_document="aapl-20230930.htm", source_url="https://example.com/aapl.htm", cik="0000320193", )]

23
00:02:12,000 --> 00:02:18,000
This returns a FilingMetadata instance with realistic test values.

24
00:02:18,000 --> 00:02:24,000
Now let's define the helper function for creating mock parsed filings. This is used for chunking tests.
[Types: def make_parsed_filing(ticker: str = "AAPL", num_sections: int = 2):]

25
00:02:24,000 --> 00:02:30,000
We import ParsedFiling from the HTML parser.
[Types: from financial_rag.ingestion.parsers.html_parser import ParsedFiling]

26
00:02:30,000 --> 00:02:36,000
We create a long text string that will be split into chunks.
[Types: text = "Apple revenue grew significantly. " * 100]

27
00:02:36,000 --> 00:02:42,000
We create the specified number of sections with the same text.
[Types: sections = [ParsedSection(name=f"Section {i}", text=text) for i in range(num_sections)]

28
00:02:42,000 --> 00:02:48,000
We return a ParsedFiling with the sections.
[Types: return ParsedFiling( ticker=ticker, filing_type="10-K", fiscal_year=2023, full_text=text * num_sections, sections=sections, )]

29
00:02:48,000 --> 00:02:54,000
This creates a test filing with realistic data for chunking tests.

30
00:02:54,000 --> 00:03:00,000
Now let's define the test class for the TextProcessor.
[Types: class TestTextProcessor:]

31
00:03:00,000 --> 00:03:06,000
We define the setup method. This runs before each test.
[Types: def setup_method(self): self.processor = TextProcessor()]

32
00:03:06,000 --> 00:03:12,000
This creates a fresh TextProcessor instance for each test.

33
00:03:12,000 --> 00:03:18,000
We test that the token count is exact. The count_tokens method uses tiktoken for accurate counting.
[Types: def test_count_tokens_is_exact(self): text = "Apple revenue grew 12% to $394 billion" count = self.processor.count_tokens(text) assert count > 0 assert isinstance(count, int)]

34
00:03:18,000 --> 00:03:24,000
Tiktoken is the same tokenizer used by OpenAI. It gives us accurate token counts.

35
00:03:24,000 --> 00:03:30,000
We test that processing returns chunks. The process method should return a list of FinancialChunk objects.
[Types: def test_process_returns_chunks(self): parsed = make_parsed_filing() meta = make_mock_filing_meta() filing_id = uuid.uuid4() chunks = self.processor.process(parsed, meta, filing_id) assert len(chunks) > 0]

36
00:03:30,000 --> 00:03:36,000
This verifies the chunking pipeline produces at least one chunk.

37
00:03:36,000 --> 00:03:42,000
We test that chunks have the correct ticker. All chunks should have the ticker from the metadata.
[Types: def test_chunks_have_correct_ticker(self): parsed = make_parsed_filing("MSFT") meta = make_mock_filing_meta("MSFT") filing_id = uuid.uuid4() chunks = self.processor.process(parsed, meta, filing_id) assert all(c.ticker == "MSFT" for c in chunks)]

38
00:03:42,000 --> 00:03:48,000
This verifies the ticker is propagated correctly to all chunks.

39
00:03:48,000 --> 00:03:54,000
We test that chunks have sequential indices. The chunk_index field should increment from 0.
[Types: def test_chunks_have_sequential_indices(self): parsed = make_parsed_filing() meta = make_mock_filing_meta() filing_id = uuid.uuid4() chunks = self.processor.process(parsed, meta, filing_id) indices = [c.chunk_index for c in chunks] assert indices == list(range(len(chunks)))]

40
00:03:54,000 --> 00:04:00,000
This verifies the chunk indexing is correct and sequential.

41
00:04:00,000 --> 00:04:06,000
We test that chunks have an empty embedding list initially. Embeddings are added later by the EmbeddingClient.
[Types: def test_chunks_embedding_is_empty_list(self): parsed = make_parsed_filing() meta = make_mock_filing_meta() chunks = self.processor.process(parsed, meta, uuid.uuid4()) assert all(c.embedding == [] for c in chunks)]

42
00:04:06,000 --> 00:04:12,000
This verifies the embedding field is empty when chunks are first created.

43
00:04:12,000 --> 00:04:18,000
We test that empty sections raise a ChunkingError. The processor should raise an error when there are no sections to chunk.
[Types: def test_empty_sections_raises_chunking_error(self): from financial_rag.ingestion.parsers.html_parser import ParsedFiling parsed = ParsedFiling( ticker="TEST", filing_type="10-K", fiscal_year=2023, full_text="", sections=[], ) with pytest.raises(ChunkingError): self.processor.process(parsed, make_mock_filing_meta(), uuid.uuid4())]

44
00:04:18,000 --> 00:04:24,000
This verifies the processor handles empty documents gracefully by raising a clear error.

45
00:04:24,000 --> 00:04:30,000
We test that estimate_cost returns the expected keys. This is used for tracking LLM costs.
[Types: def test_estimate_cost_returns_expected_keys(self): parsed = make_parsed_filing() meta = make_mock_filing_meta() chunks = self.processor.process(parsed, meta, uuid.uuid4()) estimate = self.processor.estimate_cost(chunks) assert "chunk_count" in estimate assert "total_tokens" in estimate assert "estimated_cost_usd" in estimate assert estimate["chunk_count"] == len(chunks)]

46
00:04:30,000 --> 00:04:36,000
This verifies the cost estimation returns the correct keys and values.

47
00:04:36,000 --> 00:04:42,000
We test that the chunk size is respected. Each chunk should not exceed the configured chunk size.
[Types: def test_chunk_size_respected(self): settings = get_settings() parsed = make_parsed_filing() meta = make_mock_filing_meta() chunks = self.processor.process(parsed, meta, uuid.uuid4()) for chunk in chunks: assert (chunk.token_count or 0) <= settings.CHUNK_SIZE_TOKENS]

48
00:04:42,000 --> 00:04:48,000
This verifies the chunking algorithm respects the configured chunk size limit.

49
00:04:48,000 --> 00:04:54,000
Now let's define the test class for the EmbeddingClient.
[Types: class TestEmbeddingClient:]

50
00:04:54,000 --> 00:05:00,000
We test that embed_query returns a vector. This is the most basic embedding operation.
[Types: @pytest.mark.integration async def test_embed_query_returns_vector(self): from financial_rag.retrieval.embeddings import EmbeddingClient client = EmbeddingClient() vector = await client.embed_query("What was Apple's revenue?") assert isinstance(vector, list) assert len(vector) > 0 assert all(isinstance(v, float) for v in vector)]

51
00:05:00,000 --> 00:05:06,000
This verifies the EmbeddingClient can embed a single query and returns a list of floats.

52
00:05:06,000 --> 00:05:12,000
We test that embed_texts returns the correct number of vectors. Each input text should produce one output vector.
[Types: @pytest.mark.integration async def test_embed_texts_count_matches(self): from financial_rag.retrieval.embeddings import EmbeddingClient client = EmbeddingClient() texts = ["Revenue grew 12%", "Net income declined", "EPS was $3.14"] vectors = await client.embed_texts(texts) assert len(vectors) == len(texts)]

53
00:05:12,000 --> 00:05:18,000
This verifies the batch embedding works correctly.

54
00:05:18,000 --> 00:05:24,000
We test that the embedding dimensions match the configuration. This is critical for pgvector compatibility.
[Types: @pytest.mark.integration async def test_dimensions_consistent(self): from financial_rag.retrieval.embeddings import EmbeddingClient from financial_rag.config import get_settings client = EmbeddingClient() settings = get_settings() vector = await client.embed_query("test") assert len(vector) == settings.EMBEDDING_DIMENSIONS]

55
00:05:24,000 --> 00:05:30,000
This verifies the embedding dimensions match the configured dimensions for pgvector.

56
00:05:30,000 --> 00:05:36,000
Now let's run the tests. Activate your virtual environment and run pytest.

57
00:05:36,000 --> 00:05:42,000
[Types: source .venv/bin/activate]
[Types: pytest tests/integration/test_phase3_processing.py -v]

58
00:05:42,000 --> 00:05:48,000
The unit tests should pass quickly. The integration tests may take longer because they make real embedding API calls.

59
00:05:48,000 --> 00:05:54,000
If you're running without an API key, the local embedding provider will be used automatically. This is slower but doesn't require an API key.

60
00:05:54,000 --> 00:06:00,000
If a test fails, read the error message carefully. It will tell you exactly what went wrong and where.

61
00:06:00,000 --> 00:06:06,000
Now let me recap what we've built in Part 8.

62
00:06:06,000 --> 00:06:12,000
We built tests for the TextProcessor. We tested token counting, chunking, ticker propagation, sequential indices, empty embedding lists, error handling for empty sections, cost estimation, and chunk size limits.

63
00:06:12,000 --> 00:06:18,000
We built tests for the EmbeddingClient. We tested query embedding, batch embedding, and dimension consistency.

64
00:06:18,000 --> 00:06:24,000
This is the foundation of our processing test suite. Every component is tested. Bugs are caught early. The system is reliable.

65
00:06:24,000 --> 00:06:30,000
Phase 3 is now complete. You have a working processing pipeline with tests.

66
00:06:30,000 --> 00:06:36,000
Let me give you a quick overview of what we've built in Phase 3.

67
00:06:36,000 --> 00:06:42,000
Part 1: Alembic Setup & Migration. We set up database migrations.

68
00:06:42,000 --> 00:06:48,000
Part 2: Text Processor. We built the chunking system for documents.

69
00:06:48,000 --> 00:06:54,000
Part 3: Embedding Client. We built the embedding provider with OpenAI and local support.

70
00:06:54,000 --> 00:07:00,000
Part 4: Chunks Repository. We built the database layer for storing chunks.

71
00:07:00,000 --> 00:07:06,000
Part 5: Vector Store. We built the orchestration layer for the full ingestion pipeline.

72
00:07:06,000 --> 00:07:12,000
Part 6: Hybrid Search. We built the search system combining vector and text search.

73
00:07:12,000 --> 00:07:18,000
Part 7: Document Retriever. We added caching to the search system.

74
00:07:18,000 --> 00:07:24,000
Part 8: Processing Tests. We verified everything works together.

75
00:07:24,000 --> 00:07:30,000
This is a complete processing and retrieval pipeline. You can ingest documents, chunk them, embed them, store them, and search them.

76
00:07:30,000 --> 00:07:36,000
In Phase 4, we'll build the LLM agent that uses this retrieval pipeline to answer questions.

77
00:07:36,000 --> 00:07:42,000
Thank you for watching. I'll see you in Phase 4.

78
00:07:42,000 --> 00:07:46,000
[End of Part 8]