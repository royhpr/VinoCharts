//
//  DropboxViewController.m
//  VinoCharts
//
//  Created by Ang Civics on 30/3/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "DropboxViewController.h"

@interface DropboxViewController ()

@property NSString* currentPath;

@end

@implementation DropboxViewController

static DropboxViewController* sharedDropbox = nil;

+(DropboxViewController*)sharedDropbox{
    if(sharedDropbox == nil){
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedDropbox = [[DropboxViewController alloc] initWithPath:DROPBOX_ROOT_PATH];
        });
    }
    return sharedDropbox;
}

//must to access dropbox
@synthesize restClient;
- (DBRestClient *)restClient {
    if (!restClient) {
        restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithPath:(NSString*)path{
    self.currentPath = path;
    [self.restClient loadMetadata:self.currentPath];
    [self cleanTemporaryDirectory];
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    if(!self.currentPath){
        self.currentPath = DROPBOX_ROOT_PATH;// situation when push with storyboard
    }
    
    [[self restClient] loadMetadata:self.currentPath];
    
}

-(void)setNavBar {
    NSString *controllerTitle = @"Dropbox Files";
    UILabel *navBarTitle = (UILabel *)self.navigationItem.titleView;
    if (!navBarTitle) {
        navBarTitle = [[UILabel alloc] initWithFrame:CGRectZero];
        navBarTitle.backgroundColor = [UIColor clearColor];
        navBarTitle.font = [UIFont boldSystemFontOfSize:20.0];
        navBarTitle.textColor = [UIColor whiteColor];
        [navBarTitle setText:controllerTitle];
        [navBarTitle sizeToFit];
        self.navigationItem.titleView = navBarTitle;
    }
    
    // Set the right bar button
    [self.navigationItem setRightBarButtonItem:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated {
    
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationItem.title = [self.currentPath isEqual:DROPBOX_ROOT_PATH] ? @"Dropbox" : [self.currentPath substringFromIndex:1];//to remove /
    [self setNavBar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)cleanTemporaryDirectory{
    NSArray* arr = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:NSTemporaryDirectory() error:nil];
    for(NSString* str in arr){
        [[NSFileManager defaultManager] removeItemAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:str] error:nil];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.metadata){
        return [self.metadata.contents count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
    
    DBMetadata *info = [self.metadata.contents objectAtIndex:[indexPath row]];
	cell.textLabel.text = info.filename;
	if (info.isDirectory) {
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.metadata.contents count] <= [indexPath row]) return;

	DBMetadata *info = [self.metadata.contents objectAtIndex:[indexPath row]];
    if (info.isDirectory) {
        //transit to the directory table view
        DropboxViewController *controller = [[DropboxViewController alloc] initWithPath:[self.currentPath stringByAppendingPathComponent:info.filename]];
        [self.navigationController pushViewController:controller animated:YES];
    }
    else if([info.filename hasSuffix:PNG_SUFFIX] || [info.filename hasSuffix:JPEG_SUFFIX]){
        //preview the image
        [self.restClient loadFile:info.path intoPath:[NSTemporaryDirectory() stringByAppendingPathComponent:info.filename]];
    }
    else if([info.filename isEqualToString:PERSISTENT_STORE]){
        //merge persistent store with this application
        UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"Load Project" message:@"Do you want to proceed to load this project?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
        [alertView show];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }else{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    //to confirm if user want to load persistent store project
    if(buttonIndex == alertView.cancelButtonIndex){
        return;
    }else{
        NSURL* url = [[NSURL fileURLWithPath:NSTemporaryDirectory()] URLByAppendingPathComponent:STORE_CONTENT];
        [[NSFileManager defaultManager] createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:nil];
        [self.restClient loadFile:[self.currentPath stringByAppendingPathComponent:PERSISTENT_STORE]
                         intoPath:[url.path stringByAppendingPathComponent:PERSISTENT_STORE]];
    }
}

/********** account info ************/
- (void) loadDropboxAccountInfo{
    [[self restClient] loadAccountInfo];
}
- (void)restClient:(DBRestClient*)client loadedAccountInfo:(DBAccountInfo*)info {
    //load user dropbox account info and set left bar button
    [self.delegate accountInfoLoaded:[info displayName]];
}

/************ folder ***************/
- (void)restClient:(DBRestClient*)client createdFolder:(DBMetadata*)folder{
    // Folder is the metadata for the newly created folder
    [self.restClient loadMetadata:DROPBOX_ROOT_PATH];
    [self startUploadTo:folder.filename at:(DBMetadata*)folder];
    //NSLog(@"Folder created succesfully in dropbox at %@",folder.path);
}
- (void)restClient:(DBRestClient*)client createFolderFailedWithError:(NSError*)error{
    // [error userInfo] contains the root and path
    UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"Create Folder Fail" message:@"There is an existing folder on Dropbox that has the same name as the project title. Please rename the folder or your project title and try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    [self cleanTemporaryDirectory];
    [self.syncDelegate syncDone];
    //NSLog(@"Folder failed to create in dropbox");
}

/************ upload file ***************/

-(void)uploadFileAtTemporaryDirectoryToFolder:(NSString *)folderName{
    //Upload all file exist at tmp/folderName
    //The process can only proceed following sequences dropbox delegation called, loadedMetadata or createdFolder delegate then startUploadTo... method
    
    //search for the folder or create one if does not exist
    for(DBMetadata* file in self.metadata.contents){
        if([file.filename isEqualToString:folderName] && [file isDirectory]){
            [self.restClient loadMetadata:file.path];
            return;
        }
    }
    [restClient createFolder:[DROPBOX_ROOT_PATH stringByAppendingPathComponent:folderName]];
}

-(void)startUploadTo:(NSString*)folder at:(DBMetadata*)folderMetadata{
    NSString* path = [NSTemporaryDirectory() stringByAppendingPathComponent:folder];
    
    NSArray* files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    
    for(NSString* file in files){
        if([file hasSuffix:PNG_SUFFIX] || [file hasSuffix:JPEG_SUFFIX]){
            NSString* rev = [self getRevWithName:file.lastPathComponent InMetadata:folderMetadata];
            [self.restClient uploadFile:file.lastPathComponent toPath:folderMetadata.path withParentRev:rev fromPath:[path stringByAppendingPathComponent:file]];
        }else if ([file isEqualToString:DATABASE]){
            NSString* rev = [self getRevWithName:PERSISTENT_STORE InMetadata:folderMetadata];
            path = [path stringByAppendingPathComponent:[[DATABASE stringByAppendingPathComponent:STORE_CONTENT] stringByAppendingPathComponent:PERSISTENT_STORE]];
            [self.restClient uploadFile:PERSISTENT_STORE toPath:folderMetadata.path withParentRev:rev fromPath:path];
        }
    }
}

- (NSString*)getRevWithName:(NSString*)name InMetadata:(DBMetadata*)data{
    //use rev to rewrite the file with same filename that already exist at dropbox
    //filename have to be unique or else will be overwritten
    for(DBMetadata* info in data.contents){
        if([info.filename isEqualToString:name] && !info.isDirectory){
            return info.rev;
        }
    }
    return nil;
}

#pragma mark - Dropbox uploadFileDelegate

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath
              from:(NSString*)srcPath metadata:(DBMetadata*)metadata {
    if(![srcPath hasSuffix:PERSISTENT_STORE]){
        [[NSFileManager defaultManager] removeItemAtPath:srcPath error:nil];//remove image file
    }else{
        //remove database folder which consist persistent store
        NSString* folderName = [metadata.path.pathComponents objectAtIndex:metadata.path.pathComponents.count-2];
        NSString* toBeDeletePath = [[NSTemporaryDirectory() stringByAppendingPathComponent:folderName] stringByAppendingPathComponent:DATABASE];
        [[NSFileManager defaultManager]removeItemAtPath:toBeDeletePath error:nil];
    }
    //NSLog(@"File uploaded successfully to path: %@", metadata.path);
    //[self cleanTemporaryDirectory];
    [self.syncDelegate syncDone];
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error {
    [self cleanTemporaryDirectory];
    [self.syncDelegate syncDone];
    UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"Upload Fail" message:@"Fail to upload, please try again later" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    //NSLog(@"File upload failed with error - %@", error);
}

/************ metadata ***************/

#pragma mark - Dropbox loadMetadata delegate

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    //situation when need to upload to file
    if (![metadata.path isEqualToString:DROPBOX_ROOT_PATH] && [self.currentPath isEqualToString:DROPBOX_ROOT_PATH]) {
        [self startUploadTo:metadata.filename at:metadata];
        return;
    }
    //if currentPath not equal to string mean go into table view
    self.metadata = metadata;
    [self.tableView reloadData];
}

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error {
    UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Fail to download content from dropbox server, please try again later" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    if(self.syncDelegate){
        [self cleanTemporaryDirectory];
        [self.syncDelegate syncDone];
    }
    //NSLog(@"Error loading metadata: %@", error);
}

/************ download file ***************/

#pragma mark - Dropbox downloadFile delegate

- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)localPath {
    //NSLog(@"File loaded into path: %@", localPath);
    
    if([localPath hasSuffix:PNG_SUFFIX] || [localPath hasSuffix:JPEG_SUFFIX])
    {
        DropboxImageViewController* preview = [[DropboxImageViewController alloc] initWithPath:localPath];
        [self.navigationController pushViewController:preview animated:YES];
    }
    else if([localPath.lastPathComponent isEqualToString:PERSISTENT_STORE])
    {
        //post to tell Model class to load project
        [[NSNotificationCenter defaultCenter] postNotificationName:@"persistentStoreLoaded" object:nil];
        [self.restClient loadMetadata:DROPBOX_ROOT_PATH];
        
        NSArray* navs = self.navigationController.viewControllers;
        int temp = navs.count-3;//go back to allProjectView
        [self.navigationController popToViewController:[navs objectAtIndex:temp] animated:YES];
    }
}

- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error {
    UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"Load Fail" message:@"Fail to download, please try again later" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    NSLog(@"There was an error loading the file - %@", error);
}

/****************** delete *********************/
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.restClient deletePath:[[self.metadata.contents objectAtIndex:[indexPath row]] path]];
    }
}
- (void)restClient:(DBRestClient*)client deletedPath:(NSString *)path{
    [self.restClient loadMetadata:self.currentPath];
    //NSLog(@"Deleted file at %@",path);
}
- (void)restClient:(DBRestClient*)client deletePathFailedWithError:(NSError*)error{
    UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"Delete Fail" message:@"Fail to delete, please try again later" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    //NSLog(@"Fail to delete - %@",error);
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.restClient loadMetadata:DROPBOX_ROOT_PATH];
}

@end