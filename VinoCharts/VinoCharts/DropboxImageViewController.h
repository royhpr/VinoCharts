//
//  DropboxImageViewController.h
//  VinoCharts
//
//  Created by Ang Civics on 2/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//
/*  
 This imageViewController is used to view image downloaded from dropbox to local device
 */

#import <UIKit/UIKit.h>
#import "ScrollViewImageViewController.h"

@interface DropboxImageViewController : ScrollViewImageViewController

- (id)initWithPath:(NSString*)path;
//REQUIRES: the local path of the image file to be view exists
//EFFECTS: the view will show the corresponding image

@end
