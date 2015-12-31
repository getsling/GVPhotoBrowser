//
//  GVPhotoBrowser.m
//  Example
//
//  Created by Kevin Renskers on 09-06-13.
//  Copyright (c) 2013 Gangverk. All rights reserved.
//

#import "GVPhotoBrowser.h"
#import "GVPhotoZoomScrollView.h"


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
@property (nonatomic) BOOL done;
@property (nonatomic) NSUInteger startingIndex;
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
    _currentIndex = -1; // needed so `setcurrentIndex:andScroll:` sees self.startingIndex=0 as a change
    self.pagingEnabled = YES;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;

    self.internalDelegate = [[ScrollViewDelegate alloc] init];
    [super setDelegate:self.internalDelegate];

    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    singleTap.delaysTouchesBegan = YES;
    singleTap.numberOfTapsRequired = 1;
    [self addGestureRecognizer:singleTap];

    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTap];
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)tap {
    [self performSelector:@selector(singleTapped) withObject:nil afterDelay:0.2];
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

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self start];
}

- (void)start {
    self.imageViews = nil;
    [self sizeScrollView];

    // Loads the first 2 photos and informs the delegate
    [self setCurrentIndex:self.startingIndex andScroll:YES];

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

    self.done = YES;
}

- (void)dealloc {
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

#pragma mark - Private

- (void)singleTapped {
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoBrowserSingleTapped:)]) {
        [self.delegate photoBrowserSingleTapped:self];
    }
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)tap {
    UIScrollView *scrollView = [self.imageViews objectAtIndex: _currentIndex];
    if (!scrollView) {
        return;
    }

    CGPoint touchPoint = [tap locationInView:scrollView];

    if (scrollView.zoomScale == scrollView.maximumZoomScale) {
        [scrollView setZoomScale:1.0 animated:YES];
    } else {
        [scrollView zoomToRect:CGRectMake(touchPoint.x, touchPoint.y, 1, 1) animated:YES];
    }
}

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
}

- (void)layoutPages {
    // Move all visible pages to their places, because otherwise they may overlap
    UIScrollView *controller;
    for (NSUInteger pageIndex = 0; pageIndex < [self.numberOfPhotos integerValue]; ++pageIndex) {
        controller = [self.imageViews objectAtIndex:pageIndex];

        if ((NSNull *)controller != [NSNull null]) {
            [self layoutPhotoAtIndex:pageIndex];
        }
    }
}

- (GVPhotoZoomScrollView *)createScrollViewForIndex:(NSUInteger)index {
    GVPhotoZoomScrollView *scrollView = [[GVPhotoZoomScrollView alloc] initWithFrame:self.frame];
    scrollView.delegate = self;
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    scrollView.imageView = [self createImageViewForIndex:index withFrame:scrollView.bounds];

    if ([self.dataSource respondsToSelector:@selector(photoBrowser:customizeScrollView:forIndex:)]) {
        scrollView = [self.dataSource photoBrowser:self customizeScrollView:scrollView forIndex:index];
    }

    return scrollView;
}

- (UIImageView *)createImageViewForIndex:(NSUInteger)index withFrame:(CGRect)frame {
    UIImageView *imageView;

    if ([self.dataSource respondsToSelector:@selector(baseImageViewForPhotoBrowser:withFrame:)]) {
        imageView = [self.dataSource baseImageViewForPhotoBrowser:self withFrame:frame];
    } else {
        imageView = [[UIImageView alloc] initWithFrame:frame];
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }

    imageView = [self.dataSource photoBrowser:self customizeImageView:imageView forIndex:index];

    return imageView;
}

- (void)loadPhotoAtIndex:(NSUInteger)index {
    if (index >= [self.numberOfPhotos integerValue]) return;
    if (![self.numberOfPhotos integerValue]) return;

    // Replace the placeholder if necessary
    UIScrollView *controller = [self.imageViews objectAtIndex:index];
    if ((NSNull *)controller == [NSNull null]) {
        controller = [self createScrollViewForIndex:index];
        [self.imageViews replaceObjectAtIndex:index withObject:controller];
    }

    // Add the view to the scroll view
    if (controller.superview == nil) {
        [self addSubview:controller];
		[self layoutPhotoAtIndex:index];
    }
}

- (void)layoutPhotoAtIndex:(NSUInteger)index {
    UIScrollView *controller = [self.imageViews objectAtIndex:index];

    CGRect frame = self.bounds;
    frame.origin.x = self.bounds.size.width * index;
    controller.frame = frame;
}

- (void)containerScrollViewDidScroll:(UIScrollView *)scrollView {
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
    UIScrollView *controller;
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
    UIScrollView *controller;
    for (NSUInteger pageIndex = 0; pageIndex < [self.numberOfPhotos integerValue]; ++pageIndex) {
        controller = [self.imageViews objectAtIndex:pageIndex];

        if ((NSNull *)controller != [NSNull null]) {
            controller.hidden = NO;
        }
    }

    self.rotationInProgress = NO;

	// reset the current index to force repositioning
	NSInteger oldIndex = _currentIndex;
	_currentIndex = -1;
	[self setCurrentIndex:oldIndex andScroll:YES];
}

- (void)handleMemoryWarning {
	// Unload non-visible pages in case the memory is scarse
	if ([self.imageViews count]) {
		UIScrollView *controller;
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

- (void)reloadData {
    _numberOfPhotos = nil;
    [self setNeedsDisplay];
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    if (!self.done) {
        // If you're trying to set currentIndex before the view has even been
        // loaded then change the startingIndex instead and let the start
        // method deal with it from there.
        self.startingIndex = currentIndex;
        return;
    }

    [self setCurrentIndex:currentIndex andScroll:YES];
}

#pragma mark - Per photo scroll view

- (UIView *)viewForZoomingInScrollView:(GVPhotoZoomScrollView *)scrollView {
    return scrollView.imageView;
}

- (void)scrollViewDidZoom:(GVPhotoZoomScrollView *)scrollView {
    // The scroll view has zoomed, so you need to re-center the contents
    [scrollView centerScrollViewContents];
}

@end


@implementation ScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [(GVPhotoBrowser *)scrollView containerScrollViewDidScroll:scrollView];
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
