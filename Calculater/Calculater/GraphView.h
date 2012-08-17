//
//  GraphView.h
//  Calculater
//
//  Created by Mark Xiong on 7/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GraphDelegate <NSObject>

-(double) getYfromController:(double)sender;

//make the scale and origin be defaults
-(NSArray *) retrievePointFromUserDefaults;
-(float) retrieveScaleFromUserDefaults;
-(void)saveToUserPointDefaults:(NSArray*) originSettings;
-(void)saveToUserScaleDefaults:(float) scaleSettings;  

@end

@interface GraphView : UIView

@property (nonatomic) CGFloat scale;
@property (nonatomic) CGPoint origin;
@property (nonatomic,weak) IBOutlet id<GraphDelegate> delegate;

//gestures: zoom in/out , draging picture , tap 3 times to indicate centre.
-(void)pinch:(UIPinchGestureRecognizer *)gesture; 
-(void)pan:(UIPanGestureRecognizer *)gesture;
-(void)tap:(UITapGestureRecognizer *)gesture;

@end
