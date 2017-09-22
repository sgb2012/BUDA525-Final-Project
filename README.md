# BUDA525-Final-Project
Team Four Final Project for BUDA 525 

BUDA525 – Final Group Project

Assignment: The project for this course is based on the data file "1314-08.csv".  This is every student that has at least one course they are registered for in the year 2013/2014.  You've been given a data dictionary to help you understand the impact and scope of the data set.  This project is designed to help you gain a basic understanding for the overall goal which is to understand who will come to WVU and what their financial aid package will and can be.  Basically, can we adjust the package to get more students in the door. 

In this project, I want you to begin to investigate the factors that affect the financial aid package that the university gives out.  You could look at things like student need, location, merit (test scores, GPA, etc.), as to whether the student is a Promise Scholar or not, and many other things.  I don't want to restrict you on anything in this analysis, so you can define what "financial aid package means" and the approaches you take.  Any insight you give should be based in regression analysis, and any model you report or fit needs diagnostics checked and met, and model selection addressed.  
To access the data, you will you will need to get on goFirst and it is in the group/bprice5 folder.  To call the data use the following code:

setwd("/group/bprice5")
dat<-read.csv("1314C-08.CSV", header=TRUE)

Your group’s analysis should be summarized in 5 pages or less (no smaller than 11-point font, single or double spaced) plus a one-page executive summary (i.e. top sheet, not included in the 5 pages).  In the 5 pages, you should have sections that address (and are clearly 
marked): 

Purpose – A short description of what the project purpose is and why you are doing it.

Data Description – This should identify your data source and any preliminary concerns or findings you have in the data.  Basic summary statistics that you found interesting or useful, or insights it gave you about strategy for your analysis. 

Methodological Work –  What did you to do to the data to get it ready for your analysis, what transformations did you make and why?  What decisions will affect your impact, and then present your model or models, in the context of the problem.  

4) Conclusion & Impact
Executive summary – This should be a few paragraph summary (fitting on a single page) that gives the description and impact of your analysis.  This is your elevator pitch on what you found, and in analytics if useful (which most of the time it is) should include a plot that helps a non-technical person understand what the findings are.  Note I said non-technical person; this does not mean residual plots.  

Any plots or output that you want to include should be put in an Appendix.  You should use Rmarkdown to generate this document, and remember you can hide the code, but the output is important, and showing the code without describing what it does will not work for a novice reader.  The idea of reproducibility is to make the results honest while not requiring someone to understand code.  So, if you fit a model, say what it is then show the results below.  This means you can't show everything, but you can describe what you did and why.  If you put something in an Appendix make sure you reference it, but know it may not be looked at.  The 5 pages should contain the major impact of the analysis.  Remember all the work you do may be really interesting to you but the result is what matters to the business.  Ideally, you'll submit both the RMD file and doc/PDF file to BlackBoard for your group.  

I'm grading on methodology, so it will be graded off your homework rubric with that same criterion met.  
This assignment is Due 10/6/16 by 11:59 PM.
