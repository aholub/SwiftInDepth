======================================================================
After Module 3 
======================================================================
1: Build a binary tree that holds String values. Use this typealias for
   the stored-element type. Don't hard code String into your
   implementation

		typealias T = String   

	Both of the following statements should create trees:

		var t1 = StringTree()
		var t2 = StringTree( ["a", "b", "c"] )

	You should support the following methods and computed properties:

		isEmpty 			(read-only property)
		count 				(read-only property. Number of elements in the tree)
		clear()				(remove all elements)
		smallest() -> T?	(return the smallest element, nil if the tree is empty)
		largest()  -> T?	(return the largest element, nil if the tree is empty)

		add(element:T)						    (add the specified string to the tree)

		findMatchOf(lookingFor:T ) -> T?		(return the contained string that matches
											     the lookingFor argument. Use == for
												 comparison)

		contains( lookingFor: T) -> Bool		(return true if the tree contains an
											     element that matches lookingFor. Use == for
												 comparison)

		The last to methods should call the following "workhorse" method to do the
		actual searching (I'm assuming that this method is recursive):

		func doFind( lookingFor: T,		// the value you're looking for
					 current: Node?,	// with the search starting here
					 parent: Node? )	// and this is the parent of the "current" node.
					 					// (nil if "current" is the root node)
					    -> (found: Node, parent: Node?)?
										// Return a tuple that holds the matching node
										// and its parent (or nil if the match was in
										// the root node) Return nil if you didn't find
										// the value you were looking for.

		For example, to find the node "x," starting the search at the root node of the tree,
		you'd call:

			doFind("x", current: root, parent: nil)

	My solution is in:
		StringTree.swift StringTreeTests.swift

2 (optional. This is hard, so take it as a challenge). Add:

		remove( lookingFor: T ) -> T?

	My solution is in:
		StringTreeWithRemove.swift StringTreeRemoveTests.swift


3:
	Postal Code Enum

======================================================================
After Module 4
======================================================================

Add:
	_verifyChildren( parent: T, expectedLeft: T?, expectedRight: T? ) -> Bool

that verifies that the two children of the node with the given key (parent) have
the expected values. expectedLeft and expectedRight can both be nil.

For example, given a balanced tree created by inserting the nodes "b" "a"
and "c" in that order, the following should all evaluate true:

_verifyChildren( "b", "a", "c", )
_verifyChildren( "a", nil, nil )
_verifyChildren( "c", nil, nil )

if you then add the node "d" to the tree, the following will hold

_verifyChildren( "b", "a", "c", )
_verifyChildren( "a", nil, nil )
_verifyChildren( "c", nil, "d" )
_verifyChildren( "d", nil, "d" )

You can do all checking for these conditions with
a switch with four case statements in it, one for each of the following
situations:

left  		right
nil			nil
not Nil		nil
nil			not Nil
not Nil		not Nil

and that same case statment can compare values when necessary.

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

Modify remove to throw an Exception if you try to remove an item
from an empty tree.


======================================================================
After Moudle 5 (Functions and CLosures)
======================================================================
3:	(Closures)

	t.asString ( delim: String = " " )
	t.traverse { print("\($0)"); return true }

	t.forEveryElement{
		print("\($0)")
	}

	public func  filter( okay: (T)->Bool ) -> Tree<T> 
	public func  map( transform: (T)->T ) -> Tree<T> 
	public func  reduce<U>(first: U, combine: (U, T) -> U) -> U

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

	let x = t[1]		(read only. t[1] = "x" shouldn't owrk)

