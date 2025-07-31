 Queries that reference a specific movie or TV show where a media ID is explicitly provided in the context, and the user is seeking detailed information about that specific title. These queries typically focus on attributes like release date, budget, cast, filming location, plot details, or other specific facts about the named media.

  **Examples:**
  - (With media ID or Title in context for *Titanic*) "When was *Titanic* released?"
  - (With media ID or Title in context for *The Shawshank Redemption*) "What was the budget for *The Shawshank Redemption*?"
  - (With media ID or Title in context for *Jaws*) "Where did *Jaws* take place?"
  - (With media ID or Title in context for *The Little Mermaid*) "What is the runtime of this movie?"
  - (With media ID or Title in context for *Moana 2*) "Who played Maui in Moana 2?" or "Who voiced Sarabi in Mufasa the lion king?"

  **Routing Logic:** Route to `media-detail` when the query explicitly mentions a movie title or TV show title or when a media ID is available in the context and the query seeks specific details about that media.
