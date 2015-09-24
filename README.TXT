======================================================================
Exercises for Allen Holub's Pluralsight class: Swift In Depth
    http://www.pluralsight.com/courses/swift-in-depth
======================================================================

Allen Holub
http://www.holub.com
allen@holub.com
@allenholub

======================================================================
Preliminaries:

If you haven't yet, download XCode 7 from the App Store. It's no
longer in Beta, and most (but not all, unfortunately) of the bugs
I was running up against in my video have been fixed. The testing
frameworks work well in the release version. All of my solutions
to the following problems are written in Swift-2, so they won't
compile with earlier versions of XCode. I recommend that you build
your solutions as XCode projects rather than using the Playground.

You should also build test classes for these assignments and use your
tests to verify that everything works. If you haven't done that before,
Apple describes the testing system at: http://apple.co/1Mr3XFE .
My solutions all come with tests that use the XCT framework.

======================================================================
Getting the code

To install the solutions, clone the git repository to your own hard drive.
The following git request puts it in the SwiftInDepth subdirectory of the
current directory:

    git clone http://github.com/aholub/SwiftInDepth SwiftInDepth

The cloned repository is an XCode project, so after issuing the
above request, you should be able to run it in Xcode from the
command line with:

    cd SwiftInDepth
    open SwiftExercises.xcodeproj

If that doesn't work for some reason, all of the source code files
are just source-code files, so you can import them into a new, but
empty XCode project using  File->Add Files To "MyProject" (or whatever
your project is).

======================================================================
Asking Questions:

Please address any questions to the Discussion group associated with
my class:

    http://www.pluralsight.com/courses/discussion/swift-in-depth

That way we can all benefit. If you send me email, I'll most likely just
copy it to the discussion group and post my answer there. (I'll write
back to you when I post the reply). If you're using a pirated version
of my class to learn Swift, so can't get at the Discussions,
I have no sympathy for your plight. Sorry.

======================================================================
After Module 3 
======================================================================
1: Build a simple binary tree that holds String values. 

Binary trees are described in Robert Horvick's Pluralsight Class: "Algorithms
and Data Structures---Part 1" (http://www.pluralsight.com/courses/ads-part1).
A simple binary tree is not an ideal data structure (AVL trees are better,
for example), but this is a great exercise for understanding how optionals
work. (The tree root and child pointers in the node have to be options so that
you can use nil to represent no descendants.) Don't complicate things by
implementing an AVL or Red/Black Tree unless you really relish the challenge.
The point, after all, is to learn Swift, not build a Tree class.

Use the following typealias for the stored-element type. Don't hard code
String into your implementation:

class StringTree {
    typealias T = String   
    //...
}

Both of the following statements should create trees:

    var t1 = StringTree()
    var t2 = StringTree( ["a", "b", "c"] )

You should support the following methods and computed properties:

    isEmpty             (read-only property)
    count               (read-only property. Number of elements in the tree)
    clear()             (remove all elements)
    smallest() -> T?    (return the smallest element, nil if the tree is empty)
    largest()  -> T?    (return the largest element, nil if the tree is empty)

    add(element:T)                      (add the specified string to the tree)

    findMatchOf(lookingFor:T ) -> T?    (return the contained string that matches
                                         the lookingFor argument. Use == for
                                         comparison)

    contains( lookingFor: T) -> Bool    (return true if the tree contains an
                                         element that matches lookingFor. Use == for
                                         comparison)

    The last two methods should call the following "workhorse" method to do the
    actual searching (I'm assuming that this method is recursive). This method
    will be handy should you implement remove, and is a good exercise in optionals
    even if you don't:

    func doFind( lookingFor: T,     // the value you're looking for
                 current: Node?,    // with the search starting here
                 parent: Node? )    // and this is the parent of the "current" node.
                                    // (nil if "current" is the root node)
        -> (found: Node,            // Return an optional tuple that holds the matching node
            parent: Node?)?         // and its parent (or nil if the matching node was
                                    // the root node) Return nil if you didn't find
                                    // the value you were looking for.

    For example, to find the node "x," starting the search at the root node of the tree,
    you'd call:

        doFind("x", current: root, parent: nil)

My solution is in:
    StringTree.swift StringTreeTests.swift

----------------------------------------------------------------------
2 (optional. This is hard, so take it as a challenge). Add:
----------------------------------------------------------------------

        remove( lookingFor: T ) -> T?

My solution is in:
    StringTreeWithRemove.swift StringTreeRemoveTests.swift


----------------------------------------------------------------------
3: Enums
----------------------------------------------------------------------

First, create an enum that represents a US, Canadian, or UK postal code:

        let usCode = PostalCode.US(12345,6789)
        let caCode = PostalCode.CA("A0A 0A0" )
        let ukCode = PostalCode.UK("SW1A 1AA")

Implement these with an asString() method that returns a string
representation of the code. For example, given the earlier definitions,
usCode.asString() evaluates to "12345-6789"

Next, Create a second enum that represents countries. These must
use string raw values that work as follows:

        Country.USA.rawValue == "United States"
        Country.UK.rawValue  == "United Kingdom" 
        Country.CA.rawValue  == "Canada"

The Country should be able to produce a postal code as follows:

    Country.USA.getPostalCode(12345,6789)
    Country.CA.getPostalCode("A0A 0A0")
    Country.UK.getPostalCode("SW1A 1AA")

These methods either return an appropriate PostalCode object, or
they return nil if the arguments to the methods do not form
a legitimate postal code for the specified country.

In particular, if A is a letter and d is a digit:

Canadian postal codes take the form
    AdA dAd

UK postal codes take one of these forms:
    AA0A dAA
    AdA dAA
    Ad dAA
    Add dAA
    AAd dAA
    AAdd dAA

US postal codes are two numbers. The first must be in the
range 0-99999; the second in the range 0-9999

My solution is in:
    PostalCode.swift PostalCodeTests.swift


======================================================================
After Module 4
======================================================================

Add:
    _verifyChildren( parent: T, expectedLeft: T?, expectedRight: T? ) -> Bool

that verifies that the two children of the node with the given key (parent) have
the expected values. expectedLeft and expectedRight can both be nil (in the
case of a leaf node).

For example, given a balanced tree created by inserting the nodes "b" "a"
and "c" in that order, the following should all evaluate true:

_verifyChildren( "b", "a", "c", )
_verifyChildren( "a", nil, nil )
_verifyChildren( "c", nil, nil )

if you then add the node "d" to the tree, the following will hold

_verifyChildren( "b", "a", "c", )
_verifyChildren( "a", nil, nil )
_verifyChildren( "c", nil, "d" )
_verifyChildren( "d", nil, nil )

You must do all checking for these conditions with a switch with four
case statements in it, one for each of the following situations:

left        right
nil         nil
not Nil     nil
nil         not Nil
not Nil     not Nil

That same case should compare values when necessary using a "where" clause.

In other words, a single case statement is triggered when both 
expectedRight and expectedLeft are nil, and that same case statement
should verify (with a where clause) that both children of the specified parent
are also nil.

Simliarly, if exectedLeft is Nil and expected Right isn't, a single
case statement should be trigged to handle that situation, and the
same case statement should verify that the expectedRight value matches
the value of the right child of the indicated parent.

Modify your tests to verify that a tree to which you add the following
values in the indicated order is structured correctly:

"d" "b" "f" "a" "c" "e" "g"

----------------------------------------------------------------------

If you didn't implement remove, copy my implementation into your code.

Modify remove() to throw an exception if you try to remove an item
from an empty tree or if you try to remove an item not in the tree.

----------------------------------------------------------------------

My solution to both of the above is in:

    StringTreeWithVerify.swift
    VeryifyAndTreeEmptyTests.swift


**********************************************************************
THE REMAINDER OF THIS FILE IS A WORK IN PROGRESS. PLEASE IGNORE IT!
**********************************************************************


======================================================================
After Moudle 5 (Functions and CLosures)
======================================================================
3:  (Closures)

Add the following methods to your Tree

    t.traverse { print("\($0)"); return true }

    t.forEveryElement{
        print("\($0)")
    }

    public func  filter( okay: (T)->Bool ) -> Tree<T> 
    public func  map( transform: (T)->T ) -> Tree<T> 
    public func  reduce<U>(first: U, combine: (U, T) -> U) -> U

    t.asString ( delim: String = " " )

======================================================================
After Modules 6 and 7 (Classes)
======================================================================

4. Get rid of the T typealais and make the tree class generic.
That is, create Tree<T> where T must implement the Comparable
Protocol (String implements Comparable).

We haven't covered protocols at this point in the class, but the syntax is

class Tree<T: Comparable> {
}

That will allow the relational operators ( < > == etc ) to work correctly
on node values.


======================================================================
After Module 9 (Protocols)
======================================================================
5.  Extend Tree with a SafeTree sublcass. Objects on the safe tree must implement
both Comparable and Lockable. The objects should be locked when
added to the tree and unlocked when removed. Attempts to modify
locked objects should result in an exception toss.

    public protocol Lockable {
    func lock   ()->()
    func unlock ()->()

public enum LockedObjectException : ErrorType {
    case ObjectLocked
}

public class SafeTree<T where T:Lockable, T:Comparable > : Tree<T>

----------------------------------------------------------------------
5.  Extract key operations (add remove traverse findMatchOf contains
forEveryElement into a Collection protocol that Tree<T> must implment.

Implement an UndoableTree<T: Comparable> :Collection, Undoable
Undo should be implmented as a stack of tupples, one element of which
references a "do" operation and the other implements an "undo" operation.
To undo, pop a tupple off the stack, execute its "undo", and push it onto a
redo stack.
To reco, pop a tuple off the redo stack, execute it's "redo" operation, and
push it onto the undo stack.

public class UndoableTree<T: Comparable> : Collection, Undoable 

======================================================================
After Module 10 (Customizing Swift)
======================================================================
6. Operator overloads (add using the Extension mechanism )

    let t: Tree<String> = [ "a", "b", "c" ]
    
    t += "d"
    t -= "a"
    if( t <> "a" ) {...}   // t contains "a"

    let x = t[1]        (read only. t[1] = "x" shouldn't owrk)

