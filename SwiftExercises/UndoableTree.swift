//  UndoableTree.swift
//  Copyright © 2015 Allen Holub. All rights reserved.

import Foundation

//----------------------------------------------------------------------
public protocol Undoable {
    func undo() -> Bool
    func redo() -> Bool
}
///----------------------------------------------------------------------
/// A tree that has undo and redo operations. Note that extending
/// Tree would be dangerous. This is a classic fragile-base-class
/// problem. The current class must provide versions of add() and
/// remove(), and those methods chain to the associated Tree methods,
/// but they also do a bit more undo-related work. If we had subclassed
/// Tree, and then at some future date added another variant of add()
/// to the Tree class, we would probably not override that other variant,
/// here. That would put us into the position of blowing up if we tried
/// to do an undo on a field that was added using that new variant of add(),
/// because the extra undo-related work would not have been done by the
/// new variant.
///
/// Solve the problem by implementing Collection and then *use* a tree
/// to store the data.

public class UndoableTree<T: Comparable> : Collection, Undoable {

    private var data = Tree<T>()

    private var undoStack: [ (undo:()->(), redo:()->()) ] = []
    private var redoStack: [ (undo:()->(), redo:()->()) ] = []

    public var count: Int { return data.count }

    public func add( element: T ) -> Bool {
        undoStack.append(
            ( undo:{ try! data.remove(element) },
              redo:{      data.add   (element) } )
        )
        return data.add(element)
    }

    public func remove( lookingFor: T ) -> T? {
        undoStack.append(
            ( undo:{      data.add   (lookingFor) },
              redo:{ try! data.remove(lookingFor) } )
        )
        return try! data.remove(lookingFor)
    }

    /// Undo an add or remove. It's harmless to call this
    /// method if there's nothing to undo.
    ///
    public func undo() -> Bool {
        if undoStack.count <= 0 { return false }

        let action = undoStack.removeLast()
        action.undo()
        redoStack.append(action)
        return true
    }

    /// Redo something that you undid by calling undo()
    /// Calling this method is harmless if there's nothing
    /// to redo.

    public func redo() -> Bool {
        if redoStack.count <= 0 { return false }

        let action = redoStack.removeLast()
        action.redo()
        undoStack.append(action)
        return true
    }

    public func findMatchOf( lookingFor: T ) -> T? {
        return data.findMatchOf(lookingFor)
    }

    public func contains( lookingFor: T ) -> Bool {
        return data.contains(lookingFor)
    }

    public func traverse( iterator: (T)->Bool ) {
        return data.traverse(iterator)
    }
    public func forEveryElement(iterator: (T)->()) {
        return data.forEveryElement(iterator)
    }
}