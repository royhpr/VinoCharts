//
//  DisplayTilesViewController.h
//  VinoCharts
//
//  Created by Hendy Chua on 9/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

/*
 This is a superclass that helps to define the ViewController with a scroll view.
 The purpose of this class is to provide common methods and attributes for a typical ViewController that has to hold an
 undetermined amount of TileViews (e.g. Project Views, Survey Views).
 
 This class implements the following methods:
 
 -(void)fillUpTiles
 -(void)finishDeletingMode
 -(void)showDeleteButtonOnTiles

 This class populates the scroll view by reading all the models from its attribute modelsArray.
 Concrete subclasses must initialized this array when inheriting from this class.
 
 Subclasses must also override the method:
 -(void)reloadModelsArrayAndRepresentationArray.
 This method should be called whenever the view is reloaded or whenever there is a change to the models (deleting,
 editing).
 
 In addition, there are 2 other methods that subclasses must override:
 -(void)setRightBarButtonToDeletingMode
 -(void)setRightBarButtonToDefaultMode
 This is to allow subclasses the freedom to define what their own deleting and default mode appearance.
 */

#import <UIKit/UIKit.h>
#import "TileViewController.h"
#import "Constants.h"

@interface DisplayTilesViewController : UIViewController

@property (nonatomic,strong) NSMutableArray *modelsArray;
// holds all the models in this view.

@property (nonatomic,strong) NSMutableArray *modelsRepresentationArray;
// holds all the representation (tile views).

@property (strong, nonatomic) IBOutlet UIScrollView *tilesDisplayArea;

-(void)fillUpTiles;
// Effects: fills up the scroll view with 4x4 tiles. The scrollview content size will also be adjusted according
//          to how many tiles there are.

-(void)finishDeletingMode;
// Effects: When user has exited deleting mode, this method will be in charged of removing all the cross buttons on all the views.

-(void)showDeleteButtonOnTiles;
// Effects: In charge of displaying a cross button on all the views and going into deletion mode.

-(void)reloadModelsArrayAndRepresentationArray;
// Must be overridden by subclasses to reload the modelsArray.

-(void)setRightBarButtonToDeletingMode;
// Must be overridden by subclasses.

-(void)setRightBarButtonToDefaultMode;
// Must be overridden by subclasses.

@end
