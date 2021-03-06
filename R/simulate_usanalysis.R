############################################################
##this code illustrates how to do uncertainty and sensitivity analysis
##it does sampling of some parameters of the simple bacterial infection model
##written by Andreas Handel (ahandel@uga.edu), last change 7/16/18
############################################################
#'
#' Simulation to illustrate uncertainty and sensitivty analysis
#'
#' @description This function performs uncertainty and sensitivty analysis
#' using the simple, continuous-time basic bacteria model
#' The user provides ranges for the initial conditions and parameter values and the number of samples.
#' The function does latin hypercube sampling (LHS) of the parameters
#' and runs the basic bacteria ODE model for each sample
#' The function returns a list containing values for each sample and results
#'
#' @param B0min lower bound for initial bacteria numbers
#' @param B0max upper bound for initial bacteria numbers
#' @param I0min lower bound for initial immune response
#' @param I0max upper bound for initial immune response
#' @param Bmaxmin lower bound for maximum bacteria load
#' @param Bmaxmax upper bound for maximum bacteria load
#' @param dBmin lower bound for bacteria death rate
#' @param dBmax upper bound for bacteria death rate
#' @param kmin lower bound for immune response kill rate
#' @param kmax upper bound for immune response kill rate
#' @param rmin lower bound for immune response growth rate
#' @param rmax upper bound for immune response growth rate
#' @param dImin lower bound for immune response death rate
#' @param dImax upper bound for immune response death rate
#' @param gmean mean for bacteria growth rate
#' @param gvar variance for bacteria growth rate
#' @param samples number of LHS samples to run
#' @param tmax maximum simulation time, units depend on choice of units for model parameters
#' @param rngseed seed for random number generator#'
#' @return The function returns the output as a list.
#' The list element 'dat' contains a data frame
#' with sample values for each parameter as columns, followed by columns for the results.
#' A final variable 'nosteady' is returned for each simulation.
#' It is TRUE if the simulation did not reach steady state, otherwise FALSE.
#' @details A simple 2 compartment ODE model (the simple bacteria model introduced in the app of that name)
#' is simulated for different parameter values.
#' Parameters are sampled via latin hypercube sampling.
#' Distribution for all parameters is assumed to be uniform between the min and max values.
#' The only exception is the bacteria growth parameter,
#' which is assumed to be gamma distributed with the specified mean and variance.
#' The simulation returns for each parameter sample the peak and final value for B and I.
#' Also returned are all parameter values as individual columns
#' and an indicator stating if steady state was reached.
#' @section Warning: This function does not perform any error checking. So if
#'   you try to do something nonsensical (e.g. specify negative parameter values
#'   or fractions > 1), the code will likely abort with an error message
#' @examples
#' # To run the simulation with default parameters just call this function
#' result <- simulate_usanalysis()
#' # To choose parameter values other than the standard one, specify them e.g. like such
#' result <- simulate_usanalysis(dImin = 0.1, dImax = 10, samples = 5)
#' # You should then use the simulation result returned from the function, e.g. like this:
#' plot(result$dat[,"dI"],result$dat[,"Bpeak"],xlab='values for d',ylab='Peak Bacteria',type='l')
#' @seealso See the shiny app documentation corresponding to this simulator
#' function for more details on this model.
#' @author Andreas Handel
#' @export


simulate_usanalysis <- function(B0min = 1, B0max = 10, I0min = 1, I0max = 10, Bmaxmin=1e5, Bmaxmax=1e6, dBmin=1e-1, dBmax = 1e-1, kmin=1e-7, kmax=1e-7, rmin=1e-3, rmax=1e-3, dImin=1, dImax=2, gmean=0.5, gvar=0.1, tmax = 30, samples = 10, rngseed = 100)
  {

    #this creates a LHS with the specified number of samples for all 8 parameters
    #drawn from a uniform distribution between zero and one
    #if a parameter should be kept fixed, simply set min and max to the same value
    set.seed(rngseed)
    lhssample=lhs::randomLHS(samples,8);

    #transforming parameters to be  uniform between their low and high values
    B0vec = stats::qunif(lhssample[,1],min = B0min, max = B0max)
    I0vec = stats::qunif(lhssample[,2],min = I0min, max= I0max)
    Bmaxvec = stats::qunif(lhssample[,3],min = Bmaxmin, max = Bmaxmax)
    dBvec   = stats::qunif(lhssample[,4],min = dBmin, max = dBmax)
    kvec = stats::qunif(lhssample[,5],min = kmin, max = kmax)
    rvec = stats::qunif(lhssample[,6],min = rmin, max = rmax)
    dIvec = stats::qunif(lhssample[,7],min = dImin, max = dImax)

    #transforming parameter g to a gamma distribution with mean gmean and variance gvar
    #this is just to illustrate how different assumptions of parameter distributions can be implemented
    gvec = stats::qgamma(lhssample[,8], shape = gmean^2/gvar, scale = gvar/gmean);

    Bpeak=rep(0,samples) #initialize vectors that will contain the solution
    Bsteady=rep(0,samples)
    Isteady=rep(0,samples)

    nosteady = rep(FALSE,samples) #indicates if steady state has not been reached
    for (n in 1:samples)
    {
        #values for sampled parameters
        B0=B0vec[n]
        I0=I0vec[n]
        Bmax=Bmaxvec[n]
        dB=dBvec[n];
        k=kvec[n];
        r=rvec[n];
        dI=dIvec[n];
        g=gvec[n];

        #this runs the bacteria ODE model for each parameter sample
        #all other parameters remain fixed
        odeoutput <- simulate_basicbacteria(B0 = B0, I0 = I0, tmax = tmax, g=g, Bmax=Bmax, dB=dB, k=k, r=r, dI=dI)

        timeseries = odeoutput$ts

        Bpeak[n]=max(timeseries[,"Bc"]); #get the peak for B
        Bsteady[n] = utils::tail(timeseries[,"Bc"],1)
        Isteady[n] = utils::tail(timeseries[,"Ic"],1)


        #a quick check to make sure the system is at steady state,
        #i.e. the value for B at the final time is not more than
        #1% different than B several time steps earlier
        vl=nrow(timeseries);
        if ((abs(timeseries[vl,"Bc"]-timeseries[vl-10,"Bc"])/timeseries[vl,"Bc"])>1e-2)
        {
          nosteady[n] = TRUE
        }
    }

    simresults = data.frame(Bpeak = Bpeak, Bsteady = Bsteady, Isteady = Isteady, B0 = B0vec, I0 = I0vec, Bmax = Bmaxvec, dB = dBvec, k = kvec, r = rvec, dI = dIvec, g = gvec, nosteady = nosteady)

    result = list()
    result$dat = simresults
    return(result)
}
