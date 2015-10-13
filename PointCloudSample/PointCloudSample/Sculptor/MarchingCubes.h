#ifndef MARCHINGCUBES_H
#define MARCHINGCUBES_H

#include "Triangle.h"

/**GRIDCELL represents 2*2*2 in grid*/
struct grid_s{
	Vector3DEx p[8];
	double val[8];
};

typedef struct grid_s GRIDCELL;

/**
*   Given a grid cell and an isolevel, calculate the triangular
*   facets required to represent the isosurface through the cell.
*   Return the number of triangular facets, the array "triangles"
*   will be loaded up with the vertices at most 5 triangular facets.
*	0 will be returned if the grid cell is either totally above
*   or totally below the isolevel.
*/
void Polygonise(GRIDCELL& grid,double isolevel,vector<Triangle>& triangles);


#endif