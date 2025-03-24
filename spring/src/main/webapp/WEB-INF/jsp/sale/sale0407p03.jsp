<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 판매관리 > MBO > MBO등록기간 > null
-- 작성자 : 정윤수
-- 최초 작성일 : 2023-04-03 10:15:49
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var auiGrid;
		var mngYn = "${page.fnc.F04643_001}" == "Y" ? "Y" : "N";
		$(document).ready(function () {
			createAUIGrid();
			goSearch();
		});



		// 행 추가
		function fnAdd() {
			var gridData = AUIGrid.getGridData(auiGrid);
			for(var i in gridData){
				if(gridData[i].start_dt == "" || gridData[i].end_dt == ""){
					alert("작성중인 차수의 시작일 또는 종료일을 확인해주세요.")
					return false;
				}
			}
			
			var item = new Object();

			item.sale_mbo_year = $M.getValue("s_search_year");
			item.seq_no = gridData.length > 0 ? gridData.length + 1 : 1;
			item.start_dt = "";
			item.end_dt = "";
			item.cmd = "C"

			AUIGrid.addRow(auiGrid, item, "last");
		}
		
		// 행삭제
		function fnRemove(){
			var gridData = AUIGrid.getGridData(auiGrid);
			var seqNo = gridData[gridData.length-1].seq_no;
			var year = $M.getValue("s_search_year");
			
			if(gridData[gridData.length-1].cmd == "C"){ // 마지막 row의 cmd값이 C면 removeRow 아니면 물리삭제
				AUIGrid.removeRow(auiGrid, gridData.length-1);
			} else{
				if(confirm("마지막 차수를 삭제하시겠습니까?") == false){
					return false;
				}
				$M.goNextPageAjax(this_page + "/remove/" + year + "/" + seqNo, "", {method : 'POST'},
					function (result) {
						if (result.success) {
							alert("삭제가 완료되었습니다.")
							location.reload();
						}
					}
				);
			}
		}

		
		function goSearch() {
			var param ={
				"s_search_year" : $M.getValue("s_search_year"),
			};

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
					function (result) {
						if (result.success) {
							AUIGrid.setGridData(auiGrid,result.list);
						}
					}
			);
		}

		// 저장
		function goSave() {
			if (fnChangeGridDataCnt(auiGrid) == 0) {
				alert("변경된 데이터가 없습니다.");
				return false;
			}
			var gridData = AUIGrid.getGridData(auiGrid);
			for(var i in gridData){
				if(gridData[i].start_dt == "" || gridData[i].end_dt == ""){
					alert("시작일과 종료일을 확인해주세요.")
					return false;
				}
			}
			var frm = fnChangeGridDataToForm(auiGrid, 'N');

			$M.goNextPageAjaxSave(this_page + "/save", frm, {method: "POST"},
					function (result) {
						if (result.success) {
							goSearch();
						}
					}
			);

		}

		// 창 닫기
		function fnClose() {
			window.close();
		}

		function createAUIGrid(title) {
			var gridPros = {
				rowIdField: "_$uid",
				// Row번호 표시 여부
				showRowNumColum: true,
				editable: true,
				showStateColumn : true,
				
			};
			var columnLayout = [
				{
					headerText: "MBO년도",
					dataField: "sale_mbo_year",
					width: "70",
					style: "aui-center",
					editable: false,
				},
				{
					headerText: "차수",
					dataField: "seq_no",
					width: "50",
					style: "aui-center",
					dataType : "numeric",
					formatString: "####",
					editable: false,
					editRenderer : {
						type : "InputEditRenderer",
						min : 1,
						onlyNumeric : true,
						// 에디팅 유효성 검사
						validator : AUIGrid.commonValidator
					}
				},
				{
					headerText: "차수시작일",
					dataField: "start_dt",
					width: "100",
					style: "aui-editable",
					editRenderer : {
						type : "JQCalendarRenderer", // datepicker 달력 렌더러 사용
						defaultFormat : "yyyy-mm-dd", // 원래 데이터 날짜 포맷과 일치 시키세요. (기본값: "yyyy/mm/dd")
						onlyCalendar : true, // 사용자 입력 불가, 즉 달력으로만 날짜입력 ( 기본값: true )
						maxlength : 8,
						onlyNumeric : true, // 숫자만
						showEditorBtnOver : true
					}
				},
				{
					headerText: "차수종료일",
					dataField: "end_dt",
					width: "100",
					style: "aui-editable",
					editRenderer : {
						type : "JQCalendarRenderer", // datepicker 달력 렌더러 사용
						defaultFormat : "yyyy-mm-dd", // 원래 데이터 날짜 포맷과 일치 시키세요. (기본값: "yyyy/mm/dd")
						onlyCalendar : true, // 사용자 입력 불가, 즉 달력으로만 날짜입력 ( 기본값: true )
						maxlength : 8,
						onlyNumeric : true, // 숫자만
						showEditorBtnOver : true
					}
				},
				{
					dataField: "cmd",
					visible : false,
				},
			];



			// 실제로 #grid_wrap에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
			
			if(mngYn == "N"){ // 관리자만 수정가능
				AUIGrid.setColumnPropByDataField(auiGrid, "start_dt", { style : "aui-center"} );
				AUIGrid.setColumnPropByDataField(auiGrid, "end_dt", { style : "aui-center"} );
			}
			
			AUIGrid.bind(auiGrid, "cellEditBegin", function(event) { // 관리자만 등록기간 수정 가능
				if(event.dataField == "start_dt" || event.dataField == "end_dt") {
					if(mngYn == "N"){
						return false;
					}
				}
			});
			
			AUIGrid.bind(auiGrid, "cellEditEndBefore", function(event) {
				var gridData = AUIGrid.getGridData(auiGrid);
				if(event.dataField == "start_dt") {
					if(event.rowIndex != 0) {
						if (event.value <= gridData[event.rowIndex - 1].start_dt || event.value <= gridData[event.rowIndex - 1].end_dt) {
							setTimeout(function () {
								AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "이전 차수의 시작일 또는 종료일보다 빠를 수 없습니다.");
							}, 1);
							return event.oldValue;
						}
					}
					if(event.item.end_dt != "" && event.value > event.item.end_dt){
						setTimeout(function() {
							AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "차수종료일보다 느릴 수 없습니다.");
						}, 1);
						return event.oldValue;
					}
				} else if(event.dataField == "end_dt"){
					if(event.rowIndex != 0) {
						if (event.value <= gridData[event.rowIndex - 1].end_dt) {
							setTimeout(function () {
								AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "이전 차수의 차수종료일보다 빠를 수 없습니다.");
							}, 1);
							return event.oldValue;
						}
					}
						if(event.value < event.item.start_dt){
						setTimeout(function() {
							AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "차수시작일보다 빠를 수 없습니다.");
						}, 1);
						return event.oldValue;
					}
				}
			})
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
		<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="contents">
				<div class="search-wrap mt10">
					<table class="table">
						<colgroup>
							<col width="70px">
							<col width="70px">
							<col width="70px">
							<col width="">
						</colgroup>
						<tbody>
						<tr>
							<th>조회년도</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-12">
										<select class="form-control" id="s_search_year" name="s_search_year" onchange="javascript:goSearch();">
											<c:forEach var="i" begin="2000" end="${inputParam.s_current_year + 1}" step="1">
												<option value="${i}" <c:if test="${i == inputParam.s_current_year}">selected</c:if>>${i}년</option>
											</c:forEach>
										</select>
									</div>
								</div>
							</td>
							<td>
								<div class="col-12">
									<button type="button" class="btn btn-important ml5" style="width: 50px;" onclick="goSearch()">조회</button>
								</div>
							</td>
							<td style="text-align : right;">
								<span class="text-warning">※ 행삭제 시 마지막 차수가 삭제됩니다.</span>
							</td>
						</tr>
						</tbody>
					</table>
				</div>
				<!-- 조회결과 -->
				<div class="title-wrap mt10">
					<h4 id="title">조회결과</h4>
					<div class="btn-group">
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
						</div>
					</div>
				</div>
				<!-- /조회결과 -->
				<div id="auiGrid" style="margin-top: 5px; height: 350px;"></div>
				<div class="btn-group mt5">
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
					</div>
				</div>
			</div>
			<!-- 하단 버튼 -->
		</div>
		<!-- /contents 전체 영역 -->
	</div>
	<!-- /팝업 -->
</form>
</body>
</html>