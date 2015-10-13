//
//  Zbuffer.h
//  PointCloudSample
//
//  Created by admin on 7/15/15.
//  Copyright (c) 2015 13th Lab AB. All rights reserved.
//

#ifndef __PointCloudSample__Zbuffer__
#define __PointCloudSample__Zbuffer__

#include <opencv2/opencv.hpp>
#include <limits.h>

using namespace std;
using namespace cv;

class Zbuffer {
private:
    Mat buffer;
public:
    Zbuffer(int width, int height);
    ~Zbuffer();
    
    void addVertex(int x, int y, const Vec3f& vertex, const Mat& rt);
    float getVertex(int x, int y);
};

#endif /* defined(__PointCloudSample__Zbuffer__) */
