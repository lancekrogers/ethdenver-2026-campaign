---
fest_type: task
fest_id: 04_implement_0g_storage.md
fest_name: implement_0g_storage
fest_parent: 01_inference_0g
fest_order: 4
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Implement 0G Storage Integration

## Objective

Implement the `StorageClient` interface to store inference results, agent memory, and intermediate data on 0G decentralized storage. This package handles chunked uploads, content-addressed retrieval, and metadata management. Stored data serves as persistent memory for the inference agent and provides verifiable storage of inference outputs.

**Project:** `agent-inference` at `projects/agent-inference/`
**Package:** `internal/zerog/storage/`

## Requirements

- [ ] Implement the `StorageClient` interface defined in the architecture task
- [ ] Support uploading data with metadata to 0G Storage
- [ ] Support chunked uploads for large inference results
- [ ] Support downloading data by content identifier
- [ ] Support listing stored items by prefix for agent memory retrieval
- [ ] Handle all errors with contextual wrapping
- [ ] Pass `context.Context` through all I/O operations

## Implementation

### Step 1: Research 0G Storage API

Investigate how 0G Storage works:

1. Check if 0G Storage provides a Go client library
2. Identify the storage node endpoints (testnet)
3. Determine the upload protocol: is it HTTP multipart? gRPC streaming? On-chain transaction?
4. Understand the content addressing scheme: IPFS-style CIDs? Custom hashes?
5. Check if there are size limits per upload and whether chunking is required

Document findings in a comment block at the top of `client.go`.

### Step 2: Define the model types

In `internal/zerog/storage/models.go`:

```go
package storage

import "time"

// Metadata describes a stored item on 0G Storage.
type Metadata struct {
    // ContentID is the content-addressed identifier for retrieval.
    ContentID string

    // Name is a human-readable name for the stored item.
    Name string

    // Size is the total size in bytes.
    Size int64

    // ContentType is the MIME type of the stored data.
    ContentType string

    // Tags are key-value pairs for organizing and filtering.
    Tags map[string]string

    // CreatedAt is when the item was stored.
    CreatedAt time.Time
}

// UploadOptions configures the upload behavior.
type UploadOptions struct {
    // ChunkSize overrides the default chunk size for large uploads.
    // Set to 0 to use the default (4MB).
    ChunkSize int64

    // ContentType is the MIME type of the data being uploaded.
    ContentType string

    // Tags are optional key-value pairs attached to the upload.
    Tags map[string]string
}
```

### Step 3: Implement the storage client

In `internal/zerog/storage/client.go`:

```go
package storage

import (
    "context"
)

// ClientConfig holds configuration for the 0G Storage client.
type ClientConfig struct {
    // Endpoint is the 0G Storage node URL.
    Endpoint string

    // APIKey is the authentication credential.
    APIKey string

    // DefaultChunkSize is the default chunk size for uploads (bytes).
    // Defaults to 4MB if zero.
    DefaultChunkSize int64

    // MaxRetries is the number of retry attempts for failed operations.
    MaxRetries int
}

// client implements the StorageClient interface using 0G Storage.
type client struct {
    cfg        ClientConfig
    httpClient *http.Client
}

// NewClient creates a new StorageClient connected to 0G Storage.
func NewClient(cfg ClientConfig) (StorageClient, error) {
    // Validate configuration
    // Set defaults (chunk size, retries)
    // Create HTTP client with appropriate timeouts
    // Return initialized client
}
```

Key implementation details for each method:

**Upload(ctx, data, meta)**:
1. Check `ctx.Err()` before starting
2. Determine if chunking is needed (data size > chunk size)
3. For small uploads: single POST request with data and metadata
4. For large uploads: split into chunks, upload each sequentially with context checks between chunks
5. Return the content identifier from the storage response
6. Wrap all errors: `fmt.Errorf("storage: failed to upload %s: %w", meta.Name, err)`

**Download(ctx, contentID)**:
1. Check `ctx.Err()` before starting
2. GET request to the storage node with the content ID
3. Stream the response body into a byte buffer
4. Verify data integrity if a checksum is available
5. Wrap errors: `fmt.Errorf("storage: failed to download %s: %w", contentID, err)`

**List(ctx, prefix)**:
1. Query the storage index with the given prefix
2. Parse metadata from the response
3. Return sorted by creation time (newest first)
4. Wrap errors: `fmt.Errorf("storage: failed to list items with prefix %s: %w", prefix, err)`

### Step 4: Implement chunked upload logic

Extract the chunking logic into a helper:

```go
// uploadChunked splits data into chunks and uploads each one.
func (c *client) uploadChunked(ctx context.Context, data []byte, meta Metadata) (string, error) {
    chunkSize := c.cfg.DefaultChunkSize
    if chunkSize == 0 {
        chunkSize = 4 * 1024 * 1024 // 4MB default
    }

    totalChunks := (int64(len(data)) + chunkSize - 1) / chunkSize

    for i := int64(0); i < totalChunks; i++ {
        if err := ctx.Err(); err != nil {
            return "", fmt.Errorf("storage: context cancelled during chunk %d/%d: %w", i+1, totalChunks, err)
        }

        start := i * chunkSize
        end := start + chunkSize
        if end > int64(len(data)) {
            end = int64(len(data))
        }

        chunk := data[start:end]
        // Upload this chunk to 0G Storage
        // Include chunk index and total chunks in the request
    }

    // Finalize the upload and get the content ID
    // Return the content ID
}
```

### Step 5: Define sentinel errors

```go
var (
    ErrNotFound     = errors.New("storage: content not found")
    ErrUploadFailed = errors.New("storage: upload failed")
    ErrNodeDown     = errors.New("storage: storage node unreachable")
    ErrIntegrity    = errors.New("storage: data integrity check failed")
)
```

### Step 6: Write unit tests

Create `internal/zerog/storage/client_test.go`:

1. **TestUpload_SmallFile**: Upload data below chunk size, verify content ID returned
2. **TestUpload_LargeFile**: Upload data above chunk size, verify chunked upload occurs
3. **TestUpload_ContextCancelled**: Cancel context mid-upload, verify clean exit
4. **TestDownload_Success**: Mock stored data, verify bytes match
5. **TestDownload_NotFound**: Request nonexistent ID, verify ErrNotFound
6. **TestDownload_ContextCancelled**: Cancel during download, verify clean exit
7. **TestList_WithResults**: Mock stored items, verify metadata returned
8. **TestList_Empty**: Mock empty storage, verify empty slice returned
9. **TestUpload_NodeDown**: Mock connection failure, verify ErrNodeDown

Use `httptest.NewServer` to mock the 0G Storage API responses.

### Step 7: Verify compilation and tests

```bash
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/agent-inference
go build ./internal/zerog/storage/...
go test ./internal/zerog/storage/... -v
go vet ./internal/zerog/storage/...
```

## Done When

- [ ] `StorageClient` interface fully implemented in `internal/zerog/storage/client.go`
- [ ] All model types defined in `internal/zerog/storage/models.go`
- [ ] Chunked upload logic handles large files with context checks between chunks
- [ ] Sentinel errors defined for all failure modes
- [ ] Table-driven unit tests cover upload, download, list, chunking, and error cases
- [ ] `go build`, `go test`, and `go vet` all pass cleanly
- [ ] No file exceeds 500 lines, no function exceeds 50 lines
- [ ] 0G Storage API research findings documented in code comments
