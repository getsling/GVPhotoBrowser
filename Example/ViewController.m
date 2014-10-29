//
//  ViewController.m
//  Example
//
//  Created by Kevin Renskers on 09-06-13.
//  Copyright (c) 2013 Gangverk. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import "ViewController.h"

@implementation ViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

#pragma mark - GVPhotoBrowserDataSource

- (NSUInteger)numberOfPhotosInPhotoBrowser:(GVPhotoBrowser *)photoBrowser {
    return 5;
}

- (UIImageView *)photoBrowser:(GVPhotoBrowser *)photoBrowser customizeImageView:(UIImageView *)imageView forIndex:(NSUInteger)index {
    NSArray *letters = @[ @"a", @"b", @"c", @"d", @"e" ];
    NSString *color = [@"" stringByPaddingToLength:6 withString:letters[index] startingAtIndex:0];

    NSString *urlString = [NSString stringWithFormat:@"http://placehold.it/350x500/%@/ffffff&text=%lu", color, (unsigned long)index+1];
    [imageView sd_setImageWithURL:[NSURL URLWithString:urlString]];
    return imageView;
}

#pragma mark - GVPhotoBrowserDelegate

- (void)photoBrowser:(GVPhotoBrowser *)photoBrowser didSwitchToIndex:(NSUInteger)index {
    NSLog(@"didSwitchToIndex: %lu", (unsigned long)index);
}

@end
