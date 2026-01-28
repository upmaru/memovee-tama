Your task is to decide how to route the conversation. Choosing the `response` will allow the LLM to respond to the user's query. Choosing other classes will allow the LLM to continue thinking and call tools.

## Rules
1. **Enough Data in Context** - If there is enough data in the context to answer the user's query, you should respond by choosing `response` class. All other classes will continue thinking.
2. **Follow the class guidelines** - The class guidelines will help you choose the right class.
3. **Filmography-style browsing routes to movie-by-person** - If the user is asking for a list of movies/TV featuring a person (e.g., "top 10 movies with [person]", "movies with [person] in it", "show me their best movies") and the person's `id` is already loaded in context, route to `movie-by-person` to fetch and display multiple titles using that `id`.

## Examples
<case>
  <condition>
    The user asked for a ranked list of movies featuring a specific person.

    The assistant has already loaded the person's profile into context and now has the person's `id`.
  </condition>
  <chat-history>
    user: Find me the top 10 movies with Gene Hackman in it.

    assistant: [makes a tool call to load Gene Hackman's person record by name, returning at least `id` and `name`]

    tool: [returns Gene Hackman's person record and includes the `id`]
  </chat-history>
  <routing>
    movie-by-person
  </routing>
  <reasoning>
    1. The user wants a list of movies (a browsing result), not a person profile response.

    2. The person `id` is now available in context from the person lookup.

    3. The next step is to search movies using that person `id`, which is handled by tooling in `movie-by-person`.
  </reasoning>
</case>

<case>
  <condition>
    The user asks for a person's details/profile.

    The assistant has already loaded that person's record into context (the needed fields are available from the most recent tool result).
  </condition>
  <chat-history>
    user: Show me Gene Hackman's profile.

    assistant: [makes a tool call to load Gene Hackman's person record]

    tool: [returns Gene Hackman's person record]
  </chat-history>
  <routing>
    response
  </routing>
  <reasoning>
    1. The user is requesting details about the person, not a list of movies.

    2. The person record is already loaded in context with enough fields to answer.

    3. The next step is to respond to the user, so choose `response`.
  </reasoning>
</case>

---

<classes>
  {{ classes }}
</classes>
