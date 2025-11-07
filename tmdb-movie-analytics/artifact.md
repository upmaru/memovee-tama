## Movie Analytics Specific Rules

### Artifact Rendering Rule
  - For `body.artifact.type` you can choose between `chart` and `dashboard`.

You will need to render the artifact configuration based on the data in context. When you have aggregation data from Elasticsearch, use the appropriate type:

#### When to Use "chart" vs "dashboard"
- **Use `"chart"`**: For single visualizations or when there's only ONE plot/chart to display
- **Use `"dashboard"`**: ONLY when you need to display MULTIPLE plots/charts together in a combined view

**Critical Rule**: If your configuration has only one plot in the `plots` array, you should use `"type": "chart"` instead of `"type": "dashboard"`. Dashboard type is reserved for multiple charts displayed together.

### Chart Formatter Directives - Security Guidelines

When working with charts in this Phoenix LiveView application, you must use safe formatter directives instead of JavaScript functions for security reasons. Here's how to use them:

#### Available Formatter Directives

##### Basic Currency Formatters
- `"currency"` → `$1,234` (with locale formatting)

##### Unit Formatters
- `"unit:billion"` → `$5B`
- `"unit:million"` → `$10M`
- `"unit:thousand"` → `$500K`
- `"unit:movies"` → `42 movies`
- `"unit:movie"` → `1 movie`
- `"unit:stars"` → `5 stars`
- `"unit:star"` → `1 star`
- `"unit:percent"` → `75%`
- `"unit:users"` → `100 users`
- `"unit:user"` → `1 user`
- `"unit:items"` → `25 items`
- `"unit:item"` → `1 item`

##### Number Formatters
- `"number:localestring"` → `1,234,567`
- `"number:integer"` → `42` (rounds to whole number)

##### Percentage Formatters
- `"percent:0"` → `75%` (no decimals)
- `"percent:1"` → `75.5%` (1 decimal)
- `"percent:2"` → `75.50%` (2 decimals)

##### Dynamic Formatters

###### ToFixed Format: `tofixed:decimals:suffix`
- `"tofixed:2:stars"` → `4.50 stars`
- `"tofixed:1:rating"` → `8.5 rating`
- `"tofixed:0:points"` → `100 points`

###### Currency Format: `currency:unit:symbol`
- `"currency:billion"` → `$15B` (defaults to $)
- `"currency:million:€"` → `€10M`
- `"currency:thousand:£"` → `£500K`

###### Round Format: `round:decimals:suffix`
- `"round:0:items"` → `42 items`
- `"round:2:avg"` → `3.14 avg`
- `"round:1"` → `42.5` (no suffix)

#### Security Requirements
- **Always use string directives** - Never use JavaScript function strings
- **Example of CORRECT usage**: `"formatter": "unit:movies"`
- **Example of INCORRECT usage**: `"formatter": "function(val) { return val + ' movies' }"` ❌ SECURITY RISK

#### Where to Apply Formatters
You can use formatters in these chart option locations:
- `yaxis.labels.formatter`
- `xaxis.labels.formatter`
- `tooltip.y.formatter`
- `tooltip.x.formatter`
- `dataLabels.formatter`
- `plotOptions.[chartType].dataLabels.formatter`

#### Common Movie Analytics Use Cases
- Revenue charts: `"unit:billion"` or `"unit:million"`
- Movie counts: `"unit:movies"`
- Star ratings: `"tofixed:1:stars"`
- User metrics: `"unit:users"`
- Percentages: `"percent:1"`

### Chart-Specific Configuration Requirements

#### Treemap Charts
When using treemap charts (`"type": "treemap"`), you must include the following plotOptions configuration:

```json
"plotOptions": {
  "treemap": {
    "distributed": true
  }
}
```

This ensures proper color distribution across treemap segments for better visual distinction.

**Note**: If the user specifically requests a "less colorful" or "monochrome" treemap, you can remove the entire `plotOptions` section to use the default treemap coloring scheme.

#### Bar Charts Data Labels
For both horizontal and vertical bar charts, data labels should use horizontal orientation for better readability:

**Horizontal Bar Charts:**
```json
"plotOptions": {
  "bar": {
    "horizontal": true,
    "dataLabels": {
      "position": "center",
      "orientation": "horizontal"
    }
  }
}
```

**Vertical Bar Charts:**
```json
"plotOptions": {
  "bar": {
    "horizontal": false,
    "dataLabels": {
      "position": "top",
      "orientation": "horizontal"
    }
  }
}
```

**Critical Rule**: Data labels should NEVER use `"orientation": "vertical"` as it makes text hard to read. Always use `"orientation": "horizontal"` or omit data labels entirely if they would be cluttered.

**Best Practice**: If horizontal data labels would be too crowded or hard to read, disable data labels completely with `"dataLabels": {"enabled": false}` rather than using vertical orientation.

**Preferred Approach**: Use tooltips instead of data labels whenever possible. Tooltips provide a cleaner chart appearance and make it easier for users to see precise data values when they hover over chart elements. Set `"dataLabels": {"enabled": false}` and ensure tooltips are properly configured with appropriate formatters.

**Terminology Note**: When users refer to "numbers on the bars", "values on the bars", or "text on the bars", they are referring to the `dataLabels` configuration.

#### Chart Titles
Chart titles must always be structured as objects with a `text` property, never as plain strings:

**CORRECT:**
```json
"title": {
  "text": "Movie Revenue by Year and Quarter",
  "align": "center"
}
```

**INCORRECT:**
```json
"title": "Movie Revenue by Year and Quarter"
```

This applies to both individual chart titles and plot titles within dashboards. Always use the object format to avoid rendering errors.

## Example: Rating Distribution Bar Chart

Let's say you receive Elasticsearch aggregation data showing movie rating ranges like this:

```json
{
  "took": 1,
  "timed_out": false,
  "hits": {
    "total": {
      "value": 1000,
      "relation": "eq"
    },
    "max_score": null,
    "hits": []
  },
  "aggregations": {
    "vote_average_ranges": {
      "buckets": [
        {
          "key": "0.0-1.0",
          "from": 0,
          "to": 1,
          "doc_count": 0
        },
        {
          "key": "1.0-2.0",
          "from": 1,
          "to": 2,
          "doc_count": 1
        },
        {
          "key": "2.0-3.0",
          "from": 2,
          "to": 3,
          "doc_count": 9
        },
        // ... redacted for brevity
        {
          "key": "7.0-8.0",
          "from": 7,
          "to": 8,
          "doc_count": 387
        },
        {
          "key": "8.0-9.0",
          "from": 8,
          "to": 9,
          "doc_count": 64
        },
        {
          "key": "9.0-10.0",
          "from": 9,
          "to": 10,
          "doc_count": 0
        }
      ]
    }
  }
}
```

To render this data as a bar chart showing the distribution of movie ratings, you would create an artifact like this:

```json
{
  "path": {
    "message_id": "[the ORIGIN ENTITY IDENTIFIER in <context-metadata>]"
  },
  "body": {
    "artifact": {
      "type": "chart",
      "references": [
        // the tool_call_ids from the search results to display
      ],
      "configuration": {
        "chart": {
          "type": "bar",
          "height": 400
        },
        "title": {
          "text": "Movie Rating Distribution",
          "align": "center"
        },
        "xaxis": {
          "categories": ["0.0-1.0", "1.0-2.0", "2.0-3.0", "3.0-4.0", "4.0-5.0", "5.0-6.0", "6.0-7.0", "7.0-8.0", "8.0-9.0", "9.0-10.0"],
          "title": {
            "text": "Rating Ranges"
          }
        },
        "yaxis": {
          "title": {
            "text": "Number of Movies"
          }
        },
        "series": [
          {
            "name": "Movies Count",
            "data": [0, 1, 9, 5, 20, 133, 379, 387, 64, 0]
          }
        ],
        "plotOptions": {
          "bar": {
            "horizontal": false,
            "columnWidth": "70%",
            "dataLabels": {
              "position": "top"
            }
          }
        },
        "dataLabels": {
          "enabled": true,
          "offsetY": -20,
          "style": {
            "fontSize": "12px",
            "colors": ["#304758"]
          }
        },
        "colors": ["#008FFB"],
        "tooltip": {
          "y": {
            "formatter": "unit:movies"
          }
        }
      }
    }
  }
}
```

### Key Mapping Principles

When transforming Elasticsearch aggregation data into ApexChart configurations:

1. **Extract categories from bucket keys**: Use each bucket's `key` field for the x-axis categories array
2. **Extract data values from doc_count**: Use each bucket's `doc_count` field for the series data array
3. **Choose appropriate chart types**:
   - "bar" for distributions and comparisons
   - "line" for trends over time
   - "pie" for proportional data
4. **Add descriptive titles**: Include meaningful chart and axis titles
5. **Configure tooltips**: Use safe formatter directives to show contextual information (see Chart Formatter Directives above)
6. **Apply consistent styling**: Use colors and data labels for better readability

The example above transforms the rating range buckets into a clear bar chart where users can easily see the distribution of movies across different rating ranges.

## Example: Nested Aggregation - Movies by Year and Rating Distribution

When dealing with nested aggregations that show data across multiple dimensions (like movies by year with rating breakdowns), you can create stacked bar charts. Consider this Elasticsearch response:

```json
{
  "took": 2,
  "aggregations": {
    "movies_by_year": {
      "buckets": [
        {
          "key_as_string": "2016",
          "key": 1451606400000,
          "doc_count": 100,
          "vote_average_ranges": {
            "buckets": [
              {
                "key": "0-1",
                "from": 0,
                "to": 1,
                "doc_count": 0
              },
              {
                "key": "1-2",
                "from": 1,
                "to": 2,
                "doc_count": 0
              },
              // ... redacted for brevity
              {
                "key": "6-7",
                "from": 6,
                "to": 7,
                "doc_count": 39
              },
              {
                "key": "7-8",
                "from": 7,
                "to": 8,
                "doc_count": 32
              }
            ]
          }
        },
        {
          "key_as_string": "2017",
          "key": 1483228800000,
          "doc_count": 100,
          "vote_average_ranges": {
            "buckets": [
              // Similar structure for 2017 data...
            ]
          }
        }
        // ... more years redacted for brevity
      ]
    }
  }
}
```

To render this nested data as a stacked bar chart showing movies by year with rating distribution breakdowns:

```json
{
  "path": {
    "message_id": "[the ORIGIN ENTITY IDENTIFIER in <context-metadata>]"
  },
  "body": {
    "artifact": {
      "type": "chart",
      "references": [
        // the tool_call_ids from the search results to display
      ],
      "configuration": {
        "chart": {
          "type": "bar",
          "stacked": true,
          "height": 500
        },
        "title": {
          "text": "Movies by Year and Rating Distribution",
          "align": "center"
        },
        "xaxis": {
          "categories": ["2016", "2017", "2018", "2019", "2020", "2021", "2022", "2023", "2024"],
          "title": {
            "text": "Release Year"
          }
        },
        "yaxis": {
          "title": {
            "text": "Number of Movies"
          }
        },
        "legend": {
          "position": "top",
          "horizontalAlign": "center"
        },
        "plotOptions": {
          "bar": {
            "horizontal": false,
            "columnWidth": "80%"
          }
        },
        "series": [
          {
            "name": "0-1",
            "data": [0, 0, 0, 0, 0, 0, 0, 0, 0]
          },
          {
            "name": "1-2",
            "data": [0, 0, 0, 0, 1, 0, 0, 0, 0]
          },
          {
            "name": "2-3",
            "data": [1, 0, 0, 0, 4, 1, 0, 1, 2]
          },
          {
            "name": "4-5",
            "data": [3, 4, 1, 3, 2, 1, 2, 1, 1]
          },
          {
            "name": "5-6",
            "data": [19, 15, 10, 12, 21, 11, 8, 9, 14]
          },
          {
            "name": "6-7",
            "data": [39, 38, 43, 40, 34, 38, 33, 39, 39]
          },
          {
            "name": "7-8",
            "data": [32, 36, 39, 32, 32, 44, 51, 44, 37]
          },
          {
            "name": "8-9",
            "data": [6, 7, 7, 12, 6, 5, 6, 4, 6]
          }
        ],
        "colors": ["#FF4560", "#008FFB", "#00E396", "#775DD0", "#FEB019", "#FF9800", "#4CAF50", "#9C27B0"],
        "tooltip": {
          "shared": true,
          "intersect": false,
          "y": {
            "formatter": "unit:movies"
          }
        },
        "dataLabels": {
          "enabled": false
        }
      }
    }
  }
}
```

### Handling Nested Aggregations

For nested aggregation data like the example above:

1. **Extract outer bucket keys**: Use `key_as_string` or `key` from the parent aggregation for x-axis categories
2. **Process inner aggregations**: Loop through each parent bucket's nested aggregation buckets
3. **Create series per rating range**: Each rating range becomes a separate series in the stacked chart
4. **Map data across years**: For each series, collect the doc_count values across all years
5. **Use stacked configuration**: Set `"stacked": true` in chart options to stack the bars
6. **Apply distinct colors**: Use different colors for each rating range to distinguish the segments
7. **Configure shared tooltips**: Enable shared tooltips to show all rating ranges for each year

This creates a comprehensive view showing both the total movie count per year and how ratings are distributed within each year.

## Example: Percentile Aggregation - Revenue Percentiles by Year

When working with percentile aggregations that show statistical distributions across time periods, line charts are ideal for visualizing trends. Consider this Elasticsearch response showing revenue percentiles:

```json
{
  "took": 3,
  "aggregations": {
    "movies_by_year": {
      "buckets": [
        {
          "key_as_string": "2016",
          "key": 1451606400000,
          "doc_count": 100,
          "revenue_percentiles": {
            "values": {
              "10.0": 0,
              "20.0": 0,
              "30.0": 23934871.5,
              "40.0": 77331662.2,
              "50.0": 114402439,
              "60.0": 185645485.2,
              "70.0": 240730000,
              "80.0": 351172246.6,
              "90.0": 638370828.5
            }
          }
        },
        {
          "key_as_string": "2017",
          "key": 1483228800000,
          "doc_count": 100,
          "revenue_percentiles": {
            "values": {
              // Similar percentile data for 2017...
            }
          }
        }
        // ... more years redacted for brevity
      ]
    }
  }
}
```

To render this percentile data as a multi-line chart showing revenue trends across different percentiles:

```json
{
  "path": {
    "message_id": "[the ORIGIN ENTITY IDENTIFIER in <context-metadata>]"
  },
  "body": {
    "artifact": {
      "type": "chart",
      "references": [
        // the tool_call_ids from the search results to display
      ],
      "configuration": {
        "chart": {
          "type": "line",
          "height": 450,
          "zoom": {
            "enabled": true
          }
        },
        "title": {
          "text": "Movie Revenue Percentiles by Year",
          "align": "center"
        },
        "xaxis": {
          "categories": ["2016", "2017", "2018", "2019", "2020", "2021", "2022", "2023", "2024"],
          "title": {
            "text": "Release Year"
          }
        },
        "yaxis": {
          "title": {
            "text": "Revenue (USD)"
          },
          "labels": {
            "formatter": "unit:million"
          }
        },
        "series": [
          {
            "name": "50th percentile (Median)",
            "data": [114402439, 119607525, 82339272, 64380428, 0, 2921071, 14090599, 39063126, 2756330]
          },
          {
            "name": "70th percentile",
            "data": [240730000, 281957804, 244959399, 219272463, 1882980, 72140617, 102128947, 203402999, 75704460]
          },
          {
            "name": "80th percentile",
            "data": [351172246, 409565818, 393082385, 334927583, 27846664, 158941342, 170921525, 294788826, 175644695]
          },
          {
            "name": "90th percentile",
            "data": [638370828, 797794185, 608814134, 764258489, 111597179, 336349051, 407147132, 478108492, 480260116]
          }
        ],
        "stroke": {
          "curve": "smooth",
          "width": 3
        },
        "colors": ["#008FFB", "#00E396", "#FEB019", "#FF4560"],
        "legend": {
          "position": "top",
          "horizontalAlign": "center"
        },
        "tooltip": {
          "shared": true,
          "intersect": false,
          "y": {
            "formatter": "currency"
          }
        },
        "markers": {
          "size": 4,
          "hover": {
            "size": 6
          }
        }
      }
    }
  }
}
```

### Working with Percentile Aggregations

For percentile aggregation data like the example above:

1. **Extract time periods**: Use `key_as_string` from outer buckets for x-axis categories
2. **Process percentile values**: Extract specific percentiles from the nested `values` object
3. **Create series per percentile**: Each percentile (50th, 70th, 80th, 90th) becomes a separate line
4. **Format large numbers**: Use formatter functions to display values in millions for readability
5. **Enable smooth curves**: Use `"curve": "smooth"` for better trend visualization
6. **Configure zoom**: Allow users to zoom in on specific time periods
7. **Use distinct colors**: Different colors help distinguish between percentile lines

This visualization is particularly useful for understanding revenue distribution patterns and how they change over time, showing both central tendencies and outlier performance.

## Example: Multi-Metric Dashboard - Comprehensive Movie Analytics

When you have multiple aggregations providing different metrics for analysis, dashboards allow you to create comprehensive views with multiple charts. Consider this Elasticsearch response with various movie metrics:

```json
{
  "took": 4,
  "aggregations": {
    "movies_by_year": {
      "buckets": [
        {
          "key_as_string": "2016",
          "key": 1451606400000,
          "doc_count": 100,
          "vote_percentiles": {
            "values": {
              "50.0": 6.680499792098999,
              "95.0": 8.002500009536742
            }
          },
          "total_revenue": {
            "value": 21958854432
          },
          "revenue_percentiles": {
            "values": {
              "50.0": 114402439,
              "95.0": 878972192.8499998
            }
          },
          "avg_revenue": {
            "value": 219588544.32
          }
        },
        {
          "key_as_string": "2017",
          "key": 1483228800000,
          "doc_count": 100,
          "vote_percentiles": {
            "values": {
              // Similar nested data for other metrics...
            }
          }
        }
        // ... more years redacted for brevity
      ]
    }
  }
}
```

To render this multi-metric data as a dashboard with multiple coordinated visualizations:

```json
{
  "path": {
    "message_id": "[the ORIGIN ENTITY IDENTIFIER in <context-metadata>]"
  },
  "body": {
    "artifact": {
      "type": "dashboard",
      "references": [
        // the tool_call_ids from the search results to display
      ],
      "configuration": {
        "title": "Movie Industry Analytics Dashboard",
        "plots": [
          {
            "title": {
              "text": "Revenue Overview: Total vs Average per Movie",
              "align": "center"
            },
            "series": [
              {
                "name": "Total Revenue",
                "type": "column",
                "data": [21.96, 24.13, 22.61, 23.94, 3.24, 10.56, 15.30, 17.10, 13.92]
              },
              {
                "name": "Avg Revenue per Movie",
                "type": "line",
                "data": [219.59, 241.26, 226.06, 239.38, 32.39, 105.65, 152.98, 171.03, 139.21]
              }
            ],
            "chart": {
              "height": 400,
              "type": "line",
              "toolbar": { "show": true },
              "zoom": { "enabled": false }
            },
            "stroke": {
              "width": [0, 4],
              "curve": "smooth"
            },
            "plotOptions": {
              "bar": {
                "borderRadius": 4,
                "columnWidth": "60%"
              }
            },
            "colors": ["#3498db", "#e74c3c"],
            "labels": ["2016", "2017", "2018", "2019", "2020", "2021", "2022", "2023", "2024"],
            "xaxis": {
              "title": { "text": "Year" }
            },
            "yaxis": [
              {
                "title": { "text": "Total Revenue (Billions $)" },
                "labels": {
                  "formatter": "unit:billion"
                }
              },
              {
                "opposite": true,
                "title": { "text": "Average Revenue (Millions $)" },
                "labels": {
                  "formatter": "unit:million"
                }
              }
            ],
            "tooltip": {
              "shared": true,
              "intersect": false,
              "y": [
                {
                  "formatter": "unit:billion"
                },
                {
                  "formatter": "unit:million"
                }
              ]
            }
          },
          {
            "title": {
              "text": "Revenue Distribution Analysis",
              "align": "center"
            },
            "series": [
              {
                "name": "Median Revenue (P50)",
                "data": [114.40, 119.61, 82.34, 64.38, 0, 2.92, 14.09, 39.06, 2.76]
              },
              {
                "name": "Top Tier Revenue (P95)",
                "data": [878.97, 885.93, 922.87, 1099.51, 206.06, 434.14, 863.16, 691.59, 724.32]
              }
            ],
            "chart": {
              "height": 350,
              "type": "line",
              "toolbar": { "show": true }
            },
            "colors": ["#2ecc71", "#9b59b6"],
            "stroke": {
              "width": 3,
              "curve": "smooth"
            },
            "markers": { "size": 5 },
            "labels": ["2016", "2017", "2018", "2019", "2020", "2021", "2022", "2023", "2024"],
            "xaxis": {
              "title": { "text": "Year" }
            },
            "yaxis": {
              "title": { "text": "Revenue (Millions $)" },
              "labels": {
                "formatter": "unit:million"
              }
            },
            "tooltip": {
              "shared": true,
              "y": {
                "formatter": "unit:million"
              }
            }
          },
          {
            "title": {
              "text": "Movie Ratings Quality Analysis", 
              "align": "center"
            },
            "series": [
              {
                "name": "Median Rating (P50)",
                "data": [6.68, 6.89, 6.90, 6.90, 6.55, 6.95, 7.10, 6.96, 6.91]
              },
              {
                "name": "Top Rating (P95)",
                "data": [8.00, 8.04, 8.10, 8.14, 8.09, 7.99, 8.07, 7.96, 8.04]
              }
            ],
            "chart": {
              "height": 350,
              "type": "line",
              "toolbar": { "show": true }
            },
            "colors": ["#f39c12", "#e67e22"],
            "stroke": {
              "width": 3,
              "curve": "smooth"
            },
            "markers": { "size": 5 },
            "labels": ["2016", "2017", "2018", "2019", "2020", "2021", "2022", "2023", "2024"],
            "xaxis": {
              "title": { "text": "Year" }
            },
            "yaxis": {
              "title": { "text": "Vote Rating" },
              "min": 6,
              "max": 9,
              "tickAmount": 6
            },
            "tooltip": {
              "shared": true,
              "y": {
                "formatter": "tofixed:2:stars"
              }
            }
          }
        ]
      }
    }
  }
}
```

### Creating Multi-Chart Dashboards

When working with complex aggregation data that spans multiple metrics:

1. **Use dashboard type**: Set `"type": "dashboard"` instead of `"chart"`
2. **Structure multiple plots**: Each plot in the `plots` array represents a separate visualization
3. **Coordinate related metrics**: Group related metrics in the same plot (e.g., total vs average revenue)
4. **Apply consistent styling**: Use complementary colors and consistent formatting across plots
5. **Optimize chart heights**: Balance detail with overview - key metrics get more space
6. **Enable interactivity**: Include toolbars and zoom capabilities for detailed analysis
7. **Format for context**: Use appropriate units (millions, billions) and meaningful labels

This dashboard approach provides stakeholders with a comprehensive view of movie industry trends, revenue patterns, and quality metrics all in one coordinated interface.
