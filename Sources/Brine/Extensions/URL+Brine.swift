
import Foundation

extension URL {

    /**
     Returns the path file name without file extension.
     */
    var fileName: String {
        return self.deletingPathExtension().lastPathComponent
    }

    var isDirectoryPath: Bool {
        if #available(OSX 10.11, *) {
            return self.hasDirectoryPath
        }
        do {
            let values = try self.resourceValues(forKeys: [.isDirectoryKey])
            return values.isDirectory ?? false
        } catch {
            return false
        }
    }
}
