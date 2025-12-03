## Person Detail Specific Rules

### Artifact Rendering Rule
  - For `body.artifact.type` you **MUST ALWAYS** choose `detail` since the response is providing information about a specific person.
  - Confirm the top-level `hits.total.value` equals 1 before creating the artifact; ignore any counts that appear inside `inner_hits`.
  - Always include the `tool_call_id` values tied to the person detail results inside the `references` array. Use the `path.message_id` from `<context-metadata>` without modification.
  - When the function arguments expose `path.index`, mirror that value into `body.artifact.index` (for example, `"index": 0`) to keep ordering consistent.
  - When the user asks about a specific credit (e.g., “Which movies did this person act in?”) highlight the relevant properties such as `combined_credits.cast` or `combined_credits.crew` in the artifact body so the relationship is clear.

### Examples of artifact Creation
**Single person detail**
  - When the top-level `hits.total.value` is 1, render a `detail` artifact using the actual `path.message_id` and include all relevant `tool_call_id` values in `references`.
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

**Credit spotlight**
  - When the user specifically asks about a credit (for example, “Show me the cast roles for this actor”), highlight the relevant credit entry from `_source` (such as `combined_credits.cast`) and keep the `references` list synchronized with the tool calls that returned those credits.
    Search Results:
    ```json
    {
      "inner_hits": {
        "combined_credits.cast": {
          "hits": {
            "hits": [
              {
                "_source": {
                  "character": "Hero",
                  "title": "Example Movie",
                  "release_date": "2024-01-01"
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
