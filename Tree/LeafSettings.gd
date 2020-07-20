class_name LeafSettings
extends AACustomResource


export(float, 0.001, 1) var frequency = .5
export(float) var width = 1
export(float) var height = 1
# how far up the tree the branch needs to be to have leaves
export(int, 1, 20) var min_depth = 3
export(Color) var colour = Color(0, 1, 0, 1)
