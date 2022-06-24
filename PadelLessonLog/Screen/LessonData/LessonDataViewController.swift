//
//  TechniqueViewController.swift
//  PadelLessonLog
//
//  Created by Yoshitaka on 2021/08/11.
//

import UIKit

final class LessonDataViewController: BaseViewController {
    struct Dependency {
        let viewModel: LessonDataViewModel
    }
    static func makeInstance(dependency: Dependency) -> LessonDataViewController {
        // swiftlint:disable force_unwrapping
        let viewController = R.storyboard.lessonData.lessonData()!
        // swiftlint:enable force_unwrapping
        viewController.viewModel = dependency.viewModel
        return viewController
    }
    enum Section {
        case main
    }
    class LessonItem: Hashable {
        let title: String
        var subitems: [LessonItem]
        let baseLesson: BaseLesson
        var isGroup: Bool

        init(title: String,
             baseLesson: BaseLesson,
             subitems: [LessonItem] = [], isGroup: Bool = false) {
            self.title = title
            self.subitems = subitems
            self.baseLesson = baseLesson
            self.isGroup = isGroup
        }
        func hash(into hasher: inout Hasher) {
            hasher.combine(baseLesson.orderNum)
        }
        static func == (lhs: LessonItem, rhs: LessonItem) -> Bool {
            return lhs.baseLesson.orderNum == rhs.baseLesson.orderNum
        }
    }
    var dataSource: UICollectionViewDiffableDataSource<Section, LessonItem>! = nil
    var lessonItems: [LessonItem] = []
    @IBOutlet private weak var viewForTable: UIView!
    var modernCollectionView: UICollectionView! = nil

    @IBOutlet private weak var customToolbar: UIToolbar!
    // swiftlint:disable private_outlet
    @IBOutlet private(set) weak var allBarButton: UIBarButtonItem!
    @IBOutlet private(set) weak var favoriteBarButton: UIBarButtonItem!
    @IBOutlet private(set) weak var searchBar: UISearchBar!
    @IBOutlet private(set) weak var searchButton: UIBarButtonItem!
    // swiftlint:enable private_outlet
    private var viewModel: LessonDataViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customToolbar.isTranslucent = false
        customToolbar.barTintColor = UIColor.systemBackground
        customToolbar.barStyle = .default
        allBarButton.style = .done
        favoriteBarButton.style = .done
        
        if let tabBarCon = parent as? UITabBarController {
            tabBarCon.navigationItem.leftBarButtonItem = self.createBarButtonItem(image: UIImage.gearshape, select: #selector(setting))
            tabBarCon.navigationItem.rightBarButtonItem = self.createBarButtonItem(image: UIImage.plusCircle, select: #selector(addNewLesson))
        }
        searchBar.delegate = self
        searchBar.isHidden = true
        searchBar.autocapitalizationType = .none
        
        configureCollectionView()
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(cellLongPressed))
        longPressRecognizer.delegate = self
        longPressRecognizer.minimumPressDuration = 1.0
        modernCollectionView.addGestureRecognizer(longPressRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        allButtonPressed(allBarButton)
        self.configureDataSource()
    }
    
    override func bind() {
        viewModel.allBarButtonIsOn
            .map { $0 ? .colorButtonOn : .colorButtonOff }
            .assign(to: \.tintColor, on: allBarButton)
            .store(in: &subscriptions)
        
        viewModel.favoriteBarButtonIsOn.sink { [weak self] isOn in
            guard let self = self else { return }
            self.favoriteBarButton.tintColor = isOn ? .colorButtonOn : .colorButtonOff
        }.store(in: &subscriptions)
        
        viewModel.transition.sink { [weak self] transition in
            guard let self = self else { return }
            switch transition {
            case .setting:
                guard let vc = R.storyboard.setting.setting() else { return }
                self.navigationController?.pushViewController(vc, animated: true)
            case let .lesson(lessonData, isNew):
                guard let newLessonVC = R.storyboard.newLesson.newLesson() else { return }
                newLessonVC.lessonData = lessonData
                newLessonVC.delegate = self
                
                if isNew {
                    newLessonVC.navigationItem.title = R.string.localizable.createNewData()
                } else {
                    newLessonVC.navigationItem.title = R.string.localizable.editData()
                }
                self.navigationController?.pushViewController(newLessonVC, animated: true)
            case let .detail(lessonData):
                guard let detailVC = R.storyboard.detail.detail() else { return }
                detailVC.lessonData = lessonData
                detailVC.delegate = self
                
                let nvc = UINavigationController(rootViewController: detailVC)
                self.present(nvc, animated: true)
            default:
                break
            }
        }.store(in: &subscriptions)
        
        viewModel.lessonsArray.sink { [weak self] baseLessons in
            guard let self = self else { return }
            var subItems: [Lesson] = []
            let lessonData: [LessonItem] = baseLessons.map { baseLesson -> LessonItem? in
                if let lesson = baseLesson.isLesson() {
                    if lesson.isGroupedLesson() {
                        subItems.append(lesson)
                        return nil
                    } else {
                        return LessonItem(title: lesson.title ?? "", baseLesson: lesson)
                    }
                } else if let group = baseLesson.isGroup() {
                    return LessonItem(title: group.title ?? "", baseLesson: group, isGroup: true)
                } else {
                    return nil
                }
            }.compactMap { $0 }
            
            self.lessonItems = lessonData
            
            if !subItems.isEmpty {
                subItems.forEach { lesson in
                    _ = self.lessonItems.first(where: {
                        if let group = $0.baseLesson as? LessonGroup {
                            if group.groupId == lesson.inGroup {
                                $0.subitems.append(LessonItem(title: lesson.title ?? "", baseLesson: lesson))
                                return true
                            }
                        }
                        return false
                    })
                }
            }
            
            if self.modernCollectionView != nil, self.dataSource != nil {
                let snapshot = self.initialSnapshot()
                self.dataSource.apply(snapshot, to: .main, animatingDifferences: true)
            }
        }.store(in: &subscriptions)
        
        viewModel.scrollToTableIndex.sink { [weak self] tableIndex in
            guard let self = self else { return }
            self.modernCollectionView.scrollToItem(at: IndexPath(item: tableIndex, section: 0), at: .top, animated: true)
        }.store(in: &subscriptions)
    }
    
    override func setting() {
        viewModel.settingButtonPressed.send()
    }
    
    override func addNewLesson() {
        viewModel.addLessonButtonPressed.send()
    }
    // swiftlint:disable private_action
    @IBAction func searchButtonPressed(_ sender: UIBarButtonItem) {
        searchBar.isHidden.toggle()
        searchButton.tintColor = searchBar.isHidden ? UIColor.colorButtonOff : UIColor.colorButtonOn
        if searchBar.isHidden {
            viewModel.dataReload.send()
        }
    }
    @IBAction func allButtonPressed(_ sender: UIBarButtonItem) {
        viewModel.allButtonPressed.send()
    }
    @IBAction func favoriteButtonPressed(_ sender: UIBarButtonItem) {
        viewModel.favoriteButtonPressed.send()
    }
    // swiftlint:enable private_action
}

// swiftlint:disable unused_closure_parameter
extension LessonDataViewController: UICollectionViewDelegate {
    func configureCollectionView() {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: generateLayout())
        viewForTable.addSubview(collectionView)
        collectionView.autoresizingMask = [.flexibleHeight, .flexibleRightMargin]
//        collectionView.backgroundColor = .appColor
        collectionView.tintColor = .arBlue
        self.modernCollectionView = collectionView
        collectionView.delegate = self
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        collectionView.reorderingCadence = .fast
        collectionView.isSpringLoaded = true
    }
    func generateLayout() -> UICollectionViewLayout {
        let listConfiguration = UICollectionLayoutListConfiguration(appearance: .sidebarPlain)
        let layout = UICollectionViewCompositionalLayout.list(using: listConfiguration)
        return layout
    }
    
    func configureDataSource() {
        let containerCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, LessonItem> { cell, indexPath, baseLesson in
            var contentConfiguration = cell.defaultContentConfiguration()
            contentConfiguration.text = baseLesson.title
            contentConfiguration.textProperties.font = .preferredFont(forTextStyle: .headline)
            cell.contentConfiguration = contentConfiguration
            
            let disclosureOptions = UICellAccessory.OutlineDisclosureOptions(style: .header)
            cell.accessories = [.outlineDisclosure(options: disclosureOptions)]
            cell.backgroundConfiguration = UIBackgroundConfiguration.clear()
        }
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, LessonItem> { cell, indexPath, baseLesson in
            var contentConfiguration = cell.defaultContentConfiguration()
            contentConfiguration.text = baseLesson.title
            cell.contentConfiguration = contentConfiguration
            
            if let lesson = baseLesson.baseLesson.isLesson() {
                let favoriteAction = UIAction(image: lesson.favorite ? UIImage(systemName: "star.fill") : UIImage(systemName: "star"),
                                              handler: { [weak self] _ in
                    guard let self = self else { return }
                    self.viewModel.favoriteToggled.send(lesson)
                })
                let favoriteButton = UIButton(primaryAction: favoriteAction)
                favoriteButton.tintColor = lesson.favorite ? .systemYellow : .lightGray

                let favoriteAccessory = UICellAccessory.CustomViewConfiguration(
                    customView: favoriteButton,
                    placement: .leading(displayed: .always)
                )
                cell.accessories = [.customView(configuration: favoriteAccessory)]
            }
            
            cell.backgroundConfiguration = UIBackgroundConfiguration.clear()
        }
        dataSource = UICollectionViewDiffableDataSource<Section, LessonItem>(collectionView: modernCollectionView) {(collectionView: UICollectionView, indexPath: IndexPath, item: LessonItem) -> UICollectionViewCell? in
            // Return the cell.
            if item.baseLesson.isGroup() != nil {
                return collectionView.dequeueConfiguredReusableCell(using: containerCellRegistration, for: indexPath, item: item)
            } else {
                return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
            }
        }
        
        let snapshot = initialSnapshot()
        self.dataSource.apply(snapshot, to: .main, animatingDifferences: true)
    }
    
    func initialSnapshot() -> NSDiffableDataSourceSectionSnapshot<LessonItem> {
        var snapshot = NSDiffableDataSourceSectionSnapshot<LessonItem>()
        
        func addItems(_ lessonItems: [LessonItem], to parent: LessonItem?) {
            snapshot.append(lessonItems, to: parent)
            for lessonItem in lessonItems where !lessonItem.subitems.isEmpty {
                addItems(lessonItem.subitems, to: lessonItem)
            }
        }
        addItems(lessonItems, to: nil)
        return snapshot
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let baseLessonItem = dataSource.itemIdentifier(for: indexPath)
        guard let lesson = baseLessonItem?.baseLesson.isLesson() else { return }
        viewModel.didSelectItemAt.send(lesson)
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
// swiftlint:enable unused_closure_parameter

extension LessonDataViewController: UICollectionViewDragDelegate, UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard let lessonItem = self.dataSource.itemIdentifier(for: indexPath) else { return [] }
        let itemProvider = NSItemProvider(object: "\(indexPath)" as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = lessonItem
        return viewModel.tableMode.value == .allTableView ? [dragItem] : []
    }
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        
        if collectionView.hasActiveDrag {
            if let to = destinationIndexPath, let targetLessonItem = dataSource.itemIdentifier(for: to) {
                if let dragItem = session.items.first?.localObject as? LessonItem, dragItem.isGroup {
                    // ドラッグしたアイテムがグループ
                    return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
                } else {
                    // ドラッグしたアイテムがレッスン
                    return UICollectionViewDropProposal(operation: .move, intent: targetLessonItem.isGroup ? .insertIntoDestinationIndexPath : .insertAtDestinationIndexPath)
                }
            }
        }
        return UICollectionViewDropProposal(operation: .forbidden)
    }
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        if let destinationIndexPath = coordinator.destinationIndexPath, let destinationItem = dataSource.itemIdentifier(for: destinationIndexPath), let sourceIndexPath = coordinator.items.first?.sourceIndexPath, let dragItem = coordinator.items.first?.dragItem {
            
            guard let dragLessonItem = dragItem.localObject as? LessonItem else { return }
            
            // アイテムのフォルダ挿入かどうか
            if coordinator.proposal.intent == .insertIntoDestinationIndexPath {
                // insertIntoの場合
                guard let lesson = dragLessonItem.baseLesson.isLesson(), let group = destinationItem.baseLesson.isGroup() else { return }
                viewModel.moveIntoGroup.send((lesson, group))
            } else {
                coordinator.drop(dragItem, toItemAt: destinationIndexPath)
                // insertAtの場合
                // ドラッグ中のアイテムがレッスンかどうか
                if let dragLesson = dragLessonItem.baseLesson.isLesson() {
                    // ドラッグしたアイテムがレッスン
                    if dragLesson.isGroupedLesson() {
                        // ドラッグしたアイテムがグループ内
                        // insertAt先がレッスンかどうか
                        if let destinationLesson = destinationItem.baseLesson.isLesson() {
                            // insertAt先がレッスン
                            // insertAt先がグループ内かどうか
                            if destinationLesson.isGroupedLesson() {
                                // insertAt先がグループ内
                                viewModel.reorderInsideOfGroup.send((dragLesson, destinationLesson))
                            } else {
                                // insertAt先がグループ外
                                viewModel.reorderData.send((dragLesson, nil, destinationIndexPath))
                            }
                        } else {
                            // insertAt先がグループ
                            viewModel.reorderData.send((dragLesson, nil, destinationIndexPath))
                        }
                    } else {
                        // ドラッグしたアイテムがグループ外
                        // insertAt先がレッスンかどうか
                        if let destinationLesson = destinationItem.baseLesson.isLesson() {
                            // insertAt先がレッスン
                            // insertAt先がグループ内かどうか
                            if destinationLesson.isGroupedLesson() {
                                // insertAt先がグループ内
                                viewModel.reorderInsideOfGroup.send((dragLesson, destinationLesson))
                            } else {
                                // insertAt先がグループ外
                                viewModel.reorderData.send((dragLesson, sourceIndexPath, destinationIndexPath))
                            }
                        } else {
                            // insertAt先がグループ
                            viewModel.reorderData.send((dragLesson, sourceIndexPath, destinationIndexPath))
                        }
                    }
                } else {
                    // ドラッグしたアイテムがグループ
                    guard let dragGroup = dragLessonItem.baseLesson as? LessonGroup else { return }
                    viewModel.reorderData.send((dragGroup, sourceIndexPath, destinationIndexPath))
                }
            }
        } else {
            assertionFailure("ドラッグ&ドロップに失敗しました。")
        }
    }
}

extension LessonDataViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        viewModel.dataReload.send()
        guard let text = searchBar.text else { return }
        if !text.isEmpty {
            viewModel.searchAndFilterData.send(text)
        }
    }
}

extension LessonDataViewController {
    @objc
    func cellLongPressed(recognizer: UITapGestureRecognizer) {
        guard viewModel.tableMode.value == .allTableView else { return }
        
        let point = recognizer.location(in: modernCollectionView)
        let indexPath = modernCollectionView.indexPathForItem(at: point)
        guard let index = indexPath else { return }
        guard let targetLessonItem = dataSource.itemIdentifier(for: index) else { return }
        if let targetLesson = targetLessonItem.baseLesson.isLesson() {
            if targetLesson.isGroupedLesson() {
                confirmationAlertView(withTitle: "データ移動", message: "レッスンデータをフォルダ外へ移動します", cancelString: "キャンセル", confirmString: "移動") {
                    self.viewModel.reorderData.send((targetLesson, nil, IndexPath(item: 0, section: 0)))
                }
            } else {
                textInputAlertView(withTitle: "フォルダ作成", cancelString: "キャンセル", placeholder: "フォルダ名を入力してください", confirmString: "作成") { textField in
                    self.viewModel.createNewGroup.send((index, textField.text))
                }
            }
        } else if let targetGroup = targetLessonItem.baseLesson.isGroup() {
            if targetLessonItem.subitems.isEmpty {
                destructiveAlertView(withTitle: "フォルダ削除", message: "空のフォルダを削除しますか？", cancelString: "キャンセル", destructiveString: "削除") {
                    self.viewModel.deleteGroup.send(targetGroup)
                }
            } else {
                textInputAlertView(withTitle: "フォルダ名を更新", cancelString: "キャンセル", placeholder: "新しいフォルダ名を入力してください", confirmString: "更新") { textField in
                    self.viewModel.renameGroup.send((targetGroup, textField.text))
                }
            }
        }
        
    }
}

extension LessonDataViewController: DetailViewControllerDelegate {
    func detailViewController(_ detailViewController: DetailViewController, didSelectEdit lesson: Lesson) {
        viewModel.pushToEditLessonView.send(lesson)
    }
}

extension LessonDataViewController: NewLessonViewControllerDelegate {
    func didSaveLessonData(_ newLessonViewController: NewLessonViewController) {
        viewModel.pushBackFromNewLessonView.send()
    }
}
