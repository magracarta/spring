<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 장부 > 운송사별운임정산 > 전체집계 > null
-- 작성자 : 황빛찬
-- 최초 작성일 : 2020-04-08 18:03:57
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var auiGrid;
		$(document).ready(function() {
			createAUIGrid();
			fnInit();
			goSearch();
		});

		function fnInit() {
			var now = "${inputParam.s_current_dt}";
// 			$M.setValue("s_start_dt", $M.addMonths($M.toDate(now), -1));
		}

		// 엑셀 다운로드
		function fnDownloadExcel() {
			var exportProps = {
			         // 제외항목
			  };
		  	fnExportExcel(auiGrid, "운송사별 운임정산", exportProps);
		}

		// 운송사 코드 관리 팝업
		function goSetting(){
			var param = {
				group_code : "TRANSPORT_CMP",
				all_yn : "Y",
			}
			openGroupCodeDetailPanel($M.toGetParam(param));
		}

		function createAUIGrid() {
			var gridPros = {
				// Row번호 표시 여부
				showRowNumColumn : false,
				enableFilter :true,
				showFooter : true,
				footerPosition : "top",
			};

			var columnLayout = [
				{
					headerText : "코드",
					dataField : "code_value",
					width : "5%",
					style : "aui-center"
				},
				{
					headerText : "운송사명",
					dataField : "code_name",
					width : "15%",
					style : "aui-center aui-popup",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "처리건수",
					dataField : "",
					children : [
						{
							headerText : "정산",
							dataField : "calc1",
							dataType : "numeric",
							formatString : "#,##0",
							style : "aui-right"
						},
						{
							headerText : "미정산",
							dataField : "calc2",
							dataType : "numeric",
							formatString : "#,##0",
							style : "aui-right"
						},
						{
							headerText : "계",
							dataField : "total_calc",
							dataType : "numeric",
							formatString : "#,##0",
							style : "aui-right",
							expFunction : function(  rowIndex, columnIndex, item, dataField ) {
								// 합계 계산
								return (item.calc1 + item.calc2);
							}
						}
					]
				},
				{
					headerText : "운임",
					dataField : "",
					children : [
						{
							headerText : "정산",
							dataField : "transport1",
							dataType : "numeric",
							formatString : "#,##0",
							style : "aui-right"
						},
						{
							headerText : "미정산",
							dataField : "transport2",
							dataType : "numeric",
							formatString : "#,##0",
							style : "aui-right"
						},
						{
							headerText : "계",
							dataField : "total_transport",
							dataType : "numeric",
							formatString : "#,##0",
							style : "aui-right",
							expFunction : function(  rowIndex, columnIndex, item, dataField ) {
								// 합계 계산
								return (item.transport1 + item.transport2);
							}
						}
					]
				}
			];

			// 푸터 설정
			var footerLayout = [
				{
					labelText : "합계",
					positionField : "code_name",
					style: "aui-center aui-footer"
				},
				{
					dataField: "calc1",
					positionField: "calc1",
					operation: "SUM",
					formatString : "#,##0",
					style: "aui-right aui-footer"
				},
				{
					dataField: "calc2",
					positionField: "calc2",
					operation: "SUM",
					formatString : "#,##0",
					style: "aui-right aui-footer"
				},
				{
					dataField: "total_calc",
					positionField: "total_calc",
					operation: "SUM",
					formatString : "#,##0",
					style: "aui-right aui-footer"
				},
				{
					dataField: "transport1",
					positionField: "transport1",
					operation: "SUM",
					formatString : "#,##0",
					style: "aui-right aui-footer"
				},
				{
					dataField: "transport2",
					positionField: "transport2",
					operation: "SUM",
					formatString : "#,##0",
					style: "aui-right aui-footer"
				},
				{
					dataField: "total_transport",
					positionField: "total_transport",
					operation: "SUM",
					formatString : "#,##0",
					style: "aui-right aui-footer"
				}
			];
			// 실제로 #grid_wrap에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 푸터 레이아웃 세팅
			AUIGrid.setFooter(auiGrid, footerLayout);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();

			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField == "code_name") {
					parent.openTab2();
					console.log("event : ", event);
					var param = {
							// TODO : 운송사코드, 날짜, 처리구분, 작성기간전 밈정산자료포함여부 같이 넘겨줘야함
							s_code_value : event.item.code_value,  // 운송사코드
							s_calc_yn : $M.getValue("s_calc_yn"),  // 처리구분 - (미정산분(Y), 전체(N))
							s_all_calc_yn : $M.getValue("s_all_calc_yn"),  // 작성기간전 미정산자료포함여부 (Y 포함)
							s_start_dt : $M.getValue("s_start_dt"),
							s_end_dt : $M.getValue("s_end_dt"),
							s_sort_key : "machine_no",
							s_sort_method : "asc",
							click_yn : "Y"  // 전체집계탭에서 운송사를 클릭하여 넘어갈경우 체크할 파라미터
					}

					console.log("param : ", param);
// 					$M.goNextPage("/acnt/acnt020403/search", $M.toGetParam(param));
					$M.goNextPage("/acnt/acnt020403", $M.toGetParam(param));
// 					parent.openTab2();
				}
			});
		}

		// 검색기능
		function goSearch() {
			var param = {
					s_calc_yn : $M.getValue("s_calc_yn"),  // 처리구분 - (미정산분(Y), 전체(N))
					s_all_calc_yn : $M.getValue("s_all_calc_yn"),  // 작성기간전 미정산자료포함여부 (Y 포함)
					s_start_dt : $M.getValue("s_start_dt"),
					s_end_dt : $M.getValue("s_end_dt"),
					s_sort_key : "code",
					s_sort_method : "asc"
				};
			_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
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
<body style="background : #fff">
<form id="main_form" name="main_form">
	<div class="layout-box">
		<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
				<!-- 메인 타이틀 -->
				<!-- /메인 타이틀 -->
				<div class="contents">
					<!-- 기본 -->
					<div class="search-wrap mt10">
						<table class="table">
							<colgroup>
								<col width="60px">
								<col width="260px">
								<col width="65px">
								<col width="120px">
								<col width="190px">
								<col width="">
							</colgroup>
							<tbody>
							<tr>
								<th>작성기간</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col-5">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" value="${searchDtMap.s_start_dt}">
											</div>
										</div>
										<div class="col-auto">~</div>
										<div class="col-5">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" value="${searchDtMap.s_end_dt}">
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
								<th>처리구분</th>
								<td>
									<select class="form-control" id="s_calc_yn" name="s_calc_yn">
										<option value="N">미정산분</option>
										<option value="Y">정산분</option>
										<option value="A">전체</option>
									</select>
								</td>
								<td class="pl10">
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="checkbox" value="Y" id="s_all_calc_yn" name="s_all_calc_yn">
										<label class="form-check-label" for="s_all_calc_yn">작성기간전 미정산자료포함</label>
									</div>
								</td>
								<td>
									<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
								</td>
							</tr>
							</tbody>
						</table>
					</div>
					<!-- /기본 -->
					<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap mt10">
						<h4>조회결과</h4>
						<div class="btn-group">
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
					<!-- /그리드 타이틀, 컨트롤 영역 -->
					<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
					<!-- 그리드 서머리, 컨트롤 영역 -->
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
		</div>
		<!-- /contents 전체 영역 -->
	</div>
</form>
</body>
</html>