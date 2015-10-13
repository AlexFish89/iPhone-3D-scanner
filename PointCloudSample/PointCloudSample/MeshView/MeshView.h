//
//  MeshView.h
//  PointCloudSample
//
//  Created by admin on 8/21/12.
//  Copyright (c) 2012 13th Lab AB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLView.h"
#import <OpenGLES/EAGLDrawable.h>
#import <GLKit/GLKit.h>
#include "../Sculptor/Sculpture.h"
#import "../Sidebar/HSImageSidebarView.h"
#import "../Sidebar/HSImageSidebarViewDelegate.h"
#include "../Cube.h"

@interface MeshView : UIViewController <GLViewDelegate,UIAlertViewDelegate> {
    CADisplayLink *displayLink;
    UIAlertView *alertWithYesNoButtons;
    
    struct {
        GLfloat rotationX;
        GLfloat rotationY;
        GLfloat rotationZ;
        GLfloat rotationAngle;
        
        GLfloat defoultRotationX;
        GLfloat defoultRotationY;
        GLfloat defoultRotationZ;
        GLfloat defoultRotationAngle;
        
        GLfloat translateX;
        GLfloat translateY;
        GLfloat translateZ;
        
        GLfloat defoultTranslateX;
        GLfloat defoultTranslateY;
        GLfloat defoultTranslateZ;
        
        GLfloat scalefactor;
        GLfloat defoultScalefactor;
        
    } GLDisplayData;
    
    struct {
        GLfloat rotationX;
        GLfloat rotationY;
        GLfloat rotationZ;
        GLfloat rotationAngle;
    } RotationPosition;
   
//#define OLD_FRUSTUM
#ifdef OLD_FRUSTUM
    struct {
        GLfloat zNear = 0.00001;
        GLfloat zFar = 300;
        GLfloat fovY = 45;
        GLfloat fovX = 60;
        GLfloat aspect = tan( fovX / 360 * M_PI ) / tan( fovY / 360 * M_PI );
        GLfloat ratio = zFar/zNear;
        GLfloat top = tan( fovY / 360 * M_PI ) * zNear;
        GLfloat bottom = -top;
        GLfloat right = top * aspect;
        GLfloat left = -right;
    } FrustumData;
#endif
#ifndef OLD_FRUSTUM
    struct {
        GLfloat fov = 45.0f;
        GLfloat zNear = (SCULPTURE_SIZE / 2) / tanf(fov * M_PI / 180.0f);
        GLfloat zFar = (SCULPTURE_SIZE + zNear) * 20;
        GLfloat top = right;
        GLfloat bottom = -top;
        GLfloat right = zNear * tanf((fov / 180.0f) * M_PI);
        GLfloat left = -right;
    } FrustumData;
#endif
    struct
    {
        CGPoint startTouchPositionOneFinger;
        CGPoint startTouchPositionTwoFingers;
        NSDate* startTouchTime;
        double startRotaionAngle;
    } GestureData;
}

@property (retain, nonatomic) IBOutlet UIImageView *ImageDisplay;
@property (retain, nonatomic) IBOutlet HSImageSidebarView *ImagesBar;
@property (retain, nonatomic) IBOutlet UINavigationItem *navMesh;
@property (retain, nonatomic) IBOutlet UIButton *MeshButton;
@property (retain, nonatomic) IBOutlet UIButton *SegmentationButton;
@property (retain, nonatomic) IBOutlet UIButton *SculptButton;
@property (retain, nonatomic) IBOutlet UIButton *SculptAllButton;
@property (retain, nonatomic) IBOutlet UIProgressView *progressBar;
@property (nonatomic) bool demo;
@property (nonatomic) bool silhouettes;
@property (nonatomic) Cube bBox;

-(void)makeDemo;
-(bool)isDemo;

//OpenGL setup and reset functions
-(void)setupControllerInstances;
-(void)resetControllerInstances;


//GLView protocol functions
- (void)drawView:(UIView *)theView;
- (void)setupView:(UIView *)theView;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;


@end
