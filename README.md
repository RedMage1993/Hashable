A macro that is useful whenever the compiler cannot synthesize conformance to Hashable on its own, e.g. a class that represents a destination type for a NavigationPath.

```
import Hashable

@Hashable
class ComplexType {
    let property1: AHashableType
    let property2: AnotherHashableType
    let property3: String

    // init
}

var path = NavigationPath()

enum DefaultDestination: Hashable {
    case detail
    case otherDetail(ComplexType)
}

let aComplexObject = ComplexType(...)

path.append(DefaultDestination.otherDetail(aComplexObject))
```