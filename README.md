# Marine App

This is a ShinyApp.

This project contains also a script for data transformation and a strucuture based on renv package to ensure the package versions that work.

Folders:

- `app`: ShinyApp files
- `data`: contains data raw (included in gitignore) and clean (exception in gitignore). The clean data is saved in .RDS and loaded from a link in the App.
- `renv`: manage package versions.
- `sources`: some specific files, like customized functions that were not found in packages.