/**
 * Created by lvdeluxe on 14-07-24.
 */
package com.genome2d.components {
import com.genome2d.node.GNode;

import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Polygon;
import nape.shape.Shape;

public class GNapeDynamicBody extends GComponent{

	public var body:Body;

	public function GNapeDynamicBody(p_node:GNode) {
		super(p_node);
		body = new Body(BodyType.DYNAMIC);
		//body.shapes.add(new Polygon(Polygon.box(64,64)));
		body.space = (node.core.root.getComponent(GNapePhysics) as GNapePhysics).space;
		node.core.onUpdate.add(updateHandler);
	}

	public function set shape(shape:Shape):void
	{
		body.shapes.add(shape);
	}

	private function updateHandler(dt:Number):void {
		if(body.space != null){
			node.transform.x = body.position.x;
			node.transform.y = body.position.y;
			node.transform.rotation = body.rotation;
		}
	}

	public function set x(value:Number):void{
		body.position.x = value;
	}

	public function set y(value:Number):void{
		body.position.y = value;
	}
}
}
