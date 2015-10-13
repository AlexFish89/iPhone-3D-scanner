//
//  Cube.h
//  PointCloudSample
//
//  Created by admin on 6/24/15.
//  Copyright (c) 2015 13th Lab AB. All rights reserved.
//

#ifndef __PointCloudSample__Cube__
#define __PointCloudSample__Cube__

#include <OpenGLES/ES1/gl.h>
#include <OpenGLES/ES1/glext.h>

#define numOfLines 12
#define numOfCoords 3
#define lineArraySize numOfLines * 2 * numOfCoords

class Cube {
public:
    Cube();
    Cube(Cube const& cube);
    ~Cube();
    float getSize() const;
    void setSize(float newSize);
    void resize(float factor);
    void getCorner(float& x, float& y, float& z) const;
    void setCorner(float x, float y, float z);
    void moveCorner(float x, float y, float z);
    float *getLines();
private:
    bool dirty;
    float size;
    float corner[3];
    float lines[lineArraySize];
};

#endif /* defined(__PointCloudSample__Cube__) */