//
//  CalculatorViewController.h
//  Calculater
//
//  Created by Mark Xiong on 6/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>




@interface CalculatorViewController : UIViewController <UISplitViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *display;

@property (weak, nonatomic) IBOutlet UILabel * description;

@end
