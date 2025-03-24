<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 재고관리 > HOMI관리 > null > 센터적정재고관리
-- 작성자 : 김인석
-- 최초 작성일 : 2020-02-21 17:06:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
	function fnClose() {
		if($M.getValue("saveChk") == 1) window.opener.goSearch();
		window.close();
	}
	
	function goSave() {
		var frm = document.main_form;
		if($M.validation(frm,) == false) { return;}
		$M.goNextPageAjaxSave(this_page+'/save', $M.toValueForm(frm) , {method : 'POST'},
			function(result) {
	    		if(result.success) {

	    			var param = {
	    					"s_part_no" :  $M.getValue("part_no"),
	    					"s_warehouse_cd" :  $M.getValue("warehouse_cd")
	    				};
    				
	    			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
	    				function(result) {
	    					if(result.success) {
		    					console.log("result.center_stock=>"+result.safe_stock);
	    						$M.setValue("center_stock",result.center_stock);
	    						$M.setValue("safe_stock",result.safe_stock);
	    						$M.setValue("saveChk",1);
	    					};
	    				}
	    			);
				}
			}
		); 
	}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" id="warehouse_cd" name="warehouse_cd" value="${param.s_warehouse_cd}" />
<input type="hidden" id="stock_dt" name="stock_dt" value="${inputParam.s_current_dt}"/>
<input type="hidden" id="saveChk" name="saveChk" />
<!-- 팝업 -->
	<div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <h2>센터적정재고관리</h2>
            <button type="button" class="btn btn-icon"><i class="material-iconsclose" onclick="fnClose();"></i></button>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
<!-- 상단 폼테이블 -->	
			<div>
				<table class="table-border">
					<colgroup>
						<col width="100px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right">부품번호</th>
							<td>
								<input type="text" class="form-control" value="${result.part_no}" id="part_no" name="part_no" readonly >
							</td>
						</tr>
						<tr>
							<th class="text-right">부품명</th>
							<td>
								<input type="text" class="form-control" value="${result.part_name}"  readonly>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
<!-- /상단 폼테이블 -->
<!-- 하단 폼테이블 -->	
			<div>
				<table class="table-border mt10">
					<colgroup>
						<col width="">
						<col width="">
						<col width="">
					</colgroup>
					<thead>
						<tr>
							<th class="td-gray">현재고</th>
							<th class="td-gray">현 적정재고</th>
							<th class="td-gray">변경적정재고</th>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td>
								<input type="text" class="form-control text-right" value="${result.center_stock}" id="center_stock" name="center_stock" readonly="readonly" >
							</td>
							<td>
								<input type="text" class="form-control text-right" value="${result.safe_stock}" id="current_safe_stock" name="current_safe_stock" readonly="readonly" >
							</td>
							<td>
								<input type="text" class="form-control text-right" id="safe_stock" name="safe_stock" required="required" >
							</td>
						</tr>
					</tbody>
				</table>
			</div>
<!-- /하단 폼테이블 -->
			<div class="btn-group mt10">
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>