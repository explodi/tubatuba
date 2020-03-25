
var cam_a = document.getElementById('cam_a');
var camera_elements=[document.getElementById('cam_a'),document.getElementById('cam_b')];
var current_element=0;
var seconds=0;
var camera_elements_loading=[]
for(let i=0;i<camera_elements.length;i++) {
    camera_elements[i].onload = function (e) {
        img_loading=false;	
        console.log("cam load",current_element)
        console.log(e)
        camera_elements[current_element].style.opacity=0.1;
        camera_elements[current_element].style.zIndex=9999;
        camera_elements_loading[current_element]=false;
        current_element=current_element+1;
        if(current_element>1) current_element=0;
        camera_elements[current_element].style.zIndex=9998;
        camera_elements[current_element].style.opacity=0;

    };
    camera_elements[i].onerror = function (e) {
        img_loading=false;	
        console.log("cam load error")
        console.log(e);
        camera_elements_loading[current_element]=false;

    };
    camera_elements[i].style.opacity=0;
    camera_elements_loading.push(false);
}
function refresh_jpeg() {
    seconds=seconds+1;

    if(live_video==false&&camera_elements_loading[current_element]==false) {
        console.log("[loading]",current_element);    
        camera_elements_loading[current_element]=true;
        camera_elements[current_element].src="/security_cameras/feed?u="+Math.random()*10000;
        

    }
}
refresh_jpeg();
