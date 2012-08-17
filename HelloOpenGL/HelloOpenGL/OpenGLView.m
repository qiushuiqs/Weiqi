//
//  OpenGLView.m
//  HelloOpenGL
//
//  Created by Mark Xiong on 8/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OpenGLView.h"

@implementation OpenGLView

typedef struct {
    float Position[3];
    float Color[4];
} Vertex;

const Vertex Vertices[] = {
    {{1, -1, 0}, {1, 0, 0, 1}},
    {{1, 1, 0}, {0, 1, 0, 1}},
    {{-1, 1, 0}, {0, 0, 1, 1}},
    {{-1, -1, 0}, {0, 0, 0, 1}}
};

const GLubyte Indices[] = {
    0, 1, 2,
    2, 3, 0
};

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (void)setupLayer {
    _eaglLayer = (CAEAGLLayer*) self.layer;
    _eaglLayer.opaque = YES;
}

- (void)setupContext {   
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    _context = [[EAGLContext alloc] initWithAPI:api];
    if (!_context) {
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
        exit(1);
    }
    
    if (![EAGLContext setCurrentContext:_context]) {
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
}
//Create a render buffer
- (void)setupRenderBuffer{
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);//whenever I refer to GL_RENDERBUFFER, I really mean _colorRenderBuffer.
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
}

//Create a frame buffer
- (void)setupFrameBuffer{
    GLuint framebuffer;
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer); //It lets you attach the render buffer you created earlier to the frame buffer’s GL_COLOR_ATTACHMENT0 slot.
}

#pragma mark Compiling Vertex and Fragment Shaders
//Compiling Vertex and Fragment Shaders
//   (GLuint)compileShader:(NSString*)shaderName withType:(GLenum)shaderType
//   (void)compileShaders
//It’s the job our our app to compile and run these shaders base on the glsl files
//////////////////////////////////////////////////////////////////////////////
- (GLuint)compileShader:(NSString*)shaderName withType:(GLenum)shaderType {
    
    // Gets an NSString with the contents of the file.
    NSString* shaderPath = [[NSBundle mainBundle] pathForResource:shaderName 
                                                           ofType:@"glsl"];
    NSError* error;
    NSString* shaderString = [NSString stringWithContentsOfFile:shaderPath 
                                                       encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSLog(@"Error loading shader: %@", error.localizedDescription);
        exit(1);
    }
    
    //Calls glCreateShader to create a OpenGL object to represent the shader. pass in a shaderType to indicate whether it’s a fragment or vertex shader.
    GLuint shaderHandle = glCreateShader(shaderType);    
    
    // convert the source code for the shaders from an NSString to a C-string.
    const char * shaderStringUTF8 = [shaderString UTF8String];    
    int shaderStringLength = [shaderString length];
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);

    // compile the shader at runtime
    glCompileShader(shaderHandle);
    
    // output any error messages to the screen 
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    return shaderHandle;
    
}

- (void)compileShaders {
    
    // Uses the method you just wrote to compile the vertex and fragment shaders.
    GLuint vertexShader = [self compileShader:@"SimpleVertex" 
                                     withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShader:@"SimpleFragment" 
                                       withType:GL_FRAGMENT_SHADER];
    
    // link the vertex and fragment shaders into a complete program.
    GLuint programHandle = glCreateProgram();
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    glLinkProgram(programHandle);
    
    // check and see if there were any link errors, and display the output and quit if so.
    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(programHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    // actually use this program when given vertex info.
    glUseProgram(programHandle);
    
    // 5
    _positionSlot = glGetAttribLocation(programHandle, "Position");
    _colorSlot = glGetAttribLocation(programHandle, "SourceColor");
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_colorSlot);
}

#pragma mark Creating Vertex Buffer Objects
- (void)setupVBOs {
    
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_STATIC_DRAW);
    
    GLuint indexBuffer;
    glGenBuffers(1, &indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);
    
}

#pragma mark Render!!!!!!!!!!

- (void)render{
    glClearColor(0, 104.0/255.0, 55.0/255.0, 1.0); //Clear the screen
    glClear(GL_COLOR_BUFFER_BIT);
    
    // to set the portion of the UIView to use for rendering. 
    glViewport(0, 0, self.frame.size.width/2, self.frame.size.height/2);
    
    // 2
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 
                          sizeof(Vertex), 0);
    glVertexAttribPointer(_colorSlot, 4, GL_FLOAT, GL_FALSE, 
                          sizeof(Vertex), (GLvoid*) (sizeof(float) * 3));
    
    // 3
    glDrawElements(GL_TRIANGLES, sizeof(Indices)/sizeof(Indices[0]), 
                   GL_UNSIGNED_BYTE, 0);
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}


#pragma mark Initilize and delloc

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {        
        [self setupLayer];        
        [self setupContext];                
        [self setupRenderBuffer];        
        [self setupFrameBuffer]; 
        [self compileShaders];
        [self setupVBOs];
        [self render];        
    }
    return self;
}

// Replace dealloc method with this
- (void)dealloc
{
    _context = nil;
}


@end
