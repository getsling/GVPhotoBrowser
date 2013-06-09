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


@interface ScrollViewDelegate : NSObject <UIScrollViewDelegate>
@property (strong, nonatomic) id <GVPhotoBrowserDelegate> photoBrowserDelegate;
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
    [self initInternalDelegate];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self initInternalDelegate];
    return self;
}

- (void)initInternalDelegate {
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

- (void)didMoveToSuperview {
    [super didMoveToSuperview];

    self.pagingEnabled = YES;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;

    self.imageViews = nil;
    [self sizeScrollView];

    self.currentIndex = 0;

    [self loadPhotoAtIndex:0];
    [self loadPhotoAtIndex:1];
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
}

//- (void)layoutPages {
//    // Move all visible pages to their places, because otherwise they may overlap
//    UIImageView *controller;
//    for (NSUInteger pageIndex = 0; pageIndex < self.imageViews.count; ++pageIndex) {
//        controller = [self.imageViews objectAtIndex:pageIndex];
//
//        if ((NSNull *)controller != [NSNull null]) {
//            [self layoutPhotoAtIndex:pageIndex];
//        }
//    }
//}

- (void)loadPhotoAtIndex:(NSUInteger)index {
    if (index >= self.imageViews.count) return;
    if (!self.imageViews.count) return;

    // Replace the placeholder if necessary
    UIImageView *controller = [self.imageViews objectAtIndex:index];
    if ((NSNull *)controller == [NSNull null]) {
        controller = [self.dataSource photoBrowser:self imageViewForIndex:index];
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

    CGRect frame = self.frame;
    frame.origin.x = self.frame.size.width * index;

    controller.frame = frame;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.rotationInProgress) return;

    // Forward deletate call
    [self.delegate scrollViewDidScroll:self];

    NSInteger index = floor((self.contentOffset.x - self.frame.size.width / 2) / self.frame.size.width) + 1;

    if (index != self.currentIndex) {
        // Load the visible page and the page on either side of it
        [self loadPhotoAtIndex:index];
        [self loadPhotoAtIndex:index + 1];
        [self loadPhotoAtIndex:index - 1];

        // Notify delegate
        if (self.delegate && [self.delegate respondsToSelector:@selector(photoBrowser:didSwitchToIndex:)]) {
            [self.delegate photoBrowser:self didSwitchToIndex:index];
        }
    }
}

#pragma mark - Public

- (void)setCurrentIndex:(NSUInteger)currentIndex {
    if (currentIndex != _currentIndex) {
        _currentIndex = currentIndex;
        self.contentOffset = CGPointMake(currentIndex * self.frame.size.width, 0);
        [self loadPhotoAtIndex:currentIndex];
    }
}

- (void)reloadImageViews {
    for (int i=0; i < [self.numberOfPhotos integerValue]; i++) {
        [self reloadImageViewAtIndex:i];
    }
}

- (void)reloadImageViewAtIndex:(NSUInteger)index {
    UIImageView *controller = [self.dataSource photoBrowser:self imageViewForIndex:index];
    [self.imageViews replaceObjectAtIndex:index withObject:controller];
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
