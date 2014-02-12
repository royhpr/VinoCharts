//
//  PreviewDiagramViewController.m
//  VinoCharts
//
//  Created by Ang Civics on 14/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "PreviewDiagramViewController.h"

@interface PreviewDiagramViewController ()

@property NSString* title;
@property NSString* projectTitle;
@property UIBarButtonItem* backButton;
@property UIBarButtonItem* syncButton;

- (void)uploadToDropbox;
- (void)saveScreenShot;

@end

@implementation PreviewDiagramViewController

-(id)initWithImage:(UIImage *)image Title:(NSString *)title ProjectTitle:(NSString *)projectTitle{
    self = [super init];
    if(self){
        self.imageView = [[UIImageView alloc] initWithImage:image];
        self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
        self.title = title;
        self.projectTitle = projectTitle;
        self.backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(didPressBackButton)];
       
        if([[DBSession sharedSession] isLinked]){
            self.syncButton = [[UIBarButtonItem alloc]initWithTitle:@"Sync to dropbox" style:UIBarButtonItemStyleBordered target:self action:@selector(uploadToDropbox)];
        }
        UIToolbar* toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 704, 1024, 44)];
        [toolbar setItems:[NSArray arrayWithObjects:self.backButton,self.syncButton, nil]];
        [self.view addSubview:toolbar];
    }
    return self;
}

-(void)didPressBackButton{
    [self dismissModalViewControllerAnimated:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)uploadToDropbox{
    [self.syncButton setTitle:@"Syncing..."];
    [[DropboxViewController sharedDropbox] setSyncDelegate:self];
    [self saveScreenShot];
    [[DropboxViewController sharedDropbox] uploadFileAtTemporaryDirectoryToFolder:self.projectTitle];
}

//DropboxSyncDelegate protocol method
-(void)syncDone{
    [self.syncButton setTitle:@"Sync to dropbox"];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)saveScreenShot{
    //create and save the whole scroll view screen shot(including invisible part) to temporary directory
    UIImage* image = nil;
    float scale = self.scrollView.zoomScale;
    self.scrollView.zoomScale = 1;

    UIGraphicsBeginImageContext(self.scrollView.contentSize);
    {
        CGPoint savedContentOffset = self.scrollView.contentOffset;
        CGRect savedFrame = self.scrollView.frame;
        CGRect imageFrame = self.imageView.frame;
        
        CGRect b = CGRectMake(0, 0, self.imageView.frame.size.width, self.imageView.frame.size.height);
        self.imageView.frame = b;
        self.scrollView.contentOffset = CGPointZero;
        CGRect a = CGRectMake(0, 0, self.scrollView.contentSize.width, self.scrollView.contentSize.height);
        self.scrollView.frame = a;
        [self.scrollView.layer renderInContext: UIGraphicsGetCurrentContext()];
        image = UIGraphicsGetImageFromCurrentImageContext();
        
        self.imageView.frame = imageFrame;
        self.scrollView.contentOffset = savedContentOffset;
        self.scrollView.frame = savedFrame;
    }
    UIGraphicsEndImageContext();
    
    self.scrollView.zoomScale = scale;

    if (image != nil) {
        NSString* path = [NSTemporaryDirectory() stringByAppendingPathComponent:self.projectTitle];
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        path = [path stringByAppendingPathComponent:self.title];
        [UIImagePNGRepresentation(image) writeToFile: [path stringByAppendingPathExtension:PNG_SUFFIX] atomically: YES];
        [UIImageJPEGRepresentation(image, 1) writeToFile:[path stringByAppendingPathExtension:JPEG_SUFFIX] atomically:YES];
     }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
