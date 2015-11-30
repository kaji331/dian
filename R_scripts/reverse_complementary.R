reverseComplementary <- function(x) {
	a <- strsplit(x,"")[[1]]
	for (i in 1:length(a)) {
		if (a[i] == "A") {
			a[i] <- "T"
			next
        }
        if (a[i] == "T") {
            a[i] <- "A"
            next
        }
        if (a[i] == "G") {
            a[i] <- "C"
            next
        }
        if (a[i] == "C") {
            a[i] <- "G"
            next
        }
        if (is.na(a[i]))
           next
        if (is.null(a[i]))
           next
    }
    return(paste0(rev(a),collapse=""))
}
