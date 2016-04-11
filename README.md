# Opera

<p align="left">
<a href="https://travis-ci.org/xmartlabs/Opera"><img src="https://travis-ci.org/xmartlabs/Opera.svg?branch=master" alt="Build status" /></a>
<img src="https://img.shields.io/badge/platform-iOS%20|%20OSX%20|%20watchOS%20|%20tvOS-blue.svg?style=flat" alt="Platform iOS" />
<a href="https://developer.apple.com/swift"><img src="https://img.shields.io/badge/swift2-compatible-4BC51D.svg?style=flat" alt="Swift 2 compatible" /></a>
<a href="https://github.com/Carthage/Carthage"><img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat" alt="Carthage compatible" /></a>
<a href="https://cocoapods.org/pods/XLActionController"><img src="https://img.shields.io/badge/pod-1.0.0-blue.svg" alt="CocoaPods compatible" /></a>
<a href="https://raw.githubusercontent.com/xmartlabs/Opera/master/LICENSE"><img src="http://img.shields.io/badge/license-MIT-blue.svg?style=flat" alt="License: MIT" /></a>
</p>

By [Xmartlabs SRL](http://xmartlabs.com).

## Inroduction

Networking abstraction layer written in Swift.
It simplifies our Networking API manager by splitting up your API into `RouteType`'s, a Alamofire `Request` abstraction.

It works on top of Alamofire, RxSwift and the JSON parsing library of your choice (Argo, Decodable, etc). PaginationViewModel abstraction was heavy inspired by [RxPagination](https://github.com/tryswift/RxPagination) project.

## Features

* API abstraction through `RouteType` conformance.
* Pagination support through `PaginationRequestType` conformance.
* Supports for any JSON parsing library such as [Decodable](https://github.com/Anviking/Decodable) and [Argo](https://github.com/thoughtbot/Argo) though `OperaDecodable` protocol conformance.
* Networking errors abstraction through `NetworkError` type. Opera `NetworkError` indicates either an NSURLSession error, Alamofire error, or your JSON parsing library error.
* RxSwift wrappers around `Alamofire` Request that returns an Observable of a JSON serialized type or an array if it. NetworkError is passed when error event happens.
* RxSwift wrappers around `PaginationRequestType` that returns a Observable of a `PaginationRensponseType` which contains  the serialized elements and information about the current, next and previous page.


## Usage

```swift

import Alamofire
import Opera

// just a hierarchy structure to organize routes
struct GithubAPI {
    struct Repository {}
}

extension GithubAPI.Repository {

  struct Search: RouteType {

      var method: Alamofire.Method { return .GET }
      var path: String { return "search/repositories" }
  }

  struct GetInfo: RouteType {

      let owner: String
      let repo: String

      var method: Alamofire.Method { return .GET }
      var path: String { return "repos/\(owner)/\(repo)" }
  }
}

```

> Alternatively you can opt by conforming `RouteType` form an enum where each enum value is a specific route (api endpoint) with its own associated values.

Check out the rest of [RouteType](https://github.com/xmartlabs/Opera/tree/master/Sources/RouteType.swift) protocol definition.

As you have may seen in the `RouteType` protocol definition. Any type that conforms to it must provide `baseUrl` and the Alamofire `manager` instance.

Usually these values do not change among our routes so we can easily provide them by a implementing a protocol extension over `RequestType` as shown below.

```swift
extension RouteType {

    var baseURL: NSURL {
        return NSURL(string: "https://api.github.com")!
    }

    var manager: Alamofire.Manager {
        return Manager.singleton
    }

}
```

> Now, by default, all `RouteType`s we define will provide `https://api.github.com` as `baseUrl` and `Manager.singleton` as `mananger`. It's up to you to customize it within a specific RouteType protocol conformance.

At this point we can easily create an Alamofire Request:

```swift
let request: Alamofire.Request =  GithubAPI.Repository.GetInfo(owner: "xmartlabs", repo: "Opera").request
```

> Notice that `RouteType` conforms to `Alamofire.URLRequestConvertible` so having the manager we can provide the associated `Alamofire.Request`.

We can also take advantage of the reactive helpers provided by Opera:


## Requirements

* iOS 8.0+
* Xcode 7.2+

## Getting involved

* If you **want to contribute** please feel free to **submit pull requests**.
* If you **have a feature request** please **open an issue**.
* If you **found a bug** or **need help** please **check older issues, [FAQ](#faq) and threads on [StackOverflow](http://stackoverflow.com/questions/tagged/Opera) (Tag 'Opera') before submitting an issue.**.

Before contribute check the [CONTRIBUTING](https://github.com/xmartlabs/Opera/blob/master/CONTRIBUTING.md) file for more info.

If you use **Opera** in your app We would love to hear about it! Drop us a line on [twitter](https://twitter.com/xmartlabs).

## Examples

Follow these 3 steps to run Example project: Clone Opera repository, open Opera workspace and run the *Example* project.

You can also experiment and learn with the *Opera Playground* which is contained in *Opera.workspace*.

## Installation

#### CocoaPods

[CocoaPods](https://cocoapods.org/) is a dependency manager for Cocoa projects.

To install Opera, simply add the following line to your Podfile:

```ruby
pod 'Opera', '~> 1.0'
```

#### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a simple, decentralized dependency manager for Cocoa.

To install Opera, simply add the following line to your Cartfile:

```ogdl
github "xmartlabs/Opera" ~> 1.0
```

## Author

* [Martin Barreto](https://github.com/mtnBarreto) ([@mtnBarreto](https://twitter.com/mtnBarreto))

## FAQ

#### How to .....

You can do it by conforming to .....

# Change Log

This can be found in the [CHANGELOG.md](CHANGELOG.md) file.
