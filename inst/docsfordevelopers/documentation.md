#Documentation for working on the DSAIRM package and developing new Apps 

##To work on package through RStudio: 
* Load DSAIRM.Rproj in RStudio. Edit files as needed.
* Optionally, use RStudio tie-in with github to sync project to github (the 'git' tab).

##Package structure 
* The main R functions, i.e. the menu and the simulation scripts are in the R/ folder
* The R/ folder also has a few helper/convenience functions
* The shiny apps are in the inst/shinyapps/ subfolder (which gets copied to /shinyapps in the deployed package). Each App has a corresponding www/ subfolder which contains the documentation. This folder is automatically generated as described below.
* There are a few other folders in the inst/shinyapps/ directory which do not correspond to shiny apps. Those are:
    * the _allappdocumentation_ folder contains Rmd and html files for the documentation content of all shiny apps. These HTML files are created from the Rmd files and will need to be further processed. See information below. Note that this is not part of the CRAN R package for size reasons, but if you fork the project from github it will be included.
    * The _media_ folder contains figures and a bib file used as part of the documentation (i.e. the Rmd files). Note that this is not part of the CRAN R package for size reasons, but if you fork the project from github it will be included.
    * The _styles_ folder contains css styling for the documentation
    * The _documentationtemplate_ contains an Rmd template that can be used as starting point when writing documentation for a new Shiny App
* \inst\docsfordevelopers contains this file and any other potential information for someone wanting to add new apps to the package
* \inst\simulatorfunctions contains the R code for all simulator functions for easy access and editing by users
* folder \vignettes contains the vignette - this is copied to \inst\doc at some point, don't edit it there
* folder \man contains the documentation, automatically generated by roxygen

##Dependency packages for development
* roxygen
* devtools
* rmarkdown for vignette and shiny documentation
* packages needed: see DESCRIPTION file

##Adding Apps
* Write the main simulator function, following the structure of the existing functions.
* Write the Shiny wrapper/App. Easiest by copying and modifying one of the existing apps.
* Add the simulator function and Shiny app to appropriate directories.

##Integrating Apps
* Add your App to the main menu by modifying dsairmmenu.R and the MainMenu Shiny app.R file.

##To prepare App documentation
* Write the documentation for the app as markdown file. A template exists in the shinyapps/rmarkdowntemplate/ folder. Add information to the template as described in the template. 
* Turn your documentation file into an HTML file and copy to the shinyapps/allappdocumentation/ folder. 
* First part of file name must be the same as name for the Shiny app. You can have additional text following an underscore, it will be stripped.  
* Run the R script processAllFiles.R, which will execute a function by the same name inside the script. This function runs through all html files in that folder and splits them. Each section in the documentation html file that has a 'shinytabNNN' id will be extracted and placed into a separate html file. Any other sections are ignored. Those 'shinytabNNN' files are later loaded by the shiny UI and displayed inside the app.
* The newly created files will be placed in the www subfolders for each shiny app in inst/shinyapps/
* The www subfolder for each shiny app is deleted and re-created on each run, so don't edit manually
* Naming for newly created html files is shinytab1.html, etc. and header.html/footer.html
* see also comments in processAllFiles.R for more details

##To update R documentation and vignette
* Edit documentation inside R functions. 
* Build documentation with More/Document or devtools::document()
* Edit vignette inside the \vignettes folder.
* To build new vignette, run devtools::build_vignettes()

##Contributing your Apps
* The best way to add your apps to the package is if you fork the package from github, write your app, then send a pull request.
* Alternatively, if you are not familiar with that approach, you can email me your new App files and I can manually integrate them.
* If you plan to write and contribute new apps, maybe best if you contact me (ahandel@uga.edu) and we can discuss beforehand, will likely make for a smoother process.

##To build the package:
* "by hand" edit the DESCRIPTION file to make sure it's up to date
* in RStudio, use the functions in the 'build' tab to test and build the package.
* Run clean and rebuild, then build and reload using menu, or devtools::load_all()
* Run the check, fix any errors 

##To use package:
* install either from CRAN or github
* for github install, install devtools package, load it
* then run install_github("ahgroup/DSAIRM")
* library('DSAIRM') 
* dsairmmenu()

##Notes:
* All needed libraries should be loaded via the DESCRIPTION file and not in separate R files