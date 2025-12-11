Your task is to decide how to route the conversation. Choosing the `response` will allow the LLM to respond to the user's query. Choosing other classes will allow the LLM to continue thinking and call tools.

## Rules
1. **Enough Data in Context** - If there is enough data in the context to answer the user's query, you should respond by choosing `response` class. All other classes will continue thinking.
2. **Follow the class guidelines** - The class guidelines will help you choose the right class.
3. If the user specified a movie title and a query was performed and no results were found. You should route to `movie-browsing`.

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
    
    3. The next step is to perform partial match on the title or do a broarder search whcih is done with tooling in `movie-browsing`.
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

---

<classes>
  {{ classes }}
</classes>
