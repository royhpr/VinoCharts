//
//  ProjectDiagramsViewController.h
//  VinoCharts
//
//  Created by Hendy Chua on 1/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

/*
 This is a subclass of the SingleProjectViewController class.
 It is used to display all the diagrams that is in the attribute thisProject.
 
 It overrides the following methods that are inherited from DisplayTilesViewController:
 -(void)setRightBarButtonToDefaultMode
 -(void)setRightBarButtonToDeletingMode
 -(void)reloadModelsArrayAndRepresentationArray.
 
 It implements the TileControllerDelegate protocol to complete the features to edit, view and delete a survey. The delegated methods that it implements are:
 -(void)tileSelected:(id)model;
 -(void)longPressActivated;
 -(void)deleteTile:(id)model;
 
 It implements the EditDiagramControllerDelegate protocol:
 
 -(void)saveANewDiagram:(Diagram *)diagram
 When this method is called, a new diagram will be saved to thisProject.
 
 -(void)updateDiagram:(Diagram*)diagram
 When this method is called, diagram will be updated and saved in thisProject.

 The user can transit to view a diagram or create one in this view controller. The segues are:
 -transitToViewSelectedDiagram
 -transitToCreateDiagram
 */

#import "SingleProjectViewController.h"
#import "DiagramOverviewViewController.h"
#import "EditDiagramController.h"

@interface ProjectDiagramsViewController : SingleProjectViewController <TileControllerDelegate,EditDiagramControllerDelegate> {
    Diagram *diagramSelected;
}

@end
