//
//  CalculatorGraphController.h
//  Calculater
//
//  Created by Mark Xiong on 7/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SplitViewBarButtonItemPresenter.h"

@interface CalculatorGraphController : UIViewController <SplitViewBarButtonItemPresenter>

@property (nonatomic) id program;

@end
