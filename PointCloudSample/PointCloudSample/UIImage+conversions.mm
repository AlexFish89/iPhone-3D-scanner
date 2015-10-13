//
//  UIImage+conversions.m
//  PointCloudSample
//
//  Created by admin on 8/24/12.
//  Copyright (c) 2012 13th Lab AB. All rights reserved.
//

#include <opencv2/opencv.hpp>
#import "UIImage+conversions.h"
#include <math.h>
#import "UIImageCVMatConverter.h"
#import "WatershedSegmenter.h"

#define RGBcolorRange 256
#define BINS 256
#define BIN_SIZE RGBcolorRange / BINS
#define BG_TRESH 10


@implementation UIImage (conversions)

- (CVPixelBufferRef) convertToCVPixelBufferRef {
    
    CGImageRef image = [self CGImage];
    CGSize frameSize = CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image));
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:NO], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:NO], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, frameSize.width,
                                          frameSize.height,  kCVPixelFormatType_32ARGB, (CFDictionaryRef) options, &pxbuffer);
//    TO DO: why do I have BGRA and not ARGB?
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, frameSize.width,
                                                 frameSize.height, 8, 4*frameSize.width, rgbColorSpace,
                                                 kCGImageAlphaNoneSkipLast);
    
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image),
                                           CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

- (id) initWithCVImageBufferRef: (CVImageBufferRef) imgBuff orientation: (UIImageOrientation) orien {
    [self init];
    
    /*Lock the image buffer*/
    CVPixelBufferLockBaseAddress(imgBuff,0);
    
    /*Get information about the image*/
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imgBuff);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imgBuff);
    int w = CVPixelBufferGetWidth(imgBuff);
    int h = CVPixelBufferGetHeight(imgBuff);
    
    /*We unlock the  image buffer*/
    CVPixelBufferUnlockBaseAddress(imgBuff,0);
    
    
    /*Create a CGImageRef from the CVImageBufferRef*/
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef newContext = CGBitmapContextCreate(baseAddress, w, h, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef newImage = CGBitmapContextCreateImage(newContext);
    
    /*We release some components*/
    CGContextRelease(newContext);
    CGColorSpaceRelease(colorSpace);
    
    /*We display the result on the custom layer*/
    /*self.customLayer.contents = (id) newImage;*/
    
    /*We display the result on the image view (We need to change the orientation of the image so that the video is displayed correctly)*/
    self = [UIImage imageWithCGImage:newImage scale:1.0 orientation:orien];
    
    /*We relase the CGImageRef*/
    CGImageRelease(newImage);
    
    return self;
}

- (Byte *) convertToByteArray {
    CVPixelBufferRef imgBuff = [self convertToCVPixelBufferRef];

    CVPixelBufferLockBaseAddress(imgBuff, 0);
    Byte* pixel = (Byte *)CVPixelBufferGetBaseAddress(imgBuff);
    CVPixelBufferUnlockBaseAddress (imgBuff, 0);
     
    return pixel;
}

- (Vec4i) getBackgroudColorRGB {
    Mat src = [UIImageCVMatConverter cvMatFromUIImage:self];
    int histSize[] = { BINS, BINS, BINS, BINS };
    float rRanges[] = { 0, 256 };
    float gRanges[] = { 0, 256 };
    float bRanges[] = { 0, 256 };
    float aRanges[] = { 0, 256 };
    const float* ranges[] = { bRanges, gRanges, rRanges, aRanges };     //8UC4 is bgra
    MatND hist;
    bool uniform = true; bool accamulate = false;
    int channels[] = {0, 1, 2, 3};
    calcHist( &src, 1, channels, Mat(), // do not use mask
             hist, 4, histSize, ranges, uniform, accamulate );
    int maxIndex[4];
    minMaxIdx(hist, 0, 0, 0, maxIndex);
    return Vec4i(maxIndex[0] * BIN_SIZE + (BIN_SIZE / 2), maxIndex[1] * BIN_SIZE + (BIN_SIZE / 2), maxIndex[2] * BIN_SIZE + (BIN_SIZE / 2), maxIndex[3] * BIN_SIZE + (BIN_SIZE / 2));
}

- (void) getBackgroudColorHSVwithH:(int&)maxH {
    Mat src = [UIImageCVMatConverter cvMatFromUIImage:self];
    Mat bgr,hsv;
    cvtColor(src, bgr, COLOR_BGRA2BGR);
    cvtColor(bgr, hsv, COLOR_BGR2HSV);
    int hist[BINS] = {0};
    for (int i = 0 ; i < hsv.rows; i++) {
        for (int j = 0 ; j < hsv.cols ; j++) {
            int current = (int)hsv.at<Vec3b>(i,j)(0);
            ++hist[current / int(BIN_SIZE)];
        }
    }
    maxH = 0;
    for (int i = 1 ; i < BINS ; ++i) {
        if (hist[i] > hist[maxH]) {
            maxH = i;
        }
    }
    maxH = maxH * BIN_SIZE + (BIN_SIZE / 2);
//    return maxIndex * BIN_SIZE + (BIN_SIZE / 2);
}

- (void) getBackgroudColorHSVwithH:(int&)maxH andS:(int&)maxS {
    Mat src = [UIImageCVMatConverter cvMatFromUIImage:self];
    Mat bgr,hsv;
    cvtColor(src, bgr, COLOR_BGRA2BGR);
    cvtColor(bgr, hsv, COLOR_BGR2HSV);
    int hist[BINS][BINS] = {0};
    for (int i = 0 ; i < hsv.rows; i++) {
        for (int j = 0 ; j < hsv.cols ; j++) {
            int h = (int)hsv.at<Vec3b>(i,j)(0);
            int s = (int)hsv.at<Vec3b>(i,j)(1);
            ++hist[h / int(BIN_SIZE)][s / int(BIN_SIZE)];
        }
    }
    maxH = maxS = 0;
    for (int i = 1 ; i < BINS ; ++i) {
        for (int j = 1 ; j < BINS ; ++j) {
            if (hist[i][j] > hist[maxH][maxS]) {
                maxH = i;
                maxS = j;
            }
        }
    }
    maxH = maxH * BIN_SIZE + (BIN_SIZE / 2);
    maxS = maxS * BIN_SIZE + (BIN_SIZE / 2);
}

/**
 * @function CannyThreshold
 * @brief Trackbar callback - Canny thresholds input with a ratio 1:3
 */
Mat CannyThreshold(Mat src) {
    int edgeThresh = 1;
    int lowThreshold;
    int const max_lowThreshold = 100;
    int ratio = 3;
    int kernel_size = 3;
    Mat src_gray;
    Mat dst, detected_edges;
    //cvtColor(src, src_gray, CV_BGR2GRAY);
    /// Reduce noise with a kernel 3x3
    blur( src_gray, detected_edges, cv::Size(3,3) );
    
    /// Canny detector
    Canny( detected_edges, detected_edges, max_lowThreshold, max_lowThreshold*ratio, kernel_size );
    
    /// Using Canny's output as a mask, we display our result
    dst = Scalar::all(0);
    
    src.copyTo( dst, detected_edges);
    return dst;
}

- (Mat) rgbSegmentation {
    Mat src = [UIImageCVMatConverter cvMatFromUIImage:self];
    Mat bgr,hsv;
    cvtColor(src, bgr, COLOR_BGRA2BGR);
    cvtColor(bgr, hsv, COLOR_BGR2HSV);
    Vec4i backgroundColor = [self getBackgroudColorRGB];
    Vec4b newBg(0, 0, 0, 254);
    Vec4b newFG(255, 255, 255, 255);
    for (int i = 0 ; i < src.rows; i++) {
        for (int j = 0 ; j < src.cols ; j++) {
            Vec4i current((int)src.at<Vec4b>(i,j)(0), (int)src.at<Vec4b>(i,j)(1), (int)src.at<Vec4b>(i,j)(2), (int)src.at<Vec4b>(i,j)(3));
            src.at<Vec4b>(i,j) = (norm(backgroundColor - current) < BG_TRESH) ? newBg : newFG;
        }
    }
    return src;
}

- (Mat) hsvSegmentationWithH {
    Mat src = [UIImageCVMatConverter cvMatFromUIImage:self];
    Mat bgr,hsv;
    cvtColor(src, bgr, COLOR_BGRA2BGR);
    cvtColor(bgr, hsv, COLOR_BGR2HSV);
    int backgroundColor;
    [self getBackgroudColorHSVwithH:backgroundColor];
    Vec4b newBG(0, 0, 0, 0);
    Vec4b newFG(255, 255, 255, 255);
    for (int i = 0 ; i < src.rows; i++) {
        for (int j = 0 ; j < src.cols ; j++) {
            int current = (int)hsv.at<Vec3b>(i,j)(0);
            src.at<Vec4b>(i,j) = (abs(backgroundColor - current) < BG_TRESH) ? newBG : newFG;
        }
    }
    return src;
}

- (Mat) hsvSegmentationWithHAndS {
    Mat src = [UIImageCVMatConverter cvMatFromUIImage:self];
    Mat bgr,hsv;
    cvtColor(src, bgr, COLOR_BGRA2BGR);
    cvtColor(bgr, hsv, COLOR_BGR2HSV);
    int backgroundH, backgroundS;
    [self getBackgroudColorHSVwithH:backgroundH andS:backgroundS];
    Vec4b newBG(0, 0, 0, 0);
    Vec4b newFG(255, 255, 255, 255);
    for (int i = 0 ; i < src.rows; i++) {
        for (int j = 0 ; j < src.cols ; j++) {
            int currentH = (int)hsv.at<Vec3b>(i,j)(0);
            int currentS = (int)hsv.at<Vec3b>(i,j)(1);
            float hsDist = sqrt((backgroundH - currentH) * (backgroundH - currentH) + (backgroundS - currentS) * (backgroundS - currentS));
            src.at<Vec4b>(i,j) = (hsDist < BG_TRESH) ? newBG : newFG;
        }
    }
    return src;
}

- (Mat) watershedSegmentation {
    Mat src = [UIImageCVMatConverter cvMatFromUIImage:self];
    cvtColor(src, src, CV_RGBA2RGB);
    WatershedSegmenter waterSeg(src);
    return waterSeg.getMarkers();
}

- (Mat) grabcutSegmentation {
    Mat src = [UIImageCVMatConverter cvMatFromUIImage:self];
    Mat mask(src);
    Mat bgdModel(src);
    Mat fgdModel(src);
    Rect_<int> rect(10, 10, src.cols / 2, src.rows / 2);
    grabCut(src, mask, rect, bgdModel, fgdModel, 1, GC_INIT_WITH_RECT);
    return src;
}

int segmenter = HSV_SEGMENTER_WITH_H;

- (Mat) segmentToMat {
    switch (segmenter) {
        case WATERSHED_SEGMENTER:
            return [self watershedSegmentation];
            break;
        case GRABCUT_SEGMENTER:
            return [self grabcutSegmentation];
            break;
        case RGB_SEGMENTER:
            return [self rgbSegmentation];
            break;
        case HSV_SEGMENTER_WITH_H:
            return [self hsvSegmentationWithH];
            break;
        case HSV_SEGMENTER_WITH_H_AND_S:
            return [self hsvSegmentationWithHAndS];
            break;
        default:
            return [self hsvSegmentationWithH];
            break;
    }
}

- (UIImage *) doSegmentation {
    return [UIImageCVMatConverter UIImageFromCVMat:[self segmentToMat]];
}


@end
