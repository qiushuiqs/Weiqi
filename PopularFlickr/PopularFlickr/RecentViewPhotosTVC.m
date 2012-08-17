//
//  RecentViewPhotosTVC.m
//  PopularFlickr
//
//  Created by Mark Xiong on 8/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RecentViewPhotosTVC.h"
#import "FlickrFetcher.h"
//#import "ImageViewController.h"

@interface RecentViewPhotosTVC ()

@property (nonatomic,strong)NSMutableArray *recentPhotos;

@end

@implementation RecentViewPhotosTVC
@synthesize recentPhotos = _recentPhotos;
#define RENCENTPHOTOS @"PhotoOfPlaceTVC.Recents"

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.recentPhotos = [[[NSUserDefaults standardUserDefaults] objectForKey:RENCENTPHOTOS] mutableCopy];
    [self.tableView reloadData];
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


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.recentPhotos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Recent View Photo";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    cell.textLabel.text = [[self.recentPhotos objectAtIndex:indexPath.row] objectForKey:FLICKR_PHOTO_TITLE];
    cell.detailTextLabel.text =[[self.recentPhotos objectAtIndex:indexPath.row] valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self.recentPhotos removeObjectAtIndex:indexPath.row];
        [[NSUserDefaults standardUserDefaults] setObject:self.recentPhotos forKey:RENCENTPHOTOS];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
//    else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//    }   
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


# pragma mark - Segue to ImageViewController
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSIndexPath *indexPath= [self.tableView indexPathForCell:sender]; 
    NSURL *url = [FlickrFetcher urlForPhoto:[self.recentPhotos objectAtIndex:indexPath.row] format:FlickrPhotoFormatLarge];
    if ([segue.identifier isEqualToString:@"recent view photos"]) {
       // [segue.destinationViewController setPhotoUrl:url];
        //[segue.destinationViewController setTitle:[[self.recentPhotos objectAtIndex:indexPath.row] valueForKey:FLICKR_PHOTO_TITLE]];
       // [[segue.destinationViewController imageView] becomeFirstResponder];
        [segue.destinationViewController performSelector:@selector(setPhotoUrl:) withObject:url];
    }
}

@end
