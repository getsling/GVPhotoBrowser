//
//  GVPhotoBrowserViewController.m
//  Example
//
//  Created by Kevin Renskers on 09-06-13.
//  Copyright (c) 2013 Gangverk. All rights reserved.
//

#import "GVPhotoBrowserViewController.h"

@implementation GVPhotoBrowserViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.photoBrowser = [[GVPhotoBrowser alloc] initWithFrame:self.view.frame];
    self.photoBrowser.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.photoBrowser.delegate = self;
    self.photoBrowser.dataSource = self;

    [self.view addSubview:self.photoBrowser];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - GVPhotoBrowserDataSource

- (NSUInteger)numberOfPhotosInPhotoBrowser:(GVPhotoBrowser *)photoBrowser {
    // To be implemented by subclasses
    return 0;
}

- (UIImageView *)photoBrowser:(GVPhotoBrowser *)photoBrowser imageViewForIndex:(NSUInteger)index {
    // To be implemented by subclasses
    return nil;
}

#pragma mark - GVPhotoBrowserDelegate

- (void)photoBrowser:(GVPhotoBrowser *)photoBrowser didSwitchToIndex:(NSUInteger)index {
    // To be implemented by subclasses
}

@end
