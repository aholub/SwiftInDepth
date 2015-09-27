//  TreeSupport.swift
//  Copyright © 2015 Allen Holub. All rights reserved.
//
// Various tree-support classes needed for the generic versions.
//
// These need to be global becuase we can't nest enums in a generic
// class.

public enum Ordering { case Inorder, Postorder, Preorder }
public enum Direction{ case Left, Right }
public enum TreeError : ErrorType { case Empty }    // used by remove()

