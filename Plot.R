rm(list = ls())

library(R.matlab)
library(Hmisc)
library(matrixStats)
library(ggplot2)
library(gridExtra)
library(reshape2)
library(gtable)

setwd("/Users/akiranagamori/Desktop/Papers/Tendon Stiffness/R-Code")
source('Rallfun-v33')
setwd("/Users/akiranagamori/Documents/GitHub/Tendon-Stiffness-Experiment/")

dataFile = as.character('/Users/akiranagamori/Documents/GitHub/Tendon-Stiffness-Experiment/')
for (i in 1:2){
  if (i == 1){
    dataName <- paste(dataFile,'CoV_all_Fl.mat',sep = "")
    dataCoV.Temp <- readMat(dataName)
    dataCoV <- dataCoV.Temp$CoV.all
    dataCoV.Fl.vec = as.vector(dataCoV)
  }
  else{
    dataName <- paste(dataFile,'CoV_all_Ex.mat',sep = "")
    dataCoV.Temp <- readMat(dataName)
    dataCoV <- dataCoV.Temp$CoV.all
    dataCoV.Ex.vec = as.vector(dataCoV)
  }
}

dataCoV.All <- c(dataCoV.Fl.vec,dataCoV.Ex.vec)
condition = c(rep(c('4','3','2','1'),each = 12))

data.plot.Fl = data.frame(CoV = dataCoV.Fl.vec*100,Condition = condition)
data.plot.Ex = data.frame(CoV = dataCoV.Ex.vec*100,Condition = condition)

g1 <- ggplot(data.plot.Fl,aes(x = Condition, y = CoV,fill = Condition)) + scale_fill_manual(values = c('blue','purple','violetred','red')) + geom_boxplot() + theme_bw() + theme(panel.grid.major = element_blank(),panel.grid.minor = element_blank(),plot.background = element_blank(),panel.border = element_blank(),axis.ticks = element_line(size = 0.2)) +theme(axis.line = element_line(size = 0.2)) + theme(axis.title.x = element_blank()) + scale_y_continuous(limit = c(0.5,4.5), breaks = round(seq(1,4,by = 0.5),2)) + labs(y=bquote('CoV (%)')) + theme(legend.position = "none")

g2 <- ggplot(data.plot.Ex,aes(x = Condition, y = CoV,fill = Condition)) + scale_fill_manual(values = c('blue','purple','violetred','red')) + geom_boxplot() + theme_bw() + theme(panel.grid.major = element_blank(),panel.grid.minor = element_blank(),plot.background = element_blank(),panel.border = element_blank(),axis.ticks = element_line(size = 0.2)) +theme(axis.line = element_line(size = 0.2)) + theme(axis.title.x = element_blank()) + scale_y_continuous(limit = c(0.5,4.5), breaks = round(seq(1,4,by = 0.5),2)) + labs(y=bquote('CoV (%)'))  + theme(legend.position = "none")

grid.arrange(g2)
g = arrangeGrob(g2)

ggsave(filename = 'CoV_Extensors.pdf',g,width = 5, height = 5, units = "in")
