/**
 * Created by lvdeluxe on 14-07-24.
 */
package com.genome2d.components {
import com.genome2d.node.GNode;

import nape.geom.Vec2;
import nape.space.Space;

public class GNapePhysics extends GComponent{

	public var space:Space;

	public function GNapePhysics(p_node:GNode) {
		super(p_node);
		space = new Space(Vec2.weak(0,0));
		space.worldAngularDrag = 0.9;
		space.worldLinearDrag = 0.9;
		node.core.onUpdate.add(updateHandler);
	}

	private function updateHandler(dt:Number):void {
		space.step(dt / 1000);
	}
}
}
