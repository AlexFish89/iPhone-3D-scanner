#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
//#import <OpenGLES/ES2/gl.h>
//#import <OpenGLES/ES2/glext.h>

@protocol GLViewDelegate
- (void)drawView:(UIView *)theView;
- (void)setupView:(UIView *)theView;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
@end

@interface GLView : UIView
{
    
@private

	// The GL context
    EAGLContext *context;
	
	// Buffers
	GLuint framebuffer;
    GLuint renderbuffer;
    GLuint depthbuffer;

    id<GLViewDelegate> delegate;
}
@property (assign) id<GLViewDelegate>  delegate;
@property (nonatomic, retain) EAGLContext *context;
- (BOOL) createFramebuffer;
- (void) destroyFramebuffer;
- (void) drawView;
- (void) setCurrent;
- (GLuint) getFrameBuffer;
- (GLuint) getRenderBuffer;
- (GLuint) getDepthBuffer;
@end
