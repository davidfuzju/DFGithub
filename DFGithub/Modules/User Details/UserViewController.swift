//
//  UserDetailsViewController.swift
//  DFGithub
//
//  Created by David FU on 2025/5/10.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import BonMot

class UserViewController: TableViewController {
    
    lazy var rightBarButton: BarButtonItem = {
        let view = BarButtonItem(image: R.image.icon_navigation_github(), style: .done, target: nil, action: nil)
        return view
    }()
    
    lazy var usernameLabel: Label = {
        let view = Label()
        view.textAlignment = .center
        return view
    }()
    
    lazy var fullnameLabel: Label = {
        let view = Label()
        view.textAlignment = .center
        return view
    }()
    
    lazy var navigationHeaderView: StackView = {
        let subviews: [UIView] = [self.usernameLabel, self.fullnameLabel]
        let view = StackView(arrangedSubviews: subviews)
        view.spacing = 1
        return view
    }()
    
    lazy var ownerImageView: ImageView = {
        let view = ImageView()
        view.layerCornerRadius = 50
        return view
    }()
        
    lazy var detailLabel: Label = {
        var view = Label()
        view.numberOfLines = 0
        return view
    }()
    
    lazy var headerStackView: StackView = {
        let headerView = View()
        headerView.addSubview(self.ownerImageView)
        self.ownerImageView.snp.makeConstraints({ (make) in
            make.top.left.centerX.centerY.equalToSuperview()
            make.size.equalTo(100)
        })
        let subviews: [UIView] = [headerView, self.detailLabel]
        let view = StackView(arrangedSubviews: subviews)
        view.axis = .horizontal
        return view
    }()
    
    lazy var headerView: View = {
        let view = View()
        let subviews: [UIView] = [self.headerStackView]
        let stackView = StackView(arrangedSubviews: subviews)
        view.addSubview(stackView)
        stackView.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview().inset(self.inset)
        })
        return view
    }()
    
    override func makeUI() {
        super.makeUI()
        
        headerView.theme.backgroundColor = themeService.attribute { $0.primaryDark }
        usernameLabel.theme.textColor = themeService.attribute { $0.text }
        detailLabel.theme.textColor = themeService.attribute { $0.text }
        fullnameLabel.theme.textColor = themeService.attribute { $0.textGray }
        
        navigationItem.titleView = navigationHeaderView
        navigationItem.rightBarButtonItem = rightBarButton
        
        emptyDataSetTitle = ""
        emptyDataSetImage = nil
        stackView.insertArrangedSubview(headerView, at: 0)
        tableView.footRefreshControl = nil
        tableView.register(cellWithClass: UserDetailCell.self)
        tableView.register(cellWithClass: RepositoryCell.self)
        tableView.register(cellWithClass: UserCell.self)
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        guard let viewModel = viewModel as? UserViewModel else { return }
        
        let refresh = Observable.of(Observable.just(()), headerRefreshTrigger, languageChanged.asObservable()).merge()
        let input = UserViewModel.Input(headerRefresh: refresh,
                                        openInWebSelection: rightBarButton.rx.tap.throttleForUI().mapToVoid(),
                                        selection: tableView.rx.modelSelected(UserSectionItem.self).throttleForUI())
        let output = viewModel.transform(input: input)
        
        let dataSource = RxTableViewSectionedReloadDataSource<UserSection>(configureCell: { dataSource, tableView, indexPath, item in
            switch item {
                
            case .repositoriesCount(let viewModel),
                    .followerCount(let viewModel),
                    .followingCount(let viewModel),
                    .createdItem(let viewModel),
                    .updatedItem(let viewModel),
                    .starsItem(let viewModel),
                    .watchingItem(let viewModel),
                    .companyItem(let viewModel),
                    .blogItem(let viewModel),
                    .profileSummaryItem(let viewModel):
                let cell = tableView.dequeueReusableCell(withClass: UserDetailCell.self, for: indexPath)
                cell.bind(to: viewModel)
                return cell
            }
        }, titleForHeaderInSection: { dataSource, index in
            let section = dataSource[index]
            return section.title
        })
        
        output.items
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)
        
        Observable.of(output.items.mapToVoid())
            .merge()
            .asDriver(onErrorJustReturn: ())
            .delay(.milliseconds(100))
            .drive(onNext: { [weak self] (_) in
                guard let self = self else { return }
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            })
            .disposed(by: rx.disposeBag)
        
        output.selectedEvent
            .drive(onNext: { [weak self] (item) in
                guard let self = self else { return }
                switch item {
                case .repositoriesCount: break
                case .followerCount: break
                case .followingCount: break
                case .starsItem: break
                case .watchingItem: break
                case .companyItem:
                    if let viewModel = viewModel.viewModel(for: item) as? UserViewModel {
                        self.navigator.show(segue: .userDetails(viewModel: viewModel), sender: self)
                    }
                case .blogItem:
                    if let viewModel = viewModel.blogUrl() {
                        self.navigator.show(segue: .web(viewModel: viewModel), sender: self)
                    }
                case .profileSummaryItem:
                    if let viewModel = viewModel.profileSummaryUrl() {
                        self.navigator.show(segue: .web(viewModel: viewModel), sender: self)
                    }
                default:
                    self.deselectSelectedRow()
                }
            })
            .disposed(by: rx.disposeBag)
        
        output.username.drive(usernameLabel.rx.text).disposed(by: rx.disposeBag)
        output.fullname.drive(fullnameLabel.rx.text).disposed(by: rx.disposeBag)
        output.fullname.map { $0.isEmpty }.drive(fullnameLabel.rx.isHidden).disposed(by: rx.disposeBag)
        output.description.drive(detailLabel.rx.text).disposed(by: rx.disposeBag)
        output.imageUrl.drive(ownerImageView.rx.imageURL).disposed(by: rx.disposeBag)
        
        output.openInWebSelected
            .drive(onNext: { [weak self] viewModel in
                guard let self = self else { return }
                self.navigator.show(segue: .web(viewModel: viewModel), sender: self)
            })
            .disposed(by: rx.disposeBag)
    }
    
    func attributedText(title: String, value: Int) -> NSAttributedString {
        let titleText = title.styled(with: .color(.white),
                                     .font(.boldSystemFont(ofSize: 12)),
                                     .alignment(.center))
        let valueText = value.string.styled(with: .color(.white),
                                            .font(.boldSystemFont(ofSize: 18)),
                                            .alignment(.center))
        return NSAttributedString.composed(of: [
            titleText, Special.nextLine,
            valueText
        ])
    }
}

