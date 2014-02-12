//
//  ProjectSurveysViewController.h
//  VinoCharts
//
//  Created by Hendy Chua on 1/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

/*
 This is a subclass of the SingleProjectViewController class.
 It is used to display all the surveys that is in the attribute thisProject.
 
 It overrides the following methods that are inherited from DisplayTilesViewController:
 -(void)setRightBarButtonToDefaultMode
 -(void)setRightBarButtonToDeletingMode
 -(void)reloadModelsArrayAndRepresentationArray.
 
 It implements the TileControllerDelegate protocol to complete the features to edit, view and delete a survey.
 The delegated methods that it implements are:
 -(void)tileSelected:(id)model;
 -(void)longPressActivated;
 -(void)deleteTile:(id)model;
 -(void)tileToBeEdited:(id)model;
 
 It implements the createSurveyViewControllerDelegation protocol:
 
 -(void)saveSurvey:(Survey*)survey
 When this method is called, a new survey is created and saved to thisProject.
 
 It implements the DisplaySurveyViewControllerDelegate protocol:
 
 -(void)createFeedbackWithTitle:(NSString*)title Question:(NSMutableArray*)questionArray Content:(NSMutableArray*)contentArray
  When this method is called, a new feedback will be saved.
 
 It implements the editSurveyViewControllerDelegation protocol:
 
 -(void)updateSurvey:(Survey*)survey
 When this method is called, survey will be updated in thisProject.

 The user can transit to 3 different features from this View Controller. The segues are:
  -transitToCreateSurvey
 -transitToViewSurvey
 -transitToEditSurvey
 */

#import "SingleProjectViewController.h"
#import "SurveyOverviewViewController.h"
#import "CreateSurveyViewController.h"
#import "EditSurveyViewController.h"
#import "DisplaySurveyViewController.h"
#import "FeedbackViewController.h"
#import "Feedback.h"

@interface ProjectSurveysViewController : SingleProjectViewController <TileControllerDelegate,createSurveyViewControllerDelegation, DisplaySurveyViewControllerDelegate, editSurveyViewControllerDelegation> {
    Survey *surveySelected;
}

@end
