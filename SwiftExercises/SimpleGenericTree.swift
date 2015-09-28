import Cocoa
import Foundation

//======================================================================
// Can't nest enums in a generic type!

//======================================================================

// Note that in the following definition, you should comment out the :Collection
// until you've done Exercise 7, which requires you to extract several methods
// of the tree class into a Collection protocol.

public class SimpleGenericTree<T: Comparable> : Collection  {
    private var root: Node<T>?
    private var size:    Int = 0;
    public var  count:   Int  { return size }

    //----------------------------------------------------------------------
    /// arrayVersion is used by the [] operator. [] is implemented in an
    /// extenstion, but you can declare new fields (stored properties) in
    /// extenstions. If it's nill, no array version exists, otherwise it
    /// points at an array version of the tree. It's set to nill if the
    /// tree is modified (by an add() or remove() call, for example).
    ///
    private var arrayVersion:[T]?

    //----------------------------------------------------------------------
    public var  isEmpty: Bool { return root == nil }

    //----------------------------------------------------------------------
    public func clear() {
        root = nil
        arrayVersion = nil
        size = 0
    }

    //----------------------------------------------------------------------
    /// Initialize from an array. e.g.
    /// 
    /// var t:Tree<String>( ["a", "b", "c"] )
    ///
    public init ( _ elements: [T] )
    {   for element in elements {
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
   
    // Remove an item from the tree, returning nil if it's not there and the
    /// item if it is
    
    public func remove( lookingFor: T ) throws -> T? {
        
        if let (target, parent) = doFind(lookingFor, current:root, parent:nil) {
            
            let orphanedSubtree = target.leftChild
            let targetSide      = target.isOnSideOf(parent)
            
            if( target.rightChild == nil ) {
                replaceChildOf( parent, on: targetSide, with: orphanedSubtree );
            } else {
                target.rightChild!.fillFirstAvailableSlotOn(.Left, with: orphanedSubtree)
                replaceChildOf( parent, on: targetSide, with: target.rightChild );
            }
            arrayVersion = nil; // force a rebild the next time it's needed

            --size
            return target.element
        }
        throw TreeError.Empty
    }

    /// Replace the node on the specified side of the parent with the specified node (can be nil).
    /// If the parent reference is nill, it's assumed to be the root and the root node is
    /// replaced.
    
    private func replaceChildOf( parent: Node<T>?, on: Direction, with: Node<T>?) {
        if( parent == nil ) {  // parent node is the root node
            root = with;
        } else if on == .Left {
            parent!.leftChild = with
        } else {
            parent!.rightChild = with
        }
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
    //----------------------------------------------------------------------
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

    public func traverse( direction: Ordering, visit: (T)->Bool )
    {   switch( direction ) {
        case .Inorder:   traverseIn  ( root, visit )
        case .Preorder:  traversePre ( root, visit )
        case .Postorder: traversePost( root, visit )
        }
    }

    // Need these two to conform to the Collection protocol. Can't do that
    // by defaulting the first argument, unfortunately.

    public func traverse( iterator: (T)->Bool   ) {
        return traverse( .Inorder, visit: iterator )
    }

    public func forEveryElement( iterator: (T)->()   ) {
        return traverse( .Inorder, visit: { iterator($0); return true } )
    }

    public func printAll () {
        forEveryElement{ print( "\($0)" ) }
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
            if !traversePost ( c.leftChild, visit  ){ return false }
            if !traversePost ( c.rightChild, visit ){ return false }
            if !visit        ( c.element           ){ return false }
        }
        return true;
    }
    
    private func traversePre( current: Node<T>?, _ visit: (T)->Bool) -> Bool {
        if let c = current {
            if !visit       ( c.element           ){ return false }
            if !traversePre ( c.leftChild, visit  ){ return false }
            if !traversePre ( c.rightChild, visit ){ return false }
        }
        return true;
    }

    //======================================================================
    // Test methods (internal access)

    func _verifyChildren( parent: T, left: T?, right: T? ) -> Bool {
        guard let (found, _) = doFind(parent, current:root, parent:nil)
        else { return false }

        switch (found.leftChild, found.rightChild ) {
            case (nil,   nil  ) where left==nil         && right==nil          : return true
            case (nil,   let r) where left==nil         && right!==r?.element  : return true
            case (let l, nil  ) where left!==l?.element && right==nil          : return true
            case (let l, let r) where left!==l?.element && right!==r?.element  : return true
            default                                                            : return false
        }
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

    // Stuff to support remove
    //
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
//----------------------------------------------------------------------
extension SimpleGenericTree {
    public func filter( okay: (T)->Bool ) -> Tree<T> {
        let result: Tree<T> = [];
        forEveryElement {
            if(okay($0)) {
                result.add($0)
            }
        }
        return result
    }
    //----------------------------------------------------------------------
    public func map( transform: (T)->T ) -> Tree<T> {
        let result: Tree<T> = [];
        forEveryElement {
            result.add( transform($0) )
        }
        return result
    }
    //----------------------------------------------------------------------
    public func reduce<U>(first: U, combine: (U, T) -> U) -> U {
        var combined = first;
        forEveryElement {
            combined = combine(combined, $0)
        }
        return combined
    }
}