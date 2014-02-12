//
//  DropboxImageViewController.m
//  VinoCharts
//
//  Created by Ang Civics on 2/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "DropboxImageViewController.h"

@interface DropboxImageViewController ()

@property NSString* path;

@end

@implementation DropboxImageViewController

- (id)initWithPath:(NSString *)path{
    self = [super init];
    if (self) {
        self.path = path;
        
        UIImage* image = [UIImage imageWithContentsOfFile:self.path];
        self.imageView = [[UIImageView alloc] initWithImage:image];
        self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    }
    return self;
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated{
    //remove the image from temporary directory to avoid conflict with upload image
    [[NSFileManager defaultManager] removeItemAtPath:self.path error:nil];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

@end
