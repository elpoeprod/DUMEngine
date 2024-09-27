#define DUMCameraSetSmooth
///(enable)
if argument0 DUMCameraSmooth() else DUMCameraNormal()

#define DUMCameraSmooth
__cam_xtarg=-(display_mouse_get_x()-display_get_width()/2)
__cam_dir+=(__cam_xtarg-__cam_dir)
__cam_pitch+=((display_mouse_get_y()-display_get_height()/2)-__cam_pitch)*0.1
__cam_pitch=clamp(__cam_pitch,minpitch,maxpitch)


#define DUMCameraNormal
__cam_dir-=(display_mouse_get_x()-display_get_width()/2)*(global.DUMsensitivity/5)
__cam_pitch+=(display_mouse_get_y()-display_get_height()/2)*(global.DUMsensitivity/5)
__cam_pitch=clamp(__cam_pitch,minpitch,maxpitch)
display_mouse_set(display_get_width()/2,display_get_height()/2)

#define DUMCameraFollowTargetSmooth
///(xsmooth,ysmooth,zsmooth)
//if you want regular camera use 1,1,1
//if you want smooth camera use 0.2, 0.2, 0.5
x+=(__dum_target.x-x)*argument0
y+=(__dum_target.y-y)*argument1
z+=(__dum_target.z-z)*argument2

#define DUMCameraInit
__cam_dir=0;
__cam_xtarg=0;
__cam_pitch=0;
__cam_cams=128;
myxlook=0
myylook=0
myzlook=0
__dum_target=-1;
z=0
global.__dum_camera=id
xoffset=0
yoffset=0
zoffset=0

maxpitch=85
minpitch=-85

#define DUMCameraSetCameraDist
///(math)
if argument_count==1 __cam_cams=argument[0] //adds camera dist
else __cam_cams=__dum_default_camera_dist //sets default one if no args

#define DUMCameraSetThirdPerson
global.firstpersoncam=0
global.thirdpersoncam=1
z=__dum_target.z
d3d_set_projection_ext(
x+lengthdir_x(lengthdir_x(__cam_cams,__cam_pitch),__cam_dir+180)+xoffset,
y+lengthdir_y(lengthdir_x(__cam_cams,__cam_pitch),__cam_dir-180)+yoffset,
z-lengthdir_y(__cam_cams,__cam_pitch)+zoffset,
__dum_target.x+xoffset,__dum_target.y+yoffset,__dum_target.z+zoffset,
0,0,1,global._DUM_FOV,global._DUM_CameraWidth/global._DUM_CameraHeight,1,32000)


#define DUMCameraSetFirstPerson
global.firstpersoncam=1
global.thirdpersoncam=0
myxlook=__dum_target.x+lengthdir_x(lengthdir_x(__cam_cams,__cam_pitch),__cam_dir)
myylook=__dum_target.y+lengthdir_y(lengthdir_x(__cam_cams,__cam_pitch),__cam_dir)
myzlook=__dum_target.z+lengthdir_y(__cam_cams,__cam_pitch)+32-global.shakecam*2
d3d_set_projection_ext(x+xoffset,y+yoffset,z+zoffset,myxlook+xoffset,myylook+yoffset,myzlook+yoffset,
0,0,1,global._DUM_FOV,
global._DUM_CameraWidth/global._DUM_CameraHeight,1,32000)

#define DUMCameraSetTarget
///(obj)
if instance_exists(argument0) __dum_target=argument0
return __dum_target; //return -1 or previous target obj id if arg0 inst doesn't exists

#define DUMCameraGetRotation
return global.__dum_camera.__cam_dir

#define DUMCameraSetOffset
///(xoff,yoff,zoff) returns 1
with global.__dum_camera {
xoffset=argument0
yoffset=argument1
zoffset=argument2
}

#define DUMCameraSetMinMaxPitch
///(minpitch,maxpitch)
minpitch=clamp(argument0,-89.9,89.9)
maxpitch=clamp(argument1,-89.9,89.9)

#define DUMCameraGet
return global.__dum_camera

#define DUMCameraGetPitch
return global.__dum_camera.__cam_pitch

#define DUMSoundLoad
///(fname)
if !global._DUM_audio {debug('SOUND',$01) exit}
var snd,snd1,realsnd;
snd=string(argument0) 
if !file_exists(snd) {msg('NO "'+string(argument0)+' FOUND') return -1}
snd1=string_replace(snd,".dsf",".wav")
//file_rename(snd,snd1)
if !file_exists(snd1) {msg('NO "'+string(argument0)+' FOUND') return -1}
realsnd=sound_add_ext(snd1,0,1,string_lower(DUMFnameRemoveExt(snd1)))
//file_rename(snd1,snd)
msg('LOADED '+snd)
return realsnd;

#define DUMSoundPlay
///(sound,loop)
if !global._DUM_audio {debug('SOUND',$01) exit}
var s;
if argument1 s=sound_loop(argument0)
else s=sound_play(argument0)
msg('PLAY '+string(argument0)+" WITH "+string(argument1)+" LOOP")
global.__sndplaying=argument0
return s

#define DUMSoundPlayFX
///(sound,loop,effects)
if !global._DUM_audio {debug('SOUND',$01) exit}
var s;
if argument1 s=sound_loop(argument0)
else s=sound_play(argument0)
msg('PLAY '+string(argument0)+" WITH "+string(argument1)+" LOOP")
global.__sndplaying=argument0
sound_effect_set(s,argument2)
return s

#define DUMSoundStop
///([sound])
if !global._DUM_audio {debug('SOUND',$01) exit}
if argument_count=0 sound_stop(global.__sndplaying)
else sound_stop(argument[0])

#define DUMSound3DDist
///(sound,listx,listy,listz,songx,songy,songz,mindist,maxdist)
if !global._DUM_audio {debug('SOUND',$01) exit}
var s,lx,ly,lz,sx,sy,sz,md,mmd;
s=argument0
lx=argument1
ly=argument2
lz=argument3
sx=argument4
sy=argument5
sz=argument6
md=argument7
mmd=argument8
sound_volume(s,(md+mmd-DUMPointDist3D(lx,ly,lz,sx,sy,sz))/1000)
//sound_pan(s,point_direction_pitch(sx,sy,sz,lx,ly,lz))

#define DUMBGSoundPlay
if !global._DUM_audio {debug('SOUND',$01) exit}
var song;
//if variable_global_exists('__playing') {if string(global.__playing)!='-1' sound_delete(global.__playing)}
song=sound_add('data\snd\mus\'+string(argument0),1,0)
//if song=-1 {msg('NO "data\snd\mus\'+string(argument0)+' FOUND') exit}
global.__playing=song
DUMSoundPlay(song,1)

#define DUMBGSoundStop
if !global._DUM_audio {debug('SOUND',$01) exit}
sound_stop(global.__playing)

#define DUMBGSoundPlayFX
///(sound,effects)
if !global._DUM_audio {debug('SOUND',$01) exit}
//if variable_global_exists('__playing') {if string(global.__playing)!='-1' sound_delete(global.__playing)}
var s,ss;
ss=sound_add('data\snd\mus\'+string(argument0),1,0)
//if variable_global_exists('_DUM_BG_EFFECT') sound_effect_destroy(global._DUM_BG_EFFECT)
//TODO global._DUM_BG_EFFECT=sound_kind_effect(1,argument1)
s=sound_loop(ss)
msg('PLAY '+string(argument0)+" WITH "+string(argument1)+" EFFECT")
global.__playing=argument0

return ss

#define draw_sprite_ext_blur
///DRAW_SPRITE_EXT_BLUR(SPR,SUBIMG,X,Y,XSC,YSC,ROT,COL,ALPHA)
draw_sprite_ext(argument0,argument1,argument2,argument3,argument4,argument5,argument6,argument7,argument8) 

draw_sprite_ext(argument0,argument1,argument2-1,argument3,argument4,argument5,argument6,argument7,argument8/2) 
draw_sprite_ext(argument0,argument1,argument2+1,argument3,argument4,argument5,argument6,argument7,argument8/2) 
draw_sprite_ext(argument0,argument1,argument2,argument3-1,argument4,argument5,argument6,argument7,argument8/2) 
draw_sprite_ext(argument0,argument1,argument2,argument3+1,argument4,argument5,argument6,argument7,argument8/2) 

draw_sprite_ext(argument0,argument1,argument2-2,argument3,argument4,argument5,argument6,argument7,argument8/4) 
draw_sprite_ext(argument0,argument1,argument2+2,argument3,argument4,argument5,argument6,argument7,argument8/4) 
draw_sprite_ext(argument0,argument1,argument2,argument3-2,argument4,argument5,argument6,argument7,argument8/4) 
draw_sprite_ext(argument0,argument1,argument2,argument3+2,argument4,argument5,argument6,argument7,argument8/4) 

draw_sprite_ext(argument0,argument1,argument2-3,argument3,argument4,argument5,argument6,argument7,argument8/8) 
draw_sprite_ext(argument0,argument1,argument2+3,argument3,argument4,argument5,argument6,argument7,argument8/8) 
draw_sprite_ext(argument0,argument1,argument2,argument3-3,argument4,argument5,argument6,argument7,argument8/8) 
draw_sprite_ext(argument0,argument1,argument2,argument3+3,argument4,argument5,argument6,argument7,argument8/8) 

//draw_sprite_ext(argument0,argument1+1,argument2,argument3,argument4,argument5,argument6,argument7,argument8) 

#define debug
var ret;ret=''
if argument0=='AUDIO' {
if argument1=$00 {ret=DUMStrExt('Successfully played sound from {0} at pos ({1},{2},{3})',x,y,depth)}
if argument1=$01 {ret=''}
}
show_debug_message('DUM ('+string(DUMEngineVersion)+') ['+DUMProjectName+']: ('+argument0+'): '+ret)

#define draw_text_blur
///draw_text_blur(x,y,str,xscale,yscale,angle,c1,c2,c3,c4,alpha)
var t;t=0
draw_set_alpha(0.02)
repeat(25) {
draw_text_transformed_color(argument0+t/10,argument1,argument2,argument3,argument4,argument5,argument6,argument7,argument8,argument9,argument10)
draw_text_transformed_color(argument0-t/10,argument1,argument2,argument3,argument4,argument5,argument6,argument7,argument8,argument9,argument10)
draw_text_transformed_color(argument0,argument1+t/10,argument2,argument3,argument4,argument5,argument6,argument7,argument8,argument9,argument10)
draw_text_transformed_color(argument0,argument1-t/10,argument2,argument3,argument4,argument5,argument6,argument7,argument8,argument9,argument10)
t+=1
}
draw_set_alpha(1)

#define draw_textc
///draw_textc(x,y,text,xsc,ysc,angle,col,alpha)
draw_text_transformed_color(argument0,argument1,argument2,argument3,argument4,argument5,argument6,argument6,argument6,argument6,argument7) 
 

#define draw_sprite_stretched_ext_blur
///draw_sprite_stretch_ext_blur(spr,subimg,x,y,w,h,col,alpha)
draw_sprite_stretched_ext(argument0,argument1,argument2,argument3,argument4,argument5,argument6,argument7) 

draw_sprite_stretched_ext(argument0,argument1,argument2-1,argument3,argument4,argument5,argument6,argument7/2) 
draw_sprite_stretched_ext(argument0,argument1,argument2+1,argument3,argument4,argument5,argument6,argument7/2) 
draw_sprite_stretched_ext(argument0,argument1,argument2,argument3-1,argument4,argument5,argument6,argument7/2) 
draw_sprite_stretched_ext(argument0,argument1,argument2,argument3+1,argument4,argument5,argument6,argument7/2) 

draw_sprite_stretched_ext(argument0,argument1,argument2-2,argument3,argument4,argument5,argument6,argument7/4) 
draw_sprite_stretched_ext(argument0,argument1,argument2+2,argument3,argument4,argument5,argument6,argument7/4) 
draw_sprite_stretched_ext(argument0,argument1,argument2,argument3-2,argument4,argument5,argument6,argument7/4) 
draw_sprite_stretched_ext(argument0,argument1,argument2,argument3+2,argument4,argument5,argument6,argument7/4) 

draw_sprite_stretched_ext(argument0,argument1,argument2-3,argument3,argument4,argument5,argument6,argument7/8) 
draw_sprite_stretched_ext(argument0,argument1,argument2+3,argument3,argument4,argument5,argument6,argument7/8) 
draw_sprite_stretched_ext(argument0,argument1,argument2,argument3-3,argument4,argument5,argument6,argument7/8) 
draw_sprite_stretched_ext(argument0,argument1,argument2,argument3+3,argument4,argument5,argument6,argument7/8) 

//draw_sprite_ext(argument0,argument1+1,argument2,argument3,argument4,argument5,argument6,argument7,argument8) 

#define key
return keyboard_check_direct(argument0)

#define msg
global.debugmsglist+=argument0+"#"
//show_message(argument0)

#define keyc
return keyboard_check_pressed(argument0)

#define echo
PlayerHUD.debugmsg+="#"+string(argument0)+"#"

#define string_newline_to_hash
var h;
h=string_replace_all(argument0,'#',chr(35))
return string_replace_all(h,"\n",chr(10))

#define elpack_intro
return "
elpPack 0.1 (2024) - packs anything in .PACK file

LICENSE

This script pack can be used in all type of games, even commercial.
For using 'elPack' you need to mention 'elpoep' in your game menu/ending.

Full text of mention:
'elPack - by elpoep (elpoepgames.site)'


elpoep™ - designing of the old future

2018 - 2024 ©
"

#define elpack_add_file
///elpack_add_file(pack,fname)
//adds a file to package
//Check:
//      elpack_pack()
return ds_list_add(argument0,argument1)

#define elpack_add_dir
///elpack_add_file(pack,dir)
//adds a directory (without final backslash) to package
//Check:
//      elpack_pack()
var dir,f;dir=argument1;f=file_find_first(dir+'\*.*',0)
if f!='' {if filename_ext(string_lower(f))!='.pak' ds_list_add(argument0,dir+'\'+f);do{f=file_find_next();if filename_ext(string_lower(f))!='.pak' ds_list_add(argument0,dir+'\'+f)}until f='';}
return true

#define elpack_add_file_to_pack
///elpack_add_file_to_pack(pack,pack_name,fname)
//adds a file to existing package
//Check:
//      elpack_pack()
var b;b=buffer_create()
buffer_load(b,argument1)
buffer_write_string(b,filename_name(argument2))
buffer_write_string(b,string(file_size(argument2)))
p=buffer_create()
buffer_load(p,argument2)
buffer_copy(b,p)
buffer_destroy(p) 
return ds_list_add(argument0,argument2)

#define elpack_create
///elpack_create()
//Creates list where is the files to pack stored.
//Check:
//      elpack_add_file()
var myi;myi=round(random(1000));
global.__elPackage[myi]=ds_list_create();
return global.__elPackage[myi];

#define elpack_destroy
///elpack_destroy(list from elpack_unpack() )
var i,list;i=0;list=argument0
repeat(ds_list_size(list)){file_delete(ds_list_find_value(list,i)) i+=1}
ds_list_clear(list)
return true

#define elpack_pack
///elpack_pack(pack,dest_fname)
//packs a package into file name.
//Usage:
//      elpack_pack(my_list,working_directory+"\images.pack")
var pp,b,pack,fname;b=buffer_create();pack=argument0;fname=argument1;
/*pp=0;repeat(1000) {
if global.__elPackage[pp]=0
pp+=1
}*/
var p,i;
buffer_write_string(b,'PACK') show_debug_message('ELPACK: (package) Create '+string(fname))
i=0
repeat(ds_list_size(pack)){
buffer_write_string(b,filename_name(ds_list_find_value(pack,i))) show_debug_message('ELPACK: (package) Add '+string(filename_name(ds_list_find_value(pack,i))))
buffer_write_string(b,string(file_size(ds_list_find_value(pack,i))))
p=buffer_create()
buffer_load(p,ds_list_find_value(pack,i))
buffer_copy(b,p)
buffer_destroy(p) 
i+=1}
buffer_deflate(b)
buffer_save(b,filename_change_ext(fname,'.pak'))
buffer_destroy(b)
show_debug_message('ELPACK: (package) Success!')

#define elpack_unpack
///elpack_unpack(file,dest,create_list)
//Unpacks a .pack file in destination folder
//You can choose, create list with file names or not
//If you want to delete unpacked files when you want to end game, 
//set create_list to true and make script like this:
//    global.list=elpack_unpack('yourfile.pack','working_directory',1)
//on Game End:
//    elpack_destroy(global.list)
var filee,dest,crli;
filee=argument0;dest=argument1;crli=argument2
if !directory_exists(dest) directory_create(dest)
if crli {var list;list=ds_list_create()}
var b,p;
if file_exists(filee){
b=buffer_create()
buffer_load(b,filee)
buffer_inflate(b)
buffer_set_pos(b,5)
do {
p=buffer_create()
myfilename=buffer_read_string(b)
mylen=real(string_digits(buffer_read_string(b)))
repeat(mylen) {
buffer_write_u8(p,buffer_read_u8(b))
}
buffer_save(p,dest+'\'+myfilename)
buffer_destroy(p)
if crli ds_list_add(list,dest+'\'+myfilename)
} until buffer_at_end(b)
}
if crli return list
return 1

#define DUMTexLoad
var tex,tex1,realtex;
tex=string(argument0) 
if !file_exists(tex) return -1
tex1=string_replace(tex,".dtf",".bmp")
file_rename(tex,tex1)
realtex=sprite_add(tex1,0,0,0,0,0)
file_rename(tex1,tex)
return realtex;

#define DUMTexLoadStrip
if !file_exists("data\tex\"+string(argument0)) return -1
var tex,tex1,realtex;
tex="data\tex\"+string(argument0)
tex1=string_replace(tex,".dtf",".bmp")
file_rename(tex,tex1)
realtex=sprite_add(tex1,argument1,0,0,0,0)
file_rename(tex1,tex)
return realtex;

#define DUMTexLoadStripOld
if !file_exists("data\tex\"+string(argument0)) return -1
var tex,tex1,realtex,success;
tex="data\tex\"+string(argument0)
tex1=string_replace(tex,".dtf",".bmp")
file_rename(tex,tex1)
realtex=background_add(tex1,0,0)
success=false
i=0
repeat(argument1) {
if i*argument2>background_get_width(realtex) success=true
SPRITE_STRIP[i]=tile_add(realtex,i*argument2,0,argument2,argument3,0,0,0)
i+=1
}
file_rename(tex1,tex)
return success

#define DUMTargetInit
///(maxspd,spdmulti)
i=0 repeat(4) {
xspd[i]=0
yspd[i]=0
i+=1
}
global.shakecam=0
//xspd=0
//yspd=0

myInst=-1
gotMyInst=0

maxspd=argument0
__multi=argument1
__target_dir=0

z=1

active=1
run=0
dir=0
transdir=0
jumped=1
zspeed=0
zground=0
canwalk=0
ttt=-123123
wkey=INPUT_WKEY
akey=INPUT_AKEY
skey=INPUT_SKEY
dkey=INPUT_DKEY
ekey=INPUT_EKEY
//jkey=global.__spck


#define DUMTargetGravity
//Old collisions. Use if you want levitate

/*globalvar __playInst;__playInst=id                      //player instance as a global var
with SOLID_OBJECTS {                                    //check collisions
if __playInst.z+__playInst.zspeed+10>z2                 //if player z    > z2 of a solid
or __playInst.z+__playInst.zspeed+50<z1 {               //or player z+50 < z1 of a solid 
solid=0
} else {
if !place_meeting(x,y,__playInst) {solid=1} else {
solid=0
if __playInst.z+__playInst.zspeed<z1-40 __playInst.zspeed=0 else __playInst.zground=z2
if __playInst.z+__playInst.zspeed+10>=z2 {
if __playInst.z=__playInst.zground n=1 else
__playInst.zground=z2
} else {
if __playInst.z+10+__playInst.zspeed>z2 __playInst.zspeed=0
}
}
}
}*/



/*
if !place_meeting(x,y,__dum_solidobj) {
if place_meeting(x,y,__dum_floorobj) {
if z>=THEFLOOR.z2 zground=THEFLOOR.z2 else zground=-10000
} else zground=-10000
}*/

if z>zground zspeed-=argument0
if z+zspeed<=zground {
zspeed=0 
z=zground
if jumped jumped=0
}
z+=zspeed

#define DUM3dGravityOBJNew

//IDK, maybe this works.


/*global.meobj=object_index
with SOLID_OBJECTS {
if global.meobj.z>z2-2.5 or global.meobj.z<z1-10 solid=0 else {
if !place_meeting(x,y,global.meobj) {solid=1} else {if global.meobj.z<z1 global.meobj.zspeed=0 else global.meobj.z=z2}
}


}


if !place_meeting(x,y,SOLID_OBJECTS) and !place_meeting(x,y,LadderH) and !place_meeting(x,y,platformUPDOWN){
if place_meeting(x,y,THEFLOOR) {
if z>=THEFLOOR.z2-4 zground=THEFLOOR.z2 else zground=-10000
} else zground=-10000
}

if z+zspeed<=zground {
zspeed=0 
z=zground
}
zspeed-=real(argument0)
z+=zspeed

#define DUMTargetControl
//UP
if key(wkey) and active {
xspd[0]+=__multi
yspd[0]+=__multi
if place_free(x+lengthdir_x(xspd[0],__target_dir),y) x+=lengthdir_x(xspd[0],__target_dir)
if place_free(x,y+lengthdir_y(yspd[0],__target_dir)) y+=lengthdir_y(yspd[0],__target_dir)
} else {
xspd[0]-=__multi
yspd[0]-=__multi
if place_free(x+lengthdir_x(xspd[0],__target_dir),y) x+=lengthdir_x(xspd[0],__target_dir)
if place_free(x,y+lengthdir_y(yspd[0],__target_dir)) y+=lengthdir_y(yspd[0],__target_dir)
}
//RIGHT
if key(akey) and active {
xspd[1]+=__multi
yspd[1]+=__multi
if place_free(x+lengthdir_x(xspd[1],__target_dir+90),y) x+=lengthdir_x(xspd[1],__target_dir+90)
if place_free(x,y+lengthdir_y(yspd[1],__target_dir+90)) y+=lengthdir_y(yspd[1],__target_dir+90)
} else {
xspd[1]-=__multi
yspd[1]-=__multi
if place_free(x+lengthdir_x(xspd[1],__target_dir+90),y) x+=lengthdir_x(xspd[1],__target_dir+90)
if place_free(x,y+lengthdir_y(yspd[1],__target_dir+90)) y+=lengthdir_y(yspd[1],__target_dir+90)
}

//DOWN
if key(skey) and active {
xspd[2]+=__multi
yspd[2]+=__multi
if place_free(x+lengthdir_x(xspd[2],__target_dir+180),y) x+=lengthdir_x(xspd[2],__target_dir+180)
if place_free(x,y+lengthdir_y(yspd[2],__target_dir+180)) y+=lengthdir_y(yspd[2],__target_dir+180)
} else {
xspd[2]-=__multi
yspd[2]-=__multi
if place_free(x+lengthdir_x(xspd[2],__target_dir+180),y) x+=lengthdir_x(xspd[2],__target_dir+180)
if place_free(x,y+lengthdir_y(yspd[2],__target_dir+180)) y+=lengthdir_y(yspd[2],__target_dir+180)
}

//LEFT
if key(dkey) and active {
xspd[3]+=__multi
yspd[3]+=__multi
if place_free(x+lengthdir_x(xspd[3],__target_dir+270),y) x+=lengthdir_x(xspd[3],__target_dir+270)
if place_free(x,y+lengthdir_y(yspd[3],__target_dir+270)) y+=lengthdir_y(yspd[3],__target_dir+270)
} else {
xspd[3]-=__multi
yspd[3]-=__multi
if place_free(x+lengthdir_x(xspd[3],__target_dir+270),y) x+=lengthdir_x(xspd[3],__target_dir+270)
if place_free(x,y+lengthdir_y(yspd[3],__target_dir+270)) y+=lengthdir_y(yspd[3],__target_dir+270)
}

i=0
repeat(4) {
xspd[i]=clamp(xspd[i],0,maxspd+run*2+jumped*2)
yspd[i]=clamp(yspd[i],0,(maxspd+run*2+jumped*2)*0.75)
i+=1
}


#define DUMTargetWalkSimple
spd=4
if key(wkey) {
if yspd>-maxspd yspd-=__multi else yspd=-maxspd
}
if key(akey) {
if xspd>-maxspd xspd-=__multi else xspd=-maxspd
}
if key(skey) {
if yspd<maxspd yspd+=__multi else yspd=maxspd
}
if key(dkey) {
if xspd<maxspd xspd+=__multi else xspd=maxspd
}

if !key(wkey) and !key(skey) {
if yspd>0 yspd-=__multi else {if yspd<0 yspd+=__multi else yspd=0}
}

if !key(akey) and !key(dkey) {
if xspd>0 xspd-=0.25 else {if xspd<0 xspd+=0.25 else xspd=0}
}

//BACK
if key(wkey) {
if place_free(x+lengthdir_x(maxspd+run*2,__target_dir),y) x+=lengthdir_x(maxspd+run*2,__target_dir)
if place_free(x,y+lengthdir_y(maxspd+run*2,__target_dir)) y+=lengthdir_y(maxspd+run*2,__target_dir)
}
//RIGHT
if key(akey) {
if place_free(x+lengthdir_x(maxspd+run*2,__target_dir+90),y) x+=lengthdir_x(maxspd+run*2,__target_dir+90)
if place_free(x,y+lengthdir_y(maxspd+run*2,__target_dir+90)) y+=lengthdir_y(maxspd+run*2,__target_dir+90)
}

//GO
if key(skey) {
if place_free(x+lengthdir_x(maxspd+run*2,__target_dir+180),y) x+=lengthdir_x(maxspd+run*2,__target_dir+180)
if place_free(x,y+lengthdir_y(maxspd+run*2,__target_dir+180)) y+=lengthdir_y(maxspd+run*2,__target_dir+180)
}

//LEFT
if key(dkey) {
if place_free(x+lengthdir_x(maxspd+run*2,__target_dir+270),y) x+=lengthdir_x(maxspd+run*2,__target_dir+270)
if place_free(x,y+lengthdir_y(maxspd+run*2,__target_dir+270)) y+=lengthdir_y(maxspd+run*2,__target_dir+270)
}

#define DUMTargetSetRotation
///(dir)
__target_dir=argument0

#define DUMTargetGetSpeed
///(target)
return max(xspd[0],xspd[1],xspd[2],xspd[3])

#define DUMTerrainInit
///RETURNS MODEL (file,color_file,texture_background)
//VERY SLOW AND DOESNT WORK!!!!!!!!! DONT USE IT!!!!!!!!!!


fname = argument0;
cfname = argument1;
global.terrain=-1
global.PolyTer=128
global._terrainFT = background_get_texture(argument2);
//spr = sprite_add(fname,0,0,0,0,0);
draw_clear_alpha(c_black,1);
draw_sprite_stretched(spr,0,0,0,global.PolyTer,global.PolyTer);
show_debug_message("Starting model heights...");

global.txs = room_width/global.PolyTer;
global.tys = room_height/global.PolyTer;

// the big 'for' loop (this may take a while!!!!)
for (y1 = 0; y1 <= global.PolyTer+1; y1 += 1)
{
for (x1 = 0; x1 <= global.PolyTer+1; x1 += 1)
{
global.ter1[x1,y1] = color_get_value(draw_getpixel(x1,y1))/2;
}
}
//sprite_delete(spr);
show_debug_message("End model heights.");


//spr = sprite_add(cfname,0,0,0,0,0);
draw_clear_alpha(c_black,1);
draw_sprite_stretched(spr,0,0,0,global.PolyTer,global.PolyTer);

show_debug_message("Starting model colours...");

// the second big 'for' loop (this may take a while!!!!)
for (y1 = 0; y1 <= global.PolyTer+1; y1 += 1)
{
for (x1 = 0; x1 <= global.PolyTer+1; x1 += 1)
{
global.ter2[x1,y1] = draw_getpixel(x1,y1);
}
}
sprite_delete(spr);
show_debug_message("End model colours.");



// Turn the data into a model
var i,ii;

i = global.txs;
ii = global.tys;

show_debug_message("Starting model creation");

if (variable_global_exists("terrain"))
{
d3d_model_clear(global.terrain);
}
else
{
global.terrain = d3d_model_create();
}

var m,z1,z2,z3,z4,rx,ry,nx,ny,nz;
m = global.terrain;


for (y1 = 0; y1 < global.PolyTer; y1 += 1)
{
for (x1 = 0; x1 < global.PolyTer; x1 += 1)
{

z1 = global.ter1[x1,y1];
z2 = global.ter1[x1+1,y1];
z3 = global.ter1[x1+1,y1+1];
z4 = global.ter1[x1,y1+1];

rx = point_direction(0,z1,global.txs,z2);
ry = point_direction(0,z1,global.tys,z4);

nx = lengthdir_x(1,rx);
ny = lengthdir_x(1,ry);
nz = 1;

d3d_model_primitive_begin(m,pr_trianglefan);
d3d_model_vertex_normal_texture_color(m, x1*i, y1*ii, global.ter1[x1,y1],nx,ny,nz,x1,y1, global.ter2[x1,y1], 1);
d3d_model_vertex_normal_texture_color(m, (x1+1)*i, y1*ii, global.ter1[x1+1,y1],nx,ny,nz,x1+1,y1, global.ter2[x1+1,y1], 1);
d3d_model_vertex_normal_texture_color(m, (x1+1)*i, (y1+1)*ii, global.ter1[x1+1,y1+1],nx,ny,nz,x1+1,y1+1, global.ter2[x1+1,y1+1], 1);
d3d_model_vertex_normal_texture_color(m, x1*i, (y1+1)*ii, global.ter1[x1,y1+1],nx,ny,nz,x1,y1+1, global.ter2[x1,y1+1], 1);
d3d_model_primitive_end(m);
}
}
d3d_model_primitive_end(m);
show_debug_message("End model creation");

return m;

#define DUMClearBG
background_alpha[0]=argument1
background_color=argument0

#define DUMFontLoad
///DUMFontLoad(fname,font,size,bolditalic)
//usage: global.myfont=DUMFontLoad('myfont.fnt')

var file1,file2,out,b,it,size;
size=argument2
b=clamp(argument3,0,1)
if argument3>1 it=1 else it=0
file1=argument0
file2=string_replace(argument0,'.fnt','.ttf')
file_rename(file1,file2)
out=font_add_file(file2,argument1,size,b,it,0,255)
file_rename(file2,file1)
return out;

#define DUMInit
/*
                    DUM ENGINE
                    Build of 18.07.2024
                    by elpoep
                    
                    A simple 3D engine for making games
                        -having its own PACKAGE (.pack) loader (elpack)
                        -menu maker ( .DUI saver/loader included )
                        -font, texture, audio loader
                        -simple functions
                        
                        
                    For .D3D objects converted from .OBJ, make sure you've exported
                    your .OBJ model with "Up Axis: Z, Front axis: Y" parameters.
                    Otherwise, It will be drawn not the way as you wanted.
*/




//GLOBAL VARIABLES

    // FROM PARAMETERS
       global._DUM_audio=DUMAudioEnable
       global._DUM_nosfx=0
       global._DUM_normalfog=0
       global._DUM_directxversion=9
       global._44455566667777888889999990000111=0
       

       var re;
       re=0
       repeat parameter_count()
       {
        if parameter_string(re)="-noaudio" global._DUM_audio=0
        if parameter_string(re)="-nosfx" global._DUM_nosfx=1
        if parameter_string(re)="-cheats" global._44455566667777888889999990000111=1 //sorry :/
        msg(string(parameter_string(re)))
        re+=1
       }

    //WINDOW 
        global._DUM_WindowWidth=DUMWindowWidth
        global._DUM_WindowHeight=DUMWindowHeight
        
        
        global._DUM_Fullscreen=DUMFullscreenAtStart
        global._DUM_SwitchFullscreen=DUMAllowSwitchFScreen

        if DUMAdaptViewport=1 {
        if global._DUM_WindowWidth!=display_get_width()
        global._DUM_WindowWidth=display_get_width()
        
        if global._DUM_WindowHeight!=display_get_height()
        global._DUM_WindowHeight=display_get_height()
        
                i=0 repeat(1000) {
                        if room_exists(i) 
                            room_set_view(i,0,1,0,0,
                            display_get_width(),display_get_height(),
                            0,0,display_get_width(),display_get_height(),0,0,0,0,-1) 
                            
                        i+=1
                            }
                            //d3d_set_viewport(0,0,display_get_width(),display_get_height())
                        //application_surface_enable(undefined)
                    }
    
    //CAMERA
        global._DUM_CameraWidth=global._DUM_WindowWidth
        global._DUM_CameraHeight=global._DUM_WindowHeight
        global._DUM_FOV=DUMFOV
        
        if DUMFullscreenAtStart window_set_fullscreen(1)
        
        
        
        
        
    //OTHER
        global.debugmsglist="DUM ENGINE V"+string(DUMEngineVersion)+"#BY ELPOEP"
        global.DUMsensitivity=1
       
       globalvar __dum_default_camera_dist;
       __dum_default_camera_dist=128;
       
       //globalvar __dum_target;__dum_target=-1;
       globalvar __dum_solidobj;__dum_solidobj=-1; // set solid object parent with DUMSetSolidObject()
    
    
    
    

        

        
// Init keys
    DUMKeyInit()

//FILE CHECK

//SOUNDS

if directory_exists(working_directory+"\input\") {
var i;
snd[0]=file_find_first(working_directory+"\input\*.wav",fa_directory)
if snd[0]="" nothing=1 else {
file_rename(working_directory+"\input\"+snd[0],working_directory+"\data\snd\"+string_replace(snd[0],".wav",".dsf"))
msg('CONVERT input\ TO data\snd\ THE snd[0]')
i=1
repeat(1000) {
snd[i]=file_find_next()
if snd[i]="" nothing=1 else {
file_rename(working_directory+"\input\"+snd[i],working_directory+"\data\snd\"+string_replace(snd[i],".wav",".dsf"))
msg('CONVERT input\ TO data\snd\ THE snd['+string(i)+']')
}
i+=1
}
}
file_find_close()

//MODELS

file[0]=file_find_first(working_directory+"\input\*.d3d",fa_directory)
if file[0]="" nothing=1 else {
file_rename(working_directory+"\input\"+file[0],working_directory+"\data\obj\"+string_replace(file[0],".d3d",".dof"))
msg('CONVERT input\ TO data\obj\ THE file[0]')
i=1
repeat(1000) {
file[i]=file_find_next()
if file[i]="" nothing=1 else {
file_rename(working_directory+"\input\"+file[i],working_directory+"\data\obj\"+string_replace(file[i],".d3d",".dof"))
msg('CONVERT input\ TO data\obj\ THE file['+string(i)+']')
}
i+=1
}
}
file_find_close()

//TEXTURES

tex[0]=file_find_first(working_directory+"\input\*.bmp",fa_directory)
if tex[0]="" nothing=1 else {
file_rename(working_directory+"\input\"+tex[0],working_directory+"\data\tex\"+string_replace(tex[0],".bmp",".dtf"))
msg('CONVERT input\ TO data\tex\ THE tex[0]')
i=1
repeat(1000) {
tex[i]=file_find_next()
if tex[i]="" nothing=1 else {
file_rename(working_directory+"\input\"+tex[i],working_directory+"\data\tex\"+string_replace(tex[i],".bmp",".dtf"))
msg('CONVERT input\ TO data\tex\ THE tex['+string(i)+']')
}
i+=1
}
}
file_find_close()

font[0]=file_find_first(working_directory+"\input\*.ttf",fa_directory)
if font[0]="" nothing=1 else {
file_rename(working_directory+"\input\"+font[0],working_directory+"\data\fnt\"+string_replace(font[0],".ttf",".fnt"))
msg('CONVERT input\ TO data\fnt\ THE font[0]')
i=1
repeat(1000) {
font[i]=file_find_next()
if font[i]="" nothing=1 else {
file_rename(working_directory+"\input\"+font[i],working_directory+"\data\fnt\"+string_replace(font[i],".ttf",".fnt"))
msg('CONVERT input\ TO data\fnt\ THE font['+string(i)+']')
}
i+=1
}
}
file_find_close()
}

#define DUMKeyInit
globalvar 
INPUT_AKEY,INPUT_KKEY,INPUT_UKEY,
INPUT_BKEY,INPUT_LKEY,INPUT_VKEY,
INPUT_CKEY,INPUT_MKEY,INPUT_WKEY,
INPUT_DKEY,INPUT_NKEY,INPUT_XKEY,
INPUT_EKEY,INPUT_OKEY,INPUT_YKEY,
INPUT_FKEY,INPUT_PKEY,INPUT_ZKEY,
INPUT_GKEY,INPUT_QKEY,INPUT_0KEY,
INPUT_HKEY,INPUT_RKEY,INPUT_1KEY,
INPUT_IKEY,INPUT_SKEY,INPUT_2KEY,
INPUT_JKEY,INPUT_TKEY
;

INPUT_AKEY=ord('A')
INPUT_BKEY=ord('B')
INPUT_CKEY=ord('C')
INPUT_DKEY=ord('D')
INPUT_EKEY=ord('E')
INPUT_FKEY=ord('F')
INPUT_GKEY=ord('G')
INPUT_HKEY=ord('H')
INPUT_IKEY=ord('I')
INPUT_JKEY=ord('J')
INPUT_KKEY=ord('K')
INPUT_LKEY=ord('L')
INPUT_MKEY=ord('M')
INPUT_NKEY=ord('N')
INPUT_OKEY=ord('O')
INPUT_PKEY=ord('P')
INPUT_QKEY=ord('Q')
INPUT_RKEY=ord('R')
INPUT_SKEY=ord('S')
INPUT_TKEY=ord('T')
INPUT_UKEY=ord('U')
INPUT_VKEY=ord('V')
INPUT_WKEY=ord('W')
INPUT_XKEY=ord('X')
INPUT_YKEY=ord('Y')
INPUT_ZKEY=ord('Z')
INPUT_0KEY=ord('0')
INPUT_1KEY=ord('1')
INPUT_2KEY=ord('2')

#define DUMMenuLoad
if !file_exists(argument0) {show_error('NO MENU FILE '+string(argument0),1) return -1 exit}


me=instance_create(0,0,menuLoader)
if instance_exists(me) {
with me {
file=file_text_open_read(argument0)
mx=real(file_text_read_string(file))
file_text_readln(file)
my=real(file_text_read_string(file))
file_text_readln(file)
font=real(file_text_read_string(file))
file_text_readln(file)
yh=real(file_text_read_string(file))
file_text_readln(file)
repeats=real(file_text_read_string(file))
file_text_readln(file)
i=0
repeat(repeats){
option[i]=file_text_read_string(file)
file_text_readln(file)
command[i]=file_text_read_string(file)
file_text_readln(file)
i+=1
}
file_text_close(file)
}
}

#define DUMMenuSave
if file_exists(argument0) file_delete(argument0)

file=file_text_open_write(argument0)
file_text_write_string(file,string(mx))
file_text_writeln(file)
file_text_write_string(file,string(my))
file_text_writeln(file)
file_text_write_string(file,string(font))
file_text_writeln(file)
file_text_write_string(file,string(yh))
file_text_writeln(file)
file_text_write_string(file,string(repeats))
file_text_writeln(file)
i=0 repeat(repeats) {
file_text_write_string(file,string(option[i]))
file_text_writeln(file)
file_text_write_string(file,string(command[i]))
file_text_writeln(file)
i+=1
}
file_text_close(file)

#define DUMPointDist3D
//return point_distance_3d(argument0,argument1,argument2,argument3,argument4,argument5)
return point_distance(argument0,argument1,argument3,argument4)+(max(argument2,argument5)-min(argument2,argument5))


#define DUMPointInRect
///point_in_rectangle(px,py,x1,y1,x2,y2)
var px,py,x1,y1,x2,y2;
px=argument0 py=argument1 x1=argument2 y1=argument3 x2=argument4 y2=argument5
return px>x1 and py>y1 and px<x2 and py<y2

#define DUMRotate
///rotate(dir,destdir,turnspeed)
//dir= current direction, destdir= desired direction, turnspeed= rotation speed
//returns rotated direction

var tur_dir,destdir,turnspeed,dir;
tur_dir=argument0;
destdir=argument1;
turnspeed=argument2;
        

if(tur_dir>359){tur_dir=0}
if(tur_dir<0){tur_dir=359}
dir=destdir-tur_dir
if(dir>180){dir=-(360-dir)}
if(dir<-180){dir=360+dir}

if(sqrt(sqr(dir))<=turnspeed)
{tur_dir+=dir;}
else
{tur_dir+=sign(dir)*turnspeed}
        
return tur_dir;

#define DUMSetBlColAl
draw_set_blend_mode(argument0)
draw_set_color(argument1)
draw_set_alpha(argument2)

#define DUMSetFog
///DUMSetFog(enable,col,start,end)



//DUMClearBG(c_black,0.1)

//Old fog method.
//d3d_set_fog(argument0,argument1,argument2,argument3)

//NEWEST
d3d_set_fog_ext(fog_vertex,argument1,argument2,argument3)

draw_set_color(argument1)
if global._DUM_normalfog=0 d3d_draw_ellipsoid(x-argument3,y-argument3,z-argument3,x+argument3,y+argument3,z+argument3,-1,0,0,50)
draw_set_color(c_white)

#define DUMStrCut
///(str,pos,len,write_to)
argument3=string_copy(argument0,argument1,argument2)
argument0=string_delete(argument0,argument1,argument2)

#define DUMStrEndsWith
var __l;
__l=string_length(argument1)
return string_copy(argument0,string_length(argument0)-__l+1,__l)==argument1

#define DUMStrExt
var hello;hello=0
if argument_count==1 return string(argument0)
else if argument_count<1 show_error('string_ext() - no arguments given.',0) else {
var h;h=string(argument0)
repeat(argument_count-1) {
h=string_replace_all(h,"{"+string(hello)+"}",string(argument[hello+1]))
hello+=1
}
return h;
}


#define DUMStrStartsWith
var __l;
__l=string_length(argument1)
return string_copy(argument0,1,__l)==argument1

#define Q_crandom
///Q_crandom(num)
return 2.0 * ( Q_Random( argument0 ) - 0.5 );

#define Q_Rand
///Q_Rand(seed)
return (69069*argument0+1)

#define Q_Random
///Q_Random(num)
return ( Q_Rand( argument0 ) & $ffff ) / $100000

#define d3d_draw_block_normal
///d3d_draw_block_normal(x1,y1,z1,x2,y2,z2,tex1,tex2,tex3,tex4,tex5,hrepeat,vrepeat)
var x1,y1,z1,x2,y2,z2,tex1,tex2,tex3,tex4,tex5,tex6,hr,vr;
x1=argument0
y1=argument1
z1=argument2
x2=argument3
y2=argument4
z2=argument5
tex1=argument6
tex2=argument7
tex3=argument8
tex4=argument9
tex5=argument10
tex6=argument11
hr=argument12
vr=argument13

d3d_draw_wall(x1,y1,z1,x2,y1,z2,tex1,hr,vr)
d3d_draw_wall(x1,y1,z1,x1,y2,z2,tex2,hr,vr)
d3d_draw_wall(x2,y1,z1,x2,y2,z2,tex3,hr,vr)
d3d_draw_wall(x1,y2,z2,x2,y2,z2,tex4,hr,vr)
d3d_draw_floor(x1,y1,z1,x2,y2,z1,tex5,hr,vr)
d3d_draw_floor(x1,y1,z2,x2,y2,z2,tex6,hr,vr)

#define d3d_load_model
modelload[0]=0
modelload[1]=0

var flipnormals,fliptex,cur_milisec;
flipnormals=1
if(argument2)flipnormals=-1
fliptex=argument3
scale=argument4
cur_milisec=current_time
modelload[0]=0

if(string_count(".d3d",argument1)>0)d3d_model_load(argument0,argument1);
if(string_count(".dof",argument1)>0)d3d_model_load(argument0,argument1);
if(string_count(".mod",argument1)>0)d3d_model_load(argument0,argument1);

if(string_count(".vtx",argument1)>0) 
    {
    var str,file,row,data,i,tex_y,temp,t;
    file=file_text_open_read(argument1);
    data=ds_list_create();
    row=""
    do
        {
        if!(string_count(".Vertex",row)=1)
            {
            do {row=file_text_read_string(file);file_text_readln(file)}
            until string_count(".Vertex",row)=1
            }
    
        do
            {
            row=file_text_read_string(file);file_text_readln(file)
            if(string_count("// end of .Vertex",row)=0)
                {
                str=string_copy(row,1,string_pos(" ",row)-1)
                row=string_delete(row,1,string_pos(" ",row)-1)
                ds_list_add(data,real(str))
                repeat((3-1)+3+(2-1))
                    {
                    row=string_delete(row,1,1)
                    str=string_copy(row,1,string_pos(" ",row)-1)
                    row=string_delete(row,1,string_pos(" ",row)-1)
                    ds_list_add(data,real(str))
                    }
                row=string_delete(row,1,1)
                str=string_copy(row,1,string_length(row))
                ds_list_add(data,real(str))
                }
            }
        until string_count("// end of .Vertex",row)=1

        do {row=file_text_read_string(file);file_text_readln(file)}
        until string_count(".Index",row)=1

        do
            {
            d3d_model_primitive_begin(argument0,pr_trianglelist)
            
            row=file_text_read_string(file);file_text_readln(file)
            
            if(string_count("// end if .Index",row)=0)
                {
                t=0
                repeat(3)
                    {
                    str=string_copy(row,1,string_pos(" ",row)-1)
                    row=string_delete(row,1,string_pos(" ",row))
                    temp[t]=real(str)
                    t+=1
                    }
                t=2
                repeat(3)
                    {
                    i=temp[t]*8
                    tex_y=ds_list_find_value(data,i+7)
                    if(fliptex)tex_y=1-tex_y
                    
                    d3d_model_vertex_normal_texture(argument0,ds_list_find_value(data,i+0)*scale,ds_list_find_value(data,i+1)*scale,ds_list_find_value(data,i+2)*scale
                                                            ,flipnormals*ds_list_find_value(data,i+3),flipnormals*ds_list_find_value(data,i+4),flipnormals*ds_list_find_value(data,i+5)
                                                            ,ds_list_find_value(data,i+6),tex_y);modelload[0]+=1;
                    t-=1
                    }
                d3d_model_primitive_end(argument0)
                d3d_model_primitive_begin(argument0,pr_trianglelist)
                }
            }
        until string_count("// end if .Index",row)=1

        d3d_model_primitive_end(argument0)
        ds_list_clear(data);
    
        do {row=file_text_read_string(file);file_text_readln(file)}
        until string_count("// end of .Brdf",row)=1
        do {row=file_text_read_string(file);file_text_readln(file)}
        until string_count(".Vertex",row)=1||string_count("// End of file",row)=1
        }
    until string_count("// End of file",row)=1||file_text_eof(file)
    file_text_close(file);
    ds_list_destroy(data);
    }
    
if(string_count(".obj",argument1)>0) 
    {
    var str,file,row,tex_y,v_x,v_y,v_z,n_x,n_y,n_z,u,v,i,numb,edges,faces,t,p_count;
    file=file_text_open_read(argument1);
    v_x=ds_list_create();ds_list_add(v_x,0);
    v_y=ds_list_create();ds_list_add(v_y,0);
    v_z=ds_list_create();ds_list_add(v_z,0);
    n_x=ds_list_create();ds_list_add(n_x,0);
    n_y=ds_list_create();ds_list_add(n_y,0);
    n_z=ds_list_create();ds_list_add(n_z,0);
    u=ds_list_create();ds_list_add(u,0);
    v=ds_list_create();ds_list_add(v,0);
    row=""
    
    do
        {
        if(string_count("v ",row)=0)
           {
           do {row=file_text_read_string(file);file_text_readln(file)}
           until string_char_at(row,1)="v"&&string_char_at(row,2)=" "
           }
    
        do 
            {
            row=string_delete(row,1,string_pos(" ",row));
            str=string_copy(row,1,string_pos(" ",row)-1); 
            row=string_delete(row,1,string_pos(" ",row));
            ds_list_add(v_x,real(str));
            str=string_copy(row,1,string_pos(" ",row)-1) 
            row=string_delete(row,1,string_pos(" ",row));
            ds_list_add(v_y,real(str));
            str=string_copy(row,1,string_length(row)) 
            ds_list_add(v_z,real(str));
            row=file_text_read_string(file);file_text_readln(file)
            }
        until string_count("v ",row)=0
        
        do {row=file_text_read_string(file);file_text_readln(file)}
        until (string_char_at(row,1)="v"&&string_char_at(row,2)="n")||(string_char_at(row,1)="v"&&string_char_at(row,2)="t")||(string_char_at(row,1)="f"&&string_char_at(row,2)=" ")

        if(string_count("vn ",row)=1)
            {
            do 
                {
                row=string_delete(row,1,string_pos(" ",row));
                str=string_copy(row,1,string_pos(" ",row)-1); 
                row=string_delete(row,1,string_pos(" ",row));
                ds_list_add(n_x,real(str));
                str=string_copy(row,1,string_pos(" ",row)-1) 
                row=string_delete(row,1,string_pos(" ",row));
                ds_list_add(n_y,real(str));
                str=string_copy(row,1,string_length(row)) 
                ds_list_add(n_z,real(str)); 
                row=file_text_read_string(file);file_text_readln(file) 
                }
            until string_count("vn ",row)=0
            }
                
        if(string_count("vt ",row)=0)
           {
            do {row=file_text_read_string(file);file_text_readln(file)}
            until (string_char_at(row,1)="v"&&string_char_at(row,2)="t")||(string_char_at(row,1)="f"&&string_char_at(row,2)=" ")
            }
        
        if(string_count("vt ",row)=1)
            {
            do 
                {
                row=string_delete(row,1,string_pos(" ",row));
                str=string_copy(row,1,string_pos(" ",row)-1); 
                row=string_delete(row,1,string_pos(" ",row));
                ds_list_add(u,real(str));
                str=string_copy(row,1,string_length(row)) 
                ds_list_add(v,real(str));
                row=file_text_read_string(file);file_text_readln(file) 
                }
            until string_count("vt ",row)=0
            }
        if(string_count("f ",row)=0)
           {
           do {row=file_text_read_string(file);file_text_readln(file)}
           until (string_char_at(row,1)="f"&&string_char_at(row,2)=" ")
           }
 
  
        pos=0
        do
            {
            d3d_model_primitive_begin(argument0,pr_trianglelist)
            
            row=string_delete(row,1,string_pos(" ",row));
            row=string_replace_all(row,"//","/0/");
            
            str=string_copy(row,1,string_pos(" ",row)-1); 
            p_count=string_count("/",str)
            if(p_count!=2)row=string_replace_all(row," ","/0 ");
            
            if(string_char_at(row,string_length(row))=" ")row=string_copy(row,1,string_length(row)-1)
            
            edges=string_count(" ",row)+1
            for(t=0;t<edges;t+=1)
                {
                str=string_copy(row,1,string_pos("/",row)-1); 
                row=string_delete(row,1,string_pos("/",row));
                faces[t,0]=real(str);

                str=string_copy(row,1,string_pos("/",row)-1); 
                row=string_delete(row,1,string_pos("/",row));
                faces[t,1]=real(str);

            if!(t=edges-1)
                {
                str=string_copy(row,1,string_pos(" ",row)-1); 
                row=string_delete(row,1,string_pos(" ",row));
                }
                else str=string_copy(row,1,string_length(row)); 
            faces[t,2]=real(str);
            }
            //build faces
            if(edges<=3)
                {
                for(t=0;t<edges;t+=1)
                    {
                    tex_y=ds_list_find_value(v,faces[t,1])
                    if(fliptex)tex_y=1-tex_y
                    //show_error(string(ds_list_find_value(v_x,faces[t,0]))+";"+string(ds_list_find_value(v_y,faces[t,0]))+";"+string(ds_list_find_value(v_z,faces[t,0]))+";",false)
                    d3d_model_vertex_normal_texture(argument0,ds_list_find_value(v_x,faces[t,0])*scale,ds_list_find_value(v_y,faces[t,0])*scale,ds_list_find_value(v_z,faces[t,0])*scale
                                                         ,flipnormals*ds_list_find_value(n_x,faces[t,2]),flipnormals*ds_list_find_value(n_y,faces[t,2]),flipnormals*ds_list_find_value(n_z,faces[t,2])
                                                         ,ds_list_find_value(u,faces[t,1]),tex_y);modelload[0]+=1;
                    }
                }
            else
                {

                for(t=2;t<edges;t+=1)
                    {
                    tex_y=ds_list_find_value(v,faces[0,1])
                    if(fliptex)tex_y=1-tex_y
                    d3d_model_vertex_normal_texture(argument0,ds_list_find_value(v_x,faces[0,0])*scale,ds_list_find_value(v_y,faces[0,0])*scale,ds_list_find_value(v_z,faces[0,0])*scale,flipnormals*ds_list_find_value(n_x,faces[0,2]),flipnormals*ds_list_find_value(n_y,faces[0,2]),flipnormals*ds_list_find_value(n_z,faces[0,2]),ds_list_find_value(u,faces[0,1]),tex_y);modelload[0]+=1;
                    tex_y=ds_list_find_value(v,faces[t-1,1])
                    if(fliptex)tex_y=1-tex_y
                    d3d_model_vertex_normal_texture(argument0,ds_list_find_value(v_x,faces[t-1,0])*scale,ds_list_find_value(v_y,faces[t-1,0])*scale,ds_list_find_value(v_z,faces[t-1,0])*scale,flipnormals*ds_list_find_value(n_x,faces[t-1,2]),flipnormals*ds_list_find_value(n_y,faces[t-1,2]),flipnormals*ds_list_find_value(n_z,faces[t-1,2]),ds_list_find_value(u,faces[t-1,1]),tex_y);modelload[0]+=1;
                    tex_y=ds_list_find_value(v,faces[t,1])
                    if(fliptex)tex_y=1-tex_y
                    d3d_model_vertex_normal_texture(argument0,ds_list_find_value(v_x,faces[t,0])*scale,ds_list_find_value(v_y,faces[t,0])*scale,ds_list_find_value(v_z,faces[t,0])*scale,flipnormals*ds_list_find_value(n_x,faces[t,2]),flipnormals*ds_list_find_value(n_y,faces[t,2]),flipnormals*ds_list_find_value(n_z,faces[t,2]),ds_list_find_value(u,faces[t,1]),tex_y);modelload[0]+=1;
                    }
                }
            d3d_model_primitive_end(argument0)
            d3d_model_primitive_begin(argument0,pr_trianglelist)   

            row=file_text_read_string(file);file_text_readln(file)
            if(string_count("f ",row)=0)
                {
                do {row=file_text_read_string(file);file_text_readln(file)}
                until (string_char_at(row,1)="f"&&string_char_at(row,2)=" ")||(string_char_at(row,1)="v"&&string_char_at(row,2)=" ")||file_text_eof(file);
                }
            }
        until string_count("f ",row)=0 
        
        d3d_model_primitive_end(argument0)
        while !(string_count("v ",row)=1||file_text_eof(file)) {row=file_text_read_string(file);file_text_readln(file)}
        }
    until file_text_eof(file);
           
    file_text_close(file);
    ds_list_destroy(v_x);ds_list_destroy(v_y);ds_list_destroy(v_z);
    ds_list_destroy(n_x);ds_list_destroy(n_y);ds_list_destroy(n_z);
    ds_list_destroy(u);ds_list_destroy(v);
    }

if(string_count(".x",argument1)>0) 
    {
    var str,file,row,tex_y,v_x,v_y,v_z,n_x,n_y,n_z,u,v,i,numb_faces,edges,faces,t,p_count;
    file=file_text_open_read(argument1);
    v_x=ds_list_create();
    v_y=ds_list_create();
    v_z=ds_list_create();    
    n_x=ds_list_create();
    n_y=ds_list_create();
    n_z=ds_list_create();
    u=ds_list_create();
    v=ds_list_create();
    row=""
    
    do
        {
        if!(string_count("Mesh {",row)=1)
            {
            do {row=file_text_read_string(file);file_text_readln(file)}
            until string_count("Mesh {",row)=1
            }
        row=file_text_read_string(file);file_text_readln(file);//don't read numb of vertexes    
        do
            {
            row=file_text_read_string(file);file_text_readln(file)

                row=string_replace_all(row," ","")
            
                str=string_copy(row,1,string_pos(";",row)-1)
                row=string_delete(row,1,string_pos(";",row))
                ds_list_add(v_x,real(str))
                str=string_copy(row,1,string_pos(";",row)-1)
                row=string_delete(row,1,string_pos(";",row))
                ds_list_add(v_y,real(str))
                str=string_copy(row,1,string_pos(";",row)-1)
                row=string_delete(row,1,string_pos(";",row))
                ds_list_add(v_z,real(str))
                

            }
        until string_count(";",row)=1
        
        row=file_text_read_string(file);file_text_readln(file);
        numb_faces=real(string_digits(row))
        t=0
        do
            {
            row2=file_text_read_string(file);file_text_readln(file)

                row=string_replace_all(row2," ","")
                row=string_replace_all(row,";;",",;;")
                
                str=string_copy(row,1,string_pos(";",row)-1)
                row=string_delete(row,1,string_pos(";",row))
                faces[t,0]=real(str)
                for(i=1;i<=faces[t,0];i+=1)
                    {
                    str=string_copy(row,1,string_pos(",",row)-1)
                    row=string_delete(row,1,string_pos(",",row))
                    faces[t,i]=real(string_digits(str))
                    }
                t+=1
            }        
        until string_count(";;",row2)=1  
                   
        do {row=file_text_read_string(file);file_text_readln(file)}
        until string_count("MeshNormals {",row)=1
        
        row=file_text_read_string(file);file_text_readln(file);//don't read numb of normals
        
        do
            {
            row=file_text_read_string(file);file_text_readln(file)
                row=string_replace_all(row," ","")
            
                str=string_copy(row,1,string_pos(";",row)-1)
                row=string_delete(row,1,string_pos(";",row))
                ds_list_add(n_x,real(str))
                str=string_copy(row,1,string_pos(";",row)-1)
                row=string_delete(row,1,string_pos(";",row))
                ds_list_add(n_y,real(str))
                str=string_copy(row,1,string_pos(";",row)-1)
                row=string_delete(row,1,string_pos(";",row))
                ds_list_add(n_z,real(str))

            }
        until string_count(";",row)=1

        do {row=file_text_read_string(file);file_text_readln(file)}
        until string_count("MeshTextureCoords {",row)=1
        
        row=file_text_read_string(file);file_text_readln(file);//don't read numb of MeshTextureCoords 
        
        do
            {
            row=file_text_read_string(file);file_text_readln(file)

                row=string_replace_all(row," ","")
            
                str=string_copy(row,1,string_pos(";",row)-1)
                row=string_delete(row,1,string_pos(";",row))
                ds_list_add(u,real(str))
                str=string_copy(row,1,string_pos(";",row)-1)
                row=string_delete(row,1,string_pos(";",row))
                ds_list_add(v,real(str))

            }
        until string_count(";",row)=1
        
        for(i=0;i<numb_faces;i+=1)
            {
            d3d_model_primitive_begin(argument0,pr_trianglelist)
            t=1
            for(t=1;t<=faces[i,0];t+=1)
                {
                tex_y=ds_list_find_value(v,faces[i,t])
                if(fliptex)tex_y=1-tex_y
                //show_error(string(ds_list_find_value(v_x,faces[t,0]))+";"+string(ds_list_find_value(v_y,faces[t,0]))+";"+string(ds_list_find_value(v_z,faces[t,0]))+";",false)
                d3d_model_vertex_normal_texture(argument0,ds_list_find_value(v_x,faces[i,t])*scale,ds_list_find_value(v_y,faces[i,t])*scale,ds_list_find_value(v_z,faces[i,t])*scale
                                                        ,flipnormals*ds_list_find_value(n_x,faces[i,t]),flipnormals*ds_list_find_value(n_y,faces[i,t]),flipnormals*ds_list_find_value(n_z,faces[i,t])
                                                        ,ds_list_find_value(u,faces[i,t]),tex_y);modelload[0]+=1;
                }
            d3d_model_primitive_end(argument0)      
            }
        
        do {row=file_text_read_string(file);file_text_readln(file)}
        until string_count("Mesh {",row)=1||file_text_eof(file)
    
        ds_list_clear(v_x);ds_list_clear(v_y);ds_list_clear(v_z);
        ds_list_clear(n_x);ds_list_clear(n_y);ds_list_clear(n_z);
        ds_list_clear(u);ds_list_clear(v);
        }
    until file_text_eof(file)

    
    file_text_close(file);
    ds_list_destroy(v_x);ds_list_destroy(v_y);ds_list_destroy(v_z);
    ds_list_destroy(n_x);ds_list_destroy(n_y);ds_list_destroy(n_z);
    ds_list_destroy(u);ds_list_destroy(v);
    }
    
if(string_count(".c",argument1)>0) 
    {
    var str,file,row,tex_y,v_x,v_y,v_z,n_x,n_y,n_z,u,v,i,numb,edges,faces,t,p_count;
    file=file_text_open_read(argument1);
    v_x=ds_list_create();
    v_y=ds_list_create();
    v_z=ds_list_create();    
    n_x=ds_list_create();
    n_y=ds_list_create();
    n_z=ds_list_create();
    u=ds_list_create();
    v=ds_list_create();
    row=""
    
    do
        {
        if!(string_count("_coords[]",row)=1)
            {
            do {row=file_text_read_string(file);file_text_readln(file)}
            until string_count("_coords[]",row)=1
            }
        do
            {
            row=file_text_read_string(file);file_text_readln(file)
            if(string_count("};",row)=0)
                {
                row=string_replace_all(row," ","")
            
                str=string_copy(row,1,string_pos(",",row)-1)
                row=string_delete(row,1,string_pos(",",row))
                ds_list_add(v_x,real(str))
                str=string_copy(row,1,string_pos(",",row)-1)
                row=string_delete(row,1,string_pos(",",row))
                ds_list_add(v_y,real(str))
                str=string_copy(row,1,string_pos(",",row)-1)
                row=string_delete(row,1,string_pos(",",row))
                ds_list_add(v_z,real(str))
                }
            }
        until string_count("};",row)=1
    
        do {row=file_text_read_string(file);file_text_readln(file)}
        until string_count("_normals[]",row)=1
    
        do
            {
            row=file_text_read_string(file);file_text_readln(file)
            if(string_count("};",row)=0)
                {
                row=string_replace_all(row," ","")
            
                str=string_copy(row,1,string_pos(",",row)-1)
                row=string_delete(row,1,string_pos(",",row))
                ds_list_add(n_x,real(str))
                str=string_copy(row,1,string_pos(",",row)-1)
                row=string_delete(row,1,string_pos(",",row))
                ds_list_add(n_y,real(str))
                str=string_copy(row,1,string_pos(",",row)-1)
                row=string_delete(row,1,string_pos(",",row))
                ds_list_add(n_z,real(str))
                }
            }
        until string_count("};",row)=1
    
        do {row=file_text_read_string(file);file_text_readln(file)}
        until string_count("_texcoords[]",row)=1
    
        do
            {
            row=file_text_read_string(file);file_text_readln(file)
            if(string_count("};",row)=0)
                {
                row=string_replace_all(row," ","")
            
                str=string_copy(row,1,string_pos(",",row)-1)
                row=string_delete(row,1,string_pos(",",row))
                ds_list_add(u,real(str))
                str=string_copy(row,1,string_pos(",",row)-1)
                row=string_delete(row,1,string_pos(",",row))
                ds_list_add(v,real(str))
                }
            }
        until string_count("};",row)=1
 
        do {row=file_text_read_string(file);file_text_readln(file)}
        until string_count("_indices[]",row)=1
    
        do
            {
            d3d_model_primitive_begin(argument0,pr_trianglelist)
            row=file_text_read_string(file);file_text_readln(file)
            if(string_count("};",row)=0)
                {
                row=string_replace_all(row," ","")
            
                str=string_copy(row,1,string_pos(",",row)-1)
                row=string_delete(row,1,string_pos(",",row))
                faces[0]=real(str)
                str=string_copy(row,1,string_pos(",",row)-1)
                row=string_delete(row,1,string_pos(",",row))
                faces[1]=real(str)
                str=string_copy(row,1,string_pos(",",row)-1)
                row=string_delete(row,1,string_pos(",",row))
                faces[2]=real(str)
                i=0
                repeat(3)
                    {
                    tex_y=ds_list_find_value(v,faces[i])
                    if(fliptex)tex_y=1-tex_y
                    d3d_model_vertex_normal_texture(argument0,ds_list_find_value(v_x,faces[i])*scale,ds_list_find_value(v_y,faces[i])*scale,ds_list_find_value(v_z,faces[i])*scale
                                                            ,flipnormals*ds_list_find_value(n_x,faces[i]),flipnormals*ds_list_find_value(n_y,faces[i]),flipnormals*ds_list_find_value(n_z,faces[i])
                                                            ,ds_list_find_value(u,faces[i]),tex_y);modelload[0]+=1;
                    i+=1    
                    }
                }
            d3d_model_primitive_end(argument0)
            }
        until string_count("};",row)=1
    
        do {row=file_text_read_string(file);file_text_readln(file)}
        until string_count("_coords[]",row)=1||string_count("// End of file",row)=1
    
        ds_list_clear(v_x);ds_list_clear(v_y);ds_list_clear(v_z);
        ds_list_clear(n_x);ds_list_clear(n_y);ds_list_clear(n_z);
        ds_list_clear(u);ds_list_clear(v);
        }
    until string_count("// End of file",row)=1||file_text_eof(file)

    
    file_text_close(file);
    ds_list_destroy(v_x);ds_list_destroy(v_y);ds_list_destroy(v_z);
    ds_list_destroy(n_x);ds_list_destroy(n_y);ds_list_destroy(n_z);
    ds_list_destroy(u);ds_list_destroy(v);
    }
    
if(string_count(".asc",argument1)>0) 
    {
    var str,file,row,tex_y,v_x,v_y,v_z,i,numb,edges,faces,t,p_count;
    file=file_text_open_read(argument1);
    v_x=ds_list_create();
    v_y=ds_list_create();
    v_z=ds_list_create();    
    row=""
    
    do
        {
        if(string_count("Vertex list:",row)=0)
            {
            do {row=file_text_read_string(file);file_text_readln(file)}
            until string_count("Vertex list:",row)=1
            }
        
        do
            {
            row=file_text_read_string(file);file_text_readln(file)
            if(string_count("Face list:",row)=0)
                {
                row=string_delete(row,1,string_pos(":",row))
                row=string_delete(row,1,string_pos(":",row))
                row=string_replace_all(row," ","")
                row=string_replace_all(row,"Y","")
                row=string_replace_all(row,"Z","")
                row+=":"
                str=string_copy(row,1,string_pos(":",row)-1)
                row=string_delete(row,1,string_pos(":",row))
                ds_list_add(v_x,real(str))
                str=string_copy(row,1,string_pos(":",row)-1)
                row=string_delete(row,1,string_pos(":",row))
                ds_list_add(v_y,real(str))
                str=string_copy(row,1,string_pos(":",row)-1)
                row=string_delete(row,1,string_pos(":",row))
                ds_list_add(v_z,real(str))
                }
            }
        until string_count("Face list:",row)=1
        
        do
            {
            row2=file_text_read_string(file);file_text_readln(file)
            if(string_count("Face",row2)=1)
                {
                d3d_model_primitive_begin(argument0,pr_trianglelist)
                row=string_delete(row2,1,string_pos("A:",row2)+1)
                row=string_copy(row,1,string_pos("AB",row)-1)
                row=string_replace_all(row," ","")
                row=string_replace_all(row,"B","")
                row=string_replace_all(row,"C","")
                row+=":"
                
                str=string_copy(row,1,string_pos(":",row)-1)
                row=string_delete(row,1,string_pos(":",row))
                t=real(str)
                d3d_model_vertex(argument0,ds_list_find_value(v_x,t)*scale,ds_list_find_value(v_y,t)*scale,ds_list_find_value(v_z,t)*scale)modelload[0]+=1;
                str=string_copy(row,1,string_pos(":",row)-1)
                row=string_delete(row,1,string_pos(":",row))
                t=real(str)
                d3d_model_vertex(argument0,ds_list_find_value(v_x,t)*scale,ds_list_find_value(v_y,t)*scale,ds_list_find_value(v_z,t)*scale)modelload[0]+=1;
                str=string_copy(row,1,string_pos(":",row)-1)
                row=string_delete(row,1,string_pos(":",row))
                t=real(str)
                d3d_model_vertex(argument0,ds_list_find_value(v_x,t)*scale,ds_list_find_value(v_y,t)*scale,ds_list_find_value(v_z,t)*scale)modelload[0]+=1;
                d3d_model_primitive_end(argument0)
                }
            }
        until (string_count("Face",row2)=0&&string_count("Smoothing",row2)=0)||file_text_eof(file)
        
        while !(string_count("Vertex list:",row)=1||file_text_eof(file)){row=file_text_read_string(file);file_text_readln(file)}
        ds_list_clear(v_x);ds_list_clear(v_y);ds_list_clear(v_z);
        }
    until file_text_eof(file) 
    
    ds_list_destroy(v_x);ds_list_destroy(v_y);ds_list_destroy(v_z);
    file_text_close(file);
    }    
modelload[1]=abs(current_time-cur_milisec)

#define DUMSetSolidObject
///(obj)
__dum_solidobj=argument0
return argument0

#define DUMDrawModel
///(model,x,y,z,tex,rotx,roty,rotz)
d3d_transform_set_identity()

d3d_transform_add_scaling(20,20,20)
d3d_transform_add_rotation_x(270+argument5)
d3d_transform_add_rotation_y(argument6)
d3d_transform_add_rotation_z(argument7)
d3d_transform_add_translation(argument1,argument2,argument3)

d3d_model_draw(argument0,0,0,0,argument4)
d3d_transform_set_identity()

#define DUMDrawModelExt
///(model,x,y,z,tex,rotx,roty,rotz,offsetx,offsety,offsetz,xscale,yscale,zscale)
d3d_transform_set_identity()

d3d_transform_add_scaling(20+argument11,20+argument12,20+argument13)

d3d_transform_add_rotation_x(argument5)
d3d_transform_add_rotation_y(argument6)
d3d_transform_add_rotation_z(argument7)
d3d_transform_add_translation(argument1,argument2,argument3)

d3d_model_draw(argument0,argument9/20,argument8/20,argument10/20,argument4)
d3d_transform_set_identity()

#define DUMFnameRemoveExt
return filename_change_ext(filename_name(argument0),"")

#define DUMDrawSkybox
///(sprite_stripped) sprite with 6 images

var t1,t2,t3,t4,t5,t6;
t1=sprite_get_texture(argument0,0)
t2=sprite_get_texture(argument0,1)
t3=sprite_get_texture(argument0,2)
t4=sprite_get_texture(argument0,3)
t5=sprite_get_texture(argument0,4)
t6=sprite_get_texture(argument0,5)

d3d_draw_floor(-10000,-10000,-10000,10000,10000,-10000,t1,1,1)
d3d_draw_floor(-10000,-10000,10000,10000,10000,10000,t2,1,1)

d3d_draw_wall(-10000,-10000,-10000,10000,-10000,10000,t3,1,1)
d3d_draw_wall(-10000,10000,-10000,10000,10000,10000,t4,1,1)
d3d_draw_wall(-10000,-10000,-10000,-10000,10000,10000,t5,1,1)
d3d_draw_wall(10000,-10000,-10000,10000,10000,10000,t5,1,1)


#define model_load
///(fname,flipnormals)
// MOSAIC Light 3D OBJ IMPORTER
// (c) 2006. Zoltan Percsich. All Rights Reserved.
// Don't edit this script

if !file_exists(argument0) {show_error('no obj named '+string(argument0)+".",1) return 0 exit}

filename=argument0;
flipnormals = 1;
if (argument1>0) flipnormals=-1;
vertex_list1=ds_list_create();ds_list_clear(vertex_list1);ds_list_add(vertex_list1,0);
vertex_list2=ds_list_create();ds_list_clear(vertex_list2);ds_list_add(vertex_list2,0);
vertex_list3=ds_list_create();ds_list_clear(vertex_list3);ds_list_add(vertex_list3,0);
normal_list1=ds_list_create();ds_list_clear(normal_list1);ds_list_add(normal_list1,0);
normal_list2=ds_list_create();ds_list_clear(normal_list2);ds_list_add(normal_list2,0);
normal_list3=ds_list_create();ds_list_clear(normal_list3);ds_list_add(normal_list3,0);
texture_list1=ds_list_create();ds_list_clear(texture_list1);ds_list_add(texture_list1,0);
texture_list2=ds_list_create();ds_list_clear(texture_list2);ds_list_add(texture_list2,0);
faces_list=ds_list_create();ds_list_clear(faces_list);
object_list=ds_list_create();ds_list_clear(object_list);
model_map=ds_map_create()
fp=file_text_open_read(filename);

var ii;ii=0
for (i=0;file_text_eof(fp)==false;i+=1) {

    row=file_text_read_string(fp);row=string_replace_all(row,"  "," ");
    
    if string_char_at(row,1)=="o" && string_char_at(row,2)==" " {
    ds_map_add(model_map,'objname'+string(ii),string_copy(row,3,64))
    ii+=1
    }
    
    if (string_char_at(row,1)=="v" && string_char_at(row,2)==" ") {
        row=string_delete(row,1,string_pos(" ",row));
        vx=real(string_copy(row,1,string_pos(" ",row)));
        row=string_delete(row,1,string_pos(" ",row));
        vy=real(string_copy(row,1,string_pos(" ",row)));
        row=string_delete(row,1,string_pos(" ",row));
        vz=real(string_copy(row,1,string_length(row)));
        ds_list_add(vertex_list1,vx);
        ds_list_add(vertex_list2,vy);
        ds_list_add(vertex_list3,vz);
    }
    
    if (string_char_at(row,1)=="v" && string_char_at(row,2)=="n") {
        row=string_delete(row,1,string_pos(" ",row));
        nx=real(string_copy(row,1,string_pos(" ",row)));
        row=string_delete(row,1,string_pos(" ",row));
        ny=real(string_copy(row,1,string_pos(" ",row)));
        row=string_delete(row,1,string_pos(" ",row));
        nz=real(string_copy(row,1,string_length(row)));
        ds_list_add(normal_list1,nx);
        ds_list_add(normal_list2,ny);
        ds_list_add(normal_list3,nz);
    }
    
    if (string_char_at(row,1)=="v" && string_char_at(row,2)=="t") {
        row=string_delete(row,1,string_pos(" ",row));
        tx=real(string_copy(row,1,string_pos(" ",row)));
        row=string_delete(row,1,string_pos(" ",row));
        ty=real(string_copy(row,1,string_length(row)));
        ds_list_add(texture_list1,tx);
        ds_list_add(texture_list2,ty);
    }
    
    if (string_char_at(row,1)=="f" && string_char_at(row,2)==" ") {
        row=string_replace_all(row,"  "," ");
        row=string_delete(row,1,string_pos(" ",row));
        if (string_char_at(row,string_length(row))==" ") row=string_copy(row,0,string_length(row)-1);
        face_num=string_count(" ",row);
        face_division=1;
        temp_faces[0]=0;
        
        for (fc=0;fc<face_num;fc+=1) {
            f=string_copy(row,1,string_pos(" ",row));
            row=string_delete(row,1,string_pos(" ",row));
            temp_faces[face_division]=f;
            face_division+=1;
        }
            
        f=string_copy(row,1,string_length(row));temp_faces[face_division]=f;
        if (face_division==3) {
            f1=temp_faces[2];
            f2=temp_faces[3];
            f3=temp_faces[1];
            ds_list_add(faces_list,f1);
            ds_list_add(faces_list,f2);
            ds_list_add(faces_list,f3);
        } else {
            f1=temp_faces[2];
            f2=temp_faces[3];
            f3=temp_faces[1];
            ds_list_add(faces_list,f1);
            ds_list_add(faces_list,f2);
            ds_list_add(faces_list,f3);
            for (t=0;t<face_division-3;t+=1) {
                f1=temp_faces[4+t];
                f2=temp_faces[1];
                f3=temp_faces[3+t];
                ds_list_add(faces_list,f1);
                ds_list_add(faces_list,f2);
                ds_list_add(faces_list,f3);
            }
        }
    } 
    
    file_text_readln(fp);          
}
file_text_close(fp);

var i;i=0
tm[i]=d3d_model_create();
tsn=0;
d3d_model_primitive_begin(tm,pr_trianglelist);       

for (fc=0;fc<ds_list_size(faces_list);fc+=1) {

    sub_face=ds_list_find_value(faces_list,fc);
    
    if string_count("o",sub_face)==1 {
    
    }
        
    if (string_count("/",sub_face)==0) {
        f_index=sub_face;
        t_index=-1;
        n_index=-1;
    }
    
    if (string_count("/",sub_face)==1) {
        f_index=string_copy(sub_face,1,string_pos("/",sub_face)-1);
        sub_face=string_delete(sub_face,1,string_pos("/",sub_face));
        t_index=string_copy(sub_face,1,string_length(sub_face));
        n_index=-1;
    }
    
    if (string_count("/",sub_face)==2 && string_count("//",sub_face)==0) {
        f_index=string_copy(sub_face,1,string_pos("/",sub_face)-1);
        sub_face= string_delete(sub_face,1,string_pos("/",sub_face));
        t_index=string_copy(sub_face,1,string_pos("/",sub_face)-1);
        sub_face= string_delete(sub_face,1,string_pos("/",sub_face));
        n_index=string_copy(sub_face,1,string_length(sub_face));
    }
    
    if (string_count("/",sub_face)==2 && string_count("//",sub_face)==1) {
        sub_face=string_replace(sub_face,"//","/");
        f_index=string_copy(sub_face,1,string_pos("/",sub_face)-1);
        sub_face= string_delete(sub_face,1,string_pos("/",sub_face));
        t_index=-1;
        n_index=string_copy(sub_face,1,string_length(sub_face));
    }
    
    vx=ds_list_find_value(vertex_list1,floor(real(f_index)));
    vy=ds_list_find_value(vertex_list2,floor(real(f_index)));
    vz=ds_list_find_value(vertex_list3,floor(real(f_index)));
    
    if (floor(real(n_index))!=-1 && ds_list_size(normal_list1)>=1) {
        nx=flipnormals*ds_list_find_value(normal_list1,floor(real(n_index)));
        ny=flipnormals*ds_list_find_value(normal_list2,floor(real(n_index)));
        nz=flipnormals*ds_list_find_value(normal_list3,floor(real(n_index)));
    } else {
        nx=0;
        ny=0;
        nz=0;
    }
    
    if (floor(real(t_index))!=-1 && ds_list_size(texture_list1)>=1) {
        tx=ds_list_find_value(texture_list1,floor(real(t_index)));
        ty=ds_list_find_value(texture_list2,floor(real(t_index)));
    } else {
        tx=0;
        ty=0;
    }
    d3d_model_vertex_normal_texture(tm[i],vx,vy,vz,nx,ny,nz,tx,ty);
    
    tsn+=1;
    if (tsn==999) {
        tsn=0;
        d3d_model_primitive_end(tm[i]);
        d3d_model_primitive_begin(tm[i],pr_trianglelist);
    }       
}

d3d_model_primitive_end(tm);
return tm;


#define DUMFileWrite
file_text_write_string(argument0,string(argument1))
file_text_writeln(argument0)

#define DUMOBJLoad
///(fname) returns ds_map

var fn;fn=string_lower(argument0)
fliptex=0
scale=1
flipnormals=0
if(string_count(".obj",fn)>0) 
    {
    var str,file,row,tex_y,v_x,v_y,v_z,n_x,n_y,n_z,u,v,i,numb,edges,faces,t,p_count;i=0
    repeat(64) {__model[i]=d3d_model_create() i+=1} i=0
    file=file_text_open_read(fn);
    v_x=ds_list_create();ds_list_add(v_x,0);
    v_y=ds_list_create();ds_list_add(v_y,0);
    v_z=ds_list_create();ds_list_add(v_z,0);
    n_x=ds_list_create();ds_list_add(n_x,0);
    n_y=ds_list_create();ds_list_add(n_y,0);
    n_z=ds_list_create();ds_list_add(n_z,0);
    u=ds_list_create();ds_list_add(u,0);
    v=ds_list_create();ds_list_add(v,0);
    row=""
    
    do
        {
        
        if string_count('o ',row)>0 i+=1
        
        if(string_count("v ",row)=0)
           {
           do {row=file_text_read_string(file);file_text_readln(file)}
           until string_char_at(row,1)="v"&&string_char_at(row,2)=" "
           }
    
        do 
            {
            row=string_delete(row,1,string_pos(" ",row));
            str=string_copy(row,1,string_pos(" ",row)-1); 
            row=string_delete(row,1,string_pos(" ",row));
            ds_list_add(v_x,real(str));
            str=string_copy(row,1,string_pos(" ",row)-1) 
            row=string_delete(row,1,string_pos(" ",row));
            ds_list_add(v_y,real(str));
            str=string_copy(row,1,string_length(row)) 
            ds_list_add(v_z,real(str));
            row=file_text_read_string(file);file_text_readln(file)
            }
        until string_count("v ",row)=0
        
        do {row=file_text_read_string(file);file_text_readln(file)}
        until (string_char_at(row,1)="v"&&string_char_at(row,2)="n")||(string_char_at(row,1)="v"&&string_char_at(row,2)="t")||(string_char_at(row,1)="f"&&string_char_at(row,2)=" ")

        if(string_count("vn ",row)=1)
            {
            do 
                {
                row=string_delete(row,1,string_pos(" ",row));
                str=string_copy(row,1,string_pos(" ",row)-1); 
                row=string_delete(row,1,string_pos(" ",row));
                ds_list_add(n_x,real(str));
                str=string_copy(row,1,string_pos(" ",row)-1) 
                row=string_delete(row,1,string_pos(" ",row));
                ds_list_add(n_y,real(str));
                str=string_copy(row,1,string_length(row)) 
                ds_list_add(n_z,real(str)); 
                row=file_text_read_string(file);file_text_readln(file) 
                }
            until string_count("vn ",row)=0
            }
                
        if(string_count("vt ",row)=0)
           {
            do {row=file_text_read_string(file);file_text_readln(file)}
            until (string_char_at(row,1)="v"&&string_char_at(row,2)="t")||(string_char_at(row,1)="f"&&string_char_at(row,2)=" ")
            }
        
        if(string_count("vt ",row)=1)
            {
            do 
                {
                row=string_delete(row,1,string_pos(" ",row));
                str=string_copy(row,1,string_pos(" ",row)-1); 
                row=string_delete(row,1,string_pos(" ",row));
                ds_list_add(u,real(str));
                str=string_copy(row,1,string_length(row)) 
                ds_list_add(v,real(str));
                row=file_text_read_string(file);file_text_readln(file) 
                }
            until string_count("vt ",row)=0
            }
        if(string_count("f ",row)=0)
           {
           do {row=file_text_read_string(file);file_text_readln(file)}
           until (string_char_at(row,1)="f"&&string_char_at(row,2)=" ")
           }
        
 
  
        pos=0
        do
            {
            d3d_model_primitive_begin(__model[i],pr_trianglelist)
            
            row=string_delete(row,1,string_pos(" ",row));
            row=string_replace_all(row,"//","/0/");
            
            str=string_copy(row,1,string_pos(" ",row)-1); 
            p_count=string_count("/",str)
            if(p_count!=2)row=string_replace_all(row," ","/0 ");
            
            if(string_char_at(row,string_length(row))=" ")row=string_copy(row,1,string_length(row)-1)
            
            edges=string_count(" ",row)+1
            for(t=0;t<edges;t+=1)
                {
                str=string_copy(row,1,string_pos("/",row)-1); 
                row=string_delete(row,1,string_pos("/",row));
                faces[t,0]=real(str);

                str=string_copy(row,1,string_pos("/",row)-1); 
                row=string_delete(row,1,string_pos("/",row));
                faces[t,1]=real(str);

            if!(t=edges-1)
                {
                str=string_copy(row,1,string_pos(" ",row)-1); 
                row=string_delete(row,1,string_pos(" ",row));
                }
                else str=string_copy(row,1,string_length(row)); 
            faces[t,2]=real(str);
            }
            //build faces
            if(edges<=3)
                {
                for(t=0;t<edges;t+=1)
                    {
                    tex_y=ds_list_find_value(v,faces[t,1])
                    if(fliptex)tex_y=1-tex_y
                    //show_error(string(ds_list_find_value(v_x,faces[t,0]))+";"+string(ds_list_find_value(v_y,faces[t,0]))+";"+string(ds_list_find_value(v_z,faces[t,0]))+";",false)
                    d3d_model_vertex_normal_texture(__model[i],ds_list_find_value(v_x,faces[t,0])*scale,ds_list_find_value(v_y,faces[t,0])*scale,ds_list_find_value(v_z,faces[t,0])*scale
                                                         ,flipnormals*ds_list_find_value(n_x,faces[t,2]),flipnormals*ds_list_find_value(n_y,faces[t,2]),flipnormals*ds_list_find_value(n_z,faces[t,2])
                                                         ,ds_list_find_value(u,faces[t,1]),tex_y);//modelload[0]+=1;
                    }
                }
            else
                {

                for(t=2;t<edges;t+=1)
                    {
                    tex_y=ds_list_find_value(v,faces[0,1])
                    if(fliptex)tex_y=1-tex_y
                    d3d_model_vertex_normal_texture(__model[i],ds_list_find_value(v_x,faces[0,0])*scale,ds_list_find_value(v_y,faces[0,0])*scale,ds_list_find_value(v_z,faces[0,0])*scale,flipnormals*ds_list_find_value(n_x,faces[0,2]),flipnormals*ds_list_find_value(n_y,faces[0,2]),flipnormals*ds_list_find_value(n_z,faces[0,2]),ds_list_find_value(u,faces[0,1]),tex_y);modelload[0]+=1;
                    tex_y=ds_list_find_value(v,faces[t-1,1])
                    if(fliptex)tex_y=1-tex_y
                    d3d_model_vertex_normal_texture(__model[i],ds_list_find_value(v_x,faces[t-1,0])*scale,ds_list_find_value(v_y,faces[t-1,0])*scale,ds_list_find_value(v_z,faces[t-1,0])*scale,flipnormals*ds_list_find_value(n_x,faces[t-1,2]),flipnormals*ds_list_find_value(n_y,faces[t-1,2]),flipnormals*ds_list_find_value(n_z,faces[t-1,2]),ds_list_find_value(u,faces[t-1,1]),tex_y);modelload[0]+=1;
                    tex_y=ds_list_find_value(v,faces[t,1])
                    if(fliptex)tex_y=1-tex_y
                    d3d_model_vertex_normal_texture(__model[i],ds_list_find_value(v_x,faces[t,0])*scale,ds_list_find_value(v_y,faces[t,0])*scale,ds_list_find_value(v_z,faces[t,0])*scale,flipnormals*ds_list_find_value(n_x,faces[t,2]),flipnormals*ds_list_find_value(n_y,faces[t,2]),flipnormals*ds_list_find_value(n_z,faces[t,2]),ds_list_find_value(u,faces[t,1]),tex_y);modelload[0]+=1;
                    }
                }
            d3d_model_primitive_end(__model[i])
            if 
            d3d_model_primitive_begin(__model[i],pr_trianglelist)   

            row=file_text_read_string(file);file_text_readln(file)
            if(string_count("f ",row)=0)
                {
                do {row=file_text_read_string(file);file_text_readln(file)}
                until (string_char_at(row,1)="f"&&string_char_at(row,2)=" ")||(string_char_at(row,1)="v"&&string_char_at(row,2)=" ")||file_text_eof(file);
                }
            }
        until string_count("f ",row)=0 
        
        d3d_model_primitive_end(__model[i])
        while !(string_count("v ",row)=1||file_text_eof(file)) {row=file_text_read_string(file);file_text_readln(file)}
        }
    until file_text_eof(file);
           
    file_text_close(file);
    ds_list_destroy(v_x);ds_list_destroy(v_y);ds_list_destroy(v_z);
    ds_list_destroy(n_x);ds_list_destroy(n_y);ds_list_destroy(n_z);
    ds_list_destroy(u);ds_list_destroy(v);
    }
    
var m;m=ds_map_create()
var ii;ii=0
repeat(i) {
ds_map_add(m,'model_'+string(ii),string(__model[ii]))
ii+=1
}
return m;

#define DUMModelLoad
///DUMModelLoad(fname)
//Loads .dof file (d3d object file)
//otherwise it will return failure (-1)
//example:
//mymodel=DUMModelLoad('car.dof');
//d3d_model_draw(mymodel,x,y,z,-1)
if !file_exists(string(argument0)) return -1

var model;
model=d3d_model_create_and_load(string(argument0))
d3d_model_bake(model)
return model;

#define DUMModelLoadExt
///(fname)
var m;m=d3d_model_create_and_load(argument0)
d3d_model_bake(m)
return m;

