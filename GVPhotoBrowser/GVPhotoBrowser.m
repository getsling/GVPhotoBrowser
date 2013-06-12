//
//  GVPhotoBrowser.m
//  Example
//
//  Created by Kevin Renskers on 09-06-13.
//  Copyright (c) 2013 Gangverk. All rights reserved.
//

#import "GVPhotoBrowser.h"


// ScrollViewDelegate explanation
// ------------------------------
// UIScrollView already has its own delegate property, yet we're creating
// a NEW property with the same name. This is perfectly legal since
// GVPhotoBrowserDelegate is also a UIScrollViewDelegate.
//
// Any GVPhotoBrowserViewController subclass can now set our delegate
// property to be itself, and we will call the subclass just fine.
// However, we also need to get UIScrollViewDelegate messages about
// scrolling, so we can load new images. This isn't possible, because
// the scrollview's delegate property is now set to be the
// GVPhotoBrowserViewController subclass instead of us (itself).
//
// The solution: a new delegate class that forwards all UIScrollViewDelegate
// stuff to the GVPhotoBrowserViewController subclass, while also informing
// us of anythign we need to know. The magic happens by overriding the
// getter and setter for the delegate property, together with the line
// [super setDelegate:self.internalDelegate], directly setting the SUPER's
// delegate to the custom delegate class.
//
// The implementation of the ScrollViewDelegate class can be found
// after the GVPhotoBrowser implementation.
//
// Idea taken from http://stackoverflow.com/a/9986842/403425


@interface ScrollViewDelegate : NSObject <UIScrollViewDelegate>
@property (weak, nonatomic) id <GVPhotoBrowserDelegate> photoBrowserDelegate;
@end



@interface GVPhotoBrowser () <UIScrollViewDelegate>
@property (strong, nonatomic) ScrollViewDelegate *internalDelegate;
@property (strong, nonatomic) NSMutableArray *imageViews;
@property (nonatomic) NSNumber *numberOfPhotos;
@property (nonatomic) BOOL rotationInProgress;
@end


@implementation GVPhotoBrowser

#pragma mark - Delegate handling

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self sharedInit];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self sharedInit];
    return self;
}

- (void)sharedInit {
    self.pagingEnabled = YES;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;

    self.internalDelegate = [[ScrollViewDelegate alloc] init];
    [super setDelegate:self.internalDelegate];
}

- (void)setDelegate:(id <GVPhotoBrowserDelegate>)delegate {
    self.internalDelegate.photoBrowserDelegate = delegate;

    super.delegate = nil;
    super.delegate = (id)self.internalDelegate;
}

- (id <GVPhotoBrowserDelegate>)delegate {
    return self.internalDelegate.photoBrowserDelegate;
}

#pragma mark - View Lifecycle

- (void)awakeFromNib {
    [super awakeFromNib];
    if (self.dataSource) {
        [self start];
    }
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    if (self.dataSource) {
        [self start];
    }
}

- (void)start {
    self.imageViews = nil;
    [self sizeScrollView];

    // Loads the first 2 photos and informs the delegate
    _currentIndex = -1; // needed otherwise `setcurrentIndex:andScroll:` won't do anything
    [self setCurrentIndex:0 andScroll:NO];

    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleMemoryWarning)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(statusBarOrientationWillChangeNotification:)
                                                 name:UIApplicationWillChangeStatusBarOrientationNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChangedNotification:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)dealloc {
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

#pragma mark - Private

- (NSNumber *)numberOfPhotos {
    if (!_numberOfPhotos) {
        _numberOfPhotos = @( [self.dataSource numberOfPhotosInPhotoBrowser:self] );
    }
    return _numberOfPhotos;
}

- (NSMutableArray *)imageViews {
    if (!_imageViews) {
        // The views are lazily loaded. Initialize with NSNull.
        NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:[self.numberOfPhotos integerValue]];

        for (int i=0; i < [self.numberOfPhotos integerValue]; i++) {
            [tempArray addObject:[NSNull null]];
        }

        _imageViews = tempArray;
    }
    return _imageViews;
}

- (void)sizeScrollView {
    self.contentSize = CGSizeMake(self.frame.size.width * [self.numberOfPhotos integerValue], self.frame.size.height);
    self.contentOffset = CGPointMake(self.currentIndex * self.frame.size.width, 0);
}

- (void)layoutPages {
    // Move all visible pages to their places, because otherwise they may overlap
    UIImageView *controller;
    for (NSUInteger pageIndex = 0; pageIndex < [self.numberOfPhotos integerValue]; ++pageIndex) {
        controller = [self.imageViews objectAtIndex:pageIndex];

        if ((NSNull *)controller != [NSNull null]) {
            [self layoutPhotoAtIndex:pageIndex];
        }
    }
}

- (UIImageView *)imageView {
    if ([self.dataSource respondsToSelector:@selector(baseImageViewForPhotoBrowser:)]) {
        return [self.dataSource baseImageViewForPhotoBrowser:self];
    }

    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    imageView.clipsToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    return imageView;
}

- (void)loadPhotoAtIndex:(NSUInteger)index {
    if (index >= [self.numberOfPhotos integerValue]) return;
    if (![self.numberOfPhotos integerValue]) return;

    // Replace the placeholder if necessary
    UIImageView *controller = [self.imageViews objectAtIndex:index];
    if ((NSNull *)controller == [NSNull null]) {
        controller = [self.dataSource photoBrowser:self modifyImageView:[self imageView] forIndex:index];
        [self.imageViews replaceObjectAtIndex:index withObject:controller];
    }

    // Add the view to the scroll view
    if (controller.superview == nil) {
        [self addSubview:controller];
		[self layoutPhotoAtIndex:index];
    }
}

- (void)layoutPhotoAtIndex:(NSUInteger)index {
    UIImageView *controller = [self.imageViews objectAtIndex:index];

    CGRect frame = self.bounds;
    frame.origin.x = self.bounds.size.width * index;
    controller.frame = frame;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.rotationInProgress) return;

    NSInteger index = floor((self.contentOffset.x - self.frame.size.width / 2) / self.frame.size.width) + 1;
    [self setCurrentIndex:index andScroll:NO];
}

- (void)setCurrentIndex:(NSInteger)currentIndex andScroll:(BOOL)scroll {
    if (currentIndex != _currentIndex && currentIndex >= 0 && currentIndex < [self.numberOfPhotos integerValue]) {
        _currentIndex = currentIndex;

        if (scroll) {
            self.contentOffset = CGPointMake(currentIndex * self.frame.size.width, 0);
        }

        // Load the visible page and the page on either side of it
        [self loadPhotoAtIndex:currentIndex];
        [self loadPhotoAtIndex:currentIndex + 1];
        [self loadPhotoAtIndex:currentIndex - 1];

        // Notify delegate
        if (self.delegate && [self.delegate respondsToSelector:@selector(photoBrowser:didSwitchToIndex:)]) {
            [self.delegate photoBrowser:self didSwitchToIndex:currentIndex];
        }
    }
}

#pragma mark - Notification handlers

- (void)statusBarOrientationWillChangeNotification:(NSNotification *)notification {
    self.rotationInProgress = YES;

    // Hide all pages except the current one, because pages may overlap during animation
    UIImageView *controller;
    for (NSUInteger pageIndex = 0; pageIndex < [self.numberOfPhotos integerValue]; ++pageIndex) {
        controller = [self.imageViews objectAtIndex:pageIndex];

        if ((NSNull *)controller != [NSNull null]) {
            controller.hidden = (pageIndex != self.currentIndex);
        }
    }
}

- (void)orientationChangedNotification:(NSNotification *)notification {
    [self sizeScrollView];
    [self layoutPages];

    // Unhide all pages
    UIImageView *controller;
    for (NSUInteger pageIndex = 0; pageIndex < [self.numberOfPhotos integerValue]; ++pageIndex) {
        controller = [self.imageViews objectAtIndex:pageIndex];

        if ((NSNull *)controller != [NSNull null]) {
            controller.hidden = NO;
        }
    }

    self.rotationInProgress = NO;
}

- (void)handleMemoryWarning {
	// Unload non-visible pages in case the memory is scarse
	if ([self.imageViews count]) {
		UIImageView *controller;
		for (NSUInteger pageIndex = 0; pageIndex < self.imageViews.count; ++pageIndex) {
			if (pageIndex < self.currentIndex-1 || pageIndex > self.currentIndex+1) {
				controller = [self.imageViews objectAtIndex:pageIndex];
				if ((NSNull *)controller != [NSNull null]) {
					[controller removeFromSuperview];
					[self.imageViews replaceObjectAtIndex:pageIndex withObject:[NSNull null]];
				}
			}
		}
	}
}

#pragma mark - Public

- (void)setCurrentIndex:(NSInteger)currentIndex {
    [self setCurrentIndex:currentIndex andScroll:YES];
}

@end



@implementation ScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [(GVPhotoBrowser *)scrollView scrollViewDidScroll:scrollView];
    if ([self.photoBrowserDelegate respondsToSelector:_cmd]) {
        [self.photoBrowserDelegate scrollViewDidScroll:scrollView];
    }
}

- (BOOL)respondsToSelector:(SEL)selector {
    return [self.photoBrowserDelegate respondsToSelector:selector] || [super respondsToSelector:selector];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    [invocation invokeWithTarget:self.photoBrowserDelegate];
}

@end
