# BDUIViewUpdateQueue

[![CI Status](http://img.shields.io/travis/Norsez Orankijanan/BDUIViewUpdateQueue.svg?style=flat)](https://travis-ci.org/Norsez Orankijanan/BDUIViewUpdateQueue)
[![Version](https://img.shields.io/cocoapods/v/BDUIViewUpdateQueue.svg?style=flat)](http://cocoapods.org/pods/BDUIViewUpdateQueue)
[![License](https://img.shields.io/cocoapods/l/BDUIViewUpdateQueue.svg?style=flat)](http://cocoapods.org/pods/BDUIViewUpdateQueue)
[![Platform](https://img.shields.io/cocoapods/p/BDUIViewUpdateQueue.svg?style=flat)](http://cocoapods.org/pods/BDUIViewUpdateQueue)

## Overview

A singleton class facilitates queuing on updating UITableView, UICollectionView, and other UIView based classes.

When using UITableView or UICollectionView, asynchronous updating of your datasource and your view can be difficult without proper queuing. Sometimes upating these views can even crash your app (NSInternalInconsistencyException dreads). 

## How it works

`BDUIViewUpdateQueue` uses GCD (`dispatch_queue_t`) to lock your view to a serial queue, then execute your block in the main queue. That way datasource will always sync up with the state of your UITableView or UICollectionView. Other views will also work. 

## How to use

There are a few variations of lock and update `BDUIViewUpdateQueue` provides:

- `-updateView:block:` adds input blocks into a serial queue associated with the input view, then executes the blocks in sequence in the main queue
- `-updateView:block:delay:` delays the input time interval before adding inputs blocks into a serial queue associated with the input view, then executes the blocks in sequeuence in the main queue
- `updateView:block:waitUntil:` adds input blocks into a serial queue associated with the input view, periodically executes the waitUntil block until it returns true, then executes the corresponding block in the main queue



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

Norsez Orankijanan, norsez@gmail.com

## License

BDUIViewUpdateQueue is available under the MIT license. See the LICENSE file for more info.
