//
//  ViewController2.m
//  Example
//
//  Created by Kevin Renskers on 02/09/13.
//  Copyright (c) 2013 Gangverk. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import "ViewController2.h"
#import "GVPhotoBrowser.h"

@interface ViewController2 () <GVPhotoBrowserDataSource, GVPhotoBrowserDelegate>
@property (weak, nonatomic) IBOutlet GVPhotoBrowser *photoBrowser;
@end


@implementation ViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    self.photoBrowser.currentIndex = 2;
}

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

    NSString *urlString = [NSString stringWithFormat:@"https://placehold.it/350x500/%@/ffffff&text=%lu", color, (unsigned long)index+1];
    [imageView sd_setImageWithURL:[NSURL URLWithString:urlString]];
    return imageView;
}

#pragma mark - GVPhotoBrowserDelegate

- (void)photoBrowser:(GVPhotoBrowser *)photoBrowser didSwitchToIndex:(NSUInteger)index {
    NSLog(@"didSwitchToIndex: %lu", (unsigned long)index);
}

@end
