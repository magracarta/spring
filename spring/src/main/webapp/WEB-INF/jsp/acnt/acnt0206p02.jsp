<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 인사 > 자산현황 및 재무제표 > 재무상태표 > 재무상태표 엑셀업로드
-- 작성자 : 황빛찬
-- 최초 작성일 : 2023-10-25 11:37:00
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var auiGrid;
		var thisHeaderText;
		var beHeaderText;
		$(document).ready(function () {
			thisHeaderText = $M.toNum($M.getValue("s_year").substr(2, 3)) + 2;
			beHeaderText = $M.toNum($M.getValue("s_year").substr(2, 3)) + 1;

			createAUIGrid();
			changeDate();
		});

		// 날짜 Setting
		function fnSetYearMon(year, mon) {
			return year + (mon.length == 1 ? "0" + mon : mon);
		}

		// 저장
		function goSave() {
			if ($M.validation(document.main_form) == false) {
				return;
			}

			$M.setValue("finan_mon", fnSetYearMon($M.getValue("s_year"), $M.getValue("s_mon")));
			$M.setValue("this_cnt", thisHeaderText);
			var frm = $M.toValueForm(document.main_form);

			var concatCols = [];
			var concatList = [];
			var gridIds = [auiGrid];
			for (var i = 0; i < gridIds.length; ++i) {
				concatList = concatList.concat(AUIGrid.exportToObject(gridIds[i]));
				concatCols = concatCols.concat(fnGetColumns(gridIds[i]));
			}

			var gridForm = fnGridDataToForm(concatCols, concatList);
			$M.copyForm(gridForm, frm);

			console.log("gridForm : ", gridForm);

			$M.goNextPageAjaxSave(this_page + "/save", gridForm, {method: "POST"},
					function (result) {
						if (result.success) {
							window.opener.goSearch();
							$M.setValue("s_year", $M.getValue("s_year"));
							$M.setValue("s_mon", $M.getValue("s_mon"));
							changeDate('save');
						}
					}
			);
		}

		// 날짜변경
		function changeDate(type){
			if (type != 'save') {
				if(fnChangeGridDataCnt(auiGrid) != 0){
					var check = confirm("변경한 내역을 저장하지않고 넘어가시겠습니까?");
					if(!check){
						return false;
					}
				}
			}

			var param = {
				"s_finan_mon" : fnSetYearMon($M.getValue("s_year"), $M.getValue("s_mon"))
			}
			
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), { method : "GET" }, function(result){
				if(result.success){
					thisHeaderText = $M.toNum($M.getValue("s_year").substr(2, 3)) + 2;
					beHeaderText = $M.toNum($M.getValue("s_year").substr(2, 3)) + 1;

					var changeColumnLayout = [
						{
							headerText : "과목",
							dataField : "finan_name",
							width : "200",
							minWidth : "100",
						},
						{
							headerText : "제 " + thisHeaderText + " (당)기",
							children : [
								{
									dataField : "this_1_amt",
									headerText : "금액",
									width : "150",
									minWidth : "150",
									dataType: "numeric",
									formatString: "#,##0",
									style : "aui-right",
								},
								{
									dataField : "this_2_amt",
									headerText : "금액",
									width : "150",
									minWidth : "150",
									dataType: "numeric",
									formatString: "#,##0",
									style : "aui-right",
								},
							]
						},
						{
							headerText : "제 " + beHeaderText + " (전)기",
							children : [
								{
									dataField : "be_1_amt",
									headerText : "금액",
									width : "150",
									minWidth : "150",
									dataType: "numeric",
									formatString: "#,##0",
									style : "aui-right",
								},
								{
									dataField : "be_2_amt",
									headerText : "금액",
									width : "150",
									minWidth : "150",
									dataType: "numeric",
									formatString: "#,##0",
									style : "aui-right",
								},
							]
						},
					];
					AUIGrid.changeColumnLayout(auiGrid, changeColumnLayout);

					AUIGrid.clearGridData(auiGrid);
					AUIGrid.setGridData(auiGrid,result.list);
				}
			});
		}
		
		function fnReset(){
			var check = confirm("초기화하시겠습니까?");
			if(!check){
				return false;
			}
			AUIGrid.clearGridData(auiGrid);
		}
		
		// 닫기
		function fnClose() {
			window.close();
		}

		function createAUIGrid() {
			var gridPros = {
				noDataMessage : "엑셀에서 데이터를 복사(Ctrl+C) 하여 이곳에 붙여 넣기(Ctrl+V) 하십시오.",
				rowIdField : "_$uid",
				editable : true, // 수정 모드
				editableOnFixedCell : true,
				selectionMode : "multipleCells", // 다중셀 선택
				showStateColumn : true,
				softRemovePolicy :"exceptNew",
				wrapSelectionMove : true, // 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
				enableFilter : true,
				softRemoveRowMode : false,
				// 체크박스 출력 여부
				showRowCheckColumn : false,
				// 전체선택 체크박스 표시 여부
				showRowAllCheckBox : false,
				showAutoNoDataMessage : false,
			};

			var columnLayout = [
				{
					headerText : "과목",
					dataField : "finan_name",
					width : "200",
					minWidth : "100",
				},
				{
					headerText : "제 " + thisHeaderText + " (당)기",
					children : [
						{
							dataField : "this_1_amt",
							headerText : "금액",
							width : "150",
							minWidth : "150",
							dataType: "numeric",
							formatString: "#,##0",
							style : "aui-right",
						},
						{
							dataField : "this_2_amt",
							headerText : "금액",
							width : "150",
							minWidth : "150",
							dataType: "numeric",
							formatString: "#,##0",
							style : "aui-right",
						},
					]
				},
				{
					headerText : "제 " + beHeaderText + " (전)기",
					children : [
						{
							dataField : "be_1_amt",
							headerText : "금액",
							width : "150",
							minWidth : "150",
							dataType: "numeric",
							formatString: "#,##0",
							style : "aui-right",
						},
						{
							dataField : "be_2_amt",
							headerText : "금액",
							width : "150",
							minWidth : "150",
							dataType: "numeric",
							formatString: "#,##0",
							style : "aui-right",
						},
					]
				},
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);

			$("#auiGrid").resize();

			// cellEditEndBefore 이벤트 바인딩
			AUIGrid.bind(auiGrid,  "cellEditEndBefore", function(event) {
				// 검증 결과 컬럼엔 복사 안되도록 추가
				if(event.isClipboard) {
					return event.value;
				} else {
					// 엑셀데이터 붙여넣기가 아닌경우엔 수정 불가
					return event.oldValue;
				}
			});

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
			<!-- 검색조건 -->
			<div class="search-wrap mt5">
				<table class="table">
					<colgroup>
						<col width="10px">
						<col width="300px">
					</colgroup>
					<tbody>
					<tr>
						<th>년월</th>
						<td>
							<div class="form-row inline-pd">
								<div class="col-auto">
									<select class="form-control" id="s_year" name="s_year" required="required" onchange="javascript:changeDate();">
										<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
											<c:set var="year_option" value="${inputParam.s_current_year - i + 2000}"/>
											<option value="${year_option}" <c:if test="${year_option eq inputParam.s_year}">selected</c:if>>${year_option}년</option>
										</c:forEach>
									</select>
								</div>
								<div class="col-auto">
									<select class="form-control" id="s_mon" name="s_mon" required="required" onchange="javascript:changeDate();">
										<c:forEach var="i" begin="1" end="12" step="1">
											<option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>" <c:if test="${i eq inputParam.s_mon}">selected</c:if>>${i}월</option>
										</c:forEach>
									</select>
								</div>
							</div>
						</td>
					</tr>
					</tbody>
				</table>
			</div>
			<!-- /검색조건 -->
			<div class="title-wrap mt10">
				<h4>엑셀업로드</h4>
				<div class="right">
					<div class="text-warning ml5">
						※ 엑셀에서 데이터를 복사(Ctrl+C) 하여 이곳에 붙여넣기(Ctrl+V) 하십시오.<br>
						※ 더존 경로 : 회계관리 > 결산/재무제표관리 > 재무상태표 > 세목별 탭
					</div>
				</div>
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
				</div>
			</div>
			<div id="auiGrid" style="margin-top: 5px; height: 450px;"></div>

			<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt10">
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
			<!-- /그리드 서머리, 컨트롤 영역 -->
		</div>
	</div>
	<!-- /팝업 -->
</form>
</body>
</html>