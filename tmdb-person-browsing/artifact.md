## Person Browsing Specific Rules

### Artifact Rendering Rule
  - For `body.artifact.type` pick between `grid`, `list`, or `table` for multi-result responses; use `detail` only when there is a single hit.
  - Always decide which layout to use based on the top-level `hits.total.value`; ignore counts inside `inner_hits`.
  - Person browsing responses should default to the `grid` layout for bigger sets, but you may switch to `table` when the data contains structured arrays (see Table layout rules below).
  - When the user mentions wanting larger images you must use the `grid` layout because it renders the largest images.

#### List layout (`hits.total.value` < 5)
  - Default to the `list` layout when there are fewer than 5 hits, especially if the `_source` contains rich descriptive text such as `biography`, `known_for_department`, or `profile_path`.
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

#### Grid layout (`hits.total.value` ≥ 5 or grid override)
  - Use the `grid` layout whenever there are 5 or more hits because it scales better for browsing people.
  - Person browsing should always fall back to `grid` when unsure, and you must also use `grid` when the user calls out more visual presentation (e.g., “show me larger images”).
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
  - Use the `table` layout only when the `_source` contains tabular collections such as `combined_credits.cast`, `combined_credits.crew`, or `known_for` that benefit from columnar display. This rule overrides the hit-count heuristics.
  - Always include a `configuration.columns` array in table artifacts using `_source` property names ordered by relevance to the user’s request (for example, `name`, `known_for_department`, `popularity`).
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
                "name": "name",
                "relevance": 2
              },
              {
                "name": "known_for_department",
                "relevance": 1
              },
              {
                "name": "popularity",
                "relevance": 0
              }
            ]
          }
        }
      }
    }
    ```
