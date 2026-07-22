# VectorDB AI Assistant

A high-performance C++ vector database built from scratch, featuring Brute Force, KD-Tree, and HNSW search algorithms. It includes a custom REST API, a responsive frontend UI with a 2D PCA scatter plot, and a Retrieval-Augmented Generation (RAG) pipeline powered by either local LLMs via Ollama or the cloud-based Gemini API.

![C++17](https://img.shields.io/badge/C%2B%2B-17-blue.svg)
![Ollama](https://img.shields.io/badge/Ollama-Offline-orange.svg)
![Gemini API](https://img.shields.io/badge/Gemini-Cloud-blue.svg)
![REST API](https://img.shields.io/badge/API-REST-green.svg)
![HNSW](https://img.shields.io/badge/Search-HNSW%20%7C%20KD--Tree-purple.svg)
![RAG](https://img.shields.io/badge/Pipeline-RAG-blue.svg)

---

## Live Demo

The application is deployed on Railway:
- **Production URL**: [https://vectordb-ai-assistant-production.up.railway.app](https://vectordb-ai-assistant-production.up.railway.app)

---

## Features

- **HNSW Vector Search**: High-dimensional Hierarchical Navigable Small World graph implementation for fast approximate nearest neighbor search.
- **KD-Tree Search**: Space-partitioning index optimized for exact nearest neighbor queries in low-to-medium dimensions.
- **Brute Force Search**: Exhaustive linear search providing a 100% accurate ground-truth baseline.
- **Multiple Distance Metrics**: Support for Cosine similarity, Euclidean distance, and Manhattan distance metrics.
- **Semantic Vector Search**: Live vector search and real-time visualization on pre-loaded 16D semantic dataset.
- **Interactive Visualization**: Live 2D PCA projection scatter plot visualizing cluster formations and search paths.
- **Document Embeddings**: Text chunking and embedding generation using local models or Gemini API.
- **Retrieval-Augmented Generation (RAG)**: Full RAG pipeline that fetches context from local documents to answer questions with an LLM.
- **REST API**: Clean endpoints for operations including search, insert, delete, stats, and benchmarks.
- **Dual Inference Modes**: Runs completely offline using local models via Ollama, or scales instantly in production using the cloud-based Gemini API (when `GEMINI_API_KEY` is provided).
- **Benchmarking**: Compare execution speeds of HNSW, KD-Tree, and Brute Force search side-by-side.

---

## Tech Stack

| Technology | Purpose | Details |
|---|---|---|
| **C++17** | Core Engine | Custom database structures, indexes, and algorithm implementations |
| **Ollama** (Local Mode) | Local AI Gateway | Offline nomic-embed-text (768D) & llama3.2 (LLM) |
| **Gemini API** (Prod Mode) | Cloud Inference | text-embedding-004 (768D) & gemini-1.5-flash (LLM) |
| **cpp-httplib** | Web Server | Lightweight single-header HTTP server with OpenSSL support |
| **CMake** | Build System | Handles multi-platform compilation and dependency linking |
| **Docker** | Containerization | Production-ready multi-stage Ubuntu build configuration |
| **HTML5 / Vanilla CSS** | Frontend UI | Clean, modern user interface, responsive layout, dark theme |
| **JavaScript** | UI & Visualization | Handles state, API client logic, and PCA canvas rendering |

---

## Architecture

```
       +------------------------------------+
       |              User / UI             |
       +-----------------+------------------+
                         |
                         | HTTP Requests
                         v
       +-----------------+------------------+
       |             REST API               |
       |  (Dynamic Port / Health Checks)    |
       +-----------------+------------------+
                         |
                         | Query & Commands
                         v
       +-----------------+------------------+
       |          VectorDB Engine           |
       +--------+--------+--------+---------+
                |        |        |
        +-------+        |        +-------+
        | HNSW           | KD-Tree        | Brute Force
        v                v                v
  +-----+----+     +-----+----+     +-----+----+
  | Indexing |     | Indexing |     | Baseline |
  +-----+----+     +-----+----+     +-----+----+
        |                |                |
        +-------+--------+--------+-------+
                         |
                         | Embeddings & Text Context
                         v
       +-----------------+------------------+
       |         Inference Manager          |
       +--------+------------------+--------+
                |                  |
                | (If KEY set)     | (Default)
                v                  v
       +--------+--------+  +------+--------+
       |   Gemini API    |  |    Ollama     |
       |  (Cloud RAG)    |  |  (Local RAG)  |
       +-----------------+  +---------------+
```

---

## Environment Variables

| Variable | Description | Default | Required in Production |
|---|---|---|---|
| `PORT` | The port the web server binds to | `8080` | Yes (Railway/Render binds dynamically) |
| `GEMINI_API_KEY` | Google AI developer API key | (empty - defaults to Ollama) | Optional (Required for production cloud RAG) |

---

## Local Setup

### Prerequisites
- A C++17 compliant compiler (`clang++` or `g++`)
- `CMake` (version 3.12+)
- `OpenSSL` libraries (`libssl-dev` on Linux, `openssl@3` via Homebrew on macOS)

### 1. Offline Mode: Local Ollama Setup
If running locally without an internet connection, install Ollama from [ollama.com](https://ollama.com) and pull models:
```bash
ollama pull nomic-embed-text
ollama pull llama3.2
```

### 2. Compile and Run with CMake
```bash
# Clone the repository
git clone https://github.com/Sumanth0718/vectordb-ai-assistant.git
cd vectordb-ai-assistant

# Build using CMake
mkdir build && cd build
cmake ..
make -j$(nproc)

# Start the server (runs local Ollama by default)
./db
```

### 3. Compile and Run using Gemini API Fallback
Provide your Gemini API key in the environment to bypass local Ollama:
```bash
export GEMINI_API_KEY="your-gemini-api-key"
./db
```

Access the dashboard at `http://localhost:8080`.

---

## Docker & Container Usage

### 1. Build Production Docker Image Locally
```bash
docker build -t vectordb-ai-assistant .
```

### 2. Run Container with Gemini API
```bash
docker run -d \
  -p 8080:8080 \
  -e PORT=8080 \
  -e GEMINI_API_KEY="your-gemini-api-key" \
  --name vectordb-app \
  vectordb-ai-assistant
```

### 3. Deploy Multi-Container Stack (Docker Compose)
We provide a zero-configuration Docker Compose stack that spins up the backend and a local Ollama instance, auto-downloading the necessary models at startup:
```bash
docker compose up -d
```

---

## Cloud Deployment (Railway)

To deploy to **Railway**:
1. Connect your GitHub repository to a new Railway project.
2. Railway will automatically detect the `Dockerfile` and configure build settings.
3. In Railway **Variables**, add the following:
   - `GEMINI_API_KEY` = `[Your Google Gemini API Key]`
4. Railway binds `PORT` dynamically. The backend will read the port and start listening.
5. Once built, generate a domain in the Railway dashboard to expose the public endpoint.

---

## REST API Reference

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/health` | Health check endpoint returning `{"status":"healthy"}` |
| `GET` | `/status` | Server status showing model details and active configurations |
| `GET` | `/stats` | Statistics on loaded vectors (dimension, metrics, count) |
| `GET` | `/items` | List all preloaded semantic 16D vectors |
| `GET` | `/search` | Query 16D database using specific algorithm and metric |
| `POST` | `/insert` | Add a new raw 16D vector to the database |
| `DELETE` | `/delete/:id` | Remove a 16D vector from the database by ID |
| `GET` | `/benchmark` | Execute test query across HNSW, KD-Tree, Brute Force and output timing |
| `GET` | `/hnsw-info` | Fetch current HNSW graph details, layers, and connections |
| `POST` | `/doc/insert` | Slice text document, generate 768D embeddings, save to index |
| `DELETE` | `/doc/delete/:id`| Remove a document chunk from index |
| `GET` | `/doc/list` | Retrieve list of loaded document previews |
| `POST` | `/doc/search` | Semantic nearest neighbor search over document chunks |
| `POST` | `/doc/ask` | Retrieve relevant document context and generate LLM RAG response |

---

## Troubleshooting

### CMake cannot find OpenSSL
- **macOS**: CMake may fail to find Homebrew's OpenSSL install. Build by specifying the path:
  ```bash
  cmake -DOPENSSL_ROOT_DIR=/opt/homebrew/opt/openssl@3 ..
  ```
- **Ubuntu/Debian**: Ensure you have installed the development libraries:
  ```bash
  sudo apt-get install libssl-dev
  ```

### RAG/Document operations fail
- Ensure you have either set `GEMINI_API_KEY` in your environment or running Ollama locally with `nomic-embed-text` and `llama3.2` models.
- If using Docker Compose, check the `ollama-setup` logs to verify the models downloaded completely:
  ```bash
  docker compose logs ollama-setup
  ```
