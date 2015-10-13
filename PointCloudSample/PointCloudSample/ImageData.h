//
//  ImageData.h
//  PointCloudSample
//
//  Created by admin on 7/17/15.
//  Copyright (c) 2015 13th Lab AB. All rights reserved.
//

#ifndef __PointCloudSample__ImageData__
#define __PointCloudSample__ImageData__

#include <opencv2/opencv.hpp>

using namespace cv;

class ImageData {
public:
    Mat image;
    Mat silhouette;
    Mat P;
    Mat rt;
    ImageData();
    ImageData(const Mat& _image, const Mat& _silhouette, const Mat& _P, const Mat& _rt);
    ImageData(const ImageData& imgData);
    ~ImageData();
};

#endif /* defined(__PointCloudSample__ImageData__) */
