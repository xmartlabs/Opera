# Opera

<p align="left">
<a href="https://travis-ci.org/xmartlabs/Opera"><img src="https://travis-ci.org/xmartlabs/Opera.svg?branch=master" alt="Build status" /></a>
<img src="https://img.shields.io/badge/platform-iOS%20|%20OSX%20|%20watchOS%20|%20tvOS-blue.svg?style=flat" alt="Platform iOS" />
<a href="https://developer.apple.com/swift"><img src="https://img.shields.io/badge/swift2-compatible-4BC51D.svg?style=flat" alt="Swift 2 compatible" /></a>
<a href="https://github.com/Carthage/Carthage"><img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat" alt="Carthage compatible" /></a>
<a href="https://cocoapods.org/pods/XLActionController"><img src="https://img.shields.io/badge/pod-1.0.0-blue.svg" alt="CocoaPods compatible" /></a>
<a href="https://raw.githubusercontent.com/xmartlabs/Opera/master/LICENSE"><img src="http://img.shields.io/badge/license-MIT-blue.svg?style=flat" alt="License: MIT" /></a>
</p>

Made with ❤️ by [XMARTLABS](http://xmartlabs.com). View all our [open source contributions](https://github.com/xmartlabs).

## Inroduction

Protocol-Oriented Network abstraction layer written in Swift. Greatly inspired by [RxPagination](https://github.com/tryswift/RxPagination) project but working on top of [Alamofire](https://github.com/Alamofire/Alamofire) and the Json parsing library of your choice.

## Features

* API abstraction through `RouteType` conformance.
* Pagination support through `PaginationRequestType` conformance.
* Supports for any JSON parsing library such as [Decodable](https://github.com/Anviking/Decodable) and [Argo](https://github.com/thoughtbot/Argo) though `OperaDecodable` protocol conformance.
* Networking errors abstraction through `NetworkError` type. Opera `NetworkError` indicates either an `NSURLSession` error, Alamofire error, or your JSON parsing library error.
* RxSwift wrappers around `Alamofire` Request that returns an Observable of a JSON serialized type or an array if it. NetworkError is passed when error event happens.
* RxSwift wrappers around `PaginationRequestType` that returns a Observable of a `PaginationRensponseType` which contains  the serialized elements and information about the current, next and previous page.


## Usage

A `RouteType` is a high level representation of the request for a REST API endpoint. By adopting `RouteType` protocol a type is able to create its correspond request.

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

If you are curious check out the rest of [RouteType](https://github.com/xmartlabs/Opera/tree/master/Sources/RouteType.swift) protocol definition.

As you have may seen, any type that conforms to `RouteType` must provide `baseUrl` and the Alamofire `manager` instance.

Usually these values do not change among our routes so we can provide them by implementing a protocol extension over `RequestType` as shown below.

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

> Notice that `RouteType` conforms to `Alamofire.URLRequestConvertible` so having the manager we can create the associated `Alamofire.Request`.

We can also take advantage of the reactive helpers provided by Opera:

```swift
request
.rx_collection()
.doOnNetworkError { (error: NetworkError) in
  // do something when networking went wrong
}
.subscribeNext { (repositories: [Repository]) in
  // do something when networking and Json parsing completes successfully
}
.addDisposableTo(disposeBag)
```

```swift
getInfoRequest
.rx_object()
.doOnNetworkError { (error: NetworkError) in
  // do something when networking went wrong
}
.subscribeNext { (repository: Repository) in
  // do something when networking and Json parsing completes successfully
}
.addDisposableTo(disposeBag)

```

> If you are not interested in decode your json response into a Model you can invoke `request.rx_anyObject()` which returns an `Observable` of `AnyObject` for the current request and propagates a `NetworkError` error through the result sequence if something goes wrong.

> Opera can be used along with [RxAlamofire](https://github.com/RxSwiftCommunity/RxAlamofire).


Opera represents pagination request through `PaginationRequestType` protocol which also conforms to `URLRequestConvertible`. Typically we don't need to create a new type to conform to it. Opera provides `PaginationRequest<Element: OperaDecodable>` generic type that can be used in most of the scenarios.

One of the requirements to adopt `PaginationRequestType` is to implement the following initializer:

```swift
init(route: RouteType, page: String?, query: String?, filter: FilterType?, collectionKeyPath: String?)
```
so we create a pagination request doing:

```
let paginatinRequest: PaginationRequest<Repository> = PaginationRequest(route: GithubAPI.Repository.Search(), collectionKeyPath: "items")
```

> Repositories json response array is under "items" key as [github repositories api documentation](https://developer.github.com/v3/search/#search-repositories) indicates so we pass `"items"` as `collectionKeyPath` parameter.

A pagination request type wraps up a `RouteType` instance and holds additional info related with pagination such as query string, page, filters, etc. It also provides some helpers to get a new pagination request from the current pagination request info updating  its query string, page or filters value.

let firtPageRequest = paginatinRequest.routeWithPage("1").request
let filteredFirstPageRequest = firtPageRequest.routeWithQuery("Eureka").request
> Another variant of the previous helpers is `public func routeWithFilter(filter: FilterType) -> Self`.


We've said Opera is able to decode json response into a Model using your favorite Json parsing library.  Let's see how Opera accomplishes that.

> At Xmartlabs we have been using `Decodable` as our Json parsing library since march 16. Before that we had used Argo, ObjectMapper and many others. I don't want to deep into the reason of our json parsing library choice (we have our reasons ;)) but during Opera implementation/design we though it was a good feature to be flexible about it.

This is our Repository model...

```swift
struct Repository {

    let id: Int
    let name: String
    let desc: String?
    let company: String?
    let language: String?
    let openIssues: Int
    let stargazersCount: Int
    let forksCount: Int
    let url: NSURL
    let createdAt: NSDate

}
```

and `OperaDecodable` protocol:

```swift
public protocol OperaDecodable {
    static func decode(json: AnyObject) throws -> Self
}
```

Since `OperaDecodable` and `Decodable.Decodable` require us to implement the same method, we only have to declare protocol conformance.

```swift
// Make Repository conforms to Decodable.Decodable
extension Repository: Decodable {

    static func decode(j: AnyObject) throws -> Repository {
        return try Repository.init(  id: j => "id",
                                   name: j => "name",
                                   desc: j =>? "description",
                                company: j =>? ["owner", "login"],
                               language: j =>? "language",
                             openIssues: j => "open_issues_count",
                        stargazersCount: j => "stargazers_count",
                             forksCount: j => "forks_count",
                                    url: j => "url",
                              createdAt: j => "created_at")
    }
}

// Declare OperaDecodable adoption
extension Repository : OperaDecodable {}
```

Using Argo is a little bit harder, we need to implement `OperaDecodable` in addition to declare the protocol adoption. Here where swift language protocol extension feature comes in handy....

```swift
extension Argo.Decodable where Self.DecodedType == Self, Self: OperaDecodable {
  static func decode(json: AnyObject) throws -> Self {
    let decoded = decode(JSON.parse(json))
    switch decoded {
      case .Success(let value):
        return value
      case .Failure(let error):
            throw error
    }
  }
}
```

Now we can make any Argo.Decodable model conforms to OperaDecodable by simply declaring `OperaDecodable` protocol adoption.

```swift
extension Repository : OperaDecodable {}
```

Finally let's look into PaginationViewModel generic class thats allows us to list/paginate/sort/filter decodable items in a very straightforward way.


```swift
import UIKit
import RxSwift
import RxCocoa
import Opera

class SearchRepositoriesController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var searchBar: UISearchBar!
    lazy var viewModel: PaginationViewModel<PaginationRequest<Repository>>  = { [unowned self] in
        return PaginationViewModel(paginationRequest: PaginationRequest(route: GithubAPI.Repository.Search(), collectionKeyPath: "items"))
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // set up views
        tableView.backgroundView = emptyStateLabel
        tableView.keyboardDismissMode = .OnDrag

        // on viewWill appear load pagination view model by emitting false (do not cancel pending request if any) to view model `refreshTrigger` PublishSubject.
        // viewModel is subscribed to `refreshTrigger` observable and starts a new request.
        rx_sentMessage(#selector(SearchRepositoriesController.viewWillAppear(_:)))
            .skip(1)
            .map { _ in false }
            .bindTo(viewModel.refreshTrigger)
            .addDisposableTo(disposeBag)

        // make model view loads next page when reaches table view bottom...  
        tableView.rx_reachedBottom
            .bindTo(viewModel.loadNextPageTrigger)
            .addDisposableTo(disposeBag)

        // Updates activity indicator accordingly based on modelView `loading` variable.
        viewModel.loading
            .drive(activityIndicatorView.rx_animating)
            .addDisposableTo(disposeBag)

        // updates tableView observing viewModel `elements`, since github api only works if a query string is present we show no items if the first page is being loading or UISearchBar text is empty. By doing that whenever the search criteria is updated we take away all the item from the table view giving a sense of being fetching/searching the server. Notice the strongly typed `Repository` type below.
        Driver.combineLatest(viewModel.elements.asDriver(), viewModel.firstPageLoading, searchBar.rx_text.asDriver()) { elements, loading, searchText in
                return loading || searchText.isEmpty ? [] : elements
            }
            .asDriver()
            .drive(tableView.rx_itemsWithCellIdentifier("Cell")) { _, repository: Repository, cell in
                cell.textLabel?.text = repository.name
                cell.detailTextLabel?.text = "🌟\(repository.stargazersCount)"
            }
            .addDisposableTo(disposeBag)

        // whenever search bar text is changed, wait for 1/4 sec of search bar inactivity then update the `viewModel` pagination request type (will cancel any pending request). We propagates query string by binding it to viewModel.queryTrigger.
        searchBar.rx_text
            .filter { !$0.isEmpty }
            .throttle(0.25, scheduler: MainScheduler.instance)
            .bindTo(viewModel.queryTrigger)
            .addDisposableTo(disposeBag)

        // handles view empty state.
        Driver.combineLatest(viewModel.emptyState, searchBar.rx_text.asDriver().throttle(0.25)) { $0 ||  $1.isEmpty }
            .driveNext { [weak self] state in
                self?.emptyStateLabel.hidden = !state
                self?.emptyStateLabel.text = (self?.searchBar.text?.isEmpty ?? true) ? "Enter text to search repositories" : "No repositories found"
            }
            .addDisposableTo(disposeBag)
    }

    private lazy var emptyStateLabel: UILabel = {
        let emptyStateLabel = UILabel()
        emptyStateLabel.text = ControllerConstants.NoTextMessage
        emptyStateLabel.textAlignment = .Center
        return emptyStateLabel
    }()
    private let disposeBag = DisposeBag()
}
```

--------------------------------------------------------

If you want to continue using the conventional Alamofire way to make request, Opera makes this easy by providing the following response serializers.

```swift
extension Request {
    /**
         Generic response object serializarion that returns a OperaDecodable instance.

         - parameter keyPath:           keyPath to look up json object to serialize. Ignore parameter or pass nil when json object is the json root item.
         - parameter completionHandler: A closure to be executed once the request has finished.

         - returns: The request.
         */
    public func responseObject<T : OperaDecodable>(keyPath: String? = default, completionHandler: Alamofire.Response<T, Opera.NetworkError> -> Void) -> Self
    /**
         Generic response object serializarion that returns an Array of OperaDecodable instances.

         - parameter collectionKeyPath: keyPath to look up json array to serialize. Ignore parameter or pass nil when json array is the json root item.
         - parameter completionHandler: A closure to be executed once the request has finished.

         - returns: The request.
         */
    public func responseCollection<T : OperaDecodable>(collectionKeyPath: String? = default, completionHandler: Alamofire.Response<[T], Opera.NetworkError> -> Void) -> Self
    /**
         Generic response object serializarion. Notice that Response Error type is NetworkError.

         - parameter completionHandler: A closure to be excecuted once the request has finished.

         - returns: The request.
         */
    public func responseAnyObject(completionHandler: Alamofire.Response<AnyObject, Opera.NetworkError> -> Void) -> Self
}
```

## Requirements

* iOS 8.0+ / Mac OS X 10.9+ / tvOS 9.0+ / watchOS 2.0+
* Xcode 7.3+

## Getting involved

* If you **want to contribute** please feel free to **submit pull requests**.
* If you **have a feature request** please **open an issue**.
* If you **found a bug** or **need help** please **check older issues, [FAQ](#faq) and threads on [StackOverflow](http://stackoverflow.com/questions/tagged/XLOpera) (Tag 'XLOpera') before submitting an issue**.

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

##### How do I set up additional request parameters right before creating Alamofire request from a RouteType or a PaginationRequestType?

By making any of them adopt `URLRequestParametersSetup` protocol.

```swift
/**
 *  By adopting URLRequestParametersSetup a RequestType or PaginationRequestType is able to make a final customization to request parameters dictionary before they are encoded.
 */
public protocol URLRequestParametersSetup {
    func urlRequestParametersSetup(urlRequest: NSMutableURLRequest, parameters: [String: AnyObject]?) -> [String: AnyObject]?
}

```

##### How do I customize `NSMutableURLRequest` that is not possible through RouteType and PaginationRouteType adoption?

You can make RouteType or PaginationRequestType adopt `URLRequestSetup`.

```swift
/**
 *  By adopting URLRequestSetup a RequestType or PaginationRequstType is able to customize it right before sending it to the server.
 */
public protocol URLRequestSetup {
    func urlRequestSetup(urlRequest: NSMutableURLRequest)
}
```

# Change Log

This can be found in the [CHANGELOG.md](CHANGELOG.md) file.
