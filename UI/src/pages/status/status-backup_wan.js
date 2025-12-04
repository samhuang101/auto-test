	page_tag='status-backup_wan'
	lang_tag="status_backup_wan"
	$(document).ready(function(){
		$.lang_load(lang_tag);
		page_initial();
	});

	function set_dialog_init(diagdata) {
                var conn_st, ip_proto;

                if (typeof(diagdata) == 'undefined') {
                        close_dialog();
                        return;
                }

                conn_st = diagdata.ConnectStatus;
                ip_proto = diagdata.IpProtocolType;
				if (conn_st == "connectedNotActive") {
					conn_st = "Connected but not activated";
				}
				else if (conn_st == "disconnected") {
					conn_st = "Not connected";
				}
				else{
					conn_st = "Activated and primary WAN is disconnected";
				}

                $('.el-dialog__title').text(diagdata.ConnectionName);
                $('#conn_name_diag').text(diagdata.ConnectionName);
                $('#type_diag').text(diagdata.Type);
                $('#status_diag').text(conn_st);
                $('#ipaddress_diag').text("");
                $('#pd_diag').text("");
                $('#gateway_diag').text("");
                $('#dns1_diag').text("");
                $('#dns2_diag').text("");
                $('#prefix_diag').text("");
                $('#mask_diag').text("");
				
				if ("bridge" == diagdata.Type){
					$(".wan-bridge-hide").hide()
				}else{
					$(".wan-bridge-hide").show()
				}
				
                if (conn_st != "Not connected") {
					$('#ipaddress_diag').text(diagdata.IpAddress);
					$('#pd_diag').text(diagdata.PdAddress);
					$('#gateway_diag').text(diagdata.Gateway);
					$('#dns1_diag').text(diagdata.Dns1);
					$('#dns2_diag').text(diagdata.Dns2);

					if (ip_proto == "ipv6")
						$('#prefix_diag').text(diagdata.PrefixLen);
					else
						$('#mask_diag').text(diagdata.Netmask);
                }

		if (ip_proto == "ipv6") {
                        $('#mask_div').css('display',"none");
                        $('#prefix_div').css('display',"");
                        $('#pd_div').css('display',"");
                }
                else {
                        $('#mask_div').css('display',"");
                        $('#prefix_div').css('display',"none");
                        $('#pd_div').css('display',"none");
                }
        }


	function scrolled(block,I) {
		var val = I.scrollLeft;

		$('#'+block+'_header').scrollLeft(val);
	}

	function get_info_success_cb(obj) {
		INFO_DATA = API.obj.copy(obj);
		DIALOG_DATA = API.obj.copy(INFO_DATA.BackupWanStatus.Ipv4[0]);
		set_dialog_init(DIALOG_DATA);
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