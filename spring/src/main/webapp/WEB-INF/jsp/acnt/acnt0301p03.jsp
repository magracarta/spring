<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 매출관리 > 세금계산서관리 > null > 전표조회
-- 작성자 : 박예진
-- 최초 작성일 : 2020-04-08 18:03:57
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGrid();
			goSearch();
		});
		
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "inout_doc_no",
				// No. 제거
				showRowNumColumn: true,
				editable : false,
				showFooter : true,
				footerPosition : "top",
			};
			var columnLayout = [
				{
					headerText : "전표번호", 
					dataField : "inout_doc_no", 
					width : "13%",
					style : "aui-center"
				},
				{ 
					headerText : "고객명", 
					dataField : "cust_name", 
					width : "12%",
					style : "aui-center"
				},
				{ 
					headerText : "상호", 
					dataField : "breg_name", 
					width : "15%",
					style : "aui-center",
				},
				{ 
					headerText : "적요", 
					dataField : "desc_text", 
					width : "26%",
					style : "aui-left",
				},
				{ 
					headerText : "금액", 
					dataField : "total_amt", 
					width : "12%",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right",
				},
				{ 
					headerText : "비고", 
					dataField : "dis_remark", 
					style : "aui-left"
				},
				{ 
					dataField : "inout_type_cd", 
					visible : false
				},
				{ 
					dataField : "inout_doc_type_cd", 
					visible : false
				},
				{ 
					dataField : "job_report_no", 
					visible : false
				},
				{ 
					dataField : "rental_doc_no", 
					visible : false
				},
				{ 
					dataField : "part_sale_no", 
					visible : false
				},
				{ 
					dataField : "machine_deposit_result_seq", 
					visible : false
				},
				{ 
					dataField : "machine_doc_no", 
					visible : false
				},
				{ 
					dataField : "cust_coupon_no", 
					visible : false
				},
				{ 
					dataField : "ars_reserve_no", 
					visible : false
				},
				{ 
					dataField : "cust_no", 
					visible : false
				}
			];
			// 푸터레이아웃
			var footerColumnLayout = [ 
				{
					labelText : "합계",
					positionField : "inout_doc_no",
					colSpan : 4,
					style : "aui-center aui-footer",
				}, 
				{
					dataField : "total_amt",
					positionField : "total_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				}
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 푸터 객체 세팅
			AUIGrid.setFooter(auiGrid, footerColumnLayout);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
			// 전표의 품의서구분코드와 거래구분코드에 따라 팝업 오픈
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				var inoutDocTypeCd = event.item["inout_doc_type_cd"];
				var inoutTypeCd = event.item["inout_type_cd"];
				var param = {
				};
				var popupOption = "";
				switch(inoutDocTypeCd) {
				case "00" : 
					param.inout_doc_no = event.item["inout_doc_no"];
					$M.goNextPage("/cust/cust0203p01", $M.toGetParam(param), {popupStatus : popupOption});		// 입출금전표처리 상세
					break;
				case "02" :
					param.inout_doc_no = event.item["inout_doc_no"];
// 					param.part_order_no = event.item["part_order_no"];
					$M.goNextPage("/part/part0302p01", $M.toGetParam(param), {popupStatus : popupOption});		// 매입처리 상세
					break;
				case "05" :
					param.inout_doc_no = event.item["inout_doc_no"];
					$M.goNextPage("/cust/cust0202p01", $M.toGetParam(param), {popupStatus : popupOption});		// 매출처리 상세
					break;
				case "06" :
					param.cust_coupon_no = event.item["cust_coupon_no"];
					$M.goNextPage("/cust/cust0305p01", $M.toGetParam(param), {popupStatus : popupOption});	// 쿠폰처리 상세
					break;
				case "07" :
// 					alert("정비지시서 상세-거래명세서");
					// 정비지시서 상세의 거래명세서
					// AS-IS에서 나오지 않으므로 매출처리 상세 오픈
					// $M.goNextPage("/cust/cust0305p01", $M.toGetParam(param), {popupStatus : popupOption});	// 서비스 정비 거래명세서
					param.inout_doc_no = event.item["inout_doc_no"];
					$M.goNextPage("/cust/cust0202p01", $M.toGetParam(param), {popupStatus : popupOption});		// 매출처리 상세
					break;
				case "08" :
					param.machine_doc_no = event.item["machine_doc_no"];
					$M.goNextPage("/sale/sale0101p03", $M.toGetParam(param), {popupStatus : popupOption});	// 출하의뢰서
					break;
				case "09" :
					param.cust_no = event.item["cust_no"];
					$M.goNextPage("/comp/comp0703", $M.toGetParam(param), {popupStatus : popupOption});		//  ARS 결제
					break;
// 				case "10" :
// 					alert("장비입고시 옵션부품 입고");
// 					param.part_order_no = event.item["part_order_no"];
// 					$M.goNextPage("/part/part0302p01", $M.toGetParam(param), {popupStatus : popupOption});
// 					break;
				case "11" :
					param.inout_doc_no = event.item["inout_doc_no"];
					$M.goNextPage("/cust/cust0202p01", $M.toGetParam(param), {popupStatus : popupOption});		// 매출처리 상세
					break;
				case "12" :
					param.inout_doc_no = event.item["inout_doc_no"];
					$M.goNextPage("/cust/cust0202p01", $M.toGetParam(param), {popupStatus : popupOption});		// 매출처리 상세
					break;
				}
			});	
		}
			
		
		//조회
		function goSearch() { 
			var param = {
					"s_sort_key" : "inout_doc_no", 
					"s_sort_method" : "asc",
					"s_taxbill_no" : "${inputParam.taxbill_no}"
			};
			$M.goNextPageAjax(this_page + '/search', $M.toGetParam(param), {method : 'get'},
					function(result) {
						if(result.success) {
							AUIGrid.setGridData(auiGrid, result.list);
							$("#total_cnt").html(result.total_cnt);
						};
					}
				);
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
			<div id="auiGrid" style="margin-top: 5px; height: 250px;"></div>	
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