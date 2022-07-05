setwd(".")
source("rig_names.r")

#load packages
library(ggplot2)
library(gridExtra)
library(tidyverse)
library(tidyr)

args = commandArgs(trailingOnly=TRUE)

#arguments taken by the script
num_rig = as.numeric(args[1])
num_controls_per_rig = as.numeric(args[2])
num_evaporation_controls_per_rig = as.numeric(args[3])
num_treatments_per_rig = as.numeric(args[4])
num_blocked_controls_per_rig = as.numeric(args[5])
num_blocked_treatements_per_rig = as.numeric(args[6])
num_blocked_evaporation_controls_per_rig = as.numeric(args[7])


# num_rig = 6
# num_controls_per_rig = 2
# num_evaporation_controls_per_rig = 1
# num_treatments_per_rig = 7
# num_blocked_controls_per_rig = 1
# num_blocked_treatements_per_rig = 0
# num_blocked_evaporation_controls_per_rig = 1


#build matrix 
a <- matrix(nrow = num_rig, ncol = 10)

#set up the blocks 
if(num_blocked_controls_per_rig > 0){ 
  for(i in 1:dim(a)[1]){
    for(j in 1:num_blocked_controls_per_rig){
    block_control <- sample(which(is.na(a[i,])), 1, replace = FALSE)
    a[i, block_control] <- paste("BLOCK\nCONTROL", j, sep = "") 
  }}}
  
if(num_blocked_treatements_per_rig > 0){ 
  for(i in 1:dim(a)[1]){
    for(j in 1:num_blocked_treatements_per_rig){
      block_treatment <- sample(which(is.na(a[i,])), 1, replace = FALSE)
      a[i, block_treatment] <- paste("BLOCK_T", j, sep = "") 
  }}}

if(num_blocked_evaporation_controls_per_rig > 0){ 
  for(i in 1:dim(a)[1]){
    for(j in 1:num_blocked_evaporation_controls_per_rig){
      block_evap <- sample(which(is.na(a[i,])), 1, replace = FALSE)
      a[i, block_evap] <- paste("BLOCK\nEVAP", j, sep = "") 
  }}}


#set up non-block randomization
if( abs(num_controls_per_rig - num_blocked_controls_per_rig) > 0){ 
  num_nonblock_control_per_rig <- abs(num_controls_per_rig - num_blocked_controls_per_rig)*num_rig
  a[sample(which(is.na(a)), num_nonblock_control_per_rig, replace = FALSE)] <- "NONBLOCK\nCONTROL"
  }

if( abs(num_evaporation_controls_per_rig - num_blocked_evaporation_controls_per_rig) > 0){
  for(i in 1:abs(num_evaporation_controls_per_rig - num_blocked_evaporation_controls_per_rig)){
    a[sample(which(is.na(a)), num_rig, replace = FALSE)] <- paste("NONBLOCK\nEVAP", i, sep = "")
  }}

if( abs(num_treatments_per_rig - num_blocked_treatements_per_rig) > 0){
  for(i in 1:abs(num_treatments_per_rig - num_blocked_treatements_per_rig)){
    a[sample(which(is.na(a)), num_rig, replace = FALSE)] <- paste("T", i, sep = "")
  }}


#print final matrix 
final_matrix = a

#convert final_matrix to data frame
df <- as.data.frame(final_matrix)
colnames(df) <- seq(1, dim(df)[2] )
df$rig <- as.numeric(1:dim(df)[1])
df2 <- gather(df, key = "key", value = "value", 1:(dim(df)[2]-1))
df2[,1] <- as.numeric(df2[,1])
df2[,2] <- as.numeric(df2[,2])
colnames(df2) <- c("rig", "key", "value")

g1 <- ggplot(data = df2, aes(x = key, y = rig, label=value, col = value)) + 
  geom_point(col = "white", size = 10) + 
  geom_text(size = 2) +
  scale_color_brewer(palette = "Paired") + 
  scale_y_continuous(labels = as.character(df2$rig), breaks = df2$rig) + 
  scale_x_continuous(labels = as.character(df2$key), breaks = df2$key) + 
  theme_bw() + 
  theme(
    panel.grid.major = element_line(color = rgb(235, 235, 235, 100, maxColorValue = 255)),
    panel.grid.minor = element_blank(),
    axis.title = element_blank(),
    axis.ticks = element_blank(),
    legend.position = "none")

ggsave(filename = "multiCAFE_design.pdf", g1, scale = as.numeric(args[8]), height = as.numeric(args[9]), width = as.numeric(args[10]), units = "in")
