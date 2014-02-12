//
//  SingleProjectViewController.h
//  VinoCharts
//
//  Created by Hendy Chua on 30/3/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

/*
 This is a superclass that helps to define all the view controllers in the Single Project Tab Bar View Controller.
 It is also a subclass of the DisplayTilesViewController class as the subclasses of this class might need to hold a scroll view with multiple tile views.
 
 The purpose for this class is to hold an attribute (Project *) thisProject. All the view controllers in the tab bar controller group will inherit this class and hold this attribute. When a user taps a single project in the All Projects View, this attribute will be set in the prepareSegue Method in AllProjectsViewController by looping through all the view controllers in the destination tab bar controller and casting them to SingleProjectViewController (since they all inherit from this class).
 */

#import <UIKit/UIKit.h>
#import "Project.h"
#import "Survey.h"
#import "Feedback.h"
#import "Diagram.h"
#import <QuartzCore/QuartzCore.h>
#import "CreateSurveyViewController.h"
#import "SurveyOverviewViewController.h"
#import "Constants.h"
#import "DisplayTilesViewController.h"
#import "DropboxViewController.h"

@interface SingleProjectViewController : DisplayTilesViewController

- (void)setProject:(Project*)p;

//for core data
@property NSManagedObjectContext* context;

@property (strong, nonatomic) Project *thisProject;

@end
