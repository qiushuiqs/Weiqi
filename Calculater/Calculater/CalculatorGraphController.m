//
//  CalculatorGraphController.m
//  Calculater
//
//  Created by Mark Xiong on 7/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorGraphController.h"
#import "GraphView.h"
#import "CalculatorBrain.h"
#import "CalculatorProgramTableViewController.h"

@interface CalculatorGraphController () <GraphDelegate,CalculatorProgramTableViewControllerDelegate>  

@property (nonatomic, weak) IBOutlet GraphView *graphView;
@property (nonatomic, weak) IBOutlet UIToolbar *toolBar;    //be outlet

@end

@implementation CalculatorGraphController

@synthesize program = _program;
@synthesize graphView = _graphView;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;
@synthesize toolBar = _toolBar;
#define FAVORITES_KEY @"CalculatorGraphController.Favorite"

-(void) setProgram:(id)program{
    _program = [program copy];
    [self.graphView setNeedsDisplay];
}

//deal with the bar button
-(void)handleSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem{
    
    NSMutableArray *toolbarItems = [self.toolBar.items mutableCopy]; //make mutable copy because self.toorBar is a week point.
    if(_splitViewBarButtonItem) [toolbarItems removeObject:_splitViewBarButtonItem];
    if(splitViewBarButtonItem) [toolbarItems addObject:splitViewBarButtonItem];
    self.toolBar.items = toolbarItems;
    _splitViewBarButtonItem = splitViewBarButtonItem;
}
-(void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem{
    if(_splitViewBarButtonItem != splitViewBarButtonItem){
          [self handleSplitViewBarButtonItem:splitViewBarButtonItem];
    }
    
}
-(void)viewDidLoad
{
    [super viewDidLoad];
    [self handleSplitViewBarButtonItem:self.splitViewBarButtonItem];
}

- (void)setGraphView:(GraphView *)graphView
{
    _graphView = graphView;
    [self.graphView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pinch:)]];
    [self.graphView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pan:)]];
    [self.graphView addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(tap:)]];
    [self.graphView setDelegate:self];     //controller itself accept the delegate
}


//add to favorite function
- (IBAction)addToFavorite:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *favorites = [[defaults objectForKey:FAVORITES_KEY] mutableCopy];
    if (!favorites) favorites = [NSMutableArray array];
    [favorites addObject:self.program];
    [defaults setObject:favorites forKey:FAVORITES_KEY];
    [defaults synchronize];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"Show Favorite Program"]){
        NSArray * programs = [[NSUserDefaults standardUserDefaults] objectForKey:FAVORITES_KEY];
        [segue.destinationViewController setPrograms:programs];
        [segue.destinationViewController setDelegate:self];
    }
}

//implement delegate method from delegator --> CalculatorProgramTVC
-(void) displayProgramFromFavorite:(CalculatorProgramTableViewController *) sender usingProgram:(id)program{
    self.program = program;
    [self.navigationController popViewControllerAnimated:YES];
}

//implement the method of NSDefault methods
-(void)saveToUserPointDefaults:(NSArray*) originSettings{

    NSUserDefaults  *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (standardUserDefaults){ 
        [standardUserDefaults setObject:originSettings forKey:@"PrefsPoint"]; 
        [standardUserDefaults synchronize]; 
    } 
}
-(void)saveToUserScaleDefaults:(float) scaleSettings{
    NSUserDefaults  *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (standardUserDefaults){ 
        [standardUserDefaults setObject:[NSNumber numberWithFloat: scaleSettings] forKey:@"PrefsScale"]; 
        [standardUserDefaults synchronize]; 
    } 
}
-(NSArray *) retrievePointFromUserDefaults{
    NSUserDefaults  *standardUserDefaults = [NSUserDefaults standardUserDefaults];    
    if (standardUserDefaults){
        return [standardUserDefaults objectForKey:@"PrefsPoint"];
    }else 
        return nil;
}
-(float) retrieveScaleFromUserDefaults{
    NSUserDefaults  *standardUserDefaults = [NSUserDefaults standardUserDefaults];    
    if (standardUserDefaults){
        return [[standardUserDefaults objectForKey:@"PrefsScale"] floatValue];
    }else 
    return 1.0;
}



-(double) getYfromController:(double)sender{
    NSDictionary * varible = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:sender],@"x", nil];
  //  NSLog(@"y value: %g", [CalculatorBrain runProgram:self.program usingVariableValues:varible]);
    return [CalculatorBrain runProgram:self.program usingVariableValues:varible];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
