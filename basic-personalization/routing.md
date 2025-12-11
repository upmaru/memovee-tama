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

---

<classes>
  {{ classes }}
</classes>
