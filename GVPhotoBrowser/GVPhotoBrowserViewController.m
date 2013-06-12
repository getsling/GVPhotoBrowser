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

    self.photoBrowser = [[GVPhotoBrowser alloc] initWithFrame:self.view.bounds];
    self.photoBrowser.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.photoBrowser.delegate = self;
    self.photoBrowser.dataSource = self;

    [self.view addSubview:self.photoBrowser];
}

#pragma mark - GVPhotoBrowserDataSource

- (NSUInteger)numberOfPhotosInPhotoBrowser:(GVPhotoBrowser *)photoBrowser {
    // To be implemented by subclasses
    return 0;
}

- (UIImageView *)photoBrowser:(GVPhotoBrowser *)photoBrowser customizeImageView:(UIImageView *)imageView forIndex:(NSUInteger)index {
    // To be implemented by subclasses
    return nil;
}

@end
