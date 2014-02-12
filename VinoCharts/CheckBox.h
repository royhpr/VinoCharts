//
//  CheckBox.h
//  Checkbox
//
//  Created by Roy Huang Purong on 4/6/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

/*
This class is used by DisplayQuestionViewController as a "multiple answers, multiple choices" option". It prvides multi-select function and update the question
about answers changed.
*/

#import <UIKit/UIKit.h>

@protocol CheckBoxDelegate <NSObject>
- (void)stateChangedForID:(NSUInteger)index WithCurrentState:(BOOL)currentState;
//REQUIRES: the button is tapped
//EFFECTS: update its question about anser changed
@end

@interface CheckBox : UIView
{
	//Instant variables
    NSUInteger  nID;
    UIButton    *btn_CheckBox;
    UITextView     *txt_CheckBox;
   
    id <CheckBoxDelegate> delegate;
}

//each option in one question has its own ID
@property (readwrite, nonatomic) NSUInteger nID;
//check box button which can be tapped by user
@property (strong, nonatomic) UIButton *btn_CheckBox;
//option detail
@property (strong, nonatomic) UITextView *txt_CheckBox;
//delegate object to notify  current question object about changes on options selected
@property (strong, nonatomic) id <CheckBoxDelegate> delegate;

- (id)initWithFrame:(CGRect)frame AndID:(NSUInteger)index AndSelected:(BOOL)state AndTitle:(NSString*)title;
//EFFECTS: create a new check box option with selected state and option detail

- (void)setID:(NSUInteger)index AndSelected:(BOOL)state AndTitle:(NSString*)title;
//EFFECTS: set the index, selected state and title of a check box

- (BOOL)currentState;
//EFFECTS: get the selection state of current option

-(BOOL)isOptionContentEmpty;
//EFFECTS: check if current option detail is empty

-(NSString*)getOptionContent;
//EFFECTS: get the current option detail

-(NSUInteger)getOptionID;
//EFFECTS: get the current option ID from current question

-(void)setOptionID:(NSUInteger)newID;
//EFFECTS: set the current option ID in the current question

-(void)setEditable:(BOOL)flag;
//EFFECTS: enable or disable current option (allow user to tap on current option or not)

@end
