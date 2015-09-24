import Cocoa
import Foundation

class StringTree
{
    typealias T = String

    private var root:   Node?
    private var size:   Int = 0;
    var  count:  Int  { return size }


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

    init (){} // nothing to do, but it's shadowed by init([T])
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

    //======================================================================

    class Node {
        var rightChild: Node?
        var leftChild:  Node?

        let element: StringTree.T
        init( _ element: StringTree.T ) {
            self.element = element
        }
    }
}