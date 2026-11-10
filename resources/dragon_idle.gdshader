shader_type canvas_item;

uniform sampler2D source_art : filter_linear, repeat_disable;
varying vec4 sprite_tint;

uniform sampler2D motion_mask : filter_linear, repeat_disable;
uniform float anim_time = 0.0;
uniform float blink_amount = 0.0;
uniform vec2 gaze = vec2(0.0);
uniform vec4 eye1_rect;
uniform vec4 eye2_rect;
uniform vec4 eyelid_color : source_color;
uniform vec2 left_hinge;
uniform vec2 right_hinge;
uniform float wing_amplitude = 0.18;
uniform float awake_opacity = 1.0;
uniform float drowsiness = 0.0;
uniform float wing_speed = 3.0;
uniform bool aquatic = false;
uniform vec4 tail_region;
uniform vec4 flame_core_color : source_color;
uniform vec4 flame_edge_color : source_color;

float hash(vec2 p) { return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453); }
float noise(vec2 p) {
 vec2 i=floor(p); vec2 f=fract(p); f=f*f*(3.0-2.0*f);
 return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)),f.x),f.y);
}
float turbulence(vec2 p) { return noise(p)*0.65+noise(p*2.07+5.3)*0.25+noise(p*4.13)*0.10; }
vec2 rotate_uv(vec2 p,vec2 hinge,float angle,float fold) {
 vec2 v=p-hinge; v.x/=fold;
 float c=cos(angle); float s=sin(angle);
 return hinge+vec2(v.x*c-v.y*s,v.x*s+v.y*c);
}
vec4 over(vec4 front,vec4 back) {
 float a=front.a+back.a*(1.0-front.a);
 return vec4((front.rgb*front.a+back.rgb*back.a*(1.0-front.a))/max(a,0.0001),a);
}
float eye_region(vec2 uv,vec4 eye) {
 vec2 p=(uv-eye.xy)/eye.zw;
 return 1.0-smoothstep(0.82,1.04,dot(p,p));
}
vec4 body_sample(vec2 uv) {
 float plume=texture(motion_mask,uv).b;
 float n=turbulence(uv*22.0+vec2(0.0,anim_time*(aquatic?0.9:2.3)));
 // Flow is confined to authored plumes. Skin, horns and scales keep their shape.
 vec2 flow=vec2((n-0.5)*0.020,(noise(uv*31.0+anim_time)-0.5)*0.006);
 vec2 sample_uv=uv+flow*plume;
 float eyes=max(eye_region(uv,eye1_rect),eye_region(uv,eye2_rect));
 sample_uv-=gaze*eyes*(1.0-blink_amount);
 vec4 color=texture(source_art,clamp(sample_uv,vec2(0.001),vec2(0.999)));
 float luminous=smoothstep(0.6,0.94,max(color.r,max(color.g,color.b)));
 float glow=plume*luminous*(0.045+0.085*n);
 color.rgb+=flame_core_color.rgb*glow;
 return color;
}
vec4 eyelid(vec4 color,vec2 uv,vec4 eye) {
 vec2 p=(uv-eye.xy)/eye.zw;
 float mask=eye_region(uv,eye);
 float curve=0.12*(1.0-p.x*p.x);
 float seam=0.12+curve;
 float upper=mix(-1.12,seam,blink_amount);
 float lower=mix(1.12,seam,blink_amount);
 float coverage=clamp(1.0-smoothstep(upper-0.045,upper+0.045,p.y)+smoothstep(lower-0.045,lower+0.045,p.y),0.0,1.0)*mask;
 vec3 sampled_skin=texture(source_art,eye.xy+vec2(p.x*eye.z*0.65,-eye.w*1.65)).rgb;
 vec3 skin=mix(eyelid_color.rgb,sampled_skin,0.35);
 color.rgb=mix(color.rgb,skin,coverage);
 float lash=(1.0-smoothstep(0.025,0.09,abs(p.y-upper)))*mask*blink_amount;
 color.rgb=mix(color.rgb,vec3(0.075,0.045,0.09),lash*0.85);
 return color;
}
void vertex() { sprite_tint = COLOR; }
void fragment() {
 vec2 uv=UV;
 float breath=sin(anim_time*2.1)*0.023*(1.0-drowsiness*0.65);
 vec2 planted=vec2(0.5,0.90);
 uv=planted+(uv-planted)/vec2(1.0+breath*0.35,1.0+breath-0.10*drowsiness);
 uv.x+=sin(anim_time*1.25)*0.011*(0.9-uv.y)*(1.0-drowsiness);

 vec2 tail_p=(uv-tail_region.xy)/tail_region.zw;
 float tail=(1.0-smoothstep(0.25,1.0,dot(tail_p,tail_p)))*(1.0-drowsiness);
 uv+=vec2(sin(anim_time*2.4+uv.y*8.0)*0.012,cos(anim_time*2.1+uv.x*9.0)*0.006)*tail;
 float phase=anim_time*wing_speed;
 // The shoulder and the entire body-facing edge are fixed to the torso.
 // Only the distal membrane bends; continuous UV deformation avoids cut-out gaps.
 float envelope=0.8+0.2*sin(anim_time*0.31);
 float left_angle=(sin(phase)+0.10*sin(phase*2.0-0.5))*wing_amplitude*envelope*(1.0-drowsiness*0.8);
 float right_angle=-(sin(phase-0.12)+0.08*sin(phase*2.0-0.7))*wing_amplitude*envelope*(1.0-drowsiness*0.8);
 float left_bend=1.0-smoothstep(left_hinge.x-0.26,left_hinge.x-0.045,uv.x);
 float right_bend=smoothstep(right_hinge.x+0.035,right_hinge.x+0.22,uv.x);
 left_bend=pow(left_bend,1.4);
 right_bend=pow(right_bend,1.4);
 // Feather the authored region boundary so the membrane and original silhouette
 // share a continuous surface, instead of compositing a moving wing over a hole.
 vec2 feather=vec2(0.004);
 vec2 wings=texture(motion_mask,uv).rg*0.4;
 wings+=texture(motion_mask,uv+vec2(feather.x,0.0)).rg*0.15;
 wings+=texture(motion_mask,uv-vec2(feather.x,0.0)).rg*0.15;
 wings+=texture(motion_mask,uv+vec2(0.0,feather.y)).rg*0.15;
 wings+=texture(motion_mask,uv-vec2(0.0,feather.y)).rg*0.15;
 vec2 left_uv=rotate_uv(uv,left_hinge,left_angle*left_bend,1.0+0.018*sin(phase)*left_bend);
 vec2 right_uv=rotate_uv(uv,right_hinge,right_angle*right_bend,1.0+0.018*sin(phase-0.12)*right_bend);
 left_uv.y+=sin(phase-0.35)*0.010*left_bend*(1.0-drowsiness);
 right_uv.y+=sin(phase-0.47)*0.010*right_bend*(1.0-drowsiness);
 vec2 surface_uv=uv+(left_uv-uv)*wings.r+(right_uv-uv)*wings.g;
 vec4 body=body_sample(surface_uv);
 if(blink_amount>0.001) {
  body=eyelid(body,uv,eye1_rect);
  body=eyelid(body,uv,eye2_rect);
 }
 COLOR=body*sprite_tint;
 COLOR.a*=awake_opacity;
}
