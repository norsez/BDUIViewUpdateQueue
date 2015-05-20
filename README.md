# BDUIViewUpdateQueue

[![CI Status](http://img.shields.io/travis/Norsez Orankijanan/BDUIViewUpdateQueue.svg?style=flat)](https://travis-ci.org/Norsez Orankijanan/BDUIViewUpdateQueue)
[![Version](https://img.shields.io/cocoapods/v/BDUIViewUpdateQueue.svg?style=flat)](http://cocoapods.org/pods/BDUIViewUpdateQueue)
[![License](https://img.shields.io/cocoapods/l/BDUIViewUpdateQueue.svg?style=flat)](http://cocoapods.org/pods/BDUIViewUpdateQueue)
[![Platform](https://img.shields.io/cocoapods/p/BDUIViewUpdateQueue.svg?style=flat)](http://cocoapods.org/pods/BDUIViewUpdateQueue)

## Overview

A singleton class facilitates queuing on updating UITableView, UICollectionView, and other UIView based classes.

## Typical Uses
UITableView (and UICollectionView) expects you to have all your data ready for populating your cells before drawing them on the view. In this case, when you insert, delete, `-batchUpdate…`, or `-reloadData`, your datasource state is synced up with your view state. Everything is great.

Unfortunately, we don't always have our data ready before drawing the views. Sometimes we want to start with our minimal amount of data, then download more over time so that the app appears to be fast and ready. So you asynchronously update your UITableView. However, when the UITableView gets updated repeatedly in a short interval, which typically happens in asynchronous updates, you run the risk of missing the sync between your datasource and your UITableView state. This often causes crashes with `NSInternalInconsistencyException` or `endupdates EXC_BAD_ACCESS` errors. `BDUIViewUpdateQueue` helps you queue up these updates in order to avoid these problems.

## How it works

`BDUIViewUpdateQueue` uses Grand Central Dispatch (`dispatch_queue_t`) to lock your view to a serial queue, then execute your block in the main queue. That way datasource will always sync up with the state of your UITableView or UICollectionView. Other views will also work. 

## How to use

There are a few variations of lock and update `BDUIViewUpdateQueue` provides:

- `-updateView:block:` adds input blocks into a serial queue associated with the input view, then executes the blocks in sequence in the main queue
- `-updateView:block:delay:` delays the input time interval before adding inputs blocks into a serial queue associated with the input view, then executes the blocks in sequeuence in the main queue
- `updateView:block:waitUntil:` adds input blocks into a serial queue associated with the input view, periodically executes the waitUntil block until it returns true, then executes the corresponding block in the main queue

`BDUIViewUpdateQueue` is a singleton class. So use `+shared` to get an instance. 

```
[BDUIViewUpdateQueue shared];
```

`BDUIViewUpdateQueue` requires a `UIView` as an input in order to associate a serial queue with it. This means that we can use `BDUIViewUpdateQueue` to queue updates for as many `UIView`s as you want. `BDUIViewUpdateQueue` keeps track of `dispatch_queue_t` structs for you.

Inside the input block, that's where you want to update your datasource and your view. Like so…

```
[[BDUIViewUpdateQueue shared] updateView:self.tableView block:^{
self.items = @[@"Hello"];
[self.tableView insertIndexPaths@[[NSIndexPath indexPathWithRow:0 section:0 withRowAnimation:UITableViewRowAnimationBottom]];
}];
```

## Example project

The example project demonstrates a case where the datasource and the view are updated repeatedly in a short time. Usually, this will result in a crash because the datasource is out of sync with its view. Wrapping it with a `BDUIViewUpdateQueue` call makes it all better :)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

- iOS 6.0 (Should be okay down to iOS 4.0)

## Installation

BDUIViewUpdateQueue is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```
pod "BDUIViewUpdateQueue"
```

## Author

Norsez Orankijanan, http://about.me/norsez

## License

BDUIViewUpdateQueue is available under the MIT license. See the LICENSE file for more info.
