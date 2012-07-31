//
//  BoardView.h
//  WeiQi
//
//  Created by Mark Xiong on 7/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class  BoardView;

@protocol BoardViewDelegate <NSObject>

- (NSDictionary*)movingStepFetching:(BoardView *)boardView;

@end

@interface BoardView : UIView

@property (nonatomic, strong) UIImage* imageOfBoard;
@property (nonatomic,weak) IBOutlet id <BoardViewDelegate> datasourse;

@end
