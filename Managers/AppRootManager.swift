import UIKit
import Kingfisher

final class AppCoordinator: NSObject, Manager, UITabBarControllerDelegate {
    
    // MARK: - Properties
    private let window: UIWindow
    private var tabBarController: UITabBarController?
    
    // MARK: - Initialization
    init(window: UIWindow) {
        self.window = window
    }
    
    // MARK: - Lifecycle
    func start() {
        if #available(iOS 15.0, *) {
            AppCoordinator.configureTabBar()
            AppCoordinator.configureNavigationBar()
        }
        
        ImageCache.default.clearMemoryCache()
        ImageCache.default.clearDiskCache()
        
        showMainTabBar()
    }
    
    // MARK: - Private Methods
    private func showMainTabBar() {
        let mainStoryboard = UIStoryboard(name: StoryboardConstants.mainBoard, bundle: nil)
        guard let tabBarController = mainStoryboard.instantiateViewController(
            withIdentifier: StoryboardConstants.swipeTabBarVCIdentifier) as? UITabBarController else {
            assertionFailure("SwipeTabBarController storyboard ID is wrong or missing")
            return
        }
        
        self.tabBarController = tabBarController
        tabBarController.selectedIndex = TabBarConstants.startIndex
        tabBarController.delegate = self
        
        let homeNav = UIStoryboard(name: StoryboardConstants.homeBoard, bundle: nil)
            .instantiateViewController(withIdentifier: StoryboardConstants.homeNCIdentifier)
        
        let favoritesNav = UIStoryboard(name: StoryboardConstants.favoritesBoard, bundle: nil)
            .instantiateViewController(withIdentifier: StoryboardConstants.favoritesNCIdentifier)
        
        let moviesNav = UIStoryboard(name: StoryboardConstants.moviesBoard, bundle: nil)
            .instantiateViewController(withIdentifier: StoryboardConstants.moviesNCIdentifier)
        
        let searchNav = UIStoryboard(name: StoryboardConstants.searchBoard, bundle: nil)
            .instantiateViewController(withIdentifier: StoryboardConstants.searchNCIdentifier)
        
        let chatNav = UIStoryboard(name: StoryboardConstants.chatBoard, bundle: nil)
            .instantiateViewController(withIdentifier: StoryboardConstants.chatNCIdentifier)
        
        tabBarController.viewControllers = [
            searchNav,
            favoritesNav,
            homeNav,
            moviesNav,
            chatNav
        ]
        
        tabBarController.selectedIndex = TabBarConstants.startIndex

        let titles = TabBarConstants.titles
        tabBarController.viewControllers?.enumerated().forEach { index, vc in
            vc.tabBarItem.title = titles[safe: index]
        }
        
        addSwipeGestures(to: tabBarController)
        
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
    
    
    private func configureTabTitles(for tabBarController: UITabBarController) {
        guard let items = tabBarController.viewControllers else { return }
        
        let titles = TabBarConstants.titles
        
        for (index, vc) in items.enumerated() where index < titles.count {
            vc.tabBarItem.title = titles[index]
        }
    }
    
    private func addSwipeGestures(to tabBarController: UITabBarController) {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        
        tabBarController.view.addGestureRecognizer(swipeLeft)
        tabBarController.view.addGestureRecognizer(swipeRight)
    }
    
    // MARK: - Actions
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        guard let tabBarController = tabBarController else { return }
        let maxIndex = (tabBarController.viewControllers?.count ?? 1) - 1
        
        switch gesture.direction {
        case .left where tabBarController.selectedIndex < maxIndex:
            tabBarController.selectedIndex += 1
        case .right where tabBarController.selectedIndex > 0:
            tabBarController.selectedIndex -= 1
        default:
            break
        }
    }
    
    // MARK: - UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController,
                          animationControllerForTransitionFrom fromVC: UIViewController,
                          to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard
            let viewControllers = tabBarController.viewControllers,
            let fromIndex = viewControllers.firstIndex(of: fromVC),
            let toIndex = viewControllers.firstIndex(of: toVC)
        else {
            return nil
        }
        
        let isForward = toIndex > fromIndex
        return HorizontalSlideTransition(isForward: isForward)
    }
    
    // MARK: - UI Configuration
    static func configureNavigationBar() {
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithTransparentBackground()
        navAppearance.titleTextAttributes = [
            .foregroundColor: ColorConstants.labelColor,
            .font: FontConstants.navBarTitleFont
        ]
        
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
    }
    
    static func configureTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = ColorConstants.primaryColor
        
        
        let secondaryColor = ColorConstants.secondaryLabelColor
        
        appearance.stackedLayoutAppearance.normal.iconColor = secondaryColor
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: secondaryColor
        ]
        
        appearance.stackedLayoutAppearance.selected.iconColor = ColorConstants.labelColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: ColorConstants.labelColor
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}
