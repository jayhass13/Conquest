//
//  TileMap.swift
//  Game
//
//  Created by Marvin Fishingpole on 12/21/19.
//  Copyright © 2019 None. All rights reserved.
//

import Foundation
import SpriteKit

public class TileMap:SKNode {
    
    private var defaultTileWidth:Int = 64
    private var defaultTileHeight:Int = 64
    private var defaultLeftPoint:CGPoint = CGPoint.zero
    
    public var tiles:[[Tile]] = []
    
    public var highlightedTiles:[Tile] = [] {
        
        willSet {
            dehighlightTiles()
        }
        
        didSet {
            highlightTiles()
        }
    }
    
    init(numRows: Int, numCols: Int) {
        super.init()
        
        self.drawTileMap(numRows: numRows,
                         numCols: numCols,
                         tileWidth: defaultTileWidth,
                         tileHeight: defaultTileHeight,
                         leftPoint: defaultLeftPoint)
        
    }
    
    init(numRows: Int,
         numCols: Int,
         tileWidth: Int,
         tileHeight: Int,
         leftPoint: CGPoint) {
        
        self.defaultTileWidth = tileWidth
        self.defaultTileHeight = tileHeight
        self.defaultLeftPoint = leftPoint
        
        super.init()
        
        self.drawTileMap(numRows: numRows,
                         numCols: numCols,
                         tileWidth: defaultTileWidth,
                         tileHeight: defaultTileHeight,
                         leftPoint: defaultLeftPoint)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func getNumRows() -> Int {return tiles.count}
    public func getNumCols() -> Int {return tiles[0].count}
    
    private func drawTileMap(numRows: Int,
                            numCols: Int,
                            tileWidth: Int,
                            tileHeight: Int,
                            leftPoint: CGPoint) {
        
        tiles.reserveCapacity(numRows)
        
        for row in 0...numRows - 1 {
            
            tiles.append([])
            tiles[row].reserveCapacity(numCols)
            
            for col in 0...numCols - 1 {
                    
                let tileX = tileWidth * col
                let tileY = tileHeight * row
                    
                let realX = CGFloat(tileX) + leftPoint.x
                let realY = CGFloat(tileY) + leftPoint.y
                    
                var tile_texture = SKTexture()
                //let texture = Int.random(in: 1...3)
                let texture = 3
                var moveCost = 0
                    
                switch texture {
                case 1:
                    tile_texture = SKTexture(imageNamed: "Sand")
                    moveCost = 3
                case 2:
                    tile_texture = SKTexture(imageNamed: "Grass")
                    moveCost = 2
                case 3:
                    tile_texture = SKTexture(imageNamed: "Cobblestone")
                    moveCost = 1
                default:
                    break;
                }
                    
                let tile = Tile(width: tileWidth,
                                height: tileHeight,
                                center: CGPoint(x: realX, y: realY),
                                texture: tile_texture,
                                rowIndex: row,
                                colIndex: col,
                                moveCost: moveCost)
                    
                self.addChild(tile)
                self.tiles[row].append(tile)
                    
            }
        }
    }
    
    public func centerOfTile(row: Int, col: Int) -> CGPoint {
        
        return tiles[row][col].getCenter()
    }
    
    public func getTile(at: CGPoint) -> Tile? {
        
        let h = CGFloat(defaultTileHeight)
        let w = CGFloat(defaultTileWidth)
        
        //Need to offset it because the left point is actually the center of the tile
        let tileX = at.x + (w / 2)
        let tileY = at.y + (h / 2)
        
        let column = tileX / w
        let row = tileY / h
        
        let col_int:Int = Int(floor(column))
        let row_int:Int = Int(floor(row))
        
        if (col_int < 0 || col_int >= tiles[0].count
            || row_int < 0 || row_int >= tiles.count) {
            return nil
        }
        
        let expectedTile = tiles[row_int][col_int]
        
        if (expectedTile.contains(at)) {
            return expectedTile
        }
        return nil
    }
    
    struct Node:Comparable {
        
        init(index: Int, h: Int, c: Int) {
            self.index = index
            self.h = h
            self.c = c
        }
        
        init(index: Int, c: Int) {
            self.index = index
            self.c = c
            self.h = 0
        }
        
        
        static func < (lhs: Node, rhs: Node) -> Bool {
                
            if (lhs.priority == rhs.priority) {
                    
                return lhs.h < rhs.h
            }
            return lhs.priority < rhs.priority
        }
        
        var highlightPath:[CGVector] = []
        var index:Int
        var priority:Int {
            return h + c
        }
        var h:Int
        var c:Int
        
    }
    
    
    
    //----------------------------------
    //MARK: Pathfinding
    //----------------------------------
    
    //ignoresUnit is the team which this unit can ignore while executing the action
    //i.e. a team can go through its own teammates when moving
    //includesUnit is whether the tiles returned include units, so for example moving does not but attacking does cuz u cant move onto another unit but u can attack it
    
    
    //Dijsktras algorithm
    public func getTiles(withinRange: Int, from: Tile, ignoresUnit: Bool, isPlayer: Bool, ignoresTerrain: Bool, includesUnit: Bool, recordsPath: Bool) -> [Tile] {
        
        var tilesInRange:[Tile] = []
        
        //FIRST INT is the shortest distance to that tile, second is path
        var shortest = PriorityQueue<Node>(ascending: true, startingValues: [])
        var visited:Dictionary<Int, Bool> = [:]
        shortest.push(Node(index: to1D(row: from.getRow(), col: from.getCol()), c: 0))
        visited[to1D(row: from.getRow(), col: from.getCol())] = true
        
        while !shortest.isEmpty {
            let nextShortest = shortest.pop()!

            if nextShortest.c > withinRange {
                break
            }
            
            let currentTile = to2D(i: nextShortest.index)
            if (includesUnit || currentTile.currentUnit == nil) {
                tilesInRange.append(currentTile)
            }
        
            if (recordsPath) {
                currentTile.highlightPath = nextShortest.highlightPath
            }
            
            for neighbor in self.getNeighbors(row: currentTile.getRow(), col: currentTile.getCol()) {
                let index = to1D(row: neighbor.0, col: neighbor.1)
                let neighborTile = tiles[neighbor.0][neighbor.1]
                
                if (visited[index] == nil ) {
                    
                    visited[index] = true
                    
                    if (index == 0) {
                        
                    }
                    
                    //If whatever you're getting the tiles for does not ignore units, and the unit at the tile to be investigated
                    //is not nil, AND that unit is not on the same team as the unit for which you're getting the tiles,
                    //skip it, because the unit cannot move there
                    if (!ignoresUnit
                        && neighborTile.currentUnit != nil
                        && neighborTile.currentUnit?.isPlayer() != isPlayer) {
                        continue
                    }
                    
                    var currentVector = nextShortest.highlightPath
                    currentVector.append(CGVector(dx: neighborTile.getCenter().x - currentTile.getCenter().x, dy: neighborTile.getCenter().y - currentTile.getCenter().y))
                    
                    var terrainCost = 1
                    
                    if (!ignoresTerrain) {
                        terrainCost = neighborTile.getMoveCost()
                    }
                    
                    var toPush = Node(index: index, c: nextShortest.c + terrainCost)
                    toPush.highlightPath = currentVector
                    shortest.push(toPush)
                }
            }
        }
        
        return tilesInRange
    }
    
    
    
    //Returns the possible tiles that a unit can attack, based on its range and where it can move
    //Keys are attackable tiles, values are where it came from
    public func getAttackableTiles(unit: Unit, attackRange: Int) -> Dictionary<Int, Int> {
        
        var moveTiles:[Tile] = [unit.getCurrentTile()!]
        
        moveTiles.append(contentsOf: getTiles(withinRange: unit.getStat(stat: .movement),
                                              from: unit.getCurrentTile()!,
                                              ignoresUnit: false, isPlayer: unit.isPlayer(),
                                              ignoresTerrain: false, includesUnit: false, recordsPath: true))
    
        var tilesInRange:Dictionary<Int, Int> = [:]
        for tile in moveTiles {
            
            
            //Potential area for improvement, with bigger maps this could cause a lot of slowdown
            let attackableTiles = getTiles(withinRange: attackRange, from: tile, ignoresUnit: true, isPlayer: unit.isPlayer(),
                                           ignoresTerrain: true, includesUnit: true, recordsPath: false)
            
            for t in attackableTiles {
                
                if ((tilesInRange[to1D(row: t.getRow(), col: t.getCol())]) == nil
                    && t != tile) {
                    
                    tilesInRange[to1D(row: t.getRow(), col: t.getCol())] = to1D(row: tile.getRow(),
                                                                                col: tile.getCol())
                }
            }
        }

        return tilesInRange
    }
    
    //AI Options returns the an array of pairs, tile is tile unit goes to and unit is the unit it's attacking
    
    public func getAIOptions(unit: Unit, attackRange: Int) -> [(Tile, Unit)] {
        
        let range = getAttackableTiles(unit: unit, attackRange: attackRange)
        var toReturn:[(Tile, Unit)] = []
        
        for tileIndex in range.keys {
            
            let tile = to2D(i: tileIndex)
            let attackingTile = to2D(i: range[tileIndex]!)
            
            if tile.currentUnit != nil && tile.currentUnit!.isPlayer() != unit.isPlayer() {
                toReturn.append((attackingTile, tile.currentUnit!))
            }
        }
        return toReturn
    }
    
    
    
    public func shortestPath(to: Tile, from: Tile, ignoresUnit: Bool, isPlayer: Bool, ignoresTerrain: Bool) -> [CGVector] {
        
        var frontier = PriorityQueue<Node>(ascending: true, startingValues: [Node(index: to1D(row: from.getRow(), col: from.getCol()), h: 0, c: 0)])
        
        var cameFrom = Dictionary<Int, Int>()
        var costSoFar = Dictionary<Int, Int>()
        costSoFar[to1D(row: from.getRow(), col: from.getCol())] = 0
        
        let goal = to1D(row: to.getRow(), col: to.getCol())
        
        while !frontier.isEmpty {
            let current = frontier.pop()
            
            if (current!.index == goal) {
                break
            }
            
            let pair = to2dPair(i: current!.index)
            for neighbor in getNeighbors(row: pair.0, col: pair.1) {
                
                var terrainCost = 1
                let neighborTile = tiles[neighbor.0][neighbor.1]
                
                if (!ignoresTerrain) {
                    terrainCost = neighborTile.getMoveCost()
                }
                
                if !ignoresUnit
                    && neighborTile.currentUnit != nil
                    && neighborTile.currentUnit!.isPlayer() != isPlayer {
                    
                    continue
                }
                
                let newCost = costSoFar[current!.index]! + terrainCost
                
                if costSoFar[to1D(row: neighbor.0, col: neighbor.1)] == nil || newCost < costSoFar[to1D(row: neighbor.0, col: neighbor.1)]! {
                    costSoFar[to1D(row: neighbor.0, col: neighbor.1)] = newCost
                    frontier.push(Node(index: to1D(row: neighbor.0, col: neighbor.1), h: heuristicDistance(goal: to, current: tiles[neighbor.0][neighbor.1]), c: newCost))
                    cameFrom[to1D(row: neighbor.0, col: neighbor.1)] = current!.index
                    
                }
            }
        }
        
        var current = to1D(row: to.getRow(), col: to.getCol())
        var path:[CGVector] = []
        
        while (cameFrom[current] != nil) {
            let currentTile = to2D(i: current)
            let prevTile = to2D(i: cameFrom[current]!)
            
            path.append(CGVector(dx: currentTile.getCenter().x - prevTile.getCenter().x, dy: currentTile.getCenter().y - prevTile.getCenter().y))
            current = cameFrom[current]!
        }
        path.reverse()
        
        return path
    }
    
    
    private func to1D(row: Int, col: Int) -> Int { return (row * tiles[0].count) + col}
    private func to2D(i: Int) -> Tile {
        let row = i / self.getNumCols()
        let col = i % self.getNumCols()
        return tiles[row][col]
    }
    private func to2dPair(i: Int) -> (Int, Int) {
        let row = i / self.getNumCols()
        let col = i % self.getNumCols()
        return (row, col)
    }
    
    private func getNeighbors(row: Int, col: Int) -> [(Int, Int)] {
        
        var neighbors:[(Int, Int)] = []
        
        if row > 0 {
            neighbors.append((row - 1, col))
        }
        
        if row < tiles.count - 1 {
            neighbors.append((row + 1, col))
        }
        
        if col < tiles[0].count - 1 {
            neighbors.append((row, col + 1))
        }
        
        if col > 0 {
            neighbors.append((row, col - 1))
        }
        
        return neighbors
    }
    
    
    public func heuristicDistance(goal: Tile, current: Tile) -> Int {
        
        return abs(goal.getRow() - current.getRow()) + abs(goal.getCol() - current.getCol())
    }
    
    
    private func highlightTiles() {
        
        for tile in self.highlightedTiles {
            
            tile.isHighlighted = true
        }
    }
    
    private func dehighlightTiles() {
        
        for tile in self.highlightedTiles {
            tile.highlightPath = nil
            tile.isHighlighted = false
        }
    }
    
    
    
    deinit {
        print("Tilemap Deinit")
    }
    
    
    
}


