//
//  DiagramListViewController.h
//  FinalSurvey
//
//  Created by Roy Huang Purong on 4/9/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

/*
This class works as a popover which contains a list of diagram names available in current project. It also allows user to create a new diagram.
*/

#import <UIKit/UIKit.h>

@class DiagramListViewController;

@protocol DiagramListViewControllerDelegate

-(void)updateButtonTitleWithIndex:(int)index;
//EFFECTS: update the title of diagram button according to the selected diagram

-(void)createNewDiagram;
//EFFECTS: create a new diagram
@end

@interface DiagramListViewController : UITableViewController
{
    NSMutableArray* diagramList;
}

@property(nonatomic,weak)IBOutlet id<DiagramListViewControllerDelegate> delegate;

-(id)initWithDiagramList:(NSArray*)list;
//EFFECTS: initialize the content of table view with a list of diagram name

@end
