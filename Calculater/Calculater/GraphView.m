//
//  GraphView.m
//  Calculater
//
//  Created by Mark Xiong on 7/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GraphView.h"
#import "AxesDrawer.h"

@implementation GraphView
@synthesize scale = _scale;
@synthesize delegate = _delegate;
@synthesize origin = _origin;

- (void)setup
{
    self.contentMode = UIViewContentModeRedraw; // if our bounds changes, redraw ourselves
}

- (void)awakeFromNib
{
    [self setup]; // get initialized when we come out of a storyboard
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

-(CGPoint)origin{
    if (_origin.x==0 && _origin.y==0) {
       _origin.y = [[[self.delegate retrievePointFromUserDefaults] lastObject] doubleValue];
        _origin.x = [[[self.delegate retrievePointFromUserDefaults] objectAtIndex:0] doubleValue];
    }        
    return _origin;
}

-(void)setOrigin:(CGPoint)origin{
    if((origin.x != _origin.x)||(origin.y != _origin.y)){
        _origin.x = origin.x;
        _origin.y = origin.y;
        NSArray * originSettings = [[NSArray alloc] initWithObjects: [NSNumber numberWithFloat:self.origin.x] , [NSNumber numberWithFloat:self.origin.y], nil];
        [self.delegate saveToUserPointDefaults:originSettings];
        [self setNeedsDisplay];
    }
}
-(CGFloat)scale{
    if (!_scale) {
        if (![self.delegate retrieveScaleFromUserDefaults]) {
            return 1;
        } // don't allow zero scale
        return [self.delegate retrieveScaleFromUserDefaults];
    }else 
        return _scale;   
}
-(void)setScale:(CGFloat)scale{
    if (_scale!=scale) {
        _scale = scale;
        [self.delegate saveToUserScaleDefaults:scale];
        [self setNeedsDisplay];
    }
}


-(void)pinch:(UIPinchGestureRecognizer *)gesture{
    if(gesture.state == UIGestureRecognizerStateChanged || gesture.state == UIGestureRecognizerStateEnded){
        self.scale *= gesture.scale; // adjust our scale
        gesture.scale = 1;           // reset gestures scale to 1 (so future changes are incremental, not cumulative)
    }
}

-(void)pan:(UIPanGestureRecognizer *)gesture{
    if(gesture.state == UIGestureRecognizerStateChanged || gesture.state == UIGestureRecognizerStateEnded){
        CGPoint translation = [gesture translationInView:self];
        CGPoint p =  CGPointMake(self.origin.x + translation.x, self.origin.y + translation.y);
        self.origin = p;
        [gesture setTranslation:CGPointZero inView:self];
    }
}

-(void)tap:(UITapGestureRecognizer *)gesture{
   
    gesture.numberOfTapsRequired = 3;
    self.origin =[gesture locationInView:self];
}

#define DEFAULT_WIDTH_UNIT 16.0;

- (void)drawRect:(CGRect)rect
{
    double xrayDigit, yrayMax,yrayBound, xrayBound;    
    
    CGContextRef context = UIGraphicsGetCurrentContext();

    
    CGFloat size = self.bounds.size.width*self.scale/DEFAULT_WIDTH_UNIT;    //for vertical screen

    xrayDigit = -self.origin.x/self.bounds.size.width/self.scale*DEFAULT_WIDTH_UNIT;    //start digit of x-ray 
    xrayBound = DEFAULT_WIDTH_UNIT;   //how many digit palces showed on the xray Default = 16. But change with zoom in/out 
    yrayBound = self.bounds.size.height/self.bounds.size.width*DEFAULT_WIDTH_UNIT;   // bound on yray
    yrayMax = self.origin.y/self.bounds.size.height*yrayBound/self.scale;   //the highest y value show on the screen.
    
    if (self.bounds.size.height < self.bounds.size.width){              //for horizontal screen
        size = self.bounds.size.height*self.scale/DEFAULT_WIDTH_UNIT;
        xrayDigit = (-self.origin.x*16/self.bounds.size.height)/self.scale;
        xrayBound = 16*self.bounds.size.width/self.bounds.size.height;
        yrayBound = DEFAULT_WIDTH_UNIT;
        yrayMax = self.origin.y/self.bounds.size.height*yrayBound/self.scale;
    }
//draw the coordinate    
    CGContextSetLineWidth(context, 1.0);
    [[UIColor blueColor] setStroke];
    [AxesDrawer drawAxesInRect:rect originAtPoint:self.origin scale:(size)];
   
//draw the line calulated by calculator     
    CGContextBeginPath(context);
    
    CGContextSetLineWidth(context, 2.0);
    
    double endY,startY;
    startY = [self.delegate getYfromController:(xrayDigit)];    //Use delegate here to retrieve data from controller

    for (int i=0; i<self.bounds.size.width; i++) {
        endY =[self.delegate getYfromController:(i/self.bounds.size.width*xrayBound/self.scale+xrayDigit)];
        
        double pointY =  (yrayMax-startY)*self.bounds.size.height/yrayBound*self.scale;
        if((0<pointY) && (pointY<self.bounds.size.height)){
            [[UIColor redColor] setFill];
            CGContextFillRect(context, CGRectMake(i,pointY,2,(endY-startY)*self.bounds.size.height/yrayBound*self.scale+1));
            //  CGContextMoveToPoint(context, i, pointY);
          //  pointY =  (yrayMax-endY)*self.bounds.size.height/yrayBound*self.scale;
          //  CGContextAddLineToPoint(context, i+1, pointY);
            
        }else {             //else just move and do noting
            CGContextMoveToPoint(context, i, pointY);
        }
        startY = endY ;
    }
    CGContextStrokePath(context);
}

@end

