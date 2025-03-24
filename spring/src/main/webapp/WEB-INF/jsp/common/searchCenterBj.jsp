<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%-- 센터/CC가 셋팅되고 난뒤 실행할 함수 정의 각페이지에서 기술
	- 센터 : fnActionAfterSetCenter();
	- CC : fnActionAfterSetBj();  
	### param 설명 ###
-- <jsp:param name="show_field" value="s_sale_team, s_center"/> 	==> 보일필드 기술  s_sale_team : 영업팀/영업사원 항상 같이 나옴, s_center : 센터타입/센터 같이 나옴, s_bj : bj 
-- <jsp:param name="required_field" value="s_sale_team,s_center"/> 	==> 필수필드 기술
-- <jsp:param name="hide_field" value="s_center_type_cd"/> 			==> show_field 에 같이 나오는(s_sale_team, s_center)필드 중에 감출 필드 기술 	
-- <jsp:param name="show_tr_yn" value="N"/>							==> 'N'을 주면 상/하단에 <tr></tr>을 만들지 않음
-- <jsp:param name="user_info_set" value="N"/>						==> 'N'을 주면 로그인 정보를 자동으로 셋팅하지 않음. 값을 넣고 싶을때에는 param으로 주어야함
-- <jsp:param name="s_sale_team_cd" value="3001"/>					==> user_info_set='N' 일때 param값으로 셋팅함
-- <jsp:param name="readonly_yn" value="Y"/>                        ==> readonly_yn 값에 따라 부모창에서 입력한 값을 readonly 시킴
-- <jsp:param name="s_center_status_cd" value="01"/>                ==> 01 : 정상, 02 : 중지,03 : 폐업, 04 : 삭제
-- <jsp:param name="s_bj_status_cd" value="01"/>                    ==> 01 : 정상, 02 : 중지,03 : 폐업, 04 : 삭제
--%>

<%-- 셋팅할 변수 초기화 --%>
<c:set var="readonly_yn" value="${param.readonly_yn == null ? 'Y' : param.readonly_yn}"/>

<c:set var="p_sale_team_cd" value=""/>
<c:set var="p_sale_user_id" value=""/>
<c:set var="p_center_type_cd" value=""/>
<c:set var="p_center_code" value=""/>
<c:set var="p_center_name" value=""/>

<c:set var="p_center_status_cd" value="${param.s_center_status_cd == null ? '' : param.s_center_status_cd }"/>
<c:set var="p_bj_status_cd" value="${param.s_bj_status_cd == null ? '' :  param.s_bj_status_cd}"/>

<c:set var="p_new_yn" value="${param.s_new_yn}"/>
<c:set var="p_incentive" value="${param.s_incentive_yn}"/>

<input type="hidden" id="s_incentive_yn" name="s_incentive_yn" value="${p_incentive}">

<input type="hidden" id="s_new_yn" name="s_new_yn" value="${p_new_yn}">
<input type="hidden" id="s_center_status_flag" name="s_center_status_flag" value="${p_center_status_cd}">
<input type="hidden" id="s_bj_type_flag" name="s_bj_type_flag" value="${p_bj_status_cd}">

<c:choose>
	<%-- 페이지에서 받은게 있으면 그걸로 셋팅 --%>
	<c:when test="${param.user_info_set eq 'N' }">		
		<c:set var="p_sale_team_cd" value="${param.s_sale_team_cd}"/>
		<c:set var="p_sale_user_id" value="${param.s_sale_user_id}"/>
		<c:set var="p_center_type_cd" value="${param.s_center_type_cd}"/>
		<c:set var="p_center_code" value="${param.s_center_code}"/>
		<c:set var="p_center_name" value="${param.s_center_name}"/>
	</c:when>
	<%-- 센터사용자 셋팅 (영업팀/영업사원은 할당된 것으로 가고, 없으면 선택불가 --%>
	<c:when test="${SecureUser.centerUser}">
		<c:set var="p_sale_team_disabled" value="Y"/>
		<c:set var="p_sale_team_cd" value="${SecureUser.center_sale_team_cd}"/>
		<c:set var="p_sale_user_id" value="${SecureUser.sale_user_id}"/>
		<c:set var="p_center_type_cd" value="${SecureUser.center_type_cd}"/>
		<c:set var="p_center_code" value="${SecureUser.center_code}"/>
		<c:set var="p_center_name" value="${SecureUser.center_name}"/>	
	</c:when>
	<%-- 본사영업팀사용자 셋팅 (할당 팀꺼만 가능) --%>
	<c:when test="${SecureUser.baseSaleUser }">
		<c:set var="p_sale_team_disabled" value="Y"/>
		<c:set var="p_sale_team_cd" value="${SecureUser.sale_team_cd}"/>
		<c:set var="p_sale_user_id" value="${SecureUser.user_id}"/>
	</c:when>
</c:choose>

<!--  -->
<c:set var="absolute_field" value="${param.absolute_field }"/>
<c:if test="${fn:contains(absolute_field, 's_sale_team')}">
	<c:set var="p_sale_team_cd" value="${param.s_sale_team_cd}"/>
</c:if>
<c:if test="${fn:contains(absolute_field, 's_sale_user_id')}">
	<c:set var="p_sale_user_id" value="${param.s_sale_user_id}"/>
</c:if>
<c:if test="${fn:contains(absolute_field, 's_center_type_cd')}">
	<c:set var="p_center_type_cd" value="${param.s_center_type_cd}"/>
</c:if>
<c:if test="${fn:contains(absolute_field, 's_center_code')}">
	<c:set var="p_center_code" value="${param.s_center_code}"/>
</c:if>
<c:if test="${fn:contains(absolute_field, 's_center_name')}">
	<c:set var="p_center_name" value="${param.s_center_name}"/>
</c:if>

<script type="text/javascript">
	$(document).ready(function(){		
	});
	
	var centerPopupParam = 'scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=850, height=700, left=0, top=0';
	var bjPopupParam = 'scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1180, height=760, left=0, top=0';
	var execMethod = 'fnActionAfterSetCenter()';
	var readonly_yn = "${readonly_yn}";
	var absoluteFields = "${absolute_field}";
	var absoluteFieldName = absoluteFields.replace(/ /gi, "").split(",");
	
	function setCenterBjInfo(param) {
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
		
		$M.setValue("after_set_id", param.after_set_id);
		// 셋팅되고 실행할 메소드 기술
		try { eval(execMethod); } catch(e) {return false;}
	}

	function _goSearchCenterBj(fieldName) {
		var url = (fieldName == 's_center_code') ? '/com/com0101' : '/com/com0102';
		var checkFiled = (fieldName == 's_center_code') ? ['s_center_code'] : ['s_bj_code'];
		var popupParam = (fieldName == 's_center_code') ? centerPopupParam : bjPopupParam;
		execMethod = (fieldName == 's_center_code') ? 'fnActionAfterSetCenter()' : 'fnActionAfterSetBj()';
		// 센
		var centerStatParam = "${p_center_status_cd}"; 
		var bjStatParam = "${p_bj_status_cd}";
		var centerNewYN = "${p_new_yn}";
		var incentiveYN = "${p_incentive}";
		
		if($M.validation(document.main_form, {field:checkFiled}) == false) {
			return;
		}
		
		var param = {
			's_sale_team_cd'		: $M.getValue('s_sale_team_cd'),
			's_sale_user_info'		: $M.getValue('s_sale_user_info'),
			's_center_type_cd'		: $M.getValue('s_center_type_cd'),
			's_center_code'			: $M.getValue('s_center_code'),		
			's_bj_code'				: $M.getValue('s_bj_code'),
			's_center_status_cd'	: centerStatParam,			
			's_bj_status_cd'		: bjStatParam,
			's_new_yn'				: centerNewYN,
			's_incentive_yn'		: incentiveYN,
			'load_search'			: 'Y',
			'sale_team_disabled'  	: 'Y',
			's_esthetic_yn'			: $M.getValue('s_esthetic_yn')
		};
		
		$M.goNextPageAjax(url + '/search', $M.toGetParam(param) , {method : 'get'},
			function(result) {
				if(result.success) {
					var list = result.list;
					
					switch(list.length){
						case 0 :  
							
							$M.setHiddenValue("s_center_bj_flag",'N');
							try { eval('fnActionNotSearch()');} catch(e) { return false; }
							
							break;
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
							// 셋팅되고 실행할 메소드 기술
							try { eval(execMethod); } catch(e) {return false;}
							
							break;
						default :
							param.readonly_yn = readonly_yn;
							$M.goNextPage(url, $M.toGetParam(param), {popupStatus : popupParam}); 
						break;
					}
				}
			}
		);
	}
	
	function enter(fieldObj) {
		var field = ['s_center_code', 's_bj_code' ];
		$.each(field, function() {
			if(fieldObj.name == this) {
				_goSearchCenterBj(this);
			}
		});
	}
	
	function _setSaleUser(fieldObj) {
		var checkField = ['s_center_type_cd', 's_center_code', 's_center_name', 's_bj_code', 's_bj_name'];
		
		$.each(absoluteFieldName, function(i, val){
			if($.inArray(val, checkField) > -1) {
				checkField.splice(i, 1);
			}
		});
		
		$M.clearValue({field:checkField});
		
		var param = 's_sale_team_cd=' + fieldObj.value;
		$M.goNextPageAjax('/com/com0101/searchSaleUser', param , {method : 'get'},
			function(result) {
				if(result.success) {					
					_setDefaultSaleUser(result.list);					
				}
			}
		);
	}
	
	function _setSaleTeam(fieldObj) {		
		var checkField = ['s_center_type_cd', 's_center_code', 's_center_name', 's_bj_code', 's_bj_name'];
		
		$.each(absoluteFieldName, function(i, val){
			if($.inArray(val, checkField) > -1) {
				checkField.splice(i, 1);
			}
		});
		
		$M.clearValue({field:checkField});
		$M.setValue("s_before_sale_user_info", fieldObj.value);
		
		if(fieldObj.value != '') {
			var values = fieldObj.value.split('#');

			$M.setValue('s_sale_team_cd', values[0]);
			$M.setValue('s_sale_user_id', values[1]);
			_setSaleUser($M.getComp('s_sale_team_cd'));
		} else {
			$M.setValue('s_sale_user_id', "");
		} 
	}
		
	
	function _setDefaultSaleUser(list) {
		
		var selObj = $M.getComp('s_sale_user_info');
		var beforeInfo = $M.getValue("s_before_sale_user_info");
		
		if(selObj.tagName == 'SELECT'){
			selObj.options.length = 0;		
			selObj.add(new Option("- 마케팅담당자 -", ""));
			if(list != null && list.length > 0){
				$.each(list, function () {
					var val = this.sale_team_cd + '#' + this.sale_user_id;
					selObj.add(new Option(this.sale_user_name, val));
			 	});
			}
			
			if(beforeInfo != ''){
				$M.setValue('s_sale_user_info', beforeInfo);
				$M.setValue('s_before_sale_user_info', '');
			} else if($M.getValue('s_sale_user_info') == ''){
				$M.setValue('s_sale_user_id', '');
			} 
		}
	}
	
	function _doActionAfterSetInfo() {
		
	}
</script>
<c:set var="show_f" value="${param.show_field}"/><%-- 보여줄 필드 --%>
<c:set var="req_f" value="${param.required_field}"/><%-- 필수 필드 --%>
<c:set var="hide_f" value="${param.hide_field}"/><%-- 감추는 필드 --%>

${ param.show_tr_yn eq 'N' ? '' : '<tr>' }
	<c:if test="${fn:contains(show_f, 's_sale_team')}">
	<th id="sale_th" ${param.show_tr_yn eq 'N' ? 'class="remove-bar"' : '' }>마케팅팀/마케팅담당자 ${fn:contains(req_f, 's_sale_team') ? '<span class=\"star\">*</span>' : '' }</th>
	<td><c:if test="${fn:contains(hide_f, 's_sale_team_cd') == false}">
			<%-- select readonly 대신 객체를 바꿈 --%>			
			<c:choose>
				<c:when test="${p_sale_team_cd ne '' || p_sale_team_disabled eq 'Y'}">
					<input type="text" id="s_sale_team_name" name="s_sale_team_name" class="textbox-re readonly" readonly="readonly" alt="마케팅팀" placeholder="-없음-" style="width:80px;" ${fn:contains(req_f, 's_sale_team') ? 'required="required"' : '' } value="${codeNameMap['SALE_TEAM'][p_sale_team_cd] }">
					<input type="hidden" id="s_sale_team_cd" name="s_sale_team_cd" value="${p_sale_team_cd}">
				</c:when>
				<c:otherwise>
					<select id="s_sale_team_cd" name="s_sale_team_cd" style="width: 80px;" alt="마케팅팀" ${fn:contains(req_f, 's_sale_team') ? 'required="required"' : '' } onchange="javascript:_setSaleUser(this);">
					<option value="">- 마케팅팀 -</option>
					<c:forEach var="codeList" items="${codeMap['SALE_TEAM']}">
						<option value="${codeList.code_value}" ${codeList.code_value eq p_sale_team_cd ? "selected='selected'" : ""}>${codeList.code_name}</option>
					</c:forEach>
					</select>
				</c:otherwise>
			</c:choose>
		</c:if>
		<c:if test="${fn:contains(hide_f, 's_sale_user_id') == false}">
			<%-- select readonly 대신 객체를 바꿈 --%>
			<c:choose>
				<c:when test="${p_sale_user_id ne '' || p_sale_team_disabled eq 'Y'}">
					<input type="text" id="s_sale_user_info_name" name="s_sale_user_info_name" class="textbox-re readonly" readonly="readonly" alt="마케팅담당자" placeholder="-없음-" style="width:90px;" ${fn:contains(req_f, 's_sale_team') ? 'required="required"' : '' } value="${saleUserNameMap[p_sale_user_id].sale_user_name }">
					<input type="hidden" id="s_sale_user_info" name="s_sale_user_info"  value="${p_sale_team_cd}#${p_sale_user_id }">
				</c:when>
				<c:otherwise>
					<select id="s_sale_user_info" name="s_sale_user_info" style="width: 90px;" alt="마케팅담당자" ${fn:contains(req_f, 's_sale_team') ? 'required="required"' : '' } onchange="javascript:_setSaleTeam(this);">
						<option value="">- 마케팅담당자 -</option>
						<c:forEach var="userList" items="${saleUserList}">
							<option value="${userList.sale_team_cd }#${userList.sale_user_id}" ${userList.sale_user_id eq p_sale_user_id ? "selected='selected'" : ""}>${userList.sale_user_name}</option>
						</c:forEach>
					</select>
				</c:otherwise>
			</c:choose>
			<input type="hidden" id="s_sale_user_id" name="s_sale_user_id" value="${p_sale_user_id }" alt="마케팅담당자"/>
		</c:if>
	</td>
	</c:if>
	<c:if test="${fn:contains(show_f, 's_center')}">
	<th id="center_th">센터코드/명 ${fn:contains(req_f, 's_center') ? '<span class=\"star\">*</span>' : '' }</th>
	<td><c:if test="${fn:contains(hide_f, 's_center_type_cd') == false}">
			<%-- select readonly 대신 객체를 바꿈 --%>
			<c:if test="${p_center_type_cd eq '' }">
			<select id="s_center_type_cd" name="s_center_type_cd" style="width: 64px;" alt="센터타입"  onchange="javascript:$M.clearValue({field:['s_center_code', 's_center_name', 's_bj_code', 's_bj_name', 's_cust_code', 's_cust_name']});">
				<option value="">- 타입 -</option>
				<c:forEach var="codeList" items="${codeMap['CENTER_TYPE']}">
					<option value="${codeList.code_value}" ${codeList.code_value eq p_center_type_cd ? "selected='selected'" : ""}>${codeList.code_name}</option>
				</c:forEach>
			</select></c:if>
			<c:if test="${p_center_type_cd ne '' }">
			<input type="text" id="s_center_type_name" name="s_center_type_name" class="textbox-re readonly" readonly="readonly" alt="센터타입" placeholder="-없음-" style="width:64px;" value="${codeNameMap['CENTER_TYPE'][p_center_type_cd] }">
			<input type="hidden" id="s_center_type_cd" name="s_center_type_cd" value="${p_center_type_cd}">
			</c:if>
		</c:if>
		<input type="text" id="s_center_code" name="s_center_code" class="textbox-re ${p_center_code ne '' ? 'readonly' : '' }" alt="센터코드/명" placeholder="코드/명" style="width:70px;" ${fn:contains(req_f, 's_center') ? 'required="required"' : '' } value="${p_center_code }" ${p_center_code eq '' ? 'onfocus="javascript:$M.clearValue({field:[\'s_center_code\', \'s_center_name\', \'s_bj_code\', \'s_bj_name\']});"' : 'readonly="readonly"' }  minlength="2" >
		<a href="#" id="s_center_find_btn" class="icon-search" ${ (!SecureUser.centerUser) && (p_center_code eq '' || absolute_field ne '') ? 'onclick="javascript:openSearchCenterPanel(centerPopupParam, readonly_yn);"' : '' }" >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</a>
		<input type="text" id="s_center_name" name="s_center_name" class="textbox-re readonly" placeholder="센터명" alt="센터명" style="width:80px;" readonly="readonly" ${fn:contains(req_f, 's_center') ? 'required="required"' : '' } value="${p_center_name }">
	</td>
	</c:if>	
	<c:if test="${fn:contains(show_f, 's_bj')}">
	<th id="bj_th">CC코드/명 ${fn:contains(req_f, 's_bj') ? '<span class=\"star\">*</span>' : '' }</th>
	<td>
		<input type="text" id="s_bj_code" name="s_bj_code" class="textbox-re" alt="CC코드/명" placeholder="코드/명" value="${param.s_bj_code }" style="width:70px;" ${fn:contains(req_f, 's_bj') ? 'required="required"' : '' } onfocus="javascript:$M.clearValue({field:['s_bj_code', 's_bj_name', 's_cust_code', 's_cust_name']});" minlength="2">	
		<a href="#" id="s_bj_find_btn" class="icon-search" onclick="javascript:openSearchBJPanel(bjPopupParam, readonly_yn);">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</a>
		<input type="text" id="s_bj_name" name="s_bj_name" class="textbox-re readonly" alt="CC코드/명" placeholder="CC명" style="width:70px;" readonly="readonly" value="${param.s_bj_name }">
	</td>
	</c:if>
${ param.show_tr_yn eq 'N' ? '' : '</tr>' }