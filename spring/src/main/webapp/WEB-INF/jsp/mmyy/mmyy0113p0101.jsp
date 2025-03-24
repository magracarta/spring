<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 일일현황판 > 일일현황판 등록 > 업무참조 목록
-- 작성자 : 정선경
-- 최초 작성일 : 2023-04-28 11:51:27
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var auiGrid;

		$(document).ready(function(){
			createAUIGrid();
			goSearch();
		});

		function goSearch() {
			var param = {
				"s_search_dt" : $M.getValue("s_search_dt"),
				"s_org_code" : $M.getValue("board_org_code"),
				"board_dt" : $M.getValue("board_dt"),
				"s_masking_yn" : $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N"
			};
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
					function(result) {
						if(result.success) {
							AUIGrid.setGridData(auiGrid, result.list);
							$("#total_cnt").html(result.total_cnt);
						};
					}
			);
		}

		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn : true,
				enableSorting : true,
				editable : false,
				fillColumnSizeMode : true,
			};
			var columnLayout = [
				{
					dataField: "day_board_type_cd",
					visible: false
				},
				{
					headerText: "업무구분",
					dataField: "day_board_type_name",
					width : "80",
					minWidth : "60",
					style: "aui-center"
				},
				{
					headerText : "예정일자",
					dataField : "plan_dt",
					dataType : "date",
					formatString : "yyyy-mm-dd",
					style : "aui-center",
					width : "100",
					minWidth : "80"
				},
				{
					headerText : "정비희망시간",
					dataField : "repair_request_ti",
					style : "aui-center",
					width : "80",
					minWidth : "80",
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if (value == null || value == "" || value == undefined) {
							return "aui-background-darkgray";
						}
						return false;
					}
				},
				{
					headerText: "고객명",
					dataField: "cust_name",
					width : "100",
					minWidth : "80",
					style: "aui-center"
				},
				{
					headerText: "연락처",
					dataField: "hp_no",
					width : "120",
					minWidth : "80",
					style: "aui-center"
				},
				{
					headerText: "모델명",
					dataField: "machine_name",
					width : "100",
					minWidth : "80",
					style: "aui-center"
				},
				{
					headerText: "차대번호",
					dataField: "body_no",
					width : "140",
					minWidth : "130",
					style: "aui-center"
				},
				{
					headerText: "원담당자",
					dataField: "origin_mem_name",
					width : "100",
					minWidth : "80",
					style: "aui-center",
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if (value == null || value == "" || value == undefined) {
							return "aui-background-darkgray";
						}
						return false;
					}
				},
				{
					dataField: "cap_cnt",
					visible: false
				},
				{
					dataField: "area_name",
					visible: false
				},
				{
					dataField: "todo_text",
					visible: false
				},
			]
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);

			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				// Row행 클릭 시 반영
				try{
					// 지정한 업무일자와 예정일자가 동일한 업무만 참조 가능
					// 미회수는 예정일자가 지정한 업무일자 이전인 경우 가능
					// Q&A 17423 Re 3-1. 날짜 제한 풀도록 요청
					// if (event.item['day_board_type_cd'] == 'RENTAL_RETURN' && event.item['rental_status_cd'] != '08') {
					// 	// if ($M.getValue("board_dt") != $M.getValue("s_search_dt")) {
					// 	if ($M.getValue("board_dt") < event.item['plan_dt']) {
					// 		alert("[렌탈회수] 선택한 업무일자가 예정일자가 동일하거나 이전인 업무만 참조 가능합니다.");
					// 		return false;
					// 	}
					// } else {
					// 	if ($M.getValue("board_dt") != $M.getValue("s_search_dt")) {
					// 		alert("선택한 업무일자와 예정일자가 동일한 업무만 참조 가능합니다.");
					// 		return false;
					// 	}
					// }
					opener.${inputParam.parent_js_name}(event.item);
					window.close();
				} catch(e) {
					alert('호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.');
				}
			});
		}

		// 닫기
		function fnClose() {
			window.close();
		}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
	<input type="hidden" name="board_org_code" value="${inputParam.board_org_code}">
	<input type="hidden" name="board_dt" value="${inputParam.board_dt}">

	<div class="popup-wrap width-100per">
		<!-- 메인 타이틀 -->
		<div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
		</div>
		<!-- /메인 타이틀 -->
		<div class="content-wrap">
			<!-- 검색조건 -->
			<div class="search-wrap mt5">
				<table class="table">
					<colgroup>
						<col width="65px">
						<col width="120px">
						<col width="">
					</colgroup>
					<tbody>
					<tr>
						<th>예정일자</th>
						<td>
							<div class="form-row inline-pd" style="padding-left: 10px;">
								<div class="input-group">
									<input type="text" class="form-control border-right-0 calDate" id="s_search_dt" name="s_search_dt" dateFormat="yyyy-MM-dd"  value="${inputParam.board_dt}" alt="예정일자">
								</div>
							</div>
						</td>
						<td class=""><button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button></td>
					</tr>
					</tbody>
				</table>
			</div>
			<!-- /검색조건 -->

			<!-- 검색결과 -->
			<div class="title-wrap mt10">
				<h4>조회결과</h4>
				<div class="btn-group">
					<div class="right">
						<c:if test="${page.add.POS_UNMASKING eq 'Y'}">
							<div class="form-check form-check-inline">
								<input  class="form-check-input"  type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y" >
								<label  class="form-check-input"  for="s_masking_yn" >마스킹 적용</label>
							</div>
						</c:if>
					</div>
				</div>
			</div>
			<div id="auiGrid" style="margin-top: 5px; height: 320px;"></div>
			<div class="btn-group mt10">
				<div class="left">
					총 <strong class="text-primary" id="total_cnt">0</strong>건
				</div>
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
			<!-- /검색결과 -->
		</div>
	</div>
</form>
</body>
</html>