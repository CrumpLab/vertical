# vertical 0.1.0.0000

* Manuscript published online at Behavioral Research Methods

# vertical 0.0.1.0000

* clean up branch to include only master and dev

# vertical 0.0.0.9900

* `vertical_project()` is now a single function for initialization
* `build_vertical()` removes yml updates
* yml suggestion is done by `suggest_yml()`
* minor edits to tutorial

# vertical 0.0.0.9400

* update_yml default is FALSE in build_vertical. Need explicitly overwrite
* enhanced `init_vertical_project()` to allow interactive dialogue for creation, or direct creation by script.

# vertical 0.0.0.9300

* improved documentation, added markdown support
* `init_vertical_project()` can be used to initialize a vertical project from the command line, both within an existing project, or to create new one
* added link to rparp preprint
* fixed `init_supplemental()` bug

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
