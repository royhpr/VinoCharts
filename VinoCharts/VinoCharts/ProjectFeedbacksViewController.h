//
//  ProjectFeedbacksViewController.h
//  VinoCharts
//
//  Created by Hendy Chua on 1/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

/*
 This is a subclass of the SingleProjectViewController class.
 It is used to display all the feedbacks that is in the attribute thisProject.
 
 It overrides the following methods that are inherited from DisplayTilesViewController:
 -(void)setRightBarButtonToDefaultMode
 -(void)setRightBarButtonToDeletingMode
 -(void)reloadModelsArrayAndRepresentationArray.
 
 It implements the TileControllerDelegate protocol to complete the features to edit, view and delete a survey. The delegated methods that it implements are:
 -(void)tileSelected:(id)model;
 -(void)longPressActivated;
 -(void)deleteTile:(id)model;
 
 It implements the FeedbackViewControllerDelegate protocol:
 
 -(void)CreateNoteWithContent:(NSString*)content InDiagramIndex:(NSInteger)index
 When this method is called, a note object with content will be created and stored in the diagram specified by index in thisProject’s diagrams array.
 
 -(NSArray*)CreateAndReturnListOfDiagramsDiagramNamed:(NSString*)name
 When this method is called, it returns a double array. The first nested array is an array of diagram names present in thisProject. The second array contains the number (converted to NSString*) of notes that can be created in the respective diagrams. It will return nil if there are no diagrams in thisProject.

 The user can transit to view a feedback in this view controller. The segue is:
 -transitToViewFeedback
 */

#import "SingleProjectViewController.h"
#import "FeedbackOverviewViewController.h"
#import "FeedbackViewController.h"

@interface ProjectFeedbacksViewController : SingleProjectViewController <TileControllerDelegate, FeedbackViewControllerDelegate> {
    Feedback *feedbackSelected;
}

@end
