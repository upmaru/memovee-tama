## Movie Browsing Specific Rules

### Artifact Rendering Rule
  - For `body.artifact.type` you can choose between `table`, `grid` or `list`.
  - Always decide between `list`, `grid`, and `table` using the top-level `hits.total.value`; ignore counts from `inner_hits`.
  - When the user mentions wanting larger images you must use the `grid` layout because it renders the largest images.
  - When the user explicitly asks for a table you must use the `table` layout.

#### List layout (`hits.total.value` < 5)
  - Default to the `list` layout when there are fewer than 5 hits, especially if the `_source` contains rich text properties such as `overview`, `title`, and `poster_path`.
  - Example payload:
    ```json
    {
      "path": {
        "message_id": "[ORIGIN ENTITY IDENTIFIER]"
      },
      "body": {
        "artifact": {
          "type": "list",
          "index": 0,
          "references": [
            "tool_call_id_1"
          ]
        }
      }
    }
    ```

#### Grid layout (`hits.total.value` ≥ 5)
  - Use the `grid` layout whenever there are 5 or more hits because it scales better for larger result sets.
  - Also use `grid` when the user asks for more visual or larger imagery regardless of the hit count.
  - Example payload:
    ```json
    {
      "path": {
        "message_id": "[ORIGIN ENTITY IDENTIFIER]"
      },
      "body": {
        "artifact": {
          "type": "grid",
          "references": [
            "tool_call_id_1"
          ]
        }
      }
    }
    ```

#### Table layout (structured properties)
  - Use the `table` layout whenever the results include structured collections such as `production_companies`, `genres`, or `belongs_to_collection`; this rule overrides the hit-count heuristics.
  - Always include a `configuration.columns` array in table artifacts and make sure each column name maps to `_source` properties ordered by relevance.
  - Example payload:
    ```json
    {
      "path": {
        "message_id": "[ORIGIN ENTITY IDENTIFIER]"
      },
      "body": {
        "artifact": {
          "type": "table",
          "references": [
            "tool_call_id_1",
            "tool_call_id_2"
          ],
          "configuration": {
            "columns": [
              {
                "name": "title",
                "relevance": 2
              },
              {
                "name": "genres",
                "relevance": 1
              },
              {
                "name": "production_companies",
                "relevance": 0
              }
            ]
          }
        }
      }
    }
    ```
