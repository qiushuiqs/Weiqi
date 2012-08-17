//
//  PlaceOfPopularFlickrTVC.m
//  PopularFlickr
//
//  Created by Mark Xiong on 8/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlaceOfPopularFlickrTVC.h"
#import "FlickrFetcher.h"

@interface PlaceOfPopularFlickrTVC ()

@property (nonatomic,strong)NSArray *topPlace;
@property (nonatomic,strong)NSMutableArray *topCountries;
@end

@implementation PlaceOfPopularFlickrTVC
@synthesize topPlace = _topPlace;
@synthesize topCountries = _topCountries;

- (void)setTopPlace:(NSArray *)topPlace{
    if (topPlace != _topPlace) {
        _topPlace = topPlace;
    }
}

- (void)setTopCountries:(NSArray *)topPlace{
    _topCountries = [NSMutableArray array];
    NSMutableArray *countryName = [NSMutableArray array];
    for (NSDictionary* dict in topPlace) {
        NSArray *tokens = [[dict objectForKey:FLICKR_PLACE_NAME] componentsSeparatedByString:@","];
        if (![countryName containsObject:[tokens lastObject]]) {
            [countryName addObject:[tokens lastObject]];
            NSMutableArray *countries = [NSMutableArray arrayWithObject:dict];
            [_topCountries addObject:countries];
        }else {
            [[_topCountries objectAtIndex:[countryName indexOfObject:[tokens lastObject]]] addObject:dict];
        }
    }
//    _topCountries = [[_topCountries sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] copy];
}

- (void)fetchTopPlace{
    dispatch_queue_t topPlaceQueue = dispatch_queue_create("TopPlace Download", NULL);
    dispatch_async(topPlaceQueue, ^{
        NSArray *places = [FlickrFetcher topPlaces];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.topPlace = places;
            [self setTopCountries:[places copy]];
            [self.tableView reloadData];
            self.title = [NSString stringWithFormat:@"%i places", places.count];
       });
    });
    dispatch_release(topPlaceQueue);
    for (NSDictionary* dict in self.topPlace) {
        NSLog(@"name:  %@", [dict objectForKey:FLICKR_PLACE_NAME]);
   }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self fetchTopPlace];
    // Uncomment the following line to preserve selection between presentations.
     self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
     self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSArray *) seperateArrayByComma:(NSString *)string{
    return [string componentsSeparatedByString:@","];
}

- (NSArray *) placesForSection:(NSInteger)section{
    return [self.topCountries objectAtIndex:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.topCountries.count;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [[self seperateArrayByComma:[[[self placesForSection:section] lastObject] objectForKey:FLICKR_PLACE_NAME]] lastObject];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [[self placesForSection:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Place Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    NSString *placeName = [[[self placesForSection:indexPath.section] objectAtIndex:indexPath.row] objectForKey:FLICKR_PLACE_NAME];

    //NSLog(@"%@",placeName);
    cell.textLabel.text = [[self seperateArrayByComma:placeName] objectAtIndex:0];
    cell.detailTextLabel.text = [[self seperateArrayByComma:placeName] objectAtIndex:1];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    NSDictionary *place = [[self placesForSection:indexPath.section] objectAtIndex:indexPath.row];;
    if ([segue.destinationViewController respondsToSelector:@selector(setPlace:)]) {
        [segue.destinationViewController performSelector:@selector(setPlace:) withObject:place];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
