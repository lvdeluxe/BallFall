/**
 * Created by lvdeluxe on 14-08-09.
 */
package com.deluxe.ballfall.particles {
import com.deluxe.GAtlasManager;
import com.genome2d.components.renderables.particles.GParticle;
import com.genome2d.components.renderables.particles.GSimpleParticleSystem;
import com.genome2d.context.GBlendMode;
import com.genome2d.node.GNode;

public class ExplosionParticles extends GSimpleParticleSystem{
	public function ExplosionParticles(p_node:GNode) {
		super(p_node);
		blendMode = GBlendMode.ADD;
		texture = GAtlasManager.mainAtlas.getSubTexture("particleTexture");

		emission = 75;
		emissionDelay = 0;
		emissionTime = 1;
		emissionVariance = 0;
		energy = 0.75;
		energyVariance = 0.2;
		dispersionAngle = 6.28;
		dispersionAngleVariance = 6.28;
		dispersionXVariance = 0;
		dispersionYVariance = 0;
		initialScale = 1;
		endScale = 0;
		initialScaleVariance = 0.5;
		endScaleVariance = 0;
		initialVelocity = 75;
		initialVelocityVariance = 200;
		initialAngularVelocity = 0.003;
		initialAngularVelocityVariance = 0.01;
		initialAcceleration = -0.25;
		initialAccelerationVariance = 0.25;
		initialAngle = 1;
		initialAngleVariance = 0;
		initialColor = 16770048;
		endColor = 16747008;
		initialAlpha = 1;
		initialAlphaVariance = 0;
		endAlpha = 1;
		endAlphaVariance = 0;
		initialRed = 1;
		initialRedVariance = 0;
		endRed = 1;
		endRedVariance = 0;
		initialGreen = 0.8941176470588236;
		initialGreenVariance = 0;
		endGreen = 0.5411764705882353;
		endGreenVariance = 0;
		initialBlue = 0;
		initialBlueVariance = 0;
		endBlue = 0;
		endBlueVariance = 0;
		emit = true;
		burst = true;
	}
}
}
