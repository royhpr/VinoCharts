//
//  AllProjectsViewController.h
//  VinoCharts
//
//  Created by Hendy Chua on 24/3/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

/*
 This is a subclass of DisplayTilesViewController.
 Refer to DisplayTilesViewController documentation for details on what it does. It also implements the
 TileControllerDelegate (see TileViewController for details) to create the features of selecting and deleting a project.

 User is able to transit to view a single project from this view. The segue is: 
 - transToSingleProjectView
 User can do this by tapping on a project or by creating one new project.
 
 There are no public methods in this class.
 
 */
#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>
#import "Model.h"
#import "UserOptionsLoadPicker.h"
#import "ProjectOverviewViewController.h"
#import "SingleProjectViewController.h"
#import "DisplayTilesViewController.h"
#import "DropboxViewController.h"
#import "ProjectDetailsViewController.h"

#import "PreviewDiagramViewController.h"

@interface AllProjectsViewController : DisplayTilesViewController <ProjectDetailsDeletegate, UserOptionsLoadPickerDelegate, TileControllerDelegate, ModelDelegate, DropboxDelegate> {
    UserOptionsLoadPicker *optionsPicker;
    UIPopoverController *optionsPickerPopOver;
    Project *selectedProject;
    BOOL transitToNewProject;// to keep track if user is tapping on an existing project or going to create a new one
}

@property (nonatomic) UserOptionsLoadPicker *optionsPicker;
@property (nonatomic) UIPopoverController *optionsPickerPopOver;

//for core data
@property Model* model;
@property (nonatomic)UIActivityIndicatorView *indicator;

@end
