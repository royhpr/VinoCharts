//
//  CreateQuestionViewController.h
//  FinalSurvey
//
//  Created by Roy Huang Purong on 4/6/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

/*
 This class is used as custom class of create Question view controller. It simply manages the outlook and logic of each quesion.
 It also allows user to navigate from one question to another. It contains three different types of quesion, namely "Open Ended", 
 "Radio Button (Multiple Choice, Single Answer)", "Check Box (Multiple Choice, Multiple Answer)". 
 */

#import <UIKit/UIKit.h>
#import "Question.h"
#import "Constants.h"
#import <QuartzCore/QuartzCore.h>
#import "QuestionPopoverViewController.h"

@class CreateQuestionViewController;

@protocol CreateQuestionViewControllerDelegate

-(void)createEmptyQuestionModel;
//EFFECTS: a empty question model is created and attached to curren survey model

-(void)removeCurrentQuestionModel:(int)index;
//EFFECTS: a specific questio model with location index is removed from current survey model

-(void)updateQuestionToSurveyWithTitle:(NSString*)title Type:(NSString*)type Options:(NSMutableArray*)optionList Index:(int)index;
//EFFECTS: a existing question model in current survey model is updated with required info

-(void)finishEditingSuvey;
//EFFECTS: current quesition interface is dismissed and current question model is saved to current survey model. current survey model
//         current survey model is saved to database

-(int)getNumberOfQuestion;
//EFFECTS: get the total number of questions available in current survey

-(void)changeFirstQuestion:(CreateQuestionViewController*)sender;
//EFFECTS: the firstQuestion instant variable in CreateSurveyViewController is assigned to current CreateQuestionViewController object

-(NSArray*)getQuestionInfoFromModelWithIndex:(int)index;
//EFFECTS: the info of a specific question is fetch from its survey model.

@end

@interface CreateQuestionViewController : UIViewController<UITextViewDelegate,QuestionPopoverViewControllerDelegate>
{
    //Instant variables
    NSArray* typeList;
    UITextView* activeView;
    int QuestionIndex;
    
    NSString* questionTitle;
    NSString* questionType;
    NSMutableArray* optionContentArray;
    
    UIPopoverController* popoverQuestionListController;
    NSMutableArray* questionList;
}

-(id)initWithQuestionIndex:(int)index;
//EFFECTS: create a new CreateQuestionViewController object with a question number


//works as double linked list
//used to navigate among questions
@property(nonatomic,readwrite)CreateQuestionViewController* previousController;
@property(nonatomic,readwrite)CreateQuestionViewController* nextController;

@property(nonatomic,weak)IBOutlet id<CreateQuestionViewControllerDelegate> delegate;

//buttons to be shown on the toobar above keyboard, which is used to navigate among options
@property (nonatomic, retain) UIView *inputAccView;
@property (nonatomic, retain) UIButton *btnDone;
@property (nonatomic, retain) UIButton *btnNext;
@property (nonatomic, retain) UIButton *btnPrev;


//subviews reference IBOutlets
@property (strong, nonatomic) IBOutlet UIScrollView *myCanvasView;
@property (strong, nonatomic) IBOutlet UITextView *titleView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *typePicker;
@property (strong, nonatomic) IBOutlet UIScrollView *optionArea;
@property (strong, nonatomic) IBOutlet UILabel *lblDescription;

//segmented control action method
- (IBAction)typePickerSelected:(id)sender;

-(void)saveCurrentQuestionAndSubsequentQuestions;
//EFFECTS: all questions are saved to current survey model

-(BOOL)isMandotaryFieldsOfAllQuestionsFilled;
//EFFECTS: check if mandotary fields of all question are filled.

-(NSMutableArray*)getTheMatchedControllerWithIndex:(int)index controllerArray:(NSMutableArray*)currentControllerArray;
//EFFECTS: get a specific question based on the location index provided.

-(void)pushToDestinationControllerWithIndex:(int)index;
//EFFECTS: push a specific CreatQuestionViewController to current navigation controller stack

-(void)popToDestinationControllerWithIndex:(int)index;
//EFFECTS: pop to a specific CreatQuestionViewController from current navigation controller stack
@end
