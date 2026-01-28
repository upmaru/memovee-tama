Queries that specifically ask for movies or TV shows featuring one or more known people when their TMDB person IDs are already in context. This includes filmography-style requests, "movies with [person]" follow-ups, and any browsing query that primarily constrains results by cast or crew membership.

  **Examples:**
  - "Show me the best movies starring Keanu Reeves" (after resolving the person ID)
  - "Find films directed by Greta Gerwig released since 2015"
  - "Movies with Tom Hanks and Meg Ryan together"

  **Routing Logic:** Route to `movie-by-person` when the conversation already contains the relevant person IDs and the user now wants movie/TV results that depend on those IDs. If the IDs are not yet known, stay in the person-detail or person-browsing workflows until they are resolved.
