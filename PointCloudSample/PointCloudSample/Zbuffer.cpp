//
//  Zbuffer.cpp
//  PointCloudSample
//
//  Created by admin on 7/15/15.
//  Copyright (c) 2015 13th Lab AB. All rights reserved.
//

#include "Zbuffer.h"

using namespace std;

Zbuffer::Zbuffer(int width, int height) : buffer(Mat(width,height,DataType<float>::type)){
    float floatMin = -numeric_limits<float>::max();
    for (int i = 0 ; i < width ; ++i) {
        for (int j = 0 ; j < height ; ++j) {
            buffer.at<float>(j,i) = floatMin;
        }
    }
}

Zbuffer::~Zbuffer() {
    
}

void Zbuffer::addVertex(int x, int y, const Vec3f& vertex, const Mat& rt) {
    if (x >= buffer.cols || x < 0 || y >= buffer.rows || y < 0) {
        return;
    }
    float currentZ =    vertex[0] * rt.at<float>(2,0) +
                        vertex[1] * rt.at<float>(2,1) +
                        vertex[2] * rt.at<float>(2,2) +
                        1         * rt.at<float>(2,3);
    Vec4f currentBuff = buffer.at<Vec4f>(y,x);
    if (currentBuff[3] < currentZ) {
        currentBuff[0] = vertex[0];
        currentBuff[1] = vertex[1];
        currentBuff[2] = vertex[2];
        currentBuff[3] = currentZ;
        buffer.at<Vec4f>(y,x) = currentBuff;
    }
}

float Zbuffer::getVertex(int x, int y) {
    return buffer.at<float>(y,x);
}