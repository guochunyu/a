//
//  PhotoAlbumsController.m
//  AmericanBaby
//
//  Created by 陆广庆 on 14-8-11.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

#import "PhotoAlbumsController.h"
#import "PhotoAlbumCell.h"

@interface PhotoAlbumsController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *iCancleButton;
@property (nonatomic) NSArray *albums;

@end

@implementation PhotoAlbumsController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_handler initDataForUserInterface];
    [_handler loadPhotos];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [cancelButton addTarget:self action:@selector(didCancleButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setTintColor:[UIColor whiteColor]];
    [cancelButton.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
    
    
//    [cancelButton setTitleColor:[UIColor colorWithRed:23.00/255.00 green:126.00/255.00 blue:251.00/255.00 alpha:1] forState:UIControlStateNormal];
    cancelButton.frame = CGRectMake(0, 0, 40, 30);
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    self.navigationItem.leftBarButtonItem = cancelItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)showPhotoAlbums:(NSArray *)photoAlbums
{
    _albums = photoAlbums;
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_albums count];
}

- (IBAction)didCancleButtonClick:(id)sender
{
    [_handler cancleChoose];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentifier = @"PhotoAlbumCell";
    PhotoAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier forIndexPath:indexPath];
    ALAssetsGroup *group = _albums[indexPath.row];
    [cell configureWithAlbumAssetGroup:group];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ALAssetsGroup *group = _albums[indexPath.row];
    [_handler showPhotoInAlbums:[group valueForProperty:ALAssetsGroupPropertyName]];
}

@end
