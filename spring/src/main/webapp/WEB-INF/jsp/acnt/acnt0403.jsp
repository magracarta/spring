<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 정산 > 위탁판매점월정산확인 > null > null
-- 작성자 : 황빛찬
-- 최초 작성일 : 2020-10-09 14:19:03
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
// 			fnInit();
		});

// 		function fnInit() {
// 			var now = "${inputParam.s_current_dt}";
// 			$M.setValue("s_start_dt", $M.addMonths($M.toDate(now), -1));
// 		}

		//그리드생성
		function createAUIGrid() {
			var gridPros = {
					rowIdField : "_$uid",
					showStateColumn : false,
					// No. 제거
					showRowNumColumn: true,
					enableFilter :true,
					showBranchOnGrouping : false,
					showFooter : true,
					footerPosition : "top",
					editable : false,
					enableMovingColumn : false,
// 					// fixedColumnCount : 6,
			};
			var columnLayout = [
				{
					dataField : "machine_doc_no",
					visible : false
				},
				{
					dataField : "org_code",
					visible : false
				},
				{
					headerText : "마케팅",
					children : [
						{
							// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
							// headerText : "대리점",
							headerText : "위탁판매점",
							dataField : "org_name",
							width : "130",
							minWidth : "130",
							style : "aui-center aui-popup",
							filter : {
								showIcon : true
							}
						},
						{
							headerText : "담당자",
							dataField : "doc_mem_name",
							width : "65",
							minWidth : "65",
							style : "aui-center"
						},
						{
							headerText : "작성일자",
							dataField : "reg_date",
							width : "70",
							minWidth : "70",
							dataType : "date",
							formatString : "yy-mm-dd",
							style : "aui-center",
						},
						{
							headerText : "고객명",
							dataField : "cust_name",
							width : "70",
							minWidth : "70",
							style : "aui-center",
						},
						{
							headerText : "장비명",
							dataField : "machine_name",
							width : "130",
							minWidth : "30",
							style : "aui-left",
							filter : {
								showIcon : true
							}
						},
						{
							headerText : "계약금액",
							dataField : "sale_amt",
							dataType : "numeric",
							formatString : "#,##0",
							width : "100",
							minWidth : "30",
							style : "aui-right"
						}
					]
				},
				{
					headerText : "출하확인",
					children : [
						{
							headerText : "출고일자",
							dataField : "out_dt",
							width : "70",
							minWidth : "70",
							dataType : "date",
							formatString : "yy-mm-dd",
							style : "aui-center"
						},
						{
							headerText : "차대번호",
							dataField : "body_no",
							width : "180",
							minWidth : "30",
							style : "aui-center aui-popup",
							filter : {
								showIcon : true
							}
						}
					]
				},
				{
					// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
					// headerText : "대리점정산",
					headerText : "위탁판매점정산",
					children : [
						{
							headerText : "수수료",
							dataField : "sale_commission_amt",
							width : "100",
							minWidth : "30",
							dataType : "numeric",
							formatString : "#,##0",
							style : "aui-right",
						},
						{
							headerText : "부가세",
							dataField : "sale_vat_amt",
							width : "100",
							minWidth : "30",
							dataType : "numeric",
							formatString : "#,##0",
							style : "aui-right",
						},
						{
							headerText : "정산수수료",
							dataField : "pay_commission_amt",
							width : "100",
							minWidth : "30",
							dataType : "numeric",
							formatString : "#,##0",
							style : "aui-right",
						},
						{
							headerText : "정산부가세",
							dataField : "pay_vat_amt",
							width : "100",
							minWidth : "30",
							dataType : "numeric",
							formatString : "#,##0",
							style : "aui-right",
						}
					]
				},
				{
					headerText : "상태",
					dataField : "out_confirm_yn",
					width : "60",
					minWidth : "60",
					style : "aui-center",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
					    var val = "미완료";
					    if (value == "Y") {
					    	val = "완료"
					    }
						return val;
					},
				}
			];
			// 푸터레이아웃
			var footerColumnLayout = [
				{
					labelText : "합계",
					positionField : "machine_name",
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
					dataField : "sale_commission_amt",
					positionField : "sale_commission_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "sale_vat_amt",
					positionField : "sale_vat_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "pay_commission_amt",
					positionField : "pay_commission_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "pay_vat_amt",
					positionField : "pay_vat_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);// 푸터 객체 세팅
			AUIGrid.setFooter(auiGrid, footerColumnLayout);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				// 정산확인 팝업 호출
				if(event.dataField == "org_name" ) {
					var params = {
							machine_doc_no : event.item.machine_doc_no
					};

					var popupOption = "";
					$M.goNextPage('/acnt/acnt0403p01', $M.toGetParam(params), {popupStatus : popupOption});
				}

				// 출하의뢰서 상세 팝업 호출
				if(event.dataField == "body_no" ) {
					var param = {
							machine_doc_no : event.item.machine_doc_no
					}

					var poppupOption = "";
					$M.goNextPage('/sale/sale0101p03', $M.toGetParam(param), {popupStatus : poppupOption});
				}
			});
		}

		// 엑셀다운로드
		function fnDownloadExcel() {
			var exportProps = {
			         // 제외항목
			  };
			// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
		  	// fnExportExcel(auiGrid, "대리점정산확인", exportProps);
		  	fnExportExcel(auiGrid, "위탁판매점정산확인", exportProps);
		}

		// 조회
		function goSearch() {
			var param = {
					s_start_dt : $M.getValue("s_start_dt"),
					s_end_dt : $M.getValue("s_end_dt"),
					s_out_confirm_yn : $M.getValue("s_out_confirm_yn"),
					s_sort_key : "org_code",
					s_sort_method : "asc"
				};
			_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
			console.log(param);
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid, result.list);
					};
				}
			);
		}

	</script>
</head>
<body>
<form id="main_form" name="main_form">
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
<!-- 검색영역 -->
					<div class="search-wrap">
						<table class="table">
							<colgroup>
								<col width="60px">
								<col width="260px">
								<col width="40px">
								<col width="100px">
							</colgroup>
							<tbody>
								<tr>
									<th>출고일자</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" value="${searchDtMap.s_start_dt}">
												</div>
											</div>
											<div class="col-auto">~</div>
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="" value="${searchDtMap.s_end_dt}">
												</div>
											</div>
											<jsp:include page="/WEB-INF/jsp/common/searchDtType.jsp">
				                     		<jsp:param name="st_field_name" value="s_start_dt"/>
				                     		<jsp:param name="ed_field_name" value="s_end_dt"/>
				                     		<jsp:param name="click_exec_yn" value="Y"/>
				                     		<jsp:param name="exec_func_name" value="goSearch();"/>
				                     		</jsp:include>
										</div>
									</td>
									<th>상태</th>
									<td>
										<select class="form-control" id="s_out_confirm_yn" name="s_out_confirm_yn">
											<option value="">- 전체 -</option>
											<option value="Y">완료</option>
											<option value="N">미완료</option>
										</select>
									</td>
									<td>
										<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
									</td>
								</tr>
							</tbody>
						</table>
					</div>
<!-- /검색영역 -->
<!-- 조회결과 -->
					<div class="title-wrap mt10">
						<h4>조회결과</h4>
						<div class="btn-group">
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
<!-- /조회결과 -->
					<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
					<div class="btn-group mt5">
						<div class="left">
							총 <strong id="total_cnt" class="text-primary">0</strong>건
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
