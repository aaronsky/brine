import Brine

@objc class TestDriver: NSObject {
    let brine: Brine

    override init() {
        brine = Brine()
        super.init()
        Steps.registerSteps()
        brine.configure(with: configurations())
    }

    @objc func start() {
        brine.start(filterForTags: self.filterTags())
    }

    func configurations() -> [Configuration] {
        let bundle = Bundle(for: type(of: self))
        guard let featuresPath = bundle.resourceURL?.appendingPathComponent("Features") else {
            return []
        }
        return [Configuration(featuresPath: featuresPath)]
    }

    func filterTags() -> [String] {
        return []
    }
}
