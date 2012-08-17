//
//  CalculatorProgramTableViewController.h
//  Calculater
//
//  Created by Mark Xiong on 7/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CalculatorProgramTableViewController;

@protocol CalculatorProgramTableViewControllerDelegate <NSObject>
@optional
-(void) displayProgramFromFavorite:(CalculatorProgramTableViewController *) sender usingProgram:(id)program; 
-(void)calculatorProgramsTableViewController:(CalculatorProgramTableViewController *)sender
                               deletedProgram:(id)program; // added after lecture to support deleting from table
@end


@interface CalculatorProgramTableViewController : UITableViewController

@property (nonatomic,strong) NSArray *programs;  //of CalculatorBrain programs
@property (nonatomic, weak) id <CalculatorProgramTableViewControllerDelegate> delegate;

@end
