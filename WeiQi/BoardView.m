//
//  BoardView.m
//  WeiQi
//
//  Created by Mark Xiong on 7/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BoardView.h"
#import <QuartzCore/QuartzCore.h>
@interface BoardView()


@end

@implementation BoardView
@synthesize datasourse = _datasourse;
@synthesize imageOfBoard = _imageOfBoard;
-(void)setup{
    //self.contentMode = UIViewContentModeRedraw;
    self.backgroundColor = [UIColor colorWithRed:238.0/250 green:222.0/250 blue:176.0/250 alpha:0.7];
}

-(void)awakeFromNib{            //initWithFrame will not be called for a UIView coming out of storyboard.
    [self setup];               //but awakeFromNib is.
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)drawGridLines:(CGContextRef)context widthIncresedBy:(CGFloat)w heightIncresedBy:(CGFloat)h atPosition:(CGPoint)start{
    UIGraphicsPushContext(context);
    //begin to draw the frame of cheesboard
    CGContextBeginPath(context);
    CGContextSetRGBStrokeColor(context, 182.0/250, 202.0/250, 198.0/250, 1);
    CGContextSetLineWidth(context, 2);
    CGContextAddRect(context, CGRectMake(start.x, start.y, w*18, h*18));
    CGContextStrokePath(context);
    //begin to draw the vertical lines and horizontal lines
    CGContextBeginPath(context);
    CGContextSetLineWidth(context, 1);
    CGPoint end = CGPointMake(start.x+w, start.y);
    for (int i=0; i<17; i++) {
        CGContextMoveToPoint(context, end.x, end.y);
        CGContextAddLineToPoint(context, end.x, end.y+h*18);
        end.x += w;
    }
    end = CGPointMake(start.x, start.y+h);
    for (int i=0; i<17; i++) {
        CGContextMoveToPoint(context, end.x, end.y);
        CGContextAddLineToPoint(context, end.x+w*18, end.y);
        end.y += h;
    }
    CGContextStrokePath(context);
    UIGraphicsPopContext();
}

- (void)fillCircleAtPoint:(CGContextRef)context withRadius:(CGFloat)radius atPoint:(CGPoint)point{
    UIGraphicsPushContext(context);
    CGContextBeginPath(context);
    CGContextAddArc(context, point.x, point.y, radius, 0, 2*M_PI, YES);
    CGContextFillPath(context);
    UIGraphicsPopContext();
}

- (void)tap:(UITapGestureRecognizer *)gesture{
    gesture.numberOfTapsRequired = 1;
  //  CGContextRef context = UIGraphicsGetCurrentContext();
    CGPoint point = [gesture locationInView:self];
     NSLog(@"here is the point: %f",point.x);
 //   [self setNeedsDisplay];
  //  [self fillCircleAtPoint:context withRadius:10 atPoint:point];
  //  CGContextMoveToPoint(context, 30, 30);
 //   CGContextAddLineToPoint(context, self.bounds.size.width, self.bounds.size.height);
 //   CGContextStrokePath(context);
}


#define GRID_INTERVAL 37.0
#define GRID_JUNCTION_RADIUS 5.0

- (void)boardDrawing:(CGContextRef)context{
    
    CGPoint start = CGPointMake((self.bounds.size.width-((GRID_INTERVAL)*18))/2, (self.bounds.size.height-((GRID_INTERVAL)*18))/2);
    //画棋盘
    [self drawGridLines:context widthIncresedBy:GRID_INTERVAL heightIncresedBy:GRID_INTERVAL atPosition:start];
    //画棋盘上的点
    [self fillCircleAtPoint:context withRadius:GRID_JUNCTION_RADIUS atPoint:CGPointMake(start.x+3*GRID_INTERVAL, start.y+3*GRID_INTERVAL)];
    [self fillCircleAtPoint:context withRadius:GRID_JUNCTION_RADIUS atPoint:CGPointMake(start.x+9*GRID_INTERVAL, start.y+3*GRID_INTERVAL)];
    [self fillCircleAtPoint:context withRadius:GRID_JUNCTION_RADIUS atPoint:CGPointMake(start.x+15*GRID_INTERVAL, start.y+3*GRID_INTERVAL)];
    [self fillCircleAtPoint:context withRadius:GRID_JUNCTION_RADIUS atPoint:CGPointMake(start.x+15*GRID_INTERVAL, start.y+9*GRID_INTERVAL)];
    [self fillCircleAtPoint:context withRadius:GRID_JUNCTION_RADIUS atPoint:CGPointMake(start.x+3*GRID_INTERVAL, start.y+9*GRID_INTERVAL)];
    [self fillCircleAtPoint:context withRadius:GRID_JUNCTION_RADIUS atPoint:CGPointMake(start.x+3*GRID_INTERVAL, start.y+15*GRID_INTERVAL)];
    [self fillCircleAtPoint:context withRadius:GRID_JUNCTION_RADIUS atPoint:CGPointMake(start.x+15*GRID_INTERVAL, start.y+15*GRID_INTERVAL)];
    [self fillCircleAtPoint:context withRadius:GRID_JUNCTION_RADIUS atPoint:CGPointMake(start.x+9*GRID_INTERVAL, start.y+9*GRID_INTERVAL)];
    [self fillCircleAtPoint:context withRadius:GRID_JUNCTION_RADIUS atPoint:CGPointMake(start.x+9*GRID_INTERVAL, start.y+15*GRID_INTERVAL)];

}

- (void)stepDrawing:(CGContextRef)context{
    NSDictionary* dictionary = [self.datasourse movingStepFetching:self];
    NSArray *arrayOfPoint = [dictionary allKeys];
    for (NSValue *val in arrayOfPoint) {
        CGPoint point = [val CGPointValue];
        if (![[dictionary objectForKey:val] intValue]) {
            CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        }else {
            CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
        }
        [self fillCircleAtPoint:context withRadius:18 atPoint:point];
    }

}
/*
- (void)stepErasing:(CGContextRef)context{
    NSSet* setOfPoint = [self.datasourse movingStepTaking:self];
    for (NSValue *val in setOfPoint) {
        CGPoint point = [val CGPointValue];
        CGContextSetFillColorWithColor(context, [UIColor blueColor].CGColor);
        [self fillCircleAtPoint:context withRadius:18 atPoint:point];
    }

}
*/
- (void)drawRect:(CGRect)rect
{
    
    if (!self.imageOfBoard) {
        UIGraphicsBeginImageContext(self.bounds.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        NSLog(@"no image start to draw image");
        [self boardDrawing:context];
       // [self.layer renderInContext:context];
        self.imageOfBoard = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext(); 
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    NSLog(@"image load");
    CGContextDrawImage(context, rect, self.imageOfBoard.CGImage);
    
    [self stepDrawing:context];
        /*    
    CGContextMoveToPoint(context, 30, 30);
    CGContextAddLineToPoint(context, self.bounds.size.width, self.bounds.size.height);
    NSLog(@"interface: width->%f, height->%f",self.bounds.size.width,self.bounds.size.height);
    CGContextStrokePath(context);
   CGContextSetRGBFillColor(context, 226, 156, 69, 1);
  CGContextFillRect(context, CGRectMake(0, 0, 100, 100));
*/    
    
    NSFileManager *fm =[NSFileManager defaultManager];
    
//    UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://blog.objectgraph.com/wp-content/uploads/2009/04/xcode_logo.png"]]];
    
    NSData *viewImageData = [NSData dataWithData:UIImageJPEGRepresentation(self.imageOfBoard, 1)];
    
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    NSLog(@"file path---> %@",path);
    if (![fm changeCurrentDirectoryPath:path]) {    //将当前目录转移到之前新建的文件夹中
        NSLog(@"could not change the derectory"); 
    }
    NSString *pngFilePath = [NSString stringWithFormat:@"%@/test.png",path];
    [viewImageData writeToFile:pngFilePath atomically:YES];
        if (![fm createFileAtPath:@"WeiQiBoard.png" contents:viewImageData attributes:nil]) {
            NSLog(@"could not create the file");
    }
    
}



@end
