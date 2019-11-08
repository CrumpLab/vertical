# Run all of this to run the experiment in a browser
# critical randomization is done by R right now
# so this should be run to initiate the experiment for each new subject
# After the experiment is complete, the data should be stored in the data folder
# when finished, "stop" the server that will be be started by this code

library(xprmntr)

rmarkdown::render("experiments/Experiment 1/experiment/index.Rmd", "html_document")

run_locally(path="experiments/Experiment 1/",
            show_in = "browser",
            xprmntr_host = "127.0.0.1",
            xprmntr_port = 8000)



