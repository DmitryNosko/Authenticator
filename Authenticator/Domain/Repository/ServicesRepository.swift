import RxSwift

protocol ServicesRepository: AnyObject {
    var refreshTrigger: AnyObserver<Void> { get }
    var services: Observable<[Service]> { get }

    func service(name: String) -> Service?
}

final class ServicesRepositoryImpl: ServicesRepository {
    private let refreshSubject = PublishSubject<Void>()
    private(set) lazy var refreshTrigger: AnyObserver<Void> = {
        refreshSubject
            .compactMap { [weak self] in self?.fetchServices() }
            .bind(to: servicesSubject)
            .disposed(by: disposeBag)
        return refreshSubject.asObserver()
    }()

    private let servicesSubject = BehaviorSubject<[Service]>(value: [])
    private(set) lazy var services: Observable<[Service]> = {
        return servicesSubject.asObservable()
    }()

    private let disposeBag = DisposeBag()

    init() {
        refreshTrigger.onNext(())
    }

    func service(name: String) -> Service? {
        let services = (try? servicesSubject.value()) ?? []
        return services.first(where: { $0.serviceName.lowercased() == name.lowercased() })
    }

    private func fetchServices() -> [Service] {
        guard let url = Bundle.main.url(forResource: "Services", withExtension: "json") else { return [] }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let jsonData = try decoder.decode([Service].self, from: data)
            return jsonData
        } catch {
#if DEBUG
            print("⚠️ ServicesRepositoryError: \(error)")
#endif
            return []
        }
        /*
         func loadJson() -> [Service] {
             if let url = Bundle.main.url(forResource: "Services", withExtension: "json") {
                 do {
                     let data = try Data(contentsOf: url)
                     let decoder = JSONDecoder()
                     let jsonData = try decoder.decode([Service].self, from: data)
                     return jsonData
                 } catch {
                     print("error:\(error)")
                 }
             }
             return []
         }
         */
    }
}
