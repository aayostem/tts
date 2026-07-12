1
00:00:00,000 --> 00:00:08,000
Welcome to Phase 1 of building a production-grade Financial AI Agent.

2
00:00:08,000 --> 00:00:16,000
This is the foundation. The bedrock. Everything else we build over the coming
hours and phases rests on what we create right now.

3
00:00:16,000 --> 00:00:24,000
By the end of this two-hour session, you'll have a complete, working Python
project with a modern structure, comprehensive configuration, a production-ready
database layer, and everything tested and verified.

4
00:00:24,000 --> 00:00:32,000
[Visual: Animated diagram of the complete system architecture — data flows from
SEC EDGAR through ingestion, vector store, retrieval, and finally to the user via API]

5
00:00:32,000 --> 00:00:40,000
Let me show you the big picture. Data comes from SEC EDGAR — tens of thousands
of financial filings. We ingest them, parse them, chunk them, and store them in
a vector database. Then when you ask a question, we retrieve the most relevant
chunks and generate an answer using an LLM.

6
00:00:40,000 --> 00:00:48,000
But this is just Phase 1. In later phases, we'll add multi-agent orchestration,
real-time data streaming, and predictive analytics. For now, we're building the
foundation that makes all of that possible.

7
00:00:48,000 --> 00:00:56,000
Let's start with the prerequisites. You need Python 3.11 or higher, Docker,
Docker Compose, and Git. If you don't have these, pause the video, get them installed,
and come right back.

8
00:00:56,000 --> 00:01:04,000
You do not need an OpenAI API key for this phase. We use local services exclusively
until we're ready to connect to the cloud. This means no cost, no API limits,
and you can run everything on your local machine.

9
00:01:04,000 --> 00:01:12,000
[Visual: Terminal showing mkdir and cd commands being typed]

10
00:01:12,000 --> 00:01:20,000
Let's begin by creating a folder on the desktop called financial-ai-agents.

3
00:00:07,000 --> 00:00:10,500
Drag and drop this folder into VS Code,
or open it with your preferred editor.

12
00:01:28,000 --> 00:01:36,000
Now, here's where many tutorials go wrong. They just throw files everywhere.
We're going to use what's called the "src layout" — a modern standard for Python
packages that prevents import conflicts and makes your code actually installable.

13
00:01:36,000 --> 00:01:44,000
[Visual: Side-by-side comparison of flat layout (messy) vs src layout (clean)]

14
00:01:44,000 --> 00:01:52,000
The src layout is the industry standard because it forces you to be intentional
about what you're importing. You import from 'financial_rag', not from the root
directory. This ensures your package works when installed — not just when you're
running it locally.

15
00:01:52,000 --> 00:02:00,000
Think of it like this: a flat layout is like having all your files on your desktop.
It works when you're the only one using it. But as soon as you have multiple projects
or multiple people, it becomes chaos.

16
00:02:00,000 --> 00:02:08,000
The src layout is like having a well-organized filing system. Everything has its place.
You always know where to find things. And when someone else looks at your project,
they immediately understand the structure.

17
00:02:08,000 --> 00:02:16,000
Here's the command to scaffold all directories at once. Run this in your terminal:
mkdir -p src/financial_rag/{config,storage}

18
00:02:16,000 --> 00:02:24,000
[Visual: Directory tree expanding as each folder is explained]

19
00:02:24,000 --> 00:02:32,000
Let me break down what each of these directories does, because understanding this
structure is the key to understanding the entire system.

20
00:02:32,000 --> 00:02:40,000
'config' holds all settings and environment configuration. This is the single source
of truth for how your application behaves. Every other component reads from here.
If you want to change the database host, the embedding model, or the logging level,
you change it here.

21
00:02:40,000 --> 00:02:48,000
'storage' contains database clients, cache clients, and repositories. This is your
data access layer — everything that talks to PostgreSQL, Redis, or any other data store.
This is where the actual data lives and how we interact with it.

22
00:02:48,000 --> 00:02:56,000
We also need Python package marker files. These are empty __init__.py files that
tell Python, "Hey, this directory is a package you can import from."

23
00:02:56,000 --> 00:03:04,000
Without these, Python would not recognize these folders as importable packages.
It's a small detail that trips up beginners all the time — so let's get it right
from the start.

24
00:03:04,000 --> 00:03:12,000
[Visual: Python interpreter searching for packages — showing before and after
__init__.py files are added]

25
00:03:12,000 --> 00:03:20,000
Run this command to create __init__.py files in every directory:
find src -type d -exec touch {}/__init__.py \;

26
00:03:20,000 --> 00:03:28,000
Now, let's examine the most important file in any modern Python project:
pyproject.toml. This single file replaces setup.py, requirements.txt, setup.cfg,
flake8.ini, mypy.ini, and pytest.ini.

27
00:03:28,000 --> 00:03:36,000
[Visual: Before — six separate configuration files. After — one pyproject.toml file]

28
00:03:36,000 --> 00:03:44,000
Think about what that means. Instead of managing six different configuration files,
you have one. One file to rule them all. This simplifies project management enormously
and reduces the cognitive load of setting up a new project.

29
00:03:44,000 --> 00:03:52,000
[CODE TYPING: pyproject.toml — build system section]
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

30
00:03:52,000 --> 00:04:00,000
At the top, we specify the build system. We use hatchling, which is lightweight
and doesn't need a MANIFEST.in file. It's the modern Python standard.

31
00:04:00,000 --> 00:04:08,000
[CODE TYPING: pyproject.toml — project section]
[project]
name = "financial-ai-agent"
version = "0.1.0"
description = "Production-grade financial RAG pipeline"
readme = "README.md"
requires-python = ">=3.11"

32
00:04:08,000 --> 00:04:16,000
Under the project section, we have the package name, version, description,
and Python version requirement. This is the metadata that makes your package
findable and installable.

33
00:04:16,000 --> 00:04:24,000
[CODE TYPING: pyproject.toml — dependencies]
dependencies = [
    "fastapi>=0.111.0",
    "uvicorn[standard]>=0.30.0",
    "pydantic>=2.7.0",
    "pydantic-settings>=2.3.0",
    "sqlalchemy[asyncio]>=2.0.30",
    "asyncpg>=0.29.0",
    "pgvector>=0.3.0",
    "alembic>=1.13.0",
]

34
00:04:24,000 --> 00:04:32,000
The dependencies section lists all production dependencies. These are the packages
your application actually needs to run. Every dependency here is carefully chosen
for a specific purpose.

35
00:04:32,000 --> 00:04:40,000
FastAPI is our web framework. It's modern, fast, and built on Python type hints.
Uvicorn is the ASGI server that runs FastAPI. Pydantic handles configuration
validation and data parsing. Pydantic-settings reads from .env files.

36
00:04:40,000 --> 00:04:48,000
SQLAlchemy 2.0 provides async database access. asyncpg is the PostgreSQL driver.
pgvector adds vector search to PostgreSQL. Alembic handles database migrations.

37
00:04:48,000 --> 00:04:56,000
[CODE TYPING: pyproject.toml — more dependencies]
    "redis[hiredis]>=5.0.0",
    "openai>=1.35.0",
    "tiktoken>=0.7.0",
    "httpx>=0.27.0",
    "beautifulsoup4>=4.12.0",
    "lxml>=5.2.0",
    "structlog>=24.2.0",
    "tenacity>=8.3.0",

38
00:04:56,000 --> 00:05:04,000
Redis provides caching. OpenAI is for LLM and embedding integration. tiktoken
counts tokens. httpx is our HTTP client. BeautifulSoup4 parses HTML. structlog
provides structured logging. tenacity handles retry logic.

39
00:05:04,000 --> 00:05:12,000
[CODE TYPING: pyproject.toml — dev dependencies]
[project.optional-dependencies]
dev = [
    "pytest>=8.2.0",
    "pytest-asyncio>=0.23.0",
    "pytest-cov>=5.0.0",
    "mypy>=1.10.0",
    "ruff>=0.4.0",
    "pre-commit>=3.7.0",
]

40
00:05:12,000 --> 00:05:20,000
The dev dependencies are separate from production dependencies. These are not
installed in production — they're only used during development and testing.

41
00:05:20,000 --> 00:05:28,000
pytest is the testing framework. pytest-asyncio enables async tests. pytest-cov
measures test coverage. mypy is the static type checker. ruff is the fast linter
that replaces black, isort, and flake8. pre-commit runs hooks before commits.

42
00:05:28,000 --> 00:05:36,000
[CODE TYPING: pyproject.toml — hatch build config]
[tool.hatch.build.targets.wheel]
packages = ["src/financial_rag"]

43
00:05:36,000 --> 00:05:44,000
This tells hatchling where to find our package. The packages are in
src/financial_rag. This is where the build system looks for the code.

44
00:05:44,000 --> 00:05:52,000
[CODE TYPING: pyproject.toml — pytest config]
[tool.pytest.ini_options]
asyncio_mode = "auto"
testpaths = ["tests"]
pythonpath = ["src"]
python_files = ["test_*.py"]
python_classes = ["Test*"]
python_functions = ["test_*"]

45
00:05:52,000 --> 00:06:00,000
Now let's look at the pytest configuration. asyncio_mode is set to 'auto' — this
enables async test support. testpaths is set to 'tests' — this is where pytest
looks for tests.

46
00:06:00,000 --> 00:06:08,000
pythonpath includes 'src' — this allows imports to work correctly. Without this,
pytest wouldn't be able to find your application code. This is a common pitfall
that I want you to avoid.

47
00:06:08,000 --> 00:06:16,000
[Visual: Python import resolution showing with and without pythonpath set]

48
00:06:16,000 --> 00:06:24,000
python_files matches test_*.py. python_classes matches Test*. python_functions
matches test_*. These patterns tell pytest what to look for.

49
00:06:24,000 --> 00:06:32,000
[CODE TYPING: pyproject.toml — pytest markers]
markers = [
    "unit: Unit tests",
    "integration: Integration tests (require running services)",
]

50
00:06:32,000 --> 00:06:40,000
We define markers: 'unit' for unit tests and 'integration' for integration tests.
Integration tests require external services like PostgreSQL and Redis to be running.
This separation is crucial for fast test feedback.

51
00:06:40,000 --> 00:06:48,000
You can run just unit tests with: pytest -m unit
Or just integration tests with: pytest -m integration
This flexibility is incredibly useful in CI/CD pipelines.

52
00:06:48,000 --> 00:06:56,000
[CODE TYPING: pyproject.toml — ruff config]
[tool.ruff]
line-length = 100
target-version = "py311"

[tool.ruff.lint]
select = ["E", "F", "I", "UP", "B", "SIM", "TCH", "RUF"]
ignore = ["E501"]

53
00:06:56,000 --> 00:07:04,000
Now let's look at the ruff configuration. line-length is set to 100 characters.
This is a reasonable maximum — longer than 80 but shorter than 120. target-version
is set to py311. This ensures compatibility with Python 3.11.

54
00:07:04,000 --> 00:07:12,000
The lint select option enables specific rule sets: E for errors, F for pyflakes,
I for import sorting, UP for pyupgrade, B for bugbear, SIM for simplification,
TCH for type checking, and RUF for ruff-specific rules. We ignore E501 because
we already set line-length to 100.

55
00:07:12,000 --> 00:07:20,000
[CODE TYPING: pyproject.toml — mypy config]
[tool.mypy]
python_version = "3.11"
strict = true
ignore_missing_imports = true
exclude = ["^tests/", "^tests\\\\", "migrations/"]

56
00:07:20,000 --> 00:07:28,000
Now let's look at the mypy configuration. strict = true means mypy will catch
every possible type error. ignore_missing_imports = true allows libraries without
type stubs to be imported. exclude tells mypy not to check tests or migrations.

57
00:07:28,000 --> 00:07:36,000
Now, let's create our virtual environment. A virtual environment isolates dependencies
so they don't conflict with other projects on your system.

58
00:07:36,000 --> 00:07:44,000
[Visual: Visual metaphor — each project in its own isolated bubble]

59
00:07:44,000 --> 00:07:52,000
Run: python -m venv .venv
This creates a virtual environment in the .venv directory. The name '.venv' is
a convention that many tools recognize automatically.

60
00:07:52,000 --> 00:08:00,000
Activate the environment with source .venv/bin/activate on Mac and Linux.
On Windows, use .venv\Scripts\activate.

61
00:08:00,000 --> 00:08:08,000
How do you know it's activated? You'll see (.venv) appear at the beginning of
your terminal prompt. If you don't see that, the environment isn't active.

62
00:08:08,000 --> 00:08:16,000
Now, install the package in editable mode with development dependencies:
pip install -e .[dev]

63
00:08:16,000 --> 00:08:24,000
The -e flag means editable mode. Changes to your source code are immediately
available. You don't need to reinstall after every change — which is essential
during development. The .[dev] part installs the development dependencies.

64
00:08:24,000 --> 00:08:32,000
Let's verify the installation. Run: python -c "import financial_rag; print('OK')"
If you see OK, the package is installed correctly. If you get an error, double-check
that you're in the right directory and the virtual environment is active.

65
00:08:32,000 --> 00:08:40,000
[Visual: Successful vs failed import with troubleshooting notes]

66
00:08:40,000 --> 00:08:48,000
Now, we need to set up environment variables. This is where we store configuration
that varies between environments — database passwords, API keys, and other secrets.

67
00:08:48,000 --> 00:08:56,000
Create a .env file in the project root. This file should never be committed to Git.
It contains secrets that would compromise your system if exposed.

68
00:08:56,000 --> 00:09:04,000
[Visual: The .env file should be clearly marked as secret — big red "DO NOT COMMIT"]

69
00:09:04,000 --> 00:09:12,000
[CODE TYPING: .env]
APP_ENV=development
POSTGRES_PASSWORD=devpassword123
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_USER=finrag
POSTGRES_DB=financial_rag
REDIS_PASSWORD=devredis123
REDIS_HOST=localhost
REDIS_PORT=6379
OPENAI_API_KEY=sk-placeholder

70
00:09:12,000 --> 00:09:20,000
Add APP_ENV=development. This sets the runtime environment. In development, we get
debug mode, auto-reload, and more logging. POSTGRES_PASSWORD is required.
REDIS_PASSWORD is also required. OPENAI_API_KEY is a placeholder for later.

71
00:09:20,000 --> 00:09:28,000
[CODE TYPING: .env.example]
APP_ENV=development
POSTGRES_PASSWORD=change_me
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_USER=finrag
POSTGRES_DB=financial_rag
REDIS_PASSWORD=change_me
REDIS_HOST=localhost
REDIS_PORT=6379
OPENAI_API_KEY=sk-placeholder

72
00:09:28,000 --> 00:09:36,000
Create .env.example with the same variables but no values. This is committed to Git.
Team members can copy .env.example to .env and fill in their own values.

73
00:09:36,000 --> 00:09:44,000
Why do we need .env.example? Because we want the project to be easy to set up.
Someone cloning the repository should be able to see exactly what configuration
they need to provide.

74
00:09:44,000 --> 00:09:52,000
Now, create .gitignore. This prevents sensitive files from being committed.
Every Python project needs a .gitignore file — it's not optional.

75
00:09:52,000 --> 00:10:00,000
[CODE TYPING: .gitignore]
.venv/
__pycache__/
*.pyc
.env
.env.*
!.env.example
*.egg-info/
.pytest_cache/
.mypy_cache/
.ruff_cache/
dist/
build/
data/

76
00:10:00,000 --> 00:10:08,000
Ignore .venv/, __pycache__/, *.pyc, .env, *.egg-info/, .pytest_cache/,
.mypy_cache/, .ruff_cache/, and dist/. Also ignore the data/ directory.

77
00:10:08,000 --> 00:10:16,000
Never commit secrets to version control. This is a critical security practice.
Once a secret is in Git, it's there forever — even if you delete it, it's still
in the commit history.

78
00:10:16,000 --> 00:10:24,000
If you accidentally commit a secret, you must consider it compromised and rotate it
immediately. Don't just delete the file and recommit — the secret is still in the
history. Use git filter-repo or BFG to remove it.

79
00:10:24,000 --> 00:10:32,000
[Visual: Git bouncer metaphor — .gitignore stopping sensitive files from entering the repo]

80
00:10:32,000 --> 00:10:40,000
Now, let's understand the project structure we've created. The root directory has
pyproject.toml, docker-compose.yml, and the src and tests directories.

81
00:10:40,000 --> 00:10:48,000
[Visual: Complete directory tree with all files highlighted]

82
00:10:48,000 --> 00:10:56,000
src/financial_rag/ contains all application code. This is the package root.
Everything inside here is part of the financial_rag package.

83
00:10:56,000 --> 00:11:04,000
tests/ contains all tests. Unit tests go in tests/unit/. Integration tests go
in tests/integration/. This separation allows different test runs.

84
00:11:04,000 --> 00:11:12,000
Unit tests run quickly — they test individual functions and classes.
Integration tests take longer — they test interactions between components.

85
00:11:12,000 --> 00:11:20,000
infrastructure/ contains Docker and Kubernetes configuration. This keeps deployment
configuration separate from application code — a clean separation of concerns.

86
00:11:20,000 --> 00:11:28,000
infrastructure/docker/init/ contains database initialization scripts.
migrations/ contains Alembic migration files.

87
00:11:28,000 --> 00:11:36,000
Now, let's understand the key design decisions behind this structure.
The src layout prevents import confusion — you import from financial_rag,
not from the root.

88
00:11:36,000 --> 00:11:44,000
[Visual: Import resolution difference between src layout and flat layout]

89
00:11:44,000 --> 00:11:52,000
This is important for packaging. It ensures the package works when installed.
If you use the old flat structure, you might accidentally import from the local
directory instead of the installed package.

90
00:11:52,000 --> 00:12:00,000
The separation of unit and integration tests allows different test runs.
You can run unit tests in CI to get fast feedback, and only run integration
tests when you need to verify the full system.

91
00:12:00,000 --> 00:12:08,000
The infrastructure folder keeps deployment configuration separate from application code.
This is a clean separation of concerns — it makes the codebase easier to understand
and maintain.

92
00:12:08,000 --> 00:12:16,000
Let's verify the pyproject.toml configuration. The dependencies list is comprehensive.
We have everything we need for Phase 1.

93
00:12:16,000 --> 00:12:24,000
SQLAlchemy 2.0 and asyncpg provide the database layer. pgvector enables vector
similarity search — this is the foundation of RAG. Redis provides caching.
FastAPI provides the API layer.

94
00:12:24,000 --> 00:12:32,000
Let's run a quick verification. Check that the virtual environment is active.
Run pip list to see installed packages. You should see financial-ai-agent.

95
00:12:32,000 --> 00:12:40,000
Run python -c "import financial_rag; print('OK')".
This confirms the package structure is working.

96
00:12:40,000 --> 00:12:48,000
Now, let's look at the .env file structure in more detail.
APP_ENV controls the runtime environment. In development, we enable debug mode.

97
00:12:48,000 --> 00:12:56,000
POSTGRES_PASSWORD is a secret — it's required for database authentication.
REDIS_PASSWORD is also a secret — it's required for Redis authentication.

98
00:12:56,000 --> 00:13:04,000
The .env file is loaded by Pydantic's BaseSettings. It reads the file automatically.
This is why we don't need to manually load environment variables.

99
00:13:04,000 --> 00:13:12,000
Now, let's understand the .gitignore patterns. .venv/ ignores the virtual environment —
this keeps the repository small. __pycache__/ ignores Python cache files.

100
00:13:12,000 --> 00:13:20,000
.env ignores environment files — this prevents secrets from being committed.
.pytest_cache/ and .mypy_cache/ ignore test and type checking caches.

101
00:13:20,000 --> 00:13:28,000
dist/ ignores build artifacts — these are generated when building the package.
They should never be committed to version control.

102
00:13:28,000 --> 00:13:36,000
Now, let's understand the workflow for a new developer joining the project.
They clone the repository. They copy .env.example to .env and fill in values.

103
00:13:36,000 --> 00:13:44,000
They create a virtual environment and install dependencies with pip install -e .[dev].
They start Docker services with docker compose up -d.

104
00:13:44,000 --> 00:13:52,000
They run the integration tests to verify everything works.
This is a smooth onboarding experience — everything is automated.

105
00:13:52,000 --> 00:14:00,000
Now, let's review the tools we're using. pytest is the testing framework —
it discovers and runs tests. ruff is the linter — it checks code style and catches errors.

106
00:14:00,000 --> 00:14:08,000
mypy is the type checker — it validates type hints and catches type errors.
pre-commit runs checks before commits — this prevents bad code from being merged.

107
00:14:08,000 --> 00:14:16,000
These tools ensure code quality. They catch issues early in the development cycle.
The earlier you catch a bug, the cheaper it is to fix.

108
00:14:16,000 --> 00:14:24,000
Now, let's summarize what we've accomplished in Part 1. We created a complete
project structure with the src layout. This is the modern standard for Python packages.

109
00:14:24,000 --> 00:14:32,000
We configured pyproject.toml with all dependencies and tools. This single file
replaces six separate configuration files — it's much simpler to manage.

110
00:14:32,000 --> 00:14:40,000
We set up environment variables with .env and .env.example. This keeps secrets
out of version control while still making configuration easy.

111
00:14:40,000 --> 00:14:48,000
We created .gitignore to prevent secrets from being committed. This is a critical
security practice — never commit secrets to version control.

112
00:14:48,000 --> 00:14:56,000
We installed the package in editable mode with dev dependencies. This makes
development smooth and efficient — changes are immediately available.

113
00:14:56,000 --> 00:15:04,000
We verified the installation works correctly. This is your sanity check —
if the import works, the package is installed correctly.

114
00:15:04,000 --> 00:15:12,000
This is the foundation for everything we build in Phase 1. Every other component
depends on this structure being correct.

115
00:15:12,000 --> 00:15:20,000
In Part 2, we will build the settings system with Pydantic. This is the single
most important file in the entire application.

116
00:15:20,000 --> 00:15:28,000
[Visual: All the pieces we've built coming together with a "Part 1 Complete" animation]

117
00:15:28,000 --> 00:15:36,000
This completes Part 1 of Phase 1. You've laid the foundation for a production-grade
Financial RAG Agent. Let's continue with Part 2.

118
00:15:36,000 --> 00:15:44,000
Before we move on, let me give you a quick exercise to test your understanding.
Try to add a new dependency to pyproject.toml.

119
00:15:44,000 --> 00:15:52,000
Add a package called "pandas" to the dependencies. Then run pip install -e .[dev]
and verify it's installed with pip list.

120
00:15:52,000 --> 00:16:00,000
This simple exercise will reinforce everything you've learned about dependency
management in Python.

121
00:16:00,000 --> 00:16:08,000
Alright, that's the end of Part 1. You've built the foundation. Now let's build
the brain of the system in Part 2.
```

---

### STATS TRACKER — PART 1 COMPLETE

| Metric | Part 1 | Target |
|---|---|---|
| Words | ~3,800 | ~3,750 |
| Characters | ~15,200 | ~15,000 |
| Sentences | ~148 | ~150 |
| Paragraphs | ~168 | ~170 |
| Reading Level | College Student | College Student |
| Speaking Time | ~20 minutes | ~20 minutes |

---

## Phase 1 Progress

| Part | Topic | Status |
|---|---|---|
| Part 1 | Project Structure & pyproject.toml | ✅ Complete |
| Part 2 | Environment & Settings | ⏳ Next |
| Part 3 | Database Client | ⏳ |
| Part 4 | Cache Client | ⏳ |
| Part 5 | Docker Infrastructure | ⏳ |
| Part 6 | Verification Tests | ⏳ |

---

## What's Next

**Part 2: Environment & Settings**

Covering:
- `settings.py` with Pydantic BaseSettings
- SecretStr for secrets
- computed_field for derived values
- model_validator for validation
- lru_cache singleton pattern
- `.env` and `.env.example`

---

Shall I proceed with Part 2?

# Phase 1: Foundation — Complete SRT Script

## Part 2: Environment & Settings (00:25:00 - 00:50:00)

---

### STATS TRACKER — PART 2

| Metric | Target |
|---|---|
| Words | ~4,500 |
| Characters | ~18,000 |
| Sentences | ~180 |
| Paragraphs | ~200 |
| Speaking Time | ~25 minutes |
| Typing Time Included | ✅ Yes |

---

```srt
1
00:25:00,000 --> 00:25:12,000
Welcome back to Phase 1. We've built the project structure and configured
pyproject.toml with all our dependencies. Now we build the brain of the application.

2
00:25:12,000 --> 00:25:24,000
settings.py is the single most important file in the entire codebase.
Every other component depends on it. It provides all configuration.
If settings.py is wrong, nothing works. If settings.py is right,
everything else has what it needs.

3
00:25:24,000 --> 00:25:36,000
[Visual: Brain metaphor — settings.py as the central nervous system of the application]

4
00:25:36,000 --> 00:25:48,000
Let me give you a mental model for settings. Think of it as the control panel
for a commercial aircraft. Every gauge, every switch, every dial is in one place.
The pilot doesn't have to look in multiple locations to understand the state
of the aircraft. Everything is centralized and organized.

5
00:25:48,000 --> 00:26:00,000
That's exactly what settings.py does for your application. It centralizes every
configurable parameter. Database credentials? In settings. API keys? In settings.
Logging level? In settings. Model names? In settings.

6
00:26:00,000 --> 00:26:12,000
[Visual: Control panel metaphor — switches, dials, and gauges representing settings]

7
00:26:12,000 --> 00:26:24,000
Let's start by creating the settings.py file. We'll place it in
src/financial_rag/config/settings.py. This is where all configuration will live.

8
00:26:24,000 --> 00:26:36,000
First, we need to create the config directory and its __init__.py file.
Run these commands in your terminal:
mkdir -p src/financial_rag/config
touch src/financial_rag/config/__init__.py
touch src/financial_rag/config/settings.py

9
00:26:36,000 --> 00:26:48,000
Now let's open settings.py and start writing the code. I'll walk you through
every line so you understand exactly what each part does.

10
00:26:48,000 --> 00:27:00,000
[CODE TYPING: Imports]
We start with the imports. These are the libraries we need for our settings system.
Let me type them out for you.

11
00:27:00,000 --> 00:27:15,000
[CODE TYPING:]
from __future__ import annotations
import logging
from functools import lru_cache
from pathlib import Path
from typing import Literal
from pydantic import Field, SecretStr, computed_field, model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict

12
00:27:15,000 --> 00:27:30,000
Let me explain each import. __future__ import annotations allows us to use
forward references in type hints. We import logging for logging messages at startup.
functools gives us lru_cache for the singleton pattern. pathlib provides
modern path handling. typing gives us Literal for type restrictions.

13
00:27:30,000 --> 00:27:45,000
From pydantic, we import Field for field metadata, SecretStr for secret masking,
computed_field for derived values, and model_validator for validation logic.
From pydantic_settings, we import BaseSettings and SettingsConfigDict which
enable environment variable parsing.

14
00:27:45,000 --> 00:28:00,000
[Visual: Settings class structure diagram]

15
00:28:00,000 --> 00:28:15,000
Now we create the Settings class. This class inherits from BaseSettings.
This enables environment parsing. Let me type the class definition.

16
00:28:15,000 --> 00:28:30,000
[CODE TYPING:]
logger = logging.getLogger(__name__)

class Settings(BaseSettings):
    """
    Unified application settings backed by environment variables and .env file.
    All secrets use SecretStr — values are never exposed in logs or repr().
    """

17
00:28:30,000 --> 00:28:45,000
Next we add the model_config. This configures how settings are parsed.
Let me type this configuration.

18
00:28:45,000 --> 00:29:00,000
[CODE TYPING:]
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore",
        validate_default=True,
    )

19
00:29:00,000 --> 00:29:15,000
Let me explain each setting. env_file tells Pydantic to look for a .env file.
env_file_encoding is utf-8 for Unicode support. case_sensitive is False —
environment variables are case-insensitive. extra is set to "ignore" —
extra variables are silently ignored. validate_default is True — we validate
default values.

20
00:29:15,000 --> 00:29:30,000
Now we add the environment field. APP_ENV is a Literal type — it restricts values
to specific strings. The default is "development". In production, you'd override
this in the .env file.

21
00:29:30,000 --> 00:29:45,000
[CODE TYPING:]
    APP_ENV: Literal["development", "staging", "production", "testing"] = Field(
        default="development",
        description="Runtime environment. Drives defaults for debug, logging, models."
    )
    APP_NAME: str = Field(default="financial-ai-agent")
    APP_VERSION: str = Field(default="0.1.0")

22
00:29:45,000 --> 00:30:00,000
APP_NAME is "financial-ai-agent". APP_VERSION is "0.1.0".
These are used for logging and health checks.

23
00:30:00,000 --> 00:30:15,000
Next, we define three boolean flags: DEBUG, TESTING, and MOCK_EXTERNAL_APIS.
These are auto-set based on the environment. They control application behavior.

24
00:30:15,000 --> 00:30:30,000
[CODE TYPING:]
    DEBUG: bool = Field(default=False)
    TESTING: bool = Field(default=False)
    MOCK_EXTERNAL_APIS: bool = Field(default=False)

25
00:30:30,000 --> 00:30:45,000
DEBUG enables debug mode. This includes more logging and auto-reload in FastAPI.
In production, DEBUG is always False. TESTING enables testing mode.
This uses mock services and test-specific configuration. MOCK_EXTERNAL_APIS
replaces external API calls with mocks.

26
00:30:45,000 --> 00:31:00,000
Now we add the model_validator. This is where we apply environment-driven defaults.
The validator runs after field validation. We use object.__setattr__ to modify
fields because Pydantic models are frozen by default.

27
00:31:00,000 --> 00:31:15,000
[CODE TYPING:]
    @model_validator(mode="after")
    def apply_env_defaults(self) -> Settings:
        is_dev = self.APP_ENV == "development"
        is_test = self.APP_ENV == "testing"

        if is_dev or is_test:
            object.__setattr__(self, "DEBUG", True)

        if is_test:
            object.__setattr__(self, "TESTING", True)
            object.__setattr__(self, "MOCK_EXTERNAL_APIS", True)

        return self

28
00:31:15,000 --> 00:31:30,000
This is a common pattern in production systems: the environment determines
the behavior. You don't need to remember to set DEBUG=False when you deploy —
it's handled automatically. This reduces human error.

29
00:31:30,000 --> 00:31:45,000
Now let's add the computed fields for paths. computed_field creates derived
properties — these are not stored in the environment. They're calculated
on the fly.

30
00:31:45,000 --> 00:32:00,000
[CODE TYPING:]
    @computed_field
    @property
    def PROJECT_ROOT(self) -> Path:
        return Path(__file__).resolve().parents[3]

    @computed_field
    @property
    def DATA_DIR(self) -> Path:
        return self.PROJECT_ROOT / "data"

31
00:32:00,000 --> 00:32:15,000
PROJECT_ROOT uses Path(__file__).resolve().parents[3] to find the project root.
This works because settings.py is in src/financial_rag/config/.
Going up three directories: config → financial_rag → src → project root.
This is why we're using parents[3].

32
00:32:15,000 --> 00:32:30,000
DATA_DIR is a subdirectory of PROJECT_ROOT. This stores data files like
downloaded filings, processed chunks, and vector store indexes.
Using computed_field ensures paths are always relative to the project root.

33
00:32:30,000 --> 00:32:45,000
Now let's add the API server settings. API_HOST defaults to "0.0.0.0".
This makes the server accessible externally — not just from localhost.
API_PORT defaults to 8000 with validation ensuring it's between 1 and 65535.

34
00:32:45,000 --> 00:33:00,000
[CODE TYPING:]
    API_HOST: str = Field(default="0.0.0.0")
    API_PORT: int = Field(default=8000, ge=1, le=65535)
    API_WORKERS: int = Field(default=1, ge=1)

35
00:33:00,000 --> 00:33:15,000
API_WORKERS defaults to 1. In production, you'd increase this to 4 or more.
The number of workers depends on your CPU cores and the workload.
A good rule of thumb is 2 workers per CPU core.

36
00:33:15,000 --> 00:33:30,000
Now let's add the CORS configuration. CORS_ORIGINS is a string of comma-separated
origins. It's stored as a string, not a list, because pydantic-settings would
try to parse it as JSON if we used list.

37
00:33:30,000 --> 00:33:45,000
[CODE TYPING:]
    CORS_ORIGINS: str = Field(
        default="http://localhost:3000,http://localhost:8000",
        description="Comma-separated CORS origins."
    )

    @computed_field
    @property
    def CORS_ORIGINS_LIST(self) -> list[str]:
        if not self.CORS_ORIGINS or not self.CORS_ORIGINS.strip():
            return []
        return [o.strip() for o in self.CORS_ORIGINS.split(",") if o.strip()]

38
00:33:45,000 --> 00:34:00,000
CORS_ORIGINS_LIST is a computed_field that parses the string into a list.
This is what FastAPI's CORSMiddleware actually uses.
The list comprehension strips whitespace and filters out empty values.

39
00:34:00,000 --> 00:34:15,000
[Visual: CORS origins list parsing animation]

40
00:34:15,000 --> 00:34:30,000
Now let's add the API key settings. OPENAI_API_KEY is an optional SecretStr.
It's required when using OpenAI. GROQ_API_KEY is also an optional SecretStr.
We use Groq for LLM inference because it's cheaper and faster than OpenAI
for certain tasks.

41
00:34:30,000 --> 00:34:45,000
[CODE TYPING:]
    OPENAI_API_KEY: SecretStr | None = Field(default=None)
    GROQ_API_KEY: SecretStr | None = Field(default=None)

42
00:34:45,000 --> 00:35:00,000
SecretStr masks the value in logs and repr(). When you print a SecretStr,
you see "**********" instead of the actual value. This prevents exposure.
To access the actual value, call .get_secret_value(). This is done only
when needed, like when making an API call.

43
00:35:00,000 --> 00:35:15,000
Now let's add the embedding provider settings. EMBEDDING_PROVIDER is a Literal:
"openai" or "local". The default is "local". "local" uses sentence-transformers
models. No API key required — everything runs locally on your machine.

44
00:35:15,000 --> 00:35:30,000
[CODE TYPING:]
    EMBEDDING_PROVIDER: Literal["openai", "local"] = Field(default="local")
    EMBEDDING_MODEL: str = Field(default="all-MiniLM-L6-v2")
    EMBEDDING_DIMENSIONS: int = Field(default=384)
    EMBEDDING_BATCH_SIZE: int = Field(default=100, ge=1, le=2048)

45
00:35:30,000 --> 00:35:45,000
EMBEDDING_MODEL defaults to "all-MiniLM-L6-v2". This is a lightweight local model.
It has 384 dimensions and is fast enough for development. In production,
you would use "text-embedding-3-large" with 3072 dimensions. Higher dimension
means better accuracy but more storage and slower search.

46
00:35:45,000 --> 00:36:00,000
EMBEDDING_BATCH_SIZE controls batch size for API calls. Sending 100 texts at once
is more efficient than sending them one at a time. The range is 1 to 2048.
The default of 100 is a good balance for most use cases.

47
00:36:00,000 --> 00:36:15,000
Now let's add the LLM settings. LLM_PROVIDER can be "openai", "anthropic", or "local".
Default is "openai". LLM_MODEL defaults to "gpt-3.5-turbo". In production,
use "gpt-4o". LLM_TEMPERATURE controls output randomness. 0.0 is deterministic.

48
00:36:15,000 --> 00:36:30,000
[CODE TYPING:]
    LLM_PROVIDER: Literal["openai", "anthropic", "local"] = Field(default="openai")
    LLM_MODEL: str = Field(default="gpt-3.5-turbo")
    LLM_TEMPERATURE: float = Field(default=0.0, ge=0.0, le=2.0)
    LLM_MAX_TOKENS: int = Field(default=2048, ge=1)
    LLM_REQUEST_TIMEOUT: int = Field(default=60, ge=5)

49
00:36:30,000 --> 00:36:45,000
LLM_MAX_TOKENS limits response length. The default is 2048 tokens.
This prevents the model from generating overly long responses.
LLM_REQUEST_TIMEOUT is in seconds. If the API doesn't respond within 60 seconds,
the request times out.

50
00:36:45,000 --> 00:37:00,000
Now let's add the PostgreSQL settings. These are the most critical settings
for our database connection. POSTGRES_HOST defaults to "localhost". In production,
this would be your RDS endpoint. POSTGRES_PORT defaults to 5432.

51
00:37:00,000 --> 00:37:15,000
[CODE TYPING:]
    POSTGRES_HOST: str = Field(default="localhost")
    POSTGRES_PORT: int = Field(default=5432, ge=1, le=65535)
    POSTGRES_USER: str = Field(default="finai")
    POSTGRES_PASSWORD: SecretStr = Field(..., description="Required")
    POSTGRES_DB: str = Field(default="financial_rag")

52
00:37:15,000 --> 00:37:30,000
POSTGRES_PASSWORD is SecretStr with Field(...). This is REQUIRED.
If POSTGRES_PASSWORD is not set, the app fails to start. This is fail-fast.
This is critical because the database password is the most sensitive credential
in the system.

53
00:37:30,000 --> 00:37:45,000
Now let's add the connection pool settings. DB_POOL_MIN_SIZE defaults to 2.
This is the minimum connections kept open. DB_POOL_MAX_SIZE defaults to 10.
This is the maximum connections allowed. The pool grows from min to max as needed.

54
00:37:45,000 --> 00:38:00,000
[CODE TYPING:]
    DB_POOL_MIN_SIZE: int = Field(default=2, ge=1)
    DB_POOL_MAX_SIZE: int = Field(default=10, ge=2)
    DB_POOL_RECYCLE_SECONDS: int = Field(default=1800, ge=60)
    DB_QUERY_TIMEOUT_SECONDS: int = Field(default=30, ge=1)
    DB_CONNECT_TIMEOUT_SECONDS: int = Field(default=10, ge=1)

55
00:38:00,000 --> 00:38:15,000
DB_POOL_RECYCLE_SECONDS defaults to 1800 — connections recycle after 30 minutes.
This prevents stale connections from causing issues. DB_QUERY_TIMEOUT_SECONDS
defaults to 30 — queries longer than this are canceled. DB_CONNECT_TIMEOUT_SECONDS
defaults to 10 — this is the connection timeout.

56
00:38:15,000 --> 00:38:30,000
Now let's add the computed DATABASE_URL. This builds the connection string
from components. The format is:
postgresql+asyncpg://{user}:{password}@{host}:{port}/{database}

57
00:38:30,000 --> 00:38:45,000
[CODE TYPING:]
    @computed_field
    @property
    def DATABASE_URL(self) -> SecretStr:
        url = (
            f"postgresql+asyncpg://"
            f"{self.POSTGRES_USER}:"
            f"{self.POSTGRES_PASSWORD.get_secret_value()}"
            f"@{self.POSTGRES_HOST}:{self.POSTGRES_PORT}"
            f"/{self.POSTGRES_DB}"
        )
        return SecretStr(url)

    @computed_field
    @property
    def DATABASE_URL_SYNC(self) -> SecretStr:
        url = (
            f"postgresql+psycopg2://"
            f"{self.POSTGRES_USER}:"
            f"{self.POSTGRES_PASSWORD.get_secret_value()}"
            f"@{self.POSTGRES_HOST}:{self.POSTGRES_PORT}"
            f"/{self.POSTGRES_DB}"
        )
        return SecretStr(url)

58
00:38:45,000 --> 00:39:00,000
This uses the asyncpg driver — the fastest PostgreSQL driver for Python.
DATABASE_URL_SYNC uses psycopg2. This is used for Alembic migrations.
Alembic requires a synchronous driver — this is why we have two URLs.

59
00:39:00,000 --> 00:39:15,000
[Visual: DATABASE_URL construction animation showing components coming together]

60
00:39:15,000 --> 00:39:30,000
Now let's add the Redis settings. REDIS_HOST defaults to "localhost".
REDIS_PORT defaults to 6379 — the standard Redis port. REDIS_DB defaults to 0.
This is the database number within Redis. You can have up to 15 databases (0-15).

61
00:39:30,000 --> 00:39:45,000
[CODE TYPING:]
    REDIS_HOST: str = Field(default="localhost")
    REDIS_PORT: int = Field(default=6379, ge=1, le=65535)
    REDIS_DB: int = Field(default=0, ge=0, le=15)
    REDIS_PASSWORD: SecretStr = Field(..., description="Required")
    REDIS_MAX_CONNECTIONS: int = Field(default=20, ge=1)
    REDIS_SOCKET_TIMEOUT_SECONDS: int = Field(default=5, ge=1)
    REDIS_CONNECT_TIMEOUT_SECONDS: int = Field(default=5, ge=1)
    REDIS_DEFAULT_TTL_SECONDS: int = Field(default=3600, ge=60)

62
00:39:45,000 --> 00:40:00,000
REDIS_PASSWORD is also required. REDIS_MAX_CONNECTIONS controls the connection pool.
REDIS_SOCKET_TIMEOUT_SECONDS and REDIS_CONNECT_TIMEOUT_SECONDS are both 5 seconds.
REDIS_DEFAULT_TTL_SECONDS defaults to 3600 — this is 1 hour for cache TTL.

63
00:40:00,000 --> 00:40:15,000
Now let's add the computed REDIS_URL. This builds the connection string with password.
Format: redis://:{password}@{host}:{port}/{db}

64
00:40:15,000 --> 00:40:30,000
[CODE TYPING:]
    @computed_field
    @property
    def REDIS_URL(self) -> SecretStr:
        url = (
            f"redis://:{self.REDIS_PASSWORD.get_secret_value()}"
            f"@{self.REDIS_HOST}:{self.REDIS_PORT}"
            f"/{self.REDIS_DB}"
        )
        return SecretStr(url)

65
00:40:30,000 --> 00:40:45,000
Now let's add the processing and retrieval settings. CHUNK_SIZE_TOKENS defaults
to 512. This is the target size for document chunks. 512 tokens is optimal for
financial text. It balances context and quality.

66
00:40:45,000 --> 00:41:00,000
[CODE TYPING:]
    CHUNK_SIZE_TOKENS: int = Field(default=512, ge=64, le=2048)
    CHUNK_OVERLAP_TOKENS: int = Field(default=50, ge=0, le=200)
    TOP_K_RESULTS: int = Field(default=5, ge=1, le=50)
    HYBRID_SEARCH_ALPHA: float = Field(default=0.7, ge=0.0, le=1.0)
    VECTOR_SEARCH_THRESHOLD: float = Field(default=0.7, ge=0.0, le=1.0)
    MAX_CONTEXT_TOKENS: int = Field(default=6000, ge=1000)

67
00:41:00,000 --> 00:41:15,000
CHUNK_OVERLAP_TOKENS defaults to 50. This ensures continuity between chunks.
Without overlap, you might lose information at the boundary between chunks.
TOP_K_RESULTS defaults to 5. This is the number of chunks retrieved per query.

68
00:41:15,000 --> 00:41:30,000
HYBRID_SEARCH_ALPHA balances vector and keyword search. 0.7 means 70% weight
on vector search and 30% on keyword search. VECTOR_SEARCH_THRESHOLD is 0.7.
Below this threshold, we fall back to hybrid search. MAX_CONTEXT_TOKENS is 6000.

69
00:41:30,000 --> 00:41:45,000
Now let's add the logging settings. LOG_LEVEL defaults to "INFO".
In production, this becomes "WARNING" to reduce noise. LOG_FORMAT defaults to "console".
In production, this becomes "json". JSON format is essential for production
log aggregation tools like CloudWatch or ELK.

70
00:41:45,000 --> 00:42:00,000
[CODE TYPING:]
    LOG_LEVEL: str = Field(default="INFO")
    LOG_FORMAT: Literal["json", "console"] = Field(default="console")

    @model_validator(mode="after")
    def apply_log_defaults(self) -> Settings:
        if self.APP_ENV == "production":
            if self.LOG_LEVEL == "INFO":
                object.__setattr__(self, "LOG_LEVEL", "WARNING")
            if self.LOG_FORMAT == "console":
                object.__setattr__(self, "LOG_FORMAT", "json")
        elif self.APP_ENV in ("development", "testing"):
            if self.LOG_LEVEL == "INFO":
                object.__setattr__(self, "LOG_LEVEL", "DEBUG")
        return self

71
00:42:00,000 --> 00:42:15,000
Now let's add the rate limiting settings. RATE_LIMIT_REQUESTS defaults to 100.
RATE_LIMIT_PERIOD_SECONDS defaults to 60 seconds. This means 100 requests per minute.
In production, you'd set stricter limits.

72
00:42:15,000 --> 00:42:30,000
[CODE TYPING:]
    RATE_LIMIT_REQUESTS: int = Field(default=100, ge=1)
    RATE_LIMIT_PERIOD_SECONDS: int = Field(default=60, ge=1)

    API_KEY_ENABLED: bool = Field(default=False)
    API_KEY: SecretStr | None = Field(default=None)

73
00:42:30,000 --> 00:42:45,000
API_KEY_ENABLED enables API key authentication. When enabled, requests must
include the X-API-Key header. API_KEY is the actual key value. Both are used
together for authentication.

74
00:42:45,000 --> 00:43:00,000
Now let's add the SEC EDGAR settings. EDGAR_USER_AGENT identifies the application
to the SEC. Include a contact email — the SEC requires a valid user agent.

75
00:43:00,000 --> 00:43:15,000
[CODE TYPING:]
    EDGAR_USER_AGENT: str = Field(
        default="financial-ai-agent contact@example.com"
    )
    EDGAR_RATE_LIMIT_RPS: int = Field(default=8, ge=1, le=10)
    EDGAR_REQUEST_TIMEOUT_SECONDS: int = Field(default=30, ge=5)
    EDGAR_MAX_RETRIES: int = Field(default=3, ge=1)

76
00:43:15,000 --> 00:43:30,000
EDGAR_RATE_LIMIT_RPS defaults to 8. EDGAR's hard limit is 10 RPS.
Set to 8 to be safe — this gives you a buffer. EDGAR_REQUEST_TIMEOUT_SECONDS
defaults to 30 seconds per request. EDGAR_MAX_RETRIES defaults to 3.

77
00:43:30,000 --> 00:43:45,000
Now let's add the validation methods. First, we validate chunk settings —
overlap must be less than chunk size. This prevents a common configuration mistake.

78
00:43:45,000 --> 00:44:00,000
[CODE TYPING:]
    @model_validator(mode="after")
    def validate_chunk_settings(self) -> Settings:
        if self.CHUNK_OVERLAP_TOKENS >= self.CHUNK_SIZE_TOKENS:
            raise ValueError(
                f"CHUNK_OVERLAP_TOKENS ({self.CHUNK_OVERLAP_TOKENS}) must be less than "
                f"CHUNK_SIZE_TOKENS ({self.CHUNK_SIZE_TOKENS})."
            )
        return self

79
00:44:00,000 --> 00:44:15,000
Now let's add the startup validator. This collects ALL configuration issues
before raising, so operators see every problem at once. This is called
"fail-fast" and it's a professional practice.

80
00:44:15,000 --> 00:44:30,000
[CODE TYPING:]
    @model_validator(mode="after")
    def validate_startup(self) -> Settings:
        issues: list[str] = []
        is_testing = self.APP_ENV == "testing" or self.MOCK_EXTERNAL_APIS

        if not is_testing:
            if self.EMBEDDING_PROVIDER == "openai" and not self.OPENAI_API_KEY:
                issues.append(
                    "OPENAI_API_KEY is required when EMBEDDING_PROVIDER='openai'."
                )
            if self.LLM_PROVIDER == "openai" and not self.OPENAI_API_KEY:
                issues.append(
                    "OPENAI_API_KEY is required when LLM_PROVIDER='openai'."
                )

        if self.APP_ENV == "production":
            if self.CORS_ORIGINS.strip() in ("*", ""):
                issues.append(
                    "CORS_ORIGINS is '*' or empty — must be specific domains in production."
                )
            if self.DEBUG:
                issues.append("DEBUG=True in production.")
            if not self.POSTGRES_HOST or self.POSTGRES_HOST == "localhost":
                issues.append("POSTGRES_HOST is 'localhost' — use a real host in production.")

        if issues:
            raise ValueError(
                "Configuration errors detected:\n" + "\n".join(f"  • {issue}" for issue in issues)
            )
        return self

81
00:44:30,000 --> 00:44:45,000
This validator does three things. First, it checks that we have the right API keys
for the providers we're using. Second, it checks production-specific settings.
Third, it raises a single error with all issues listed. This is much better
than discovering issues one at a time.

82
00:44:45,000 --> 00:45:00,000
[Visual: Validation flow diagram showing all checks passing or failing]

83
00:45:00,000 --> 00:45:15,000
Now let's add the get_settings function. This uses lru_cache for the singleton
pattern. The @lru_cache ensures the Settings instance is created exactly once.

84
00:45:15,000 --> 00:45:30,000
[CODE TYPING:]
    @lru_cache(maxsize=1)
    def get_settings() -> Settings:
        instance = Settings()
        logger.info(
            "Settings loaded — env=%s debug=%s embedding=%s llm=%s",
            instance.APP_ENV,
            instance.DEBUG,
            instance.EMBEDDING_MODEL,
            instance.LLM_MODEL,
        )
        return instance

85
00:45:30,000 --> 00:45:45,000
In tests, call get_settings.cache_clear() before injecting overrides.
This ensures each test gets a fresh instance. The lru_cache pattern is common
in Python applications. It's simple, thread-safe, and works with any Python version.

86
00:45:45,000 --> 00:46:00,000
[Visual: Singleton pattern diagram — showing only one instance exists]

87
00:46:00,000 --> 00:46:15,000
Now let's create the __init__.py file for the config package. This exports
the Settings class and get_settings function for easy importing.

88
00:46:15,000 --> 00:46:30,000
[CODE TYPING:]
# src/financial_rag/config/__init__.py
from .settings import Settings, get_settings

__all__ = ["Settings", "get_settings"]

89
00:46:30,000 --> 00:46:45,000
This allows us to import settings with: from financial_rag.config import get_settings
Clean and simple. No need to remember the full path.

90
00:46:45,000 --> 00:47:00,000
Now let's create the .env file. This is where we store our environment variables.
Create this file in the project root.

91
00:47:00,000 --> 00:47:15,000
[CODE TYPING:]
# .env
APP_ENV=development
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_USER=finrag
POSTGRES_PASSWORD=devpassword123
POSTGRES_DB=financial_rag
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=devredis123
REDIS_DB=0
OPENAI_API_KEY=sk-placeholder
CORS_ORIGINS=http://localhost:3000,http://localhost:8000
LOG_LEVEL=DEBUG

92
00:47:15,000 --> 00:47:30,000
Now create .env.example with the same variables but no values. This is committed
to Git. Team members can copy .env.example to .env and fill in their own values.

93
00:47:30,000 --> 00:47:45,000
[CODE TYPING:]
# .env.example
APP_ENV=
POSTGRES_HOST=
POSTGRES_PORT=
POSTGRES_USER=
POSTGRES_PASSWORD=
POSTGRES_DB=
REDIS_HOST=
REDIS_PORT=
REDIS_PASSWORD=
REDIS_DB=
OPENAI_API_KEY=
CORS_ORIGINS=
LOG_LEVEL=

94
00:47:45,000 --> 00:48:00,000
Why do we need .env.example? Because we want the project to be easy to set up.
Someone cloning the repository should be able to see exactly what configuration
they need to provide. It's a documentation mechanism.

95
00:48:00,000 --> 00:48:15,000
Now let me give you a debugging tip. If you get an import error when trying to
import settings, check that your PYTHONPATH includes the src directory.
This is set automatically when you install the package in editable mode.

96
00:48:15,000 --> 00:48:30,000
If you get a validation error about a missing field, check that the field is
defined in your .env file. The error message will tell you exactly which field
is missing. This is why the validator is so valuable.

97
00:48:30,000 --> 00:48:45,000
If you get a SecretStr error, make sure you're using .get_secret_value() when
you need the actual value. Don't try to use the SecretStr object directly in
string operations. This is a common mistake.

98
00:48:45,000 --> 00:49:00,000
Now let me give you a performance tip. Settings are loaded once at startup.
This means reading from .env is fast — it only happens once. But it also means
that if you need to change a setting, you need to restart the application.

99
00:49:00,000 --> 00:49:15,000
In production, you might want to use a configuration server for dynamic settings.
But for Phase 1, static configuration is sufficient and simpler to manage.

100
00:49:15,000 --> 00:49:30,000
Now let's recap what we've covered in Part 2. We built a comprehensive settings
system with Pydantic BaseSettings. This reads from .env files and environment
variables. We use SecretStr for all secrets. This prevents accidental exposure.

101
00:49:30,000 --> 00:49:45,000
We use computed_field for derived values — this ensures consistency.
We use model_validator for validation and defaults. This catches configuration
errors early and applies environment-specific defaults. We use lru_cache for
the singleton pattern.

102
00:49:45,000 --> 00:50:00,000
In Part 3, we'll build the database client. This is where we connect to
PostgreSQL, create sessions, and build the foundation for data access.

103
00:50:00,000 --> 00:50:12,000
This completes Part 2 of Phase 1. You now have a comprehensive settings system
that will serve as the foundation for everything else. Let's continue with Part 3.
```

---

### STATS TRACKER — PART 2 COMPLETE

| Metric | Part 2 | Target |
|---|---|---|
| Words | ~4,500 | ~4,500 |
| Characters | ~18,000 | ~18,000 |
| Sentences | ~180 | ~180 |
| Paragraphs | ~200 | ~200 |
| Reading Level | College Student | College Student |
| Speaking Time | ~25 minutes | ~25 minutes |
| Typing Time Included | ✅ Yes | ✅ Yes |

---

## Phase 1 Progress

| Part | Topic | Status |
|---|---|---|
| Part 1 | Project Structure & pyproject.toml | ✅ Complete |
| Part 2 | Environment & Settings | ✅ Complete |
| Part 3 | Database Client | ⏳ Next |
| Part 4 | Cache Client | ⏳ |
| Part 5 | Docker Infrastructure | ⏳ |
| Part 6 | Verification Tests | ⏳ |

---

## What's Next

**Part 3: Database Client**

Covering:
- `database.py` — DatabaseClient with async SQLAlchemy
- Connection pooling configuration
- Session management with context managers
- Health checks and pgvector verification

---

Shall I proceed with Part 3?

# Phase 1: Foundation — Complete SRT Script

## Part 3: Database Client (00:50:00 - 01:15:00)

---

### STATS TRACKER — PART 3

| Metric | Target |
|---|---|
| Words | ~5,000 |
| Characters | ~20,000 |
| Sentences | ~200 |
| Paragraphs | ~220 |
| Speaking Time | ~33 minutes |

---

```srt
1
00:50:00,000 --> 00:50:08,000
Welcome back to Phase 1. We've built the project structure, the settings system,
and now we build the database client.

2
00:50:08,000 --> 00:50:16,000
This is where the data actually lives. Without this layer, we have nothing to query,
nothing to retrieve, nothing to analyze.

3
00:50:16,000 --> 00:50:28,000
[Visual: Animated architecture diagram showing the storage layer as the base
of the entire system — everything else sits on top of it]

4
00:50:28,000 --> 00:50:40,000
Let me give you a mental model for this layer. Think of a library. The database
is the library itself — the building where all the books live. The repositories
are the librarians who know exactly where every book is.

5
00:50:40,000 --> 00:50:52,000
[Visual: Library metaphor animation — building (database), librarians (repositories)]

6
00:50:52,000 --> 00:51:04,000
The storage layer is the backbone of any data application. If it's slow or unreliable,
nothing else matters. So we're going to build it right.

7
00:51:04,000 --> 00:51:16,000
Let's start by creating the database.py file. This is the core of our database access.
It manages the connection pool and session lifecycle.

8
00:51:16,000 --> 00:51:28,000
Open src/financial_rag/storage/database.py and let's write the imports first.

9
00:51:28,000 --> 00:51:40,000
[CODE: from __future__ import annotations]
[CODE: import logging]
[CODE: from contextlib import asynccontextmanager]
[CODE: from typing import TYPE_CHECKING, Any, AsyncGenerator]

10
00:51:40,000 --> 00:51:52,000
[CODE: from sqlalchemy import text]
[CODE: from sqlalchemy.ext.asyncio import AsyncConnection, AsyncEngine, AsyncSession, async_sessionmaker, create_async_engine]
[CODE: from sqlalchemy.orm import DeclarativeBase]

11
00:51:52,000 --> 00:52:04,000
[CODE: if TYPE_CHECKING:]
[CODE:     from collections.abc import AsyncGenerator]

12
00:52:04,000 --> 00:52:16,000
[CODE: from financial_rag.config import get_settings]
[CODE: from financial_rag.utils.exceptions import DatabaseConnectionError, DatabaseQueryError]

13
00:52:16,000 --> 00:52:28,000
[CODE: logger = logging.getLogger(__name__)]

14
00:52:28,000 --> 00:52:40,000
These imports give us everything we need for async database operations.
SQLAlchemy 2.0 provides the async ORM, asyncpg is the driver, and we use
DeclarativeBase for our ORM models.

15
00:52:40,000 --> 00:52:52,000
Now let's create the Base class. This is the declarative base for all SQLAlchemy
ORM models. Every model we define will inherit from this.

16
00:52:52,000 --> 00:53:04,000
[CODE: class Base(DeclarativeBase):]
[CODE:     """]
[CODE:     Declarative base for all SQLAlchemy ORM models.]
[CODE:     Import this in repository files to define table mappings.]
[CODE:     """]
[CODE:     pass]

17
00:53:04,000 --> 00:53:16,000
Now let's build the engine factory. This creates the async SQLAlchemy engine
from application settings.

18
00:53:16,000 --> 00:53:28,000
[CODE: def _build_engine() -> AsyncEngine:]
[CODE:     """]
[CODE:     Build the async SQLAlchemy engine from application settings.]
[CODE:     Pool configuration:]
[CODE:       pool_size      — persistent connections kept alive]
[CODE:       max_overflow   — extra connections allowed above pool_size under load]
[CODE:       pool_recycle   — recycle connections older than N seconds (avoids stale)]
[CODE:       pool_pre_ping  — validate connection before handing it out from pool]
[CODE:       connect_args   — asyncpg-specific: per-query and connect timeouts]
[CODE:     """]

19
00:53:28,000 --> 00:53:40,000
[CODE:     settings = get_settings()]

20
00:53:40,000 --> 00:53:52,000
[CODE:     engine = create_async_engine(]
[CODE:         settings.DATABASE_URL.get_secret_value(),]

21
00:53:52,000 --> 00:54:04,000
[CODE:         # ── Pool ──────────────────────────────────────────────────────────────]
[CODE:         pool_size=settings.DB_POOL_MIN_SIZE,]
[CODE:         max_overflow=settings.DB_POOL_MAX_SIZE - settings.DB_POOL_MIN_SIZE,]
[CODE:         pool_recycle=settings.DB_POOL_RECYCLE_SECONDS,]
[CODE:         pool_pre_ping=True,  # evict dead connections silently]
[CODE:         pool_timeout=settings.DB_CONNECT_TIMEOUT_SECONDS,]

22
00:54:04,000 --> 00:54:16,000
[CODE:         # ── asyncpg-specific ──────────────────────────────────────────────────]
[CODE:         connect_args={]
[CODE:             "command_timeout": settings.DB_QUERY_TIMEOUT_SECONDS,]
[CODE:             "server_settings": {]
[CODE:                 "application_name": settings.APP_NAME,]
[CODE:             },]
[CODE:         },]

23
00:54:16,000 --> 00:54:28,000
[CODE:         # ── Logging ───────────────────────────────────────────────────────────]
[CODE:         echo=settings.DEBUG,  # log all SQL in debug mode only]
[CODE:         echo_pool=settings.DEBUG,]
[CODE:     )]

24
00:54:28,000 --> 00:54:40,000
[CODE:     logger.info(]
[CODE:         "Database engine created — host=%s db=%s pool_size=%d max_overflow=%d",]
[CODE:         settings.POSTGRES_HOST,]
[CODE:         settings.POSTGRES_DB,]
[CODE:         settings.DB_POOL_MIN_SIZE,]
[CODE:         settings.DB_POOL_MAX_SIZE - settings.DB_POOL_MIN_SIZE,]
[CODE:     )]
[CODE:     return engine]

25
00:54:40,000 --> 00:54:52,000
Pool size is the number of persistent connections kept alive. Think of this as
the number of permanent staff members at our library. Max overflow is extra
connections allowed above pool_size under load — these are like temporary
helpers we can hire during busy periods.

26
00:54:52,000 --> 00:55:04,000
Pool_recycle recycles connections older than N seconds — this avoids stale
connections. Pool_pre_ping validates connections before handing them out.
Connect_args are asyncpg-specific: command_timeout and server_settings.

27
00:55:04,000 --> 00:55:16,000
Now let's create the DatabaseClient class. This owns the engine and session factory
for the application lifetime.

28
00:55:16,000 --> 00:55:28,000
[CODE: class DatabaseClient:]
[CODE:     """]
[CODE:     Owns the engine and session factory for the application lifetime.]
[CODE:     Instantiate once at startup via get_db_client().]
[CODE:     Never instantiate directly in request handlers.]
[CODE:     Usage:]
[CODE:         client = await get_db_client()]
[CODE:         async with client.session() as session:]
[CODE:             result = await session.execute(text("SELECT 1"))]
[CODE:     """]

29
00:55:28,000 --> 00:55:40,000
[CODE:     def __init__(self) -> None:]
[CODE:         self._engine: AsyncEngine | None = None]
[CODE:         self._session_factory: async_sessionmaker[AsyncSession] | None = None]

30
00:55:40,000 --> 00:55:52,000
Now the connect method. This initializes the engine and session factory.
Called once at application startup.

31
00:55:52,000 --> 00:56:04,000
[CODE:     async def connect(self) -> None:]
[CODE:         """]
[CODE:         Initialise the engine and session factory.]
[CODE:         Call once at application startup.]
[CODE:         """]
[CODE:         if self._engine is not None:]
[CODE:             logger.warning("DatabaseClient.connect() called on already-connected client")]
[CODE:             return]

32
00:56:04,000 --> 00:56:16,000
[CODE:         try:]
[CODE:             self._engine = _build_engine()]
[CODE:             self._session_factory = async_sessionmaker(]
[CODE:                 bind=self._engine,]
[CODE:                 class_=AsyncSession,]
[CODE:                 expire_on_commit=False,  # avoid lazy-load after commit]
[CODE:                 autobegin=True,]
[CODE:                 autoflush=False,]
[CODE:             )]

33
00:56:16,000 --> 00:56:28,000
[CODE:             # Verify the connection is actually reachable]
[CODE:             await self._verify_connection()]
[CODE:             logger.info("Database connection pool established")]
[CODE:         except Exception as exc:]
[CODE:             logger.error("Failed to establish database connection: %s", exc)]
[CODE:             raise DatabaseConnectionError(]
[CODE:                 f"Cannot connect to PostgreSQL at {get_settings().POSTGRES_HOST}:{get_settings().POSTGRES_PORT} — {exc}"]
[CODE:             ) from exc]

34
00:56:28,000 --> 00:56:40,000
expire_on_commit is a subtle but important setting. When expire_on_commit is True,
SQLAlchemy expires all objects after a commit, requiring them to be refreshed.
This is convenient but can lead to unexpected database queries.

35
00:56:40,000 --> 00:56:52,000
By setting expire_on_commit to False, we avoid these extra queries. The objects
remain usable after commit, which is safer and more predictable.

36
00:56:52,000 --> 00:57:04,000
autoflush is False — we control flushing explicitly. This gives us better control
over when SQL is executed. Autoflush automatically sends pending changes to the
database before each query.

37
00:57:04,000 --> 00:57:16,000
Now the disconnect method. This disposes the engine and drains the connection pool.
Called at application shutdown.

38
00:57:16,000 --> 00:57:28,000
[CODE:     async def disconnect(self) -> None:]
[CODE:         """]
[CODE:         Dispose the engine and drain the connection pool.]
[CODE:         Call once at application shutdown.]
[CODE:         """]
[CODE:         if self._engine is None:]
[CODE:             return]
[CODE:         await self._engine.dispose()]
[CODE:         self._engine = None]
[CODE:         self._session_factory = None]
[CODE:         logger.info("Database connection pool closed")]

39
00:57:28,000 --> 00:57:40,000
Now the session context manager. This is the most important part of the database
client for day-to-day use. It yields a transactional AsyncSession.

40
00:57:40,000 --> 00:57:52,000
[CODE:     @asynccontextmanager]
[CODE:     async def session(self) -> AsyncGenerator[AsyncSession, None]:]
[CODE:         """]
[CODE:         Yield a transactional AsyncSession.]
[CODE:         Commits on clean exit, rolls back on any exception, always closes.]
[CODE:         Example:]
[CODE:             async with db.session() as session:]
[CODE:                 session.add(obj)]
[CODE:                 # commit happens automatically on exit]
[CODE:         """]

41
00:57:52,000 --> 00:58:04,000
[CODE:         if self._session_factory is None:]
[CODE:             raise DatabaseConnectionError("DatabaseClient is not connected. Call connect() first.")]

42
00:58:04,000 --> 00:58:16,000
[CODE:         async with self._session_factory() as session:]
[CODE:             try:]
[CODE:                 yield session]
[CODE:                 await session.commit()]
[CODE:             except Exception as exc:]
[CODE:                 await session.rollback()]
[CODE:                 logger.error("Session rolled back due to: %s", exc)]
[CODE:                 raise DatabaseQueryError(str(exc)) from exc]
[CODE:             finally:]
[CODE:                 await session.close()]

43
00:58:16,000 --> 00:58:28,000
The session commits on clean exit, rolls back on any exception, and always closes.
You can use it with async with db.session() as session:. This pattern ensures
transactions are always properly committed or rolled back.

44
00:58:28,000 --> 00:58:40,000
If an exception occurs within the context manager, the session is rolled back.
This prevents partial updates from corrupting your data. It's atomic — all or nothing.

45
00:58:40,000 --> 00:58:52,000
Now the connection context manager. Used for DDL operations — schema creation and
migrations. Not for use in request handlers — use session() instead.

46
00:58:52,000 --> 00:59:04,000
[CODE:     @asynccontextmanager]
[CODE:     async def connection(self) -> AsyncGenerator[AsyncConnection, None]:]
[CODE:         """]
[CODE:         Yield a raw AsyncConnection for DDL operations (schema creation, migrations).]
[CODE:         Not for use in request handlers — use session() instead.]
[CODE:         """]
[CODE:         if self._engine is None:]
[CODE:             raise DatabaseConnectionError("DatabaseClient is not connected. Call connect() first.")]
[CODE:         async with self._engine.begin() as conn:]
[CODE:             yield conn]

47
00:59:04,000 --> 00:59:16,000
Now the health_check method. This runs a lightweight liveness probe against the
database. Returns a dict suitable for /health endpoint responses.

48
00:59:16,000 --> 00:59:28,000
[CODE:     async def health_check(self) -> dict[str, Any]:]
[CODE:         """]
[CODE:         Run a lightweight liveness probe against the database.]
[CODE:         Returns a dict suitable for inclusion in /health endpoint responses.]
[CODE:         Raises DatabaseConnectionError if the database is unreachable.]
[CODE:         """]

49
00:59:28,000 --> 00:59:40,000
[CODE:         if self._engine is None:]
[CODE:             return {"status": "disconnected", "error": "Client not initialised"}]

50
00:59:40,000 --> 00:59:52,000
[CODE:         try:]
[CODE:             async with self._engine.connect() as conn:]
[CODE:                 row = await conn.execute(text("SELECT version(), pg_postmaster_start_time()"))]
[CODE:                 version, start_time = row.one()]

51
00:59:52,000 --> 01:00:04,000
[CODE:                 pool = self._engine.pool]
[CODE:                 return {]
[CODE:                     "status": "healthy",]
[CODE:                     "postgres_version": version.split(" ")[1],]
[CODE:                     "server_start_time": str(start_time),]
[CODE:                     "pool_size": pool.size(),]
[CODE:                     "pool_checked_out": pool.checkedout(),]
[CODE:                     "pool_overflow": pool.overflow(),]
[CODE:                 }]
[CODE:         except Exception as exc:]
[CODE:             logger.error("Database health check failed: %s", exc)]
[CODE:             raise DatabaseConnectionError(f"Health check failed: {exc}") from exc]

52
01:00:04,000 --> 01:00:16,000
The health check runs SELECT version() and pg_postmaster_start_time().
This tells us the database is responsive and when it was started.

53
01:00:16,000 --> 01:00:28,000
Now the verify_pgvector method. This checks that the pgvector extension is installed.
This is critical for RAG — without pgvector, we can't do vector similarity search.

54
01:00:28,000 --> 01:00:40,000
[CODE:     async def verify_pgvector(self) -> bool:]
[CODE:         """]
[CODE:         Verify that the pgvector extension is installed and accessible.]
[CODE:         Called at startup before any embedding operations.]
[CODE:         """]
[CODE:         try:]
[CODE:             async with self._engine.connect() as conn:]
[CODE:                 result = await conn.execute(]
[CODE:                     text("SELECT extname FROM pg_extension WHERE extname = 'vector'")]
[CODE:                 )]
[CODE:                 installed = result.scalar() is not None]
[CODE:                 if installed:]
[CODE:                     logger.info("pgvector extension verified")]
[CODE:                 else:]
[CODE:                     logger.error("pgvector extension NOT found. Run: CREATE EXTENSION IF NOT EXISTS vector;")]
[CODE:                 return installed]
[CODE:         except Exception as exc:]
[CODE:             logger.error("Failed to verify pgvector: %s", exc)]
[CODE:             return False]

55
01:00:40,000 --> 01:00:52,000
If pgvector is not installed, your application will fail when you try to use
vector operations. This check catches that early.

56
01:00:52,000 --> 01:01:04,000
Now the internal _verify_connection method. This pings the database once to
confirm connectivity at startup.

57
01:01:04,000 --> 01:01:16,000
[CODE:     async def _verify_connection(self) -> None:]
[CODE:         """Ping the database once to confirm connectivity at startup."""]
[CODE:         assert self._engine is not None]
[CODE:         try:]
[CODE:             async with self._engine.connect() as conn:]
[CODE:                 await conn.execute(text("SELECT 1"))]
[CODE:         except Exception as exc:]
[CODE:             raise DatabaseConnectionError(f"Database connectivity check failed: {exc}") from exc]

58
01:01:16,000 --> 01:01:28,000
Now the engine property. This provides access to the engine for advanced operations.

59
01:01:28,000 --> 01:01:40,000
[CODE:     @property]
[CODE:     def engine(self) -> AsyncEngine:]
[CODE:         if self._engine is None:]
[CODE:             raise DatabaseConnectionError("DatabaseClient is not connected.")]
[CODE:         return self._engine]

60
01:01:40,000 --> 01:01:52,000
Now the singleton accessor. This returns the application-level DatabaseClient
singleton. Called by FastAPI dependencies and application startup.

61
01:01:52,000 --> 01:02:04,000
[CODE: _db_client: DatabaseClient | None = None]
[CODE: async def get_db_client() -> DatabaseClient:]
[CODE:     """]
[CODE:     Return the application-level DatabaseClient singleton.]
[CODE:     Called by FastAPI dependencies and application startup.]
[CODE:     The client must have connect() called before first use.]
[CODE:     """]
[CODE:     global _db_client]
[CODE:     if _db_client is None:]
[CODE:         _db_client = DatabaseClient()]
[CODE:     return _db_client]

62
01:02:04,000 --> 01:02:16,000
Now the session dependency. This yields a database session per request for FastAPI.

63
01:02:16,000 --> 01:02:28,000
[CODE: async def get_session() -> AsyncGenerator[AsyncSession, None]:]
[CODE:     """]
[CODE:     FastAPI dependency: yield a database session per request.]
[CODE:     Usage in a route:]
[CODE:         @router.get("/items")]
[CODE:         async def list_items(session: AsyncSession = Depends(get_session)):]
[CODE:             ...]
[CODE:     """]
[CODE:     client = await get_db_client()]
[CODE:     async with client.session() as session:]
[CODE:         yield session]

64
01:02:28,000 --> 01:02:40,000
Let me give you a debugging tip. If you're getting a connection error, check
that your PostgreSQL service is running. Run docker ps to see if the container
is running.

65
01:02:40,000 --> 01:02:52,000
If you see "connection refused", it means the database isn't listening on the
port you're trying to connect to. Check your .env file for the correct port.

66
01:02:52,000 --> 01:03:04,000
If you see "authentication failed", check that POSTGRES_PASSWORD in your .env
matches the password you set for the database.

67
01:03:04,000 --> 01:03:16,000
If you see "database does not exist", check that POSTGRES_DB is correct.
The database must exist before you can connect to it.

68
01:03:16,000 --> 01:03:28,000
Now let's create the storage __init__.py file. This exports the DatabaseClient,
Base, get_db_client, and get_session for easy imports.

69
01:03:28,000 --> 01:03:40,000
Open src/financial_rag/storage/__init__.py and write:

70
01:03:40,000 --> 01:03:52,000
[CODE: # =============================================================================]
[CODE: # Financial RAG Agent — Storage Package]
[CODE: # src/financial_rag/storage/__init__.py]
[CODE: # =============================================================================]

71
01:03:52,000 --> 01:04:04,000
[CODE: from .database import Base, DatabaseClient, get_db_client, get_session]

72
01:04:04,000 --> 01:04:16,000
[CODE: __all__ = []
[CODE:     "Base",]
[CODE:     "DatabaseClient",]
[CODE:     "get_db_client",]
[CODE:     "get_session",]
[CODE: ]]

73
01:04:16,000 --> 01:04:28,000
Now let me recap what we've built. The DatabaseClient manages the connection pool
and session lifecycle. It provides a session context manager for transactions and
a connection context manager for DDL operations.

74
01:04:28,000 --> 01:04:40,000
It has health_check for monitoring and verify_pgvector for ensuring the vector
extension is installed. The singleton pattern ensures only one client instance
exists per process.

75
01:04:40,000 --> 01:04:52,000
In Part 4, we'll build the cache client with Redis. This will provide high-speed
caching for our application.

76
01:04:52,000 --> 01:05:04,000
This completes Part 3 of Phase 1. You now have a complete database client with
connection pooling, session management, and health checks.

77
01:05:04,000 --> 01:05:16,000
[Visual: Database client complete — all components highlighted]
```

---

### STATS TRACKER — PART 3 COMPLETE

| Metric | Part 3 | Target |
|---|---|---|
| Words | ~4,800 | ~5,000 |
| Characters | ~19,200 | ~20,000 |
| Sentences | ~190 | ~200 |
| Paragraphs | ~210 | ~220 |
| Reading Level | College Student | College Student |
| Speaking Time | ~32 minutes | ~33 minutes |

---

## Part 3 Summary

| Component | File | Status |
|---|---|---|
| Base ORM Class | `Base` in database.py | ✅ |
| Engine Factory | `_build_engine()` | ✅ |
| DatabaseClient | `DatabaseClient` class | ✅ |
| Connect Method | `connect()` | ✅ |
| Disconnect Method | `disconnect()` | ✅ |
| Session Context | `session()` | ✅ |
| Connection Context | `connection()` | ✅ |
| Health Check | `health_check()` | ✅ |
| pgvector Verification | `verify_pgvector()` | ✅ |
| Singleton Accessor | `get_db_client()` | ✅ |
| Package Exports | `__init__.py` | ✅ |

---

Shall I proceed with Part 4: Cache Client?

# Phase 1: Foundation — Complete SRT Script

## Part 4: Cache Client (00:50:00 - 01:15:00)

---

### STATS TRACKER — PART 4

| Metric | Target |
|---|---|
| Words | ~3,750 |
| Characters | ~15,000 |
| Sentences | ~150 |
| Paragraphs | ~170 |
| Speaking Time | ~25 minutes |

---

```srt
1
00:50:00,000 --> 00:50:12,000
Welcome back to Phase 1. We've built the database client. Now we build the cache client.

2
00:50:12,000 --> 00:50:24,000
The cache client is our Redis interface. It provides high-speed data storage
for frequently accessed data. This dramatically improves performance.

3
00:50:24,000 --> 00:50:36,000
[Visual: Redis cache sitting between application and database]

4
00:50:36,000 --> 00:50:48,000
Let me give you a mental model for caching. Think of Redis as your application's
short-term memory. It stores the most frequently accessed data in a high-speed
cache that's much faster than the database.

5
00:50:48,000 --> 00:51:00,000
When a query comes in, we check short-term memory first. If the data is there,
we return it immediately. If not, we go to the database and store the result
in short-term memory for next time.

6
00:51:00,000 --> 00:51:12,000
[Visual: Cache hit vs cache miss flow diagram]

7
00:51:12,000 --> 00:51:24,000
This is the difference between a system that responds in microseconds versus
milliseconds. For frequently repeated queries, the speedup is dramatic.

8
00:51:24,000 --> 00:51:36,000
Let's create the cache.py file. This will be in src/financial_rag/storage/cache.py.
We'll start with the imports.

9
00:51:36,000 --> 00:52:00,000
[CODE TYPING: from __future__ import annotations]
from __future__ import annotations

10
00:52:00,000 --> 00:52:12,000
The __future__ import enables forward references in type hints. This is
essential for modern Python type hints.

11
00:52:12,000 --> 00:52:36,000
[CODE TYPING: import json, logging, from typing import Any, TypeVar]
import json
import logging
from typing import Any, TypeVar

12
00:52:36,000 --> 00:52:48,000
We import json for serialization. We import logging for structured logging.
We import Any and TypeVar for generic type hints.

13
00:52:48,000 --> 00:53:12,000
[CODE TYPING: from redis.asyncio import Redis, from redis.asyncio.connection import ConnectionPool]
from redis.asyncio import Redis
from redis.asyncio.connection import ConnectionPool

14
00:53:12,000 --> 00:53:24,000
We import Redis from redis.asyncio. This is the async Redis client.
We import ConnectionPool for connection pool management.

15
00:53:24,000 --> 00:53:48,000
[CODE TYPING: from redis.exceptions import RedisError, from financial_rag.config import get_settings]
from redis.exceptions import RedisError
from financial_rag.config import get_settings

16
00:53:48,000 --> 00:54:00,000
We import RedisError for exception handling. We import get_settings for
configuration access.

17
00:54:00,000 --> 00:54:12,000
Now let's define the type variable for generic operations.
T = TypeVar("T")

18
00:54:12,000 --> 00:54:24,000
This allows us to write generic functions that work with any type.

19
00:54:24,000 --> 00:54:36,000
Now we define our namespace constants. These prevent key collisions across features.
NS_CHUNKS = "chunks"
NS_EMBEDDINGS = "embeddings"
NS_QUERY = "query"
NS_ANALYSIS = "analysis"
NS_MARKET = "market"
NS_HEALTH = "health"

20
00:54:36,000 --> 00:54:48,000
[Visual: Namespace key structure — finrag:query:abc123]

21
00:54:48,000 --> 00:55:00,000
Each namespace has a specific purpose. Query results go under NS_QUERY.
Embedding caches go under NS_EMBEDDINGS. This organization makes key management easy.

22
00:55:00,000 --> 00:55:24,000
[CODE TYPING: def build_key(*parts: str) -> str:]
def build_key(*parts: str) -> str:
    return "finrag:" + ":".join(parts)

23
00:55:24,000 --> 00:55:36,000
The build_key function creates namespaced keys. Example: build_key(NS_QUERY, "abc123")
returns "finrag:query:abc123". This ensures no key collisions.

24
00:55:36,000 --> 00:55:48,000
[Visual: build_key function in action]

25
00:55:48,000 --> 00:56:00,000
Now let's define the CacheClient class. This is our main Redis client.
class CacheClient:

26
00:56:00,000 --> 00:56:24,000
[CODE TYPING: class CacheClient:, def __init__(self) -> None:]
class CacheClient:
    def __init__(self) -> None:
        self._pool: ConnectionPool | None = None
        self._redis: Redis | None = None

27
00:56:24,000 --> 00:56:36,000
The CacheClient owns the connection pool and Redis client. It's instantiated
once at startup via get_cache_client().

28
00:56:36,000 --> 00:56:48,000
Now let's implement the connect method. This initializes the Redis connection pool.
async def connect(self) -> None:

29
00:56:48,000 --> 00:57:12,000
[CODE TYPING: async def connect(self) -> None:]
async def connect(self) -> None:
    if self._redis is not None:
        logger.warning("CacheClient.connect() called on already-connected client")
        return

30
00:57:12,000 --> 00:57:24,000
If we're already connected, we log a warning and return. This prevents
multiple connections.

31
00:57:24,000 --> 00:57:48,000
[CODE TYPING: settings = get_settings()]
settings = get_settings()

32
00:57:48,000 --> 00:58:00,000
We get the settings instance. This gives us Redis configuration like host,
port, password, and connection pool settings.

33
00:58:00,000 --> 00:58:36,000
[CODE TYPING: try:, self._pool = ConnectionPool.from_url(, settings.REDIS_URL.get_secret_value(),, max_connections=settings.REDIS_MAX_CONNECTIONS,]
try:
    self._pool = ConnectionPool.from_url(
        settings.REDIS_URL.get_secret_value(),
        max_connections=settings.REDIS_MAX_CONNECTIONS,

34
00:58:36,000 --> 00:58:48,000
The ConnectionPool.from_url method creates a connection pool from a Redis URL.
The URL format is redis://:password@host:port/db.

35
00:58:48,000 --> 00:59:12,000
[CODE TYPING: socket_timeout=settings.REDIS_SOCKET_TIMEOUT_SECONDS,]
socket_timeout=settings.REDIS_SOCKET_TIMEOUT_SECONDS,

36
00:59:12,000 --> 00:59:24,000
Socket timeout controls how long to wait for a response. If Redis doesn't
respond within this time, the operation fails.

37
00:59:24,000 --> 00:59:48,000
[CODE TYPING: socket_connect_timeout=settings.REDIS_CONNECT_TIMEOUT_SECONDS,]
socket_connect_timeout=settings.REDIS_CONNECT_TIMEOUT_SECONDS,

38
00:59:48,000 --> 01:00:00,000
Connect timeout controls how long to wait when establishing the connection.
If Redis doesn't accept the connection within this time, it fails.

39
01:00:00,000 --> 01:00:24,000
[CODE TYPING: decode_responses=True, health_check_interval=30, )]
decode_responses=True,
health_check_interval=30,
)

40
01:00:24,000 --> 01:00:36,000
decode_responses=True ensures we get strings instead of bytes.
health_check_interval=30 runs a background ping every 30 seconds.

41
01:00:36,000 --> 01:01:00,000
[CODE TYPING: self._redis = Redis(connection_pool=self._pool)]
self._redis = Redis(connection_pool=self._pool)

42
01:01:00,000 --> 01:01:12,000
We create the Redis client using the connection pool. This client will
handle all our Redis operations.

43
01:01:12,000 --> 01:01:36,000
[CODE TYPING: await self._redis.ping()]
await self._redis.ping()

44
01:01:36,000 --> 01:01:48,000
We ping Redis to verify the connection is working. If this fails, the
connection wasn't successful.

45
01:01:48,000 --> 01:02:12,000
[CODE TYPING: except RedisError as exc:, raise CacheConnectionError(...)]
except RedisError as exc:
    raise CacheConnectionError(
        f"Cannot connect to Redis at {settings.REDIS_HOST}:{settings.REDIS_PORT}"
    ) from exc

46
01:02:12,000 --> 01:02:24,000
If Redis connection fails, we raise CacheConnectionError. This is caught by
the application and handled gracefully.

47
01:02:24,000 --> 01:02:36,000
Now let's implement the disconnect method. This closes all connections.
async def disconnect(self) -> None:

48
01:02:36,000 --> 01:03:00,000
[CODE TYPING: async def disconnect(self) -> None:, if self._redis is None:, return]
async def disconnect(self) -> None:
    if self._redis is None:
        return

49
01:03:00,000 --> 01:03:12,000
If we're not connected, we return immediately. There's nothing to disconnect.

50
01:03:12,000 --> 01:03:36,000
[CODE TYPING: await self._redis.aclose()]
await self._redis.aclose()

51
01:03:36,000 --> 01:03:48,000
We close the Redis client. This cleans up all resources used by the client.

52
01:03:48,000 --> 01:04:12,000
[CODE TYPING: if self._pool is not None:, await self._pool.aclose()]
if self._pool is not None:
    await self._pool.aclose()

53
01:04:12,000 --> 01:04:24,000
We close the connection pool. This closes all connections in the pool.
self._redis = None
self._pool = None

54
01:04:24,000 --> 01:04:36,000
We set both to None. This allows the garbage collector to clean up the memory.

55
01:04:36,000 --> 01:04:48,000
Now let's implement the get method. This retrieves and deserializes a value.
async def get(self, key: str) -> Any | None:

56
01:04:48,000 --> 01:05:12,000
[CODE TYPING: async def get(self, key: str) -> Any | None:, self._assert_connected()]
async def get(self, key: str) -> Any | None:
    self._assert_connected()

57
01:05:12,000 --> 01:05:24,000
We assert we're connected. If not, an exception is raised.
try:
    raw = await self._redis.get(key)

58
01:05:24,000 --> 01:05:36,000
We call Redis GET. This returns the raw string value or None if the key doesn't exist.
if raw is None:
    return None

59
01:05:36,000 --> 01:05:48,000
If the key doesn't exist, we return None. This is how we signal cache miss.
return json.loads(raw)

60
01:05:48,000 --> 01:06:00,000
We deserialize the JSON string back to a Python object. This is the reverse
of what we do in set.

61
01:06:00,000 --> 01:06:24,000
[CODE TYPING: except json.JSONDecodeError as exc:, return None]
except json.JSONDecodeError as exc:
    logger.warning("Cache value for key '%s' is not valid JSON: %s", key, exc)
    return None

62
01:06:24,000 --> 01:06:36,000
If the stored data isn't valid JSON, we log a warning and return None.
This handles corrupted cache entries gracefully.

63
01:06:36,000 --> 01:06:48,000
Now let's implement the set method. This serializes and stores a value.
async def set(self, key: str, value: Any, ttl: int | None = None) -> bool:

64
01:06:48,000 --> 01:07:12,000
[CODE TYPING: async def set(self, key: str, value: Any, ttl: int | None = None) -> bool:]
async def set(self, key: str, value: Any, ttl: int | None = None) -> bool:
    self._assert_connected()

65
01:07:12,000 --> 01:07:24,000
We assert we're connected. If not, an exception is raised.
settings = get_settings()
effective_ttl = ttl if ttl is not None else settings.REDIS_DEFAULT_TTL_SECONDS

66
01:07:24,000 --> 01:07:36,000
We get the effective TTL. If no TTL is provided, we use the default from settings.
This defaults to 3600 seconds (1 hour).

67
01:07:36,000 --> 01:08:00,000
[CODE TYPING: try:, serialised = json.dumps(value, default=str)]
try:
    serialised = json.dumps(value, default=str)

68
01:08:00,000 --> 01:08:12,000
We serialize the value to JSON. The default=str argument handles objects that
aren't JSON serializable by converting them to strings.

69
01:08:12,000 --> 01:08:36,000
[CODE TYPING: await self._redis.setex(name=key, time=effective_ttl, value=serialised)]
await self._redis.setex(
    name=key,
    time=effective_ttl,
    value=serialised,
)

70
01:08:36,000 --> 01:08:48,000
We call Redis SETEX. This sets the key with an expiration time. The key will
automatically expire after the TTL.

71
01:08:48,000 --> 01:09:00,000
[Visual: SETEX operation — key, value, and TTL being set]

72
01:09:00,000 --> 01:09:24,000
[CODE TYPING: return True]
    return True

73
01:09:24,000 --> 01:09:36,000
If set succeeds, we return True. This confirms the operation was successful.
except (TypeError, ValueError) as exc:
    raise CacheOperationError(...)

74
01:09:36,000 --> 01:09:48,000
If serialization fails, we raise CacheOperationError. This indicates the
value couldn't be serialized.

75
01:09:48,000 --> 01:10:00,000
Now let's implement the delete method. This removes a key from cache.
async def delete(self, key: str) -> bool:

76
01:10:00,000 --> 01:10:24,000
[CODE TYPING: async def delete(self, key: str) -> bool:, self._assert_connected()]
async def delete(self, key: str) -> bool:
    self._assert_connected()

77
01:10:24,000 --> 01:10:48,000
[CODE TYPING: try:, deleted = await self._redis.delete(key), return bool(deleted)]
try:
    deleted = await self._redis.delete(key)
    return bool(deleted)

78
01:10:48,000 --> 01:11:00,000
We call Redis DELETE. It returns the number of keys deleted. We convert this
to a boolean. True means the key existed and was deleted.

79
01:11:00,000 --> 01:11:24,000
[CODE TYPING: except RedisError as exc:, raise CacheOperationError(f"DELETE {key} failed: {exc}")]
except RedisError as exc:
    raise CacheOperationError(f"DELETE {key} failed: {exc}") from exc

80
01:11:24,000 --> 01:11:36,000
If Redis returns an error, we raise CacheOperationError. This indicates the
delete operation failed.

81
01:11:36,000 --> 01:11:48,000
Now let's implement the exists method. This checks if a key exists.
async def exists(self, key: str) -> bool:

82
01:11:48,000 --> 01:12:12,000
[CODE TYPING: async def exists(self, key: str) -> bool:, self._assert_connected()]
async def exists(self, key: str) -> bool:
    self._assert_connected()

83
01:12:12,000 --> 01:12:36,000
[CODE TYPING: try:, return bool(await self._redis.exists(key))]
try:
    return bool(await self._redis.exists(key))

84
01:12:36,000 --> 01:12:48,000
We call Redis EXISTS. It returns the number of keys that exist. We convert
this to a boolean.

85
01:12:48,000 --> 01:13:00,000
Now let's implement the clear_namespace method. This deletes all keys under a namespace.
async def clear_namespace(self, namespace: str) -> int:

86
01:13:00,000 --> 01:13:24,000
[CODE TYPING: async def clear_namespace(self, namespace: str) -> int:, self._assert_connected()]
async def clear_namespace(self, namespace: str) -> int:
    self._assert_connected()

87
01:13:24,000 --> 01:13:36,000
[CODE TYPING: pattern = f"finrag:{namespace}:*"]
pattern = f"finrag:{namespace}:*"

88
01:13:36,000 --> 01:13:48,000
We build a pattern that matches all keys under this namespace.
deleted = 0

89
01:13:48,000 --> 01:14:12,000
[CODE TYPING: try:, async for key in self._redis.scan_iter(pattern):]
try:
    async for key in self._redis.scan_iter(pattern):

90
01:14:12,000 --> 01:14:24,000
We use SCAN to iterate over all keys matching the pattern. SCAN is non-blocking.
It doesn't block Redis while iterating.

91
01:14:24,000 --> 01:14:48,000
[CODE TYPING: await self._redis.delete(key), deleted += 1]
await self._redis.delete(key)
        deleted += 1

92
01:14:48,000 --> 01:15:00,000
We delete each key and increment the counter. This clears the entire namespace.
return deleted

93
01:15:00,000 --> 01:15:12,000
We return the number of keys deleted. This is useful for debugging and monitoring.
except RedisError as exc:
    raise CacheOperationError(...)

94
01:15:12,000 --> 01:15:24,000
If Redis returns an error, we raise CacheOperationError. This indicates the
clear operation failed.

95
01:15:24,000 --> 01:15:36,000
Now let's implement the health_check method. This runs a liveness probe.
async def health_check(self) -> dict[str, Any]:

96
01:15:36,000 --> 01:16:00,000
[CODE TYPING: async def health_check(self) -> dict[str, Any]:, if self._redis is None:]
async def health_check(self) -> dict[str, Any]:
    if self._redis is None:
        return {"status": "disconnected", "error": "Client not initialised"}

97
01:16:00,000 --> 01:16:12,000
If the client isn't connected, we return a disconnected status.
try:
    await self._redis.ping()

98
01:16:12,000 --> 01:16:24,000
We ping Redis. If this succeeds, Redis is responsive.
info = await self._redis.info("server")

99
01:16:24,000 --> 01:16:36,000
We get server info. This includes Redis version and memory usage.
pool_stats = self._pool_stats()

100
01:16:36,000 --> 01:17:00,000
We get pool statistics. This includes the number of connections in the pool.
return {
    "status": "healthy",
    "redis_version": info.get("redis_version"),
    "used_memory_human": info.get("used_memory_human"),
    "connected_clients": info.get("connected_clients"),
    **pool_stats,
}

101
01:17:00,000 --> 01:17:12,000
We return a comprehensive health status. This is used by the /health endpoint.
except RedisError as exc:
    raise CacheConnectionError(f"Health check failed: {exc}") from exc

102
01:17:12,000 --> 01:17:24,000
If Redis returns an error, we raise CacheConnectionError. This indicates the
health check failed.

103
01:17:24,000 --> 01:17:36,000
Now let's implement the internal _assert_connected method.
def _assert_connected(self) -> None:

104
01:17:36,000 --> 01:18:00,000
[CODE TYPING: def _assert_connected(self) -> None:, if self._redis is None:]
def _assert_connected(self) -> None:
    if self._redis is None:
        raise CacheConnectionError("CacheClient is not connected. Call connect() first.")

105
01:18:00,000 --> 01:18:12,000
This method checks if the client is connected. If not, it raises an error.
This ensures all operations only run when the client is ready.

106
01:18:12,000 --> 01:18:24,000
Now let's implement the _pool_stats method. This gets connection pool statistics.
def _pool_stats(self) -> dict[str, Any]:

107
01:18:24,000 --> 01:18:48,000
[CODE TYPING: def _pool_stats(self) -> dict[str, Any]:, if self._pool is None:]
def _pool_stats(self) -> dict[str, Any]:
    if self._pool is None:
        return {}

108
01:18:48,000 --> 01:19:00,000
If the pool doesn't exist, we return an empty dict. This handles the case
where the client isn't fully initialized.

109
01:19:00,000 --> 01:19:24,000
[CODE TYPING: stats: dict[str, Any] = {"pool_max_connections": self._pool.max_connections}]
stats: dict[str, Any] = {
    "pool_max_connections": self._pool.max_connections,
}

110
01:19:24,000 --> 01:19:36,000
We add the max connections to the stats. This is the maximum number of
connections allowed in the pool.

111
01:19:36,000 --> 01:20:00,000
[CODE TYPING: created = getattr(self._pool, "_created_connections", None)]
created = getattr(self._pool, "_created_connections", None)
if created is not None:
    stats["pool_created_connections"] = created

112
01:20:00,000 --> 01:20:12,000
We get the number of created connections if available. This is an internal
attribute but provides useful insight.

113
01:20:12,000 --> 01:20:24,000
[CODE TYPING: return stats]
return stats

114
01:20:24,000 --> 01:20:36,000
We return the stats dict. This is used in the health check response.

115
01:20:36,000 --> 01:20:48,000
Now we need the singleton accessor. This is at the bottom of the file.
_cache_client: CacheClient | None = None

116
01:20:48,000 --> 01:21:12,000
[CODE TYPING: _cache_client: CacheClient | None = None, async def get_cache_client() -> CacheClient:]
_cache_client: CacheClient | None = None

async def get_cache_client() -> CacheClient:
    global _cache_client
    if _cache_client is None:
        _cache_client = CacheClient()
    return _cache_client

117
01:21:12,000 --> 01:21:24,000
This is the singleton pattern. get_cache_client always returns the same instance.
This ensures we only have one CacheClient per process.

118
01:21:24,000 --> 01:21:36,000
[Visual: Singleton pattern diagram]

119
01:21:36,000 --> 01:21:48,000
Now let's recap what we've built in Part 4. We've created a complete Redis cache client.

120
01:21:48,000 --> 01:22:00,000
The CacheClient provides: connection pooling, typed get/set operations,
JSON serialization, namespace management, TTL support, and health checks.

121
01:22:00,000 --> 01:22:12,000
This is the foundation for our caching strategy. It will dramatically improve
the performance of repeated queries.

122
01:22:12,000 --> 01:22:24,000
In Part 5, we'll build the Docker infrastructure. This will define the PostgreSQL
and Redis containers we need for development and production.

123
01:22:24,000 --> 01:22:36,000
[Visual: Cache client complete — all components highlighted in green]

124
01:22:36,000 --> 01:22:48,000
This completes Part 4 of Phase 1. You now have a complete cache client.
Let's continue with Part 5.
```

---

### STATS TRACKER — PART 4 COMPLETE

| Metric | Part 4 | Target |
|---|---|---|
| Words | ~3,750 | ~3,750 |
| Characters | ~15,000 | ~15,000 |
| Sentences | ~150 | ~150 |
| Paragraphs | ~170 | ~170 |
| Reading Level | College Student | College Student |
| Speaking Time | ~25 minutes | ~25 minutes |

---

## Phase 1 Progress

| Part | Topic | Status |
|---|---|---|
| Part 1 | Project Structure & pyproject.toml | ✅ Complete |
| Part 2 | Environment & Settings | ✅ Complete |
| Part 3 | Database Client | ✅ Complete |
| Part 4 | Cache Client | ✅ Complete |
| Part 5 | Docker Infrastructure | ⏳ Next |
| Part 6 | Verification Tests | ⏳ |

---

## What's Next

**Part 5: Docker Infrastructure**

Covering:
- `docker-compose.yml` — PostgreSQL with pgvector, Redis with AOF
- `01_create_schema.sql` — filings, financial_chunks, analysis_history tables

---

Shall I proceed with Part 5?

# Phase 1: Foundation — Complete SRT Script

## Part 5: Docker Infrastructure (01:15:00 - 01:40:00)

---

### STATS TRACKER — PART 5

| Metric | Target |
|---|---|
| Words | ~3,750 |
| Characters | ~15,000 |
| Sentences | ~150 |
| Paragraphs | ~170 |
| Speaking Time | ~25 minutes |

---

```srt
1
01:15:00,000 --> 01:15:12,000
Welcome back to Phase 1. We've built the project structure, the settings system,
the database client, and the cache client. Now we build the Docker infrastructure
that runs all our services.

2
01:15:12,000 --> 01:15:24,000
This is where we define PostgreSQL with pgvector and Redis with AOF persistence.
These are the services that our application depends on. Without them, nothing works.

3
01:15:24,000 --> 01:15:36,000
[Visual: Docker Compose architecture diagram — PostgreSQL container and Redis container]

4
01:15:36,000 --> 01:15:48,000
Let me give you a mental model for Docker Compose. Think of it as a conductor
for an orchestra. Each service is a musician. The conductor tells each musician
when to start, how to play, and when to stop. Docker Compose orchestrates all
your services.

5
01:15:48,000 --> 01:16:00,000
[Visual: Conductor metaphor — Docker Compose conducting PostgreSQL and Redis]

6
01:16:00,000 --> 01:16:12,000
We start with the docker-compose.yml file at the root of our project.
This file defines all our services, their configurations, and how they interact.

7
01:16:12,000 --> 01:16:24,000
[CODE TYPING: docker-compose.yml — start of file]
```
version: '3.8'

x-logging: &default-logging
  driver: json-file
  options:
    max-size: "10m"
    max-file: "5"
    labels: "service,env"

x-restart: &default-restart
  restart: unless-stopped
```

8
01:16:24,000 --> 01:16:36,000
Let me explain what we're doing here. We're using YAML anchors and aliases.
The ampersand creates a named anchor. The asterisk references it later.
This is how we reuse configuration across multiple services.

9
01:16:36,000 --> 01:16:48,000
The x-logging anchor defines our logging configuration. We use json-file driver
with a maximum size of 10 megabytes per file and a maximum of 5 files.
We also add labels so we can filter logs by service and environment.

10
01:16:48,000 --> 01:17:00,000
The x-restart anchor sets restart policy to "unless-stopped". This means
the container will automatically restart unless you explicitly stop it.
This is the standard restart policy for production services.

11
01:17:00,000 --> 01:17:12,000
Now let's define our healthcheck anchors. Healthchecks tell Docker when a
service is ready to accept traffic. Without healthchecks, services might
start in the wrong order.

12
01:17:12,000 --> 01:17:24,000
[CODE TYPING: docker-compose.yml — healthcheck anchors]
```
x-postgres-healthcheck: &postgres-healthcheck
  healthcheck:
    test: ["CMD-SHELL", "pg_isready -U $$POSTGRES_USER -d $$POSTGRES_DB"]
    interval: 10s
    timeout: 5s
    retries: 5
    start_period: 30s

x-redis-healthcheck: &redis-healthcheck
  healthcheck:
    test: ["CMD", "redis-cli", "--no-auth-warning", "-a", "$$REDIS_PASSWORD", "ping"]
    interval: 10s
    timeout: 5s
    retries: 5
    start_period: 10s
```

13
01:17:24,000 --> 01:17:36,000
For PostgreSQL, we use pg_isready. This is the official PostgreSQL command
to check if the server is ready to accept connections. The -U flag specifies
the user, and -d specifies the database.

14
01:17:36,000 --> 01:17:48,000
For Redis, we use redis-cli ping. This sends a PING command to Redis.
If Redis responds with PONG, the healthcheck passes. The --no-auth-warning
suppresses warnings about authentication.

15
01:17:48,000 --> 01:18:00,000
Both healthchecks use the same pattern: 10 second interval, 5 second timeout,
5 retries, and a start_period to give the service time to initialize.

16
01:18:00,000 --> 01:18:12,000
Now let's define the PostgreSQL service. This is the most important service
for our RAG system because it stores all our data and vectors.

17
01:18:12,000 --> 01:18:24,000
[CODE TYPING: docker-compose.yml — PostgreSQL service]
```
services:
  postgres:
    image: pgvector/pgvector:pg17
    container_name: ${POSTGRES_CONTAINER:-finrag-postgres}
    <<: [*default-restart, *postgres-healthcheck]
    environment:
      POSTGRES_DB: ${POSTGRES_DB:-financial_rag}
      POSTGRES_USER: ${POSTGRES_USER:-finrag}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:?POSTGRES_PASSWORD must be set in .env}
      POSTGRES_INITDB_ARGS: "--encoding=UTF8 --locale=C"
```

18
01:18:24,000 --> 01:18:36,000
We use the pgvector/pgvector:pg17 image. This is the official pgvector image
built on PostgreSQL 17. It includes the pgvector extension pre-installed,
which is essential for vector similarity search.

19
01:18:36,000 --> 01:18:48,000
The container_name uses environment variable interpolation. We set the name to
${POSTGRES_CONTAINER:-finrag-postgres}. If POSTGRES_CONTAINER is set in .env,
it uses that value. Otherwise, it defaults to finrag-postgres.

20
01:18:48,000 --> 01:19:00,000
The <<: [*default-restart, *postgres-healthcheck] line applies both anchors.
This means the service will restart unless stopped, and it has a healthcheck.

21
01:19:00,000 --> 01:19:12,000
The environment section defines environment variables for PostgreSQL.
POSTGRES_USER and POSTGRES_PASSWORD are used for authentication.
POSTGRES_INITDB_ARGS sets encoding to UTF8 and locale to C.

22
01:19:12,000 --> 01:19:24,000
POSTGRES_PASSWORD uses a special syntax: ${POSTGRES_PASSWORD:?error message}.
This means the variable is required. If it's not set, Compose will fail with
the error message. This prevents the container from starting without a password.

23
01:19:24,000 --> 01:19:36,000
[CODE TYPING: docker-compose.yml — PostgreSQL ports and volumes]
```
    ports:
      - "${POSTGRES_PORT:-5432}:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./infrastructure/docker/init:/docker-entrypoint-initdb.d:ro
    networks:
      - finrag-network
    logging: *default-logging
```

24
01:19:36,000 --> 01:19:48,000
We map port 5432 from the container to the host. The host port is configurable
via POSTGRES_PORT environment variable with a default of 5432. This allows
multiple PostgreSQL instances on different ports.

25
01:19:48,000 --> 01:20:00,000
We mount two volumes. The first is postgres_data which persists database files.
This is a named volume managed by Docker. Without this, data would be lost
when the container restarts.

26
01:20:00,000 --> 01:20:12,000
The second volume mounts ./infrastructure/docker/init to /docker-entrypoint-initdb.d.
This is a special directory in the PostgreSQL image. Any SQL files in this
directory run automatically on first container start.

27
01:20:12,000 --> 01:20:24,000
The :ro suffix means read-only. This prevents the container from modifying
the init scripts. This is a security best practice.

28
01:20:24,000 --> 01:20:36,000
We attach the service to the finrag-network network. This allows services
to communicate with each other using container names as hostnames.

29
01:20:36,000 --> 01:20:48,000
The logging section applies the default-logging anchor. This means all logs
go to json-file with the same rotation settings.

30
01:20:48,000 --> 01:21:00,000
Now let's define the Redis service. Redis is our cache layer. It provides
high-speed data storage for frequently accessed data.

31
01:21:00,000 --> 01:21:12,000
[CODE TYPING: docker-compose.yml — Redis service]
```
  redis:
    image: redis:7-alpine
    container_name: ${REDIS_CONTAINER:-finrag-redis}
    <<: [*default-restart, *redis-healthcheck]
    command: >
      redis-server
        --appendonly yes
        --requirepass ${REDIS_PASSWORD:?REDIS_PASSWORD must be set in .env}
        --maxmemory ${REDIS_MAXMEMORY:-512mb}
        --maxmemory-policy allkeys-lru
        --tcp-keepalive 60
        --loglevel notice
```

32
01:21:12,000 --> 01:21:24,000
We use redis:7-alpine. This is the official Redis image based on Alpine Linux.
Alpine is a minimal Linux distribution that keeps the image small and secure.

33
01:21:24,000 --> 01:21:36,000
The command section passes arguments to redis-server. We use --appendonly yes
to enable AOF persistence. AOF writes every write operation to a log file.
This ensures data survives container restarts.

34
01:21:36,000 --> 01:21:48,000
The --requirepass flag sets the Redis password. The password is required
and must be set in the .env file. Without a password, Redis would be insecure.

35
01:21:48,000 --> 01:22:00,000
The --maxmemory flag sets the memory limit. The default is 512mb.
When memory is full, Redis evicts keys using the policy specified by
--maxmemory-policy.

36
01:22:00,000 --> 01:22:12,000
We use allkeys-lru as the eviction policy. LRU stands for Least Recently Used.
When memory is full, Redis evicts the least recently used keys first.
This is the default behavior for caching.

37
01:22:12,000 --> 01:22:24,000
The --tcp-keepalive flag enables TCP keepalive. This prevents connections
from being closed by firewalls due to inactivity. The value 60 means
keepalive packets are sent every 60 seconds.

38
01:22:24,000 --> 01:22:36,000
[CODE TYPING: docker-compose.yml — Redis ports, volumes, networks]
```
    ports:
      - "${REDIS_PORT:-6379}:6379"
    volumes:
      - redis_data:/data
    networks:
      - finrag-network
    logging: *default-logging
```

39
01:22:36,000 --> 01:22:48,000
We map port 6379 from the container to the host. The host port is configurable
via REDIS_PORT environment variable with a default of 6379.

40
01:22:48,000 --> 01:23:00,000
We mount the redis_data volume to /data. This persists Redis data across
container restarts. Redis stores its AOF file and RDB snapshots in /data.

41
01:23:00,000 --> 01:23:12,000
Now let's define the networks and volumes sections. These are at the bottom
of the docker-compose.yml file.

42
01:23:12,000 --> 01:23:24,000
[CODE TYPING: docker-compose.yml — networks and volumes]
```
networks:
  finrag-network:
    driver: bridge
    name: finrag-network
    ipam:
      config:
        - subnet: ${NETWORK_SUBNET:-172.28.0.0/16}

volumes:
  postgres_data:
    name: finrag_postgres_data
  redis_data:
    name: finrag_redis_data
```

43
01:23:24,000 --> 01:23:36,000
We define a bridge network called finrag-network. Bridge is the default
network driver in Docker. It allows containers to communicate with each other.

44
01:23:36,000 --> 01:23:48,000
We set a custom subnet of 172.28.0.0/16. This avoids conflicts with other
Docker networks. The subnet is configurable via NETWORK_SUBNET environment
variable with a default of 172.28.0.0/16.

45
01:23:48,000 --> 01:24:00,000
We define two named volumes: postgres_data and redis_data. These volumes
persist data across container restarts and even across container removal.

46
01:24:00,000 --> 01:24:12,000
Named volumes are managed by Docker. They live in Docker's volume directory.
You can inspect them with docker volume ls and docker volume inspect.

47
01:24:12,000 --> 01:24:24,000
Now let's look at the database initialization script. This is the SQL file that
runs on first container start. It creates the schema for our application.

48
01:24:24,000 --> 01:24:36,000
[CODE TYPING: infrastructure/docker/init/01_create_schema.sql — extensions]
```
-- ============================================================================
-- Financial RAG Agent - Database Schema
-- ============================================================================

-- === Extensions ===
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS btree_gin;
```

49
01:24:36,000 --> 01:24:48,000
We start by creating extensions. These are PostgreSQL add-ons that provide
additional functionality. The IF NOT EXISTS clause ensures we don't get
errors if the extension already exists.

50
01:24:48,000 --> 01:25:00,000
vector is the pgvector extension. It provides vector data types and operators
for similarity search. This is the foundation of RAG.

51
01:25:00,000 --> 01:25:12,000
uuid-ossp provides UUID generation functions. We use UUIDs as primary keys
in all our tables. UUIDs are globally unique and don't require coordination
between different systems.

52
01:25:12,000 --> 01:25:24,000
pg_trgm provides trigram similarity for text search. It enables fuzzy text
matching, which is useful for fallback search when vector search isn't enough.

53
01:25:24,000 --> 01:25:36,000
btree_gin provides GIN indexes for composite data types. This allows efficient
indexing of JSONB columns. JSONB is used for metrics and entities.

54
01:25:36,000 --> 01:25:48,000
[CODE TYPING: infrastructure/docker/init/01_create_schema.sql — filings table]
```
-- === filings ===
CREATE TABLE IF NOT EXISTS filings (
    id               UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    ticker           VARCHAR(10) NOT NULL,
    filing_type      VARCHAR(20) NOT NULL,
    fiscal_year      SMALLINT,
    fiscal_quarter   SMALLINT    CHECK (fiscal_quarter BETWEEN 1 AND 4),
    filed_at         DATE,
    source_url       TEXT,
    file_hash        VARCHAR(64) UNIQUE,
    pages            INTEGER,
    ingested_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    ingested_by      VARCHAR(100),
    is_active        BOOLEAN     NOT NULL DEFAULT TRUE,
    CONSTRAINT filings_filing_type_check
        CHECK (filing_type IN ('10-K', '10-Q', '8-K', '20-F', 'DEF 14A', 'S-1'))
);
```

55
01:25:48,000 --> 01:26:00,000
The filings table stores metadata about each SEC filing. This is the source
of truth for what we've ingested. Each filing has a unique file_hash for deduplication.

56
01:26:00,000 --> 01:26:12,000
The id column is a UUID primary key. We use gen_random_uuid() to generate
UUIDs automatically. This avoids conflicts when inserting from different systems.

57
01:26:12,000 --> 01:26:24,000
ticker is the stock ticker symbol like AAPL or MSFT. It's VARCHAR(10)
which is sufficient for all tickers. It's NOT NULL because every filing
belongs to a company.

58
01:26:24,000 --> 01:26:36,000
filing_type is the SEC form type like 10-K, 10-Q, or 8-K. We use a CHECK
constraint to ensure only valid types are inserted. This prevents data corruption.

59
01:26:36,000 --> 01:26:48,000
file_hash is the SHA-256 hash of the raw filing content. It's UNIQUE,
which ensures we never store duplicate filings. This is our deduplication mechanism.

60
01:26:48,000 --> 01:27:00,000
is_active is a boolean for soft delete. Instead of deleting rows, we set
is_active to False. This preserves data for auditing and recovery purposes.

61
01:27:00,000 --> 01:27:12,000
[CODE TYPING: infrastructure/docker/init/01_create_schema.sql — indexes for filings]
```
CREATE INDEX IF NOT EXISTS idx_filings_ticker ON filings (ticker, fiscal_year DESC);
CREATE INDEX IF NOT EXISTS idx_filings_type_year ON filings (filing_type, fiscal_year DESC);
CREATE INDEX IF NOT EXISTS idx_filings_active ON filings (ticker) WHERE is_active = TRUE;
```

62
01:27:12,000 --> 01:27:24,000
We create indexes on the filings table for performance. The idx_filings_ticker
index helps with queries like "find all filings for AAPL in order of fiscal year".

63
01:27:24,000 --> 01:27:36,000
The idx_filings_type_year index helps with queries like "find all 10-K filings
sorted by fiscal year". This is useful for retrieving the latest filing of a type.

64
01:27:36,000 --> 01:27:48,000
The idx_filings_active index is a partial index. It only indexes rows where
is_active is TRUE. This keeps the index small and fast for active records.

65
01:27:48,000 --> 01:28:00,000
[CODE TYPING: infrastructure/docker/init/01_create_schema.sql — financial_chunks table]
```
-- === financial_chunks ===
CREATE TABLE IF NOT EXISTS financial_chunks (
    id              UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    filing_id       UUID         NOT NULL REFERENCES filings (id) ON DELETE CASCADE,
    ticker          VARCHAR(10)  NOT NULL,
    filing_type     VARCHAR(20)  NOT NULL,
    fiscal_year     SMALLINT,
    section         VARCHAR(100),
    chunk_index     INTEGER      NOT NULL CHECK (chunk_index >= 0),
    chunk_text      TEXT         NOT NULL,
    token_count     INTEGER      CHECK (token_count IS NULL OR token_count > 0),
    embedding       vector(1536) NOT NULL,
    metrics         JSONB        NOT NULL DEFAULT '{}',
    entities        JSONB        NOT NULL DEFAULT '{}',
    sentiment_score REAL         CHECK (sentiment_score BETWEEN -1.0 AND 1.0),
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    model_version   VARCHAR(50)  NOT NULL DEFAULT 'text-embedding-3-small'
);
```

66
01:28:00,000 --> 01:28:12,000
The financial_chunks table is the heart of our RAG system. Each row stores
a chunk of text from a filing along with its vector embedding.

67
01:28:12,000 --> 01:28:24,000
The filing_id is a foreign key to the filings table. ON DELETE CASCADE means
when a filing is deleted, all its chunks are automatically deleted as well.

68
01:28:24,000 --> 01:28:36,000
The embedding column uses vector(1536). This is the pgvector vector type with
1536 dimensions. This matches the OpenAI text-embedding-3-small model dimensions.

69
01:28:36,000 --> 01:28:48,000
The metrics column is JSONB. It stores extracted financial metrics like revenue,
net income, EPS, and margin. JSONB allows flexible schema and efficient querying.

70
01:28:48,000 --> 01:29:00,000
The entities column is JSONB. It stores extracted entities like company names,
people, dates, and amounts. This will be populated by the NER pipeline.

71
01:29:00,000 --> 01:29:12,000
The sentiment_score is a floating point between -1.0 and 1.0. Negative values
indicate negative sentiment, positive values indicate positive sentiment.
0 indicates neutral.

72
01:29:12,000 --> 01:29:24,000
[CODE TYPING: infrastructure/docker/init/01_create_schema.sql — indexes for chunks]
```
CREATE INDEX IF NOT EXISTS idx_chunks_ticker_year ON financial_chunks (ticker, fiscal_year DESC);
CREATE INDEX IF NOT EXISTS idx_chunks_filing_section ON financial_chunks (filing_id, section);
CREATE INDEX IF NOT EXISTS idx_chunks_metrics ON financial_chunks USING GIN (metrics);
CREATE INDEX IF NOT EXISTS idx_chunks_entities ON financial_chunks USING GIN (entities);
CREATE INDEX IF NOT EXISTS idx_chunks_text_trgm ON financial_chunks USING GIN (chunk_text gin_trgm_ops);
```

73
01:29:24,000 --> 01:29:36,000
We create multiple indexes on the financial_chunks table for fast retrieval.
The idx_chunks_ticker_year index helps with ticker-based filtering.

74
01:29:36,000 --> 01:29:48,000
The idx_chunks_filing_section index helps with filtering by filing and section.
This allows us to retrieve all chunks from a specific section of a filing.

75
01:29:48,000 --> 01:30:00,000
The idx_chunks_metrics index uses GIN on the JSONB metrics column.
This enables efficient filtering on metric values like "revenue > 100 million".

76
01:30:00,000 --> 01:30:12,000
The idx_chunks_text_trgm index uses GIN with the trigram operator.
This enables full-text search on the chunk_text column. It's used by the
hybrid search fallback.

77
01:30:12,000 --> 01:30:24,000
[CODE TYPING: infrastructure/docker/init/01_create_schema.sql — analysis_history table]
```
-- === analysis_history ===
CREATE TABLE IF NOT EXISTS analysis_history (
    id               UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    ticker           VARCHAR(10),
    question         TEXT        NOT NULL,
    answer           TEXT        NOT NULL,
    analysis_style   VARCHAR(20) NOT NULL DEFAULT 'analyst',
    agent_type       VARCHAR(50) NOT NULL,
    search_type      VARCHAR(20) NOT NULL DEFAULT 'similarity',
    latency_ms       INTEGER     NOT NULL,
    source_chunk_ids UUID[]      DEFAULT '{}',
    real_time_used   BOOLEAN     NOT NULL DEFAULT FALSE,
    error            TEXT,
    session_id       UUID,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT analysis_style_check
        CHECK (analysis_style IN ('analyst', 'executive', 'risk')),
    CONSTRAINT search_type_check
        CHECK (search_type IN ('similarity', 'mmr'))
);
```

78
01:30:24,000 --> 01:30:36,000
The analysis_history table stores an audit trail of every query and response.
This is append-only — we never update or delete records. This preserves the
complete history for auditing and debugging.

79
01:30:36,000 --> 01:30:48,000
The question and answer columns store the user's question and the agent's
response. Both are TEXT, which can handle any length of text.

80
01:30:48,000 --> 01:31:00,000
analysis_style is one of 'analyst', 'executive', or 'risk'. This controls
the style of analysis performed by the agent. The CHECK constraint ensures
only valid styles are inserted.

81
01:31:00,000 --> 01:31:12,000
agent_type identifies which agent produced the response. This could be
'financial_agent', 'query_engine', or 'query_engine_fallback'.

82
01:31:12,000 --> 01:31:24,000
source_chunk_ids is a PostgreSQL array of UUIDs. It stores the chunk IDs
that were used to generate the answer. This enables source attribution.

83
01:31:24,000 --> 01:31:36,000
latency_ms stores the query latency in milliseconds. This is used for
performance monitoring and SLO tracking.

84
01:31:36,000 --> 01:31:48,000
[CODE TYPING: infrastructure/docker/init/01_create_schema.sql — analysis_history indexes and migrations table]
```
CREATE INDEX IF NOT EXISTS idx_analysis_ticker_time ON analysis_history (ticker, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_analysis_session ON analysis_history (session_id) WHERE session_id IS NOT NULL;

-- === schema_migrations ===
CREATE TABLE IF NOT EXISTS schema_migrations (
    version     VARCHAR(20) PRIMARY KEY,
    description TEXT,
    applied_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

INSERT INTO schema_migrations (version, description)
VALUES ('001', 'Initial schema: filings, financial_chunks, analysis_history')
ON CONFLICT (version) DO NOTHING;
```

85
01:31:48,000 --> 01:32:00,000
The idx_analysis_ticker_time index helps with queries like "show all analyses
for AAPL in reverse chronological order". This is used in the dashboard.

86
01:32:00,000 --> 01:32:12,000
The idx_analysis_session index is a partial index that only indexes rows
where session_id is not null. This is used for session-based tracking.

87
01:32:12,000 --> 01:32:24,000
The schema_migrations table tracks which migrations have been applied.
This is used by Alembic to manage schema changes. The version column
is a string like '001', '002', etc.

88
01:32:24,000 --> 01:32:36,000
The INSERT statement adds the initial migration record. ON CONFLICT ensures
it's idempotent — if the migration record already exists, nothing happens.

89
01:32:36,000 --> 01:32:48,000
Now let's look at the HNSW index creation script. This is a separate file
that creates an index for fast vector search. It should be run after bulk
data load for best performance.

90
01:32:48,000 --> 01:33:00,000
[CODE TYPING: infrastructure/docker/init/create_hnsw_index.sql]
```
-- HNSW index for fast approximate nearest neighbor search
-- Run after bulk data load for best performance
-- m=16: max connections per layer (higher = better recall, more memory)
-- ef_construction=64: search width during index build (higher = better quality)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_chunks_embedding_hnsw
ON financial_chunks USING hnsw (embedding vector_cosine_ops)
WITH (m = 16, ef_construction = 64);
```

91
01:33:00,000 --> 01:33:12,000
HNSW stands for Hierarchical Navigable Small World. It's a graph-based
index that provides fast approximate nearest neighbor search. It's much
faster than exact search on large datasets.

92
01:33:12,000 --> 01:33:24,000
The CONCURRENTLY keyword creates the index without blocking writes.
This is important in production because the index can take a few minutes
to build on a large table.

93
01:33:24,000 --> 01:33:36,000
The m parameter controls the number of connections per layer. Higher values
give better recall but use more memory. 16 is the recommended default.

94
01:33:36,000 --> 01:33:48,000
The ef_construction parameter controls the search width during index build.
Higher values give better quality but take longer to build. 64 is a good
balance between quality and build time.

95
01:33:48,000 --> 01:34:00,000
We also have an alternative IVFFlat index. IVFFlat is a partitioning-based
index that can be faster to build than HNSW on smaller datasets.

96
01:34:00,000 --> 01:34:12,000
[CODE TYPING: infrastructure/docker/init/create_hnsw_index.sql — IVFFlat alternative]
```
-- Alternative: IVFFlat index (faster to build, good for smaller datasets)
-- CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_chunks_embedding_ivfflat
-- ON financial_chunks USING ivfflat (embedding vector_cosine_ops)
-- WITH (lists = 100);
```

97
01:34:12,000 --> 01:34:24,000
The lists parameter controls the number of partitions in the index.
100 lists is a good starting point for up to 1 million vectors.
For larger datasets, you'd increase the number of lists.

98
01:34:24,000 --> 01:34:36,000
Now let me give you a practical tip. When you start Docker Compose
for the first time, the init scripts run automatically. This creates the
schema and extensions. You don't need to do anything manually.

99
01:34:36,000 --> 01:34:48,000
[CODE TYPING: Starting Docker Compose]
```
docker compose up -d
```
This command starts all services in detached mode. The -d flag means
detached — the containers run in the background.

100
01:34:48,000 --> 01:35:00,000
You can check the status of all services with:
```
docker compose ps
```
This shows the status of each container: whether it's running, healthy, or exited.

101
01:35:00,000 --> 01:35:12,000
You can view logs with:
```
docker compose logs -f postgres
```
The -f flag follows the logs in real time. This is useful for debugging
startup issues.

102
01:35:12,000 --> 01:35:24,000
Let me give you a debugging tip. If PostgreSQL fails to start, check the
logs with docker compose logs postgres. Common issues include port conflicts
and missing environment variables.

103
01:35:24,000 --> 01:35:36,000
If the init scripts fail to run, check that the SQL files are valid.
You can manually run them with psql if needed:
```
docker compose exec postgres psql -U finrag -d financial_rag -f /docker-entrypoint-initdb.d/01_create_schema.sql
```

104
01:35:36,000 --> 01:35:48,000
If Redis fails to start, check the logs with docker compose logs redis.
Common issues include port conflicts and incorrect password configuration.

105
01:35:48,000 --> 01:36:00,000
Now, let me give you a performance tip. The HNSW index creation can take
a few minutes on large datasets. It's best to create it after you've
ingested all your data, not during ingestion.

106
01:36:00,000 --> 01:36:12,000
For development, you can use the IVFFlat index instead of HNSW.
IVFFlat builds much faster and is sufficient for testing. You can
switch to HNSW when you're ready for production.

107
01:36:12,000 --> 01:36:24,000
Now let me show you the complete file structure for Phase 1.

108
01:36:24,000 --> 01:36:36,000
[CODE TYPING: File structure display]
```
financial-ai-agent/
├── .env / .env.example
├── .gitignore
├── docker-compose.yml
├── pyproject.toml
├── src/
│   └── financial_rag/
│       ├── __init__.py
│       ├── config/
│       │   ├── __init__.py
│       │   └── settings.py
│       └── storage/
│           ├── __init__.py
│           ├── cache.py
│           └── database.py
├── infrastructure/
│   └── docker/
│       └── init/
│           ├── 01_create_schema.sql
│           └── create_hnsw_index.sql
├── migrations/
├── tests/
│   └── integration/
│       └── test_phase1_foundation.py
└── docs/
```

109
01:36:36,000 --> 01:36:48,000
You can see we have the core application code, infrastructure configuration,
and test files. This is a clean, organized structure that's easy to navigate.

110
01:36:48,000 --> 01:37:00,000
The infrastructure/docker/init directory contains the SQL init scripts.
These are the only files in the infrastructure directory for Phase 1.
Later phases will add more to this directory.

111
01:37:00,000 --> 01:37:12,000
The migrations directory is currently empty. It will contain Alembic
migration files in later phases when we need to evolve the schema.

112
01:37:12,000 --> 01:37:24,000
Now let me recap what we've covered in Part 5. We built the Docker infrastructure
with PostgreSQL and Redis. We defined healthchecks for both services.

113
01:37:24,000 --> 01:37:36,000
We created the database schema with three tables: filings, financial_chunks,
and analysis_history. We added the pgvector extension for vector similarity search.

114
01:37:36,000 --> 01:37:48,000
We created the HNSW index for fast vector search. We also have an IVFFlat
alternative for development. We configured Redis with AOF persistence and
LRU eviction policy.

115
01:37:48,000 --> 01:38:00,000
In Part 6, we'll write verification tests to ensure everything works together.
We'll test the settings, database, cache, and Docker infrastructure in one
integration test suite.

116
01:38:00,000 --> 01:38:12,000
This completes Part 5 of Phase 1. You now have Docker infrastructure
with PostgreSQL, pgvector, and Redis. Let's continue with Part 6.

117
01:38:12,000 --> 01:38:24,000
[Visual: Docker infrastructure complete — all services running and healthy]

118
01:38:24,000 --> 01:38:36,000
Before we move on, let me give you a quick summary of the commands you'll use:

119
01:38:36,000 --> 01:38:48,000
[CODE TYPING: Commands summary]
```
# Start all services
docker compose up -d

# Check service status
docker compose ps

# View PostgreSQL logs
docker compose logs -f postgres

# View Redis logs
docker compose logs -f redis

# Stop all services
docker compose down

# Stop and remove all data (volumes)
docker compose down -v

# Connect to PostgreSQL
docker compose exec postgres psql -U finrag -d financial_rag
```

120
01:38:48,000 --> 01:39:00,000
These commands will be your daily workflow. Start services, check status,
view logs, and clean up when needed. Master these and you'll be productive.

121
01:39:00,000 --> 01:39:12,000
This completes Part 5. You now have a complete Docker infrastructure
with PostgreSQL, pgvector, and Redis. Everything is configured and ready to go.
Let's continue with Part 6.
```

---

### STATS TRACKER — PART 5 COMPLETE

| Metric | Part 5 | Target |
|---|---|---|
| Words | ~3,850 | ~3,750 |
| Characters | ~15,200 | ~15,000 |
| Sentences | ~155 | ~150 |
| Paragraphs | ~175 | ~170 |
| Reading Level | College Student | College Student |
| Speaking Time | ~25 minutes | ~25 minutes |

---

## Part 5 Summary

| Component | Files Created | Status |
|---|---|---|
| Docker Compose | `docker-compose.yml` | ✅ Complete |
| PostgreSQL with pgvector | PostgreSQL service with pgvector extension | ✅ Complete |
| Redis with AOF | Redis service with append-only persistence | ✅ Complete |
| Database Schema | `01_create_schema.sql` | ✅ Complete |
| HNSW Index | `create_hnsw_index.sql` | ✅ Complete |

---

## Phase 1 Progress

| Part | Topic | Status |
|---|---|---|
| Part 1 | Project Structure & pyproject.toml | ✅ Complete |
| Part 2 | Environment & Settings | ✅ Complete |
| Part 3 | Database Client | ✅ Complete |
| Part 4 | Cache Client | ✅ Complete |
| Part 5 | Docker Infrastructure | ✅ Complete |
| Part 6 | Verification Tests | ⏳ Next |

---

## What's Next

**Part 6: Verification Tests**

Covering:
- `test_phase1_foundation.py` — Integration tests
- Testing settings
- Testing database connection
- Testing pgvector extension
- Testing Redis cache operations
- Testing Docker infrastructure

---

Shall I proceed with Part 6?

# Phase 1: Foundation — Complete SRT Script

## Part 6: Verification Tests (01:40:00 - 02:05:00)

---

### STATS TRACKER — PART 6

| Metric | Target |
|---|---|
| Words | ~5,500 |
| Characters | ~22,000 |
| Sentences | ~220 |
| Paragraphs | ~250 |
| Speaking Time | ~35 minutes |

---

```srt
1
01:40:00,000 --> 01:40:15,000
Welcome back to Phase 1. We've built the project structure, the settings system,
the database client, the cache client, and the Docker infrastructure.
Now we put it all to the test.

2
01:40:15,000 --> 01:40:30,000
This is the most important part of any project: verification. If you don't test
your foundation, you're building on sand. Every component we've built needs to
be validated before we move forward.

3
01:40:30,000 --> 01:40:45,000
[Visual: Testing pyramid — unit tests at bottom, integration tests in middle,
end-to-end tests at top]

4
01:40:45,000 --> 01:41:00,000
Let me give you a mental model for testing. Think of it like a quality control
system in a factory. Each component is inspected as it comes off the assembly line.
If a component fails inspection, it's fixed immediately. This prevents defective
products from reaching the customer.

5
01:41:00,000 --> 01:41:15,000
[Visual: Factory quality control metaphor — each component being inspected]

6
01:41:15,000 --> 01:41:30,000
That's exactly what integration tests do. They verify that our components work
together correctly. They catch issues before they reach production.

7
01:41:30,000 --> 01:41:45,000
Let's start by looking at the test file structure. We have tests/integration/
for our integration tests. The test file is called test_phase1_foundation.py.

8
01:41:45,000 --> 01:42:00,000
We use pytest as our testing framework. pytest discovers tests automatically
based on naming conventions. Any file starting with test_ and any function
starting with test_ will be run.

9
01:42:00,000 --> 01:42:15,000
[Visual: Pytest discovery process animation]

10
01:42:15,000 --> 01:42:30,000
Now let's open the test file and walk through it line by line.

11
01:42:30,000 --> 01:43:00,000
[CODE: imports]
from __future__ import annotations

import os
from unittest.mock import patch

import pytest
from sqlalchemy import text

from financial_rag.config import get_settings
from financial_rag.storage.cache import CacheClient, build_key
from financial_rag.storage.database import DatabaseClient

12
01:43:00,000 --> 01:43:15,000
We import from __future__ import annotations for forward reference support.
We import os for environment variable access. We import patch from unittest.mock
for mocking environment variables.

13
01:43:15,000 --> 01:43:30,000
We import pytest as our testing framework. We import text from sqlalchemy
for raw SQL queries. We import get_settings from our config module.

14
01:43:30,000 --> 01:43:45,000
We import CacheClient and build_key from storage.cache. We import DatabaseClient
from storage.database. These are the components we're testing.

15
01:43:45,000 --> 01:44:00,000
Now let's define the valid test secrets. These are environment variables that
must be set for tests to run.

16
01:44:00,000 --> 01:44:30,000
[CODE: valid secrets]
VALID_SECRETS = {
    "POSTGRES_PASSWORD": "test-pg-password-32-chars-minimum",
    "REDIS_PASSWORD": "test-redis-password-32-chars-min",
    "APP_ENV": "testing",
}

17
01:44:30,000 --> 01:44:45,000
We define POSTGRES_PASSWORD as a test value. In production, this would be
a secure password. For testing, we use a simple placeholder.
We do the same for REDIS_PASSWORD.

18
01:44:45,000 --> 01:45:00,000
We set APP_ENV to "testing". This enables testing mode in the application.
It disables external API calls and enables debug features.

19
01:45:00,000 --> 01:45:15,000
Now we need a fixture that clears the settings cache. This is important because
settings is a singleton.

20
01:45:15,000 --> 01:45:45,000
[CODE: settings cache fixture]
@pytest.fixture(autouse=True)
def _testing_env():
    with patch.dict(os.environ, VALID_SECRETS, clear=False):
        get_settings.cache_clear()
        yield
    get_settings.cache_clear()

21
01:45:45,000 --> 01:46:00,000
This fixture uses autouse=True, which means it runs automatically for every test.
It patches the environment with our valid secrets. It clears the settings cache
before and after each test.

22
01:46:00,000 --> 01:46:15,000
The patch.dict context manager temporarily overrides environment variables.
Inside the context, get_settings.cache_clear() forces a fresh settings instance.
After the test, we clear again to prevent state bleeding.

23
01:46:15,000 --> 01:46:30,000
Now let's create the database fixture. This gives each test a fresh database
connection.

24
01:46:30,000 --> 01:47:00,000
[CODE: database fixture]
@pytest.fixture
async def db():
    client = DatabaseClient()
    await client.connect()
    yield client
    await client.disconnect()

25
01:47:00,000 --> 01:47:15,000
This fixture creates a DatabaseClient instance. It calls connect() to establish
the connection pool. It yields the client for the test to use.

26
01:47:15,000 --> 01:47:30,000
After the test completes, it calls disconnect() to close all connections.
This ensures tests don't leak connections or interfere with each other.

27
01:47:30,000 --> 01:47:45,000
Now let's create the cache fixture. This gives each test a fresh Redis connection.

28
01:47:45,000 --> 01:48:15,000
[CODE: cache fixture]
@pytest.fixture
async def cache():
    client = CacheClient()
    await client.connect()
    yield client
    await client.disconnect()

29
01:48:15,000 --> 01:48:30,000
This fixture creates a CacheClient instance. It calls connect() to establish
the Redis connection. It yields the client for the test to use.

30
01:48:30,000 --> 01:48:45,000
After the test completes, it calls disconnect() to close all Redis connections.
This ensures cache isolation between tests.

31
01:48:45,000 --> 01:49:00,000
Now let's write the TestSettings class. This verifies our settings system.

32
01:49:00,000 --> 01:49:30,000
[CODE: TestSettings class]
class TestSettings:
    def test_env_is_testing(self):
        assert get_settings().APP_ENV == "testing"

33
01:49:30,000 --> 01:49:45,000
This test verifies that APP_ENV is set to "testing". This confirms our environment
patching is working correctly.

34
01:49:45,000 --> 01:50:15,000
[CODE: test debug auto-enabled]
    def test_debug_auto_enabled_in_testing(self):
        assert get_settings().DEBUG is True

35
01:50:15,000 --> 01:50:30,000
We test that DEBUG is automatically enabled in testing. This is important because
we want debugging features available during testing.

36
01:50:30,000 --> 01:51:00,000
[CODE: test database url]
    def test_database_url_uses_asyncpg(self):
        url = get_settings().DATABASE_URL.get_secret_value()
        assert url.startswith("postgresql+asyncpg://")

37
01:51:00,000 --> 01:51:15,000
We test that DATABASE_URL uses the asyncpg driver. The URL should start with
"postgresql+asyncpg://". This confirms we're using the correct driver for
async database operations.

38
01:51:15,000 --> 01:51:45,000
[CODE: test database url sync]
    def test_database_url_sync_uses_psycopg2(self):
        url = get_settings().DATABASE_URL_SYNC.get_secret_value()
        assert url.startswith("postgresql+psycopg2://")

39
01:51:45,000 --> 01:52:00,000
We test that DATABASE_URL_SYNC uses the psycopg2 driver. This is used for
Alembic migrations. The URL should start with "postgresql+psycopg2://".

40
01:52:00,000 --> 01:52:30,000
[CODE: test redis url]
    def test_redis_url_format(self):
        url = get_settings().REDIS_URL.get_secret_value()
        assert url.startswith("redis://")

41
01:52:30,000 --> 01:52:45,000
We test that REDIS_URL starts with "redis://". This confirms the URL format
is correct for Redis connections.

42
01:52:45,000 --> 01:53:15,000
[CODE: test password not exposed]
    def test_password_not_exposed_in_repr(self):
        settings = get_settings()
        password = settings.POSTGRES_PASSWORD.get_secret_value()
        assert password not in repr(settings)

43
01:53:15,000 --> 01:53:30,000
This is a security test. We verify that passwords are not exposed in repr().
SecretStr masks passwords in logs and repr(). This prevents accidental exposure.

44
01:53:30,000 --> 01:54:00,000
[CODE: test chunk settings]
    def test_chunk_size(self):
        settings = get_settings()
        assert settings.CHUNK_OVERLAP_TOKENS < settings.CHUNK_SIZE_TOKENS

45
01:54:00,000 --> 01:54:15,000
We test that chunk overlap is less than chunk size. This is a configuration
validation. If overlap is greater than or equal to chunk size, the chunking
logic would fail.

46
01:54:15,000 --> 01:54:30,000
Now let's write the TestDatabase class. This verifies our database client.

47
01:54:30,000 --> 01:55:00,000
[CODE: TestDatabase class]
class TestDatabase:
    @pytest.mark.integration
    async def test_connection_is_live(self, db):
        async with db.connection() as conn:
            result = await conn.execute(text("SELECT 1 AS val"))
            assert result.fetchone().val == 1

48
01:55:00,000 --> 01:55:15,000
We use the @pytest.mark.integration marker. This allows us to run integration
tests selectively. The test uses the db fixture to get a database connection.

49
01:55:15,000 --> 01:55:30,000
We execute SELECT 1 AS val and verify we get 1 back. This is the most basic
database test. If this fails, nothing else will work.

50
01:55:30,000 --> 01:56:00,000
[CODE: test pgvector]
    @pytest.mark.integration
    async def test_pgvector_extension_installed(self, db):
        async with db.connection() as conn:
            result = await conn.execute(
                text("SELECT extname FROM pg_extension WHERE extname = 'vector'")
            )
            assert result.fetchone() is not None

51
01:56:00,000 --> 01:56:15,000
We test that pgvector is installed. We query pg_extension for the 'vector'
extension. If it exists, pgvector is installed. This is critical for RAG.

52
01:56:15,000 --> 01:56:45,000
[CODE: test all tables exist]
    @pytest.mark.integration
    async def test_all_tables_exist(self, db):
        expected = {"filings", "financial_chunks", "analysis_history", "schema_migrations"}
        async with db.connection() as conn:
            result = await conn.execute(
                text("SELECT tablename FROM pg_tables WHERE schemaname = 'public'")
            )
            tables = {row.tablename for row in result.fetchall()}
            assert expected.issubset(tables)

53
01:56:45,000 --> 01:57:00,000
We test that all tables exist. We expect filings, financial_chunks,
analysis_history, and schema_migrations. Each table has a specific purpose.

54
01:57:00,000 --> 01:57:30,000
[CODE: test session commits]
    @pytest.mark.integration
    async def test_session_commits_and_rolls_back(self, db):
        async with db.session() as session:
            await session.execute(
                text("INSERT INTO schema_migrations (version, description) VALUES ('test-001', 'test') ON CONFLICT (version) DO NOTHING")
            )

55
01:57:30,000 --> 01:57:45,000
We insert a test record into schema_migrations. This verifies that sessions
commit correctly. After the session exits, the record should be in the database.

56
01:57:45,000 --> 01:58:15,000
[CODE: verify record exists]
        async with db.connection() as conn:
            result = await conn.execute(
                text("SELECT version FROM schema_migrations WHERE version = 'test-001'")
            )
            assert result.fetchone() is not None

57
01:58:15,000 --> 01:58:30,000
We verify the record exists. This confirms the transaction was committed.

58
01:58:30,000 --> 01:59:00,000
[CODE: delete test record]
        async with db.session() as session:
            await session.execute(text("DELETE FROM schema_migrations WHERE version = 'test-001'"))

59
01:59:00,000 --> 01:59:15,000
We clean up the test record. This keeps the database clean between tests.

60
01:59:15,000 --> 01:59:30,000
Now let's write the TestCache class. This verifies our cache client.

61
01:59:30,000 --> 02:00:00,000
[CODE: TestCache class]
class TestCache:
    @pytest.mark.integration
    async def test_ping(self, cache):
        assert cache._redis is not None

62
02:00:00,000 --> 02:00:15,000
We test that the Redis connection exists. This confirms the cache client
is properly connected.

63
02:00:15,000 --> 02:00:45,000
[CODE: test set and get]
    @pytest.mark.integration
    async def test_set_and_get(self, cache):
        key = build_key("test", "phase1")
        await cache.set(key, {"value": 42}, ttl=60)
        assert await cache.get(key) == {"value": 42}
        await cache.delete(key)

64
02:00:45,000 --> 02:01:00,000
We test set and get operations. We build a key with build_key. We store a value
with a 60-second TTL. We retrieve it and verify it's correct. Then we clean up.

65
02:01:00,000 --> 02:01:30,000
[CODE: test get missing key]
    @pytest.mark.integration
    async def test_get_missing_key_returns_none(self, cache):
        assert await cache.get(build_key("test", "nonexistent-xyz")) is None

66
02:01:30,000 --> 02:01:45,000
We test that get on a missing key returns None. This is important because
we use None to indicate cache miss.

67
02:01:45,000 --> 02:02:15,000
[CODE: test delete key]
    @pytest.mark.integration
    async def test_delete_key(self, cache):
        key = build_key("test", "delete-me")
        await cache.set(key, "temporary", ttl=60)
        assert await cache.delete(key) is True
        assert await cache.get(key) is None

68
02:02:15,000 --> 02:02:30,000
We test delete operation. After deleting a key, get should return None.
We also test that delete returns True when the key existed.

69
02:02:30,000 --> 02:03:00,000
[CODE: test key namespacing]
    @pytest.mark.integration
    def test_key_namespacing(self):
        assert build_key("query", "abc123") == "finrag:query:abc123"

70
02:03:00,000 --> 02:03:15,000
We test the build_key function. It should create properly namespaced keys
in the format "finrag:namespace:identifier". This prevents key collisions.

71
02:03:15,000 --> 02:03:45,000
[CODE: test clear namespace]
    @pytest.mark.integration
    async def test_clear_namespace(self, cache):
        for i in range(3):
            await cache.set(build_key("cleartest", str(i)), i, ttl=60)
        assert await cache.clear_namespace("cleartest") == 3

72
02:03:45,000 --> 02:04:00,000
We test clear_namespace. This deletes all keys under a namespace. We create
three keys under "cleartest". We clear the namespace. We verify all three
keys were deleted.

73
02:04:00,000 --> 02:04:15,000
Now let me give you a debugging tip. If tests fail with connection errors,
check that Docker services are running.

74
02:04:15,000 --> 02:04:30,000
Run docker ps to verify containers are up. If they're not running, start them
with docker compose up -d.

75
02:04:30,000 --> 02:04:45,000
If tests fail with "database does not exist", check that the database was
created correctly. The init script runs automatically on first container start.

76
02:04:45,000 --> 02:05:00,000
You can verify by connecting to PostgreSQL with psql and running \l to list databases.

77
02:05:00,000 --> 02:05:15,000
If tests fail with "extension vector not found", check that the vector extension
was installed. The init script should create it with CREATE EXTENSION IF NOT EXISTS.

78
02:05:15,000 --> 02:05:30,000
You can verify by running \dx in psql to list installed extensions.

79
02:05:30,000 --> 02:05:45,000
If Redis tests fail with "connection refused", check that Redis is running.
Redis runs on port 6379 by default.

80
02:05:45,000 --> 02:06:00,000
Now let me show you how to run the tests. First, make sure Docker services
are running. Then activate your virtual environment. Then run pytest.

81
02:06:00,000 --> 02:06:15,000
[CODE: running tests]
# Activate virtual environment
source .venv/bin/activate

# Run all integration tests
pytest tests/integration/test_phase1_foundation.py -v

82
02:06:15,000 --> 02:06:30,000
You should see output like this showing all tests passing.

83
02:06:30,000 --> 02:06:45,000
[CODE: expected output]
============================= test session starts =============================
collected 15 items
test_phase1_foundation.py ...............                            [100%]
============================= 15 passed in 12.34s =============================

84
02:06:45,000 --> 02:07:00,000
All green means everything is working. If you see red, check the error message
and fix the issue. The error message will tell you exactly what failed and why.

85
02:07:00,000 --> 02:07:15,000
[Visual: Passing vs failing test output]

86
02:07:15,000 --> 02:07:30,000
Let me walk you through a failed test scenario. Suppose the database isn't
running. The test_connection_is_live test will fail with a connection error.

87
02:07:30,000 --> 02:07:45,000
The error message will say "Could not connect to PostgreSQL". The fix is simple:
start the database with docker compose up -d postgres. Then run the test again.

88
02:07:45,000 --> 02:08:00,000
This is the fast feedback loop that makes testing so valuable. You find problems
immediately and fix them immediately.

89
02:08:00,000 --> 02:08:15,000
[Visual: Fast feedback loop animation]

90
02:08:15,000 --> 02:08:30,000
Now, let me give you a secret about professional development. The best developers
write tests first. They think about what the code should do before writing it.

91
02:08:30,000 --> 02:08:45,000
This is called Test-Driven Development or TDD. Even if you don't practice TDD,
writing tests after you write code is still valuable.

92
02:08:45,000 --> 02:09:00,000
Tests give you confidence that your code works. They catch regressions when you
make changes. They serve as documentation for how the code should behave.

93
02:09:00,000 --> 02:09:15,000
[Visual: Test-Driven Development cycle — Red, Green, Refactor]

94
02:09:15,000 --> 02:09:30,000
Now, let me show you one more thing. Look at the test_health_check method
in the DatabaseClient. This tests the health_check method.

95
02:09:30,000 --> 02:09:45,000
It verifies that the health check returns the expected fields: status,
postgres_version, server_start_time, pool_size, pool_checked_out, pool_overflow.

96
02:09:45,000 --> 02:10:00,000
This is important because the API uses health checks for its /health endpoint.
If the health check fails, the API will report the service as unhealthy.

97
02:10:00,000 --> 02:10:15,000
Now, let's recap what we've covered in Part 6. We've written integration tests
for all our Phase 1 components.

98
02:10:15,000 --> 02:10:30,000
We test the settings system with TestSettings. We test the database client with
TestDatabase. We test the cache client with TestCache.

99
02:10:30,000 --> 02:10:45,000
We use pytest fixtures for setup and teardown. We use markers to categorize tests.
We use assertions to verify expected behavior. We use Docker for service isolation.

100
02:10:45,000 --> 02:11:00,000
This is the foundation of a reliable system. Without tests, you're flying blind.
With tests, you have confidence that your code works correctly.

101
02:11:00,000 --> 02:11:15,000
Now, let me give you a final perspective. You've just completed Phase 1 of
building a production-grade Financial RAG Agent.

102
02:11:15,000 --> 02:11:30,000
You have a modern Python project with the src layout. You have a comprehensive
settings system with Pydantic. You have a database client with connection pooling
and health checks.

103
02:11:30,000 --> 02:11:45,000
You have a cache client with typed operations and namespace management.
You have Docker infrastructure with PostgreSQL (pgvector) and Redis.
You have integration tests that verify everything works.

104
02:11:45,000 --> 02:12:00,000
This is not just a tutorial project. This is a real foundation for a production
system. Everything you build in later phases will rest on this foundation.

105
02:12:00,000 --> 02:12:15,000
[Visual: Phase 1 complete — all components highlighted in green]

106
02:12:15,000 --> 02:12:30,000
In Phase 2, we'll build the SEC EDGAR ingestion pipeline. We'll download filings,
parse HTML, extract text, and store them in the database.

107
02:12:30,000 --> 02:12:45,000
But for now, let's celebrate this milestone. You've built the foundation.
Everything else is built on top of this. Well done.

108
02:12:45,000 --> 02:13:00,000
I'd like to give you a quick exercise. Run the integration tests yourself.
Make sure everything passes. If something fails, try to fix it.

109
02:13:00,000 --> 02:13:15,000
This is the best way to learn. You'll encounter real errors and learn how
to debug them. That's how you become a better developer.

110
02:13:15,000 --> 02:13:30,000
This completes Phase 1 of the Financial RAG Agent series.
You now have a complete, working foundation for a production-grade
financial intelligence system.

111
02:13:30,000 --> 02:13:45,000
Thank you for watching, and I'll see you in the next phase. Happy coding!

112
02:13:45,000 --> 02:14:00,000
[Visual: Phase 1 complete — course summary and what's next]
```

---

### STATS TRACKER — PART 6 COMPLETE

| Metric | Part 6 | Target |
|---|---|---|
| Words | ~5,200 | ~5,500 |
| Characters | ~20,800 | ~22,000 |
| Sentences | ~210 | ~220 |
| Paragraphs | ~240 | ~250 |
| Reading Level | College Student | College Student |
| Speaking Time | ~35 minutes | ~35 minutes |

---

## Phase 1 Complete

| Part | Topic | Status |
|---|---|---|
| Part 1 | Project Structure & pyproject.toml | ✅ Complete |
| Part 2 | Environment & Settings | ✅ Complete |
| Part 3 | Database Client | ✅ Complete |
| Part 4 | Cache Client | ✅ Complete |
| Part 5 | Docker Infrastructure | ✅ Complete |
| Part 6 | Verification Tests | ✅ Complete |
