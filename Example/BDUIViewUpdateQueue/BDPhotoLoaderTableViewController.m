//
//  BDPhotoLoaders.m
//  BDUIViewUpdateQueue
//
//  Created by Norsez Orankijanan on 5/22/15.
//  Copyright (c) 2015 Norsez Orankijanan. All rights reserved.
//

#import "BDPhotoLoaderTableViewController.h"
#import <BDUIViewUpdateQueue/BDUIViewUpdateQueue.h>
#import "BDPhotoCellTableViewCell.h"
@interface BDPhotoLoaderTableViewController ()
{
  NSArray *_photos;
}
@end

@implementation BDPhotoLoaderTableViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  NSString* path = [[NSBundle mainBundle] pathForResource:@"photos" ofType:@"json"];
  NSData *data = [[NSData alloc] initWithContentsOfFile:path];
  NSError* error;
  NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingAllowFragments | NSJSONReadingMutableContainers) error:&error];

  
  _photos = [json valueForKeyPath:@"photoset.photo"];
  [[self tableView] reloadData];
  
}

#pragma mark - table view delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return _photos.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  
  static NSString *cellID = @"photoCell";
  BDPhotoCellTableViewCell *cell = (BDPhotoCellTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
  NSDictionary* photo = _photos[indexPath.row];
  cell.titleLabel.text = [photo valueForKey:@"title"];
  cell.photoView.image = nil;
  UIImage* thumbnail = [photo valueForKey:@"thumbnailImage"];
  if (!thumbnail) {
    [self _loadThumbmailWithRowIndex:indexPath.row];
  }else {
    cell.photoView.image = thumbnail;
  }
  
  NSDictionary* owner = [photo valueForKey:@"owner"];
  if (!owner) {
    [self _loadPhotoInfoWithRowIndex:indexPath.row];
  }else {
    cell.titleLabel.attributedText = [self _attributedTextWithRowIndex:indexPath.row];
  }
  
  return cell;
}

- (NSAttributedString*)_attributedTextWithRowIndex:(NSUInteger)row
{
  NSDictionary* p = _photos [row];
  NSMutableAttributedString* str = [[NSMutableAttributedString alloc] initWithString:[p valueForKey:@"title"] attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Helvetica Neue Light" size:18]}];
  [str appendAttributedString:[[NSAttributedString alloc] initWithString:@" by " attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Helvetica Neue" size:14]}]];
  [str appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@ \n", [p valueForKeyPath:@"owner.username"]] attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Helvetica Neue Bold" size:14]}]];
  [str appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\t%@\n", [p valueForKeyPath:@"description._content"]] attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Helvetica Neue Thin" size:16]}]];
  
  return str;
}

- (void)_loadPhotoInfoWithRowIndex:(NSUInteger)row
{
  
}

- (void)_loadThumbmailWithRowIndex:(NSUInteger)row
{
  
  NSDictionary* p = _photos [row];
  NSString* path = [NSString stringWithFormat:@"http://farm%@.staticflickr.com/%@/%@_%@_s.jpg",
                    [p valueForKey:@"farm"],
                    [p valueForKey:@"server"],
                    [p valueForKey:@"id"],
                    [p valueForKey:@"secret"]
                    ];
  
  
  NSURLSessionDownloadTask *dtsk = [[NSURLSession sharedSession] downloadTaskWithURL:[NSURL URLWithString:path] completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
    if (!error) {
      UIImage *image = [UIImage imageWithData:
                        [NSData dataWithContentsOfURL:location]];
      [[BDUIViewUpdateQueue shared] updateView:self.tableView block:^{
        NSMutableDictionary* photo = [_photos objectAtIndex:row];
        [photo setObject:image forKey:@"thumbnailImage"];
        
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        
      }];
    }
  }];
  
  [dtsk resume];
}

- (void)_didReceiveThumbnail:(NSURL*)location rowIndex:(NSUInteger)row
{
  [[BDUIViewUpdateQueue shared] updateView:self.tableView block:^{

    UIImage* image = [[UIImage alloc] initWithData:[[NSData alloc] initWithContentsOfURL:location]];
    NSMutableDictionary* photo = [_photos objectAtIndex:row];
    [photo setObject:image forKey:@"thumbnailImage"];
    
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    
  }];
}

@end
