version 9

//ssc install estout

sysuse auto, clear
estimates clear

regress weight length
estimates store est1

stgit .
esttab est1 using mytable.csv, replace nonotes ///
	addnotes("Git branch: `r(branch)'" "Git SHA of last commit: `r(sha)'")
