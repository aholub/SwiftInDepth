import Foundation

//======================================================================
/// The safe tree adds the ability to lock a node when it's inserted in
/// the tree and unlock it when it's removed. A locked node, once locked,
/// must not change state in such a way that the Comparable methodds
/// return different values.
//======================================================================

/// It's dangerous to put an item in the tree if the key values used by
/// the Comparable methods can change their behavior when the item is
/// is modified. In other words, if you put an item with a specific
/// key value into the tree, changing the key without first removing
/// it from the tree is a serious bug. Solve that problem with a tree
/// make up of "Lockable" objects. Lockable objects, once locked, cannot
/// be modified in such a way that the behvior of the Comparable methods would
/// change if the item is manipulated in some way.
///
/// THIS CLASS IS SUSEPTABLE TO FRAGILE-BASE-CLASS bugs. It's essential that
/// all Tree<T> methods that can modify the tree have overrides in the
/// current class. Be careful. See the UndoableTree for a way around this
/// problem.

public protocol Lockable {
    func lock   ()->()
    func unlock ()->()
}

public enum LockedObjectException : ErrorType {
    case ObjectLocked
}

public class SafeTree<T where T:Lockable, T:Comparable > : Tree<T>
{
    public required init( arrayLiteral elements: T...) {
        super.init(elements)
    }
    
    public override init( _ array: [T] ) {
        super.init(array)
    }
    
    public override func add( element: T        ) -> Bool {
        element.lock()
        return super.add(element)
    }
    
    public override func remove( lookingFor: T  ) throws -> T? {
        let found = try! super.remove(lookingFor)
        if found != nil {
            found?.unlock()
        }
        return found
    }
}
