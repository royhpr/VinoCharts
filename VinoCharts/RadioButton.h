//
//  RadioButton.h
//  RadioButton
//
//  Created by Roy Huang Purong on 4/6/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RadioButton;
@protocol RadioButtonDelegate <NSObject>
- (void)stateChangedForGroupID:(NSUInteger)indexGroup WithSelectedButton:(NSUInteger)indexID;
//EFFECTS: update the answer of current question about changes on option
@end

@interface RadioButton : UIView
{
	//Instant variables
    NSUInteger  nID;
    NSUInteger  nGroupID;
    UIButton    *btn_RadioButton;
    UITextView     *txt_RadioButton;
    
    id <RadioButtonDelegate> delegate;
}

//each option has its own ID
@property (readwrite, nonatomic) NSUInteger nID;
//each question has its own group ID which identifies a set of option IDs
@property (readwrite, nonatomic) NSUInteger nGroupID;
//radio button can be tapped by user to change option
@property (strong, nonatomic) UIButton *btn_RadioButton;
//option detail
@property (strong, nonatomic) UITextView *txt_RadioButton;
//delegate object to invoke method to update the answer for current question when selection state of one option is changed
@property (strong, nonatomic) id <RadioButtonDelegate> delegate;

- (id)initWithFrame:(CGRect)frame AndGroupID:(NSUInteger)indexGroup AndID:(NSUInteger)indexID AndTitle:(NSString*)title;
//EFFECTS: create a radio button option with group ID, its own ID and option details

- (void)setGroupID:(NSUInteger)indexGroup AndID:(NSUInteger)indexID AndTitle:(NSString*)title;
//EFFECTS: set group ID, its own Id and options details of current option

+ (NSUInteger)selectedIDForGroupID:(NSUInteger)indexGroup;
//EFFECTS: get the ID of selected option in current question

-(BOOL)isOptionContentEmpty;
//EFFECTS: check if current option detail is empty

-(NSString*)getOptionContent;
//EFFECTS: get the details of current option

-(NSUInteger)getOptionID;
//EFFECTS: get current option ID

-(void)setOptionID:(NSUInteger)newID;
//EFFECTS: set current option ID

-(void)setEditable:(BOOL)flag;
//allow or disallow user to tap on current option

@end
