======================================================================
Exercises for Allen Holub's Pluralsight class: Swift In Depth
    http://www.pluralsight.com/courses/swift-in-depth
======================================================================

	Allen Holub
	http://www.holub.com
	allen@holub.com
	@allenholub

	This file and all associated solutions (c)2015, Allen I. Holub.
	All rights reserved.

======================================================================

These are the same exercises that I use when I teach a hands-on version
of my swift class in house. If you'd like me to do that for you, please
contact me at allen@holub.com. The main advantage of having me come
in instead of going the Pluralsight route is that I can answer questions
as you work.

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
Getting the code and running it

My solutions are all available at

    http://github.com/aholub/SwiftInDepth

(I suppose you know that or you wouldn't be reading this file :-)
You can just read them on gitHub if all you want to do is read them.

To install the solutions on your own machine, clone the git repository
to your own hard drive. The following git request puts it in the
SwiftInDepth subdirectory of the current directory on your disk:

    git clone http://github.com/aholub/SwiftInDepth SwiftInDepth

The cloned repository is an XCode project, so after issuing the
above request, you should be able to run it in Xcode from the
command line with:

    cd SwiftInDepth
    open SwiftExercises.xcodeproj

If that doesn't work for some reason, you can import the source-code
files into a new, but empty, XCode project using  
File->Add Files To "MyProject" (or whatever your project is named).

Once you're in XCode, the code for the solutions in the SwiftExercises
group, and all the tests are in the SwiftExercisesTest group.
The groups form separate "targets" (modules). The tests, since
they're in a different target, must use the following import
statement to access the classes they're testing:

@testable import SwiftExercises

(The @testable makes all of the internal-access methods available
to your test code. Without it, you'll only be able to access public
stuff.)

If you want to set up a similar structure for your own tests,
you'll need to tell XCode that the SwiftExercises
group defines a "module." To do that, go into the "Project Navigator"
(View->Navigators->Show Project Navigator) and highlight the project
itself (at the very top of the window with the blue icon to its left)
On the Right, Select "Swift Exercises" under "TARGETS." Scroll down
to the "Packaging" category and set "Defines Module" to "Yes."

======================================================================
Asking Questions:

Please address any questions to the Discussion group associated with
my class:

    http://www.pluralsight.com/courses/discussion/swift-in-depth

That way we can all benefit. If you send me email, I'll most likely just
copy it to the discussion group and post my answer there. (I'll write
back to you when I post the reply). If you can't get at the Discussions
because you're using a pirated version of my class, I have no sympathy
for your plight.

*********************************************************************
EXERCISES:
*********************************************************************

=====================================================================
After Finishing Module 3 
======================================================================

1: Build a simple binary tree that holds String values. 

If you've never worked with a binary tree, they're described in
Robert Horvick's Pluralsight Class: "Algorithms and Data 
Structures---Part 1" (http://www.pluralsight.com/courses/ads-part1).

A simple binary tree is not an ideal data structure (AVL trees are better,
for example), but this is a great exercise for understanding how optionals
work. (The tree root and child pointers in the node have to be options so that
you can use nil to represent no descendants.) Don't complicate things by
implementing an AVL or Red/Black Tree unless you really relish the
challenge. The point, after all, is to learn Swift, not build a Tree class.

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
        -> (found: Node,            // Return an optional tuple that holds the matching
            parent: Node?)?         // node and its parent (or nil if the matching
                                    // node was the root node) Return nil if you didn't
                                    // find the value you were looking for.

    For example, to find the node "x," starting the search at the root node of the tree,
    you'd call:

        doFind("x", current: root, parent: nil)

My solution is in:

    StringTree.swift
	StringTreeTests.swift

----------------------------------------------------------------------
2: (optional. This is hard, so take it as a challenge). Add:

        remove( lookingFor: T ) -> T?

My solution is in:

    StringTreeWithRemove.swift
	StringTreeRemoveTests.swift

----------------------------------------------------------------------
3: First, create an enum that represents a US, Canadian, or UK postal code:

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
After finishing module 4
======================================================================

4: Add:
    _verifyChildren( parent: T, expectedLeft: T?, expectedRight: T? ) -> Bool

to your tree. This mehod verifies that the two children of the node with the given
key (parent) have the expected values. expectedLeft and expectedRight can
both be nil (in the case of a leaf node).

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
(and only four) case statements in it, one for each of the following
situations:

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

Similarly, if exectedLeft is nil and expected Right isn't, a single
case statement should be trigged to handle that situation, and the
same case statement (in its where clause) should verify that the
expectedRight value matches the acctual value of the right child of
the indicated parent.

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

======================================================================
After finishing module 5 (Functions and CLosures)
======================================================================
5:

Add the following methods to your Tree

    t.traverse { print("\($0)"); return true }

    t.forEveryElement{
        print("\($0)")
    }

    public func  filter( okay: (T)->Bool ) -> Tree<T> 
    public func  map( transform: (T)->T ) -> Tree<T> 
    public func  reduce<U>(first: U, combine: (U, T) -> U) -> U

    t.asString ( delim: String = " " )

My Solution:
	StringTreeWithClosures.swift
	StringTreeClosuresTests.swift


======================================================================
After Modules 6 and 7 (Classes)
======================================================================

6. Get rid of the T typealias and make the tree class generic.
That is, create Tree<T> where T must implement the Comparable
Protocol (String implements Comparable). Also add public and private
where appropriate. The class itself should be public.

We haven't covered protocols at this point in the class, but the syntax is

class Tree<T: Comparable> {
}

That will allow the relational operators ( < > == etc ) to work correctly
on node values.

Also, extract the filter() map() and reduce() methods into an extension
rather than defining them in the tree class itself.

MySolution: SimpleGenericTree.swift
			SimpleGenericTreeTests.swift

======================================================================
After Module 9 (Protocols)
======================================================================

7. Extract the key operations (add, remove, traverse, contains, findMatchOf,
forEveryElement, and the count computed property) into a Collection protocol
and modify your generic tree implementation to implement that protocol.

My Solution:
	Collection.swift (and comment in the :Collection in SimpleGenericTree.swift)

8. Extend the Collection protocol to add the method median(), which finds
the "median" element (e.g. if you turned the tree into an array with
indexes 0 to i, the median element would be at tree[i/2]. That's not
the same thing as the root element. Do not turn to tree into an array
to solve this problem, however.) Return nil if the tree is empty.

My Solution:
	Median.swift
	MedianTests.swift

----------------------------------------------------------------------

9. Implement an UndoableTree class into which you can insert any Comparable
object. This class should adopt Collection, and should also adopt the
Undoable protocol, which has the members undo() and redo().

Calling undo() should reverse the last modification (add or remove).
Subsequently calling redo() should reverse the most recent undo().
It must be possible to call undo() multiple times and then reverse
the set of undo operations by calling redo() as many times as you called
undo().

Implemented this mechanism using a stack of tuples that contain two closures.
One of these closures implements a "do" operation and the other
implements an "undo" operation.
To undo, pop a tuple off the stack, execute its "undo" closure,
and then push the tuple onto a redo stack. To redo, pop a tuple off the
redo stack, execute it's "redo" closure, and then push the tuple
onto the undo stack.

(As an aside, this is a classic example of the Gang Of Four "Command"
design pattern, but with the Command object defined with a tuple rather
than a class)

My Solution:
	UndoableTree.swift
	UndoableTreeTests.swift

======================================================================
After finishing module 10 (Customizing Swift)
======================================================================

10. One problem with the tree is that, if you change the value of the
"key" after you've inserted an item into a tree, then the entire
tree structure becomes invalid. Solve that problem by introducing a Lockable
protocol with two members, lock() and unlock(). Then implement a
SafeTree subclass of our generic tree whose members must adopt
both Comparable (as is the case with our original tree) and Lockable.
The add() method locks the inserted item, and the remove() method unlocks it.
Any attempt to modify a locked item should result in a exception toss.
(You may not recycle any of the standard exception types for this purpose---make
up one of your own).

Test your Safe Tree using a class of your own creation that implements
both Lockable and Comparable.

My Solution:
	SafeTree.swift
	SafeTreeTests.swift
	
----------------------------------------------------------------------
11. Modify your tree so that it supports the following operations. (Use
   the Extension mechanism when possible)

    let t: Tree<String> = [ "a", "b", "c" ]
    
    t += "d"
    t -= "a"
    if( t <> "a" ) {...}    // if t contains "a"
    if( t !<> "a" ) {...}   // if t doesn't contain "a"

    let x = t[1]        (read only. t[1] = "x" shouldn't work)

	for element in t {
		print("\(t)" )
	}

My Solution

Tree.swift
TreeTests.swift
