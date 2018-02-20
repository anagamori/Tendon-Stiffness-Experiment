

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
  else {
    dataName <- paste(dataFile,'CoV_all_Ex.mat',sep = "")
    dataCoV.Temp <- readMat(dataName)
    dataCoV <- dataCoV.Temp$CoV.all
    dataCoV.Ex.vec = as.vector(dataCoV)
  }
}
dataCoV.All <- c(dataCoV.Fl.vec,dataCoV.Ex.vec)
condition = rep(1:4,each = 12)
muscle = rep(1:2,each = 48)
dataCoV.All.mat <- cbind(dataCoV.Fl.vec,dataCoV.Ex.vec,condition)
z = bw2list(dataCoV.All.mat,3,c(1,2))
rmanova(dataCoV,tr = 0)
rmmcp(dataCoV,tr=0)
