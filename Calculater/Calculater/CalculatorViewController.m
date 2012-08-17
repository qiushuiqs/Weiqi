//
//  CalculatorViewController.m
//  Calculater
//
//  Created by Mark Xiong on 6/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"
#import "CalculatorGraphController.h"
#import "SplitViewBarButtonItemPresenter.h"

@interface CalculatorViewController ()

@property (nonatomic) BOOL userInTheMiddleOfEnterANumber;
@property (nonatomic, strong) CalculatorBrain* brain; 
@end

@implementation CalculatorViewController
@synthesize display = _display;
@synthesize description = _description;
@synthesize userInTheMiddleOfEnterANumber = _userInTheMiddleOfEnterANumber;
@synthesize brain = _brain;


-(void)awakeFromNib{     // always try to be the split view's delegate
    [super awakeFromNib];
    self.splitViewController.delegate = self;   //delegate to itself through portocal
}

-(id <SplitViewBarButtonItemPresenter>)splitViewBarButtonItemPresenter{
    id detailVC = [self.splitViewController.viewControllers lastObject];
    if(![detailVC conformsToProtocol:@protocol(SplitViewBarButtonItemPresenter)]){
        detailVC = nil;
    }
    return detailVC;
}

-(BOOL)splitViewController:(UISplitViewController *)svc 
  shouldHideViewController:(UIViewController *)vc 
             inOrientation:(UIInterfaceOrientation)orientation{
    //return UIInterfaceOrientationIsPortrait(orientation);
    return [self splitViewBarButtonItemPresenter] ? UIInterfaceOrientationIsPortrait(orientation) : NO; 
}

-(void)splitViewController:(UISplitViewController *)svc 
    willHideViewController:(UIViewController *)aViewController 
         withBarButtonItem:(UIBarButtonItem *)barButtonItem 
      forPopoverController:(UIPopoverController *)pc{
    barButtonItem.title = @"Calculator";
    //tell the detail view controller to pop to put the button over
    //  [[self splitViewBarButtonItemPresenter] setSplitViewBarButtonItem:barButtonItem];
    self.splitViewBarButtonItemPresenter.splitViewBarButtonItem = barButtonItem;
}

-(void)splitViewController:(UISplitViewController *)svc 
    willShowViewController:(UIViewController *)aViewController 
 invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem{
    //tell the detail view controller to take the button away
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = nil; 
}


-(CalculatorBrain *)brain{
    if (!_brain) {
        _brain = [[CalculatorBrain alloc] init];
    }
    return  _brain;
}


- (IBAction)digitPressed:(UIButton*)sender {   //IBAction == void,  id is point to any object
    NSString *digit = [sender currentTitle];

    if (self.userInTheMiddleOfEnterANumber) {
        self.display.text = [self.display.text stringByAppendingString:digit];
    }else {
        self.display.text = digit;
        self.userInTheMiddleOfEnterANumber = YES;
    }

}


- (IBAction)operatorPressed:(UIButton*)sender {
    if (self.userInTheMiddleOfEnterANumber) {
        [self enterPressed];
    }
    double result = [self.brain performOperation:sender.currentTitle];
    NSString *resultString = [NSString stringWithFormat:@"%g", result]; //double to string
    self.display.text = resultString;
    self.description.text = [self.brain showTheDescription];
}

- (IBAction)enterPressed {
    if(!([self.display.text doubleValue]||[self.display.text isEqualToString:@"π"])){
        NSLog(@"it is a string");
        [self.brain pushVariable:self.display.text];
    
    }else{
        if([self.display.text isEqualToString:@"π"]) {
            double pi = M_PI;
            [self.brain pushOperand:pi]; 
        }
        [self.brain pushOperand:[self.display.text doubleValue]];     //string to double
    }
    
    self.description.text = [self.brain showTheDescription];
    self.userInTheMiddleOfEnterANumber = NO;
}

- (IBAction)undoPressed {
    if (self.userInTheMiddleOfEnterANumber && self.display.text.length>0) {
        self.display.text = [self.display.text substringToIndex:(self.display.text.length-1)];
    }else {
        self.description.text = [self.brain removeLastOperand];
        self.display.text =@"0";
    }

}

- (IBAction)graphPressed {
    if([self callCalculatorGraphController])
        [[self callCalculatorGraphController] setProgram:self.brain.program];   //for splitview (ipad)
    else 
        [self performSegueWithIdentifier:@"ShowDiagram" sender:self];       //for segue (iphone)
}

-(CalculatorGraphController*) callCalculatorGraphController{
    id dvc = [self.splitViewController.viewControllers lastObject];  //dvc == detail view controller
    
    if(![dvc isKindOfClass:[CalculatorGraphController class]])
        return nil; 
    else 
        return dvc;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [segue.destinationViewController setProgram:self.brain.program];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


@end
