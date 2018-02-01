#' @title A helper function that takes result from the simulators and produces plots
#'
#' @description This function generates plots to be displayed in the Shiny UI.
#' This is a helper function. This function processes results returned from the simulation, supplied as a list
#' @param input the shiny app input structure
#' @param output the shiny app output structure
#' @param allres a list containing all simulation results.
#'    the length of the list indicates number of separate plots to make, each list entry is one plot and one set of text output
#'    for each list entry (e.g. allres[[i]]$type), 'type' specifies the kind of plot
#'    allres[[i]]$dat contains a dataframe in tidy/ggplot format for plotting. one column is called xvals, one column yvals, further columns are stratifiers/aesthetics, e.g. names of variables or number of run for a given variable
#' @return output a list with plots for display in a shiny UI
#' @details This function is called by the shiny server to produce plots returned to the shiny UI
#' @author Andreas Handel
#' @export

generate_plots <- function(input,output,allres)
{

  # this function produces all plots
  # the resulting plot is a ggplot/ggpubr object and saved in the "plot" placeholder of the output variable
  output$plot <- renderPlot({
    input$submitBtn

    res=isolate(allres()) #get results for processing

    #nplots contains the number of plots to be produced.
    nplots = length(res) #length of list

    allplots=vector("list",nplots) #will hold all plots

    for (n in 1:nplots) #loop to create each plot
    {
      plottype = res[[n]]$plottype
      dat = res[[n]]$dat
      p1 = ggplot2::ggplot(dat, aes(x = xvals, y = yvals, color = varnames) )


      if (plottype == 'Scatterplot') {p2 = p1 + ggplot2::geom_point() }
      if (plottype == 'Lineplot') {p2 = p1 + ggplot2::geom_line() }
      if (plottype == 'Boxplot') {p2 = p1 + ggplot2::geom_boxplot()}

      p3 = p2 + ggplot2::labs(x = res[[n]]$xlab, y = res[[n]]$ylab)
      #p4 = p3 +

      pfinal = p3
      allplots[[n]] = pfinal



    } #end loop over individual plots

    #number of columns needs to be stored in 1st list element
    cowplot::plot_grid(plotlist = allplots, ncol = res[[1]]$ncol)

    } #finish render-plot statement
    , width = 'auto', height = 'auto'
  ) #end the function which produces the plots
}