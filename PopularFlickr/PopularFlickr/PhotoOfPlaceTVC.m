//
//  PhotoOfPlaceTVC.m
//  PopularFlickr
//
//  Created by Mark Xiong on 8/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoOfPlaceTVC.h"
#import "FlickrFetcher.h"
#import "ImageViewController.h"
@interface PhotoOfPlaceTVC ()

@property (nonatomic,strong)NSArray *photos;

@end

@implementation PhotoOfPlaceTVC
@synthesize place = _place;
@synthesize photos = _photos;
#define RENCENTPHOTOS @"PhotoOfPlaceTVC.Recents"


- (void)fetchPhotoWithPlace{
    dispatch_queue_t photosLoad = dispatch_queue_create("load photos", NULL);
    dispatch_async(photosLoad, ^{
        NSArray *array = [FlickrFetcher photosInPlace:self.place maxResults:50];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.photos = array;
            [self.tableView reloadData];
            self.title = [[NSString stringWithFormat:@"%i", self.photos.count] stringByAppendingString:@" Photos"];
        });
    });
    dispatch_release(photosLoad);
}

- (void)setPlace:(NSDictionary *)place{
    _place = place;
    [self fetchPhotoWithPlace];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!self.photos && self.place) {
        [self fetchPhotoWithPlace];
        NSLog(@"%i", self.photos.count);
        
    }
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


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.photos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Picture Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSString *titleOfPhoto = [[self.photos objectAtIndex:indexPath.row] objectForKey:FLICKR_PHOTO_TITLE];
    if ([titleOfPhoto isEqualToString:@""]) 
        titleOfPhoto = @"Unknown";
    NSString *descOfPhoto = [[self.photos objectAtIndex:indexPath.row] valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
    if ([descOfPhoto isEqualToString:@""]) 
        descOfPhoto = @"Unknown";
    cell.textLabel.text = titleOfPhoto;
    cell.detailTextLabel.text = descOfPhoto;
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    NSURL *url =  [FlickrFetcher urlForPhoto:[self.photos objectAtIndex:indexPath.row] format:FlickrPhotoFormatLarge];
    //将看过的图片放在recent array 里面。
    NSString *photoID = [[self.photos objectAtIndex:indexPath.row] objectForKey:FLICKR_PHOTO_ID];
    NSMutableArray *recentPhoto = [NSMutableArray array];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    for (NSDictionary *photo in [defaults objectForKey:RENCENTPHOTOS]) {
        if (![[photo objectForKey:FLICKR_PHOTO_ID] isEqualToString:photoID]) {
            [recentPhoto addObject:photo];
        }
    }
    [recentPhoto addObject:[self.photos objectAtIndex:indexPath.row]];
    [defaults setObject:recentPhoto forKey:RENCENTPHOTOS];
    
    if ([segue.identifier isEqualToString:@"show photo"]) {
        [segue.destinationViewController setPhotoUrl:url];
        [segue.destinationViewController setTitle:[[self.photos objectAtIndex:indexPath.row] objectForKey:FLICKR_PHOTO_TITLE]];
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
