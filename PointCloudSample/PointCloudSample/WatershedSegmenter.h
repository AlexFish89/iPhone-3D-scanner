//
//  WatershedSegmenter.h
//  PointCloudSample
//
//  Created by admin on 9/8/12.
//  Copyright (c) 2012 13th Lab AB. All rights reserved.
//

#ifndef __PointCloudSample__WatershedSegmenter__
#define __PointCloudSample__WatershedSegmenter__

#include <opencv2/opencv.hpp>
#include <iostream>

class WatershedSegmenter{
private:
    cv::Mat markers;
public:
    WatershedSegmenter(cv::Mat& image);
    void setMarkers(cv::Mat& markerImage);
    cv::Mat& getMarkers();
    cv::Mat process(cv::Mat &image);
};

#endif /* defined(__PointCloudSample__WatershedSegmenter__) */
