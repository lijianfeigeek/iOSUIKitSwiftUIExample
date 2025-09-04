//
//  ViewController.swift
//  iOSUIKitSwiftUIExample
//
//  Created by LIJIANFEI on 4/9/25.
//

import UIKit
import SwiftUI

// MARK: - Data Model
struct EventModel: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let date: Date
    let duration: TimeInterval
    let location: String?
    let isAllDay: Bool
    
    init(title: String, date: Date, duration: TimeInterval = 3600, location: String? = nil, isAllDay: Bool = false) {
        self.title = title
        self.date = date
        self.duration = duration
        self.location = location
        self.isAllDay = isAllDay
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = isAllDay ? .none : .short
        return formatter.string(from: date)
    }
    
    var formattedDuration: String {
        if isAllDay {
            return "全天"
        } else {
            let hours = Int(duration) / 3600
            let minutes = (Int(duration) % 3600) / 60
            if hours > 0 {
                return "\(hours)小时\(minutes > 0 ? " \(minutes)分钟" : "")"
            } else {
                return "\(minutes)分钟"
            }
        }
    }
}

// MARK: - SwiftUI View
struct DateDetailsView: View {
    let title: String
    let events: [EventModel]
    let lineWidth: Double
    
    var body: some View {
        VStack(spacing: 16) {
            // 标题区域
            HStack {
                Text(title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("共 \(events.count) 个事件")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            // 分隔线
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: lineWidth)
                .padding(.horizontal)
            
            // 事件列表
            if events.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    
                    Text("暂无事件")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("这一天还没有安排任何事件")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(events, id: \.id) { event in
                            EventRowView(event: event)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            Spacer()
        }
        .padding(.top, 20)
        .padding(.bottom, 16)
        .background(Color(.systemBackground))
    }
}

struct EventRowView: View {
    let event: EventModel
    
    var body: some View {
        HStack(spacing: 12) {
            // 时间指示器
            VStack(spacing: 4) {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 8, height: 8)
                
                Rectangle()
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                HStack {
                    Text(event.formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if !event.isAllDay {
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(event.formattedDuration)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if let location = event.location {
                    HStack {
                        Image(systemName: "location.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(location)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - UIHostingController
private final class DateDetailsHostVC: UIHostingController<DateDetailsView>, UIPopoverPresentationControllerDelegate {
    
    override init(rootView: DateDetailsView) {
        super.init(rootView: rootView)
        setupAppearance()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVisualEffects()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        adjustPreferredSize()
    }
    
    // MARK: - Private Methods
    
    private func setupAppearance() {
        view.backgroundColor = .systemBackground
        
        // 配置视图控制器样式
        if presentingViewController != nil {
            modalPresentationStyle = .formSheet
            modalTransitionStyle = .coverVertical
        }
    }
    
    private func setupVisualEffects() {
        // 设置背景效果
        view.backgroundColor = .systemBackground
        
        // 设置圆角
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        
        // 添加阴影效果
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.1
    }
    
    private func adjustPreferredSize() {
        // 如果已经设置了 preferredContentSize，则不再动态调整
        // 这样可以保持我们在工厂方法中设置的大尺寸
        if preferredContentSize.width > 0 && preferredContentSize.height > 0 {
            return
        }
        
        // 只在没有设置尺寸时才进行动态调整
        let fittingSize = view.systemLayoutSizeFitting(
            CGSize(
                width: UIScreen.main.bounds.width * 0.8,
                height: UIView.layoutFittingCompressedSize.height
            )
        )
        
        // 限制最大宽度和高度
        let maxWidth = UIScreen.main.bounds.width * 0.9
        let maxHeight = UIScreen.main.bounds.height * 0.8
        
        let finalSize = CGSize(
            width: min(fittingSize.width, maxWidth),
            height: min(fittingSize.height, maxHeight)
        )
        
        preferredContentSize = finalSize
    }
}

// MARK: - Factory Methods
extension DateDetailsHostVC {
    
    static func createPopover(
        title: String,
        events: [EventModel],
        lineWidth: Double = 1.0
    ) -> UIViewController {
        let hostingController = DateDetailsHostVC(
            rootView: DateDetailsView(
                title: title,
                events: events,
                lineWidth: lineWidth
            )
        )
        
        // 配置为弹出框
        hostingController.modalPresentationStyle = .popover
        
        // 根据 UIDevice 类型设置不同的尺寸
        if UIDevice.current.userInterfaceIdiom == .pad {
            // iPad 上设置更大的尺寸，确保内容完整显示
            hostingController.preferredContentSize = CGSize(width: 700, height: 800)
        } else {
            // iPhone 上保持较小的尺寸
            hostingController.preferredContentSize = CGSize(width: 320, height: 400)
        }
        
        // 配置弹出框委托
        hostingController.popoverPresentationController?.delegate = hostingController
        
        return hostingController
    }
    
    static func createFormSheet(
        title: String,
        events: [EventModel],
        lineWidth: Double = 1.0
    ) -> UIViewController {
        let hostingController = DateDetailsHostVC(
            rootView: DateDetailsView(
                title: title,
                events: events,
                lineWidth: lineWidth
            )
        )
        
        // 配置为表单
        hostingController.modalPresentationStyle = .formSheet
        
        // 根据 UIDevice 类型设置不同的尺寸
        if UIDevice.current.userInterfaceIdiom == .pad {
            // iPad 上设置更大的尺寸，确保内容完整显示
            hostingController.preferredContentSize = CGSize(width: 800, height: 900)
        } else {
            // iPhone 上保持较小的尺寸
            hostingController.preferredContentSize = CGSize(width: 400, height: 500)
        }
        
        return hostingController
    }
}

// MARK: - Main View Controller
class ViewController: UIViewController {

    private let showSwiftUIButton = UIButton(type: .system)
    private let showPopoverButton = UIButton(type: .system)
    private let showFormSheetButton = UIButton(type: .system)
    
    private let stackView = UIStackView()
    
    // 示例事件数据
    private lazy var sampleEvents: [EventModel] = {
        let calendar = Calendar.current
        let today = Date()
        
        return [
            EventModel(
                title: "晨会",
                date: calendar.date(bySettingHour: 9, minute: 0, second: 0, of: today)!,
                duration: 1800,
                location: "会议室A",
                isAllDay: false
            ),
            EventModel(
                title: "代码审查",
                date: calendar.date(bySettingHour: 10, minute: 30, second: 0, of: today)!,
                duration: 3600,
                location: "会议室B",
                isAllDay: false
            ),
            EventModel(
                title: "午餐会议",
                date: calendar.date(bySettingHour: 12, minute: 0, second: 0, of: today)!,
                duration: 3600,
                location: "餐厅",
                isAllDay: false
            ),
            EventModel(
                title: "客户演示",
                date: calendar.date(bySettingHour: 14, minute: 0, second: 0, of: today)!,
                duration: 5400,
                location: "会议室C",
                isAllDay: false
            ),
            EventModel(
                title: "团队建设活动",
                date: calendar.date(byAdding: .day, value: 1, to: today)!,
                duration: 0,
                location: "户外活动中心",
                isAllDay: true
            )
        ]
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "UIKit + SwiftUI 集成示例"
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // 配置堆栈视图
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        // 配置按钮
        setupButton(showSwiftUIButton, title: "显示 SwiftUI 视图 (内嵌)3秒停留", selector: #selector(showSwiftUIView))
        setupButton(showPopoverButton, title: "显示 SwiftUI 视图 (弹出框)（iPad上有区别）", selector: #selector(showPopover))
        setupButton(showFormSheetButton, title: "显示 SwiftUI 视图 (表单)（iPad上有区别）", selector: #selector(showFormSheet))
        
        // 添加按钮到堆栈视图
        [showSwiftUIButton, showPopoverButton, showFormSheetButton].forEach {
            stackView.addArrangedSubview($0)
        }
    }
    
    private func setupButton(_ button: UIButton, title: String, selector: Selector) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: selector, for: .touchUpInside)
        
        // Use modern button configuration to avoid deprecation warning
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            config.title = title
            config.baseBackgroundColor = .systemBlue
            config.baseForegroundColor = .white
            config.cornerStyle = .medium
            config.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 24)
            button.configuration = config
        } else {
            button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 24, bottom: 16, right: 24)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
            stackView.widthAnchor.constraint(lessThanOrEqualToConstant: 400)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func showSwiftUIView() {
        let hostingController = DateDetailsHostVC(
            rootView: DateDetailsView(
                title: "今日日程",
                events: sampleEvents,
                lineWidth: 1.0
            )
        )
        
        // 作为子控制器添加到当前视图
        addChild(hostingController)
        view.addSubview(hostingController.view)
        
        // 设置约束
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            hostingController.view.heightAnchor.constraint(equalToConstant: 300)
        ])
        
        hostingController.didMove(toParent: self)
        
        // 3秒后自动移除
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.removeSwiftUIView(hostingController)
        }
    }
    
    private func removeSwiftUIView(_ hostingController: UIViewController) {
        hostingController.willMove(toParent: nil)
        hostingController.view.removeFromSuperview()
        hostingController.removeFromParent()
    }
    
    @objc private func showPopover() {
        let hostingController = DateDetailsHostVC.createPopover(
            title: "今日日程",
            events: sampleEvents,
            lineWidth: 1.0
        )
        
        // 设置弹出框源视图
        if let popover = hostingController.popoverPresentationController {
            popover.sourceView = showPopoverButton
            popover.sourceRect = showPopoverButton.bounds
            popover.permittedArrowDirections = .up
        }
        
        present(hostingController, animated: true)
    }
    
    @objc private func showFormSheet() {
        let hostingController = DateDetailsHostVC.createFormSheet(
            title: "本周日程",
            events: sampleEvents,
            lineWidth: 1.0
        )
        
        present(hostingController, animated: true)
    }
}
