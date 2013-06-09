//
//  GVPhotoBrowserViewController.h
//  Example
//
//  Created by Kevin Renskers on 09-06-13.
//  Copyright (c) 2013 Gangverk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GVPhotoBrowser.h"

// Creates a photo browser with the correct dimensions and autoresizing,
// setting the datasource and delegate to self.

@interface GVPhotoBrowserViewController : UIViewController <GVPhotoBrowserDataSource, GVPhotoBrowserDelegate>

@property (strong, nonatomic) GVPhotoBrowser *photoBrowser;

@end
