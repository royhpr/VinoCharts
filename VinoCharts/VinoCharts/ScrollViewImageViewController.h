//
//  ScrollViewImageViewController.h
//  VinoCharts
//
//  Created by Ang Civics on 20/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//
/*
 This viewController consist of a scroll view with double tapped zoom in, two finger tapped zoom out, resizing gesture and auto focus
 Created after refering to http://www.raywenderlich.com/10518/how-to-use-uiscrollview-to-scroll-and-zoom-content tutorial
 Only need to init the imageView.
 */

#import <UIKit/UIKit.h>

@interface ScrollViewImageViewController : UIViewController<UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property UIImageView* imageView;

@end
