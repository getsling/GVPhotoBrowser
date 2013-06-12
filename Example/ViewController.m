//
//  ViewController.m
//  Example
//
//  Created by Kevin Renskers on 09-06-13.
//  Copyright (c) 2013 Gangverk. All rights reserved.
//

#import "ViewController.h"
#import "UIImageView+WebCache.h"

@implementation ViewController

#pragma mark - GVPhotoBrowserDataSource

- (NSUInteger)numberOfPhotosInPhotoBrowser:(GVPhotoBrowser *)photoBrowser {
    return 5;
}

- (UIImageView *)photoBrowser:(GVPhotoBrowser *)photoBrowser modifyImageView:(UIImageView *)imageView forIndex:(NSUInteger)index {
    NSArray *letters = @[ @"a", @"b", @"c", @"d", @"e" ];
    NSString *color = [@"" stringByPaddingToLength:6 withString:letters[index] startingAtIndex:0];

    NSString *urlString = [NSString stringWithFormat:@"http://placehold.it/350x500/%@/ffffff&text=%i", color, index+1];
    [imageView setImageWithURL:[NSURL URLWithString:urlString]];
    return imageView;
}

#pragma mark - GVPhotoBrowserDelegate

- (void)photoBrowser:(GVPhotoBrowser *)photoBrowser didSwitchToIndex:(NSUInteger)index {
    self.title = [NSString stringWithFormat:@"%i of %i", index+1, 5];
}

@end
