<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 판매관리 > 장비판매현황-직원별 > null > 직원별장비판매현황상세
-- 작성자 : 손광진
-- 최초 작성일 : 2020-09-21 17:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		$(document).ready(function() {
			createAUIGrid();
		});

		//엑셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, '장비판매현황_상세');
		}
		
		//그리드생성
		function createAUIGrid() {
	
			var gridPros = {
				rowIdField : "row",
				height : 565,
			};
			
			var columnLayout = [
				{
					headerText : "관리번호", 
					dataField : "machine_doc_no", 
					width : "70",
					minWidth : "25", 
					style : "aui-center aui-popup",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
		                  var ret = "";
		                  if (value != null && value != "") {
		                     ret = value.split("-");
		                     ret = ret[0]+"-"+ret[1];
		                     ret = ret.substr(4, ret.length);
		                  }
		                   return ret; 
		               }, 
				},
				{ 
					headerText : "차대번호", 
					dataField : "body_no", 
					width : "145",
					minWidth : "25", 
					style : "aui-center"
				},
				{ 
					headerText : "모델명", 
					dataField : "machine_name", 
					width : "130",
					minWidth : "25", 
					style : "aui-left"
				},
				{ 
					headerText : "작성자", 
					dataField : "doc_mem_name", 
					width : "55",
					minWidth : "25", 
					style : "aui-center"
				},
				{ 
					headerText : "작성일", 
					dataField : "doc_dt", 
				    dataType : "date",   
					width : "65",
					minWidth : "25", 
					style : "aui-center",
					formatString : "yy-mm-dd",
				},
				{ 
					headerText : "고객명", 
					dataField : "cust_name", 
					width : "95",
					minWidth : "25", 
					style : "aui-center"
				},
				{ 
					headerText : "휴대폰", 
					dataField : "hp_no", 
					width : "110",
					minWidth : "25", 
					style : "aui-center"
				},
				{ 
					headerText : "출고일", 
					dataField : "out_dt", 
				    dataType : "date",   
					width : "65",
					minWidth : "25", 
					style : "aui-center",
					formatString : "yy-mm-dd",
				},
				{ 
					headerText : "도착지", 
					dataField : "arrival_area_name", 
					style : "aui-left",
					width : "370",
					minWidth : "25"
				},
			];
			
			
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			
			AUIGrid.setGridData(auiGrid, listJson);
			
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				var param = {
					machine_doc_no : event.item.machine_doc_no
				};

				if(event.dataField == 'machine_doc_no') {
					var popupOption = "";
					$M.goNextPage('/sale/sale0101p03', $M.toGetParam(param), {popupStatus : popupOption});
				};
			}); 
		}

		function goSearch() {
			var param = {
					"year_mon" 			: "${inputParam.year_mon}",
					"machine_name" 		: "${inputParam.machine_name}",
					"rental_yn" 		: "${inputParam.rental_yn}",
					s_sale_org_code 	: "${inputParam.s_sale_org_code}",
					s_sale_sub_org_code : "${inputParam.s_sale_sub_org_code}",
					s_sale_org_mem 		: "${inputParam.s_sale_org_mem}",
					"s_masking_yn" : $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N"
        	 }
		$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result){
					if(result.success){
						AUIGrid.setGridData(auiGrid, result.list);
						$("#total_cnt").html(result.total_cnt);
					}
				}
			); 
		}
		
		function fnClose() {
			window.close();
		}
		
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">	
			<div class="title-wrap">		
				<h4 class="primary">${year_month}<c:if test="${not empty year_month}">월 </c:if>조회결과</h4>
				<div class="right">		
					<c:if test="${page.add.POS_UNMASKING eq 'Y'}">
					<div class="form-check form-check-inline">
						<input  class="form-check-input"  type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y" onclick="javascript:goSearch();">
						<label  class="form-check-input"  for="s_masking_yn" >마스킹 적용</label>
					</div>
					</c:if>	
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
				</div>
			</div>	

			<!-- 그리드 생성 영역 -->
			<div id="auiGrid" style="margin-top: 5px;"></div>
			
<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt5">		
				<div class="left">
					총 <strong class="text-primary" id="total_cnt">${total_cnt}</strong>건
				</div>				
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
<!-- /상단 폼테이블 -->
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>