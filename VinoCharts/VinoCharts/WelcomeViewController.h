//
//  WelcomeViewController.h
//  VinoCharts
//
//  Created by Hendy Chua on 23/3/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

/*
 The WelcomeViewController displays the initial view that users will see whenever they turn on the app and are not signed in to a
 Dropbox account.
 
 The only transition from this view is to the AllProjectsViewController. User can do this by either syncing with a Dropbox account
 (which brings them to the AllProjects view after authentication is successful) or choosing to proceed without syncing a Dropbox
 account.
 
 This module uses a singleton instance of DBSesson which is provided by the Dropbox iOS SDK to verify the user’s Dropbox account.
 
 There are no public methods in this module.
*/

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>

@interface WelcomeViewController : UIViewController

@property (strong, nonatomic) UIButton *syncButton;
@property (strong, nonatomic) UIButton *proceedButton;


@end
