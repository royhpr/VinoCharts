//
//  ProjectOverviewViewController.h
//  VinoCharts
//
//  Created by Hendy Chua on 24/3/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

/*
 
 This is subclass of TileViewController. Refer to TileViewController’s documentation for details on what it does.
 This class implements its own initializing method:
 -(id)initWithModel:(Project*)p Delegate:(id)d
 
 It also overrides the following methods inherited from TileViewController:
 -(void)selectTile:(UITapGestureRecognizer*)
 -(void)deleteTile:(UITapGestureRecognizer*)
 +(UIImage*)getTileImage (to provide its own image).
 
*/

#import "TileViewController.h"
#import <UIKit/UIKit.h>
#import "Project.h"
#import "Constants.h"

@interface ProjectOverviewViewController : TileViewController

@property (nonatomic, strong) Project *project;

-(id)initWithModel:(Project*)p Delegate:(id)d;
// Requires: project, delegate non-nil
// Effects: initialise a project tile view with this project

@end
