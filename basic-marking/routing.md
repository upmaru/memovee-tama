Your task is to decide how to route the conversation. Choosing the `response` will allow the LLM to respond to the user's query. Choosing other classes will allow the LLM to continue thinking and call tools.

## Rules
1. **Enough Data in Context** - If there is enough data in the context to answer the user's query, you should respond by choosing `response` class. All other classes will continue thinking.
2. **Follow the class guidelines** - The class guidelines will help you choose the right class.

## Examples
<case>
  <condition>
    The user has made a search query for movies and there are search results in context.

    The user then indicates they've seen a particular title or multiple titles from the search results.
  </condition>
  <chat-history>
    user: Show me some good movies to watch

    assistant: [makes tool call to search for movies]

    tool: [returns search results with multiple movies]

    assistant: Here are some great movies you might enjoy: [lists movies from search results]

    user: I've seen The Wild Robot already
  </chat-history>
  <routing>
    movie-browsing
  </routing>
  <reasoning>
    1. The user made a search query and received movie results.

    2. The user indicated they've seen one of the titles from the search results.

    3. The system should mark the movie as seen and then continue browsing to find alternatives.

    4. Route to `movie-browsing` to handle the marking and provide alternative recommendations.
  </reasoning>
</case>

<case>
  <condition>
    The user starts the conversation by mentioning they've seen a movie and wants recommendations based on it.
  </condition>
  <chat-history>
    user: I've seen Dune: Part Two, can you show me more like this?
  </chat-history>
  <routing>
    movie-browsing
  </routing>
  <reasoning>
    1. The user is starting the conversation with a movie they've watched.

    2. They're asking for similar recommendations.

    3. The system needs to mark the mentioned movie as seen and then search for similar content.

    4. Route to `movie-browsing` to handle both the marking and the browsing request.
  </reasoning>
</case>

<case>
  <condition>
    The user starts the conversation asking for recommendations after watching a movie.
  </condition>
  <chat-history>
    user: I just watched The Count of Monte Cristo, what should I watch next?
  </chat-history>
  <routing>
    movie-browsing
  </routing>
  <reasoning>
    1. The user indicates they recently watched a specific movie.

    2. They're asking for what to watch next, which requires recommendations.

    3. The system should mark the movie as seen and provide recommendations.

    4. Route to `movie-browsing` to handle the marking and recommendation process.
  </reasoning>
</case>

<case>
  <condition>
    The user explicitly asks to mark a movie with a specific status without requesting further browsing or recommendations.
  </condition>
  <chat-history>
    user: Can you mark The Wild Robot as seen?
  </chat-history>
  <routing>
    response
  </routing>
  <reasoning>
    1. The user is making a simple marking request.

    2. They are not asking for recommendations or browsing.

    3. This is a direct action request that can be completed and responded to.

    4. Route to `response` to handle the marking and confirm completion.
  </reasoning>
</case>

<case>
  <condition>
    The user asks to mark a movie as favorite without requesting additional browsing.
  </condition>
  <chat-history>
    user: Can you mark Transformers One as favorite?
  </chat-history>
  <routing>
    response
  </routing>
  <reasoning>
    1. The user is requesting a specific marking action (favorite).

    2. No browsing or recommendation request is implied.

    3. This is a direct action that can be completed with a simple response.

    4. Route to `response` to handle the marking and provide confirmation.
  </reasoning>
</case>

---

<classes>
  {{ classes }}
</classes>
