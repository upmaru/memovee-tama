## Media Detail Specific Rules

These rules apply specifically to media detail, when you have a single media item to render.

### Artifact Rendering Rule
  - For `body.artifact.type` you **MUST ALWAYS** choose `detail` since response is providing detail for a specific media item.

### Media Watch Providers and User Region
- If the user has asked about where they can stream or watch a movie.
  - You tried to get the user's region preferences but it didn't exist.
    - **ACTION:** Inform the user to specify their region.
