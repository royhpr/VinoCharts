//
//  FeedbackOverviewViewController.h
//  VinoCharts
//
//  Created by Hendy Chua on 8/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

/*
 This is subclass of TileViewController. Refer to TileViewController’s documentation for details on what it does.
 This class implements its own initializing method:
 -(id)initWithModel:(Feedback*)f Delegate:(id)d
 
 It also overrides the following methods inherited from TileViewController:
 -(void)selectTile:(UITapGestureRecognizer*)
 -(void)deleteTile:(UITapGestureRecognizer*)
 +(UIImage*)getTileImage (to provide its own image).
 */

#import "TileViewController.h"
#import <UIKit/UIKit.h>
#import "Feedback.h"
#import "Constants.h"

@interface FeedbackOverviewViewController : TileViewController

@property (nonatomic, strong) Feedback *feedback;

-(id)initWithModel:(Feedback*)f Delegate:(id)d;
// Requires: Feedback, delegate non-nil
// Effects: initialise a Feedback tile view with this Feedback

@end
