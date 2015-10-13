//
//  Sculpture.h
//  PointCloudSample
//

#ifndef __PointCloudSample__Sculpture__
#define __PointCloudSample__Sculpture__



#include <opencv2/opencv.hpp>
#include "MarchingCubes.h"
#include "Mesh.h"
#include "../Cube.h"
#include "Zbuffer.h"
#include "ImageData.h"

#ifndef F_X
#define F_X 456 //455
#endif

#ifndef F_Y
#define F_Y 456
#endif

#ifndef DEMO_MESH_SIZE
#define DEMO_MESH_SIZE  0.2463
#endif

#ifndef DEMO_X_POSITION
#define DEMO_X_POSITION -0.1307//(-0.1307 + DEMO_MESH_SIZE / 2)
#endif

#ifndef DEMO_Y_POSITION
#define DEMO_Y_POSITION -0.1307//(-0.1307 + DEMO_MESH_SIZE / 2)
#endif

#ifndef DEMO_Z_POSITION
#define DEMO_Z_POSITION -0.7483//(-0.7483 + DEMO_MESH_SIZE / 2)
#endif

#define STEP 2
#define contour 1

#define EPSILON 0.0001

#define doubleEqual(a,b) (a-b < EPSILON && b-a < EPSILON)

#define SCULPTURE_SIZE 128
//static int SCULPTURE_SIZE = 128;

using namespace cv;
using namespace std;

class Sculpture {
    byte sculpture[SCULPTURE_SIZE * SCULPTURE_SIZE * SCULPTURE_SIZE];
    byte colors[SCULPTURE_SIZE * SCULPTURE_SIZE * SCULPTURE_SIZE * CHANNELS];
    Vector<ImageData> cameras;
    Cube boundingBox;
    Mesh mesh;
    
    void getProjection(double& x, double& y, double& z, const Mat& projection);
    void initGrid(GRIDCELL& grid, double x, double y, double z);
    void interpolateColor(int x, int y, int z, double xPart, double yPart, double zPart, byte& r, byte& g, byte& b, byte& a);
    void addTrianglesToZbuffer(vector<Triangle>& triangles, Zbuffer& zBuff, ImageData& imgData);
    void addColorToTrianglesWithZbufferAndImage(vector<Triangle>& triangles, Zbuffer& zBuff, ImageData& imgData);
    void addColorToTrianglesFromOneImage(vector<Triangle>& triangles, ImageData& imgData);
    void updateColors(vector<Triangle>& triangles);
    void trianglesToMesh(vector<Triangle>& triangles);
public:
    Sculpture();
    ~Sculpture();
    void setBit(int x, int y, int z);
    void unsetBit(int x, int y, int z);
    bool getBit(int x, int y, int z) const;
    
    void setAll();
    void unsetAll();
    
    void setColor(int x, int y, int z, byte r, byte g, byte b, byte a);
    bool getColor(int x, int y, int z, byte& r, byte& g, byte& b, byte& a) const;
    
    Mesh const& getMesh() const;
    void sculpt(const ImageData& imgData, const Cube& bBox);
    
    int createMesh();
    
    string rawData() const;
    string objData() const;
    string plyData() const;

};


#endif /* defined(__PointCloudSample__Sculpture__) */
