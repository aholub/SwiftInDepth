import Cocoa
import Foundation

/*
 *  This version adds deletion, filter/map/reduce, and generally
 *  cleans up the code
 */

/// Note that both add and findMatchOf are risky because they add (and give access to) the
/// object that's used as the "key," which could be a reference objecgt. If you modify
/// that object, you'll break the tree. It would be better to use (and return) a copy.
/// Since swift classes do not extend a universal base class (e.g. Object), there's no
/// way to programmatically determine if something is a value type or a reference type
/// in a generic. You can say "someObject is AnyClass" but that evaluates true for
/// structs as well. Since there's no exception mechanism, you can't try to modify it
/// and catch the error at runtime, either. In order to make findMatchOf optional,
/// it has to go into an @objc base protocol, but it can't be generic in that case
/// (no typealiases are allowed, so the argument and return have to be AnyObject),
//  so you'll loose type safety.

public protocol Collection {
    typealias T
    
    /// Add an element to the tree. If it's a reference object, it's dangerous to keep
    /// the element around after it's been added. If T adopts Lockable, then the
    /// item is locked when it's added and unlocked when it's removed.
    
    func add( element: T        ) -> Bool
    func remove( lookingFor: T  ) -> T?
    
    /// Find a matching element (using Comparable overrides) and return it.
    /// Since this method makes it possible for someone to destroy the
    /// tree's internal structure by modifying the node, this is a dangerous
    /// method to provide. However, it's also ridiculous to require someone
    /// to remove an element from the tree to examine it. Contains() is
    /// safer. You don't have to worry about any of this if the element
    /// is Lockable.
    
    func findMatchOf( lookingFor: T         ) -> T?
    
    func contains   ( lookingFor: T         ) -> Bool
    func traverse   ( iterator: (T)->Bool   )
}

public class Tree<T: Comparable>: ArrayLiteralConvertible, Collection
{
    private var root: Node<T>?
    private var arrayVersion:[T]?
    
    private var size:    Int = 0;
    public var  count:   Int  { return size }

    public var  isEmpty: Bool { return root == nil; }
    
    //----------------------------------------------------------------------
    /// ArrayLiteralCovertible support. Initilize from and array literal. e.g.
    ///
    ///  var t:Tree<Int> = [0,1,2]
    ///
    public required init( arrayLiteral elements: T...) {
        for element in elements {
            add(element)
        }
    }
    
    //----------------------------------------------------------------------
    /// Initialize from an array. e.g.
    /// 
    /// var t:Tree<String>( ["a", "b", "c"] )
    ///
    public init ( array: [T] )
    {   for element in array {
            add(element)
        }
    }

    //----------------------------------------------------------------------
    /// Convert to a String using the indicated delimiter between elements.
    public func asString ( delim: String = " " ) -> String {
        return reduce("", combine:{ return $0.characters.count == 0 ? "\($1)" : "\($0)\(delim)\($1)"})
    }
    
    //----------------------------------------------------------------------
    /// Add a new element. Return false (and do nothing) if the element
    /// is already there
    ///
    public func add( element: T ) -> Bool {
        if root == nil {
            root = Node<T>(element)
        }
        else {
            var current = root!;
            for ;;
            {
                if element > current.element { // go right
                    if current.rightChild == nil {
                        current.rightChild = Node(element)
                        break;
                    }
                    else {
                        current = current.rightChild!
                    }
                }
                else if element < current.element { // go left
                    if current.leftChild == nil {
                        current.leftChild = Node(element)
                        break;
                    }
                    else {
                        current = current.leftChild!
                    }
                }
                else {  // it's equal. Refuse to add a conflicting node
                    return false;
                }
            }
        }
        ++size
        arrayVersion = nil; // force a rebild the next time it's needed
        return true
    }
    
    /// Remove an item from the tree, returning nil if it's not there and the
    /// item if it is
    
    public func remove( lookingFor: T ) -> T? {
        
        if let (target, parent) = doFind(lookingFor, current:root, parent:nil) {
            
            let orphanedSubtree = target.leftChild
            let targetSide      = target.isOnSideOf(parent)
            
            if( target.rightChild == nil ) {
                replaceChildNodeChildOf( parent, on: targetSide, with: orphanedSubtree );
            } else {
                target.rightChild!.fillFirstAvailableSlotOn(.Left, with: orphanedSubtree)
                replaceChildNodeChildOf( parent, on: targetSide, with: target.rightChild );
            }
            arrayVersion = nil; // force a rebild the next time it's needed
            return target.element
        }
        return nil;
    }

    /// Return the element that matches (==) lookingFor or nil if you can't find it.
    /// Returns a tuple holding optional references to both the
    /// found node and its parent (see doFind()).
    
    public func findMatchOf( lookingFor: T ) -> T? {
        if let (found, _) = doFind(lookingFor, current:root, parent:nil) {
            return found.element
        }
        return nil
    }
    
    public func contains( lookingFor: T ) -> Bool {
        return findMatchOf( lookingFor ) != nil
    }
    
    /// The workhorse method used by both findMatchOf and remove.
    /// When you find something, all you need is the node you're looking for, but when you're
    /// removing, you'll need both that node and its parent. Consequently, this method returns
    /// an optional tuple that's nil if you can't find what you're looking for. The tuple holds
    /// a reference to the current node and also a reference to an optional parent node. The latter
    /// is nil when found item is the root node.
    ///
    private func doFind( lookingFor: T, current: Node<T>?, parent: Node<T>? )->
                                                    (found: Node<T>, parent: Node<T>?)?
    {
        if let c = current {
            return  lookingFor > c.element ? doFind(lookingFor, current: c.rightChild, parent: current):
                    lookingFor < c.element ? doFind(lookingFor, current: c.leftChild,  parent: current):
                    /* == */                 (c, parent)
        }
        return nil
    }
    //----------------------------------------------------------------------
    public func smallest() -> T? {
        var current = root
        while  current?.leftChild != nil {
            current = current?.leftChild
        }
        return current?.element
    }
    //----------------------------------------------------------------------
    public func largest() -> T? {
        var current = root
        while  current?.rightChild != nil {
            current = current?.rightChild
        }
        return current?.element
    }
    //----------------------------------------------------------------------

    public func traverse( direction: Ordering, visit: (T)->Bool )
    {   switch( direction ) {
        case .Inorder:   traverseIn  ( root, visit )
        case .Preorder:  traversePre ( root, visit )
        case .Postorder: traversePost( root, visit )
        }
    }

    // Need this one to conform to Collection protocol. Can't do the same thing
    // with a default first argument, unfortunately.
    //
    public func traverse( iterator: (T)->Bool   ) {
        return traverse( .Inorder, visit: iterator )
    }

    public func printAll () {
        traverse {
            print( "\($0)" )
            return true
        }
    }
    
    private func traverseIn(current: Node<T>?, _ visit: (T)->Bool) -> Bool {
        if let c = current {
            if !traverseIn ( c.leftChild, visit  ){ return false }
            if !visit      ( c.element           ){ return false }
            if !traverseIn ( c.rightChild, visit ){ return false }
        }
        return true;
    }
    
    private func traversePost( current: Node<T>?, _ visit: (T)->Bool) -> Bool {
        if let c = current {
            if !traverseIn ( c.leftChild, visit  ){ return false }
            if !traverseIn ( c.rightChild, visit ){ return false }
            if !visit      ( c.element           ){ return false }
        }
        return true;
    }
    
    private func traversePre( current: Node<T>?, _ visit: (T)->Bool) -> Bool {
        if let c = current {
            if !visit      ( c.element           ){ return false }
            if !traverseIn ( c.leftChild, visit  ){ return false }
            if !traverseIn ( c.rightChild, visit ){ return false }
        }
        return true;
    }
}

//======================================================================
// A Node can't be a struct because we can't have references to
// value objects.
//
// We can't nest the definition inside of Tree, where it belongs, because
// of a COMPILER BUG. (Causes a hard crash.)
//

private class Node<T> {
    var rightChild: Node?
    var leftChild:  Node?
    
    let element: T
    init( _ element: T ) {
        self.element = element
    }
}

// Stuff to support remove
//
extension Node {

    /// Returns the side of the parent node that that the current node is on.
    /// Returns .Left if this is the root node.
    ///
    func isOnSideOf (parent: Node<T>?) -> Direction {
        return parent != nil && parent?.rightChild === self ? .Right : .Left
    }

    /// Finds the first available (nil) slot in the indicated direction, then inserts
    /// "insertsThis" into that slot. For example, if isThisDirection is .Left, it starts
    /// traversing at the current node, following links specified in the leftChild
    /// reference until it finds a nil leftChild. Then it inserts the insertNode
    /// in place of the nil.

    private func fillFirstAvailableSlotOn(inThisDirection: Direction, with insertThis: Node<T>?) {
        switch (inThisDirection) {
        case (.Left ) where leftChild  == nil : leftChild  = insertThis
        case (.Right) where rightChild == nil : rightChild = insertThis
            
        case (.Left ): leftChild! .fillFirstAvailableSlotOn( .Left,  with: insertThis )
        case (.Right): rightChild!.fillFirstAvailableSlotOn( .Right, with: insertThis )
        }
    }
}

extension Tree {
    
    /// Replace the node on the specified side of the parent with the specified node (can be nil).
    /// If the parent reference is nill, it's assumed to be the root and the root node is
    /// replaced.
    
    private func replaceChildNodeChildOf( parent: Node<T>?, on: Direction, with: Node<T>?) {
        if( parent == nil ) {  // parent node is the root node
            root = with;
        } else if on == .Left {
            parent!.leftChild = with
        } else {
            parent!.rightChild = with
        }
    }
}

//======================================================================
func += <T>( left: Tree<T>, right: T ) {
    left.add(right)
}
//----------------------------------------------------------------------
extension Tree {
    public func filter( okay: (T)->Bool ) -> Tree<T> {
        let result: Tree<T> = [];
        traverse( .Inorder ){
            if(okay($0)) {
                result.add($0)
            }
            return true
        }
        return result
    }
    
    //----------------------------------------------------------------------
    public func map( transform: (T)->T ) -> Tree<T> {
        let result: Tree<T> = [];
        traverse( .Inorder ){
            result.add( transform($0) )
            return true
        }
        return result
    }
    
    //----------------------------------------------------------------------
    public func reduce<U>(first: U, combine: (U, T) -> U) -> U {
        var combined = first;
        traverse( .Inorder ){
            combined = combine(combined, $0)
            return true;
        }
        return combined
    }
}
//======================================================================
extension Tree: SequenceType {

    subscript (index:Int)->T {      // read-only access, so explicit get{...} not
        return asArray()[index]     // required
    }

    public func asArray() -> [T] {
        if let array = arrayVersion {
            return array
        }
        else {
            arrayVersion = []
            traverse( .Inorder ){ self.arrayVersion!.append($0); return true }
        }
        return arrayVersion!
    }

    public func generate() -> TreeGenerator<T> {
        return TreeGenerator<T>( items: asArray() )
    }
}

//----------------------------------------------------------------------
public class TreeGenerator<T>: GeneratorType {
    var current = 0;
    let items:[T]
    init( items:[T] ){ self.items = items }
    public func next() -> T? {
        if current >= items.count { return nil }
        return items[current++]
    }
}
//======================================================================
public enum Ordering { case Inorder, Postorder, Preorder }
public enum Direction{ case Left, Right }

//======================================================================
/// The safe tree adds the ability to lock a node when it's inserted in
/// the tree and unlock it when it's removed. A locked node, once locked,
/// must not change state in such a way that the Comparable methodds
/// return different values.
//======================================================================

/// It's dangerous to put an item in the tree if the key values used by
/// the Comparable methods can change their behavior if when the item is
/// is modified. Lockable objects, once locked, cannot be modified
/// in such a way that the behvior of the Comparable methods would
/// change if the item is manipulated in some way.

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
        super.init(array: elements)
    }
    
    public override init( array: [T] ) {
        super.init(array:array)
    }
    
    public override func add( element: T        ) -> Bool {
        element.lock()
        return super.add(element)
    }
    
    public override func remove( lookingFor: T  ) -> T? {
        let found = super.remove(lookingFor)
        if found != nil {
            found?.unlock()
        }
        return found
    }
}
