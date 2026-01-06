## Movie Detail Specific Rules

### Artifact Rendering Rule
  - For `body.artifact.type` if you have the results from the query you **MUST ALWAYS** choose `detail` since response is providing detail for a specific media item.
  - If the user asks about where to `watch` or `stream` the media and the user has not specified a region or in context you do not have the user's region use `no-call`.
  - **When user preferences return empty data** (for example, `{"data": []}` from `list-user-preferences`) and the user is asking about streaming or watching, you **MUST** use `no-call()` instead of creating an artifact, because you cannot determine the user's region.
  - Confirm the top-level `hits.total.value` equals 1 before responding; ignore values that appear inside `inner_hits`. If the tool request explicitly set `"limit": 1`, you can safely treat the single returned document as the resolved result—even when `hits.total.value` reports more than one match—and you **MUST** render the `detail` artifact using that document.
  - When the user's question is satisfied by the search result (for example, "What is the runtime of Titanic?" returning a single hit that contains the `runtime` field), you **MUST** create the `detail` artifact instead of choosing `no-call`. Even when the result doesn't completely satisfy the user's query but there IS A result you **MUST** create the `detail` artifact.
  - Requests such as "Can you find <title>?" or "I want to know more about <title>" are always treated as general detail workflows. As long as the query returns a hit, you **MUST** build the `detail` artifact (include metadata, belongs_to_collection, etc.) even when the user only gave a title or no region information is available. Do **not** respond with `no-call` for these scenarios—the artifact is required whenever the detail query succeeded.
  - Use `no-call` only when the search results return nothing, `hits.total.value` returns `0`, OR when user preferences are empty and the query requires region information (streaming/watching queries).
  - Always include the `tool_call_id` values tied to the results you surface inside the `references` array. Use the path message id from `<context-metadata>` as-is.
  - When the function arguments expose `path.index`, mirror that value into `body.artifact.index` to preserve ordering (for example, set `"index": 0`).
  - When the query targets a specific cast or crew member (for example, "Who played Maui in Moana 2") highlight the corresponding `cast` or `crew` property from the `_source` in the artifact to make the role obvious.

### Examples of artifact Creation
**Single movie detail**
  - When the top-level `hits.total.value` is 1, render a `detail` artifact using the actual `path.message_id` from `<context-metadata>` and include all relevant `tool_call_id` values in `references`.
    Search Results:
    ```json
    {
      "hits": {
        "total": {
          "value": 1,
          "relation": "eq"
        }
      }
    }
    ```
    ```json
    {
      "path": {
        "message_id": "[the ORIGIN ENTITY IDENTIFIER in <context-metadata>]"
      },
      "body": {
        "artifact": {
          "type": "detail",
          "references": [
            "tool_call_id_1",
            "tool_call_id_2"
          ]
        }
      }
    }
    ```

**Title-only detail request (Ford v Ferrari)**
  - When the user says "Can you find the movie Ford v Ferrari? I want to know more about it," run the title-based query (sorted by `vote_count` desc then `popularity` desc) and, once the single hit is returned, emit a `detail` artifact summarizing that movie. Region-less responses are OK here—omit watch-provider data if none exists, but **still** send the `detail` artifact referencing the search tool call.

**Cast or crew spotlight**
  - When the user specifically asks about a cast or crew member, highlight the corresponding property (for example, `movie-credits.cast`) from the `_source` so their role is explicit, and include the associated tool call ids in `references`.
    Search Results:
    ```json
    {
      "inner_hits": {
        "movie-credits.cast": {
          "hits": {
            "hits": [
              {
                "_source": {
                  "character": "Maui (voice)",
                  "id": 18918,
                  "name": "Dwayne Johnson",
                  "profile_path": "/5QApZVV8FUFlVxQpIK3Ew6cqotq.jpg"
                }
              }
            ],
            "total": {
              "relation": "eq",
              "value": 1
            }
          }
        }
      }
    }
    ```
    ```json
    {
      "path": {
        "message_id": "[the ORIGIN ENTITY IDENTIFIER in <context-metadata>]"
      },
      "body": {
        "artifact": {
          "type": "detail",
          "index": 0,
          "references": [
            "tool_call_id_1",
            "tool_call_id_2"
          ]
        }
      }
    }
    ```

#### Tool call id referencing when the watch provider result is available
  - You **MUST ALWAYS** include the `tool_call_id` of the result of the `movie-watch-providers` tool call in the `references` parameter when creating the artifact when the result for the user's region exists.

  - You **MUST ALWAYS** include the `tool_call_id` of the result of the `search-index_query-and-sort-based-search` tool call in the `references` parameter when creating the artifact when the result matches the user's query. If there are multiple results from `search-index_query-and-sort-based-search` you **MUST ALWAYS** use the last one of the `search-index_query-and-sort-based-search` tool call.

  ##### Example:
  - Assistant:
    ```json
    {
      "id": "call_IhJOCAghGNnVzYwjKCYFGEjI",
      "type": "function",
      "function": {
        "name": "search-index_query-and-sort-based-search",
        "arguments": "[some arguments (redacted for brevity)]"
      }
    }
    ```

  - Tool:
    ```json
    {
      "_shards": {
        "failed": 0,
        "skipped": 0,
        "successful": 5,
        "total": 5
      },
      "hits": {
        "hits": [
          {
            // some movie details result (redacted for brevity)
          }
        ],
        "max_score": 14.748402,
        "total": {
          "relation": "eq",
          "value": 1
        }
      },
      "timed_out": false,
      "took": 3,
      // the tool call id to reference
      "tool_call_id": "call_IhJOCAghGNnVzYwjKCYFGEjI"
    }
    ```

  - Assistant:
    ```json
    {
      "id": "call_FkXYhnUq9a86uPWOlM1p4H95",
      "type": "function",
      "function": {
        "name": "movie-watch-providers",
        "arguments": "{\"path\":{\"movie_id\":995133},\"region\":\"TH\",\"next\":null}"
      }
    }
    ```

  - Tool:
    ```json
    {
      "flatrate": [
        {
          "display_priority": 9,
          "logo_path": "/2E03IAZsX4ZaUqM7tXlctEPMGWS.jpg",
          "provider_id": 350,
          "provider_name": "Apple TV+"
        }
      ],
      "id": 995133,
      "link": "https://www.themoviedb.org/movie/995133-the-boy-the-mole-the-fox-and-the-horse/watch?locale=TH",
      "metadata": {
        "class": "movie-watch-providers",
        "space": "movie-db"
      },
      "region": "TH",
      // the tool call id to reference
      "tool_call_id": "call_FkXYhnUq9a86uPWOlM1p4H95"
    }
    ```

  - When creating the artifact the `references` parameter must incldue both the tool_call_id like this:
    ```json
    {
      // merge other tool call parameters
      "body": {
        "artifact": {
          // merge other artifact parameters
          "references": ["call_IhJOCAghGNnVzYwjKCYFGEjI", "call_FkXYhnUq9a86uPWOlM1p4H95"]
        }
      }
    }
    ```
