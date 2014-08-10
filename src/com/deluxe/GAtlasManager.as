/**
 * Created by lvdeluxe on 14-08-09.
 */
package com.deluxe {
import com.genome2d.textures.GTextureAtlas;
import com.genome2d.textures.factories.GTextureAtlasFactory;

import flash.display.BitmapData;

public class GAtlasManager {

	[Embed(source = "/assets/ball.png")]
	private static var BallTexture:Class;
	[Embed(source = "/assets/endPoint.png")]
	private static var EndPointTexture:Class;
	[Embed(source = "/assets/background.png")]
	private static var BackgroundTexture:Class;
	[Embed(source = "/assets/particle.png")]
	private static var ParticleTexture:Class;

	public static var mainAtlas:GTextureAtlas;

	public static function init():void {
		var vBmpData:Vector.<BitmapData> = new Vector.<BitmapData>();
		vBmpData.push(new BallTexture().bitmapData);
		vBmpData.push(new EndPointTexture().bitmapData);
		vBmpData.push(new BackgroundTexture().bitmapData);
		vBmpData.push(new ParticleTexture().bitmapData);
		var vTextureIds:Vector.<String> = new Vector.<String>();
		vTextureIds.push("ballTexture");
		vTextureIds.push("endpointTexture");
		vTextureIds.push("bgTexture");
		vTextureIds.push("particleTexture");
		mainAtlas = GTextureAtlasFactory.createFromBitmapDatas("mainAtlas", vBmpData,vTextureIds);
	}
}
}
