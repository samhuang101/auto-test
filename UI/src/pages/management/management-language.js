	page_tag='management_language'
	lang_tag='management_language'
	$(document).ready(function(){
		$.lang_load(lang_tag);
		page_initial()
	}); 

	function page_initial(){
		//Coding initial function here
		//get_obj_data(OBJ_LIST) 
		$("#language_select").val(localStorage.lang);
	} 
	function select_language_select() {
		const selector = document.getElementById('language_select');
		localStorage.lang = $("#language_select").val()
		selectedLanguage = selector.options[selector.selectedIndex].text;
		window.location.reload();
	}
