//
//  GVPhotoBrowserViewController.m
//  Example
//
//  Created by Kevin Renskers on 09-06-13.
//  Copyright (c) 2013 Gangverk. All rights reserved.
//

#import "GVPhotoBrowserViewController.h"

@implementation GVPhotoBrowserViewController

- (GVPhotoBrowser *)photoBrowser {
    if (!_photoBrowser) {
        _photoBrowser = [[GVPhotoBrowser alloc] initWithFrame:self.view.bounds];
        _photoBrowser.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _photoBrowser.delegate = self;
        _photoBrowser.dataSource = self;
    }
    return _photoBrowser;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
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
