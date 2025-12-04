*** Settings ***
Library    Process
Library    OperatingSystem
#Library    SerialLibrary
Library    SeleniumLibrary
Library    SSHLibrary
Library     String
Library     BuiltIn
Library     telnet_case.py
#Suite Setup    SSH To Router And Get all SSID and BSSID
*** Variables ***
${IFACE}       wlp3s0
${Client_PASSWORD}    password

${conf_PATH}   /etc/wpa_supplicant/wpa_supplicant.conf
${conf_wpa3_PATH}   /etc/wpa_supplicant/wpa_supplicant_wpa3.conf
${Config_name}    test.conf
${TIMEOUT}     10
${Count_Number}    0
${total_unable_to_get_value_from_USP}    0
${total_get_value_from_USP}    0
${wait_counter}        0
${dynamic_value}        0
${TMP_CONF}    test_tmp.conf
${ORIG_CONF}    /etc/wpa_supplicant/wpa_supplicant.conf
${TMP1_CONF}    test_tmp1.conf
${ORIG_wpa3_CONF}    /etc/wpa_supplicant/wpa_supplicant_wpa3.conf
${TMP1_wpa3_CONF}    test_wpa3_tmp1.conf
${GUI_IP}    192.168.1.1
##---telnet buffalo console-----
${Switch_HOST}    127.0.0.1
${Switch_PORT}    9998
##---SSH-----
${HOST}     192.168.1.1
${USER}     root
${SSH_PASSWORD}    
${CMD}      ifconfig
${Switch_HOST}    127.0.0.1
${Switch_PORT}    9999
##---DUT SSID---
${Default_PSK}    12345678
${Changed_common_PSK}    123456789012345678901234567890121234567890123456789012345678901
${Changed_common_SSID}    AUTOmeshTEST12345678901234567890
${Changed_2G_SSID}    AUTOWiFiBasic_2G_123456789012345
${Changed_5G_SSID}    AUTOWiFiBasic_5G_123456789012345
${Changed_6G_SSID}    AUTOWiFiBasic_6G_123456789012345
*** Test Cases ***
Enable Client wired Network`
    Enable Client wired Network
    Disable the switch port connected to the agent

Check Wizard`
    [Tags]    Wizard
    Check Wizard

Default Controller`    
    Login GUI    ${HOST}
    Defalut DUT/Agent and Wait setup
    Close All Browsers  
    
Setup Wizard with mesh disabled`
    [Tags]    Wizard
    Login Wizard GUI    ${HOST}
    Setup Wizard with mesh disabled
    Close All Browsers   

Check DUT FW 
    Check DUT FW   ${HOST}

Enable SSh`
    Enable SSH

Set the DUT channel to be scannable
    [Tags]    6G    5G
    Set DUT 5G and 6G channel to be scannable

Get Router all SSID,password and BSSID`
    SSH To Disable Mesh Router And Get all Common/disable common SSID and BSSID
    SSH To Controller And Get default wifi password

Disable Client wired Network and Reset WiFi Interface`
    Disable Client wired Network
    Reset WiFi Interface
    
No.1 Connect to common 2G SSID
    [Tags]    2G
    Modify WPA Supplicant wpa3 Config    ${2G_common_SSID}    ${2G_SSID_BSSID}    ${Default_PSK}
    Connect to ssid and Check client can ping DUT    ${2G_SSID_BSSID}     
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Check SSID can be scan    ${2G_SSID_BSSID}

No.2 Connect to common 5G SSID
    [Tags]    5G
    Modify WPA Supplicant wpa3 Config    ${5G_common_SSID}    ${5G_SSID_BSSID}    ${Default_PSK}
    Connect to ssid and Check client can ping DUT    ${5G_SSID_BSSID} 
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Check SSID can be scan    ${5G_SSID_BSSID}

No.3 Connect to common 6G SSID
    [Tags]    6G
    Modify WPA Supplicant wpa3 Config    ${6G_common_SSID}    ${6G_SSID_BSSID}    ${Default_PSK}
    Connect to ssid and Check client can ping DUT    ${6G_SSID_BSSID} 
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Check SSID can be scan    ${6G_SSID_BSSID}

# # No.4 WPS > Not Test
# #     Pass Execution    Not Test

Change common SSID/Authentication/Key and Get router common SSID`
    Enable Client wired Network

    Login GUI    ${HOST}
    Change common/MLO SSID/Authentication/Key
    Close All Browsers

    SSH To Disable Mesh Router And Get all Common/disable common SSID and BSSID
    Disable Client wired Network

    Reset WiFi Interface

No.5 Connect to common 2G SSID
    [Tags]    2G
    Modify WPA Supplicant wpa3 Config    ${Changed_common_SSID}    ${2G_SSID_BSSID}    ${Changed_common_PSK}
    Connect to ssid and Check client can ping DUT    ${2G_SSID_BSSID}     
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Check SSID can be scan    ${2G_SSID_BSSID}


No.6 Connect to common 5G SSID
    [Tags]    5G
    Modify WPA Supplicant wpa3 Config    ${Changed_common_SSID}    ${5G_SSID_BSSID}    ${Changed_common_PSK}
    Connect to ssid and Check client can ping DUT    ${5G_SSID_BSSID} 
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Check SSID can be scan    ${5G_SSID_BSSID}


No.7 Connect to common 6G SSID
    [Tags]    6G
    Modify WPA Supplicant wpa3 Config    ${Changed_common_SSID}    ${6G_SSID_BSSID}    ${Changed_common_PSK}
    Connect to ssid and Check client can ping DUT    ${6G_SSID_BSSID} 
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Check SSID can be scan    ${6G_SSID_BSSID}

    
Change common ssid Mode, Channel and Bandwidth`
    Enable Client wired Network

    Login GUI    ${HOST}
    Change Mode/Channel/Bandwidth
    Close All Browsers

    Disable Client wired Network

    Reset WiFi Interface 

No.8 Connect to common 2G SSID
    [Tags]    2G
    Modify WPA Supplicant wpa3 Config    ${Changed_common_SSID}    ${2G_SSID_BSSID}    ${Changed_common_PSK}
    Connect to ssid and Check client can ping DUT    ${2G_SSID_BSSID}  
    Ckeck 2G SSID Mode/Channel/Bandwidth
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Check SSID can be scan    ${2G_SSID_BSSID}

No.9 Connect to common 5G SSID
    [Tags]    5G
    Modify WPA Supplicant wpa3 Config    ${Changed_common_SSID}    ${5G_SSID_BSSID}    ${Changed_common_PSK}
    Connect to ssid and Check client can ping DUT    ${5G_SSID_BSSID} 
    Ckeck 5G SSID Mode/Channel/Bandwidth
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Check SSID can be scan    ${5G_SSID_BSSID}

No.10 Connect to common 6G SSID
    [Tags]    6G
    Modify WPA Supplicant wpa3 Config    ${Changed_common_SSID}    ${6G_SSID_BSSID}    ${Changed_common_PSK}
    Connect to ssid and Check client can ping DUT    ${6G_SSID_BSSID} 
    Ckeck 6G SSID Mode/Channel/Bandwidth
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Check SSID can be scan    ${6G_SSID_BSSID}

Default DUT``    
    Enable Client wired Network

    Login GUI    ${HOST}
    Defalut DUT/Agent 
    Close All Browsers  

Setup Wizard with mesh disabled``
    [Tags]    Wizard
    Login Wizard GUI    ${HOST}
    Setup Wizard with mesh disabled
    Close All Browsers  

Enable MLO`
    [Tags]    MLO
    Enable SSH  

    Login GUI    ${HOST}
    Enable MLO
    Close All Browsers  

    Set DUT 5G and 6G channel to be scannable 

    SSH To Disable Mesh Router And Get all MLO SSID and BSSID

    Disable Client wired Network

    Reset WiFi Interface

No.11 Connect to MLO 2G SSID
    [Tags]    2G    MLO
    Modify WPA Supplicant wpa3 Config    ${2G_common_SSID}    ${2G_SSID_BSSID}    ${Default_PSK}
    Connect to ssid and Check client can ping DUT    ${2G_SSID_BSSID} 
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Check SSID can be scan    ${2G_SSID_BSSID}   

No.12 Connect to MLO 5G SSID
    [Tags]    5G    MLO
    Modify WPA Supplicant wpa3 Config    ${5G_common_SSID}    ${5G_SSID_BSSID}    ${Default_PSK}
    Connect to ssid and Check client can ping DUT    ${5G_SSID_BSSID} 
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Check SSID can be scan    ${5G_SSID_BSSID}

No.13 Connect to MLO 6G SSID
    [Tags]    6G    MLO
    Modify WPA Supplicant wpa3 Config    ${6G_common_SSID}    ${6G_SSID_BSSID}    ${Default_PSK}
    Connect to ssid and Check client can ping DUT    ${6G_SSID_BSSID} 
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Check SSID can be scan    ${6G_SSID_BSSID}

# # No.14 WPS > Not Test
# #     Pass Execution    Not Test


Change MLO SSID, Authentication, Key and Get router common SSID`
    [Tags]    MLO
    Enable Client wired Network

    Login GUI    ${HOST}
    Change common/MLO SSID/Authentication/Key
    Close All Browsers

    SSH To Disable Mesh Router And Get all MLO SSID and BSSID

    Disable Client wired Network

    Reset WiFi Interface

No.15 Connect to MLO 2G SSID
    [Tags]    2G    MLO
    Modify WPA Supplicant wpa3 Config    ${Changed_common_SSID}    ${2G_SSID_BSSID}    ${Changed_common_PSK}
    Connect to ssid and Check client can ping DUT    ${2G_SSID_BSSID}  
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Check SSID can be scan    ${2G_SSID_BSSID}

No.16 Connect to MLO 5G SSID
    [Tags]    5G    MLO
    Modify WPA Supplicant wpa3 Config    ${Changed_common_SSID}    ${5G_SSID_BSSID}    ${Changed_common_PSK}
    Connect to ssid and Check client can ping DUT    ${5G_SSID_BSSID} 
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Check SSID can be scan    ${5G_SSID_BSSID}

No.17 Connect to MLO 6G SSID
    [Tags]    6G    MLO
    Modify WPA Supplicant wpa3 Config    ${Changed_common_SSID}    ${6G_SSID_BSSID}    ${Changed_common_PSK}
    Connect to ssid and Check client can ping DUT    ${6G_SSID_BSSID} 
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Check SSID can be scan    ${6G_SSID_BSSID}

Change MLO ssid Mode, Channel and Bandwidth`
    [Tags]    MLO    802.11 mode
    Enable Client wired Network

    Login GUI    ${HOST}
    Change MLO Mode/Channel/Bandwidth
    Close All Browsers

    Disable Client wired Network

    Reset WiFi Interface 

No.18 Connect to MLO 2G SSID
    [Tags]    2G    MLO    802.11 mode
    Modify WPA Supplicant wpa3 Config    ${Changed_common_SSID}    ${2G_SSID_BSSID}    ${Changed_common_PSK}
    Connect to ssid and Check client can ping DUT    ${2G_SSID_BSSID}  
    Ckeck 2G SSID Mode/Channel/Bandwidth
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Check SSID can be scan    ${2G_SSID_BSSID}
    
No.19 Connect to MLO 5G SSID
    [Tags]    5G    MLO    802.11 mode
    Modify WPA Supplicant wpa3 Config    ${Changed_common_SSID}    ${5G_SSID_BSSID}    ${Changed_common_PSK}
    Connect to ssid and Check client can ping DUT    ${5G_SSID_BSSID} 
    Ckeck 5G SSID Mode/Channel/Bandwidth
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Check SSID can be scan    ${5G_SSID_BSSID}

No.20 Connect to MLO 6G SSID
    [Tags]    6G    MLO    802.11 mode
    Modify WPA Supplicant wpa3 Config    ${Changed_common_SSID}    ${6G_SSID_BSSID}    ${Changed_common_PSK}
    Connect to ssid and Check client can ping DUT    ${6G_SSID_BSSID} 
    Ckeck 6G SSID Mode/Channel/Bandwidth
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Check SSID can be scan    ${6G_SSID_BSSID}
    



Default DUT/Agent`` 
    Enable Client wired Network

    Login GUI    ${HOST}
    Defalut DUT/Agent 
    Close All Browsers  

Setup Wizard with mesh disabled```
    [Tags]    Wizard
    Login Wizard GUI    ${HOST}
    Setup Wizard with mesh disabled
    Close All Browsers  
    
Disable MLO and common ssid`    
    Enable SSH 

    Login GUI    ${HOST}
    Disable MLO and common ssid
    Close All Browsers   

    Set DUT 5G and 6G channel to be scannable 

    SSH To Disable Mesh Router And Get all Common/disable common SSID and BSSID
    
    Disable Client wired Network

    Reset WiFi Interface

No.21 Connect to 2G SSID
    [Tags]    2G
    Modify WPA Supplicant wpa3 Config    ${2G_common_SSID}    ${2G_SSID_BSSID}    ${Default_PSK}
    Connect to ssid and Check client can ping DUT    ${2G_SSID_BSSID} 
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Check SSID can be scan    ${2G_SSID_BSSID}

No.22 Connect to 5G SSID
    [Tags]    5G
    Modify WPA Supplicant wpa3 Config    ${5G_common_SSID}    ${5G_SSID_BSSID}    ${Default_PSK}
    Connect to ssid and Check client can ping DUT    ${5G_SSID_BSSID} 
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Check SSID can be scan    ${5G_SSID_BSSID}

No.23 Connect to 6G SSID
    [Tags]    6G
    Modify WPA Supplicant wpa3 Config    ${6G_common_SSID}    ${6G_SSID_BSSID}    ${Default_PSK}
    Connect to ssid and Check client can ping DUT    ${6G_SSID_BSSID} 
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Check SSID can be scan    ${6G_SSID_BSSID}

# # No.24 WPS > Not Test
# #     Pass Execution    Not Test

Change SSID, Authentication, Key and Get router SSID`
    Enable Client wired Network

    Login GUI    ${HOST}
    Change SSID/Authentication/Key
    Close All Browsers

    SSH To Disable Mesh Router And Get all Common/disable common SSID and BSSID
    Disable Client wired Network

    Reset WiFi Interface

No.25 Connect to 2G SSID
    [Tags]    2G
    Modify WPA Supplicant wpa3 Config    ${Changed_2G_SSID}    ${2G_SSID_BSSID}    ${Changed_common_PSK}
    Connect to ssid and Check client can ping DUT    ${2G_SSID_BSSID}  
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Check SSID can be scan    ${2G_SSID_BSSID}

No.26 Connect to 5G SSID
    [Tags]    5G
    Modify WPA Supplicant wpa3 Config    ${Changed_5G_SSID}    ${5G_SSID_BSSID}    ${Changed_common_PSK}
    Connect to ssid and Check client can ping DUT    ${5G_SSID_BSSID} 
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Check SSID can be scan    ${5G_SSID_BSSID}

No.27 Connect to 6G SSID
    [Tags]    6G
    Modify WPA Supplicant wpa3 Config    ${Changed_6G_SSID}    ${6G_SSID_BSSID}    ${Changed_common_PSK}
    Connect to ssid and Check client can ping DUT    ${6G_SSID_BSSID} 
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Check SSID can be scan    ${6G_SSID_BSSID}

Change ssid Mode, Channel and Bandwidth`
    Enable Client wired Network

    Login GUI    ${HOST}
    Change Mode/Channel/Bandwidth
    Close All Browsers

    Disable Client wired Network

    Reset WiFi Interface 

No.28 Connect to 2G SSID
    [Tags]    2G
    Modify WPA Supplicant wpa3 Config    ${Changed_2G_SSID}    ${2G_SSID_BSSID}    ${Changed_common_PSK}
    Connect to ssid and Check client can ping DUT    ${2G_SSID_BSSID}  
    Ckeck 2G SSID Mode/Channel/Bandwidth
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Check SSID can be scan    ${2G_SSID_BSSID}

No.29 Connect to 5G SSID
    [Tags]    5G
    Modify WPA Supplicant wpa3 Config    ${Changed_5G_SSID}    ${5G_SSID_BSSID}    ${Changed_common_PSK}
    Connect to ssid and Check client can ping DUT    ${5G_SSID_BSSID} 
    Ckeck 5G SSID Mode/Channel/Bandwidth
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Check SSID can be scan    ${5G_SSID_BSSID}

No.30 Connect to 6G SSID
    [Tags]    6G
    Modify WPA Supplicant wpa3 Config    ${Changed_6G_SSID}    ${6G_SSID_BSSID}    ${Changed_common_PSK}
    Connect to ssid and Check client can ping DUT    ${6G_SSID_BSSID} 
    Ckeck 6G SSID Mode/Channel/Bandwidth
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Check SSID can be scan    ${6G_SSID_BSSID}

Enable Client wired Network.
    Enable Client wired Network
    Disable the switch port connected to the agent

Check Wizard
    [Tags]    Wizard
    Check Wizard

Default Controller.    
    Login GUI    ${HOST}
    Defalut DUT/Agent and Wait setup
    Close All Browsers  
    
Setup Wizard
    [Tags]    Wizard
    Login Wizard GUI    ${HOST}
    Setup Wizard
    Close All Browsers   

Enable SSh.
    Enable SSH

Set DUT 5G and 6G channel to be scannable.
    [Tags]    6G
    Set DUT 5G and 6G channel to be scannable

Get Router all SSID,password and BSSID.
    SSH To Enable Mesh Router And Get all Common/disable common SSID and BSSID
    SSH To Controller And Get default wifi password

Disable Client wired Network and Reset WiFi Interface.
    Disable Client wired Network
    Reset WiFi Interface
    
No.31 Connect to common 2G SSID
    [Tags]    2G
    Modify WPA Supplicant wpa3 Config    ${2G_common_SSID}    ${2G_SSID_BSSID}    ${Default_PSK}
    Connect to ssid and Check client can ping DUT    ${2G_SSID_BSSID}     
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Check SSID can be scan    ${2G_SSID_BSSID}

No.32 Connect to common 5G SSID
    [Tags]    5G
    Modify WPA Supplicant wpa3 Config    ${5G_common_SSID}    ${5G_SSID_BSSID}    ${Default_PSK}
    Connect to ssid and Check client can ping DUT    ${5G_SSID_BSSID} 
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Check SSID can be scan    ${5G_SSID_BSSID}

No.33 Connect to common 6G SSID
    [Tags]    6G
    Modify WPA Supplicant wpa3 Config    ${6G_common_SSID}    ${6G_SSID_BSSID}    ${Default_PSK}
    Connect to ssid and Check client can ping DUT    ${6G_SSID_BSSID} 
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Check SSID can be scan    ${6G_SSID_BSSID}

# # No.34 WPS > Not Test
# #     Pass Execution    Not Test

Change common SSID/Authentication/Key and Get router common SSID.
    Enable Client wired Network

    Login GUI    ${HOST}
    Change common/MLO SSID/Authentication/Key
    Close All Browsers

    SSH To Enable Mesh Router And Get all Common/disable common SSID and BSSID
    Disable Client wired Network

    Reset WiFi Interface

No.35 Connect to common 2G SSID
    [Tags]    2G
    Modify WPA Supplicant wpa3 Config    ${Changed_common_SSID}    ${2G_SSID_BSSID}    ${Changed_common_PSK}
    Connect to ssid and Check client can ping DUT    ${2G_SSID_BSSID}     
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Check SSID can be scan    ${2G_SSID_BSSID}

No.36 Connect to common 5G SSID
    [Tags]    5G
    Modify WPA Supplicant wpa3 Config    ${Changed_common_SSID}    ${5G_SSID_BSSID}    ${Changed_common_PSK}
    Connect to ssid and Check client can ping DUT    ${5G_SSID_BSSID} 
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Check SSID can be scan    ${5G_SSID_BSSID}


No.37 Connect to common 6G SSID
    [Tags]    6G
    Modify WPA Supplicant wpa3 Config    ${Changed_common_SSID}    ${6G_SSID_BSSID}    ${Changed_common_PSK}
    Connect to ssid and Check client can ping DUT    ${6G_SSID_BSSID} 
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Check SSID can be scan    ${6G_SSID_BSSID}

    
Change common ssid Mode, Channel and Bandwidth.
    Enable Client wired Network

    Login GUI    ${HOST}
    Change Mode/Channel/Bandwidth
    Close All Browsers

    Disable Client wired Network

    Reset WiFi Interface 

No.38 Connect to common 2G SSID
    [Tags]    2G
    Modify WPA Supplicant wpa3 Config    ${Changed_common_SSID}    ${2G_SSID_BSSID}    ${Changed_common_PSK}
    Connect to ssid and Check client can ping DUT    ${2G_SSID_BSSID}  
    Ckeck 2G SSID Mode/Channel/Bandwidth
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Check SSID can be scan    ${2G_SSID_BSSID}

No.39 Connect to common 5G SSID
    [Tags]    5G
    Modify WPA Supplicant wpa3 Config    ${Changed_common_SSID}    ${5G_SSID_BSSID}    ${Changed_common_PSK}
    Connect to ssid and Check client can ping DUT    ${5G_SSID_BSSID} 
    Ckeck 5G SSID Mode/Channel/Bandwidth
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Check SSID can be scan    ${5G_SSID_BSSID}

No.40 Connect to common 6G SSID
    [Tags]    6G
    Modify WPA Supplicant wpa3 Config    ${Changed_common_SSID}    ${6G_SSID_BSSID}    ${Changed_common_PSK}
    Connect to ssid and Check client can ping DUT    ${6G_SSID_BSSID} 
    Ckeck 6G SSID Mode/Channel/Bandwidth
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Check SSID can be scan    ${6G_SSID_BSSID}





Default DUT    
    Enable Client wired Network

    Login GUI    ${HOST}
    Defalut DUT/Agent 
    Close All Browsers  

Setup Wizard.
    [Tags]    Wizard
    Login Wizard GUI    ${HOST}
    Setup Wizard
    Close All Browsers  

Enable MLO.
    [Tags]    MLO
    Enable SSH  

    Login GUI    ${HOST}
    Enable MLO
    Close All Browsers  

    Set DUT 5G and 6G channel to be scannable 

    SSH To Enable Mesh Router And Get all MLO SSID and BSSID

    Disable Client wired Network

    Reset WiFi Interface

No.41 Connect to MLO 2G SSID
    [Tags]    2G    MLO
    Modify WPA Supplicant wpa3 Config    ${2G_common_SSID}    ${2G_SSID_BSSID}    ${Default_PSK}
    Connect to ssid and Check client can ping DUT    ${2G_SSID_BSSID}   
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Check SSID can be scan    ${2G_SSID_BSSID} 

No.42 Connect to MLO 5G SSID
    [Tags]    5G    MLO
    Modify WPA Supplicant wpa3 Config    ${5G_common_SSID}    ${5G_SSID_BSSID}    ${Default_PSK}
    Connect to ssid and Check client can ping DUT    ${5G_SSID_BSSID} 
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Check SSID can be scan    ${5G_SSID_BSSID}

No.43 Connect to MLO 6G SSID
    [Tags]    6G    MLO
    Modify WPA Supplicant wpa3 Config    ${6G_common_SSID}    ${6G_SSID_BSSID}    ${Default_PSK}
    Connect to ssid and Check client can ping DUT    ${6G_SSID_BSSID} 
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Check SSID can be scan    ${6G_SSID_BSSID}

# # No.44 WPS > Not Test
# #     Pass Execution    Not Test


Change MLO SSID, Authentication, Key and Get router common SSID.
    [Tags]    MLO
    Enable Client wired Network

    Login GUI    ${HOST}
    Change common/MLO SSID/Authentication/Key
    Close All Browsers

    SSH To Enable Mesh Router And Get all MLO SSID and BSSID

    Disable Client wired Network

    Reset WiFi Interface

No.45 Connect to MLO 2G SSID
    [Tags]    2G    MLO
    Modify WPA Supplicant wpa3 Config    ${Changed_common_SSID}    ${2G_SSID_BSSID}    ${Changed_common_PSK}
    Connect to ssid and Check client can ping DUT    ${2G_SSID_BSSID} 
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Check SSID can be scan    ${2G_SSID_BSSID} 

No.46 Connect to MLO 5G SSID
    [Tags]    5G    MLO
    Modify WPA Supplicant wpa3 Config    ${Changed_common_SSID}    ${5G_SSID_BSSID}    ${Changed_common_PSK}
    Connect to ssid and Check client can ping DUT    ${5G_SSID_BSSID} 
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Check SSID can be scan    ${5G_SSID_BSSID}

No.47 Connect to MLO 6G SSID
    [Tags]    6G    MLO
    Modify WPA Supplicant wpa3 Config    ${Changed_common_SSID}    ${6G_SSID_BSSID}    ${Changed_common_PSK}
    Connect to ssid and Check client can ping DUT    ${6G_SSID_BSSID} 
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Check SSID can be scan    ${6G_SSID_BSSID}

Change MLO ssid Mode, Channel and Bandwidth.
    [Tags]    MLO    802.11 mode
    Enable Client wired Network

    Login GUI    ${HOST}
    Change MLO Mode/Channel/Bandwidth
    Close All Browsers

    Disable Client wired Network

    Reset WiFi Interface 

No.48 Connect to MLO 2G SSID
    [Tags]    2G    MLO    802.11 mode
    Modify WPA Supplicant wpa3 Config    ${Changed_common_SSID}    ${2G_SSID_BSSID}    ${Changed_common_PSK}
    Connect to ssid and Check client can ping DUT    ${2G_SSID_BSSID}  
    Ckeck 2G SSID Mode/Channel/Bandwidth
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Check SSID can be scan    ${2G_SSID_BSSID}
    
No.49 Connect to MLO 5G SSID
    [Tags]    5G    MLO    802.11 mode
    Modify WPA Supplicant wpa3 Config    ${Changed_common_SSID}    ${5G_SSID_BSSID}    ${Changed_common_PSK}
    Connect to ssid and Check client can ping DUT    ${5G_SSID_BSSID} 
    Ckeck 5G SSID Mode/Channel/Bandwidth
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Check SSID can be scan    ${5G_SSID_BSSID}

No.50 Connect to MLO 6G SSID
    [Tags]    6G    MLO    802.11 mode
    Modify WPA Supplicant wpa3 Config    ${Changed_common_SSID}    ${6G_SSID_BSSID}    ${Changed_common_PSK}
    Connect to ssid and Check client can ping DUT    ${6G_SSID_BSSID} 
    Ckeck 6G SSID Mode/Channel/Bandwidth
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Check SSID can be scan    ${6G_SSID_BSSID}
    



Default DUT/Agent.. 
    Enable Client wired Network

    Login GUI    ${HOST}
    Defalut DUT/Agent 
    Close All Browsers  

Setup Wizard..
    [Tags]    Wizard
    Login Wizard GUI    ${HOST}
    Setup Wizard
    Close All Browsers  
    
Disable MLO and common ssid.    
    Enable SSH 

    Login GUI    ${HOST}
    Disable MLO and common ssid
    Close All Browsers   

    Set DUT 5G and 6G channel to be scannable 

    SSH To Enable Mesh Router And Get all Common/disable common SSID and BSSID
    
    Disable Client wired Network

    Reset WiFi Interface

No.51 Connect to 2G SSID
    [Tags]    2G
    Modify WPA Supplicant wpa3 Config    ${2G_common_SSID}    ${2G_SSID_BSSID}    ${Default_PSK}
    Connect to ssid and Check client can ping DUT    ${2G_SSID_BSSID}
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Check SSID can be scan    ${2G_SSID_BSSID} 

No.52 Connect to 5G SSID
    [Tags]    5G
    Modify WPA Supplicant wpa3 Config    ${5G_common_SSID}    ${5G_SSID_BSSID}    ${Default_PSK}
    Connect to ssid and Check client can ping DUT    ${5G_SSID_BSSID} 
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Check SSID can be scan    ${5G_SSID_BSSID}

No.53 Connect to 6G SSID
    [Tags]    6G
    Modify WPA Supplicant wpa3 Config    ${6G_common_SSID}    ${6G_SSID_BSSID}    ${Default_PSK}
    Connect to ssid and Check client can ping DUT    ${6G_SSID_BSSID} 
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Check SSID can be scan    ${6G_SSID_BSSID}

# # No.54 WPS > Not Test
# #     Pass Execution    Not Test

Change SSID, Authentication, Key and Get router SSID.
    Enable Client wired Network

    Login GUI    ${HOST}
    Change SSID/Authentication/Key
    Close All Browsers

    SSH To Enable Mesh Router And Get all Common/disable common SSID and BSSID
    Disable Client wired Network

    Reset WiFi Interface

No.55 Connect to 2G SSID
    [Tags]    2G
    Modify WPA Supplicant wpa3 Config    ${Changed_2G_SSID}    ${2G_SSID_BSSID}    ${Changed_common_PSK}
    Connect to ssid and Check client can ping DUT    ${2G_SSID_BSSID}  
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Check SSID can be scan    ${2G_SSID_BSSID}

No.56 Connect to 5G SSID
    [Tags]    5G
    Modify WPA Supplicant wpa3 Config    ${Changed_5G_SSID}    ${5G_SSID_BSSID}    ${Changed_common_PSK}
    Connect to ssid and Check client can ping DUT    ${5G_SSID_BSSID} 
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Check SSID can be scan    ${5G_SSID_BSSID}

No.57 Connect to 6G SSID
    [Tags]    6G
    Modify WPA Supplicant wpa3 Config    ${Changed_6G_SSID}    ${6G_SSID_BSSID}    ${Changed_common_PSK}
    Connect to ssid and Check client can ping DUT    ${6G_SSID_BSSID} 
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Check SSID can be scan    ${6G_SSID_BSSID}

Change ssid Mode, Channel and Bandwidth.
    Enable Client wired Network

    Login GUI    ${HOST}
    Change Mode/Channel/Bandwidth
    Close All Browsers

    Disable Client wired Network

    Reset WiFi Interface 

No.58 Connect to 2G SSID
    [Tags]    2G
    Modify WPA Supplicant wpa3 Config    ${Changed_2G_SSID}    ${2G_SSID_BSSID}    ${Changed_common_PSK}
    Connect to ssid and Check client can ping DUT    ${2G_SSID_BSSID}  
    Ckeck 2G SSID Mode/Channel/Bandwidth
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Check SSID can be scan    ${2G_SSID_BSSID}

No.59 Connect to 5G SSID
    [Tags]    5G
    Modify WPA Supplicant wpa3 Config    ${Changed_5G_SSID}    ${5G_SSID_BSSID}    ${Changed_common_PSK}
    Connect to ssid and Check client can ping DUT    ${5G_SSID_BSSID} 
    Ckeck 5G SSID Mode/Channel/Bandwidth
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Check SSID can be scan    ${5G_SSID_BSSID}

No.60 Connect to 6G SSID
    [Tags]    6G
    Modify WPA Supplicant wpa3 Config    ${Changed_6G_SSID}    ${6G_SSID_BSSID}    ${Changed_common_PSK}
    Connect to ssid and Check client can ping DUT    ${6G_SSID_BSSID} 
    Ckeck 6G SSID Mode/Channel/Bandwidth
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Check SSID can be scan    ${6G_SSID_BSSID}

Enable Client wired Network..
    Enable Client wired Network














































    

*** Keywords ***
Defalut DUT/Agent 
    Click Element    xpath=//*[@id="menu_management"]
    sleep    3
    Click Element    xpath=//*[@id="menu_management_settings"]
    sleep    3
    Click Element    xpath=//*[@id="lang_restore_btn"]
    sleep    3
    Click Element    xpath=//*[@id="confirm_dialog_confirmed"]
    sleep    3
    sleep    300

Check DUT FW 
    [Arguments]    ${DUT_IP}
    Login GUI    ${DUT_IP}
    ${text} =    Get Text    xpath=//*[@id="dashboard_system_swversion"]
    Log    ${text}
    Close All Browsers

SSH To Enable Mesh Router And Get all MLO SSID and BSSID
    Wait Until Keyword Succeeds    3x    10s    Retry SSH To Enable Mesh Router And Get all MLO SSID and BSSID

Retry SSH To Enable Mesh Router And Get all MLO SSID and BSSID
    Open Connection    ${HOST}
    Login              ${USER}    ${SSH_PASSWORD}

    ${2G_common_SSID} =    Execute Command    iw dev | grep -A5 "Interface mld2" | awk '/ssid/{print $2}'
    ${2G_SSID_BSSID} =    Execute Command    iw dev mld2 info | awk '/link 0:/{getline; print $2}'
    ${2G_SSID_BSSID}=    Convert To Lower Case    ${2G_SSID_BSSID}
    Set Suite Variable    ${2G_common_SSID}
    Set Suite Variable    ${2G_SSID_BSSID}

    ${5G_common_SSID} =    Execute Command    iw dev | grep -A5 "Interface mld1" | awk '/ssid/{print $2}'
    ${5G_SSID_BSSID} =    Execute Command    iw dev mld1 info | awk '/link 1:/{getline; print $2}'
    ${5G_SSID_BSSID}=    Convert To Lower Case    ${5G_SSID_BSSID}
    Set Suite Variable    ${5G_common_SSID}
    Set Suite Variable    ${5G_SSID_BSSID}

    ${6G_common_SSID} =    Execute Command    iw dev | grep -A5 "Interface mld1" | awk '/ssid/{print $2}'
    ${6G_SSID_BSSID} =    Execute Command    iw dev mld1 info | awk '/link 2:/{getline; print $2}'
    ${6G_SSID_BSSID}=    Convert To Lower Case    ${6G_SSID_BSSID}
    Set Suite Variable    ${6G_common_SSID}
    Set Suite Variable    ${6G_SSID_BSSID}

    Close Connection

SSH To Enable Mesh Router And Get all Common/disable common SSID and BSSID
    Wait Until Keyword Succeeds    3x    10s    Retry SSH To Enable Mesh Router And Get all Common/disable common SSID and BSSID

Retry SSH To Enable Mesh Router And Get all Common/disable common SSID and BSSID
    Open Connection    ${HOST}
    Login              ${USER}    ${SSH_PASSWORD}

    ${2G_SSID_BSSID} =    Execute Command    iw dev mld0 info | awk '/link 0:/{getline; print $2}'
    ${2G_common_SSID} =    Execute Command    iw dev | grep -A5 "Interface mld0" | awk '/ssid/{print $2}'
    ${2G_SSID_BSSID}=    Convert To Lower Case    ${2G_SSID_BSSID}
    Set Suite Variable    ${2G_common_SSID}
    Set Suite Variable    ${2G_SSID_BSSID}

    ${5G_SSID_BSSID} =    Execute Command    iw dev mld2 info | awk '/link 1:/{getline; print $2}'
    ${5G_common_SSID} =    Execute Command    iw dev | grep -A5 "Interface mld2" | awk '/ssid/{print $2}'
    ${5G_SSID_BSSID}=    Convert To Lower Case    ${5G_SSID_BSSID}
    Set Suite Variable    ${5G_common_SSID}
    Set Suite Variable    ${5G_SSID_BSSID}

    ${6G_SSID_BSSID} =    Execute Command    iw dev mld4 info | awk '/link 2:/{getline; print $2}'
    ${6G_common_SSID} =    Execute Command    iw dev | grep -A5 "Interface mld4" | awk '/ssid/{print $2}'
    ${6G_SSID_BSSID}=    Convert To Lower Case    ${6G_SSID_BSSID}
    Set Suite Variable    ${6G_common_SSID}
    Set Suite Variable    ${6G_SSID_BSSID}

    Close Connection

Check SSID can be scan 
    [Arguments]    ${mac}
    ${output}=    Run    echo ${Client_PASSWORD} | sudo iw dev ${IFACE} scan | grep -F -A 100 "BSS ${mac}"
    sleep    5
    ${output}=    Run    echo ${Client_PASSWORD} | sudo iw dev ${IFACE} scan | grep -F -A 100 "BSS ${mac}"
    sleep    5
    ${output}=    Run    echo ${Client_PASSWORD} | sudo iw dev ${IFACE} scan | grep -F -A 100 "BSS ${mac}"
    sleep    5
    ${output}=    Run    echo ${Client_PASSWORD} | sudo iw dev ${IFACE} scan | grep -F -A 100 "BSS ${mac}"
    sleep    5
    ${output}=    Run    echo ${Client_PASSWORD} | sudo iw dev ${IFACE} scan | grep -F -A 100 "BSS ${mac}"
    sleep    5

SSH To Disable Mesh Router And Get all MLO SSID and BSSID
    Wait Until Keyword Succeeds    3x    10s    Retry SSH To Disable Mesh Router And Get all MLO SSID and BSSID

Retry SSH To Disable Mesh Router And Get all MLO SSID and BSSID
    Open Connection    ${HOST}
    Login              ${USER}    ${SSH_PASSWORD}

    ${2G_common_SSID} =    Execute Command    iw dev | grep -A5 "Interface mld0" | awk '/ssid/{print $2}'
    ${2G_SSID_BSSID} =    Execute Command    iw dev mld0 info | awk '/link 0:/{getline; print $2}'
    ${2G_SSID_BSSID}=    Convert To Lower Case    ${2G_SSID_BSSID}
    Set Suite Variable    ${2G_common_SSID}
    Set Suite Variable    ${2G_SSID_BSSID}

    ${5G_common_SSID} =    Execute Command    iw dev | grep -A5 "Interface mld0" | awk '/ssid/{print $2}'
    ${5G_SSID_BSSID} =    Execute Command    iw dev mld0 info | awk '/link 1:/{getline; print $2}'
    ${5G_SSID_BSSID}=    Convert To Lower Case    ${5G_SSID_BSSID}
    Set Suite Variable    ${5G_common_SSID}
    Set Suite Variable    ${5G_SSID_BSSID}

    ${6G_common_SSID} =    Execute Command    iw dev | grep -A5 "Interface mld0" | awk '/ssid/{print $2}'
    ${6G_SSID_BSSID} =    Execute Command    iw dev mld0 info | awk '/link 2:/{getline; print $2}'
    ${6G_SSID_BSSID}=    Convert To Lower Case    ${6G_SSID_BSSID}
    Set Suite Variable    ${6G_common_SSID}
    Set Suite Variable    ${6G_SSID_BSSID}

    Close Connection

SSH To Disable Mesh Router And Get all Common/disable common SSID and BSSID
    Wait Until Keyword Succeeds    3x    10s    Retry SSH To Disable Mesh Router And Get all Common/disable common SSID and BSSID

Retry SSH To Disable Mesh Router And Get all Common/disable common SSID and BSSID
    Open Connection    ${HOST}
    Login              ${USER}    ${SSH_PASSWORD}

    ${2G_SSID_BSSID} =    Execute Command    iw dev mld0 info | awk '/link 0:/{getline; print $2}'
    ${2G_common_SSID} =    Execute Command    iw dev | grep -A5 "Interface mld0" | awk '/ssid/{print $2}'
    ${2G_SSID_BSSID}=    Convert To Lower Case    ${2G_SSID_BSSID}
    Set Suite Variable    ${2G_common_SSID}
    Set Suite Variable    ${2G_SSID_BSSID}

    ${5G_SSID_BSSID} =    Execute Command    iw dev mld4 info | awk '/link 1:/{getline; print $2}'
    ${5G_common_SSID} =    Execute Command    iw dev | grep -A5 "Interface mld4" | awk '/ssid/{print $2}'
    ${5G_SSID_BSSID}=    Convert To Lower Case    ${5G_SSID_BSSID}
    Set Suite Variable    ${5G_common_SSID}
    Set Suite Variable    ${5G_SSID_BSSID}

    ${6G_SSID_BSSID} =    Execute Command    iw dev mld8 info | awk '/link 2:/{getline; print $2}'
    ${6G_common_SSID} =    Execute Command    iw dev | grep -A5 "Interface mld8" | awk '/ssid/{print $2}'
    ${6G_SSID_BSSID}=    Convert To Lower Case    ${6G_SSID_BSSID}
    Set Suite Variable    ${6G_common_SSID}
    Set Suite Variable    ${6G_SSID_BSSID}

    Close Connection

Reset WiFi Interface
    Run    echo ${Client_PASSWORD} | sudo pkill -f wpa_supplicant || true
    sleep    3
    Run    echo ${Client_PASSWORD} | sudo pkill -f dhclient || true
    sleep    3
    Run    echo ${Client_PASSWORD} | sudo rm -rf /var/run/wpa_supplicant
    sleep    3
    Run    echo ${Client_PASSWORD} | sudo ip link set ${IFACE} down
    Sleep    2
    Run    echo ${Client_PASSWORD} | sudo ip addr flush dev ${IFACE}
    sleep    3
    Run    echo ${Client_PASSWORD} | sudo ip link set ${IFACE} up
    sleep    3

Disable Client wired Network
    ${output}=    Run    echo ${Client_PASSWORD} | sudo -S /sbin/ifconfig enp1s0 down

Enable Client wired Network
    ${output}=    Run    echo ${Client_PASSWORD} | sudo -S /sbin/ifconfig enp1s0 up
    ${output}=    Run    echo ${Client_PASSWORD} | sudo -S service NetworkManager start
    ${output}=    Run    echo ${Client_PASSWORD} | sudo -S dhclient enp1s0 -r
    ${output}=    Run    echo ${Client_PASSWORD} | sudo -S ifconfig enp1s0 192.168.1.199 netmask 255.255.255.0
    sleep    10
    # ${output}=    Run    echo ${Client_PASSWORD} | sudo -S dhclient enp1s0
    ${output}=    Run    ping 192.168.1.1 -c 4
    Should Contain    ${output}    ttl=
    

Ckeck 2G SSID Mode/Channel/Bandwidth
    Wait Until Keyword Succeeds    3x    10s    Retry Ckeck 2G SSID Mode/Channel/Bandwidth
    
Retry Ckeck 2G SSID Mode/Channel/Bandwidth
    ${output}=    Run    echo ${Client_PASSWORD} | sudo -S iw dev ${IFACE} link
    Should Contain    ${output}    2412
    Should Contain    ${output}    HE-NSS
    Should Contain    ${output}    HE-MCS
    ${output1}=    Run    echo ${Client_PASSWORD} | sudo -S iw dev ${IFACE} station dump
    Should Contain    ${output1}    40MHz

Ckeck 5G SSID Mode/Channel/Bandwidth
    Wait Until Keyword Succeeds    3x    10s    Retry Ckeck 5G SSID Mode/Channel/Bandwidth
    
Retry Ckeck 5G SSID Mode/Channel/Bandwidth
    ${output}=    Run    echo ${Client_PASSWORD} | sudo -S iw dev ${IFACE} link
    Should Contain    ${output}    5180
    Should Contain    ${output}    HE-NSS
    Should Contain    ${output}    HE-MCS
    ${output1}=    Run    echo ${Client_PASSWORD} | sudo -S iw dev ${IFACE} station dump
    Should Contain    ${output1}    80MHz

Ckeck 6G SSID Mode/Channel/Bandwidth
    Wait Until Keyword Succeeds    3x    10s    Retry Ckeck 6G SSID Mode/Channel/Bandwidth
    
Retry Ckeck 6G SSID Mode/Channel/Bandwidth
    ${output}=    Run    echo ${Client_PASSWORD} | sudo -S iw dev ${IFACE} link
    Should Contain    ${output}    6215
    Should Contain    ${output}    HE-NSS
    Should Contain    ${output}    HE-MCS
    ${output1}=    Run    echo ${Client_PASSWORD} | sudo -S iw dev ${IFACE} station dump
    Should Contain    ${output1}    160MHz

Modify WPA Supplicant Config
    [Arguments]    ${SSID}    ${BSSID}    ${PSK}
    Run Process    echo ${Client_PASSWORD} | sudo -S cp ${ORIG_CONF} ${TMP_CONF}    shell=True

    ${content}=    OperatingSystem.Get File    ${TMP_CONF}

    ${content}=    Replace String Using Regexp    ${content}    ssid=".*?"    ssid="${SSID}"
    ${content}=    Replace String Using Regexp    ${content}    bssid=.*    bssid=${BSSID}
    ${content}=    Replace String Using Regexp    ${content}    psk=".*?"    psk="${PSK}"
ㄋ
    Create File    ${TMP1_CONF}    ${content}

    Run Process    echo ${Client_PASSWORD} | sudo -S cp ${TMP1_CONF} ${ORIG_CONF}    shell=True

    Log    ${ORIG_CONF}

Connect DUT SSID
    [Arguments]    ${SSID_mac}
    Wait Until Keyword Succeeds    3x    10s    Retry Connect DUT SSID    ${SSID_mac}

Retry Connect DUT SSID
    [Arguments]    ${SSID_mac}
    ${output}=	Run    echo ${Client_PASSWORD} | sudo -S service NetworkManager stop
    sleep    10
    ${output}=	Run    echo ${Client_PASSWORD} | sudo -S ip link set ${IFACE} up
    sleep    10
    #Log To Console	${output}
    ${output}=	Run    echo ${Client_PASSWORD} | sudo killall wpa_supplicant
    #Log To Console	${output}ㄋ
    ${output}=	Run    echo ${Client_PASSWORD} | sudo rm -rf /var/run/wpa_supplicant
    ${output}=	Run    echo ${Client_PASSWORD} | sudo wpa_supplicant -B -i ${IFACE} -c ${conf_PATH} -D nl80211
    #Log To Console	${output}
    Sleep          15
    ${output}=     Run    iw ${IFACE} link    
    Log            ${output}
    sleep   3
    Should Contain    ${output}    Connected to ${SSID_mac}
    Run    echo ${Client_PASSWORD} | sudo dhclient ${IFACE}
    Sleep          3

Check SSID Authentication
    ${output}=    Run    echo ${Client_PASSWORD} | sudo -S nmcli dev wifi list | grep ${Changed_2G_SSID}
    # Should Contain    ${output}    WPA3
    # Should Contain    ${output}    WPA2
    Log To Console    ${output}
    Log    ${output}

Set DUT 5G and 6G channel to be scannable
    Wait Until Keyword Succeeds    3x    10s    Retry Set DUT 5G and 6G channel to be scannable

Retry Set DUT 5G and 6G channel to be scannable
    Run Keyword And Ignore Error    Close All Browsers
    Login GUI    ${HOST}
    Click Element    xpath=//*[@id="menu_basic_setting"]
    sleep    3
    Click Element    xpath=//*[@id="menu_basic_setting_wlan"]
    sleep    3
    Click Element    xpath=//*[@id="tab_wifi_adv_allinone"]
    sleep    3
    Select From List By Value    id=wifi_channel_select5    40
    Select From List By Value    id=wifi_channel_select6    1
    Click Element    xpath=//*[@id="apply"]
    sleep    180
    Close All Browsers

Connect to ssid and Check client can ping DUT
    [Arguments]    ${SSID}
    #Wait Until Keyword Succeeds    3x    10s    Reconnect and Check client can get ip    ${SSID}
    Connect DUT wpa3 SSID    ${SSID}
    Check client can get ip
    
Reconnect and Check client can get ip
    [Arguments]    ${SSID}
    Connect DUT wpa3 SSID    ${SSID}
    Check client can get ip


Check client can get ip
    Wait Until Keyword Succeeds    3x    10s    Retry Check client can get ip

Retry Check client can get ip 
    # ${output}=     Run    ifconfig wlo1
    # Should Contain    ${output}    192.168.1.
    # ${output}=    Run    ping 8.8.8.8 -c 10
    # Should Contain    ${output}    ttl=
    ${output}=    Run    ping 192.168.1.1 -c 10
    Should Contain    ${output}    ttl=


SSH To Controller And Get default wifi password
    Wait Until Keyword Succeeds    3x    10s    Retry SSH To Controller And Get default wifi password

Retry SSH To Controller And Get default wifi password
    Open Connection    ${HOST}
    Login              ${USER}    ${SSH_PASSWORD}

    ${Default_PSK} =    Execute Command    cat /etc/config/wireless | grep -m1 "option key" | awk -F 'option key ' '{print $2}' | tr -d "'"
    ${2G_Guest_SSID} =    Execute Command    iwconfig ath0 | grep 'ESSID' | awk -F 'ESSID:' '{print $2}' | tr -d '" '
    Set Suite Variable    ${Default_PSK}
    Log    Default SSID PSK: ${Default_PSK}
    Close Connection

Defalut DUT/Agent and Wait setup
    Click Element    xpath=//*[@id="menu_management"]
    sleep    3
    Click Element    xpath=//*[@id="menu_management_settings"]
    sleep    3
    Click Element    xpath=//*[@id="lang_restore_btn"]
    sleep    3
    Click Element    xpath=//*[@id="confirm_dialog_confirmed"]
    sleep    300


Modify WPA Supplicant wpa3 Config
    [Arguments]    ${SSID}    ${BSSID}    ${PSK}
    Run Process    echo ${Client_PASSWORD} | sudo -S cp ${ORIG_wpa3_CONF} ${TMP_CONF}    shell=True

    ${content}=    OperatingSystem.Get File    ${TMP_CONF}

    ${content}=    Replace String Using Regexp    ${content}    ssid=".*?"    ssid="${SSID}"
    ${content}=    Replace String Using Regexp    ${content}    bssid=.*    bssid=${BSSID}
    ${content}=    Replace String Using Regexp    ${content}    psk=".*?"    psk="${PSK}"

    Create File    ${TMP1_wpa3_CONF}    ${content}

    Run Process    echo ${Client_PASSWORD} | sudo -S cp ${TMP1_wpa3_CONF} ${ORIG_wpa3_CONF}    shell=True

    Log    ${ORIG_wpa3_CONF}

Connect DUT wpa3 SSID
    [Arguments]    ${SSID_mac}
    Wait Until Keyword Succeeds    5x    10s    Retry Connect DUT wpa3 SSID    ${SSID_mac}

Retry Connect DUT wpa3 SSID
    [Arguments]    ${SSID_mac}
    ${output}=	Run    echo ${Client_PASSWORD} | sudo -S service NetworkManager stop
    sleep    10
    ${output}=	Run    echo ${Client_PASSWORD} | sudo -S ip link set ${IFACE} up
    sleep    10
    #Log To Console	${output}
    ${output}=	Run    echo ${Client_PASSWORD} | sudo killall wpa_supplicant
    #Log To Console	${output}
    ${output}=	Run    echo ${Client_PASSWORD} | sudo rm -rf /var/run/wpa_supplicant
    ${output}=	Run    echo ${Client_PASSWORD} | sudo wpa_supplicant -B -i ${IFACE} -c ${conf_wpa3_PATH} -D nl80211
    #Log To Console	${output}
    Sleep          15
    ${output}=     Run    iw ${IFACE} link    
    Log            ${output}
    sleep   3
    Should Contain    ${output}    Connected to ${SSID_mac}
    #Run    echo ${Client_PASSWORD} | sudo dhclient ${IFACE}
    Run    echo ${Client_PASSWORD} | sudo ifconfig ${IFACE} 192.168.1.198 netmask 255.255.255.0
    Sleep          3

Login Wizard GUI
    [Arguments]    ${DUT_IP}
    Open browser    http://${DUT_IP}    
    sleep    3
    Input Text    xpath=//*[@id="acnt_username"]    admin
    sleep    1
    Input Text    xpath=//*[@id="acnt_passwd"]    admin
    sleep    1
    Click Element    xpath=//*[@id="myButton"]
    sleep    8
    
Check Wizard
    Login Wizard GUI    ${HOST}
    ${result}=  Run Keyword And Return Status    Wait Until Element Is Visible    xpath=//*[@id="lang_have_read_and_agree"]    timeout=10
    Run Keyword If    '${result}'=='True'    Setup Wizard
    Close All Browsers

Setup Wizard
    Wait Until Keyword Succeeds    3x    10s    Retry Setup Wizard

Retry Setup Wizard
    Run Keyword And Ignore Error    Close All Browsers
    Login Wizard GUI    ${HOST}
    Click Element    xpath=//*[@id="lang_have_read_and_agree"]
    sleep    5
    Click Element    xpath=//*[@id="ml-agree"]
    sleep    5
    Click Element    xpath=//*[@id="router-mode-card"]
    Click Element    xpath=//*[@id="ml-next"]
    sleep    5

    Click Element    xpath=//*[@id="ml-next"]
    sleep    5
    Click Element    xpath=//*[@id="ml-next"]
    sleep    5
    Click Element    xpath=//*[@id="switch_layout_enable_mesh_btn"]
    sleep    5
    Click Element    xpath=//*[@id="ml-next"]
    sleep    5
    Click Element    xpath=//*[@id="ml-next"]
    sleep    5

    #Execute Javascript    document.body.style.zoom='0.5'
    Input Text    xpath=//*[@id="new_pwd"]    admin
    Input Text    xpath=//*[@id="confirm_pwd"]    admin

    Click Element    xpath=//*[@id="ml-next"]
    sleep    5

    Click Element    xpath=//*[@id="ml-apply"]
    sleep    180
    Click Element    xpath=//*[@id="btn-redirect"]
    sleep    5
    Wait Until Element Is Visible    xpath=//*[@id="acnt_username"]    timeout=60


Check Wizard with mesh disabled
    Login Wizard GUI    ${HOST}
    ${result}=  Run Keyword And Return Status    Wait Until Element Is Visible    xpath=//*[@id="lang_have_read_and_agree"]    timeout=10
    Run Keyword If    '${result}'=='True'    Setup Wizard with mesh disabled
    Close All Browsers

Setup Wizard with mesh disabled
    Wait Until Keyword Succeeds    3x    10s    Retry Setup Wizard with mesh disabled

Retry Setup Wizard with mesh disabled
    Run Keyword And Ignore Error    Close All Browsers
    Login Wizard GUI    ${HOST}
    Click Element    xpath=//*[@id="lang_have_read_and_agree"]
    sleep    5
    Click Element    xpath=//*[@id="ml-agree"]
    sleep    5
    Click Element    xpath=//*[@id="router-mode-card"]
    Click Element    xpath=//*[@id="ml-next"]
    sleep    5

    Click Element    xpath=//*[@id="ml-next"]
    sleep    5
    Click Element    xpath=//*[@id="ml-next"]
    sleep    5
    Click Element    xpath=//*[@id="ml-next"]
    sleep    5
    Click Element    xpath=//*[@id="ml-next"]
    sleep    5

    #Execute Javascript    document.body.style.zoom='0.5'
    Input Text    xpath=//*[@id="new_pwd"]    admin
    Input Text    xpath=//*[@id="confirm_pwd"]    admin

    Click Element    xpath=//*[@id="ml-next"]
    sleep    5

    Click Element    xpath=//*[@id="ml-apply"]
    sleep    180
    Click Element    xpath=//*[@id="btn-redirect"]
    sleep    5
    Wait Until Element Is Visible    xpath=//*[@id="acnt_username"]    timeout=60













Login GUI
    [Arguments]    ${DUT_IP}
    Open browser    http://${DUT_IP}    
    sleep    3
    Input Text    xpath=//*[@id="acnt_username"]    admin
    sleep    1
    Input Text    xpath=//*[@id="acnt_passwd"]    admin
    sleep    1
    Click Element    xpath=//*[@id="myButton"]
    sleep    30
    Wait Until Element Is Visible    xpath=//*[@id="menu_dashboard"]    timeout=60
    Execute Javascript    document.body.style.zoom='0.3'
    sleep    1

Disable Mesh
    Login GUI    ${HOST}
    Click Element    xpath=//*[@id="menu_basic_setting"]
    sleep    3
    Click Element    xpath=//*[@id="menu_basic_setting_wlan"]
    sleep    3
    Click Element    xpath=//*[@id="tab_mesh"]
    sleep    3
    Click Element    xpath=//*[@id="switch_layout_enable_btn"]
    sleep    3
    Click Element    xpath=//*[@id="apply"]
    sleep    180   
    Close All Browsers    

Disable the switch port connected to the agent
    ${banner}=    Open Telnet Connection    ${Switch_HOST}    ${Switch_PORT}
    Log To Console    \n--- BANNER ---\n${banner}\n
    ${out}=    telnet_command    ethctl eth0 phy-power down
    Log To Console    \n--- IFCONFIG ---\n${out}\n
    telnet_exec_command
    sleep    60

Enable SSH 
    Wait Until Keyword Succeeds    3x    10s    Retry Enable SSH 

Retry Enable SSH
    Run Keyword And Ignore Error    Close All Browsers    
    Login GUI    ${HOST}
    Click Element    xpath=//*[@id="menu_adv_setting"]
    sleep    5
    Click Element    xpath=//*[@id="menu_adv_setting_ssh"]
    sleep    15
    ${status}=    Get Element Attribute    id=ssh_enabled    value
    Run Keyword If    '${status}' == '0'    Click ssh button

Click ssh button    
    Click Element    xpath=//*[@id="switch_layout_ssh_enabled"]
    sleep    5
    Click Element    xpath=//*[@id="apply"]
    sleep    5
    Handle Alert
    sleep    30
    Close All Browsers    

Change SSID/Authentication/Key
    Click Element    xpath=//*[@id="menu_basic_setting"]
    sleep    3
    Click Element    xpath=//*[@id="menu_basic_setting_wlan"]
    sleep    3
    Input Text    xpath=//*[@id="2g_ssid"]    ${Changed_2G_SSID}
    sleep    3
    Input Text    xpath=//*[@id="2g_wpa_key"]    ${Changed_common_PSK}
    sleep    3
    Select From List By Value    id=authtype_2g    wpa3
    Input Text    xpath=//*[@id="5g_ssid"]    ${Changed_5G_SSID}
    sleep    3
    Input Text    xpath=//*[@id="5g_wpa_key"]    ${Changed_common_PSK}
    sleep    3
    Select From List By Value    id=authtype_5g    wpa3
    Input Text    xpath=//*[@id="6g_ssid"]    ${Changed_6G_SSID}
    sleep    3
    Input Text    xpath=//*[@id="6g_wpa_key"]    ${Changed_common_PSK}
    sleep    3
    Select From List By Value    id=authtype_6g    wpa3
    sleep    3
    Execute Javascript    document.body.style.zoom='0.2'
    sleep    5
    Click Element    xpath=//*[@id="apply"]
    sleep    300

Change common/MLO SSID/Authentication/Key
    Click Element    xpath=//*[@id="menu_basic_setting"]
    sleep    3
    Click Element    xpath=//*[@id="menu_basic_setting_wlan"]
    sleep    3
    Input Text    xpath=//*[@id="commong_ssid"]    ${Changed_common_SSID}
    sleep    3
    Input Text    xpath=//*[@id="commong_wpa_key"]    ${Changed_common_PSK}
    sleep    3
    Select From List By Value    id=authtype_commong    mixed3
    sleep    3
    Click Element    xpath=//*[@id="apply"]
    sleep    300
    
Change Mode/Channel/Bandwidth
    
    Click Element    xpath=//*[@id="menu_basic_setting"]
    sleep    3
    Click Element    xpath=//*[@id="menu_basic_setting_wlan"]
    sleep    3
    Click Element    xpath=//*[@id="tab_wifi_adv_allinone"]
    sleep    3
    Execute Javascript    document.body.style.zoom='0.2'
    sleep    5
    ##-----2G-----
    Select From List By Value    id=wifi_mode_select2    ax
    Select From List By Value    id=wifi_bw_select2    40only
    Select From List By Value    id=wifi_channel_select2    1
    ##-----5G-----
    Select From List By Value    id=wifi_mode_select5    ax
    Select From List By Value    id=wifi_bw_select5    204080
    Select From List By Value    id=wifi_channel_select5    36
    ##-----6G-----
    Select From List By Value    id=wifi_mode_select6    ax
    Select From List By Value    id=wifi_bw_select6    mixed160
    Select From List By Value    id=wifi_channel_select6    45

    Click Element    xpath=//*[@id="apply"]
    sleep    180

Change MLO Mode/Channel/Bandwidth
    
    Click Element    xpath=//*[@id="menu_basic_setting"]
    sleep    3
    Click Element    xpath=//*[@id="menu_basic_setting_wlan"]
    sleep    3
    Click Element    xpath=//*[@id="tab_wifi_adv_allinone"]
    sleep    3
    Execute Javascript    document.body.style.zoom='0.2'
    sleep    5
    ##-----2G-----
    Select From List By Value    id=wifi_bw_select2    40only
    Select From List By Value    id=wifi_channel_select2    1
    ##-----5G-----
    Select From List By Value    id=wifi_bw_select5    204080
    Select From List By Value    id=wifi_channel_select5    36
    ##-----6G-----

    Select From List By Value    id=wifi_bw_select6    mixed160
    Select From List By Value    id=wifi_channel_select6    45

    Click Element    xpath=//*[@id="apply"]
    sleep    180

Disable MLO and common ssid
    Click Element    xpath=//*[@id="menu_basic_setting"]
    sleep    3
    Click Element    xpath=//*[@id="menu_basic_setting_wlan"]
    sleep    3
    Click Element    xpath=//*[@id="switch_layout_single_ssid_enable"]
    sleep    3
    Execute Javascript    document.body.style.zoom='0.3'
    sleep    5
    Click Element    xpath=//*[@id="apply"]
    sleep    180   


Enable MLO
    Click Element    xpath=//*[@id="menu_basic_setting"]
    sleep    3
    Click Element    xpath=//*[@id="menu_basic_setting_wlan"]
    sleep    3
    Click Element    xpath=//*[@id="switch_layout_MLO_enable"]
    sleep    3
    Click Element    xpath=//*[@id="apply"]
    sleep    300

# Create WPA Supplicant Config
#     ${config}=    Catenate
#     ...    ctrl_interface=/var/run/wpa_supplicant\n
#     ...    update_config=0\n
#     ...    country=TW\n
#     ...    \n
#     ...    network={\n
#     ...        ssid="${5G_SSID2}"\n
#     ...        bssid=${BSSID}\n
#     ...        psk="${PSK}"\n
#     ...    }\n
#     Create File    ${Config_name}    ${config}
#     Log File       ${Config_name}
