//
//  ImageData.cpp
//  PointCloudSample
//
//  Created by admin on 7/17/15.
//  Copyright (c) 2015 13th Lab AB. All rights reserved.
//

#include "ImageData.h"

using namespace std;

ImageData::ImageData() {
}

ImageData::ImageData(const Mat& _image, const Mat& _silhouette, const Mat& _P, const Mat& _rt) : image(_image), silhouette(_silhouette), P(_P), rt(_rt) {
}

ImageData::ImageData(const ImageData& imgData) : image(imgData.image), silhouette(imgData.silhouette), P(imgData.P), rt(imgData.rt)  {
}

ImageData::~ImageData() {
}