source("https://bioconductor.org/biocLite.R")
biocLite("ggtree")
library(ape)
library(ggtree)

newick <- "((J:0.9083706415,((I:0.8326311093,H:0.07603828167)80.9:0.2007562974,(G:0.8517731184,F:0.02782827057)54.8:0.3981233414)59.5:0.6319717341)94.3:0.1211002113,((E:0.1816114427,D:0.9939428424)90.4:0.6175854302,((C:0.2478344585,B:0.7329164757)97.3:0.7039844056,A:0.3370267684)55.1:0.1834741929)89.1:0.6485942581)71.2;"

tip_data <- data.frame(
	taxa = LETTERS[1:10],
	place = c(rep("CT", 5), rep("VT", 2), rep("MA", 3)),
	value = round(abs(rnorm(10, mean = 5, sd = 2)), digits=1))

print(newick)

tree <- read.tree(text = newick)

# The Base R default tree 
plot(tree)

# Now for ggtree 

str(ggtree(tree))

ggtree(tree)  # first layer 
ggtree(tree) + 
  geom_tiplab() + 
  geom_treescale(x = 0, y = 0, offset = 0.2)
  
# another method of tree scales 
ggtree(tree) + 
  geom_tiplab() + 
  theme_tree2()


# bootstrap values assuming the values are already in your newick format (or put them on branches) 

ggtree(tree) + 
  geom_tiplab() + 
  geom_treescale(x = 0, y = 0, offset = 0.2) +
  geom_text2(
    aes(
      x = branch,
      label = as.numeric(label), 
      subset = !is.na(as.numeric(label)),
      hjust = -.2,
      vjust = -.5
    )
  )


# only keep things that are less than 90

ggtree(tree) + 
  geom_tiplab() + 
  geom_treescale(x = 0, y = 0, offset = 0.2) +
  geom_text2(
    aes(
      x = branch,
      label = as.numeric(label), 
      subset = !is.na(as.numeric(label)) &
      as.numeric(label) < 90,
      hjust = -.2,
      vjust = -.5
    )
  )





# Changing support values to different colors 

ggtree(tree) + 
  geom_tiplab() + 
  geom_treescale(x = 0, y = 0, offset = 0.2) +
  geom_text2(
    aes(
      x = branch,
      label = as.numeric(label), 
      subset = !is.na(as.numeric(label)) &
        as.numeric(label) < 90,
      hjust = -.2,
      vjust = -.5
    ) ,
    color = "blue"
  )



# Color range of support values and putting in a key 

ggtree(tree) + 
  geom_tiplab() + 
  geom_treescale(x = 0, y = 0, offset = 0.2) +
  geom_text2(
    aes(
      x = branch,
      label = as.numeric(label), 
      subset = !is.na(as.numeric(label)), 
      color = as.numeric(label)
    ) 
  ) + 
  scale_color_continuous(
    name = "Node Support" ,
    low = "red" ,
    high = "green"
) +
  theme(legend.position = "right")


# Changing size of support values based on their magnitude 
ggtree(tree) + 
  geom_tiplab() + 
  geom_treescale(x = 0, y = 0, offset = 0.2) +
  geom_text2(
    aes(
      x = branch,
      label = as.numeric(label), 
      subset = !is.na(as.numeric(label)), 
      size = as.numeric(label)
    ) 
  )


#### Putting in other data on tree
#### You need a data frame where first column is taxa, second is place, third is value 

print(tip_data)

# Attaching tip data 
ggtree(tree) %<+% tip_data +
  geom_tiplab(
    aes(
      color = place
    )
  ) + 
  geom_treescale(x = 0, y = 0, offset = 0.2) +
  geom_text2(
    aes(
      x = branch,
      label = as.numeric(label), 
      subset = !is.na(as.numeric(label)) 
    ) 
  ) + 
  theme(
    legend.position = "right"
  ) 

facet_plot(
  tree_plot,
  data = tip_data,
  geom = geom_segment,
  aes(x = 0, xend = value, y = y, yend = y ),
  size = 10, 
  color = "blue"
)


tip_data2 <- data.frame(
  place = tip_data$place, 
  row.names = tip_data$taxa
)

gheatmap(
  tree_plot,
  tip_data2,
  width = 0.5,
  font.size = 3,
  hjust = 0
)






# Adjusting the x axis so the really long branch that may come out of the screen fits inside
ggtree(tree) + geom_tiplab() + xlim(0, 3)

