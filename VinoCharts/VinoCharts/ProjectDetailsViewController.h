//
//  ProjectDetailsViewController.h
//  VinoCharts
//
//  Created by Hendy Chua on 1/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

/*
 This is a subclass of the SingleProjectViewController class.
 It is used to display basic project details e.g. title and details. User can tap on the title textfield or details textview to edit them.
 
 It overrides the following methods that are inherited from DisplayTilesViewController:
 -(void)setRightBarButtonToDefaultMode.

*/

#import "SingleProjectViewController.h"
#import <QuartzCore/QuartzCore.h>

@protocol ProjectDetailsDeletegate <NSObject>

-(BOOL)projectTitleTaken:(NSString*)projectTitle CompareWithThisProject:(Project*)proj;

@end

@interface ProjectDetailsViewController : SingleProjectViewController <FileCreatedDelegate, UITextFieldDelegate,DropboxSyncDelegate> {
    BOOL wantToDisplayInEditMode;
    BOOL saveUnsuccessful;
}

@property (strong, nonatomic) IBOutlet UITextField *titleTextField;
@property (strong, nonatomic) IBOutlet UITextView *detailsTextView;
@property (nonatomic) id<ProjectDetailsDeletegate> delegate;

- (IBAction)saveNewDetails:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *saveBtn;
@property (strong, nonatomic) IBOutlet UILabel *feedbackNumberLbl;
@property (strong, nonatomic) IBOutlet UILabel *diagramNumberLbl;
@property (strong, nonatomic) IBOutlet UILabel *surveyNumberLbl;

-(void)setWantToDisplayInEditModeWithBool:(BOOL)b;
// Requires: a boolean b
// Effects: If b is YES, this view will be loaded in editmode where the title textfield will be the first responder,
//          keyboard will be shown, save button will be shown and user cannot change views until he saves the changes.
//          If b is no, this view will be loaded in view mode.

@end
