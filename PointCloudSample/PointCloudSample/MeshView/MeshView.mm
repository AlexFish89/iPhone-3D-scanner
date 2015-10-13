
//
//  MeshView.m
//  PointCloudSample
//
//  Created by admin on 8/21/12.
//  Copyright (c) 2012 13th Lab AB. All rights reserved.
//

#include <opencv2/opencv.hpp>
#import "MeshView.h"
#import "GLView.h"
#import "UIImage+conversions.h"
#import "../../../PointCloud.h"
#import "../UIImageCVMatConverter.h"
#import <QuartzCore/CADisplayLink.h>
#include "Mesh.h"
#import "UIView+buttons.h"
#include "../../dinosaur/matrices/matricesData.h"
//#import "../WatershedSegmenter.h"

using namespace std;

@interface MeshView ()  <HSImageSidebarViewDelegate> {
}

@property (nonatomic, strong)NSMutableArray *images;
@property (nonatomic, strong)NSMutableArray *imagesPaths;
@property (nonatomic)Sculpture *sculpture;
@property (nonatomic, strong)NSTimer *progressTimer;

-(void)sideBarInsertRow:(UIImage*)image atIndex:(NSInteger)index;
-(void)sideBarRemoveRowAtIndex:(NSUInteger)anIndex;
-(void)sideBarRemoveAllRows;
-(NSUInteger)countOfImagesInSidebar:(HSImageSidebarView *)sidebar;
-(UIImage *)sidebar:(HSImageSidebarView *)sidebar imageForIndex:(NSUInteger)anIndex;
//-(void) updateProgressBar:(NSNumber*)progressValue;




@end

@implementation MeshView
@synthesize ImageDisplay = _ImageDisplay;
@synthesize ImagesBar = _ImagesBar;
@synthesize navMesh = _navMesh;
@synthesize MeshButton = _MeshButton;
@synthesize SegmentationButton = _SegmentationButton;
@synthesize SculptButton = _SculptButton;
@synthesize SculptAllButton = _SculptAllButton;
@synthesize images = _images;
@synthesize imagesPaths = _imagesPaths;
@synthesize sculpture = _sculpture;
@synthesize progressBar;
@synthesize progressTimer = _progressTimer;
@synthesize bBox;

bool redraw = YES;
bool silhouetteAlertAnswered = NO;

-(void)makeDemo {
    _demo = true;
}

-(bool)isDemo {
    return _demo;
}

-(void) updateProgressBar:(NSNumber*)progressValue {
    if ([progressValue floatValue] <= 1.0) {
        [progressBar setProgress:[progressValue floatValue] animated:YES];
    }
}

-(void)showProgressBar {
    progressBar.hidden = false;
}

-(void)hideProgressBar {
    progressBar.hidden = true;
}

- (void)initProgressBar {
    [self updateProgressBar:[NSNumber numberWithFloat:0.0f]];
    [self hideProgressBar];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)addBackButton {
    // create button
    UIButton* backButton = [UIButton buttonWithType:(UIButtonType)101]; // left-pointing shape!
    [backButton addTarget:self action:@selector(backButtonPushed) forControlEvents:UIControlEventTouchUpInside];
    [backButton setTitle:@"Shoot" forState:UIControlStateNormal];
    
    // create button item -- possible because UIButton subclasses UIView!
    UIBarButtonItem* backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    // add to toolbar, or to a navbar (you should only have one of these!)
    _navMesh.leftBarButtonItem = backItem;
}

- (IBAction)backButtonPushed {
    [[super presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addBackButton];
    _ImagesBar.delegate = self;
    _sculpture = new Sculpture();
    _images = [[NSMutableArray alloc] init];
    [self initProgressBar];
    [self setupControllerInstances];
}

-(void)viewWillAppear:(BOOL)animated {
    [[UIApplication sharedApplication]
     setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:animated];
    if (_demo) {
        [self sideBarRemoveAllRows];
        _sculpture->setAll();
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [[UIApplication sharedApplication]
     setStatusBarOrientation:UIInterfaceOrientationPortrait animated:animated];
}

-(void)viewDidAppear:(BOOL)animated {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *picturesDirectory = [documentsDirectory stringByAppendingPathComponent:@"Snapshots"];
    NSError **picturesError = nil;
    if (_demo) {
        if (_silhouettes) {                                             //change condition
            picturesDirectory = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"silhouettes"];
        } else {
            picturesDirectory = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"pictures"];
        }
        
    }
    _imagesPaths = (NSMutableArray *)[[NSFileManager defaultManager] contentsOfDirectoryAtPath:picturesDirectory error:picturesError];
    [_imagesPaths sortUsingComparator:^NSComparisonResult(NSString *str1, NSString *str2) {
        return [str1 compare:str2 options:(NSNumericSearch)];
    }];
    for (NSUInteger i = 0; i < _imagesPaths.count; ++i) {
        [_imagesPaths replaceObjectAtIndex:i withObject:[picturesDirectory stringByAppendingPathComponent:[_imagesPaths objectAtIndex:i]]];
    } 
    NSLog(@"%u",_imagesPaths.count);   
    for (NSUInteger insertionIndex = _images.count ; insertionIndex < _imagesPaths.count ; insertionIndex++) {
        [self sideBarInsertRow:[[UIImage alloc] initWithContentsOfFile:[_imagesPaths objectAtIndex:insertionIndex]] atIndex:insertionIndex];
    }

    if (_imagesPaths.count == 0) {
        _SegmentationButton.enabled = NO;
        _SculptButton.enabled = NO;
        _SculptAllButton.enabled = NO;
    }
    else {
        _SegmentationButton.enabled = YES;
        _SculptButton.enabled = YES;
        _SculptAllButton.enabled = YES;
    }
}


- (void)viewDidUnload
{
    [self setImageDisplay:nil];
    [self setImagesBar:nil];
    [self setNavMesh:nil];
    [self setMeshButton:nil];
    [self setSegmentationButton:nil];
    [self setSculptButton:nil];
    [self setSculptAllButton:nil];
    [_images release];
    [super viewDidUnload];
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (void)dealloc {
    [_ImageDisplay release];
    [_ImagesBar release];
    [_navMesh release];
    [_MeshButton release];
    [_SegmentationButton release];
    [_SculptButton release];
    [_SculptAllButton release];
    [progressBar release];
    [super dealloc];
}

-(void)setupControllerInstances
{  
    GLDisplayData.rotationX = 1.0f;
    GLDisplayData.rotationY = 1.0;
    GLDisplayData.rotationZ = 0.0f;
    GLDisplayData.rotationAngle = 0.0f;
    
    GLDisplayData.defoultRotationX = 1.0f;
    GLDisplayData.defoultRotationY = 1.0;
    GLDisplayData.defoultRotationZ = 0.0f;
    GLDisplayData.defoultRotationAngle = 0.0f;
    
    
    GLDisplayData.translateX = 0.0f;
    GLDisplayData.translateY = 0.0f;
    GLDisplayData.translateZ = 0.0f;
    
    GLDisplayData.defoultTranslateX = 0.0f;
    GLDisplayData.defoultTranslateY = 0.0f;
    GLDisplayData.defoultTranslateZ = 0.0f;
    
    
    GLDisplayData.scalefactor = 1.0f;
    GLDisplayData.defoultScalefactor = 1.0f;
    
//  Init rotation position
    
    RotationPosition.rotationX = 1.0f;
    RotationPosition.rotationY = 1.0f;
    RotationPosition.rotationZ = 0.0f;
    RotationPosition.rotationAngle = 0.0f;
    
}

-(void)resetControllerInstances
{
//  Update position
    RotationPosition.rotationX += GLDisplayData.rotationX;
    RotationPosition.rotationY += GLDisplayData.rotationY;
    RotationPosition.rotationZ += GLDisplayData.rotationZ;
    RotationPosition.rotationAngle += GLDisplayData.rotationAngle;
    
//  Reset GLD data
    GLDisplayData.rotationX = GLDisplayData.defoultRotationX;
    GLDisplayData.rotationY = GLDisplayData.defoultRotationY;
    GLDisplayData.rotationZ = GLDisplayData.defoultRotationZ;
    GLDisplayData.rotationAngle = GLDisplayData.defoultRotationAngle;
    
    GLDisplayData.translateX = GLDisplayData.defoultTranslateX;
    GLDisplayData.translateY = GLDisplayData.defoultTranslateY;
    GLDisplayData.translateZ = GLDisplayData.defoultTranslateZ;
    
    GLDisplayData.scalefactor = GLDisplayData.defoultScalefactor;
}

#pragma mark - HSImageSidebarViewDelegate

-(void)sideBarInsertRow:(UIImage*)image atIndex:(NSInteger)index {
	[_images insertObject:image atIndex:index];
    
	[_ImagesBar insertRowAtIndex:index];
	[_ImagesBar scrollRowAtIndexToVisible:index];
	_ImagesBar.selectedIndex = index;
}

-(void)sideBarRemoveRowAtIndex:(NSUInteger)anIndex {
    [_images removeObjectAtIndex:anIndex];
    [_ImagesBar deleteRowAtIndex:anIndex];
    _SegmentationButton.enabled = NO;
    _SculptButton.enabled = NO;
    _SculptAllButton.enabled = NO;
}

-(void)sideBarRemoveAllRows {
    while (_ImagesBar.imageCount) {
        [self sideBarRemoveRowAtIndex:0];
    }
}

- (NSUInteger)countOfImagesInSidebar:(HSImageSidebarView *)sidebar {
	return _images.count;
}

- (UIImage *)sidebar:(HSImageSidebarView *)sidebar imageForIndex:(NSUInteger)anIndex {
    return [_images objectAtIndex:anIndex];   
}

-(void)sidebar:(HSImageSidebarView *)sidebar didTapImageAtIndex:(NSUInteger)anIndex {
    _ImageDisplay.image = [_images objectAtIndex:anIndex];
}

+ (void)getMatrixFromPath: (NSString *)path to: (double *)destination {
    NSString *contentOfFile = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSArray *components = [contentOfFile componentsSeparatedByString:@";"];
    for (unsigned int i = 0 ; i < components.count; i++) {
        destination[i] = [[components objectAtIndex:i] doubleValue];
    }
}

- (IBAction)segmentCurrentImage {
    if (_ImagesBar.selectedIndex != -1) {
        _ImageDisplay.image = [[_images objectAtIndex:_ImagesBar.selectedIndex] doSegmentation];
    }
}

- (void)updateBBox:(Cube&)box {
    if (_demo) {
        box.setCorner(DEMO_X_POSITION, DEMO_Y_POSITION, DEMO_Z_POSITION);
        box.setSize(DEMO_MESH_SIZE);
    }
}

- (void)updateProjectionMatrix:(cv::Mat&)P andRTmatrix:(cv::Mat&)rt withImage:(const cv::Mat&)image {
    if (_demo) {
        double dim[] = {
            3217.3,     -78.6,      289.9,
            0,          2292.4,    -1070.5,
            0,          0,          1
        };
        cv::Mat K(3,3,cv::DataType<double>::type,dim);
        P = cv::Mat(3,4,cv::DataType<double>::type,demoP[_ImagesBar.selectedIndex]);
        rt = K.inv() * P;
    } else {
        NSString *matricesDirectory = nil;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        matricesDirectory = [documentsDirectory stringByAppendingPathComponent:@"Matrices"];
        NSString *matrixPath = [matricesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.txt",_ImagesBar.selectedIndex]];
        double Matrix[16];
        [MeshView getMatrixFromPath:matrixPath to:Matrix];
        double dim[] = {
            F_X,    0,      image.size().width/2,    0,
            0,      F_Y,    image.size().height/2,   0,
            0,      0,      1,                       0
        };
        cv::Mat K(3,4,cv::DataType<double>::type,dim);
        rt = cv::Mat(4,4,cv::DataType<double>::type,Matrix);
        rt = rt.t();
        P = K * rt;
        rt = rt.clone();
    }
}

- (void)updateImage:(cv::Mat&)image andSilhouette:(cv::Mat&)silhouette {
    if (_silhouettes) {
        NSString *imageDirectory = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"pictures"];
        NSString *imagePath = [imageDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"viff.%d.png",_ImagesBar.selectedIndex + 1]];
        image = [UIImageCVMatConverter cvMatFromUIImage:[[UIImage alloc] initWithContentsOfFile:imagePath]];
        silhouette = [UIImageCVMatConverter cvMatFromUIImage:[self sidebar:_ImagesBar imageForIndex:_ImagesBar.selectedIndex]];
    } else {
        image = [UIImageCVMatConverter cvMatFromUIImage:[self sidebar:_ImagesBar imageForIndex:_ImagesBar.selectedIndex]];
        silhouette = [[_images objectAtIndex:_ImagesBar.selectedIndex] segmentToMat];
    }
}

- (IBAction)SculptFromCurrentImage {
    cv::Mat image, silhouette, P, rt;
    [self updateImage:image andSilhouette:silhouette];
    [self updateProjectionMatrix:P andRTmatrix:rt withImage:image];
    [self updateBBox:bBox];
    _sculpture->sculpt(ImageData(image,silhouette,P,rt), bBox);
//    _ImageDisplay.image = [UIImageCVMatConverter UIImageFromCVMat:silhouette];
}

- (void)sculptAllBackgroundWorker {
    [self performSelectorOnMainThread:@selector(showProgressBar) withObject:nil waitUntilDone:YES];
    NSInteger oldIndex = _ImagesBar.selectedIndex;
    for (_ImagesBar.selectedIndex = 0 ; _ImagesBar.selectedIndex < [_images count] ; ++_ImagesBar.selectedIndex) {
        cout << "image " << _ImagesBar.selectedIndex + 1 << " of " << [_images count] << "..." << endl;
        [self SculptFromCurrentImage];
        [self performSelectorOnMainThread:@selector(updateProgressBar:) withObject:[NSNumber numberWithFloat:(float(_ImagesBar.selectedIndex + 1) / [_images count])] waitUntilDone:YES];
    }
    _ImagesBar.selectedIndex = oldIndex;
    [self performSelectorOnMainThread:@selector(hideProgressBar) withObject:nil waitUntilDone:YES];
    //    [self hideProgressBar];
}

- (IBAction)SculptAll {
    [self performSelectorInBackground:@selector(sculptAllBackgroundWorker) withObject:nil];
}

- (void)updateGLView:(GLView *)targetView {
    if (targetView.context != nil)
    {
        //make it the current context for rendering
        [EAGLContext setCurrentContext:targetView.context];
        
        //if our framebuffers have not been created yet, do that now!
        if (![targetView getFrameBuffer])
            [targetView createFramebuffer];
    }   
    redraw = YES;    
}

#define OBJ_TEST
//#define PLY_TEST

- (IBAction)getMesh {
    _sculpture->createMesh();
    GLView *MeshGLView = [[GLView alloc] initWithFrame:_ImageDisplay.frame];
    MeshGLView.delegate = self;
    MeshGLView.opaque = YES;
    MeshGLView.hidden = NO;
    MeshGLView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:MeshGLView];
    [NSTimer scheduledTimerWithTimeInterval:0.04 target:MeshGLView selector:@selector(drawView) userInfo:nil repeats:YES];
    [MeshGLView addExitButton:BottomLeft withSize:25];
    [self addGestureRecognizers:MeshGLView];
#ifdef OBJ_TEST
    NSString *objTest = [[NSString alloc] initWithCString:_sculpture->objData().c_str()];
    [self writeStringToFile:objTest withFileName:@"Model.obj"];
    [objTest release];
#endif
#ifdef PLY_TEST
    NSString *plyTest = [[NSString alloc] initWithCString:_sculpture->plyData().c_str()];
    [self writeStringToFile:plyTest withFileName:@"Model.ply"];
    [plyTest release];
#endif
}

//our render loop just tells the iOS device that we want to keep refreshing our view all the time
- (void)startRenderLoop:(GLView *)MeshGLView {
    //check whether the loop is already running
    if(displayLink == nil) {
        //the display link specifies what to do when the screen has to be redrawn,
        //here we use the selector (method) drawFrame
        displayLink = [self.view.window.screen displayLinkWithTarget:MeshGLView selector:@selector(drawView)];
        //by adding the display link to the run loop our draw method will be called 60 times per second
        [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        NSLog(@"Starting Render Loop");
    }
}

- (void)updatePOV {
    glMatrixMode(GL_MODELVIEW);
    GLfloat modelView[16];
    glGetFloatv(GL_MODELVIEW_MATRIX, modelView);
    glLoadIdentity();
    glTranslatef(GLDisplayData.translateX, GLDisplayData.translateY, GLDisplayData.translateZ);
    glMultMatrixf(modelView);
    glRotatef(GLDisplayData.rotationAngle,GLDisplayData.rotationX, GLDisplayData.rotationY, GLDisplayData.rotationZ);
    glScalef(GLDisplayData.scalefactor, GLDisplayData.scalefactor, GLDisplayData.scalefactor);
}

- (void)drawAxes {
    const GLfloat lineX[] = {
        -100.0f, 0.0f, 0.0f, //point A
        100.0f, 0.0f, 0.0f //point B
    };
    const GLfloat lineY[] = {
        0.0f , -100.0f, 0.0f, //point A
        0.0f , 100.0f, 0.0f //point B
    };
    const GLfloat lineZ[] = {
        0.0f, 0.0f, -100.0f, //point A
        0.0f, 0.0f, 100.0f //point B
    };
    
    glEnableClientState(GL_VERTEX_ARRAY);
    
    glColor4f(1.0f, 0.0f, 0.0f, 1.0f); // opaque red
    glVertexPointer(3, GL_FLOAT, 0, lineX);
    glDrawArrays(GL_LINES, 0, 2);
    
    glColor4f(0.0f, 1.0f, 0.0f, 1.0f); // opaque green
    glVertexPointer(3, GL_FLOAT, 0, lineY);
    glDrawArrays(GL_LINES, 0, 2);
    
    glColor4f(0.0f, 0.0f, 1.0f, 1.0f); // opaque blue
    glVertexPointer(3, GL_FLOAT, 0, lineZ);
    glDrawArrays(GL_LINES, 0, 2);
    
    glDisableClientState(GL_VERTEX_ARRAY);
}

#define PAINT_SCULPTURE

- (void)drawMesh {   
    Mesh mesh = _sculpture->getMesh();
    const vector<float>& vertices = mesh.getVertices();
    const vector<float>& normals = mesh.getNormals();
#ifdef PAINT_SCULPTURE
    const vector<byte>& colors = mesh.getColors();
#endif
    glColor4f(0.0f,0.0f,1.0f,1.0f);
    glEnable(GL_COLOR_MATERIAL);
    glShadeModel(GL_FLAT);
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_NORMAL_ARRAY);
#ifdef PAINT_SCULPTURE
    glEnableClientState(GL_COLOR_ARRAY);
    glColorMask(true, true, true, true);
#endif
    glVertexPointer(3, GL_FLOAT, 0, vertices.data());
    glNormalPointer(GL_FLOAT, 0, normals.data());
#ifdef PAINT_SCULPTURE
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, colors.data());
#endif
    glDrawArrays(GL_TRIANGLES, 0, mesh.getNumberOfTriangles() * 3);
    glDisableClientState(GL_NORMAL_ARRAY);
    glDisableClientState(GL_VERTEX_ARRAY);
#ifdef PAINT_SCULPTURE
    glDisableClientState(GL_COLOR_ARRAY);
#endif
    glShadeModel(GL_SMOOTH);
    glLightf(0, GL_LINEAR_ATTENUATION, 1);
    glLightf(1, GL_SPOT_CUTOFF, 2);
    glDisable(GL_COLOR_MATERIAL);
    glColor4f(1, 1, 1, 1);
}

- (void)writeStringToFile:(NSString*)aString withFileName:(NSString*)fileName {
    
    // Build the path, and create if needed.
    NSString* filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* fileAtPath = [filePath stringByAppendingPathComponent:fileName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileAtPath]) {
        [[NSFileManager defaultManager] createFileAtPath:fileAtPath contents:nil attributes:nil];
    }
    [[aString dataUsingEncoding:NSUTF8StringEncoding] writeToFile:fileAtPath atomically:NO];
}

//GLView Delegate
- (void)drawView:(GLView *)theView {
    if (theView.context != nil) {
        [EAGLContext setCurrentContext:theView.context];
        if (![theView getFrameBuffer])
            [theView createFramebuffer];
    }
    if (redraw) {
        //clear current display
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        [self updatePOV];
        [self drawMesh];
        [self drawAxes];
        redraw = NO;
    }
}

inline void addLight(unsigned int light, const GLfloat *ambient, const GLfloat *diffuse, const GLfloat *specular, const GLfloat *position, const GLfloat *direction, const GLfloat cutoff) {
    // Turn the light on
    glEnable(light);
    glLightfv(light, GL_AMBIENT, ambient);
    glLightfv(light, GL_DIFFUSE, diffuse);
    glLightfv(light, GL_SPECULAR, specular);
    glLightfv(light, GL_POSITION, position);
    glLightfv(light, GL_SPOT_DIRECTION, direction);
    // Define a cutoff angle. This defines a 90° field of vision, since the cutoff
    // is number of degrees to each side of an imaginary line drawn from the light's
    // position along the vector supplied in GL_SPOT_DIRECTION above
    glLightf(light, GL_SPOT_CUTOFF, cutoff);
}

- (void)addLights {
    glEnable(GL_LIGHTING);
    const GLfloat light0Ambient[] = {0.5, 0.5, 0.5, 1.0};
    const GLfloat light0Diffuse[] = {0.2, 0.2, 0.2, 1.0};
    const GLfloat light0Specular[] = {0.1, 0.1, 0.1, 1.0};
    const GLfloat light0Position[] = {-200.0, 0.0, 0.0, 0.0};
    const GLfloat light0Direction[] = {1.0,0.0,0.0};
    addLight(GL_LIGHT0, light0Ambient, light0Diffuse, light0Specular, light0Position, light0Direction, 45.0);
    const GLfloat light1Position[] = {200.0, 0.0, 0.0, 0.0};
    const GLfloat light1Direction[] = {-1.0,0.0,0.0};
    addLight(GL_LIGHT0, light0Ambient, light0Diffuse, light0Specular, light1Position, light1Direction, 45.0);
}

- (void)setupView:(UIView *)theView {
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glViewport(0, 0, theView.bounds.size.width * theView.contentScaleFactor, theView.bounds.size.height * theView.contentScaleFactor);
    glMatrixMode(GL_PROJECTION);
	glLoadIdentity();       
    //If enabled, do depth comparisons and update the depth buffer
    glEnable(GL_DEPTH_TEST);
    GLfloat aspectRatio = (theView.bounds.size.width / theView.bounds.size.height);
    FrustumData.top = FrustumData.right / aspectRatio;
    FrustumData.bottom = -FrustumData.top;
    glFrustumf(FrustumData.left, FrustumData.right, FrustumData.bottom, FrustumData.top, FrustumData.zNear, FrustumData.zFar);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    glTranslatef(0.0f, 0.0f, -FrustumData.zNear * 5);
//    [self addLights];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

//Gesture functions
- (void) updateGLViewR:(UIGestureRecognizer *)recognizer {
    [self updateGLView:(GLView *)(recognizer.delegate)];
}

- (void) addGestureRecognizers:(UIView *)targetView {
	UIGestureRecognizer *recognizer;
    //Pan
    recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFrom:)];
    [recognizer addTarget:self action:@selector(updateGLViewR:)];
    [(UIPanGestureRecognizer*)recognizer setMaximumNumberOfTouches:2];
    [(UIPanGestureRecognizer*)recognizer setDelegate:targetView];
    [self.view addGestureRecognizer:recognizer];
    [recognizer release];
    //Pinch
    recognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchFrom:)];
    [recognizer addTarget:self action:@selector(updateGLViewR:)];
    [(UIPinchGestureRecognizer*)recognizer setDelegate:targetView];
    [self.view addGestureRecognizer:recognizer];
    [recognizer release];
}

-(void)handlePinchFrom:(UIPinchGestureRecognizer *)recognizer {
    [self resetControllerInstances];
    if ([recognizer state] == UIGestureRecognizerStateBegan) {
        GestureData.startTouchPositionTwoFingers = [recognizer locationInView:self.view];
        GLDisplayData.scalefactor += [recognizer scale] - 1;
        [recognizer setScale:1];
        return;
    } else if ([recognizer state] == UIGestureRecognizerStateEnded) {
        return;
    }
    CGPoint point = [recognizer locationInView:self.view];
    GestureData.startTouchPositionTwoFingers = point;
    GLDisplayData.scalefactor += [recognizer scale] - 1;
    [recognizer setScale:1];
}

#define OLD_PAN

-(void)handlePanOneFinger:(UIPanGestureRecognizer *)recognizer {
    if ([recognizer state] == UIGestureRecognizerStateBegan) {
        GestureData.startTouchPositionOneFinger = [recognizer locationInView:self.view];
        return;
        
    }
    CGPoint point = [recognizer locationInView:self.view];
    double vecX = point.x - GestureData.startTouchPositionOneFinger.x;
    double vecY = point.y - GestureData.startTouchPositionOneFinger.y;
#ifdef OLD_PAN
    double vecNorm = sqrtf(vecX*vecX + vecY*vecY) * 0.2;
    //        vecX = vecX / vecNorm;
    //        vecY = vecY / vecNorm;
    
    // vecX and vecY are used to rotate the vector
    GLDisplayData.rotationX = vecY;
    GLDisplayData.rotationY = -vecX;
    GLDisplayData.rotationZ = 0.0f;
    GLDisplayData.rotationAngle = vecNorm;
#endif
#ifndef OLD_PAN
    float oldRotationAngle = GLDisplayData.rotationAngle;
    float oldRotationX = GLDisplayData.rotationX;
    float oldRotationY = GLDisplayData.rotationY;
    float oldRotationZ = GLDisplayData.rotationZ;
    
    float newRotationAngle = sqrtf(vecX*vecX + vecY*vecY) * 0.2;
    float newRotationX = vecY;
    float newRotationY = -vecX;
    float newRotationZ = 0.0f;
    //perform quaternion multiplication
    GLDisplayData.rotationAngle = oldRotationAngle * newRotationAngle - oldRotationX * newRotationX - oldRotationY * newRotationY - oldRotationZ * newRotationZ;
    GLDisplayData.rotationX = oldRotationAngle * newRotationX + oldRotationX * newRotationAngle + oldRotationY * newRotationZ - oldRotationZ * newRotationY;
    GLDisplayData.rotationY = oldRotationAngle * newRotationY - oldRotationX * newRotationZ + oldRotationY * newRotationAngle + oldRotationZ * newRotationX;
    GLDisplayData.rotationZ = oldRotationAngle * newRotationZ + oldRotationX * newRotationY - oldRotationY * newRotationX + oldRotationZ * newRotationAngle;
#endif
}

-(void)handlePanTwoFingers:(UIPanGestureRecognizer *)recognizer {
    if ([recognizer state] == UIGestureRecognizerStateBegan) {
        GestureData.startTouchPositionTwoFingers = [recognizer locationInView:self.view];
        return;
    }
    else if ([recognizer state] == UIGestureRecognizerStateEnded) {
        return;
    }
    CGPoint point = [recognizer locationInView:self.view];
    double vecX = point.x - GestureData.startTouchPositionTwoFingers.x;
    double vecY = point.y - GestureData.startTouchPositionTwoFingers.y;
    GLDisplayData.translateX =  vecX;
    GLDisplayData.translateY =  -vecY;
    GestureData.startTouchPositionTwoFingers = point;
}

-(void)handlePanFrom:(UIPanGestureRecognizer *)recognizer {
#ifdef OLD_PAN
    [self resetControllerInstances];
#endif
    switch (int([recognizer numberOfTouches])) {
        case 1:
            [self handlePanOneFinger:recognizer];
            break;
        case 2:
            [self handlePanTwoFingers:recognizer];
            break;
        default:
            break;
    };
}
@end
