//
//  CreateSurveyViewController.h
//  FinalSurvey
//
//  Created by Roy Huang Purong on 4/6/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

/*
 This is custom class of Create Survey ViewController. It is used to organize the logic and outlook of survey
 title and details. This is the first interface of survey creation.
 */

#import <UIKit/UIKit.h>
#import "CreateQuestionViewController.h"
#import "Survey.h"
#import "QuestionPopoverViewController.h"

@class CreateSurveyViewController;

@protocol createSurveyViewControllerDelegation

-(void)saveSurvey:(Survey*)survey;
//REQUIRES: survey object is not nil or null. This method can only be called when all the mandotary fields in each question are filled
//EFFECTS: it circulate the current survey model info to project level, the current project will create and store this new survey model to
//         current database 

@end

@interface CreateSurveyViewController : UIViewController<CreateQuestionViewControllerDelegate,UITextViewDelegate,QuestionPopoverViewControllerDelegate, UITextFieldDelegate>
{
    //instants variables used to stored tentative info
    CreateQuestionViewController* firstQuestion;
    UIPopoverController* popoverQuestionListController;
    NSMutableArray* questionList;
}

//Views reference IBOutlet
@property (strong, nonatomic) IBOutlet UITextField *txtTitleView;
@property (strong, nonatomic) IBOutlet UITextView *txtDetailView;
@property (strong, nonatomic) IBOutlet UIView *myBackgroundView;

//Properties
//model: Model of current survey, it can be updated by delegate methods in question level
//delegate: this delegate object builds up the communication path between survey level and project level. It comes handy whenever there is a need to notify project level
@property (nonatomic,readwrite) Survey* model;
@property (nonatomic,weak)IBOutlet id<createSurveyViewControllerDelegation> delegate;

@end
