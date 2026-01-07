Your task is to decide how to route the conversation. Choosing the `response` will allow the LLM to respond to the user's query. Choosing other classes will allow the LLM to continue thinking and call tools.

## Rules
1. **Enough Data in Context** - If there is enough data in the context to answer the user's query, you should respond by choosing `response` class. All other classes will continue thinking.
2. **Follow the class guidelines** - The class guidelines will help you choose the right class.

## Examples
<case>
  <condition>
    The user has provided you with some new data and you created the user's preferences.

    You now have enough information from the user to make query about the media the user is interested in.
  </condition>
  <chat-history>
    user: Can you tell me where I can stream Moana 2?

    assistant: Where are you streaming from?

    user: I'm streaming from Thailand.

    assistant: [makes tool call to create or update the user's regional preferences]

    tool: [shows successful creation of user's regional preferences]
  </chat-history>
  <routing>
    movie-detail
  </routing>
  <reasoning>
    1. The user initially asked where they can stream a specific movie.

    2. The assistant didn't have the regional preferences from the user and asks the user to provide them.

    3. The user provides their regional data.

    4. The assistant saves the preferences and then should use the new information to query the tools in `movie-detail`.

    5. Tool call was successful.

    6. Next step is to use the data to query the tools in `movie-detail`.
  </reasoning>
</case>

<case>
  <condition>
    The user wants a list of movies available in their region.

    The assistant collected the region, updated the user's preferences, and now needs to browse multiple titles matching the request.
  </condition>
  <chat-history>
    user: Only show me comedies I can stream in my location.

    assistant: I need to know your region first. Where are you streaming from?

    user: I'm in Singapore.

    assistant: [makes tool call to create or update the user's regional preferences]

    tool: [shows successful creation of user's regional preferences]
  </chat-history>
  <routing>
    movie-browsing
  </routing>
  <reasoning>
    1. The user is seeking multiple comedies filtered by their streaming region, which is a browsing-style request.

    2. The assistant obtained the missing regional data and successfully saved it via `list-user-preferences`.

    3. With the region now in context, the correct next step is to run multi-movie searches, so route to `movie-browsing`.
  </reasoning>
</case>

<case>
  <condition>
    The user wants movies filtered by both their region and specific streaming providers, but the streaming providers are not configured yet.
  </condition>
  <chat-history>
    user: Show me comedies I can stream on my subscriptions in Canada.

    assistant: I can do that—can you confirm your region and the streaming services you want me to filter by?

    user: I'm in Canada, but I haven't told you the services yet.

    assistant: [makes tool call to update the user's regional preferences with Canada]

    tool: [shows successful creation of user's regional preferences]
  </chat-history>
  <routing>
    response
  </routing>
  <reasoning>
    1. The user needs movies filtered not only by region but also by their streaming services.

    2. Although the region is saved, the streaming-provider data is still missing, so running browsing queries would give incorrect results.

    3. We must respond to ask the user to set their streaming providers (e.g., via the preferences link) before routing to any querying workflow, so choose `response`.
  </reasoning>
</case>

<case>
  <condition>
    The user previously asked about streaming availability for MULTIPLE movies (using plural references like "these", "them").

    The assistant asked for the user's region because it was missing.

    The user has now provided their region and preferences were successfully saved.
  </condition>
  <chat-history>
    user: [Previous messages show search results with multiple movies]

    user: Where can I stream these?

    assistant: I need to know your region to look up where these movies are available to stream. Could you let me know which country you're in?

    user: I'm in Germany.

    assistant: [makes tool call to create or update the user's regional preferences]

    tool: [shows successful creation of user's regional preferences]
  </chat-history>
  <routing>
    movie-browsing
  </routing>
  <reasoning>
    1. The user's initial query was about streaming availability for MULTIPLE movies from existing search results (using plural reference "these").

    2. The assistant collected the missing regional data and successfully saved it.

    3. With the region now in context, the assistant needs to query streaming availability for those multiple movies.

    4. Since this involves querying multiple movies with streaming provider filters, route to `movie-browsing`.

    5. CRITICAL: The key indicator is the plural reference to movies ("these", "them", "which ones") in the original streaming availability question.
  </reasoning>
</case>

---

<classes>
  {{ classes }}
</classes>
