<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%--
	제품이 셋팅되고 난후 함수 fnActionAfterSetProd()
	<jsp:param name="show_field" value="s_brand, s_prod"/>					=== 보여질 필드 
	<jsp:param name="required_field" value="s_brand, s_prod"/>				=== 필수 필드
	<jsp:param name="hide_field" value="s_brand_code, s_brand_line_code"/>	=== 숨길 필드
	<jsp:param name="s_prod_status_cd" value="01"/>							=== 제품 상태 코드
	<jsp:param name="readonly_yn" value="Y"/>								=== readonly 처리 여부
--%>
<c:set var="prod_readonly_yn" value="${param.readonly_yn == null ? 'Y' : param.readonly_yn}"/>
<c:set var="p_prod_status_cd" value="${param.s_prod_status_cd == '' ? '' : param.s_prod_status_cd }"/>
<c:set var="p_order_genuine_yn" value="${param.s_order_genuine_yn}"/>

<input type="hidden" id="s_prod_status_flag" name="s_prod_status_flag" value="${p_prod_status_cd}">
<input type="hidden" id="s_order_genuine_yn" name="s_order_genuine_yn" value="${p_order_genuine_yn}">

<script type="text/javascript">
	var prodPopupParam = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=760, left=0, top=0";
	var prod_readonly_yn = "${prod_readonly_yn}";
	var execMethod = 'fnActionAfterSetProd()';
	
	$(document).ready(function(){
	});
	
	function setProdInfo(data){
			$M.setValue("s_brand_code", data.brand_code);
			$M.setValue("s_prod_code", data.prod_code);
			$M.setValue("s_prod_name", data.prod_name);
			
			$("#s_brand_code").trigger("change", $M.setValue("set_before_line_code", data.brand_line_code));
		try{
			eval(execMethod);
		} catch(e){
			return false;
		}
	}
	
	function _goSearchProd(){
		
		var prodStatParam = "${p_center_statud_cd}";
		
		if($M.validation(document.main_form, {field: ['s_prod_code']}) == false){
			return;
		}
		
		var param = {
			's_brand_code'			: $M.getValue('s_brand_code'),
			's_brand_line_code'		: $M.getValue('s_brand_line_code'),
			's_prod_code'			: $M.getValue('s_prod_code'),
			's_prod_use_type_cd'	: $M.getValue('s_prod_use_type_cd'),
			's_order_genuine_yn'    : $M.getValue('s_order_genuine_yn'),
			's_prod_status_cd'		: ($M.getValue('s_prod_status_cd') == '') ? prodStatParam : $M.getValue('s_prod_status_cd'),
			'load_search'			: 'Y',
		};
		
		$M.goNextPageAjax("/com/com0103/search", $M.toGetParam(param), {method : 'get'},
			function(result){
				if(result.success){
					var list = result.list;
					switch(list.length){
						case 0 : break;
						case 1 : 
							var list = list[0];
							$M.setValue("s_brand_code", list.brand_code);
							$M.setValue("s_prod_code", list.prod_code);
							$M.setValue("s_prod_name", list.prod_name);
							//브랜드라인할당
							$("#s_brand_code").trigger("change", $M.setValue("set_before_line_code", list.brand_line_code));
							
							try { eval(execMethod); } catch(e) {return false;}
							
							break;
						default :
							param.readonly_yn = prod_readonly_yn;
							$M.goNextPage("/com/com0103", $M.toGetParam(param), {popupStatus : prodPopupParam});
							break;
					}
				}
			}
		);
	}
	
	function prodEnter(fieldObj){
		if(event.keyCode == 13){
			_goSearchProd();
		}
	}

</script>
<c:set var="prod_show_f" value="${param.show_field}"/><%-- 보여줄 필드 --%>
<c:set var="prod_req_f" value="${param.required_field}"/><%-- 필수 필드 --%>
<c:set var="prod_hide_f" value="${param.hide_field}"/><%-- 감추는 필드 --%>

${ param.show_tr_yn eq 'N' ? '' : '<tr>' }
<c:if test="${fn:contains(prod_show_f, 's_brand')}">
<th ${param.show_tr_yn eq 'N' ? 'style="background: none;"' : '' }>브랜드 ${fn:contains(prod_req_f, 's_brand') ? '<span class=\"star\">*</span>' : '' }</th>
<td>
	<div>
		<c:if test="${fn:contains(prod_hide_f, 's_brand_code') == false}">
			<select  style="width: 90px" id="s_brand_code" alt="브랜드" name="s_brand_code" ${fn:contains(prod_hide_f, 's_brand_line_code') == false ? 'onchange="goSearchBrandLine(this);"' : ''} ${fn:contains(prod_req_f, 's_brand') ? 'required="required"' : '' }>
				<option value="">- 전체 -</option>
				<c:forEach var="row" items="${brandList}">
					<option value="${row.cate_code }">${row.cate_name }</option>
				</c:forEach>									
			</select>
		</c:if>
		<c:if test="${fn:contains(prod_hide_f, 's_brand_line_code') == false}">
			<select id="s_brand_line_code" alt="브랜드라인" name="s_brand_line_code" style="width: 120px;" ${fn:contains(prod_req_f, 's_brand') ? 'required="required"' : '' }>
				<option value="">- 전체 -</option>
			</select>
		</c:if>
	</div>
</td>
</c:if>
<c:if test="${fn:contains(prod_show_f, 's_prod')}">
<th ${param.show_tr_yn eq 'N' && fn:contains(prod_show_f, 's_brand') == false? 'style="background: none;"' : '' }>제품코드/명 ${fn:contains(prod_req_f, 's_prod') ? '<span class=\"star\">*</span>' : '' }</th>
<td>
	<div>
		<input type="text" id="s_prod_code" name="s_prod_code" class="textbox-re" alt="제품코드/명" placeholder="코드/명" style="width:95px;" onfocus="javascript:$M.clearValue({field:['s_prod_code', 's_prod_name']});" minlength="2" ${fn:contains(prod_req_f, 's_prod') ? 'required="required"' : ''} onkeydown="javascript:prodEnter(this);">
		<a href="#" class="icon-search" onclick="javascript:openSearchProdPanel(prodPopupParam, prod_readonly_yn);">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</a>
		<input type="text" id="s_prod_name" name="s_prod_name" class="textbox-re readonly" placeholder="제품명" style="width:140px;" readonly="readonly">
	</div>
</td>
</c:if>
${ param.show_tr_yn eq 'N' ? '' : '</tr>' }