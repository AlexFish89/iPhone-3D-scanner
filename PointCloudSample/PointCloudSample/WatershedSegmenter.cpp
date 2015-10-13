//
//  WatershedSegmenter.cpp
//  PointCloudSample
//
//  Created by admin on 9/8/12.
//  Copyright (c) 2012 13th Lab AB. All rights reserved.
//

#include "WatershedSegmenter.h"

WatershedSegmenter::WatershedSegmenter(cv::Mat& image) {
    cv::Mat binary;
    cv::cvtColor(image, binary, CV_BGR2GRAY);
    cv::threshold(binary, binary, 103, 255, cv::THRESH_BINARY);
    
    // Eliminate noise and smaller objects
    cv::Mat fg;
    cv::erode(binary,fg,cv::Mat(),cv::Point(-1,-1),6);
    
    // Identify image pixels without objects
    cv::Mat bg;
    cv::dilate(binary,bg,cv::Mat(),cv::Point(-1,-1),6);
    cv::threshold(bg,bg,1, 128,cv::THRESH_BINARY_INV);
    
    // Create markers image
    cv::Mat marker(binary.size(),CV_8U,cv::Scalar(0));
    marker = fg+bg;
    
    this->setMarkers(marker);
    this->process(image);
}

void WatershedSegmenter::setMarkers(cv::Mat& markerImage) {
    markerImage.convertTo(markers, CV_32S);
}

cv::Mat& WatershedSegmenter::getMarkers() {
    return markers;
}

cv::Mat WatershedSegmenter::process(cv::Mat &image) {
    cv::watershed(image, markers);
    markers.convertTo(markers,CV_8U);
    return markers;
}