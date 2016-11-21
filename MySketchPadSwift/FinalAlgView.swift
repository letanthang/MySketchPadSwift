//
//  FinalAlgView.swift
//  MySketchPadSwift
//
//  Created by Le Tan Thang on 11/18/16.
//  Copyright © 2016 Le Tan Thang. All rights reserved.
//

import UIKit

let CAPACITY = 100
let FF = 0.2
let LOWER: CGFloat = 0.01
let UPPER: CGFloat = 1.0

struct LineSegment {
    var firstPoint: CGPoint
    var secondPoint: CGPoint
}

class FinalAlgView: UIView {
    
    var color: UIColor = UIColor.black
    var lineWidth: CGFloat = 1.0
    var lineEffect: CGFloat = 0.1
    
    
    var incrementalImage: UIImage?
    var pts: [CGPoint] = [CGPoint](repeating: CGPoint.zero, count: 5)
    var ctr: Int = 0
    var bufIdx: Int = 0
    var pointsBuffer: [CGPoint] = [CGPoint](repeating: CGPoint.zero, count: CAPACITY)
    var drawingQueue: DispatchQueue = DispatchQueue(label: "drawingQueue")
    var isFirstTouchPoint: Bool = false
    var lastSegmentOfPrev: LineSegment!
    var count = 0;
    var subPath = [UIBezierPath]()
    var paths = [[UIBezierPath]]()
    
    var test = UIView()
    

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initHelper()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initHelper()
    }
    
    convenience init() {
        self.init()
        initHelper()
    }
    
    func initHelper() {
        isOpaque = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(eraseDrawing))
        tap.numberOfTapsRequired = 3
        addGestureRecognizer(tap)
    }
    
    func eraseDrawing() {
        incrementalImage = nil
        setNeedsDisplay()
    }
    
    func addPathForUndo() {
        if count > 0 {
            paths.removeSubrange(paths.count - count ..< paths.count)
            count = 0
        }
        
        paths.append(subPath)
    }
    
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        incrementalImage?.draw(in: rect)
    }
    
    func reDraw() {
        //0: erase all
        incrementalImage = nil
        setNeedsDisplay()
        
        //start redraw from begin to paths.count - count
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        for i in 0 ..< paths.count - count {
            let subs: [UIBezierPath] = paths[i]
            if subs.count > 0 {
                for path: UIBezierPath in subs {
                    if incrementalImage == nil {
                        let rectPath: UIBezierPath = UIBezierPath(rect: bounds)
                        UIColor.clear.setFill()
                        rectPath.fill()
                        incrementalImage = UIGraphicsGetImageFromCurrentImageContext()
                    }
                    incrementalImage?.draw(at: CGPoint.zero)
                    color.setStroke()
                    color.setFill()
                    path.stroke()
                    path.fill()
                }
            } else {
                UIGraphicsEndImageContext()
                incrementalImage = nil
            }
            
        }
        incrementalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        setNeedsDisplay()
    }
    
    func undoDraw() {
        guard count < paths.count else { return }
        count += 1
        reDraw()
    }
    
    func redoDraw() {
        guard count > 0 else { return }
        count -= 1
        reDraw()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        ctr = 0
        bufIdx = 0
        let touch = touches.first!
        pts[0] = touch.location(in: self)
        isFirstTouchPoint = true
        subPath = [UIBezierPath]()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let p = touch.location(in: self)
        ctr += 1
        pts[ctr] = p
        if ctr == 4 {
            pts[3] = CGPoint(x: (pts[2].x + pts[4].x)/2.0, y: (pts[2].y + pts[4].y)/2.0)
            
            for i in 0 ..< 4 {
                pointsBuffer[bufIdx + i] = pts[i]
            }
            bufIdx += 4
            let bounds = self.bounds
            
            drawingQueue.async {
                let offsetPath = UIBezierPath()
                if self.bufIdx == 0 { return }
                
                offsetPath.lineWidth = CGFloat(self.lineWidth)
                var ls = [LineSegment](repeatElement(LineSegment(firstPoint: CGPoint.zero, secondPoint: CGPoint.zero), count: 4))
                //var ls = [LineSegment]()
                
                for i in sequence(first: 0, next: { $0 + 4 < self.bufIdx ? $0 + 4 : nil }) {
                    
                    if self.isFirstTouchPoint {
                        
                        ls[0] = LineSegment(firstPoint: self.pointsBuffer[0], secondPoint: self.pointsBuffer[0])
                        offsetPath.move(to: ls[0].firstPoint)
                        self.isFirstTouchPoint = false
                        
                        
                    } else {
                        ls[0] = self.lastSegmentOfPrev
                        //print(ls[0])
                    }
                    
                    let frac1: CGFloat = self.lineEffect/self.clamp(value: self.len_sq(p1: self.pointsBuffer[i], p2: self.pointsBuffer[i+1]), lower: LOWER, higher: UPPER)
                    
                    
                    let frac2: CGFloat = self.lineEffect/self.clamp(value: self.len_sq(p1: self.pointsBuffer[i+1], p2: self.pointsBuffer[i+2]), lower: LOWER, higher: UPPER)
                    
                    let frac3: CGFloat = self.lineEffect/self.clamp(value: self.len_sq(p1: self.pointsBuffer[i+2], p2: self.pointsBuffer[i+3]), lower: LOWER, higher: UPPER)
                    
                    ls[1] = self.lineSegmentPerpendicularTo(pp: LineSegment(firstPoint: self.pointsBuffer[i], secondPoint: self.pointsBuffer[i+1]), ofRelativeLength: frac1)
                    
                    ls[2] = self.lineSegmentPerpendicularTo(pp: LineSegment(firstPoint: self.pointsBuffer[i+1], secondPoint: self.pointsBuffer[i+2]), ofRelativeLength: frac2)
                    
                    ls[3] = self.lineSegmentPerpendicularTo(pp: LineSegment(firstPoint: self.pointsBuffer[i+2], secondPoint: self.pointsBuffer[i+3]), ofRelativeLength: frac3)
                    
                    offsetPath.move(to: ls[0].firstPoint)
                    offsetPath.addCurve(to: ls[3].firstPoint, controlPoint1: ls[1].firstPoint, controlPoint2: ls[2].firstPoint)
                    
                    offsetPath.addLine(to: ls[3].secondPoint)
                    offsetPath.addCurve(to: ls[0].secondPoint, controlPoint1: ls[2].secondPoint, controlPoint2: ls[1].secondPoint)
                    offsetPath.close()
                    
                    self.lastSegmentOfPrev = ls[3]

                    
                }
                //store path for undo
                self.subPath.append(offsetPath)
                UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
                if self.incrementalImage ==  nil {
                    let rectPath = UIBezierPath(rect: self.bounds)
                    UIColor.clear.setFill()
                    rectPath.fill()
                }
                self.incrementalImage?.draw(at: CGPoint.zero)
                self.color.setStroke()
                self.color.setFill()
                offsetPath.stroke()
                offsetPath.fill()
                self.incrementalImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                DispatchQueue.main.async {
                    self.bufIdx = 0
                    self.setNeedsDisplay()
                }
            }
            pts[0] = pts[3]
            pts[1] = pts[4]
            ctr = 1
            
        }
        
    }
    
    func lineSegmentPerpendicularTo(pp: LineSegment, ofRelativeLength fraction: CGFloat) -> LineSegment {
        let x0 = pp.firstPoint.x
        let y0 = pp.firstPoint.y
        let x1 = pp.secondPoint.x
        let y1 = pp.secondPoint.y
        
        let dx = x1 - x0
        let dy = y1 - y0
        
        let xa = x1 + fraction/2 * dy
        let ya = y1 - fraction/2 * dx
        let xb = x1 - fraction/2 * dy
        let yb = y1 + fraction/2 * dx
        
        
        return LineSegment(firstPoint: CGPoint(x: xa, y: ya), secondPoint: CGPoint(x: xb, y: yb))
    }
    
    func len_sq(p1: CGPoint, p2: CGPoint) -> CGFloat {
        let dx = p2.x - p1.x;
        let dy = p2.y - p1.y;
        return dx * dx + dy * dy;
    }
    
    func clamp(value: CGFloat, lower: CGFloat, higher: CGFloat) -> CGFloat {
        if value < lower { return lower }
        if value > higher { return higher }
        return value
    }
    

}
