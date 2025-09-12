//
//  Created by Alex.M on 30.06.2022.
//

import Foundation

extension URLCache {
    static let imageCache = URLCache(
        memoryCapacity: 64.megabytes(), // Reduced for avatars
        diskCapacity: 256.megabytes()   // Reduced for avatars
    )
}

private extension Int {
    func kilobytes() -> Int {
        self * 1024
    }

    func megabytes() -> Int {
        self * 1024 * 1024
    }

    func gigabytes() -> Int {
        self * 1024 * 1024 * 1024
    }
}
