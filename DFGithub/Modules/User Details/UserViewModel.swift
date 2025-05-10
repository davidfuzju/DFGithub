//
//  UserDetailsViewModel.swift
//  DFGithub
//
//  Created by David FU on 2025/5/10.
//

import Foundation
import RxCocoa
import RxSwift
import SwiftDate

class UserViewModel: ViewModel, ViewModelType {
    
    struct Input {
        let headerRefresh: Observable<Void>
        let openInWebSelection: Observable<Void>
        let selection: Observable<UserSectionItem>
    }
    
    struct Output {
        let items: Observable<[UserSection]>
        let username: Driver<String>
        let fullname: Driver<String>
        let description: Driver<String>
        let imageUrl: Driver<URL?>
        let following: Driver<Bool>
        let hidesFollowButton: Driver<Bool>
        let openInWebSelected: Driver<WebViewModel>
        let selectedEvent: Driver<UserSectionItem>
    }
    
    let user: BehaviorRelay<User>
    
    init(user: User, provider: DFGithubAPI) {
        self.user = BehaviorRelay(value: user)
        super.init(provider: provider)
    }
    
    func transform(input: Input) -> Output {
        
        input.headerRefresh
            .flatMapLatest { [weak self] () -> Observable<User> in
                guard let self = self else { return Observable.just(User()) }
                let user = self.user.value
                let request: Single<User>
                if !user.isMine() {
                    let owner = user.login ?? ""
                    switch user.type {
                    case .user: request = self.provider.user(owner: owner)
                    case .organization: request = self.provider.organization(owner: owner)
                    }
                } else {
                    request = self.provider.profile()
                }
                return request
                    .trackActivity(self.loading)
                    .trackActivity(self.headerLoading)
                    .trackError(self.error)
            }
            .subscribe(onNext: { [weak self] (user) in
                self?.user.accept(user)
                if user.isMine() {
                    user.save()
                }
            })
            .disposed(by: rx.disposeBag)
        
        let refreshStarring = Observable.of(input.headerRefresh).merge()
        refreshStarring
            .flatMapLatest { [weak self] () -> Observable<RxSwift.Event<Void>> in
                guard let self = self, loggedIn.value == true else { return Observable.just(RxSwift.Event.next(())) }
                let username = self.user.value.login ?? ""
                return self.provider.checkFollowing(username: username)
                    .trackActivity(self.loading)
                    .materialize()
                    .share()
            }
            .subscribe(onNext: { [weak self] (event) in
                guard let self = self else { return }
                switch event {
                case .next:
                    var user = self.user.value
                    user.viewerIsFollowing = true
                    self.user.accept(user)
                case .error:
                    var user = self.user.value
                    user.viewerIsFollowing = false
                    self.user.accept(user)
                case .completed: break
                }
            })
            .disposed(by: rx.disposeBag)
        
        let username = user.map { $0.login ?? "" }.asDriverOnErrorJustComplete()
        let fullname = user.map { $0.name ?? "" }.asDriverOnErrorJustComplete()
        let description = user.map { $0.bio ?? $0.descriptionField ?? "" }.asDriverOnErrorJustComplete()
        let imageUrl = user.map { $0.avatarUrl?.url }.asDriverOnErrorJustComplete()
        
        let openInWebSelected = input.openInWebSelection
            .withUnretained(self)
            .map { $0.0.user.value.htmlUrl?.url }
            .filterNil()
            .withUnretained(self)
            .map { WebViewModel(with: $0.1, provider: $0.0.provider) }
            .asDriverOnErrorJustComplete()
        
        let hidesFollowButton = Observable.combineLatest(loggedIn, user)
            .map({ (loggedIn, user) -> Bool in
                guard loggedIn == true else { return true }
                return user.isMine() == true || user.type == .organization
            })
            .asDriver(onErrorJustReturn: false)
        
        let following = user.map { $0.viewerIsFollowing }.filterNil()
        
        let items = user.map { (user) -> [UserSection] in
            var items: [UserSectionItem] = []
            
            // Repositories Count
            let repositoriesCountCellViewModel = UserDetailCellViewModel(with: R.string.localizable.userRepositoriesButtonTitle.key.localized(),
                                                                         detail: user.repositoriesCount?.string ?? "0",
                                                                         image: R.image.icon_cell_created()?.template,
                                                                         hidesDisclosure: true)
            items.append(UserSectionItem.createdItem(viewModel: repositoriesCountCellViewModel))
            
            // Followers Count
            let followersCountCellViewModel = UserDetailCellViewModel(with: R.string.localizable.userFollowersButtonTitle.key.localized(),
                                                                      detail: user.followers?.string ?? "0",
                                                                      image: R.image.icon_cell_created()?.template,
                                                                      hidesDisclosure: true)
            items.append(UserSectionItem.createdItem(viewModel: followersCountCellViewModel))
            
            // Following Count
            let followingCountCellViewModel = UserDetailCellViewModel(with: R.string.localizable.userFollowingButtonTitle.key.localized(),
                                                                      detail: user.following?.string ?? "0",
                                                                      image: R.image.icon_cell_created()?.template,
                                                                      hidesDisclosure: true)
            items.append(UserSectionItem.createdItem(viewModel: followingCountCellViewModel))
            
            // Created
            if let created = user.createdAt {
                let createdCellViewModel = UserDetailCellViewModel(with: R.string.localizable.userCreatedCellTitle.key.localized(),
                                                                   detail: created.toRelative(since: nil),
                                                                   image: R.image.icon_cell_created()?.template,
                                                                   hidesDisclosure: true)
                items.append(UserSectionItem.createdItem(viewModel: createdCellViewModel))
            }
            
            // Updated
            if let updated = user.updatedAt {
                let updatedCellViewModel = UserDetailCellViewModel(with: R.string.localizable.userUpdatedCellTitle.key.localized(),
                                                                   detail: updated.toRelative(since: nil),
                                                                   image: R.image.icon_cell_updated()?.template,
                                                                   hidesDisclosure: true)
                items.append(UserSectionItem.updatedItem(viewModel: updatedCellViewModel))
            }
            
            if user.type == .user {
                // Stars
                let starsCellViewModel = UserDetailCellViewModel(with: R.string.localizable.userStarsCellTitle.key.localized(),
                                                                 detail: user.starredRepositoriesCount?.string ?? "0",
                                                                 image: R.image.icon_cell_star()?.template,
                                                                 hidesDisclosure: true)
                items.append(UserSectionItem.starsItem(viewModel: starsCellViewModel))
                
                // Watching
                let watchingCellViewModel = UserDetailCellViewModel(with: R.string.localizable.userWatchingCellTitle.key.localized(),
                                                                    detail: user.watchingCount?.string ?? "0",
                                                                    image: R.image.icon_cell_theme()?.template,
                                                                    hidesDisclosure: true)
                items.append(UserSectionItem.watchingItem(viewModel: watchingCellViewModel))
            }
            
            // Company
            if let company = user.company, company.isNotEmpty {
                let companyCellViewModel = UserDetailCellViewModel(with: R.string.localizable.userCompanyCellTitle.key.localized(),
                                                                   detail: company,
                                                                   image: R.image.icon_cell_company()?.template,
                                                                   hidesDisclosure: false)
                items.append(UserSectionItem.companyItem(viewModel: companyCellViewModel))
            }
            
            // Blog
            if let blog = user.blog, blog.isNotEmpty {
                let companyCellViewModel = UserDetailCellViewModel(with: R.string.localizable.userBlogCellTitle.key.localized(),
                                                                   detail: blog,
                                                                   image: R.image.icon_cell_link()?.template,
                                                                   hidesDisclosure: false)
                items.append(UserSectionItem.blogItem(viewModel: companyCellViewModel))
            }
            
            // Profile Summary
            let profileSummaryCellViewModel = UserDetailCellViewModel(with: R.string.localizable.userProfileSummaryCellTitle.key.localized(),
                                                                      detail: "\(Configs.Network.profileSummaryBaseUrl)",
                                                                      image: R.image.icon_cell_profile_summary()?.template,
                                                                      hidesDisclosure: false)
            items.append(UserSectionItem.profileSummaryItem(viewModel: profileSummaryCellViewModel))
            
            var userSections: [UserSection] = []
            userSections.append(UserSection.user(title: "", items: items))
            
            return userSections
        }
        
        let selectedEvent = input.selection.asDriverOnErrorJustComplete()
        
        return Output(items: items,
                      username: username,
                      fullname: fullname,
                      description: description,
                      imageUrl: imageUrl,
                      following: following.asDriver(onErrorJustReturn: false),
                      hidesFollowButton: hidesFollowButton,
                      openInWebSelected: openInWebSelected,
                      selectedEvent: selectedEvent)
    }
    
    func viewModel(for item: UserSectionItem) -> ViewModel? {
        let user = self.user.value
        switch item {
        case .repositoriesCount: return nil
        case .followerCount: return nil
        case .followingCount: return nil
        case .createdItem: return nil
        case .updatedItem: return nil
        case .starsItem: return nil
        case .watchingItem: return nil
        case .companyItem:
            if let companyName = user.company?.removingPrefix("@") {
                var user = User()
                user.login = companyName
                let viewModel = UserViewModel(user: user, provider: provider)
                return viewModel
            }
        case .blogItem: return nil
        case .profileSummaryItem: return nil
        }
        return nil
    }
    
    func blogUrl() -> WebViewModel? {
        let url = user.value.blog?.url
        guard let url = url else { return nil }
        return WebViewModel(with: url, provider: provider)
    }
    
    func profileSummaryUrl() -> WebViewModel? {
        let url = "\(Configs.Network.profileSummaryBaseUrl)/user/\(self.user.value.login ?? "")".url
        guard let url = url else { return nil }
        return WebViewModel(with: url, provider: provider)
    }
}
