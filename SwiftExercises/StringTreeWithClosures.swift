//  StringTreeWithClosures.swift
//  Copyright © 2015 Allen Holub. All rights reserved.
//  StringTreeWithVerify.swift
//  Copyright © 2015 Allen Holub. All rights reserved.

import Foundation

class StringTreeWithClosures
{
    typealias T = String

    private var root:   Node?
    private var size:   Int = 0;
    var  count:  Int  { return size }

    //----------------------------------------------------------------------
    enum Error : ErrorType { case Empty }    // used by remove()

    //----------------------------------------------------------------------
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

    //----------------------------------------------------------------------
    var  isEmpty: Bool { return root == nil; }
    //----------------------------------------------------------------------
    func clear() {
        root = nil
        size = 0
    }
    //----------------------------------------------------------------------
    // Initialize from an array. e.g.
    // var t = StringTree( ["a", "b", "c"] )
    //
    init ( _ elements: [T] )
    {   for element in elements {
            add(element)
        }
    }

    init (){} // nothing to do, but it's shadowed by [T] version
    //----------------------------------------------------------------------
    /// Add a new element. Return false (and do nothing) if the element
    /// is already there
    ///
    func add( element: T ) -> Bool {
        if root == nil {
            root = Node(element)
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
        return true
    }

    /// Remove an item from the tree, returning nil if it's not there and the
    /// item if it is
    
    func remove( lookingFor: T ) throws -> T? {
        
        if let (target, parent) = doFind(lookingFor, current:root, parent:nil) {
            
            let orphanedSubtree = target.leftChild
            let targetSide      = target.isOnSideOf(parent)
            
            if( target.rightChild == nil ) {
                replaceChildOf( parent, on: targetSide, with: orphanedSubtree );
            } else {
                target.rightChild!.fillFirstAvailableSlotOn(.Left, with: orphanedSubtree)
                replaceChildOf( parent, on: targetSide, with: target.rightChild );
            }
            --size
            return target.element
        }

        throw Error.Empty
    }

    /// Replace the node on the specified side of the parent with the specified node (can be nil).
    /// If the parent reference is nill, it's assumed to be the root and the root node is
    /// replaced.
    
    private func replaceChildOf( parent: Node?, on: Direction, with: Node?) {
        if( parent == nil ) {  // parent node is the root node
            root = with;
        } else if on == .Left {
            parent!.leftChild = with
        } else {
            parent!.rightChild = with
        }
    }
    //----------------------------------------------------------------------
    func smallest() -> T? {
        var current = root
        while  current?.leftChild != nil {
            current = current?.leftChild
        }
        return current?.element
    }
    //----------------------------------------------------------------------
    func largest() -> T? {
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
    
    func findMatchOf( lookingFor: T ) -> T? {
        if let (found, _) = doFind(lookingFor, current:root, parent:nil) {
            return found.element
        }
        return nil
    }
    
    func contains( lookingFor: T ) -> Bool {
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
    func doFind( lookingFor: T, current: Node?, parent: Node? ) -> (found: Node, parent: Node?)?
    {
        if let c = current {
            return  lookingFor > c.element ? doFind(lookingFor, current: c.rightChild, parent: current):
                    lookingFor < c.element ? doFind(lookingFor, current: c.leftChild,  parent: current):
                    /* == */                 (c, parent)
        }
        return nil
    }
    //----------------------------------------------------------------------

    func traverse( direction: Ordering, visit: (T)->Bool )
    {   switch( direction ) {
        case .Inorder:   traverseIn  ( root, visit )
        case .Preorder:  traversePre ( root, visit )
        case .Postorder: traversePost( root, visit )
        }
    }

    // Need these two to conform to the Collection protocol. Can't do that
    // by defaulting the first argument, unfortunately.

    func traverse( iterator: (T)->Bool   ) {
        return traverse( .Inorder, visit: iterator )
    }

    func forEveryElement( iterator: (T)->()   ) {
        return traverse( .Inorder, visit: { iterator($0); return true } )
    }

    func printAll () {
        forEveryElement{ print( "\($0)" ) }
    }
    
    private func traverseIn(current: Node?, _ visit: (T)->Bool) -> Bool {
        if let c = current {
            if !traverseIn ( c.leftChild, visit  ){ return false }
            if !visit      ( c.element           ){ return false }
            if !traverseIn ( c.rightChild, visit ){ return false }
        }
        return true;
    }
    
    private func traversePost( current: Node?, _ visit: (T)->Bool) -> Bool {
        if let c = current {
            if !traversePost ( c.leftChild, visit  ){ return false }
            if !traversePost ( c.rightChild, visit ){ return false }
            if !visit        ( c.element           ){ return false }
        }
        return true;
    }
    
    private func traversePre( current: Node?, _ visit: (T)->Bool) -> Bool {
        if let c = current {
            if !visit       ( c.element           ){ return false }
            if !traversePre ( c.leftChild, visit  ){ return false }
            if !traversePre ( c.rightChild, visit ){ return false }
        }
        return true;
    }
    //----------------------------------------------------------------------
    func filter( okay: (T)->Bool ) -> Tree<T> {
        let result: Tree<T> = [];
        forEveryElement {
            if(okay($0)) {
                result.add($0)
            }
        }
        return result
    }
    //----------------------------------------------------------------------
    func map( transform: (T)->T ) -> Tree<T> {
        let result: Tree<T> = [];
        forEveryElement {
            result.add( transform($0) )
        }
        return result
    }
    //----------------------------------------------------------------------
    func reduce<U>(first: U, combine: (U, T) -> U) -> U {
        var combined = first;
        forEveryElement {
            combined = combine(combined, $0)
        }
        return combined
    }
    //----------------------------------------------------------------------
    /// Convert to a String using the indicated delimiter between elements.
    func asString ( delim: String = " " ) -> String {
        return reduce("", combine:{ return $0.characters.count == 0 ? "\($1)" : "\($0)\(delim)\($1)"})
    }

    //======================================================================

    class Node {
        var rightChild: Node?
        var leftChild:  Node?
        
        let element: StringTreeWithClosures.T
        init( _ element: StringTreeWithClosures.T ) {
            self.element = element
        }

        // Stuff to support remove
        //
        /// Returns the side of the parent node that that the current node is on.
        /// Returns .Left if this is the root node.
        ///
        func isOnSideOf (parent: Node?) -> Direction {
            return parent != nil && parent?.rightChild === self ? .Right : .Left
        }

        /// Finds the first available (nil) slot in the indicated direction, then inserts
        /// "insertsThis" into that slot. For example, if isThisDirection is .Left, it starts
        /// traversing at the current node, following links specified in the leftChild
        /// reference until it finds a nil leftChild. Then it inserts the insertNode
        /// in place of the nil.

        private func fillFirstAvailableSlotOn(inThisDirection: Direction, with insertThis: Node?) {
            switch (inThisDirection) {
            case (.Left ) where leftChild  == nil : leftChild  = insertThis
            case (.Right) where rightChild == nil : rightChild = insertThis
                
            case (.Left ): leftChild! .fillFirstAvailableSlotOn( .Left,  with: insertThis )
            case (.Right): rightChild!.fillFirstAvailableSlotOn( .Right, with: insertThis )
            }
        }
    }
}