//
//  UIImage+conversions.h
//  PointCloudSample
//
//  Created by admin on 8/24/12.
//  Copyright (c) 2012 13th Lab AB. All rights reserved.
//

#import <UIKit/UIKit.h>

#define WATERSHED_SEGMENTER         0
#define GRABCUT_SEGMENTER           1
#define RGB_SEGMENTER               2
#define HSV_SEGMENTER_WITH_H        3
#define HSV_SEGMENTER_WITH_H_AND_S  4

using namespace cv;

@interface UIImage (conversions)

- (CVPixelBufferRef) convertToCVPixelBufferRef;

- (id) initWithCVImageBufferRef: (CVImageBufferRef) sourceImageBuffer orientation: (UIImageOrientation) orien;

- (Byte *) convertToByteArray;

- (Mat) segmentToMat;

- (UIImage *) doSegmentation;


@end
