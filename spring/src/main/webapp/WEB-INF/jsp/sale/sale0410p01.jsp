<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 판매관리 > 장비판매현황-판매점별 > null > 판매점별장비판매현황상세
-- 작성자 : 정선경
-- 최초 작성일 : 2024-04-29 16:54:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var auiGrid;

		$(document).ready(function() {
			$("input:checkbox[id='sale_base']").prop("checked", true);
			$("input:checkbox[id='rental_base']").prop("checked", true);

			createAUIGrid();
			goSearch();
		});

		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "row",
				height : 565
			};

			var columnLayout = [
				{
					headerText : "위탁판매점명",
					dataField : "agency_org_name",
					width : "120",
					minWidth : "100",
					style : "aui-center"
				},
				{
					headerText : "대표자명",
					dataField : "breg_rep_name",
					width : "100",
					minWidth : "80",
					style : "aui-center"
				},
				{
					headerText : "품의서작성자",
					dataField : "doc_mem_name",
					width : "110",
					minWidth : "80",
					style : "aui-center"
				},
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
					headerText : "모델명",
					dataField : "machine_name",
					width : "130",
					minWidth : "25",
					style : "aui-left"
				},
				{
					headerText : "고객명",
					dataField : "cust_name",
					width : "100",
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
					width : "80",
					minWidth : "25",
					style : "aui-center",
					formatString : "yy-mm-dd",
				},
				{
					headerText: "판매유형",
					dataField: "sale_type_sr_name",
					width : "100",
					minWidth : "25",
					style : "aui-center"
				},
				{
					headerText : "최종판매가",
					dataField : "sale_amt",
					width : "100",
					minWidth : "100",
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{
					headerText : "위탁판매점 공급가",
					dataField : "agency_price",
					width : "110",
					minWidth : "100",
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0"
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
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.resize(auiGrid);

			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				var param = {
					machine_doc_no : event.item.machine_doc_no
				};
				if(event.dataField == 'machine_doc_no') {
					var popupOption = "";
					$M.goNextPage('/sale/sale0101p03', $M.toGetParam(param), {popupStatus : popupOption});
				}
			});
		}

		function goSearch() {
			var checkedNum = $("input[type='checkbox']").filter(':checked').size();
			if($("input:checkbox[id='s_masking_yn']").is(":checked") === true) {
				checkedNum = checkedNum-1;
			}
			if(checkedNum < 1) {
				alert("판매유형구분은 최소 1개 이상 선택해야 합니다.");
				return;
			}

			var param = {
				"year_mon" 				: "${inputParam.year_mon}",
				"agency_code" 			: "${inputParam.agency_code}",
				"agency_org_code" 		: "${inputParam.agency_org_code}",
				"agency_org_mem_no" 	: "${inputParam.agency_org_mem_no}",
				"maker_cd" 				: "${inputParam.maker_cd}",
				"machine_plant_seq_str"	: "${inputParam.machine_plant_seq_str}",
				"st_year_mon"			: "${inputParam.st_year_mon}",
				"ed_year_mon"			: "${inputParam.ed_year_mon}",
				"sale_base" 	 		: $M.getValue("sale_base"),
				"rental_base"  			: $M.getValue("rental_base"),
				"s_masking_yn" 			: $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N"
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

		//엑셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, '장비판매현황_상세');
		}

		// 닫기
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
					<div class="condition-items">
						<div class="condition-item">
							<div>
								<strong class="pr15">판매유형구분</strong>
							</div>
							<div class="form-check form-check-inline">
								<input class="form-check-input" type="checkbox" id="sale_base" name="sale_base" value="Y">
								<label class="form-check-label" for="sale_base">순수판매</label>
							</div>
							<div class="form-check form-check-inline">
								<input class="form-check-input" type="checkbox" id="rental_base" name="rental_base" value="Y">
								<label class="form-check-label" for="rental_base">본사렌탈</label>
							</div>
						</div>
						<c:if test="${page.add.POS_UNMASKING eq 'Y'}">
						<div class="form-check form-check-inline">
							<input  class="form-check-input"  type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y">
							<label  class="form-check-input"  for="s_masking_yn" >마스킹 적용</label>
						</div>
						</c:if>
						<div class="form-check form-check-inline">
							<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
						</div>
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
					</div>
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