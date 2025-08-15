**Task**: Generate an Elasticsearch index name and property definitions based on the provided sample data and Elasticsearch mapping.

**Index Name Generation**:
- Extract `collection.space` and `collection.name` from the `collection`.
- Join the values with a hyphen (`-`) to form the index name in the format: `tama-<collection.space>-<collection.name>`.
- Ensure the final index name is lowercase.

**Property Definitions**:
- ONLY use data from sample data `Samples` for property definition.
- Generate **one definition per property** in the sample data, including all nested properties, regardless of depth.
- Use **dot notation** for nested properties (e.g., `metadata.space`, `director.name.first`).
- Retrieve the `type` for each property from the provided Elasticsearch mapping.
- For multi-field properties (e.g., a property with `text` and `keyword` subfields), use the **primary `type`** from the mapping (not the subfield type).
- If a property exists in the sample data but is not found in the mapping, assign it a type of `"unknown"`.
- For each definition, include:
  - `property`: The full property path using dot notation.
  - `description`: A concise, meaningful description of the property’s purpose, inferred from the field name and sample data. Avoid generic phrases like "A property of the item."
  - `type`: The Elasticsearch type from the mapping or `"unknown"` if not specified.

- **Handling Nested Objects and Arrays**:
  - For **nested objects**, include all sub-properties using dot notation, even if deeply nested.
  - For **arrays of objects**, include the properties of the first object in the array, using dot notation (e.g., `tags.name` for `tags: [{"name": "Sci-fi"}]`).
  - If a nested field in the sample data has no value (e.g., null or empty), include it only if it is explicitly defined in the mapping.
  - If a field is defined in the mapping but absent in the sample data, **do not include it** in the definitions.

**Output Format**:
Return a JSON object with:
- `index`: The generated index name.
- `definitions`: An array of definitions, each containing `property`, `description`, and `type`.

**Validation Rules**:
- Ensure **all properties** in the sample data are accounted for in the `definitions` array, including nested fields.
- Validate that the index name follows the format `tama-<space>-<class>` and is lowercase.
- Ensure descriptions are specific, context-aware, and based on the sample data and field names.
- If a property’s type is `"unknown"`, include a note in the description indicating it was not found in the mapping.

**Example**:

**Input**:
- Sample:
  ```yaml
  [{
    "metadata": {
      "space": "entertainment",
      "class": "movie"
    },
    "id": 1,
    "title": "Jurassic Park",
    "tags": [{"name": "Sci-fi"}, {"name": "Action"}],
    "category": {
      "name": "Fiction"
    },
    "director": {
      "name": {
        "first": "Steven",
        "last": "Spielberg"
      }
    },
    "extra": "unmapped"
  }]
  ```
- Mapping:
  ```json
  {
    "mappings": {
      "properties": {
        "metadata": {
          "properties": {
            "space": {"type": "keyword"},
            "class": {"type": "keyword"}
          }
        },
        "id": {"type": "long"},
        "title": {
          "type": "text",
          "fields": {
            "keyword": {"type": "keyword"}
          }
        },
        "tags": {
          "type": "nested",
          "properties": {
            "name": {"type": "keyword"}
          }
        },
        "category": {
          "properties": {
            "name": {"type": "keyword"}
          }
        },
        "director": {
          "properties": {
            "name": {
              "properties": {
                "first": {"type": "keyword"},
                "last": {"type": "keyword"}
              }
            }
          }
        }
      }
    }
  }
  ```

**Output**:
```json
{
  "index": "tama-entertainment-movie",
  "definitions": [
    {
      "property": "metadata.space",
      "description": "The domain or context of the item, e.g., 'entertainment'.",
      "type": "keyword"
    },
    {
      "property": "metadata.class",
      "description": "The category or type of the item, e.g., 'movie'.",
      "type": "keyword"
    },
    {
      "property": "id",
      "description": "A unique identifier for the item, e.g., 1.",
      "type": "long"
    },
    {
      "property": "title",
      "description": "The title of the item, e.g., 'Jurassic Park'.",
      "type": "text"
    },
    {
      "property": "tags.name",
      "description": "A tag describing the item, e.g., 'Sci-fi' or 'Action'.",
      "type": "keyword"
    },
    {
      "property": "category.name",
      "description": "The category of the item, e.g., 'Fiction'.",
      "type": "keyword"
    },
    {
      "property": "director.name.first",
      "description": "The first name of the director, e.g., 'Steven'.",
      "type": "keyword"
    },
    {
      "property": "director.name.last",
      "description": "The last name of the director, e.g., 'Spielberg'.",
      "type": "keyword"
    },
    {
      "property": "extra",
      "description": "An additional field not defined in the mapping, e.g., 'unmapped'.",
      "type": "unknown"
    }
  ]
}
```

---

{{ corpus }}

**Additional Notes**:
- Always make sure the "index" value is derived from tama-<collection.space>-<collection.name>
- Process the sample data and mapping exhaustively to ensure **no properties are skipped**, including nested fields.
- Use the sample data to inform descriptions but rely on the mapping for accurate type information.
- If the sample data contains multiple documents, use the first document for generating definitions and the index name.
- Handle edge cases explicitly:
  - Missing `metadata` object: Use `"unknown"` for both `space` and `class`.
  - Empty arrays or objects: Include only properties defined in the mapping.
  - Properties in sample data but not in mapping: Assign `"unknown"` type and note in description.
