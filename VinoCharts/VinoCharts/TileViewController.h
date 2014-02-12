//
//  TileViewController.h
//  VinoCharts
//
//  Created by Hendy Chua on 9/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

/*
 This is a superclass that helps to define the tile views users see in VinoCharts. This class implements the basically functionalities
 such as adding gesture recognizers to its image view,  adding a cross button on its image view, removing the cross button and notifying
 the delegate when a long-press gesture is detected.
 
 It also comes with a default image returned by the class method:
 
 +(UIImage*) getTileImage.
 
 There are 2 methods that must be overwritten by the subclasses:
 
 -(void)selectTile:(UITapGestureRecognizer*)
 -(void)deleteTile:(UITapGestureRecognizer*).
 
 The TileControllerDelegate has 3 compulsory and 1 optional delegate methods. They are:
 -(void)tileSelected:(id)model
 -(void)longPressActivated
 -(void)deleteTile:(id)model
 (optional)
 -(void)tileToBeEdited
 
 Classes conforming to the TileControllerDelegate must fulfil the delegated methods so that they can detect when gestures are applied to
 the tiles and take the appropriate actions.
 */

#import <UIKit/UIKit.h>

#define VIEW_STATE 0
#define DELETE_STATE 1

@protocol TileControllerDelegate <NSObject>

-(void)tileSelected:(id)model;
// Effects: tell the delegate that this tile is being selected by user, passes the model that comes with this
//          tile view into this method so delegate can manipulate if necessaryn

-(void)longPressActivated;
// Effects: notify the delegate when long press gesture is detected on this tile.

-(void)deleteTile:(id)model;
// Effects: tells the delegate that this tile is being selected by user to be deleted, passes the model in so
//          delegate knows which model to delete.

@optional
-(void)tileToBeEdited:(id)model;
// Effects: tells the delegate that this tile is being selected by user to be edited, passes the model in so
//          delegate knows which model to edit.

@end;

@interface TileViewController : UIViewController {
    id<TileControllerDelegate> delegate;
    int tileState;
}

@property (nonatomic, strong) UIImageView *tileImageView;
@property (nonatomic, strong) UIImageView *crossButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailsLabel;
@property (nonatomic) id delegate;

-(void)editSelectedTile:(UITapGestureRecognizer *)gesture;
// Should be (not compulsory) overriden by subclasses

-(void)selectTile:(UITapGestureRecognizer *)gesture;
// Must be overriden by subclasses

-(void)deleteThisTile:(UITapGestureRecognizer *)gesture;
// Must be overriden by subclasses

-(void)notifyDelegateLongPress:(UILongPressGestureRecognizer *)gesture;
// Requires: a long press gesture
// Effects: tells the delegate that longpress has been detected.

-(void)displayDeleteCrossIcon;
// Effects: Display a cross icon on the image. Also set the state to edit state. if the tile is already in edit state (i.e. cross icon
//          already shown, nothing will happen.

-(void)removeDeleteCrossIcon;
// Effects: Remove the cross icon on the image. Also set the state to view state. If its already in view state, nothing will be changed.

+(UIImage*)getTileImage;
// Effects: returns a default UIImage for tile views.

+(UIImage*)getCrossIcon;
// Effects: returns a default UIImage for the cross icon.

-(void)addTapAndLongPressGestureOnTile;
// Effects: add single tap, long press and double tap gestures on this tile.

@end
