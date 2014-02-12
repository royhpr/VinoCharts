//
//  EditToolBarVC.m
//  VinoCharts
//
//  Created by Lee Jian Yi David on 4/20/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "EditToolBarVC.h"
#import "Constants.h"

#import "ColorViewController.h"
#import "WEPopoverController.h"

#import "UserOptionsLoadPicker.h"

@interface EditToolBarVC ()

@property(readwrite) UIToolbar* view;
@property(readwrite, nonatomic) NSString* name;
@property (readwrite, nonatomic, weak) IBOutlet id delegate;

//Counters to count button presses.
@property (readwrite) int boldButtonPressCnt;
@property (readwrite) int italicsButtonPressCnt;

// Different button arrays for different purposes.
// 1. Editing single note
@property(readwrite) NSArray *singleNoteConfig;
// 2. Editing multiple notes
@property(readwrite) NSArray *multipleNotesConfig;

// Font Color
@property (nonatomic, strong) WEPopoverController *wePopoverController;
// Font Family
@property (readwrite) UserOptionsLoadPicker* fontPicker;
// Note's material
@property (readwrite) UserOptionsLoadPicker* materialPicker;
// Droplist Popover controller
@property (nonatomic) UIPopoverController *optionsPickerPopOver;

@end





@implementation EditToolBarVC

-(id)initForEditingSingleNotesWithToolBarName:(NSString*)name{
    _view = [[UIToolbar alloc]init];
    _view.frame = CGRectMake(0, 0, 1024, 44);
    _name = [NSString stringWithString:name];
    
    UIBarButtonItem *boldButton = [[UIBarButtonItem alloc]initWithTitle:@"B" style:UIBarButtonItemStyleBordered target:self action:@selector(didPressBoldButton:)];
    UIBarButtonItem *italicsButton = [[UIBarButtonItem alloc]initWithTitle:@"I" style:UIBarButtonItemStyleBordered target:self action:@selector(didPressItalicsButton:)];
    UIBarButtonItem *fontButton = [[UIBarButtonItem alloc]initWithTitle:@"Font" style:UIBarButtonItemStyleBordered target:self action:@selector(didPressFontButton:Event:)];
    UIBarButtonItem *textColorButton = [[UIBarButtonItem alloc]initWithTitle:@"Text Color" style:UIBarButtonItemStyleBordered target:self action:@selector(didPresstextColorButton:Event:)];
    UIBarButtonItem *noteColorButton = [[UIBarButtonItem alloc]initWithTitle:@"Note Color" style:UIBarButtonItemStyleBordered target:self action:@selector(didPressNoteMaterialButton:Event:)];
    UIBarButtonItem *deleteNoteButton = [[UIBarButtonItem alloc]initWithTitle:@"Delete" style:UIBarButtonItemStyleBordered target:self action:@selector(didPressDeleteNoteButton:)];
    UIBarButtonItem *verticalAlignButton = [[UIBarButtonItem alloc]initWithTitle:@"Align Vertically" style:UIBarButtonItemStyleBordered target:self action:@selector(didPressverticalAlignButton:)];
    UIBarButtonItem *horizontalAlignButton = [[UIBarButtonItem alloc]initWithTitle:@"Align Horizontally" style:UIBarButtonItemStyleBordered target:self action:@selector(didPresshorizontalAlignButton:)];
    
    //Initialise different button configurations
    _singleNoteConfig = [NSArray arrayWithObjects:boldButton,italicsButton,fontButton,textColorButton,noteColorButton,deleteNoteButton, nil];
    _multipleNotesConfig = [NSArray arrayWithObjects:boldButton,italicsButton,fontButton,textColorButton,noteColorButton,verticalAlignButton,horizontalAlignButton,deleteNoteButton, nil];
    
    
    /*Initialise popover views*/
    // Material Picker
    _materialPicker = [[UserOptionsLoadPicker alloc]
                       initWithOptions:[[NSArray alloc] initWithObjects:
                                        NOTE_MATERIAL_BLUE_PAPER_PRETTYNAME,
                                        NOTE_MATERIAL_GREEN_PAPER_PRETTYNAME,
                                        NOTE_MATERIAL_RED_PAPER_PRETTYNAME,
                                        NOTE_MATERIAL_WHITE_PAPER_PRETTYNAME,
                                        NOTE_MATERIAL_YELLOW_PAPER_PRETTYNAME,nil]];
    _materialPicker.delegate = self;
    
    // Font Picker
    self.fontPicker = [[UserOptionsLoadPicker alloc]
                       initWithOptions:[[NSArray alloc] initWithObjects:fBASKERVILLE,fCOCHIN,fGEORGIA,fGILLSANS,fHELVETICA_NEUE,fVERDANA,nil]];
    self.fontPicker.delegate = self;
    
    return self;
}



-(void)setDelegate:(id)delegate{
    _delegate = delegate;
}

-(void)addToSuperView:(UIView*)superV{
    [superV addSubview:_view];
}

-(void)showForEditingSingleNote{
    _boldButtonPressCnt = 0; _italicsButtonPressCnt = 0;
    [_view setItems:_singleNoteConfig];
    [_view setHidden:NO];
}

-(void)showForEditingMultipleNotes{
    _boldButtonPressCnt = 0; _italicsButtonPressCnt = 0;
    [_view setItems:_multipleNotesConfig];
    [_view setHidden:NO];
}

-(int)boldButtonPressCounts{
    return _boldButtonPressCnt;
}

-(int)italicsButtonPressCounts{
    return _italicsButtonPressCnt;
}

-(void)hide{
    [_view setHidden:YES];
}

-(NSString*)name{
    return _name;
}


// -------------------------------------------------------
#pragma mark - BUTTON ACTIONS
// -------------------------------------------------------


// Bold
- (IBAction)didPressBoldButton:(id)sender{
    ++_boldButtonPressCnt;
    [_delegate EditToolBarDidPressBoldButton_Name:_name];
}


// Italics
- (IBAction)didPressItalicsButton:(id)sender{
    ++_italicsButtonPressCnt;
    [_delegate EditToolBarDidPressItalicsButton_Name:_name];
}


// Font
- (IBAction)didPressFontButton:(id)sender Event:(UIEvent*)event{
    self.optionsPickerPopOver = [[UIPopoverController alloc]
                                 initWithContentViewController:self.fontPicker];
    
    [self.optionsPickerPopOver presentPopoverFromRect:[[event.allTouches anyObject] view].frame
                                               inView:self.view
                             permittedArrowDirections:UIPopoverArrowDirectionUp
                                             animated:YES];
    
    [self.optionsPickerPopOver setPopoverContentSize:CGSizeMake(150,270) animated:NO];
}




// Text Color
- (IBAction)didPresstextColorButton:(id)sender Event:(UIEvent*)event{
    if (!self.wePopoverController) {
        
		ColorViewController *contentViewController = [[ColorViewController alloc] init];
        contentViewController.delegate = self;
		self.wePopoverController = [[WEPopoverController alloc] initWithContentViewController:contentViewController];
		self.wePopoverController.delegate = self;
        
		[self.wePopoverController presentPopoverFromRect:[[event.allTouches anyObject] view].frame
                                                  inView:self.view
                                permittedArrowDirections:(UIPopoverArrowDirectionUp|UIPopoverArrowDirectionDown)
                                                animated:YES];
        
	} else {
		[self.wePopoverController dismissPopoverAnimated:YES];
        self.wePopoverController = nil;
	}
}

-(void) colorPopoverControllerDidSelectColor:(NSString *)hexColor{
    [_delegate EditToolBarDidPressTextColorButton_Name:_name SelectedColor:hexColor];
}

- (void)popoverControllerDidDismissPopover:(WEPopoverController *)thePopoverController {
	//Safe to release the popover here
	self.wePopoverController = nil;
}

- (BOOL)popoverControllerShouldDismissPopover:(WEPopoverController *)thePopoverController {
	//The popover is automatically dismissed if you click outside it, unless you return NO here
	return YES;
}


//Note Color (AKA Material)
- (IBAction)didPressNoteMaterialButton:(id)sender Event:(UIEvent*)event{
    
    _optionsPickerPopOver = [[UIPopoverController alloc]
                             initWithContentViewController:_materialPicker];
    
    [_optionsPickerPopOver presentPopoverFromRect:[[event.allTouches anyObject] view].frame
                                           inView:self.view
                         permittedArrowDirections:UIPopoverArrowDirectionUp
                                         animated:YES];
    
    [_optionsPickerPopOver setPopoverContentSize:CGSizeMake(120,220) animated:NO];
}


//Delete
- (IBAction)didPressDeleteNoteButton:(id)sender{
    [_delegate EditToolBarDidPressDeleteButton_Name:_name];
}


//Vertical alignment
- (IBAction)didPressverticalAlignButton:(id)sender{
    [_delegate EditToolBarDidPressVerticalAlignButton_Name:_name];
}

//Horizontal alignment
- (IBAction)didPresshorizontalAlignButton:(id)sender{
    [_delegate EditToolBarDidPressHorizAlignButton_Name:_name];
}


// Options Picker Popover delegate method
-(void)optionSelected:(NSString *)option{
    if ([_optionsPickerPopOver.contentViewController isEqual:_fontPicker]) { // If _fontPicker is the popover.
        
        [_delegate EditToolBarDidPressFontButton_Name:_name SelectedOption:option];
    }
    
    else if ([_optionsPickerPopOver.contentViewController isEqual:_materialPicker]){ // If _materialPicker is the popover.
        [_delegate EditToolBarDidPressNoteColorButton_Name:_name SelectedOption:option];
    }
    
}

@end


