//
//  DiagramOverviewViewController.h
//  VinoCharts
//
//  Created by Hendy Chua on 8/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

/*
 This is subclass of TileViewController. Refer to TileViewController’s documentation for details on what it does.
 This class implements its own initializing method:
 -(id)initWithModel:(Diagram*)diag Delegate:(id)d
 
 It also overrides the following methods inherited from TileViewController:
 -(void)selectTile:(UITapGestureRecognizer*)
 -(void)deleteTile:(UITapGestureRecognizer*)
 +(UIImage*)getTileImage (to provide its own image).
 */

#import "TileViewController.h"
#import <UIKit/UIKit.h>
#import "Diagram.h"
#import "Constants.h"

@interface DiagramOverviewViewController : TileViewController

@property (nonatomic, strong) Diagram *diagram;

-(id)initWithModel:(Diagram*)diag Delegate:(id)d;
// Requires: Diagram, delegate non-nil
// Effects: initialise a Diagram tile view with this Diagram

@end
