//
//  GVPhotoBrowser.h
//  Example
//
//  Created by Kevin Renskers on 09-06-13.
//  Copyright (c) 2013 Gangverk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GVPhotoBrowser;


@protocol GVPhotoBrowserDataSource <NSObject>
@required
- (NSUInteger)numberOfPhotosInPhotoBrowser:(GVPhotoBrowser *)photoBrowser;
- (UIImageView *)photoBrowser:(GVPhotoBrowser *)photoBrowser imageViewForIndex:(NSUInteger)index;
@end


@protocol GVPhotoBrowserDelegate <NSObject, UIScrollViewDelegate, UIScrollViewDelegate>
@optional
- (void)photoBrowser:(GVPhotoBrowser *)photoBrowser didSwitchToIndex:(NSUInteger)index;
@end


@interface GVPhotoBrowser : UIScrollView

@property (weak, nonatomic) IBOutlet id <GVPhotoBrowserDataSource> dataSource;
@property (weak, nonatomic) IBOutlet id <GVPhotoBrowserDelegate> delegate;
@property (nonatomic) NSUInteger currentIndex;

- (void)reloadImageViews;
- (void)reloadImageViewAtIndex:(NSUInteger)index;

@end
