# GVPhotoBrowser
A reusable photo browser for iOS using the datasource and delegate patterns.


## Features
GVPhotoBrowser is extremely flexibly. Where other photo browsers expect an array of UIImage objects NSURL's, GVPhotoBrowser instead uses the datasource pattern and will ask you to provide it with a UIImageView for every image. It's very similar to UITableView.

GVPhotoBrowser consists of a UIScrollView subclass to be used directly in your own view controllers, and a GVPhotoBrowserViewController which you can subclass, and which will take care of creating the GVPhotoBrowser with the correct frame and auto resizing masks. Again, very similar to UITableView and UITableViewController.


## Example
An example of using the photo browser to load remote images using [SDWebImage](https://github.com/rs/SDWebImage). In this example the GVPhotoBrowser object is loaded from a nib or storyboard via the IBOutlet.

```objective-c
@interface ViewController : UIViewController <GVPhotoBrowserDataSource, GVPhotoBrowserDelegate>
@property (weak, nonatomic) IBOutlet GVPhotoBrowser *photoBrowser;
@propery (strong, nonatomic) NSArray *imageUrls;
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