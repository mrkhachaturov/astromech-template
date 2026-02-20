# QMD Model Warmup

This file is used during Docker build to trigger QMD model downloads.

## Purpose

When `qmd embed` and `qmd query` run on this document during image build:
- **Embedding model** (~314MB) downloads for vector search
- **Query expansion model** (~1.2GB) downloads for query variations
- **Reranker model** (~700MB) downloads for result scoring

## Content

The actual content doesn't matter - we just need a markdown file that QMD can:
1. Index into a collection
2. Generate embeddings for
3. Query against

This ensures all three models are baked into the Docker image, preventing first-run delays when users search their memory.

---

**Build timestamp:** <!-- Updated during Docker build -->
**QMD version:** <!-- Matches @tobilu/qmd version in package.json -->
