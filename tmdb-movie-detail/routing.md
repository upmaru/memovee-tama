Your task is to decide how to route the conversation. Choosing the `response` will allow the LLM to respond to the user's query. Choosing other classes will allow the LLM to continue thinking and call tools.

## Rules
1. **Enough Data in Context** - If there is enough data in the context to answer the user's query, you should respond by choosing `response` class. All other classes will continue thinking.
2. **Follow the class guidelines** - The class guidelines will help you choose the right class.
3. If the user specified a movie title and a query was performed and no results were found. You should route to `movie-browsing`.
4. If the user asks for movies similar to a given title (e.g., "movies like [title]", "similar to [title]") and the seed movie has been loaded into context, you should route to `movie-browsing` to perform the similarity search/recommendation step.
5. The user may provide **multiple seed titles** (e.g., "movies like X and Y"). If the required seed movies have been loaded into context (one-at-a-time, chained via `next`), route to `movie-browsing` to run the similarity workflow using all loaded seeds.

## Examples
<case>
  <condition>
    The user has asked to see a particular movie title
    
    The search tool calling returned no results.
  </condition>
  <chat-history>
    user: Tell me about [title]
    
    assistant: [makes tool call to search for the given title]
    
    tool: [returns no result or result with a different title than asked by the user]
  </chat-history>
  <routing>
    movie-browsing
  </routing>
  <reasoning>
    1. The user input the wrong title or misspelled a movie title.
    
    2. The assistant tried searching based on the provided title but found nothing.
    
    3. The next step is to perform partial match on the title or do a broader search which is done with tooling in `movie-browsing`.
  </reasoning>
</case>

<case>
  <condition>
    The user has asked to see a particular movie title
    
    The search tool calling returned exact match on the title
  </condition>
  <chat-history>
    user: Tell me about [title]
    
    assistant: [makes tool call to search for the given title]
    
    tool: [returns exact match of what the user is looking for]
  </chat-history>
  <routing>
    response
  </routing>
  <reasoning>
    1. The user input the correct title.
    
    2. The assistant tried searching based on the provided title and found the exact match.
    
    3. The next step is to provide a `response`.
  </reasoning>
</case>

<case>
  <condition>
    The user asked for movies similar to one or more seed titles.

    The assistant has already loaded the required seed movie record(s) into context (title lookup succeeded), potentially across multiple tool calls chained via `next`.
  </condition>
  <chat-history>
    user: Find me movies like [title] (or movies like [title A] and [title B])

    assistant: [makes tool call(s) to load the seed movie(s) by title, including concept preload fields]

    tool: [returns the seed movie record(s) the user referenced]
  </chat-history>
  <routing>
    movie-browsing
  </routing>
  <reasoning>
    1. The user’s request is for recommendations/similar titles, not details about the seed movie itself.

    2. Loading the seed movie(s) provides the needed context (concept preload) to drive similarity.

    3. The next step is to search/browse for similar movies, which is handled by tooling in `movie-browsing`.
  </reasoning>
</case>

---

<classes>
  {{ classes }}
</classes>
