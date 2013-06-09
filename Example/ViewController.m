//
//  ViewController.m
//  Example
//
//  Created by Kevin Renskers on 09-06-13.
//  Copyright (c) 2013 Gangverk. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

#pragma mark - GVPhotoBrowserDataSource

- (NSUInteger)numberOfPhotosInPhotoBrowser:(GVPhotoBrowser *)photoBrowser {
    return 5;
}

- (UIImageView *)photoBrowser:(GVPhotoBrowser *)photoBrowser imageViewForIndex:(NSUInteger)index {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    imageView.clipsToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    return imageView;
}

#pragma mark - GVPhotoBrowserDelegate

- (void)photoBrowser:(GVPhotoBrowser *)photoBrowser didSwitchToIndex:(NSUInteger)index {
    self.title = [NSString stringWithFormat:@"%i of %i", index, 5];
}

@end
