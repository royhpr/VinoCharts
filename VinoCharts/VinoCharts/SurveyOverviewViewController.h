//
//  SurveyOverviewViewController.h
//  VinoCharts
//
//  Created by Hendy Chua on 31/3/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

/*
 This is subclass of TileViewController. Refer to TileViewController’s documentation for details on what it does.
 This class implements its own initializing method:
 -(id)initWithModel:(Survey*)s Delegate:(id)d
 
 It also overrides the following methods inherited from TileViewController:
 -(void)selectTile:(UITapGestureRecognizer*)
 -(void)deleteTile:(UITapGestureRecognizer*)
 -(void)editSelectedTile:(UITapGestureRecognizer*)
 +(UIImage*)getTileImage (to provide its own image).

 */

#import "TileViewController.h"
#import <UIKit/UIKit.h>
#import "Survey.h"
#import "Constants.h"

@interface SurveyOverviewViewController : TileViewController


@property (nonatomic, strong) Survey *survey;

-(id)initWithModel:(Survey*)s Delegate:(id)d;
// Requires: survey, delegate non-nil
// Effects: initialise a survey tile view with this survey

@end
