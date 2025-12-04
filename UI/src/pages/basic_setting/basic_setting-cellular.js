	page_tag='basic_setting-cellular'
	lang_tag='basic_setting_cellular'
	$(document).ready(function(){
		$.lang_load(lang_tag);
		page_initial()
	}); 

	var LOADING_TIME = 30000

	function loading_wait(){
		var process_percentage = 0
		var bar_timer
		var intervalTimes = LOADING_TIME/100

		$("#loading_message").html(L.common.lang_plz_wait+"<br/>0%")

		bar_timer = setInterval(function(){
			process_percentage = process_percentage + 1
			$("#loading_message").html(L.common.lang_plz_wait+"<br/>"+process_percentage+"%")
			if( 100 == process_percentage ){
				clearInterval(bar_timer)
				loading_control(0);
			}
		},intervalTimes);
	}

	function limit_rate(){
		var dl_val = $("#dl_limit").val();
		var up_val = $("#up_limit").val();
		if (dl_val < 0 || dl_val > 204800){
			warning_control('on','global',L.basic_setting_cellular.lang_dl_limit_error)
			return false;
		} else if(up_val < 0 || up_val > 204800) {
			warning_control('on','global',L.basic_setting_cellular.lang_up_limit_error)
			return false;
		}else{
			MODIFIED_OBJ_DATA.Cellular.CellularP.UPRateLimit = up_val
			MODIFIED_OBJ_DATA.Cellular.CellularP.DLRateLimit = dl_val
			return true;
		}
	}

	function select_authentication(type) {
		if(typeof(type)=="undefined")
			type = MODIFIED_OBJ_DATA.Cellular.CellularP.Auth = $("#auth").val()
		else
			MODIFIED_OBJ_DATA.Cellular.CellularP.Auth = type

		$("#auth").val(type)
	}

	function select_network_mode(mode){
		if(typeof(mode)=="undefined")
			mode = MODIFIED_OBJ_DATA.Cellular.CellularP.NetworkMode = $("#network_mode").val()
		else
			MODIFIED_OBJ_DATA.Cellular.CellularP.NetworkMode = mode

		$("#network_mode").val(mode)
	}

	function switch_radio(obj, flag){
		if (obj.id == "auto_apn") {
			$(".apn_type_show").hide();
			MODIFIED_OBJ_DATA.Cellular.CellularP.APNMode = "auto"
		} else if (obj.id == "manual_apn") {
			$(".apn_type_show").show();
			MODIFIED_OBJ_DATA.Cellular.CellularP.APNMode = "manual"
		} else {
			$(".apn_type_show").hide();
			MODIFIED_OBJ_DATA.Cellular.CellularP.APNMode = "auto"
		}

	}

	function switch_apn_mode(mode){
		if (mode == "auto") {
			$("#auto_apn").prop("checked", true)
			$("#manual_apn").prop("checked", false)
			switch_radio($("#auto_apn")[0])
		} if (mode == "manual") {
			$("#manual_apn").prop("checked", true)
			$("#auto_apn").prop("checked", false)
			switch_radio($("#manual_apn")[0])
		} else {
			$("#auto_apn").prop("checked", true)
			$("#manual_apn").prop("checked", false)
			switch_radio($("#auto_apn")[0])
		}
	}

	function switch_toggle(id, val) {
		if(typeof(val) == "undefined" || val == "2"){  // val: 2 is from GUI trigger
			val = $('#'+id).val()
		}

		if(val == "1"){
			if(id=="auto_connect"){
				MODIFIED_OBJ_DATA.Cellular.CellularP.AutoConnectEnabled = "1";
			}
			if(id=="roaming"){
				MODIFIED_OBJ_DATA.Cellular.CellularP.RoamingEnabled = "1";
			}
		} else {
			if(id=="auto_connect"){
				MODIFIED_OBJ_DATA.Cellular.CellularP.AutoConnectEnabled = "0";
			}
			if(id=="roaming"){
				MODIFIED_OBJ_DATA.Cellular.CellularP.RoamingEnabled = "0";
			}
		}

		switcher_handler(id,val)
	}

	function layout_init(obj){

		if (obj.Cellular.CellularP.AutoConnectEnabled == "1")
			switcher_handler('auto_connect', obj.Cellular.CellularP.AutoConnectEnabled, 'switch_toggle(\'auto_connect\',\'1\')');
		else
			switcher_handler('auto_connect', obj.Cellular.CellularP.AutoConnectEnabled, 'switch_toggle(\'auto_connect\',\'0\')');

		if (obj.Cellular.CellularP.RoamingEnabled == "1")
			switcher_handler('roaming', obj.Cellular.CellularP.RoamingEnabled, 'switch_toggle(\'roaming\',\'1\')');
		else
			switcher_handler('roaming', obj.Cellular.CellularP.RoamingEnabled, 'switch_toggle(\'roaming\',\'0\')');

		select_network_mode(obj.Cellular.CellularP.NetworkMode)

		$("#dl_limit").val(obj.Cellular.CellularP.DLRateLimit)
		$("#up_limit").val(obj.Cellular.CellularP.UPRateLimit)
		$("#usage_limit").val(obj.Cellular.CellularP.DLUsageLimit)
		$("#usage_dl_limit").val(obj.Cellular.CellularP.UsageDownloadLimit)
		$("#usage_up_limit").val(obj.Cellular.CellularP.UsageUploadLimit)
		$("#pdp_type").val(obj.Cellular.CellularP.PDPType)
		$("#apn").val(obj.Cellular.CellularP.APN)


		switch_apn_mode(obj.Cellular.CellularP.APNMode)
		select_authentication(obj.Cellular.CellularP.Auth)

		$("#username").val(obj.Cellular.CellularP.Username)
		$("#password").val(obj.Cellular.CellularP.Password)
		set_trafficcontrol_status()
	}
	
	function get_obj_success_cb(obj) { 
		ORIGINAL_OBJ_DATA = API.obj.copy(obj); 
		MODIFIED_OBJ_DATA = API.obj.copy(ORIGINAL_OBJ_DATA);
		layout_init(ORIGINAL_OBJ_DATA)
	} 
	function get_obj_error_cb(obj) { 
		
	} 
	function get_obj_data(obj_list){ 
		API.obj.get(obj_list, get_obj_success_cb, get_obj_error_cb); 
	} 
	function page_initial(){
		//Coding initial function here
		get_info_data(INFO_LIST) 
	}

	function page_save(){
		if (! limit_rate()){
			return;
		}

		MODIFIED_OBJ_DATA.Cellular.CellularP.NetworkMode = $("#network_mode").val();
		MODIFIED_OBJ_DATA.Cellular.CellularP.PDPType = $("#pdp_type").val();
		MODIFIED_OBJ_DATA.Cellular.CellularP.APN = $("#apn").val();
		MODIFIED_OBJ_DATA.Cellular.CellularP.Auth = $("#auth").val();
		MODIFIED_OBJ_DATA.Cellular.CellularP.Username = $("#username").val();
		MODIFIED_OBJ_DATA.Cellular.CellularP.Password = $("#password").val();
		MODIFIED_OBJ_DATA.Cellular.CellularP.DLUsageLimit = $("#usage_limit").val();
		MODIFIED_OBJ_DATA.Cellular.CellularP.UsageDownloadLimit = $("#usage_dl_limit").val();
		MODIFIED_OBJ_DATA.Cellular.CellularP.UsageUploadLimit = $("#usage_up_limit").val();
		warning_control('off','global')
		loading_control(1)
		set_obj_data(MODIFIED_OBJ_DATA)
	}
	function set_obj_success_cb(obj) {
		loading_wait()
	}
	function set_obj_error_cb(obj) {
		loading_control(0);
		if(obj.api_return == 403){
			logout('sto')
			return;
		}else{
			pop_alert_message(L.common.lang_error_msg,'error')
		}
		//show_alert(L.common.fail_title, L.common.save_fail)
	}
	function set_obj_data(obj_content){
		if(typeof(obj_content) == 'string')
			API.obj.set(JSON.parse(obj_content), set_obj_success_cb, set_obj_error_cb);
		else if(typeof(obj_content) == 'object')
			API.obj.set(obj_content, set_obj_success_cb, set_obj_error_cb);
	}

	function get_info_data(info_list){ 
		API.info.get(info_list, get_info_success_cb, get_info_error_cb); 
	} 

	function get_info_success_cb(obj) {
		INFO_DATA = API.obj.copy(obj);
		get_obj_data(OBJ_LIST)

	}	function get_info_error_cb(obj) {
		if(obj.api_return == 403) {
			logout('sto');
		}
	} 
	function set_trafficcontrol_status() {
		// Get the value of the client update switch
		var st = INFO_DATA.CellularInfo.TrafficControl
		// If the client update switch is set to "0", disable NTP server inputs
		if (st == "1") {
			$('#up_limit').prop('disabled', true).addClass('is-disabled');
			$('#up_limit').parent('.el-input').addClass('is-disabled');
			$('#dl_limit ').attr("disabled", true);
			$('#dl_limit ').parent('div.el-input').addClass("is-disabled");
		}
		// Otherwise, enable NTP server inputs
		else {
			$('#up_limit').prop('disabled', false).removeClass('is-disabled');
			$('#up_limit').parent('.el-input').removeClass('is-disabled');
			$('#dl_limit').removeAttr("disabled");
			$('#dl_limit').parent('div.el-input').removeClass("is-disabled");
		}
	}
