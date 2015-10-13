//
//  UIImageCVMatConverter.h
//  PointCloudSample
//
//  Created by admin on 9/8/12.
//  Copyright (c) 2012 13th Lab AB. All rights reserved.
//

#include <opencv2/opencv.hpp>
#import <Foundation/Foundation.h>

@interface UIImageCVMatConverter : NSObject

+ (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat;
+ (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat withUIImage:(UIImage*)image;
+ (cv::Mat)cvMatFromUIImage:(UIImage *)image;
+ (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image;
+ (UIImage *)scaleAndRotateImageFrontCamera:(UIImage *)image;
+ (UIImage *)scaleAndRotateImageBackCamera:(UIImage *)image;

@end
