page_tag='status-cellular'
lang_tag="status_cellular"
$(document).ready(function(){
	$.lang_load(lang_tag);
	page_initial();
});

function layout(data){
	if (data.USIMStatus === "Ready") {
		$(".connection_show").show();
	} else {
		$(".connection_show").hide();
	}

	$.each(data, function(info_index, info_content) {
		if (info_index === "USIMStatus" && data.USIMStatus === "UnKnown") {
			$("#"+info_index).html("Not inserted")
		} else {
			$("#"+info_index).html(info_content)
		}
	});
}

function get_info_success_cb(obj) {
	INFO_DATA = API.obj.copy(obj);
	layout(INFO_DATA.CellularInfo)
	loading_control(0);
}
function get_info_error_cb(obj) {
	loading_control(0);
	if(obj.api_return == 403) {
		logout('sto');
	}
} 
function get_info_data(info_list){ 
	API.info.get(info_list, get_info_success_cb, get_info_error_cb); 
} 
function page_initial(){
	//Coding initial function here
	loading_control(1);
	get_info_data(INFO_LIST) 
} 
