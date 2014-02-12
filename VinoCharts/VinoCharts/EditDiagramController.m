//
//  EditDiagramController.m
//  vinocharts_diagrams
//
//  Created by Lee Jian Yi David on 3/24/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#define DEBUG_EDC 0

#import <math.h> // Good ol' math.h
#import <dispatch/dispatch.h> // Grand Central Dispatch

#import "EditDiagramController.h" // That's my header!

#import "PreviewDiagramViewController.h"

#import "Note.h"
#import "NoteM.h"
#import "Diagram.h"

#import "GridView.h"
#import "AlignmentLineView.h"
#import "FramingLinesView.h"
#import "MinimapView.h"
#import "diagramTitleVC.h"

#import "Constants.h"
#import "ViewHelper.h"
#import "ViewHelper+Note.h"
#import "DebugHelper.h"
#import "FontHelper.h"

//#import "ColorViewController.h"
//#import "WEPopoverController.h"
#import "CanvasSettingController.h"
//#import "UserOptionsLoadPicker.h"


// An object to use as a collision type for the screen border.
// Class objects and strings are easy and convenient to use as collision types.
static NSString *borderType = @"borderType";



@implementation EditDiagramController

@synthesize editNoteToolBar = _editNoteToolBar;
@synthesize basketOfNotesToBeEdited = _basketOfNotesToBeEdited;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES];
    
    // Set up keyboard management.
    [self setupKeyboardMgmt];
    
    // Initialise arrays of notes
    _placedNotesArr = [[NSMutableArray alloc]init];
    _temporaryHoldingAreaForNotes = [[NSMutableArray alloc]init];
    _unplacedNotesArray = [[NSMutableArray alloc]init];
    _unplacedNotesButton.title = [NSString stringWithFormat:@"%d Unplaced Notes",_unplacedNotesArray.count];
    
    // Initialise toolbar that appears when editing notes
    _editNoteToolBar = [[EditToolBarVC alloc]initForEditingSingleNotesWithToolBarName:@"single"];
    [_editNoteToolBar setDelegate:self];
    [_editNoteToolBar addToSuperView:self.view];
    [_editNoteToolBar hide];
    
    // Initialise the platform that keyboard will be tied to when editing a note's textual content.
    _editNoteTextPlatform = [[UITextView alloc]initWithFrame:CGRectMake(0, 400-100, NOTE_DEFAULT_WIDTH, 100)];
    [_editNoteTextPlatform setDelegate:self];
    
    // Initialise _canvasWindow
    [_canvasWindow setBackgroundColor:[UIColor grayColor]];
    // Zooming
    [_canvasWindow setDelegate:self];
    [_canvasWindow setMaximumZoomScale:CANVAS_WINDOW_ZOOMSCALE_MAX];
    [_canvasWindow setMinimumZoomScale:CANVAS_WINDOW_ZOOMSCALE_MIN];
    [_canvasWindow setClipsToBounds:YES];
    
    
    // Initialise _canvas
    _canvas = [[UIView alloc]initWithFrame:CGRectMake(0,
                                                      0,
                                                      CANVAS_DEFAULT_WIDTH,
                                                      CANVAS_DEFAULT_HEIGHT)];

    
    [_canvas setBackgroundColor:[UIColor whiteColor]];
    _canvasColorHexValue = White; //TODO Civics wasn't able to implement saving UIColor objects.
    [_canvasWindow addSubview:_canvas];
    
    // Center content view in _canvasWindow
    // _canvasWindow.contentSize is 0,0 now.
    [_canvasWindow setZoomScale:0.98 animated:NO];
    [_canvasWindow setZoomScale:1 animated:YES];
    // _canvasWindow.contentSize is _canvas.bounds now.
    
    //Memorise original canvasWindow height.
    _canvasWindowOrigHeight = 704;
    
    // Initialise states
    _editingANote = NO;
    _noteBeingEdited = nil;
    _snapToGridEnabled = NO;
    _minimapEnabled = NO;
    _massSelectMode = NO;
    
    // Initialise _space (Chipmunk physics space)
    _space = [[ChipmunkSpace alloc] init];
    [_space addBounds:_canvas.bounds
            thickness:1000000.0f elasticity:0.2f friction:0.8 layers:CP_ALL_LAYERS group:CP_NO_GROUP collisionType:borderType];
    [_space setGravity:cpv(0, 0)];
    [self createCollisionHandlers];

    
    // Initialise gridView moderating parameters.
    _stepping = GRID_DEFAULT_STEPPING; //changes as zoom scale of _canvasWindow changes.
    _gridLineThickness = 0.8; //changes as zoom scale of _canvasWindow changes.
    
    /* Attach gesture recognizers */
    // Single tapping on canvas window (the UIScrollView)
    UITapGestureRecognizer *singleTapRecog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapResponse:)];
    [_canvasWindow addGestureRecognizer:singleTapRecog];
    
    UILongPressGestureRecognizer* longPressRecog = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(massSelectModeEnable:)];
    [self.view addGestureRecognizer:longPressRecog];
    
    // Mass selection of notes
    _overlayForMassSelectingNotes = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 1024, 748)];
    [_overlayForMassSelectingNotes setBackgroundColor:[UIColor whiteColor]];
    [_overlayForMassSelectingNotes setAlpha:0.5];
    [self.view addSubview:_overlayForMassSelectingNotes];
    [_overlayForMassSelectingNotes setHidden:YES];
    // Drag finger around to select notes
    UIPanGestureRecognizer *panRecogMassSelectNotes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panResponseForMassSelectMode:)];
    [_overlayForMassSelectingNotes addGestureRecognizer:panRecogMassSelectNotes];
    // Single tap to quit
    UITapGestureRecognizer *singleTapRecogMassSelectNotesQuit = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(massSelectModeDisable)];
    [_overlayForMassSelectingNotes addGestureRecognizer:singleTapRecogMassSelectNotesQuit];
    // Initialise diagram model in case of saving later.
    _diagramModel = [[Diagram alloc]init];
    
    // Initialise diagram title.
    _diagramTitleVC = [[diagramTitleVC alloc]initDefaultOn:_canvas];
    
    // Load diagram model
    if (_requestToLoadDiagramModel) {
        [self loadWithDiagramModel:_requestedDiagram];
        _diagramModel = _requestedDiagram;
        _requestToLoadDiagramModel = NO;
    }
    
}


#pragma mark - Segues
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"CanvasSettingController"]) {
        _currentPopoverSegue = (UIStoryboardPopoverSegue *)segue; // Will be used in dismissing this popover.
        _canvasSettingController = [segue destinationViewController];
        [_canvasSettingController setDelegate:self]; //Set delegate. IMPORTANT!
        // Initialise popover view's information.
        NSString *currCanvasW = [NSString stringWithFormat:@"%.0f",_canvas.bounds.size.width];
        NSString *currCanvasH = [NSString stringWithFormat:@"%.0f",_canvas.bounds.size.height];
        _canvasSettingController.widthDisplay.text = currCanvasW;
        _canvasSettingController.heightDisplay.text = currCanvasH;
    }
}


#pragma mark - Canvas Settings

// CanvasSettingControllerDelegate callback function
- (void)CanvasSettingControllerDelegateOkButton:(double)newWidth :(double)newHeight{
    
    //Check if canvas dimensions have changed.
    if (_canvas.bounds.size.height != newHeight || _canvas.bounds.size.width != newWidth){
        
        //Finding the upcomingCanvasFrame.
        CGRect upcomingCanvasFrame = [ViewHelper frameOf:_canvas WithWidth:newWidth AndHeight:newHeight];
        UIView* upcomingCanvas = [[UIView alloc]initWithFrame:upcomingCanvasFrame];
        NSMutableIndexSet* indicesOfAffectedNotes = [[NSMutableIndexSet alloc]init];
        
        int strandedNotesCount = 0;
        int index = 0; //Carries the index at which the loop is at.
        
        //Test which notes would be stranded after resizing the canvas' dimensions
        for (Note* eachNote in _placedNotesArr) {
            //Check if changing dimensions will affect notes.
            if(![ViewHelper isView:eachNote.view completelyInside:upcomingCanvas]){
                ++strandedNotesCount;
                [indicesOfAffectedNotes addIndex:index];
            }
            ++index;
        }
        
        if (strandedNotesCount != 0) {
            //Pass newWidth and newHeight over to _canvasSettingController.
            //These values are needed for the calling of methods from the arbitration of the uialert
            //  in _canvasSettingController.
            _canvasSettingController.passedWidth = newWidth;
            _canvasSettingController.passedheight = newHeight;
            _canvasSettingController.passedIndicesOfAffectedNotes = indicesOfAffectedNotes;
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%d notes will be affected by a change in canvas size.",strandedNotesCount]
                                                            message:@"These notes will be placed under the button [Unplaced Notes]. Continue with resizing the canvas?"
                                                           delegate:_canvasSettingController
                                                  cancelButtonTitle:@"No"
                                                  otherButtonTitles:@"Yes", nil];
            [alert show];
        }
        else {
            [self effectNewDimsFromCanvasSettings:newWidth :newHeight];
        }
    }
    
    
    [[_currentPopoverSegue popoverController] dismissPopoverAnimated: YES]; // dismiss the popover.
}

// CanvasSettingControllerDelegate callback function
- (void)CanvasSettingControllerDelegateCancelButton{
    [_canvas setBackgroundColor:_canvasSettingController.beginningCanvasColor];
    [[_currentPopoverSegue popoverController] dismissPopoverAnimated: YES]; // dismiss the popover.
}

// CanvasSettingControllerDelegate callback function
- (void) CanvasSettingControllerDelegateTappedColor:(UIColor*)tappedColor{
    [_canvas setBackgroundColor:tappedColor];
    [_diagramTitleVC setTextColor:[ViewHelper invColorOf:_canvas.backgroundColor]];
    if (_minimapEnabled) {
        [self minimapButton:nil];[self minimapButton:nil]; //refresh minimap.
    }
    if (_snapToGridEnabled) {
        [self gridSnappingButton:nil];[self gridSnappingButton:nil]; //refresh grid
    }
}

- (void) CanvasSettingControllerDelegateTappedGZColorHexValue:(NSString*)hexValue{
    _canvasColorHexValue = hexValue;
}

// CanvasSettingControllerDelegate callback function
- (UIColor*) CanvasSettingControllerAsksForCanvasColor{
    return _canvas.backgroundColor;
}

-(void)CanvasSettingControllerDelegateChangeCanvas:(double)newWidth :(double)newHeight strandedNotesAt:(NSMutableIndexSet*)indicesOfAffectedPlacedNotes{
    
    // 1. Rescue notes that will be stranded by a resizing of the canvas.
    
    
    // Retrieve models of notes that will be stranded and use these models to create
    // new notes in a safe location, that is, _unplacedNotesArray;
    [_placedNotesArr enumerateObjectsAtIndexes:indicesOfAffectedPlacedNotes
                                       options:(uint)0
                                    usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                        NoteM* affectedNoteModel = [(Note*)obj generateModel];
                                        Note* copyOfAffectedNote = [[Note alloc]initWithText:@""];
                                        [copyOfAffectedNote loadWithModel:affectedNoteModel];
                                        [_unplacedNotesArray addObject:copyOfAffectedNote];
                                        // Remove affected note from user's view
                                        [((Note*)obj).view removeFromSuperview];
                                        // Remove affected note from physics engine
                                        [_space remove:(Note*)obj];
                                    }];

    //Clear out affected notes from placedNotesArr
    [_placedNotesArr removeObjectsAtIndexes:indicesOfAffectedPlacedNotes];
    
    // 2. Update unplaced notes button to reflect new count.
    _unplacedNotesButton.title = [NSString stringWithFormat:@"%d Unplaced Notes",_unplacedNotesArray.count];
    
    // 3. Resize canvas!
    [self effectNewDimsFromCanvasSettings:(double)newWidth :(double)newHeight];
} 

- (void)effectNewDimsFromCanvasSettings:(double)newWidth :(double)newHeight{
    
    // Display alert if canvas dimensions have changed.
    if (_canvas.bounds.size.height != newHeight || _canvas.bounds.size.width != newWidth) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"Canvas settings successfully changed.\nWidth:%.2f Height:%.2f",newWidth,newHeight]
                                                       message:nil
                                                      delegate:self
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];
        [alert show];
    }
    
    //TODO can optimise grid drawing.
    
    if (_snapToGridEnabled) {
        [_grid removeFromSuperview]; //hide.
        _grid = [[GridView alloc]initWithFrame:CGRectMake(0, 0, _canvas.bounds.size.width, _canvas.bounds.size.height)
                                          Step:_stepping
                                     LineColor:[ViewHelper invColorOf:[_canvas backgroundColor]]
                                     Thickness:_gridLineThickness];
        [_canvas addSubview:_grid]; //Show.
        [_canvas sendSubviewToBack:_grid]; //Don't block notes.
    }
    
    
    
    // Modify _canvas.
    CGRect bounds = _canvas.bounds;
    bounds.size.width = newWidth;
    bounds.size.height = newHeight;
    _canvas.bounds = bounds;
    [_canvas setFrame:CGRectMake(_canvas.frame.origin.x,
                                 _canvas.frame.origin.y,
                                 _canvas.bounds.size.width*[_canvasWindow zoomScale],
                                 _canvas.bounds.size.height*[_canvasWindow zoomScale])];
    
    // Center content view in _canvasWindow. Don't know why this works. But it does.
    [_canvasWindow setZoomScale:[_canvasWindow zoomScale]-0.01 animated:NO]; //Scale to something slightly smaller than zoomscale that we used before segueing to canvas settings controller.
    [_canvasWindow setZoomScale:[_canvasWindow zoomScale] animated:YES]; //Reinstate zoomScale before changing canvas settings
    
    // Remove all notes from space.
    for (Note* eachNote in _placedNotesArr) {
        [_space remove:eachNote];
    }
    
    // Modify _space. (Destroy and make anew);
    _space = nil;
    _space = [[ChipmunkSpace alloc] init];
    [_space addBounds:_canvas.bounds
            thickness:100000.0f elasticity:0.0f friction:1.0f layers:CP_ALL_LAYERS group:CP_NO_GROUP collisionType:borderType];
    [_space setGravity:cpv(0, 0)];
    [self createCollisionHandlers];//MUST ALSO REASSIGN COLLISION HANDLERS.
    
    // Add notes to new space.
    for (Note* eachNote in _placedNotesArr) {
        [_space add:eachNote];
    }
    
    // Redo minimap
    if (_minimapEnabled) {
        [_minimapView removeFromSuperview];
        _minimapView = [[MinimapView alloc]initWithMinimapDisplayFrame:CGRectMake(800, 480, 200, 200) MapOf:_canvas PopulateWith:_placedNotesArr];
        [_minimapView setAlpha:0.8]; // make transparent.
        [self.view addSubview:_minimapView];
    }
    //Set thickness of screen tracker on minimap regardless.
    //    [_mV1.screenTracker setThickness:(_canvas.bounds.size.height*_canvas.bounds.size.width)/10000];
    
    // Reposition title and color title appropriately
    [_diagramTitleVC setTextColor:[ViewHelper invColorOf:_canvas.backgroundColor]];
    [_diagramTitleVC housekeep];
}



#pragma mark - Gestures


-(void)unplacedNotePanResponse:(UIPanGestureRecognizer*)recognizer{
    
    // Guard
    if (_editingANote) {
        return;
    }
    
    /* Gesture begins ...    */
    if (recognizer.state == UIGestureRecognizerStateBegan){
        
        NoteView* v = (NoteView*)recognizer.view;
        Note* n = (Note*)v.delegate;
        
       
        
        [_canvasWindow setScrollEnabled:NO]; //disable scrollview.
        
        //Find coordinates of note's view's center w.r.t canvas.
        CGPoint vFrameCenterOnCanvas = [_canvas convertPoint:v.center fromView:v.superview];
        
        [_canvas addSubview:v];
       
        //Set body and align view.
        n.body.pos = vFrameCenterOnCanvas;
        v.frame = CGRectMake(-v.frame.size.width/2.0,
                             -v.frame.size.height/2.0,
                             v.frame.size.width,
                             v.frame.size.height);
        
        [_placedNotesArr addObject:n];
        
        //don't add to physics engine yet.
        
        //Remove note from unplaced notes array.
        [_temporaryHoldingAreaForNotes removeObjectIdenticalTo:n]; //MUST UNCOMMENT
        
        [self commonCodeForStateBeganNotePanResponse:recognizer]; //COMMON CODE!
    }

    /* Gesture continues changing ...    */
    
    NoteView* v = (NoteView*)recognizer.view;
    Note* n = (Note*)v.delegate;
    
    // Move body.
    cpVect origBodyPos = n.body.pos;
    
    CGPoint translation = [recognizer translationInView:recognizer.view.superview];
    
    n.body.pos = cpv(origBodyPos.x+translation.x,
                     origBodyPos.y+translation.y);
    
        //Adjust view part to match up with body part.
        double finBodyCenterX = n.body.pos.x;
        double finBodyCenterY = n.body.pos.y;
        double finBodyTLX = finBodyCenterX - v.frame.size.width/2.0;
        double finBodyTLY = finBodyCenterY - v.frame.size.height/2.0;
        double finBodyBLX = finBodyCenterX + v.frame.size.width/2.0;
        double finBodyBLY = finBodyCenterY + v.frame.size.height/2.0;

        // If note's body will be panned to outside the canvas, then do not effect the translation.
        if (finBodyTLX < 0
            ||finBodyTLY < 0
            ||finBodyBLX > _canvas.bounds.size.width
            ||finBodyBLY > _canvas.bounds.size.height) {
            n.body.pos = origBodyPos;
        }
    
        [self commonCodeForStateChangedNotePanResponse:recognizer]; //COMMON CODE!
        
        //Reset recognizer
        [recognizer setTranslation:CGPointZero inView:recognizer.view.superview];
    
    
    /* Gesture ends ...    */
    if(recognizer.state == UIGestureRecognizerStateEnded) {
        
        NoteView* noteViewToBePlaced = ((NoteView*)recognizer.view);
        Note* noteToBePlaced = ((Note*)noteViewToBePlaced.delegate);
        
        [_space add:noteToBePlaced]; //visible to physics engine.
        
        [self commonCodeForStateEndedNotePanResponse:recognizer]; // COMMON CODE!
        
        // Undim note
        [noteViewToBePlaced setAlpha:1];
        
        // Attach pan gesture recognizers for placed note.
        UIPanGestureRecognizer *panRecog = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(notePanResponse:)];
        [noteViewToBePlaced addGestureRecognizer:panRecog];
        
        [_canvasWindow setScrollEnabled:YES]; //re-enable scrolling
        
        // Remove this gesture recognizer.
        [noteViewToBePlaced removeGestureRecognizer:recognizer];
    }
}


-(void)notePanResponse:(UIPanGestureRecognizer*)recognizer {
    
    /* Gesture begins ...    */
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        _canvasWindow.scrollEnabled = NO; //Disable scrolling
        
        NoteView* recognizerView = (NoteView*)recognizer.view;
        Note* noteBeingPanned = (Note*)recognizerView.delegate;
        
        [_space remove:noteBeingPanned]; //Remove note from space
        recognizerView.alpha = 0.7; //Dim note's appearance.
        [_canvas bringSubviewToFront:recognizerView]; //Give illusion of lifting note up from canvas.
        
        [self commonCodeForStateBeganNotePanResponse:recognizer]; //COMMON CODE!
    }
    
    /* Gesture continues changing ...    */
    
    NoteView* recognizerView = (NoteView*)recognizer.view;
    Note* noteBeingPanned = (Note*)recognizerView.delegate;
    
    cpVect origBodyPos = noteBeingPanned.body.pos;
    
    CGPoint translation = [recognizer translationInView:recognizer.view.superview];
    
    // Move only the body. Somehow the view is constantly updated by _displayLink. Wow.
    noteBeingPanned.body.pos = cpv(origBodyPos.x+translation.x,
                                   origBodyPos.y+translation.y);
    
    // If note's body will be panned to outside the canvas, then do not effect the translation.
    double finBodyCenterX = noteBeingPanned.body.pos.x;
    double finBodyCenterY = noteBeingPanned.body.pos.y;
    double finBodyTLX = finBodyCenterX - recognizerView.frame.size.width/2.0;
    double finBodyTLY = finBodyCenterY - recognizerView.frame.size.height/2.0;
    double finBodyBLX = finBodyCenterX + recognizerView.frame.size.width/2.0;
    double finBodyBLY = finBodyCenterY + recognizerView.frame.size.height/2.0;
    if (finBodyTLX < 0
        ||finBodyTLY < 0
        ||finBodyBLX > _canvas.bounds.size.width
        ||finBodyBLY > _canvas.bounds.size.height) {
        noteBeingPanned.body.pos = origBodyPos;
    }
    
    [self commonCodeForStateChangedNotePanResponse:recognizer]; //COMMON CODE!
    
    [recognizer setTranslation:CGPointZero inView:recognizer.view.superview];
    
    
    /* Gesture ends ...    */
	if(recognizer.state == UIGestureRecognizerStateEnded) {
        
        NoteView* recognizerView = (NoteView*)recognizer.view;
        Note* noteBeingPanned = (Note*)recognizerView.delegate;
        
        [self commonCodeForStateEndedNotePanResponse:recognizer]; //COMMON CODE!
        
        _canvasWindow.scrollEnabled = YES; //enable scrolling
        [_space add:noteBeingPanned]; //Re-add note into space
        recognizerView.alpha = 1; //Un-dim note's appearance.
    }
}


-(void)commonCodeForStateBeganNotePanResponse:(UIPanGestureRecognizer*)recognizer {
    NoteView* noteView = (NoteView*)recognizer.view;
    
    _singlySelectedPannedNotesCount++; // increment count. Useful in regulating disabling/re-enabling of grid snapping button.
    
    if ([_gridSnappingButton isEnabled]) [_gridSnappingButton setEnabled:NO]; //disable grid snapping button. Safety reasons.
    
    // Prepare alignment lines.
    noteView.alignmentLines = [[AlignmentLineView alloc]initToDemarcateFrame:((NoteView*)recognizer.view).frame In:_canvas.bounds LineColor:[ViewHelper invColorOf:_canvas.backgroundColor] Thickness:1.6/_canvasWindow.zoomScale];
    
    // Show the alignment lines.
    [noteView.alignmentLines addToBottommostOf:_canvas];
    
    if (_snapToGridEnabled){
        
        //Prepare foreshadow.
        noteView.foreShadow = [[UIImageView alloc]initWithFrame:CGRectMake(((NoteView*)recognizer.view).frame.origin.x,
                                                                                   noteView.frame.origin.y,
                                                                                   noteView.bounds.size.width,
                                                                                   noteView.bounds.size.height)];
        [noteView.foreShadow setBackgroundColor:[ViewHelper invColorOf:[_canvas backgroundColor]]]; //set color of foreshadow.
        [noteView.foreShadow setAlpha:0.3]; //set alpha of foreshadow.
        //Show foreshadow.
        [_canvas addSubview:noteView.foreShadow];
    }
}

-(void)commonCodeForStateChangedNotePanResponse:(UIPanGestureRecognizer*)recognizer {
    NoteView* noteView = (NoteView*)recognizer.view;
    Note* note = (Note*)noteView.delegate;
    
    if (_snapToGridEnabled) {
        
        // The purpose of this block is to mark out where the note would snap to upon releasing your finger.
        double step = _grid.step; //Find out the stepping involved.
        // Perform rounding algo. This algo finds out where the note's frame's origin would end after releasing your finger.
        double unsnappedX = noteView.frame.origin.x;
        double unsnappedY = noteView.frame.origin.y;
        double snappedX = ((int)(unsnappedX/step))*step;
        double snappedY = ((int)(unsnappedY/step))*step;
        // Move foreShadow to help user visualize where the note will rest after he releases his finger.
        [noteView.foreShadow setFrame:CGRectMake(snappedX, snappedY, noteView.foreShadow.frame.size.width, noteView.foreShadow.frame.size.height)];
        
        // With snap to grid, alignment lines redraw to demarcate foreshadow.
        [noteView.alignmentLines redrawWithDemarcatedFrame:noteView.foreShadow.frame];
    }
    else{
        //Without snap to grid, alignment lines redraw to demarcate note itself.
        [noteView.alignmentLines
         redrawWithDemarcatedFrame:CGRectMake(note.body.pos.x - noteView.frame.size.width/2.0,
                                              note.body.pos.y - noteView.frame.size.height/2.0,
                                              noteView.frame.size.width,
                                              noteView.frame.size.height)];
    }
}

-(void)commonCodeForStateEndedNotePanResponse:(UIPanGestureRecognizer*)recognizer {
    NoteView* noteView = ((NoteView*)recognizer.view);
    Note* note = ((Note*)noteView.delegate);
    
    _singlySelectedPannedNotesCount--; // Decrement count. Useful in regulating disabling/re-enabling of grid snapping button.
    
    if (_singlySelectedPannedNotesCount == 0) { //Implies no notes being singly selected and panned.
        [_gridSnappingButton setEnabled:YES]; //re-enable grid snapping button.
    }
    
    if (_snapToGridEnabled) {
        double step = _grid.step; //Find out the stepping involved.
        //Perform snap rounding algo. This algo focuses on snapping the origin of the note.
        //The origin of the note refers to the top left hand corner of the note.
        double unsnappedXcenter = note.body.pos.x;
        double unsnappedYcenter = note.body.pos.y;
        double unsnappedXorigin = unsnappedXcenter - noteView.bounds.size.width/2.0;
        double unsnappedYorigin = unsnappedYcenter - noteView.bounds.size.height/2.0;
        double snappedXorigin = ((int)(unsnappedXorigin/step))*step;
        double snappedYorigin = ((int)(unsnappedYorigin/step))*step;
        double snappedXcenter = snappedXorigin + noteView.bounds.size.width/2.0;
        double snappedYcenter = snappedYorigin + noteView.bounds.size.height/2.0;
        //Apply new coordinates ONLY to body
        note.body.pos = cpv(snappedXcenter,
                                      snappedYcenter);
        
        //Remove foreshadow.
        [noteView.foreShadow removeFromSuperview];
    }
    
    [noteView.alignmentLines removeLines]; // Hide alignment lines.
}


-(void)noteDoubleTapResponse:(UITapGestureRecognizer*)recognizer {
    //State management
    if (_massSelectMode) {
        return;
    }
    
    //Adjusting states below.
    _editingANote = YES;
    _noteBeingEdited = ((Note*)((NoteView*)(recognizer.view)).delegate);
    
    //Show platform for user to edit text.
    [_editNoteTextPlatform setText:[_noteBeingEdited content]];
    [_editNoteTextPlatform setBackgroundColor:[ViewHelper invColorOf:_canvas.backgroundColor]];
    [_editNoteTextPlatform setTextColor:[ViewHelper invColorOf:_editNoteTextPlatform.backgroundColor]];
    [_editNoteTextPlatform setFont:[_noteBeingEdited getFont]];
    [self.view addSubview:_editNoteTextPlatform];
    
    //Summon keyboard w.r.t UITextView.
    [_editNoteTextPlatform becomeFirstResponder];
    
    //Show tool bar related to editing notes.
    [_editNoteToolBar showForEditingSingleNote];
}



- (void)singleTapResponse:(UITapGestureRecognizer *)recognizer {
    [self.view endEditing:YES]; // Dismiss keyboard.
    if (_massSelectMode) {
        [self massSelectModeDisable];
    }
}


#pragma mark - Main Toolbar & its BarButtons

- (IBAction)addNewNoteButton:(id)sender {
    
    // Limit the number of notes a canvas can have.
    if (_placedNotesArr.count > CANVAS_NOTE_COUNT_LIM) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"Cannot exceed %d notes on one diagram.",CANVAS_NOTE_COUNT_LIM]
                                                       message:nil
                                                      delegate:self
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];
        [alert show];
        return; //terminate adding new note
    }
    
    // Limit the number of fresh UNplaced notes that can be floating in front of the canvas window.
    if (_temporaryHoldingAreaForNotes.count >= CANVAS_WINDOW_UNPLACED_FRESH_NOTE_LIM) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"You should arrange your fresh new notes before adding more new notes. Your stack of notes building up in front of your screen is blocking a vital part of your screen."]
                                                       message:nil
                                                      delegate:self
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];
        [alert show];
        return; //terminate adding new note
    }
    
    Note *newN = [[Note alloc]initWithText:@"new"];
    
    // Determine coordinates of new note
    CGPoint centerOfNewNote = CGPointMake(_canvasWindow.bounds.size.width/2.0, _canvasWindow.bounds.size.height/2.0);
    [newN.view setCenter:centerOfNewNote];
    
    [_temporaryHoldingAreaForNotes addObject:(Note*)newN]; // Stored in property
    [self.view addSubview:newN.view]; // Visible to user
    newN.view.alpha = 0.6; //Dim note's appearance.
    
    /*Attach gesture recognizers*/
    
    // New UNplaced notes can be dragged and placed.
    UIPanGestureRecognizer *panRecog = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(unplacedNotePanResponse:)];
    [newN.view addGestureRecognizer:panRecog];
    
    // New UNplaced notes are editable.
    UITapGestureRecognizer *doubleTapRecog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(noteDoubleTapResponse:)];
    doubleTapRecog.numberOfTapsRequired = 2;
    [newN.view addGestureRecognizer:doubleTapRecog];
}


- (IBAction)closeButton:(id)sender {
    [_delegate updateDiagram:[self generateDiagramModel]];
    
    //Dismiss all popovers.
    while ([[_currentPopoverSegue popoverController] isPopoverVisible]){
        [[_currentPopoverSegue popoverController] dismissPopoverAnimated: NO];
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)resetZoomButton:(id)sender {
    [_canvasWindow setZoomScale:1];
}

- (IBAction)gridSnappingButton:(id)sender {
    // Toggles snapping to grid feature.
    if (_snapToGridEnabled) {
        // Grid snapping: ON -> OFF
        [_grid removeFromSuperview]; //hide.
        _snapToGridEnabled = NO; //toggle.
    }
    else {
        // Grid snapping: OFF -> ON
        _grid = [[GridView alloc]initWithFrame:CGRectMake(0, 0, _canvas.bounds.size.width, _canvas.bounds.size.height)
                                          Step:_stepping
                                     LineColor:[ViewHelper invColorOf:[_canvas backgroundColor]]
                                     Thickness:_gridLineThickness];
        [_canvas addSubview:_grid]; //Show.
        [_canvas sendSubviewToBack:_grid]; //Don't block notes.
        _snapToGridEnabled = YES; //Toggle.
    }
}

- (IBAction)minimapButton:(id)sender {
    
    if (_minimapEnabled) { 
        [_minimapView removeFromSuperview];
        _minimapEnabled = NO; //toggle.
    }
    else {
        _minimapView = [[MinimapView alloc]initWithMinimapDisplayFrame:CGRectMake(800, 480, 200, 200) MapOf:_canvas PopulateWith:_placedNotesArr];
        [_minimapView setAlpha:0.8]; // make transparent.
        [self.view addSubview:_minimapView];
        _minimapEnabled = YES; //toggle.
    }
    
}


- (IBAction)unplacedNotesButton:(id)sender {
    // Check if there are any notes in unplaced notes array.
    if (_unplacedNotesArray.count == 0 ) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"You have no more unplaced notes."]
                                                       message:nil
                                                      delegate:self
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];
        [alert show];
        return; //terminate
    }
    
    // Limit the number of fresh UNplaced notes that can be floating in front of the canvas window.
    if (_temporaryHoldingAreaForNotes.count >= CANVAS_WINDOW_UNPLACED_FRESH_NOTE_LIM) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"You should arrange your new notes before adding more new notes. Your stack of notes building up in front of your screen is blocking a vital part of your screen."]
                                                       message:nil
                                                      delegate:self
                                             cancelButtonTitle:@"OK I'll clear up my new notes."
                                             otherButtonTitles:nil];
        [alert show];
        return; //terminate
    }
    
    
    
    // Retrieve
    Note *noteToBePlacedSoon = (Note*)[_unplacedNotesArray objectAtIndex:0];
    // Remove from unplaced notes array.
    [_unplacedNotesArray removeObjectAtIndex:0];
    // decrement count of unplaced notes and display on button.
    _unplacedNotesButton.title = [NSString stringWithFormat:@"%d Unplaced Notes",_unplacedNotesArray.count];
    // Add to holding area
    [_temporaryHoldingAreaForNotes addObject:noteToBePlacedSoon];
    
    // Determine coordinates of new note
    CGPoint centerOfNewNote = CGPointMake(_canvasWindow.bounds.size.width/2.0, _canvasWindow.bounds.size.height/2.0);
    [noteToBePlacedSoon.view setCenter:centerOfNewNote];
    
    [_temporaryHoldingAreaForNotes addObject:(Note*)noteToBePlacedSoon]; // Stored in property
    [self.view addSubview:noteToBePlacedSoon.view]; // Visible to user
    noteToBePlacedSoon.view.alpha = 0.6; //Dim note's appearance.
    
    /*Attach gesture recognizers*/
    
    // UNplaced notes can be dragged and placed.
    UIPanGestureRecognizer *panRecog = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(unplacedNotePanResponse:)];
    [noteToBePlacedSoon.view addGestureRecognizer:panRecog];
    
    // UNplaced notes are editable.
    UITapGestureRecognizer *doubleTapRecog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(noteDoubleTapResponse:)];
    doubleTapRecog.numberOfTapsRequired = 2;
    [noteToBePlacedSoon.view addGestureRecognizer:doubleTapRecog];
}

- (IBAction)exportAsImageButton:(id)sender {
    BOOL needToReenableSnapTpGrid = NO;
    
    if (_snapToGridEnabled) {
        [_grid setHidden:YES]; //turn off grid
        needToReenableSnapTpGrid = YES;
    }
    //Convert canvas to image
    UIImage* img = [ViewHelper imageWithView:_canvas];
    
    //Init PreviewDiagramViewController
    PreviewDiagramViewController* pDVC = [[PreviewDiagramViewController alloc]initWithImage:img Title:[_diagramTitleVC text] ProjectTitle:[_delegate getProjectTitle]];
    
    if (needToReenableSnapTpGrid) {
        [_grid setHidden:NO];
    }
    
    [self presentModalViewController:pDVC animated:YES];
}


#pragma mark - Editing Note Tool Bar Delegates

#pragma mark Bold
-(void)EditToolBarDidPressBoldButton_Name:(NSString *)name{
    
    if (_editingANote) {
        [_noteBeingEdited toggleBold];
    }
    else if (_massSelectMode){
        if ([_editNoteToolBar boldButtonPressCounts]%2 == 1) {
            for (Note* eachNote in _basketOfNotesToBeEdited) {
                [eachNote addBold];
            }
        }
        else {
            for (Note* eachNote in _basketOfNotesToBeEdited) {
                [eachNote minusBold];
            }
        }
        
    }
}

#pragma mark Italics
-(void)EditToolBarDidPressItalicsButton_Name:(NSString *)name{
    
    if (_editingANote) {
        [_noteBeingEdited toggleItalics];
    }
    else if (_massSelectMode){
        if ([_editNoteToolBar italicsButtonPressCounts]%2 == 1) {
            for (Note* eachNote in _basketOfNotesToBeEdited) {
                [eachNote addItalics];
            }
        }
        else {
            for (Note* eachNote in _basketOfNotesToBeEdited) {
                [eachNote minusItalics];
            }
        }
    }
}

#pragma mark Font
-(void)EditToolBarDidPressFontButton_Name:(NSString*)name SelectedOption:(NSString *)option{
    if (_editingANote) {
        [_noteBeingEdited setFont:[FontHelper modifyFont:[_noteBeingEdited getFont] WhileKeepingModifiersAndSizeToFontFamily:option]];
    }
    else if (_massSelectMode){
        for (Note* eachNote in _basketOfNotesToBeEdited) {
            [eachNote setFont:[FontHelper modifyFont:[eachNote getFont] WhileKeepingModifiersAndSizeToFontFamily:option]];
        }

    }
}

#pragma mark Text Color
-(void)EditToolBarDidPressTextColorButton_Name:(NSString*)name SelectedColor:(NSString *)hexColor{
    if (_editingANote) {
    [_noteBeingEdited setTextColor:[GzColors colorFromHex:hexColor]];
    [_noteBeingEdited setTextColorGZColorString:hexColor];//TODO temporary fix. Ask Civics.
    }
    else if (_massSelectMode){
        for (Note* eachNote in _basketOfNotesToBeEdited) {
            [eachNote setTextColor:[GzColors colorFromHex:hexColor]];
            [eachNote setTextColorGZColorString:hexColor];//TODO temporary fix. Ask Civics.
        }
        
    }
    
}

#pragma mark Note Color(Material)
-(void)EditToolBarDidPressNoteColorButton_Name:(NSString*)name SelectedOption:(NSString *)option{
    if (_editingANote) {
        [_noteBeingEdited setMaterialWithPictureFileName:[Constants FileNameOfNoteMaterial:option]];
    }
    else if (_massSelectMode){
        for (Note* eachNote in _basketOfNotesToBeEdited) {
            [eachNote setMaterialWithPictureFileName:[Constants FileNameOfNoteMaterial:option]];
        }
    }
}

#pragma mark Delete Note
-(void)EditToolBarDidPressDeleteButton_Name:(NSString*)name{
    if (_editingANote) {
        if ([_placedNotesArr containsObject:_noteBeingEdited]) {
            [self removePlacedNote:_noteBeingEdited];
        }
        else if ([_temporaryHoldingAreaForNotes containsObject:_noteBeingEdited]){
            [self removeUNplacedFreshNote:_noteBeingEdited];
        }
        else{
            [NSException raise:@"Note being edited is neither placed nor unplaced." format:@"%s",__FUNCTION__];
        }
        
        [self.view endEditing:YES];
        _editingANote = NO;
        _noteBeingEdited = nil;
        
        //Reinstate _canvasWindow to original size
        _canvasWindow.frame=CGRectMake(_canvasWindow.frame.origin.x, _canvasWindow.frame.origin.y, _canvasWindow.frame.size.width, _canvasWindowOrigHeight);
        
        //Hide tool bar related to editing notes
        [_editNoteToolBar hide];
    }
    else if (_massSelectMode){
        for (Note* eachNote in _basketOfNotesToBeEdited) {
            [self removePlacedNote:eachNote];
        }
        _basketOfNotesToBeEdited = nil;
        [self massSelectModeDisable];
    }
}

#pragma mark Aligning Multiple Notes

-(void)EditToolBarDidPressVerticalAlignButton_Name:(NSString *)name{
    CGRect basketFrame = _basket.frame;
    double basketMinX = basketFrame.origin.x;
    double basketMidX = basketMinX + (basketFrame.size.width/2.0);
    double basketMinY = basketFrame.origin.y;
    
    //Sort notes in basket according to y value of position
    NSArray *sortedBasketOfNotes;
    sortedBasketOfNotes = [_basketOfNotesToBeEdited sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        double aY = ((Note*)a).body.pos.y;
        double bY = ((Note*)b).body.pos.y;
        if (aY < bY) {
            return NSOrderedAscending;
        } else if (aY > bY) {
            return NSOrderedDescending;
        } else
            return NSOrderedSame;
    }];
    
    //Initialisation of variables that will be used in loop.
    double nextNoteTLY = basketMinY;
    double nextNoteMidX = basketMidX;
    
    for (Note* eachNote in sortedBasketOfNotes) {
        
        //Check if eachNote will be exceeding the bottom of the canvas.
        if ((nextNoteTLY+NOTE_DEFAULT_HEIGHT) > _canvas.bounds.size.height) {
            nextNoteTLY = basketMinY;
            nextNoteMidX += NOTE_DEFAULT_WIDTH*1.5;
            if ((nextNoteMidX+NOTE_DEFAULT_WIDTH) > _canvas.bounds.size.width) {
                [ViewHelper raiseUIAlert:@"Alignment aborted. Unable to fit all notes on canvas."];
                break;
            }
            
        }
        
        eachNote.body.pos = cpv(nextNoteMidX, eachNote.body.pos.y); //shift to middle.
        [eachNote setBodyTopLeftPoint:CGPointMake([eachNote getBodyTopLeftPoint].x,
                                                  nextNoteTLY)];
        nextNoteTLY += NOTE_DEFAULT_HEIGHT*1.3;
    }
    
    CGRect newBasketFrame = [ViewHelper getTightestFrameThatCoversAllNotesIn:sortedBasketOfNotes];
    _basket.frame = newBasketFrame;
}

-(void)EditToolBarDidPressHorizAlignButton_Name:(NSString *)name{
    CGRect basketFrame = _basket.frame;
    double basketMinY = basketFrame.origin.y;
    double basketMidY = basketMinY + (basketFrame.size.height/2.0);
    double basketMinX = basketFrame.origin.x;
    
    //Sort notes in basket according to x value of position
    NSArray *sortedBasketOfNotes;
    sortedBasketOfNotes = [_basketOfNotesToBeEdited sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        double aX = ((Note*)a).body.pos.x;
        double bX = ((Note*)b).body.pos.x;
        if (aX < bX) {
            return NSOrderedAscending;
        } else if (aX > bX) {
            return NSOrderedDescending;
        } else
            return NSOrderedSame;
    }];
    
    //Initialisation of variables that will be used in loop.
    double nextNoteTLX = basketMinX;
    double nextNoteMidY = basketMidY;
    
    for (Note* eachNote in sortedBasketOfNotes) {
        
        //Check if eachNote will be exceeding the bottom of the canvas.
        if ((nextNoteTLX+NOTE_DEFAULT_WIDTH) > _canvas.bounds.size.width) {
            nextNoteTLX = basketMinX;
            nextNoteMidY += NOTE_DEFAULT_HEIGHT*1.5;
            if ((nextNoteMidY+NOTE_DEFAULT_HEIGHT) > _canvas.bounds.size.height) {
                [ViewHelper raiseUIAlert:@"Alignment aborted. Unable to fit all notes on canvas."];
                break;
            }
            
        }
        
        eachNote.body.pos = cpv(eachNote.body.pos.x,nextNoteMidY); //shift to middle.
        [eachNote setBodyTopLeftPoint:CGPointMake(nextNoteTLX,[eachNote getBodyTopLeftPoint].y)];
        nextNoteTLX += NOTE_DEFAULT_WIDTH*1.3;
    }
    
    CGRect newBasketFrame = [ViewHelper getTightestFrameThatCoversAllNotesIn:sortedBasketOfNotes];
    _basket.frame = newBasketFrame;
}

#pragma mark - Mass Select Notes

-(void)basketPanResponse:(UIPanGestureRecognizer*)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        _canvasWindow.scrollEnabled = NO; //Disable scrolling
    }
    
    /* Gesture Recognizer is in progress...    */
    
    UIView* overlay = recognizer.view;
    
    CGPoint translation = [recognizer translationInView:recognizer.view.superview];
    
    double finBasketTLX = overlay.frame.origin.x+translation.x;
    double finBasketTLY = overlay.frame.origin.y+translation.y;
    double finBasketBLX = finBasketTLX + overlay.frame.size.width;
    double finBasketBLY = finBasketTLY + overlay.frame.size.height;
    if (finBasketTLX < 0
        ||finBasketTLY < 0
        ||finBasketBLX > _canvas.bounds.size.width
        ||finBasketBLY > _canvas.bounds.size.height) {
        ; //do nothing because basket is moving outside of canvas!
    }
    else {
        overlay.frame = CGRectMake(finBasketTLX,
                                   finBasketTLY,
                                   overlay.frame.size.width,
                                   overlay.frame.size.height);
        
        for (Note* eachNote in _basketOfNotesToBeEdited) {
            cpVect origBodyPos = eachNote.body.pos;
            
            // Move only the body.
            eachNote.body.pos = cpv(origBodyPos.x+translation.x,
                                    origBodyPos.y+translation.y);
        }
        
    }
    
    [recognizer setTranslation:CGPointZero inView:recognizer.view.superview];
    
	if(recognizer.state == UIGestureRecognizerStateEnded) {
        _canvasWindow.scrollEnabled = YES; //enable scrolling
    }
}

-(void)massSelectWindowQuit{
    [_overlayForMassSelectingNotes setHidden:YES];
}

-(void)massSelectModeEnable:(UILongPressGestureRecognizer*)recognizer{
    //State management
    if (_massSelectMode || _editingANote) {
        return;
    }
    _massSelectMode = YES;
    [_overlayForMassSelectingNotes setHidden:NO];
    [_overlayForMassSelectingNotes setUserInteractionEnabled:YES];
    _basketOfNotesToBeEdited = [[NSMutableArray alloc]init]; //prepare to take in notes being selected.
}

-(void)massSelectModeDisable{
    [_overlayForMassSelectingNotes setHidden:YES];
    [_editNoteToolBar hide];
    for (Note* eachNote in _basketOfNotesToBeEdited) {
        [_space add:eachNote];
        [eachNote.view setAlpha:1];
    }
    _basketOfNotesToBeEdited = nil;
    [_basket removeFromSuperview];
    _massSelectMode = NO;
}


-(void)panResponseForMassSelectMode:(UIPanGestureRecognizer*)recognizer{
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        _basketOfNotesToBeEdited = [[NSMutableArray alloc]init];
    }
    
    if (recognizer.numberOfTouches >= 1) {
        _fingerForMassSelectingNotes = [recognizer locationOfTouch:0 inView:_canvas];
        [ViewHelper embedMark:_fingerForMassSelectingNotes WithColor:[ViewHelper invColorOf:_canvas.backgroundColor] DurationSecs:3 In:_canvas];
        
        // Check all notes to see if finger is above the note.
        for (Note* eachNote in _placedNotesArr) {
            if ([ViewHelper isPoint:_fingerForMassSelectingNotes TouchingRect:eachNote.view.frame]) {
                [eachNote.view setAlpha:0.5];
                // Add note into basket of notes to be edited.
                if (![_basketOfNotesToBeEdited containsObject:eachNote]) {
                    [_basketOfNotesToBeEdited addObject:eachNote];
                    [_space remove:eachNote];
                }
            }
        }
        
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        [self massSelectWindowQuit];
        if (_basketOfNotesToBeEdited.count == 0) {
            return;
        }
        [self createBasket];
        [_editNoteToolBar showForEditingMultipleNotes];
    }
}

-(void)createBasket{
    
    // Determine the boundaries of the basket that is to snugly wrap the notes.
    CGRect basketFrame = [ViewHelper getTightestFrameThatCoversAllNotesIn:_basketOfNotesToBeEdited];
    
    _basket = [[UIView alloc]initWithFrame:basketFrame];
    _basket.backgroundColor = [ViewHelper invColorOf:_canvas.backgroundColor];
    [_basket setAlpha:0.2];
    [_canvas addSubview:_basket];
    
    // Panning basket
    UIPanGestureRecognizer *panRecog = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(basketPanResponse:)];
    [_basket addGestureRecognizer:panRecog];
    
    // Killing basket
    UITapGestureRecognizer *singleTapRecog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(massSelectModeDisable)];
    [_basket addGestureRecognizer:singleTapRecog];
}


#pragma mark - Note modifiying contents

#pragma mark UITextView delegate methods

-(BOOL)textView:(UITextView*)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    NSUInteger newLength = [textView.text length]+[text length] - range.length;
    
    if ([_editNoteTextPlatform isFirstResponder]) {
        
        // Length limitations
        if (newLength > NOTE_CONTENT_CHAR_LIM) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"Cannot exceed %d characters.",NOTE_CONTENT_CHAR_LIM]
                                                           message:nil
                                                          delegate:self
                                                 cancelButtonTitle:nil
                                                 otherButtonTitles:nil];
            [alert show];
            [alert performSelector:@selector(dismissAnimated:) withObject:(BOOL)NO afterDelay:0.0f];
            return NO;
        }
        
        if ([_noteBeingEdited.view getMinYOfContent] > _noteBeingEdited.view.frame.size.height*(2.0/3)) {
            if (range.length > 0 && text.length ==0) {
                //indicates deleting a selection of text or backspacing.
                return YES;
            }
            return NO;
        }
        
        return YES;
    }
    
    return NO; //Unknown cases of textView attempting to get themselves edited are denied!
}

-(void)textViewDidChange:(UITextView *)textView{
        [_noteBeingEdited setContent:textView.text];
    
}

//-(void)textViewDidBeginEditing:(UITextView *)textView{
//    
////    //Remove note editing stuff when switching from a note being the first responder to a
////    //title being a first responder.
////    NSLog(@"textview delgeate method in EDC called.");
////        if (_noteBeingEdited != nil) {
////            // Note was being edited.
////            // Adjust the state of this Controller.
////            _editingANote = NO;
////            // Invalidate pointer to note that was being edited.
////            _noteBeingEdited = nil;
////            //Hide tool bar related to editing notes.
////            [_editNoteToolBar removeFromSuperview];
////            //Hide edit note text platform
////            [_editNoteTextPlatform removeFromSuperview];
////            
////        }
//    
//}

-(void)textViewDidEndEditing:(UITextView *)textView{
    if (_noteBeingEdited != nil) {
        // Note was being edited.
        // Adjust the state of this Controller.
        _editingANote = NO;
        // Invalidate pointer to note that was being edited.
        _noteBeingEdited = nil;
        //Hide tool bar related to editing notes.
        [_editNoteToolBar hide];
        //Hide edit note text platform
        [_editNoteTextPlatform removeFromSuperview];
        
    }
}

#pragma mark - Generate/Load Diagram Models.

-(Diagram*)generateDiagramModel{
    
    _diagramModel.title = [_diagramTitleVC text];
    _diagramModel.width = _canvas.bounds.size.width;
    _diagramModel.height = _canvas.bounds.size.height;
    _diagramModel.color = _canvasColorHexValue;//TODO temporary fix.
    
    [_diagramModel.placedNotes removeAllObjects];//IMPT! If this edit diagram VC loaded a diagram from ProjectDiagramVC, then this array is likely to begin non-empty. Clear it first, fill it up with this VC's stuff.
    
    for (Note* eachNote in _placedNotesArr) {
        NoteM* model = [eachNote generateModel];
        [_diagramModel.placedNotes addObject:model];
    }
    
    [_diagramModel.unplacedNotes removeAllObjects];//IMPT! If this edit diagram VC loaded a diagram from ProjectDiagramVC, then this array is likely to begin non-empty. Clear it first, fill it up with this VC's stuff.
    
    for (Note* eachNote in _unplacedNotesArray) {
        NoteM* model = [eachNote generateModel];
        [_diagramModel.unplacedNotes addObject:model];
    }
    
    return _diagramModel;
}

-(void)loadWithDiagramModel:(Diagram*)aDiagramModel
{
    /* Steps
     1. Clear out all note arrays. (Placed, unplaced, etc.)
     2. Remake space of physics engine.
     3. Resize canvas.
     3.5. Color canvas.
     4. Load title
     5. Fill up all note arrays. (Placed, unplaced, etc.)
     */
    
    //1.
    [self clearPlacedNotesArray];
    [self clearUNplacedFreshNotesArray];
    [self clearUNplacedNotesArray];
    
    //2. & 3.
    _canvas.bounds = CGRectMake(0, 0, aDiagramModel.width, aDiagramModel.height);
    
    if (_snapToGridEnabled) {
        [_grid removeFromSuperview]; //hide.
        _grid = [[GridView alloc]initWithFrame:CGRectMake(0, 0, _canvas.bounds.size.width, _canvas.bounds.size.height)
                                          Step:_stepping
                                     LineColor:[ViewHelper invColorOf:[_canvas backgroundColor]]
                                     Thickness:_gridLineThickness];
        [_canvas addSubview:_grid]; //Show.
        [_canvas sendSubviewToBack:_grid]; //Don't block notes.
    }
    
    
    
    // Modify _canvas.
//    [_canvas setFrame:CGRectMake(_canvas.frame.origin.x,
//                                 _canvas.frame.origin.y,
//                                 _canvas.bounds.size.width*[_canvasWindow zoomScale],
//                                 _canvas.bounds.size.height*[_canvasWindow zoomScale])];
    
    // Center content view in _canvasWindow. Don't know why this works. But it does.
    [_canvasWindow setZoomScale:[_canvasWindow zoomScale]-0.01 animated:NO]; //Scale to something slightly smaller than zoomscale that we used before segueing to canvas settings controller.
    [_canvasWindow setZoomScale:[_canvasWindow zoomScale] animated:YES]; //Reinstate zoomScale before changing canvas settings
    
    // Modify _space. (Destroy and make anew);
    _space = nil;
    _space = [[ChipmunkSpace alloc] init];
    [_space addBounds:_canvas.bounds
            thickness:100000.0f elasticity:0.0f friction:1.0f layers:CP_ALL_LAYERS group:CP_NO_GROUP collisionType:borderType];
    [_space setGravity:cpv(0, 0)];
    [self createCollisionHandlers];//MUST ALSO REASSIGN COLLISION HANDLERS.
    
    // Redo minimap
    if (_minimapEnabled) {
        [_minimapView removeFromSuperview];
        _minimapView = [[MinimapView alloc]initWithMinimapDisplayFrame:CGRectMake(800, 480, 200, 200) MapOf:_canvas PopulateWith:_placedNotesArr];
        [_minimapView setAlpha:0.8]; // make transparent.
        [self.view addSubview:_minimapView];
    }
    
    // 3.5
    _canvasColorHexValue = aDiagramModel.color;
    _canvas.backgroundColor = [GzColors colorFromHex:aDiagramModel.color];
    
    // 4.
    [_diagramTitleVC remove];
    _diagramTitleVC = [[diagramTitleVC alloc]initWith:aDiagramModel.title AndAllElseDefaultOn:_canvas];
    
    // 5.
    for (NoteM* eachNoteModel in aDiagramModel.placedNotes) {
        Note* eachToBePlacedNote = [[Note alloc]initWithText:@""];
        [eachToBePlacedNote loadWithModel:eachNoteModel];
        [self addPlacedNote:eachToBePlacedNote];
    }
    
    for (NoteM* eachNoteModel in aDiagramModel.unplacedNotes) {
        Note* eachToBePlacedNote = [[Note alloc]initWithText:@""];
        [eachToBePlacedNote loadWithModel:eachNoteModel];
        [_unplacedNotesArray addObject:eachToBePlacedNote];
    }

    _unplacedNotesButton.title = [NSString stringWithFormat:@"%d Unplaced Notes",_unplacedNotesArray.count];

}

-(void)viewWillDisappear:(BOOL)animated{
    [_delegate updateDiagram:[self generateDiagramModel]]; //save diagram
}

#pragma mark - Programmatically Removing/Adding notes to holding arrays

// Placed notes.

-(void)addPlacedNote:(Note*)n1{
    
    //Attach gesture recognizers to view part of note
    UIPanGestureRecognizer *panRecog = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(notePanResponse:)];
    [n1.view addGestureRecognizer:panRecog];
    
    UITapGestureRecognizer *doubleTapRecog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(noteDoubleTapResponse:)];
    doubleTapRecog.numberOfTapsRequired = 2;
    [n1.view addGestureRecognizer:doubleTapRecog];
    
    //Add view part to canvas.
    [_canvas addSubview:n1.view];
    
    //Add to placed notes array.
    [_placedNotesArr addObject:n1];
    
    //Add body part to physics engine.
    [_space add:n1];
}

-(void)removePlacedNote:(Note*)n1{
    
    [n1.view setUserInteractionEnabled:NO]; // for safety reasons.
    [n1.view removeFromSuperview];
    if ([_space contains:n1]) {
        [_space remove:n1];
    }
    [_placedNotesArr removeObjectIdenticalTo:n1];
}

-(void)clearPlacedNotesArray{
    for (Note* eachNote in _placedNotesArr) {
        [eachNote.view setUserInteractionEnabled:NO];//safety reasons
        [eachNote.view removeFromSuperview];
        if ([_space contains:eachNote]) {
            [_space remove:eachNote];
        }
    }
    [_placedNotesArr removeAllObjects];
}

// Unplaced notes with non-trivial content.

-(void)removeUNplacedNote:(Note*)n1{
    [n1.view setUserInteractionEnabled:NO]; // for safety reasons.
    [n1.view removeFromSuperview];
    if ([_space contains:n1]) {
        [_space remove:n1];
    }
    [_unplacedNotesArray removeObjectIdenticalTo:n1];
}

-(void)clearUNplacedNotesArray{
    for (Note* eachNote in _unplacedNotesArray) {
        [eachNote.view setUserInteractionEnabled:NO];//safety reasons
        [eachNote.view removeFromSuperview];
        if ([_space contains:eachNote]) {
            [_space remove:eachNote];
        }
    }
    [_unplacedNotesArray removeAllObjects];
}


// Unplaced fresh notes.

-(void)removeUNplacedFreshNote:(Note*)n1{
    [n1.view setUserInteractionEnabled:NO]; // for safety reasons.
    [n1.view removeFromSuperview];
    if ([_space contains:n1]) {
        [_space remove:n1];
    }
    [_temporaryHoldingAreaForNotes removeObjectIdenticalTo:n1];
}

-(void)clearUNplacedFreshNotesArray{
    for (Note* eachNote in _temporaryHoldingAreaForNotes) {
        [eachNote.view setUserInteractionEnabled:NO];//safety reasons
        [eachNote.view removeFromSuperview];
        if ([_space contains:eachNote]) {
            [_space remove:eachNote];
        }
    }
    [_temporaryHoldingAreaForNotes removeAllObjects];
}

#pragma mark - Chipmunk Physics Engine

// When the view appears on the screen, start the animation timer and tilt callbacks.
- (void)viewDidAppear:(BOOL)animated {
	// Set up the display link to control the timing of the animation.
	_displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
	_displayLink.frameInterval = 1;
	[_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

// The view disappeared. Stop the animation timers and tilt callbacks.
- (void)viewDidDisappear:(BOOL)animated {
	// Remove the timer.
	[_displayLink invalidate];
	_displayLink = nil;
}

// This method is called each frame to update the scene.
// It is called from the display link every time the screen wants to redraw itself.
- (void)update {
	// Step (simulate) the space based on the time since the last update.
	cpFloat dt = _displayLink.duration*_displayLink.frameInterval;
	[_space step:dt];
    
    for (Note* eachNote in _placedNotesArr) {
        [eachNote updatePos];
    }

    
    if (_minimapEnabled) {
        [_minimapView removeAllNotes];
        [_minimapView remakeWith:_placedNotesArr];
        
        
        /* Begin algorithm to compute CGRect of visible area in _canvas. (x,y,w,h) of this CGRect is w.r.t _canvas. */
        CGRect visibleRect = [ViewHelper visibleRectOf:_canvas thatIsSubViewOf:_canvasWindow withParentMostView:self.view];
        /* algo ends*/
        
        [_minimapView setScreenTrackerFrame:visibleRect]; //set the rect outline in minimap that depicts the area of _canvas that is visible to user.
        
    }
}

-(void)createCollisionHandlers{
    [_space addCollisionHandler:self
                          typeA:[Note class] typeB:borderType
                          begin:@selector(beginCollision:space:)
                       preSolve:nil
                      postSolve:nil
                       separate:nil
     ];
}

- (bool)beginCollision:(cpArbiter*)arbiter space:(ChipmunkSpace*)space {
	CHIPMUNK_ARBITER_GET_SHAPES(arbiter, noteShape, border);
    ((Note*)(noteShape.data)).body.angle = 0.2; // Hack to get notes that are parallel to wall to bounce off walls.
	return TRUE;
}


#pragma mark - Grid


//empty


#pragma mark - UIScrollView delegate methods

-(UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return _canvas;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
//    if (DEBUG_EDC)
//        [DebugHelper printUIScrollView:scrollView :@"scrollview didZoom"];
    
    // Center content view during zooming.
    ((UIView*)[scrollView.subviews objectAtIndex:0]).frame = [ViewHelper centeredFrameForScrollViewWithNoContentInset:scrollView AndWithContentView: ((UIView*)[scrollView.subviews objectAtIndex:0])];
}

//-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    if (DEBUG_EDC){
//        [DebugHelper printUIScrollView:scrollView :@"scrollview didScroll"];
//        NSLog(@"canvas didScroll %@",_canvas);
//    }
//}

-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale{
    // Center content view during zooming.
    ((UIView*)[scrollView.subviews objectAtIndex:0]).frame = [ViewHelper centeredFrameForScrollViewWithNoContentInset:scrollView AndWithContentView: ((UIView*)[scrollView.subviews objectAtIndex:0])];
    
    // Change stepping.
    double z = _canvasWindow.zoomScale;
    if (CANVAS_WINDOW_ZOOMSCALE_TIER5_UPPER_LIM<z
        && z<=CANVAS_WINDOW_ZOOMSCALE_MAX) {
        _stepping = GRID_TIER6_STEPPING;
        _gridLineThickness = 0.4;
    }else if (CANVAS_WINDOW_ZOOMSCALE_TIER4_UPPER_LIM<z
              && z<= CANVAS_WINDOW_ZOOMSCALE_TIER5_UPPER_LIM){
        _stepping = GRID_TIER5_STEPPING;
        _gridLineThickness = 0.6;
    }else if (CANVAS_WINDOW_ZOOMSCALE_TIER3_UPPER_LIM<z
              && z<= CANVAS_WINDOW_ZOOMSCALE_TIER4_UPPER_LIM){
        _stepping = GRID_DEFAULT_STEPPING;
        _gridLineThickness = 0.8;
    }else if (CANVAS_WINDOW_ZOOMSCALE_TIER2_UPPER_LIM<z
              && z<= CANVAS_WINDOW_ZOOMSCALE_TIER3_UPPER_LIM){
        _stepping = GRID_TIER3_STEPPING;
        _gridLineThickness = 1.8;
    }else if (CANVAS_WINDOW_ZOOMSCALE_TIER1_UPPER_LIM<z
              && z<= CANVAS_WINDOW_ZOOMSCALE_TIER2_UPPER_LIM){
        _stepping = GRID_TIER2_STEPPING;
        _gridLineThickness = 2.5;
    }else if (CANVAS_WINDOW_ZOOMSCALE_MIN<=z
              && z<= CANVAS_WINDOW_ZOOMSCALE_TIER1_UPPER_LIM){
        _stepping = GRID_TIER1_STEPPING;
        _gridLineThickness = 3.2;
    }
    
    // Update view if grid snapping is ON.
    if (_snapToGridEnabled) {
        [_grid removeFromSuperview]; //hide.
        _grid = [[GridView alloc]initWithFrame:CGRectMake(0, 0, _canvas.bounds.size.width, _canvas.bounds.size.height)
                                          Step:_stepping
                                     LineColor:[ViewHelper invColorOf:[_canvas backgroundColor]]
                                     Thickness:_gridLineThickness];
        [_canvas addSubview:_grid]; //Show.
        [_canvas sendSubviewToBack:_grid]; //Don't block notes.
    }
}

#pragma mark - Keyboard Management

- (void)setupKeyboardMgmt {
    // Set up to link to do adjustments when showing and hiding the keyboard.
    // An e.g. of an adjustment is resizing the _canvasWindow to occupy the space above the keyboard when the keyboard is shown.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

-(void)keyboardWillShow:(NSNotification*)notification{
    
    //Move _canvasWindow to show the note being edited. _canvasWindow is resized.
    _canvasWindow.frame=CGRectMake(_canvasWindow.frame.origin.x, _canvasWindow.frame.origin.y, _canvasWindow.frame.size.width, 400);
    
    CGRect rectToBeVisible;
    
    if ([_editNoteTextPlatform isFirstResponder]) {
        //Note is being edited.
        rectToBeVisible = [_noteBeingEdited.view convertRect:CGRectMake(0, 0, _noteBeingEdited.view.frame.size.width, _noteBeingEdited.view.frame.size.height) toView:_canvasWindow];
    }
    else if ([_diagramTitleVC isFirstResponder]){
        //Title is being edited.
        rectToBeVisible = [_diagramTitleVC.view convertRect:CGRectMake(0, 0, _diagramTitleVC.view.frame.size.width, _diagramTitleVC.view.frame.size.height) toView:_canvasWindow];
    }
    
    [_canvasWindow scrollRectToVisible:rectToBeVisible animated:YES]; //Scrollin' time!

}

-(void)keyboardWillHide:(NSNotification*)notification{
    
    //Reinstate _canvasWindow to original size.
    _canvasWindow.frame=CGRectMake(_canvasWindow.frame.origin.x, _canvasWindow.frame.origin.y, _canvasWindow.frame.size.width, _canvasWindowOrigHeight);
}


#pragma mark - Orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if((toInterfaceOrientation == UIDeviceOrientationLandscapeRight) ||
       (toInterfaceOrientation == UIDeviceOrientationLandscapeLeft))
        return YES;
    else
        return NO;
}


#pragma mark - Don't Care

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setCanvasWindow:nil];
    [self setGridSnappingButton:nil];
    [self setUnplacedNotesButton:nil];
    [super viewDidUnload];
}

@end
