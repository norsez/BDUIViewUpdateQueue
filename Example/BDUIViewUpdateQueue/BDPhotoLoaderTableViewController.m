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
  _photos = [_photos sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
    return arc4random_uniform(3);
  }];
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
  cell.photoView.clipsToBounds = YES;
  NSDictionary* photo = _photos[indexPath.row];
  cell.titleLabel.text = [photo valueForKey:@"title"];
  cell.photoView.image = nil;
  UIImage* thumbnail = [photo valueForKey:@"thumbnailImage"];
  if (!thumbnail) {
    [self _loadThumbmailWithRowIndex:indexPath.row];
  }else {
    cell.photoView.image = thumbnail;
  }
  
  NSDictionary* info = [photo valueForKeyPath:@"info"];
  if (!info) {
    [self _loadPhotoInfoWithRowIndex:indexPath.row];
  }else {
    NSAttributedString* attr = [photo valueForKey:@"attr"];
    if (!attr) {
      cell.titleLabel.attributedText = [self _attributedTextWithRowIndex:indexPath.row];
    }else {
      cell.titleLabel.attributedText = attr;
    }
  }
  
  return cell;
}


- (void)_loadPhotoInfoWithRowIndex:(NSUInteger)row
{
  // Create JSON Session Configuration
  NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
  [sessionConfiguration setHTTPAdditionalHeaders:@{ @"Accept" : @"application/json" }];
  NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
  
  NSDictionary* p = _photos [row];
  NSString* path = [NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.getInfo&api_key=f54215c654a239c02b8e4004e10c80fa&photo_id=%@&format=json&nojsoncallback=1",
                    [p valueForKey:@"id"]
                    ];

  // Send Request
  NSURL *url = [NSURL URLWithString:path];
  [[session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    NSMutableDictionary* info = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSMutableDictionary* photo = [_photos objectAtIndex:row];
    [photo setObject:info forKey:@"info"];
    
    [[BDUIViewUpdateQueue shared] updateView:self.tableView block:^{
      NSLog(@"BDUIViewUpdateQueue - reloading row: %lu for more photo information…", row);
      [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }];
    
  }] resume];
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
        NSLog(@"BDUIViewUpdateQueue - reloading row: %lu for thumbnail…", row);
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        
      }];
    }
  }];
  
  [dtsk resume];
}


- (NSAttributedString*)_attributedTextWithRowIndex:(NSUInteger)row
{
  NSDictionary* p = _photos [row];

  
  NSMutableAttributedString* str = [[NSMutableAttributedString alloc] initWithString:@"" attributes:@{}];
  NSString* value = [p valueForKeyPath:@"info.photo.title._content"];
  [str appendAttributedString:[[NSAttributedString alloc] initWithString:value==nil?@"":value attributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:14]}]];
  [str appendAttributedString:[[NSAttributedString alloc] initWithString:@" by " attributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:10]}]];
  value = [NSString stringWithFormat:@" %@ \n", [p valueForKeyPath:@"info.photo.owner.username"]];
  [str appendAttributedString:[[NSAttributedString alloc] initWithString:value?value:@"" attributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Bold" size:12]}]];
  
  NSArray* tags = [p valueForKeyPath:@"info.photo.tags.tag"];
  NSString* tagtext = @"";
  for (NSDictionary *t in tags) {
    tagtext = [tagtext stringByAppendingString:[t valueForKey:@"raw"]];
    tagtext = [tagtext stringByAppendingString:@", "];
  }
  
  static NSMutableParagraphStyle *par;
  if (!par) {
    par = [NSMutableParagraphStyle new];
    par.lineSpacing = 0;
    par.lineBreakMode = NSLineBreakByCharWrapping;
    par.alignment = NSTextAlignmentJustified;
    par.paragraphSpacingBefore = 8;
    
  }
  
  [str appendAttributedString:[[NSAttributedString alloc] initWithString:tagtext?tagtext:@"" attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Courier New" size:8], NSParagraphStyleAttributeName: par}]];
  
  //cache the NSAttributedString
  NSMutableDictionary* photo = _photos [row];
  [photo setObject:str forKey:@"attr"];
  
  return str;
}

@end
