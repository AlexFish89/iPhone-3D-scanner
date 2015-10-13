#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>

#import "GLView.h"

@implementation GLView

@synthesize context;
@synthesize delegate;

// Set up a view with an OpenGL backing
+ (Class)layerClass 
{
    return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		
        CAEAGLLayer *layer = (CAEAGLLayer *)self.layer;
        
        layer.opaque = YES;
        layer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSNumber numberWithBool:NO], 
									kEAGLDrawablePropertyRetainedBacking,
									kEAGLColorFormatRGBA8,
									kEAGLDrawablePropertyColorFormat,
									nil];
        
		context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
		
		if (!context || ![EAGLContext setCurrentContext:context]) {
			[self release];
			return nil;
		}
    }
	
    return self;
}

- (void)drawView 
{
    [self setCurrent];
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, framebuffer);
    
	[delegate drawView:self];
	
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, renderbuffer);
    
	[context presentRenderbuffer:GL_RENDERBUFFER_OES];
}

- (void) setCurrent
{
    [EAGLContext setCurrentContext:context];
}

- (void)layoutSubviews 
{
    [EAGLContext setCurrentContext:context];
    
	//[self destroyFramebuffer];
	
    static bool flagged = 0;
    
    if (!flagged)
    {[self createFramebuffer];
        flagged=1;
    }
	
    [self drawView];
}

- (BOOL)createFramebuffer 
{    
    glGenFramebuffersOES(1, &framebuffer);
    glGenRenderbuffersOES(1, &renderbuffer);
	glGenRenderbuffersOES(1, &depthbuffer);
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, framebuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, renderbuffer);
	
    [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer*)self.layer];
	
	// Attach renderbuffer to framebuffer
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, renderbuffer);
	
	GLint width;
    GLint height;

    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &width);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &height);
	
	// Create 16 bit depth buffer
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthbuffer);
	glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, width, height);
	
	// attach the depth buffer to the frame buffer
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthbuffer);
    
    if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) {
        NSLog(@"OpenGL framebuffer incomplete: %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
        return NO;
    }
    [delegate setupView:self];
    return YES;
}

- (void)destroyFramebuffer 
{
    glDeleteFramebuffersOES(1, &framebuffer);
    framebuffer = 0;
	
    glDeleteRenderbuffersOES(1, &renderbuffer);
    renderbuffer = 0;    
	
	glDeleteRenderbuffersOES(1, &depthbuffer);
	depthbuffer = 0;
}

- (void)dealloc 
{
    if ([EAGLContext currentContext] == context) 
        [EAGLContext setCurrentContext:nil];
    
    [context release];  
    [super dealloc];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[delegate touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
{
	[delegate touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
{
	[delegate touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
{
	[delegate touchesCancelled:touches withEvent:event];
}

- (GLuint) getFrameBuffer {
    return framebuffer;
}

- (GLuint) getRenderBuffer {
    return renderbuffer;
}

- (GLuint) getDepthBuffer {
    return depthbuffer;
}

@end
