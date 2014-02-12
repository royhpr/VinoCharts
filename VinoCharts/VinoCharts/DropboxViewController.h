//
//  DropboxViewController.h
//  VinoCharts
//
//  Created by Ang Civics on 30/3/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//
/*  
 This is a singleton class that hold method related to sync with dropbox. 
 This table view controller is used to let user view the file and folder exist in dropbox vinochart app folder only. 
 It handle traditional swipe gesture deletion, that delete the file at dropbox, user can also view the image file and download the persistentStore data file to merge as local project.
*/

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>
#import "DropboxImageViewController.h"
#import "CoreDataConstant.h"

@protocol DropboxDelegate <NSObject>
-(void)accountInfoLoaded:(NSString*)userName;
//REQUIRES: delegate set up correctly and loadDropboxAccountInfo method is called
//EFFECTS: provide corresponding account user username for display.
@end

@protocol DropboxSyncDelegate <NSObject>
-(void)syncDone;
//REQUIRES: delegate set up correctly
//EFFECTS: to notify that upload file is done
@end

@interface DropboxViewController : UITableViewController<DBRestClientDelegate, UIAlertViewDelegate>

@property(nonatomic) DBRestClient *restClient;
@property DBMetadata* metadata;

@property id<DropboxDelegate> delegate;
@property id<DropboxSyncDelegate> syncDelegate;

+(id)sharedDropbox;
//Singleton object

- (id)initWithPath:(NSString*)path;
//REQUIRES: the path is valid path at dropbox
//EFFECTS: The metadata file at the corresponding will be loaded if internet connection is normal

- (void)uploadFileAtTemporaryDirectoryToFolder:(NSString*)folderName;
//REQUIRES: File exist inside folder at local path: tmp/folderName
//EFFECTS: will upload all file at tmp/folderName directory to corresponding folder at dropbox.
//          Will create a new folder in dropbox with the folderName if the folder does not exist.

- (void)loadDropboxAccountInfo;
// REQUIRE: user is linked to dropbox account already
// EFFECTS: current dropbox user account info loaded

@end
