//
//  EditSurveyViewController.h
//  FinalSurvey
//
//  Created by Roy Huang Purong on 4/6/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

/* 
 This class is the custom class of EditSurveyViewController, which resposible for editting survey title and details. It also manages the outlook and logic of
 updating current survey model as well as navigation among different questions
 */

#import <UIKit/UIKit.h>
#import "Survey.h"
#import "EditQuestionViewController.h"
#import "QuestionPopoverViewController.h"

@class EditSurveyViewController;

@protocol editSurveyViewControllerDelegation

-(void)updateSurvey:(Survey*)survey;
//EFFECTS: update the survey model in database with current editted survey model

@end

@interface EditSurveyViewController : UIViewController<UITextViewDelegate,EditQuestionViewControllerDelegate,QuestionPopoverViewControllerDelegate, UITextFieldDelegate>
{
    //Instant variables
    EditQuestionViewController* firstQuestion;
    UIPopoverController* popoverQuestionListController;
    NSMutableArray* questionList;
}

//subview reference IBOutlets
@property (strong, nonatomic) IBOutlet UITextField *txtTitleView;
@property (strong, nonatomic) IBOutlet UITextView *txtDetailView;
@property (strong, nonatomic) IBOutlet UIView *myBackgroundView;


//current survey model
@property (nonatomic,readwrite) Survey* model;
@property (nonatomic,weak)IBOutlet id<editSurveyViewControllerDelegation> delegate;


@end
