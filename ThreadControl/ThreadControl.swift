//
//  ThreadControl.swift
//  ThreadControl
//
//  Created by Daisuke T on 2019/04/24.
//  Copyright © 2019 ThreadControl. All rights reserved.
//

import Foundation

public class ThreadControl {
	
	// MARK: - Enum, Const
	public enum Mode {
		case oneShot
		case loop
	}
	
	private struct ThreadArgument {
		let target: AnyObject
		let selector: Selector
		let rawArgument: Any?
		let loopTimeInterval: TimeInterval
	}
	
	
	// MARK: - Property
	public private(set) var rawThread: Thread?
	public private(set) var mode = Mode.oneShot
	
	
	// MARK: - Initialize
	public init(target: AnyObject, selector: Selector, object argument: Any?, mode: Mode, loopTimeInterval: TimeInterval) {
		self.mode = mode
		
		var threadEntey = #selector(ThreadControl.threadEntryOneShot(_:))
		if mode == .loop {
			threadEntey = #selector(ThreadControl.threadEntryLoop(_:))
		}
		
		let threadArgument = ThreadArgument(target: target,
											selector: selector,
											rawArgument: argument,
											loopTimeInterval: loopTimeInterval)
		
		rawThread = Thread.init(target: self,
								selector: threadEntey,
								object: threadArgument)
	}
	
	/// Initialize for One-Shot
	public convenience init(target: AnyObject, selector: Selector, object argument: Any?){
		self.init(target: target, selector: selector, object: argument, mode: .oneShot, loopTimeInterval: 0)
	}
	
	/// Initialize for Loop
	public convenience init(target: AnyObject, selector: Selector, object argument: Any?, loopTimeInterval: TimeInterval) {
		self.init(target: target, selector: selector, object: argument, mode: .loop, loopTimeInterval: loopTimeInterval)
	}
	
}


// MARK: - Thread Entry
public extension ThreadControl {
	
	@objc func threadEntryOneShot(_ argument: Any?) {
		autoreleasepool {
			guard let threadArgument = argument as? ThreadArgument else {
				return
			}
			
			let target = threadArgument.target
			let selector = threadArgument.selector
			let rawArgument = threadArgument.rawArgument
			
			target.perform(selector, on: Thread.current, with: rawArgument, waitUntilDone: false)
			RunLoop.current.run(until: Date.init(timeIntervalSinceNow: 0.01))
		}
	}
	
	@objc func threadEntryLoop(_ argument: Any?) {
		autoreleasepool {
			guard let threadArgument = argument as? ThreadArgument else {
				return
			}
			
			let target = threadArgument.target
			let selector = threadArgument.selector
			let rawArgument = threadArgument.rawArgument
			let loopTimeInterval = threadArgument.loopTimeInterval
			
			while !Thread.current.isCancelled {
				autoreleasepool {
					target.perform(selector, on: Thread.current, with: rawArgument, waitUntilDone: false)
					RunLoop.current.run(until: Date.init(timeIntervalSinceNow: 0.01))
					
					Thread.sleep(forTimeInterval: loopTimeInterval)
				}
			}
		}
	}
	
}
