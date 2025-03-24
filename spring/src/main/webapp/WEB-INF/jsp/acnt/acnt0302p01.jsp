<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 매출관리 > 세금계산서-기간내 일괄병행 > null > 미발행 부가세거래내역
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
			fnInitPage();
		});
		
		function fnInitPage() {
			var info = ${info};
			$M.setValue(info);
			$M.setValue("vat_amt", Math.round(info.vat_amt));

			// 품명 외 몇건
	     	var gridData = AUIGrid.getGridData(auiGrid);
	     	var gridLength = gridData.length - 1;
	     	var descText = gridData[0].count_remark;
	     	
	     	if(gridData.length <= 1) {
	     		$M.setValue("desc_text", descText);
	     	} else {
	     		$M.setValue("desc_text", descText + " 외 " + gridLength + "건");
	     	}
		}
		
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
					headerText : "처리일자", 
					dataField : "inout_dt", 
					dataType : "date",
					formatString : "yyyy-mm-dd",
					width : "13%",
					style : "aui-center"
				},
				{ 
					headerText : "전표번호", 
					dataField : "inout_doc_no", 
					width : "16%",
					style : "aui-center aui-popup"
				},
				{ 
					headerText : "전표구분", 
					dataField : "inout_type_name", 
					width : "10%",
					style : "aui-center",
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
					headerText : "물품대", 
					dataField : "doc_amt", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "12%",
					style : "aui-right",
				},
				{ 
					headerText : "부가세", 
					dataField : "vat_amt", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "12%",
					style : "aui-right",
				},
				{ 
					headerText : "합계액", 
					dataField : "total_amt", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "12%",
					style : "aui-right",
				},
				{ 
					headerText : "적요", 
					dataField : "count_remark", 
					style : "aui-left"
				}
			];
			// 푸터레이아웃
			var footerColumnLayout = [ 
				{
					labelText : "합계",
					positionField : "inout_dt",
					colSpan : 3, 
					style : "aui-center aui-footer",
				}, 
				{
					dataField : "doc_amt",
					positionField : "doc_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "vat_amt",
					positionField : "vat_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
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
			AUIGrid.setGridData(auiGrid, ${list});
			$("#auiGrid").resize();
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField == "inout_doc_no" ) {
					var params = {
							"inout_doc_no" : event.item["inout_doc_no"]
					};
					var popupOption = "";
					$M.goNextPage('/cust/cust0202p01', $M.toGetParam(params), {popupStatus : popupOption});
				}
			});	
		}
		
		// 문자발송
// 		function fnSendSms() {
// 			var param = {
// 					"name" : $M.getValue("cust_name"),
// 					"hp_no" : $M.getValue("cust_hp_no")
// 			}
// 			openSendSmsPanel($M.toGetParam(param));
// 		}
		
		// 발행
		function goNew() {
			var params = {
					"inout_doc_no_str" : "${inputParam.inout_doc_no_str}",
					"taxbill_dt" : $M.getValue("taxbill_dt")
			};
			var popupOption = "scrollbars=yes, resizable=1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=450, height=400, left=0, top=0";
			$M.goNextPage('/acnt/acnt0302p02', $M.toGetParam(params), {popupStatus : popupOption});
		}
		
		// 닫기
		function fnClose() {
			window.close();
		}
	
		
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" id="cust_no" name="cust_no">
<input type="hidden" id="breg_no" name="breg_no">
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
					<h4>미발행 부가세거래내역</h4>
				</div>
				<table class="table-border mt5">
					<colgroup>
						<col width="100px">
						<col width="">
						<col width="100px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right">고객명</th>
							<td>
								<input type="text" class="form-control width120px" readonly="readonly" id="cust_name" name="cust_name">
							</td>
							<th class="text-right">상호</th>
							<td>
								<input type="text" class="form-control width120px" readonly="readonly" id="breg_name" name="breg_name">
							</td>
						</tr>
						<tr>
							<th class="text-right">연락처</th>
							<td>
								<input type="text" class="form-control width120px" readonly="readonly" id="cust_hp_no" name="cust_hp_no">
							</td>
							<th class="text-right essential-item">발행일자</th>
							<td>
								<div class="input-group">
									<input type="text" class="form-control border-right-0 calDate sale-rb" id="taxbill_dt" name="taxbill_dt" dateformat="yyyy-MM-dd" alt="발행일자" required="required" value="${inputParam.s_end_dt}">
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">물품대</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width100px">
										<input type="text" class="form-control text-right" readonly="readonly" id="taxbill_amt" name="taxbill_amt" format="decimal">
									</div>
									<div class="col width22px">원</div>
								</div>
							</td>
							<th class="text-right">부가세</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width100px">
										<input type="text" class="form-control text-right" readonly="readonly" id="vat_amt" name="vat_amt" format="decimal">
									</div>
									<div class="col width22px">원</div>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right essential-item">적요</th>
							<td colspan="3">
								<input type="text" class="form-control sale-rb" id="desc_text" name="desc_text">
							</td>
						</tr>																		
					</tbody>
				</table>
			</div>
<!-- /폼테이블 -->	
<!-- 폼테이블2 -->				
			<div>
				<div class="title-wrap mt10">
					<h4>매출처리내역</h4>
				</div>
				<div id="auiGrid" style="margin-top: 5px; height: 300px;"></div>
			</div>
<!-- /폼테이블2 -->	
			<div class="btn-group mt10">
				<div class="left">
					총 <strong class="text-primary" id="total_cnt">${total_cnt}</strong>건
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