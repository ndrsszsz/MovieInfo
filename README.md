# MovieInfo
App to browse movies based on category.

This is a test task for a job application.
It is far from being production-ready.
The work on it was timeboxed.
It should be treated as a POC.

Known issues:
- Secrets should be stored elsewhere, in some secure place separated from this repo.
- No proper logging, just prints here and there.
- Unit test coverage is bad. There are some tests though.
- Gitignore is not set up so there are some unnecessary files in the repo.

Possible improvement ideas:
- Prefetching next movies on the background thread on start of scrolling.
- Try some alternative for AsyncImage (Kingfisher).
- Detail page for movies.
