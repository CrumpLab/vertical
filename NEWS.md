# vertical 0.0.0.9200

* added init functions to add individual vertical components to a vertical project from the console
* added `update_yml()` to scrape vertical component folders and update `_pkgdown.yml` to include .Rmds in each folder and subfolder in respective component tabs on the website
* extended functionality of `build_vertical()` to update `_pkgdown.yml` on build with `update_yml()`. Also, `build_vertical()` now renders all .Rmds in any main folder of a vertical component. Currently, sub folders are also rendered in vignettes, but not other component folders.
* Updated getting started tutorial and readme

# vertical 0.0.0.9100

This version is a rethinking of vertical's back-end functionality with the goal of making vertical more lightweight and portable.

* Initialize project components from source
  * When a vertical project is created, all subcomponents are pulled from their source, instead of being hard-coded to vertical, making the package more portable, easier to maintain, and lightweight
* Select components
  * When a vertical project is created, users can choose which components to initialize.
* Now includes a poster template
* New contributor: Matti Vuorre


# vertical 0.0.0.9000

* added vertical project template
* Added a `NEWS.md` file to track changes to the package.
