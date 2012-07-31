//
//  WeiQiViewController.m
//  WeiQi
//
//  Created by Mark Xiong on 7/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WeiQiViewController.h"
#import "BoardView.h"
#import "WeiQiBrain.h"

@interface WeiQiViewController () <BoardViewDelegate>
@property (nonatomic,weak) IBOutlet BoardView* boardView;
@property (nonatomic,strong) WeiQiBrain* brain;
@property (nonatomic) int countOfStep;
@end

@implementation WeiQiViewController
@synthesize boardView = _boardView;
@synthesize brain = _brain;
@synthesize countOfStep = _countOfStep;

- (void)setBoardView:(BoardView *)boardView{
     if(_boardView != boardView)
         _boardView = boardView;
    
    self.boardView.datasourse = self;
}

- (WeiQiBrain*)brain{
    if (!_brain) {
        _brain = [[WeiQiBrain alloc] init];
    }
    return _brain;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
     NSLog(@"how many subviews in boardview %i", self.boardView.subviews.count);
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.countOfStep = 0;
    // Release any retained subviews of the main view.
}

#define GRID_INTERVAL 37.0

- (IBAction)tapMove:(UITapGestureRecognizer *)sender {
    [self.boardView setNeedsDisplay];
    self.countOfStep++;
    //manipulate the point to make sure it signed at right place at board
    CGPoint start = CGPointMake((self.boardView.bounds.size.width-((GRID_INTERVAL)*18))/2, (self.boardView.bounds.size.height-((GRID_INTERVAL)*18))/2);
    CGPoint point = [sender locationInView:self.boardView];
    int x = 0.5 + (point.x - start.x)/GRID_INTERVAL;
    int y = 0.5 + (point.y - start.y)/GRID_INTERVAL;
    if ((x<19) && (y<19)) {
        CGPoint step = CGPointMake(start.x+x*GRID_INTERVAL, start.y+y*GRID_INTERVAL);
        [self.brain pushStep:step withCount:self.countOfStep];
    }    
}

- (NSDictionary*)movingStepFetching:(BoardView *)boardView{
    return [self.brain.stepRecords copy];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
   return  UIInterfaceOrientationIsLandscape(interfaceOrientation);

}

@end
