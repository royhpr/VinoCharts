//
//  EditDiagramController.h
//  vinocharts_diagrams
//
//  Created by Lee Jian Yi David on 3/24/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <quartzcore/CADisplayLink.h>
#import <dispatch/dispatch.h>
#import "Note.h"
#import "NoteM.h"
#import "Diagram.h"
#import "CanvasSettingController.h"
#import "GridView.h"

//#import "ColorViewController.h"
//#import "WEPopoverController.h"
//
//#import "UserOptionsLoadPicker.h"

#import "MinimapView.h"
#import"FramingLinesView.h"
#import "diagramTitleVC.h"
#import "EditToolBarVC.h"

@protocol EditDiagramControllerDelegate

-(void)saveANewDiagram:(Diagram*)diagram;
-(void)updateDiagram:(Diagram*)diagram;
-(NSString*)getProjectTitle;

@end


@interface EditDiagramController : UIViewController
<UIScrollViewDelegate,
UITextViewDelegate,
UIPopoverControllerDelegate,
CanvasSettingControllerDelegate,
EditToolBarVCDelegate>

/*Outlets*/
@property (weak, nonatomic) IBOutlet UIScrollView *canvasWindow;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *gridSnappingButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *unplacedNotesButton;


/*Actions*/
- (IBAction)addNewNoteButton:(id)sender;
- (IBAction)closeButton:(id)sender;
- (IBAction)resetZoomButton:(id)sender;
- (IBAction)gridSnappingButton:(id)sender;
- (IBAction)minimapButton:(id)sender;
- (IBAction)unplacedNotesButton:(id)sender;
- (IBAction)exportAsImageButton:(id)sender;


/*States*/
@property (readwrite) BOOL editingANote;
@property (readwrite) Note *noteBeingEdited;
@property (readwrite) int singlySelectedPannedNotesCount; // number of notes being panned via single touch pan gesture.
@property (readwrite) BOOL snapToGridEnabled;
@property (readwrite) BOOL minimapEnabled;
@property (readwrite) BOOL massSelectMode;


/*Properties*/
@property (readwrite, nonatomic, weak) IBOutlet id<EditDiagramControllerDelegate>delegate;
@property (readwrite) CADisplayLink *displayLink;
@property (readwrite) ChipmunkSpace *space;
@property (readwrite) NSMutableArray *placedNotesArr;
@property (readwrite) NSMutableArray *temporaryHoldingAreaForNotes;
@property (readwrite) NSMutableArray *unplacedNotesArray;
@property (readwrite) UIView *canvas;
@property (readwrite) diagramTitleVC *diagramTitleVC;
@property (readwrite) NSString* canvasColorHexValue; //TODO temporary fix. Civics wasn't able to implement saving UIColor objects.

/* Editing notes */
// Contents of note
@property (readwrite) UITextView *editNoteTextPlatform;
// Edit toolbar
@property (readwrite) EditToolBarVC* editNoteToolBar;

// Memorise canvasWindow's height. Need this when desummoning keyboarding.
@property (readwrite) double canvasWindowOrigHeight;

/* Data from another view controller's summoning of this view controller. Only used ONCE when initialising this view controller. */
// Data from ProjectDiagramsViewController ...
@property (readwrite) Diagram* requestedDiagram;
@property (readwrite) BOOL requestToLoadDiagramModel;


// Canvas Setting Controller. Popover kind.
@property (readwrite) CanvasSettingController *canvasSettingController;
@property (readwrite) UIStoryboardPopoverSegue *currentPopoverSegue;

// Grid
@property (readwrite) double stepping; //changes as zoom scale of _canvasWindow changes.
@property (readwrite) double gridLineThickness; //changes as zoom scale of _canvasWindow changes.
@property (readwrite) GridView *grid;

// Minimap
@property (readwrite) MinimapView *minimapView;

//Diagram Model
@property (readwrite) Diagram* diagramModel;

// Mass Select Notes //TODO Looks like mass select can be seperated into another class.
@property (readwrite) NSMutableArray* basketOfNotesToBeEdited;
@property (readwrite) UIView* basket;
@property (readwrite) UIView* overlayForMassSelectingNotes;
@property (readwrite) CGPoint fingerForMassSelectingNotes;


/*Gesture Recognizer Methods*/

-(void)unplacedNotePanResponse:(UIPanGestureRecognizer*)recognizer;

-(void)notePanResponse:(UIPanGestureRecognizer*)recognizer;
// EFFECTS: Executes what a note is supposed to do during panning.

-(void)noteDoubleTapResponse:(UITapGestureRecognizer*)recognizer;
// EFFECTS: Executes what a note is supposed to do when the button at the bottom left of the note is double tapped.

- (void)singleTapResponse:(UITapGestureRecognizer *)recognizer;
// EFFECTS: Executes what a single tap is supposed to do.

/*Methods*/


@end
