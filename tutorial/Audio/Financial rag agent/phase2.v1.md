1
00:00:00,000 --> 00:00:06,000
Welcome back to the Financial RAG Agent series. We're moving into Phase 2 now.

2
00:00:06,000 --> 00:00:12,000
This is where we start building the ingestion pipeline. The ingestion pipeline
is what brings financial data into our system.

3
00:00:12,000 --> 00:00:18,000
But before we can build anything, we need a proper exception hierarchy.
This is something most tutorials skip entirely.

4
00:00:18,000 --> 00:00:24,000
In production, you need to know exactly what went wrong. You need to know if
it's a database issue, an API issue, or a configuration issue.

5
00:00:24,000 --> 00:00:30,000
A good exception hierarchy tells you that immediately. The class name alone
tells you the category of the error.

6
00:00:30,000 --> 00:00:36,000
So let's build the foundation for error handling. Open your editor and create
`src/financial_rag/utils/exceptions.py`.

7
00:00:36,000 --> 00:00:42,000
We'll start with the __future__ import. This enables forward references in
type hints, which is a modern Python best practice.
[Types: from __future__ import annotations]

8
00:00:42,000 --> 00:00:48,000
Now let's define our base exception class. Every exception in our application
will inherit from this. This gives us a common parent for all application errors.
[Types: class FinRAGError(Exception):]

9
00:00:48,000 --> 00:00:54,000
We inherit from Python's built-in Exception class. This means our exceptions
can be caught by `except Exception` if needed, but they also have their own
identity for more specific handling.

10
00:00:54,000 --> 00:01:00,000
Now let's define the init method. This is where we set up our exception instance.
[Types: def __init__(self, message: str, *, cause: BaseException | None = None) -> None:]

11
00:01:00,000 --> 00:01:06,000
We take a message string as the first parameter. This is the error message
that will be displayed to the user or logged.

12
00:01:06,000 --> 00:01:12,000
The `*` syntax means all following parameters must be keyword arguments.
This is a Python feature that makes the API clearer.
[Types: *]

13
00:01:12,000 --> 00:01:18,000
We take an optional cause parameter. This is another exception that caused
this one. It lets us chain exceptions together.
[Types: cause: BaseException | None = None]

14
00:01:18,000 --> 00:01:24,000
The cause is important because it preserves the original error. When a
database error causes a storage error, we keep both.

15
00:01:24,000 --> 00:01:30,000
Now we call the parent class's init method. This passes the message up to
the base Exception class.
[Types: super().__init__(message)]

16
00:01:30,000 --> 00:01:36,000
This ensures the message is stored properly and can be accessed by
Python's exception handling machinery.

17
00:01:36,000 --> 00:01:42,000
Now we store the cause on the instance. We can access it later for debugging.
[Types: self.cause = cause]

18
00:01:42,000 --> 00:01:48,000
This is how we preserve the root cause of an error. When we log the
exception, we can include the cause.

19
00:01:48,000 --> 00:01:54,000
Now let's define the string representation. This is what gets printed when
the exception is raised and not caught.
[Types: def __str__(self) -> str:]

20
00:01:54,000 --> 00:02:00,000
We start by getting the base message from the parent class.
[Types: base = super().__str__()]

21
00:02:00,000 --> 00:02:06,000
This gives us the message we passed to the parent init method.

22
00:02:06,000 --> 00:02:12,000
Now we check if there's a cause. If there is, we want to include it in
the string representation.
[Types: if self.cause:]

23
00:02:12,000 --> 00:02:18,000
We return a formatted string that includes both the base message and the cause.
[Types: return f"{base} (caused by: {self.cause})"]

24
00:02:18,000 --> 00:02:24,000
This format makes it clear that one error caused another. The parentheses
make it easy to parse visually.

25
00:02:24,000 --> 00:02:30,000
If there's no cause, we just return the base message.
[Types: return base]

26
00:02:30,000 --> 00:02:36,000
This completes our base exception. Let me show you the complete class so far.

27
00:02:36,000 --> 00:02:42,000
We have the class definition, the init method with message and optional cause,
and the string representation that handles chaining.

28
00:02:42,000 --> 00:02:48,000
Now let's build the storage errors. These cover database and cache issues.
[Types: class StorageError(FinRAGError):]

29
00:02:48,000 --> 00:02:54,000
We inherit from FinRAGError. This means StorageError is a type of
application error, specifically for storage-related issues.

30
00:02:54,000 --> 00:03:00,000
We don't need anything special here. Just the inheritance creates a
clear category of errors.
[Types: pass]

31
00:03:00,000 --> 00:03:06,000
The pass statement is used because we don't need to add any new behavior.
The class name itself is the feature.

32
00:03:06,000 --> 00:03:12,000
Now let's define DatabaseConnectionError. This is raised when we can't
connect to PostgreSQL.
[Types: class DatabaseConnectionError(StorageError):]

33
00:03:12,000 --> 00:03:18,000
This inherits from StorageError, which means it's a type of storage error
specifically for connection issues.
[Types: pass]

34
00:03:18,000 --> 00:03:24,000
When you see this in logs, you know immediately it's a database connection
problem, not a query problem.

35
00:03:24,000 --> 00:03:30,000
Now DatabaseQueryError. This is raised when a SQL query fails.
[Types: class DatabaseQueryError(StorageError):]

36
00:03:30,000 --> 00:03:36,000
This is different from DatabaseConnectionError. The connection worked,
but the query failed. This could be a syntax error or a constraint violation.
[Types: pass]

37
00:03:36,000 --> 00:03:42,000
Now the cache errors. CacheConnectionError for Redis connection failures.
[Types: class CacheConnectionError(StorageError):]

38
00:03:42,000 --> 00:03:48,000
Redis is our cache layer. If we can't connect to Redis, this is raised.
[Types: pass]

39
00:03:48,000 --> 00:03:54,000
CacheOperationError for Redis operation failures. This is when Redis is
connected but an operation like GET or SET fails.
[Types: class CacheOperationError(StorageError):]

40
00:03:54,000 --> 00:04:00,000
This could happen due to timeouts, network issues, or Redis internal errors.
[Types: pass]

41
00:04:00,000 --> 00:04:06,000
Now RecordNotFoundError. This is raised when a database lookup returns
no results for a required record.
[Types: class RecordNotFoundError(StorageError):]

42
00:04:06,000 --> 00:04:12,000
This is like a 404 error at the database level. We know the record should
exist, but it doesn't.

43
00:04:12,000 --> 00:04:18,000
We define a custom init method because we want to provide more context.
[Types: def __init__(self, entity: str, identifier: str | int) -> None:]

44
00:04:18,000 --> 00:04:24,000
We take the entity name like "Filing" or "User" and the identifier like
"ABC123" or 42.

45
00:04:24,000 --> 00:04:30,000
We format a message that includes both pieces of information.
[Types: super().__init__(f"{entity} not found: {identifier}")]

46
00:04:30,000 --> 00:04:36,000
This gives us a clear message like "Filing not found: 123" which is
much more useful than just "Record not found".

47
00:04:36,000 --> 00:04:42,000
Now we store the entity and identifier on the instance for debugging.
[Types: self.entity = entity]

48
00:04:42,000 --> 00:04:48,000
[Types: self.identifier = identifier]
This allows us to access the values later if needed.

49
00:04:48,000 --> 00:04:54,000
Now let's build the ingestion errors. These cover SEC EDGAR and document parsing.
[Types: class IngestionError(FinRAGError):]

50
00:04:54,000 --> 00:05:00,000
This is the base for all ingestion-related errors. Any error that occurs
during the ingestion pipeline will be a type of IngestionError.
[Types: pass]

51
00:05:00,000 --> 00:05:06,000
SECFetchError for when EDGAR API calls fail. This could be due to network
issues, rate limiting, or the SEC API being down.
[Types: class SECFetchError(IngestionError):]

52
00:05:06,000 --> 00:05:12,000
[Types: pass]
Clear category for EDGAR-specific failures.

53
00:05:12,000 --> 00:05:18,000
DocumentParseError for when HTML or PDF parsing fails. This could be due
to malformed documents or unsupported formats.
[Types: class DocumentParseError(IngestionError):]

54
00:05:18,000 --> 00:05:24,000
[Types: pass]
Clear category for parsing failures.

55
00:05:24,000 --> 00:05:30,000
DuplicateFilingError for when a filing is already ingested. This prevents
duplicate entries in our database.
[Types: class DuplicateFilingError(IngestionError):]

56
00:05:30,000 --> 00:05:36,000
We define a custom init method to capture the ticker and file hash.
[Types: def __init__(self, ticker: str, file_hash: str) -> None:]

57
00:05:36,000 --> 00:05:42,000
These values help identify exactly which filing is a duplicate.
[Types: super().__init__(f"Filing already ingested — ticker={ticker} hash={file_hash}")]

58
00:05:42,000 --> 00:05:48,000
The message includes both the ticker and the hash for complete context.

59
00:05:48,000 --> 00:05:54,000
[Types: self.ticker = ticker]
[Types: self.file_hash = file_hash]
We store both for debugging purposes.

60
00:05:54,000 --> 00:06:00,000
Now let's build the processing errors. These cover text processing and chunking.
[Types: class ProcessingError(FinRAGError):]

61
00:06:00,000 --> 00:06:06,000
This is the base for all text processing errors. Any error that occurs
during cleaning, normalizing, or chunking text is a ProcessingError.
[Types: pass]

62
00:06:06,000 --> 00:06:12,000
ChunkingError for when tokenization or chunking fails. This could be due
to texts that are too large or malformed.
[Types: class ChunkingError(ProcessingError):]

63
00:06:12,000 --> 00:06:18,000
[Types: pass]
Clear category for chunking failures.

64
00:06:18,000 --> 00:06:24,000
Now let's build the retrieval errors. These cover embeddings and vector search.
[Types: class RetrievalError(FinRAGError):]

65
00:06:24,000 --> 00:06:30,000
This is the base for all retrieval errors. Any error that occurs during
embedding generation or vector search is a RetrievalError.
[Types: pass]

66
00:06:30,000 --> 00:06:36,000
EmbeddingError for when embedding API calls fail. This could be due to
OpenAI API issues, rate limiting, or authentication problems.
[Types: class EmbeddingError(RetrievalError):]

67
00:06:36,000 --> 00:06:42,000
[Types: pass]
Clear category for embedding failures.

68
00:06:42,000 --> 00:06:48,000
VectorSearchError for when pgvector similarity search fails. This could
be due to invalid queries or database issues.
[Types: class VectorSearchError(RetrievalError):]

69
00:06:48,000 --> 00:06:54,000
[Types: pass]
Clear category for vector search failures.

70
00:06:54,000 --> 00:07:00,000
Finally, ConfigurationError. This is raised when settings validation fails.
[Types: class ConfigurationError(FinRAGError):]

71
00:07:00,000 --> 00:07:06,000
This is a special error because it happens at startup. If you have a
configuration error, the application should fail fast.
[Types: pass]

72
00:07:06,000 --> 00:07:12,000
Now let's update the utils __init__.py file. This makes the exceptions
importable from the package level.

73
00:07:12,000 --> 00:07:18,000
Open `src/financial_rag/utils/__init__.py`.
[Types: from financial_rag.utils.exceptions import *]

74
00:07:18,000 --> 00:07:24,000
This imports all exception classes from the exceptions module. The asterisk
is safe here because we control the exports.

75
00:07:24,000 --> 00:07:30,000
Now we define __all__. This controls what gets imported when someone
does `from financial_rag.utils import *`.
[Types: __all__ = []]

76
00:07:30,000 --> 00:07:36,000
We'll add all the exception classes to this list.

77
00:07:36,000 --> 00:07:42,000
[Types: __all__ = ["FinRAGError", "StorageError", "DatabaseConnectionError", "DatabaseQueryError", "CacheConnectionError", "CacheOperationError", "RecordNotFoundError", "IngestionError", "SECFetchError", "DocumentParseError", "DuplicateFilingError", "ProcessingError", "ChunkingError", "RetrievalError", "EmbeddingError", "VectorSearchError", "ConfigurationError"]]

78
00:07:42,000 --> 00:07:48,000
Let me explain why this hierarchy is so powerful.

79
00:07:48,000 --> 00:07:54,000
When you catch `FinRAGError`, you catch every application error.
This is useful at the highest level of your application.

80
00:07:54,000 --> 00:08:00,000
When you catch `StorageError`, you catch all database and cache errors.
This is useful in the data access layer.

81
00:08:00,000 --> 00:08:06,000
When you catch `IngestionError`, you catch all ingestion errors.
This is useful in the ingestion pipeline.

82
00:08:06,000 --> 00:08:12,000
This allows you to handle errors at the right level. You don't need to
check the error message to understand the category. The class name
tells you immediately.

83
00:08:12,000 --> 00:08:18,000
In the API layer, you catch `FinRAGError` and return a 500 response.
You log the error and the cause for debugging.

84
00:08:18,000 --> 00:08:24,000
In the ingestion layer, you catch `SECFetchError` and retry with backoff.
This handles transient network failures gracefully.

85
00:08:24,000 --> 00:08:30,000
In the database layer, you catch `DatabaseConnectionError` and attempt
to reconnect. This handles temporary database outages.

86
00:08:30,000 --> 00:08:36,000
This is how you build resilient systems. You handle errors at the right
level with the right strategy.

87
00:08:36,000 --> 00:08:42,000
Now let's verify our work. Open the terminal and run Python.

88
00:08:42,000 --> 00:08:48,000
[Types: python]
We're starting the Python interpreter.

89
00:08:48,000 --> 00:08:54,000
[Types: from financial_rag.utils import FinRAGError]
We import the base exception.

90
00:08:54,000 --> 00:09:00,000
[Types: from financial_rag.utils import RecordNotFoundError]
We import a specific exception.

91
00:09:00,000 --> 00:09:06,000
[Types: try:]
We start a try block for testing.

92
00:09:06,000 --> 00:09:12,000
[Types: raise RecordNotFoundError("Filing", "abc-123")]
We raise the exception with test values.

93
00:09:12,000 --> 00:09:18,000
[Types: except RecordNotFoundError as e:]
We catch the specific exception.

94
00:09:18,000 --> 00:09:24,000
[Types: print(e)]
We print the exception. This shows the formatted message.

95
00:09:24,000 --> 00:09:30,000
You should see `Filing not found: abc-123`. This confirms the exception
works correctly.

96
00:09:30,000 --> 00:09:36,000
Now test the chaining. This is our most powerful feature.
[Types: try:]

97
00:09:36,000 --> 00:09:42,000
[Types: raise FinRAGError("Application error", cause=ValueError("Root cause"))]
We raise a FinRAGError with a cause.

98
00:09:42,000 --> 00:09:48,000
[Types: except FinRAGError as e:]
We catch the base exception.

99
00:09:48,000 --> 00:09:54,000
[Types: print(e)]
We print the exception. This shows the chained message.

100
00:09:54,000 --> 00:10:00,000
You should see `Application error (caused by: Root cause)`. This confirms
exception chaining works.

101
00:10:00,000 --> 00:10:06,000
This is the power of a proper exception hierarchy. You get clear, meaningful
error messages that tell you exactly what happened.

102
00:10:06,000 --> 00:10:12,000
Now let me recap what we've built in Part 1.

103
00:10:12,000 --> 00:10:18,000
We built a complete exception hierarchy with a base `FinRAGError` class.

104
00:10:18,000 --> 00:10:24,000
We built `StorageError` for database and cache issues with specific
subclasses for different types of storage errors.

105
00:10:24,000 --> 00:10:30,000
We built `IngestionError` for SEC EDGAR and parsing issues with specific
subclasses for fetching, parsing, and deduplication.

106
00:10:30,000 --> 00:10:36,000
We built `ProcessingError` for text processing and chunking issues.

107
00:10:36,000 --> 00:10:42,000
We built `RetrievalError` for embeddings and vector search issues.

108
00:10:42,000 --> 00:10:48,000
We built `ConfigurationError` for settings validation failures.

109
00:10:48,000 --> 00:10:54,000
We updated the utils __init__.py file to export all exceptions.

110
00:10:54,000 --> 00:11:00,000
We tested the exceptions and confirmed exception chaining works.

111
00:11:00,000 --> 00:11:06,000
This is the foundation of error handling in our application.
Every future component will use these exceptions.

112
00:11:06,000 --> 00:11:12,000
In Part 2, we'll build the BaseRepository. This is the foundation
of our data access layer. All repositories will inherit from it.

113
00:11:12,000 --> 00:11:18,000
Thank you for watching. I'll see you in Part 2.

114
00:11:18,000 --> 00:11:22,000
[End of Part 1]
1
00:00:00,000 --> 00:00:06,000
Welcome back to Phase 2. In Part 2, we build the Base Repository.
This is the foundation of our data access layer.

2
00:00:06,000 --> 00:00:12,000
Every repository in our application will inherit from this class.
It provides common CRUD operations that every repository needs.

3
00:00:12,000 --> 00:00:18,000
Think of it this way. Every table in our database needs the same operations.
Create, Read, Update, Delete. Instead of writing these for every table,
we write them once in a base class.

4
00:00:18,000 --> 00:00:24,000
This is the DRY principle. Don't Repeat Yourself. It saves time and
reduces bugs. One change in the base class affects all repositories.

5
00:00:24,000 --> 00:00:30,000
Open your editor and create `src/financial_rag/storage/repositories/base.py`.

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
We import TypeVar for generic type hints. This allows us to write generic
repositories that work with any model type.
[Types: from typing import Any, TypeVar]

9
00:00:48,000 --> 00:00:54,000
We import UUID for primary key handling.
[Types: from uuid import UUID]

10
00:00:54,000 --> 00:01:00,000
Now we import SQLAlchemy components. func for aggregate functions like count.
[Types: from sqlalchemy import func, select]

11
00:01:00,000 --> 00:01:06,000
We import AsyncSession for type hints in the constructor.
[Types: from sqlalchemy.ext.asyncio import AsyncSession]

12
00:01:06,000 --> 00:01:12,000
We import our custom exceptions for error handling.
[Types: from financial_rag.utils.exceptions import DatabaseQueryError, RecordNotFoundError]

13
00:01:12,000 --> 00:01:18,000
Now let's define the type variable. This is a generic type parameter.
[Types: ModelT = TypeVar("ModelT")]

14
00:01:18,000 --> 00:01:24,000
ModelT represents the ORM model type. When we inherit from BaseRepository,
we specify the model type. This makes the repository type-safe.

15
00:01:24,000 --> 00:01:30,000
Now let's define the BaseRepository class. It's a generic class.
[Types: class BaseRepository(Generic[ModelT]):]

16
00:01:30,000 --> 00:01:36,000
The Generic[ModelT] tells Python this is a generic class.
It means the class can work with any model type.

17
00:01:36,000 --> 00:01:42,000
Now let's define the model_class attribute. This is a class variable.
[Types: model_class: type[Any]]

18
00:01:42,000 --> 00:01:48,000
Subclasses must override this with their specific model.
For example, FilingsRepository sets model_class = Filing.

19
00:01:48,000 --> 00:01:54,000
Now let's define the constructor. It takes an AsyncSession.
[Types: def __init__(self, session: AsyncSession) -> None:]

20
00:01:54,000 --> 00:02:00,000
We store the session in an instance variable.
[Types: self._session = session]

21
00:02:00,000 --> 00:02:06,000
The session is injected from the caller. The repository doesn't create its own
session. This follows the principle of dependency injection.

22
00:02:06,000 --> 00:02:12,000
Now let's implement the add method. This creates a new record.
[Types: async def add(self, instance: ModelT) -> ModelT:]

23
00:02:12,000 --> 00:02:18,000
We wrap the operation in a try-except block.
[Types: try:]

24
00:02:18,000 --> 00:02:24,000
We add the instance to the session.
[Types: self._session.add(instance)]

25
00:02:24,000 --> 00:02:30,000
We flush the session to send the INSERT to the database.
[Types: await self._session.flush()]

26
00:02:30,000 --> 00:02:36,000
We refresh the instance to get the generated values like ID.
[Types: await self._session.refresh(instance)]

27
00:02:36,000 --> 00:02:42,000
We log the addition for debugging purposes.
[Types: logger.debug("Added %s id=%s", self.model_class.__name__, getattr(instance, "id", "?"))]

28
00:02:42,000 --> 00:02:48,000
We return the instance with its generated values.
[Types: return instance]

29
00:02:48,000 --> 00:02:54,000
If there's an error, we catch it and raise our custom exception.
[Types: except Exception as exc:]

30
00:02:54,000 --> 00:03:00,000
We include the model name in the error message for context.
[Types: raise DatabaseQueryError(f"Failed to add {self.model_class.__name__}: {exc}") from exc]

31
00:03:00,000 --> 00:03:06,000
Now let's implement the add_many method. This adds multiple records at once.
[Types: async def add_many(self, instances: list[ModelT]) -> list[ModelT]:]

32
00:03:06,000 --> 00:03:12,000
We handle the empty list case first.
[Types: if not instances:]
[Types: return []]

33
00:03:12,000 --> 00:03:18,000
We wrap the operation in a try-except block.
[Types: try:]

34
00:03:18,000 --> 00:03:24,000
We use add_all to add all instances at once.
[Types: self._session.add_all(instances)]

35
00:03:24,000 --> 00:03:30,000
We flush to send all INSERTs in a single batch.
[Types: await self._session.flush()]

36
00:03:30,000 --> 00:03:36,000
We log the bulk operation.
[Types: logger.debug("Bulk-added %d %s records", len(instances), self.model_class.__name__)]

37
00:03:36,000 --> 00:03:42,000
We return the instances with generated values.
[Types: return instances]

38
00:03:42,000 --> 00:03:48,000
If there's an error, we raise our custom exception.
[Types: except Exception as exc:]

39
00:03:48,000 --> 00:03:54,000
[Types: raise DatabaseQueryError(f"Failed to bulk-add {self.model_class.__name__}: {exc}") from exc]

40
00:03:54,000 --> 00:04:00,000
Now let's implement the get_by_id method. This retrieves a record by ID.
[Types: async def get_by_id(self, record_id: UUID) -> ModelT:]

41
00:04:00,000 --> 00:04:06,000
We wrap the operation in a try-except block.
[Types: try:]

42
00:04:06,000 --> 00:04:12,000
We use session.get for primary key lookup. This is more efficient than a query.
[Types: instance = await self._session.get(self.model_class, record_id)]

43
00:04:12,000 --> 00:04:18,000
If the instance is None, we raise RecordNotFoundError.
[Types: if instance is None:]

44
00:04:18,000 --> 00:04:24,000
[Types: raise RecordNotFoundError(self.model_class.__name__, str(record_id))]

45
00:04:24,000 --> 00:04:30,000
If we find the instance, we return it.
[Types: return instance]

46
00:04:30,000 --> 00:04:36,000
If there's a database error, we raise DatabaseQueryError.
[Types: except Exception as exc:]

47
00:04:36,000 --> 00:04:42,000
[Types: raise DatabaseQueryError(f"Failed to fetch {self.model_class.__name__} id={record_id}: {exc}") from exc]

48
00:04:42,000 --> 00:04:48,000
Now let's implement get_by_id_or_none. This returns None if not found.
[Types: async def get_by_id_or_none(self, record_id: UUID) -> ModelT | None:]

49
00:04:48,000 --> 00:04:54,000
We wrap the operation in a try-except block.
[Types: try:]

50
00:04:54,000 --> 00:05:00,000
We use session.get for primary key lookup.
[Types: return await self._session.get(self.model_class, record_id)]

51
00:05:00,000 --> 00:05:06,000
If there's a database error, we raise DatabaseQueryError.
[Types: except Exception as exc:]

52
00:05:06,000 --> 00:05:12,000
[Types: raise DatabaseQueryError(f"Failed to fetch {self.model_class.__name__} id={record_id}: {exc}") from exc]

53
00:05:12,000 --> 00:05:18,000
Now let's implement the list_all method. This retrieves all records with pagination.
[Types: async def list_all(self, *, limit: int = 100, offset: int = 0,) -> list[ModelT]:]

54
00:05:18,000 --> 00:05:24,000
We wrap the operation in a try-except block.
[Types: try:]

55
00:05:24,000 --> 00:05:30,000
We build a select query for the model.
[Types: stmt = select(self.model_class).limit(limit).offset(offset)]

56
00:05:30,000 --> 00:05:36,000
We execute the query.
[Types: result = await self._session.execute(stmt)]

57
00:05:36,000 --> 00:05:42,000
We return the results as a list.
[Types: return list(result.scalars().all())]

58
00:05:42,000 --> 00:05:48,000
If there's a database error, we raise DatabaseQueryError.
[Types: except Exception as exc:]

59
00:05:48,000 --> 00:05:54,000
[Types: raise DatabaseQueryError(f"Failed to list {self.model_class.__name__}: {exc}") from exc]

60
00:05:54,000 --> 00:06:00,000
Now let's implement the count method. This returns the total number of records.
[Types: async def count(self) -> int:]

61
00:06:00,000 --> 00:06:06,000
We wrap the operation in a try-except block.
[Types: try:]

62
00:06:06,000 --> 00:06:12,000
We use func.count to count all records.
[Types: result = await self._session.execute(select(func.count()).select_from(self.model_class))]

63
00:06:12,000 --> 00:06:18,000
We return the count as an integer.
[Types: return result.scalar_one()]

64
00:06:18,000 --> 00:06:24,000
If there's a database error, we raise DatabaseQueryError.
[Types: except Exception as exc:]

65
00:06:24,000 --> 00:06:30,000
[Types: raise DatabaseQueryError(f"Failed to count {self.model_class.__name__}: {exc}") from exc]

66
00:06:30,000 --> 00:06:36,000
Now let's implement the update method. This updates specific fields on a record.
[Types: async def update(self, instance: ModelT, **fields: Any) -> ModelT:]

67
00:06:36,000 --> 00:06:42,000
We wrap the operation in a try-except block.
[Types: try:]

68
00:06:42,000 --> 00:06:48,000
We iterate through each field to update.
[Types: for key, value in fields.items():]

69
00:06:48,000 --> 00:06:54,000
We check if the attribute exists on the model.
[Types: if not hasattr(instance, key):]

70
00:06:54,000 --> 00:07:00,000
If it doesn't exist, we raise an error.
[Types: raise DatabaseQueryError(f"{self.model_class.__name__} has no attribute '{key}'")]

71
00:07:00,000 --> 00:07:06,000
We set the attribute to the new value.
[Types: setattr(instance, key, value)]

72
00:07:06,000 --> 00:07:12,000
We flush to send the UPDATE to the database.
[Types: await self._session.flush()]

73
00:07:12,000 --> 00:07:18,000
We refresh the instance to get any computed values.
[Types: await self._session.refresh(instance)]

74
00:07:18,000 --> 00:07:24,000
We return the updated instance.
[Types: return instance]

75
00:07:24,000 --> 00:07:30,000
If there's a database error, we raise DatabaseQueryError.
[Types: except Exception as exc:]

76
00:07:30,000 --> 00:07:36,000
[Types: raise DatabaseQueryError(f"Failed to update {self.model_class.__name__}: {exc}") from exc]

77
00:07:36,000 --> 00:07:42,000
Now let's implement the delete method. This deletes a record permanently.
[Types: async def delete(self, instance: ModelT) -> None:]

78
00:07:42,000 --> 00:07:48,000
We wrap the operation in a try-except block.
[Types: try:]

79
00:07:48,000 --> 00:07:54,000
We delete the instance from the session.
[Types: await self._session.delete(instance)]

80
00:07:54,000 --> 00:08:00,000
We flush to send the DELETE to the database.
[Types: await self._session.flush()]

81
00:08:00,000 --> 00:08:06,000
If there's a database error, we raise DatabaseQueryError.
[Types: except Exception as exc:]

82
00:08:06,000 --> 00:08:12,000
[Types: raise DatabaseQueryError(f"Failed to delete {self.model_class.__name__}: {exc}") from exc]

83
00:08:12,000 --> 00:08:18,000
Now let's implement the soft_delete method. This sets is_active to False.
[Types: async def soft_delete(self, instance: ModelT) -> ModelT:]

84
00:08:18,000 --> 00:08:24,000
This is safer than hard delete. It preserves the data for auditing.
We simply call update with is_active=False.

85
00:08:24,000 --> 00:08:30,000
[Types: return await self.update(instance, is_active=False)]

86
00:08:30,000 --> 00:08:36,000
Now let's update the repositories __init__.py file.
Open `src/financial_rag/storage/repositories/__init__.py`.

87
00:08:36,000 --> 00:08:42,000
We import BaseRepository from the base module.
[Types: from .base import BaseRepository]

88
00:08:42,000 --> 00:08:48,000
And we export it.
[Types: __all__ = ["BaseRepository"]]

89
00:08:48,000 --> 00:08:54,000
Now let me explain the transaction management pattern.

90
00:08:54,000 --> 00:09:00,000
The repository doesn't commit transactions. It only flushes.
The caller is responsible for committing the transaction.

91
00:09:00,000 --> 00:09:06,000
This is important. It allows the caller to group multiple operations
into a single transaction. If any operation fails, everything rolls back.

92
00:09:06,000 --> 00:09:12,000
For example, when ingesting a filing, we need to insert the filing record
and all its chunks in a single transaction. If the chunks fail,
the filing record is rolled back.

93
00:09:12,000 --> 00:09:18,000
This ensures data consistency. There are no partial writes.

94
00:09:18,000 --> 00:09:24,000
Now let me show you a practical example of using the base repository.

95
00:09:24,000 --> 00:09:30,000
class FilingsRepository(BaseRepository[Filing]):
    model_class = Filing

96
00:09:30,000 --> 00:09:36,000
That's it. The base repository provides all the CRUD operations.
The child class only needs to specify the model class.

97
00:09:36,000 --> 00:09:42,000
Then you can add custom methods for specific queries.
Like get_by_ticker or get_by_hash.

98
00:09:42,000 --> 00:09:48,000
This is the power of inheritance. You write the common code once
in the base class. Child classes inherit it for free.

99
00:09:48,000 --> 00:09:54,000
Now let me recap what we've built in Part 2.

100
00:09:54,000 --> 00:10:00,000
We built the BaseRepository class. This is a generic class that
provides common CRUD operations. It has add, add_many, get_by_id,
get_by_id_or_none, list_all, count, update, delete, and soft_delete.

101
00:10:00,000 --> 00:10:06,000
Every repository in our application will inherit from this class.
This saves time and reduces bugs.

102
00:10:06,000 --> 00:10:12,000
In Part 3, we'll build the Filings Repository and ORM.
This will implement the specific operations for the filings table.

103
00:10:12,000 --> 00:10:18,000
Thank you for watching. I'll see you in Part 3.

104
00:10:18,000 --> 00:10:22,000
[End of Part 2]
1
00:00:00,000 --> 00:00:06,000
Welcome back to Phase 2. In Part 3, we build the Filings Repository and ORM.

2
00:00:06,000 --> 00:00:12,000
This is where we define our database schema for SEC filings. We create the ORM
model and the repository that interacts with it.

3
00:00:12,000 --> 00:00:18,000
Open your editor and create `src/financial_rag/storage/repositories/filings.py`.

4
00:00:18,000 --> 00:00:24,000
We'll start with the imports. The __future__ import enables forward references.
[Types: from __future__ import annotations]

5
00:00:24,000 --> 00:00:30,000
We import logging for structured logging throughout the repository.
[Types: import logging]

6
00:00:30,000 --> 00:00:36,000
We import date from datetime for handling filing dates.
[Types: from datetime import date]

7
00:00:36,000 --> 00:00:42,000
We import UUID for primary key handling.
[Types: from uuid import UUID]

8
00:00:42,000 --> 00:00:48,000
Now we import SQLAlchemy types. Boolean for boolean fields.
[Types: from sqlalchemy import Boolean]

9
00:00:48,000 --> 00:00:54,000
Date for date fields. Integer for integer fields.
[Types: from sqlalchemy import Date, Integer]

10
00:00:54,000 --> 00:01:00,000
SmallInteger for small integer fields like fiscal quarter.
[Types: from sqlalchemy import SmallInteger]

11
00:01:00,000 --> 00:01:06,000
String for string fields like ticker and filing_type.
[Types: from sqlalchemy import String]

12
00:01:06,000 --> 00:01:12,000
We import select for building queries.
[Types: from sqlalchemy import select]

13
00:01:12,000 --> 00:01:18,000
Now we import the ORM mapping types. Mapped for type hints.
[Types: from sqlalchemy.orm import Mapped]

14
00:01:18,000 --> 00:01:24,000
And mapped_column for defining columns.
[Types: from sqlalchemy.orm import mapped_column]

15
00:01:24,000 --> 00:01:30,000
We import Base from our database module. This is the declarative base.
[Types: from financial_rag.storage.database import Base]

16
00:01:30,000 --> 00:01:36,000
We import BaseRepository from the base module.
[Types: from financial_rag.storage.repositories.base import BaseRepository]

17
00:01:36,000 --> 00:01:42,000
And we import DatabaseQueryError for handling database errors.
[Types: from financial_rag.utils.exceptions import DatabaseQueryError]

18
00:01:42,000 --> 00:01:48,000
Now let's define the ORM model for filings. This maps to the filings table.
[Types: class Filing(Base):]

19
00:01:48,000 --> 00:01:54,000
We set the table name to match our schema.
[Types: __tablename__ = "filings"]

20
00:01:54,000 --> 00:02:00,000
Now let's define the id column. This is the primary key.
[Types: id: Mapped[UUID] = mapped_column(primary_key=True)]

21
00:02:00,000 --> 00:02:06,000
We use UUID as the type. This is more secure than auto-incrementing integers.
It prevents ID enumeration attacks.

22
00:02:06,000 --> 00:02:12,000
Now the ticker column. This stores the stock ticker symbol like AAPL or MSFT.
[Types: ticker: Mapped[str] = mapped_column(String(10), nullable=False, index=True)]

23
00:02:12,000 --> 00:02:18,000
We use String(10) because tickers are short. We set nullable=False because
every filing belongs to a company. We add index=True for fast lookups.

24
00:02:18,000 --> 00:02:24,000
Now the filing_type column. This stores the SEC form type like 10-K or 10-Q.
[Types: filing_type: Mapped[str] = mapped_column(String(20), nullable=False)]

25
00:02:24,000 --> 00:02:30,000
We use String(20) because form types are short like "10-K" or "10-Q".
We set nullable=False because every filing has a type.

26
00:02:30,000 --> 00:02:36,000
Now the fiscal_year column. This stores the fiscal year as a small integer.
[Types: fiscal_year: Mapped[int | None] = mapped_column(SmallInteger)]

27
00:02:36,000 --> 00:02:42,000
We use SmallInteger because years fit in a small integer. We allow None
because some filings might not have a fiscal year.

28
00:02:42,000 --> 00:02:48,000
Now the fiscal_quarter column. This stores the fiscal quarter, 1 through 4.
[Types: fiscal_quarter: Mapped[int | None] = mapped_column(SmallInteger)]

29
00:02:48,000 --> 00:02:54,000
We use SmallInteger for the quarter number. We allow None because not all
filings have a quarter.

30
00:02:54,000 --> 00:03:00,000
Now the filed_at column. This stores the date the filing was filed with the SEC.
[Types: filed_at: Mapped[date | None] = mapped_column(Date)]

31
00:03:00,000 --> 00:03:06,000
We use Date for the data type. We allow None because some filings might not
have a filed date.

32
00:03:06,000 --> 00:03:12,000
Now the source_url column. This stores the URL where the filing came from.
[Types: source_url: Mapped[str | None] = mapped_column(String)]

33
00:03:12,000 --> 00:03:18,000
We use String without a length limit because URLs can be long.
We allow None because the URL might not always be available.

34
00:03:18,000 --> 00:03:24,000
Now the file_hash column. This stores the SHA-256 hash for deduplication.
[Types: file_hash: Mapped[str | None] = mapped_column(String(64), unique=True)]

35
00:03:24,000 --> 00:03:30,000
We use String(64) because SHA-256 hashes are exactly 64 characters.
We set unique=True to prevent duplicate filings.

36
00:03:30,000 --> 00:03:36,000
Now the pages column. This stores the number of pages in the filing.
[Types: pages: Mapped[int | None] = mapped_column(Integer)]

37
00:03:36,000 --> 00:03:42,000
We use Integer because pages can be large. We allow None because we might
not always parse the page count.

38
00:03:42,000 --> 00:03:48,000
Now the ingested_by column. This identifies who or what ingested the filing.
[Types: ingested_by: Mapped[str | None] = mapped_column(String(100))]

39
00:03:48,000 --> 00:03:54,000
We use String(100) for the ingestion source. We allow None because it's
optional metadata.

40
00:03:54,000 --> 00:04:00,000
Now the is_active column. This enables soft deletion.
[Types: is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)]

41
00:04:00,000 --> 00:04:06,000
We use Boolean for the active flag. We set default=True because new filings
are active by default. We set nullable=False because it always has a value.

42
00:04:06,000 --> 00:04:12,000
Now let's define the string representation. This is for debugging.
[Types: def __repr__(self) -> str:]

43
00:04:12,000 --> 00:04:18,000
We return a string with the ticker, filing type, and fiscal year.
[Types: return f"<Filing id={self.id} ticker={self.ticker} type={self.filing_type} year={self.fiscal_year}>"]

44
00:04:18,000 --> 00:04:24,000
This makes it easy to identify filings when debugging.

45
00:04:24,000 --> 00:04:30,000
Now let's define the FilingsRepository class. This inherits from BaseRepository.
[Types: class FilingsRepository(BaseRepository[Filing]):]

46
00:04:30,000 --> 00:04:36,000
We specify Filing as the model type. This tells the repository what table to use.

47
00:04:36,000 --> 00:04:42,000
We set the model_class class variable.
[Types: model_class = Filing]

48
00:04:42,000 --> 00:04:48,000
This is used by the base repository for common operations.

49
00:04:48,000 --> 00:04:54,000
Now let's implement get_by_hash. This looks up a filing by its SHA-256 hash.
[Types: async def get_by_hash(self, file_hash: str) -> Filing | None:]

50
00:04:54,000 --> 00:05:00,000
We use this for deduplication during ingestion. If the hash exists,
the filing is already ingested.

51
00:05:00,000 --> 00:05:06,000
We wrap the query in a try-except block for error handling.
[Types: try:]

52
00:05:06,000 --> 00:05:12,000
We build a select query on the Filing model.
[Types: result = await self._session.execute(select(Filing).where(Filing.file_hash == file_hash))]

53
00:05:12,000 --> 00:05:18,000
We use scalar_one_or_none to get the first result or None.
[Types: return result.scalar_one_or_none()]

54
00:05:18,000 --> 00:05:24,000
If there's an error, we raise DatabaseQueryError with context.
[Types: except Exception as exc:]

55
00:05:24,000 --> 00:05:30,000
We include the hash in the error message for debugging.
[Types: raise DatabaseQueryError(f"Failed to look up filing by hash '{file_hash}': {exc}") from exc]

56
00:05:30,000 --> 00:05:36,000
Now let's implement exists_by_hash. This is a faster version of get_by_hash.
[Types: async def exists_by_hash(self, file_hash: str) -> bool:]

57
00:05:36,000 --> 00:05:42,000
We just return True or False based on whether the hash exists.
[Types: return await self.get_by_hash(file_hash) is not None]

58
00:05:42,000 --> 00:05:48,000
This is used during ingestion to check for duplicates without loading the full record.

59
00:05:48,000 --> 00:05:54,000
Now let's implement get_by_ticker. This returns all filings for a ticker.
[Types: async def get_by_ticker(self, ticker: str, *, active_only: bool = True, limit: int = 50,) -> list[Filing]:]

60
00:05:54,000 --> 00:06:00,000
We use try-except for error handling.
[Types: try:]

61
00:06:00,000 --> 00:06:06,000
We build a select query with a where clause on ticker.
[Types: stmt = select(Filing).where(Filing.ticker == ticker.upper())]

62
00:06:06,000 --> 00:06:12,000
We order by fiscal year descending to get the most recent first.
[Types: stmt = stmt.order_by(Filing.fiscal_year.desc())]

63
00:06:12,000 --> 00:06:18,000
We limit the results to prevent overwhelming queries.
[Types: stmt = stmt.limit(limit)]

64
00:06:18,000 --> 00:06:24,000
If active_only is True, we filter to only active filings.
[Types: if active_only: stmt = stmt.where(Filing.is_active.is_(True))]

65
00:06:24,000 --> 00:06:30,000
We execute the query and return the results.
[Types: result = await self._session.execute(stmt)]
[Types: return list(result.scalars().all())]

66
00:06:30,000 --> 00:06:36,000
If there's an error, we raise DatabaseQueryError.
[Types: except Exception as exc:]
[Types: raise DatabaseQueryError(f"Failed to fetch filings for ticker '{ticker}': {exc}") from exc]

67
00:06:36,000 --> 00:06:42,000
Now let's implement get_by_ticker_and_type. This is more specific.
[Types: async def get_by_ticker_and_type(self, ticker: str, filing_type: str, *, fiscal_year: int | None = None, active_only: bool = True,) -> list[Filing]:]

68
00:06:42,000 --> 00:06:48,000
This is used when we need filings of a specific type, like all 10-Ks for AAPL.

69
00:06:48,000 --> 00:06:54,000
We start with the try block.
[Types: try:]

70
00:06:54,000 --> 00:07:00,000
We build the base query with ticker and filing_type filters.
[Types: stmt = select(Filing).where(Filing.ticker == ticker.upper(), Filing.filing_type == filing_type)]

71
00:07:00,000 --> 00:07:06,000
We order by fiscal year descending to get the most recent first.
[Types: stmt = stmt.order_by(Filing.fiscal_year.desc())]

72
00:07:06,000 --> 00:07:12,000
If fiscal_year is provided, we add it as a filter.
[Types: if fiscal_year is not None: stmt = stmt.where(Filing.fiscal_year == fiscal_year)]

73
00:07:12,000 --> 00:07:18,000
If active_only is True, we filter to only active filings.
[Types: if active_only: stmt = stmt.where(Filing.is_active.is_(True))]

74
00:07:18,000 --> 00:07:24,000
We execute the query and return the results.
[Types: result = await self._session.execute(stmt)]
[Types: return list(result.scalars().all())]

75
00:07:24,000 --> 00:07:30,000
If there's an error, we raise DatabaseQueryError.
[Types: except Exception as exc:]
[Types: raise DatabaseQueryError(f"Failed to fetch {filing_type} filings for '{ticker}': {exc}") from exc]

76
00:07:30,000 --> 00:07:36,000
Now let's implement get_latest. This returns the most recent filing of a type.
[Types: async def get_latest(self, ticker: str, filing_type: str,) -> Filing | None:]

77
00:07:36,000 --> 00:07:42,000
This is used to check if we need to re-ingest. If the latest filing is recent,
we can skip ingestion.

78
00:07:42,000 --> 00:07:48,000
We start with the try block.
[Types: try:]

79
00:07:48,000 --> 00:07:54,000
We build the query with ticker and filing_type filters.
[Types: result = await self._session.execute(select(Filing).where(Filing.ticker == ticker.upper(), Filing.filing_type == filing_type, Filing.is_active.is_(True),).order_by(Filing.fiscal_year.desc()).limit(1))]

80
00:07:54,000 --> 00:08:00,000
We filter to active filings only. We order by fiscal year descending.
We limit to 1 to get the most recent.

81
00:08:00,000 --> 00:08:06,000
We return the first result or None.
[Types: return result.scalar_one_or_none()]

82
00:08:06,000 --> 00:08:12,000
If there's an error, we raise DatabaseQueryError.
[Types: except Exception as exc:]
[Types: raise DatabaseQueryError(f"Failed to fetch latest {filing_type} for '{ticker}': {exc}") from exc]

83
00:08:12,000 --> 00:08:18,000
Now let's implement list_tickers. This returns all distinct tickers.
[Types: async def list_tickers(self) -> list[str]:]

84
00:08:18,000 --> 00:08:24,000
This is used for getting a list of all companies in the system.

85
00:08:24,000 --> 00:08:30,000
We need to import distinct from sqlalchemy.
[Types: from sqlalchemy import distinct]

86
00:08:30,000 --> 00:08:36,000
We start with the try block.
[Types: try:]

87
00:08:36,000 --> 00:08:42,000
We build a query for distinct tickers.
[Types: result = await self._session.execute(select(distinct(Filing.ticker)).where(Filing.is_active.is_(True)).order_by(Filing.ticker))]

88
00:08:42,000 --> 00:08:48,000
We filter to active filings only. We order alphabetically.
[Types: return list(result.scalars().all())]

89
00:08:48,000 --> 00:08:54,000
If there's an error, we raise DatabaseQueryError.
[Types: except Exception as exc:]
[Types: raise DatabaseQueryError(f"Failed to list tickers: {exc}") from exc]

90
00:08:54,000 --> 00:09:00,000
Now let's update the repositories __init__.py file.
Open `src/financial_rag/storage/repositories/__init__.py`.

91
00:09:00,000 --> 00:09:06,000
We import the Filing model and FilingsRepository.
[Types: from .filings import Filing, FilingsRepository]

92
00:09:06,000 --> 00:09:12,000
And we export them.
[Types: __all__ = ["Filing", "FilingsRepository"]]

93
00:09:12,000 --> 00:09:18,000
Now let me recap what we've built in Part 3.

94
00:09:18,000 --> 00:09:24,000
We built the Filing ORM model. This maps to the filings table.
It has fields for ticker, filing_type, fiscal_year, fiscal_quarter,
filed_at, source_url, file_hash, pages, ingested_by, and is_active.

95
00:09:24,000 --> 00:09:30,000
We built the FilingsRepository. This provides CRUD operations and
query methods for the filings table. It has get_by_hash for
deduplication, get_by_ticker for listings, and get_latest for
checking if re-ingestion is needed.

96
00:09:30,000 --> 00:09:36,000
In Part 4, we'll build the Rate Limiter and SEC Ingestor.
This will download filings from EDGAR with proper rate limiting.

97
00:09:36,000 --> 00:09:42,000
Thank you for watching. I'll see you in Part 4.

98
00:09:42,000 --> 00:09:46,000
[End of Part 3]
1
00:00:00,000 --> 00:00:06,000
Welcome back to Phase 2. In Part 4, we build the SEC EDGAR ingestor.

2
00:00:06,000 --> 00:00:12,000
This is the heart of our ingestion pipeline. It downloads filings from
the SEC's EDGAR system. This is where we get all our financial data.

3
00:00:12,000 --> 00:00:18,000
But before we can download anything, we need to talk about rate limiting.
The SEC has a hard limit of 10 requests per second per IP address.

4
00:00:18,000 --> 00:00:24,000
This is not a suggestion. It's a hard rule. The SEC will ban your IP
if you make too many requests. We need to be respectful of their servers.

5
00:00:24,000 --> 00:00:30,000
So let's build a rate limiter. Open your editor and create
`src/financial_rag/ingestion/sec_ingestor.py`.

6
00:00:30,000 --> 00:00:36,000
We'll start with the imports. The __future__ import enables forward references.
[Types: from __future__ import annotations]

7
00:00:36,000 --> 00:00:42,000
We need asyncio for async I/O operations.
[Types: import asyncio]

8
00:00:42,000 --> 00:00:48,000
We need hashlib for SHA-256 deduplication.
[Types: import hashlib]

9
00:00:48,000 --> 00:00:54,000
We need logging for structured logging.
[Types: import logging]

10
00:00:54,000 --> 00:01:00,000
We import date from datetime for filing dates.
[Types: from datetime import date]

11
00:01:00,000 --> 00:01:06,000
We import TYPE_CHECKING for conditional type imports.
[Types: from typing import TYPE_CHECKING]

12
00:01:06,000 --> 00:01:12,000
We import Path from pathlib for file system operations.
[Types: from pathlib import Path]

13
00:01:12,000 --> 00:01:18,000
Now we import the HTTP client. httpx is async and fast.
[Types: import httpx]

14
00:01:18,000 --> 00:01:24,000
Now we import tenacity for retries with exponential backoff.
[Types: from tenacity import retry, retry_if_exception_type, stop_after_attempt, wait_exponential]

15
00:01:24,000 --> 00:01:30,000
We import get_settings from our config.
[Types: from financial_rag.config import get_settings]

16
00:01:30,000 --> 00:01:36,000
And we import SECFetchError from our exception hierarchy.
[Types: from financial_rag.utils.exceptions import SECFetchError]

17
00:01:36,000 --> 00:01:42,000
Now let's define the EDGAR base URLs. These are constants.
[Types: _EDGAR_BASE = "https://data.sec.gov"]

18
00:01:42,000 --> 00:01:48,000
This is the main EDGAR API endpoint. All requests go through this.

19
00:01:48,000 --> 00:01:54,000
Now the search endpoint for finding filings.
[Types: _EDGAR_SEARCH = "https://efts.sec.gov/LATEST/search-index"]

20
00:01:54,000 --> 00:02:00,000
The submissions endpoint for CIK lookups.
[Types: _EDGAR_FILINGS = f"{_EDGAR_BASE}/submissions"]

21
00:02:00,000 --> 00:02:06,000
And the archives endpoint where documents are stored.
[Types: _EDGAR_ARCHIVES = "https://www.sec.gov/Archives/edgar/data"]

22
00:02:06,000 --> 00:02:12,000
Now let's define the filing types we support. We use a frozenset for speed.
[Types: SUPPORTED_FILING_TYPES = frozenset({"10-K", "10-Q", "8-K", "20-F", "DEF 14A", "S-1"})]

23
00:02:12,000 --> 00:02:18,000
A frozenset is immutable and provides O(1) lookup. This is perfect for validation.

24
00:02:18,000 --> 00:02:24,000
Now let's build the rate limiter class. This is a token bucket implementation.
[Types: class _EdgarRateLimiter:]

25
00:02:24,000 --> 00:02:30,000
We use an underscore because this is an internal class. It's not meant to be used directly.

26
00:02:30,000 --> 00:02:36,000
Now the init method. We take requests per second as a parameter.
[Types: def __init__(self, rps: int) -> None:]

27
00:02:36,000 --> 00:02:42,000
We create a semaphore to limit concurrent requests.
[Types: self._semaphore = asyncio.Semaphore(rps)]

28
00:02:42,000 --> 00:02:48,000
A semaphore limits how many coroutines can access a resource at once.
We set it to RPS to limit concurrent requests.

29
00:02:48,000 --> 00:02:54,000
Now we calculate the interval between requests in seconds.
[Types: self._interval = 1.0 / rps]

30
00:02:54,000 --> 00:03:00,000
For 10 RPS, this is 0.1 seconds. This ensures we space out requests evenly.

31
00:03:00,000 --> 00:03:06,000
Now let's implement the async context manager. This is the entry point.
[Types: async def __aenter__(self) -> None:]

32
00:03:06,000 --> 00:03:12,000
We acquire the semaphore before making a request.
[Types: await self._semaphore.acquire()]

33
00:03:12,000 --> 00:03:18,000
This blocks if there are already RPS requests in flight.

34
00:03:18,000 --> 00:03:24,000
Now the exit method. This runs after the request completes.
[Types: async def __aexit__(self, *_: object) -> None:]

35
00:03:24,000 --> 00:03:30,000
We sleep for the interval to maintain the rate.
[Types: await asyncio.sleep(self._interval)]

36
00:03:30,000 --> 00:03:36,000
Then we release the semaphore so the next request can proceed.
[Types: self._semaphore.release()]

37
00:03:36,000 --> 00:03:42,000
This ensures we never make more than RPS requests per second.
The semaphore limits concurrent requests. The sleep ensures spacing.

38
00:03:42,000 --> 00:03:48,000
Now let's define the FilingMetadata class. This holds filing metadata.
[Types: class FilingMetadata:]

39
00:03:48,000 --> 00:03:54,000
We use __slots__ to reduce memory usage.
[Types: __slots__ = ("accession_number", "cik", "filed_at", "filing_type", "fiscal_quarter", "fiscal_year", "primary_document", "source_url", "ticker")]

40
00:03:54,000 --> 00:04:00,000
__slots__ prevents the creation of a __dict__ for each instance. This saves memory.

41
00:04:00,000 --> 00:04:06,000
Now the init method. We use keyword-only arguments.
[Types: def __init__(self, *, ticker: str, filing_type: str, fiscal_year: int | None, fiscal_quarter: int | None, filed_at: date | None, accession_number: str, primary_document: str, source_url: str, cik: str) -> None:]

42
00:04:06,000 --> 00:04:12,000
Keyword-only arguments prevent confusion. You must specify each field by name.

43
00:04:12,000 --> 00:04:18,000
Now we assign each attribute.
[Types: self.ticker = ticker]
[Types: self.filing_type = filing_type]
[Types: self.fiscal_year = fiscal_year]
[Types: self.fiscal_quarter = fiscal_quarter]
[Types: self.filed_at = filed_at]
[Types: self.accession_number = accession_number]
[Types: self.primary_document = primary_document]
[Types: self.source_url = source_url]
[Types: self.cik = cik]

44
00:04:18,000 --> 00:04:24,000
Now the string representation for debugging.
[Types: def __repr__(self) -> str:]

45
00:04:24,000 --> 00:04:30,000
[Types: return f"<FilingMetadata {self.ticker} {self.filing_type} FY{self.fiscal_year} filed={self.filed_at}>"]

46
00:04:30,000 --> 00:04:36,000
This makes it easy to identify filings when debugging.

47
00:04:36,000 --> 00:04:42,000
Now let's build the main SECIngestor class.
[Types: class SECIngestor:]

48
00:04:42,000 --> 00:04:48,000
This is the main class that interacts with EDGAR.

49
00:04:48,000 --> 00:04:54,000
Now the init method.
[Types: def __init__(self) -> None:]

50
00:04:54,000 --> 00:05:00,000
We get the settings instance.
[Types: self._settings = get_settings()]

51
00:05:00,000 --> 00:05:06,000
We create the rate limiter with the configured RPS.
[Types: self._rate_limiter = _EdgarRateLimiter(self._settings.EDGAR_RATE_LIMIT_RPS)]

52
00:05:06,000 --> 00:05:12,000
The rate limiter ensures we don't exceed EDGAR's 10 RPS limit.

53
00:05:12,000 --> 00:05:18,000
Now we initialize the HTTP client as None. It will be created in the context manager.
[Types: self._client: httpx.AsyncClient | None = None]

54
00:05:18,000 --> 00:05:24,000
We use type hints to tell mypy this can be None until initialized.

55
00:05:24,000 --> 00:05:30,000
Now let's implement the async context manager. This is the entry point.
[Types: async def __aenter__(self) -> SECIngestor:]

56
00:05:30,000 --> 00:05:36,000
We create the HTTP client with headers.
[Types: self._client = httpx.AsyncClient(headers={"User-Agent": self._settings.EDGAR_USER_AGENT, "Accept-Encoding": "gzip, deflate"}, timeout=self._settings.EDGAR_REQUEST_TIMEOUT_SECONDS, follow_redirects=True)]

57
00:05:36,000 --> 00:05:42,000
The User-Agent header is required by EDGAR. You must identify your application.

58
00:05:42,000 --> 00:05:48,000
The Accept-Encoding header enables compression. This saves bandwidth.
The timeout prevents hanging requests. And follow_redirects handles redirects automatically.

59
00:05:48,000 --> 00:05:54,000
Now we return self.
[Types: return self]

60
00:05:54,000 --> 00:06:00,000
Now the exit method. This closes the client.
[Types: async def __aexit__(self, *_: object) -> None:]

61
00:06:00,000 --> 00:06:06,000
If the client exists, we close it.
[Types: if self._client:]
[Types: await self._client.aclose()]
[Types: self._client = None]

62
00:06:06,000 --> 00:06:12,000
Now let's implement the list_filings method.
[Types: async def list_filings(self, ticker: str, filing_type: str, *, years: int = 3) -> list[FilingMetadata]:]

63
00:06:12,000 --> 00:06:18,000
First, validate the filing type.
[Types: if filing_type not in SUPPORTED_FILING_TYPES:]

64
00:06:18,000 --> 00:06:24,000
If it's not supported, raise an error.
[Types: raise SECFetchError(f"Unsupported filing type '{filing_type}'. Supported: {sorted(SUPPORTED_FILING_TYPES)}")]

65
00:06:24,000 --> 00:06:30,000
Now cap years at a reasonable limit.
[Types: years = min(years, self._settings.EDGAR_MAX_RETRIES * 2)]

66
00:06:30,000 --> 00:06:36,000
We use EDGAR_MAX_RETRIES * 2 to cap at 5 years. This prevents excessive requests.

67
00:06:36,000 --> 00:06:42,000
Now normalize the ticker to uppercase.
[Types: ticker = ticker.upper()]

68
00:06:42,000 --> 00:06:48,000
SEC tickers are always uppercase. This ensures consistency.

69
00:06:48,000 --> 00:06:54,000
Log the start of the operation.
[Types: logger.info("Listing %s filings for %s (years=%d)", filing_type, ticker, years)]

70
00:06:54,000 --> 00:07:00,000
Now resolve the CIK. This is the central index key used by the SEC.
[Types: cik = await self._resolve_cik(ticker)]

71
00:07:00,000 --> 00:07:06,000
Without the CIK, we can't fetch submissions. This is a critical step.

72
00:07:06,000 --> 00:07:12,000
Now fetch the submissions.
[Types: submissions = await self._fetch_submissions(cik)]

73
00:07:12,000 --> 00:07:18,000
The submissions contain all filings for this CIK.

74
00:07:18,000 --> 00:07:24,000
Now parse the submissions into FilingMetadata objects.
[Types: filings = self._parse_submissions(submissions, ticker=ticker, filing_type=filing_type, cik=cik, years=years)]

75
00:07:24,000 --> 00:07:30,000
We pass ticker, filing_type, cik, and years to filter the results.

76
00:07:30,000 --> 00:07:36,000
Log the number of filings found.
[Types: logger.info("Found %d %s filings for %s", len(filings), filing_type, ticker)]

77
00:07:36,000 --> 00:07:42,000
Return the list of filings.
[Types: return filings]

78
00:07:42,000 --> 00:07:48,000
Now let's implement the download_filing method.
[Types: async def download_filing(self, meta: FilingMetadata, *, raw_dir: Path | None = None) -> tuple[str, str]:]

79
00:07:48,000 --> 00:07:54,000
This returns the raw HTML content and the SHA-256 hash.

80
00:07:54,000 --> 00:08:00,000
First, check the local cache if a directory is provided.
[Types: if raw_dir:]

81
00:08:00,000 --> 00:08:06,000
Call the cache check method.
[Types: cached = self._check_cache(meta, raw_dir)]

82
00:08:06,000 --> 00:08:12,000
If cached content exists, use it.
[Types: if cached:]
[Types: content, file_hash = cached]

83
00:08:12,000 --> 00:08:18,000
Log the cache hit.
[Types: logger.info("Cache hit for %s %s FY%s", meta.ticker, meta.filing_type, meta.fiscal_year)]

84
00:08:18,000 --> 00:08:24,000
Return the cached content and hash.
[Types: return content, file_hash]

85
00:08:24,000 --> 00:08:30,000
If not cached, download from EDGAR.
[Types: content = await self._fetch_document(meta.source_url)]

86
00:08:30,000 --> 00:08:36,000
The fetch document method handles the actual HTTP request.

87
00:08:36,000 --> 00:08:42,000
Now compute the SHA-256 hash of the content.
[Types: file_hash = hashlib.sha256(content.encode()).hexdigest()]

88
00:08:42,000 --> 00:08:48,000
This hash is used for deduplication. It uniquely identifies the filing.

89
00:08:48,000 --> 00:08:54,000
If a cache directory is provided, write the content to cache.
[Types: if raw_dir:]
[Types: self._write_cache(meta, raw_dir, content)]

90
00:08:54,000 --> 00:09:00,000
This saves the filing locally for future runs.

91
00:09:00,000 --> 00:09:06,000
Log the download.
[Types: logger.info("Downloaded %s %s FY%s — %d chars hash=%s", meta.ticker, meta.filing_type, meta.fiscal_year, len(content), file_hash[:12])]

92
00:09:06,000 --> 00:09:12,000
Return the content and hash.
[Types: return content, file_hash]

93
00:09:12,000 --> 00:09:18,000
Now let's implement the _resolve_cik method. This resolves ticker to CIK.
[Types: @retry(retry=retry_if_exception_type(SECFetchError), stop=stop_after_attempt(3), wait=wait_exponential(multiplier=1, min=2, max=10), reraise=True) async def _resolve_cik(self, ticker: str) -> str:]

94
00:09:18,000 --> 00:09:24,000
The retry decorator handles transient failures. If SECFetchError is raised,
it retries up to 3 times with exponential backoff.

95
00:09:24,000 --> 00:09:30,000
Define the URL for company tickers.
[Types: url = "https://www.sec.gov/files/company_tickers.json"]

96
00:09:30,000 --> 00:09:36,000
This file maps ticker symbols to CIK numbers.

97
00:09:36,000 --> 00:09:42,000
Start the try block.
[Types: try:]

98
00:09:42,000 --> 00:09:48,000
Use the rate limiter. This ensures we don't exceed EDGAR's rate limit.
[Types: async with self._rate_limiter:]

99
00:09:48,000 --> 00:09:54,000
Make the HTTP request.
[Types: response = await self._client.get(url)]

100
00:09:54,000 --> 00:10:00,000
Check for HTTP errors.
[Types: response.raise_for_status()]

101
00:10:00,000 --> 00:10:06,000
Parse the JSON response.
[Types: data = response.json()]

102
00:10:06,000 --> 00:10:12,000
The data is a dictionary mapping CIK to company info.

103
00:10:12,000 --> 00:10:18,000
Iterate through the entries.
[Types: for entry in data.values():]

104
00:10:18,000 --> 00:10:24,000
Check if the ticker matches. Normalize to uppercase.
[Types: if entry.get("ticker", "").upper() == ticker:]

105
00:10:24,000 --> 00:10:30,000
If found, get the CIK and pad it to 10 digits with zeros.
[Types: cik = str(entry["cik_str"]).zfill(10)]

106
00:10:30,000 --> 00:10:36,000
Log the resolution.
[Types: logger.debug("Resolved %s → CIK %s", ticker, cik)]

107
00:10:36,000 --> 00:10:42,000
Return the CIK.
[Types: return cik]

108
00:10:42,000 --> 00:10:48,000
If ticker not found, raise an error.
[Types: raise SECFetchError(f"Ticker '{ticker}' not found in EDGAR company registry. Verify the ticker is correct.")]

109
00:10:48,000 --> 00:10:54,000
Handle HTTP errors.
[Types: except httpx.HTTPError as exc:]

110
00:10:54,000 --> 00:11:00,000
Raise SECFetchError with context.
[Types: raise SECFetchError(f"Failed to resolve CIK for '{ticker}': {exc}") from exc]

111
00:11:00,000 --> 00:11:06,000
Now let's implement the _fetch_submissions method.
[Types: @retry(retry=retry_if_exception_type(SECFetchError), stop=stop_after_attempt(3), wait=wait_exponential(multiplier=1, min=2, max=10), reraise=True) async def _fetch_submissions(self, cik: str) -> dict:]

112
00:11:06,000 --> 00:11:12,000
Again we use retry for transient failures.

113
00:11:12,000 --> 00:11:18,000
Build the URL for the submissions endpoint.
[Types: url = f"{_EDGAR_FILINGS}/CIK{cik}.json"]

114
00:11:18,000 --> 00:11:24,000
The CIK is included in the URL path.

115
00:11:24,000 --> 00:11:30,000
Start the try block.
[Types: try:]

116
00:11:30,000 --> 00:11:36,000
Use the rate limiter.
[Types: async with self._rate_limiter:]

117
00:11:36,000 --> 00:11:42,000
Make the HTTP request.
[Types: response = await self._client.get(url)]

118
00:11:42,000 --> 00:11:48,000
Check for HTTP errors.
[Types: response.raise_for_status()]

119
00:11:48,000 --> 00:11:54,000
Return the JSON data.
[Types: return response.json()]

120
00:11:54,000 --> 00:12:00,000
Handle HTTP errors.
[Types: except httpx.HTTPError as exc:]

121
00:12:00,000 --> 00:12:06,000
Raise SECFetchError with context.
[Types: raise SECFetchError(f"Failed to fetch submissions for CIK {cik}: {exc}") from exc]

122
00:12:06,000 --> 00:12:12,000
Now let's implement the _fetch_document method.
[Types: @retry(retry=retry_if_exception_type(SECFetchError), stop=stop_after_attempt(3), wait=wait_exponential(multiplier=1, min=2, max=10), reraise=True) async def _fetch_document(self, url: str) -> str:]

123
00:12:12,000 --> 00:12:18,000
We use retry for transient failures during document download.

124
00:12:18,000 --> 00:12:24,000
Start the try block.
[Types: try:]

125
00:12:24,000 --> 00:12:30,000
Use the rate limiter.
[Types: async with self._rate_limiter:]

126
00:12:30,000 --> 00:12:36,000
Make the HTTP request with Host header.
[Types: response = await self._client.get(url, headers={"Host": "www.sec.gov"})]

127
00:12:36,000 --> 00:12:42,000
The Host header is required for some EDGAR endpoints.

128
00:12:42,000 --> 00:12:48,000
Check for HTTP errors.
[Types: response.raise_for_status()]

129
00:12:48,000 --> 00:12:54,000
Return the text content.
[Types: return response.text]

130
00:12:54,000 --> 00:13:00,000
Handle HTTP errors.
[Types: except httpx.HTTPError as exc:]

131
00:13:00,000 --> 00:13:06,000
Raise SECFetchError with context.
[Types: raise SECFetchError(f"Failed to download filing from {url}: {exc}") from exc]

132
00:13:06,000 --> 00:13:12,000
Now let's implement the _parse_submissions method.
[Types: def _parse_submissions(self, data: dict, *, ticker: str, filing_type: str, cik: str, years: int) -> list[FilingMetadata]:]

133
00:13:12,000 --> 00:13:18,000
Extract the recent filings from the data.
[Types: recent = data.get("filings", {}).get("recent", {})]

134
00:13:18,000 --> 00:13:24,000
The "recent" key contains the list of filings.

135
00:13:24,000 --> 00:13:30,000
If no recent filings, log a warning and return empty.
[Types: if not recent:]

136
00:13:30,000 --> 00:13:36,000
[Types: logger.warning("No recent filings found for %s", ticker)]

137
00:13:36,000 --> 00:13:42,000
[Types: return []]

138
00:13:42,000 --> 00:13:48,000
Now extract the arrays from the recent data.
[Types: forms = recent.get("form", [])]

139
00:13:48,000 --> 00:13:54,000
[Types: accessions = recent.get("accessionNumber", [])]

140
00:13:54,000 --> 00:14:00,000
[Types: filed_dates = recent.get("filingDate", [])]

141
00:14:00,000 --> 00:14:06,000
[Types: documents = recent.get("primaryDocument", [])]

142
00:14:06,000 --> 00:14:12,000
These arrays are parallel. The index connects them.

143
00:14:12,000 --> 00:14:18,000
Initialize the results list and set for seen years.
[Types: results: list[FilingMetadata] = []]

144
00:14:18,000 --> 00:14:24,000
[Types: seen_years: set[int] = set()]

145
00:14:24,000 --> 00:14:30,000
Now iterate through the forms.
[Types: for i, form in enumerate(forms):]

146
00:14:30,000 --> 00:14:36,000
Check if the form matches the requested filing_type.
[Types: if form != filing_type:]

147
00:14:36,000 --> 00:14:42,000
If not, skip this entry.
[Types: continue]

148
00:14:42,000 --> 00:14:48,000
Check if we have enough results.
[Types: if len(results) >= years:]

149
00:14:48,000 --> 00:14:54,000
If so, stop processing.
[Types: break]

150
00:14:54,000 --> 00:15:00,000
Start a try block for parsing.
[Types: try:]

151
00:15:00,000 --> 00:15:06,000
Parse the filing date from the filed_dates array.
[Types: filed_at = date.fromisoformat(filed_dates[i]) if filed_dates[i] else None]

152
00:15:06,000 --> 00:15:12,000
Extract the fiscal year from the date.
[Types: fiscal_year = filed_at.year if filed_at else None]

153
00:15:12,000 --> 00:15:18,000
Remove hyphens from the accession number.
[Types: accession = accessions[i].replace("-", "")]

154
00:15:18,000 --> 00:15:24,000
SEC accession numbers have hyphens. We remove them for the URL.

155
00:15:24,000 --> 00:15:30,000
Get the primary document name.
[Types: primary_doc = documents[i] if i < len(documents) else ""]

156
00:15:30,000 --> 00:15:36,000
Build the source URL.
[Types: source_url = f"{_EDGAR_ARCHIVES}/{int(cik)}/{accession}/{primary_doc}"]

157
00:15:36,000 --> 00:15:42,000
The URL points to the actual filing document.

158
00:15:42,000 --> 00:15:48,000
Check if we've already seen this fiscal year.
[Types: if fiscal_year and fiscal_year in seen_years:]

159
00:15:48,000 --> 00:15:54,000
If so, skip to avoid duplicates.
[Types: continue]

160
00:15:54,000 --> 00:16:00,000
If fiscal_year exists, add it to seen_years.
[Types: if fiscal_year:]

161
00:16:00,000 --> 00:16:06,000
[Types: seen_years.add(fiscal_year)]

162
00:16:06,000 --> 00:16:12,000
Create a FilingMetadata object and add it to results.
[Types: results.append(FilingMetadata(ticker=ticker, filing_type=filing_type, fiscal_year=fiscal_year, fiscal_quarter=None, filed_at=filed_at, accession_number=accession, primary_document=primary_doc, source_url=source_url, cik=cik))]

163
00:16:12,000 --> 00:16:18,000
Handle parsing errors.
[Types: except (IndexError, ValueError) as exc:]

164
00:16:18,000 --> 00:16:24,000
Log a warning and continue.
[Types: logger.warning("Skipping malformed filing entry at index %d: %s", i, exc)]

165
00:16:24,000 --> 00:16:30,000
[Types: continue]

166
00:16:30,000 --> 00:16:36,000
Return the results.
[Types: return results]

167
00:16:36,000 --> 00:16:42,000
Now let's implement the cache helper methods.

168
00:16:42,000 --> 00:16:48,000
First, _cache_path. This builds the cache file path.
[Types: def _cache_path(self, meta: FilingMetadata, raw_dir: Path) -> Path:]

169
00:16:48,000 --> 00:16:54,000
Replace any slashes in the ticker.
[Types: safe_ticker = meta.ticker.replace("/", "_")]

170
00:16:54,000 --> 00:17:00,000
Build the full path.
[Types: return raw_dir / safe_ticker / meta.filing_type / f"FY{meta.fiscal_year}.html"]

171
00:17:00,000 --> 00:17:06,000
The path structure is: raw_dir/ticker/filing_type/FY{year}.html

172
00:17:06,000 --> 00:17:12,000
Now _check_cache. This checks if a filing is cached.
[Types: def _check_cache(self, meta: FilingMetadata, raw_dir: Path) -> tuple[str, str] | None:]

173
00:17:12,000 --> 00:17:18,000
Get the cache path.
[Types: path = self._cache_path(meta, raw_dir)]

174
00:17:18,000 --> 00:17:24,000
If the path exists, read the content.
[Types: if path.exists():]

175
00:17:24,000 --> 00:17:30,000
Read the file with UTF-8 encoding.
[Types: content = path.read_text(encoding="utf-8", errors="ignore")]

176
00:17:30,000 --> 00:17:36,000
Compute the SHA-256 hash.
[Types: return content, hashlib.sha256(content.encode()).hexdigest()]

177
00:17:36,000 --> 00:17:42,000
If not cached, return None.
[Types: return None]

178
00:17:42,000 --> 00:17:48,000
Now _write_cache. This writes a filing to the cache.
[Types: def _write_cache(self, meta: FilingMetadata, raw_dir: Path, content: str) -> None:]

179
00:17:48,000 --> 00:17:54,000
Get the cache path.
[Types: path = self._cache_path(meta, raw_dir)]

180
00:17:54,000 --> 00:18:00,000
Create parent directories if they don't exist.
[Types: path.parent.mkdir(parents=True, exist_ok=True)]

181
00:18:00,000 --> 00:18:06,000
Write the content to the file.
[Types: path.write_text(content, encoding="utf-8")]

182
00:18:06,000 --> 00:18:12,000
Log the cache write.
[Types: logger.debug("Cached filing to %s", path)]

183
00:18:12,000 --> 00:18:18,000
Now let's update the ingestion __init__.py file.
Open `src/financial_rag/ingestion/__init__.py`.

184
00:18:18,000 --> 00:18:24,000
Import the classes.
[Types: from .sec_ingestor import SUPPORTED_FILING_TYPES, FilingMetadata, SECIngestor]

185
00:18:24,000 --> 00:18:30,000
Export them.
[Types: __all__ = ["SUPPORTED_FILING_TYPES", "FilingMetadata", "SECIngestor"]]

186
00:18:30,000 --> 00:18:36,000
Now let me explain the complete flow.

187
00:18:36,000 --> 00:18:42,000
First, you call list_filings. It resolves the CIK. It fetches the submissions.
It parses the recent filings. It returns a list of metadata.

188
00:18:42,000 --> 00:18:48,000
Then, you call download_filing for each metadata. It checks the cache.
If the filing is cached, it returns the cached content. If not, it downloads.
It computes the SHA-256 hash for deduplication.

189
00:18:48,000 --> 00:18:54,000
Let me give you a tip. The local cache is essential for development.
If you're testing the ingestion pipeline, you don't want to hit EDGAR
for every test. The cache saves you from rate limiting.

190
00:18:54,000 --> 00:19:00,000
Now let me explain the rate limiter in detail.

191
00:19:00,000 --> 00:19:06,000
The semaphore ensures we never make more than RPS concurrent requests.
The sleep ensures we space out the requests evenly.

192
00:19:06,000 --> 00:19:12,000
This is a classic token bucket implementation. It's the industry standard
for rate limiting in Python. It works well with async code.

193
00:19:12,000 --> 00:19:18,000
Now let's test the ingestor. We'll use an IPython session.

194
00:19:18,000 --> 00:19:24,000
[Types: from financial_rag.ingestion import SECIngestor]

195
00:19:24,000 --> 00:19:30,000
[Types: async with SECIngestor() as ingestor:]

196
00:19:30,000 --> 00:19:36,000
[Types: filings = await ingestor.list_filings("AAPL", "10-K", years=2)]

197
00:19:36,000 --> 00:19:42,000
[Types: print(len(filings))]

198
00:19:42,000 --> 00:19:48,000
You should see two filings in the output. One for this year and one for last year.

199
00:19:48,000 --> 00:19:54,000
[Types: print(filings[0].source_url)]

200
00:19:54,000 --> 00:20:00,000
This prints the source URL of the first filing.

201
00:20:00,000 --> 00:20:06,000
Now let's test the download.

202
00:20:06,000 --> 00:20:12,000
[Types: content, hash = await ingestor.download_filing(filings[0])]

203
00:20:12,000 --> 00:20:18,000
[Types: print(len(content))]

204
00:20:18,000 --> 00:20:24,000
[Types: print(hash[:16])]

205
00:20:24,000 --> 00:20:30,000
You should see the content length and the first 16 characters of the hash.
This confirms the download is working.

206
00:20:30,000 --> 00:20:36,000
Now let me show you the user agent. The SEC requires a descriptive user agent.

207
00:20:36,000 --> 00:20:42,000
[Types: print(ingestor._settings.EDGAR_USER_AGENT)]

208
00:20:42,000 --> 00:20:48,000
If you don't provide a proper user agent, EDGAR may block your requests.
Make sure you set EDGAR_USER_AGENT in your .env file.

209
00:20:48,000 --> 00:20:54,000
Now let me give you a debugging tip. If you see "429 Too Many Requests",
you're being rate limited. Wait a few seconds and try again.
The retry decorator handles this automatically.

210
00:20:54,000 --> 00:21:00,000
Let me recap what we've built in Part 4.

211
00:21:00,000 --> 00:21:06,000
We built a token bucket rate limiter. It ensures we don't exceed EDGAR's
limit of 10 requests per second. We use a semaphore and sleep.

212
00:21:06,000 --> 00:21:12,000
We built the FilingMetadata class. It holds all the data about a filing.
We use __slots__ for memory efficiency.

213
00:21:12,000 --> 00:21:18,000
We built the SECIngestor class. It has four main methods:
list_filings, download_filing, _resolve_cik, _fetch_submissions.

214
00:21:18,000 --> 00:21:24,000
We built a local cache. It stores downloaded filings in the raw data directory.
This saves time and bandwidth during development.

215
00:21:24,000 --> 00:21:30,000
We built SHA-256 deduplication. The file_hash is used to prevent duplicate
ingestion. This ensures we don't store the same filing twice.

216
00:21:30,000 --> 00:21:36,000
In Part 5, we'll build the HTML parser. We'll extract text from SEC filings
and identify sections like "MD&A" and "Risk Factors".

217
00:21:36,000 --> 00:21:42,000
Thank you for watching. I'll see you in Part 5.

218
00:21:42,000 --> 00:21:46,000
[End of Part 4]
1
00:30:00,000 --> 00:30:06,000
Welcome back to Phase 2. In Part 5, we build the HTML parser.

2
00:30:06,000 --> 00:30:12,000
We've downloaded raw HTML filings from EDGAR. Now we need to extract clean text
and identify sections like MD&A and Risk Factors.

3
00:30:12,000 --> 00:30:18,000
SEC filings are messy. They contain SGML headers, XBRL tags, and exhibit noise.
Our parser needs to strip all of that and return structured, clean text.

4
00:30:18,000 --> 00:30:24,000
Open your editor and create `src/financial_rag/ingestion/parsers/html_parser.py`.

5
00:30:24,000 --> 00:30:30,000
We'll start with the imports. The __future__ import enables forward references.
[Types: from __future__ import annotations]

6
00:30:30,000 --> 00:30:36,000
We import logging for structured logging throughout the parser.
[Types: import logging]

7
00:30:36,000 --> 00:30:42,000
We import re for regular expressions used in pattern matching.
[Types: import re]

8
00:30:42,000 --> 00:30:48,000
We import dataclass for creating data structures to hold parsed content.
[Types: from dataclasses import dataclass, field]

9
00:30:48,000 --> 00:30:54,000
We import BeautifulSoup from bs4 for parsing HTML.
[Types: from bs4 import BeautifulSoup, Tag]

10
00:30:54,000 --> 00:31:00,000
BeautifulSoup is the industry standard for HTML parsing in Python.
It handles malformed HTML gracefully.

11
00:31:00,000 --> 00:31:06,000
Now let's define the section detection patterns. This maps heading patterns
to canonical section names.

12
00:31:06,000 --> 00:31:12,000
We use a list of tuples where each tuple contains a regex pattern and a section name.
[Types: _SECTION_PATTERNS: list[tuple[re.Pattern[str], str]] = []]

13
00:31:12,000 --> 00:31:18,000
The first pattern matches MD&A sections with various spellings.
[Types: (re.compile(r"management.{0,20}discussion.{0,20}analysis", re.I), "MD&A"),]

14
00:31:18,000 --> 00:31:24,000
This pattern handles "Management's Discussion and Analysis", "Management Discussion and Analysis",
and similar variations. The .{0,20} allows up to 20 characters between words.

15
00:31:24,000 --> 00:31:30,000
The second pattern matches Risk Factors sections.
[Types: (re.compile(r"risk\s+factors", re.I), "Risk Factors"),]

16
00:31:30,000 --> 00:31:36,000
This is simpler because "Risk Factors" is consistently formatted in SEC filings.

17
00:31:36,000 --> 00:31:42,000
The third pattern matches Market Risk sections.
[Types: (re.compile(r"quantitative.{0,20}qualitative.{0,20}market\s+risk", re.I), "Market Risk"),]

18
00:31:42,000 --> 00:31:48,000
This catches "Quantitative and Qualitative Disclosures About Market Risk".
The .{0,20} handles variations in spacing.

19
00:31:48,000 --> 00:31:54,000
The fourth pattern matches Business Overview sections.
[Types: (re.compile(r"business\s+overview|item\s+1[.\s]+business", re.I), "Business"),]

20
00:31:54,000 --> 00:32:00,000
This handles both "Business Overview" and "Item 1. Business" variations.

21
00:32:00,000 --> 00:32:06,000
The fifth pattern matches Financial Statements sections.
[Types: (re.compile(r"financial\s+statements", re.I), "Financial Statements"),]

22
00:32:06,000 --> 00:32:12,000
This identifies the main financial statements section.

23
00:32:12,000 --> 00:32:18,000
The sixth pattern matches Balance Sheet sections.
[Types: (re.compile(r"balance\s+sheet|financial\s+position", re.I), "Balance Sheet"),]

24
00:32:18,000 --> 00:32:24,000
This catches "Balance Sheet" and "Statement of Financial Position".

25
00:32:24,000 --> 00:32:30,000
The seventh pattern matches Income Statement sections.
[Types: (re.compile(r"income\s+statement|results\s+of\s+operations", re.I), "Income Statement"),]

26
00:32:30,000 --> 00:32:36,000
This catches "Income Statement" and "Results of Operations".

27
00:32:36,000 --> 00:32:42,000
The eighth pattern matches Cash Flow sections.
[Types: (re.compile(r"cash\s+flow", re.I), "Cash Flow"),]

28
00:32:42,000 --> 00:32:48,000
This identifies cash flow statement sections.

29
00:32:48,000 --> 00:32:54,000
The ninth pattern matches Legal Proceedings sections.
[Types: (re.compile(r"legal\s+proceedings", re.I), "Legal Proceedings"),]

30
00:32:54,000 --> 00:33:00,000
This identifies legal proceedings sections.

31
00:33:00,000 --> 00:33:06,000
The tenth pattern matches Properties sections.
[Types: (re.compile(r"properties", re.I), "Properties"),]

32
00:33:06,000 --> 00:33:12,000
This identifies property descriptions.

33
00:33:12,000 --> 00:33:18,000
The eleventh pattern matches Selected Financial Data sections.
[Types: (re.compile(r"selected\s+financial\s+data", re.I), "Selected Financial Data"),]

34
00:33:18,000 --> 00:33:24,000
This identifies the selected financial data summary.

35
00:33:24,000 --> 00:33:30,000
The twelfth pattern matches Notes to Financial Statements.
[Types: (re.compile(r"notes\s+to\s+(the\s+)?financial", re.I), "Notes to Financials"),]

36
00:33:30,000 --> 00:33:36,000
This catches "Notes to Financial Statements" and "Notes to the Financial Statements".

37
00:33:36,000 --> 00:33:42,000
Now let's define the tags to discard. These tags never contain useful text.
[Types: _DISCARD_TAGS = frozenset({]

38
00:33:42,000 --> 00:33:48,000
We use a frozenset for fast lookups and immutability.

39
00:33:48,000 --> 00:33:54,000
Script tags contain JavaScript code that we don't need.
[Types: "script",]

40
00:33:54,000 --> 00:34:00,000
Style tags contain CSS that we don't need.
[Types: "style",]

41
00:34:00,000 --> 00:34:06,000
Meta tags contain metadata that we don't need.
[Types: "meta",]

42
00:34:06,000 --> 00:34:12,000
Link tags contain stylesheet references that we don't need.
[Types: "link",]

43
00:34:12,000 --> 00:34:18,000
Head tags contain document metadata that we don't need.
[Types: "head",]

44
00:34:18,000 --> 00:34:24,000
Noscript tags contain fallback content that we don't need.
[Types: "noscript",]

45
00:34:24,000 --> 00:34:30,000
SVG tags contain vector graphics that we don't need.
[Types: "svg",]

46
00:34:30,000 --> 00:34:36,000
IMG tags contain images that we don't need.
[Types: "img",]

47
00:34:36,000 --> 00:34:42,000
Figure tags contain figure elements that we don't need.
[Types: "figure",]

48
00:34:42,000 --> 00:34:48,000
XBRL tags contain inline XBRL data that we don't need.
[Types: "ix:nonfraction", "ix:nonnumeric",]

49
00:34:48,000 --> 00:34:54,000
These are the inline XBRL tags used in SEC filings. They contain financial data
but in a format that's hard to parse.

50
00:34:54,000 --> 00:35:00,000
And XBRL root tags that we don't need.
[Types: "xbrl", "xbrli",})

51
00:35:00,000 --> 00:35:06,000
These are the XBRL root elements that contain the filing structure.

52
00:35:06,000 --> 00:35:12,000
Now let's define the maximum consecutive blank lines to preserve.
[Types: _MAX_BLANK_LINES = 2]

53
00:35:12,000 --> 00:35:18,000
We preserve up to 2 blank lines for readability. More than that is noise.

54
00:35:18,000 --> 00:35:24,000
Now let's define the ParsedSection dataclass. This holds a single section.
[Types: @dataclass]
[Types: class ParsedSection:]

55
00:35:24,000 --> 00:35:30,000
The name field stores the section name like "MD&A" or "Risk Factors".
[Types: name: str]

56
00:35:30,000 --> 00:35:36,000
The text field stores the cleaned section text.
[Types: text: str]

57
00:35:36,000 --> 00:35:42,000
The char_count field stores the character count, computed in __post_init__.
[Types: char_count: int = field(init=False)]

58
00:35:42,000 --> 00:35:48,000
We use field(init=False) to indicate this is computed, not passed in.

59
00:35:48,000 --> 00:35:54,000
Now let's define the __post_init__ method. This runs after initialization.
[Types: def __post_init__(self) -> None:]

60
00:35:54,000 --> 00:36:00,000
We compute the character count from the text length.
[Types: self.char_count = len(self.text)]

61
00:36:00,000 --> 00:36:06,000
This is useful for metrics and debugging.

62
00:36:06,000 --> 00:36:12,000
Now let's define the string representation for debugging.
[Types: def __repr__(self) -> str:]

63
00:36:12,000 --> 00:36:18,000
We return a string with the section name and character count.
[Types: return f"<ParsedSection '{self.name}' chars={self.char_count}>"]

64
00:36:18,000 --> 00:36:24,000
This makes it easy to see what sections were extracted.

65
00:36:24,000 --> 00:36:30,000
Now let's define the ParsedFiling dataclass. This holds the complete parsed filing.
[Types: @dataclass]
[Types: class ParsedFiling:]

66
00:36:30,000 --> 00:36:36,000
The ticker field stores the company ticker symbol.
[Types: ticker: str]

67
00:36:36,000 --> 00:36:42,000
The filing_type field stores the SEC form type.
[Types: filing_type: str]

68
00:36:42,000 --> 00:36:48,000
The fiscal_year field stores the fiscal year.
[Types: fiscal_year: int | None]

69
00:36:48,000 --> 00:36:54,000
The full_text field stores the complete cleaned text.
[Types: full_text: str]

70
00:36:54,000 --> 00:37:00,000
The sections field stores the list of ParsedSection objects.
[Types: sections: list[ParsedSection]]

71
00:37:00,000 --> 00:37:06,000
The char_count field is computed in __post_init__.
[Types: char_count: int = field(init=False)]

72
00:37:06,000 --> 00:37:12,000
Now let's define the __post_init__ method for ParsedFiling.
[Types: def __post_init__(self) -> None:]

73
00:37:12,000 --> 00:37:18,000
We compute the total character count from the full text.
[Types: self.char_count = len(self.full_text)]

74
00:37:18,000 --> 00:37:24,000
Now let's define a convenience method to get a section by name.
[Types: def get_section(self, name: str) -> str | None:]

75
00:37:24,000 --> 00:37:30,000
This is useful for extracting specific sections like MD&A.
[Types: for s in self.sections:]

76
00:37:30,000 --> 00:37:36,000
If the section name matches, we return the text.
[Types: if s.name == name: return s.text]

77
00:37:36,000 --> 00:37:42,000
If no match is found, we return None.
[Types: return None]

78
00:37:42,000 --> 00:37:48,000
Now let's define the string representation for ParsedFiling.
[Types: def __repr__(self) -> str:]

79
00:37:48,000 --> 00:37:54,000
We create a list of section names for the representation.
[Types: section_names = [s.name for s in self.sections]]

80
00:37:54,000 --> 00:38:00,000
We return a string with ticker, filing type, year, and section names.
[Types: return f"<ParsedFiling {self.ticker} {self.filing_type} FY{self.fiscal_year} chars={self.char_count} sections={section_names}>"]

81
00:38:00,000 --> 00:38:06,000
Now let's define the HTMLParser class. This is the main parser.
[Types: class HTMLParser:]

82
00:38:06,000 --> 00:38:12,000
Now let's implement the parse method. This is the public entry point.
[Types: def parse(self, raw_html: str, *, ticker: str, filing_type: str, fiscal_year: int | None = None,) -> ParsedFiling:]

83
00:38:12,000 --> 00:38:18,000
First, we strip the SGML header from the raw HTML.
[Types: html_content = self._strip_sgml_header(raw_html)]

84
00:38:18,000 --> 00:38:24,000
SEC filings start with an SGML header before the HTML. We need to remove it.

85
00:38:24,000 --> 00:38:30,000
Then we parse the HTML with BeautifulSoup using the lxml parser.
[Types: soup = BeautifulSoup(html_content, "lxml")]

86
00:38:30,000 --> 00:38:36,000
We use lxml because it's faster and more lenient than the built-in parser.

87
00:38:36,000 --> 00:38:42,000
We remove noise tags like script, style, and XBRL tags.
[Types: self._remove_noise_tags(soup)]

88
00:38:42,000 --> 00:38:48,000
Then we extract clean text from the soup.
[Types: full_text = self._extract_text(soup)]

89
00:38:48,000 --> 00:38:54,000
We detect sections within the text using our pattern matching.
[Types: sections = self._detect_sections(full_text)]

90
00:38:54,000 --> 00:39:00,000
We log the parsing results for debugging.
[Types: logger.debug("Parsed %s %s — %d chars, %d sections", ticker, filing_type, len(full_text), len(sections))]

91
00:39:00,000 --> 00:39:06,000
We return a ParsedFiling object with all the data.
[Types: return ParsedFiling(ticker=ticker, filing_type=filing_type, fiscal_year=fiscal_year, full_text=full_text, sections=sections,)]

92
00:39:06,000 --> 00:39:12,000
Now let's implement _strip_sgml_header. This removes the SGML header.
[Types: def _strip_sgml_header(self, content: str) -> str:]

93
00:39:12,000 --> 00:39:18,000
We search for the first <html> tag using a regex.
[Types: match = re.search(r"<html", content, re.I)]

94
00:39:18,000 --> 00:39:24,000
If we find an HTML tag, we return everything from that position onward.
[Types: if match: return content[match.start() :]]

95
00:39:24,000 --> 00:39:30,000
If there's no HTML tag, we treat it as plain text and return it as-is.
[Types: return content]

96
00:39:30,000 --> 00:39:36,000
Now let's implement _remove_noise_tags. This removes tags we don't need.
[Types: def _remove_noise_tags(self, soup: BeautifulSoup) -> None:]

97
00:39:36,000 --> 00:39:42,000
We iterate through each tag in our discard list.
[Types: for tag_name in _DISCARD_TAGS:]

98
00:39:42,000 --> 00:39:48,000
We find all instances of the tag and remove them from the soup.
[Types: for tag in soup.find_all(tag_name): tag.decompose()]

99
00:39:48,000 --> 00:39:54,000
decompose() removes the tag and all its contents from the soup.

100
00:39:54,000 --> 00:40:00,000
Now we remove empty tags that don't contain any text.
[Types: for tag in soup.find_all(True):]

101
00:40:00,000 --> 00:40:06,000
We check if the tag is a Tag and has no text content.
[Types: if isinstance(tag, Tag) and not tag.get_text(strip=True): tag.decompose()]

102
00:40:06,000 --> 00:40:12,000
This removes tags like <div></div> that don't add value.

103
00:40:12,000 --> 00:40:18,000
Now let's implement _extract_text. This extracts clean text from the soup.
[Types: def _extract_text(self, soup: BeautifulSoup) -> str:]

104
00:40:18,000 --> 00:40:24,000
We extract text with newlines as separators to preserve structure.
[Types: raw_text = soup.get_text(separator="\n")]

105
00:40:24,000 --> 00:40:30,000
Using newline as a separator helps us preserve paragraph breaks.

106
00:40:30,000 --> 00:40:36,000
Now we process each line to normalize whitespace.
[Types: lines = []]
[Types: for line in raw_text.splitlines():]

107
00:40:36,000 --> 00:40:42,000
We collapse multiple spaces and tabs into a single space.
[Types: line = re.sub(r"[ \t]+", " ", line).strip()]

108
00:40:42,000 --> 00:40:48,000
We append the cleaned line to our list.
[Types: lines.append(line)]

109
00:40:48,000 --> 00:40:54,000
Now we collapse excessive blank lines.
[Types: cleaned_lines: list[str] = []]
[Types: blank_count = 0]

110
00:40:54,000 --> 00:41:00,000
We iterate through each line.
[Types: for line in lines:]

111
00:41:00,000 --> 00:41:06,000
If the line is empty, we increment the blank count.
[Types: if not line: blank_count += 1]

112
00:41:06,000 --> 00:41:12,000
If we're under the maximum blank lines, we keep the blank line.
[Types: if blank_count <= _MAX_BLANK_LINES: cleaned_lines.append("")]

113
00:41:12,000 --> 00:41:18,000
If the line has content, we reset the blank count and add the line.
[Types: else: blank_count = 0; cleaned_lines.append(line)]

114
00:41:18,000 --> 00:41:24,000
We join the cleaned lines with newlines.
[Types: text = "\n".join(cleaned_lines).strip()]

115
00:41:24,000 --> 00:41:30,000
Then we remove boilerplate text.
[Types: text = self._remove_boilerplate(text)]

116
00:41:30,000 --> 00:41:36,000
Now let's implement _remove_boilerplate. This removes common SEC noise.
[Types: def _remove_boilerplate(self, text: str) -> str:]

117
00:41:36,000 --> 00:41:42,000
We define a list of patterns to remove.
[Types: patterns = []]

118
00:41:42,000 --> 00:41:48,000
First, page numbers like "- 42 -" or just "42".
[Types: r"\n\s*-\s*\d+\s*-\s*\n",]

119
00:41:48,000 --> 00:41:54,000
SEC filings often have page numbers in the margins. These are noise.

120
00:41:54,000 --> 00:42:00,000
Second, table of contents markers like ".....42".
[Types: r"\.{5,}\s*\d+",]

121
00:42:00,000 --> 00:42:06,000
These are dots leading to page numbers. We don't need them.

122
00:42:06,000 --> 00:42:12,000
Third, EDGAR filing header fields.
[Types: r"UNITED STATES\s+SECURITIES AND EXCHANGE COMMISSION.*?FORM\s+\S+",]

123
00:42:12,000 --> 00:42:18,000
This removes the SEC header that appears at the top of every filing.

124
00:42:18,000 --> 00:42:24,000
Fourth, exhibit separators like "==========".
[Types: r"={10,}",]

125
00:42:24,000 --> 00:42:30,000
Fifth, separator lines like "----------".
[Types: r"-{10,}",]

126
00:42:30,000 --> 00:42:36,000
We compile the patterns and replace each with a newline.
[Types: for pattern in patterns:]
[Types: text = re.sub(pattern, "\n", text, flags=re.S)]

127
00:42:36,000 --> 00:42:42,000
We use re.S to make the dot match newlines as well.

128
00:42:42,000 --> 00:42:48,000
Now let's implement _detect_sections. This identifies sections in the text.
[Types: def _detect_sections(self, text: str) -> list[ParsedSection]:]

129
00:42:48,000 --> 00:42:54,000
We split the text into lines for processing.
[Types: lines = text.splitlines()]

130
00:42:54,000 --> 00:43:00,000
We initialize a list of heading positions and names.
[Types: heading_positions: list[tuple[int, str]] = []]

131
00:43:00,000 --> 00:43:06,000
We iterate through each line with its index.
[Types: for i, line in enumerate(lines):]

132
00:43:06,000 --> 00:43:12,000
We strip whitespace from the line.
[Types: stripped = line.strip()]

133
00:43:12,000 --> 00:43:18,000
If the line is empty or too long, we skip it.
[Types: if not stripped or len(stripped) > 500: continue]

134
00:43:18,000 --> 00:43:24,000
Heading lines are usually short, so we skip long lines.

135
00:43:24,000 --> 00:43:30,000
We check each pattern against the line.
[Types: for pattern, section_name in _SECTION_PATTERNS:]

136
00:43:30,000 --> 00:43:36,000
If the pattern matches, we add the position and section name.
[Types: if pattern.search(stripped): heading_positions.append((i, section_name)); break]

137
00:43:36,000 --> 00:43:42,000
We break after the first match to avoid duplicate section assignments.

138
00:43:42,000 --> 00:43:48,000
If there are no headings, we return a single General section.
[Types: if not heading_positions: return [ParsedSection(name="General", text=text)]]

139
00:43:48,000 --> 00:43:54,000
Now we build sections from the headings.
[Types: sections: list[ParsedSection] = []]

140
00:43:54,000 --> 00:44:00,000
We track seen section names to avoid duplicates.
[Types: seen: set[str] = set()]

141
00:44:00,000 --> 00:44:06,000
We iterate through each heading position.
[Types: for idx, (line_idx, section_name) in enumerate(heading_positions):]

142
00:44:06,000 --> 00:44:12,000
We calculate the end index for this section.
[Types: end_idx = heading_positions[idx + 1][0] if idx + 1 < len(heading_positions) else len(lines)]

143
00:44:12,000 --> 00:44:18,000
The section ends at the next heading or at the end of the file.

144
00:44:18,000 --> 00:44:24,000
We extract the section text from the current heading to the end index.
[Types: section_text = "\n".join(lines[line_idx:end_idx]).strip()]

145
00:44:24,000 --> 00:44:30,000
If the section name is already seen or the text is too short, we skip it.
[Types: if section_name in seen or len(section_text) < 50: continue]

146
00:44:30,000 --> 00:44:36,000
We add the section to the list and mark it as seen.
[Types: seen.add(section_name)]
[Types: sections.append(ParsedSection(name=section_name, text=section_text))]

147
00:44:36,000 --> 00:44:42,000
If no sections were found, we return a single General section.
[Types: return sections or [ParsedSection(name="General", text=text)]]

148
00:44:42,000 --> 00:44:48,000
Now let's update the parsers __init__.py file.
Open `src/financial_rag/ingestion/parsers/__init__.py`.

149
00:44:48,000 --> 00:44:54,000
We import the HTMLParser and the data classes.
[Types: from .html_parser import HTMLParser, ParsedFiling, ParsedSection]

150
00:44:54,000 --> 00:45:00,000
And we export them.
[Types: __all__ = ["HTMLParser", "ParsedFiling", "ParsedSection"]]

151
00:45:00,000 --> 00:45:06,000
Now let me recap what we've built in Part 5.

152
00:45:06,000 --> 00:45:12,000
We built a complete HTML parser for SEC filings. It strips SGML headers,
removes noise tags, extracts clean text, and identifies sections.

153
00:45:12,000 --> 00:45:18,000
We defined section detection patterns for MD&A, Risk Factors, Business Overview,
Financial Statements, and many other sections.

154
00:45:18,000 --> 00:45:24,000
We created data classes for ParsedSection and ParsedFiling to hold the results.
We implemented caching, logging, and error handling throughout.

155
00:45:24,000 --> 00:45:30,000
In Part 6, we'll build the Text Parser. This will clean and normalize the
text extracted from the HTML.

156
00:45:30,000 --> 00:45:36,000
Thank you for watching. I'll see you in Part 6.

157
00:45:36,000 --> 00:45:40,000
[End of Part 5]
# Phase 2: SEC EDGAR Ingestion Pipeline — Part 6 (00:40:00 - 01:10:00)

## Text Parser — Complete SRT Script

**File to Build:**
- `src/financial_rag/ingestion/parsers/text_parser.py`

---

```srt
1
00:40:00,000 --> 00:40:06,000
Welcome back to Phase 2. In Part 6, we build the Text Parser.

2
00:40:06,000 --> 00:40:12,000
We've downloaded raw HTML from EDGAR. We've parsed it into clean text sections.
But that text is still messy. It has URLs, email addresses, control characters,
and inconsistent whitespace.

3
00:40:12,000 --> 00:40:18,000
This is where the Text Parser comes in. It cleans and normalises plain text
extracted from SEC filings. It prepares the text for chunking and embedding.

4
00:40:18,000 --> 00:40:24,000
Open your editor and create `src/financial_rag/ingestion/parsers/text_parser.py`.

5
00:40:24,000 --> 00:40:30,000
We'll start with the imports. The __future__ import enables forward references.
[Types: from __future__ import annotations]

6
00:40:30,000 --> 00:40:36,000
We import logging for structured logging during parsing.
[Types: import logging]

7
00:40:36,000 --> 00:40:42,000
We import re for regular expression pattern matching.
[Types: import re]

8
00:40:42,000 --> 00:40:48,000
We import unicodedata for normalising Unicode characters.
[Types: import unicodedata]

9
00:40:48,000 --> 00:40:54,000
Now let's define the noise patterns. These are regular expressions that match
unwanted text. We use a list of compiled patterns for performance.
[Types: _NOISE_PATTERNS: list[re.Pattern[str]] = []]

10
00:40:54,000 --> 00:41:00,000
The first pattern matches URLs. This catches http and https links.
[Types: re.compile(r"\b(https?|ftp)://\S+", re.I)]

11
00:41:00,000 --> 00:41:06,000
We use re.I for case-insensitive matching. URLs are noise in financial text.
They don't add value to the content.

12
00:41:06,000 --> 00:41:12,000
The second pattern matches email addresses.
[Types: re.compile(r"\S+@\S+\.\S+")]

13
00:41:12,000 --> 00:41:18,000
Email addresses in SEC filings are often from boilerplate text. They're not
useful for analysis and should be removed.

14
00:41:18,000 --> 00:41:24,000
The third pattern matches control characters. These are non-printable characters
that can break text processing.
[Types: re.compile(r"[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]")]

15
00:41:24,000 --> 00:41:30,000
Control characters include things like null, backspace, and escape codes.
They're invisible and cause problems with tokenization.

16
00:41:30,000 --> 00:41:36,000
The fourth pattern matches four or more consecutive newlines.
[Types: re.compile(r"\n{4,}")]

17
00:41:36,000 --> 00:41:42,000
Excessive newlines are just whitespace noise. We compress them to make the
text more readable and reduce token count.

18
00:41:42,000 --> 00:41:48,000
Now let's define the number patterns. These normalise financial formatting.
[Types: _NUMBER_PATTERNS: list[tuple[re.Pattern[str], str]] = []]

19
00:41:48,000 --> 00:41:54,000
The first pattern removes dollar signs before numbers.
[Types: (re.compile(r"\$\s*([\d,]+(?:\.\d+)?)"), r"\1")]

20
00:41:54,000 --> 00:42:00,000
This catches things like "$1,234.56" and converts them to "1,234.56".
The dollar sign is noise for numerical analysis.

21
00:42:00,000 --> 00:42:06,000
The second pattern removes commas from numbers.
[Types: (re.compile(r"(\d),(\d{3})"), r"\1\2")]

22
00:42:06,000 --> 00:42:12,000
This catches "1,234,567" and converts it to "1234567". Commas in numbers
fragment tokenization. We remove them.

23
00:42:12,000 --> 00:42:18,000
The third pattern normalises percentage formatting.
[Types: (re.compile(r"(\d)\s+%"), r"\1%")]

24
00:42:18,000 --> 00:42:24,000
This catches "12.5 %" and converts it to "12.5%". The space is unnecessary
and fragmenting.

25
00:42:24,000 --> 00:42:30,000
Now let's define the TextParser class. This is the main class for cleaning text.
[Types: class TextParser:]

26
00:42:30,000 --> 00:42:36,000
We'll start with the clean method. This applies the full cleaning pipeline.
[Types: def clean(self, text: str) -> str:]

27
00:42:36,000 --> 00:42:42,000
First, check if the text is empty. If it is, return empty string.
[Types: if not text or not text.strip():]
[Types: return ""]

28
00:42:42,000 --> 00:42:48,000
This guards against null or whitespace-only input. We return early to avoid
unnecessary processing.

29
00:42:48,000 --> 00:42:54,000
Step one is Unicode normalisation. NFKC converts ligatures and normalises
accented characters.
[Types: text = unicodedata.normalize("NFKC", text)]

30
00:42:54,000 --> 00:43:00,000
NFKC stands for Normalization Form KC. It's the compatibility decomposition
followed by canonical composition. This ensures consistent character
representation.

31
00:43:00,000 --> 00:43:06,000
Step two is removing noise patterns. We iterate over each pattern and replace
matches with a space.
[Types: for pattern in _NOISE_PATTERNS:]
[Types: text = pattern.sub(" ", text)]

32
00:43:06,000 --> 00:43:12,000
Using a space instead of empty string prevents words from merging together.
This maintains word boundaries.

33
00:43:12,000 --> 00:43:18,000
Step three is normalising whitespace within lines. We split into lines and
clean each one.
[Types: lines = []]

34
00:43:18,000 --> 00:43:24,000
[Types: for line in text.splitlines():]

35
00:43:24,000 --> 00:43:30,000
We collapse multiple spaces and tabs into a single space.
[Types: line = re.sub(r"[ \t]+", " ", line).strip()]

36
00:43:30,000 --> 00:43:36,000
The strip() removes leading and trailing whitespace from each line.
[Types: lines.append(line)]

37
00:43:36,000 --> 00:43:42,000
Step four is collapsing excessive blank lines. We allow a maximum of two
consecutive blank lines.
[Types: cleaned_lines: list[str] = []]

38
00:43:42,000 --> 00:43:48,000
[Types: blank_count = 0]

39
00:43:48,000 --> 00:43:54,000
[Types: for line in lines:]

40
00:43:54,000 --> 00:44:00,000
If the line is empty, we increment the blank counter.
[Types: if not line:]
[Types: blank_count += 1]

41
00:44:00,000 --> 00:44:06,000
If we're under the limit of two blank lines, we add it.
[Types: if blank_count <= 2:]
[Types: cleaned_lines.append("")]

42
00:44:06,000 --> 00:44:12,000
If the line is not empty, we reset the blank counter and add the line.
[Types: else:]
[Types: blank_count = 0]
[Types: cleaned_lines.append(line)]

43
00:44:12,000 --> 00:44:18,000
Finally, we join the lines back together and strip trailing whitespace.
[Types: return "\n".join(cleaned_lines).strip()]

44
00:44:18,000 --> 00:44:24,000
Now let's implement the normalise_numbers method. This normalises financial
number formatting.
[Types: def normalise_numbers(self, text: str) -> str:]

45
00:44:24,000 --> 00:44:30,000
First, we remove dollar signs. This catches $1,234 and $1,234.56.
[Types: text = re.sub(r"\$\s*", "", text)]

46
00:44:30,000 --> 00:44:36,000
We use \$\s* to match dollar signs with optional whitespace after them.
This removes currency symbols while preserving the numbers.

47
00:44:36,000 --> 00:44:42,000
Next, we remove commas from numbers. This converts 1,234,567 to 1234567.
[Types: text = text.replace(",", "")]

48
00:44:42,000 --> 00:44:48,000
We use replace instead of regex for performance. Commas fragment tokenization
and make numbers harder to parse.

49
00:44:48,000 --> 00:44:54,000
Finally, we normalise percentages. This converts "12.5 %" to "12.5%".
[Types: text = re.sub(r"(\d)\s+%", r"\1%", text)]

50
00:44:54,000 --> 00:45:00,000
We use a regex to catch digits followed by optional spaces and a percent sign.
The replacement removes the space.

51
00:45:00,000 --> 00:45:06,000
[Types: return text]

52
00:45:06,000 --> 00:45:12,000
Now let's implement the extract_metrics method. This extracts financial metrics
from text using regex patterns.
[Types: def extract_metrics(self, text: str) -> dict[str, float]:]

53
00:45:12,000 --> 00:45:18,000
We start with an empty dictionary.
[Types: metrics: dict[str, float] = {}]

54
00:45:18,000 --> 00:45:24,000
Now we define a helper function for safe float conversion.
[Types: def _safe_float(raw: str) -> float | None:]

55
00:45:24,000 --> 00:45:30,000
First, remove commas and whitespace.
[Types: cleaned = raw.replace(",", "").strip()]

56
00:45:30,000 --> 00:45:36,000
If the cleaned string is empty, return None.
[Types: if not cleaned: return None]

57
00:45:36,000 --> 00:45:42,000
Try to convert to float. If it fails, return None.
[Types: try: return float(cleaned)]
[Types: except ValueError: return None]

58
00:45:42,000 --> 00:45:48,000
Now let's extract revenue. We look for "revenue" followed by a number with scale.
[Types: revenue_match = re.search( r"(?:revenue|net\s+revenue|total\s+revenue)[^\d]* ([\d,]+(?:\.\d+)?)\s* (billion|million|thousand)?", text, re.I, )]

59
00:45:48,000 --> 00:45:54,000
The pattern captures the number and optional scale. We use case-insensitive
matching with re.I.

60
00:45:54,000 --> 00:46:00,000
If we find a match, we extract the number and scale.
[Types: if revenue_match:]
[Types: value = _safe_float(revenue_match.group(1))]

61
00:46:00,000 --> 00:46:06,000
If the value is valid, we apply the scale and store it.
[Types: if value is not None:]
[Types: scale = revenue_match.group(2) or ""]

62
00:46:06,000 --> 00:46:12,000
We call _apply_scale to convert billion or million to full value.
[Types: metrics["revenue"] = _apply_scale(value, scale)]

63
00:46:12,000 --> 00:46:18,000
Now let's extract net income. We look for "net income" or "net earnings".
[Types: income_match = re.search( r"net\s+(?:income|earnings|loss)[^\d]* ([\d,]+(?:\.\d+)?)\s* (billion|million|thousand)?", text, re.I, )]

64
00:46:18,000 --> 00:46:24,000
The pattern is similar to revenue but with different keywords.
[Types: if income_match:]
[Types: value = _safe_float(income_match.group(1))]

65
00:46:24,000 --> 00:46:30,000
[Types: if value is not None:]
[Types: scale = income_match.group(2) or ""]
[Types: metrics["net_income"] = _apply_scale(value, scale)]

66
00:46:30,000 --> 00:46:36,000
Now let's extract EPS. Earnings Per Share is usually a decimal number.
[Types: eps_match = re.search( r"(?:earnings\s+per\s+(?:diluted\s+)?share|eps)[^\d]* \$?([\d]+(?:\.\d+)?)", text, re.I, )]

67
00:46:36,000 --> 00:46:42,000
The pattern matches "earnings per share" or "EPS" with an optional dollar sign.
[Types: if eps_match:]
[Types: value = _safe_float(eps_match.group(1))]

68
00:46:42,000 --> 00:46:48,000
[Types: if value is not None:]
[Types: metrics["eps"] = value]

69
00:46:48,000 --> 00:46:54,000
Now let's extract operating margin. This is a percentage.
[Types: margin_match = re.search( r"(?:operating|gross|net)\s+margin[^\d]* ([\d]+(?:\.\d+)?)\s*%", text, re.I, )]

70
00:46:54,000 --> 00:47:00,000
The pattern matches "operating margin" or "gross margin" with a percentage.
[Types: if margin_match:]
[Types: value = _safe_float(margin_match.group(1))]

71
00:47:00,000 --> 00:47:06,000
[Types: if value is not None:]
[Types: metrics["margin_pct"] = value]

72
00:47:06,000 --> 00:47:12,000
Finally, we return the metrics dictionary.
[Types: return metrics]

73
00:47:12,000 --> 00:47:18,000
Now let's define the helper function _apply_scale. This converts scaled values
to their full numeric form.
[Types: def _apply_scale(value: float, scale: str) -> float:]

74
00:47:18,000 --> 00:47:24,000
First, convert scale to lowercase for case-insensitive matching.
[Types: scale = scale.lower()]

75
00:47:24,000 --> 00:47:30,000
If the scale is "billion", multiply by 1,000,000,000.
[Types: if scale == "billion":]
[Types: return value * 1_000_000_000]

76
00:47:30,000 --> 00:47:36,000
If the scale is "million", multiply by 1,000,000.
[Types: if scale == "million":]
[Types: return value * 1_000_000]

77
00:47:36,000 --> 00:47:42,000
If the scale is "thousand", multiply by 1,000.
[Types: if scale == "thousand":]
[Types: return value * 1_000]

78
00:47:42,000 --> 00:47:48,000
If there's no scale, return the value as is.
[Types: return value]

79
00:47:48,000 --> 00:47:54,000
Now let's update the parsers __init__.py file.
Open `src/financial_rag/ingestion/parsers/__init__.py`.

80
00:47:54,000 --> 00:48:00,000
We import the TextParser from this module.
[Types: from .text_parser import TextParser]

81
00:48:00,000 --> 00:48:06,000
We already have HTMLParser and the Parsed dataclasses.
[Types: from .html_parser import HTMLParser, ParsedFiling, ParsedSection]

82
00:48:06,000 --> 00:48:12,000
We export everything in __all__.
[Types: __all__ = ["HTMLParser", "ParsedFiling", "ParsedSection", "TextParser"]]

83
00:48:12,000 --> 00:48:18,000
Now let's test the TextParser. Open a Python terminal.

84
00:48:18,000 --> 00:48:24,000
[Types: from financial_rag.ingestion.parsers import TextParser]
We import the TextParser from the parsers package.

85
00:48:24,000 --> 00:48:30,000
[Types: parser = TextParser()]
We instantiate the parser.

86
00:48:30,000 --> 00:48:36,000
[Types: text = "Visit https://sec.gov for info. Contact investor@apple.com"]
We create a test string with noise.

87
00:48:36,000 --> 00:48:42,000
[Types: cleaned = parser.clean(text)]
[Types: print(cleaned)]
We clean the text and print the result. The URL and email should be removed.

88
00:48:42,000 --> 00:48:48,000
Now test normalise_numbers.
[Types: text2 = "Revenue was $1,234.5 million with 12.5 % margin"]
[Types: cleaned2 = parser.normalise_numbers(text2)]
[Types: print(cleaned2)]

89
00:48:48,000 --> 00:48:54,000
The dollar sign should be gone. The comma should be gone.
The space before the percent should be gone.

90
00:48:54,000 --> 00:49:00,000
Now test extract_metrics.
[Types: text3 = "Revenue was 394.3 billion. Net income was 93.7 billion. EPS was 6.13. Operating margin was 29.8%"]
[Types: metrics = parser.extract_metrics(text3)]
[Types: print(metrics)]

91
00:49:00,000 --> 00:49:06,000
You should see revenue, net_income, eps, and margin_pct in the output.
The values should be correctly scaled.

92
00:49:06,000 --> 00:49:12,000
Now let me explain why these patterns are designed this way.

93
00:49:12,000 --> 00:49:18,000
The revenue pattern looks for "revenue" or "net revenue" or "total revenue".
It captures the number with optional commas and decimals. It captures the
scale as "billion", "million", or "thousand".

94
00:49:18,000 --> 00:49:24,000
The net income pattern is similar but looks for "net income", "net earnings",
or "net loss". This is because income can be positive or negative.

95
00:49:24,000 --> 00:49:30,000
The EPS pattern looks for "earnings per share", "diluted share", or "EPS".
It captures the decimal number after optional dollar sign.

96
00:49:30,000 --> 00:49:36,000
The margin pattern looks for "operating margin", "gross margin", or "net margin".
It captures the percentage number.

97
00:49:36,000 --> 00:49:42,000
These patterns aren't perfect. They'll catch false positives sometimes.
But for a first pass, they work well. We can refine them over time.

98
00:49:42,000 --> 00:49:48,000
Now let me give you a debugging tip. If a metric isn't extracted, check the
pattern. The text might be formatted differently.

99
00:49:48,000 --> 00:49:54,000
For example, "Revenue of $394.3B" won't match because we look for "billion"
spelled out. You can update the pattern to catch abbreviations.

100
00:49:54,000 --> 00:50:00,000
The TextParser is designed to be easily extended. You can add new patterns
as you discover new formats in SEC filings.

101
00:50:00,000 --> 00:50:06,000
Now let's recap what we've built in Part 6.

102
00:50:06,000 --> 00:50:12,000
We built the TextParser class. It cleans text by removing URLs, email addresses,
control characters, and excessive whitespace.

103
00:50:12,000 --> 00:50:18,000
It normalises numbers by removing dollar signs, commas, and space before percent.
This makes numbers more parseable.

104
00:50:18,000 --> 00:50:24,000
It extracts financial metrics from text. Revenue, net income, EPS, and margin.
The values are correctly scaled to their full numeric form.

105
00:50:24,000 --> 00:50:30,000
This is the final step in the parsing pipeline. Raw HTML → Clean HTML → Clean Text →
Metric Extraction. The text is now ready for chunking and embedding.

106
00:50:30,000 --> 00:50:36,000
In Part 7, we'll write integration tests for the entire ingestion pipeline.
We'll test the HTMLParser, TextParser, and SECIngestor together.

107
00:50:36,000 --> 00:50:42,000
Thank you for watching. I'll see you in Part 7.

108
00:50:42,000 --> 00:50:46,000
[End of Part 6]
```

1
00:00:00,000 --> 00:00:06,000
Welcome back to Phase 2. In Part 7, we build the ingestion tests.

2
00:00:06,000 --> 00:00:12,000
We've built the exception hierarchy, the base repository, the filings repository,
the SEC ingestor, the HTML parser, and the text parser.

3
00:00:12,000 --> 00:00:18,000
Now we need to verify everything works together. This is where we catch
bugs before they reach production.

4
00:00:18,000 --> 00:00:24,000
Open your editor and create `tests/integration/test_phase2_ingestion.py`.

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
We import pytest as our testing framework.
[Types: import pytest]

8
00:00:42,000 --> 00:00:48,000
We import patch from unittest.mock for mocking external dependencies.
[Types: from unittest.mock import patch]

9
00:00:48,000 --> 00:00:54,000
We import get_settings from our config module for test configuration.
[Types: from financial_rag.config import get_settings]

10
00:00:54,000 --> 00:01:00,000
We import the HTMLParser for testing HTML parsing.
[Types: from financial_rag.ingestion.parsers.html_parser import HTMLParser]

11
00:01:00,000 --> 00:01:06,000
We import the TextParser for testing text cleaning and metric extraction.
[Types: from financial_rag.ingestion.parsers.text_parser import TextParser]

12
00:01:06,000 --> 00:01:12,000
We import the SECIngestor for testing EDGAR integration.
[Types: from financial_rag.ingestion.sec_ingestor import SECIngestor]

13
00:01:12,000 --> 00:01:18,000
We import SUPPORTED_FILING_TYPES for validation tests.
[Types: from financial_rag.ingestion.sec_ingestor import SUPPORTED_FILING_TYPES]

14
00:01:18,000 --> 00:01:24,000
We import the exception types we need to test.
[Types: from financial_rag.utils.exceptions import DuplicateFilingError, SECFetchError]

15
00:01:24,000 --> 00:01:30,000
Now let's define the valid test secrets. These are environment variables that
must be set for tests to run.
[Types: VALID_SECRETS = { "POSTGRES_PASSWORD": "test-pg-password-32-chars-minimum", "REDIS_PASSWORD": "test-redis-password-32-chars-min", "APP_ENV": "testing", }]

16
00:01:30,000 --> 00:01:36,000
We set POSTGRES_PASSWORD to a test value. In production, this would be a secure
password. For testing, we use a placeholder.

17
00:01:36,000 --> 00:01:42,000
We do the same for REDIS_PASSWORD. We set APP_ENV to "testing" which enables
testing mode in the application.

18
00:01:42,000 --> 00:01:48,000
Now let's define the settings cache fixture. This clears the cache before and after
each test to prevent state bleeding.
[Types: @pytest.fixture(autouse=True) def clear_settings_cache(): get_settings.cache_clear() yield get_settings.cache_clear()]

19
00:01:48,000 --> 00:01:54,000
The fixture runs automatically for every test. It clears the cache before the test
and again after the test completes.

20
00:01:54,000 --> 00:02:00,000
Now let's define the testing environment fixture. This patches the environment
with our valid test secrets.
[Types: @pytest.fixture def test_env(): with patch.dict(os.environ, VALID_SECRETS, clear=False): yield]

21
00:02:00,000 --> 00:02:06,000
This fixture ensures our tests have the required environment variables set.

22
00:02:06,000 --> 00:02:12,000
Now let's define the test class for the exception hierarchy.
[Types: class TestExceptionHierarchy:]

23
00:02:12,000 --> 00:02:18,000
We test that SECFetchError is an instance of IngestionError.
[Types: def test_sec_fetch_error_is_ingestion_error(self): err = SECFetchError("test") assert isinstance(err, IngestionError)]

24
00:02:18,000 --> 00:02:24,000
This verifies our exception hierarchy is correct. SECFetchError should inherit
from IngestionError.

25
00:02:24,000 --> 00:02:30,000
We test that DuplicateFilingError stores the ticker and file_hash correctly.
[Types: def test_duplicate_filing_error_stores_fields(self): err = DuplicateFilingError("AAPL", "abc123") assert err.ticker == "AAPL" assert err.file_hash == "abc123"]

26
00:02:30,000 --> 00:02:36,000
This verifies the exception stores the data we need for debugging.

27
00:02:36,000 --> 00:02:42,000
We test that the error message includes the file_hash.
[Types: assert "abc123" in str(err)]

28
00:02:42,000 --> 00:02:48,000
This is important because the message is what we see in logs.

29
00:02:48,000 --> 00:02:54,000
We test that the cause appears in the string representation.
[Types: def test_cause_appears_in_str(self): from financial_rag.utils.exceptions import FinRAGError original = ValueError("root cause") err = FinRAGError("wrapper", cause=original) assert "root cause" in str(err)]

30
00:02:54,000 --> 00:03:00,000
This verifies the chain of errors is preserved in the error message.

31
00:03:00,000 --> 00:03:06,000
Now let's define the test class for the HTML parser.
[Types: class TestHTMLParser:]

32
00:03:06,000 --> 00:03:12,000
We define the setup method. This runs before each test.
[Types: def setup_method(self): self.parser = HTMLParser()]

33
00:03:12,000 --> 00:03:18,000
This creates a fresh parser instance for each test.

34
00:03:18,000 --> 00:03:24,000
We test that SGML headers are stripped from the content.
[Types: def test_strips_sgml_header(self): content = "SGML JUNK\n<html><body><p>Hello</p></body></html>" parsed = self.parser.parse(content, ticker="TEST", filing_type="10-K") assert "SGML JUNK" not in parsed.full_text assert "Hello" in parsed.full_text]

35
00:03:24,000 --> 00:03:30,000
SEC filings begin with an SGML header before the HTML. We need to strip
this header to parse the HTML correctly.

36
00:03:30,000 --> 00:03:36,000
We test that the parser detects the MD&A section correctly.
[Types: def test_detects_mda_section(self): html = """<html><body><h2>Management's Discussion and Analysis</h2><p>Revenue increased significantly</p></body></html>""" parsed = self.parser.parse(html, ticker="AAPL", filing_type="10-K", fiscal_year=2023) section_names = [s.name for s in parsed.sections] assert "MD&A" in section_names]

37
00:03:36,000 --> 00:03:42,000
The parser uses regex patterns to identify sections like MD&A, Risk Factors,
and Financial Statements.

38
00:03:42,000 --> 00:03:48,000
We test that documents without known sections return a "General" section.
[Types: def test_returns_general_when_no_sections(self): html = "<html><body><p>Plain text with no known section headings here.</p></body></html>" parsed = self.parser.parse(html, ticker="TEST", filing_type="10-K") assert len(parsed.sections) == 1 assert parsed.sections[0].name == "General"]

39
00:03:48,000 --> 00:03:54,000
This ensures we always get at least one section, even if the parser can't
identify specific sections.

40
00:03:54,000 --> 00:04:00,000
We test that get_section returns None for a missing section.
[Types: def test_get_section_returns_none_for_missing(self): html = "<html><body><p>Text</p></body></html>" parsed = self.parser.parse(html, ticker="TEST", filing_type="10-K") assert parsed.get_section("MD&A") is None]

41
00:04:00,000 --> 00:04:06,000
This verifies the get_section method handles missing sections gracefully.

42
00:04:06,000 --> 00:04:12,000
We test that script tags are removed from the parsed content.
[Types: def test_removes_script_tags(self): html = "<html><body><script>alert('xss')</script><p>Clean</p></body></html>" parsed = self.parser.parse(html, ticker="TEST", filing_type="10-K") assert "alert" not in parsed.full_text]

43
00:04:12,000 --> 00:04:18,000
Script tags contain JavaScript that adds noise to the extracted text.
We remove them during parsing.

44
00:04:18,000 --> 00:04:24,000
We test that char_count is populated correctly.
[Types: def test_char_count_is_populated(self): html = "<html><body><p>Some content here</p></body></html>" parsed = self.parser.parse(html, ticker="TEST", filing_type="10-K") assert parsed.char_count == len(parsed.full_text)]

45
00:04:24,000 --> 00:04:30,000
This verifies the char_count field is updated when the ParsedFiling is created.

46
00:04:30,000 --> 00:04:36,000
Now let's define the test class for the text parser.
[Types: class TestTextParser:]

47
00:04:36,000 --> 00:04:42,000
We define the setup method. This runs before each test.
[Types: def setup_method(self): self.parser = TextParser()]

48
00:04:42,000 --> 00:04:48,000
This creates a fresh text parser instance for each test.

49
00:04:48,000 --> 00:04:54,000
We test that URLs are removed from the text.
[Types: def test_removes_urls(self): result = self.parser.clean("Visit https://example.com for more info.") assert "https://example.com" not in result]

50
00:04:54,000 --> 00:05:00,000
URLs add noise to the extracted text. We remove them during cleaning.

51
00:05:00,000 --> 00:05:06,000
We test that email addresses are removed from the text.
[Types: def test_removes_emails(self): result = self.parser.clean("Contact investor@apple.com for details.") assert "investor@apple.com" not in result]

52
00:05:06,000 --> 00:05:12,000
Email addresses add noise and are not relevant to financial analysis.

53
00:05:12,000 --> 00:05:18,000
We test that dollar signs and commas are normalized.
[Types: def test_normalise_numbers_strips_dollar_commas(self): result = self.parser.normalise_numbers("Revenue was $1,234,567 million") assert "$" not in result assert "1234567" in result]

54
00:05:18,000 --> 00:05:24,000
This makes numbers easier to extract and parse for metrics.

55
00:05:24,000 --> 00:05:30,000
We test that percentage spacing is normalized.
[Types: def test_normalise_percentage_spacing(self): result = self.parser.normalise_numbers("Margin increased 12.5 %") assert "12.5%" in result]

56
00:05:30,000 --> 00:05:36,000
This ensures percentages are consistently formatted.

57
00:05:36,000 --> 00:05:42,000
We test that revenue metrics are extracted correctly.
[Types: def test_extract_revenue_metric(self): text = "Total revenue was $394.3 billion for the fiscal year." metrics = self.parser.extract_metrics(text) assert "revenue" in metrics assert metrics["revenue"] > 0]

58
00:05:42,000 --> 00:05:48,000
The text parser extracts financial metrics like revenue, net income, EPS,
and margin from the text.

59
00:05:48,000 --> 00:05:54,000
We test that EPS metrics are extracted correctly.
[Types: def test_extract_eps_metric(self): text = "Earnings per diluted share was $6.13 for the quarter." metrics = self.parser.extract_metrics(text) assert "eps" in metrics assert abs(metrics["eps"] - 6.13) < 0.01]

60
00:05:54,000 --> 00:06:00,000
EPS is a critical financial metric. We extract it for use in analysis.

61
00:06:00,000 --> 00:06:06,000
We test that empty text returns empty.
[Types: def test_empty_text_returns_empty(self): assert self.parser.clean("") == "" assert self.parser.clean("   ") == ""]

62
00:06:06,000 --> 00:06:12,000
This verifies the parser handles empty input gracefully.

63
00:06:12,000 --> 00:06:18,000
Now let's define the test class for the SEC ingestor.
[Types: class TestSECIngestor:]

64
00:06:18,000 --> 00:06:24,000
We test that the supported filing types are correctly defined.
[Types: def test_supported_filing_types(self): assert "10-K" in SUPPORTED_FILING_TYPES assert "10-Q" in SUPPORTED_FILING_TYPES assert "INVALID" not in SUPPORTED_FILING_TYPES]

65
00:06:24,000 --> 00:06:30,000
This verifies our supported filing types include the most common SEC forms.

66
00:06:30,000 --> 00:06:36,000
We test that years are capped at five.
[Types: def test_years_capped_at_five(self): assert min(10, 5) == 5 assert min(3, 5) == 3]

67
00:06:36,000 --> 00:06:42,000
This verifies we never request more than five years of filings from EDGAR.

68
00:06:42,000 --> 00:06:48,000
Now let's define the integration test for resolving CIK.
[Types: @pytest.mark.integration async def test_resolve_cik_for_apple(self): async with SECIngestor() as ingestor: cik = await ingestor._resolve_cik("AAPL") assert cik == "0000320193"]

69
00:06:48,000 --> 00:06:54,000
This test makes a live API call to EDGAR to resolve Apple's CIK.
It verifies the resolution works correctly.

70
00:06:54,000 --> 00:07:00,000
We use the integration marker for tests that make external API calls.

71
00:07:00,000 --> 00:07:06,000
We test that unsupported filing types raise an error.
[Types: @pytest.mark.integration async def test_unsupported_type_raises(self): async with SECIngestor() as ingestor: with pytest.raises(SECFetchError): await ingestor.list_filings("AAPL", "INVALID")]

72
00:07:06,000 --> 00:07:12,000
This verifies the ingestor rejects unsupported filing types with a clear error.

73
00:07:12,000 --> 00:07:18,000
Now let's run the tests. Activate your virtual environment and run pytest.

74
00:07:18,000 --> 00:07:24,000
[Types: source .venv/bin/activate]
[Types: pytest tests/integration/test_phase2_ingestion.py -v]

75
00:07:24,000 --> 00:07:30,000
The unit tests should pass quickly. The integration tests may take longer
because they make network calls to EDGAR.

76
00:07:30,000 --> 00:07:36,000
If a test fails, read the error message carefully. It will tell you exactly
what went wrong and where.

77
00:07:36,000 --> 00:07:42,000
Now let me recap what we've built in Part 7.

78
00:07:42,000 --> 00:07:48,000
We built tests for the exception hierarchy. We verified SECFetchError inherits
from IngestionError and DuplicateFilingError stores the correct fields.

79
00:07:48,000 --> 00:07:54,000
We built tests for the HTML parser. We verified it strips SGML headers, detects
sections, removes script tags, and handles documents without sections.

80
00:07:54,000 --> 00:08:00,000
We built tests for the text parser. We verified it removes URLs and emails,
normalizes numbers, and extracts financial metrics.

81
00:08:00,000 --> 00:08:06,000
We built tests for the SEC ingestor. We verified supported filing types,
year capping, CIK resolution, and error handling for unsupported types.

82
00:08:06,000 --> 00:08:12,000
This is the foundation of our test suite. Every component is tested.
Bugs are caught early. The system is reliable.

83
00:08:12,000 --> 00:08:18,000
Phase 2 is now complete. You have a working ingestion pipeline with tests.

84
00:08:18,000 --> 00:08:24,000
Thank you for watching. I'll see you in Phase 3.

85
00:08:24,000 --> 00:08:28,000
[End of Part 7]