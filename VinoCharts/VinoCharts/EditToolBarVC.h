//
//  EditToolBarVC.h
//  VinoCharts
//
//  Created by Lee Jian Yi David on 4/20/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ColorViewController.h"
#import "WEPopoverController.h"

#import "UserOptionsLoadPicker.h"

@protocol EditToolBarVCDelegate

//Internal to a note
-(void)EditToolBarDidPressBoldButton_Name:(NSString*)name;
-(void)EditToolBarDidPressItalicsButton_Name:(NSString*)name;
-(void)EditToolBarDidPressFontButton_Name:(NSString*)name SelectedOption:(NSString *)option;
-(void)EditToolBarDidPressTextColorButton_Name:(NSString*)name SelectedColor:(NSString *)hexColor;
-(void)EditToolBarDidPressNoteColorButton_Name:(NSString*)name SelectedOption:(NSString *)option;
-(void)EditToolBarDidPressDeleteButton_Name:(NSString*)name;

//External to a note
-(void)EditToolBarDidPressVerticalAlignButton_Name:(NSString*)name;
-(void)EditToolBarDidPressHorizAlignButton_Name:(NSString*)name;

@end


@interface EditToolBarVC : NSObject
<WEPopoverControllerDelegate,
ColorViewControllerDelegate,
UserOptionsLoadPickerDelegate>

-(id)initForEditingSingleNotesWithToolBarName:(NSString*)name;
//EFFECT: ctor. Name is set only once - at the start.

-(void)setDelegate:(id)delegate;
//EFFECT: sets delegate.

-(void)addToSuperView:(UIView*)superV;
//EFFECT: adds this toolbar to superV.

-(void)showForEditingSingleNote;
//EFFECT: Shows the toolbar and configs bar's buttons for editing a single note.

-(void)showForEditingMultipleNotes;
//EFFECT: Shows the toolbar and configs bar's buttons for editing multiple note.

-(int)boldButtonPressCounts;
//EFFECT: Returns the number of times the bold button has been pressed since the toolbar was shown.

-(int)italicsButtonPressCounts;
//EFFECT: Returns the number of times the italics button has been pressed since the toolbar was shown.

-(void)hide;
//EFFECT: Hides the toolbar

-(NSString*)name;
//EFFECT: returns name of toolbar

@end
