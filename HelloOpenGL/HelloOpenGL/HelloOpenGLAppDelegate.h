//
//  HelloOpenGLAppDelegate.h
//  HelloOpenGL
//
//  Created by Mark Xiong on 8/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenGLView.h"

@interface HelloOpenGLAppDelegate : UIResponder <UIApplicationDelegate>{
    OpenGLView* _glView;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) IBOutlet OpenGLView *glView;

@end
