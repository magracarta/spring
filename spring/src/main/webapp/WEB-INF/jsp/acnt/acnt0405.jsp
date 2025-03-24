<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 정산 > 장비거래원장-위탁판매점 > null > null
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-04-08 18:03:57
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGridLeft();
			createAUGridRight();
		});

		function fnSetRightGridData(orgCode, orgName) {
			if (orgCode == undefined) {
				AUIGrid.setGridData(auiGridRight, []);
			} else {
				$("#agency_name").html(orgName);
				var param = {
					s_org_code : orgCode,
					s_sort_key : "aa.machine_doc_no",
					s_sort_method : "asc"
				}
				$M.setValue("org_code", orgCode);
				$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
					function(result){
						if(result.success) {
							$("#right_total_cnt").html(result.list.length);
							AUIGrid.setGridData(auiGridRight, result.list);
						}
					}
				);
			}
		}

		//그리드생성
		function createAUIGridLeft() {
			var gridPros = {
				rowIdField : "org_code",
				// No. 제거
				showRowNumColumn: true,
				editable : false,
				showFooter : true,
				footerPosition : "top",
				enableMovingColumn : false
			};
			var columnLayout = [
				{
					dataField : "org_code",
					visible : false
				},
				{
					// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
					// headerText : "대리점",
					headerText : "위탁판매점",
					dataField : "org_name",
					width : "40%",
					style : "aui-center aui-link"
				},
				{
					headerText : "현미수금",
					dataField : "misu_amt",
					width : "60%",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right aui-link"
				}
			];
			// 푸터레이아웃
			var footerColumnLayout = [
				{
					labelText : "합계",
					positionField : "org_name",
					style : "aui-center aui-footer",
				},
				{
					dataField : "misu_amt",
					positionField : "misu_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				}
			];
			auiGridLeft = AUIGrid.create("#auiGridLeft", columnLayout, gridPros);
			// 푸터 객체 세팅
			AUIGrid.setFooter(auiGridLeft, footerColumnLayout);
			var list = ${list}
			AUIGrid.setGridData(auiGridLeft, list);
			$("#left_total_cnt").html(list.length);
			AUIGrid.bind(auiGridLeft, "cellClick", function(event) {
				fnSetRightGridData(event.item.org_code, event.item.org_name);
			});
			$("#auiGridLeft").resize();
		}

		function fnDownloadExcelLeft() {
			  // 엑셀 내보내기 속성
			  var exportProps = {
			         // 제외항목
			         //exceptColumnFields : ["removeBtn"]
			  };
			  // [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
			  // fnExportExcel(auiGridLeft, "대리점별미수금", exportProps);
			  fnExportExcel(auiGridLeft, "위탁판매점별미수금", exportProps);
		}

		function fnDownloadExcelRight() {
			// 엑셀 내보내기 속성
			var exportProps = {
			       // 제외항목
			       //exceptColumnFields : ["removeBtn"]
			};
			fnExportExcel(auiGridRight, "미수금목록-"+$("#agency_name").html(), exportProps);
		}

		//그리드생성
		function createAUGridRight() {
			var gridPros = {
				rowIdField : "row",
				showRowNumColumn: true,
				editable : false,
				showFooter : true,
				footerPosition : "top",
				enableMovingColumn : false
			};
			var columnLayout = [
				{
					headerText : "접수번호",
					dataField : "machine_doc_no",
					width : "12%",
					style : "aui-center aui-popup"
				},
				{
					headerText : "고객명",
					dataField : "cust_name",
					width : "10%",
					style : "aui-center"
				},
				{
					headerText : "장비명",
					dataField : "machine_name",
					width : "15%",
					style : "aui-center",
				},
				{
					headerText : "출하일",
					dataField : "out_dt",
					dataType : "date",
					formatString : "yyyy-mm-dd",
					width : "10%",
					style : "aui-center aui-popup",
				},
				{
					headerText : "판매금액",
					dataField : "plan_amt",
					dataType : "numeric",
					formatString : "#,##0",
					width : "12%",
					style : "aui-right",
				},
				{
					headerText : "입금액",
					dataField : "deposit_amt",
					dataType : "numeric",
					formatString : "#,##0",
					width : "12%",
					style : "aui-right",
				},
				{
					headerText : "미수금",
					dataField : "misu_amt",
					dataType : "numeric",
					formatString : "#,##0",
					width : "12%",
					style : "aui-right",
				},
				{
					headerText : "비고",
					dataField : "remark",
					style : "aui-left",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						if (item.machine_doc_status_cd != '5') {
							return "미출하";
						}
					},
				},
				{
					dataField : "machine_doc_status_cd",
					visible : false
				}
			];
			// 푸터레이아웃
			var footerColumnLayout = [
				{
					labelText : "합계",
					positionField : "out_dt",
					style : "aui-center aui-footer",
				},
				{
					dataField : "plan_amt",
					positionField : "plan_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer"
				},
				{
					dataField : "deposit_amt",
					positionField : "deposit_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer"
				},
				{
					dataField : "misu_amt",
					positionField : "misu_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer"
				}
			];

			auiGridRight = AUIGrid.create("#auiGridRight", columnLayout, gridPros);
			// 푸터 객체 세팅
			AUIGrid.setFooter(auiGridRight, footerColumnLayout);
			AUIGrid.setGridData(auiGridRight, []);
			$("#auiGridRight").resize();
			AUIGrid.bind(auiGridRight, "cellClick", function(event) {
				if(event.dataField == "machine_doc_no" ) {
					var params = {
						machine_doc_no : event.item.machine_doc_no
					};
					var popupOption = "scrollbars=yes, resizable=yes, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=900, height=500, left=0, top=0";
					$M.goNextPage('/acnt/acnt0405p01', $M.toGetParam(params), {popupStatus : popupOption});
				}
				if(event.dataField == "out_dt" ) {
					var params = {
						machine_doc_no : event.item.machine_doc_no
					};
					var popupOption = "scrollbars=yes, resizable=yes, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1300, height=800, left=0, top=0";
					$M.goNextPage('/sale/sale0101p03', $M.toGetParam(params), {popupStatus : popupOption});
				}
			});
		}

		function goTotal() {
			var orgName = $("#agency_name").html();
			var params = {
				org_code : $M.getValue("org_code"),
				org_name : orgName
			};
			var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=900, height=500, left=0, top=0";
			$M.goNextPage('/acnt/acnt0405p02', $M.toGetParam(params), {popupStatus : popupOption});
		}

	</script>
</head>
<body>
<form id="main_form" name="main_form">
<input type="hidden" id="org_code" name="org_code">
<div class="layout-box">
<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
<!-- 메인 타이틀 -->
				<div class="main-title">
					<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
				</div>
<!-- /메인 타이틀 -->
				<div class="contents">
					<div class="row">
						<div class="col-3">
<!-- 대리점 -->
							<div>
								<div class="title-wrap mt10">
									<%-- [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체 --%>
									<%--<h4>대리점</h4>--%>
									<h4>위탁판매점</h4>
									<div class="btn-group">
										<div class="right">
											<button type="button" class="btn btn-default" onclick="javascript:fnDownloadExcelLeft();"><i class="icon-btn-excel inline-btn"></i>엑셀다운로드</button>
										</div>
									</div>
								</div>
								<div id="auiGridLeft" style="margin-top: 5px; height: 555px;"></div>
								<div class="btn-group mt5">
									<div class="left">
										총 <strong class="text-primary" id="left_total_cnt">0</strong>건
									</div>
								</div>
							</div>
<!-- /대리점 -->
						</div>
						<div class="col-9">
<!-- 잔액명세 -->
							<div>
								<div class="title-wrap mt10">
									<h4><span class="text-primary" id="agency_name">지사</span> 잔액명세</h4>
									<div class="btn-group">
										<div class="right">
											<button type="button" class="btn btn-default" onclick="javascript:goTotal();">전체거래내역</button>
											<button type="button" class="btn btn-default" onclick="javascript:fnDownloadExcelRight();""><i class="icon-btn-excel inline-btn"></i>엑셀다운로드</button>
										</div>
									</div>
								</div>
								<div id="auiGridRight" style="margin-top: 5px; height: 555px;"></div>
								<div class="btn-group mt5">
									<div class="left">
										총 <strong class="text-primary" id="right_total_cnt">0</strong>건
									</div>
								</div>
							</div>
<!-- /잔액명세 -->
						</div>
					</div>
				</div>
			</div>
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
		</div>
<!-- /contents 전체 영역 -->
</div>
</form>
</body>
</html>
