Your task is to decide how to route the conversation. Choosing the `response` will allow the LLM to respond to the user's query. Choosing other classes will allow the LLM to continue thinking and call tools.

## Rules
1. **Enough Data in Context** - If there is enough data in the context to answer the user's query, you should respond by choosing `response` class. All other classes will continue thinking.
2. **Follow the class guidelines** - The class guidelines will help you choose the right class.
3. **Movie with multiple people -> movie-by-person** - If the user is trying to find a movie title that includes 2+ specific people and person-browsing has already resolved those people to `id`s in context, route to `movie-by-person` so the next step can search titles using those person IDs.
4. **General people trivia -> response** - If the user asks a general question about people that is not a "find this person in the database" lookup (e.g., awards trivia), route to `response`.

## Examples
<case>
  <condition>
    The user is trying to find a movie that includes two specific people.

    The assistant already ran person-browsing and now has both people `id`s in context.
  </condition>
  <chat-history>
    user: I'm looking for a movie that has Justin Timberlake and Mila Kunis, what movie is it?

    assistant: [makes tool call(s) to find matching people and returns their `id`s]

    tool: [returns person hits that include the resolved `id`s for Justin Timberlake and Mila Kunis]
  </chat-history>
  <routing>
    movie-by-person
  </routing>
  <reasoning>
    1. The user wants a movie title (a browsing/search task), not person profiles.

    2. Person-browsing has resolved the people to `id`s in context.

    3. The next step is to query movies using those person IDs, which is handled by tooling in `movie-by-person`.
  </reasoning>
</case>

<case>
  <condition>
    The user asks a general knowledge question about people (not a database lookup).
  </condition>
  <chat-history>
    user: People who've won the academy award
  </chat-history>
  <routing>
    response
  </routing>
  <reasoning>
    1. This is general awards trivia and is not an Elasticsearch person-lookup request.

    2. The correct action is to respond conversationally, so choose `response`.
  </reasoning>
</case>

<case>
  <condition>
    The user asks a query that requires searching/filtering people (place of birth).
  </condition>
  <chat-history>
    user: Which actors are born in Thailand?
  </chat-history>
  <routing>
    response
  </routing>
  <reasoning>
    1. This is a broad, general question that is better handled as a conversational response (it could imply many results and may need the user to narrow scope).

    2. The correct action is to respond (e.g., ask the user to narrow it down), so choose `response`.
  </reasoning>
</case>

---

<classes>
  {{ classes }}
</classes>
