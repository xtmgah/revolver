#' helper function to calculate diversity indices
#' 
#' @param   x           revolver output 
#' @param   n.boot      number of bootstraps (default is 1)
#' @param   table       return a table of results? (default is FALSE) 
#' @param   index       'Shannon' or 'VA' (default is Shannon) 
#' @param   type        'before.expansion' or 'after.expansion' (default after)
#' @param   driver.only use driver events only? (default is FALSE)
#' 
#' @return
#' 
#' @importFrom  vegan diversity specnumber
#' @importFrom  qualvar VA
revolver_DETindex <- function(x, 
                              n.boot=1, 
                              table=FALSE, 
                              index=c('Shannon','VA'), 
                              type=c('after.expansion','before.expansion'),
                              driver.only=FALSE) {
    
  type <- match.arg(type)
  index <- match.arg(index)
  feat <- revolver.featureMatrix(x)
  how <- paste0(ifelse(driver.only, "driver", "all"), 
                ifelse(type=="before.expansion", "before", "after"))

  switch(how, 
    "driverbefore"=doidx(x=x, w=x$fit$multinomial.penalty, n=n.boot, 
                         index=index, table=table),
    "allbefore"=idx(x=x, w=x$fit$multinomial.penalty, n=n.boot, 
                    index=index, table=table),
    "driverafter"=doidx(x=x, w=DFW2Matrix(feat$consensus.explosion), n=n.boot, 
                        index=index, table=table),
    "allafter"=idx(x=x, w=DFW2Matrix(feat$consensus.explosion), n=n.boot, 
                   index=index, table=table)
  )

}


# helper fn: Support 2 types of indices
rev_eval <- function(M, index=c("Shannon","VA")) { 
  index <- match.arg(index)
  if (index == 'Shannon') {
    values <- vegan::diversity(M,MARGIN=2)/log(vegan::specnumber(M,MARGIN=2))
    values[is.na(values)] = 0 # normalized at 0 (100% homogenous trajectories)
  } else if (index == 'VA') {
    values <- apply(M, 2, qualvar::VA)
  } else { 
    stop('Unknown index? Use "Shannon" or "VA".')
  }
  return(values)
} 


# helper fn: driver-only index 
doidx <- function(x, w, n, index, table=FALSE) {
  w <- w[, -1]
  DET <- rev_eval(w, index) # empirical
  res <- list(DET.cohort = NULL, DET.driver = DET)
  return(res) 
}


# helper fn: all lesions index 
idx <- function(x, w, n, index, table=FALSE) { 
  w <- w[, -1]
  DET <- rev_eval(w, index) # empirical
  npbs <- c()
  pb <- txtProgressBar(min = 1, max = n, style = 3)
  pb.status <- getOption('revolver.progressBar', default = TRUE)
  for (i in seq_len(n)) {
    # update progress bar
    if (pb.status) setTxtProgressBar(pb, i)
    npb <- w[, sample(ncol(w), replace = TRUE)]
    npbs[i] <- sum(rev_eval(npb, index))
    # DET = DET + rev_eval(npb, index)/n
  }
  close(pb)
  cat(green(' DONE\n\n'))
  return(list(DET.cohort = npbs, DET.driver = DET))
} 
