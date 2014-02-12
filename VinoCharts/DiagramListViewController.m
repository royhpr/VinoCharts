//
//  DiagramListViewController.m
//  FinalSurvey
//
//  Created by Roy Huang Purong on 4/9/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "DiagramListViewController.h"

@interface DiagramListViewController ()

@end

@implementation DiagramListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		//initialize the width and height of current popover
        self.contentSizeForViewInPopover = CGSizeMake(250.0, 320.0);
    }
    return self;
}

-(id)initWithDiagramList:(NSArray*)list
{
    self = [super init];
    
    if(self)
    {
        diagramList = [[NSMutableArray alloc]initWithArray:list];
    }
    return self;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return diagramList.count + 1;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"MainCell"];
    
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MainCell"];
    }
    
    if(indexPath.row == diagramList.count)
    {
        cell.textLabel.text = @"+ Add Diagram";
    }
    else
    {
        NSString* cellText = [NSString stringWithString:[diagramList objectAtIndex:indexPath.row]];
        cell.textLabel.text = cellText;
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == diagramList.count)
    {
        [self.delegate createNewDiagram];
    }
    else
    {
        [self.delegate updateButtonTitleWithIndex:indexPath.row];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
