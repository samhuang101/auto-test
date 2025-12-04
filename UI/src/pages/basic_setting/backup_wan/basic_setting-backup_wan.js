page_tag='basic_setting_backup_wan'
SELECTED_CHECK_MODE = ""
$(document).ready(function(){
    $.lang_load("basic_setting_backup_wan");
    page_initial()
}); 

function get_obj_success_cb(obj) { 
    ORIGINAL_OBJ_DATA = API.obj.copy(obj); 
    MODIFIED_OBJ_DATA = API.obj.copy(ORIGINAL_OBJ_DATA); 
    layout_init()
} 
function get_obj_error_cb(obj) { 
    if (obj.api_return == 403) {
        logout('sto');
    }
} 
function get_obj_data(obj_list){ 
    API.obj.get(obj_list, get_obj_success_cb, get_obj_error_cb); 
} 
function page_initial(){
    //Coding initial function here
    get_obj_data(OBJ_LIST) 
}

function check_mode_selector(mode){
    if( 'icmp' ==  mode){
        SELECTED_CHECK_MODE = "icmp"
        $("#mode_icmp").prop("checked", true);
        $(".mode_icmp").show()
        $(".mode_dns").hide()
    }else{
        SELECTED_CHECK_MODE = "dns"
        $("#mode_dns").prop("checked", true);
        $(".mode_icmp").hide()
        $(".mode_dns").show()
    }
}

function check_interval_validation(obj){
    if($('#check_interval').val()>=1 && $('#check_interval').val()<=60){
        obj.CheckPingPeriod = $("#check_interval").val()
    }else{
        warning_control('on','global',L.basic_setting_backup_wan.lang_check_interval_error)
        return false
    }
    return true
}

function check_count_validation(obj){
    if($('#check_count').val()>=1 && $('#check_count').val()<=5){
        obj.Wan1CheckCount = $("#check_count").val()
        obj.Wan2CheckCount = $("#check_count").val()
    }else{
        warning_control('on','global',L.basic_setting_backup_wan.lang_check_count_error)
        return false
    }
    return true
}

var NOW_WAN_INDEX = 0

function save_table(index){
    if(typeof(index)=="undefined")
        var Backupwan = MODIFIED_OBJ_DATA.BackupWan.BackupWanT[wan_name_val[0]]
    else
        var Backupwan = MODIFIED_OBJ_DATA.BackupWan.BackupWanT[index]

    if (!check_count_validation(Backupwan))
        return false

    if (!check_interval_validation(Backupwan))
        return false

    Backupwan.CheckMethod = SELECTED_CHECK_MODE
    if(SELECTED_CHECK_MODE == "icmp"){
        Backupwan.Wan1CheckTarget = $("#internet_URL").val()
        Backupwan.Wan2CheckTarget = $("#internet_URL").val()
    }else if(SELECTED_CHECK_MODE == "dns"){
        Backupwan.DnsCheckDNSServer=$("#dns_target").val()
        Backupwan.DnsCheckURLTarget=$("#dns_url").val()
    }
    
    return true
}

function switch_toggle(id, val){
    if(typeof(val) == "undefined" || val == "2"){  // val: 2 is from GUI trigger
            val = $('#'+id).val()
    }
    
    if(val == "1"){
        if(id=="enable"){
            MODIFIED_OBJ_DATA.BackupWan.BackupWanT[wan_name_val[0]].Enabled = "1";
            $("#input_internet_URL").show();
            $("#input_check_interval").show();
            $("#input_check_count").show();
        }
    }else{
        if(id=="enable"){
            MODIFIED_OBJ_DATA.BackupWan.BackupWanT[wan_name_val[0]].Enabled = "0";
            $("#input_internet_URL").hide();
            $("#input_check_interval").hide();
            $("#input_check_count").hide();
        }
    }

    switcher_handler(id, val);
}

function failover_enabled(val){
    if( typeof(val) == "undefined" ){
        val = $("#failover_enabled").val()
    }
    
    if(val == "1"){
        MODIFIED_OBJ_DATA.BackupWan.BackupWanT[wan_name_val[0]].Enabled = "1";
    }else{
        MODIFIED_OBJ_DATA.BackupWan.BackupWanT[wan_name_val[0]].Enabled = "0";
    }

    switcher_handler("failover_enabled", val);
}

function select_iface(){
    MODIFIED_OBJ_DATA.BackupWan.BackupWanT[wan_name_val[0]].InterfaceType = $("#backupwan_iface").val()
}

function layout_init(obj){
    if(typeof(obj)=="undefined")
        var Backupwan = MODIFIED_OBJ_DATA.BackupWan.BackupWanT[wan_name_val[0]]
    else
        var Backupwan = MODIFIED_OBJ_DATA.BackupWan.BackupWanT[obj]

    if(Backupwan.CheckMethod == "icmp")
        check_mode_selector('icmp')
    else
        check_mode_selector('dns')

    $("#dns_target").val(Backupwan.DnsCheckDNSServer)
    $("#dns_url").val(Backupwan.DnsCheckURLTarget)
    $("#internet_URL").val(Backupwan.Wan1CheckTarget);
    $("#check_interval").val(Backupwan.CheckPingPeriod);
    $("#check_count").val(Backupwan.Wan1CheckCount);

    if(Backupwan.Enabled=="1") {
        failover_enabled("1")
    }
    else{
        failover_enabled("0")
    }

    backupwan_iface_val = G_BACKUP_WAN_IFLIST
    backupwan_iface_str = []
    display_content = ""
    G_BACKUP_WAN_IFLIST.forEach((key, i) => {
        eval("display_content = L.basic_setting_backup_wan.lang_iface_type_" + key)
        backupwan_iface_str.push(display_content)
    });

    update_select('backupwan_iface', backupwan_iface_str, backupwan_iface_val,'select_iface()', Backupwan.InterfaceType);

    /*
    if(Backupwan.Enabled=="1") {
        switcher_handler('enable', '1', 'switch_toggle(\'enable\',\'1\')');
        $("#input_internet_URL").show();
        $("#input_check_interval").show();
        $("#input_check_count").show();
    }
    else {              
        switcher_handler('enable', '0', 'switch_toggle(\'enable\',\'0\')');
        $("#input_internet_URL").hide();
        $("#input_check_interval").hide();
        $("#input_check_count").hide();
    }
        */
}

function valid_local_ip_rule(net1, net2){
    var net1 = net1.split('.')
    var net2 = net2.split('.')
    if(net1[0]==net2[0] && net1[1] == net2[1] && net1[2] == net2[2]){
            return true
    }else{
            return false
    }
}

function static_rule_validation(){
    var Backupwan_type = MODIFIED_OBJ_DATA.BackupWan.BackupWanT[wan_name_val[0]].ConnectionType
    var ip=""
    var url=""

    if(SELECTED_CHECK_MODE == "icmp"){
        ip = $('#internet_URL').val()
        if (Backupwan_type == 'dhcp'){
            if(ValidateIPaddress(ip)!=true && ! valid_url(ip) ){
                warning_control('on','global',L.error_message.lang_error16_msg)
                return false;
            }
        }
    }else if(SELECTED_CHECK_MODE == "dns"){
        ip = $('#dns_target').val()
        url = $('#dns_url').val()
        if(ValidateIPaddress(ip)!=true){
            warning_control('on','global',L.error_message.lang_error16_msg)
            return false;
        }else if(! valid_url(url)){
            warning_control('on','global',L.error_message.lang_error_domain_format_msg)
            return false;
        }
    }

    return true
} 
function page_save(){
    warning_control('off','global')
    if(!static_rule_validation())
        return;

    if(!save_table())
        return;

    set_obj_data(MODIFIED_OBJ_DATA)
}

function set_obj_success_cb(obj) {
    //show_alert(L.common.success_title, L.common.save_success);
    ORIGINAL_OBJ_DATA = API.obj.copy(MODIFIED_OBJ_DATA);
    loading_wait_control(10,page_initial())
                
}
function set_obj_error_cb(obj) {
    loading_control(0)
    //show_alert(L.common.fail_title, L.common.save_fail)
}
function set_obj_data(obj_content){
    if(typeof(obj_content) == 'string')
        API.obj.set(JSON.parse(obj_content), set_obj_success_cb, set_obj_error_cb);
    else if(typeof(obj_content) == 'object')
        API.obj.set(obj_content, set_obj_success_cb, set_obj_error_cb);
}
