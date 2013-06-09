# GVPhotoBrowser
A reusable photo browser for iOS using the datasource and delegate patterns.


## Features
GVPhotoBrowser is extremely flexible. Where other photo browsers expect an array of `UIImage` objects `NSURL`'s, GVPhotoBrowser instead uses the datasource pattern and will ask you to provide it with a `UIImageView` for every image. It's very similar to `UITableView`.

GVPhotoBrowser consists of `GVPhotoBrowser`, a `UIScrollView` subclass to be used directly in your own view controllers; and `GVPhotoBrowserViewController` which you can subclass, and which will take care of creating the `GVPhotoBrowser` with the correct frame and auto resizing masks, and the delegate and datasource set to itself. Again, very similar to `UITableView` and `UITableViewController`.

It does not come with title or `UIPageControl` handling. Adding a page control is easily done in your view controller, use the delegate to set the current page. And if you want to show titles or captions, this can be done by customizing the `UIImageView` that your datasource returns. These design decisions are what make GVPhotoBrowser so flexible.


## Example
An example of using the photo browser to load remote images using [SDWebImage](https://github.com/rs/SDWebImage).

```objective-c
@interface ViewController : GVPhotoBrowserViewController
@property (strong, nonatomic) NSArray *imageUrls;
@end
```

```objective-c
@implementation ViewController

#pragma mark - GVPhotoBrowserDataSource

- (NSUInteger)numberOfPhotosInPhotoBrowser:(GVPhotoBrowser *)photoBrowser {
    return [self.imageUrls count];
}

- (UIImageView *)photoBrowser:(GVPhotoBrowser *)photoBrowser imageViewForIndex:(NSUInteger)index {
    NSURL *url = self.imageUrls[index];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    imageView.clipsToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [imageView setImageWithURL:url];
    return imageView;
}

#pragma mark - GVPhotoBrowserDelegate

- (void)photoBrowser:(GVPhotoBrowser *)photoBrowser didSwitchToIndex:(NSUInteger)index {
    self.title = [NSString stringWithFormat:@"%i of %i", index, [self.imageUrls count]];
}
```

If you don't want to use the `GVPhotoBrowserViewController` subclass, you can just use `GVPhotoBrowser` directly.

```objective-c
@interface ViewController : UIViewController <GVPhotoBrowserDataSource, GVPhotoBrowserDelegate>
@property (weak, nonatomic) IBOutlet GVPhotoBrowser *photoBrowser;
@end
```
