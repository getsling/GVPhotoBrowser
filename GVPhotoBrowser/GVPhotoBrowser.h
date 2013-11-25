//
//  GVPhotoBrowser.h
//  Example
//
//  Created by Kevin Renskers on 09-06-13.
//  Copyright (c) 2013 Gangverk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GVPhotoZoomScrollView.h"

@class GVPhotoBrowser;


@protocol GVPhotoBrowserDataSource <NSObject>

@required

/**
 * How many photo's to show
 *
 * @param photoBrowser The photoBrowser asking the question
 * @return The number of photo's to show
 */
- (NSUInteger)numberOfPhotosInPhotoBrowser:(GVPhotoBrowser *)photoBrowser;

/**
 * Modify the blank imageView
 *
 * @param photoBrowser The photoBrowser asking the question
 * @param imageView An instance of UIImageView already set up with the correct content mode, auto resizing mask, etc. You have to set its image property and can can also choose to modify the imageview as you see fit (add subviews for example).
 * @param index The photo index belonging to this imageView
 * @return The modified imageView
 */
- (UIImageView *)photoBrowser:(GVPhotoBrowser *)photoBrowser customizeImageView:(UIImageView *)imageView forIndex:(NSUInteger)index;

@optional

/**
 * You can give a custom UIImageView instance to the photoBrowser:modifyImageView:forIndex: method
 *
 * @param photoBrowser The photoBrowser asking the question
 * @param frame The frame that the imageView has to frame
 * @return Your custom instance of the base UIImageView
 */
- (UIImageView *)baseImageViewForPhotoBrowser:(GVPhotoBrowser *)photoBrowser withFrame:(CGRect)frame;

/**
 * Modify the per-photo scroll view
 *
 * @param photoBrowser The photoBrowser asking the question
 * @param scrollView An instance of GVPhotoZoomScrollView that you can modify as you see fit.
 * @param index The photo index belonging to this scrollView
 * @return Your custom instance of the base GVPhotoZoomScrollView
 */
- (GVPhotoZoomScrollView *)photoBrowser:(GVPhotoBrowser *)photoBrowser customizeScrollView:(GVPhotoZoomScrollView *)scrollView forIndex:(NSUInteger)index;

@end


@protocol GVPhotoBrowserDelegate <NSObject, UIScrollViewDelegate, UIScrollViewDelegate>

@optional

/**
 * The delegate can tell you when the photobrowser switched to a new photo
 *
 * @param photoBrowser The photoBrowser telling you
 * @param index The photo index that was switched to
 */
- (void)photoBrowser:(GVPhotoBrowser *)photoBrowser didSwitchToIndex:(NSUInteger)index;

@end


@interface GVPhotoBrowser : UIScrollView

@property (weak, nonatomic) IBOutlet id <GVPhotoBrowserDataSource> dataSource;
@property (weak, nonatomic) IBOutlet id <GVPhotoBrowserDelegate> delegate;

/// Which photo to show. Changing the value will scroll to that photo.
@property (nonatomic) NSInteger currentIndex;

- (void)reloadPhotoBrowser;

@end
