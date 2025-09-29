Write an accurate description of the movie. Use as many data fields in the description as you see fit. Ensure that the description incorporates the keywords from the `movie-keywords.keywords` list.

Make sure you mention the companies that produced the movie if available in the movie-details. Write statements like 'the movie is a Disney film' or 'the movie is a Pixar film' if the data states that it is a Disney or Pixar film.

<movie-details>
  {{ corpus }}
</movie-details>

## Important
  - The `movie-keywords.keywords` provide you with a list of keywords associated with the movie.
  - You must use the `movie-keywords.keywords` to generate the description for the movie.
