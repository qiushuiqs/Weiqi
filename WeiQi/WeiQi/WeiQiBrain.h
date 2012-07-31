//
//  WeiQiBrain.h
//  WeiQi
//
//  Created by Mark Xiong on 7/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeiQiBrain : NSObject

@property (readonly)id stepRecords;  //dictionary of CGPoints

- (void)pushStep:(CGPoint)step withCount:(int)countOfsteps;//落子
- (void)removeLastStep; //悔棋
@end
