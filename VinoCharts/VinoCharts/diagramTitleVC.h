//
//  diagramTitleViewController.h
//  VinoCharts
//
//  Created by Lee Jian Yi David on 4/18/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol diagramTitleViewControllerDelegate

@end

@interface diagramTitleVC : NSObject <UITextViewDelegate>

@property (readonly, nonatomic, weak) UIView* sheet;
@property (readonly) UITextView* view;

-(id)initDefaultOn:(UIView*)mySheet;
//EFFECT: ctor

-(id)initWith:(NSString*)myText AndAllElseDefaultOn:(UIView*)mySheet;
//EFFECT: ctor

-(void)invitesUserToEdit;
//EFFECT: Expands the textview so that user can edit to the left and right edges of _sheet.
//      Typically called just before the user is given the keyboard to edit the contents of this textview.

-(void)housekeep;
//EFFECT: Positions and shrinks the frame to appropriate dimensions.
//      Typically called after the user is done editing the contents of this textview.

-(void)setTextColorWIthGZColorHexValue:(NSString*)mygzcolorhexvalue;
//EFFECT: Sets text color

-(void)setTextColor:(UIColor*)myColor;
//EFFECT: Sets text color

-(void)setBackgroundColor:(UIColor*)myColor;
//EFFECT: Sets background color

-(BOOL)isFirstResponder;
//EFFECT: Returns YES if _textview isFirstResponder. Returns NO otherwise.

-(NSString*)text;
//EFFECT: Returns the text inside the UITextView.

-(void)remove;
//EFFECT: Removes the view from superview.

@end
