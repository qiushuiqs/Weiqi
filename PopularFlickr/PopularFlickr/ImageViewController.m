//
//  ImageViewController.m
//  PopularFlickr
//
//  Created by Mark Xiong on 8/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation ImageViewController
@synthesize imageView = _imageView;
@synthesize scrollView = _scrollView;
@synthesize photoUrl = _photoUrl;

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView;
}

- (void)imageLoad{
    if (self.imageView) {   //if imageview has been allocated, load image to imageview
        if (self.photoUrl) {    //invalid url turn out to be nil
            dispatch_queue_t photoDownloadQueue = dispatch_queue_create("photo download", NULL);
            dispatch_async(photoDownloadQueue, ^{
                NSData *data = [NSData dataWithContentsOfURL:self.photoUrl];
                UIImage *image = [UIImage imageWithData:data];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.imageView.image = image;
                    self.scrollView.contentSize = self.imageView.image.size;
                    self.imageView.frame = CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height);
                });
            });
                        
        }else {
            self.imageView.image = nil;
        }
    }
}

- (void)setPhotoUrl:(NSURL *)photoUrl{
    if (photoUrl != _photoUrl) {
        _photoUrl = photoUrl;
        if (self.imageView.window) {    // we're on screen, so update the image
            [self imageLoad];
        }else {     // we're not on screen, so no need to loadImage (it will happen next viewWillAppear:)
            self.imageView.image = nil; // but image has changed (so we can't leave imageView.image the same, so set to nil)
        }
        
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.imageView.image && self.photoUrl) {
        [self imageLoad];
    }
}

- (void)viewDidUnload
{
    [self setImageView:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
