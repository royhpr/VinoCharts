//
//  NewDiagramController.h
//  vinocharts_diagrams
//
//  Created by Lee Jian Yi David on 3/25/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GridView;
#import "ProjectDiagramsViewController.h"

@interface NewDiagramController : UIViewController <UITextFieldDelegate>

/*properties*/
@property (readwrite) double height;
@property (readwrite) double width;
@property (readwrite, nonatomic, weak) IBOutlet id<EditDiagramControllerDelegate>projectDiagramsVC;

/*Actions*/
- (IBAction)dismissView:(id)sender;

/*Outlets*/
@property (weak, nonatomic) IBOutlet UITextField *heightIO;
@property (weak, nonatomic) IBOutlet UITextField *widthIO;
@property (weak, nonatomic) IBOutlet UITextField *titleIO;


@end
