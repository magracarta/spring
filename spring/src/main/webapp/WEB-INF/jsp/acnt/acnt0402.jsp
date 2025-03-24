<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 정산 > 위탁판매점월정산 > null > null
-- 작성자 : 황빛찬
-- 최초 작성일 : 2020-09-21 18:03:57
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<style>
		.my-row-style {
			background : #FF0000;
 			color : #FFFFFF;
		}
	</style>
	<script type="text/javascript">

		var auiGrid;
		var payDt;
		var payControl;

		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGrid();
		});

		function goSearch() {
			payDt = fnSetDate($M.getValue("s_end_year"), $M.getValue("s_end_mon"));
			console.log("payDt : ", payDt);
			var param = {
					s_pay_dt : payDt,
					s_all_yn : $M.getValue("s_all_yn"),
// 					s_sort_key : "reg_date",
// 					s_sort_method : "desc"
				};

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid, result.list);
					};
				}
			);
		}

		// 검색조건 날짜 포멧
        function fnSetDate(year, mon) {
			var day;

			// 정산일경우 날짜가 해당월의 마지막날짜로
			// 현재일경우 해당날짜
			if ($M.getValue("pay_control") == 2) {
				day = new Date(year, mon, 0).getDate();
			} else {
				var now = new Date();
				day = now.getDate() > 9 ? '' + now.getDate() : '0' + now.getDate();
			}

        	if(mon.length == 1) {
        		mon = "0" + mon;
			}
        	var sYearMon = year + mon + day;

        	return $M.dateFormat($M.toDate(sYearMon), 'yyyyMMdd');
		}

		//그리드생성
		function createAUIGrid() {
			var gridPros = {
					rowIdField : "_$uid",
					showStateColumn : false,
					// 고정칼럼 카운트 지정
					useGroupingPanel : false,
					enableFilter :true,
					// No. 제거
					showRowNumColumn: true,
					groupingFields : ["agency_type_ca"],
					groupingSummary :{
						dataFields : ["all_misu", "misu_unsecure", "misu_sum", "schedule_money",
									  "pending_money", "total_bond", "bjngmoney", "dambomoney"],

						rows : [
							{
								operation: "SUM",
								text : "$value 소계",
								dataField : "agency_type_ca",
							}
						]
				    },
				 	// 그룹핑 썸머리행에 값을 채움
				    fillValueGroupingSummary : true,
					// 동일 선상은 groupingFields 의 마지막 필드인 name 에 일치시킵니다.
				    adjustSummaryPosition : true,
				    displayTreeOpen : true,
					enableCellMerge : false,
					showBranchOnGrouping : false,
					editable : false,
					// usePaging : true,
					enableMovingColumn : false,
			 		rowStyleFunction :  function(rowIndex, item) {
			 			 if(item._$isGroupSumField) {
			 				 return "my-row-style";
			 			 } else if (item.aui_status_cd !== "") {
			 				if(item.aui_status_cd == "D") { // 기본
			 					return "aui-status-default";
			 				} else if(item.aui_status_cd == "P") { // 진행예정
			 					return "aui-status-pending";
			 				} else if(item.aui_status_cd == "G") { // 진행중
			 					return "aui-status-ongoing";
			 				} else if(item.aui_status_cd == "R") { // 반려
			 					return "aui-status-reject-or-urgent";
			 				} else if(item.aui_status_cd == "C") { // 완료
			 					return "aui-status-complete";
			 				}
			 			}
		 			}
			};
			var columnLayout = [
				{
					// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
					// headerText : "대리점타입",
					headerText : "위탁판매점타입",
					dataField : "agency_type_ca",
					visible : false,
				},
				{
					dataField : "agency_pay_no",
					visible : false
				},
				{
					dataField : "agency_pay_status_cd",
					visible : false
				},
				{
					dataField : "org_code",
					visible : false
				},
				{
					headerText : "부서명",
					dataField : "org_name",
					width : "135",
					minWidth : "30",
					style : "aui-center aui-popup",
                    labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						if (item._$isGroupSumField) {
							var upperItem = AUIGrid.getItemByRowIndex(auiGrid, rowIndex-1);
							if (upperItem != null) {
								return upperItem.agency_type_ca;
							}
						}
						return value;
					},
					filter : {
						showIcon : true
					}
				},
				{
					// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
					// headerText : "대리점주",
					headerText : "위탁판매점주",
					dataField : "cust_name",
					style : "aui-center",
					width : "105",
					minWidth : "30",
				},
				{
					headerText : "전체미수계",
					dataField : "all_misu",
					width : "130",
					minWidth : "30",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right",
				},
				{
					headerText : "미확보미수",
					dataField : "misu_unsecure",
					width : "130",
					minWidth : "30",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right aui-popup",
				},
				{
					headerText : "미수금합계",
					dataField : "misu_sum",
					width : "130",
					minWidth : "30",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right",
				},
				{
					headerText : "지급예정",
					dataField : "schedule_money",
					width : "130",
					minWidth : "30",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right",
				},
				{
					headerText : "미확정수수료",
					dataField : "pending_money",
					width : "130",
					minWidth : "30",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right"
				},
				{
					headerText : "채권사항",
					children : [
						{
							headerText : "계",
							dataField : "total_bond",
							width : "130",
							minWidth : "30",
							dataType : "numeric",
							formatString : "#,##0",
							style : "aui-right aui-popup",
						},
						{
							headerText : "보증금",
							dataField : "bjngmoney",
							width : "130",
							minWidth : "30",
							dataType : "numeric",
							formatString : "#,##0",
							style : "aui-right",
						},
						{
							headerText : "담보금",
							dataField : "dambomoney",
							width : "130",
							minWidth : "30",
							dataType : "numeric",
							formatString : "#,##0",
							style : "aui-right",
						}
					]
				},
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				// 부서명 클릭시 월정산서관리-대리점 팝업 호출
				if(event.dataField == "org_name" ) {
					// 소계행 클릭시 호출 x
					if (event.item._$isGroupSumField) {
						return false;
					} else {
						var params = {
								pay_dt : event.item.pay_dt,
								org_code : event.item.org_code,
								agency_pay_no : event.item.agency_pay_no
						}
						var popupOption = "";
						$M.goNextPage('/acnt/acnt0402p03', $M.toGetParam(params), {popupStatus : popupOption});
					}
				}

				// 미확보미수 클릭시 장비미수명세 팝업 호출
				if(event.dataField == "misu_unsecure" ) {
					if (event.item._$isGroupSumField) {
						return false;
					} else {
						var params = {
								pay_dt : event.item.pay_dt,
								org_code : event.item.org_code,
						}
						var popupOption = "";
						$M.goNextPage('/acnt/acnt0402p01', $M.toGetParam(params), {popupStatus : popupOption});
					}
				}
				// 계 클릭 시 대리점 채권사항 메모 팝업 호출
				if(event.dataField == "total_bond" ) {
					if (event.item._$isGroupSumField) {
						return false;
					} else {
						var params = {
							org_code : event.item.org_code,
							s_sort_key 		: "seq_no",
							s_sort_method 	: "asc",
						}
						var popupOption = "";
						$M.goNextPage('/acnt/acnt0402p06', $M.toGetParam(params), {popupStatus : popupOption});
					}
				}
			});
		}

		// 기타비용관리 팝업
		function goAdd() {
			var params = {

			}
			var popupOption = "";
			$M.goNextPage('/acnt/acnt0402p02', $M.toGetParam(params), {popupStatus : popupOption});
		}

		function fnPayControl(val) {
			// 2 : 정산일경우
			if (val == 2) {
				$("#s_end_year").attr("disabled", false);
				$("#s_end_mon").attr("disabled", false);
				payControl = "31";
			} else {
				var date = new Date();
				var year = date.getFullYear();
				var mon = String(date.getMonth()+1);

	        	var sYearMon = year + mon;

				$M.setValue("s_end_year", year);
				$M.setValue("s_end_mon", mon);
				$("#s_end_year").attr("disabled", true);
				$("#s_end_mon").attr("disabled", true);
			}
		}

		// 엑셀다운로드
		function fnDownloadExcel() {
			var exportProps = {
			         // 제외항목
			  };
			// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
		  	// fnExportExcel(auiGrid, "대리점월정산", exportProps);
		  	fnExportExcel(auiGrid, "위탁판매점월정산", exportProps);
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
								<col width="70px">
								<col width="80px">
								<col width="70px">
								<col width="90px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<td>
										<select class="form-control" id="pay_control" name="pay_control" onchange="javascript:fnPayControl(this.value)">
											<option value="1">현재</option>
											<option value="2">정산</option>
										</select>
									</td>
									<td>
										<select class="form-control" id="s_end_year" name="s_end_year" disabled>
											<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
												<option value="${i}" <c:if test="${i==inputParam.s_end_year}">selected</c:if>>${i}년</option>
											</c:forEach>
										</select>
									</td>
									<td>
										<select class="form-control" id="s_end_mon" name="s_end_mon" disabled>
											<c:forEach var="i" begin="1" end="12" step="1">
												<option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>" <c:if test="${i==inputParam.s_end_mon}">selected</c:if>>${i}월</option>
											</c:forEach>
										</select>
									</td>
									<td>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="checkbox" id="s_all_yn"  name="s_all_yn" value="Y">
											<label class="form-check-input" for="s_all_yn">전체조회</label>
										</div>
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
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
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
