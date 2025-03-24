<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="cust_readonly_yn" value="${param.readonly_yn == null ? 'Y' : param.readonly_yn}"/>

<c:set var="p_center_status_cd" value="${param.s_center_status_cd}"/>
<c:set var="p_bj_status_cd" value="${param.s_bj_status_cd}"/>
<c:set var="p_cust_status_cd" value="${param.s_cust_status_cd}"/>

<input type="hidden" id="s_cust_center_status_flag" name="s_cust_center_status_flag" value="${p_center_status_cd}">
<input type="hidden" id="s_cust_bj_status_flag" name="s_cust_bj_status_flag" value="${p_bj_status_cd}">
<input type="hidden" id="s_cust_cust_status_flag" name="s_cust_cust_status_flag" value="${p_cust_status_cd}">


<script type="text/javascript">
	var custPopupParam = 'scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1380, height=800, left=0, top=0';
	var cust_readonly_yn = "${cust_readonly_yn}";
	var execMethod = 'fnActionAfterSetCust()';
	
	function setCustInfo(param){
		$M.setValue('s_sale_team_cd', param.sale_team_cd);
		$M.setValue("s_before_sale_user_info", param.sale_team_cd + '#' + param.sale_user_id);
		$("#s_sale_team_cd").trigger("change");
		$M.setValue('s_sale_user_info', param.sale_team_cd + '#' + param.sale_user_id);
		$M.setValue('s_sale_user_id', param.sale_user_id);
		$M.setValue('s_center_type_cd', param.center_type_cd);
		$M.setValue('s_center_code', param.center_code);
		$M.setValue('s_center_name', param.center_name);		
		$M.setValue('s_bj_code', param.bj_code);
		$M.setValue('s_bj_name', param.bj_name);
		$M.setValue('s_cust_code', param.cust_code);	
		$M.setValue('s_cust_name', param.cust_name);	
		
		try { eval(execMethod); } catch(e) {return false;}
	}
	
	function _goSearchCust(){
		execMethod  = "fnActionAfterSetCust()";
		if($M.validation(document.main_form, {field: ['s_cust_code']}) == false){
			return;
		}

		var param = {
				's_sale_team_cd'		: $M.getValue('s_sale_team_cd'),
				's_sale_user_info'		: $M.getValue('s_sale_user_info'),
				's_sale_user_id'		: $M.getValue('s_sale_user_id'),
				's_center_type_cd'		: $M.getValue('s_center_type_cd'),
				's_center_code'			: $M.getValue('s_center_code'),		
				's_bj_code'				: $M.getValue('s_bj_code'),
				's_center_status_cd'	: $M.getValue('s_center_status_cd'),			
				's_bj_status_cd'		: $M.getValue('s_bj_status_cd'),
				's_cust_code'			: $M.getValue('s_cust_code'),
				'load_search'			: 'Y',
				's_center_status_cd'	: "${p_center_status_cd}",
				's_bj_status_cd'		: "${p_bj_status_cd}",
				's_cust_status_cd'		: "${p_cust_status_cd}",
				'readonly_yn'			: "${cust_readonly_yn}"
				
		}
		
		$M.goNextPageAjax("/com/com0113/search" , $M.toGetParam(param), {method : "GET"},
			function(result){
				if(result.success){
					var list = result.list;
					switch(list.length){
					case 0 : break; 
					case 1 :
						var list = list[0];
						$M.setValue('s_sale_team_cd', list.sale_team_cd);
						$M.setValue("s_before_sale_user_info", list.sale_team_cd + '#' + list.sale_user_id);
						$("#s_sale_team_cd").trigger("change");
						$M.setValue('s_sale_user_info', list.sale_team_cd + '#' + list.sale_user_id);
						$M.setValue('s_sale_user_id', list.sale_user_id);
						$M.setValue('s_center_code', list.center_code);							
						$M.setValue('s_center_name', list.center_name);							
						$M.setValue('s_center_type_cd', list.center_type_cd);							
						$M.setValue('s_bj_code', list.bj_code);
						$M.setValue('s_bj_name', list.bj_name);
						$M.setValue('s_cust_code', list.cust_code);
						$M.setValue('s_cust_name', list.cust_name);
						//셋팅하고 실행할 메소드
						try { eval(execMethod); } catch(e) {return false;}
						
						break;
					default :
						param.readonly_yn = cust_readonly_yn;
						$M.goNextPage('/com/com0113', $M.toGetParam(param), {popupStatus : custPopupParam});
					}
				}
			}
		);
		
	}
	
	function custEnter(fieldObj){
		if(event.keyCode == 13){
			_goSearchCust();
		}
	}
	
</script>
<c:set var="cust_req_f" value="${param.required_field}"/><%-- 필수 필드 --%>

${ param.show_tr_yn eq 'N' ? '' : '<tr>' }
<th ${param.show_tr_yn eq 'N' ? 'style="background: none;"' : '' }>고객코드/명${fn:contains(cust_req_f, 's_cust') ? '<span class=\"star\">*</span>' : '' }</th>
<td>
	<input type="text" id="s_cust_code" name="s_cust_code" class="textbox-re" alt="고객코드/명" placeholder="코드/명" style="width:70px;" minlength="2" ${fn:contains(cust_req_f, 's_cust') ? 'required="required"' : ''} onkeydown="javascript:custEnter(this);" onfocus="javascript:$M.clearValue({field:['s_cust_code', 's_cust_name']});">
	<a href="#" id="s_cust_find_btn" name="s_cust_find_btn" class="icon-search" onclick="javascript:openSearchCustPanel(custPopupParam, cust_readonly_yn);">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</a>
	<input type="text" id="s_cust_name" name="s_cust_name" class="textbox-re readonly" placeholder="고객명" style="width:110px;" readonly="readonly">
</td>
${ param.show_tr_yn eq 'N' ? '' : '</tr>' }