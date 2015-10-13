//
//  Cube.cpp
//  PointCloudSample
//
//  Created by admin on 6/24/15.
//  Copyright (c) 2015 13th Lab AB. All rights reserved.
//

#include "Cube.h"

Cube::Cube() {
    size = 0.3f;
    corner[0] = corner[2] = -size / 2;
    corner[1] = 0.0f;
    dirty = true;
}

Cube::Cube(Cube const& cube) {
    size = cube.size;
    corner[0] = cube.corner[0];
    corner[1] = cube.corner[1];
    corner[2] = cube.corner[2];
    dirty = true;
}

Cube::~Cube() {}

float Cube::getSize() const{
    return size;
}

void Cube::setSize(float newSize) {
    size = newSize;
    dirty = true;
}

void Cube::resize(float factor) {
    size *= factor;
    dirty = true;
}

void Cube::getCorner(float& x, float& y, float& z) const {
    x = corner[0];
    y = corner[1];
    z = corner[2];
}

void Cube::setCorner(float x, float y, float z) {
    corner[0] = x;
    corner[1] = y;
    corner[2] = z;
    dirty = true;
}

void Cube::moveCorner(float x, float y, float z) {
    corner[0] += x;
    corner[1] += y;
    corner[2] += z;
    dirty = true;
}

float *Cube::getLines() {
    if (dirty) {
        //bot face
        //line 1
        lines[0] = corner[0];
        lines[1] = corner[1];
        lines[2] = corner[2];
        lines[3] = corner[0] + size;
        lines[4] = corner[1];
        lines[5] = corner[2];
        //line 2
        lines[6] = corner[0] + size;
        lines[7] = corner[1];
        lines[8] = corner[2];
        lines[9] = corner[0] + size;
        lines[10] = corner[1] + size;
        lines[11] = corner[2];
        //line 3
        lines[12] = corner[0] + size;
        lines[13] = corner[1] + size;
        lines[14] = corner[2];
        lines[15] = corner[0];
        lines[16] = corner[1] + size;
        lines[17] = corner[2];
        //line 4
        lines[18] = corner[0];
        lines[19] = corner[1] + size;
        lines[20] = corner[2];
        lines[21] = corner[0];
        lines[22] = corner[1];
        lines[23] = corner[2];
       
        //top face
        //line 5
        lines[24] = corner[0];
        lines[25] = corner[1];
        lines[26] = corner[2] + size;
        lines[27] = corner[0] + size;
        lines[28] = corner[1];
        lines[29] = corner[2] + size;
        //line 6
        lines[30] = corner[0] + size;
        lines[31] = corner[1];
        lines[32] = corner[2] + size;
        lines[33] = corner[0] + size;
        lines[34] = corner[1] + size;
        lines[35] = corner[2] + size;
        //line 7
        lines[36] = corner[0] + size;
        lines[37] = corner[1] + size;
        lines[38] = corner[2] + size;
        lines[39] = corner[0];
        lines[40] = corner[1] + size;
        lines[41] = corner[2] + size;
        //line 8
        lines[42] = corner[0];
        lines[43] = corner[1] + size;
        lines[44] = corner[2] + size;
        lines[45] = corner[0];
        lines[46] = corner[1];
        lines[47] = corner[2] + size;
        
        //side lnes
        //line 9
        lines[48] = corner[0];
        lines[49] = corner[1];
        lines[50] = corner[2];
        lines[51] = corner[0];
        lines[52] = corner[1];
        lines[53] = corner[2] + size;
        //line 10
        lines[54] = corner[0] + size;
        lines[55] = corner[1];
        lines[56] = corner[2];
        lines[57] = corner[0] + size;
        lines[58] = corner[1];
        lines[59] = corner[2] + size;
        //line 11
        lines[60] = corner[0] + size;
        lines[61] = corner[1] + size;
        lines[62] = corner[2];
        lines[63] = corner[0] + size;
        lines[64] = corner[1] + size;
        lines[65] = corner[2] + size;
        //line 12
        lines[66] = corner[0];
        lines[67] = corner[1] + size;
        lines[68] = corner[2];
        lines[69] = corner[0];
        lines[70] = corner[1] + size;
        lines[71] = corner[2] + size;
        
        dirty = false;
    }
    return lines;
}