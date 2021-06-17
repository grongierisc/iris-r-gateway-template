getMode <- function(x) {
  l <- unique(x)
  l[which.max(tabulate(match(x, l)))]
}

getLength <- function(x) {
  length(x)
}

createHistJPG <- function(data, dir, label) {
  dir2 = paste(dir, "/hist.jpeg", sep="")
  jpeg(file = dir2)
  hist(data, xlab=label)
  dev.off()
}

createHistPNG <- function(data, dir, label) {
  dir2 = paste(dir, "/hist.png", sep="")
  png(file = dir2)
  hist(data, xlab=label)
  dev.off()
}

createHistPDF <- function(data, dir, label) {
  dir2 = paste(dir, "/hist.pdf", sep="")
  pdf(file = dir2)
  hist(data, xlab=label)
  dev.off()
}

# install.packages("party", repos='http://cran.us.r-project.org')
# library(party)
# decisionTree <- function(dir) {
#   dir2 = paste(dir, "/tree.png", sep="")
#   input.dat <- readingSkills[c(1:105),]
#   png(file=dir2)
#   output.tree <- ctree(
#     nativeSpeaker ~ age + shoeSize + score,
#     data = input.dat)
#   plot(output.tree)
#   dev.off()
# }
