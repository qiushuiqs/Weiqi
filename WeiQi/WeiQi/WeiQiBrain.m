//
//  WeiQiBrain.m
//  WeiQi
//
//  Created by Mark Xiong on 7/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WeiQiBrain.h"

@interface WeiQiBrain()

@property (nonatomic,strong)NSMutableArray *movingSteps;
@property (nonatomic,strong)NSMutableDictionary *stepOnBoard;
@property (nonatomic,strong)NSMutableArray *takenSteps;
@property (nonatomic)int color;

@end

@implementation WeiQiBrain
@synthesize movingSteps =_movingSteps;
@synthesize stepOnBoard = _stepOnBoard;
@synthesize takenSteps = _takenSteps;
@synthesize color = _color;

- (NSMutableArray*)movingSteps{
    if (!_movingSteps) {
        _movingSteps = [[NSMutableArray alloc] init];
    }
    return _movingSteps;
}

- (NSMutableDictionary*)stepOnBoard{
    if(!_stepOnBoard){
        _stepOnBoard = [[NSMutableDictionary alloc] init];
    }
    return  _stepOnBoard;
}

- (NSMutableArray*)takenSteps{
    if (!_takenSteps) {
        _takenSteps = [[NSMutableArray alloc] init];
    }
    return _takenSteps;
}

- (id)stepRecords{
  //  NSLog(@"stepRecords: %i",self.movingSteps.count);
    return [self.stepOnBoard copy];
}

- (id)takenRecords{
    NSLog(@"stepOnBoard: %i",self.stepOnBoard.count);
   // [self.takenSteps addObject:[NSValue valueWithCGPoint:CGPointMake(100, 100)]];
    
    return [self.stepOnBoard copy];
}

- (void)pushStep:(CGPoint)step withCount:(int)countOfsteps{
    if (![[self.stepOnBoard allKeys] containsObject:[NSValue valueWithCGPoint:step]]) {
        [self.movingSteps addObject:[NSValue valueWithCGPoint:step]];
       // NSLog(@"number of step, %i",self.movingSteps.count);
        [self.stepOnBoard setObject:[NSNumber numberWithInt:(countOfsteps%2)] forKey:[NSValue valueWithCGPoint:step]]; //transfer CGPoint to NSValue. After that you can save it into array.
       // self.color = countOfsteps%2;
        [self libertyCalculate:step];
    }
}

- (void)removeLastStep{
    [self.movingSteps removeLastObject];
}

#define GRID_INTERVAL 37.0
#define LEFT_MARGIN 49.0
#define RIGHT_MARGIN 715.0
#define TOP_MARGIN 41.0
#define BOTTOM_MARGIN 708.0

- (void)libertyCalculate:(CGPoint) point{
    BOOL isTakenPoint =  NO;
    //first, get the reverse color of step (black or white)
    self.color = self.movingSteps.count%2;
    //NSLog(@"color in the libertyCalculate %i", color);
    //secondly, get the 4 direction point
    CGPoint upPoint = CGPointMake([self.movingSteps.lastObject CGPointValue].x, [self.movingSteps.lastObject CGPointValue].y-GRID_INTERVAL);
    CGPoint downPoint = CGPointMake([self.movingSteps.lastObject CGPointValue].x, [self.movingSteps.lastObject CGPointValue].y+GRID_INTERVAL);
    CGPoint rightPoint = CGPointMake([self.movingSteps.lastObject CGPointValue].x+GRID_INTERVAL, [self.movingSteps.lastObject CGPointValue].y);
    CGPoint leftPoint = CGPointMake([self.movingSteps.lastObject CGPointValue].x-GRID_INTERVAL, [self.movingSteps.lastObject CGPointValue].y);
    
    if ([[self.stepOnBoard allKeys] containsObject:[NSValue valueWithCGPoint:upPoint]]) {
        if (self.color!=[[self.stepOnBoard objectForKey:[NSValue valueWithCGPoint:upPoint]] intValue]%2) {
            //NSLog(@"upside color difference");
            //  NSLog(@"up taken!!!!!! %i",[self selfLibertyCalculate:upPoint withDirection:2] );
            if ([self selfLibertyCalculate:upPoint withDirection:2] ==0) {
              //记录每个提掉的子 
                //[self.stepOnBoard removeObjectForKey:[NSValue valueWithCGPoint:upPoint]];
 //               NSLog(@"start to taken upside point");
                [self takenStep:upPoint withDirection:2];
                isTakenPoint = YES;
            }
            [self.takenSteps removeAllObjects];
        }
    }
    if ([[self.stepOnBoard allKeys] containsObject:[NSValue valueWithCGPoint:downPoint]]) {
        if (self.color!=[[self.stepOnBoard objectForKey:[NSValue valueWithCGPoint:downPoint]] intValue]%2) {
            if ([self selfLibertyCalculate:downPoint withDirection:1] ==0) {
                //记录每个提掉的子  
                //[self.stepOnBoard removeObjectForKey:[NSValue valueWithCGPoint:downPoint]];
   //             NSLog(@"start to taken downside point");
                [self takenStep:downPoint withDirection:1];
                isTakenPoint = YES;
            } 
            [self.takenSteps removeAllObjects];
        }
    }
    if ([[self.stepOnBoard allKeys] containsObject:[NSValue valueWithCGPoint:leftPoint]]) {
        if (self.color!=[[self.stepOnBoard objectForKey:[NSValue valueWithCGPoint:leftPoint]] intValue]%2) {
            if ([self selfLibertyCalculate:leftPoint withDirection:4] ==0) {
                //记录每个提掉的子 
                //[self.stepOnBoard removeObjectForKey:[NSValue valueWithCGPoint:leftPoint]];
    //            NSLog(@"start to taken leftside point");
                [self takenStep:leftPoint withDirection:4];
                isTakenPoint = YES;
            }
            [self.takenSteps removeAllObjects];
        }
    }
    if ([[self.stepOnBoard allKeys] containsObject:[NSValue valueWithCGPoint:rightPoint]]) {
        if (self.color!=[[self.stepOnBoard objectForKey:[NSValue valueWithCGPoint:rightPoint]] intValue]%2) {
            if ([self selfLibertyCalculate:rightPoint withDirection:3] ==0) {
                //记录每个提掉的子 
                //[self.stepOnBoard removeObjectForKey:[NSValue valueWithCGPoint:rightPoint]];
  //              NSLog(@"start to taken rightside point");
                [self takenStep:rightPoint withDirection:3];
                isTakenPoint = YES;
            } 
            [self.takenSteps removeAllObjects];
        }
    }
    if (!isTakenPoint) {
        self.color = 1 - self.color; //trasmit to same color
        if ([self selfLibertyCalculate:point withDirection:0]==0) {
            //记录每个提掉的子
            NSLog(@"self dead");
            [self.stepOnBoard removeObjectForKey:[NSValue valueWithCGPoint:point]];
            [self takenStep:point withDirection:0];
        }
    } 
    [self.takenSteps removeAllObjects];
}    
- (NSString *)description{
    return [NSString stringWithFormat:@"steps are followed by %@", self.stepOnBoard];
}
//up 方向一
//down 方向二
//left 方向三
//right 方向四

- (int)selfLibertyCalculate:(CGPoint) point withDirection:(int) direction{
    int liberty = 0;
    [self.takenSteps addObject:[NSValue valueWithCGPoint:point]];
    //secondly, get the 4 direction point
    CGPoint upPoint = CGPointMake(point.x, point.y-GRID_INTERVAL);
    CGPoint downPoint = CGPointMake(point.x, point.y+GRID_INTERVAL);
    CGPoint rightPoint = CGPointMake(point.x+GRID_INTERVAL, point.y);
    CGPoint leftPoint = CGPointMake(point.x-GRID_INTERVAL, point.y);
    
    //recursion part
    if(direction!=1){
        if ([[self.stepOnBoard allKeys] containsObject:[NSValue valueWithCGPoint:upPoint]] ) {
            if ((self.color!=[[self.stepOnBoard objectForKey:[NSValue valueWithCGPoint:upPoint]] intValue]%2) && (![self.takenSteps containsObject:[NSValue valueWithCGPoint:upPoint]]))  
                liberty += [self selfLibertyCalculate:upPoint withDirection:2];
        }else {
            if (upPoint.y>=TOP_MARGIN){
                liberty += 1;
   //             NSLog(@"has liberty up");
        }
            
    }
    }
    if(direction!=2){
        if ([[self.stepOnBoard allKeys] containsObject:[NSValue valueWithCGPoint:downPoint]] ) {
            if ((self.color!=[[self.stepOnBoard objectForKey:[NSValue valueWithCGPoint:downPoint]] intValue]%2) && (![self.takenSteps containsObject:[NSValue valueWithCGPoint:downPoint]])) 
                liberty += [self selfLibertyCalculate:downPoint withDirection:1];
        }else {
            if (downPoint.y<=BOTTOM_MARGIN){
                liberty += 1; 
     //           NSLog(@"has liberty down");
            }
        }
    }
    if(direction!=3){
        if ([[self.stepOnBoard allKeys] containsObject:[NSValue valueWithCGPoint:leftPoint]] ) {
            if ((self.color!=[[self.stepOnBoard objectForKey:[NSValue valueWithCGPoint:leftPoint]] intValue]%2) && (![self.takenSteps containsObject:[NSValue valueWithCGPoint:leftPoint]])) 
                liberty += [self selfLibertyCalculate:leftPoint withDirection:4];
        }else {
            if (leftPoint.x>=LEFT_MARGIN){
                liberty += 1;
    //            NSLog(@"has liberty left");
            }
        }
    }
    if(direction!=4){
        if ([[self.stepOnBoard allKeys] containsObject:[NSValue valueWithCGPoint:rightPoint]]) {
        if ((self.color!=[[self.stepOnBoard objectForKey:[NSValue valueWithCGPoint:rightPoint]] intValue]%2) && (![self.takenSteps containsObject:[NSValue valueWithCGPoint:rightPoint]])) 
            liberty += [self selfLibertyCalculate:rightPoint withDirection:3];
    }else {
            if (rightPoint.x<=RIGHT_MARGIN){
             liberty += 1;
    //        NSLog(@"has liberty right");
        }
        }
    }
    return liberty;
}

- (void)takenStep:(CGPoint)point withDirection:(int)direction{
    for (NSValue *val in self.takenSteps) {
        if([[self.stepOnBoard allKeys] containsObject:val]){
            NSLog(@"deleted step: (%i %i)", (int)([val CGPointValue].x/37),(int)([val CGPointValue].y/37)) ;
            [self.stepOnBoard removeObjectForKey:val];
        }
    }
}
    
@end
/*
- (void)takenStep:(CGPoint)point withDirection:(int)direction{
    CGPoint upPoint = CGPointMake(point.x, point.y-GRID_INTERVAL);
    CGPoint downPoint = CGPointMake(point.x, point.y+GRID_INTERVAL);
    CGPoint rightPoint = CGPointMake(point.x+GRID_INTERVAL, point.y);
    CGPoint leftPoint = CGPointMake(point.x-GRID_INTERVAL, point.y);
    //recursion part
    if ([[self.stepOnBoard allKeys] containsObject:[NSValue valueWithCGPoint:upPoint]] && (direction!=1)) {
        if (self.color==([self.movingSteps indexOfObject:[NSValue valueWithCGPoint:upPoint]]%2)){
            [self.stepOnBoard removeObjectForKey:[NSValue valueWithCGPoint:upPoint]];
            [self takenStep:upPoint withDirection:2];
        }
    }
    if ([[self.stepOnBoard allKeys] containsObject:[NSValue valueWithCGPoint:downPoint]] &&(direction!=2)) {
        if (self.color==([self.movingSteps indexOfObject:[NSValue valueWithCGPoint:downPoint]]%2)){
            [self.stepOnBoard removeObjectForKey:[NSValue valueWithCGPoint:downPoint]];
            [self takenStep:downPoint withDirection:1];
        }
    }
    if ([[self.stepOnBoard allKeys] containsObject:[NSValue valueWithCGPoint:rightPoint]] &&(direction!=4)) {
        if (self.color==([self.movingSteps indexOfObject:[NSValue valueWithCGPoint:rightPoint]]%2)){
            [self.stepOnBoard removeObjectForKey:[NSValue valueWithCGPoint:rightPoint]];
            [self takenStep:rightPoint withDirection:3];
        }
    }
    if ([[self.stepOnBoard allKeys] containsObject:[NSValue valueWithCGPoint:leftPoint]] &&(direction!=3)) {
        if (self.color==([self.movingSteps indexOfObject:[NSValue valueWithCGPoint:leftPoint]]%2)){
            [self.stepOnBoard removeObjectForKey:[NSValue valueWithCGPoint:leftPoint]];
            [self takenStep:leftPoint withDirection:4];
        }
    }
}
*/
    

