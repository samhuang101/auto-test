	page_tag='application-storage-samba'
	lang_tag='application_storage_samba'
	$(document).ready(function(){
		$.lang_load(lang_tag);
		page_initial()
	}); 
		
	function get_obj_success_cb(obj) { 
		ORIGINAL_OBJ_DATA = API.obj.copy(obj); 
		MODIFIED_OBJ_DATA = API.obj.copy(ORIGINAL_OBJ_DATA); 
		
		switcher_handler('samba_enable',MODIFIED_OBJ_DATA.Samba.SambaP.Enable,"")
		
	} 
	function get_obj_error_cb(obj) { 
		
	} 
	function get_obj_data(obj_list){ 
		API.obj.get(obj_list, get_obj_success_cb, get_obj_error_cb); 
	} 

	function get_info_success_cb(obj) {
		if(obj.api_return != 0){
			get_info_error_cb(obj)
			return;
		}
		
		if (typeof(obj.StorageInfo) != 'object' || obj.StorageInfo == null || Object.keys(obj.StorageInfo).length === 0){
			warning_control('on','page',L.error_message.lang_storage_notfound_msg)
			$("#apply").hide()
		}else{
			$("#apply").show()
		}
		
		get_obj_data(OBJ_LIST) 
	} 
	function get_info_error_cb(obj) {
				
	}
	
	function get_storage_status(info){
		API.info.get(info, get_info_success_cb, get_info_error_cb);
	}

	function page_initial(){
		//Coding initial function here
		warning_control('off','page')
		get_storage_status(INFO_LIST) 
	} 
	
	function set_obj_success_cb(obj) {
		if(obj.api_return != 0){
			set_obj_error_cb(obj)
			return;
		}

		setTimeout(function () {
			loading_control(0);
			page_initial()
		},2000);
	}
	function set_obj_error_cb(obj) {
		$("#loader").hide()
		if(obj.api_return == 403){
			logout('sto')
			return;
		}else{
			setTimeout(function () {
				loading_control(0);
				page_initial()
			},2000);
		}
	}
	function set_obj_data(obj_content){
		if(typeof(obj_content) == 'string')
			API.obj.set(JSON.parse(obj_content), set_obj_success_cb, set_obj_error_cb);
		else if(typeof(obj_content) == 'object')
			API.obj.set(obj_content, set_obj_success_cb, set_obj_error_cb);
	}
	function page_save(){
		loading_control(1);

		MODIFIED_OBJ_DATA.Samba.SambaP.Enable=$("#samba_enable").val()
		
		set_obj_data(MODIFIED_OBJ_DATA)
	}