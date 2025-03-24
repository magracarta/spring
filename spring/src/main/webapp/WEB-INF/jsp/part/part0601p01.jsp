<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 부품통계 > 부품판매현황-기간별 > null > 매입매출현황
-- 작성자 : 손광진
-- 최초 작성일 : 2020-09-08 16:18:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		$(document).ready(function() {
			
			// 그리드 생성
			createAUIGrid();	
			fnInitSet();
			goSearch();
		});
			
		// 받아온 정보 셋팅
		function fnInitSet() {
			var params = {
				s_start_dt 			: '${inputParam.s_start_dt}',
				s_end_dt 			: '${inputParam.s_end_dt}',
				part_production_oke : '${inputParam.part_production_oke}',
				maker_stat_cd 		: '${inputParam.maker_stat_cd}',
				maker_stat_name 	: '${inputParam.maker_stat_name}',
	    	};
			
			$M.setValue(params);

		}
		
		
		// 부품판매현황-기간별 목록 조회
		function goSearch() {

			
			var param = {
				s_start_dt 				: $M.getValue("s_start_dt"),
				s_end_dt 				: $M.getValue("s_end_dt"),
				s_part_no 				: $M.getValue("s_part_no"),
				s_part_name				: $M.getValue("s_part_name"),
				maker_stat_cd			: $M.getValue("maker_stat_cd"),
				part_production_oke		: $M.getValue("part_production_oke"),
			};
			
			
			if ("${inputParam.s_type}" != "") {
				param["s_type"] = "${inputParam.s_type}";
			}
			
			if ("${inputParam.s_kpi_part_no_str}" != "") {
				param["s_kpi_part_no_str"] = "${inputParam.s_kpi_part_no_str}";
			}
			
			if ("${inputParam.s_part_group_cd_str}" != "") {
				param["s_part_group_cd_str"] = "${inputParam.s_part_group_cd_str}";
			}
			
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid, result.list);
					};
				}
			);
		}
		
		//엑셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "매입매출 현황", "");
		}
				
		function goPrint() {
			alert("인쇄");
		}
				
		// 그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn: true,
				showFooter : true,
				footerPosition : "top"
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
				    headerText: "부품정보",
					children : [
						{
							dataField : "part_no",
							headerText : "부품번호",
							width : "8%",
							style : "aui-center aui-popup",
							
						}, 
						{
							dataField : "part_name",
							headerText : "부품명",
							width : "15%",
							style : "aui-left",
						},
						{
							dataField : "part_output_price_cd",
							headerText : "산출구분",
							width : "5%",
							style : "aui-center",
						},
						{
							dataField : "part_group_cd",
							headerText : "분류",
							width : "5%",
							style : "aui-center",
						},
					]
				},
				{
				    headerText: "기간매입",
				    dataField: "in_amt",
					dataType : "numeric",
					formatString : "#,##0",
					width : "6%",
					style : "aui-right"
				},
				{
				    headerText: "부품부판매",
					children : [
						{
							dataField : "part_amt",
							headerText : "매출",
							dataType : "numeric",
							formatString : "#,##0",
							width : "6%",
							style : "aui-right",
						}, 
						{
							dataField : "part_origin_amt",
							headerText : "원가",
							dataType : "numeric",
							formatString : "#,##0",
							width : "6%",
							style : "aui-right",
						},
						{
							dataField : "part_profit_amt",
							headerText : "이익",
							dataType : "numeric",
							formatString : "#,##0",
							width : "6%",
							style : "aui-right",
						},
						{
							dataField : "part_profit_rate",
							headerText : "%",
							width : "5%",
							style : "aui-center",
						},
					]
				},
				{
				    headerText: "서비스판매",
					children : [
						{
							dataField : "svc_amt",
							headerText : "매출",
							dataType : "numeric",
							formatString : "#,##0",
							width : "6%",
							style : "aui-right",
						}, 
						{
							dataField : "svc_origin_amt",
							headerText : "원가",
							dataType : "numeric",
							formatString : "#,##0",
							width : "6%",
							style : "aui-right",
						},
						{
							dataField : "svc_profit_amt",
							headerText : "이익",
							dataType : "numeric",
							formatString : "#,##0",
							width : "6%",
							style : "aui-right",
						},
						{
							dataField : "svc_profit_rate",
							headerText : "%",
							width : "6%",
							style : "aui-center",
						},
					]
				},
				{
				    headerText: "마케팅판매",
					children : [
						{
							dataField : "sale_amt",
							headerText : "매출",
							dataType : "numeric",
							formatString : "#,##0",
							width : "6%",
							style : "aui-right",
						}, 
						{
							dataField : "sale_origin_amt",
							headerText : "원가",
							dataType : "numeric",
							formatString : "#,##0",
							width : "6%",
							style : "aui-right",
						},
						{
							dataField : "sale_profit_amt",
							headerText : "이익",
							dataType : "numeric",
							formatString : "#,##0",
							width : "6%",
							style : "aui-right",
						},
						{
							dataField : "sale_profit_rate",
							headerText : "%",
							width : "5%",
							style : "aui-center",
						},
					]
				},
				{
				    headerText: "계",
					children : [
						{
							dataField : "org_amt_sum",
							headerText : "매출",
							dataType : "numeric",
							formatString : "#,##0",
							width : "8%",
							style : "aui-right",
						}, 
						{
							dataField : "org_origin_amt_sum",
							headerText : "원가",
							dataType : "numeric",
							formatString : "#,##0",
							width : "8%",
							style : "aui-right",
						},
						{
							dataField : "org_profit_amt_sum",
							headerText : "이익",
							dataType : "numeric",
							formatString : "#,##0",
							width : "8%",
							style : "aui-right",
						},
						{
							dataField : "org_profit_rate_sum",
							headerText : "%",
							width : "6%",
							style : "aui-center",
						},
					]
				},
				{
					headerText : "서비스",
					dataField : "svc_free_origin_amt",
					dataType : "numeric",
					formatString : "#,##0",
					width : "8%",
					style : "aui-right"
				},
				{
				    headerText: "기본출하",
				    dataField: "mch_out_origin_amt",
				    dataType : "numeric",
				    formatString : "#,##0",
				    width : "8%",
					style : "aui-right"
				},
				{
				    headerText: "총원가",
				    dataField: "tot_origin_amt",
				    dataType : "numeric",
				    formatString : "#,##0",
				    width : "8%",
					style : "aui-right"
				},
			];
			
			// 푸터레이아웃
			var footerColumnLayout = [ 
				{
					labelText : "합계",
					positionField : "part_group_cd",
					style : "aui-center aui-footer",
				}, 
				{
					dataField : "in_amt",
					positionField : "in_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "part_amt",
					positionField : "part_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "part_origin_amt",
					positionField : "part_origin_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "part_profit_amt",
					positionField : "part_profit_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "part_profit_rate",
					positionField : "part_profit_rate",
					// operation : "SUM",
					labelFunction : function(value, columnValues, footerValues) {
						var amtSum = footerValues[2];
						var originAmtSum = footerValues[3];
						
						var profitRateSum = Math.round((Number(amtSum) - Number(originAmtSum) ) / Number(amtSum) * Number(100));
						
						return isNaN(profitRateSum) ? 0 : profitRateSum;
					},
					formatString : "#,##0",
					style : "aui-center aui-footer",
				},
				{
					dataField : "svc_amt",
					positionField : "svc_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "svc_origin_amt",
					positionField : "svc_origin_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "svc_profit_amt",
					positionField : "svc_profit_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "svc_profit_rate",
					positionField : "svc_profit_rate",
					// operation : "SUM",
					formatString : "#,##0",
					labelFunction : function(value, columnValues, footerValues) {
						var amtSum = footerValues[6];
						var originAmtSum = footerValues[7];
						
						var profitRateSum = Math.round((Number(amtSum) - Number(originAmtSum) ) / Number(amtSum) * Number(100));
						
						return isNaN(profitRateSum) ? 0 : profitRateSum;
					},
					style : "aui-center aui-footer",
				},
				{
					dataField : "sale_amt",
					positionField : "sale_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "sale_origin_amt",
					positionField : "sale_origin_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "sale_profit_amt",
					positionField : "sale_profit_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "sale_profit_rate",
					positionField : "sale_profit_rate",
					formatString : "#,##0",
					labelFunction : function(value, columnValues, footerValues) {
						var amtSum = footerValues[10];
						var originAmtSum = footerValues[11];
						
						var profitRateSum = Math.round((Number(amtSum) - Number(originAmtSum) ) / Number(amtSum) * Number(100));
						
						return isNaN(profitRateSum) ? 0 : profitRateSum;
					},
					style : "aui-right aui-footer",
				},
				{
					dataField : "org_amt_sum",
					positionField : "org_amt_sum",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "org_origin_amt_sum",
					positionField : "org_origin_amt_sum",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "org_profit_amt_sum",
					positionField : "org_profit_amt_sum",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "org_profit_rate_sum",
					positionField : "org_profit_rate_sum",
					// operation : "SUM",
					formatString : "#,##0",
					labelFunction : function(value, columnValues, footerValues) {
						var amtSum = footerValues[14];
						var originAmtSum = footerValues[15];
						
						var profitRateSum = Math.round((Number(amtSum) - Number(originAmtSum) ) / Number(amtSum) * Number(100));
						
						return isNaN(profitRateSum) ? 0 : profitRateSum;
					},
					style : "aui-center aui-footer",
				},
				{
					dataField : "svc_free_origin_amt",
					positionField : "svc_free_origin_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "mch_out_origin_amt",
					positionField : "mch_out_origin_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "tot_origin_amt",
					positionField : "tot_origin_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
			];
			
			// 그리드 출력
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.setFooter(auiGrid, footerColumnLayout);
			// AUIGrid.setFixedColumnCount(auiGrid, 5);
			$("#auiGrid").resize();
			// 클릭 시 팝업페이지 호출
 			AUIGrid.bind(auiGrid, "cellClick", function(event) {
 				if(event.dataField == "part_no") {
					if($M.getValue("popupCase") == "S") {
 	 					
		 				var param = {
							"part_no"	: event.item.part_no,
							"part_name"	: event.item.part_name
 			            }
 					
 						// 집계상세조회 check
	 					var popupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=600, left=0, top=0";
						$M.goNextPage("/part/part0601p02",  $M.toGetParam(param), {popupStatus : popupOption});
 						
 					} else if($M.getValue("popupCase") == "M") {
		 				var param = {
							s_start_dt 		: $M.getValue("s_start_dt"),
							s_end_dt 		: $M.getValue("s_end_dt"),
							"part_no"		: event.item.part_no,
							"checkPage" 	: "Y",
							"s_part_move_type_cd_in" 	: "Y",
							"s_part_move_type_cd_out" 	: "Y",
							"s_part_move_type_cd_move" 	: "Y",
							"s_cost_yn" 	: "Y",
				        }
 						
		 				openInoutPartPanel('fnSetInoutPartInfo', $M.toGetParam(param));
 			
 					};
 					
 				}
			});
		}
		
		//팝업 닫기
		function fnClose() {
			window.close(); 
		}
		
		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_part_no", "s_part_name"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch();
				};
			});
		}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" id="part_production_oke" name="part_production_oke" value="">
<input type="hidden" id="maker_stat_cd" name="maker_stat_cd" value="">
<input type="hidden" id="maker_stat_name" name="maker_stat_name" value="">

<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
<!-- 폼테이블 -->					
			<div>
				<div class="title-wrap">
					<h4>${inputParam.maker_stat_name} / ${inputParam.part_production_oke}</h4>
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>				
				</div>						
<!-- 검색영역 -->					
				<div class="search-wrap mt5">
					<table class="table">
						<colgroup>
							<col width="220px">
							<col width="60px">
							<col width="100px">
							<col width="60px">
							<col width="100px">
							<col width="">
						</colgroup>
						<tbody>
							<tr>
								<td class="pl15">
									<div class="form-check form-check-inline">
										<label class="form-check-label"><input type="radio" name="popupCase" checked value="S"> 집계상세조회</label>
										<label class="form-check-label"><input type="radio" name="popupCase" value="M"> 수불내역조회</label>
									</div>
								</td>
								<th>부품번호</th>
								<td>
									<input type="text" class="form-control" id="s_part_no" name="s_part_no" value="" alt="부품번호">
								</td>
								<th>부품명</th>
								<td>
									<input type="text" class="form-control" id="s_part_name" name="s_part_name" value="" alt="부품명">
								</td>
								<td class=""><button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button></td>							
							</tr>
						</tbody>
					</table>
				</div>
<!-- /검색영역 -->
				<div class="title-wrap mt10">
					<h4>조회결과</h4>
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
				</div>
				<div style="margin-top: 5px; height: 450px;" id="auiGrid"></div>
			</div>		
<!-- /폼테이블 -->
			<div class="btn-group mt10">
				<div class="left">
					총 <strong class="text-primary" id="total_cnt">0</strong>건
				</div>	
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