//
//  PreviewDiagramViewController.h
//  VinoCharts
//
//  Created by Ang Civics on 14/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//
/*  
 This class is used to preview the diagram created by the user, then it can perform upload to dropbox function. It is subclass from DropboxImageViewController to inherit the scroll view feature provided that suitable to preview image.
 */

#import "ScrollViewImageViewController.h"
#import "DropboxViewController.h"
#import <DropboxSDK/DropboxSDK.h>
#import "CoreDataConstant.h"
#import <QuartzCore/QuartzCore.h>

@interface PreviewDiagramViewController : ScrollViewImageViewController<DropboxSyncDelegate>

-(id)initWithImage:(UIImage*)image Title:(NSString*)title ProjectTitle:(NSString*)projectTitle;
//REQUIRES: valid image, title and projectTitle parameter
//EFFECTS: Image will be show, corresponding image will be upload to dropbox with authorization of user
@end
