//
//  DisplayQuestionViewController.h
//  FinalSurvey
//
//  Created by Roy Huang Purong on 4/6/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

/*
This is the custom class of DisplayQuestionViewController. It simply displays individual question in one survey.
User is able to answer three different types of question: 1) Open ended (1000 characters)
														  2) Radio button (Single answer, multiple choices)
														  3) Check box (multiple answers, multiple choices)
*/

#import <UIKit/UIKit.h>
#import "RadioButton.h"
#import "CheckBox.h"
#import "Constants.h"
#import <QuartzCore/QuartzCore.h>
#import "QuestionPopoverViewController.h"
#import "Survey.h"

@class DisplayQuestionViewController;

@protocol DisplayQuestionViewControllerDelegate

-(int)getNumberOfQuestion;
//EFFECTS: get the amount of questions in current survey

-(NSArray*)getQuestionInfoFromModelWithIndex:(int)index;
//EFFECTS: retrieve current a specific question data from current survey model

-(void)addAnswerWith:(NSMutableArray*)ans WithIndex:(int)questionIndex;
//EFFECTS: add answer of a specific question to a answer array list

-(void)finishSurveyWithFeedBackTitle:(NSString*)title;
//EFFECTS: generate a feedback to the current project when user ansers all the questions in current survey

-(NSMutableArray*)isAllAnswered;
//EFFECTS: check if all questions in current survey are answered 

-(void)returnToMainInterface;
//EFFECTS: dismiss current question view and return to project view when quite button is tapped

@end

@interface DisplayQuestionViewController : UIViewController<RadioButtonDelegate,CheckBoxDelegate,UIAlertViewDelegate,QuestionPopoverViewControllerDelegate,UITextViewDelegate>
{
	//Instant variables
    UITextView* activeView;
    int QuestionIndex;
    
    NSString* questionTitle;
    NSString* questionType;
    NSMutableArray* optionContentArray;
    
    NSMutableArray* answerList;
    
    UIPopoverController* popoverQuestionListController;
    NSMutableArray* questionList;
    
    NSMutableArray* returnedUnansweredQuestionList;
}


#pragma constructor
-(id)initWithQuestionIndex:(int)index;
//EFFECTS: create a new question with specific question number and show it in non-editable mode
#pragma end

#pragma Model
//current survey model, used to retrieve survey data and show it in both survey and question interfaces
@property(nonatomic,readwrite)Survey* model;
#pragma end

#pragma Properties
//double linked list, used to navigate among different quesitons
@property(nonatomic,readwrite)DisplayQuestionViewController* previousController;
@property(nonatomic,readwrite)DisplayQuestionViewController* nextController;

@property(nonatomic,weak)IBOutlet id<DisplayQuestionViewControllerDelegate> delegate;
#pragma end

#pragma IBOutlets
//Subviewes reference IBOutlets
@property (strong, nonatomic) IBOutlet UILabel *lblQuestionNumber;
@property (strong, nonatomic) IBOutlet UITextView *txtQuestionTitle;
@property (strong, nonatomic) IBOutlet UITextView *txtOpenEndEntry;
@property (strong, nonatomic) IBOutlet UIView *vwCanvas;
#pragma end


#pragma Methods
-(NSMutableArray*)getTheMatchedControllerWithIndex:(int)index controllerArray:(NSMutableArray*)currentControllerArray;
//EFFECTS: return a matched DisplayQuestionViewController data

-(void)pushToDestinatedControllerWithIndex:(int)index;
//EFFECTS: push next controllers until the specific controller with index

-(void)popToDestinationControllerWithIndex:(int)index;
//EFFECTS: pop to previous controllers until the specific controller with index
#pragma end

@end
